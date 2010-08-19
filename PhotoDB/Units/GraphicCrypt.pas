unit GraphicCrypt;

interface

uses win32crc, Windows, SysUtils, Classes, Graphics, ADODB,
  JPEG, PngImage, PngDef, TiffImageUnit, uFileUtils,
  GraphicEx, RAWImage, uConstants,
  GIFImage, DB;

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

  TDBInfoInGraphicFile = record
    FileNameSize: Cardinal;
  end;

const

  CRYPT_OPTIONS_NORMAL = 0;
  CRYPT_OPTIONS_SAVE_CRC = 1;
  PhotoDBFileHeaderID = '.PHDBCRT';

function GetGraphicClass(EXT: string; ToSave: Boolean): TGraphicClass;
function CryptGraphicFileV1(FileName: string; Password: AnsiString; Options: Integer): Boolean;
function DeCryptGraphicFileEx(FileName: string; Password: string; var Pages: Word;
  LoadFullRAW: Boolean = false; Page: Word = 0): TGraphic;
function DeCryptGraphicFile(FileName: string; Password: string;
  LoadFullRAW: Boolean = false; Page: Word = 0): TGraphic;
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
procedure CryptGraphicImage(Image: TJpegImage; Password: string; MS : TMemoryStream);

implementation

uses CommonDBSupport, Dolphin_DB;

function GetGraphicClass(EXT: String; ToSave: Boolean): TGraphicClass;
begin
  EXT := AnsiLowerCase(EXT);
  result := nil;
  if EXT = 'bmp' then
    result := TBitmap
  else if EXT = 'jpg' then
    result := TJpegImage
  else if EXT = 'thm' then
    result := TJpegImage
  else if EXT = 'jpeg' then
    result := TJpegImage
  else if EXT = 'ico' then
    result := TIcon
  else if EXT = 'wmf' then
    result := TMetaFile
  else if EXT = 'emf' then
    result := TMetaFile
  else if EXT = 'jfif' then
    result := TJpegImage
  else if EXT = 'jpe' then
    result := TJpegImage
  else if EXT = 'rle' then
    result := TBitmap
  else if EXT = 'dib' then
    result := TBitmap
{$IFNDEF EXT}
  else if EXT = 'win' then
    result := TTargaGraphic
  else if EXT = 'vst' then
    result := TTargaGraphic
  else if EXT = 'vda' then
    result := TTargaGraphic
  else if EXT = 'tga' then
    result := TTargaGraphic
  else if EXT = 'icb' then
    result := TTargaGraphic
  else if EXT = 'tiff' then
    result := TiffImageUnit.TTIFFGraphic
  else if EXT = 'tif' then
    result := TiffImageUnit.TTIFFGraphic
  else if EXT = 'fax' then
    result := TiffImageUnit.TTIFFGraphic
  else if EXT = 'eps' then
    result := TEPSGraphic
  else if EXT = 'pcx' then
    result := TPCXGraphic
  else if EXT = 'pcc' then
    result := TPCXGraphic
  else if EXT = 'scr' then
    result := TPCXGraphic
  else if EXT = 'rpf' then
    result := TRLAGraphic
  else if EXT = 'rla' then
    result := TRLAGraphic
  else if EXT = 'sgi' then
    result := TSGIGraphic
  else if EXT = 'rgba' then
    result := TSGIGraphic
  else if EXT = 'rgb' then
    result := TSGIGraphic
  else if EXT = 'bw' then
    result := TSGIGraphic
  else if EXT = 'psd' then
    result := TPSDGraphic
  else if EXT = 'pdd' then
    result := TPSDGraphic
  else if EXT = 'ppm' then
    result := TPPMGraphic
  else if EXT = 'pgm' then
    result := TPPMGraphic
  else if EXT = 'pbm' then
    result := TPPMGraphic
  else if EXT = 'cel' then
    result := TAutodeskGraphic
  else if EXT = 'pic' then
    result := TAutodeskGraphic
  else if EXT = 'pcd' then
    result := TPCDGraphic
  else if EXT = 'gif' then
    result := TGIFImage
  else if EXT = 'cut' then
    result := TCUTGraphic
  else if EXT = 'psp' then
    result := TPSPGraphic

  else if Pos('|' + AnsiUpperCase(EXT) + '|', RAWImages) > -1 then
    result := TRAWImage

  else if EXT = 'png' then
  begin
    if ToSave then
      result := PngImage.TPNGGraphic
    else
      result := GraphicEx.TPNGGraphic;
  end;
  // PNG_CAN_SAVE MANUALLY processing
  // else if Ext = 'png' then begin if PNG_CAN_SAVE then Result := PngImage.TPNGGraphic else  Result := GraphicEx.TPNGGraphic;  end;
{$ENDIF}
end;

procedure FillCharArray(var CharAray : TFileNameAnsi; Str : String);
var
  I : Integer;
begin
  for I := 1 to Length(Str) do
    CharAray[I] := AnsiChar(Str[I]);

  CharAray[Length(Str) + 1] := #0;
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
    x[I] := x[I] xor (TMagicByte(Magic)[I mod 4] xor Byte
        (Password[I mod LPass + 1])) xor xcos[I mod 1024];
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
end;

procedure TryOpenFSForRead(var FS: TFileStream; FileName : string);
var
  I : Integer;
begin
  FS := nil;

  if not FileExistsEx(FileName) then
    Exit;

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

function CryptGraphicFileV1W(FileName: string; Password: AnsiString; Options: Integer;
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
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
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

procedure CryptGraphicImage(Image: TJpegImage; Password: String; MS : TMemoryStream);
var
  FS: TMemoryStream;
  X: TByteArray;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  FS := TMemoryStream.Create;
  try
    Image.SaveToStream(FS);
    FS.Seek(0, soFromBeginning);
    SetLength(X, FS.Size);
    FS.Read(Pointer(X)^, FS.Size);
  finally
    FS.Free;
  end;

  WriteCryptHeaderV1(FS, X, '', Password, CRYPT_OPTIONS_NORMAL, GraphicHeaderV1);
  CryptArrayByteV1(X, GraphicHeaderV1.Magic, Password);
  MS.Write(Pointer(X)^, Length(X));
  SetLength(X, 0);
end;

function CryptGraphicFileV1(FileName: string; Password: AnsiString;
  Options: Integer): Boolean;
begin
  Result := CryptGraphicFileV1W(FileName, Password, Options, Result, Options);
end;

function DeCryptGraphicFile(FileName: string; Password: String;
  LoadFullRAW: Boolean = False; Page: Word = 0): TGraphic;
var
  Pages: Word;
begin
  Result := DeCryptGraphicFileEx(FileName, Password, Pages, LoadFullRAW, Page);
end;

function DecryptStreamToByteArray(Stream : TStream; GraphicHeader: TGraphicCryptFileHeader; Password : string; var X : TByteArray) : Boolean;
var
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  AnsiPassword : AnsiString;
  FileCRC, CRC : Cardinal;
  I, LPass : Integer;
  XCos: array [0 .. 1023] of Byte;
begin
  Result := False;
  if GraphicHeader.Version = 1 then
  begin
    AnsiPassword := Password;
    Stream.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(AnsiPassword, CRC);
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

    Result := True;
  end;
  //TODO: new algoritm place here
end;

function DeCryptGraphicFileEx(FileName: String; Password: String; var Pages: Word;
  LoadFullRAW: Boolean = False; Page: Word = 0): TGraphic;
var
  FS: TFileStream;
  X: TByteArray;
  TempStream: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := nil;

  TryOpenFSForRead(FS, FileName);
  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStreamToByteArray(FS, GraphicHeader, Password, X) then
      Exit;

    TempStream := TMemoryStream.Create;
    try
      TempStream.Seek(0, soFromBeginning);
      TempStream.WriteBuffer(Pointer(X)^, length(X));
      SetLength(X, 0);
      Result := GetGraphicClass(GetExt(GraphicHeaderV1.CFileName), False).Create;
      TempStream.Seek(0, soFromBeginning);

      if (Result is TRAWImage) then
        (Result as TRAWImage).LoadHalfSize := not LoadFullRAW
      else if (Result is TiffImageUnit.TTIFFGraphic) then
      begin

        if Page = -1 then
          (Result as TiffImageUnit.TTIFFGraphic).GetPagesCount(TempStream)
        else
          (result as TiffImageUnit.TTIFFGraphic).LoadFromStreamEx(TempStream, Page);

        Pages := (result as TiffImageUnit.TTIFFGraphic).Pages;

      end else
        Result.LoadFromStream(TempStream);

    finally
      TempStream.Free;
    end;
  finally
    FS.Free;
  end;
end;

function ResetPasswordInGraphicFile(FileName, Password: String): Boolean;
var
  FS: TFileStream;
  X: TByteArray;
  GraphicHeader: TGraphicCryptFileHeader;
  FA: Integer;
begin
  Result := false;
  FS := nil;

  TryOpenFSForRead(FS, FileName);

  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStreamToByteArray(FS, GraphicHeader, Password, X) then
      Exit;

  finally
    FS.Free;
  end;

  FA := FileGetAttr(FileName);
  ResetFileattributes(FileName, FA);

  FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
  try
    FS.Write(Pointer(X)^, length(X));
  finally
    FS.Free;
  end;
  FileSetAttr(FileName, FA);
  Result := True;
end;

function ChangePasswordInGraphicFile(FileName: String;
  OldPass, NewPass: String): Boolean;
var
  FS: TFileStream;
  X: TByteArray;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  FA : Cardinal;
begin
  Result := false;

  TryOpenFSForRead(FS, FileName);

  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStreamToByteArray(FS, GraphicHeader, OldPass, X) then
      Exit;

  finally
    FS.Free;
  end;
  Fa := FileGetAttr(FileName);
  ResetFileattributes(FileName, FA);

  FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
  try
    WriteCryptHeaderV1(FS, X, FileName, NewPass, CRYPT_OPTIONS_SAVE_CRC, GraphicHeaderV1);
    CryptArrayByteV1(X, GraphicHeaderV1.Magic, NewPass);
    FS.Write(Pointer(X)^, length(X));
  finally
    FS.Free;
  end;

  FileSetAttr(FileName, FA);
  Result := True;
end;

Function ValidPassInCryptGraphicFile(FileName, Password: String): Boolean;
var
  FS: TFileStream;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  I: Integer;
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
      CalcStringCRC32(Password, CRC);
      Result := GraphicHeaderV1.PassCRC = CRC;
    end;
  finally
    FS.Free;
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
    FS.Free;
  end;
end;

function GetPasswordCRCFromCryptGraphicFile(FileName: String): Cardinal;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := 0;

  TryOpenFSForRead(FS, FileName);

  if FS = nil then
    Exit;

  try
    FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID = PhotoDBFileHeaderID then
    begin
      FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
      Result := GraphicHeaderV1.PassCRC;
    end;
  finally
    FS.Free;
  end;
end;

function CryptBlobStream(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
  X: TByteArray;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := False;
  SetLength(X, 0);
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    SetLength(X, FBS.Size);
    FBS.Read(GraphicHeader, SizeOf(GraphicHeader));
    if GraphicHeader.ID = PhotoDBFileHeaderID then
      Exit;

    FBS.Seek(0, soFromBeginning);
    FBS.Read(Pointer(X)^, FBS.Size);
  finally
    FBS.Free;
  end;

  FBS := TADOBlobStream.Create(TBlobField(DF), bmWrite);
  try
    WriteCryptHeaderV1(FBS, X, '', Password, CRYPT_OPTIONS_NORMAL, GraphicHeaderV1);
    CryptArrayByteV1(X, GraphicHeaderV1.Magic, Password);
    FBS.Write(Pointer(X)^, length(X));
  finally
    FBS.Free;
  end;
  Result := True;
end;

function DeCryptBlobStreamJPG(DF: TField; Password: string; JPEG: TJpegImage) : Boolean;
var
  FBS: TStream;
  X: TByteArray;
  MS: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStreamToByteArray(FBS, GraphicHeader, Password, X) then
      Exit;

    MS := TMemoryStream.Create;
    try
      MS.Seek(0, soFromBeginning);
      MS.WriteBuffer(Pointer(X)^, Length(X));
      MS.Seek(0, soFromBeginning);
      JPEG.LoadFromStream(MS);
    finally
      MS.Free;
    end;
  finally
    FBS.Free;
  end;
  Result := True;
end;

function ValidCryptBlobStreamJPG(DF: TField): Boolean;
var
  FBS: TStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  Result := False;
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    Result := GraphicHeader.ID = PhotoDBFileHeaderID;
  finally
    FBS.Free;
  end;
end;

function ValidPassInCryptBlobStreamJPG(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
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
      CalcStringCRC32(Password, CRC);
      Result := GraphicHeaderV1.PassCRC = CRC;
    end;
  finally
    FBS.Free;
  end;
end;

function ResetPasswordInCryptBlobStreamJPG(DF: TField; Password: String): Boolean;
var
  FBS: TStream;
  X: TByteArray;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := False;
  SetLength(X, 0);
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> PhotoDBFileHeaderID then
      Exit;

    if not DecryptStreamToByteArray(FBS, GraphicHeader, Password, X) then
      Exit;
  finally
    FBS.Free;
  end;

  FBS := GetBlobStream(DF, bmWrite);
  try
    FBS.Write(Pointer(X)^, Length(X));
  finally
    FBS.Free;
  end;
  Result := True;
end;

end.
