#!/usr/bin/make
ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif
PORT=8080
SHELL=/bin/bash
HOST="localhost"
.ONESHELL:

all: help

.PHONY: help
help:
	@echo -e "\tMakefile for Tide"
	@echo ''
	@echo "  usage: $0 [COMMAND]"
	@echo ''
	@echo "The available commands are:"
	@echo ''
	@echo "  help                  - Print this help text and exit."
	@echo "  configure             - Configure the project folder."
	@echo "  lint                  - Check the code format."
	@echo "  fix-lint              - Fix the code format."
	@echo "  test                  - Run the Flutter unit and widget tests."
	@echo "  update-goldens        - Create or update golden files."
	@echo "  docker-update-goldens - Create or update golden files from a Linux Docker container (to update the Linux golden images)."
	@echo "  doc                   - Generate the documentation."
	@echo "  rmdoc                 - Remove the documentation."
	@echo "  update-launcher       - Update the icon launcher."
	@echo "  build-release-android - Build a release version for Android. It is currently not supported in this Makefile."
	@echo "  fix-packages-version  - Replace the 'any' packages version in 'pubspec.yaml' to their actual installed version based on 'pubspec.lock'."
	@echo ''

# Print to stdout the configuration file if found, else and print error message to stderr and exit with code 1
.PHONY: get-config-file
get-config-file:
	@set -euo pipefail

	if [[ -f tide.yaml ]]; then
		echo "tide.yaml"
	elif [[ -f tide.yml ]]; then
		echo "tide.yml"
	else
		echo "No tide.yaml found at the root of the project." 1>&2
		exit 1
	fi

.PHONY: configure
configure:
	@flutter channel beta
	flutter upgrade
	flutter pub get
	flutter packages pub run build_runner build
	echo "\nFlutter has now the web feature enable. Please check the following tutorial to ensure it works: https://flutter.dev/docs/get-started/web"

.PHONY: clean
clean:
	flutter clean
	rm -rf coverage
	rm -f .coverage

.PHONY: lint
lint:
	@set -euo pipefail
	echo "Checking Dart files format..."
	flutter format --output none --set-exit-if-changed .

.PHONY: fix-lint
fix-lint:
	flutter format --fix .

.PHONY: test
test:
	@set -euo pipefail
	flutter test --coverage --reporter expanded --dart-define=FLUTTER_TEST=true

.PHONY: docker-test
docker-test:
	@set -euo pipefail

	# Bash array containing all volumes as arguments
	extra_volumes=()

	set +e
	config_file=$$($(MAKE) --quiet --no-print-directory get-config-file 2> /dev/null)
	set -e

	if [[ -n $$config_file ]]; then
	  extra_volumes+=("-v" "$$(realpath "$$config_file"):/usr/local/apache2/htdocs/assets/tide.yaml:ro")
	fi

	docker run \
			-it \
			--rm \
    		--name=tide-tests \
    		--hostname="tide-tests" \
    		-v "/etc/timezone:/etc/timezone:ro" \
    		-v "/etc/localtime:/etc/localtime:ro" \
    		"$${extra_volumes[@]}" \
    		-e TZ \
    		--restart=no \
    		--security-opt="no-new-privileges=true" \
    		--cap-drop=all \
    		cynnexis/tide:sdk test --coverage --concurrency=1 --reporter expanded --dart-define=FLUTTER_TEST=true

.PHONY: update-goldens
update-goldens:
	@set -euo pipefail
	flutter test --update-goldens --dart-define=FLUTTER_TEST=true

.PHONY: docker-update-goldens
docker-update-goldens:
	@set -euo pipefail

	# Build SDK Docker image
	time ./docker/build.bash --only=sdk

	# Bash array containing all volumes as arguments
	extra_volumes=()

	set +e
	config_file=$$($(MAKE) --quiet --no-print-directory get-config-file 2> /dev/null)
	set -e

	if [[ -n $$config_file ]]; then
	  extra_volumes+=("-v" "$$(realpath "$$config_file"):/root/tide/tide.yaml:ro")
	fi

	PS4=' $$ '
	set -x

	# Launch tests
	docker run \
		-it \
		--rm \
		--name=tide-update-golden \
		--hostname="tide-update-golden" \
		-v "/etc/timezone:/etc/timezone:ro" \
		-v "/etc/localtime:/etc/localtime:ro" \
		-v "$(pwd)/test/golden-images/:/root/tide/test/golden-images/" \
		"$${extra_volumes[@]}" \
		-e TZ \
		--restart=no \
		--security-opt="no-new-privileges=true" \
		--cap-drop=all \
		cynnexis/tide:sdk test --update-goldens --dart-define=FLUTTER_TEST=true

	{ set +x; } 2> /dev/null

.PHONY: test-integration
test-integration:
	@set -euo pipefail
	flutter test --coverage --reporter expanded --dart-define=FLUTTER_TEST=true integration_test/tide_test.dart

.PHONY: test-integration-web
test-integration-web:
	@set -euo pipefail

	echo "To run the integrations tests on web, you need to have the ChromeDriver. Please see https://docs.flutter.dev/cookbook/testing/integration/introduction#5b-web" 1>&2

	flutter drive \
		--driver=test_driver/integration_test.dart \
		--target=integration_test/tide_test.dart \
		--dart-define=FLUTTER_TEST=true \
		-d web-server

.PHONY: doc
doc:
	@PS4='$$ '
	set -euxo pipefail
	flutter pub global run dartdoc .
	{ set +x; } 2> /dev/null

.PHONY: rmdoc
rmdoc:
	rm -rf doc/api

.PHONY: update-launcher
update-launcher:
	flutter pub run flutter_launcher_icons:main

build/app/outputs/bundle/release/app-release.aab:
	@if [[ ! -f "android/key.properties" ]]; then
		echo "Couldn't find \"android/key.properties\". Make sure that you can generate an Android signed app bundle. Please see https://flutter.dev/docs/deployment/android" > /dev/stderr
	fi
	# Create a directory to store debug symbols after obfuscation (see https://flutter.dev/docs/deployment/obfuscate)
	mkdir -p build/debug
	flutter build appbundle --obfuscate --split-debug-info=build/debug
	echo "Use 'flutter install' to install the generated application bundle on your Android phone."

.PHONY: build-release-and
build-release-and: build/app/outputs/bundle/release/app-release.aab

.PHONY: build-docker
build-docker:
	@set -euo pipefail
	time ./docker/build.bash

.PHONY: build-docker-action
build-docker-action:
	@set -euo pipefail
	cd .github/actions/tide-configuration-file
	time docker build -t cynnexis/tide:action .
	cd ../../../

.PHONY: docker-serve
docker-serve:
	@set -euo pipefail

	# Bash array containing all volumes as arguments
	extra_volumes=()

	set +e
	config_file=$$($(MAKE) --quiet --no-print-directory get-config-file 2> /dev/null)
	set -e

	if [[ -n $$config_file ]]; then
	  extra_volumes+=("-v" "$$(realpath "$$config_file"):/usr/local/apache2/htdocs/assets/tide.yaml:ro")
	fi

	PS4=' $$ '
	set -x

	docker run -d \
		--name=tide-web \
		--hostname="tide-web" \
		--publish 80:80 \
		-v "/etc/timezone:/etc/timezone:ro" \
		-v "/etc/localtime:/etc/localtime:ro" \
		"$${extra_volumes[@]}" \
		-e TZ \
		"--restart=no" \
		--health-cmd="{ \
				{ curl -skL  http://localhost/ | grep -Ee '^\s*<title>Tide</title>\$$'; } && \
				{ curl -skIL http://localhost/ | grep -Ee '^\s*HTTP/1.1 200(\s+OK)?';   } \
			} || exit 1" \
		--health-interval=1m \
		--health-timeout=5s \
		--health-start-period=10s \
		--health-retries=3 \
		--security-opt="no-new-privileges=true" \
		--cap-drop=all \
		--cap-add=NET_BIND_SERVICE \
		"cynnexis/tide:web"

		{ set +x; } 2> /dev/null

.PHONY: fix-packages-version
fix-packages-version:
	@set -euo pipefail
	# List all type of dependencies
	dependency_types=('dependencies' 'dev_dependencies')
	for dependency_type in "$${dependency_types[@]}"; do
		# List all dependencies from the pubspec.yaml file
		dependencies=$$(yq --no-colors --no-doc eval ".\"$$dependency_type\" | keys" pubspec.y[a]ml | awk '{print $$2;}')
		while read -r dependency; do
			# Treat only dependencies that have "any" as version
			if [[ $$(yq --no-colors --no-doc eval ".\"$$dependency_type\".\"$$dependency\"" pubspec.y[a]ml 2> /dev/null) == "any" ]]; then
				# Get the version from pubspec.lock
				version=$$(yq --no-colors --no-doc eval ".packages.\"$$dependency\".version" pubspec.lock 2> /dev/null)
				# If the fetched version is valid, put it in the pubspec.yaml
				if [[ -n $$version && $$version != "null" ]]; then
					echo "$$dependency: $$version"
					sed -iEe "s@^\(\s\+\)$${dependency}:\s*any\$$@\1$${dependency}: $$version@g" pubspec.y[a]ml
				else
					echo "Warning: no version found for \"$${dependency}\" from the group \"$${dependency_type}\"" 1>&2
				fi
			fi
		done <<< "$$dependencies"
	done

.PHONY: version
version:
	@set -euo pipefail
	if command -v yq &> /dev/null; then
		VERSION=$$(yq eval -MN --unwrapScalar '.version' pubspec.yaml)
	else
		VERSION="$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}')"
	fi

	if [[ -d .git/ ]]; then
		if command -v "git" &> /dev/null; then
			if [[ "$$(git rev-parse --abbrev-ref HEAD)" != "main" ]]; then
				VERSION="$$VERSION - rev $$(git rev-parse HEAD)"
			fi
		else
			VERSION="$$VERSION - rev $$(cat ".git/$$(grep "ref:" .git/HEAD | head -1 | awk '{print $$2}')")"
		fi
	fi

	echo "tide version $$VERSION"

