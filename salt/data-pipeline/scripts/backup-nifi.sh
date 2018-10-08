#!/bin/bash
# run as root from the {{ nifi_toolkit_dir }} directory
# this script is in charge of managing the {{ nifi_backup_dir }} where ubr will look daily to upload stuff to s3

set -e

if [ $firstdayofweek ]; then
    # do the comprehensive backup, 1.5GB+
    # UBR will be called immediately afterwards and clear the backup dir
    ./bin/file-manager.sh --operation backup --backupDir {{ nifi_backup_dir }} --nifiCurrentDir {{ nifi_dir }}
else
    # do a quick backup
    # maybe 100MB+
    mkdir -p {{ nifi_backup_dir }}
    (
        cd {{ nifi_dir }}
        
        # ignore these:
        # flowfile_repository == temporary flowfiles as they pass through this node
        # content_repository == flowfiles preserved for a certain amount of time in blobs
        # state == runtime indexes of flowfiles
        cp -R \
            provenance_repository \
            logs \
            conf \
            database_repository \
            {{ nifi_backup_dir }}/
    )
fi
