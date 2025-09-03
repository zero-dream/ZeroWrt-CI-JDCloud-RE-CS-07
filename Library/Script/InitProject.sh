#!/bin/bash
# Copyright (C) 2000 ZeroDream

# --------------------------------------------------

# GITHUB_ENV
echo "ZD_DATE=$(TZ=UTC-8 date +"%y%m%d%H%M%S")" >> $GITHUB_ENV

# Check Script
find "$GITHUB_WORKSPACE/" -type f -iregex ".*\.\(sh\|hook\)$" -exec dos2unix {} \; -exec chmod +x {} \;

# --------------------------------------------------

# ZD ENV

# LibraryPath
echo "ZD_LibraryPath=$GITHUB_WORKSPACE/Library" >>$GITHUB_ENV

# UploadReleasePath
uploadPath="$RUNNER_TEMP/upload-release"
mkdir -p "$uploadPath"
echo "ZD_ReleaseUploadPath=$uploadPath" >>$GITHUB_ENV

# UploadArtifactPath
artifactPath="$RUNNER_TEMP/upload-artifact"
mkdir -p "$artifactPath"
echo "ZD_ArtifactUploadPath=$artifactPath" >>$GITHUB_ENV

# TempPath
tempPath="$RUNNER_TEMP/temp"
mkdir -p "$tempPath"
echo "ZD_TempPath=$tempPath" >>$GITHUB_ENV
