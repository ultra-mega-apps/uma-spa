#!/usr/bin/env bash
set -euo pipefail

docker buildx bake -f compose.yaml --push
