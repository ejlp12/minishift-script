
STOP_OPT=""
test "$(minishift status)" = "Running" && minishift stop $STOP_OPT

minishift delete
rm -rf $HOME/.minishift
rm -rf $HOME/.kube
