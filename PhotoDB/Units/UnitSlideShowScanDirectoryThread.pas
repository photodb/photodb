unit UnitSlideShowScanDirectoryThread;

interface

uses
  Classes, Forms, uThreadForm, uThreadEx, ActiveX,
  UnitDBCommon, UnitDBDeclare, uDBUtils;

type
  TSlideShowScanDirectoryThread = class(TThreadEx)
  private
    { Private declarations }
    FSender: TForm;
    BaseFileName: string;
    Info: TRecordsInfo;
    FSID: TGUID;
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
end;

procedure TSlideShowScanDirectoryThread.Execute;
var
  N : integer;
begin
  FreeOnTerminate:=true;
  CoInitialize(nil);
  try
    GetFileListByMask(BaseFileName, SupportedExt, Info, N, true);
    SynchronizeEx(SynchNotify);
  finally
    CoUninitialize;
  end;
end;

procedure TSlideShowScanDirectoryThread.SynchNotify;
begin
  Viewer.WaitingList := False;
  Viewer.ExecuteW(Self, Info, BaseFileName);
end;

end.
