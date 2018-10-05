#/bin/bash
# ejp-XML-scraper, 

set -e
source_zip=$1
source_basename=$(basename "$source_zip")
test -e "/ext/ejp-xml-scraper/data/$source_basename"

cd /opt/data-pipeline-ejp-to-json-converter
docker-compose run --rm \
    -v /ext/ejp-xml-scraper/data:/data \
    ejp-to-json-converter \
    python -m ejp_to_json_converter.stage_zip \
    --source-zip "/data/$source_basename"

docker-compose run --rm \
    ejp-to-json-converter \
    python -m ejp_to_json_converter.apply_changes
