#/bin/bash
# WARN: removes input
# converts zip file to csv, applies changes in db, removes source zip

set -e
source_zip=$1
source_basename=$(basename "$source_zip")
data_dir="/ext/ejp-to-json-converter/data"

actual_zip="$data_dir/$source_basename"
test -e "$actual_zip"

cd /opt/data-pipeline-ejp-to-json-converter
docker-compose run --rm \
    -v $data_dir:/data \
    ejp-to-json-converter \
    python -m ejp_to_json_converter.stage_zip \
    --source-zip "/data/$source_basename"

docker-compose run --rm \
    ejp-to-json-converter \
    python -m ejp_to_json_converter.apply_changes

rm -f "$actual_zip"
