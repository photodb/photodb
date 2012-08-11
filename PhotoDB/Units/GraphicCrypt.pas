unit GraphicCrypt;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  win32crc,
  Windows,
  SysUtils,
  Classes,
  Graphics,
  ADODB,
  JPEG,
  PngImage,
  uFileUtils,
  uAssociations,
  uTiffImage,
  GraphicEx,
  RAWImage,
  uConstants,
  uStrongCrypt,
  uTransparentEncryption,
  DECUtil,
  DECCipher,
  GIFImage,
  DB,
  uMemoryUtils,
  uErrors,
  uGraphicUtils,
  uShellUtils,
  CommonDBSupport;

const
  CRYPT_OPTIONS_NORMAL = 0;
  CRYPT_OPTIONS_SAVE_CRC = 1;

function CryptGraphicFileV2(FileName: string; Password: string; Options: Integer): Integer;
function DeCryptGraphicFileEx(FileName: string; Password: string; var Pages: Word;
  LoadFullRAW: Boolean = false; Page: Integer = 0): TGraphic;
function DeCryptGraphicFile(FileName: string; Password: string;
  LoadFullRAW: Boolean = false; Page: Integer = 0): TGraphic;
function DecryptGraphicFileToStream(FileName, Password: string; S: TStream): Boolean;
function ValidPassInCryptGraphicFile(FileName, Password: string): Boolean;
function ResetPasswordInGraphicFile(FileName, Password: string): Integer;
function ChangePasswordInGraphicFile(FileName: string; OldPass, NewPass: string): Integer;
function ValidCryptGraphicFile(FileName: string): Boolean;
function ValidCryptGraphicStream(Stream: TStream): Boolean;
function GetPasswordCRCFromCryptGraphicFile(FileName: string): Cardinal;

function CryptBlobStream(DF: TField; Password: string): Boolean;
function DeCryptBlobStreamJPG(DF: TField; Password: string; JPEG: TJpegImage): Boolean;
function ValidCryptBlobStreamJPG(DF: TField): Boolean;
function ValidPassInCryptBlobStreamJPG(DF: TField; Password: string): Boolean;
function ResetPasswordInCryptBlobStreamJPG(DF: TField; Password: string): Boolean;
procedure CryptGraphicImage(Image: TJpegImage; Password: string; Dest: TMemoryStream);
function DecryptFileToStream(FileName: string; Password: string; Stream: TStream): Boolean;
function DecryptStreamToStream(Src, Dest: TStream; Password: string): Boolean;
procedure CryptStream(S, D: TStream; Password: string; Options: Integer; FileName: string);
function ValidPassInCryptStream(S: TStream; Password: String): Boolean;
function SaveNewStreamForEncryptedFile(FileName: String; Password: string; Stream: TStream): Integer;

implementation

procedure FatalSaveStream(S: TStream; OriginalFileName: string);
var
  FileName: string;

  function SaveToFile(FileName: string): Boolean;
  var
    FS: TFileStream;
  begin
    Result := False;
    try
      FS := TFileStream.Create(FileName, fmCreate);
      try
        S.Seek(0, soFromBeginning);
        FS.CopyFrom(S, S.Size);
        Result := True;
      finally
        F(FS);
      end;
    except
      Exit;
    end;
  end;

begin
  FileName := ExtractFilePath(OriginalFileName) + ExtractFileName(OriginalFileName) + '.dump';
  if not SaveToFile(FileName) then
    SaveToFile(GetTempFileName + '.crypt_dump');
end;

procedure FillCharArray(var CharAray: TFileNameUnicode; Str: string);
var
  I: Integer;
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

{procedure WriteCryptHeaderV2(Stream: TStream; Src: TStream; FileName: string; Password: string; Options: Integer;
  var Seed: Binary);
var
  FileCRC: Cardinal;
  GraphicHeader: TEncryptedFileHeader;
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
  Stream.Write(GraphicHeader, SizeOf(TEncryptedFileHeader));
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
end; }

procedure CryptStream(S, D: TStream; Password: string; Options: Integer; FileName: string);
var
  Chipper: TDECCipherClass;
begin
  Chipper := ValidCipher(nil);
  EncryptStreamEx(S, D, Password, FileName, Chipper, nil);
end;

function CryptGraphicFileV2W(FileName: string; Password: string; Options: Integer): Integer;
var
  FS: TFileStream;
  MS: TMemoryStream;
  FA: Integer;
  GraphicHeader: TEncryptedFileHeader;
begin
  MS := TMemoryStream.Create;
  try

    try
      TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
      if FS = nil then
      begin
        Result := CRYPT_RESULT_ERROR_READING_FILE;
        Exit;
      end;

      try
        FS.Read(GraphicHeader, SizeOf(GraphicHeader));
        if GraphicHeader.ID = PhotoDBFileHeaderID then
        begin
          Result := CRYPT_RESULT_ALREADY_CRYPT;
          Exit;
        end;

        FS.Seek(0, SoFromBeginning);
        MS.CopyFrom(Fs, FS.Size);
        MS.Position := 0;
      finally
        F(FS);
      end;
    except
      Result := CRYPT_RESULT_ERROR_READING_FILE;
      Exit;
    end;

    FA := FileGetAttr(FileName);
    ResetFileAttributes(FileName, FA);

    try
      FS := TFileStream.Create(FileName, FmOpenWrite or FmCreate);
      try
        try
          CryptStream(MS, FS, Password, Options, FileName);
        except
          //if any error in this block - user can lost original data, so we had to save it in any case
          FatalSaveStream(MS, FileName);
          raise;
        end;
      finally
        F(FS);
      end;
    except
      Result := CRYPT_RESULT_ERROR_WRITING_FILE;
      Exit;
    end;
  finally
    F(MS);
  end;
  FileSetAttr(FileName, FA);
  Result := CRYPT_RESULT_OK;
end;

procedure CryptGraphicImage(Image: TJpegImage; Password: string; Dest: TMemoryStream);
var
  MS: TMemoryStream;
//  Seed: Binary;
  ACipher: TDECCipherClass;
begin
  MS := TMemoryStream.Create;
  try
    Image.SaveToStream(MS);
    MS.Seek(0, soFromBeginning);

    ACipher := ValidCipher(nil);
    EncryptStreamEx(MS, Dest, Password, '', ACipher, nil);

    //WriteCryptHeaderV2(Dest, MS, '', Password, CRYPT_OPTIONS_NORMAL, Seed);
    //CryptStreamV2(MS, Dest, Password, Seed);
  finally
    F(MS);
  end;
end;

function CryptGraphicFileV2(FileName: string; Password: string;
  Options: Integer): Integer;
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

function DecryptStream(Stream: TStream; GraphicHeader: TEncryptedFileHeader;
  Password: string; MS: TStream): Boolean;
var
  AnsiPassword: AnsiString;
  FileCRC, CRC: Cardinal;
  I, LPass: Integer;
  XCos: array [0 .. 1023] of Byte;
  X: TByteArray;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
  GraphicHeaderEx1: TEncryptFileHeaderExV1;
  Chipper: TDECCipherClass;
begin
  Result := False;
  if GraphicHeader.Version = ENCRYPT_FILE_VERSION_BASIC then
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

      for I := 0 to length(X) - 1 do
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
  end else if GraphicHeader.Version = ENCRYPT_FILE_VERSION_STRONG then
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
  end else if GraphicHeader.Version = ENCRYPT_FILE_VERSION_TRANSPARENT then
  begin
    StrongCryptInit;

    Stream.Read(GraphicHeaderEx1, SizeOf(TEncryptFileHeaderExV1));
    CalcStringCRC32(Password, CRC);
    if GraphicHeaderEx1.PassCRC <> CRC then
      Exit;

    if GraphicHeaderEx1.Displacement > 0 then
      Stream.Seek(GraphicHeaderEx1.Displacement, soCurrent);

    Chipper := CipherByIdentity(GraphicHeaderEx1.Algorith);
    DeCryptStreamV2(Stream, MS, Password, SeedToBinary(GraphicHeaderEx1.Seed), GraphicHeaderEx1.FileSize, Chipper);
    Result := True;
  end;
end;

function DecryptGraphicFileToStream(FileName, Password: string; S: TStream): Boolean;
var
  FS: TFileStream;
  GraphicHeader: TEncryptedFileHeader;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStream(FS, GraphicHeader, Password, S) then
      Exit;

    S.Seek(0, soFromBeginning);
    Result := True;
  finally
    F(FS);
  end;
end;

function DecryptStreamToStream(Src, Dest: TStream; Password: string): Boolean;
var
  GraphicHeader: TEncryptedFileHeader;
begin
  Result := False;
  Src.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
  if GraphicHeader.ID <> PhotoDBFileHeaderID then
    Exit;

  if not DecryptStream(Src, GraphicHeader, Password, Dest) then
    Exit;

  Dest.Seek(0, soFromBeginning);

  Result := True;
end;

function DecryptFileToStream(FileName: string; Password: string; Stream: TStream): Boolean;
var
  FS: TFileStream;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
  if FS = nil then
    Exit;

  try
    Result := DecryptStreamToStream(FS, Stream, Password);
  finally
    F(FS);
  end;
end;

function SaveNewStreamForEncryptedFile(FileName: String; Password: string; Stream: TStream): Integer;
var
//  Seed: Binary;
  FS: TFileStream;
  MS: TMemoryStream;
  ACipher: TDECCipherClass;
begin
  Result := CRYPT_RESULT_UNDEFINED;

  TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
  if FS = nil then
    Exit;

  try
    if ValidPassInCryptStream(FS, Password) then
    begin
      F(FS);

      MS := TMemoryStream.Create;
      try
        ACipher := ValidCipher(nil);

        EncryptStreamEx(Stream, MS, Password, '', ACipher, nil);

        //WriteCryptHeaderV2(MS, Stream, '', Password, CRYPT_OPTIONS_NORMAL, Seed);
        //CryptStreamV2(Stream, MS, Password, Seed);
        try
          FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
          try
            try
              MS.Seek(0, soFromBeginning);
              FS.CopyFrom(MS, MS.Size);
            except
              //if any error in this block - user can lost original data, so we had to save it in any case
              FatalSaveStream(MS, FileName);
              raise;
            end;
          finally
            F(FS);
          end;
        except
          Result := CRYPT_RESULT_ERROR_WRITING_FILE;
          Exit;
        end;
      finally
        F(MS);
      end;

    end;

  finally
    F(FS);
  end;

  Result := CRYPT_RESULT_OK;
end;

//TODO: remove this function
function DeCryptGraphicFileEx(FileName: string; Password: string; var Pages: Word;
  LoadFullRAW: Boolean = False; Page: Integer = 0): TGraphic;
var
  FS: TFileStream;
  MS: TMemoryStream;
  GraphicHeader: TEncryptedFileHeader;
  GraphicClass : TGraphicClass;
begin
  Result := nil;

  MS := TMemoryStream.Create;
  try
    TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
    if FS = nil then
      Exit;

    try
      FS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
      if GraphicHeader.ID <> PhotoDBFileHeaderID then
        Exit;

      if not DecryptStream(FS, GraphicHeader, Password, MS) then
        Exit;

      MS.Seek(0, soFromBeginning);
      GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
      if GraphicClass = nil then
        Exit;

      Result := GraphicClass.Create;
      InitGraphic(Result);
      if (Result is TRAWImage) then
         (Result as TRAWImage).IsPreview := not LoadFullRAW;

      if (Result is TTiffImage) then
      begin
        if Page = -1 then
          (Result as TTiffImage).GetPagesCount(MS)
        else
          (Result as TTiffImage).LoadFromStreamEx(MS, Page);

        Pages := (Result as TTiffImage).Pages;

      end else
        Result.LoadFromStream(MS);

    finally
      F(FS);
    end;
  finally
    F(MS);
  end;
end;

function ResetPasswordInGraphicFile(FileName, Password: String): Integer;
var
  FS: TFileStream;
  MS: TMemoryStream;
  GraphicHeader: TEncryptedFileHeader;
  FA: Integer;
begin
  Result := CRYPT_RESULT_UNDEFINED;

  MS := TMemoryStream.Create;
  try

    try
      TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
      if FS = nil then
        Exit;

      try
        FS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
        if GraphicHeader.ID <> PhotoDBFileHeaderID then
          Exit;

        if not DecryptStream(FS, GraphicHeader, Password, MS) then
          Exit;

      finally
        F(FS);
      end;
    except
      Result := CRYPT_RESULT_ERROR_READING_FILE;
      Exit;
    end;

    FA := FileGetAttr(FileName);
    ResetFileAttributes(FileName, FA);

    try
      FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
      try
        try
          MS.Seek(0, soFromBeginning);
          FS.CopyFrom(MS, MS.Size);
        except
          //if any error in this block - user can lost original data, so we had to save it in any case
          FatalSaveStream(MS, FileName);
          raise;
        end;
      finally
        F(FS);
      end;
    except
      Result := CRYPT_RESULT_ERROR_WRITING_FILE;
      Exit;
    end;
  finally
    F(MS);
  end;
  FileSetAttr(FileName, FA);
  Result := CRYPT_RESULT_OK;
end;

function ChangePasswordInGraphicFile(FileName: String; OldPass, NewPass: String): Integer;
var
  FS: TFileStream;
  MS: TMemoryStream;
  GraphicHeader: TEncryptedFileHeader;
  FA: Cardinal;
//  Seed: Binary;
  ACipher: TDECCipherClass;
begin
  Result := CRYPT_RESULT_UNDEFINED;

  MS := TMemoryStream.Create;
  try
    try
      TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
      if FS = nil then
        Exit;

      try
        FS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
        if GraphicHeader.ID <> PhotoDBFileHeaderID then
          Exit;

        if not DecryptStream(FS, GraphicHeader, OldPass, MS) then
          Exit;

      finally
        F(FS);
      end;
    except
      Result := CRYPT_RESULT_ERROR_READING_FILE;
      Exit;
    end;
    FA := FileGetAttr(FileName);
    ResetFileattributes(FileName, FA);

    try
      FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
      try
        try
          ACipher := ValidCipher(nil);
          EncryptStreamEx(MS, FS, NewPass, '', ACipher, nil);

          //WriteCryptHeaderV2(FS, MS, FileName, NewPass, CRYPT_OPTIONS_SAVE_CRC, Seed);
          //CryptStreamV2(MS, FS, NewPass, Seed);
        except
          //if any error in this block - user can lost original data, so we had to save it in any case
          FatalSaveStream(MS, FileName);
          raise;
        end;
      finally
        F(FS);
      end;

    except
      Result := CRYPT_RESULT_ERROR_WRITING_FILE;
      Exit;
    end;

  finally
    F(MS);
  end;
  FileSetAttr(FileName, FA);
  Result := CRYPT_RESULT_OK;
end;

function ValidPassInCryptGraphicFile(FileName, Password: String): Boolean;
var
  FS: TFileStream;
  CRC: Cardinal;
  GraphicHeader: TEncryptedFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
  GraphicHeaderEx1: TEncryptFileHeaderExV1;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if GraphicHeader.Version = ENCRYPT_FILE_VERSION_BASIC then
    begin
      FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
      CalcAnsiStringCRC32(AnsiString(Password), CRC);
      Result := GraphicHeaderV1.PassCRC = CRC;
    end;

    if GraphicHeader.Version = ENCRYPT_FILE_VERSION_STRONG then
    begin
      FS.Read(GraphicHeaderV2, SizeOf(TGraphicCryptFileHeaderV2));
      CalcStringCRC32(Password, CRC);
      Result := GraphicHeaderV2.PassCRC = CRC;
    end;

    if GraphicHeader.Version = ENCRYPT_FILE_VERSION_TRANSPARENT then
    begin
      FS.Read(GraphicHeaderEx1, SizeOf(GraphicHeaderEx1));
      CalcStringCRC32(Password, CRC);
      Result := GraphicHeaderEx1.PassCRC = CRC;
    end;
  finally
    F(FS);
  end;
end;

function ValidCryptGraphicStream(Stream: TStream): Boolean;
var
  GraphicHeader: TEncryptedFileHeader;
  Pos: Int64;
begin
  Pos := Stream.Position;
  Stream.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
  Result := GraphicHeader.ID = PhotoDBFileHeaderID;
  Stream.Seek(Pos, soFromBeginning);
end;

function ValidCryptGraphicFile(FileName: String): Boolean;
var
  FS: TFileStream;
begin
  Result := False;

  TryOpenFSForRead(FS, FileName, DelayReadFileOperation);
  if FS = nil then
   Exit;

  try
    Result := ValidCryptGraphicStream(FS);
  finally
    F(FS);
  end;
end;

function GetPasswordCRCFromCryptGraphicFile(FileName: String): Cardinal;
var
  FS: TFileStream;
  GraphicHeader: TEncryptedFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
begin
  Result := 0;

  TryOpenFSForRead(FS, FileName, DelayReadFileOperation);

  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
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
  GraphicHeader: TEncryptedFileHeader;
//  Seed: Binary;
  ACipher: TDECCipherClass;
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
      ACipher := ValidCipher(nil);
      EncryptStreamEx(MS, FBS, Password, '', ACipher, nil);

      //WriteCryptHeaderV2(FBS, MS, '', Password, CRYPT_OPTIONS_NORMAL, Seed);
      //CryptStreamV2(MS, FBS, Password, Seed);
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
  GraphicHeader: TEncryptedFileHeader;
begin
  Result := False;

  MS := TMemoryStream.Create;
  try

    FBS := GetBlobStream(DF, BmRead);
    try
      FBS.Seek(0, SoFromBeginning);
      FBS.read(GraphicHeader, SizeOf(TEncryptedFileHeader));
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
  GraphicHeader: TEncryptedFileHeader;
begin
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    FBS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
    Result := GraphicHeader.ID = PhotoDBFileHeaderID;
  finally
    F(FBS);
  end;
end;

function ValidPassInCryptStream(S: TStream; Password: String): Boolean;
var
  CRC: Cardinal;
  GraphicHeader: TEncryptedFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  GraphicHeaderV2: TGraphicCryptFileHeaderV2;
begin
  Result := False;

  S.Seek(0, soFromBeginning);
  S.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
  if GraphicHeader.ID <> PhotoDBFileHeaderID then
    Exit;

  if GraphicHeader.Version = 1 then
  begin
    S.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcAnsiStringCRC32(AnsiString(Password), CRC);
    Result := GraphicHeaderV1.PassCRC = CRC;
  end;

  if GraphicHeader.Version = 2 then
  begin
    S.Read(GraphicHeaderV2, SizeOf(TGraphicCryptFileHeaderV2));
    CalcStringCRC32(Password, CRC);
    Result := GraphicHeaderV2.PassCRC = CRC;
  end;
end;

function ValidPassInCryptBlobStreamJPG(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
begin
  FBS := GetBlobStream(DF, bmRead);
  try
    Result := ValidPassInCryptStream(FBS, Password);
  finally
    F(FBS);
  end;
end;

function ResetPasswordInCryptBlobStreamJPG(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
  MS : TMemoryStream;
  GraphicHeader: TEncryptedFileHeader;
begin
  Result := False;
  MS := TMemoryStream.Create;
  try
    FBS := GetBlobStream(DF, bmRead);
    try
      FBS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
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
