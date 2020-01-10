#/bin/bash
# WARN: removes input
# converts zip file to csv, applies changes in db, removes source zip

set -e
source_zip=$1
environment=${2:-{{ pillar.elife.env }}} # default to project instance env
source_basename=$(basename "$source_zip")
data_dir="/ext/ejp-to-json-converter/data/$environment"
dbname="$DATA_PIPELINE_DATABASE_NAME" # "elife_etl", default set in .env file 

# backwards compatibility
if [ "$environment" != "prod" ]; then
    dbname="$dbname_$environment" # "elife_etl_staging"
fi

actual_zip="$data_dir/$source_basename"
test -e "$actual_zip"

cd /opt/data-pipeline-ejp-to-json-converter
DATA_PIPELINE_DATABASE_NAME=$dbname docker-compose run --rm \
    -v $data_dir:/data \
    ejp-to-json-converter \
    python3 -m ejp_to_json_converter.stage_zip \
    --source-zip "/data/$source_basename"

DATA_PIPELINE_DATABASE_NAME=$dbname docker-compose run --rm \
    ejp-to-json-converter \
    python3 -m ejp_to_json_converter.apply_changes

rm -f "$actual_zip"
