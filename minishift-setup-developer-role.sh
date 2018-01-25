oc login -u system:admin > /dev/null 2>&1

echo "---> Add role related to build and registry to developer"
oc adm policy add-role-to-user system:registry developer
oc adm policy add-role-to-user system:image-builder developer

echo "---> Also make developer able to manage 'openshift' project"
oc adm policy add-role-to-user admin developer -n openshift

oc logout
