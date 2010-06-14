unit UnitSlideShowUpdateInfoThread;

interface

uses
  Classes, SysUtils, DB, CommonDBSupport, Dolphin_DB;

type
  TSlideShowUpdateInfoThread = class(TThread)
  private
   FFileName : string;
   DS : TDataSet;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure DoUpdateWithSlideShow;
    procedure DoSetNotDBRecord;
  public
    constructor Create(CreateSuspennded: Boolean; FileName : string);
    destructor Destroy; override;
  end;

implementation

uses SlideShow;

{ TSlideShowUpdateInfoThread }

constructor TSlideShowUpdateInfoThread.Create(CreateSuspennded: Boolean;
  FileName: string);
begin
 inherited Create(true);
 fFileName:=FileName;
 if not CreateSuspennded then Resume;
end;

destructor TSlideShowUpdateInfoThread.Destroy;
begin
 inherited;
end;

procedure TSlideShowUpdateInfoThread.DoSetNotDBRecord;
begin
 if Viewer<>nil then
 begin
  Viewer.DoSetNoDBRecord(fFileName);
 end;
end;

procedure TSlideShowUpdateInfoThread.DoUpdateWithSlideShow;
begin
 if Viewer<>nil then
 begin
  Viewer.DoUpdateRecordWithDataSet(fFileName, DS);
 end;
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
  Synchronize(DoSetNotDBRecord);
  exit;
 end;
 if DS.RecordCount=0 then
 begin           
  Synchronize(DoSetNotDBRecord);
 end else
 begin
  Synchronize(DoUpdateWithSlideShow);
 end;
 FreeDS(DS);
end;

end.
