#define MyAppName "K-Pomodoro"
#ifndef MyAppVersion
#define MyAppVersion "1.3.0"
#endif
#define MyAppPublisher "K-Pomodoro"
#define MyAppExeName "KPomodoro.exe"
#define SourceDir "publish"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=installer_output
OutputBaseFilename=K-Pomodoro_Setup_v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "{#SourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[Code]
// Check if .NET 8 Desktop Runtime is installed
function IsDotNet8DesktopInstalled: Boolean;
var
  Names: TArrayOfString;
  I: Integer;
  RegKey: String;
begin
  Result := False;
  RegKey := 'SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App';
  if RegGetValueNames(HKLM, RegKey, Names) then
  begin
    for I := 0 to GetArrayLength(Names) - 1 do
    begin
      if Copy(Names[I], 1, 2) = '8.' then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

function InitializeSetup: Boolean;
var
  ErrorMsg: String;
  Ret: Integer;
begin
  Result := True;

  if not IsDotNet8DesktopInstalled then
  begin
    ErrorMsg :=
      '.NET 8 Desktop Runtime was not detected.' + #13#10#13#10 +
      'This program requires .NET 8 Desktop Runtime to run.' + #13#10 +
      'Please download and install it from:' + #13#10#13#10 +
      'https://dotnet.microsoft.com/download/dotnet/8.0' + #13#10#13#10 +
      '(Choose ".NET Desktop Runtime 8.x.x" - Windows x64)' + #13#10#13#10 +
      'Would you like to open the download page now?';

    Ret := MsgBox(ErrorMsg, mbError, MB_YESNO);

    if Ret = IDYES then
      ShellExec('open', 'https://dotnet.microsoft.com/download/dotnet/8.0', '', '', SW_SHOWNORMAL, ewNoWait, Ret);

    Result := False;
  end;
end;
