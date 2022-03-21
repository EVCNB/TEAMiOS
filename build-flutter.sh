#!/usr/bin/env bash
set -eo pipefail
readonly basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v pyenv || ! pyenv help virtualenv-init 2>&1 >>/dev/null ; then
  echo "Please install pyenv and pyenv-virtualenv" >&2
  echo "" >&2
  echo "  brew install pyenv" >&2
  echo "  brew install pyenv-virtualenv" >&2
  echo "" >&2
  exit 1
fi

projcmd() {
  eval "$(pyenv init --path "${basedir}")"
  if ! pyenv which pbxproj; then
    pyenv exec pip install pbxproj
  fi
  
  if ! pyenv exec pbxproj "$@"; then
    exit 0
  fi
}

cleanframeworks() {
  pushd "${basedir}"
  #  -e 's@/Debug/@/$(CONFIGURATION)/@g' \
  find Flutter -name '*.xcframework' | sed \
    -e 's@/Debug/@/Release/@g' \
    -e 's@/Profile/@/Release/@g' \
    -e 's@/Release/@/Release/@g' \
   | sort -u | xargs -L 1 "$0" projcmd file -D "${basedir}/TEAM.xcodeproj"
  popd
  rm -rf Flutter/*
}

buildframeworks() {
  pushd "${basedir}/../TEAM"
  #pushd "${basedir}/../teamtest"
  SWIFT_VERSION=5.0 flutter build ios-framework -v --no-cocoapods --no-obfuscate --no-pub --no-debug --no-profile --output="${basedir}/Flutter"
  popd

  # remove these for now
  find "${basedir}/Flutter" -name 'AppAuth.xcframework' -print0 | xargs -0 rm -rf
  find "${basedir}/Flutter" -name 'GTMAppAuth.xcframework'  -print0 | xargs -0 rm -rf
  find "${basedir}/Flutter" -name 'GTMSessionFetcher.xcframework'  -print0 | xargs -0 rm -rf
}

linkframeworks() {
  pushd "${basedir}"
  find Flutter -name '*.xcframework' | xargs -L 1 basename | sort -u | xargs -L 1 "$0" linkframework
  popd
}

is_embeddable() {
  local xcfmwk
  local fmwkRelPath
  local fmwk
  local fexe

  while [[ "$#" -gt 0 ]]; do
    xcfmwk="$1"
    shift
    fmwkRelPath="$(plutil -convert json -o - -r "${xcfmwk}/Info.plist" | jq -r '.AvailableLibraries[] | select(.SupportedPlatformVariant != "simulator") | .LibraryIdentifier + "/" + .LibraryPath' | head -n 1)"
    fmwk="${xcfmwk}/${fmwkRelPath}"
    fexe="${fmwk}/$(plutil -convert json -o - -r "${fmwk}/Info.plist" | jq -r '.CFBundleExecutable' | head -n 1)"
    if file -bI "$fexe" | grep -q 'application/x-archive'; then
      exit 1
    fi
  done

}

linkframework() {
  local fwname
  fwname="$1"
  pushd "${basedir}"
  if find Flutter -name "${fwname}" -print0 | xargs -0 "$0" is_embeddable; then
    # "$0" projcmd file "${basedir}/TEAM.xcodeproj" 'Flutter/$(CONFIGURATION)/'"${fwname}" --target TEAM --parent Frameworks -s
    "$0" projcmd file "${basedir}/TEAM.xcodeproj" 'Flutter/Release/'"${fwname}" --target TEAM --parent Frameworks -s
  else
    # "$0" projcmd file "${basedir}/TEAM.xcodeproj" 'Flutter/$(CONFIGURATION)/'"${fwname}" --target TEAM --parent Frameworks -E
    "$0" projcmd file "${basedir}/TEAM.xcodeproj" 'Flutter/Release/'"${fwname}" --target TEAM --parent Frameworks -E
  fi
  popd
}

if [[ "$#" -eq 0 ]]; then
  cleanframeworks
  buildframeworks
  linkframeworks
else
  "$@"
fi

