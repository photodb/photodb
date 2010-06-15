unit UnitSlideShowScanDirectoryThread;

interface

uses
  Classes, Forms, Dolphin_DB;

type
  TSlideShowScanDirectoryThread = class(TThread)
  private
   FSender : TForm;
   BaseFileName : string;
   Info : TRecordsInfo;
   fSID : TGUID;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; Sender : TForm; SID : TGUID; aBaseFileName : string);
    procedure SynchNotify;
  end;

implementation

uses SlideShow, SysUtils;

constructor TSlideShowScanDirectoryThread.Create(CreateSuspennded: Boolean;
  Sender: TForm; SID : TGUID; aBaseFileName: string);
begin         
 inherited create(true);
 fSID := SID;
 fSender:=Sender;
 BaseFileName:=aBaseFileName;  
 if not CreateSuspennded then Resume;
end;

procedure TSlideShowScanDirectoryThread.Execute;
var
  n : integer;
begin
 FreeOnTerminate:=true;
 GetFileListByMask(BaseFileName, SupportedExt,Info, n, true);
 Synchronize(SynchNotify);
end;

procedure TSlideShowScanDirectoryThread.SynchNotify;
begin
 if Viewer<>nil then
 if IsEqualGUID(Viewer.SID, fSID) then
 begin
  Viewer.WaitingList:=false;
  Viewer.ExecuteW(self, Info, BaseFileName);
 end;
end;

end.
