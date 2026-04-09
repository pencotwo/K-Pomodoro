[Setup]
AppName=K-Pomodoro
AppVersion=1.2.0
AppPublisher=hartman-hsieh
AppPublisherURL=https://sourceforge.net/projects/k-pomodoro/
DefaultDirName={autopf}\K-Pomodoro
DefaultGroupName=K-Pomodoro
OutputDir=D:\Source\Win\PomodoroApp2\installer
OutputBaseFilename=K-Pomodoro_Setup_v1.2.0
Compression=lzma
SolidCompression=yes
UninstallDisplayIcon={app}\KPomodoro.exe
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible

[Files]
Source: "D:\Source\Win\PomodoroApp2\bin\Release\net8.0-windows\publish\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\K-Pomodoro"; Filename: "{app}\KPomodoro.exe"
Name: "{autodesktop}\K-Pomodoro"; Filename: "{app}\KPomodoro.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\KPomodoro.exe"; Description: "Launch K-Pomodoro"; Flags: nowait postinstall skipifsilent
