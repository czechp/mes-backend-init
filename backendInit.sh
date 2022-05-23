#!/usr/bin/bash

COMANND=""
OPTION=10
GIT_URL="someLinkToGit"


function set_command(){
	echo $1
	read -p "Yes or No (y/n)" COMMAND
}

function reset_command(){
	COMMNAD="n"
}

function press_any_key(){
	read -p "Press any key to continue ... "
}

function show_statement(){
	echo "<-------------------------------------------------------->"
	echo $1
	echo "<-------------------------------------------------------->"
}



function show_menu(){
	echo "Select activites: "
	echo "1. Get project from GitHub"
	echo "2. Build project"
	echo "3. Set to autostart"
	echo "4. Install java 11 and maven"
	echo "5. Configure network"
	echo "6. Reboot"
	echo ""
	echo "0. End of script"
	echo ""

	read -p "Choose number: "  OPTION
}

function select_option(){
	clear
	show_statement "Script to deploy backend for MES System"
	show_statement "Created by PCzech"
	while [ ${OPTION} -ne 0 ]
	do
		show_menu
		if [ ${OPTION} -eq 1 ]
		then
			get_project
		elif [ ${OPTION} -eq 2 ]
		then
			build_project
		elif [ ${OPTION} -eq 3 ]
		then
			set_autostart
		elif [ ${OPTION} -eq 4 ]
		then
			install_java_and_maven
		elif [ ${OPTION} -eq 5 ]
		then
			network_configuration
		elif [ ${OPTION} -eq 6 ]
		then
			reboot			
		fi
	done
	show_statement "End of script good luck"
}

function network_configuration(){

	read -p "Enter Ip Address  for RPI: " IP_ADDRESS

	echo "" > /etc/dhcpcd.conf
	set_in_dhcpcd_conf "hostname"
	set_in_dhcpcd_conf "clientid"
	set_in_dhcpcd_conf "persistent"
	set_in_dhcpcd_conf "option rapid_commit"
	set_in_dhcpcd_conf "option domain_name_servers, domain_name, domain_search, host_name"
	set_in_dhcpcd_conf "option classless_static_routes"
	set_in_dhcpcd_conf "option interface_mtu"
	set_in_dhcpcd_conf "require dhcp_server_identifier"
	set_in_dhcpcd_conf "slaac private "
	set_in_dhcpcd_conf "interface eth0"
	set_in_dhcpcd_conf "static ip_address=${IP_ADDRESS}/16"
	set_in_dhcpcd_conf "static routers=192.168.0.249"
	set_in_dhcpcd_conf "static domain_name_servers=192.168.6.52"


	show_statement "Network configured"
	press_any_key
	clear
}

function set_in_dhcpcd_conf(){
	echo $1 >> /etc/dhcpcd.conf
}

function install_java_and_maven() {
	sudo apt-get  install --yes openjdk-11-jdk
	sudo apt-get install --yes maven
	show_statement "Java and Maven installed successfully"
	press_any_key
	clear
}


function git_clone(){
	git clone "${GIT_URL}" .
}

function git_pull(){
	git pull "${GIT_URL}" master
}

function get_project(){
	show_statement "Creating destination directory"
	DESTINATION_DIRECTORY="/home/pi/Programming/MesBackend"
	if [ -d ${DESTINATION_DIRECTORY} ]
	then
		echo "${DESTINATION_DIRECTORY} already exists"
		reset_command
		set_command "Do you want to clone (Y)  or pull master branch (N)?"
		if [ "${COMMAND}" == "Y" ] || [ "${COMMAND}" == "y" ]
		then
			cd ${DESTINATION_DIRECTORY}
			rm -rf  *
			rm -rf .*
			git_clone
			show_statement "Project downloaded"
		else
			cd ${DESTINATION_DIRECTORY}
			git_pull
			show_statement "Project updated"
		fi
	else
		mkdir -p "${DESTINATION_DIRECTORY}"
		cd "${DESTINATION_DIRECTORY}"
		git_clone
		show_statement "Project downloaded"
	fi
	reset_command
	press_any_key
	clear
}

function build_project(){
	set_command "Do you want to build the project by MVN?"
	if [ "${COMMAND}" == "Y" ] || [ "${COMMAND}" == "y" ]
	then
		cd ${DESTINATION_DIRECTORY}
		sudo mvn clean
		sudo mvn install
		sudo mvn package
		show_statement "Project built successfully"
	fi
	reset_command
	clear
	press_any_key
	clear
}

function set_autostart(){
	set_command "Do you want to set project to autostart?"
	if [ "${COMMAND} == Y" ] || [ "${COMMAND} == y" ]
	then
		FILE_LOCATION="/etc/rc.local"
		echo "#!/bin/sh -e" > ${FILE_LOCATION}
		echo "java -jar /home/pi/Programming/MesBackend/core/target/core-0.0.1-SNAPSHOT.jar &" >> ${FILE_LOCATION}
		echo "exit 0" >> ${FILE_LOCATION}
	fi
	reset_command
	press_any_key
	clear
}

function reboot(){
	set_command "To apply changes you should reboot system. Do you want to make now?"
	if [ "${COMMAND}" == "Y"  ] || [ "${COMMAND}" == "y" ]
	then
		sudo reboot
	fi
}


select_option
