#!/bin/sh

# https://gist.github.com/bastman/5b57ddb3c11942094f8d0a97d461b430
# docker system prune doesn't seem to do very much

echo "Deleting exited containers..."
docker ps -qaf status=exited | xargs -r docker rm
echo
echo "Deleting dangling volumes..."
docker volume ls -qf dangling=true | xargs -r docker volume rm
echo
echo "Deleting bridge networks..."
docker network ls | awk '$3 == "bridge" && $2 != "bridge" { print $1 }' | xargs -r docker network rm
echo
echo "Deleting dangling images..."
docker images -qaf dangling=true | xargs -r docker rmi
