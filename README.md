# myphp82

[![Build and publish Docker image](https://github.com/baiyamao/myphp82/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/baiyamao/myphp82/actions/workflows/docker-publish.yml)
[![Docker Image Version](https://img.shields.io/docker/v/baiyamao/myphp82?sort=semver)](https://hub.docker.com/r/baiyamao/myphp82)
[![Docker Pulls](https://img.shields.io/docker/pulls/baiyamao/myphp82)](https://hub.docker.com/r/baiyamao/myphp82)

基于 PHP 8.2.35 FPM 的多架构 Docker 镜像，保留原
`baiyamao/myphp82:v0.0.1` 中常用的 PHP 扩展和构建工具，并通过 GitHub
Actions 自动构建、合并并发布 `linux/amd64` 与 `linux/arm64` 镜像到 Docker
Hub。

## 镜像信息

| 项目 | 内容 |
| --- | --- |
| 镜像地址 | `baiyamao/myphp82` |
| 基础镜像 | `php:8.2.35-fpm-alpine3.23` |
| PHP 版本 | `8.2.35` |
| 支持架构 | `linux/amd64`、`linux/arm64` |
| 默认端口 | `9000`（PHP-FPM） |
| 工作目录 | `/app` |

### 内置 PHP 扩展

- `pdo_mysql`
- `exif`
- `pcntl`
- `bcmath`
- `gd`
- `opcache`

### 内置工具

- Composer 2
- Git、curl、zip、unzip
- Node.js、npm
- Python 3、pip
- Alpine 常用编译工具链

## 安全说明

- 本镜像使用包含安全修复的 PHP `8.2.35`。
- PHP 8.2 将于 **2026-12-31** 结束官方安全支持。在此之前应规划升级到仍受支持的
  PHP 主版本，并重新执行本项目的构建流程。
- 工作流在构建时启用了 `pull: true`，会重新拉取基础镜像和依赖，建议定期重新运行
  工作流以获取 Alpine 系统和基础镜像的安全更新。
- 不要在仓库、Issue、日志或命令历史中提交 Docker Hub 密码或个人访问令牌。

## 快速使用

拉取正式版本：

```powershell
docker pull baiyamao/myphp82:v0.0.2
```

Docker 会根据当前主机自动选择 `linux/amd64` 或 `linux/arm64`，无需手动指定。

启动 PHP-FPM：

```powershell
docker run --rm -p 9000:9000 baiyamao/myphp82:v0.0.2
```

检查 PHP 版本和扩展：

```powershell
docker run --rm --network none --entrypoint php `
  baiyamao/myphp82:v0.0.2 -v

docker run --rm --network none --entrypoint php `
  baiyamao/myphp82:v0.0.2 -m
```

强制测试 ARM64 镜像：

```powershell
docker run --rm --network none --platform linux/arm64 `
  --entrypoint php baiyamao/myphp82:v0.0.2 -v
```

## 仓库结构

```text
.
|-- .github/workflows/docker-publish.yml  # GitHub Actions 多架构发布流程
|-- .dockerignore                         # Docker 构建上下文排除规则
|-- Dockerfile                            # PHP 8.2 FPM 镜像定义
|-- build.ps1                             # 本地构建和推送脚本
`-- README.md
```

## 本地构建

环境要求：

- Docker Desktop 或 Docker Engine
- Docker Buildx
- PowerShell 7（Windows）

只构建当前平台的 `linux/amd64` 镜像：

```powershell
.\build.ps1
```

默认镜像标签为 `baiyamao/myphp82:v0.0.2`。

构建其他版本：

```powershell
.\build.ps1 -Tag v0.0.3
```

构建并推送单架构镜像：

```powershell
docker login
.\build.ps1 -Tag v0.0.2 -Push
```

构建并推送多架构镜像：

```powershell
docker login
.\build.ps1 -Tag v0.0.2 `
  -Platforms "linux/amd64,linux/arm64" `
  -Push
```

多架构构建必须使用 `-Push`，因为 Docker 本地镜像库不能同时加载一个多架构
manifest。

## GitHub Actions 自动发布

工作流文件：

```text
.github/workflows/docker-publish.yml
```

发布流程如下：

1. `linux/amd64` 在 GitHub 原生的 AMD64 runner 上构建。
2. `linux/arm64` 在 GitHub 原生的 ARM64 runner 上构建。
3. 两个任务分别按 digest 推送到 Docker Hub。
4. 合并任务生成一个同时包含 `linux/amd64` 和 `linux/arm64` 的 OCI
   manifest。
5. 最终任务从 Docker Hub 读取 manifest，验证发布结果。

使用原生 runner 可以避免 QEMU 跨架构编译，显著缩短 ARM64 构建时间。
工作流使用 Node.js 24 运行时的新版官方 action，避免 Node.js 20 弃用警告。

### 触发方式

工作流会在以下情况自动运行：

| 触发操作 | 生成的 Docker 标签 |
| --- | --- |
| 推送到 `main` | `latest` |
| 推送 `v*.*.*` Git 标签 | 对应版本标签，例如 `v0.0.2` |
| 在 GitHub Actions 页面手动运行 | `main` 发布 `latest`，标签发布对应版本 |

`latest` 只在默认分支 `main` 上更新。正式发布时应创建 `v*.*.*` 标签。
工作流不会再生成 `main` 或 `sha-<commit>` 等临时标签。

### 配置 GitHub Actions Secrets

进入仓库：

```text
Settings -> Secrets and variables -> Actions -> Repository secrets
```

添加以下两个 Secret：

| Secret 名称 | 值 |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub 用户名，例如 `baiyamao` |
| `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token |

`DOCKERHUB_TOKEN` 必须是 **Repository permissions: Repo Read & Write**。
不要使用 Docker Hub 登录密码，也不需要授予删除仓库的权限。

### 创建 Docker Hub Personal Access Token

1. 登录 Docker Hub。
2. 打开
   [Personal access tokens](https://app.docker.com/accounts/baiyamao/settings/personal-access-tokens)。
3. 点击 **Generate new token**。
4. 将描述填写为 `GitHub Actions - myphp82`。
5. 选择有效期，建议使用 90 天。
6. 将 Repository permissions 设置为 **Repo Read & Write**。
7. 点击 **Generate**，并立即复制令牌。
8. 在 GitHub 仓库中创建 `DOCKERHUB_TOKEN` Secret 并粘贴令牌。

令牌通常只显示一次，关闭页面后无法再次查看。

### 自动发布 main 分支

```powershell
git add .
git commit -m "feat: update PHP image"
git push origin main
```

该操作只会更新 Docker Hub 上的 `latest` 标签。

### 发布正式版本

例如发布 `v0.0.2`：

```powershell
git tag -a v0.0.2 -m "PHP 8.2.35 multi-architecture release"
git push origin v0.0.2
```

推送标签后，GitHub Actions 会自动构建并发布包含以下架构的
`baiyamao/myphp82:v0.0.2`：

- `linux/amd64`
- `linux/arm64`

### 手动运行工作流

1. 打开仓库的 **Actions** 页面。
2. 选择 **Build and publish Docker image**。
3. 点击 **Run workflow**。
4. 选择 `main` 或某个 `v*.*.*` 标签。
5. 点击 **Run workflow** 开始构建。

如果选择正式标签，Docker Hub 会发布对应版本；如果选择 `main`，会更新
`latest`。

## 验证发布结果

检查 Docker Hub 上的多架构 manifest：

```powershell
docker buildx imagetools inspect baiyamao/myphp82:v0.0.2
```

输出中应同时出现：

```text
Platform: linux/amd64
Platform: linux/arm64
```

拉取并验证实际镜像：

```powershell
docker pull baiyamao/myphp82:v0.0.2
docker run --rm --network none --entrypoint php `
  baiyamao/myphp82:v0.0.2 -v
docker run --rm --network none --entrypoint php-fpm `
  baiyamao/myphp82:v0.0.2 -t
```

## Docker Hub 令牌过期注意事项

当前配置建议每 90 天轮换一次 Docker Hub PAT。如果令牌在 2026-10-26
创建，预计会在 **2027-01-24 前后**到期，请以 Docker Hub 页面显示的具体日期为准。

令牌过期或失效时，GitHub Actions 通常会在登录或推送阶段失败，并出现以下类型的错误：

```text
unauthorized: incorrect username or password
denied: requested access to the resource is denied
```

处理步骤：

1. 在 Docker Hub 创建新的 **Repo Read & Write** PAT。
2. 进入 GitHub 仓库的 Actions Secrets 页面。
3. 更新 `DOCKERHUB_TOKEN`，保存新令牌。
4. 重新运行失败的 GitHub Actions workflow。
5. 确认镜像推送成功后，在 Docker Hub 删除旧令牌。

建议在到期前 7 天设置日历提醒。不要等到发布时才更新令牌，也不要把 PAT 写入
`Dockerfile`、README、构建参数或仓库文件。

## 常见问题

### Docker Hub 登录失败

检查：

- `DOCKERHUB_USERNAME` 是否为 Docker Hub 用户名，而不是邮箱地址。
- `DOCKERHUB_TOKEN` 是否已过期或被撤销。
- PAT 是否具有 **Repo Read & Write** 权限。
- Secret 名称是否与 workflow 中的引用完全一致。

### ARM64 任务没有运行

确认 workflow 中的 ARM64 runner 仍为：

```yaml
runner: ubuntu-24.04-arm
```

公共仓库可免费使用 GitHub 托管的 ARM64 runner。

### 多架构 manifest 只有一个平台

确认两个架构构建任务都成功，并且 `merge` 任务完成。任一构建任务失败时，不会发布
最终的合并 manifest。

### 如何更新 PHP 安全版本

修改 `Dockerfile` 第一行中的完整 PHP 补丁版本，例如：

```dockerfile
FROM php:8.2.35-fpm-alpine3.23
```

提交并推送新版本标签，GitHub Actions 会重新构建两个架构并发布到 Docker Hub。
