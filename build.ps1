param(
    [string]$Tag = "v0.0.2",
    [string]$Platforms = "linux/amd64",
    [switch]$Push
)

$ErrorActionPreference = "Stop"
$image = "baiyamao/myphp82:$Tag"

if ($Push) {
    docker buildx build `
        --pull `
        --platform $Platforms `
        --build-arg "VERSION=$Tag" `
        --tag $image `
        --push `
        .
} else {
    if ($Platforms.Contains(",")) {
        throw "Multi-platform builds must use -Push because they cannot be loaded into the local Docker image store."
    }

    docker build `
        --pull `
        --platform $Platforms `
        --build-arg "VERSION=$Tag" `
        --tag $image `
        .
}
