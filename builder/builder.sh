#!/bin/bash

APP=pdfbuilder
VERSION=1.0.0

TEMP=.tmp
if [ "$COLOR" != "false" ]
then
	RED='\e[31m'
	GREEN='\e[32m'
	BLUE='\e[36m'
	YELLOW='\e[33m'
	RESET='\e[39m'
fi

IMAGENAME=ppamo.$APP
IMAGE=$IMAGENAME:$VERSION
BASEPATH=${PWD#/cygdrive}/$(dirname $0)/..
VOLUMES="--volume $BASEPATH:/data"
DMName=default

run(){
	printf -- $YELLOW"+ Running container for $BLUE$IMAGE$YELLOW:\n"$RESET
	docker run -t --rm --name $APP \
		$VOLUMES \
		$IMAGE 
	printf -- $GREEN"- Done!\n"$RESET
}

build(){
	printf -- $YELLOW"+ Building image $BLUE$IMAGE$YELLOW:\n"$RESET
	# check if the docker image exists
	docker images --format "{{.Repository}}:{{.Tag}}" | \
		grep -E "^$IMAGE\$" > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		# create the docker image
		docker build -t $IMAGE builder/docker/
		if [ $? -ne 0 ]
		then
			printf -- $RED"- ERROR:
docker build failed!\n"$RESET
			exit -1
		fi
	fi
	printf -- $GREEN"- Done!\n"$RESET
}

signal_caught_logs_container(){
	echo
	trap - SIGINT
}
signal_trap_logs_container(){
	trap signal_caught_logs_container SIGINT
}

payload(){
	printf -- $YELLOW"+ Running payload tasks:\n"$RESET
	DM=1
	which docker-machine > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		docker-machine ls $DMName | grep $DMName > /dev/null 2>&1
		DM=$?
	fi

	chcon -Rt svirt_sandbox_file_t $BASEPATH > /dev/null 2>&1
	printf -- $GREEN"- Done!\n"$RESET
}

check(){
	printf -- $YELLOW"+ Running initial checks:\n"$RESET
	# check if the assigned port is in use
	netstat -an | grep "LISTEN" | grep -Eo ":$SERVICEPORT .+LISTEN" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		printf -- $RED"- The port $SERVICEPORT seems to be in use!\n"$RESET
		exit -1
	fi
	# check if the assigned port is in use by docker machine
	if [ $DM -eq 0 ]
	then
		docker-machine ssh $DMName netstat -lnt | grep -Eo ":$SERVICEPORT .+LISTEN" > /dev/null 2>&1
		if [ $? -eq 0 ]
		then
			printf -- $RED"- The port $SERVICEPORT seems to be in use by docker-machine $DMName!\n"$RESET
			exit -1
		fi
	fi
	# check if docker is running
	docker info > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		printf -- $RED"- Cannot connect to the Docker daemon.
Is the docker daemon running and environment configured in this host?\n"$RESET
		exit -1
	fi
	# check if the machine name is in use
	docker ps -a --format "{{.Names}}" | grep "$APP" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		printf -- $RED"- The name $APP is already in use!\n"$RESET
		exit -1
	fi
	# check if the Dockerfile is in the folder
	if [ ! -f builder/docker/Dockerfile ]
	then
		printf -- $RED"- Dockerfile is not present, please run the script from right folder\n"$RESET
		exit -1
	fi
	printf -- $GREEN"- Done!\n"$RESET
}

stop_service(){
	printf -- $GREEN"+ Stoping service $BLUE$APP$GREEN:\n"$RESET
	docker ps --format "{{.Names}}" | grep -E "^$APP$" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		docker stop $APP > /dev/null 2>&1
		if [ $? -ne 0 ]
		then
			printf -- $RED"- ERROR: The machine $BLUE$APP$RED could not be stopped!\n"$RESET
			exit -1
		fi
	else
		printf -- $YELLOW"- The machine $BLUE$APP$YELLOW is not running\n"$RESET
	fi
	printf -- $GREEN"- Done!\n"$RESET
}

remove_service(){
	printf -- $GREEN"+ Removing service $BLUE$APP$GREEN:\n"$RESET
	docker ps --format "{{.Names}}" --filter "status=exited" | grep -E "^$APP$" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		docker rm $APP > /dev/null 2>&1
		if [ $? -ne 0 ]
		then
			printf -- $RED"- ERROR: The machine $BLUE$APP$RED could not be removed!\n"$RESET
			exit -1
		fi
	else
		printf -- $YELLOW"- The machine $BLUE$APP$YELLOW is not present\n"$RESET
	fi
	printf -- $GREEN"- Done!\n"$RESET
}

remove_image(){
	printf -- $GREEN"+ Removing image $BLUE$IMAGE$GREEN:\n"$RESET
	docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "^$IMAGE$" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		docker rmi $IMAGE > /dev/null 2>&1
		if [ $? -ne 0 ]
		then
			printf -- $RED"- ERROR: The image $BLUE$IMAGE$RED could not be removed!\n"$RESET
			exit -1
		fi
	else
		printf -- $YELLOW"- The image $BLUE$IMAGE$YELLOW is not present\n"$RESET
	fi
	printf -- $GREEN"- Done!\n"$RESET
}

usage(){
	printf $GREEN"
* Usage:$RESET
	$YELLOW$(basename $0) $BLUE[rm|rmi|build|run|stop]$RESET
"
}

# - - - -

payload
check
build
run
