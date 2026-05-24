# Cognitive Code Analysis GitHub Action

Composite GitHub Action that runs [Cognitive Code Analysis](https://github.com/Phauthentic/cognitive-code-analysis) (`phpcca`) in pull-request workflows. Install via PHAR or Composer, analyse changed PHP files, and optionally publish Markdown PR comments, workflow annotations, artifacts, and SARIF uploads.

**Repository:** [Phauthentic/cognitive-code-analysis-github-action](https://github.com/Phauthentic/cognitive-code-analysis-github-action)

This repository is separate from the main `cognitive-code-analysis` package ([issue #29](https://github.com/Phauthentic/cognitive-code-analysis/issues/29)).

## Quick start

Add this workflow to your repository (`.github/workflows/cognitive-code-analysis.yml`):

```yaml
name: Cognitive Code Analysis

on:
  pull_request:
    paths:
      - '**/*.php'

permissions:
  pull-requests: write
  contents: read

jobs:
  analyse:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: Phauthentic/cognitive-code-analysis-github-action@v1
        with:
          install-mode: phar
          post-comment: true
          upload-artifact: true
          emit-annotations: true
```

When `cca.yaml` exists in your project root, `phpcca` loads it automatically. See the [main CI integration guide](https://github.com/Phauthentic/cognitive-code-analysis/blob/main/docs/CI-Integration.md) for manual workflow snippets.

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `install-mode` | `phar` | `phar` or `composer` |
| `phar-version` | `1.11.0` | Release tag to download from `Phauthentic/cognitive-code-analysis` |
| `phar-url` | _(empty)_ | Override PHAR download URL (for forks/testing) |
| `composer-command` | `vendor/bin/phpcca` | Path to phpcca when `install-mode=composer` |
| `config` | _(empty)_ | Config file path; empty = auto `cca.yaml` in CWD |
| `php-version` | `8.4` | PHP version via `shivammathur/setup-php` |
| `analyze-changed-files-only` | `true` | Diff PR base...head for `.php` files; if false, use `paths` |
| `paths` | `src` | Space-separated paths when not using changed-files mode |
| `post-comment` | `true` | Post Markdown report as PR comment via `actions/github-script` |
| `upload-artifact` | `true` | Upload report files as artifact |
| `artifact-name` | `cca-report` | Artifact name |
| `emit-annotations` | `true` | Run `--report-type=github-actions` and print to stdout |
| `upload-sarif` | `false` | Generate SARIF and upload via `github/codeql-action/upload-sarif` |
| `fail-on-threshold` | `false` | Fail job if methods exceed threshold (JUnit report) |
| `token` | `${{ github.token }}` | Token for PR comments / SARIF upload |

## Outputs

| Output | Description |
|--------|-------------|
| `has-report` | `true` when a Markdown or SARIF report was generated |
| `changed-files-count` | Number of PHP files analysed |
| `report-path` | Path to the Markdown report file, if generated |
| `sarif-path` | Path to the SARIF report file, if generated |

## Permissions

Grant only the permissions you need:

```yaml
permissions:
  contents: read                    # always required
  pull-requests: write              # post-comment: true
  security-events: write            # upload-sarif: true
```

## Install modes

### PHAR (default)

Downloads `phpcca.phar` from [GitHub Releases](https://github.com/Phauthentic/cognitive-code-analysis/releases). No Composer install step required in your workflow.

```yaml
- uses: Phauthentic/cognitive-code-analysis-github-action@v1
  with:
    install-mode: phar
    phar-version: '1.11.0'
```

### Composer

Install dependencies first, then point the action at your binary:

```yaml
- uses: shivammathur/setup-php@v2
  with:
    php-version: '8.4'
    tools: composer

- run: composer install --prefer-dist --no-ansi --no-interaction --no-progress

- uses: Phauthentic/cognitive-code-analysis-github-action@v1
  with:
    install-mode: composer
    composer-command: vendor/bin/phpcca
```

## Feature toggles

Each report type requires a separate `phpcca` invocation (one `--report-type` per run). The action runs only the passes you enable:

| Toggle | Report type | Behaviour |
|--------|-------------|-----------|
| `post-comment` or `upload-artifact` | `markdown` | Writes `cca-report.md` |
| `emit-annotations` | `github-actions` | Prints `::warning` / `::error` lines to the log |
| `upload-sarif` | `sarif` | Writes `cca-results.sarif` and uploads to Code Scanning |
| `fail-on-threshold` | `junit` | Writes `cca-junit.xml`; fails when `failures > 0` |

`fail-on-threshold` is **off by default**. Enable it when you want the job to fail on threshold violations.

## Examples

See [`examples/minimal.yml`](examples/minimal.yml) for a PHAR workflow with PR comments, and [`examples/full-featured.yml`](examples/full-featured.yml) for all toggles documented.

### Local / path reference

Pin a stable release (recommended):

```yaml
- uses: Phauthentic/cognitive-code-analysis-github-action@v1
```

Test the action from the default branch before a release:

```yaml
- uses: Phauthentic/cognitive-code-analysis-github-action@master
```

Or reference a checkout of this repo:

```yaml
- uses: ./path/to/cognitive-code-analysis-github-action
  with:
    analyze-changed-files-only: 'false'
    paths: src/
    post-comment: false
```

## Development

```bash
shellcheck scripts/**/*.sh
```

The [`ci.yml`](.github/workflows/ci.yml) workflow runs Shellcheck and a dogfood job against [`fixtures/`](fixtures/).

## License

GPL-3.0-only — see [LICENSE](LICENSE).
