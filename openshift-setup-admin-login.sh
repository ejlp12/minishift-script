MASTER_HOST=master

mkdir ~/.kube
scp $MASTER_HOST:/etc/origin/master/admin.kubeconfig  ~/.kube/config
