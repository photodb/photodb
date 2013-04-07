unit uLoadStyleThread;

interface

uses
  Windows,
  Vcl.Styles,
  Themes,
  SysUtils,
  uLogger,
  uSettings,
  uConstants,
  uDBThread,
  uRuntime,
  uTime,
  Classes;

type
  TLoadStyleThread = class(TDBThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses
  uFastLoad;

{ TLoadStyleThread }

procedure TLoadStyleThread.Execute;
var
  StyleFileName: string;
  StyleHandle: TStyleManager.TStyleServicesHandle;
  SI: TStyleInfo;
begin
  FreeOnTerminate := True;
  try
    TW.I.Start('TLoadStyleThread - START');
    if not FolderView then
    begin
      StyleFileName := AppSettings.ReadString('Style', 'FileName', DefaultThemeName);
      if StyleFileName <> '' then
      begin
        if Pos(':', StyleFileName) = 0 then
          StyleFileName := ExtractFilePath(ParamStr(0)) + StylesFolder + StyleFileName;
        if TStyleManager.IsValidStyle(StyleFileName, SI) then
        begin
          TStyleManager.LoadFromFile(StyleFileName);
          TStyleManager.SetStyle(si.Name);
        end;
      end;
    end else
    begin
      TStyleManager.Initialize;
      if TStyleManager.TryLoadFromResource(HInstance, 'MOBILE_STYLE', PWideChar(StyleResourceSection), StyleHandle) then
        TStyleManager.SetStyle(StyleHandle);
    end;
    TW.I.Start('TLoadStyleThread - END');
  except
    on e: Exception do
      EventLog(e);
  end;
end;

initialization
  TLoad.Instance.StartStyleThread;

end.
