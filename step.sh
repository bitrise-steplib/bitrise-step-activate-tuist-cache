#! /bin/bash
set -euo pipefail

CACHE_URL=grpcs://pluggable.services.bitrise.io
RELEASE_URL=https://storage.googleapis.com/bitrise-tuist-fork/tuist-3.15-bitrise-999cd33.zip
RELEASE_SHA256SUM=a56848b3cf0608e78581728b44bd63e92e8a966c68f934e8f3a6ca279266dc58

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
envman add --key TUIST_BITRISE_CACHE_URL --value $CACHE_URL
envman add --key TUIST_BITRISE_CACHE_TOKEN --value "$BITRISEIO_BITRISE_SERVICES_ACCESS_TOKEN"
echo "Done!"
echo "Tuist commands will utilize the remote cache from now on."
