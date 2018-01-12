set -euo pipefail # make sure script fails promptly on error

TREE_HASH=$1
APPLICATION=$2
IMAGE_NAME=dkr.ecr.eu-west-2.amazonaws.com/spike/${APPLICATION}
HASH_TAG_NAME=${IMAGE_NAME}:${TREE_HASH}
LATEST_TAG_NAME=${IMAGE_NAME}:latest

docker build -t ${HASH_TAG_NAME} -t ${LATEST_TAG_NAME} .

aws ecr get-login --region eu-west-2 > login.txt
cut -d " " -f1-6,9- login.txt | sh
docker push ${IMAGE_NAME}
