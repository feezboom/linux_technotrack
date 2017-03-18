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


function createNewUser()
{
	user_name=$1
	user_groups_line=$2
	user_home=$3
	user_password=$4
	
	# Splitting groups
	IFS=';' read -ra ADDR <<< "$user_groups_line"
	main_group="${ADDR[0]}"
	sub_groups="${ADDR[1]}"
		
	sudo useradd -g $main_group -G $sub_groups --home-dir $user_home --create_home 
	sudo passwd $user_name < "$user_password"
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

	printCurrentUser $user_params

	
	sleep 1
done < "$input"

