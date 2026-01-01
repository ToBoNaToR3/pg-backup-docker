#!/bin/bash

# Colors for output
RED='\033[0;31m'
# shellcheck disable=SC2034
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
WHITE='\033[0;97m'
NC='\033[0m'

log() {
  echo -e "${MAGENTA}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ${WHITE}$1${NC}"
}

error() {
  echo -e "${MAGENTA}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ${RED}✗${NC} ${WHITE}$1${NC}" >&2
}

warn() {
  echo -e "${MAGENTA}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ${YELLOW}$1${NC}"
}