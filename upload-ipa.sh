#!/usr/bin/env bash
# https://rderik.com/blog/automating-build-and-testflight-upload-for-simple-ios-apps/#automating-the-build-version-increase
set -eo pipefail
readonly basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

commit="true"
bundle_name="TEAM"
display_name="TEAM Blue"

while [[ "$#" -gt 0 ]]; do
    opt="$1"
    shift
    case "$opt" in
    --no-commit)
    commit="false";;
    --bundle-name)
    bundle_name="$1"
    shift;;
    --display-name)
    display_name="$1"
    shift;;
    *)
    echo "unknown option $opt" >&2
    exit 1;;
    esac
done

pushd "${basedir}"

cat > ./TEAMConfigOverride.xcconfig <<EOXCC
MAIN_APP_BUNDLE_IDENTIFIER = net.adamcin.${bundle_name}
MAIN_APP_DISPLAY_NAME = ${display_name}
EOXCC

bundle_name_lower="$(echo ${bundle_name} | tr '[:upper:]' [:lower:])"
app_version="$(plutil -extract CFBundleShortVersionString xml1 -o - TEAM/Info.plist | xmllint --xpath "//string/text()" -)"

current_project_version=0
if git config -f versions.gitconfig --get-regexp "${bundle_name_lower}.v${app_version}.b" >>/dev/null; then
    current_project_version="$(git config -f versions.gitconfig --get-regexp "${bundle_name_lower}.v${app_version}.b" | sed -e 's/^.*\.b//' | cut -f1 -d' ' | sort -rn | head -n 1)"
fi

new_project_version=$((current_project_version + 1))

sed -i.bak "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = ${new_project_version};/" TEAM.xcodeproj/project.pbxproj 

xcodebuild -project TEAM.xcodeproj -scheme TEAM -sdk iphoneos -configuration Release archive -archivePath "$(pwd)/build/TEAM.xcarchive" -allowProvisioningUpdates

xcodebuild -exportArchive -archivePath "$(pwd)/build/TEAM.xcarchive" -exportOptionsPlist exportOptions.plist -exportPath "$(pwd)/build" -allowProvisioningUpdates

git config -f versions.gitconfig "${bundle_name_lower}.v${app_version}.b${new_project_version}" "$(git -C ../TEAM rev-parse --short HEAD)"

git add TEAM.xcodeproj/project.pbxproj
git add versions.gitconfig

if [[ "$commit" == "true" ]]; then
    git commit -m "uploaded ${bundle_name} v${app_version} b${new_project_version}"
    git tag "${bundle_name_lower}.v${app_version}.b${new_project_version}"
    git push --tags
fi
