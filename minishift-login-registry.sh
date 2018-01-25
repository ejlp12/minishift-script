USER=developer
PASSWD=developer

echo "---> Setup oc and docker environment for minishift"
eval $(minishift oc-env)
eval $(minishift docker-env)

oc login -u $USER -p $PASSWD > /dev/null

if [ $? -eq 0 ]; then 
   docker login -u $(oc whoami) -p $(oc whoami -t) $(minishift openshift registry)
   if [ $? -eq 0 ]; then echo "---> Successfully logged into Minishift registry: $(minishift openshift registry)"; fi
fi

echo "Please run this command to setup your shell:"
echo "eval \$(minishift oc-env)"
echo "eval \$(minishift docker-env)"

