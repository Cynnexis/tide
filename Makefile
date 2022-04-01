#!/usr/bin/make
ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif
PORT=8080
SHELL=/bin/bash
HOST="localhost"
.PHONY: help configure serve clean lint fix-lint build-docker docker-serve doc rmdoc update-launcher build-release-android fix-packages-version version
.ONESHELL:

all: help

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
	@echo "  doc                   - Generate the documentation."
	@echo "  rmdoc                 - Remove the documentation."
	@echo "  update-launcher       - Update the icon launcher."
	@echo "  build-release-android - Build a release version for Android. It is currently not supported in this Makefile."
	@echo "  fix-packages-version  - Replace the 'any' packages version in 'pubspec.yaml' to their actual installed version based on 'pubspec.lock'."
	@echo ''

configure:
	@flutter channel beta
	flutter upgrade
	flutter pub get
	flutter packages pub run build_runner build
	echo "\nFlutter has now the web feature enable. Please check the following tutorial to ensure it works: https://flutter.dev/docs/get-started/web"

clean:
	flutter clean
	rm -rf coverage
	rm -f .coverage

lint:
	@set -euo pipefail
	echo "Checking Dart files format..."
	dart format --output none --set-exit-if-changed .

fix-lint:
	dart format --fix .

doc:
	@PS4='$$ '
	set -euxo pipefail
	flutter pub global run dartdoc .
	{ set +x; } 2> /dev/null

rmdoc:
	rm -rf doc/api

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

build-release-and: build/app/outputs/bundle/release/app-release.aab

build-docker:
	@set -euo pipefail
	./docker/build.bash

docker-serve:
	@set -euo pipefail

	docker run -d \
		--name=tide-web \
		--hostname="tide-web" \
		--publish 80:80 \
		-v "/etc/timezone:/etc/timezone:ro" \
		-v "/etc/localtime:/etc/localtime:ro" \
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

version:
	@set -euo pipefail
	if command -v yq &> /dev/null; then
		VERSION=$$(yq eval -MN --unwrapScalar '.version' pubspec.yaml)
	else
		VERSION="$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}')"
	fi

	if [[ -d .git/ ]]; then
		if command -v "git" &> /dev/null; then
			if [[ "$$(git rev-parse --abbrev-ref HEAD)" != "master" ]]; then
				VERSION="$$VERSION - rev $$(git rev-parse HEAD)"
			fi
		else
			VERSION="$$VERSION - rev $$(cat ".git/$$(grep "ref:" .git/HEAD | head -1 | awk '{print $$2}')")"
		fi
	fi

	echo "tide version $$VERSION"

