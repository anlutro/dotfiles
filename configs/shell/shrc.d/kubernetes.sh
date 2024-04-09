#!/bin/sh

function kubectx {
    kubectl config set-context $(kubectl config get-contexts --output=name | fzf)
}
