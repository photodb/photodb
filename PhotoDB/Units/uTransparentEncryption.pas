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
    FSize: Int64;
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
    function CanDecryptWithPassword(Password: string): Boolean;
    procedure ReadBlock(const Block; BlockPosition: Int64; BlockSize: Int64);
    function GetBlock(BlockPosition: Int64; BlockSize: Int64): Pointer;
    procedure FreeBlock(Block: Pointer);
    property Size: Int64 read GetSize;
    property Blocks[Index: Int64]: TMemoryBlock read GetBlockByIndex;
  end;

procedure WriteEnryptHeaderV3(Stream: TStream; Src: TStream;
  BlockSize32k: Byte; Password: string; var Seed: Binary; ACipher: TDECCipherClass);

procedure EncryptStreamEx(S, D: TStream; Password: string; FileName: string;
                         ACipher: TDECCipherClass; Progress: TEncryptProgress = nil);
function EncryptFileEx(FileName: string; Password: string;
                       ACipher: TDECCipherClass = nil; Progress: TEncryptProgress = nil): Integer;
function DecryptStreamEx(S, D: TStream; Password: string; Seed: Binary; FileSize: Int64; AChipper: TDECCipherClass; BlockSize32k: Byte; Progress: TEncryptProgress = nil): Boolean;

function ValidEnryptFileEx(FileName: String): Boolean;
function CanBeTransparentEncryptedFile(FileName: string): Boolean;

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

procedure EncryptStreamEx(S, D: TStream; Password: string; FileName: string;
                         ACipher: TDECCipherClass; Progress: TEncryptProgress = nil);
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
      Progress(FileName, Size, S.Position);
  end;
end;

function EncryptFileEx(FileName: string; Password: string;
  ACipher: TDECCipherClass = nil; Progress: TEncryptProgress = nil): Integer;
var
  SFS, DFS: TFileStream;
  FA: Integer;
  EncryptHeader: TEncryptedFileHeader;
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
      SFS.Read(EncryptHeader, SizeOf(EncryptHeader));
      if EncryptHeader.ID = PhotoDBFileHeaderID then
      begin
        Result := CRYPT_RESULT_ALREADY_CRYPT;
        Exit;
      end;

      SFS.Seek(0, SoFromBeginning);

      try
        DFS := TFileStream.Create(FileName + '.tmp', FmOpenWrite or FmCreate);
        try
          EncryptStreamEx(SFS, DFS, Password, FileName, ACipher, Progress);
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

  //TODO: rename file, erase content
  FA := FileGetAttr(FileName);
  ResetFileAttributes(FileName, FA);

  FileSetAttr(FileName, FA);
  Result := CRYPT_RESULT_OK;
end;

function DecryptStreamEx(S, D: TStream; Password: string; Seed: Binary; FileSize: Int64; AChipper: TDECCipherClass; BlockSize32k: Byte; Progress: TEncryptProgress = nil): Boolean;
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
      Progress('', FileSize, S.Position - StartPos);
  end;

  Result := True;
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

function ValidEnryptFileEx(FileName: String): Boolean;
var
  FS: TFileStream;
begin
  Result := False;

  if StartsStr('\\.', FileName) then
    Exit;

  TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
  if FS = nil then
    Exit;

  try
    Result := ValidEncryptFileExStream(FS);
  finally
    F(FS);
  end;
end;

{ TEncryptedFile }

function TEncryptedFile.CanDecryptWithPassword(Password: string): Boolean;
var
  EncryptHeader: TEncryptedFileHeader;
  EncryptHeaderV1: TEncryptFileHeaderExV1;
  Position: Int64;
  CRC: Cardinal;
begin
  Result := False;

  if FHandle = 0 then
    Exit;

  Position := FileSeek(FHandle, 0, FILE_CURRENT);

  FSize := FileSeek(FHandle, 0, FILE_END);

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
  FHeaderSize := 0;
end;

procedure TEncryptedFile.DecodeDataBlock(const Source; var Dest; DataSize: Integer);
var
  APassword: AnsiString;
  Bytes: TBytes;
  ACipher: TDECCipherClass;
  AHash: TDECHashClass;
begin
  ACipher := ValidCipher(nil);
  AHash := ValidHash(nil);

  Bytes := TEncoding.UTF8.GetBytes(FPassword);
  SetLength(APassword, Length(Bytes));
  Move(Bytes[0], APassword[1], Length(Bytes));

  with ACipher.Create do
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
