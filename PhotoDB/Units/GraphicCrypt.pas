unit GraphicCrypt;

interface

//{$DEFINE EXT}

uses win32crc, Windows, SysUtils, Classes, Graphics, ADODB,
     JPEG, PngImage, PngDef, TiffImageUnit, uFileUtils,
{$IFNDEF EXT}
     GraphicEx, RAWImage, uConstants,
{$ENDIF}
     GIFImage, DB;

//{$DEFINE DBDEBUG}

type

 TCryptImageOptions = record
  Password : String;
  CryptFileName : Boolean;
  SaveFileCRC : Boolean;
  end;

 TGraphicCryptFileHeader = record
  ID : string[8];
  Version : Byte;
  DBVersion : Byte;
 end;

 TMagicByte = array[0..3] of byte;

 TGraphicCryptFileHeaderV1 = record
  Version : byte;
  Magic : Cardinal;
  FileSize : Cardinal;
  PassCRC : Cardinal;
  CRCFileExists : Boolean;
  CRCFile : Cardinal;
  TypeExtract : Byte;
  CryptFileName : Boolean;
  CFileName : string[255];
  TypeFileNameExtract : byte;
  FileNameCRC : Cardinal;
  Displacement : Cardinal;
 end;

 TDBInfoInGraphicFile = Record
  FileNameSize : Cardinal;
  
 end;

 const

 CRYPT_OPTIONS_NORMAL        = 0;
 CRYPT_OPTIONS_SAVE_CRC      = 1;

function GetGraphicClass(EXT : String; ToSave : boolean) : TGraphicClass;
function CryptGraphicFileV1(FileName : String; Pass : String; Options : Integer) : boolean;
function DeCryptGraphicFileEx(FileName : String; Pass : String; var Pages : Word; LoadFullRAW : boolean = false; Page : Word = 0) : TGraphic;
function DeCryptGraphicFile(FileName : String; Pass : String; LoadFullRAW : boolean = false; Page : Word = 0) : TGraphic;
function ValidPassInCryptGraphicFile(FileName, Pass : String) : boolean;
function ResetPasswordInGraphicFile(FileName, Pass : String) : boolean;
function ChangePasswordInGraphicFile(FileName : String; OldPass, NewPass : String) : boolean;
function LoadFileNameFromCryptGraphicFile(FileName, Pass : String) : String;
function ValidCryptGraphicFileA(FileName : String) : boolean;
function ValidCryptGraphicFile(FileName : String) : boolean;
function GetPasswordCRCFromCryptGraphicFile(FileName : String) : Cardinal;


function CryptBlobStream(DF : TField; Pass : String) : boolean;
function CryptBlobStreamJPG(DF : TField; Image : TGraphic; Pass : String) : boolean;
function DeCryptBlobStreamJPG(DF : TField; Pass : String) : TGraphic;
function ValidCryptBlobStreamJPG(DF : TField) : boolean;
function ValidPassInCryptBlobStreamJPG(DF : TField; Pass : String) : boolean;
function ResetPasswordInCryptBlobStreamJPG(DF : TField; Pass : String) : boolean;
function CryptGraphicImage(Image : TJpegImage; Pass : String) : TMemoryStream;

implementation

uses CommonDBSupport;

Function GetExt(Filename : string) : string;
var
  i,j:integer;
  s:string;
begin
 j:=0;
 For i:=length(filename) downto 1 do
 begin
  If filename[i]='.' then
  begin
   j:=i;
   break;
  end;
  If filename[i]='\' then break;
 end;
 s:='';
 If j<>0 then
 begin
  s:=copy(filename,j+1,length(filename)-j);
  For i:=1 to length(s) do
  s[i]:=Upcase(s[i]);
 end;
 result:=s;
end;

function GetGraphicClass(EXT : String; ToSave : boolean) : TGraphicClass;
begin
 Ext := AnsiLowerCase(Ext);
 Result:=nil;
 if Ext = 'bmp' then Result := TBitmap
 else if Ext = 'jpg' then Result := TJPEGImage   
 else if Ext = 'thm' then Result := TJPEGImage
 else if Ext = 'jpeg' then Result := TJPEGImage
 else if Ext = 'ico' then Result := TIcon
 else if Ext = 'wmf' then Result := TMetaFile
 else if Ext = 'emf' then Result := TMetaFile
 else if Ext = 'jfif' then Result := TJPEGImage
 else if Ext = 'jpe' then Result := TJPEGImage
 else if Ext = 'rle' then Result := TBitmap
 else if Ext = 'dib' then Result := TBitmap
{$IFNDEF EXT}
 else if Ext = 'win' then Result := TTargaGraphic
 else if Ext = 'vst' then Result := TTargaGraphic
 else if Ext = 'vda' then Result := TTargaGraphic
 else if Ext = 'tga' then Result := TTargaGraphic
 else if Ext = 'icb' then Result := TTargaGraphic
 else if Ext = 'tiff' then Result := TiffImageUnit.TTIFFGraphic
 else if Ext = 'tif' then Result := TiffImageUnit.TTIFFGraphic
 else if Ext = 'fax' then Result := TiffImageUnit.TTIFFGraphic
 else if Ext = 'eps' then Result := TEPSGraphic
 else if Ext = 'pcx' then Result := TPCXGraphic
 else if Ext = 'pcc' then Result := TPCXGraphic
 else if Ext = 'scr' then Result := TPCXGraphic
 else if Ext = 'rpf' then Result := TRLAGraphic
 else if Ext = 'rla' then Result := TRLAGraphic
 else if Ext = 'sgi' then Result := TSGIGraphic
 else if Ext = 'rgba' then Result := TSGIGraphic
 else if Ext = 'rgb' then Result := TSGIGraphic
 else if Ext = 'bw' then Result := TSGIGraphic
 else if Ext = 'psd' then Result := TPSDGraphic
 else if Ext = 'pdd' then Result := TPSDGraphic
 else if Ext = 'ppm' then Result := TPPMGraphic
 else if Ext = 'pgm' then Result := TPPMGraphic
 else if Ext = 'pbm' then Result := TPPMGraphic
 else if Ext = 'cel' then Result := TAutodeskGraphic
 else if Ext = 'pic' then Result := TAutodeskGraphic
 else if Ext = 'pcd' then Result := TPCDGraphic
 else if Ext = 'gif' then Result := TGIFImage
 else if Ext = 'cut' then Result := TCUTGraphic
 else if Ext = 'psp' then Result := TPSPGraphic    

 else if Ext = 'cr2' then Result := TRAWImage

 else if Ext = 'png' then
 begin
  if ToSave then
  Result := PngImage.TPNGGraphic else
  Result := GraphicEx.TPNGGraphic;
 end;
 // PNG_CAN_SAVE MANUALLY processing
// else if Ext = 'png' then begin if PNG_CAN_SAVE then Result := PngImage.TPNGGraphic else  Result := GraphicEx.TPNGGraphic;  end;
{$ENDIF}
end;

function CryptGraphicFileV1W(FileName : String; Pass : String; Options : Integer; const Info; Size : Cardinal) : boolean;
var
 FS : TFileStream;
 x : array of byte;
 i, LPass : integer;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 FileCRC : Cardinal;
 fa, oldfa : integer;
 c : Boolean;
 xcos : array[0..1023] of byte;
begin
 Result:=false;
 FS:=nil;
 c:=false;
 if not FileExists(FileName) then exit;
 for i:=1 to 20 do
 begin
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   sleep(DelayReadFileOperation);
  end;
 end;
 if not c then exit;
 SetLength(x,FS.Size);
 FS.Read(GraphicHeader,SizeOf(GraphicHeader));
 if GraphicHeader.ID='.PHDBCRT' then
 begin
  FS.Free;
  exit;
 end;
 FS.Seek(0,soFromBeginning);
 FS.Read(Pointer(x)^,FS.Size);
 FS.free;
 if Options=CRYPT_OPTIONS_SAVE_CRC then
 begin
  GraphicHeaderV1.CRCFileExists:=true;
  CalcBufferCRC32(x,Length(x),FileCRC);
  GraphicHeaderV1.CRCFile:=FileCRC;
 end;
 if Options=CRYPT_OPTIONS_NORMAL then
 begin
  GraphicHeaderV1.CRCFileExists:=false;
  GraphicHeaderV1.CRCFile:=0;
 end;
 LPass:=length(Pass);
 Randomize;
 GraphicHeaderV1.Magic:=Random(High(Integer));

{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
 for i:=0 to 1023 do
 xcos[i]:=Round(255*cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4]+i));

 for i:=0 to Length(x)-1 do
 x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}

 try
  oldfa:=FileGetAttr(FileName);
  fa:=oldfa;
  if (fa and SysUtils.fahidden)<>0 then fa:=fa-SysUtils.fahidden;
  if (fa and SysUtils.faReadOnly)<>0 then fa:=fa-SysUtils.faReadOnly;
  if (fa and SysUtils.faSysFile)<>0 then fa:=fa-SysUtils.faSysFile;
  FileSetAttr(FileName,fa);
  FS:=TFileStream.Create(FileName,fmOpenWrite or fmCreate);
 except
  Result:=false;
  exit;
 end;
 GraphicHeader.ID:='.PHDBCRT';
 GraphicHeader.Version:=1;
 GraphicHeader.DBVersion:=0;
 FS.Write(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 GraphicHeaderV1.Version:=2; //!!!!!!!!!!!!!!!!!
 GraphicHeaderV1.FileSize:=Length(x);
 CalcStringCRC32(Pass,GraphicHeaderV1.PassCRC);
 GraphicHeaderV1.TypeExtract:=0;
 GraphicHeaderV1.CryptFileName:=false;
 GraphicHeaderV1.CFileName:=ExtractFileName(FileName);
 GraphicHeaderV1.TypeFileNameExtract:=0;
 CalcStringCRC32(AnsiLowerCase(FileName),GraphicHeaderV1.FileNameCRC);
 GraphicHeaderV1.Displacement:=0;
 FS.Write(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
 if Size>0 then
 FS.Write(Info,Size);
 FS.Write(Pointer(x)^,Length(x));
 FS.Free;
 FileSetAttr(FileName,oldfa);
 Result:=true;
end;

function CryptGraphicImage(Image : TJpegImage; Pass : String) : TMemoryStream;
var
 FS : TMemoryStream;
 x : array of byte;
 i, LPass : integer;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 xcos : array[0..1023] of byte;
begin
 FS:=TMemoryStream.Create;
 Image.SaveToStream(FS);
 FS.Seek(0,soFromBeginning);
 SetLength(x,FS.Size);
 FS.Read(Pointer(x)^,FS.Size);
 FS.free;
 GraphicHeaderV1.CRCFileExists:=false;
 GraphicHeaderV1.CRCFile:=0;
 LPass:=length(Pass);
 Randomize;
 GraphicHeaderV1.Magic:=Random(High(Integer));

{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
 for i:=0 to 1023 do
 xcos[i]:=Round(255*cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4]+i));

 for i:=0 to Length(x)-1 do
 x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}

 Result:=TMemoryStream.Create;
 GraphicHeader.ID:='.PHDBCRT';
 GraphicHeader.Version:=1;
 GraphicHeader.DBVersion:=0;
 Result.Write(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 GraphicHeaderV1.Version:=2;
 GraphicHeaderV1.FileSize:=Length(x);
 CalcStringCRC32(Pass,GraphicHeaderV1.PassCRC);
 GraphicHeaderV1.TypeExtract:=0;
 GraphicHeaderV1.CryptFileName:=false;
 GraphicHeaderV1.CFileName:='';
 GraphicHeaderV1.TypeFileNameExtract:=0;
 GraphicHeaderV1.FileNameCRC:=0;
 GraphicHeaderV1.Displacement:=0;
 Result.Write(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
 Result.Write(Pointer(x)^,Length(x));
 SetLength(x,0);
end;

function CryptGraphicFileV1(FileName : String; Pass : String; Options : Integer) : boolean;
begin
 Result:=CryptGraphicFileV1W(FileName, Pass, Options, result, Options);
end;

function DeCryptGraphicFile(FileName : String; Pass : String; LoadFullRAW : boolean = false; Page : Word = 0) : TGraphic;
var
  Pages : Word;
begin
  Result:=DeCryptGraphicFileEx(FileName, Pass, Pages, LoadFullRAW, Page);
end;

function DeCryptGraphicFileEx(FileName : String; Pass : String; var Pages : Word; LoadFullRAW : boolean = false; Page : Word = 0) : TGraphic;
var
 FS : TFileStream;
 x : array of byte;
 i, Lpass : integer;
 CRC : Cardinal;
 TempStream : TMemoryStream;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 FileCRC : Cardinal;
 c : Boolean;
 xcos : array[0..1024] of byte;
begin
 Result:=nil;
 FS:=nil;
 c:=false;
 if not FileExists(FileName) then exit;
 for i:=1 to 20 do
 begin
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   sleep(DelayReadFileOperation);
  end;
 end;
 if not c then exit;
 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  FS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC<>CRC then
  begin
   FS.Free;
   exit;
  end;
  if GraphicHeaderV1.Displacement>0 then
  FS.Seek(GraphicHeaderV1.Displacement,soCurrent);
  SetLength(x,GraphicHeaderV1.FileSize);
  FS.Read(Pointer(x)^,GraphicHeaderV1.FileSize);
  FS.Free;
  Lpass:=Length(Pass);

  if GraphicHeaderV1.Version=1 then
  begin
   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1]));
  end;

  if GraphicHeaderV1.Version=2 then
  begin
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
   for i:=0 to 1023 do
   xcos[i]:=Round(255*cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4]+i));

   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
  end;


  if GraphicHeaderV1.CRCFileExists then
  begin
   CalcBufferCRC32(x,Length(x),FileCRC);
   if GraphicHeaderV1.CRCFile<>FileCRC then
   exit;
  end;
  TempStream := TMemoryStream.Create;
  TempStream.Seek(0,soFromBeginning);
  TempStream.WriteBuffer(Pointer(x)^,Length(x));
  SetLength(x,0);
  Result:=GetGraphicClass(GetExt(GraphicHeaderV1.CFileName),false).Create;
  TempStream.Seek(0,soFromBeginning);
  
  if LoadFullRAW then
  if Result is TRAWImage then
  (Result as TRAWImage).LoadHalfSize:=false;

  if Page=-1 then
  begin
   if not (Result is TiffImageUnit.TTIFFGraphic) then
   Result.LoadFromStream(TempStream) else
   begin
    (Result as TiffImageUnit.TTIFFGraphic).GetPagesCount(TempStream);   
    Pages:=(Result as TiffImageUnit.TTIFFGraphic).Pages;
   end;
   //else do nothing - page will changed!
  end;
  if (Result is TiffImageUnit.TTIFFGraphic) and (Page>-1) then
  begin
   (Result as TiffImageUnit.TTIFFGraphic).LoadFromStreamEx(TempStream,Page);
   Pages:=(Result as TiffImageUnit.TTIFFGraphic).Pages;
  end else
  begin
   Result.LoadFromStream(TempStream);
  end;
  TempStream.Free;
 end;
end;

function ResetPasswordInGraphicFile(FileName, Pass : String) : boolean;
var
 FS : TFileStream;
 x : array of byte;
 i, Lpass : integer;
 CRC : Cardinal;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 fa, oldfa : integer;
 c : boolean;
 xcos : array[0..1023] of byte;
begin
 Result:=false;
 c:=false;
 fs:=nil;
 if not FileExists(FileName) then exit;
 for i:=1 to 20 do
 begin
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   sleep(DelayReadFileOperation);
  end;
 end;
 if not c then exit;
 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  if FS<>nil then FS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC<>CRC then
  begin
   FS.Free;
   exit;
  end;
  if GraphicHeaderV1.Displacement>0 then
  FS.Seek(GraphicHeaderV1.Displacement,soCurrent);
  SetLength(x,GraphicHeaderV1.FileSize);
  FS.Read(Pointer(x)^,GraphicHeaderV1.FileSize);
  FS.Free;
  Lpass:=Length(Pass);

  if GraphicHeaderV1.Version=1 then
  begin
   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1]));
  end;

{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
   for i:=0 to 1023 do
   xcos[i]:=Round(255*cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4]+i));

   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}


  try
   oldFA:=FileGetAttr(FileName);
   fa:=oldfa;
   if (FA and SysUtils.fahidden)<>0 then FA:=FA-SysUtils.fahidden;
   if (FA and SysUtils.faReadOnly)<>0 then FA:=FA-SysUtils.faReadOnly;
   if (FA and SysUtils.faSysFile)<>0 then FA:=FA-SysUtils.faSysFile;
   FileSetAttr(FileName,FA);
   FS:=TFileStream.Create(FileName,fmOpenWrite or fmCreate);
  except
   Result:=false;
   exit;
  end;
  FS.Write(Pointer(x)^,Length(x));
  FS.Free;
  FileSetAttr(FileName,oldfa);
 end;
 Result:=true;
end;

function ChangePasswordInGraphicFile(FileName : String; OldPass, NewPass : String) : boolean;
var
 FS : TFileStream;
 x : array of byte;
 i, Lpass : integer;
 CRC : Cardinal;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 c : Boolean;
begin
 Result:=false;
 c:=false;
 FS:=nil;
 if not FileExists(FileName) then exit;
 for i:=1 to 20 do
 begin
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   sleep(DelayReadFileOperation);
  end;
 end;
 if not c then exit;
 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  if FS<>nil then FS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(OldPass,CRC);
  if GraphicHeaderV1.PassCRC<>CRC then
  begin
   FS.Free;
   exit;
  end;
  if GraphicHeaderV1.Displacement>0 then
  FS.Seek(GraphicHeaderV1.Displacement,soCurrent);
  SetLength(x,GraphicHeaderV1.FileSize);
  FS.Read(Pointer(x)^,GraphicHeaderV1.FileSize);
  FS.Free;
  Lpass:=Length(OldPass);
  for i:=0 to Length(x)-1 do
  x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(OldPass[i mod Lpass+1]));
  Lpass:=Length(NewPass);
  Randomize;
  GraphicHeaderV1.Magic:=Random(High(Integer));
  CalcStringCRC32(NewPass,GraphicHeaderV1.PassCRC);
  for i:=0 to Length(x)-1 do
  x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(NewPass[i mod Lpass+1]));
  FS:=TFileStream.Create(FileName,fmOpenWrite or fmCreate);
  FS.Write(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
  FS.Write(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  FS.Write(Pointer(x)^,Length(x));
  FS.Free;
  Result:=true;
 end;
end;

Function ValidPassInCryptGraphicFile(FileName, Pass : String) : boolean;
var
 FS : TFileStream;
 CRC : Cardinal;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 c : Boolean;
 i : integer;
begin
 Result:=false;
 c:=false;
 FS:=nil;
 if not FileExists(FileName) then exit;
 for i:=1 to 20 do
 begin
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   sleep(DelayReadFileOperation);
  end;
 end;
 if not c then exit;

 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  if FS<>nil then FS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC=CRC then
  Result:=true;
 end;
 FS.free;
end;

function ValidCryptGraphicFile(FileName : String) : boolean;
var
 FS : TFileStream;
 GraphicHeader : TGraphicCryptFileHeader;
 c : boolean;
 i : integer;

{$IFDEF DBDEBUG}
 f : TextFile;
{$ENDIF}

begin
 Result:=false;
 c:=false;
 if not FileExistsEx(FileName) then exit;
 {$IFDEF DBDEBUG}
 Assign(F,FileName);
 {$ENDIF}
 FS:=nil;
 for i:=1 to 20 do
 begin

  {$IFNDEF DBDEBUG}
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   Sleep(DelayReadFileOperation);
  end;
  {$ENDIF}
  {$IFDEF DBDEBUG}
  {$I-}
  Reset(F);
  {$I+}
  if IOResult<>0 then
  begin
   Sleep(DelayReadFileOperation);
  end else
  begin
   Close(F);
   c:=true;
   break;
  end;
  {$ENDIF}
 end;
 if not c then exit;

{$IFDEF DBDEBUG}
 FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
{$ENDIF}
 if FS=nil then exit;
 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID='.PHDBCRT' then
 begin
  Result:=true;
 end;
 FS.Free;
end;

function GetPasswordCRCFromCryptGraphicFile(FileName : String) : Cardinal;
var
 FS : TFileStream;
 GraphicHeader : TGraphicCryptFileHeader; 
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 c : boolean;
 i : integer;

{$IFDEF DBDEBUG}
 f : TextFile;
{$ENDIF}

begin
 Result:=0;
 c:=false;
 if not FileExists(FileName) then exit;
 {$IFDEF DBDEBUG}
 Assign(F,FileName);
 {$ENDIF}
 FS:=nil;
 for i:=1 to 20 do
 begin

  {$IFNDEF DBDEBUG}
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   Sleep(DelayReadFileOperation);
  end;
  {$ENDIF}
  {$IFDEF DBDEBUG}
  {$I-}
  Reset(F);
  {$I+}
  if IOResult<>0 then
  begin
   Sleep(DelayReadFileOperation);
  end else
  begin
   Close(F);
   c:=true;
   break;
  end;
  {$ENDIF}
 end;
 if not c then exit;

{$IFDEF DBDEBUG}
 FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
{$ENDIF}
 if FS=nil then exit;
 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID='.PHDBCRT' then
 begin
  FS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  Result:=GraphicHeaderV1.PassCRC;
 end;
 FS.Free;
end;

Function ValidCryptGraphicFileA(FileName : String) : boolean;
var
 FS : TFileStream;
 GraphicHeader : TGraphicCryptFileHeader;
 c : boolean;
 i : integer;
begin
 Result:=false;
 c:=false;
 FS:=nil;
 for i:=1 to 20 do
 begin
  try
   FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
   c:=true;
   break;
  except
   sleep(DelayReadFileOperation);
  end;
 end;
 if not c then exit;  
 if FS=nil then exit;
 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID='.PHDBCRT' then
 begin
  Result:=true;
 end;
 FS.Free;
end;

Function LoadFileNameFromCryptGraphicFile(FileName, Pass : String) : String;
var
 FS : TFileStream;
 CRC : Cardinal;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
begin
 Result:='';
 try
  FS:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
 except
  exit;
 end;
 FS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  FS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC=CRC then
  Result:=GraphicHeaderV1.CFileName;
 end;
 FS.free;
end;

function CryptBlobStream(DF : TField; Pass : String) : boolean;
var
 FBS : TStream;
 x : array of byte;
 i, LPass : integer;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 xcos : array[0..1023] of byte;
begin
 Result:=false;
 FBS:=GetBlobStream(DF,bmRead);   
 FBS.Seek(0,soFromBeginning);
 SetLength(x,FBS.Size);
 FBS.Read(GraphicHeader,SizeOf(GraphicHeader));
 if GraphicHeader.ID='.PHDBCRT' then
 begin
  FBS.Free;
  exit;
 end;
 FBS.Seek(0,soFromBeginning);
 FBS.Read(Pointer(x)^,FBS.Size);
 FBS.Free;
 LPass:=length(Pass);
 Randomize;
 GraphicHeaderV1.Magic:=Random(High(Integer));

 for i:=0 to 1023 do
 xcos[i]:=Round(255*cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4]+i));

 for i:=0 to Length(x)-1 do
 x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1])) xor xcos[i mod 1024];

 FBS:=TADOBlobStream.Create(TBlobField(DF),bmWrite);
 GraphicHeader.ID:='.PHDBCRT';
 GraphicHeader.Version:=1;
 GraphicHeader.DBVersion:=0;
 FBS.Write(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 GraphicHeaderV1.Version:=2;
 GraphicHeaderV1.FileSize:=Length(x);
 CalcStringCRC32(Pass,GraphicHeaderV1.PassCRC);
 GraphicHeaderV1.CRCFileExists:=false;
 GraphicHeaderV1.CRCFile:=0;
 GraphicHeaderV1.TypeExtract:=0;
 GraphicHeaderV1.CryptFileName:=false;
 GraphicHeaderV1.CFileName:='';
 GraphicHeaderV1.TypeFileNameExtract:=0;
 GraphicHeaderV1.FileNameCRC:=0;
 GraphicHeaderV1.Displacement:=0;
 FBS.Write(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
 FBS.Write(Pointer(x)^,Length(x));
 FBS.Free;
 Result:=true;
end;

function CryptBlobStreamJPG(DF : TField; Image : TGraphic; Pass : String) : boolean;
begin
 result:=false;
end;

function DeCryptBlobStreamJPG(DF : TField; Pass : String) : TGraphic;
var
 FBS : TStream;
 x : array of byte;
 i, Lpass : integer;
 CRC : Cardinal;
 TempStream : TMemoryStream;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
  xcos : array[0..1023] of byte;
begin
 Result:=nil;
 FBS:=GetBlobStream(DF,bmRead);  
 FBS.Seek(0,soFromBeginning);
 FBS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  FBS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FBS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC<>CRC then
  begin
   FBS.Free;
   exit;
  end;
  if GraphicHeaderV1.Displacement>0 then
  FBS.Seek(GraphicHeaderV1.Displacement,soCurrent);
  SetLength(x,GraphicHeaderV1.FileSize);
  FBS.Read(Pointer(x)^,GraphicHeaderV1.FileSize);
  FBS.Free;
  Lpass:=Length(Pass);


  if GraphicHeaderV1.Version=1 then
  begin
   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1]));
  end;

{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
   for i:=0 to 1023 do
   xcos[i]:=Round(255*cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4]+i));

   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}



  TempStream := TMemoryStream.Create;
  TempStream.Seek(0,soFromBeginning);
  TempStream.WriteBuffer(Pointer(x)^,Length(x));
  Result:=TJpegImage.Create;
  TempStream.Seek(0,soFromBeginning);
  Result.LoadFromStream(TempStream);
  TempStream.Free;
 end;
end;

function ValidCryptBlobStreamJPG(DF : TField) : boolean;
var
  FBS : TStream;
  GraphicHeader : TGraphicCryptFileHeader;
begin
  Result := False;
  FBS := GetBlobStream(DF,bmRead);
  try
    FBS.Seek(0, soFromBeginning);
    FBS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    Result := GraphicHeader.ID = '.PHDBCRT';
  finally
    FBS.Free;
  end;
end;

function ValidPassInCryptBlobStreamJPG(DF : TField; Pass : String) : boolean;
var
 FBS : TStream;
 CRC : Cardinal;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
begin
 Result:=false;
 FBS:=GetBlobStream(DF,bmRead);   
 FBS.Seek(0,soFromBeginning);
 FBS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  FBS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FBS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC=CRC then
  Result:=true;
 end;
 FBS.free;
end;

function ResetPasswordInCryptBlobStreamJPG(DF : TField; Pass : String) : boolean;
var
 FBS : TStream;
 x : array of byte;
 i, Lpass : integer;
 CRC : Cardinal;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
 xcos : array[0..1023] of byte;
begin
 Result:=false;
 FBS:=GetBlobStream(DF,bmRead);   
 FBS.Seek(0,soFromBeginning);
 FBS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  FBS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  FBS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC<>CRC then
  begin
   FBS.Free;
   exit;
  end;
  if GraphicHeaderV1.Displacement>0 then
  FBS.Seek(GraphicHeaderV1.Displacement,soCurrent);
  SetLength(x,GraphicHeaderV1.FileSize);
  FBS.Read(Pointer(x)^,GraphicHeaderV1.FileSize);
  FBS.Free;
  Lpass:=Length(Pass);

  if GraphicHeaderV1.Version=1 then
  begin
   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1]));
  end;

{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
   for i:=0 to 1023 do
   xcos[i]:=Round(255*cos(TMagicByte(GraphicHeaderV1.Magic)[i mod 4]+i));

   for i:=0 to Length(x)-1 do
   x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4] xor Byte(Pass[i mod Lpass+1])) xor xcos[i mod 1024];
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}


  FBS:=GetBlobStream(DF,bmWrite);
  FBS.Write(Pointer(x)^,Length(x));
  FBS.Free;
 end;
end;

end.
