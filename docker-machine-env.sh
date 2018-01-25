export DOCKER_API_VERSION=1.21

# Make this directory available to the PATH
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

if grep -q $PATH <<<$SCRIPTPATH; then
 echo "# $SCRIPTPATH is already in PATH variable"
else
  echo "export PATH=\$PATH:$SCRIPTPATH"
fi

echo "export DOCKER_API_VERSION=$DOCKER_API_VERSION"

STATUS=$(docker-machine status)

if [ "$STATUS" == "Running" ]; then
   docker-machine env |grep -v "#"

   echo "# Run this command to configure your shell:"
   echo "# eval \$(${0##*/})"
fi
