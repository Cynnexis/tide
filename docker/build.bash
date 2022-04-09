#!/bin/bash

set -euo pipefail

if [[ -f sdk.Dockerfile ]]; then
  echo "Please execute this file at the root of the 'tide' project. Current directory: $(pwd)" 1>&2
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "This script requires jq." 1>&2
  exit 1
fi

if ! command -v yq &> /dev/null; then
  echo "This script requires yq." 1>&2
  exit 1
fi

print_help() {
  echo 'Tide Dockerfile builder'
  echo
  echo 'Build the Dockerfiles in tide/docker/.'
  echo
  echo "usage: $0 [-h/--help] [--android-sdk=VERSION] [--flutter-version=VERSION]"
  echo
  echo 'Arguments:'
  echo '  -h / --help   - Print this message and exit.'
  echo '  --config=FILE - Path the the configuration file. Defaults to "tide.yaml", and if not found, to "tide.yml".'
  echo
}

tide_config_file=
for arg in "$@"; do
	case $arg in
	  -h|--help)
	    print_help
	    exit 0
	    ;;
		--config=*)
		  build_sdk_args+=("--build-arg" "ANDROID_SDK_VERSION=${arg#*=}")
			;;
		*)
			echo "Invalid argument: $arg" 1>&2
			print_help 1>&2
			exit 1
			;;
	esac
done

if [[ -z $tide_config_file ]]; then
  if [[ -r tide.yaml ]]; then
    tide_config_file=tide.yaml
  elif [[ -r tide.yml ]]; then
    tide_config_file=tide.yml
  else
    echo "You need to create a readable tide.yml (or tide.yaml) from tide.sample.yml." 1>&2
    exit 1
  fi
fi

# Get information from configuration file
# shellcheck disable=SC2034
{
PROJECT_VERSION=$(yq e -MN --unwrapScalar '.version' pubspec.yaml)
ANDROID_SDK_VERSION=$(yq e -MN '.docker.android_sdk_version' "$tide_config_file")
ANDROID_BUILD_TOOLS_VERSION=$(yq e -MN '.docker.android_build_tools_version' "$tide_config_file")
FLUTTER_VERSION=$(yq e -MN '.docker.flutter_version' "$tide_config_file")
APT_UBUNTU_MIRROR_URL=$(yq e -MN '.docker.apt_ubuntu_mirror_url' "$tide_config_file")
FLUTTER_WEB_RENDERER=$(yq e -MN '.docker.flutter_web_renderer' "$tide_config_file")
GOOGLE_SEARCH_META_OWNERSHIP_CONTENT=$(yq e -MN '.docker.google_search_meta_ownership_content' "$tide_config_file")
MAINTAINER_EMAIL=$(yq e -MN '.maintainer_email' "$tide_config_file")
}

all_args=(\
ANDROID_SDK_VERSION \
ANDROID_BUILD_TOOLS_VERSION \
FLUTTER_VERSION \
APT_UBUNTU_MIRROR_URL \
FLUTTER_WEB_RENDERER \
GOOGLE_SEARCH_META_OWNERSHIP_CONTENT \
MAINTAINER_EMAIL \
)

# Fallback for arguments
for arg in "${all_args[@]}"; do
  if [[ "${!arg}" = "null" ]]; then
    printf -v "$arg" ''
  fi
done

# Check other parameters
if [[ -z $MAINTAINER_EMAIL || $MAINTAINER_EMAIL = "null" ]]; then
  echo "You need to specify maintainer_email in ${tide_config_file}." 1>&2
  exit 1
fi

build_sdk_args=()
build_web_args=()

# Add a build argument to the SDK Dockerfile.
#
# PARAMETERS
# ==========
# $@: The name of the environment variables to add. If the value associated to
#     the name of one of the variable is empty, it will not be added.
add_sdk_build_args() {
  for arg in "$@"; do
    if [[ -n $arg && -n ${!arg} ]]; then
      build_sdk_args+=("--build-arg" "$arg=${!arg}")
    fi
  done
}

# Add a build argument to the web Dockerfile.
#
# PARAMETERS
# ==========
# $@: The name of the environment variables to add. If the value associated to
#     the name of one of the variable is empty, it will not be added.
add_web_build_args() {
  for arg in "$@"; do
    if [[ -n $arg && -n ${!arg} ]]; then
      build_web_args+=("--build-arg" "$arg=${!arg}")
    fi
  done
}

add_sdk_build_args ANDROID_SDK_VERSION ANDROID_BUILD_TOOLS_VERSION FLUTTER_VERSION
add_web_build_args FLUTTER_WEB_RENDERER GOOGLE_SEARCH_META_OWNERSHIP_CONTENT

common_vars=(PROJECT_VERSION APT_UBUNTU_MIRROR_URL MAINTAINER_EMAIL)
add_sdk_build_args "${common_vars[@]}"
add_web_build_args "${common_vars[@]}"

PS4='$ '

# Build Flutter SDK first
set -x
time docker build -t cynnexis/tide:sdk "${build_sdk_args[@]}" -f docker/sdk.Dockerfile .
{ set +x; } 2> /dev/null

# Set the tag
docker tag cynnexis/tide:sdk "cynnexis/tide:sdk-$PROJECT_VERSION"

# Then, build the Apache server
set -x
time docker build -t "cynnexis/tide:web" "${build_web_args[@]}" -f docker/web.Dockerfile .
{ set +x; } 2> /dev/null

# Set the tag
docker tag cynnexis/tide:web "cynnexis/tide:web-$PROJECT_VERSION"
