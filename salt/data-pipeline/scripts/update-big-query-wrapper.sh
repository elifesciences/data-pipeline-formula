#!/bin/bash
# run as root
set -e
sudo -u elife --login /bin/bash << EOF
cd /opt/data-pipeline-ejp-to-json-converter/
DATA_PIPELINE_BQ_DATASET={{ pillar.env }} ./update-big-query.sh
EOF
#

