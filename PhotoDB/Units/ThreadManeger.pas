unit ThreadManeger;

interface

Uses Windows, Classes, ExtCtrls, Messages, Controls, Forms, Dolphin_DB;


Const

 Thread_Type_Searching            = 0;
 Thread_Type_Normal               = 1;
 Thread_Type_Explorer_Loading     = 2;
 Thread_Type_Explorer_Watching    = 3;
 Thread_Type_Timer                = 4;
 Thread_Type_Other                = 5;

Type

TDBThreadInfo = record
 Handle : THandle;
 Type_ : Integer;
 OwnerHandle : THandle;
 End;

 TDBThreadsInfo = Array of TDBThreadInfo;


TThreadManeger = Class(TObject)
   Private
    FThreads : TDBThreadsInfo;
   Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure AddThread(Thread : TDBThreadInfo);
    Procedure RemoveThread(Thread : TDBThreadInfo);
    Property Threads : TDBThreadsInfo Read FThreads;
    Procedure TerminateThreadsByOwner(Owner : THandle);
    Procedure TerminateThreadW(Handle_ : THandle);
    Procedure TerminateAll;
    Procedure ExitW(Sender : TObject);
    Procedure TerminateThreads(Owner : THandle; Type_ : Integer);
   published
  end;

type
  TThreadTimer = class(TThread)
  private
   FNotify : TNotifyEvent;
  protected
   procedure Execute; override;
   procedure Terminate;
   procedure RegisterThread;
   procedure UnRegisterThread;
  public
   constructor Create(CreateSuspennded: Boolean;  OnNotify : TNotifyEvent);
  end;

var DBThreadManeger: TThreadManeger;

    CurrentTick, LastTick : Integer;
    TimerTerminated, TimerWorking : Boolean;
    TimerTerminateAction : TTemtinatedAction;

Const
  Delay = 200000;

implementation

uses FormManegerUnit;

{ TThreadManeger }

procedure TThreadManeger.AddThread(Thread: TDBThreadInfo);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FThreads)-1 do
 if FThreads[i].Handle=Thread.Handle then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FThreads,Length(FThreads)+1);
  FThreads[Length(FThreads)-1]:=Thread;
 end;
end;

constructor TThreadManeger.Create;
begin
 SetLength(FThreads,0);
 TThreadTimer.Create(False,ExitW);
end;

destructor TThreadManeger.Destroy;
begin
 SetLength(FThreads,0);
 inherited;
end;

procedure TThreadManeger.ExitW(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TThreadManeger.RemoveThread(Thread: TDBThreadInfo);
var
  i, j : integer;
begin
 For i:=0 to Length(FThreads)-1 do
 if FThreads[i].Handle=Thread.Handle then
 begin
  For j:=i to Length(FThreads)-2 do
  FThreads[j]:=FThreads[j+1];
  SetLength(FThreads,Length(FThreads)-1);
  break;
 end;
end;

procedure TThreadManeger.TerminateThreadW(Handle_: THandle);
Var
  i, j: Integer;
begin
 For i:=0 to Length(FThreads)-1 do
 if FThreads[i].Handle=Handle_ then
 begin
  TerminateThread(FThreads[i].Handle,0);
  FThreads[i].Handle:=0;
  FThreads[i].OwnerHandle:=0;
 end;
 For i:=Length(FThreads)-1 Downto 0 do
 If FThreads[i].Handle=0 then
 begin
  For j:=i to Length(FThreads)-2 do
  FThreads[j]:=FThreads[j+1];
  SetLength(FThreads,Length(FThreads)-1);
 end;
end;

procedure TThreadManeger.TerminateThreadsByOwner(Owner: THandle);
Var
  i, j: Integer;
begin
 For i:=0 to Length(FThreads)-1 do
 if FThreads[i].OwnerHandle=Owner then
 begin
  TerminateThread(FThreads[i].Handle,0);
  FThreads[i].Handle:=0;
  FThreads[i].OwnerHandle:=0;
 end;
 For i:=Length(FThreads)-1 Downto 0 do
 If FThreads[i].Handle=0 then
 begin
  For j:=i to Length(FThreads)-2 do
  FThreads[j]:=FThreads[j+1];
  SetLength(FThreads,Length(FThreads)-1);
 end;
end;

procedure TThreadManeger.TerminateAll;
var
  i : Integer;
begin
 for i:=0 to Length(FThreads)-1 do
 begin
  TerminateThread(FThreads[i].Handle,0);
 end;
 SetLength(FThreads,0);
end;

procedure TThreadManeger.TerminateThreads(Owner: THandle; Type_: Integer);
Var
  i, j: Integer;
begin
 For i:=0 to Length(FThreads)-1 do
 if (FThreads[i].OwnerHandle=Owner) and (FThreads[i].Type_=Type_) then
 begin
  TerminateThread(FThreads[i].Handle,0);
  FThreads[i].Handle:=0;
  FThreads[i].OwnerHandle:=0;
 end;
 For i:=Length(FThreads)-1 Downto 0 do
 If FThreads[i].Handle=0 then
 begin
  For j:=i to Length(FThreads)-2 do
  FThreads[j]:=FThreads[j+1];
  if length(FThreads)>0 then
  SetLength(FThreads,Length(FThreads)-1);
 end;
end;

{ TThreadTimer }

constructor TThreadTimer.Create(
  CreateSuspennded: Boolean; OnNotify: TNotifyEvent);
begin
  inherited Create(True);
  FNotify:=OnNotify;
  If not CreateSuspennded then Resume;
end;

procedure TThreadTimer.Execute;
begin
 inherited;
 if DBInDebug then exit;
 FreeOnTerminate:=true;
 Synchronize(RegisterThread);
 CurrentTick := GetTickCount;
 LastTick := GetTickCount;
 Repeat
  if CurrentTick - LastTick > Delay then
  Synchronize(Terminate);
  LastTick:=CurrentTick;
  CurrentTick:=GetTickCount;
  sleep(100);
  if TimerTerminated then break;
  if DBTerminating then break;
 Until False;
 Synchronize(UnRegisterThread);
end;

procedure TThreadTimer.RegisterThread;
Var
  Info : TDBThreadInfo;
begin
 Info.Handle:=ThreadID;
 Info.Type_:=Thread_Type_Timer;
 Info.OwnerHandle:=0;
 DBThreadManeger.AddThread(Info);
 TimerTerminated:=false;
 TimerWorking:=true;
 TimerTerminateAction.TerminatedPointer:=@TimerTerminated;
 TimerTerminateAction.TerminatedVerify:=@TimerWorking;
 TimerTerminateAction.Options:=TA_INFORM_AND_NT;
 TimerTerminateAction.Owner:=nil;
 if FormManager<>nil then
 FormManager.RegisterActionCanTerminating(TimerTerminateAction);
end;

procedure TThreadTimer.Terminate;
begin
 If Assigned(FNotify) then FNotify(Self);
end;

procedure TThreadTimer.UnRegisterThread;
Var
  Info : TDBThreadInfo;
begin
 TimerWorking:=false;
 Info.Handle:=ThreadID;
 Info.Type_:=Thread_Type_Timer;
 Info.OwnerHandle:=0;
 DBThreadManeger.RemoveThread(Info);
end;

initialization

if ThisFileInstalled or DBInDebug or Emulation or GetDBViewMode then
DBThreadManeger:= TThreadManeger.Create;

Finalization

if ThisFileInstalled then
DBThreadManeger.Free;

end.
