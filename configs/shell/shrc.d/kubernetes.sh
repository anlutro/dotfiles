#!/bin/sh

function kubectx {
    kubectl config use-context $(kubectl config get-contexts --output=name | fzf)
}
