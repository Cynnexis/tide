# Dockerfile used by the Tide CI/CD workflow to add the configuration file
# tide.yaml in the working directory.
#
# See https://docs.github.com/en/actions/creating-actions/about-custom-actions
# to learn more about custom GitHub Actions using Docker.
#
# Note that this Dockerfile must be built with its parents folder as context.
#
FROM ubuntu:20.04

# Disable interactive behaviors during build
ARG DEBIAN_FRONTEND=noninteractive

# Copy the entrypoint.bash. It is assumed that the context is in the same
# directory as this Dockerfile.
COPY entrypoint.bash /usr/bin/entrypoint.bash

# To install git at the latest version, you need to run the following commands:
#
# $ apt-get update
# $ apt-get install -qqy software-properties-common
# $ add-apt-repository ppa:git-core/ppa
# $ apt-get update
# $ apt-get install -qqy git
#
# It is not recommended to use them, as the installation is quite long. If it
# is possible, please install a more stable version of git using apt.

RUN \
  # Make the entrypoint.bash script executable
  chmod a+x /usr/bin/entrypoint.bash && \
  # Install requirements
  apt-get update && \
  apt-get install -qqy git && \
  # Clean apt
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/usr/bin/entrypoint.bash" ]
