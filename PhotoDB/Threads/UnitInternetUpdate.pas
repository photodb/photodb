unit UnitInternetUpdate;

interface

uses
  Classes, Registry, Windows, SysUtils, UnitDBKernel, Forms,
  uVistaFuncs, uLogger, uConstants, uShellIntegration,
  uTranslate, uInternetUtils;

type
  TInternetUpdate = class(TThread)
  private
    { Private declarations }
    NewVersion, Text, URL: string;
    FNeedsInformation: Boolean;
    StringParam: string;
  protected
    procedure Execute; override;
    procedure ShowUpdates;
    procedure Inform(Info : String);
    procedure InformSynch;
  public
   constructor Create(NeedsInformation : Boolean);
  end;

var
  UpdatingWorking : boolean;

implementation

uses UnitFormInternetUpdating;

constructor TInternetUpdate.Create(NeedsInformation: Boolean);
begin
  inherited Create(False);
  FNeedsInformation := NeedsInformation;
end;

procedure TInternetUpdate.Execute;
var
  UpdateFullUrl,
  UpdateText: string;
  Vesrion, Release: Integer;
  I: Integer;
  D: TDateTime;
begin
  FreeOnTerminate := True;
  if UpdatingWorking then
    Exit;
  UpdatingWorking := True;
  D := DBKernel.ReadDateTime('', 'LastUpdating', Now);
  Sleep(5000);
  if (Now - D < 7) and not FNeedsInformation then
  begin
    UpdatingWorking := False;
    Exit;
  end;

  try
    UpdateFullUrl := HomeURL + StringReplace(UpdateNotifyURL, '{LNG}', TTranslateManager.Instance.Language, []);
    UpdateText := DownloadFile(UpdateFullUrl);
  except
    on E: Exception do
      EventLog(':TInternetUpdate::Execute() throw exception: ' + E.message);
  end;

  UpdatingWorking := False;
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

procedure TInternetUpdate.ShowUpdates;
begin
  ShowAvaliableUpdating(NewVersion, Text, URL);
end;

initialization

UpdatingWorking := False;

end.
