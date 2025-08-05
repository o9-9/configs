function git-amend {
    git add .
    git commit --amend --no-edit
}

function git-cam {
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $msg
    )
    git add .
    git commit -m $msg
}

function git-search {
    param (
        [parameter(Mandatory=$true)]
        [string]$query,
        
        [bool]$regex = $false        
    )
    $reFlag = if ($regex) { '-G' } else { '-S' }
    git log $reFlag $query --source --all --oneline
}

<#

[alias]
    a = "!f() { git add . && git commit --amend --no-edit; }; f"
    allchangesforfile = "!f() { git allfiles | fzf | xargs git log -p --; }; f"
    allcommitsforfile = "!f() { git allfiles | fzf | xargs git log --oneline --all --first-parent --remotes --reflog --; }; f"
    allfiles = "!f() { git log --name-only --diff-filter=A --pretty=format: | sort -u; }; f"
    cam = commit -am
    camp = "!f() { git commit -am \"$1\" && git push; }; f"
    cfg = config --list
    changedfiles = "diff-tree --no-commit-id -r --name-only"
    cm = commit -m
    co = checkout
    cob = checkout -b
    discard = reset HEAD --hard
    discardhunk = checkout -p 
    lastversion = "!f() { git log --diff-filter=d -1 --date-order --all --format=format:%H -- $1 | xargs -i git show {}:$1; }; f"
    lastversionfzf = "!f() { git allfiles | fzf | xargs git lastversion; }; f"
    ol = "log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    others = "ls-files --others --ignored --exclude-from=.gitignore"
    quickmerge = "!f() { git checkout - && git merge --ff - && git branch -d @{-1}; }; f"
    rmuntracked = clean -df
    root = rev-parse --show-toplevel
    s = status
    searchfiles = "log --name-status --source --all -S" 
    searchtext = "!f() { git grep \"$*\" $(git rev-list --all); }; f"
    showfile = "!f() { git show $1:$2; }; f"
    showfileinteractive = "!f() {  git allfiles | fzf > /tmp/showfile && cat /tmp/showfile | tr -d '\n' | xargs git ol --follow -- | fzf | grep -oE '[a-f0-9]{7}' | xargs -i git cat-file -p {}:`cat /tmp/showfile`; }; f"
    uncommit = reset --soft HEAD^
    unstage = reset HEAD --
    wip = "!f() { git add . && git commit -m 'Work in progress'; }; f"
    
  #>