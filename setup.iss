[Setup]
AppName=Autorinks                      ; Nazwa aplikacji
AppVersion=1.0                         ; Wersja
DefaultDirName={pf}\Autorinks         ; Domyślny folder instalacji
DefaultGroupName=Autorinks            ; Nazwa grupy w menu Start
OutputDir=build\installer             ; Gdzie zapisać instalator
OutputBaseFilename=autorinks_installer; Nazwa pliku instalatora                  ; Nowoczesny wygląd instalatora
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
AppPublisher=Michał Filutkowski
AppCopyright=© 2025 Michał Filutkowski

[Files]
Source: "build\build\main\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Autorinks"; Filename: "{app}\main.exe"
Name: "{group}\Uninstall Autorinks"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\main.exe"; Description: "Uruchom Autorinks"; Flags: nowait postinstall skipifsilent