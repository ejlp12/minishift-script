FILEPATH=$2
BRANCH=$1 

git fetch
git checkout origin/$BRANCH $FILEPATH 
