# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a multi-module Gradle project that builds and packages a Ballerina-based API server. The build system uses a custom Gradle plugin to orchestrate Ballerina compilation, template-based configuration management, and automated distribution packaging.

**Key Technologies:**
- Ballerina 2201.13.1 (programming language for the API service)
- Gradle 8.12 (build orchestration)
- Java 21 (required runtime)

## Build Commands

```bash
# Build everything (verifies Ballerina version, compiles code, creates distributions)
./gradlew build

# Clean all build outputs
./gradlew clean

# Build without tests
./gradlew build -x test

# Just build Ballerina code
./gradlew :apiserver-workspace:balBuild

# Create distribution ZIP
./gradlew :distribution:apiServerDistZip

# Publish to GitHub Packages (requires publishUser/publishPAT env vars)
./gradlew publish

# Release workflow (creates tags, updates versions)
./gradlew release
```

**Prerequisites:**
- Ballerina version MUST match `gradle.properties` (currently 2201.13.1)
- Build fails if local Ballerina version doesn't match
- Java 21 required
- Git properly configured (for automated commit tasks)

## Architecture

### Module Structure

**`:apiserver-workspace` (components/)**
- Contains Ballerina source code and workspace configuration
- Main code: `components/api-server/service.bal`
- Compiles to executable JAR in `target/bin/`

**`:distribution` (distribution/)**
- Packages deployable artifacts as ZIP distributions
- Includes JAR, startup scripts, configs, and documentation
- Publishes to GitHub Packages as `io.ayeshlk:api-server-distribution`

**`buildSrc`**
- Custom Gradle plugin: `WebsubhubBallerinaComponentPlugin`
- Handles Ballerina build orchestration and version management

### Build Workflow

The custom plugin orchestrates this build sequence:

1. **`updateTomlFiles`**: Reads templates from `build-config/resources/`, replaces `@toml.version@` and `@ballerina.version@` placeholders, copies updated TOML files to component directories

2. **`balBuild`**: Executes `bal build` command (cross-platform)

3. **`commitTomlFiles`**: Auto-commits updated Ballerina.toml and Dependencies.toml to git

Task dependency chain: `build → verifyLocalBalVersion → updateTomlFiles → balBuild → commitTomlFiles`

### Configuration Management

**Template-Based System:**
- Templates stored in: `build-config/resources/api-server/`
- Templates contain placeholders: `@toml.version@`, `@ballerina.version@`
- Build process replaces placeholders and copies to: `components/api-server/`
- **IMPORTANT**: Always edit templates in `build-config/resources/`, NOT the files in `components/`

**Version Management:**
- Project version: `gradle.properties` (currently 0.3.1-SNAPSHOT)
- Ballerina version: `gradle.properties` (currently 2201.13.1)
- Release plugin manages version bumping and git tagging

### API Service

The main service is a simple HTTP greeting API:
- File: `components/api-server/service.bal`
- Configurable port from `Config.toml` (default: 9090)
- Endpoint: `GET /greeting?name=<string>`
- Returns: `"Hello, <name>"` or error if name is empty

**Testing the Service:**
```bash
# Extract and run distribution
unzip distribution/build/distributions/api-server-*.zip
cd api-server-*/
./bin/apiserver.sh start

# Test endpoint
curl "http://localhost:9090/greeting?name=Test"

# Stop service
./bin/apiserver.sh stop
```

## CI/CD Workflows

**Release Workflow** (`.github/workflows/release.yml`):
- Manual trigger via workflow_dispatch
- Stages: Build → Trivy Security Scan → Release → Docker Build → GitHub Release → Sync PR
- Publishes to GitHub Packages and Docker Hub

**Docker Build Workflow** (`.github/workflows/docker-build.yml`):
- Builds multi-arch images
- Tags: `latest` and `<version>`
- Registry: Docker Hub (`ayeshalmeida/apiserver`)

**Trivy Scan Workflow** (`.github/workflows/trivy-scan.yml`):
- Daily vulnerability scanning of compiled JAR
- Fails build on vulnerabilities found

## Modifying the Codebase

**To change the API service:**
1. Edit `components/api-server/service.bal`
2. Build: `./gradlew :apiserver-workspace:balBuild`
3. Test manually using the startup script

**To update versions:**
1. Update `gradle.properties` (version and ballerinaDistributionVersion)
2. Update template: `build-config/resources/api-server/Ballerina.toml`
3. Run `./gradlew build` (automatically updates component TOML files)

**To add new Ballerina components:**
1. Create directory in `components/`
2. Add `Ballerina.toml` with package metadata
3. Update `components/Ballerina.toml` workspace packages list
4. Create corresponding template in `build-config/resources/<component-name>/`
5. Add distribution configuration in `distribution/build.gradle`

## Docker Deployment

**Container Image:**
- Base: Debian stable-slim
- Non-root user: wso2:10001
- JAR-based deployment (no Ballerina runtime in container)
- Config passed via `BAL_CONFIG_FILES` environment variable

**Docker file location:** `docker/components/api-server/Dockerfile`

## Testing

This project currently has no formal test suite. Security testing is performed via:
- Trivy vulnerability scanning (daily and on release)
- Manual integration testing using startup scripts

To add Ballerina tests: Create test files in `components/api-server/tests/` with test annotations.

## Publishing

**GitHub Packages:**
- Repository: `ayeshLK/gradle-bal-project`
- Artifact: `io.ayeshlk:api-server-distribution`
- Credentials: Environment variables `publishUser` and `publishPAT`

**Docker Hub:**
- Image: `ayeshalmeida/apiserver`
- Credentials: GitHub secrets `DOCKER_USERNAME` and `DOCKER_PASSWORD`
