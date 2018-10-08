# may one day live outside of data-pipeline project

install repo:
    git.latest:
        - name: git@github.com:elifesciences/data-pipeline-ejp-to-json-converter.git
        - target: /opt/data-pipeline-ejp-to-json-converter

    cmd.run:
        - cwd: /opt/data-pipeline-ejp-to-json-converter/
        - name: docker-compose build

    # this is what the container will read from
    file.directory:
        - name: /ext/ejp-xml-scraper/data
        - makedirs: True


# helper script that ties all the docker commands together
process file script:
    file.managed:
        - name: /ext/ejp-xml-scraper/process-zip-apply.sh
        - source: salt://data-pipeline/scripts/process-zip-apply.sh
        - makedirs: True
        - mode: 740
