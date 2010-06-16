unit UnitSlideShowUpdateInfoThread;

interface

uses
  Classes, SysUtils, DB, CommonDBSupport, Dolphin_DB, uThreadForm, uThreadEx;

type
  TSlideShowUpdateInfoThread = class(TThreadEx)
  private
   FFileName : string;
   DS : TDataSet;
    { Private declarations }
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
  Start;
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
 FreeOnTerminate:=true;
 DS:=GetQuery;
 SetSQL(DS,'SELECT * FROM '+GetDefDBName+' WHERE FFileName like :ffilename');
 SetStrParam(DS,0,DelNakl(AnsiLowerCase(FFileName)));
 try
  DS.Active:=true;
 except      
  FreeDS(DS);
  SynchronizeEx(DoSetNotDBRecord);
  exit;
 end;
 if DS.RecordCount=0 then
 begin           
  SynchronizeEx(DoSetNotDBRecord);
 end else
 begin
  SynchronizeEx(DoUpdateWithSlideShow);
 end;
 FreeDS(DS);
end;

end.
