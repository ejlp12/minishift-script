git add .

git status
echo
read -p "Press enter to continue... [CTRL+C] to break"

git commit -m "$1"

echo
echo "Going to push to $(git remote -v | grep push | awk '{print $2}')"
git push origin master


echo
echo "--> Git status:"
git status
