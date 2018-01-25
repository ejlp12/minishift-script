set -x 
oc adm manage-node localhost --list-pods

minishift ssh "docker ps"
