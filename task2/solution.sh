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
	
	echo "Creating user $localVar_user_name..." 

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


# According to exit values of passwd. For exact info look "man passwd".
function printPasswdExitStatus() 
{
	localVar_user_name=$1
	localVar_user_groupsLine=$2
	localVar_user_home_dir=$3
	localVar_user_password=$4

	if [ $? -eq 0 ]; then
		echo "Password set successfully."
	elif [ $? -eq 1 ]; then
		echo "Permission denied while setting password to $localVar_user_name"
	elif [ $? -eq 2 ]; then
		# This must not appear.
		echo "Invalid combination of options"
	elif [ $? -eq 3 ]; then
		echo "Unexpected failure. Password was not set for user $localVar_user_name"
	elif [ $? -eq 4 ]; then
		"Unexpectedd failure, passwd file missing while processing user $localVar_user_name"
	elif [ $? -eq 5 ]; then
		"passwd file busy. No password set for user $localVar_user_name. Try again."
	elif [ $? -eq 6 ]; then
		echo "Invalid argument to option while processing user $localVar_user_name."
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
	
	
	sudo useradd -g $main_group -G $sub_groups --home-dir $user_home --create_home 
	printUseraddExitStatus $all_params
	sudo passwd $user_name $user_password
	printPasswdExitStatus $all_params
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

	
	sleep 1
done < "$input"

