function cd-git-root {
    root=$(git rev-parse --show-toplevel)
    [ $? = 0 ] && cd $root
}

function tf-fmt-git {
    if [ $# -gt 1 ]; then
        git_diff_args=(diff-tree --no-commit-id --name-only -r "$1")
    else
        git_diff_args=(diff --name-only --diff-filter=ACM)
    fi
    # need two commands - one for existing files, one for new/untracked files
    { git "${git_diff_args[@]}"; git ls-files --other --exclude-standard; } \
    | sort | uniq \
    | awk -v root=$(git rev-parse --show-toplevel) '/\.tf(vars)?$/ { print root "/" $0 }' \
    | xargs -n1 terraform fmt
}

# git pull or push based on context
function gp {
    if git status -sb | head -1 | grep -q -F '[ahead'; then
        git push
    else
        git pull
    fi
}
