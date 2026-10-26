# myphp82

PHP 8.2 FPM Docker image with the extensions and build tools used by the
original `baiyamao/myphp82:v0.0.1` image.

## Image contents

- PHP 8.2.35 FPM on Alpine 3.23
- Composer 2
- PHP extensions: `pdo_mysql`, `exif`, `pcntl`, `bcmath`, `gd`, `opcache`
- Git, Node.js, npm, Python 3, and common build tools
- FPM listening on port 9000

## Build

```powershell
.\build.ps1
```

The default image tag is `baiyamao/myphp82:v0.0.2`.

## Build and push

```powershell
docker login
.\build.ps1 -Push
```

To build and push both architectures locally:

```powershell
docker login
.\build.ps1 -Tag v0.0.2 -Platforms "linux/amd64,linux/arm64" -Push
```

To create another version, pass a tag explicitly:

```powershell
.\build.ps1 -Tag v0.0.3 -Push
```

## GitHub Actions

The workflow in `.github/workflows/docker-publish.yml` builds native images on
GitHub-hosted AMD64 and ARM64 runners, then combines them into a single
multi-architecture manifest for:

- `linux/amd64`
- `linux/arm64`

It runs on pushes to `main`, `v*.*.*` tags, and manual dispatches. Each
architecture is built on a matching native runner, then the workflow publishes
one combined manifest to Docker Hub. The default branch also updates `latest`.

Add these repository secrets under **Settings > Secrets and variables >
Actions**:

- `DOCKERHUB_USERNAME`: Docker Hub username, normally `baiyamao`
- `DOCKERHUB_TOKEN`: Docker Hub personal access token with Read & Write access

After creating a release tag, the workflow publishes the matching tag (for
example `v0.0.2`) as a manifest containing both architectures.

Pull the matching architecture automatically:

```powershell
docker pull baiyamao/myphp82:v0.0.2
```

Force a specific architecture when needed:

```powershell
docker pull --platform linux/arm64 baiyamao/myphp82:v0.0.2
```
