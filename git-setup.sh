USERNAME="Ejlp Indonesia"
EMAIL="ejlp12@gmail.com"


echo "  --> Setup global username & email: $USERNAME <$EMAIL>" 
grep "$USERNAME" ~/.gitconfig > /dev/null || git config --global user.name "$USERNAME" 
git config --global user.email $EMAIL 


if [[ "$OSTYPE" =~ ^darwin ]] && [ ! -f /usr/local/bin/git-credential-osxkeychain ]; then
   echo
   echo "  --> Setup OSX keychain credential"
   curl -O http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
   sudo mv git-credential-osxkeychain /usr/local/bin/
   sudo chmod u+x /usr/local/bin/git-credential-osxkeychain
   git config --global credential.helper osxkeychain
fi


echo 
echo "  --> Setup bash completion"
if [[ "$OSTYPE" =~ ^darwin ]]; then
   source `brew --prefix git`/etc/bash_completion.d/git-completion.bash
fi

git config --global color.ui auto
git config --global core.excludesfile '~/.gitignore'

grep "\[alias\]" ~/.gitconfig > /dev/null
if [ $? -ne 0 ]; then
   echo
   echo "  --> Adding new git alias"
   cat <<EOT >> ~/.gitconfig 
[alias]
    co = checkout
    st = status
    ec = config --global -e
    up = !git pull --rebase --prune $@ && git submodule update --init --recursive
    cob = checkout -b
    cm = !git add -A && git commit -m
    save = !git add -A && git commit -m 'SAVEPOINT'
    wip = !git add -u && git commit -m "WIP"
    undo = reset HEAD~1 --mixed
    amend = commit -a --amend
    wipe = !git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard
    bclean = "!f() { git branch --merged ${1-master} | grep -v " ${1-master}$" | xargs -r git branch -d; }; f"
    bdone = "!f() { git checkout ${1-master} && git up && git bclean ${1-master}; }; f"
    rao = remote add origin
    ac = !git add . && git commit -am
    pushitgood = push -u origin --all
    ls = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]" --decorate
    ll = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
    lds = log --pretty=format:"%C(yellow)%h\\\\ %ad%Cred%d\\ %Creset%s%Cblue\\\\ [%cn]" --decorate --date=short
    logtree = log --graph --oneline --decorate --all

     # list aliases
    la = "!git config -l | grep alias | cut -c 7-"
EOT
else
  echo
  echo "  --> Alias config is exist in ~/.gitconfig"
  echo "      Will not adding new alias for you"
fi
