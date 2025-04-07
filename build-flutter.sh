#!/usr/bin/env bash
set -eo pipefail
readonly basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v pyenv >/dev/null || ! pyenv help virtualenv-init 2>&1 >>/dev/null ; then
  echo "Please install pyenv and pyenv-virtualenv" >&2
  echo "" >&2
  echo "  brew install pyenv" >&2
  echo "  brew install pyenv-virtualenv" >&2
  echo "" >&2
  exit 1
fi

projcmd() {
  eval "$(pyenv init --path "${basedir}")"
  if ! pyenv which pbxproj >/dev/null; then
    pyenv exec pip install pbxproj
  fi
  
  if ! pyenv exec pbxproj file "${basedir}/TEAM.xcodeproj" "$@" 2>&1 >/dev/null; then
    exit 0
  fi
}

# projcmd() {
#   if ! xcodeproj show --no-ansi | sed -e 's/^\([^- ].*\)$/\1:/' | yq "$@" 2>&1 >/dev/null; then
#     exit 0
#   fi
# }

unlinkframeworks() {
  local config
  config="$1"
  if [ "$config" == "" ]; then
    config='$(CONFIGURATION)'
  fi
  cd "${basedir}" && find Flutter -name '*.xcframework' | sed \
    -e 's@/Debug/@/'"${config}"'/@g' \
    -e 's@/Profile/@/'"${config}"'/@g' \
    -e 's@/Release/@/'"${config}"'/@g' \
   | sort -u | xargs -L 1 "$0" projcmd -D --parent Frameworks
}

cleanframeworks() {
  cd "${basedir}" && mkdir -p Flutter
  #  -e 's@/Debug/@/$(CONFIGURATION)/@g' \
  unlinkframeworks
  unlinkframeworks Debug
  unlinkframeworks Profile
  unlinkframeworks Release

  cd "${basedir}" && rm -rf "${basedir}"/Flutter/*
}

buildframeworks() {
  #pushd "${basedir}/../teamtest"
  cd "${basedir}/../TEAM" && SWIFT_VERSION=5.0 flutter build ios-framework -v --no-cocoapods --no-obfuscate --no-pub --no-debug --no-profile --output="${basedir}/Flutter"

  # remove these for now
  #find "${basedir}/Flutter" -name 'AppAuth.xcframework' -print0 | xargs -0 rm -rf
  #find "${basedir}/Flutter" -name 'GTMAppAuth.xcframework'  -print0 | xargs -0 rm -rf
  #find "${basedir}/Flutter" -name 'GTMSessionFetcher.xcframework'  -print0 | xargs -0 rm -rf
}

linkframeworks() {
  cd "${basedir}" && find Flutter -name '*.xcframework' | xargs -L 1 basename | sort -u | xargs -L 1 "$0" linkframework
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
      return 1
    fi
  done

}

linkframework() {
  local fwname
  fwname="$1"
  cd "${basedir}"
  
  if find Flutter -name "${fwname}" -print0 | xargs -0 "$0" is_embeddable; then
    echo "linking -s ${fwname}"
    # "$0" projcmd file "${basedir}/TEAM.xcodeproj" 'Flutter/$(CONFIGURATION)/'"${fwname}" --target TEAM --parent Frameworks -s
    "$0" projcmd 'Flutter/Release/'"${fwname}" --target TEAM --parent Frameworks -s || echo "failed to link -s ${fwname}"
  else
    echo "linking -E ${fwname}"
    # "$0" projcmd file "${basedir}/TEAM.xcodeproj" 'Flutter/$(CONFIGURATION)/'"${fwname}" --target TEAM --parent Frameworks -E
    "$0" projcmd 'Flutter/Release/'"${fwname}" --target TEAM --parent Frameworks -E || echo "failed to link -E ${fwname}"
  fi
}

if [[ "$#" -eq 0 ]]; then
  "$0" cleanframeworks
  "$0" buildframeworks
  "$0" linkframeworks
else
  "$@"
fi

