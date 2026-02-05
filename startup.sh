#!/bin/bash

parameters=()

if [ -n "$API_SECRET" ]; then
    parameters=(--apisecret "$API_SECRET")
fi

/opt/janus/bin/janus "${parameters[@]}" 2>&1
