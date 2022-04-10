#!/bin/bash
set -euo pipefail

output_file="tide.yaml"
scheme="https"
host="cynnexis.github.io"
port="443"
path="/tide/"
maintainer_email=""

for arg in "$@"; do
  case "$arg" in
    --output-file=*|--out=*)
      output_file="${arg#*=}"
      ;;
    --scheme=*|--protocol=*)
      scheme="${arg#*=}"
      ;;
    --host=*|--hostname=*|--sni=*)
      host="${arg#*=}"
      ;;
    --port=*)
      port="${arg#*=}"
      ;;
    --path=*)
      path="${arg#*=}"
      ;;
    --maintainer-email=*|--email=*)
      maintainer_email="${arg#*=}"
      ;;
  esac
done

# Get author email address from initial commit
if [[ -z $maintainer_email ]]; then
  if [[ -d .git ]]; then
    echo -e "Cannot get the maintainer email from a project without a '.git/' folder.:\n$(pwd)\n$(ls -lha .)" 1>&2
    exit 1
  fi
  maintainer_email=$(git show -s --format='%ae' "$(git rev-list --max-parents=0 HEAD)")
fi

cat > "$output_file" <<EOF
webapp:
  uri:
    scheme: "$scheme"
    host: "$host"
    port: $port
    path: "$path"

maintainer_email: "$maintainer_email"
EOF
