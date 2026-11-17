; Wallhaven AutoBG - Inno Setup installer script
; Compile: ISCC.exe /DAppVersion=x.y.z installer.iss

#ifndef AppVersion
#define AppVersion "0.0.0"
#endif

[Setup]
AppId={{8F3A9B72-6E1D-4A8B-9C34-1B2D3E4F5A6B}
AppName=Wallhaven AutoBG
AppVersion={#AppVersion}
AppPublisher=ascerx
AppPublisherURL=https://wallhaven.cc
DefaultDirName={autopf}\Wallhaven AutoBG
DefaultGroupName=Wallhaven AutoBG
DisableProgramGroupPage=yes
OutputDir=installer
OutputBaseFilename=Wallhaven-AutoBG-Setup-{#AppVersion}
SetupIconFile=..\assets\icon.ico
UninstallDisplayIcon={app}\wallhaven_client.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=0,6.1

[Languages]
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Wallhaven AutoBG"; Filename: "{app}\wallhaven_client.exe"; Comment: "Rotación automática de fondos con wallhaven.cc"
Name: "{group}\{cm:UninstallProgram,Wallhaven AutoBG}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Wallhaven AutoBG"; Filename: "{app}\wallhaven_client.exe"; Tasks: desktopicon; Comment: "Rotación automática de fondos con wallhaven.cc"

[Tasks]
Name: "desktopicon"; Description: "Crear acceso directo en el escritorio"; GroupDescription: "Tareas adicionales:"

[Run]
Filename: "{app}\wallhaven_client.exe"; Description: "Ejecutar Wallhaven AutoBG"; Flags: postinstall nowait skipifsilent

[UninstallRun]
Filename: "reg"; Params: "delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v ""Wallhaven Client"" /f"; Flags: runhidden
