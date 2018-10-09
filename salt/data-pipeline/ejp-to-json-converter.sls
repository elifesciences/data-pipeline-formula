# may one day live outside of data-pipeline project

install repo:
    builder.git_latest:
        - name: git@github.com:elifesciences/data-pipeline-ejp-to-json-converter.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ salt['elife.rev']() }}
        - branch: {{ salt['elife.branch']() }}
        - target: /opt/data-pipeline-ejp-to-json-converter
        - force_fetch: True
        - force_checkout: True
        - force_reset: True

    cmd.run:
        - cwd: /opt/data-pipeline-ejp-to-json-converter/
        - name: docker-compose build
        - require:
            - builder: install repo

    # this is where the container will read nifi data from (untested)
    file.directory:
        - name: /ext/ejp-to-json-converter/data
        - makedirs: True

# helper script that ties all the docker commands together
process file script:
    file.managed:
        - name: /ext/ejp-to-json-converter/process-zip-apply.sh
        - source: salt://data-pipeline/scripts/process-zip-apply.sh
        - makedirs: True
        - mode: 740
