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