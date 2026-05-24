#!/usr/bin/env bash
set -euo pipefail

build_config_args() {
    CONFIG_ARGS=()
    if [[ -n "${INPUT_CONFIG:-}" ]]; then
        CONFIG_ARGS=(--config="${INPUT_CONFIG}")
    fi
}

run_analyse() {
    local report_type="$1"
    local report_file="$2"

    # shellcheck disable=SC2086
    php "${PHPCCA_BIN}" analyse ${CHANGED_FILES} \
        --report-type="${report_type}" \
        --report-file="${report_file}" \
        "${CONFIG_ARGS[@]}"
}

needs_markdown_report() {
    [[ "${INPUT_POST_COMMENT:-true}" == "true" || "${INPUT_UPLOAD_ARTIFACT:-true}" == "true" ]]
}

run_all_analyses() {
    build_config_args

    export REPORT_PATH=""
    export SARIF_PATH=""

    if needs_markdown_report; then
        echo "Generating Markdown report..."
        run_analyse markdown cca-report.md || true
        if [[ -f cca-report.md && -s cca-report.md ]]; then
            REPORT_PATH="cca-report.md"
        fi
    fi

    if [[ "${INPUT_EMIT_ANNOTATIONS:-true}" == "true" ]]; then
        echo "Generating GitHub Actions annotations..."
        run_analyse github-actions cca-annotations.txt || true
        if [[ -f cca-annotations.txt && -s cca-annotations.txt ]]; then
            cat cca-annotations.txt
        fi
    fi

    if [[ "${INPUT_UPLOAD_SARIF:-false}" == "true" ]]; then
        echo "Generating SARIF report..."
        run_analyse sarif cca-results.sarif || true
        if [[ -f cca-results.sarif && -s cca-results.sarif ]]; then
            SARIF_PATH="cca-results.sarif"
        fi
    fi

    if [[ "${INPUT_FAIL_ON_THRESHOLD:-false}" == "true" ]]; then
        echo "Generating JUnit report for threshold check..."
        run_analyse junit cca-junit.xml || true
    fi

    export REPORT_PATH
    export SARIF_PATH
}
