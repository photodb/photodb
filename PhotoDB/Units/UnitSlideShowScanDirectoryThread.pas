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
   fSID : String;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; Sender : TForm; SID, aBaseFileName : string);
    procedure SynchNotify;
  end;

implementation

uses SlideShow;

constructor TSlideShowScanDirectoryThread.Create(CreateSuspennded: Boolean;
  Sender: TForm; SID, aBaseFileName: string);
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
 GetFileListByMask(BaseFileName,SupportedExt,Info,n,DBKernel.UserRights.ShowPrivate);
 Synchronize(SynchNotify);
end;

procedure TSlideShowScanDirectoryThread.SynchNotify;
begin
 if Viewer<>nil then
 if Viewer.SID=fSID then
 begin
  Viewer.WaitingList:=false;
  Viewer.ExecuteW(self, Info, BaseFileName);
 end;
end;

end.
