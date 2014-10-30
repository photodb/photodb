unit uRWLock;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.SyncObjs,
  System.SysUtils,

  Dmitry.Utils.System;

type
  TRWLock = class(TInterfacedObject, IReadWriteSync)
    procedure BeginRead; virtual; abstract;
    procedure EndRead; virtual; abstract;
    function BeginWrite: Boolean; virtual; abstract;
    procedure EndWrite; virtual; abstract;
  end;

  TFastRWLock = class(TRWLock)
  private
    FLock: Pointer;
  public
    constructor Create;
    procedure BeginRead; override;
    procedure EndRead; override;
    function BeginWrite: Boolean; override;
    procedure EndWrite; override;
  end;

  TFailSafeRWLock = class(TRWLock)
  private
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginRead; override;
    procedure EndRead; override;
    function BeginWrite: Boolean; override;
    procedure EndWrite; override;
  end;

function CreateRWLock: IReadWriteSync;

implementation

var
  _createRWLock: function: IReadWriteSync = nil;

procedure InitializeSRWLock(out P: Pointer); stdcall;
  external 'kernel32.dll' name 'InitializeSRWLock' delayed;
procedure AcquireSRWLockShared(var P: Pointer); stdcall;
  external 'kernel32.dll' name 'AcquireSRWLockShared' delayed;
procedure ReleaseSRWLockShared(var P: Pointer); stdcall;
  external 'kernel32.dll' name 'ReleaseSRWLockShared' delayed;

procedure AcquireSRWLockExclusive(var P: Pointer); stdcall;
  external 'kernel32.dll' name 'AcquireSRWLockExclusive' delayed;
procedure ReleaseSRWLockExclusive(var P: Pointer); stdcall;
  external 'kernel32.dll' name 'ReleaseSRWLockExclusive' delayed;

function CreateFastRWLock: IReadWriteSync;
begin
  Result := TFastRWLock.Create;
end;

function CreateSafeRWLock: IReadWriteSync;
begin
  Result := TFailSafeRWLock.Create;
end;

function CreateRWLock: IReadWriteSync;
begin
  if not Assigned(_createRWLock) then
  begin
    if IsWindowsVista then
      _createRWLock := CreateFastRWLock
    else
      _createRWLock := CreateSafeRWLock;
  end;
  Result := _createRWLock();
end;

{ TFastRWLock }

procedure TFastRWLock.BeginRead;
begin
  AcquireSRWLockShared(FLock);
end;

procedure TFastRWLock.EndRead;
begin
  ReleaseSRWLockShared(FLock);
end;

function TFastRWLock.BeginWrite: Boolean;
begin
  AcquireSRWLockExclusive(FLock);
  Result := True;
end;

constructor TFastRWLock.Create;
begin
  InitializeSRWLock(FLock);
end;

procedure TFastRWLock.EndWrite;
begin
  ReleaseSRWLockExclusive(FLock);
end;

{ TFailSafeRWLock }

procedure TFailSafeRWLock.BeginRead;
begin
  FLock.Enter;
end;

function TFailSafeRWLock.BeginWrite: Boolean;
begin
  FLock.Enter;
  Result := True;
end;

constructor TFailSafeRWLock.Create;
begin
end;

destructor TFailSafeRWLock.Destroy;
begin
  FLock.Free;
end;

procedure TFailSafeRWLock.EndRead;
begin
  FLock.Leave;
end;

procedure TFailSafeRWLock.EndWrite;
begin
  FLock.Leave;
end;

end.
