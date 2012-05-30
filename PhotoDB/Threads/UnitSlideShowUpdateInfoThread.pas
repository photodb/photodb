unit UnitSlideShowUpdateInfoThread;

interface

uses
  Classes, SysUtils, DB, CommonDBSupport, Dolphin_DB, uThreadForm, uThreadEx,
  ActiveX, UnitDBDeclare, uMemory, uExifUtils, uConstants;

type
  TSlideShowUpdateInfoThread = class(TThreadEx)
  private
    { Private declarations }
    FFileName : string;
    DS : TDataSet;
    FInfo: TDBPopupMenuInfoRecord;
  protected
    procedure Execute; override;
    procedure DoUpdateWithSlideShow;
    procedure DoSetNotDBRecord;
    procedure SetNoInfo;
  public
    constructor Create(AOwner : TThreadForm; AState : TGUID; FileName : string);
    destructor Destroy; override;
  end;

implementation

uses SlideShow;

{ TSlideShowUpdateInfoThread }

constructor TSlideShowUpdateInfoThread.Create(AOwner : TThreadForm; AState : TGUID; FileName : string);
begin
  inherited Create(AOwner, AState);
  FFileName := FileName;
  FInfo := nil;
end;

destructor TSlideShowUpdateInfoThread.Destroy;
begin
  F(FInfo);
  inherited;
end;

procedure TSlideShowUpdateInfoThread.DoSetNotDBRecord;
begin
  ViewerForm.DoSetNoDBRecord(FInfo);
end;

procedure TSlideShowUpdateInfoThread.DoUpdateWithSlideShow;
begin
  ViewerForm.DoUpdateRecordWithDataSet(FFileName, DS);
end;

procedure TSlideShowUpdateInfoThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    DS := GetQuery(True);
    try
      SetSQL(DS, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FFileName, True)) + ' AND FFileName LIKE :FFileName');
      SetStrParam(DS, 0, AnsiLowerCase(FFileName));
      try
        DS.Active := True;
      except
        SetNoInfo;
        Exit;
      end;
      if DS.RecordCount = 0 then
        SetNoInfo
      else
        SynchronizeEx(DoUpdateWithSlideShow);
    finally
      FreeDS(DS);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TSlideShowUpdateInfoThread.SetNoInfo;
begin
  FInfo := TDBPopupMenuInfoRecord.CreateFromFile(FFileName);
  UpdateImageRecordFromExif(FInfo, False);
  SynchronizeEx(DoSetNotDBRecord);
end;

end.
