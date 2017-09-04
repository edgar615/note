#!/bin/bash

#Add BuildNumber
echo "SVN_REVISION:$SVN_REVISION" >> version
echo "BUILD_NUMBER:$BUILD_NUMBER" >> version

# Build the image to be used for this job.
IMAGE=$(docker build . | tail -1 | awk '{ print $NF }')
# Build the directory to be mounted into Docker.
MNT="$WORKSPACE/.."
# Execute the build inside Docker.
#CONTAINER=$(docker run -d -v "$MNT:/opt/project" $IMAGE /bin/bash -c 'cd /opt/project/workspace && ps aux | grep mysql')
CONTAINER=$(docker run -d -e ON_CREATE_DB="user" -e STARTUP_SQL="/user.sql" $IMAGE)
# Attach to the container so that we can see the output.
#Mysql will block console
#docker attach $CONTAINER
# Get its exit code as soon as the container stops.
#Mysql will block console
#RC=$(docker wait $CONTAINER)

RC=1

echo "sleeping for 10 seconds"
sleep 10
echo "woke up"

if [ -n "$(docker logs $CONTAINER | grep 'Database created!')" ]; then
	RC=0;
	echo "You can now connect to this MySQL Server using:";
	echo $(docker logs $CONTAINER | grep 'mysql -uadmin');
else
	echo "Database not created!";
fi;

#STOP CONTAINER
docker stop $CONTAINER
#tag image
TAG=$(docker tag -f $IMAGE 10.4.7.48:5000/csst/user-mysql:$SVN_REVISION)
#push image
PUSH=$(docker push 10.4.7.48:5000/csst/user-mysql:$SVN_REVISION)
# Delete the container we've just used.
docker rm -f $CONTAINER
# Delete image
docker rmi -f $IMAGE
# Exit with the same value as that with which the process exited.
exit $RC