[Setup]
AppName=WindowMenu
AppVersion=1.0
AppCopyright=Copyright © 2016 DNX Solutions Ltd
DefaultDirName={pf}\DNXSolutions\MyHotKeys
OutputDir=.
OutputBaseFilename=MyHotKeys_Setup
AppendDefaultDirName=False
DisableProgramGroupPage=yes

[Files]
Source: "..\MyHotKeys.exe"; DestDir: "{app}"

[Icons]
Name: "{userstartup}\MyHotKeys"; Filename: "{app}\MyHotKeys.exe"; Flags: excludefromshowinnewinstall; Tasks: startup

[Tasks]
Name: startup; Description: "Automatically start on login"; GroupDescription: "{cm:AdditionalIcons}"
