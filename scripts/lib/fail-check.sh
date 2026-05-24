#!/usr/bin/env bash
set -euo pipefail

check_threshold_failures() {
    if [[ "${INPUT_FAIL_ON_THRESHOLD:-false}" != "true" ]]; then
        return 0
    fi

    if [[ ! -f cca-junit.xml ]]; then
        echo "Warning: fail-on-threshold is enabled but cca-junit.xml was not generated."
        return 0
    fi

    local failures
    failures=$(grep -oP 'failures="\K[0-9]+' cca-junit.xml | head -1 || echo "0")

    if [[ "${failures}" -gt 0 ]]; then
        echo "Error: ${failures} method(s) exceed the cognitive complexity threshold."
        exit 1
    fi

    echo "No methods exceed the cognitive complexity threshold."
}
