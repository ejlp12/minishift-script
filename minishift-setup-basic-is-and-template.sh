# https://docs.openshift.org/latest/install_config/imagestreams_templates.html

function confirm() {
  local response
  local msg="${1:-Are you sure?} [y/N] "; shift
  read -r $* -p "$msg" response || echo
  case "$response" in
  [yY][eE][sS]|[yY]) return 0 ;;
  *) exit 1 ;;
  esac
}

confirm "This will download files from github and may takes a long time"

oc login -u system:admin > /dev/null 2>&1
oc project openshift > /dev/null 2>&1

DIR=`pwd`
VERSION=`minishift openshift version | grep openshift | cut -d" " -f2 | sed "s/^\(v[0-9.]\.[0-9]\).*/\1/"`

echo "--> Clone GIT repo of ImageStream and Template: https://github.com/openshift/openshift-ansible"
echo "Dir: $DIR"
if [ ! -d "$MINISHIFT_DIR" ]; then
   git clone https://github.com/openshift/openshift-ansible
fi

IMAGESTREAMDIR=$DIR/openshift-ansible/roles/openshift_examples/files/examples/$VERSION/image-streams
DBTEMPLATES=$DIR/openshift-ansible/roles/openshift_examples/files/examples/$VERSION/db-templates
QSTEMPLATES=$DIR/openshift-ansible/roles/openshift_examples/files/examples/$VERSION/quickstart-templates

echo
echo "---> Adding RHEL 7 image stream"
oc create -f $IMAGESTREAMDIR/image-streams-rhel7.json -n openshift

echo
echo "---> Adding DB templates"
oc create -f $DBTEMPLATES -n openshift

echo
echo "---> Adding Quick Start templates"
oc create -f $QSTEMPLATES -n openshift

echo
echo "---> List all ImageStream"
oc get is -n openshift

echo
echo "---> List all Templates"
oc get templates -n openshift


oc logout


echo
echo "You might remove $DIR/openshift-ansible"

