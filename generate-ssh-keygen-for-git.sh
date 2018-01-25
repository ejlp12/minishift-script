GITHOST=bitbucket
FILENAME=repo-at-$GITHOST

ssh-keygen -C "openshift-source-builder/repo@$GITHOST" -f $FILENAME -N ''

echo
echo "---> Created private key file: $FILENAME"
echo "---> Created public key file: $FILENAME.pub" 
echo
ls -la repo-at-github*
