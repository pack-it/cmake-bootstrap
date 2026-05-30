#!/bin/sh
# Creates a release of CMake Bootstrap for Windows in the 'release' directory.
# Supports the -o flag to overwrite the files in the release directory if there are any.

RELEASE_DIR="./release"

# Parse flags
overwrite=false
while getopts "o" opt; do
  case $opt in
    o)
      overwrite=true
      ;;
    *)
      echo "Usage: $0 [-o]"
      exit 1
      ;;
  esac
done

# Create release dir or exit
if [ -d "$RELEASE_DIR" ]; then
    if [ "$overwrite" = true ]; then
        rm -r $RELEASE_DIR/*
    else
        echo "Release directory already exists, please remove it first"
        exit 1
    fi
else
    mkdir "$RELEASE_DIR"
fi

# Create bootstrap.patch file
echo \
"# SPDX-License-Identifier: BSD-3-Clause
# Distributed under the OSI-approved BSD 3-Clause License. See LICENSE file for details." \
> "$RELEASE_DIR/bootstrap.patch"

cd CMake
git diff --no-index /dev/null bootstrap.ps1 >> "../$RELEASE_DIR/bootstrap.patch"

# Create cmake.patch file
cp cmake.patch "../$RELEASE_DIR/cmake.patch"

echo "Prepared CMake Bootstrap for Windows release"
