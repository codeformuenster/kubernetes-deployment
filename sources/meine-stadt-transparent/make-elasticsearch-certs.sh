#!/bin/bash

set -e

certificates_path=secrets/certificates
# don't change these unless you're changing the `nodes_dn` in `elasticsearch.yml` as well
CN=elasticsearch
O=cfm
L=ms
ST=nrw
C=DE

#common_opts= --passphrase "" --key-bits 2048 --cn "${CN}" --organization "${O}" --locality "${L}" --province "${ST}" --country "${C}"

# generate CA
certstrap --depot-path "${certificates_path}" init --expires "10 years" --passphrase "" --key-bits 2048 --cn "${CN}-ca" --organization "${O}" --locality "${L}" --province "${ST}" --country "${C}"
# generate Cert
certstrap --depot-path "${certificates_path}" request-cert --passphrase "" --key-bits 2048 --cn "${CN}" --organization "${O}" --locality "${L}" --province "${ST}" --country "${C}"
# Sign it
certstrap --depot-path "${certificates_path}" sign --CA "${CN}-ca" --expires "10 years" "${CN}"
# Convert key
openssl pkcs8 -v1 "PBE-SHA1-3DES" -in "${certificates_path}/${CN}.key" -topk8 -out "$certificates_path/${CN}-pk8.key" -nocrypt
