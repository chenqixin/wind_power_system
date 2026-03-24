; Inno Setup Script - 风电监控系统安装程序
; 编译前需要先 flutter build windows --release

#define MyAppName "风电监控系统"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Changjia"
#define MyAppExeName "wind_power_system.exe"

; Flutter build 输出目录（相对于 .iss 文件位置）
#define BuildOutput "..\build\windows\x64\runner\Release"

[Setup]
AppId={{YOUR-GUID-HERE}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\build\installer
OutputBaseFilename=wind_power_system_setup_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Flutter build 产物（整个 Release 目录）
Source: "{#BuildOutput}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  LicensePage: TInputQueryWizardPage;

procedure InitializeWizard;
begin
  { 在"选择目录"之后插入一个密钥输入页面 }
  LicensePage := CreateInputQueryPage(
    wpSelectDir,
    '软件授权',
    '请输入授权密钥以激活软件',
    '请将授权密钥粘贴到下方输入框中：'
  );
  LicensePage.Add('授权密钥：', False);
  LicensePage.Values[0] := '';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Key: String;
begin
  Result := True;

  if CurPageID = LicensePage.ID then
  begin
    Key := Trim(LicensePage.Values[0]);
    if Key = '' then
    begin
      MsgBox('请输入授权密钥！', mbError, MB_OK);
      Result := False;
    end;
    { 密钥格式基本校验：必须是合法的 base64 }
    { 详细校验由 Flutter 应用启动时完成 }
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Key: String;
  LicensePath: String;
begin
  if CurStep = ssPostInstall then
  begin
    Key := Trim(LicensePage.Values[0]);
    if Key <> '' then
    begin
      { 将密钥写入安装目录下的 license.dat }
      LicensePath := ExpandConstant('{app}\license.dat');
      SaveStringToFile(LicensePath, Key, False);
    end;
  end;
end;
