#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck >/dev/null && shellcheck "$0"

# Please keep this in sync with the Ports overview in HACKING.md
TENDERMINT_PORT_GUEST="26657"
TENDERMINT_PORT_HOST="26658"
API_PORT_GUEST="1317"
API_PORT_HOST="1318"

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
# shellcheck source=./env
# shellcheck disable=SC1091
source "$SCRIPT_DIR"/env

# TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/simapp.XXXXXXXXX")
# chmod 777 "$TMP_DIR"
# echo "Using temporary dir $TMP_DIR"
# SIMD_LOGFILE="$TMP_DIR/simd.log"

# Use a fresh volume for every start
docker volume rm -f simapp_data
docker pull "$REPOSITORY:$VERSION"

echo "starting simd running on http://localhost:$TENDERMINT_PORT_HOST"

docker run --rm \
  --name "$CONTAINER_NAME" \
  -p "$TENDERMINT_PORT_HOST":"$TENDERMINT_PORT_GUEST" \
  -p "$API_PORT_HOST":"$API_PORT_GUEST" \
  --mount type=bind,source="$SCRIPT_DIR/template",target=/template \
  --mount type=volume,source=simapp_data,target=/root \
  "$REPOSITORY:$VERSION" \
  /template/run_simd.sh \
  2>&1 | grep -i 'Executed block'
