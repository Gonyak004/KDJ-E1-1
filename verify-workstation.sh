#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
stamp=$(date +%Y%m%d-%H%M%S)
mkdir -p logs
exec > >(tee "logs/verification-$stamp.log") 2>&1
set -x
uname -a
cat /etc/os-release
ls -l permission.txt
ls -ld permission-dir
docker version
docker info
docker build --progress=plain -t "kdj-verification:$stamp" .
web="kdj-web-check-$stamp"
writer="kdj-volume-writer-$stamp"
reader="kdj-volume-reader-$stamp"
volume="kdj-volume-check-$stamp"
# Unique resources preserve existing containers and volumes.
docker volume create "$volume"
docker run --name "$writer" -v "$volume:/data" alpine sh -c 'printf "%s\n" "Docker Volume Persistence Test" > /data/test.txt; cat /data/test.txt'
docker inspect "$writer" --format '{{json .Mounts}}'
docker rm "$writer"
docker run --name "$reader" -v "$volume:/data" alpine sh -c 'cat /data/test.txt; test "$(cat /data/test.txt)" = "Docker Volume Persistence Test"'
docker inspect "$reader" --format '{{json .Mounts}}'
docker rm "$reader"
# Bind a new test container to a Docker-assigned localhost port.
docker run -d --name "$web" -p 127.0.0.1::80 --mount "type=bind,source=$(pwd)/app,target=/usr/share/nginx/html,readonly" "kdj-verification:$stamp"
trap 'docker stop "$web" >/dev/null 2>&1 || true' EXIT
docker inspect "$web" --format '{{json .Mounts}}'
address=$(docker port "$web" 80/tcp)
curl --retry 10 --retry-connrefused --retry-delay 1 --fail -I "http://$address"
curl --fail "http://$address"
docker logs "$web"
git remote -v
git status --short
printf '\nVERIFICATION PASSED\n'
printf 'Test volume %s and stopped container %s are retained for inspection.\n' "$volume" "$web"
