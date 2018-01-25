
echo "---> Setting up docker-env"
eval $(minishift docker-env)


echo "---> Pull required images: jenkins-2-centos7, launchpad-jenkins-slave, nexus..."
docker images | grep openshift/jenkins-2-centos7 > /dev/null; if [ $? -ne 0 ]; then docker pull openshift/jenkins-2-centos7; fi
docker images | grep openshiftio/launchpad-jenkins-slave > /dev/null; if [ $? -ne 0 ]; then docker pull openshiftio/launchpad-jenkins-slave; fi
docker images | grep sonatype/nexus > /dev/null; if [ $? -ne 0 ]; then docker pull sonatype/nexus; fi

oc login -u developer -p developer > /dev/null


echo
echo "---> Deploying nexus..."
oc get projects nexus-repo --no-headers=true > /dev/null
if [ $? -eq 0 ]; then
   echo "Project nexus-repo is exist, skip creating"
else
   oc new-project nexus-repo   
fi

oc get all --selector app=nexus > /dev/null
if [ $? -ne 0  ]; then
   echo "Resource with selector app=nexus is exist, skip creating new nexus app"
   exit 1
fi

oc new-app sonatype/nexus
oc expose svc/nexus 

oc volumes dc/nexus --add \
 --name 'nexus-volume-1' \
 --type 'pvc' \
 --mount-path '/sonatype-work/' \
 --claim-name 'nexus-pv' \
 --claim-size '1Gi' \
 --overwrite


echo
echo "---> Set liveness & readiness proble"
oc set probe dc/nexus \
	--liveness \
	--failure-threshold 3 \
	--initial-delay-seconds 30 \
	-- echo ok

oc set probe dc/nexus \
	--readiness \
	--failure-threshold 3 \
	--initial-delay-seconds 30 \
	--get-url=http://:8081/nexus/content/groups/public

echo
echo "---> Created route for Nexus:"
oc get routes

sleep 10
echo
echo "---> Wait until nexus pod is created and completely running
while true
do
   oc get pods --no-headers=true | grep -v deploy | grep -e nexus- -e Running -e  1/1  >/dev/null 2>&1
   if [ $? -eq 0 ]; then
      break
   else
      sleep 3
   fi
done

echo "---> Opening Nexus web page in a browser..."
open http://"$(oc get routes --no-headers=true | awk '{print $2}')/nexus"

echo
echo "---> View created pod       [CTRL+C] to exit!!"
oc get pods -w


