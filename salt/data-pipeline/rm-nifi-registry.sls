 
{% set nifi_registry_dir = "/srv/nifi-registry-0.3.0" %}

download-nifi-registry:
    file.absent:
        - name: /root/downloads/nifi-registry-0.3.0-bin.tar.gz

delete-nifi-registry:
    file.absent:
        - name: {{ nifi_registry_dir }}

nifi-registry-symlink:
    file.absent:
        - name: /srv/nifi-registry

install-registry-init-file:
    file.absent:
        - name: /lib/systemd/system/nifi-registry.service

nifi-registry:
    service.dead:
        - require_in:
            - install-registry-init-file

