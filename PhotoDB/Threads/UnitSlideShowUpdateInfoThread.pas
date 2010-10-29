unit UnitSlideShowUpdateInfoThread;

interface

uses
  Classes, SysUtils, DB, CommonDBSupport, Dolphin_DB, uThreadForm, uThreadEx, ActiveX;

type
  TSlideShowUpdateInfoThread = class(TThreadEx)
  private
    { Private declarations }
   FFileName : string;
   DS : TDataSet;
  protected
    procedure Execute; override;
    procedure DoUpdateWithSlideShow;
    procedure DoSetNotDBRecord;
  public
    constructor Create(AOwner : TThreadForm; AState : TGUID; FileName : string);
  end;

implementation

uses SlideShow;

{ TSlideShowUpdateInfoThread }

constructor TSlideShowUpdateInfoThread.Create(AOwner : TThreadForm; AState : TGUID; FileName : string);
begin
  inherited Create(AOwner, AState);
  FFileName := FileName;
end;

procedure TSlideShowUpdateInfoThread.DoSetNotDBRecord;
begin
  Viewer.DoSetNoDBRecord(fFileName);
end;

procedure TSlideShowUpdateInfoThread.DoUpdateWithSlideShow;
begin
  Viewer.DoUpdateRecordWithDataSet(fFileName, DS);
end;

procedure TSlideShowUpdateInfoThread.Execute;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    DS:=GetQuery(True);
    try
      SetSQL(DS, 'SELECT * FROM $DB$ WHERE FolderCRC = '+IntToStr(GetPathCRC(FFileName))+' AND FFileName LIKE :FFileName');
      SetStrParam(DS, 0, DelNakl(AnsiLowerCase(FFileName)));
      try
        DS.Active := True;
      except
        SynchronizeEx(DoSetNotDBRecord);
        Exit;
      end;
      if DS.RecordCount = 0 then
        SynchronizeEx(DoSetNotDBRecord)
      else
        SynchronizeEx(DoUpdateWithSlideShow);
    finally
      FreeDS(DS);
    end;
  finally
    CoUninitialize;
  end;
end;

end.
