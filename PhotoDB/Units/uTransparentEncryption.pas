unit uTransparentEncryption;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.Types,
  System.SysUtils,
  System.StrUtils,
  System.SyncObjs,
  System.Math,
  System.Classes,
  Winapi.Windows,

  Dmitry.CRC32,
  Dmitry.Utils.System,
  Dmitry.Utils.Files,

  DECUtil,
  DECHash,
  DECCipher,

  uConstants,
  uErrors,
  uMemory,
  uStrongCrypt,
  uRWLock,
  {$IFDEF PHOTODB}
  uSettings,
  {$ENDIF}
  uLockedFileNotifications;

type
  TMemoryBlock = class
    Memory: Pointer;
    Size: Integer;
    Index: Int64;
  end;

  TEncryptionErrorHandler = procedure(ErrorMessage: string);

  TEncryptedFile = class(TObject)
  private
    FSync: TCriticalSection;
    FHandle: THandle;
    FFileBlocks: TList;
    FMemoryBlocks: TList;
    FBlockSize: Int64;
    FMemorySize: Int64;
    FMemoryLimit: Int64;
    FHeaderSize: Integer;
    FContentSize: Int64;
    FSalt: Binary;
    FChipper: TDECCipherClass;
    FIsDecrypted: Boolean;
    FPassword: string;
    FFileName: string;
    FlpOverlapped: POverlapped;
    FIsAsyncHandle: Boolean;
    FAsyncFileHandle: THandle;
    procedure DecodeDataBlock(const Source; var Dest; DataSize: Integer);
    function GetSize: Int64;
    function GetBlockByIndex(Index: Int64): TMemoryBlock;
  public
    constructor Create(Handle: THandle; FileName: string; IsAsyncHandle: Boolean);
    destructor Destroy; override;
    function CanDecryptWithPasswordRequest(FileName: string): Boolean;
    procedure ReadBlock(const Block; BlockPosition: Int64; BlockSize: Int64; lpOverlapped: POverlapped = nil);
    function GetBlock(BlockPosition: Int64; BlockSize: Int64): Pointer;
    procedure FreeBlock(Block: Pointer);
    property Size: Int64 read GetSize;
    property Blocks[Index: Int64]: TMemoryBlock read GetBlockByIndex;
    property HeaderSize: Integer read FHeaderSize;
  end;

  TEncryptionOptions = class(TObject)
  private
    FSync: IReadWriteSync;
    FFileExtensionList: string;
  public
    constructor Create;
    destructor Destroy; override;
    function CanBeTransparentEncryptedFile(FileName: string): Boolean;
    procedure Refresh;
  end;

procedure WriteEnryptHeaderV3(Stream: TStream; Src: TStream;
  BlockSize32k: Byte; Password: string; var Seed: Binary; ACipher: TDECCipherClass);

function EncryptStreamEx(S, D: TStream; Password: string;
                          ACipher: TDECCipherClass; Progress: TSimpleEncryptProgress = nil): Boolean;
function TransparentEncryptFileEx(FileName: string; Password: string;
                                  ACipher: TDECCipherClass = nil; Progress: TFileProgress = nil): Integer;
function DecryptStreamEx(S, D: TStream; Password: string; Seed: Binary; FileSize: Int64;
                         AChipper: TDECCipherClass; BlockSize32k: Byte; Progress: TSimpleEncryptProgress = nil): Boolean;

function ValidEnryptFileEx(FileName: String): Boolean;
function ValidEncryptFileExHandle(FileHandle: THandle; IsAsyncHandle: Boolean): Boolean;
function CanBeTransparentEncryptedFile(FileName: string): Boolean;
function TransparentDecryptFileEx(FileName: string; Password: string;
                                  Progress: TFileProgress = nil): Integer;

procedure SetEncryptionErrorHandler(ErrorHander: TEncryptionErrorHandler);

function EncryptionOptions: TEncryptionOptions;


function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  lpNumberOfBytesRead: PDWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'ReadFile';

implementation

var
  FEncryptionOptions: TEncryptionOptions = nil;
  FErrorHander: TEncryptionErrorHandler = nil;

procedure SetEncryptionErrorHandler(ErrorHander: TEncryptionErrorHandler);
begin
  FErrorHander := ErrorHander;
end;

function EncryptionOptions: TEncryptionOptions;
begin
  if FEncryptionOptions = nil then
    FEncryptionOptions := TEncryptionOptions.Create;

  Result := FEncryptionOptions;
end;

function CanBeTransparentEncryptedFile(FileName: string): Boolean;
begin
  Result := EncryptionOptions.CanBeTransparentEncryptedFile(FileName);
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

function EncryptStreamEx(S, D: TStream; Password: string;
                         ACipher: TDECCipherClass; Progress: TSimpleEncryptProgress = nil): Boolean;
var
  Seed: Binary;
  BlockSize32k: Byte;
  Size, SizeToEncrypt: Int64;
  BreakOperation: Boolean;
begin
  Result := True;
  BreakOperation := False;

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
    begin
      Progress(Size, S.Position, BreakOperation);
      if BreakOperation then
        Exit(False);
    end;
  end;
end;

procedure DoCodeStreamEx(Source,Dest: TStream; Size: Int64; BlockSize: Integer; const Proc: TDECCipherCodeEvent; const Progress: IDECProgress; Buffer: Binary);
var
  BufferSize, Bytes: Integer;
  Min, Max, Pos: Int64;
begin
  Pos := Source.Position;
  if Size < 0 then Size := Source.Size - Pos;
  Min := Pos;
  Max := Pos + Size;
  if Size > 0 then
  try
    if StreamBufferSize <= 0 then StreamBufferSize := 8192;

    BufferSize := StreamBufferSize mod BlockSize;
    if BufferSize = 0 then BufferSize := StreamBufferSize
      else BufferSize := StreamBufferSize + BlockSize - BufferSize;

    if Size > BufferSize then SetLength(Buffer, BufferSize)
      else SetLength(Buffer, Size);

    while Size > 0 do
    begin
      if Assigned(Progress) then Progress.Process(Min, Max, Pos);
      Bytes := BufferSize;
      if Bytes > Size then
        Bytes := Size;
      Source.ReadBuffer(Buffer[1], Bytes);
      Proc(Buffer[1], Buffer[1], Bytes);
      Dest.WriteBuffer(Buffer[1], Bytes);
      Dec(Size, Bytes);
      Inc(Pos, Bytes);
    end;
  finally

    if Assigned(Progress) then Progress.Process(Min, Max, Max);
  end;
end;

function DecryptStreamEx(S, D: TStream; Password: string;
                         Seed: Binary; FileSize: Int64;
                         AChipper: TDECCipherClass; BlockSize32k: Byte; Progress: TSimpleEncryptProgress = nil): Boolean;
var
  StartPos, SizeToEncrypt: Int64;
  APassword: AnsiString;
  Bytes: TBytes;
  AHash: TDECHashClass;
  Key, Buffer: Binary;
  BreakOperation: Boolean;
begin
  if Password = '' then
    Exit(False);

  BreakOperation := False;
  StartPos := S.Position;
  AChipper := ValidCipher(AChipper);
  AHash := ValidHash(nil);

  Bytes := TEncoding.UTF8.GetBytes(Password);
  SetLength(APassword, Length(Bytes));
  Move(Bytes[0], APassword[1], Length(Bytes));

  SetLength(Buffer, BlockSize32k * Encrypt32kBlockSize);
  try
    with AChipper.Create do
    try
      Mode := CmCTSx;
      Key := AHash.KDFx(APassword, Seed, Context.KeySize);

      while S.Position - StartPos < FileSize do
      begin
        SizeToEncrypt := BlockSize32k * Encrypt32kBlockSize;
        if S.Position + SizeToEncrypt - StartPos >= FileSize then
          SizeToEncrypt := FileSize - (S.Position - StartPos);

        Init(Key);

        DoCodeStreamEx(S, D, SizeToEncrypt, Context.BlockSize, Decode, nil, Buffer);

        if Assigned(Progress) then
        begin
          Progress(FileSize, S.Position - StartPos, BreakOperation);
          if BreakOperation then
            Exit(False);
        end;
      end;
    finally
      Free;
    end;
  finally
    ProtectBinary(Buffer);
  end;
  Result := True;
end;

function TransparentEncryptFileEx(FileName: string; Password: string;
  ACipher: TDECCipherClass = nil; Progress: TFileProgress = nil): Integer;
var
  IsEncrypted: Boolean;
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
          IsEncrypted := EncryptStreamEx(SFS, DFS, Password, ACipher,
            procedure(BytesTotal, BytesDone: Int64; var BreakOperation: Boolean)
            begin
              if Assigned(Progress) then     //encryption is the first part of operation
                Progress(FileName, FileSize, BytesDone div 2, BreakOperation);
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

  if not IsEncrypted then
  begin
    DeleteFile(PChar(TmpFileName));
    Exit(CRYPT_RESULT_FAILED_GENERAL_ERROR);
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
          procedure(FileName: string; BytesTotal, BytesDone: Int64; var BreakOperation: Boolean)
          begin
            if Assigned(Progress) then     //erase is the second part of operation
              Progress(FileName, FileSize, FileSize div 2 + BytesDone div 2, BreakOperation);
          end
        );
        TLockFiles.Instance.RemoveLockedFile(TmpErasedFile);
        System.SysUtils.DeleteFile(TmpErasedFile);
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
  IsDecrypted: Boolean;
  SFS, DFS: TFileStream;
  FA: Integer;
  EncryptHeader: TEncryptedFileHeader;
  EncryptHeaderExV1: TEncryptFileHeaderExV1;
  TmpFileName, TmpErasedFile: string;
  ACipher: TDECCipherClass;
begin
  StrongCryptInit;

  TmpFileName := FileName + '.tmp';
  TmpErasedFile := FileName + '.erased';

  TLockFiles.Instance.AddLockedFile(FileName, 10000);
  TLockFiles.Instance.AddLockedFile(TmpFileName, 10000);
  TLockFiles.Instance.AddLockedFile(TmpErasedFile, 10000);
  try
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

        try
          DFS := TFileStream.Create(TmpFileName, FmOpenWrite or FmCreate);
          try
            IsDecrypted := DecryptStreamEx(SFS, DFS, Password, SeedToBinary(EncryptHeaderExV1.Seed),
                            EncryptHeaderExV1.FileSize, ACipher, EncryptHeaderExV1.BlockSize32k,
              procedure(BytesTotal, BytesDone: Int64; var BreakOperation: Boolean)
              begin
                if Assigned(Progress) then
                  Progress(FileName, EncryptHeaderExV1.FileSize, BytesDone, BreakOperation);
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

    if not IsDecrypted then
    begin
      DeleteFile(PChar(TmpFileName));
      Exit(CRYPT_RESULT_FAILED_GENERAL_ERROR);
    end;

    FA := FileGetAttr(FileName);
    ResetFileAttributes(FileName, FA);

    if RenameFile(FileName, TmpErasedFile) then
      if RenameFile(TmpFileName, FileName) then
      begin
        TLockFiles.Instance.RemoveLockedFile(TmpErasedFile);
        System.SysUtils.DeleteFile(TmpErasedFile);
      end;
  finally
    TLockFiles.Instance.RemoveLockedFile(FileName);
    TLockFiles.Instance.RemoveLockedFile(TmpFileName);
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
  Stream.Seek(Pos, TSeekOrigin.soBeginning);
end;

function ValidEncryptFileExHandle(FileHandle: THandle; IsAsyncHandle: Boolean): Boolean;
var
  EncryptHeader: TEncryptedFileHeader;
  Pos: Int64;
  Overlapped: TOverlapped;
  lpNumberOfBytesTransferred: DWORD;
begin
  Result := False;
  if FileHandle = 0 then
    Exit;

  if not IsAsyncHandle then
  begin
    Pos := FileSeek(FileHandle, 0, FILE_CURRENT);

    FileSeek(FileHandle, 0, FILE_BEGIN);
    if FileRead(FileHandle, EncryptHeader, SizeOf(EncryptHeader)) = SizeOf(EncryptHeader) then
      Result := EncryptHeader.ID = PhotoDBFileHeaderID;

    FileSeek(FileHandle, Pos, FILE_BEGIN);
  end else
  begin
    FillChar(Overlapped, SizeOf(TOverlapped), #0);
    Overlapped.hEvent := CreateEvent(nil, True, False, nil);
    try

      ReadFile(FileHandle, EncryptHeader, SizeOf(EncryptHeader), nil, @Overlapped);

      if ERROR_IO_PENDING <> GetLastError then
        Exit;

      if WaitForSingleObject(Overlapped.hEvent, INFINITE) = WAIT_OBJECT_0 then
      begin
        if not GetOverlappedResult(FileHandle, Overlapped, lpNumberOfBytesTransferred, True) then
          Exit;

        if lpNumberOfBytesTransferred = 0 then
          Exit;

        Result := EncryptHeader.ID = PhotoDBFileHeaderID;
      end;
    finally
      CloseHandle(Overlapped.hEvent);
    end;
  end;
end;

procedure TryOpenHandleForRead(var hFile: THandle; FileName: string; DelayReadFileOperation: Integer);
var
  I: Integer;
begin
  hFile := 0;

  for I := 1 to 20 do
  begin

    hFile := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_WRITE or FILE_SHARE_READ, nil, OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL, 0);

    if hFile = 0 then
    begin
      if GetLastError in [0, ERROR_PATH_NOT_FOUND, ERROR_INVALID_DRIVE, ERROR_NOT_READY,
                          ERROR_FILE_NOT_FOUND, ERROR_GEN_FAILURE, ERROR_INVALID_NAME] then
        Exit;
      Sleep(DelayReadFileOperation);
    end else
      Break;
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

  Result := ValidEncryptFileExHandle(hFile, False);

  CloseHandle(hFile);
end;

{ TEncryptedFile }

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

  FFilePosition: Int64;
  procedure InternalFileSeek(Offset: Int64);
  begin
    if FIsAsyncHandle then
      FFilePosition := Offset
    else
      FileSeek(FHandle, Offset, FILE_BEGIN)
  end;

  procedure InternalFileRead(var Buffer; SizeToRead: Integer);
  var
    Res: BOOL;
    lpNumberOfBytesTransferred: Cardinal;
    lpOverlapped: POverlapped;
  begin
    if FIsAsyncHandle then
    begin

      GetMem(lpOverlapped, SizeOf(TOverlapped));
      FillChar(lpOverlapped^, SizeOf(TOverlapped), #0);

      lpOverlapped.Offset     := Int64Rec(FFilePosition).Lo;
      lpOverlapped.OffsetHigh := Int64Rec(FFilePosition).Hi;

      lpOverlapped.hEvent := CreateEvent(nil, True, False, nil);

      try
        Res := ReadFile(FHandle, Buffer, SizeToRead, nil, lpOverlapped);

        if not Res and (GetLastError = ERROR_IO_PENDING) then
        begin
          if not WaitForSingleObject(lpOverlapped.hEvent, INFINITE) = WAIT_OBJECT_0 then
            Exit;

          if not GetOverlappedResult(FHandle, lpOverlapped^, lpNumberOfBytesTransferred, True) then
            Exit;

          FFilePosition := FFilePosition + Int64(lpNumberOfBytesTransferred);
        end;

      finally
        CloseHandle(lpOverlapped.hEvent);
        FreeMem(lpOverlapped);
      end;
    end else
      FileRead(FHandle, Buffer, SizeToRead);
  end;

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
      cd.cbData := ((Length(MessageToSent) + 1) * SizeOf(Char));
      GetMem(Buf, cd.cbData);
      try
        P := PByte(Buf);

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
    Password := '1';
  {$ENDIF}

  if Password = '' then
    Exit;

  Position := FileSeek(FHandle, Int64(0), FILE_CURRENT);

  InternalFileSeek(0);

  FillChar(EncryptHeader, SizeOf(EncryptHeader), #0);
  FillChar(EncryptHeaderV1, SizeOf(EncryptHeaderV1), #0);

  InternalFileRead(EncryptHeader, SizeOf(EncryptHeader));

  if EncryptHeader.ID = PhotoDBFileHeaderID then
  begin
    if EncryptHeader.Version = ENCRYPT_FILE_VERSION_TRANSPARENT then
    begin
      StrongCryptInit;

      InternalFileRead(EncryptHeaderV1, SizeOf(EncryptHeaderV1));
      CalcStringCRC32(Password, CRC);
      if EncryptHeaderV1.PassCRC <> CRC then
        Exit;

      FBlockSize := EncryptHeaderV1.BlockSize32k * Encrypt32kBlockSize;
      FHeaderSize := SizeOf(EncryptHeader) + SizeOf(EncryptHeaderV1);
      FHeaderSize := FHeaderSize + Integer(EncryptHeaderV1.Displacement);

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

constructor TEncryptedFile.Create(Handle: THandle; FileName: string; IsAsyncHandle: Boolean);
begin
  FSync := TCriticalSection.Create;

  FChipper := nil;
  FlpOverlapped := nil;

  FFileBlocks := TList.Create;
  FMemoryBlocks := TList.Create;

  FIsDecrypted := False;

  FHandle := Handle;
  FFileName := FileName;
  FIsAsyncHandle := IsAsyncHandle;

  FHeaderSize := 0;
  FBlockSize := 0;

  FContentSize := 0;
  FMemorySize := 0;
  FMemoryLimit := 10 * 1024 * 1024;

  FAsyncFileHandle := 0;
  if IsAsyncHandle then
  begin
    FAsyncFileHandle := CreateFile(PChar(FFileName), GENERIC_READ, FILE_SHARE_WRITE or FILE_SHARE_READ, nil, OPEN_EXISTING,
                                   FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);
    if FAsyncFileHandle = INVALID_HANDLE_VALUE then
      FAsyncFileHandle := 0;
  end;
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
  if FAsyncFileHandle <> 0 then
    CloseHandle(FAsyncFileHandle);

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
  Res: BOOL;
  BlockStart, CurrentPosition: Int64;
  BlockSize: Integer;
  lpNumberOfBytesTransferred,
  lpNumberOfBytesRead: DWORD;
  MemorySize, FileReadPosition: Int64;
  lpOverlapped: POverlapped;

  Async: Boolean;
  FileHandle: THandle;
begin
  Result := nil;

  Async := FlpOverlapped <> nil;  // FIsAsyncHandle

  FileHandle := FHandle;
  if Async and (FAsyncFileHandle <> 0) then
    FileHandle := FAsyncFileHandle;

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

  CurrentPosition := 0;
  if not Async then
  begin
    CurrentPosition := FileSeek(FileHandle, Int64(0), FILE_CURRENT);
    FileSeek(FileHandle, BlockStart + FHeaderSize, FILE_BEGIN);
  end;

  SData := AllocMem(BlockSize);
  try
    lpOverlapped := nil;
    if Async then
    begin
      New(lpOverlapped);
      FillChar(lpOverlapped^, SizeOf(TOverlapped), #0);

      FileReadPosition := BlockStart + FHeaderSize;
      lpOverlapped.Offset     := Int64Rec(FileReadPosition).Lo;
      lpOverlapped.OffsetHigh := Int64Rec(FileReadPosition).Hi;
    end;

    try
      Res := ReadFile(FileHandle, SData^, BlockSize, @lpNumberOfBytesRead, lpOverlapped);

      if Res or (not Res and Async and (GetLastError = ERROR_IO_PENDING)) then
      begin
        if Async then
        begin
          if not GetOverlappedResult(FileHandle, lpOverlapped^, lpNumberOfBytesTransferred, True) then
            Exit(nil);

          if lpNumberOfBytesTransferred = 0 then
            Exit(nil);
        end;

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
      if Async then
        Dispose(lpOverlapped);
    end;
  finally
    FreeMem(SData);
  end;

  if not Async then
    FileSeek(FileHandle, CurrentPosition, FILE_BEGIN);
end;

function TEncryptedFile.GetSize: Int64;
begin
  Int64Rec(Result).Lo := Winapi.Windows.GetFileSize(FHandle, @Int64Rec(Result).Hi);
  Result := Result - FHeaderSize;
end;

procedure TEncryptedFile.ReadBlock(const Block; BlockPosition, BlockSize: Int64; lpOverlapped: POverlapped = nil);
var
  I, StartBlock, BlockEnd: Integer;
  B: TMemoryBlock;
  S, D: Pointer;
  MemoryToCopy, MemoryCopied, C: Integer;
  StartBlockPosition: Integer;
begin
  if BlockSize = 0 then
    Exit;

  FlpOverlapped := lpOverlapped;

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
  if (MemoryToCopy > 0) then
  begin
    D := Pointer(MemoryCopied + NativeInt(Addr(Pointer(Block))));
    FillChar(D^, MemoryToCopy, #0);
    if Assigned(FErrorHander) then
      FErrorHander('ReadBlock, LIMIT');
  end;
end;

{ TEncryptionOptions }

function TEncryptionOptions.CanBeTransparentEncryptedFile(
  FileName: string): Boolean;
var
  Ext: string;
begin
  Ext := AnsiUpperCase(ExtractFileExt(FileName));

  FSync.BeginRead;
  try
    Result := FFileExtensionList.IndexOf(Ext) > 0;
  finally
    FSync.EndRead;
  end;
end;

constructor TEncryptionOptions.Create;
begin
  FSync := CreateRWLock;
  Refresh;
end;

destructor TEncryptionOptions.Destroy;
begin
  FSync := nil;
  inherited;
end;

procedure TEncryptionOptions.Refresh;
{$IFDEF PHOTODB}
var
  Associations: TStrings;
  I: Integer;
{$ENDIF}
begin
  FSync.BeginWrite;
  try
    FFileExtensionList := '';
    {$IFDEF PHOTODB}
    Associations := AppSettings.ReadKeys(cMediaAssociationsData);
    try
      for I := 0 to Associations.Count - 1 do
        FFileExtensionList := FFileExtensionList + ':' + AnsiUpperCase(Associations[I]);
    finally
      F(Associations);
    end;
    {$ENDIF}
  finally
    FSync.EndWrite;
  end;
end;

initialization
finalization
  F(FEncryptionOptions);

end.
