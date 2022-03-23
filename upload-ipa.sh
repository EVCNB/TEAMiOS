#!/usr/bin/env bash
# https://rderik.com/blog/automating-build-and-testflight-upload-for-simple-ios-apps/#automating-the-build-version-increase
set -eo pipefail
readonly basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(pwd)" != "${basedir}" ]]; then
    pushd "${basedir}"
fi

if ! type -p firebase >/dev/null; then
    echo "please install firebase cli" >&2
    exit 1
fi

appname() {
    if [[ "$#" -gt 1 ]]; then
        echo "app token cannot have spaces" >&2
        exit 1
    fi

    if [[ "$1" == "" ]]; then
        echo "please provide a valid app token" >&2
        exit 1
    fi

    echo "$1" | tr '[:upper:]' '[:lower:]'
}

app=team
# handle global arguments
while [[ "$#" -gt 0 ]]; do
    opt="$1"
    shift
    case "$opt" in
    -a|--app)
    app="$(appname $1)"
    shift;;
    *)
    set -- "$opt" "$@"
    break;;
    esac
done

nextbuildversion() {
    local app_version
    local build_version

    app_version="$(git config -f apps.gitconfig apps.${app}.appversion)"
    build_version=0
    if git config -f versions.gitconfig --get-regexp "${app}.v${app_version}.b" >>/dev/null; then
        build_version="$(git config -f versions.gitconfig --get-regexp "${app}.v${app_version}.b" | sed -e 's/^.*\.b//' | cut -f1 -d' ' | sort -rn | head -n 1)"
    fi
    echo "$((build_version + 1))"
}

setfirebaseinfo() {
    local sdkconfig

    if [[ -f TEAM/GoogleService-Info.plist ]]; then
        rm TEAM/GoogleService-Info.plist
    fi
    sdkconfig="$(git config -f apps.gitconfig apps.${app}.sdkconfig)"
    if [[ "$sdkconfig" != "" ]]; then
        firebase apps:sdkconfig -o TEAM/GoogleService-Info.plist IOS "$sdkconfig"
    else
        plutil -create xml1 TEAM/GoogleService-Info.plist
    fi
}

setxcconfig() {
    local bundle_id
    local app_version
    local display_name
    local build_version
    local clientid_rev

    bundle_id="$(git config -f apps.gitconfig apps.${app}.bundleid)"
    display_name="$(git config -f apps.gitconfig apps.${app}.displayname)"
    app_version="$(git config -f apps.gitconfig apps.${app}.appversion)"

    cat > ./TEAMConfigOverride.xcconfig <<EOXCC
MAIN_APP_BUNDLE_IDENTIFIER = ${bundle_id}
MAIN_APP_DISPLAY_NAME = ${display_name}
EOXCC

    plutil -replace CFBundleShortVersionString -string "${app_version}" TEAM/Info.plist

    build_version="$(nextbuildversion "$app")"
    sed -i.bak "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = ${build_version};/" TEAM.xcodeproj/project.pbxproj 

    clientid_rev="$(plutil -extract 'REVERSED_CLIENT_ID' raw -o - TEAM/GoogleService-Info.plist)"
    if [[ "${clientid_rev}" != "" ]] && ! plutil -extract 'CFBundleURLTypes.0.CFBundleURLSchemes' json -o - TEAM/Info.plist | jq -r '.[]' | fgrep -q "${clientid_rev}" >/dev/null; then
        plutil -insert 'CFBundleURLTypes.0.CFBundleURLSchemes' -string "${clientid_rev}" -append TEAM/Info.plist
    fi
}

runxcodebuild() {
    local bundle_id
    local app_version
    local build_version
    local commit

    commit=true

    while [[ "$#" -gt 0 ]]; do
        opt="$1"
        shift
        case "$opt" in
        --no-commit)
        commit=false;;
        *)
        set -- "$opt" "$@"
        break;;
        esac
    done

    bundle_id="$(git config -f apps.gitconfig apps.${app}.bundleid)"
    app_version="$(git config -f apps.gitconfig apps.${app}.appversion)"

    xcodebuild -workspace TEAM.xcworkspace -scheme TEAM -sdk iphoneos -configuration Release archive -archivePath "${basedir}/build/TEAM.xcarchive" -allowProvisioningUpdates
    xcodebuild -exportArchive -archivePath "${basedir}/build/TEAM.xcarchive" -exportOptionsPlist exportOptions.plist -exportPath "${basedir}/build" -allowProvisioningUpdates

    build_version="$(nextbuildversion "$app")"
    git config -f versions.gitconfig "${app}.v${app_version}.b${build_version}" "$(git -C ../TEAM rev-parse --short HEAD)"

    git add TEAM.xcodeproj/project.pbxproj
    git add versions.gitconfig

    if [[ "$commit" == "true" ]]; then
        git commit -m "uploaded ${bundle_id} v${app_version} b${build_version}"
        git tag "${app}.v${app_version}.b${build_version}"
        git push --tags
    fi
}

if [[ "$#" -eq 0 ]]; then
  setfirebaseinfo
  setxcconfig
  runxcodebuild
else
  "$@"
fi


