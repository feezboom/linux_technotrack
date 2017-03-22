#!/bin/bash


function readLine()
{
	IFS= read -r var
	echo "$var"
}

function printCurrentUser() 
{
	
	echo "userName : $1"
	echo "groups line : $2"
	echo "home dir line : $3"
	echo "password line  : $4"
}


# According to exit values of useradd. For exact info look "man useradd".
function printUseraddExitStatus()
{

	localVar_user_name=$1
	localVar_user_groupsLine=$2
	localVar_user_home_dir=$3
	localVar_user_password=$4
	
	if [ $? -eq 0 ]; then
		echo "Successfully created"
	elif [ $? -eq 1 ]; then
		echo "Can't update password file"
	elif [ $? -eq 2 ]; then
		# This must not appear.
		echo "Invalid command syntax"
	elif [ $? -eq 3 ]; then
		echo "Invalid argument to option"
	elif [ $? -eq 4 ]; then
		"UID already in use"
	elif [ $? -eq 6 ]; then
		"Specified group doesn't exist"
	elif [ $? -eq 9 ]; then
		echo "Username $localVar_user_name already in use."
	elif [ $? -eq 10 ]; then
		echo "Can't update group file."
	elif [ $? -eq 12 ]; then
		"Can't create home directory: $localVar_user_home_dir"
	elif [ $? -eq 14 ]; then
		echo "Can't update SELinux user mapping."	
	fi	
}

function createNewUser()
{
	user_name=$1
	user_groups_line=$2
	user_home=$3
	user_password=$4
	
	all_params="$1 $2 $3 $4"

	# Splitting groups
	IFS=';' read -ra ADDR <<< "$user_groups_line"
	main_group="${ADDR[0]}"
	sub_groups="${ADDR[1]}"
	
		
	echo "Creating user $localVar_user_name..." 
	sudo useradd -g $main_group -G $sub_groups --home-dir $user_home --create-home $user_name 
	printUseraddExitStatus $all_params

	echo "$user_name:$user_password" | sudo chpasswd
	if [ $? -eq 0 ]; then
		echo "password for $user_name was set successfully"
	fi
}

input="input.txt"
label="init_value"

while : 
do
	label=$(readLine)
	
	if [ "$label" == "ENDUSERS" ]; then
		break
	fi 

	user_name_line=$(readLine)
	user_groups_line=$(readLine)
	user_home_dir_line=$(readLine)
	user_password_line=$(readLine)
	
	user_params="$user_name_line $user_groups_line $user_home_dir_line $user_password_line"

	createNewUser $user_params
	echo ""	

	sleep 1
done < "$input"

