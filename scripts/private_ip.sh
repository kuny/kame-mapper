#!/usr/bin/env bash

IP=$(ip -4 a show en0 | grep -oE '(\s?inet\s)\d{1,3}(\.\d{1,3}){3}' | grep -oE '\d{1,3}(\.\d{1,3}){3}')

echo "IP: $IP"
