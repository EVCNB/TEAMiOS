#!/usr/bin/env bash
set -eo pipefail
readonly basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "${basedir}/../TEAM"
SWIFT_VERSION=5.0 flutter build ios-framework -v --no-cocoapods --no-pub --output="${basedir}/Flutter"
