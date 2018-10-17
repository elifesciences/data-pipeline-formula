#!/bin/bash
# run as root
set -e
sudo -u elife --login /bin/bash << EOF
cd /opt/data-pipeline-ejp-to-json-converter/
./update-big-query.sh
EOF
#

