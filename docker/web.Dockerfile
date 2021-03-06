# DOCKERFILE FOR TIDE WEB
#
# Dockerfile that contains the project and that can serve the webapp.
#
# To build it, please execute:
#	 docker build \
#    -t cynnexis/tide:web \
#    --build-arg PROJECT_VERSION 0.0.1 \
#    --build-arg MAINTAINER_EMAIL=john.doe@corp.com \
#    --build-arg APT_UBUNTU_MIRROR_URL=http://ftp.rezopole.net/ \
#    --build-arg FLUTTER_WEB_RENDERER=auto \
#    --build-arg GOOGLE_SEARCH_META_OWNERSHIP_CONTENT=my-meta-id \
#    -f docker/web.Dockerfile \
#    .

########## STAGE 1 - BUILDER ##########
# Configure flutter for web and build web release.
FROM cynnexis/tide:sdk AS builder

# Add expand-emoji program
ADD https://github.com/Cynnexis/expand-emoji/releases/latest/download/expand-emoji-linux-amd64 /usr/bin/expand-emoji

# Arguments to use an APT mirror instead of default Ubuntu servers. Please make
# sure that the given value starts with the protocol (http://, https://,
# ftp://, ...) and ends with a slash ("/").
ARG APT_UBUNTU_MIRROR_URL

# The Flutter web rendered to use.
# See https://docs.flutter.dev/development/tools/web-renderers for more details.
ARG FLUTTER_WEB_RENDERER=auto

# Disable interactive behaviors
ARG DEBIAN_FRONTEND=noninteractive

# Change default shell to bash for conditions
SHELL ["/bin/bash", "-c"]

# Install web dependencies
RUN \
  set -euo pipefail; \
  # Configure installed program
  chmod a+x /usr/bin/expand-emoji && \
	# Change the mirror
	if [[ -v APT_UBUNTU_MIRROR_URL && -n $APT_UBUNTU_MIRROR_URL ]]; then \
		sed "s@http://archive.ubuntu.com/@$APT_UBUNTU_MIRROR_URL@" -i /etc/apt/sources.list ; \
	fi && \
	apt-get update && \
	apt-get install -qqy chromium-browser && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	# Update flutter project dependencies, activate web and build release
	flutter config --enable-web && \
	flutter doctor --no-color --verbose && \
	flutter clean && \
	flutter pub get && \
	# Build documentation
	flutter pub global activate dartdoc && \
	flutter pub global run dartdoc . && \
	# Expand emoji in documentation
	find doc -type f \( -iname '*.html' -o -iname '*.htm' -o -iname '*.html5' -o -iname '*.css' -o -iname '*.php' -o -iname '*.js' \) -exec expand-emoji "{}" \; 1> /dev/null && \
	# Build release
	flutter build web --release --web-renderer "$FLUTTER_WEB_RENDERER" && \
	make version

########## STAGE 2 - SERVER ##########
# Fetch the release from last stage and serve it
FROM httpd:2.4.51-alpine3.15 AS server

# The version of the Tide project.
# See pubspec.yaml
ARG PROJECT_VERSION

# The email address of the maintainer of the project.
ARG MAINTAINER_EMAIL

# If you want to monitor your website from Google Search Console, you might need to pass an HTML tag
# in the index.html file in order to assess your ownership over the server. Instead of adding the
# line directly to the `index.html` and to commit it (not recommended!), you can add the content of
# the "content" field in this variable. If this variable is set for instance to `abc`, then the
# index.html will have the following line:
#
#   <meta name="google-site-verification" content="abc"/>.
#
# Note that an empty string will not add anything to the index.html
ARG GOOGLE_SEARCH_META_OWNERSHIP_CONTENT=''

# Define labels
LABEL name="cynnexis/tide:web"
LABEL description="Dockerfile that contains the Tide project and that can serve the webapp."
LABEL version="$PROJECT_VERSION"
LABEL maintainer="$MAINTAINER_EMAIL"
LABEL apt_mirror_url="$APT_UBUNTU_MIRROR_URL"
LABEL flutter_web_renderer="$FLUTTER_WEB_RENDERER"

# Install bash
RUN apk add --no-cache bash

# Change default shell to bash for conditions
SHELL ["/bin/bash", "-c"]

# Copy the configuration file for apache2
COPY --from=builder /root/tide/docker/apache/httpd.template.conf /usr/local/apache2/conf/httpd.template.conf

# Copy the built HTML, CSS and JavaScript files from the previous stage to this
# stage, right in the served directory:
COPY --from=builder /root/tide/build/web /usr/local/apache2/htdocs

# Copy the built documentation
COPY --from=builder /root/tide/doc/api/ /usr/local/apache2/htdocs/docs/

# For cURL configuration
ENV CURL_HOME=/etc/curl

RUN \
	set -euo pipefail; \
	# Change access rights to conf, logs, bin from root to www-data
	# See https://github.com/docker-library/httpd/issues/102#issuecomment-404637485
	touch /var/log/apache-errors.log && \
	chown www-data: /var/log/apache-errors.log /usr/local/apache2/logs && \
	apk update && \
	apk upgrade && \
	apk add --no-cache tini tzdata gettext libcap curl openssl ca-certificates && \
	# Check Docker build arguments
	if [[ -z $PROJECT_VERSION || -z $MAINTAINER_EMAIL ]]; then \
	  echo "Expected PROJECT_VERSION and MAINTAINER_EMAIL to be non-empty, got PROJECT_VERSION=\"$PROJECT_VERSION\" and MAINTAINER_EMAIL=\"$MAINTAINER_EMAIL\"." 1>&2 && \
	  exit 1; \
	fi && \
	# Expand shell variable in template configuration file
	envsubst < /usr/local/apache2/conf/httpd.template.conf > /usr/local/apache2/conf/httpd.conf && \
	rm -f /usr/local/apache2/conf/httpd.template.conf && \
	# Add Google ownership meta tag if given
	if [[ -v GOOGLE_SEARCH_META_OWNERSHIP_CONTENT && -n $GOOGLE_SEARCH_META_OWNERSHIP_CONTENT ]]; then \
		line_where_to_insert=$(grep -m 1 -nEe '^\s*</head>' /usr/local/apache2/htdocs/index.html | awk -F ':' '{print $1;}') && \
		sed -i "$line_where_to_insert i <meta name=\"google-site-verification\" content=\"$GOOGLE_SEARCH_META_OWNERSHIP_CONTENT\"/>" /usr/local/apache2/htdocs/index.html; \
	fi && \
	# setcap to bind to privileged ports as non-root
	# See https://github.com/docker-library/httpd/issues/102#issuecomment-404637485
	setcap 'cap_net_bind_service=+ep' /usr/local/apache2/bin/httpd && \
	# Install Mozilla certificates
	echo "Installing Mozilla certificates..." && \
	curl -fsL https://curl.se/ca/cacert.pem -o /etc/ssl/certs/ca-curl.pem && \
	openssl x509 -outform der -in /etc/ssl/certs/ca-curl.pem -out /etc/ssl/certs/ca-curl.crt && \
	chown root: /etc/ssl/certs/ca-curl.* && \
	chmod 400 /etc/ssl/certs/ca-curl.* && \
	# Configure cURL
	mkdir -p "$CURL_HOME" && \
	echo -e "capath=/etc/ssl/certs/\ncacert=/etc/ssl/certs/ca-certificates.crt" > "$CURL_HOME/.curlrc" && \
	# Install new CA certificates
	update-ca-certificates && \
	# Clean APK
	rm -rf /var/cache/apk/*

# Change default user
USER www-data

EXPOSE 80

ENTRYPOINT [ "tini", "--", "httpd-foreground" ]
