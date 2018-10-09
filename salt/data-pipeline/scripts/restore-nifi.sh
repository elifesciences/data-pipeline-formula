#!/bin/bash
# run as root from {{ nifi_toolkit_dir }}
# assumes complete a full backup is available in {{ nifi_restore_dir }}
# full backups are done once a week, partial backups daily

set -ex

# TODO: can I target a specific backup to download from UBR? that would be convenient

# directory only present on a full backups
test -d {{ nifi_restore_dir }}/bootstrap_files/

# TODO: do I need to stop nifi?

./bin/file-manager.sh --operation restore --backupDir {{ nifi_restore_dir }} --nifiRollbackDir {{ nifi_dir }}
