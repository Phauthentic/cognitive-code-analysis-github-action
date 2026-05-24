#!/usr/bin/env bash
set -euo pipefail

install_phar() {
    local phar_version="${INPUT_PHAR_VERSION:-1.11.0}"
    local phar_url="${INPUT_PHAR_URL:-}"
    local install_dir="${RUNNER_TEMP:-/tmp}/phpcca"
    local phar_path="${install_dir}/phpcca.phar"

    mkdir -p "${install_dir}"

    if [[ -z "${phar_url}" ]]; then
        phar_url="https://github.com/Phauthentic/cognitive-code-analysis/releases/download/${phar_version}/phpcca.phar"
    fi

    echo "Downloading phpcca.phar from ${phar_url}..."
    curl -fsSL "${phar_url}" -o "${phar_path}"
    chmod +x "${phar_path}"

    export PHPCCA_BIN="${phar_path}"
}

install_composer() {
    local composer_command="${INPUT_COMPOSER_COMMAND:-vendor/bin/phpcca}"

    if [[ ! -x "${composer_command}" && ! -f "${composer_command}" ]]; then
        echo "Error: phpcca not found at '${composer_command}'." >&2
        echo "Run 'composer install' before this action when install-mode=composer." >&2
        exit 1
    fi

    export PHPCCA_BIN="${composer_command}"
}

resolve_phpcca_bin() {
    local install_mode="${INPUT_INSTALL_MODE:-phar}"

    case "${install_mode}" in
        phar)
            install_phar
            ;;
        composer)
            install_composer
            ;;
        *)
            echo "Error: install-mode must be 'phar' or 'composer', got '${install_mode}'." >&2
            exit 1
            ;;
    esac

    echo "Using phpcca: ${PHPCCA_BIN}"
}
