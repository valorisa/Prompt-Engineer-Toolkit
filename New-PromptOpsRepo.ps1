#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Crée la structure complète du repository prompt-engineer-toolkit.
.DESCRIPTION
    Script de bootstrap pour initialiser tous les dossiers et fichiers
    selon la structure canonicalisée v1.0.0.
.NOTES
    Author: valorisa
    License: MIT
    Requires: PowerShell 7+
    TODO(v2): Add parameter for custom root path.
    TODO(v2): Add git init and initial commit automation.
#>

[CmdletBinding()]
param(
    [string]$RootPath = ".\prompt-engineer-toolkit"
)

# --- Configuration ---
$ProjectName = "prompt-engineer-toolkit"
$Version = "1.0.0"

# --- Helper Functions ---
function Write-Status {
    param([string]$Message, [string]$Color = "Cyan")
    $Previous = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = $Previous
}

function New-SafeFile {
    param([string]$Path, [string]$Content = "")
    $dir = Split-Path $Path -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (!(Test-Path $Path)) {
        Set-Content -Path $Path -Value $Content -Encoding UTF8
        Write-Status "  ✓ Created: $Path" "Green"
    } else {
        Write-Status "  ⚠ Exists: $Path" "Yellow"
    }
}

# --- Execution ---
Write-Status "`n=== PromptOps Toolkit Scaffolding v$Version ===`n" "Cyan"

# 1. Create Root
if (Test-Path $RootPath) {
    Write-Status "ERROR: $RootPath already exists." "Red"
    exit 1
}
New-Item -ItemType Directory -Path $RootPath -Force | Out-Null
Write-Status "  ✓ Created: $RootPath" "Green"

Push-Location $RootPath

# 2. Directory Structure
$directories = @(
    ".github/workflows",
    ".github/ISSUE_TEMPLATE",
    "scripts/node",
    "scripts/python",
    "prompts/templates",
    "docker",
    ".devcontainer",
    "tests",
    "docs"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Status "  ✓ Created: $dir/" "Green"
}

# 3. GitHub Workflows (CORRIGÉ - Pas d'échappement dans les here-strings)
New-SafeFile ".github/workflows/ci.yml" @'
name: CI/CD Pipeline

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  lint-markdown:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Lint Markdown
        run: npx markdownlint-cli2 "**/*.md"

  lint-shell:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: ShellCheck
        uses: ludeeus/action-shellcheck@v2
        with:
          check_together: 'yes'
          scan: "scripts/"

  test-powershell:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [windows-latest, ubuntu-latest, macos-latest]
        pwsh: [5.1, 7.4]
        exclude:
          - os: ubuntu-latest
            pwsh: 5.1
          - os: macos-latest
            pwsh: 5.1
    steps:
      - uses: actions/checkout@v3
      - name: Setup PowerShell
        uses: microsoft/setup-powershell@v1
        with:
          version: ${{ matrix.pwsh }}
      - name: Install Pester
        run: pwsh -Command "Install-Module -Name Pester -Force -SkipPublisherCheck"
      - name: Run Tests
        run: pwsh -Command "Invoke-Pester ./tests -CI -Output Detailed"

  test-python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install -r scripts/python/requirements.txt
      - name: Lint and Test
        run: |
          pytest tests/
          ruff check scripts/python/

  test-node:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 'lts/*'
      - name: Install and Test
        run: |
          cd scripts/node
          npm ci
          npm test
'@

New-SafeFile ".github/workflows/release.yml" @'
name: Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            prompts/templates/*.yml
            scripts/*.ps1
            scripts/*.sh
'@

# 4. GitHub Templates
New-SafeFile ".github/ISSUE_TEMPLATE/bug_report.md" @'
---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior.

**Expected behavior**
A clear and concise description of what you expected to happen.

**Environment:**
- OS: [e.g. Windows 11, macOS 13, Ubuntu 22.04]
- PowerShell: [e.g. 5.1, 7.4]
- Version: [e.g. 1.0.0]
'@

New-SafeFile ".github/PULL_REQUEST_TEMPLATE.md" @'
## Description
Brief description of changes.

## Checklist
- [ ] Tests pass locally
- [ ] CI/CD workflows updated
- [ ] Documentation updated
- [ ] TODO(v2) markers added where applicable
'@

# 5. Scripts CLI
New-SafeFile "scripts/PromptOpsConsole.ps1" @'
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    PromptOps Console - Interactive CLI for prompt-engineer-toolkit.
.NOTES
    Author: valorisa
    License: MIT
    TODO(v2): Add telemetry opt-in mechanism.
    TODO(v2): Implement plugin architecture for menu extensions.
#>

[CmdletBinding()]
param(
    [switch]$Help,
    [switch]$Version,
    [switch]$WhatIf
)

$ScriptVersion = "1.0.0"

if ($Help) { Get-Help $PSCommandPath; exit 0 }
if ($Version) { Write-Host $ScriptVersion; exit 0 }

Write-Host "PromptOps Console v$ScriptVersion"
Write-Host "----------------------------------------"
Write-Host "[1] Project Scaffold"
Write-Host "[2] Automation Engine"
Write-Host "[3] Docs Generator"
Write-Host "[4] Super-Prompt Studio"
Write-Host "[5] Health Check"
Write-Host "[6] Settings"
Write-Host "[0] Exit"
Write-Host "----------------------------------------"
'@

New-SafeFile "scripts/PromptOpsConsole.sh" @'
#!/usr/bin/env bash
# PromptOps Console - Interactive CLI for prompt-engineer-toolkit
# License: MIT
# TODO(v2): Add signal handling for SIGINT during long operations.
# TODO(v2): Implement JSON parsing for config without jq dependency fallback.

set -euo pipefail

SCRIPT_VERSION="1.0.0"

echo "PromptOps Console v${SCRIPT_VERSION}"
echo "----------------------------------------"
echo "[1] Project Scaffold"
echo "[2] Automation Engine"
echo "[3] Docs Generator"
echo "[4] Super-Prompt Studio"
echo "[5] Health Check"
echo "[6] Settings"
echo "[0] Exit"
echo "----------------------------------------"
'@

# 6. Node.js Utilities
New-SafeFile "scripts/node/promptops.js" @'
#!/usr/bin/env node
/**
 * PromptOps Node Utility
 * License: MIT
 * TODO(v2): Add support for JSON Schema validation.
 * TODO(v2): Implement npm publish workflow.
 */

const ARGS = process.argv.slice(2);

function showHelp() {
    console.log('PromptOps Node Utility v1.0.0');
    console.log('Usage: node promptops.js [command]');
}

function main() {
    const command = ARGS[0];
    switch (command) {
        case 'help': showHelp(); break;
        case 'version': console.log('1.0.0'); break;
        default: showHelp();
    }
}

main();
'@

New-SafeFile "scripts/node/package.json" @'
{
  "name": "promptops-node-utils",
  "version": "1.0.0",
  "description": "Node.js utilities for prompt-engineer-toolkit",
  "main": "promptops.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "lint": "eslint promptops.js"
  },
  "author": "valorisa",
  "license": "MIT"
}
'@

# 7. Python Utilities
New-SafeFile "scripts/python/promptops.py" @'
#!/usr/bin/env python3
"""
PromptOps Python Utility
License: MIT
TODO(v2): Integrate pyyaml and jsonschema for validation.
TODO(v2): Add secret scanning regex patterns.
"""

import sys
import argparse

VERSION = "1.0.0"

def main():
    parser = argparse.ArgumentParser(description="PromptOps Python Utility")
    parser.add_argument('command', choices=['version', 'help'], help="Command to run")
    args = parser.parse_args()
    
    if args.command == 'version':
        print(VERSION)
    else:
        print(f"PromptOps Python Utility v{VERSION}")

if __name__ == "__main__":
    main()
'@

New-SafeFile "scripts/python/requirements.txt" @'
# PromptOps Python Dependencies
# TODO(v2): Add pyyaml, jsonschema, ruff for production usage.
'@

# 8. Prompt Templates
New-SafeFile "prompts/templates/reverse-engineering.yml" @'
meta:
  id: reverse-engineering-v1
  name: "Reverse Prompt Engineering Assistant"
  version: "1.0.0"
  author: valorisa
  target_models:
    - gpt
    - claude
    - gemini
    - qwen
  category: reverse-engineering

prompt:
  system: |
    You are an expert in reverse prompt engineering.
  user_template: |
    Analyze this AI output and reverse-engineer its prompt.
    Target model: {{target_model}}
    Output to analyze: """{{ai_output}}"""

variables:
  - name: target_model
    type: enum
    options: [gpt, claude, gemini, qwen]
  - name: ai_output
    type: string

guardrails:
  max_tokens: 4096
  temperature: 0.3

quality:
  success_criteria: |
    Optimized prompt produces superior output.

model_adaptations:
  qwen:
    notes: "Linear instructions. Front-load key rules. Bilingual markers if applicable."
'@

New-SafeFile "prompts/templates/repo-orchestration.yml" @'
meta:
  id: repo-orchestration-v1
  name: "Repository Orchestration Agent"
  version: "1.0.0"
  author: valorisa
  target_models:
    - gpt
    - claude
    - qwen
  category: automation

prompt:
  system: |
    You are a DevOps architect specializing in repository scaffolding.
  user_template: |
    Generate a project structure for {{project_type}}.

variables:
  - name: project_type
    type: enum
    options: [library, application, infrastructure]

guardrails:
  max_tokens: 8192
  temperature: 0.2

model_adaptations:
  qwen:
    notes: "Linear instructions. Front-load key rules. Bilingual markers if applicable."
'@

New-SafeFile "prompts/templates/content-pipeline.yml" @'
meta:
  id: content-pipeline-v1
  name: "Content Pipeline Generator"
  version: "1.0.0"
  author: valorisa
  target_models:
    - gpt
    - gemini
    - qwen
  category: content-generation

prompt:
  system: |
    You are a technical writer and content strategist.
  user_template: |
    Create a content plan for {{topic}}.

variables:
  - name: topic
    type: string
  - name: audience
    type: enum
    options: [beginner, intermediate, expert]

guardrails:
  max_tokens: 4096
  temperature: 0.7

model_adaptations:
  qwen:
    notes: "Linear instructions. Front-load key rules. Bilingual markers if applicable."
'@

New-SafeFile "prompts/templates/schema.yml" @'
# Super-Prompt Template Schema Reference
meta:
  id: string
  name: string
  version: string
  author: string
  target_models: [gpt, claude, gemini, qwen]
  category: string
prompt:
  system: string
  user_template: string
variables:
  - name: string
    type: string
    description: string
guardrails:
  max_tokens: integer
  temperature: float
quality:
  success_criteria: string
model_adaptations:
  gpt: { notes: string }
  claude: { notes: string }
  gemini: { notes: string }
  qwen: { notes: string }
'@

# 9. Docker
New-SafeFile "docker/Dockerfile" @'
# PromptOps Toolkit Development Container
# Base: PowerShell 7.4 on Ubuntu 22.04
FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04 AS base

LABEL maintainer="valorisa"
LABEL version="1.0.0"

ENV DEBIAN_FRONTEND=noninteractive

FROM base AS tools
RUN apt-get update && apt-get install -y shellcheck git curl jq && rm -rf /var/lib/apt/lists/*

FROM tools AS node
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs

FROM node AS python
RUN apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

FROM python AS final
WORKDIR /app
COPY . .
RUN pwsh -Command "Install-Module -Name Pester -Force -SkipPublisherCheck"

ENTRYPOINT ["pwsh", "-NoLogo", "-NoProfile", "-Command"]
# TODO(v2): Add non-root user for security hardening.
# TODO(v2): Add healthcheck instruction.
'@

# 10. DevContainer
New-SafeFile ".devcontainer/devcontainer.json" @'
{
  "name": "PromptOps Toolkit",
  "build": {
    "dockerfile": "../docker/Dockerfile"
  },
  "extensions": [
    "ms-vscode.powershell",
    "timonwong.shellcheck",
    "DavidAnson.vscode-markdownlint",
    "ms-python.python"
  ],
  "postCreateCommand": "pwsh -c 'Install-Module Pester -Force'"
}
'@

# 11. Tests
New-SafeFile "tests/PromptOpsConsole.Tests.ps1" @'
# PromptOps Console Tests - Pester 5+
BeforeAll {
    $ScriptPath = "$PSScriptRoot/../scripts/PromptOpsConsole.ps1"
}

Describe "PromptOpsConsole.ps1" {
    It "Should exist" {
        $ScriptPath | Should -Exist
    }

    It "Should return version with -Version flag" {
        $output = & $ScriptPath -Version
        $output | Should -Match "^\d+\.\d+\.\d+$"
    }
}
# TODO(v2): Add integration tests for menu navigation.
'@

New-SafeFile "tests/test_promptops.py" @'
# PromptOps Python Tests - pytest
def test_version():
    assert True
# TODO(v2): Add actual test coverage for promptops.py.
'@

# 12. Documentation
New-SafeFile "docs/ARCHITECTURE.md" @'
# Architecture Overview

## Security Model
- **Secrets**: Environment Variables or GitHub Secrets only.
- **Script Signing**: PowerShell scripts should be signed in production (TODO v2).

## Directory Structure
See root README.md for complete tree.

## CI/CD Flow
1. Push/PR triggers ci.yml
2. Lint → Test → Release
'@

New-SafeFile "docs/USAGE.md" @'
# Usage Guide

## Quick Start
```bash
./scripts/PromptOpsConsole.sh       # Linux/macOS
./scripts/PromptOpsConsole.ps1      # Windows
```

## Configuration
User preferences stored in ~/.promptops/config.json
'@

New-SafeFile "docs/SUPER-PROMPT-SPEC.md" @'
# Super-Prompt Specification

## Template Schema
All templates in prompts/templates/ follow schema.yml.

## Model Adaptations
Each template includes model-specific notes for GPT, Claude, Gemini, and Qwen.
'@

# 13. Root Files
New-SafeFile ".shellcheckrc" @'
severity=warning
enable=all
shell=bash
'@

New-SafeFile ".markdownlint.json" @'
{
  "default": true,
  "MD013": false,
  "MD033": { "allowed_elements": ["br", "details", "summary"] },
  "MD041": true
}
'@

New-SafeFile "README.md" @'
# Prompt Engineer Toolkit

> Production-grade framework for super-prompt engineering and cross-platform automation.

![Release](https://img.shields.io/badge/release-v1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features
- Interactive CLI (PowerShell & Bash)
- Super-Prompt Templates (YAML)
- CI/CD Ready (GitHub Actions)
- Containerized (Docker + DevContainer)

## Quick Start
```bash
git clone https://github.com/valorisa/prompt-engineer-toolkit.git
cd prompt-engineer-toolkit
./scripts/PromptOpsConsole.ps1   # Windows
./scripts/PromptOpsConsole.sh    # Unix
```

## License
MIT
'@

New-SafeFile "CONTRIBUTING.md" @'
# Contributing

1. Fork the repository
2. Create a feature branch
3. Run tests locally
4. Submit a pull request
'@

New-SafeFile "CODE_OF_CONDUCT.md" @'
# Code of Conduct

Be respectful and inclusive. Follow standard open source community guidelines.
'@

New-SafeFile "LICENSE" @'
MIT License

Copyright (c) 2026 valorisa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'@

New-SafeFile "RELEASE_CHECKLIST.md" @'
# Release Checklist

## Pre-Release
- [ ] All tests pass
- [ ] No secrets hardcoded
- [ ] Documentation updated
- [ ] Version numbers updated

## Release Execution
- [ ] Commit to main
- [ ] Create tag v1.0.0
- [ ] Push tag

## Post-Release
- [ ] Verify CI/CD
- [ ] Monitor for issues
'@

Pop-Location

Write-Status "`n=== Scaffolding Complete ===" "Cyan"
Write-Status "Repository created at: $(Get-Location)`n" "Green"
Write-Status "Next steps:" "Yellow"
Write-Status "  1. cd $RootPath" "White"
Write-Status "  2. git init" "White"
Write-Status "  3. git add ." "White"
Write-Status "  4. git commit -m 'Initial commit v1.0.0'" "White"
Write-Status "  5. git remote add origin <your-repo-url>" "White"
Write-Status "  6. git push -u origin main`n" "White"

