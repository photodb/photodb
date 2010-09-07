unit UnitSlideShowScanDirectoryThread;

interface

uses
  Classes, Forms, Dolphin_DB, uThreadForm, uThreadEx, ActiveX, UnitDBCommon;

type
  TSlideShowScanDirectoryThread = class(TThreadEx)
  private
   FSender : TForm;
   BaseFileName : string;
   Info : TRecordsInfo;
   fSID : TGUID;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(Sender : TThreadForm; SID : TGUID; aBaseFileName : string);
    procedure SynchNotify;
  end;

implementation

uses SlideShow, SysUtils;

constructor TSlideShowScanDirectoryThread.Create(
  Sender: TThreadForm; SID : TGUID; aBaseFileName: string);
begin         
  inherited Create(Sender, SID);
  fSID := SID;
  fSender:=Sender;
  BaseFileName:=aBaseFileName;
  Start;
end;

procedure TSlideShowScanDirectoryThread.Execute;
var
  n : integer;
begin
  FreeOnTerminate:=true;
  CoInitialize(nil);
  try
    GetFileListByMask(BaseFileName, SupportedExt,Info, n, true);
    SynchronizeEx(SynchNotify);
  finally
    CoUninitialize;
  end;
end;

procedure TSlideShowScanDirectoryThread.SynchNotify;
begin
  Viewer.WaitingList:=false;
  Viewer.ExecuteW(self, Info, BaseFileName);
end;

end.
