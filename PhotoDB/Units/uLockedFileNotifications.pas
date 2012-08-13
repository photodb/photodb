unit uLockedFileNotifications;

interface

uses
  Classes,
  SyncObjs,
  SysUtils,
  uMemory;

type
  TLockedFile = class(TObject)
  public
    DateOfUnLock: TDateTime;
    FileName: string;
  end;

  TLockFiles = class(TObject)
  private
    FFiles: TList;
    FSync: TCriticalSection;
  public
    constructor Create;
    class function Instance : TLockFiles;
    destructor Destroy; override;
    function AddLockedFile(FileName: string; LifeTimeMs: Integer): TLockedFile;
    function RemoveLockedFile(FileName: string): Boolean;
    function IsFileLocked(FileName: string): Boolean;
  end;

implementation

var
  LockedFiles : TLockFiles = nil;

{ TLockFiles }

function TLockFiles.AddLockedFile(FileName: string; LifeTimeMs: Integer): TLockedFile;
var
  I: Integer;
  FFile: TLockedFile;
begin
  FileName := AnsiLowerCase(FileName);
  FSync.Enter;
  try
    for I := FFiles.Count - 1 downto 0 do
    begin
      FFile := TLockedFile(FFiles[I]);
      if FFile.FileName = FileName then
      begin
        FFile.DateOfUnLock := Now + LifeTimeMs / (1000 * 60 * 60 * 24);
        Result := FFile;
        Exit;
      end;
    end;
    Result := TLockedFile.Create;
    Result.FileName := FileName;
    Result.DateOfUnLock := Now + LifeTimeMs / (1000 * 60 * 60 * 24);
    FFiles.Add(Result);
  finally
    FSync.Leave;
  end;
end;

constructor TLockFiles.Create;
begin
  FFiles := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TLockFiles.Destroy;
begin
  FreeList(FFiles);
  F(FSync);
  inherited;
end;

class function TLockFiles.Instance: TLockFiles;
begin
  if LockedFiles = nil then
    LockedFiles := TLockFiles.Create;

  Result := LockedFiles;
end;

function TLockFiles.IsFileLocked(FileName: string): Boolean;
var
  I: Integer;
  FFile: TLockedFile;
  ANow: TDateTime;
begin
  Result := False;
  ANow := Now;
  FileName := AnsiLowerCase(FileName);
  FSync.Enter;
  try
    for I := FFiles.Count - 1 downto 0 do
    begin
      FFile := TLockedFile(FFiles[I]);
      if FFile.DateOfUnLock < ANow then
      begin
        FFiles.Remove(FFile);
        F(FFile);
        Continue;
      end;
      if AnsiLowerCase(FFile.FileName) = FileName then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TLockFiles.RemoveLockedFile(FileName: string): Boolean;
var
  I: Integer;
  FFile: TLockedFile;
begin
  Result := False;
  FileName := AnsiLowerCase(FileName);
  FSync.Enter;
  try
    for I := FFiles.Count - 1 downto 0 do
    begin
      FFile := TLockedFile(FFiles[I]);
      if AnsiLowerCase(FFile.FileName) = FileName then
      begin
        FFiles.Remove(FFile);
        F(FFile);
        Result := True;
        Break;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

initialization
finalization
  F(LockedFiles);

end.
