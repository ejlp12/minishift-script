oc login -u system:admin > /dev/null 2>&1
oc project openshift > /dev/null 2>&1

echo "---> Adding JBoss ImageSteam"
oc create -n openshift -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json

echo
echo "---> List all ImageStream"
oc get is -n openshift

echo
echo "---> List all Templates"
oc get templates -n openshift


oc logout
