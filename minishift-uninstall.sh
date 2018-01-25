echo "This will delete Minishift VM and any VM-specific files and files in MINISHIFT_HOME directory"
echo
read -p "Press any key to continue..."
minishift delete
rm -rf ~/.minishift
rm -rf ~/.kube
