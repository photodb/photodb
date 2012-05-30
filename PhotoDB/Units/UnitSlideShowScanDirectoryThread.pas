unit UnitSlideShowScanDirectoryThread;

interface

uses
  Classes, Forms, uThreadForm, uThreadEx, ActiveX, uMemory, uConstants,
  UnitDBCommon, UnitDBDeclare, uDBUtils, uDBPopupMenuInfo, uAssociations;

type
  TSlideShowScanDirectoryThread = class(TThreadEx)
  private
    { Private declarations }
    FSender: TForm;
    BaseFileName: string;
    Info: TDBPopupMenuInfo;
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
  N: Integer;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    Info := TDBPopupMenuInfo.Create;
    try
      GetFileListByMask(BaseFileName, TFileAssociations.Instance.ExtensionList, Info, N, True);
      SynchronizeEx(SynchNotify);
    finally
      F(Info);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TSlideShowScanDirectoryThread.SynchNotify;
begin
  ViewerForm.WaitingList := False;
  ViewerForm.ExecuteW(Self, Info, BaseFileName);
end;

end.
