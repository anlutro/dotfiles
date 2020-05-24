#!/bin/sh

alias av='venv activate'
alias avenv='venv activate'
alias mkvenv='venv create'
alias rmvenv='venv destroy'

function venv {
    function confirm {
        if [ "$ask" = 'no' ]; then
            return 0
        fi
        read -rp "$* [Y/n] "
        if [ -z "$REPLY" ] || [[ "$REPLY" =~ ^[Yy] ]]; then
            return 0
        fi
        return 1
    }

    local arg
    local ask
    local func
    local python
    local venv
    local venv_name
    local venv_found

    while [ $# -gt 0 ]; do
        arg="$1"
        case $arg in
            -a|--ask )
                ask='yes'
                ;;
            -n|--no-ask|--noninteractive )
                ask='no'
                ;;
            -p|--python )
                shift
                python="$1"
                ;;
            -p* )
                python="${1:2}"
                ;;
            -2|--two )
                python='python2'
                ;;
            -3|--three )
                python='python3'
                ;;
            -* )
                echo "Unknown option: $arg" >&2
                return 1
                ;;
            * )
                if [ -z "$func" ]; then
                    func="$1"
                elif [ -z "$venv" ]; then
                    venv="$1"
                    venv_name="$1"
                else
                    echo "Extra argument received: $arg" >&2
                    return 1
                fi
                ;;
        esac
        shift
    done

    if [ -z "$venv" ] || [ "$venv" = "$PWD" ] || [ "$venv" = '.' ]; then
        venv=".venv"
    fi

    # remove trailing slash, which is common when autocompleting directories
    if [ -n "$venv_name" ] && [ -e "$venv_name" ]; then
        venv_name="${venv_name%/}"
    fi

    if [ -z "$python" ]; then
        python=$(
            find /usr/local/bin /usr/bin $HOME/.local/bin -regex '.*/python[3-9][0-9.]+' -printf '%f\n' \
            | sort -V | tail -1
        )
    elif echo "$python" | grep -qP '^[\d\.]+$'; then
        python="python${python}"
    fi

    function venv-activate {
        if [ -n "$VIRTUAL_ENV" ]; then
            echo "A virtualenv is already active!" >&2
            return 1
        fi

        venv-locate

        if [ -n "$venv_found" ]; then
            venv="$venv_found"
            if [ ! -e "$venv/bin/python" ]; then
                ls --color=yes -l $venv/bin/python*
                echo "Python binary not found in venv, possibly due to python being upgraded." >&2
                if ! confirm "Re-create virtualenv?"; then
                    return 1
                fi
                venv-destroy
                venv-create
            fi
        else
            echo "Couldn't find a virtualenv in PWD!" >&2
            ask="${ask:-yes}" venv-create || return $?
            venv-activate
            return $?
        fi

        local relpath
        relpath=$(realpath --relative-to=$PWD $venv)
        if echo "$relpath" | grep -q '^\.\.'; then
            relpath=$venv
        fi
        echo -n "Activating virtualenv: $relpath"
        echo " - $($venv/bin/python --version 2>&1)"
        echo "Run \`deactivate\` to exit the virtualenv."
        . $venv/bin/activate
        export VIRTUAL_ENV_NAME="$venv_name"
        _set_ps1
    }

    function venv-locate {
        local dir="$PWD"
        local venv_dir
        if [ -d $dir/.tox ]; then
            if [ -n "$venv_name" ]; then
                venv_found=$dir/.tox/$venv_name
            else
                venv_found=$(find $dir/.tox -mindepth 1 -maxdepth 1 -name 'py*' | sort | tail -1)
            fi
            if [ ! -d "$venv_found" ]; then
                echo ".tox directory found but no virtualenvs!" >&2
                return 1
            fi
            venv_name="$(basename $dir)/$(basename $venv_found)"
        else
            for venv_dir in . $venv .virtualenv .venv venv .; do
                if [ -f $venv_dir/bin/activate ]; then
                    venv_found=$venv_dir
                    if [ -z "$venv_name" ]; then
                        venv_name=$(basename $dir)
                    fi
                    break
                fi
            done
        fi
        if [ -n "$venv_found" ]; then
            return 0
        else
            return 1
        fi
    }

    function venv-create {
        local cmd
        local venv_pdir

        if echo "$python" | grep -q 'python3'; then
            cmd="$python -m venv"
        elif command -v virtualenv >/dev/null 2>&1; then
            cmd="virtualenv -p $python"
        elif [ -e /usr/lib/python3/dist-packages/virtualenv.py ]; then
            cmd="python3 -m virtualenv -p $python"
        elif [ -e /usr/lib/python2.7/dist-packages/virtualenv.py ]; then
            cmd="python2.7 -m virtualenv -p $python"
        else
            echo "Don't know how to make a virtualenv for $python" >&2
            return 1
        fi

        echo "Creating virtualenv in '$venv' using $($python --version 2>&1) ..."
        if ! confirm "Confirm"; then
            return 1
        fi
        $cmd "$venv" || return 1
        echo "Upgrading pip, setuptools, wheel ..."
        "$venv/bin/pip" --quiet install --upgrade pip setuptools wheel

        venv_pdir=$(dirname $(readlink -f "$venv"))
        if [ -e "$venv_pdir/pyproject.toml" ]; then
            if grep -qF '[tool.poetry]' "$venv_pdir/pyproject.toml"; then
                echo "Installing poetry ..."
                "$venv/bin/pip" --quiet install --upgrade poetry
            fi
        fi

        for f in dev-requirements.txt requirements-dev.txt requirements/dev.txt; do
            if [ -e $f ] && confirm "Install $f?"; then
                $venv/bin/pip install --upgrade -r $f
            fi
        done
    }

    function venv-destroy {
        venv-locate || echo "No virtualenv found!"
        venv="$venv_found"

        if ! confirm "Remove virtualenv '$venv'?"; then
            return 1
        fi

        if [ -n "$VIRTUAL_ENV" ]; then
            deactivate
            _set_ps1
        fi
        echo "Removing $venv ..."
        rm -rf $venv
    }

    venv-$func
}
