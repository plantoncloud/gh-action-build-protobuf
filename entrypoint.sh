#!/bin/sh
set -o errexit
set -o nounset

export PLANTON_CLOUD_SERVICE_CLI_ENV=${1}
export PLANTON_CLOUD_SERVICE_CLIENT_ID=${2}
export PLANTON_CLOUD_SERVICE_CLIENT_SECRET=${3}
export PLANTON_CLOUD_ARTIFACT_STORE_ID=${4}

if ! [ -n "${PLANTON_CLOUD_SERVICE_CLIENT_ID}" ]; then
  echo "PLANTON_CLOUD_SERVICE_CLIENT_ID is not set. Configure Machine Account Credentials for Repository or Organization."
  exit 1
fi
if ! [ -n "${PLANTON_CLOUD_SERVICE_CLIENT_SECRET}" ]; then
  echo "PLANTON_CLOUD_SERVICE_CLIENT_SECRET is not set. Configure Machine Account Credentials for Repository or Organization."
  exit 1
fi
if ! [ -n "${PLANTON_CLOUD_ARTIFACT_STORE_ID}" ]; then
  echo "PLANTON_CLOUD_ARTIFACT_STORE_ID is required. It should be set to the id of the artifact-store on planton cloud"
  exit 1
fi

echo "exchanging planton-cloud machine-account credentials to get an access token"
planton auth machine login \
  --client-id $PLANTON_CLOUD_SERVICE_CLIENT_ID \
  --client-secret $PLANTON_CLOUD_SERVICE_CLIENT_SECRET
echo "successfully exchanged planton-cloud machine-account credentials and received an access token"
echo "fetching buf token from artifact-store: ${PLANTON_CLOUD_ARTIFACT_STORE_ID}"
#looks up buf-token configured on artifact-store and exports it as an environment variable.
#if either the artifact-store does not have a buf-token or project does not import any npm packages from
# npm repository on buf.build, this step has no effect.
export BUF_TOKEN=$(planton product artifact-store secrets get-buf-token --artifact-store-id ${PLANTON_CLOUD_ARTIFACT_STORE_ID} 2>&1)
echo "successfully fetched buf token from artifact-store: ${PLANTON_CLOUD_ARTIFACT_STORE_ID}"
#todo: add buf-username fetching using cli
echo "running 'make build' step"
make build
echo "step 'make build' completed successfully"
