# https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html
   
# download nifi and nifi-kit

{% set nifi_dir = "/srv/nifi-1.7.1" %}
{% set nifi_ext_dir = "/ext/nifi" %}
{% set nifi_toolkit_dir = "/srv/nifi-toolkit-1.7.1" %}

# vagrant only
# guest:/root/downloads -> guest:/vagrant -> host:./builder/downloads
vagrant-root-downloads-link:
    cmd.run:
        - cwd: /root
        - name: rm -f downloads && ln -s /vagrant/downloads
        - onlyif:
            - test -d /vagrant

download-nifi:
    file.managed:
        - name: /root/downloads/nifi-1.7.1-bin.tar.gz
        - source: http://www-eu.apache.org/dist/nifi/1.7.1/nifi-1.7.1-bin.tar.gz
        - source_hash: 51dd598178992fa617cb28a8c77028b3
        - makedirs: True
        - replace: False
        - keep_source: False # is large at 1GB+
        - require:
            - vagrant-root-downloads-link
        - unless:
            - test -d {{ nifi_dir }} # file has been unpacked

    archive.extracted:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/
        - if_missing: {{ nifi_dir }}
        - source: /root/downloads/nifi-1.7.1-bin.tar.gz
        - source_hash: 51dd598178992fa617cb28a8c77028b3
        - keep_source: True # default
        - require:
            - file: download-nifi

download-nifi-toolkit:
    file.managed:
        - name: /root/downloads/nifi-toolkit-1.7.1-bin.tar.gz
        - source: http://www-eu.apache.org/dist/nifi/1.7.1/nifi-toolkit-1.7.1-bin.tar.gz
        - source_hash: 3247bb6194977da6dbf90d476289e0de
        - makedirs: True
        - replace: False
        - require:
            - vagrant-root-downloads-link

    archive.extracted:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/
        - if_missing: {{ nifi_toolkit_dir }}
        - source: /root/downloads/nifi-toolkit-1.7.1-bin.tar.gz
        - source_hash: 3247bb6194977da6dbf90d476289e0de
        - keep_source: True # default
        - require:
            - file: download-nifi-toolkit

nifi-ext-dir:
    file.directory:
        - name: {{ nifi_ext_dir }}
        - makedirs: True
        - require:
            - download-nifi

# todo: there is configuration inside nifi referencing the '1.7.1' path. obviously not a good idea
nifi-symlink:
    file.symlink:
        - name: /srv/nifi
        - target: {{ nifi_dir }}
        - require:
            - download-nifi

nifi-init-file:
    file.managed:
        - name: /lib/systemd/system/nifi.service
        - source: salt://data-pipeline/config/lib-systemd-system-nifi.service

generate keystore:
    cmd.run:
        - cwd: {{ nifi_dir }}/conf
        - name: |
            keytool -genkeypair -noprompt \
                -alias client \
                -dname "CN=localhost, OU=IT, O=eLife, L=Cambridge, S=Cambridgeshire, C=GB" \
                -keystore nifi.keystore \
                -storepass {{ pillar.data_pipeline.nifi.keystore_password }} \
                -keypass {{ pillar.data_pipeline.nifi.key_password }}
        - unless:
            - test -e {{ nifi_dir }}/conf/nifi.keystore

nifi-config-properties:
    file.managed:
        - name: {{ nifi_dir }}/conf/nifi.properties
        - source: salt://data-pipeline/config/srv-nifi-conf-nifi.properties
        - template: jinja
        - defaults:
            dev: {{ pillar.elife.env == 'dev' }}
            nifi_dir: {{ nifi_dir }}
            nifi_ext_dir: {{ nifi_ext_dir }}
        - require:
            - nifi-ext-dir
        - watch_in:
            - service: nifi

# nifi.properties can specify where the lib directory is and the lib directory is about 1.5GB of jar/nar files
# a bunch of other things still depend on it being at /path/to/nifi/lib though
nifi-lib-symlink:
    cmd.run:
        - name: mv {{ nifi_dir }}/lib {{ nifi_ext_dir }}/lib
        - require:
            - nifi-ext-dir
        - onlyif:
            - test -d {{ nifi_dir }}/lib

    file.symlink:
        - name: /srv/nifi/lib
        - target: {{ nifi_ext_dir }}/lib
        - require:
            - cmd: nifi-lib-symlink

nifi-aws-properties:
    file.managed:
        - name: {{ nifi_dir }}/conf/aws.properties
        - source: salt://data-pipeline/config/srv-nifi-conf-aws.properties
        - template: jinja

# TODO: this should 'gcp', 'google cloud platform' rather than 'gcs', which is 'google cloud storage'
nifi-gcs-json:
    file.managed:
        - name: {{ nifi_dir }}/conf/gcs.json
        - source: salt://data-pipeline/config/srv-nifi-conf-gcs.json

nifi-config-auth:
    file.managed:
        - name: {{ nifi_dir }}/conf/authorizers.xml
        - source: salt://data-pipeline/config/srv-nifi-conf-authorizers.xml
        - watch_in:
            - service: nifi

nifi:
    # this can take a while to come up
    service.running:
        - enable: True
        - watch:
            - nifi-config-properties
            - nifi-init-file

nifi-nginx-proxy:
    file.managed:
        - name: /etc/nginx/sites-enabled/nifi-demo.conf
        - source: salt://data-pipeline/config/etc-nginx-sites-enabled-nifi-demo.conf
        - template: jinja
        - watch_in:
            - service: nginx-server-service

flow support repo:
    builder.git_latest:
        - name: git@github.com:elifesciences/data-pipeline-flow-support
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - branch: master
        - target: /opt/flow-support
        - force_fetch: True
        - force_checkout: True
        - force_reset: True

    file.directory:
        - name:  /opt/flow-support
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: flow support repo

#
# 2019-02-11. section deprecated, removed once fully deployed
# 

grr:
    pkg.purged:
        - pkgs:
            - openjdk-8-jdk-headless
            - maven

build nifi-bigquery-bundle:
    file.absent:
        - name: /opt/nifi-bigquery-bundle

remove nifi-bigquery-processor:
    file.absent:
        - name: {{ nifi_ext_dir }}/lib/nifi-bigquery-nar-0.1.nar

#
#
#

nifi ubr backup:
    file.managed:
        - name: /etc/ubr/nifi-backup.yaml
        - source: salt://data-pipeline/config/etc-ubr-nifi-backup.yaml
        - template: jinja
        - defaults:
            nifi_dir: {{ nifi_dir }}

{% set backup_restore_dir = "/ext/tmp/backup" %}

# nifi can do an elaborate backup that is quite large but easy to restore from
# what is probably most essential for recovery is the global flow file that is tiny
# the backup script will, on the first day of the week, do a comprehensive backup
# and every other day it will do the smaller files/dirs that it needs
nifi backup script:
    file.managed:
        - name: {{ nifi_toolkit_dir }}/backup-nifi.sh
        - source: salt://data-pipeline/scripts/backup-nifi.sh
        - mode: 750
        - template: jinja
        - defaults:
            nifi_dir: {{ nifi_dir }}
            nifi_ext_dir: {{ nifi_ext_dir }}
            nifi_toolkit_dir: {{ nifi_toolkit_dir }}
            nifi_backup_dir: {{ backup_restore_dir }}
        - require:
            - download-nifi
            - download-nifi-toolkit

nifi restore script:
    file.managed:
        - name: {{ nifi_toolkit_dir }}/restore-nifi.sh
        - source: salt://data-pipeline/scripts/restore-nifi.sh
        - mode: 750
        - template: jinja
        - defaults:
            nifi_dir: {{ nifi_dir }}
            nifi_toolkit_dir: {{ nifi_toolkit_dir }}
            nifi_restore_dir: {{ backup_restore_dir }}
        - require:
            - download-nifi
            - download-nifi-toolkit

# see builder-base-formula/salt/elife/backups-cron.sls
extend:
    daily-backups:
        {% if pillar.elife.env in ['dev', 'ci', 'end2end'] %}
        cron.absent:
        {% else %}
        cron.present:
        {% endif %}
            - user: root
            - identifier: daily-app-backups
            - name: cd {{ nifi_toolkit_dir }} && ./backup-nifi.sh && cd /opt/ubr/ && ./ubr.sh > /var/log/ubr-cron.log && rm -rf {{ backup_restore_dir }}
            - minute: 0
            - hour: 23
            - require:
                - install-ubr
                - nifi backup script

#
# logging
#

syslog-ng config:
    file.managed:
        - name: /etc/syslog-ng/conf.d/nifi.conf
        - source: salt://data-pipeline/config/etc-syslog-ng-conf.d-nifi.conf
        - template: jinja
        - defaults:
            nifi_dir: {{ nifi_dir }}
