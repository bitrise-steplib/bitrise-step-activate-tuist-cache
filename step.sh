#! /bin/bash
set -euo pipefail

CACHE_URL=grpcs://pluggable.services.bitrise.io
RELEASE_URL=https://bitrise-tuist.bitrise.io/tuist-3.18-bitrise-a4baa03.zip
RELEASE_SHA256SUM=b31d9c982809a2dea0c0d7b091674bb4b9b3035d7efcb035fd1880d7284fbb88

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
