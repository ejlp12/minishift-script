GITHUB_USERNAME=$(git config --get-all user.email)

repo_name=$1
test -z $repo_name && echo "Repo name is required." 1>&2 && exit 1

if [[ -z "${param// }" ]]; then
   curl -u $GITHUB_USERNAME https://api.github.com/user/repos -d "{\"name\":\"$repo_name\"}"
else
   echo "Github username is required"
fi
echo
