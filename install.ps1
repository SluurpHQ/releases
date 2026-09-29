# Install Sluurp on Windows: one binary, put in ~\.sluurp\bin and added to
# your PATH.
#
#   irm https://raw.githubusercontent.com/SluurpHQ/releases/main/install.ps1 | iex
#
# $env:SLUURP_VERSION = "v0.2.0" picks a release (the latest by default);
# $env:SLUURP_INSTALL = "D:\tools\sluurp" picks where it goes.
$ErrorActionPreference = "Stop"

$repo = "SluurpHQ/releases"
$version = if ($env:SLUURP_VERSION) { $env:SLUURP_VERSION } else { "latest" }
$root = if ($env:SLUURP_INSTALL) { $env:SLUURP_INSTALL } else { Join-Path $HOME ".sluurp" }
$dir = Join-Path $root "bin"
$target = "x86_64-pc-windows-msvc"

$url = if ($version -eq "latest") {
  "https://github.com/$repo/releases/latest/download/sluurp-$target.zip"
} else {
  "https://github.com/$repo/releases/download/$version/sluurp-$target.zip"
}

Write-Host "Downloading sluurp for $target"
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("sluurp-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force $tmp | Out-Null
try {
  $zip = Join-Path $tmp "sluurp.zip"
  Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
  Expand-Archive -Path $zip -DestinationPath $tmp -Force
  New-Item -ItemType Directory -Force $dir | Out-Null
  Move-Item -Force (Join-Path $tmp "sluurp.exe") (Join-Path $dir "sluurp.exe")
} finally {
  Remove-Item -Recurse -Force $tmp
}

Write-Host "Installed $dir\sluurp.exe"
$path = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not (($path -split ";") -contains $dir)) {
  [Environment]::SetEnvironmentVariable("Path", "$dir;$path", "User")
  $env:Path = "$dir;$env:Path"
  Write-Host "Added $dir to your PATH (new terminals will have it)."
}
Write-Host ""
Write-Host "Then: sluurp serve --public .\my-app"
