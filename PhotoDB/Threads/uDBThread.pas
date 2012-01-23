unit uDBThread;

interface

uses
  Windows, Classes, uTranslate, uAssociations, uMemory, uGOM, SyncObjs, Forms,
  uDBForm, uIME, uTime, SysUtils, uSysUtils, uDBCustomThread;

type
  TDBThread = class(TDBCustomThread)
  private
    FSupportedExt: string;
    FMethod: TThreadMethod;
    FProcedure: TThreadProcedure;
    FCallResult: Boolean;
    FOwnerForm: TDBForm;
    function GetSupportedExt: string;
    procedure CallMethod;
    procedure CallProcedure;
  protected
    function L(TextToTranslate: string): string; overload;
    function L(TextToTranslate, Scope: string): string; overload;
    function GetThreadID: string; virtual;
    function SynchronizeEx(Method: TThreadMethod): Boolean; overload; virtual;
    function SynchronizeEx(Proc: TThreadProcedure): Boolean; overload; virtual;
    property SupportedExt: string read GetSupportedExt;
    property OwnerForm: TDBForm read FOwnerForm;
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TDBForm; CreateSuspended: Boolean);
    destructor Destroy; override;
  end;

implementation

{ TThreadEx }

function TDBThread.L(TextToTranslate: string): string;
begin
  Result := TA(TextToTranslate, GetThreadID);
end;

procedure TDBThread.CallMethod;
begin
  FCallResult := GOM.IsObj(FOwnerForm) or (FOwnerForm = nil);
  if FCallResult then
    FMethod
  else
    Terminate;
end;

procedure TDBThread.CallProcedure;
begin
  FCallResult := GOM.IsObj(FOwnerForm) or (FOwnerForm = nil);
  if FCallResult then
    FProcedure
  else
    Terminate;
end;

constructor TDBThread.Create(OwnerForm: TDBForm; CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FOwnerForm := OwnerForm;
  GOM.AddObj(Self);
end;

destructor TDBThread.Destroy;
begin
  GOM.RemoveObj(Self);
  inherited;
end;

procedure TDBThread.Execute;
begin
  DisableIME;
end;

function TDBThread.GetSupportedExt: string;
begin
  if FSupportedExt = '' then
    FSupportedExt := TFileAssociations.Instance.ExtensionList;

  Result := FSupportedExt;
end;

function TDBThread.GetThreadID: string;
begin
  Result := ClassName;
end;

function TDBThread.L(TextToTranslate, Scope: string): string;
begin
  Result := TA(TextToTranslate, Scope);
end;

function TDBThread.SynchronizeEx(Proc: TThreadProcedure): Boolean;
begin
  FProcedure := Proc;
  FCallResult := False;
  Synchronize(CallProcedure);
  Result := FCallResult;
end;

function TDBThread.SynchronizeEx(Method: TThreadMethod): Boolean;
begin
  FMethod := Method;
  FCallResult := False;
  Synchronize(CallMethod);
  Result := FCallResult;
end;

procedure FormsWaitProc;
begin
  Application.ProcessMessages;
end;

initialization
   CustomWaitProc := FormsWaitProc;

end.
