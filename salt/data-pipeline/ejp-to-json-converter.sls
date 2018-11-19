# may one day live outside of data-pipeline project

install repo:
    builder.git_latest:
        - name: git@github.com:elifesciences/data-pipeline-ejp-to-json-converter
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

    file.directory:
        - name: /opt/data-pipeline-ejp-to-json-converter
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group

temp dir symlink:
    file.symlink:
        - name: /ext/tmp/data-pipeline-ejp-to-json-converter-.temp
        - target: /opt/data-pipeline-ejp-to-json-converter/.temp
        - require:
            install repo

#
# gcloud
#

install google-cloud-sdk:
    archive.extracted:
        - name: /opt
        - source: https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-220.0.0-linux-x86_64.tar.gz
        - source_hash: a2205e35b11136004d52d47774762fbec9145bf0bda74ca506f52b71452c570e
        #- source: https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-218.0.0-linux-x86_64.tar.gz
        #- source_hash: 9e7f336e4b332cbc56a53d3af7b74a8e
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - trim_output: True

    # run the install script
    cmd.run:
        - cwd: /opt/google-cloud-sdk
        - runas: {{ pillar.elife.deploy_user.username }}
        - name: |
            set -e
            ./install.sh --usage-reporting=no --quiet
            ln -s /home/{{ pillar.elife.deploy_user.username }}
            touch .installed.flag
        - unless:
            - test -e .installed.flag

    file.managed:
        - name: /etc/profile.d/google-cloud-sdk-scripts-path.sh
        - contents: export PATH=/opt/google-cloud-sdk/bin:$PATH
        - mode: 644

{% if pillar.elife.env != "dev" %}
configure google-cloud-sdk:
    cmd.run:
        - cwd: /home/{{ pillar.elife.deploy_user.username }}
        - runas: {{ pillar.elife.deploy_user.username }}
        - name: gcloud auth activate-service-account --key-file=/srv/nifi-1.7.1/conf/gcs.json && bq version
{% endif %}

data directory:
    # this is where the container will read nifi data from
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

# helper script that runs as update-big-query as the elife user
update big query wrapper:
    file.managed:
        - name: /ext/ejp-to-json-converter/update-big-query-wrapper.sh
        - source: salt://data-pipeline/scripts/update-big-query-wrapper.sh
        - makedirs: True
        - mode: 740
