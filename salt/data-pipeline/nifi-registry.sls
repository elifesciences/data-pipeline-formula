 
{% set nifi_registry_dir = "/srv/nifi-registry-0.3.0" %}

download-nifi-registry:
    file.managed:
        - name: /root/downloads/nifi-registry-0.3.0-bin.tar.gz
        - source: https://www-eu.apache.org/dist/nifi/nifi-registry/nifi-registry-0.3.0/nifi-registry-0.3.0-bin.tar.gz
        - source_hash: 4e432b6436881d641c45595cb98f7f6f3c396ca28dd85ce51c7b66c9b2bf8710
        - makedirs: True
        - replace: False
        - require:
            - vagrant-root-downloads-link

    archive.extracted:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/
        - if_missing: {{ nifi_registry_dir }}
        - source: /root/downloads/nifi-registry-0.3.0-bin.tar.gz
        - source_hash: 4e432b6436881d641c45595cb98f7f6f3c396ca28dd85ce51c7b66c9b2bf8710
        - makedirs: True
        - trim_output: True
        - replace: False
        - require:
            - file: download-nifi-registry

nifi-registry-symlink:
    file.symlink:
        - name: /srv/nifi-registry
        - target: {{ nifi_registry_dir }}
        - require:
            - download-nifi-registry

install-registry-init-file:
    file.managed:
        - name: /lib/systemd/system/nifi-registry.service
        - source: salt://data-pipeline/config/lib-systemd-system-nifi-registry.service

generate registry keystore:
    cmd.run:
        - cwd: /srv/nifi-registry/conf
        - name: |
            keytool -genkeypair -noprompt \
                -alias nifi-registry \
                -dname "CN=localhost, OU=IT, O=eLife, L=Cambridge, S=Cambridgeshire, C=GB" \
                -keystore nifi-registry.keystore \
                -storepass {{ pillar.data_pipeline.nifi_registry.keystore_password }} \
                -keypass {{ pillar.data_pipeline.nifi_registry.key_password }}
        - unless:
            - test -e /srv/nifi-registry/conf/nifi.keystore

nifi-registry-config-properties:
    file.managed:
        - name: /srv/nifi-registry/conf/nifi-registry.properties
        - source: salt://data-pipeline/config/srv-nifi-registry-conf-nifi-registry.properties
        - template: jinja
        - defaults:
            dev: {{ pillar.elife.env == 'dev' }}

nifi-registry:
    service.running:
        - enable: True
        - require:
            - install-registry-init-file
        - watch:
            - nifi-registry-config-properties

