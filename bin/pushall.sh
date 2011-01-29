#!/bin/zsh

[[ $# -eq 3 ]] || exit 1
[[ -d $1 ]] || exit 1
[[ -f $2 ]] || exit 1

ssh-agent zsh<<EOF
ssh-add $2
cd $1
branch=\$(git branch | grep '\*' | sed 's/^..//')
echo "start autocommit at \$(date)" >> log
git stash
echo "git stashed with status \$?">>log
git branch -D tmp
echo "git deleted tmp branch with status \$?">>log
git checkout -b tmp master
echo "git checked out to tmp with status \$?" >> log
git stash apply
echo "git stash apply with status \$?">>log
git commit -a -m "autocommit"
echo "git commited to branch \${branch} with status \$?" >> log
git push origin +tmp:tmp
echo "git pushed with status \$?" >> log
git checkout -f \${branch}
echo "git checked out to \${branch} with status \$?">>log
git stash pop
echo "git stash poped with status \$?" >> log
git branch -D tmp
EOF
