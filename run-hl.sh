#!/bin/bash

# Set up environment for HashLink
export DYLD_LIBRARY_PATH=".:$DYLD_LIBRARY_PATH"
export DYLD_FALLBACK_LIBRARY_PATH=".:$DYLD_FALLBACK_LIBRARY_PATH"

# Run HashLink
./hl "$@"