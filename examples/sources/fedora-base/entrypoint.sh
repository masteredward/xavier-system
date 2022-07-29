#!/bin/bash
set -e

export PATH=$HOME/bin:$PATH
env > ${HOME}/.ssh/environment

exec "$@"