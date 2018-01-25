MASTER_HOST=$1

ssh root@$MASTER_HOST

oc login -u system:admin --config=/etc/origin/master/admin.kubeconfig
RegistryAddr=$(oc get svc docker-registry -n default -o 'jsonpath={.spec.clusterIP}:{.spec.ports[0].port}')



# Make sure that the registry can write to the volume
oc project default 
oc rsh `oc get pods -o name -l docker-registry`

touch /registry/test
ls -la /registry/
rm /registry/test
exit
