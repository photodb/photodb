unit UnitRefreshDBRecordsThread;

interface

uses
  Classes,
  uDBPopupMenuInfo,
  UnitDBKernel,
  Forms,
  UnitPropeccedFilesSupport,
  UnitDBDeclare,
  SysUtils,
  uLogger,
  uMemory,
  uDBUtils,
  ActiveX,
  uDBForm,
  uDBThread,
  uConstants;

type
  TRefreshIDRecordThreadOptions = record
    Info: TDBPopupMenuInfo;
  end;

type
  TRefreshDBRecordsThread = class(TDBThread)
  private
    { Private declarations }
    FInfo: TDBPopupMenuInfo;
    ProgressWindow: TForm;
    BoolParam: Boolean;
    Count: Integer;
    IntParam: Integer;
    StrParam: string;
    DBEvent_Sender: TDBForm;
    DBEvent_ID: Integer;
    DBEvent_Params: TEventFields;
    DBEvent_Value: TEventValues;
  protected
    procedure Execute; override;
  public
    constructor Create(Owner: TDBForm; Options: TRefreshIDRecordThreadOptions);
    destructor Destroy; override;
    procedure InitializeProgress;
    procedure DestroyProgress;
    procedure IfBreakOperation;
    procedure SetProgressPosition(Position: Integer);
    procedure SetProgressPositionSynch;
    procedure DoDBkernelEvent;
    procedure DoDBkernelEventRefreshList;
    procedure OnDBKernelEventProcedure(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure OnDBKernelEventProcedureSunch;
  end;

implementation

uses ProgressActionUnit;

{ TRefreshDBRecordsThread }

constructor TRefreshDBRecordsThread.Create(Owner: TDBForm; Options: TRefreshIDRecordThreadOptions);
var
  I: Integer;
begin
  inherited Create(Owner, False);
  DBEvent_Sender := Owner;
  FInfo := TDBPopupMenuInfo.Create;
  FInfo.Assign(Options.Info);
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].ID <> 0 then
      if FInfo[I].Selected then
        ProcessedFilesCollection.AddFile(FInfo[I].FileName);
  DoDBkernelEventRefreshList;
end;

procedure TRefreshDBRecordsThread.Execute;
var
  I, J: Integer;
  C: Integer;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    Count := 0;
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].ID <> 0 then
        if FInfo[I].Selected then
          Inc(Count);
    SynchronizeEx(InitializeProgress);
    C := 0;
    for I := 0 to FInfo.Count - 1 do
    begin
      if FInfo[I].ID <> 0 then
        if FInfo[I].Selected then
        begin
          SynchronizeEx(IfBreakOperation);
          if BoolParam then
          begin
            for J := I to FInfo.Count - 1 do
              ProcessedFilesCollection.RemoveFile(FInfo[J].FileName);

            SynchronizeEx(DoDBkernelEventRefreshList);
            Continue;
          end;
          Inc(C);
          SetProgressPosition(C);
          try
            UpdateImageRecordEx(DBEvent_Sender, FInfo[I].FileName, FInfo[I].ID, OnDBKernelEventProcedure);
          except
            on E: Exception do
              EventLog(':TRefreshDBRecordsThread::Execute()/UpdateImageRecord throw exception: ' + E.message);
          end;
          IntParam := FInfo[I].ID;
          StrParam := FInfo[I].FileName;
          ProcessedFilesCollection.RemoveFile(FInfo[I].FileName);
          SynchronizeEx(DoDBKernelEventRefreshList);
          SynchronizeEx(DoDBKernelEvent);
        end;
    end;
  finally
    CoUninitialize;
  end;
  SynchronizeEx(DestroyProgress);
end;

procedure TRefreshDBRecordsThread.InitializeProgress;
begin
  ProgressWindow := GetProgressWindow;
  with ProgressWindow as TProgressActionForm do
  begin
    CanClosedByUser := True;
    OneOperation := False;
    OperationCount := 1;
    OperationPosition := 1;
    MaxPosCurrentOperation := Count;
    XPosition := 0;
    Show;
  end;
end;

destructor TRefreshDBRecordsThread.Destroy;
begin
  F(FInfo);
  inherited;
end;

procedure TRefreshDBRecordsThread.DestroyProgress;
begin
  (ProgressWindow as TProgressActionForm).WindowCanClose := True;
  ProgressWindow.Release;
end;

procedure TRefreshDBRecordsThread.IfBreakOperation;
begin
  BoolParam := (ProgressWindow as TProgressActionForm).Closed;
end;

procedure TRefreshDBRecordsThread.SetProgressPosition(Position: Integer);
begin
  IntParam := Position;
  SynchronizeEx(SetProgressPositionSynch);
end;

procedure TRefreshDBRecordsThread.SetProgressPositionSynch;
begin
  (ProgressWindow as TProgressActionForm).XPosition := IntParam;
end;

procedure TRefreshDBRecordsThread.DoDBkernelEvent;
var
  EventInfo: TEventValues;
begin
  EventInfo.ID := IntParam;
  DBKernel.DoIDEvent(DBEvent_Sender, IntParam, [EventID_Param_Image], EventInfo);
end;

procedure TRefreshDBRecordsThread.DoDBkernelEventRefreshList;
var
  EventInfo: TEventValues;
begin
  DBKernel.DoIDEvent(DBEvent_Sender, IntParam, [EventID_Repaint_ImageList], EventInfo);
end;

procedure TRefreshDBRecordsThread.OnDBKernelEventProcedure(Sender: TDBForm; ID: Integer; Params: TEventFields;
  Value: TEventValues);
begin
  DBEvent_Sender := Sender;
  DBEvent_ID := ID;
  DBEvent_Params := Params;
  DBEvent_Value := Value;
  SynchronizeEx(OnDBKernelEventProcedureSunch);
end;

procedure TRefreshDBRecordsThread.OnDBKernelEventProcedureSunch;
begin
  DBKernel.DoIDEvent(DBEvent_Sender, DBEvent_ID, DBEvent_Params, DBEvent_Value);
end;

end.
