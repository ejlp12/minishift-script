oc login -u developer -p developer

echo
echo "---> Deleting all resources except images"
oc delete all --selector app=nexus
