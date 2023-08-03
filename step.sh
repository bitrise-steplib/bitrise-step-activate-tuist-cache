#! /bin/bash
set -eo pipefail

CACHE_URL=grpcs://pluggable.services.bitrise.io
RELEASE_URL=https://bitrise-tuist.bitrise.io/tuist-3.21.1-bitrise-1f08276.zip
RELEASE_SHA256SUM=c4a38def14ad258d3cdef9206f215772c695df70670b3180ec3134b50269d49f
UNAVAILABLE_MESSAGE=$(cat <<-END
You have added the **Activate Bitrise Build Cache for Gradle** add-on step to your workflow.
    
However, it has not been activated for this workspace yet. Please contact [support@bitrise.io](mailto:support@bitrise.io) to activate it.

Build cache is not activated in this build.
END

)

if [ "$BITRISEIO_BUILD_CACHE_ENABLED" != "true" ]; then
  printf "\n%s\n" "$UNAVAILABLE_MESSAGE"
  bitrise :annotation annotate "$UNAVAILABLE_MESSAGE" --style error || {
    echo "Failed to create annotation"
    exit 0
  }
  exit 0
fi

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
