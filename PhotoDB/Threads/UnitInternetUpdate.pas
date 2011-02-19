unit UnitInternetUpdate;

interface

uses
  Classes, Registry, Windows, SysUtils, UnitDBKernel, Forms,
  uVistaFuncs, uLogger, uConstants, uShellIntegration, uGOM, DateUtils,
  uTranslate, uInternetUtils, MSXML, OmniXML_MSXML, uDBForm, ActiveX,
  Dolphin_DB;

type
  TInternetUpdate = class(TThread)
  private
    { Private declarations }
    NewVersion, Text, URL: string;
    FNeedsInformation: Boolean;
    StringParam: string;
    FNotifyHandler: TUpdateNotifyHandler;
    FOwner: TDBForm;
    Info : TUpdateInfo;
  protected
    procedure Execute; override;
    procedure ShowUpdates;
    procedure Inform(Info : String);
    procedure InformSynch;
    procedure ParceReply(Reply : string);
    procedure NotifySync;
  public
   constructor Create(Owner : TDBForm; NeedsInformation : Boolean; NotifyHandler : TUpdateNotifyHandler);
  end;
                                  
implementation

uses
  UnitFormInternetUpdating;

constructor TInternetUpdate.Create(Owner : TDBForm; NeedsInformation : Boolean; NotifyHandler : TUpdateNotifyHandler);
begin
  inherited Create(False);
  FOwner := Owner;
  FNeedsInformation := NeedsInformation;
  FNotifyHandler := NotifyHandler;
end;

procedure TInternetUpdate.Execute;
var
  UpdateFullUrl,
  UpdateText: string;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
  {  if UpdatingWorking then
      Exit;
    UpdatingWorking := True;
    D := DBKernel.ReadDateTime('', 'LastUpdating', Now);
    Sleep(5000);
    if (Now - D < 7) and not FNeedsInformation then
    begin
      UpdatingWorking := False;
      Exit;
    end;     }

    try
      UpdateFullUrl := ResolveLanguageString(UpdateNotifyURL);
      UpdateText := DownloadFile(UpdateFullUrl);
    except
      on E: Exception do
        EventLog(':TInternetUpdate::Execute() throw exception: ' + E.message);
    end;

    ParceReply(UpdateText);

  finally
    CoUninitialize;
  end;
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
  begin
    FNotifyHandler(Self, Info);
  end;
end;

{
<update>
  <release>12</release>
  <build>250</build>
  <version>2.3.0.250</version>
  <release_date>201104312359</release_date>
  <release_notes>New Database 2.3</release_notes>
  <release_text>New Database 2.3 release notes</release_text>
  <download_url>http://photodb.illusdolphin.net/en/download.aspx</download_url>
</update>
}
procedure TInternetUpdate.ParceReply(Reply: string);
var
  XmlReply: IXMLDOMDocument;
  DocumentNode : IXMLDOMNode;
  I: Integer;
  DetailName, DetailValue : string;
begin
  XmlReply := CreateXMLDoc;
  XmlReply.loadXML(Reply);
  Info.InfoAvaliable := False;
  DocumentNode := XmlReply.documentElement;
  if DocumentNode <> nil then
  begin
    if DocumentNode.nodeName = 'update' then
    begin
      for I := 0 to DocumentNode.childNodes.length - 1 do
      begin
        DetailName := DocumentNode.childNodes[I].nodeName;
        DetailValue := DocumentNode.childNodes[I].text;
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
    end;
  end;
  Synchronize(NotifySync);
end;

procedure TInternetUpdate.ShowUpdates;
begin
  ShowAvaliableUpdating(NewVersion, Text, URL);
end;

initialization

end.
