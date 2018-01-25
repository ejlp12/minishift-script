# Script ini belum ditest.. tapi command-nya sudah dicoba secara manual
#  https://developers.redhat.com/blog/2017/04/05/adding-persistent-storage-to-minishift-cdk-3-in-minutes/

STATUS=$(minishift status)
if [ "$STATUS" != "Running" ]; then
   echo "Minishift should be running"
   exit 1
fi

minishift ssh <<< " 
sudo -i; \
mkdir -p /mnt/sda1/var/lib/minishift/openshift.local.volumes/pv; \
mkdir /mnt/sda1/var/lib/minishift/openshift.local.volumes/pv/registry; \
chmod 777 -R /mnt/sda1/var/lib/minishift/openshift.local.volumes/pv;"



oc login -u system:admin
oc project default


echo
echo " ---> Create Persitent Volume"
cat << __PV__ | oc create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
 name: registry
spec:
 capacity:
  storage: 25Gi
 accessModes:
  - ReadWriteOnce
 storageClassName: slow
 hostPath:
  path: /mnt/sda1/var/lib/minishift/openshift.local.volumes/pv/registry
__PV__


echo
echo " ---> Create PV Claim"
cat << PVC | oc create -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
 name: registryclaim
spec:
 accessModes:
  - ReadWriteOnce
 resources:
  requests:
   storage: 25Gi
 storageClassName: slow
 selector:
  name: registry
PVC


echo
echo " ---> Check PV and PVC"
oc get pv
oc get pvc
