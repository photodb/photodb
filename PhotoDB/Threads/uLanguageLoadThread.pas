unit uLanguageLoadThread;

interface

uses
  uTranslate, Classes, ActiveX, uRuntime, uMobileUtils, uTime;

type
  TLanguageThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

{ TLanguageThread }

procedure TLanguageThread.Execute;
begin
  FreeOnTerminate := True;
  TW.I.Start('TLanguageThread.Execute - CoInitialize');
  CoInitializeEx(COINIT_MULTITHREADED, nil);
  try
    //Call translate manager to load XML with language in separate thead
    TW.I.Start('TLanguageThread.Execute - PhotoDB');
    TA('PhotoDB');
    TW.I.Start('TLanguageThread.Execute - END');
  finally
    TW.I.Start('TLanguageThread.Execute - CoUninitialize');
    CoUninitialize;
  end;
end;

initialization

  if FolderView then
    LanguageInitCallBack := LoadLanguageFromMobileFS;

  TLanguageThread.Create(False);
  TW.I.Start('LANGUAGE THREAD');

end.
