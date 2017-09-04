#!/bin/sh

# https://gist.github.com/bastman/5b57ddb3c11942094f8d0a97d461b430
# docker system prune doesn't seem to do very much

docker ps -qaf status=exited | xargs -r docker rm
docker volume ls -qf dangling=true | xargs -r docker volume rm
docker network ls | awk '$3 == "bridge" { print $1 }' | xargs -r docker network rm
docker images -qaf dangling=true | xargs -r docker rmi
