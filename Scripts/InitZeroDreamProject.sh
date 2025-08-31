#!/bin/bash
# Copyright (C) 2000 ZeroDream

# ZD_UploadReleasePath
uploadPath="$RUNNER_TEMP/upload-release"
mkdir -p "$uploadPath"
echo "ZD_UploadReleasePath=$uploadPath" >>$GITHUB_ENV

# ZD_UploadArtifactPath
artifactPath="$RUNNER_TEMP/upload-artifact"
mkdir -p "$artifactPath"
echo "ZD_UploadArtifactPath=$artifactPath" >>$GITHUB_ENV

# ZD_TempPath
tempPath="$RUNNER_TEMP/temp"
mkdir -p "$tempPath"
echo "ZD_TempPath=$tempPath" >>$GITHUB_ENV
