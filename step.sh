#! /bin/bash
set -euo pipefail

CACHE_URL=grpcs://pluggable.services.bitrise.io
RELEASE_URL=https://storage.googleapis.com/bitrise-tuist-fork/tuist-3.15-bitrise-2315adc.zip
RELEASE_SHA256SUM=b0dd2d57aa07948de2cbac9ff31492dcd9016662e12d5ea4365e36d5b4971d15

DOWNLOAD_PATH=$TMPDIR/tuist.zip
echo "Downloading $RELEASE_URL"
curl --fail --silent --show-error $RELEASE_URL --output "$DOWNLOAD_PATH"

DOWNLOAD_CHECKSUM=$(sha256sum "$DOWNLOAD_PATH" | cut -d' ' -f1)

if test $RELEASE_SHA256SUM = "$DOWNLOAD_CHECKSUM"
then
  echo "Checksum OK"
else
  printf "Checksum mismatch\nExpected: %s\nActual: %s" $RELEASE_SHA256SUM "$DOWNLOAD_CHECKSUM";
  exit 1
fi

echo "Moving downloaded Tuist version to .tuist-bin..."
TUIST_BIN_PATH=$BITRISE_SOURCE_DIR/.tuist-bin
rm -rf "$TUIST_BIN_PATH"
mkdir "$TUIST_BIN_PATH"
tar -xf "$DOWNLOAD_PATH" --directory="$TUIST_BIN_PATH"
echo "Done"

echo "Configuring Bitrise remote cache..."
envman add --key REMOTE_CACHE_ENDPOINT --value $CACHE_URL
envman add --key REMOTE_CACHE_TOKEN --value "$BITRISEIO_BITRISE_SERVICES_ACCESS_TOKEN"
echo "Done!"
echo "Tuist commands will utilize the remote cache from now on."
