function cd-git-root {
    root=$(git rev-parse --show-toplevel)
    [ $? = 0 ] && cd $root
}

function tf-fmt-git {
    if [ $# -gt 0 ]; then
        git_diff_args=(diff-tree --no-commit-id --name-only -r "$@")
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
    git_status=$(git status -sb | head -1)
    # no upstream defined means we can't pull anyway
    if ! echo "$git_status" | grep -qF '...'; then
        git push
    # upstream is defined and we are ahead
    elif echo "$git_status" | grep -qF '[ahead'; then
        git push
    else
        git pull
    fi
}
