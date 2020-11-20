#!/bin/bash

set -e

export R=$( (curl -fs es01:9200) > /dev/null && echo ok )

echo es01 $0 $R

if [[ "$R" == "ok" ]]; then
    exit 0
else
    exit 1
fi