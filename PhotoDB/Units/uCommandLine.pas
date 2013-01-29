unit uCommandLine;

interface

uses
  System.SysUtils,
  Vcl.Forms,

  Dmitry.Utils.Files,

  UnitConvertDBForm,
  CMDUnit,
  GraphicCrypt,
  UnitCrypting,

  uMemory,
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
    if GetParamStrDBBool('/CONVERT') or Settings.ReadBool('StartUp', 'ConvertDB', False) then
    begin
      CloseSplashWindow;
      EventLog('Converting...');
      Settings.WriteBool('StartUp', 'ConvertDB', False);
      ConvertDB(dbname);
    end;

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

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/RECREATETHTABLE') or Settings.ReadBool('StartUp', 'RecreateIDEx', False) then
    begin
      CloseSplashWindow;
      EventLog('Recreating thumbs in Table...');
      Settings.WriteBool('StartUp', 'RecreateIDEx', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.RecreateImThInPhotoTable;
      R(CMDForm);
    end;

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/SHOWBADLINKS') or Settings.ReadBool('StartUp', 'ScanBadLinks', False) then
    begin
      CloseSplashWindow;
      EventLog('Show Bad Links in table...');
      Settings.WriteBool('StartUp', 'ScanBadLinks', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.ShowBadLinks;
      R(CMDForm);
    end;

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/OPTIMIZE_DUPLICTES') or Settings.ReadBool('StartUp', 'OptimizeDuplicates', False) then
    begin
      CloseSplashWindow;
      EventLog('Optimizingduplicates in table...');
      Settings.WriteBool('StartUp', 'OptimizeDuplicates', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.OptimizeDuplicates;
      R(CMDForm);
    end;

  if not FolderView and not DBTerminating then
    if Settings.ReadBool('StartUp', 'Restore', False) then
    begin
      CloseSplashWindow;
      Settings.WriteBool('StartUp', 'Restore', False);
      EventLog('Restoring Table...' + Settings.ReadString('StartUp', 'RestoreFile'));
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.RestoreTable(Settings.ReadString('StartUp', 'RestoreFile'));
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
