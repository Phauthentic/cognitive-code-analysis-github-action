#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/install.sh
source "${SCRIPT_DIR}/lib/install.sh"
# shellcheck source=lib/changed-files.sh
source "${SCRIPT_DIR}/lib/changed-files.sh"
# shellcheck source=lib/analyse.sh
source "${SCRIPT_DIR}/lib/analyse.sh"
# shellcheck source=lib/fail-check.sh
source "${SCRIPT_DIR}/lib/fail-check.sh"

set_outputs() {
    local has_report="false"

    if [[ -n "${REPORT_PATH:-}" || -n "${SARIF_PATH:-}" ]]; then
        has_report="true"
    fi

    echo "has-report=${has_report}" >> "${GITHUB_OUTPUT}"
    echo "changed-files-count=${CHANGED_FILES_COUNT}" >> "${GITHUB_OUTPUT}"
    echo "report-path=${REPORT_PATH:-}" >> "${GITHUB_OUTPUT}"
    echo "sarif-path=${SARIF_PATH:-}" >> "${GITHUB_OUTPUT}"
}

main() {
    resolve_phpcca_bin
    resolve_changed_files

    if [[ -z "${CHANGED_FILES// }" ]]; then
        echo "Skipping analysis: no PHP files to analyse."
        REPORT_PATH=""
        SARIF_PATH=""
        set_outputs
        exit 0
    fi

    echo "Analysing ${CHANGED_FILES_COUNT} file(s): ${CHANGED_FILES}"
    run_all_analyses
    check_threshold_failures
    set_outputs
}

main "$@"
