<#
.SYNOPSIS
    Builds a Microsoft Store-ready MSIX package for K-Pomodoro.

.DESCRIPTION
    Steps:
      1. dotnet publish (self-contained, win-x64, Release)
      2. Generate app icons via System.Drawing
      3. Write AppxManifest.xml
      4. makeappx.exe pack  ->  dist\KPomodoro_x.x.x.x_x64.msix

.PARAMETER IdentityName
    Package/Identity/Name from Partner Center (e.g. "Contoso.KPomodoro")

.PARAMETER Publisher
    Package/Identity/Publisher from Partner Center (e.g. "CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")

.PARAMETER PublisherDisplayName
    Your display name shown in the Store listing.

.EXAMPLE
    # Normal Store build - fill in your Partner Center values:
    .\build-msix.ps1 -IdentityName "Contoso.KPomodoro" -Publisher "CN=XXXXXXXX-..." -PublisherDisplayName "Contoso"

#>
param(
    [string]$IdentityName         = 'HartmanHsieh.3681915CEAB1F',
    [string]$Publisher            = 'CN=C6E91ED1-CB2E-42CD-AB49-D183F21CA12D',
    [string]$PublisherDisplayName = 'Hartman Hsieh',
    [string]$Version              = '1.2.0.0'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Constants ─────────────────────────────────────────────────────────────────
$AppName     = 'K-Pomodoro'
$Description = 'A minimalist Pomodoro timer with configurable cycles (2–8), work log, and next-session hints.'
$Executable  = 'KPomodoro.exe'
$MakeAppx    = 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\makeappx.exe'
$Root        = $PSScriptRoot
$PublishDir  = Join-Path $Root 'dist\publish'
$LayoutDir   = Join-Path $Root 'dist\layout'
$AssetsDir   = Join-Path $LayoutDir 'Assets'
$OutputDir   = Join-Path $Root 'dist'
$OutputMsix  = Join-Path $OutputDir "KPomodoro_${Version}_x64.msix"

# ── Validate ──────────────────────────────────────────────────────────────────

if (-not (Test-Path $MakeAppx)) {
    Write-Error "makeappx.exe not found at: $MakeAppx"
}

# ── STEP 1: Clean & prepare dirs ─────────────────────────────────────────────
Write-Host '[1/4] Preparing output directories...' -ForegroundColor Cyan
if (Test-Path $OutputDir) { Remove-Item $OutputDir -Recurse -Force }
New-Item -ItemType Directory -Path $AssetsDir -Force | Out-Null

# ── STEP 2: dotnet publish ────────────────────────────────────────────────────
Write-Host '[2/4] Publishing app (self-contained, win-x64, Release)...' -ForegroundColor Cyan
$csproj = Join-Path $Root 'PomodoroApp2.csproj'
& dotnet publish $csproj -c Release -r win-x64 --self-contained true -o $PublishDir
if ($LASTEXITCODE -ne 0) { Write-Error 'dotnet publish failed.' }

# Copy published output into layout root (excluding .pdb for Store)
Get-ChildItem $PublishDir -Exclude '*.pdb' | Copy-Item -Destination $LayoutDir -Recurse -Force

# ── STEP 3: Generate icons ────────────────────────────────────────────────────
Write-Host '[3/4] Generating icons...' -ForegroundColor Cyan
Add-Type -AssemblyName System.Drawing

function New-KIcon {
    param(
        [string] $Path,
        [int]    $W,
        [int]    $H,
        [switch] $Wide
    )

    $bmp = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $bgColor     = [System.Drawing.Color]::FromArgb(255, 28, 28, 46)   # #1C1C2E
    $accentColor = [System.Drawing.Color]::FromArgb(255, 232, 93, 80)  # #E85D50

    $bgBrush     = New-Object System.Drawing.SolidBrush($bgColor)
    $accentBrush = New-Object System.Drawing.SolidBrush($accentColor)
    $whiteBrush  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $fmt         = New-Object System.Drawing.StringFormat
    $fmt.Alignment     = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center

    $g.FillRectangle($bgBrush, 0, 0, $W, $H)

    if ($Wide) {
        $pad        = [int]($H * 0.12)
        $circleSize = $H - 2 * $pad
        $circleX    = $pad

        $g.FillEllipse($accentBrush, $circleX, $pad, $circleSize, $circleSize)

        $kFont = New-Object System.Drawing.Font('Segoe UI', ([int]($circleSize * 0.58)),
                    [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $g.DrawString('K', $kFont,
            $whiteBrush,
            [System.Drawing.RectangleF]::new($circleX, $pad, $circleSize, $circleSize), $fmt)
        $kFont.Dispose()

        $textX    = $circleX + $circleSize + [int]($H * 0.10)
        $nameFont = New-Object System.Drawing.Font('Segoe UI', ([int]($H * 0.20)),
                        [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $g.DrawString('K-Pomodoro', $nameFont,
            $whiteBrush,
            [System.Drawing.RectangleF]::new($textX, 0, ($W - $textX - $pad), $H), $fmt)
        $nameFont.Dispose()
    }
    else {
        $pad        = [int]([Math]::Min($W, $H) * 0.12)
        $circleSize = [Math]::Min($W, $H) - 2 * $pad
        $circleX    = [int](($W - $circleSize) / 2)
        $circleY    = [int](($H - $circleSize) / 2)

        $g.FillEllipse($accentBrush, $circleX, $circleY, $circleSize, $circleSize)

        $kFont = New-Object System.Drawing.Font('Segoe UI', ([int]($circleSize * 0.58)),
                    [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $g.DrawString('K', $kFont,
            $whiteBrush,
            [System.Drawing.RectangleF]::new($circleX, $circleY, $circleSize, $circleSize), $fmt)
        $kFont.Dispose()
    }

    $g.Dispose()
    $bgBrush.Dispose()
    $accentBrush.Dispose()
    $whiteBrush.Dispose()
    $fmt.Dispose()

    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "  $([System.IO.Path]::GetFileName($Path))  (${W}x${H})"
}

New-KIcon "$AssetsDir\Square44x44Logo.png"             44  44
New-KIcon "$AssetsDir\Square44x44Logo.scale-200.png"   88  88
New-KIcon "$AssetsDir\Square150x150Logo.png"          150 150
New-KIcon "$AssetsDir\Square150x150Logo.scale-200.png" 300 300
New-KIcon "$AssetsDir\Wide310x150Logo.png"            310 150 -Wide
New-KIcon "$AssetsDir\Wide310x150Logo.scale-200.png"  620 300 -Wide
New-KIcon "$AssetsDir\Square310x310Logo.png"          310 310
New-KIcon "$AssetsDir\StoreLogo.png"                   50  50
New-KIcon "$AssetsDir\StoreLogo.scale-200.png"        100 100

# ── STEP 4: AppxManifest.xml ──────────────────────────────────────────────────
$manifestPath = Join-Path $LayoutDir 'AppxManifest.xml'
$manifestContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities"
  IgnorableNamespaces="rescap">

  <Identity
    Name="$IdentityName"
    Publisher="$Publisher"
    Version="$Version"
    ProcessorArchitecture="x64" />

  <Properties>
    <DisplayName>$AppName</DisplayName>
    <PublisherDisplayName>$PublisherDisplayName</PublisherDisplayName>
    <Logo>Assets\StoreLogo.png</Logo>
    <Description>$Description</Description>
  </Properties>

  <Dependencies>
    <TargetDeviceFamily Name="Windows.Desktop"
      MinVersion="10.0.17763.0"
      MaxVersionTested="10.0.26100.0" />
  </Dependencies>

  <Resources>
    <Resource Language="en-US" />
  </Resources>

  <Applications>
    <Application Id="App"
      Executable="$Executable"
      EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements
        DisplayName="$AppName"
        Description="$Description"
        BackgroundColor="#1C1C2E"
        Square150x150Logo="Assets\Square150x150Logo.png"
        Square44x44Logo="Assets\Square44x44Logo.png">
        <uap:DefaultTile
          Wide310x150Logo="Assets\Wide310x150Logo.png"
          Square310x310Logo="Assets\Square310x310Logo.png"
          ShortName="K-Pomodoro">
          <uap:ShowNameOnTiles>
            <uap:ShowOn Tile="wide310x150Logo" />
          </uap:ShowNameOnTiles>
        </uap:DefaultTile>
      </uap:VisualElements>
    </Application>
  </Applications>

  <Capabilities>
    <rescap:Capability Name="runFullTrust" />
  </Capabilities>

</Package>
"@
[System.IO.File]::WriteAllText($manifestPath, $manifestContent, (New-Object System.Text.UTF8Encoding($false)))

# ── STEP 5: makeappx pack ─────────────────────────────────────────────────────
Write-Host '[4/4] Packaging with makeappx...' -ForegroundColor Cyan
if (Test-Path $OutputMsix) { Remove-Item $OutputMsix -Force }
& $MakeAppx pack /d $LayoutDir /p $OutputMsix /nv
if ($LASTEXITCODE -ne 0) { Write-Error 'makeappx.exe failed.' }

$sizeMB = [Math]::Round((Get-Item $OutputMsix).Length / 1MB, 2)
Write-Host ''
Write-Host "Done!  $(Resolve-Path $OutputMsix)  ($sizeMB MB)" -ForegroundColor Green
Write-Host ''
Write-Host 'Next steps for Microsoft Store:' -ForegroundColor Yellow
Write-Host '  1. https://partner.microsoft.com/dashboard  ->  New app submission'
Write-Host '  2. Upload the .msix file above'
Write-Host '  3. Microsoft signs the package during ingestion'
Write-Host ''
