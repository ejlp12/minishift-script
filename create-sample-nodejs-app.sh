oc logout

oc login -u system:admin
oc delete project nodejs-echo

oc logout 

oc login -u developer -p developer
oc new-project nodejs-echo --display-name="nodejs" --description="Sample Node.js app"
oc project nodejs-echo
oc new-app https://github.com/ejlp12/nodejs-ex -l name=myapp
oc status
oc expose svc/nodejs-ex
oc get routes
