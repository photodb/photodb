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
  CoInitialize(nil);
  try
    //Call translate manager to load XML with language in separate thead
    TA('PhotoDB');
  finally
    CoUninitialize;
  end;
end;

initialization

  if FolderView then
    LanguageInitCallBack := LoadLanguageFromMobileFS;

  TLanguageThread.Create(False);
  TW.I.Start('LANGUAGE THREAD');

end.
