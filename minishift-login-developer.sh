MINISHIFT_DIR=/Users/ejlp12/playground/minishift


if [[ ! $PATH == *"$MINISHIFT_DIR"*  ]] 
then 
 echo "export PATH=$PATH:$MINISHIFT_DIR"
 export PATH=$PATH:$MINISHIFT_DIR
else
 echo "# Minisift directory is already on your PATH"
fi

if [ $(minishift status) == "Running" ] 
then
  eval $(minishift oc-env)
  eval $(minishift docker-env)
  minishift oc-env | grep -v "#"
  minishift docker-env | grep -v "#"
else
  echo "Minishift is not running"
fi

   echo "# Run this command to configure your shell:"
   echo "# eval \$(${0##*/})"  

oc login -u developer -p developer
