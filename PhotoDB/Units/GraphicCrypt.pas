unit GraphicCrypt;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  win32crc, Windows, SysUtils, Classes, Graphics, ADODB,
  JPEG, PngImage, uFileUtils, uAssociations, uTiffImage,
  GraphicEx, RAWImage, uConstants, uStrongCrypt, DECUtil, DECCipher,
  GIFImage, DB, uMemoryUtils;

type

  TCryptImageOptions = record
    Password: String;
    CryptFileName: Boolean;
    SaveFileCRC: Boolean;
  end;

  TGraphicCryptFileHeader = record
    IDSize : Byte;
    ID: array[0..7] of AnsiChar;
    Version: Byte;
    DBVersion: Byte;
  end;

  TMagicByte = array [0 .. 3] of Byte;
  TFileNameAnsi = array[0..254] of AnsiChar;
  TByteArray = array of Byte;

  TGraphicCryptFileHeaderV1 = record
    Version: Byte;
    Magic: Cardinal;
    FileSize: Cardinal;
    PassCRC: Cardinal;
    CRCFileExists: Boolean;
    CRCFile: Cardinal;
    TypeExtract: Byte;
    CryptFileName: Boolean;
    FileNameLength : Byte;
    CFileName: TFileNameAnsi;
    TypeFileNameExtract: Byte;
    FileNameCRC: Cardinal;
    Displacement: Cardinal;
  end;

  TGraphicCryptFileHeaderV2 = record
    Version: Byte;
    Seed: TSeed;
    FileSize: Int64;
    PassCRC: Cardinal;
    Algorith: Cardinal;
    CRCFileExists: Boolean;
    CRCFile: Cardinal;
    TypeExtract: Byte;
    CryptFileName: Boolean;
    FileNameLength : Byte;
    CFileName: TFileNameUnicode;
    TypeFileNameExtract: Byte;
    FileNameCRC: Cardinal;
    Displacement: Cardinal;
    Reserved : Cardinal;
    Reserved2 : Cardinal;
  end;

  TDBInfoInGraphicFile = record
    FileNameSize: Cardinal;
  end;

const

  CRYPT_OPTIONS_NORMAL = 0;
  CRYPT_OPTIONS_SAVE_CRC = 1;
  PhotoDBFileHeaderID = '.PHDBCRT';

function CryptGraphicFileV2(FileName: string; Password: string; Options: Integer): Boolean;
function DeCryptGraphicFileEx(FileName: string; Password: string; var Pages: Word;
  LoadFullRAW: Boolean = false; Page: Integer = 0): TGraphic;
function DeCryptGraphicFile(FileName: string; Password: string;
  LoadFullRAW: Boolean = false; Page: Integer = 0): TGraphic;
function DecryptGraphicFileToStream(FileName, Password: string; S: TStream): Boolean;
function ValidPassInCryptGraphicFile(FileName, Password: string): Boolean;
function ResetPasswordInGraphicFile(FileName, Password: string): Boolean;
function ChangePasswordInGraphicFile(FileName: string; OldPass, NewPass: string): Boolean;
function ValidCryptGraphicFile(FileName: string): Boolean;
function GetPasswordCRCFromCryptGraphicFile(FileName: string): Cardinal;

function CryptBlobStream(DF: TField; Password: string): Boolean;
function DeCryptBlobStreamJPG(DF: TField; Password: string; JPEG: TJpegImage) : Boolean;
function ValidCryptBlobStreamJPG(DF: TField): Boolean;
function ValidPassInCryptBlobStreamJPG(DF: TField; Password: string): Boolean;
function ResetPasswordInCryptBlobStreamJPG(DF: TField; Password: string): Boolean;
procedure CryptGraphicImage(Image: TJpegImage; Password: string; Dest : TMemoryStream);
function DecryptFileToStream(FileName: String; Password : string; Stream : TStream) : Boolean;
procedure CryptStream(S, D : TStream; Password : string; Options: Integer; FileName : string);

implementation

uses CommonDBSupport, Dolphin_DB;

procedure FillCharArray(var CharAray : TFileNameUnicode; Str : String);
var
  I : Integer;
begin
  for I := 1 to Length(Str) do
    CharAray[I - 1] := Str[I];

  CharAray[Length(Str)] := #0;
end;

(*function CryptGraphicFileV1W(FileName: string; Password: AnsiString; Options: Integer;
  const Info; Size: Cardinal): Boolean;
var
  FS: TFileStream;
  X: TByteArray;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  FileCRC: Cardinal;
  FA: Integer;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName);
  if FS = nil then
    Exit;

  try
    SetLength(X, FS.Size);
    FS.Read(GraphicHeader, SizeOf(GraphicHeader));
    if GraphicHeader.ID = PhotoDBFileHeaderID then
      Exit;

    FS.Seek(0, soFromBeginning);
    FS.Read(Pointer(X)^, FS.Size);
  finally
    FS.Free;
  end;

  FA := FileGetAttr(FileName);
  ResetFileattributes(FileName, FA);

  FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
  try
    WriteCryptHeaderV1(FS, X, FileName, Password, Options, GraphicHeaderV1);
    CryptArrayByteV1(X, GraphicHeaderV1.Magic, Password);
    if Size > 0 then
      FS.Write(Info, Size);
    FS.Write(Pointer(X)^, Length(X));
  finally
    FS.Free;
  end;
  FileSetAttr(FileName, FA);
  Result := True;
end;

procedure CryptArrayByteV1(X : TByteArray; Magic : Cardinal; Password : AnsiString);
var
  I, LPass : Integer;
  XCos: array [0 .. 1023] of Byte;
begin
  {$IFOPT R+}
  {$DEFINE CKRANGE}
  {$R-}
  {$ENDIF}
  LPass := Length(Password);

  for I := 0 to 1023 do
    XCos[I] := Round(255 * Cos(TMagicByte(Magic)[I mod 4] + I));

  for I := 0 to length(x) - 1 do
    X[I] := X[I] xor (TMagicByte(Magic)[I mod 4] xor Byte
        (Password[I mod LPass + 1])) xor XCos[I mod 1024];
  {$IFDEF CKRANGE}
  {$UNDEF CKRANGE}
  {$R+}
  {$ENDIF}
end;

procedure WriteCryptHeaderV1(Stream : TStream; X : TByteArray; FileName : AnsiString; Password : AnsiString; Options: Integer; var GraphicHeaderV1: TGraphicCryptFileHeaderV1);
var
  FileCRC : Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  GraphicHeaderV1.CRCFileExists := Options = CRYPT_OPTIONS_SAVE_CRC;
  if GraphicHeaderV1.CRCFileExists then
  begin
    CalcBufferCRC32(X, Length(X), FileCRC);
    GraphicHeaderV1.CRCFile := FileCRC;
  end;

  Randomize;
  GraphicHeaderV1.Magic := Random(High(Integer));
  GraphicHeader.ID := PhotoDBFileHeaderID;
  GraphicHeader.Version := 1;
  GraphicHeader.DBVersion := 0;
  Stream.Write(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  GraphicHeaderV1.Version := 2; // !!!!!!!!!!!!!!!!!
  GraphicHeaderV1.FileSize := Length(X);
  CalcStringCRC32(Password, GraphicHeaderV1.PassCRC);
  GraphicHeaderV1.TypeExtract := 0;
  GraphicHeaderV1.CryptFileName := False;
  FillCharArray(GraphicHeaderV1.CFileName, ExtractFileName(FileName));
  GraphicHeaderV1.TypeFileNameExtract := 0;
  CalcStringCRC32(AnsiLowerCase(FileName), GraphicHeaderV1.FileNameCRC);
  GraphicHeaderV1.Displacement := 0;
  Stream.Write(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
end;*)

procedure WriteCryptHeaderV2(Stream : TStream; Src : TStream; FileName : string; Password : string; Options: Integer; var Seed : Binary);
var
  FileCRC : Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
begin
  FillChar(GraphicHeaderV2, SizeOf(GraphicHeaderV2), #0);
  GraphicHeaderV2.CRCFileExists := Options = CRYPT_OPTIONS_SAVE_CRC;
  if GraphicHeaderV2.CRCFileExists and (Src is TMemoryStream) then
  begin
    CalcBufferCRC32(TMemoryStream(Src).Memory, Src.Size, FileCRC);
    GraphicHeaderV2.CRCFile := FileCRC;
  end;

  Randomize;
  Seed := RandomBinary(16);
  GraphicHeaderV2.Seed := ConvertSeed(Seed);
  GraphicHeader.ID := PhotoDBFileHeaderID;
  GraphicHeader.Version := 2;
  GraphicHeader.DBVersion := 0;
  Stream.Write(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  GraphicHeaderV2.Version := 1;
  GraphicHeaderV2.Algorith := ValidCipher(nil).Identity;
  GraphicHeaderV2.FileSize := Src.Size;
  CalcStringCRC32(Password, GraphicHeaderV2.PassCRC);
  GraphicHeaderV2.TypeExtract := 0;
  GraphicHeaderV2.CryptFileName := False;
  FillCharArray(GraphicHeaderV2.CFileName, ExtractFileName(FileName));
  GraphicHeaderV2.TypeFileNameExtract := 0;
  CalcStringCRC32(AnsiLowerCase(FileName), GraphicHeaderV2.FileNameCRC);
  GraphicHeaderV2.Displacement := 0;
  Stream.Write(GraphicHeaderV2, SizeOf(TGraphicCryptFileHeaderV2));
end;

procedure TryOpenFSForRead(var FS: TFileStream; FileName : string);
var
  I : Integer;
begin
  FS := nil;

  for I := 1 to 20 do
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      Break;
    except
      Sleep(DelayReadFileOperation);
    end;
  end;
end;

procedure ResetFileattributes(FileName : string; FA : Integer);
begin
  if (FA and SysUtils.fahidden) <> 0 then
    FA := FA - SysUtils.fahidden;
  if (FA and SysUtils.faReadOnly) <> 0 then
    FA := FA - SysUtils.faReadOnly;
  if (FA and SysUtils.faSysFile) <> 0 then
    FA := FA - SysUtils.faSysFile;
  FileSetAttr(FileName, FA);
end;

procedure CryptStream(S, D : TStream; Password : string; Options: Integer; FileName : string);
var
  Seed : Binary;
begin
  WriteCryptHeaderV2(D, S, FileName, Password, Options, Seed);
  CryptStreamV2(S, D, Password, Seed);
end;

function CryptGraphicFileV2W(FileName: string; Password: string; Options: Integer): Boolean;
var
  FS: TFileStream;
  MS: TMemoryStream;
  FA: Integer;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;

  MS := TMemoryStream.Create;
  try

    TryOpenFSForRead(FS, FileName);
    if FS = nil then
      Exit;

    try
      FS.Read(GraphicHeader, SizeOf(GraphicHeader));
      if GraphicHeader.ID = PhotoDBFileHeaderID then
        Exit;

      FS.Seek(0, SoFromBeginning);
      MS.CopyFrom(Fs, FS.Size);
      MS.Position := 0;
    finally
      F(FS);
    end;

    FA := FileGetAttr(FileName);
    ResetFileAttributes(FileName, FA);

    FS := TFileStream.Create(FileName, FmOpenWrite or FmCreate);
    try
      CryptStream(MS, FS, Password, Options, FileName);
    finally
      F(FS);
    end;
  finally
    MS.Free;
  end;
  FileSetAttr(FileName, FA);
  Result := True;
end;

procedure CryptGraphicImage(Image: TJpegImage; Password: string; Dest : TMemoryStream);
var
  MS: TMemoryStream;
  Seed: Binary;
begin
  MS := TMemoryStream.Create;
  try
    Image.SaveToStream(MS);
    MS.Seek(0, soFromBeginning);

    WriteCryptHeaderV2(Dest, MS, '', Password, CRYPT_OPTIONS_NORMAL, Seed);
    CryptStreamV2(MS, Dest, Password, Seed);
  finally
    F(MS);
  end;
end;

function CryptGraphicFileV2(FileName: string; Password: string;
  Options: Integer): Boolean;
begin
  Result := CryptGraphicFileV2W(FileName, Password, Options);
end;

function DeCryptGraphicFile(FileName: string; Password: String;
  LoadFullRAW: Boolean = False; Page: Integer = 0): TGraphic;
var
  Pages: Word;
begin
  Result := DeCryptGraphicFileEx(FileName, Password, Pages, LoadFullRAW, Page);
end;

function DecryptStream(Stream : TStream; GraphicHeader: TGraphicCryptFileHeader; Password : string; MS : TStream) : Boolean;
var
  AnsiPassword : AnsiString;
  FileCRC, CRC : Cardinal;
  I, LPass : Integer;
  XCos: array [0 .. 1023] of Byte;
  X : TByteArray;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
  Chipper : TDECCipherClass;
begin
  Result := False;
  if GraphicHeader.Version = 1 then
  begin
    AnsiPassword := AnsiString(Password);
    Stream.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcAnsiStringCRC32(AnsiPassword, CRC);
    if GraphicHeaderV1.PassCRC <> CRC then
      Exit;

    if GraphicHeaderV1.Displacement > 0 then
      Stream.Seek(GraphicHeaderV1.Displacement, soCurrent);

    SetLength(X, GraphicHeaderV1.FileSize);
    Stream.Read(Pointer(X)^, GraphicHeaderV1.FileSize);

    LPass := Length(AnsiPassword);

    if GraphicHeaderV1.Version = 1 then
    begin
      for I := 0 to Length(X) - 1 do
        X[I] := X[I] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(AnsiPassword[I mod LPass + 1]));
    end;

    if GraphicHeaderV1.Version = 2 then
    begin
      {$IFOPT R+}
      {$DEFINE CKRANGE}
      {$R-}
      {$ENDIF}
      for I := 0 to 1023 do
        XCos[I] := Round(255 * Cos(TMagicByte(GraphicHeaderV1.Magic)[I mod 4] + I));

      for I := 0 to length(x) - 1 do
        X[I] := X[I] xor (TMagicByte(GraphicHeaderV1.Magic)[I mod 4] xor Byte
            (AnsiPassword[I mod LPass + 1])) xor XCos[I mod 1024];
      {$IFDEF CKRANGE}
      {$UNDEF CKRANGE}
      {$R+}
      {$ENDIF}
    end;

    if GraphicHeaderV1.CRCFileExists then
    begin
      CalcBufferCRC32(X, length(X), FileCRC);
      if GraphicHeaderV1.CRCFile <> FileCRC then
        Exit;
    end;

    MS.Write(Pointer(X)^, Length(X));

    Result := True;
  end else if GraphicHeader.Version = 2 then
  begin
    StrongCryptInit;

    Stream.Read(GraphicHeaderV2, SizeOf(TGraphicCryptFileHeaderV2));
    CalcStringCRC32(Password, CRC);
    if GraphicHeaderV2.PassCRC <> CRC then
      Exit;

    if GraphicHeaderV2.Displacement > 0 then
      Stream.Seek(GraphicHeaderV2.Displacement, soCurrent);

    Chipper := CipherByIdentity(GraphicHeaderV2.Algorith);
    DeCryptStreamV2(Stream, MS, Password, SeedToBinary(GraphicHeaderV2.Seed), GraphicHeaderV2.FileSize, Chipper);
    Result := True;
  end;
end;

function DecryptGraphicFileToStream(FileName, Password: string; S: TStream): Boolean;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName);
  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStream(FS, GraphicHeader, Password, S) then
      Exit;

    Result := True;
  finally
    F(FS);
  end;
end;


function DecryptFileToStream(FileName: String; Password : string; Stream : TStream) : Boolean;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName);
  if FS = nil then
    Exit;
  try

    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStream(FS, GraphicHeader, Password, Stream) then
      Exit;
  finally
    F(FS);
  end;

  Result := True;
end;

function DeCryptGraphicFileEx(FileName: string; Password: string; var Pages: Word;
  LoadFullRAW: Boolean = False; Page: Integer = 0): TGraphic;
var
  FS: TFileStream;
  MS: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicClass : TGraphicClass;
begin
  Result := nil;

  MS := TMemoryStream.Create;
  try
    TryOpenFSForRead(FS, FileName);
    if FS = nil then
      Exit;

    try
      FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
      if GraphicHeader.ID <> PhotoDBFileHeaderID then
        Exit;

      if not DecryptStream(FS, GraphicHeader, Password, MS) then
        Exit;

      MS.Seek(0, soFromBeginning);
      GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
      if GraphicClass = nil then
        Exit;

      Result := GraphicClass.Create;

      if (Result is TRAWImage) then
         (Result as TRAWImage).IsPreview := not LoadFullRAW;

      if (Result is TTiffImage) then
      begin

        if Page = -1 then
          (Result as TTiffImage).GetPagesCount(MS)
        else
          (result as TTiffImage).LoadFromStreamEx(MS, Page);

        Pages := (result as TTiffImage).Pages;

      end else
        Result.LoadFromStream(MS);

    finally
      F(FS);
    end;
  finally
    F(MS);
  end;
end;

function ResetPasswordInGraphicFile(FileName, Password: String): Boolean;
var
  FS: TFileStream;
  MS: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  FA: Integer;
begin
  Result := false;

  MS := TMemoryStream.Create;
  try

    TryOpenFSForRead(FS, FileName);

    if FS = nil then
      Exit;

    try
      FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
      if GraphicHeader.ID <> PhotoDBFileHeaderID then
        Exit;

      if not DecryptStream(FS, GraphicHeader, Password, MS) then
        Exit;

    finally
      F(FS);
    end;

    FA := FileGetAttr(FileName);
    ResetFileattributes(FileName, FA);

    FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
    try
      MS.Seek(0, soFromBeginning);
      FS.CopyFrom(MS, MS.Size);
    finally
      F(FS);
    end;
  finally
    F(MS);
  end;
  FileSetAttr(FileName, FA);
  Result := True;
end;

function ChangePasswordInGraphicFile(FileName: String;
  OldPass, NewPass: String): Boolean;
var
  FS: TFileStream;
  MS: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  FA : Cardinal;
  Seed : Binary;
begin
  Result := false;

  TryOpenFSForRead(FS, FileName);

  MS := TMemoryStream.Create;
  try

    if FS = nil then
      Exit;

    try
      FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
      if GraphicHeader.ID <> PhotoDBFileHeaderID then
        Exit;

      if not DecryptStream(FS, GraphicHeader, OldPass, MS) then
        Exit;

    finally
      F(FS);
    end;
    FA := FileGetAttr(FileName);
    ResetFileattributes(FileName, FA);

    FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
    try
      WriteCryptHeaderV2(FS, MS, FileName, NewPass, CRYPT_OPTIONS_SAVE_CRC, Seed);
      CryptStreamV2(MS, FS, NewPass, Seed);
    finally
      F(FS);
    end;

  finally
    F(MS);
  end;
  FileSetAttr(FileName, FA);
  Result := True;
end;

function ValidPassInCryptGraphicFile(FileName, Password: String): Boolean;
var
  FS: TFileStream;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName);
  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if GraphicHeader.Version = 1 then
    begin
      FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
      CalcAnsiStringCRC32(AnsiString(Password), CRC);
      Result := GraphicHeaderV1.PassCRC = CRC;
    end;

    if GraphicHeader.Version = 2 then
    begin
      FS.Read(GraphicHeaderV2, SizeOf(TGraphicCryptFileHeaderV2));
      CalcStringCRC32(Password, CRC);
      Result := GraphicHeaderV2.PassCRC = CRC;
    end;
  finally
    F(FS);
  end;
end;

function ValidCryptGraphicFile(FileName: String): Boolean;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName);

  if FS = nil then
   Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    Result := GraphicHeader.ID = PhotoDBFileHeaderID;
  finally
    F(FS);
  end;
end;

function GetPasswordCRCFromCryptGraphicFile(FileName: String): Cardinal;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
begin
  Result := 0;

  TryOpenFSForRead(FS, FileName);

  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID = PhotoDBFileHeaderID then
    begin
      if GraphicHeader.Version = 1 then
      begin
        FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
        Result := GraphicHeaderV1.PassCRC;
      end;
      if GraphicHeader.Version = 2 then
      begin
        FS.Read(GraphicHeaderV2, SizeOf(TGraphicCryptFileHeaderV2));
        Result := GraphicHeaderV2.PassCRC;
      end;
    end;
  finally
    F(FS);
  end;
end;

function CryptBlobStream(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
  MS: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  Seed : Binary;
begin
  Result := False;
  MS := TMemoryStream.Create;
  try
    FBS := GetBlobStream(DF, bmRead);
    try
      FBS.Seek(0, soFromBeginning);
      FBS.Read(GraphicHeader, SizeOf(GraphicHeader));
      if GraphicHeader.ID = PhotoDBFileHeaderID then
        Exit;

      FBS.Seek(0, soFromBeginning);
    finally
      F(FBS);
    end;

    FBS := TADOBlobStream.Create(TBlobField(DF), bmWrite);
    try
      WriteCryptHeaderV2(FBS, MS, '', Password, CRYPT_OPTIONS_NORMAL, Seed);
      CryptStreamV2(MS, FBS, Password, Seed);
    finally
      F(FBS);
    end;
  finally
    F(MS);
  end;
  Result := True;
end;

function DeCryptBlobStreamJPG(DF: TField; Password: string; JPEG: TJpegImage) : Boolean;
var
  FBS: TStream;
  MS: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;

  MS := TMemoryStream.Create;
  try

    FBS := GetBlobStream(DF, BmRead);
    try
      FBS.Seek(0, SoFromBeginning);
      FBS.read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
      if GraphicHeader.ID <> PhotoDBFileHeaderID then
        Exit;

      if not DecryptStream(FBS, GraphicHeader, Password, MS) then
        Exit;

      MS.Seek(0, SoFromBeginning);
      JPEG.LoadFromStream(MS);
    finally
      F(FBS);
    end;
  finally
    F(MS);
  end;
  Result := True;
end;

function ValidCryptBlobStreamJPG(DF: TField): Boolean;
var
  FBS: TStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    Result := GraphicHeader.ID = PhotoDBFileHeaderID;
  finally
    F(FBS);
  end;
end;

function ValidPassInCryptBlobStreamJPG(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
begin
  Result := false;
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if GraphicHeader.Version = 1 then
    begin
      FBS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
      CalcAnsiStringCRC32(AnsiString(Password), CRC);
      Result := GraphicHeaderV1.PassCRC = CRC;
    end;

    if GraphicHeader.Version = 2 then
    begin
      FBS.Read(GraphicHeaderV2, SizeOf(TGraphicCryptFileHeaderV2));
      CalcStringCRC32(Password, CRC);
      Result := GraphicHeaderV2.PassCRC = CRC;
    end;

  finally
    F(FBS);
  end;
end;

function ResetPasswordInCryptBlobStreamJPG(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
  MS : TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;
  MS := TMemoryStream.Create;
  try
    FBS := GetBlobStream(DF, bmRead);
    try
      FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
      if GraphicHeader.ID <> PhotoDBFileHeaderID then
        Exit;

      if not DecryptStream(FBS, GraphicHeader, Password, MS) then
        Exit;

    finally
      F(FBS);
    end;

    FBS := GetBlobStream(DF, bmWrite);
    try
      MS.Seek(0, soBeginning);
      FBS.CopyFrom(MS, MS.Size);
    finally
      F(FBS);
    end;
  finally
    F(MS);
  end;
  Result := True;
end;

end.
