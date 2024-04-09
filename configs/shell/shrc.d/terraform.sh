#!/bin/sh

function tffmt() {
    if [ $# -eq 0 ]; then
        terraform fmt -recursive
    else
        terraform fmt "$@"
    fi
}

