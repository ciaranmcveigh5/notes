#!/bin/bash

set -euo pipefail # make sure script fails promptly on error

cp ../../shared/specs/client-swagger.yml .
docker build -t local:imposter .
docker run -it -p 8443:8443 local:imposter