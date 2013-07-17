unit uCommandLine;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Forms,

  Dmitry.Utils.Files,

  CMDUnit,
  GraphicCrypt,
  UnitCrypting,

  uConstants,
  uMemoryEx,
  uAppUtils,
  uSplashThread,
  uMediaPlayers,
  uLogger,
  uSettings,
  uTranslate,
  uShellIntegration,
  uUninstallUtils,
  uRuntime,
  uShellUtils,
  uFormInterfaces,
  uSessionPasswords,
  uAssociations,
  uDBUtils,
  uDBContext;

type
  TCommandLine = class
    class procedure ProcessServiceCommands(Context: IDBContext);
    class procedure ProcessUserCommandLine(Context: IDBContext);
  end;

implementation

procedure StopApplication;
begin
  CloseSplashWindow;
  DBTerminating := True;
end;

{ TCommandLine }

class procedure TCommandLine.ProcessServiceCommands(Context: IDBContext);
var
  ExtensionList: string;
begin
  if GetParamStrDBBool('/AddPass') then
    SessionPasswords.GetPasswordsFromParams;

  if GetParamStrDBBool('/installExt') then
  begin
    ExtensionList := GetParamStrDBValue('/installExt');

    InstallGraphicFileAssociationsFromParamStr(Application.ExeName, ExtensionList);
    RefreshSystemIconCache;
  end;

  if GetParamStrDBBool('/CPU1') then
    ProcessorCount := 1;

  if not FolderView and not DBTerminating and GetParamStrDBBool('/install') then
  begin
    //to force check updates after install
    AppSettings.ReadDateTime('Updater', 'LastTime', Now - 365);
    RegisterVideoFiles;
    StopApplication;
  end;

  if not FolderView and not DBTerminating and GetParamStrDBBool('/uninstall') then
  begin
    CleanUpUserSettings;
    StopApplication;
  end;

  if GetParamStrDBBool('/close') then
    StopApplication;

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/PACKTABLE') or AppSettings.ReadBool('StartUp', 'Pack', False) then
    begin
      CloseSplashWindow;
      EventLog('Packing...');
      AppSettings.WriteBool('StartUp', 'Pack', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.PackPhotoTable(Context.CollectionFileName);
      R(CMDForm);
    end;

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/BACKUP') or AppSettings.ReadBool('StartUp', 'BackUp', False) then
    begin
      CloseSplashWindow;
      EventLog('BackUp...');
      AppSettings.WriteBool('StartUp', 'BackUp', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.BackUpTable(Context.CollectionFileName);
      R(CMDForm);
    end;
end;

class procedure TCommandLine.ProcessUserCommandLine(Context: IDBContext);
var
  S: string;
  Password: string;
  ID: Integer;
  MediaRepository: IMediaRepository;
begin
  if GetParamStrDBBool('/cmd') then
  begin
    CloseSplashWindow;
    DBTerminating := True;
  end;

  if GetParamStrDBBool('/e') then
  begin
    MediaRepository := Context.Media;
    S := AnsiDequotedStr(GetParamStrDBValue('/e'), '"');
    ID := MediaRepository.GetIdByFileName(S);
    Password := AnsiDequotedStr(GetParamStrDBValue('/p'), '"');

    EncryptImageByFileName(Context, nil, S, ID, Password, CRYPT_OPTIONS_NORMAL, False);
  end;

  if GetParamStrDBBool('/d') then
  begin
    MediaRepository := Context.Media;
    S := AnsiDequotedStr(GetParamStrDBValue('/d'), '"');
    ID := MediaRepository.GetIdByFileName(S);
    Password := AnsiDequotedStr(GetParamStrDBValue('/p'), '"');

    ResetPasswordImageByFileName(Context, nil, S, ID, Password);
  end;

  if not FolderView then
  begin
    if AnsiUpperCase(ParamStr(1)) = '/GETPHOTOS' then
      if ParamStr(2) <> '' then
        ImportForm.FromDrive(ParamStr(2)[1]);
  end;
end;

end.
