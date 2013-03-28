unit uCommandLine;

interface

uses
  System.SysUtils,
  Vcl.Forms,

  Dmitry.Utils.Files,

  CMDUnit,
  GraphicCrypt,
  UnitCrypting,

  uMemoryEx,
  uAppUtils,
  uSplashThread,
  uLogger,
  uSettings,
  uRuntime,
  uDBUtils;

type
  TCommandLine = class
    class procedure ProcessServiceCommands;
    class procedure ProcessUserCommandLine;
  end;

implementation

{ TCommandLine }

class procedure TCommandLine.ProcessServiceCommands;
begin
  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/PACKTABLE') or Settings.ReadBool('StartUp', 'Pack', False) then
    begin
      CloseSplashWindow;
      EventLog('Packing...');
      Settings.WriteBool('StartUp', 'Pack', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.PackPhotoTable;
      R(CMDForm);
    end;

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/BACKUP') or Settings.ReadBool('StartUp', 'BackUp', False) then
    begin
      CloseSplashWindow;
      EventLog('BackUp...');
      Settings.WriteBool('StartUp', 'BackUp', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.BackUpTable;
      R(CMDForm);
    end;
end;

class procedure TCommandLine.ProcessUserCommandLine;
var
  S: string;
  Password: string;
  ID: Integer;
begin
  if GetParamStrDBBool('/cmd') then
  begin
    CloseSplashWindow;
    DBTerminating := True;
  end;

  if GetParamStrDBBool('/SQLExec') then
  begin
    ExecuteQuery(AnsiDequotedStr(GetParamStrDBValue('/SQLExec'), '"'));
  end;

  if GetParamStrDBBool('/SQLExecFile') then
  begin
    S := AnsiDequotedStr(GetParamStrDBValue('/SQLExecFile'), '"');
    S := ReadTextFileInString(S);
    ExecuteQuery(S);
  end;

  if GetParamStrDBBool('/e') then
  begin
    S := AnsiDequotedStr(GetParamStrDBValue('/e'), '"');
    ID := GetIdByFileName(S);
    Password := AnsiDequotedStr(GetParamStrDBValue('/p'), '"');

    EncryptImageByFileName(nil, S, ID, Password, CRYPT_OPTIONS_NORMAL, False);
  end;

  if GetParamStrDBBool('/d') then
  begin
    S := AnsiDequotedStr(GetParamStrDBValue('/d'), '"');
    ID := GetIdByFileName(S);
    Password := AnsiDequotedStr(GetParamStrDBValue('/p'), '"');

    ResetPasswordImageByFileName(nil, S, ID, Password);
  end;
end;

end.
