#!/bin/bash

# Check for essential env var
if [[ "$FSLDIR" == "" || "$UKB_SUBJECTS" == "" ]] ; then
    echo "ERROR: Key env vars, FSLDIR, UKB_SUBJECTS not all set"
    exit 1
fi

InJob="$1"

cat "$InJob" | while read CMD ; do
    OutImg="$(echo "$CMD" | awk '{print $7}')"
    if [[ "$(imtest $OutImg)" == 0 ]] ; then
	echo "$CMD"
    fi
done
