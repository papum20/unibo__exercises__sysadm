#!/bin/bash

SERVER=10.200.1.254


# get uid/gid
function SEARCH_USERS {
	ldapsearch -x -D "cn=admin,dc=labammsis" -w "gennaio.marzo" -H ldap://$SERVER/ -b "ou=People,dc=labammsis" -s sub
}
function SEARCH_GROUPS {
	ldapsearch -x -D "cn=admin,dc=labammsis" -w "gennaio.marzo" -H ldap://$SERVER/ -b "ou=Groups,dc=labammsis" -s sub
}

UID=$(SEARCH_USERS | egrep 'uidNumber: ' | sort -u | tail -1 | cut -d' ' -f2)
GID=$(SEARCH_USERS | egrep 'gidNumber: ' | sort -u | tail -1 | cut -d' ' -f2)
UID=$(($UID+1))
GID=$(($GID+1))

echo "Uid, Gid: $UID, $GID"


ASK_USERNAME="Username (matching '[a-z]*'): "

echo $ASK_USERNAME

while read USERNAME ; do
	if [[ $(egrep -o '[a-z]*' <<< $USERNAME) != $USERNAME ]]
	then
		echo "only [a-z]*"
		echo $ASK_USERNAME
		continue
	fi
	if [[ -n $(egrep "^uid: $USERNAME$" <<< $SEARCH_USERS) ]]
	then
		echo "Already taken"
		echo $ASK_USERNAME
		continue
	fi
	break
done

echo "Username: $USERNAME"

GRPS="$(SEARCH_GROUPS | egrep '^cn: ' | cut -d' ' -f2)"

echo "Available groups: $GRPS" 


ASK_GROUP="Choose one of the given groups: "

echo $ASK_GROUP

while read GRP ; do
	if [[ -z $(egrep "^$GRP$" <<< $GRPS) ]]
	then
		echo "Group not found"
		echo $ASK_GROUP
		continue
	fi
	break
done


echo "Group: $GRP"

GID=$(SEARCH_GROUPS |egrep 'cn: temp' -A 1 | egrep 'gidNumber: ' | cut -d' ' -f2)


ldapadd -x -D "cn=admin,dc=labammsis" -w "gennaio.marzo" -H ldap://10.200.1.254/ -v <<ENTRY
dn: uid=$USERNAME,ou=People,dc=labammsis
objectClass: top
objectClass: posixAccount
objectClass: shadowAccount
objectClass: inetOrgPerson
givenName: $USERNAME
cn: $USERNAME
sn: $USERNAME
uid: $USERNAME
uidNumber: $UID
gidNumber: $GID
homeDirectory: /tmp
loginShell: /bin/bash
gecos:$USERNAME
ENTRY

PASSWD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 6)

echo "Password: $PASSWD"


ldappasswd -x -D "cn=admin,dc=labammsis" -w "gennaio.marzo" -H ldap://10.200.1.254/ -v  "uid=$USERNAME,ou=People,dc=labammsis" -s $PASSWD

