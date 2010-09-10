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
  FSID := SID;
  FSender := Sender;
  BaseFileName := ABaseFileName;
  Start;
end;

procedure TSlideShowScanDirectoryThread.Execute;
var
  N : integer;
begin
  FreeOnTerminate:=true;
  CoInitialize(nil);
  try
    GetFileListByMask(BaseFileName, SupportedExt,Info, N, true);
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
