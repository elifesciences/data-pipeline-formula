#!/bin/bash
# run as root
set -eu
environment=${1:-{{ pillar.elife.env }}} # backwards compatibility: default to instance environment
sudo -u elife --login /bin/bash << EOF
cd /opt/data-pipeline-ejp-to-json-converter/
DATA_PIPELINE_BQ_DATASET=$environment ./update-big-query.sh
EOF
#

