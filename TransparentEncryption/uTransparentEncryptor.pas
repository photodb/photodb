unit uTransparentEncryptor;

interface

uses
  Windows,
  SysUtils,
  Generics.Collections,
  Classes,
  uMemory,
  SyncObjs,
  uTransparentEncryption;

type
  TSetFilePointerNextHook   = function (hFile: THandle; lDistanceToMove: Longint;
                                        lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
  TSetFilePointerExNextHook = function (hFile: THandle; liDistanceToMove: TLargeInteger;
                                        const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD): BOOL; stdcall;

procedure CloseFileHandle(Handle: THandle);
procedure InitEncryptedFile(FileName: string; hFile: THandle);
procedure ReplaceBufferContent(hFile: THandle; var Buffer; dwCurrentFilePosition: Int64; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD);
function FixFileSize(hFile: THandle; lDistanceToMove: Longint; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD; SeekProc: TSetFilePointerNextHook): DWORD;
function FixFileSizeEx(hFile: THandle; liDistanceToMove: TLargeInteger; const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD; SeekExProc: TSetFilePointerExNextHook): BOOL;
procedure StartLib;
procedure StopLib;
procedure AddFileMapping(FileHandle, MappingHandle: THandle);
function IsInternalFileMapping(MappingHandle: THandle): Boolean;
function GetInternalFileMapping(hFileMappingObject: THandle; dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T): Pointer;
function IsEncryptedHandle(FileHandle: THandle): Boolean;

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

  SyncObj.Enter;
  try
    if not IsInternalFileMapping(hFileMappingObject) then
      Exit;

    FileHandle := FFileMappings[hFileMappingObject];

    if FData.ContainsKey(FileHandle) then
    begin
      Int64Rec(Pos).Hi := dwFileOffsetHigh;
      Int64Rec(Pos).Lo := dwFileOffsetLow;

      MS := FData[FileHandle];
      Result := MS.GetBlock(dwFileOffsetLow, dwNumberOfBytesToMap);
    end;
  finally
    SyncObj.Leave;
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

procedure InitEncryptedFile(FileName: string; hFile: THandle);
var
  MS: TEncryptedFile;
begin
  SyncObj.Enter;
  try
    if hFile = Windows.INVALID_HANDLE_VALUE then
      Exit;

    if FData.ContainsKey(hFile) then
      Exit;

    MS := TEncryptedFile.Create(hFile);
    try
      if MS.CanDecryptWithPassword('123') then
      begin
        FData.Add(hFile, MS);
        MS := nil;
      end;
    finally
      F(MS);
    end;
  finally
    SyncObj.Leave;
  end;
end;

function FixFileSize(hFile: THandle; lDistanceToMove: Longint; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD; SeekProc: TSetFilePointerNextHook): DWORD;
var
  dwCurrentFilePosition: Int64;
  MS: TEncryptedFile;
begin
  Result := SeekProc(hFile, lDistanceToMove, lpDistanceToMoveHigh, dwMoveMethod);

  if SyncObj = nil then
    Exit;

  SyncObj.Enter;
  try

    if not FData.ContainsKey(hFile) then
      Exit;

    dwCurrentFilePosition := FileSeek(hFile, 0, FILE_CURRENT);

    MS := FData[hFile];

    if dwCurrentFilePosition > MS.Size then
    begin
      dwCurrentFilePosition := MS.Size - 1;

      Result := SetFilePointer(hFile, Int64Rec(dwCurrentFilePosition).Lo, @Int64Rec(dwCurrentFilePosition).Hi, FILE_BEGIN);

      PWord(lpDistanceToMoveHigh)^ := Int64Rec(dwCurrentFilePosition).Hi;
    end;

  finally
    SyncObj.Leave;
  end;
end;

function FixFileSizeEx(hFile: THandle; liDistanceToMove: TLargeInteger; const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD; SeekExProc: TSetFilePointerExNextHook): BOOL;
var
  dwCurrentFilePosition: Int64;
  MS: TEncryptedFile;
begin
  Result := SeekExProc(hFile, liDistanceToMove, lpNewFilePointer, dwMoveMethod);

  if SyncObj = nil then
    Exit;

  SyncObj.Enter;
  try
    if not FData.ContainsKey(hFile) then
      Exit;

    dwCurrentFilePosition := FileSeek(hFile, 0, FILE_CURRENT);

    MS := FData[hFile];

    if dwCurrentFilePosition > MS.Size then
    begin
      dwCurrentFilePosition := MS.Size - 1;

      SetFilePointerEx(hFile, dwCurrentFilePosition, lpNewFilePointer, FILE_BEGIN);
    end;

  finally
    SyncObj.Leave;
  end;
end;

procedure ReplaceBufferContent(hFile: THandle; var Buffer; dwCurrentFilePosition: Int64; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD);
var
  MS: TEncryptedFile;
  //Size: NativeInt;
begin
  if SyncObj = nil then
    Exit;

  SyncObj.Enter;
  try
    if not FData.ContainsKey(hFile) then
      Exit;

    MS := FData[hFile];

    //TODO: fix file size to avoid this
    {Size := MS.Size;
    if dwCurrentFilePosition + lpNumberOfBytesRead > MS.Size then
    begin
      lpNumberOfBytesRead := MS.Size - dwCurrentFilePosition - 1;
      FileSeek(hFile, MS.Size - 1, FILE_BEGIN);
    end;  }

    MS.ReadBlock(Buffer, dwCurrentFilePosition, lpNumberOfBytesRead);
  finally
    SyncObj.Leave;
  end;
end;

procedure StartLib;
begin
  SyncObj := TCriticalSection.Create;
  FData := TDictionary<Integer, TEncryptedFile>.Create;
  FFileMappings := TDictionary<Integer, Integer>.Create;
end;

procedure StopLib;
begin
  F(SyncObj);
  F(FFileMappings);
end;

end.
