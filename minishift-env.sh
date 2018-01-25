MINISHIFT_DIR=/Users/ejlp12/playground/minishift


if [[ ! $PATH == *"$MINISHIFT_DIR"*  ]] 
then 
 echo "export PATH=$PATH:$MINISHIFT_DIR"
 export PATH=$PATH:$MINISHIFT_DIR
else
 echo "# Minisift directory is already on your PATH"
fi

if [ $(minishift status | grep Minishift: | awk '{print $2}') == "Running" ] 
then
  minishift oc-env | grep -v "#"
  minishift docker-env | grep -v "#"
else
  echo "Minishift is not running"
fi

   echo "# Run this command to configure your shell:"
   echo "# eval \$(${0##*/})"  
