unit UnitRefreshDBRecordsThread;

interface

uses
  Classes, Dolphin_DB, UnitDBKernel, Forms, UnitPropeccedFilesSupport,
  UnitDBDeclare, SysUtils, uLogger;

type
  TRefreshIDRecordThreadOptions = record
   Files : TArStrings;
   IDs : TArInteger;   
   Selected : TArBoolean;
  end;

type
  TRefreshDBRecordsThread = class(TThread)
  private
    fOptions: TRefreshIDRecordThreadOptions;   
    ProgressWindow : TForm;
    BoolParam : boolean;
    Count : integer;
    IntParam : integer;
    StrParam : string;
    DBEvent_Sender: TObject;
    DBEvent_ID: integer;
    DBEvent_Params: TEventFields;
    DBEvent_Value: TEventValues;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; Options: TRefreshIDRecordThreadOptions); 
    procedure InitializeProgress;    
    procedure DestroyProgress;   
    procedure IfBreakOperation;
    procedure SetProgressPosition(Position : integer);
    procedure SetProgressPositionSynch;
    procedure DoDBkernelEvent;
    procedure DoDBkernelEventRefreshList;
    procedure RemoveFileFromUpdatingList;
    procedure OnDBKernelEventProcedure(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure OnDBKernelEventProcedureSunch;
  end;

implementation

uses ProgressActionUnit;

{ TRefreshDBRecordsThread }

constructor TRefreshDBRecordsThread.Create(CreateSuspennded: Boolean;
  Options: TRefreshIDRecordThreadOptions);
var
  i : integer;
begin
 inherited create(true);
 fOptions:=Options;
 for i:=0 to Length(Options.Files)-1 do    
 if Options.IDs[i]<>0 then
 if Options.Selected[i] then
 ProcessedFilesCollection.AddFile(Options.Files[i]);
 DoDBkernelEventRefreshList;
 if not CreateSuspennded then Resume;
end;

procedure TRefreshDBRecordsThread.Execute;
var
  i,j : integer;
  c : integer;
begin
 FreeOnTerminate:=true;
 Count:=0;
 for i:=0 to Length(fOptions.IDs)-1 do
 if fOptions.Selected[i] then    
 if fOptions.IDs[i]<>0 then
 inc(Count);
 Synchronize(InitializeProgress);
 c:=0;
 for i:=0 to Length(fOptions.IDs)-1 do
 begin
  if fOptions.IDs[i]<>0 then
  if fOptions.Selected[i] then
  begin   
   Synchronize(IfBreakOperation);
   if BoolParam then
   begin
    for j:=i to Length(fOptions.IDs)-1 do
    begin
     StrParam:=fOptions.Files[j];
     Synchronize(RemoveFileFromUpdatingList);
    end;
    Synchronize(DoDBkernelEventRefreshList);
    continue;
   end;
   Inc(c);
   SetProgressPosition(c);
   try
    //TODO: DBKernelEvent NOT in thread!
    UpdateImageRecordEx(fOptions.Files[i],fOptions.IDs[i],OnDBKernelEventProcedure);
   except
    on e : Exception do EventLog(':TRefreshDBRecordsThread::Execute()/UpdateImageRecord throw exception: '+e.Message);
   end;
   IntParam:=fOptions.IDs[i];
   StrParam:=fOptions.Files[i];
   Synchronize(RemoveFileFromUpdatingList);    
   Synchronize(DoDBkernelEventRefreshList);
   Synchronize(DoDBkernelEvent);
  end;
 end;
 Synchronize(DestroyProgress);
end;

procedure TRefreshDBRecordsThread.InitializeProgress;
begin
 ProgressWindow:=GetProgressWindow;
 With ProgressWindow as TProgressActionForm do
 begin
  CanClosedByUser:=True;
  OneOperation:=false;
  OperationCount:=1;
  OperationPosition:=1;
  MaxPosCurrentOperation:=Count;
  xPosition:=0;
  Show;
 end;
end;

procedure TRefreshDBRecordsThread.DestroyProgress;
begin
 (ProgressWindow as TProgressActionForm).WindowCanClose:=true;
 ProgressWindow.Release;
 if UseFreeAfterRelease then ProgressWindow.Free;
end;

procedure TRefreshDBRecordsThread.IfBreakOperation;
begin
 BoolParam:=(ProgressWindow as TProgressActionForm).Closed;
end;

procedure TRefreshDBRecordsThread.SetProgressPosition(Position: integer);
begin
 IntParam:=Position;
 Synchronize(SetProgressPositionSynch);
end;

procedure TRefreshDBRecordsThread.SetProgressPositionSynch;
begin
 (ProgressWindow as TProgressActionForm).xPosition:=IntParam;
end;

procedure TRefreshDBRecordsThread.DoDBkernelEvent;
var
  EventInfo : TEventValues;
begin
 EventInfo.ID := IntParam;
 EventInfo.Image:=nil;
 DBKernel.DoIDEvent(nil,IntParam,[EventID_Param_Image],EventInfo);
end;

procedure TRefreshDBRecordsThread.RemoveFileFromUpdatingList;
begin
 ProcessedFilesCollection.RemoveFile(StrParam);
end;

procedure TRefreshDBRecordsThread.DoDBkernelEventRefreshList;
var
  EventInfo : TEventValues;
begin
 DBKernel.DoIDEvent(nil,IntParam,[EventID_Repaint_ImageList],EventInfo);
end;

procedure TRefreshDBRecordsThread.OnDBKernelEventProcedure(Sender: TObject;
  ID: integer; Params: TEventFields; Value: TEventValues);
begin
 DBEvent_Sender:=Sender;
 DBEvent_ID:=ID;
 DBEvent_Params:=Params;
 DBEvent_Value:=Value;
 Synchronize(OnDBKernelEventProcedureSunch);
end;

procedure TRefreshDBRecordsThread.OnDBKernelEventProcedureSunch;
begin
 DBKernel.DoIDEvent(DBEvent_Sender, DBEvent_ID, DBEvent_Params, DBEvent_Value);
end;

end.
