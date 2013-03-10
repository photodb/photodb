unit uDBThread;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Vcl.Forms,

  Dmitry.Utils.System,
  {$IFNDEF EXTERNAL}
  uTranslate,
  uAssociations,
  uPortableDeviceManager,
  {$ENDIF}

  uGOM,
  uDBForm,
  uIME,
  uTime,
  uDBCustomThread;

type
  TDBThread = class(TDBCustomThread)
  private
    FSupportedExt: string;
    FMethod: TThreadMethod;
    FProcedure: TThreadProcedure;
    FCallResult: Boolean;
    FOwnerForm: TDBForm;
    {$IFNDEF EXTERNAL}
    function GetSupportedExt: string;
    {$ENDIF}
    procedure CallMethod;
    procedure CallProcedure;
  protected
    function L(TextToTranslate: string): string; overload;
    function L(TextToTranslate, Scope: string): string; overload;
    function GetThreadID: string; virtual;
    function SynchronizeEx(Method: TThreadMethod): Boolean; overload; virtual;
    function SynchronizeEx(Proc: TThreadProcedure): Boolean; overload; virtual;
    {$IFNDEF EXTERNAL}
    property SupportedExt: string read GetSupportedExt;
    {$ENDIF}
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
  Result := {$IFDEF EXTERNAL}TextToTranslate{$ELSE}TA(TextToTranslate, GetThreadID){$ENDIF};
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
  {$IFNDEF EXTERNAL}
  ThreadCleanUp(ThreadID);
  {$ENDIF}
  inherited;
end;

procedure TDBThread.Execute;
begin
  DisableIME;
end;

{$IFNDEF EXTERNAL}
function TDBThread.GetSupportedExt: string;
begin
  if FSupportedExt = '' then
    FSupportedExt := TFileAssociations.Instance.ExtensionList;

  Result := FSupportedExt;
end;
{$ENDIF}

function TDBThread.GetThreadID: string;
begin
  Result := ClassName;
end;

function TDBThread.L(TextToTranslate, Scope: string): string;
begin
  Result := {$IFDEF EXTERNAL}TextToTranslate{$ELSE}TA(TextToTranslate, Scope){$ENDIF};
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
  CheckSynchronize();
end;

initialization
   CustomWaitProc := FormsWaitProc;

end.
