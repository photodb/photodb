unit uLoadStyleThread;

interface

uses
  Vcl.Styles,
  Themes,
  SysUtils,
  uLogger,
  uSettings,
  uConstants,
  uDBThread,
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
  SI: TStyleInfo;
begin
  FreeOnTerminate := True;
  try
    StyleFileName := Settings.ReadString('Style', 'FileName', 'Amakrits.vsf');
    if StyleFileName <> '' then
    begin
      StyleFileName := ExtractFilePath(ParamStr(0)) + StylesFolder + StyleFileName;
      if TStyleManager.IsValidStyle(StyleFileName, SI) then
      begin
        TStyleManager.LoadFromFile(StyleFileName);
        TStyleManager.SetStyle(si.Name);
      end;
    end;
  except
    on e: Exception do
      EventLog(e);
  end;
end;

initialization
  TLoad.Instance.StartStyleThread;

end.
