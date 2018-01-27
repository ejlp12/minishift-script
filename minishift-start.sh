#!/usr/local/bin/bash

DEBUG=false
AUTH_RHEL=false
export MINISHIFT_USERNAME=
export MINISHIFT_PASSWORD=
export MINISHIFT_ENABLE_EXPERIMENTAL=y

if [ -f minishift ]; then
   echo "<--- Adding current directory to PATH"
   export PATH=$PATH:$(pwd)
fi

if [ "$(minishift status | grep Minishift | awk '{print $2}')" = "Running" ]; then
   echo "Minishift already running"
   exit 1
fi

if [ ! -d "$HOME/.minishift" ]; then
   echo "---> Setup CDK for the first time"
   minishift setup-cdk
fi


ARG="$ARG --vm-driver=virtualbox"
ARG="$ARG --cpus=2"
ARG="$ARG --disk-size=20GB"
ARG="$ARG --memory=3GB"
#ARG="$ARG --iso-url file:///"
ARG="$ARG --skip-registry-check"

# Metric (experimental) as of CDK 3.1
echo "<--- Enabling metrics"
ARG="$ARG --metrics"

# Logging (experimental) as of CDK 3.1 
#ARG="$ARG --logging"

if [ "$AUTH_RHEL" = true ]; then
  echo "<--- Will register RHEL VM"
  ARG="$ARG --username=$MINISHIFT_USERNAME --password=$MINISHIFT_PASSWORD"
else 
  ARG="$ARG --skip-registration"
fi

if [ "$DEBUG" = true ]; then
  ARG="$ARG --show-libmachine-logs --v 5 --logtostderr"
fi 

echo
echo "---> Minishift version info: "
minishift version


echo
echo "---> Starting minishift ..."
echo "minishift start $ARG" > history.minishift-start
minishift start $ARG

echo 
echo "Minishift status: " && minishift status

echo
echo "<--- Set image-caching"
minishift config set image-caching true

echo
echo "---> List of Addons:"
minishift addons list
echo "Enable using: minishift addons enable <addon_name>"

echo
minishift addons enable registry-route --priority=5 2>/dev/null
minishift addons apply anyuid admin-user registry-route 2>/dev/null

echo 
minishift openshift config set --patch '{"corsAllowedOrigins": [".*"]}'

echo 
echo "---> Minishift info:"
echo "IP address: $(minishift ip)"
echo "Registry: " && minishift openshift registry 

echo
echo "---> Running containers:"
minishift ssh 'docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Status}}"'

echo
echo "---> Try to login using 'system:admin'"
oc login -u system:admin >/dev/null 2>&1 
if [ $? -eq 0 ]; then 
  echo ".. Logged in"
  echo
  oc get pods -n default --show-labels
else
  echo ".. Cannot logged in to minishift"
fi

echo 
cat <<-MESG
   You may do the following:

   Setup environment:
     eval \$(minishift oc-env)
     eval \$(minishift docker-env)
   Access shell: minishift ssh
   Login: oc login -u developer -p developer
   Login: oc login -u system:admin
   Login to registry: docker login -u developer -p \$(oc whoami -t) \$(minishift openshift registry)
MESG


echo
minishift console


if [ ! -f $HOME/.minishift/machines/minishift_kubeconfig ]; then
   echo
   echo "$HOME/.minishift/machines/minishift_kubeconfig seems not found... Minishift might not work correctly"
fi

test $(oc get pods -n default | grep -v build | grep -e 1/1 -e Running | wc -l) -ne 2 && \
CAT <<-ERR
   Somthin wrong with Minishift router and registry
   Please try to manual starting it by following command:
      oc login -u system:admin
      oc project default
      oc deploy router --retry
      oc deploy docker-registry --retry
ERR


