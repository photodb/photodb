unit UnitSlideShowScanDirectoryThread;

interface

uses
  Classes,
  Forms,
  ActiveX,

  uConstants,
  uMemory,
  uThreadEx,
  uThreadForm,
  uDBUtils,
  uDBContext,
  uDBPopupMenuInfo,
  uAssociations;

type
  TSlideShowScanDirectoryThread = class(TThreadEx)
  private
    { Private declarations }
    FContext: IDBContext;
    FSender: TForm;
    BaseFileName: string;
    Info: TDBPopupMenuInfo;
    FSID: TGUID;
  protected
    procedure Execute; override;
  public
    constructor Create(Context: IDBContext; Sender: TThreadForm; SID: TGUID; aBaseFileName: string);
    procedure SynchNotify;
  end;

implementation

uses SlideShow, SysUtils;

constructor TSlideShowScanDirectoryThread.Create(Context: IDBContext;
  Sender: TThreadForm; SID: TGUID; aBaseFileName: string);
begin
  inherited Create(Sender, SID);
  FContext := Context;
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
      GetFileListByMask(FContext, BaseFileName, TFileAssociations.Instance.ExtensionList, Info, N, True);
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
