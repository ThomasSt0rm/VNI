# Steps taken

## First things first

### Clean up

It is always better to have a fresh start.
So I deleted already existing VPC, 3 subnets, IGW, deactivated API key.

### Set the repo

There are few folders in the repo:
* **Docs** - documentation
* **Servers_conf** - configuration management playbooks
* **AWS_conf** - AWS configuration playbooks
* **Toolkit** - few scripts to use

### Initial network infrastructure.

Assuming all the requirements, I've decided to build solution in 1 VPC, containing 4 subnets: 2 private and 2 public
Naming convention has been taken. VNI - for a company name, DE - for German region, Frankfurt - for a city, 01 - order number. After regional part there is a dash with explanation: like RT for route table and SG for security group

In the end my VPC name is VNIDEFR01. CIDR range is 192.150.0.0/16
My subnets:
* VNIDEFR01-PUB01:  192.150.1.0/28
* VNIDEFR01-PUB02:  192.150.2.0/28
* VNIDEFR01-PRIV01: 192.150.9.0/24
* VNIDEFR01-PRIV02: 192.150.10.0/24

Public subnets are used only for ELB, NAT Gateways and Internet Gateways.
Route tables allow access to internet. For public subnets IGW is used, for private - NAT (for updates and access to 3rd party networks)
Since this is not a complex task, I only cover firewalling in Security Groups, not touching NACLs.
However, best practice is also to use NACL security.


### Servers

For primary task it is required to build Directory Service.
To acomplish this task 1 small EC2 instance will be used.

I'm not going to use Ansible for configuration management of this machine. This machine will be configured manually. In "why" section you can find explanation of my 'selective' automation.


### Directory Service

I've created a small t2.micro server in Private subnet.
To install and configure OpenLDAP I followed [this](http://www.itskarma.wtf/openldap-on-ec2/) guide.
User info is stored [here](https://github.com/ThomasSt0rm/VNI/blob/master/Docs/Users.md)

Password are encrypted with a hash. To decrypt them you need to use "decryptor.py' stored in a Toolkit directory, providing the secret_key and encrypted password as an argument.
Simply run it like this:

` python decryptor.py secret_key encrypted_password `

Once configured with default settings end users there is AMI (Amazon Machine Image) created. When needed to redeploy from scratch, I can use this AMI, so I don't need to configure OpenLDAP again.

In 'Why' section there is also expalained why I chose OpenLDAP as identity provider.

All the 'client' machines (AppServers) are also configured to allow authentication via LDAP.
To do so, all I have to do is:
1. Setup LDAP client (as in the guide above)
2. Configure password auth in SSH daemon

This will be done automagically by Ansible playbook + AWS dynamic inventory, but also with user_data within launch configuration.
Best practice is to keep special Management server for Ansible playbook for server configuration management, but to avoid unnecessary hosts, I will install Ansible on Bastion host.


### Application Servers

It is required to provide 2 Application Servers to run Docker containers.
Since we need to have some sort of orchestration, there are my options:
1. EC2 Container Service
2. Kubernetes
3. CoreOS/Mesos
4. Docker Swarm

My choice goes for ECS, all explanation can be found in 'Why' section.
I will use Ansible playbook to provision ECS cluster and use Bastion with Ansible to install LDAP client settings on cluster.

The cluster itself is built within 3 steps in Ansible playbook:
1. Create empty cluster
2. Create Launch Confirguration for ECS nodes
3. Create AutoScaling Group for Node


LC contains user_data, so ECS servers will automatically register themselves in the cluster and have necessary LDAP settings.

Technically the infrastructure part of this task is done.
To actually build the whole infrastructure, you need to run main playbook.
It will bring you:
1. VPC with network settings
2. LDAP server from the AMI with all LDAP settings
3. Bastion host with LDAP settings
4. ECS cluster with LDAP settings

That's the core infrastructure to help VNI to accomplish it's mission in Germany.
For the demo purposes I'm going to create some repos and pipeline in AWS.



## For Demo purpose

### About ECS services

ECS is a container orchestration service from AWS. By design, you spin up several EC2 instances which are running container optimized AMI in the AutoScaling group.
When you have your cluster running, you can start launching containers in it. AWS Documentation states that you need to build task definitions in order to run container.
Task Definition is a detailed setting for a container, containing:
* image
* network settings
* storage/volume settings
* resource settings

You can use any type of repository: Docker Hub, ECR (Elastic Container Registry) or other private image repository
When task definition is done, you can run it as a services (also defining amount of containers) or a batch task.

For example, if you have a Docker application which does some analytical job, but doesn't need to be ran continiously, you can run task by schedule.
In case if your application needs to be running 24/7 (web server, web service, Database) you can build a service from it.

### Actual Demo

To provide you with some insights, I'm going to run a small service with a Docker container which gets JSON data from bittrex.com and stores in the logs.
I'm going to use internal AWS repo and also build CodePipelin to build, test, package and store Docker image in ECR.

Developers will be able to read the logs from the AWS console, but if the need to do some debugging manually, they can also SSH to ECS nodes and run docker commands (like docker logs or docker inspect) from inside of the node.

### Demo ECS details

There is a cluster VNIDEFR01-PRECS01 running in AWS.
Container images are stored in ECR repository under a name 'demorepo'
Whole CI/CD process is managed by CodePipeline working alon with CodeCommit and CodeBuild.

When developer will push new code to the repository, CodePipeline will trigger a build on a CodeBuild.
Since this is a demo project only thing that CodeBuild does is to put Python script into a docker image.
The new image will be automatically deployed to the ECR.

The only manual part to be done is to create a new revision of the Task definition - which basically means 'Deploy new image to production'.

However, using CodePipeline with ECS can be a pain. For example, it only supports CodeBuild projects which have artifact settings.
As a workaround, I've created a bucket on S3, which will only remain blank, because an actual artifact (Docker image) is being rolled directly into the ECR. So there will be no extra costs for that.

In that case obvious question is - why use CodePipeline. You see, CodePipeline is the only AWS server which will trigger the build on push to CodeCommit, since CodeBuild can not trigger itself.

The actual steps for a Demo Pipeline
1. New code is being pushed
2. CodePipeline triggers a build
3. CodeBuild will put a new Docker image in ECR

In ECS there is also a demo service 'demo_services' which runs multiple instances of the task, the logs can be accessed in AWS CloudWatch.