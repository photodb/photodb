unit uTransparentEncryption;

interface

uses
  Classes,
  Windows,
  SysUtils,
  StrUtils,
  SyncObjs,
  Math,
  win32Crc,
  uConstants,
  uErrors,
  uMemory,
  uSysUtils,
  uFileUtils,
  uStrongCrypt,
  uLockedFileNotifications,
  DECUtil,
  DECHash,
  DECCipher;

type
  TMemoryBlock = class
    Memory: Pointer;
    Size: Integer;
    Index: Int64;
  end;

  TEncryptedFile = class(TObject)
  private
    FSync: TCriticalSection;
    FHandle: THandle;
    FFileBlocks: TList;
    FMemoryBlocks: TList;
    FBlockSize: Int64;
    FMemorySize: Int64;
    FMemoryLimit: Int64;
    FHeaderSize: Int64;
    FContentSize: Int64;
    FSalt: Binary;
    FChipper: TDECCipherClass;
    FIsDecrypted: Boolean;
    FPassword: string;
    procedure DecodeDataBlock(const Source; var Dest; DataSize: Integer);
    function GetSize: Int64;
    function GetBlockByIndex(Index: Int64): TMemoryBlock;
  public
    constructor Create(Handle: THandle);
    destructor Destroy; override;
    function CanDecryptWithPasswordRequest(FileName: string): Boolean;
    procedure ReadBlock(const Block; BlockPosition: Int64; BlockSize: Int64);
    function GetBlock(BlockPosition: Int64; BlockSize: Int64): Pointer;
    procedure FreeBlock(Block: Pointer);
    property Size: Int64 read GetSize;
    property Blocks[Index: Int64]: TMemoryBlock read GetBlockByIndex;
  end;

procedure WriteEnryptHeaderV3(Stream: TStream; Src: TStream;
  BlockSize32k: Byte; Password: string; var Seed: Binary; ACipher: TDECCipherClass);

procedure EncryptStreamEx(S, D: TStream; Password: string;
                          ACipher: TDECCipherClass; Progress: TSimpleEncryptProgress = nil);
function TransparentEncryptFileEx(FileName: string; Password: string;
                                  ACipher: TDECCipherClass = nil; Progress: TFileProgress = nil): Integer;
function DecryptStreamEx(S, D: TStream; Password: string; Seed: Binary; FileSize: Int64;
                         AChipper: TDECCipherClass; BlockSize32k: Byte; Progress: TSimpleEncryptProgress = nil): Boolean;

function ValidEnryptFileEx(FileName: String): Boolean;
function ValidEncryptFileExHandle(FileHandle: THandle): Boolean;
function CanBeTransparentEncryptedFile(FileName: string): Boolean;
function TransparentDecryptFileEx(FileName: string; Password: string;
                                  Progress: TFileProgress = nil): Integer;

implementation

function CanBeTransparentEncryptedFile(FileName: string): Boolean;
begin
  Result := True;
end;

procedure WriteEnryptHeaderV3(Stream: TStream; Src: TStream;
  BlockSize32k: Byte; Password: string; var Seed: Binary; ACipher: TDECCipherClass);
var
  EncryptHeader: TEncryptedFileHeader;
  EncryptHeaderV1: TEncryptFileHeaderExV1;
begin
  FillChar(EncryptHeader, SizeOf(EncryptHeader), #0);
  EncryptHeader.ID := PhotoDBFileHeaderID;
  EncryptHeader.Version := ENCRYPT_FILE_VERSION_TRANSPARENT;
  EncryptHeader.DBVersion := ReleaseNumber;
  Stream.Write(EncryptHeader, SizeOf(EncryptHeader));

  FillChar(EncryptHeaderV1, SizeOf(EncryptHeaderV1), #0);
  Randomize;
  Seed := RandomBinary(16);
  EncryptHeaderV1.Seed := ConvertSeed(Seed);
  EncryptHeaderV1.Version := 1;
  EncryptHeaderV1.Algorith := ACipher.Identity;
  EncryptHeaderV1.BlockSize32k := BlockSize32k;
  EncryptHeaderV1.FileSize := Src.Size;
  EncryptHeaderV1.ProgramVersion := GetExeVersion(ParamStr(0));
  CalcStringCRC32(Password, EncryptHeaderV1.PassCRC);
  EncryptHeaderV1.Displacement := 0;
  Stream.Write(EncryptHeaderV1, SizeOf(EncryptHeaderV1));
end;

procedure EncryptStreamEx(S, D: TStream; Password: string;
                         ACipher: TDECCipherClass; Progress: TSimpleEncryptProgress = nil);
var
  Seed: Binary;
  BlockSize32k: Byte;
  Size, SizeToEncrypt: Int64;
begin
  BlockSize32k := 1;
  ACipher := ValidCipher(ACipher);
  WriteEnryptHeaderV3(D, S, BlockSize32k, Password, Seed, ACipher);

  Size := S.Size;
  while S.Position < Size do
  begin
    SizeToEncrypt := BlockSize32k * Encrypt32kBlockSize;
    if S.Position + SizeToEncrypt >= Size then
      SizeToEncrypt := Size - S.Position;

    CryptStreamV2(S, D, Password, Seed, nil, cmCTSx, nil, SizeToEncrypt);
    if Assigned(Progress) then
      Progress(Size, S.Position);
  end;
end;

function DecryptStreamEx(S, D: TStream; Password: string;
                         Seed: Binary; FileSize: Int64;
                         AChipper: TDECCipherClass; BlockSize32k: Byte; Progress: TSimpleEncryptProgress = nil): Boolean;
var
  StartPos, SizeToEncrypt: Int64;
begin
  StartPos := S.Position;

  while S.Position - StartPos < FileSize do
  begin
    SizeToEncrypt := BlockSize32k * Encrypt32kBlockSize;
    if S.Position + SizeToEncrypt - StartPos >= FileSize then
      SizeToEncrypt := FileSize - (S.Position - StartPos);

    DeCryptStreamV2(S, D, Password, Seed, SizeToEncrypt, AChipper, cmCTSx, nil);
    if Assigned(Progress) then
      Progress(FileSize, S.Position - StartPos);
  end;

  Result := True;
end;

function TransparentEncryptFileEx(FileName: string; Password: string;
  ACipher: TDECCipherClass = nil; Progress: TFileProgress = nil): Integer;
var
  SFS, DFS: TFileStream;
  FA: Integer;
  FileSize: Int64;
  EncryptHeader: TEncryptedFileHeader;
  TmpFileName, TmpErasedFile: string;
begin
  StrongCryptInit;

  try
    TryOpenFSForRead(SFS, FileName, DelayReadFileOperation);
    if SFS = nil then
    begin
      Result := CRYPT_RESULT_ERROR_READING_FILE;
      Exit;
    end;

    try
      FileSize := SFS.Size;

      SFS.Read(EncryptHeader, SizeOf(EncryptHeader));
      if EncryptHeader.ID = PhotoDBFileHeaderID then
      begin
        Result := CRYPT_RESULT_ALREADY_CRYPT;
        Exit;
      end;

      TmpFileName := FileName + '.tmp';
      TmpErasedFile := FileName + '.erased';

      SFS.Seek(0, SoFromBeginning);

      try
        DFS := TFileStream.Create(TmpFileName, FmOpenWrite or FmCreate);
        try
          EncryptStreamEx(SFS, DFS, Password, ACipher,
            procedure(BytesTotal, BytesDone: Int64)
            begin
              if Assigned(Progress) then     //encryption is the first part of operation
                Progress(FileName, FileSize, BytesDone div 2);
            end
          );
        finally
          F(DFS);
        end;
      except
        Result := CRYPT_RESULT_ERROR_WRITING_FILE;
        Exit;
      end;

    finally
      F(SFS);
    end;
  except
    Result := CRYPT_RESULT_ERROR_READING_FILE;
    Exit;
  end;

  FA := FileGetAttr(FileName);
  ResetFileAttributes(FileName, FA);

  TLockFiles.Instance.AddLockedFile(FileName, 10000);
  TLockFiles.Instance.AddLockedFile(TmpErasedFile, 10000);
  try
    if RenameFile(FileName, TmpErasedFile) then
      if RenameFile(TmpFileName, FileName) then
      begin
        WipeFile(TmpErasedFile, 1,
          procedure(FileName: string; BytesTotal, BytesDone: Int64)
          begin
            if Assigned(Progress) then     //erase is the second part of operation
              Progress(FileName, FileSize, FileSize div 2 + BytesDone div 2);
          end
        );
        TLockFiles.Instance.RemoveLockedFile(TmpErasedFile);
        DeleteFile(TmpErasedFile);
      end;
  finally
    TLockFiles.Instance.RemoveLockedFile(FileName);
    TLockFiles.Instance.RemoveLockedFile(TmpErasedFile);
  end;

  FileSetAttr(FileName, FA);
  Result := CRYPT_RESULT_OK;
end;

function TransparentDecryptFileEx(FileName: string; Password: string;
                                  Progress: TFileProgress = nil): Integer;
var
  SFS, DFS: TFileStream;
  FA: Integer;
  EncryptHeader: TEncryptedFileHeader;
  EncryptHeaderExV1: TEncryptFileHeaderExV1;
  TmpFileName, TmpErasedFile: string;
  ACipher: TDECCipherClass;
begin
  StrongCryptInit;

  try
    TryOpenFSForRead(SFS, FileName, DelayReadFileOperation);
    if SFS = nil then
      Exit(CRYPT_RESULT_ERROR_READING_FILE);

    try
      SFS.Read(EncryptHeader, SizeOf(EncryptHeader));
      if EncryptHeader.ID <> PhotoDBFileHeaderID then
        Exit(CRYPT_RESULT_ALREADY_DECRYPTED);
      if EncryptHeader.Version <> ENCRYPT_FILE_VERSION_TRANSPARENT then
        Exit(CRYPT_RESULT_UNSUPORTED_VERSION);

      SFS.Read(EncryptHeaderExV1, SizeOf(EncryptHeaderExV1));

      ACipher := CipherByIdentity(EncryptHeaderExV1.Algorith);
      if ACipher = nil then
        Exit(CRYPT_RESULT_UNSUPORTED_VERSION);

      TmpFileName := FileName + '.tmp';
      TmpErasedFile := FileName + '.erased';

      try
        DFS := TFileStream.Create(TmpFileName, FmOpenWrite or FmCreate);
        try
          DecryptStreamEx(SFS, DFS, Password, SeedToBinary(EncryptHeaderExV1.Seed),
                          EncryptHeaderExV1.FileSize, ACipher, EncryptHeaderExV1.BlockSize32k,
            procedure(BytesTotal, BytesDone: Int64)
            begin
              if Assigned(Progress) then
                Progress(FileName, EncryptHeaderExV1.FileSize, BytesDone);
            end
          );
        finally
          F(DFS);
        end;
      except
        Result := CRYPT_RESULT_ERROR_WRITING_FILE;
        Exit;
      end;

    finally
      F(SFS);
    end;
  except
    Result := CRYPT_RESULT_ERROR_READING_FILE;
    Exit;
  end;

  FA := FileGetAttr(FileName);
  ResetFileAttributes(FileName, FA);

  TLockFiles.Instance.AddLockedFile(FileName, 10000);
  TLockFiles.Instance.AddLockedFile(TmpErasedFile, 10000);
  try
    if RenameFile(FileName, TmpErasedFile) then
      if RenameFile(TmpFileName, FileName) then
      begin
        TLockFiles.Instance.RemoveLockedFile(TmpErasedFile);
        DeleteFile(TmpErasedFile);
      end;
  finally
    TLockFiles.Instance.RemoveLockedFile(FileName);
    TLockFiles.Instance.RemoveLockedFile(TmpErasedFile);
  end;

  FileSetAttr(FileName, FA);
  Result := CRYPT_RESULT_OK;
end;

function ValidEncryptFileExStream(Stream: TStream): Boolean;
var
  EncryptHeader: TEncryptedFileHeader;
  Pos: Int64;
begin
  Pos := Stream.Position;
  Stream.Read(EncryptHeader, SizeOf(EncryptHeader));
  Result := EncryptHeader.ID = PhotoDBFileHeaderID;
  Stream.Seek(Pos, soFromBeginning);
end;

function ValidEncryptFileExHandle(FileHandle: THandle): Boolean;
var
  EncryptHeader: TEncryptedFileHeader;
  Pos: Int64;
begin
  Result := False;
  if FileHandle = 0 then
    Exit;

  Pos := FileSeek(FileHandle, 0, FILE_CURRENT);
  if FileRead(FileHandle, EncryptHeader, SizeOf(EncryptHeader)) = SizeOf(EncryptHeader) then
  begin
    Result := EncryptHeader.ID = PhotoDBFileHeaderID;
    FileSeek(FileHandle, Pos, FILE_BEGIN);
  end;
end;

procedure TryOpenHandleForRead(var hFile: THandle; FileName: string; DelayReadFileOperation: Integer);
var
  I: Integer;
begin
  hFile := 0;

  for I := 1 to 20 do
  begin

    hFile := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_WRITE or FILE_SHARE_READ, nil, OPEN_ALWAYS,
        FILE_ATTRIBUTE_NORMAL, 0);

    if hFile = 0 then
    begin
      if GetLastError in [0, ERROR_PATH_NOT_FOUND, ERROR_INVALID_DRIVE, ERROR_NOT_READY,
                          ERROR_FILE_NOT_FOUND, ERROR_GEN_FAILURE, ERROR_INVALID_NAME] then
        Exit;
      Sleep(DelayReadFileOperation);
    end;
  end;
end;

function ValidEnryptFileEx(FileName: String): Boolean;
var
  hFile: THandle;
begin
  Result := False;

  if StartsStr('\\.', FileName) then
    Exit;

  TryOpenHandleForRead(hFile, FileName, DelayReadFileOperation);
  if hFile = 0 then
    Exit;

  Result := ValidEncryptFileExHandle(hFile);
end;

{ TEncryptedFile }

type
  PMsgHdr = ^TMsgHdr;
  TMsgHdr = packed record
    MsgSize : Integer;
    Data : PChar;
  end;

function TEncryptedFile.CanDecryptWithPasswordRequest(FileName: string): Boolean;
var
  EncryptHeader: TEncryptedFileHeader;
  EncryptHeaderV1: TEncryptFileHeaderExV1;
  Position: Int64;
  CRC: Cardinal;
  hFileMapping: THandle;
  Password,
  SharedFileName,
  MessageToSent: string;
  CD: TCopyDataStruct;
  Buf: Pointer;
  P: PByte;
  WinHandle: HWND;
  m_pViewOfFile: Pointer;
begin
  Result := False;

  if FHandle = 0 then
    Exit;

  Password := '';
  //request password from Photo Dtabase host

  SharedFileName := 'FILE_HANDLE_' + IntToStr(FHandle);
  //1024 bytes maximum in pasword
  hFileMapping := CreateFileMapping(
       INVALID_HANDLE_VALUE, // system paging file
       nil, // security attributes
       PAGE_READWRITE, // protection
       0, // high-order DWORD of size
       1024, // low-order DWORD of size
       PChar(SharedFileName)); // name

  if (hFileMapping <> 0) then
  begin

    WinHandle := FindWindow(nil, PChar(DB_ID));
    if WinHandle <> 0 then
    begin
      MessageToSent := '::PASS:' + SharedFileName + ':' + FileName;

      cd.dwData := WM_COPYDATA_ID;
      cd.cbData := SizeOf(TMsgHdr) + ((Length(MessageToSent) + 1) * SizeOf(Char));
      GetMem(Buf, cd.cbData);
      try
        P := PByte(Buf);
        NativeInt(P) := NativeInt(P) + SizeOf(TMsgHdr);

        StrPLCopy(PChar(P), MessageToSent, Length(MessageToSent));
        cd.lpData := Buf;

        if SendMessage(WinHandle, WM_COPYDATA, 0, NativeInt(@cd)) = 0 then
        begin
           ///// Creating a view of the file in the Processes address space
           m_pViewOfFile := MapViewOfFile(
             hFileMapping, // handle to file-mapping object
             FILE_MAP_ALL_ACCESS, // desired access
             0,
             0,
             0);

           if m_pViewOfFile <> nil then
           begin
             Password := string(PChar(m_pViewOfFile));
             UnmapViewOfFile(m_pViewOfFile);
           end;
        end;

      finally
        FreeMem(Buf);
      end;
    end;

    CloseHandle(hFileMapping);
  end;

  {$IFDEF TESTPASS}
  if Password = '' then
    Password := '12';
  {$ENDIF}

  if Password = '' then
    Exit;

  Position := FileSeek(FHandle, 0, FILE_CURRENT);

  FileSeek(FHandle, 0, FILE_BEGIN);

  FillChar(EncryptHeader, SizeOf(EncryptHeader), #0);
  FillChar(EncryptHeaderV1, SizeOf(EncryptHeaderV1), #0);

  FileRead(FHandle, EncryptHeader, SizeOf(EncryptHeader));

  if EncryptHeader.ID = PhotoDBFileHeaderID then
  begin
    if EncryptHeader.Version = ENCRYPT_FILE_VERSION_TRANSPARENT then
    begin
      StrongCryptInit;

      FileRead(FHandle, EncryptHeaderV1, SizeOf(EncryptHeaderV1));
      CalcStringCRC32(Password, CRC);
      if EncryptHeaderV1.PassCRC <> CRC then
        Exit;

      FBlockSize := EncryptHeaderV1.BlockSize32k * Encrypt32kBlockSize;
      FHeaderSize := SizeOf(EncryptHeader) + SizeOf(EncryptHeaderV1);
      FHeaderSize := FHeaderSize + EncryptHeaderV1.Displacement;

      FChipper := CipherByIdentity(EncryptHeaderV1.Algorith);
      FContentSize := EncryptHeaderV1.FileSize;

      FSalt := SeedToBinary(EncryptHeaderV1.Seed);

      FPassword := Password;
      FIsDecrypted := True;

      Result := True;
    end;
  end;

  FileSeek(FHandle, Position, FILE_BEGIN);
end;

constructor TEncryptedFile.Create(Handle: THandle);
begin
  FSync := TCriticalSection.Create;
  FChipper := nil;

  FFileBlocks := TList.Create;
  FMemoryBlocks := TList.Create;

  FIsDecrypted := False;
  FHandle := Handle;
  FHeaderSize := 0;
  FBlockSize := 0;

  FContentSize := 0;
  FMemorySize := 0;
  FMemoryLimit := 10 * 1024 * 1024;
end;

procedure TEncryptedFile.DecodeDataBlock(const Source; var Dest; DataSize: Integer);
var
  APassword: AnsiString;
  Bytes: TBytes;
  AHash: TDECHashClass;
begin
  AHash := ValidHash(nil);

  Bytes := TEncoding.UTF8.GetBytes(FPassword);
  SetLength(APassword, Length(Bytes));
  Move(Bytes[0], APassword[1], Length(Bytes));

  with FChipper.Create do
  try
    Mode := CmCTSx;
    Init(AHash.KDFx(APassword, FSalt, Context.KeySize));
    Decode(Source, Dest, DataSize);
  finally
    Free;
  end;
end;

destructor TEncryptedFile.Destroy;
begin
  F(FFileBlocks);
  //don't free items -> application should call FreeBlock to avoid
  //memory leaks in winows kernel
  F(FMemoryBlocks);

  F(FSync);
  inherited;
end;

procedure TEncryptedFile.FreeBlock(Block: Pointer);
var
  Index: Integer;
begin
  Index := FMemoryBlocks.IndexOf(Block);
  if Index > -1 then
  begin
    FMemoryBlocks.Remove(Block);
    FreeMem(Block);
  end;
end;

function TEncryptedFile.GetBlock(BlockPosition, BlockSize: Int64): Pointer;
begin
  if BlockSize = 0 then
    BlockSize := Size;
  GetMem(Result, BlockSize);
  ReadBlock(Result^, BlockPosition, BlockSize);
end;

function TEncryptedFile.GetBlockByIndex(Index: Int64): TMemoryBlock;
var
  I: Integer;
  B: TMemoryBlock;
  SData, DData: Pointer;
  BlockStart, CurrentPosition: Int64;
  BlockSize: Integer;
  lpNumberOfBytesRead: DWORD;
  MemorySize: Int64;
begin
  Result := nil;
  for I := FFileBlocks.Count - 1 downto 0 do
  begin
    B := FFileBlocks[I];
    if B.Index = Index then
    begin
      if I < FFileBlocks.Count - 1 then
      begin
        FFileBlocks.Remove(B);
        FFileBlocks.Add(B);
      end;
      Exit(B);
    end;
  end;

  MemorySize := 0;
  for I := 0 to FFileBlocks.Count - 1  do
    MemorySize := MemorySize + TMemoryBlock(FFileBlocks[I]).Size;

  while (MemorySize > FMemoryLimit) and (FFileBlocks.Count > 0) do
  begin
    B := FFileBlocks[0];
    MemorySize := MemorySize - B.Size;
    FFileBlocks.Delete(0);
    FreeMem(B.Memory);
    F(B);
  end;

  BlockStart := Index * FBlockSize;
  BlockSize := FBlockSize;
  if BlockStart + BlockSize >= Size then
    BlockSize := Size - BlockStart;

  if BlockSize <= 0 then
    Exit;

  CurrentPosition := FileSeek(FHandle, 0, FILE_CURRENT);

  FileSeek(FHandle, BlockStart + FHeaderSize, FILE_BEGIN);

  GetMem(SData, BlockSize);
  try
    if ReadFile(FHandle, SData^, BlockSize, lpNumberOfBytesRead, nil) then
    begin
      GetMem(DData, BlockSize);
      try
        DecodeDataBlock(SData^, DData^, BlockSize);

        Result := TMemoryBlock.Create;
        Result.Index := Index;
        Result.Size := BlockSize;
        Result.Memory := DData;
        DData := nil;
        FFileBlocks.Add(Result);
      finally
        if DData <> nil then
          FreeMem(DData);
      end;
    end;
  finally
    FreeMem(SData);
  end;

  FileSeek(FHandle, CurrentPosition, FILE_BEGIN);
end;

function TEncryptedFile.GetSize: Int64;
begin
  Int64Rec(Result).Lo := Windows.GetFileSize(FHandle, @Int64Rec(Result).Hi);
  Result := Result - FHeaderSize;
end;

procedure TEncryptedFile.ReadBlock(const Block; BlockPosition, BlockSize: Int64);
var
  I, StartBlock, BlockEnd: Integer;
  B: TMemoryBlock;
  S, D: Pointer;
  MemoryToCopy, MemoryCopied, C: Integer;
  StartBlockPosition: Integer;
begin
  StartBlock := BlockPosition div FBlockSize;
  BlockEnd := Ceil((BlockPosition + BlockSize) / FBlockSize);

  MemoryToCopy := BlockSize;
  MemoryCopied := 0;
  for I := StartBlock to BlockEnd do
  begin
    if MemoryToCopy > 0 then
    begin
      B := Blocks[I];
      if B <> nil then
      begin
        C := MemoryToCopy;
        if C > B.Size then
          C := B.Size;

        StartBlockPosition := BlockPosition + MemoryCopied - B.Index * FBlockSize;

        if StartBlockPosition + C > B.Size then
          C := B.Size - StartBlockPosition;
        D := Pointer(MemoryCopied + NativeInt(Addr(Pointer(Block))));
        S := Pointer(StartBlockPosition + NativeInt(B.Memory));
        CopyMemory(D, S, C);

        MemoryToCopy := MemoryToCopy - C;
        MemoryCopied := MemoryCopied + C;
      end;
    end;
  end;
  if MemoryToCopy > 0 then
  begin
    D := Pointer(MemoryCopied + NativeInt(Addr(Pointer(Block))));
    FillChar(D^, MemoryToCopy, #0);
  end;
end;

end.
