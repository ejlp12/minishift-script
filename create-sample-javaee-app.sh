function confirm() {
  local response
  local msg="${1:-Are you sure?} [y/N] "; shift
  read -r $* -p "$msg" response || echo
  case "$response" in
  [yY][eE][sS]|[yY]) return 0 ;;
  *) exit 1 ;;
  esac
}

confirm "This will create a new project and provision an binary application (WAR file) from github" 

oc login -u developer -p developer > /dev/null 2>&1
oc new-project hello --display-name='OpenShift JBoss EAP Hello App' --description='JBoss EAP Sample App'

echo
echo "---> Create a Java EE sample application with 'name=hellowebwar' using JBoss EAP 7.0"
oc new-app jboss-eap70-openshift:1.5~https://github.com/ejlp12/HelloWebAppWAR.git  --name='hellowebwar' --labels name='hellowebwar'

echo
oc expose svc/hellowebwar


echo
HOST=$(oc get routes | grep hellowebwar | awk '{print $2}')
echo "Host: http://$HOST/HelloWebApp/"



echo
confirm "Continue to delete all object related to hellowebwar"
oc delete all -l app=hellowebwar

oc logout
