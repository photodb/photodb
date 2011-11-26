unit UnitInternetUpdate;

interface

uses
  Classes, Registry, Windows, SysUtils, UnitDBKernel, Forms,
  uVistaFuncs, uLogger, uConstants, uShellIntegration, uGOM, DateUtils,
  uTranslate, uInternetUtils, xmldom, uDBForm, ActiveX,
  Dolphin_DB, uActivationUtils, uSettings, uSysUtils, uDBThread;

type
  TInternetUpdate = class(TDBThread)
  private
    { Private declarations }
    FIsBackground: Boolean;
    StringParam: string;
    FNotifyHandler: TUpdateNotifyHandler;
    FOwner: TDBForm;
    Info : TUpdateInfo;
  protected
    function GetThreadID: string; override;
    procedure Execute; override;
    procedure ShowUpdates;
    procedure Inform(Info : String);
    procedure InformSynch;
    procedure ParceReply(Reply : string);
    procedure NotifySync;
  public
   constructor Create(Owner: TDBForm; IsBackground: Boolean; NotifyHandler: TUpdateNotifyHandler);
  end;
                                  
implementation

uses
  UnitFormInternetUpdating;

constructor TInternetUpdate.Create(Owner: TDBForm; IsBackground: Boolean; NotifyHandler: TUpdateNotifyHandler);
begin
  //form synchronization isn't used
  inherited Create(nil, False);
  FOwner := Owner;
  FIsBackground := IsBackground;
  FNotifyHandler := NotifyHandler;
end;

procedure TInternetUpdate.Execute;
var
  UpdateFullUrl,
  UpdateText: string;
  LastCheckDate: TDateTime;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try

    if FIsBackground then
    begin
      LastCheckDate := Settings.ReadDateTime('Updater', 'LastTime', Now - 365);

      if not (Now - LastCheckDate > 7) then
        Exit;
    end;

    try
      UpdateFullUrl := ResolveLanguageString(UpdateNotifyURL);
      UpdateFullUrl := UpdateFullUrl + '?c=' + TActivationManager.Instance.ApplicationCode + '&v=' + ProductVersion + '&lang=' + TTranslateManager.Instance.Language;
      UpdateText := DownloadFile(UpdateFullUrl, TEncoding.UTF8);
    except
      on E: Exception do
        EventLog(':TInternetUpdate::Execute() throw exception: ' + E.message);
    end;

    ParceReply(UpdateText);

  finally
    CoUninitialize;
  end;
end;

function TInternetUpdate.GetThreadID: string;
begin
  Result := 'Updates';
end;

procedure TInternetUpdate.Inform(Info: string);
begin
  StringParam := Info;
  Synchronize(InformSynch);
end;

procedure TInternetUpdate.InformSynch;
var
  ActiveFormHandle: Integer;
begin
  if Screen.ActiveForm <> nil then
    ActiveFormHandle := Screen.ActiveForm.Handle
  else
    ActiveFormHandle := 0;
  MessageBoxDB(ActiveFormHandle, StringParam, TA('Information'), TD_BUTTON_OK, TD_ICON_INFORMATION);
end;

procedure TInternetUpdate.NotifySync;
begin
  if (Assigned(FNotifyHandler)) and GOM.IsObj(FOwner) then
    FNotifyHandler(Self, Info);
end;

{
<update>
  <release>12</release>
  <build>250</build>
  <version>2.3.0.250</version>
  <release_date>201104312359</release_date>
  <release_notes>New Database 2.3</release_notes>
  <release_text>New Database 2.3 release text</release_text>
  <download_url>http://photodb.illusdolphin.net/en/download.aspx</download_url>
</update>
}
procedure TInternetUpdate.ParceReply(Reply: string);
var
  XmlReply: IDOMDocument;
  DocumentNode : IDOMNode;
  I: Integer;
  DetailName, DetailValue : string;
begin
  XmlReply := GetDOM.createDocument('', '', nil);
  (XmlReply as IDOMPersist).loadxml(Reply);
  Info.InfoAvaliable := False;
  Info.IsNewVersion := False;
  DocumentNode := XmlReply.documentElement;
  if DocumentNode <> nil then
  begin
    if DocumentNode.nodeName = 'update' then
    begin
      for I := 0 to DocumentNode.childNodes.length - 1 do
      begin
        DetailName := DocumentNode.childNodes[I].nodeName;
        DetailValue := '';
        if DocumentNode.childNodes[I].childNodes.length = 1 then
          DetailValue := DocumentNode.childNodes[I].childNodes[0].nodeValue;
        if DetailName = 'version' then
          Info.Version := StrToIntDef(DetailValue, 0)
        else if DetailName = 'build' then
          Info.Build := StrToIntDef(DetailValue, 0)
        else if DetailName = 'release' then
          Info.Release := StringToRelease(DetailValue)
        else if DetailName = 'release_date' then
          Info.ReleaseDate := InternetTimeToDateTime(DetailValue)
        else if DetailName = 'release_notes' then
          Info.ReleaseNotes := DetailValue
        else if DetailName = 'release_text' then
          Info.ReleaseText := DetailValue
        else if DetailName = 'download_url' then
          Info.UrlToDownload := DetailValue;
      end;
      Info.InfoAvaliable := True;
      Info.IsNewVersion := IsNewRelease(GetExeVersion(ParamStr(0)), Info.Release);
    end;
  end;
  if not Assigned(FNotifyHandler)  then
  begin
    if not (FIsBackground and not Info.IsNewVersion) then
    begin
      if Info.IsNewVersion then
        Synchronize(ShowUpdates)
      else if Info.InfoAvaliable then
        Inform(L('No new updates are available'))
      else
        Inform(L('Unable to check updates! Please, check internet settings in Internet Explorer!'));
    end;
  end else
    Synchronize(NotifySync);
end;

procedure TInternetUpdate.ShowUpdates;
begin
  ShowAvaliableUpdating(Info);
end;

end.
