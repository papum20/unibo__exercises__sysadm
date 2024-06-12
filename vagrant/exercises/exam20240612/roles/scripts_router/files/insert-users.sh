#!/bin/bash

if [[ -z $1 ]]
then
	echo "missing argument: FILE"
	exit 1
fi

FILE=$1

PATH_KEYS=/home/vagrant/keys/

if [[ ! -e $PATH_KEYS ]]
then
	mkdir $PATH_KEYS
fi

egrep '^[^#].*;.*;.*$' $FILE | tr ';' ' ' | while read USERNAME USERID PASSWORD ; do
	echo $USERNAME $USERID $PASSWORD

	# insert user
    ldapadd -x -H ldapi:/// -D "cn=admin,dc=labammsis" -w "gennaio.marzo" <<LDIF
dn: uid=$USERNAME,ou=People,dc=labammsis
objectClass: top
objectClass: posixAccount
objectClass: shadowAccount
objectClass: inetOrgPerson
givenName: $USERNAME
cn: $USERNAME
sn: $USERNAME
mail: $USERNAME@$USERNAME.com
uid: $USERNAME
uidNumber: $USERID
gidNumber: $USERID
homeDirectory: /home/$USERNAME
loginShell: /bin/bash
gecos:$USERNAME
userPassword: $PASSWORD
LDIF

	# insert group
	ldapadd -x -H ldap:/// -D "cn=admin,dc=labammsis" -w "gennaio.marzo" <<LDIF
dn: cn=$USERNAME,ou=Groups,dc=labammsis
objectClass: top
objectClass: posixGroup
cn: $USERNAME
gidNumber: $USERID
LDIF
	
	# key (first remove if already present)
	if [[ -e "${PATH_KEYS}/$USERNAME" ]]
	then
		rm "${PATH_KEYS}/$USERNAME"
	fi
	if [[ -e "${PATH_KEYS}/$USERNAME.pub" ]]
	then
		rm "${PATH_KEYS}/$USERNAME.pub"
	fi
	ssh-keygen -f ${PATH_KEYS}$USERNAME -N ' '

	# syslog
	for S in 10.22.22.{100..120} ; do
		logger -p local1.info -n $S <<< "$USERNAME"
	done
	for C in 10.11.11.{100..120} ; do
		logger -p local1.info -n $C <<< "$USERNAME"
	done

	# add command to snmpd
	sudo echo "extend-sh ${USERNAME}_PUB /usr/bin/sudo /usr/bin/cat ${PATH_KEYS}${USERNAME}.pub" >> /etc/snmp/snmpd.conf
	sudo echo "extend-sh ${USERNAME}_PRIV /usr/bin/sudo /usr/bin/cat ${PATH_KEYS}$USERNAME" >> /etc/snmp/snmpd.conf

done

# give back ownership to vagrant, as must be executed with sudo
chown vagrant:vagrant ${PATH_KEYS}/*

# restart snmpd once for all
sudo systemctl restart snmpd.service
