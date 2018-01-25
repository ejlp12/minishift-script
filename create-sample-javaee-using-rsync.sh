## https://blog.openshift.com/fast-iterative-java-development-on-openshift-kubernetes-using-rsync/

PROJECTNAME=java-ee-rsync
IMAGE=registry.access.redhat.com/jboss-eap-7/eap70-openshift
REPO=https://github.com/paulojeronimo/openshift-javaee-helloworld


echo "---> Login to openshift"
oc login -u developer -p developer > /dev/null 2>&1
oc project $PROJECTNAME > /dev/null 2>&1

echo
echo "---> Trying to delete existing '$PROJECTNAME' project and resource inside it" 
oc delete all --selector app=${REPO##*/} 
oc delete project $PROJECTNAME 

sleep 10

echo
echo "---> Create new project $PROJECTNAME"
oc new-project $PROJECTNAME 
if [ $? -ne 0 ]; then
   echo "Cannot create project, probably delete process is still on going"
   exit 1
fi

echo
echo "---> Deploy JBoss EAP 7 image and sample web app"
oc new-app $IMAGE~$REPO

# Wait until BuildConfig is created
while true
do 
   oc logs -f bc/${REPO##*/} 2>/dev/null
   if [ $? -eq 0 ]; then 
      break
   else
      sleep 3
   fi
done
oc expose service ${REPO##*/}

sleep 10

echo
echo "Open browser and access the sample app"
read -p "Press enter to continue..."

clear
if [ ! -d "${REPO##*/}" ]; then
  echo
  echo "--> Clone a simple example Java EE project"
  git clone $REPO
else
  echo "---> Using existing cloned repo in local disk"
fi
cd ${REPO##*/}

echo
echo "---> Simulate change in the source code (HTML file) and build again"
sed -i -e 's/Hello World/Hello my New World/g'  src/main/webapp/index.html

sleep 5

echo
echo "---> Build sample application"
mvn package -Popenshift

echo
echo "---> Get pods:"
oc get pods

sleep 5 

while true 
do
  # Select Running pod but not the build pod or deploy pod
  POD_NAME=$(oc get pods |grep Running |grep ${REPO##*/} |grep -v build |grep -v deploy| cut -d" " -f1)

  if [ -n "$POD_NAME" ]; then
     echo
     echo "---> Deploy new app into pod $POD_NAME using rsync" 

     # Replace <pod_name> with the value from the previous step
     oc rsync --include="ROOT.war" --exclude="*" target/ $POD_NAME:/deployments/ --no-perms=true 
     
     break
  else
     sleep 5
  fi
done

read -p "Press enter to continue..."

