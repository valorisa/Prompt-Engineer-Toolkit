# Architecture Overview

## Security Model
- **Secrets**: Environment Variables or GitHub Secrets only.
- **Script Signing**: PowerShell scripts should be signed in production (TODO v2).

## Directory Structure
See root README.md for complete tree.

## CI/CD Flow
1. Push/PR triggers ci.yml
2. Lint → Test → Release
