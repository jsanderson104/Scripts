#!/bin/bash
# Author: Justin Sanderson
# Date: 07/11/21
# Purpose: Randomly generate SHA-512 hashes for Linux accounts so passwords won't expire.
# The user uses an RSA Token to access the system; therefore doesn't need to know their PW.
# Command to generate SHA-512 hash w/ OpenSSL. The '-6' option indicates the $6$ in shadow file which is SHA-512 algorithm.


##########
# CONFIG #
##########

# Verify openssl is in PATH
which openssl 2>&1 1>/dev/null 
if [ `echo $?` != "0" ]; then echo "OpenSSL command not found in PATH. Exiting" && exit 2 ; fi

# If not root user exit
if [ `whoami` != "root" ]; then echo "Not root user .. " && exit 1 ; fi

# Whether or not to actually apply the changes to the accounts.
# Boolean VALUE 0=Off 1=On
ACTIVE=0


########
# MAIN #
########

# Initialize globals. Make arrays global so they can jump function boundaries.
EXCLUDE_LIST=();
INCLUDE_LIST=();
WHEEL_GROUP_USERS=();


function getUserList {
	# Get all users that are above UID 1000 and not members of wheel group from passwd file
	INCLUDE_LIST=(`awk -F: '{ if ($3 >999 && $4 !=10) print $1}' /etc/passwd`);
}

function excludeWheelMembers {
	# Populate array with users that are in wheel group
	WHEEL_GROUP_USERS=(`awk -F: '{if ($1 == "wheel") print $4}' /etc/group|sed 's/,/ /g'`);

	# Short-hand to append one array to another. Way faster than forloop
	EXCLUDE_LIST+=( ${WHEEL_GROUP_USERS[@]} );
} 

function genPWhash {
	# Generate a random 32-char case-sensitive alphanumeric string
	random_str=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
	sha512_hash=`echo "$random_str" |openssl passwd -6 -stdin`
	echo $sha512_hash;
}

function addLockPWtoExclude {
	for user in ${INCLUDE_LIST[@]} ; do
		passwd -S $user |grep LK 2>&1 1>/dev/null;

		# Get exit code of grep command. 0=Locked 1=NotLocked
		LKRC=`echo $?`;
		# If Password is locked then put in exclude list. Setting their password will unlock it.
		if [ "$LKRC" == "0" ] ; then
			#echo "Excluding locked account: $user"
			EXCLUDE_LIST+=($user) ;
		fi
	done
}

# Note: When adding a value/element to an array w/o referencing a var, do not use quotes; just type the value in the paren.
function excludeGenericAccount { 
	generic_ex_user=$1
	echo "Excluding: $generic_ex_user"
	EXCLUDE_LIST+=($generic_ex_user);
}

function uniqExcludes() {
	local -n exc_array=$1;
	# Re-define global Exclude array and send it thru sort for cleanup.
	EXCLUDE_LIST=(`printf "%s\n" "${exc_array[@]}" | sort -u`);
} 

function uniqIncludes() {
	local -n inc_array=$1;
	# Re-define global Include array and send it thru sort for cleanup.
	INCLUDE_LIST=(`printf "%s\n" "${inc_array[@]}" | sort -u`);
} 


function compareArrays() {
	let "position = 0";
	for euser in ${EXCLUDE_LIST[@]} ; do
		for iuser in ${!INCLUDE_LIST[@]}; do
			if [[ "$euser" = "${INCLUDE_LIST[$iuser]}" ]]; then
				echo "Excluding: $euser";

				#Debug - in case the uniq function ever fails.
				#echo "Postion: " ; echo "$iuser"

				INCLUDE_LIST[$iuser]="";
			fi
		let "position++"
		done
	done
}

function setHash() {
	op_user=$1;
	hash=$(genPWhash);

	if [ "$ACTIVE" = "0" ]; then
	echo "$op_user : $hash"
	else
		usermod -p $hash $op_user
		success=`echo $?`;
		if [ "$success" = "0" ]; then
			echo "Success --> $op_user:$hash"
		else
			echo "Failed --> $op_user:$hash"
		fi
	fi		
}


if [ "$ACTIVE" = "0" ]; then
	echo "======================================="
	echo "========== Logging mode ==============="
	echo "== No changes to system will be made =="
	echo "======================================="
fi


# Gathering info and coming up with list to modify.
getUserList;
addLockPWtoExclude;
excludeWheelMembers;
excludeGenericAccount root;
uniqIncludes INCLUDE_LIST;
uniqExcludes EXCLUDE_LIST; 
compareArrays;

# This loop is where we start down the road of making changes. There is an ACTIVE check in the last function -aka setHash()- for safety.
for user in "${INCLUDE_LIST[@]}"; do
	#if [ "$user" != "" ] && [ $ACTIVE -ne 0 ]; then setHash $user; fi
	if [ "$user" != "" ]; then setHash $user; fi
done	
