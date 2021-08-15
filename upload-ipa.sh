#!/usr/bin/env bash
# https://rderik.com/blog/automating-build-and-testflight-upload-for-simple-ios-apps/#automating-the-build-version-increase
git config -f versions.gitconfig "team.v${app_version}.b${new_project_version}" "$(git rev-parse --short HEAD)"
git config -f versions.gitconfig --get-regexp team.v1.0.b | cut -f2 -db | cut -f1 -d' ' | sort -rn | head -n 1
