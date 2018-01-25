MINISHIFT_DIR=/Users/ejlp12/playground/minishift


if [[ ! $PATH == *"$MINISHIFT_DIR"*  ]] 
then 
 echo "export PATH=\$PATH:$MINISHIFT_DIR"
 export PATH=$PATH:$MINISHIFT_DIR
else
 echo "# Minisift directory is already on your PATH"
fi

if [ "$(minishift status |grep Minishift| awk '{print $2}')" == "Running" ] 
then
  eval $(minishift oc-env)
  eval $(minishift docker-env)
  minishift oc-env | grep -v "#"
  minishift docker-env | grep -v "#"

  echo "# Run this command to configure your shell:"
  echo "# eval \$(${0##*/})"
else
  echo "Minishift is not running"
fi


oc login -u system:admin 1>/dev/null 2>&1 
echo "# Login to minishift as $(oc whoami)"
