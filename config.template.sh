#!/usr/bin/env bash

export STELLAR_CORE_DATA_DISK=
export GETH_DATA_DISK=

read -d '' STELLAR_BIFROST_CFG << CFG
{
    "ethereum": {
        "master_public_key": "xpub6C79.........",
        "network_id": "3",
        "minimum_value_eth": "0.00001"
    },
    "stellar": {
        "issuer_public_key": "...",
        "signer_secret_key": "...",
        "token_asset_code": "TOKE",
        "needs_authorize": "true",
        "network_passphrase": "Test SDF Network ; September 2015"
    },
    "database": {
        "type": "postgres"
    }
}
CFG
export STELLAR_BIFROST_CFG

export STELLAR_HORIZON_IMAGE="gcr.io/lucid-course-142515/github-otokarev-docker-stellar-horizon:v0.1.0"
export STELLAR_CORE_IMAGE="gcr.io/lucid-course-142515/github-otokarev-docker-stellar-core:v0.1.0"
export STELLAR_BIFROST_IMAGE="gcr.io/lucid-course-142515/github-otokarev-docker-stellar-bifrost:v0.1.0"

export DATABASE_INSTANCE="<PROJECT>:<ZONE>:<INSTANCE ID>=tcp:5432"

export STELLAR_CORE_DATABASE_URL="<DATABASE_URL in format postgres://USER:PASSWORD@127.0.0.1/DATABASE?sslmode=disable>"
export STELLAR_HORIZON_DATABASE_URL="<DATABASE_URL in format postgres://USER:PASSWORD@127.0.0.1/DATABASE?sslmode=disable>"
export STELLAR_BIFROST_DATABASE_URL="<DATABASE_URL in format postgres://USER:PASSWORD@127.0.0.1/DATABASE?sslmode=disable>"
