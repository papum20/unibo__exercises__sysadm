#!/bin/bash

OPT=$1

ROUTER=10.20.20.254
SERVER=10.20.20.20

function GET_PEOPLE {
	ldapsearch -x -D "cn=admin,dc=labammsis" -w "gennaio.marzo" -H ldap://$SERVER/ -b "ou=People,dc=labammsis" -s sub
}

function DELETE_PEOPLE {
	FILE_LDIF=$(mktemp)
	GET_PEOPLE | egrep '^uid: ' | cut -d' ' -f2 | while read USERID ; do
		echo "
			dn: uid=$USERID,ou=People,dc=labammsis
			changetype: delete
		" >> $FILE_LDIF
	done

	cat $FILE_LDIF
	ldapmodify -x -D cn=admin,dc=labammsis -H ldap://$SERVER/ -w gennaio.marzo -f $FILE_LDIF
}


if [[ $OPT == 'new' ]]
then
	DELETE_PEOPLE

	echo "Deleted People, new People:"
	GET_PEOPLE
	
	scp temp@$ROUTER:/tmp/dir.backup /tmp/dir.backup
	ldapmodify -x -D cn=admin,dc=labammsis -H ldap://$SERVER/ -w gennaio.marzo -f /tmp/dir.backup

	echo "Used backup, new People":
	GET_PEOPLE
elif [[ -n $OPT ]]
then
	logger -p local5.info -n $ROUTER <<< "Error: wrong params: $@" 
	echo "Error with params $*"
else
	FILE_LDIF=$(mktemp)
	GET_PEOPLE | egrep -v '^# search result' -A 10 | egrep -v '^#' > $FILE_LDIF
	scp $FILE_LDIF temp@$ROUTER:/tmp/dir.backup

	echo "Created dump and sent:"
	cat $FILE_LDIF
fi



