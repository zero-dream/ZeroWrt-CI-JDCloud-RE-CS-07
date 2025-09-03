#!/bin/bash
# Copyright (C) 2000 ZeroDream

# Hook
# $1 scriptPath
function hook() {
  # Param
  local scriptPath=$1
  # Hook
  echo '--------------------------------------------------'
  echo "Hook: $scriptPath"
  "$GITHUB_WORKSPACE/Hook/$scriptPath.hook" || exit 0
  echo '--------------------------------------------------'
}
