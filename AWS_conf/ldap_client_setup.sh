#!/bin/bash
sudo yum install -y openldap-clients nss-pam-ldapd
authconfig --useshadow --usemd5 --enableldap --enableldapauth --ldapserver=192.150.10.10 --ldapbasedn="dc=vni,dc=com" --enablemkhomedir --updateall
sudo sed -i -- 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo service sshd restart