#!/bin/bash

DOCKERDEB=false   # if using Docker Desktop, set to false
ARCH=linux/arm64  
echo default is to build arm64 locally. Pass "--multi" as argument to build multi-arch and push to DockerHub.

# ARCHS=()
# while getopts ":a" option; do
#    case $option in
#       a) # arch
#          arch=$OPTARG;
#          ARCHS+=$arch;;
#       \?) # Invalid option
#          echo "Error: Invalid option"
#          exit;;
#     esac
# done

# if [ ! -z "$ARCHS" ]; then
#     ARCH=$ARCHS
# fi

if [[ ! -z "$1" && "$1" == "--multi" ]]; then
    ARCH=linux/arm64,linux/amd64
    PUSH="--push"
    echo Building for $ARCH and with the $PUSH argument...
    NAMESPACE=seleniarm
else 
    NAMESPACE=local-seleniarm
fi

exit;

if [[ $DOCKERDEB == true ]]
then
    echo 'Getting geckodriver binary from the Docker Debian VM...'
    sh get-geckodriver.sh
else
    echo 'Getting geckodriver from /media/host...'
    cp /media/host/geckodriver .
fi

echo 'Generate the Dockerfile...'
BUILD_DATE=$(date +'%Y%m%d')
VERSION=4.1.0-alpha
# NAMESPACE=seleniarm
AUTHORS=SeleniumHQ,sj26,jamesmortensen

echo "# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" > ./Dockerfile
echo "# NOTE: DO *NOT* EDIT THIS FILE.  IT IS GENERATED." >> ./Dockerfile
echo "# PLEASE UPDATE Dockerfile.txt INSTEAD OF THIS FILE" >> ./Dockerfile
echo "# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ./Dockerfile
echo FROM ${NAMESPACE}/node-base:${VERSION}-${BUILD_DATE} >> ./Dockerfile
echo LABEL authors="$AUTHORS" >> ./Dockerfile
echo "" >> ./Dockerfile
cat ./Dockerfile.arm64 >> ./Dockerfile



echo "Building Seleniarm/NodeFirefox:$VERSION-$BUILD_DATE"
docker buildx build $PUSH --platform $ARCH -f Dockerfile -t $NAMESPACE/node-firefox:$VERSION-$BUILD_DATE .
docker tag $NAMESPACE/node-firefox:$VERSION-$BUILD_DATE $NAMESPACE/node-firefox:latest

# Generate the Seleniarm/StandaloneFirefox Dockerfile
cd ../Standalone && sh generate.sh StandaloneFirefox node-firefox $VERSION-$BUILD_DATE $NAMESPACE $AUTHORS
cd ../StandaloneFirefox

echo "Building Seleniarm/StandaloneFirefox:$VERSION-$BUILD_DATE"
docker buildx build $PUSH --platform $ARCH -f Dockerfile -t $NAMESPACE/standalone-firefox:$VERSION-$BUILD_DATE .
docker tag $NAMESPACE/standalone-firefox:$VERSION-$BUILD_DATE $NAMESPACE/standalone-firefox:latest


# Remove geckodriver image and dependencies if build is successful, since it's 4.9GB!
docker image rm local-seleniarm/geckodriver-arm64:$VERSION-$BUILD_DATE
