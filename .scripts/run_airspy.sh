#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

run_airspy() {
    run_script 'update_system'
    run_script 'get_airspy'
}

test_run_airspy() {
    run_script 'run_airspy'
}