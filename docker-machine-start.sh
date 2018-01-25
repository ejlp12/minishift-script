echo "---> Docker status: " && docker-machine status


docker-machine start

echo
echo "---> Setup your shell env for using with docker"
eval $(docker-machine env)

export DOCKER_API_VERSION=1.21
IP=`docker-machine ip`

docker version
echo "Docker started with IP address: $IP"

echo
echo "--> Try following command:"
echo " Available diskspace: docker-machine ssh default \"df -h\""
echo " Available images: docker images"
echo " General info: docker info"
