# Steps taken

## First things first

### Clean up

It is always better to have a fresh start.
So I deleted already existing VPC, 3 subnets, IGW, deactivated API key

### Set the repo

There are few folders in the repo
* **Docs** - documentation
* **Servers_conf** - configuration management playbooks
* **AWS_conf** - AWS configuration playbooks
* **Toolkit** - few scripts to use

### Initial network infrastructure.

Assuming all requirements, i've decided to build solution in 1 VPC, containing 4 subnets: 2 private and 2 public
Naming convention has been taken. VNI - for a company name, DE - for German region, Frankfurt - for a city, 01 - location number. After regional part there is a dash with explanation: like RT for route table and SG for security group

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

My chose goes for ECS, all explanation can be found in 'Why' section.
I will use Ansible playbook to provision ECS cluster and use Bastion with Ansible to install LDAP client settings on cluster.

The cluster itself is built within 3 steps in Ansible playbook:
1. Create empty cluster
2. Create Launch Confirguration for ECS nodes
3. Create AutoScaling Group for Node


LC contains user_data, so ECS servers will automatically register themselves in the cluster and have necessary LDAP settings.