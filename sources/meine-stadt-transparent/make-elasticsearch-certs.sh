#!/bin/bash

set -e

CN=elasticsearch

certstrap --depot-path secrets/certificates init --expires "10 years" --cn "${CN}-ca" --passphrase ""
for i in {0..2}
do
    certstrap --depot-path secrets/certificates request-cert --cn "${CN}-node-${i}" --passphrase ""
    certstrap --depot-path secrets/certificates sign --CA "${CN}-ca" --expires "10 years" "${CN}-node-${i}"
done
