#!/bin/bash

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

fail=

db_file_path=${FATHOM_DATABASE_NAME:-}
if [[ -z "${db_file_path}" ]]; then
    echo "Error: No FATHOM_DATABASE_NAME variable found"
    fail=1
fi

host_var=${MC_HOST_c4m:-}
if [[ -z "${host_var}" ]]; then
    echo "Error: No MC_HOST_c4m variable found."
    echo "It needs to be in this format: MC_HOST_<alias>=https://<Access Key>:<Secret Key>:<Session Token>@<YOUR-S3-ENDPOINT>"
    fail=1
fi

if [[ -n "$fail" ]]; then
  exit 1
fi

workdir="/tmp/backup"
backup_target="c4m/codeformuenster/fathom-backup"

# Create sqlite backup
sqlite3 "${db_file_path}" -bail "VACUUM main INTO '${workdir}/fathom.db';"

# Compress
gzip -9 -k "${workdir}/fathom.db"

# Upload
mc cp "${workdir}/fathom.db.gz" "${backup_target}/fathom-$(date --utc -Iseconds).db.gz"
