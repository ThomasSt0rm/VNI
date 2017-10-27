# Why?

Asking why and answering this question is something each engineer and architect is doing every day.
Hereby you can find my explanation on tooling and way of working.
First of all.

# Why Ansible?

I've been working with Ansible since 2014 and I am very used to it. Agentless architecture and dynamic inventory make Ansible able to deploy really fast.
In addition to that, Ansible has 'Cloud' modules used to work with different providers.
Playbooks in Ansible are easy to read and understand, roles allow you to predefine your desired state configuration for servers.
Also Ansible is really nice with performance. For example it takes about 4-5 minutes to build *whole* infrastructure.



## Why not automate deployment of Directory Server?

First of all, i was trying to use AWS Directory Service.
Unfortunately, AWS DS can yet work only as:

* user pool by Cognito (used for mobile auth)
* federated Active Directory

Which means I can't simply create my domain.
In the end I've decided just to build OpenLDAP server, which works like a charm.

I had to do a lot of manual operations from the guide found in Google, so it is a good practice to automate those.
However LDAP server is thing you don't build that often. So for me easiest and quickest way was to build a setup and save it as an AMI.