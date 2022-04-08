# DOCKERFILE FOR FLUTTER SDK
#
# This Dockerfile builds a Docker image containing the Flutter SDK with the tide
# project.
# It based on https://github.com/cirruslabs/docker-images-flutter
#
# To build it, please execute:
#	 docker build \
#    -t cynnexis/tide:sdk \
#    --build-arg ANDROID_SDK_VERSION=32 \
#    --build-arg FLUTTER_VERSION=stable \
#    --build-arg PROJECT_VERSION 0.0.1 \
#    --build-arg MAINTAINER_EMAIL=john.doe@corp.com \
#    --build-arg APT_UBUNTU_MIRROR_URL=http://ftp.rezopole.net/ \
#    -f docker/sdk.Dockerfile \
#    .

FROM cirrusci/android-sdk:tools

# The Android SDK version to use.
# See https://developer.android.com/studio/releases/platforms
ARG ANDROID_SDK_VERSION=32

# The Android SDK tools version.
# See https://developer.android.com/studio/releases/build-tools
ARG ANDROID_BUILD_TOOLS_VERSION=30.0.2

# The Flutter channel name to use.
# See https://docs.flutter.dev/development/tools/sdk/releases
ARG FLUTTER_VERSION=stable

# The version of the Tide project.
# See pubspec.yaml
ARG PROJECT_VERSION

# The email address of the maintainer of the project.
ARG MAINTAINER_EMAIL

# Arguments to use an APT mirror instead of default Ubuntu servers. Please make
# sure that the given value starts with the protocol (http://, https://,
# ftp://, ...) and ends with a slash ("/").
ARG APT_UBUNTU_MIRROR_URL

# Define labels
LABEL name="cynnexis/tide:sdk"
LABEL description="Dockerfile that contains the Flutter SDK with the Tide project."
LABEL version="$PROJECT_VERSION"
LABEL maintainer="$MAINTAINER_EMAIL"
LABEL android_sdk_version="$ANDROID_SDK_VERSION"
LABEL flutter_version="$FLUTTER_VERSION"
LABEL apt_mirror_url="$APT_UBUNTU_MIRROR_URL"

# Disable interactive behaviors
ARG DEBIAN_FRONTEND=noninteractive

ENV \
  WORKDIR=/root/tide \
  FLUTTER_HOME=/opt/flutter \
  FLUTTER_VERSION="$FLUTTER_VERSION"

ENV \
  FLUTTER_ROOT="$FLUTTER_HOME" \
  PATH="${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:/root/.pub-cache/bin"

USER root
WORKDIR "$WORKDIR"

# Change default shell to bash
SHELL ["/bin/bash", "-c"]

# Copy workspace to image
COPY . "$WORKDIR"

RUN \
	set -euo pipefail; \
	# Install Android SDK
	sdkmanager \
    "platforms;android-$ANDROID_SDK_VERSION" \
    "build-tools;$ANDROID_BUILD_TOOLS_VERSION" && \
  # Clone flutter
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_HOME" && \
  # Accept Android licenses
  flutter doctor --android-licenses && \
  # Disable telemetry
	dart --disable-analytics && \
	flutter config --no-analytics && \
	# Run flutter doctor to download Flutter requirements, and print useful
	# information during build
  flutter doctor --no-color --verbose && \
  chown -R root:root "${FLUTTER_HOME}" && \
	# Change the APT mirror
	if [[ -v APT_UBUNTU_MIRROR_URL && -n $APT_UBUNTU_MIRROR_URL ]]; then \
		sed "s@http://archive.ubuntu.com/@$APT_UBUNTU_MIRROR_URL@" -i /etc/apt/sources.list ; \
	fi && \
	# Install some tools and dependencies
	apt-get update && \
	apt-get install -qq dos2unix lcov make && \
	# Remove the updates list of packages to lighten the layer
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	# Configure project
	flutter clean && \
	# Print the version of the built flutter app
	make version

ENTRYPOINT [ "flutter" ]
