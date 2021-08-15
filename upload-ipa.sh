#!/usr/bin/env bash
# https://rderik.com/blog/automating-build-and-testflight-upload-for-simple-ios-apps/#automating-the-build-version-increase
set -eo pipefail
readonly basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "${basedir}"

app_version="$(plutil -extract CFBundleShortVersionString xml1 -o - TEAM/Info.plist | xmllint --xpath "//string/text()" -)"

current_project_version=0
if git config -f versions.gitconfig --get-regexp "team.v${app_version}.b" >>/dev/null; then
    current_project_version="$(git config -f versions.gitconfig --get-regexp "team.v${app_version}.b" | cut -f2 -db | cut -f1 -d' ' | sort -rn | head -n 1)"
fi

new_project_version=$((current_project_version + 1))

sed -i.bak "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = ${new_project_version};/" TEAM.xcodeproj/project.pbxproj 

xcodebuild -project TEAM.xcodeproj -scheme TEAM -sdk iphoneos -configuration Release archive -archivePath "$(pwd)/build/TEAM.xcarchive"

xcodebuild -exportArchive -archivePath "$(pwd)/build/TEAM.xcarchive" -exportOptionsPlist exportOptions.plist -exportPath "$(pwd)/build"

git config -f versions.gitconfig "team.v${app_version}.b${new_project_version}" "$(git rev-parse --short HEAD)"

git add TEAM.xcodeproj/project.pbxproj
git add versions.gitconfig
