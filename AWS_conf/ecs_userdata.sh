#!/bin/bash
echo ECS_CLUSTER=VNIDEFR01-PRECS01 >> /etc/ecs/ecs.config

yum -y install openldap-clients nss-pam-ldapd
authconfig --useshadow --usemd5 --enableldap --enableldapauth --ldapserver=192.150.10.10 --ldapbasedn="dc=vni,dc=com" --enablemkhomedir --updateall

sed -i -- 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

service sshd restart