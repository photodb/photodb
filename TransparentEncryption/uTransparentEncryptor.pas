unit uTransparentEncryptor;

interface

uses
  Windows,
  SysUtils,
  Generics.Collections,
  uMemory,
  SyncObjs,
  uWinApiRuntime,
  uTransparentEncryption;

procedure CloseFileHandle(Handle: THandle);
procedure InitEncryptedFile(FileName: string; hFile: THandle; AsyncHandle: Boolean);
procedure ReplaceBufferContent(hFile: THandle; var Buffer; dwCurrentFilePosition: Int64; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped; Result: PBOOL);
function FixFileSize(hFile: THandle; lDistanceToMove: DWORD; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD; SeekProc: TSetFilePointerNextHook): DWORD;
function FixFileSizeEx(hFile: THandle; liDistanceToMove: TLargeInteger; const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD; SeekExProc: TSetFilePointerExNextHook): BOOL;
procedure StartLib;
procedure StopLib;
procedure AddFileMapping(FileHandle, MappingHandle: THandle);
function IsInternalFileMapping(MappingHandle: THandle): Boolean;
function GetInternalFileMapping(hFileMappingObject: THandle; dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T): Pointer;
function IsEncryptedHandle(FileHandle: THandle): Boolean;

var
  IsHookStarted: Boolean;

implementation

var
  SyncObj: TCriticalSection = nil;
  FFileMappings: TDictionary<Integer, Integer> = nil;
  FData: TDictionary<Integer, TEncryptedFile> = nil;

procedure AddFileMapping(FileHandle, MappingHandle: THandle);
begin
  if SyncObj = nil then
    Exit;

  SyncObj.Enter;
  try
    FFileMappings.Add(MappingHandle, FileHandle);
  finally
    SyncObj.Leave;
  end;
end;

function IsInternalFileMapping(MappingHandle: THandle): Boolean;
begin
  if SyncObj = nil then
    Exit(False);

  SyncObj.Enter;
  try
    Result := FFileMappings.ContainsKey(MappingHandle);
  finally
    SyncObj.Leave;
  end;
end;

function GetInternalFileMapping(hFileMappingObject: THandle; dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T): Pointer;
var
  FileHandle: THandle;
  Pos: Int64;
  MS: TEncryptedFile;
begin
  Result := nil;

  if SyncObj = nil then
    Exit;

  if not IsInternalFileMapping(hFileMappingObject) then
    Exit;

  FileHandle := FFileMappings[hFileMappingObject];

  if FData.ContainsKey(FileHandle) then
  begin
    Int64Rec(Pos).Hi := dwFileOffsetHigh;
    Int64Rec(Pos).Lo := dwFileOffsetLow;

    SyncObj.Enter;
    try
      MS := FData[FileHandle];
    finally
      SyncObj.Leave;
    end;

    Result := MS.GetBlock(dwFileOffsetLow, dwNumberOfBytesToMap);
  end;
end;

function IsEncryptedHandle(FileHandle: THandle): Boolean;
begin
  if SyncObj = nil then
    Exit(False);

  SyncObj.Enter;
  try
    Result := FData.ContainsKey(FileHandle);
  finally
    SyncObj.Leave;
  end;
end;

procedure CloseFileHandle(Handle: THandle);
var
  MS: TEncryptedFile;
begin
  if SyncObj = nil then
    Exit;

  SyncObj.Enter;
  try
    if FData.ContainsKey(Handle) then
    begin
      MS := FData[Handle];
      FData.Remove(Handle);
      F(MS);
    end;
  finally
    SyncObj.Leave;
  end;
end;

procedure InitEncryptedFile(FileName: string; hFile: THandle; AsyncHandle: Boolean);
var
  MS: TEncryptedFile;
begin
  if hFile = Windows.INVALID_HANDLE_VALUE then
    Exit;

  if FData.ContainsKey(hFile) then
    Exit;

  MS := TEncryptedFile.Create(hFile, FileName, AsyncHandle);
  try
    if MS.CanDecryptWithPasswordRequest(FileName) then
    begin
      SyncObj.Enter;
      try
        FData.Add(hFile, MS);
        MS := nil;
      finally
        SyncObj.Leave;
      end;
    end;
  finally
    F(MS);
  end;
end;

function FixFileSize(hFile: THandle; lDistanceToMove: DWORD; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD; SeekProc: TSetFilePointerNextHook): DWORD;
var
  MS: TEncryptedFile;
  LastError: Cardinal;
begin
  Result := SeekProc(hFile, lDistanceToMove, lpDistanceToMoveHigh, dwMoveMethod);
  LastError := GetLastError;

  if SyncObj = nil then
    Exit;

  if not FData.ContainsKey(hFile) then
    Exit;

  if dwMoveMethod = FILE_END then
  begin
    SyncObj.Enter;
    try
      MS := FData[hFile];
    finally
      SyncObj.Leave;
    end;

    PDWORD(lpDistanceToMoveHigh)^ := 0;
    lDistanceToMove := MS.HeaderSize;
    Result := SeekProc(hFile, lDistanceToMove, lpDistanceToMoveHigh, FILE_END);
  end;

  SetLastError(LastError);
end;

function FixFileSizeEx(hFile: THandle; liDistanceToMove: TLargeInteger; const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD; SeekExProc: TSetFilePointerExNextHook): BOOL;
var
  MS: TEncryptedFile;
  LastError: Cardinal;
begin
  Result := SeekExProc(hFile, liDistanceToMove, lpNewFilePointer, dwMoveMethod);
  LastError := GetLastError;

  if SyncObj = nil then
    Exit;

  if not FData.ContainsKey(hFile) then
    Exit;

  if dwMoveMethod = FILE_END then
  begin
    SyncObj.Enter;
    try
      MS := FData[hFile];
    finally
      SyncObj.Leave;
    end;
    liDistanceToMove := MS.HeaderSize;
    Result := SeekExProc(hFile, liDistanceToMove, lpNewFilePointer, FILE_END);
  end;

  SetLastError(LastError);
end;

procedure ReplaceBufferContent(hFile: THandle; var Buffer; dwCurrentFilePosition: Int64; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped; Result: PBOOL);
var
  MS: TEncryptedFile;
  Size: Int64;
begin
  if SyncObj = nil then
    Exit;

  SyncObj.Enter;
  try
    if not FData.ContainsKey(hFile) then
      Exit;

    MS := FData[hFile];
  finally
    SyncObj.Leave;
  end;

  if not Assigned(lpOverlapped) then
  begin
    Size := MS.Size;
    if dwCurrentFilePosition + lpNumberOfBytesRead > Size then
    begin
      if Size > dwCurrentFilePosition then
        lpNumberOfBytesRead := MS.Size - dwCurrentFilePosition
      else
        lpNumberOfBytesRead := 0;

      FileSeek(hFile, MS.HeaderSize, FILE_END);
      //if Assigned(Result) then
      //  Result^ := False;
    end;
  end;

  MS.ReadBlock(Buffer, dwCurrentFilePosition, nNumberOfBytesToRead, lpOverlapped);
end;

procedure StartLib;
begin
  SyncObj := TCriticalSection.Create;
  FData := TDictionary<Integer, TEncryptedFile>.Create;
  FFileMappings := TDictionary<Integer, Integer>.Create;
  IsHookStarted := True;
end;

procedure StopLib;
var
  Pair: TPair<Integer, TEncryptedFile>;
begin
  IsHookStarted := False;
  F(SyncObj);
  F(FFileMappings);
  for Pair in FData do
    Pair.Value.Free;
  F(FData);
end;

end.
