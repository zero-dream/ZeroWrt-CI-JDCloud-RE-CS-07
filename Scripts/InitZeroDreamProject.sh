#!/bin/bash
# Copyright (C) 2000 ZeroDream

# ZD_UploadReleasePath
uploadPath="$GITHUB_WORKSPACE/upload-release"
mkdir -p "$uploadPath"
echo "ZD_UploadReleasePath=$uploadPath" >>$GITHUB_ENV

# ZD_UploadArtifactPath
artifactPath="$GITHUB_WORKSPACE/upload-artifact"
mkdir -p "$artifactPath"
echo "ZD_UploadArtifactPath=$artifactPath" >>$GITHUB_ENV

# ZD_TempPath
tempPath="$GITHUB_WORKSPACE/temp"
mkdir -p "$tempPath"
echo "ZD_TempPath=$tempPath" >>$GITHUB_ENV
