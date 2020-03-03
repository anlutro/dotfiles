#!/bin/sh

alias av='venv activate'
alias avenv='venv activate'
alias mkvenv='venv create'
alias rmvenv='venv destroy'

function venv {
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
                read -rp "Re-create virtualenv? [Y/n] "
                if [ -n "$REPLY" ] && ! [[ "$REPLY" =~ ^[Yy] ]]; then
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
        if [ "$ask" = 'yes' ]; then
            read -rp "Confirm [Y/n] "
            if [ -n "$REPLY" ] && ! [[ "$REPLY" =~ ^[Yy] ]]; then
                return 1
            fi
        fi
        $cmd "$venv" || return 1
        "$venv/bin/pip" install --upgrade pip setuptools wheel
    }

    function venv-destroy {
        venv-locate || echo "No virtualenv found!"
        venv="$venv_found"

        if [ "$ask" = 'yes' ]; then
            read -rp "Remove virtualenv '$venv'? [Y/n] "
            if [ -n "$REPLY" ] && ! [[ "$REPLY" =~ ^[Yy] ]]; then
                return 1
            fi
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
