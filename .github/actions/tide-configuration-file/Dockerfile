# Dockerfile used by the Tide CI/CD workflow to add the configuration file
# tide.yaml in the working directory.
#
# See https://docs.github.com/en/actions/creating-actions/about-custom-actions
# to learn more about custom GitHub Actions using Docker.
#
# Note that this Dockerfile must be built with its parents folder as context.
#
FROM alpine:3.15.4

# Copy the entrypoint.bash. It is assumed that the context is in the same
# directory as this Dockerfile.
COPY entrypoint.bash /usr/bin/entrypoint.bash

RUN \
  # Make the entrypoint.bash script executable
  chmod a+x /usr/bin/entrypoint.bash && \
  # Install requirements
  apk update && \
  apk add --no-cache bash git

ENTRYPOINT [ "/usr/bin/entrypoint.bash" ]
