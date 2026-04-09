# Windows Signing and Microsoft Certification

This repository can now produce two Windows distribution formats:

- `MSIX` for Microsoft Store submission
- `EXE` installer for direct distribution

These are not certified in the same way:

- Microsoft Store: certification happens in Partner Center after you upload a valid `MSIX` package.
- Direct download installer: you must sign the installer yourself with an Authenticode code signing certificate.

## 1. Microsoft Store path

Use this path if you want Microsoft to validate and distribute the app.

Requirements:

- A Microsoft Partner Center developer account
- A reserved app identity in Partner Center
- The exact `Identity Name` and `Publisher` values from that reservation

Build command:

```powershell
.\build-msix.ps1 `
  -IdentityName "YourPartnerCenterIdentity" `
  -Publisher "CN=YOUR-PARTNER-CENTER-PUBLISHER-ID" `
  -PublisherDisplayName "Your Publisher Name" `
  -Version "1.1.0.0"
```

Upload the generated `.msix` file from `dist\`.

Important:

- For Store submissions, the package identity must exactly match Partner Center.
- Microsoft performs package validation during ingestion.
- Microsoft handles Store trust/distribution; you do not need to self-sign the Store package for final customer installs.

## 2. Sideload-signed MSIX

Use this if you want to install the `MSIX` outside the Microsoft Store.

Requirements:

- A `.pfx` code signing certificate trusted by the target machine
- Windows SDK `signtool.exe`

Build and sign:

```powershell
.\build-msix.ps1 `
  -IdentityName "YourIdentity" `
  -Publisher "CN=YOUR-PUBLISHER" `
  -PublisherDisplayName "Your Publisher Name" `
  -Version "1.1.0.0" `
  -CertificatePath "C:\path\to\codesign.pfx" `
  -CertificatePassword "your-password"
```

## 3. Sign the EXE installer

If you distribute `installer_output\K-Pomodoro_Setup.exe` yourself, sign it with a code signing certificate.

Set environment variables, then run the existing build script:

```powershell
$env:SIGN_CERT_FILE = "C:\path\to\codesign.pfx"
$env:SIGN_CERT_PASSWORD = "your-password"
$env:SIGN_TIMESTAMP_URL = "http://timestamp.digicert.com"
.\build_installer.bat
```

Optional:

- Set `SIGNTOOL_PATH` if `signtool.exe` is not in the default Windows SDK location.

## 4. What "Microsoft certified" actually means

If your goal is to have Windows users see Microsoft-backed trust, the correct route is:

1. Package as `MSIX`
2. Reserve the app in Partner Center
3. Submit the package for Store certification
4. Pass automated and policy review
5. Publish through Microsoft Store

If your goal is only to remove SmartScreen warnings for a downloaded installer, that is different:

- Sign the installer with a reputable OV or EV code signing certificate
- EV certificates build reputation faster with SmartScreen
- Microsoft Store certification is not the same thing as Authenticode signing
