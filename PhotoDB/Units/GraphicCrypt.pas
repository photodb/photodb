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
    ID: array[0..7] of AnsiChar;
    Version: Byte;
    DBVersion: Byte;
  end;

  TMagicByte = array [0 .. 3] of Byte;
  TFileNameAnsi = array[0..254] of AnsiChar;

  TGraphicCryptFileHeaderV1 = record
    Version: Byte;
    Magic: Cardinal;
    FileSize: Cardinal;
    PassCRC: Cardinal;
    CRCFileExists: Boolean;
    CRCFile: Cardinal;
    TypeExtract: Byte;
    CryptFileName: Boolean;
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

function GetGraphicClass(EXT: String; ToSave: Boolean): TGraphicClass;
function CryptGraphicFileV1(FileName: String; Pass: String;
  Options: Integer): Boolean;
function DeCryptGraphicFileEx(FileName: String; Pass: String; var Pages: Word;
  LoadFullRAW: Boolean = false; Page: Word = 0): TGraphic;
function DeCryptGraphicFile(FileName: String; Pass: String;
  LoadFullRAW: Boolean = false; Page: Word = 0): TGraphic;
function ValidPassInCryptGraphicFile(FileName, Pass: String): Boolean;
function ResetPasswordInGraphicFile(FileName, Pass: String): Boolean;
function ChangePasswordInGraphicFile(FileName: String;
  OldPass, NewPass: String): Boolean;
function LoadFileNameFromCryptGraphicFile(FileName, Pass: String): String;
function ValidCryptGraphicFileA(FileName: String): Boolean;
function ValidCryptGraphicFile(FileName: String): Boolean;
function GetPasswordCRCFromCryptGraphicFile(FileName: String): Cardinal;

function CryptBlobStream(DF: TField; Pass: String): Boolean;
function CryptBlobStreamJPG(DF: TField; Image: TGraphic; Pass: String): Boolean;
function DeCryptBlobStreamJPG(DF: TField; Pass: string): TJpegImage; overload;
procedure DeCryptBlobStreamJPG(DF: TField; Pass: string; JPEG: TJpegImage);
  overload;
function ValidCryptBlobStreamJPG(DF: TField): Boolean;
function ValidPassInCryptBlobStreamJPG(DF: TField; Pass: String): Boolean;
function ResetPasswordInCryptBlobStreamJPG(DF: TField; Pass: String): Boolean;
function CryptGraphicImage(Image: TJpegImage; Pass: String): TMemoryStream;

implementation

uses CommonDBSupport, Dolphin_DB;

function GetExt(FileName: string): string;
var
  i, j: Integer;
  s: string;
begin
  j := 0;
  For i := length(FileName) downto 1 do
  begin
    If FileName[i] = '.' then
    begin
      j := i;
      break;
    end;
    If FileName[i] = '\' then
      break;
  end;
  s := '';
  If j <> 0 then
  begin
    s := copy(FileName, j + 1, length(FileName) - j);
    For i := 1 to length(s) do
      s[i] := Upcase(s[i]);
  end;
  result := s;
end;

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

function CryptGraphicFileV1W(FileName: String; Pass: String; Options: Integer;
  const Info; Size: Cardinal): Boolean;
var
  FS: TFileStream;
  x: array of Byte;
  i, LPass: Integer;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  FileCRC: Cardinal;
  fa, oldfa: Integer;
  c: Boolean;
  xcos: array [0 .. 1023] of Byte;
begin
  result := false;
  FS := nil;
  c := false;
  if not FileExists(FileName) then
    exit;
  for i := 1 to 20 do
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
  end;
  if not c then
    exit;
  SetLength(x, FS.Size);
  FS.Read(GraphicHeader, SizeOf(GraphicHeader));
  if GraphicHeader.ID = '.PHDBCRT' then
  begin
    FS.Free;
    exit;
  end;
  FS.Seek(0, soFromBeginning);
  FS.Read(Pointer(x)^, FS.Size);
  FS.Free;
  if Options = CRYPT_OPTIONS_SAVE_CRC then
  begin
    GraphicHeaderV1.CRCFileExists := true;
    CalcBufferCRC32(x, length(x), FileCRC);
    GraphicHeaderV1.CRCFile := FileCRC;
  end;
  if Options = CRYPT_OPTIONS_NORMAL then
  begin
    GraphicHeaderV1.CRCFileExists := false;
    GraphicHeaderV1.CRCFile := 0;
  end;
  LPass := length(Pass);
  Randomize;
  GraphicHeaderV1.Magic := Random( High(Integer));
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
  for i := 0 to 1023 do
    xcos[i] := Round(255 * cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4] + i));

  for i := 0 to length(x) - 1 do
    x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
        (Pass[i mod LPass + 1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
  try
    oldfa := FileGetAttr(FileName);
    fa := oldfa;
    if (fa and SysUtils.fahidden) <> 0 then
      fa := fa - SysUtils.fahidden;
    if (fa and SysUtils.faReadOnly) <> 0 then
      fa := fa - SysUtils.faReadOnly;
    if (fa and SysUtils.faSysFile) <> 0 then
      fa := fa - SysUtils.faSysFile;
    FileSetAttr(FileName, fa);
    FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
  except
    result := false;
    exit;
  end;
  GraphicHeader.ID := '.PHDBCRT';
  GraphicHeader.Version := 1;
  GraphicHeader.DBVersion := 0;
  FS.Write(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  GraphicHeaderV1.Version := 2; // !!!!!!!!!!!!!!!!!
  GraphicHeaderV1.FileSize := length(x);
  CalcStringCRC32(Pass, GraphicHeaderV1.PassCRC);
  GraphicHeaderV1.TypeExtract := 0;
  GraphicHeaderV1.CryptFileName := false;
  FillCharArray(GraphicHeaderV1.CFileName, ExtractFileName(FileName));
  GraphicHeaderV1.TypeFileNameExtract := 0;
  CalcStringCRC32(AnsiLowerCase(FileName), GraphicHeaderV1.FileNameCRC);
  GraphicHeaderV1.Displacement := 0;
  FS.Write(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
  if Size > 0 then
    FS.Write(Info, Size);
  FS.Write(Pointer(x)^, length(x));
  FS.Free;
  FileSetAttr(FileName, oldfa);
  result := true;
end;

function CryptGraphicImage(Image: TJpegImage; Pass: String): TMemoryStream;
var
  FS: TMemoryStream;
  x: array of Byte;
  i, LPass: Integer;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  xcos: array [0 .. 1023] of Byte;
begin
  FS := TMemoryStream.Create;
  Image.SaveToStream(FS);
  FS.Seek(0, soFromBeginning);
  SetLength(x, FS.Size);
  FS.Read(Pointer(x)^, FS.Size);
  FS.Free;
  GraphicHeaderV1.CRCFileExists := false;
  GraphicHeaderV1.CRCFile := 0;
  LPass := length(Pass);
  Randomize;
  GraphicHeaderV1.Magic := Random( High(Integer));
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
  for i := 0 to 1023 do
    xcos[i] := Round(255 * cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4] + i));

  for i := 0 to length(x) - 1 do
    x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
        (Pass[i mod LPass + 1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
  result := TMemoryStream.Create;
  GraphicHeader.ID := '.PHDBCRT';
  GraphicHeader.Version := 1;
  GraphicHeader.DBVersion := 0;
  result.Write(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  GraphicHeaderV1.Version := 2;
  GraphicHeaderV1.FileSize := length(x);
  CalcStringCRC32(Pass, GraphicHeaderV1.PassCRC);
  GraphicHeaderV1.TypeExtract := 0;
  GraphicHeaderV1.CryptFileName := false;
  GraphicHeaderV1.CFileName := '';
  GraphicHeaderV1.TypeFileNameExtract := 0;
  GraphicHeaderV1.FileNameCRC := 0;
  GraphicHeaderV1.Displacement := 0;
  result.Write(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
  result.Write(Pointer(x)^, length(x));
  SetLength(x, 0);
end;

function CryptGraphicFileV1(FileName: String; Pass: String;
  Options: Integer): Boolean;
begin
  result := CryptGraphicFileV1W(FileName, Pass, Options, result, Options);
end;

function DeCryptGraphicFile(FileName: String; Pass: String;
  LoadFullRAW: Boolean = false; Page: Word = 0): TGraphic;
var
  Pages: Word;
begin
  result := DeCryptGraphicFileEx(FileName, Pass, Pages, LoadFullRAW, Page);
end;

function DeCryptGraphicFileEx(FileName: String; Pass: String; var Pages: Word;
  LoadFullRAW: Boolean = false; Page: Word = 0): TGraphic;
var
  FS: TFileStream;
  x: array of Byte;
  i, LPass: Integer;
  CRC: Cardinal;
  TempStream: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  FileCRC: Cardinal;
  c: Boolean;
  xcos: array [0 .. 1024] of Byte;
begin
  result := nil;
  FS := nil;
  c := false;
  if not FileExists(FileName) then
    exit;
  for i := 1 to 20 do
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
  end;
  if not c then
    exit;
  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    FS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(Pass, CRC);
    if GraphicHeaderV1.PassCRC <> CRC then
    begin
      FS.Free;
      exit;
    end;
    if GraphicHeaderV1.Displacement > 0 then
      FS.Seek(GraphicHeaderV1.Displacement, soCurrent);
    SetLength(x, GraphicHeaderV1.FileSize);
    FS.Read(Pointer(x)^, GraphicHeaderV1.FileSize);
    FS.Free;
    LPass := length(Pass);

    if GraphicHeaderV1.Version = 1 then
    begin
      for i := 0 to length(x) - 1 do
        x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
            (Pass[i mod LPass + 1]));
    end;

    if GraphicHeaderV1.Version = 2 then
    begin
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
      for i := 0 to 1023 do
        xcos[i] := Round
          (255 * cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4] + i));

      for i := 0 to length(x) - 1 do
        x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
            (Pass[i mod LPass + 1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
    end;

    if GraphicHeaderV1.CRCFileExists then
    begin
      CalcBufferCRC32(x, length(x), FileCRC);
      if GraphicHeaderV1.CRCFile <> FileCRC then
        exit;
    end;
    TempStream := TMemoryStream.Create;
    TempStream.Seek(0, soFromBeginning);
    TempStream.WriteBuffer(Pointer(x)^, length(x));
    SetLength(x, 0);
    result := GetGraphicClass(GetExt(GraphicHeaderV1.CFileName), false).Create;
    TempStream.Seek(0, soFromBeginning);

    if LoadFullRAW then
      if result is TRAWImage then (result as TRAWImage)
        .LoadHalfSize := false;

    if Page = -1 then
    begin
      if not(result is TiffImageUnit.TTIFFGraphic) then
        result.LoadFromStream(TempStream)
      else
      begin (result as TiffImageUnit.TTIFFGraphic)
        .GetPagesCount(TempStream);
        Pages := (result as TiffImageUnit.TTIFFGraphic).Pages;
      end;
      // else do nothing - page will changed!
    end;
    if (result is TiffImageUnit.TTIFFGraphic) and (Page > -1) then
    begin (result as TiffImageUnit.TTIFFGraphic)
      .LoadFromStreamEx(TempStream, Page);
      Pages := (result as TiffImageUnit.TTIFFGraphic).Pages;
    end
    else
    begin
      result.LoadFromStream(TempStream);
    end;
    TempStream.Free;
  end;
end;

function ResetPasswordInGraphicFile(FileName, Pass: String): Boolean;
var
  FS: TFileStream;
  x: array of Byte;
  i, LPass: Integer;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  fa, oldfa: Integer;
  c: Boolean;
  xcos: array [0 .. 1023] of Byte;
begin
  result := false;
  c := false;
  FS := nil;
  if not FileExists(FileName) then
    exit;
  for i := 1 to 20 do
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
  end;
  if not c then
    exit;
  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    if FS <> nil then
      FS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(Pass, CRC);
    if GraphicHeaderV1.PassCRC <> CRC then
    begin
      FS.Free;
      exit;
    end;
    if GraphicHeaderV1.Displacement > 0 then
      FS.Seek(GraphicHeaderV1.Displacement, soCurrent);
    SetLength(x, GraphicHeaderV1.FileSize);
    FS.Read(Pointer(x)^, GraphicHeaderV1.FileSize);
    FS.Free;
    LPass := length(Pass);

    if GraphicHeaderV1.Version = 1 then
    begin
      for i := 0 to length(x) - 1 do
        x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
            (Pass[i mod LPass + 1]));
    end;
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
    for i := 0 to 1023 do
      xcos[i] := Round(255 * cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4] + i)
        );

    for i := 0 to length(x) - 1 do
      x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
          (Pass[i mod LPass + 1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
    try
      oldfa := FileGetAttr(FileName);
      fa := oldfa;
      if (fa and SysUtils.fahidden) <> 0 then
        fa := fa - SysUtils.fahidden;
      if (fa and SysUtils.faReadOnly) <> 0 then
        fa := fa - SysUtils.faReadOnly;
      if (fa and SysUtils.faSysFile) <> 0 then
        fa := fa - SysUtils.faSysFile;
      FileSetAttr(FileName, fa);
      FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
    except
      result := false;
      exit;
    end;
    FS.Write(Pointer(x)^, length(x));
    FS.Free;
    FileSetAttr(FileName, oldfa);
  end;
  result := true;
end;

function ChangePasswordInGraphicFile(FileName: String;
  OldPass, NewPass: String): Boolean;
var
  FS: TFileStream;
  x: array of Byte;
  i, LPass: Integer;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  c: Boolean;
begin
  result := false;
  c := false;
  FS := nil;
  if not FileExists(FileName) then
    exit;
  for i := 1 to 20 do
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
  end;
  if not c then
    exit;
  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    if FS <> nil then
      FS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(OldPass, CRC);
    if GraphicHeaderV1.PassCRC <> CRC then
    begin
      FS.Free;
      exit;
    end;
    if GraphicHeaderV1.Displacement > 0 then
      FS.Seek(GraphicHeaderV1.Displacement, soCurrent);
    SetLength(x, GraphicHeaderV1.FileSize);
    FS.Read(Pointer(x)^, GraphicHeaderV1.FileSize);
    FS.Free;
    LPass := length(OldPass);
    for i := 0 to length(x) - 1 do
      x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
          (OldPass[i mod LPass + 1]));
    LPass := length(NewPass);
    Randomize;
    GraphicHeaderV1.Magic := Random( High(Integer));
    CalcStringCRC32(NewPass, GraphicHeaderV1.PassCRC);
    for i := 0 to length(x) - 1 do
      x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
          (NewPass[i mod LPass + 1]));
    FS := TFileStream.Create(FileName, fmOpenWrite or fmCreate);
    FS.Write(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    FS.Write(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    FS.Write(Pointer(x)^, length(x));
    FS.Free;
    result := true;
  end;
end;

Function ValidPassInCryptGraphicFile(FileName, Pass: String): Boolean;
var
  FS: TFileStream;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  c: Boolean;
  i: Integer;
begin
  result := false;
  c := false;
  FS := nil;
  if not FileExists(FileName) then
    exit;
  for i := 1 to 20 do
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
  end;
  if not c then
    exit;

  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    if FS <> nil then
      FS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(Pass, CRC);
    if GraphicHeaderV1.PassCRC = CRC then
      result := true;
  end;
  FS.Free;
end;

function ValidCryptGraphicFile(FileName: String): Boolean;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
  c: Boolean;
  i: Integer;
{$IFDEF DBDEBUG}
  f: TextFile;
{$ENDIF}
begin
  result := false;
  c := false;
  if not FileExistsEx(FileName) then
    exit;
{$IFDEF DBDEBUG}
  Assign(f, FileName);
{$ENDIF}
  FS := nil;
  for i := 1 to 20 do
  begin
{$IFNDEF DBDEBUG}
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
{$ENDIF}
{$IFDEF DBDEBUG}
{$I-}
    Reset(f);
{$I+}
    if IOResult <> 0 then
    begin
      sleep(DelayReadFileOperation);
    end
    else
    begin
      Close(f);
      c := true;
      break;
    end;
{$ENDIF}
  end;
  if not c then
    exit;
{$IFDEF DBDEBUG}
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
{$ENDIF}
  if FS = nil then
    exit;
  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID = '.PHDBCRT' then
  begin
    result := true;
  end;
  FS.Free;
end;

function GetPasswordCRCFromCryptGraphicFile(FileName: String): Cardinal;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  c: Boolean;
  i: Integer;
{$IFDEF DBDEBUG}
  f: TextFile;
{$ENDIF}
begin
  result := 0;
  c := false;
  if not FileExists(FileName) then
    exit;
{$IFDEF DBDEBUG}
  Assign(f, FileName);
{$ENDIF}
  FS := nil;
  for i := 1 to 20 do
  begin
{$IFNDEF DBDEBUG}
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
{$ENDIF}
{$IFDEF DBDEBUG}
{$I-}
    Reset(f);
{$I+}
    if IOResult <> 0 then
    begin
      sleep(DelayReadFileOperation);
    end
    else
    begin
      Close(f);
      c := true;
      break;
    end;
{$ENDIF}
  end;
  if not c then
    exit;
{$IFDEF DBDEBUG}
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
{$ENDIF}
  if FS = nil then
    exit;
  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID = '.PHDBCRT' then
  begin
    FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    result := GraphicHeaderV1.PassCRC;
  end;
  FS.Free;
end;

Function ValidCryptGraphicFileA(FileName: String): Boolean;
var
  FS: TFileStream;
  GraphicHeader: TGraphicCryptFileHeader;
  c: Boolean;
  i: Integer;
begin
  result := false;
  c := false;
  FS := nil;
  for i := 1 to 20 do
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      c := true;
      break;
    except
      sleep(DelayReadFileOperation);
    end;
  end;
  if not c then
    exit;
  if FS = nil then
    exit;
  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID = '.PHDBCRT' then
  begin
    result := true;
  end;
  FS.Free;
end;

Function LoadFileNameFromCryptGraphicFile(FileName, Pass: String): String;
var
  FS: TFileStream;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  result := '';
  try
    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  except
    exit;
  end;
  FS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    FS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(Pass, CRC);
    if GraphicHeaderV1.PassCRC = CRC then
      result := GraphicHeaderV1.CFileName;
  end;
  FS.Free;
end;

function CryptBlobStream(DF: TField; Pass: String): Boolean;
var
  FBS: TStream;
  x: array of Byte;
  i, LPass: Integer;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  xcos: array [0 .. 1023] of Byte;
begin
  result := false;
  FBS := GetBlobStream(DF, bmRead);
  FBS.Seek(0, soFromBeginning);
  SetLength(x, FBS.Size);
  FBS.Read(GraphicHeader, SizeOf(GraphicHeader));
  if GraphicHeader.ID = '.PHDBCRT' then
  begin
    FBS.Free;
    exit;
  end;
  FBS.Seek(0, soFromBeginning);
  FBS.Read(Pointer(x)^, FBS.Size);
  FBS.Free;
  LPass := length(Pass);
  Randomize;
  GraphicHeaderV1.Magic := Random( High(Integer));

  for i := 0 to 1023 do
    xcos[i] := Round(255 * cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4] + i));

  for i := 0 to length(x) - 1 do
    x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
        (Pass[i mod LPass + 1])) xor xcos[i mod 1024];

  FBS := TADOBlobStream.Create(TBlobField(DF), bmWrite);
  GraphicHeader.ID := '.PHDBCRT';
  GraphicHeader.Version := 1;
  GraphicHeader.DBVersion := 0;
  FBS.Write(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  GraphicHeaderV1.Version := 2;
  GraphicHeaderV1.FileSize := length(x);
  CalcStringCRC32(Pass, GraphicHeaderV1.PassCRC);
  GraphicHeaderV1.CRCFileExists := false;
  GraphicHeaderV1.CRCFile := 0;
  GraphicHeaderV1.TypeExtract := 0;
  GraphicHeaderV1.CryptFileName := false;
  GraphicHeaderV1.CFileName := '';
  GraphicHeaderV1.TypeFileNameExtract := 0;
  GraphicHeaderV1.FileNameCRC := 0;
  GraphicHeaderV1.Displacement := 0;
  FBS.Write(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
  FBS.Write(Pointer(x)^, length(x));
  FBS.Free;
  result := true;
end;

function CryptBlobStreamJPG(DF: TField; Image: TGraphic; Pass: String): Boolean;
begin
  result := false;
end;

function DeCryptBlobStreamJPG(DF: TField; Pass: String): TJpegImage;
begin
  result := TJpegImage.Create;
  DeCryptBlobStreamJPG(DF, Pass, result);
end;

procedure DeCryptBlobStreamJPG(DF: TField; Pass: string; JPEG: TJpegImage);
  overload;
var
  FBS: TStream;
  x: array of Byte;
  i, LPass: Integer;
  CRC: Cardinal;
  TempStream: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  xcos: array [0 .. 1023] of Byte;
begin
  FBS := GetBlobStream(DF, bmRead);
  FBS.Seek(0, soFromBeginning);
  FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    FBS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FBS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(Pass, CRC);
    if GraphicHeaderV1.PassCRC <> CRC then
    begin
      FBS.Free;
      exit;
    end;
    if GraphicHeaderV1.Displacement > 0 then
      FBS.Seek(GraphicHeaderV1.Displacement, soCurrent);
    SetLength(x, GraphicHeaderV1.FileSize);
    FBS.Read(Pointer(x)^, GraphicHeaderV1.FileSize);
    FBS.Free;
    LPass := length(Pass);

    if GraphicHeaderV1.Version = 1 then
    begin
      for i := 0 to length(x) - 1 do
        x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
            (Pass[i mod LPass + 1]));
    end;
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
    for i := 0 to 1023 do
      xcos[i] := Round(255 * cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4] + i)
        );

    for i := 0 to length(x) - 1 do
      x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
          (Pass[i mod LPass + 1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
    TempStream := TMemoryStream.Create;
    TempStream.Seek(0, soFromBeginning);
    TempStream.WriteBuffer(Pointer(x)^, length(x));
    TempStream.Seek(0, soFromBeginning);
    JPEG.LoadFromStream(TempStream);
    TempStream.Free;
  end;
end;

function ValidCryptBlobStreamJPG(DF: TField): Boolean;
var
  FBS: TStream;
  GraphicHeader: TGraphicCryptFileHeader;
begin
  result := false;
  FBS := GetBlobStream(DF, bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    result := GraphicHeader.ID = '.PHDBCRT';
  finally
    FBS.Free;
  end;
end;

function ValidPassInCryptBlobStreamJPG(DF: TField; Pass: String): Boolean;
var
  FBS: TStream;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  result := false;
  FBS := GetBlobStream(DF, bmRead);
  FBS.Seek(0, soFromBeginning);
  FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    FBS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FBS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(Pass, CRC);
    if GraphicHeaderV1.PassCRC = CRC then
      result := true;
  end;
  FBS.Free;
end;

function ResetPasswordInCryptBlobStreamJPG(DF: TField; Pass: String): Boolean;
var
  FBS: TStream;
  x: array of Byte;
  i, LPass: Integer;
  CRC: Cardinal;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
  xcos: array [0 .. 1023] of Byte;
begin
  result := false;
  FBS := GetBlobStream(DF, bmRead);
  FBS.Seek(0, soFromBeginning);
  FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
  if GraphicHeader.ID <> '.PHDBCRT' then
  begin
    FBS.Free;
    exit;
  end;
  if GraphicHeader.Version = 1 then
  begin
    FBS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    CalcStringCRC32(Pass, CRC);
    if GraphicHeaderV1.PassCRC <> CRC then
    begin
      FBS.Free;
      exit;
    end;
    if GraphicHeaderV1.Displacement > 0 then
      FBS.Seek(GraphicHeaderV1.Displacement, soCurrent);
    SetLength(x, GraphicHeaderV1.FileSize);
    FBS.Read(Pointer(x)^, GraphicHeaderV1.FileSize);
    FBS.Free;
    LPass := length(Pass);

    if GraphicHeaderV1.Version = 1 then
    begin
      for i := 0 to length(x) - 1 do
        x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
            (Pass[i mod LPass + 1]));
    end;
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
    for i := 0 to 1023 do
      xcos[i] := Round(255 * cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4] + i)
        );

    for i := 0 to length(x) - 1 do
      x[i] := x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte
          (Pass[i mod LPass + 1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
    FBS := GetBlobStream(DF, bmWrite);
    FBS.Write(Pointer(x)^, length(x));
    FBS.Free;
  end;
end;

end.
