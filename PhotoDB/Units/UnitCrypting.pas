unit UnitCrypting;

interface

uses dolphin_db, GraphicCrypt, Language, DB, Windows, SysUtils,
     UnitDBKernel, Classes, Win32Crc, UnitDBDeclare;

const

  CRYPT_RESULT_UNDEFINED         = 0;
  CRYPT_RESULT_OK                = 1;
  CRYPT_RESULT_FAILED_CRYPT      = 2;
  CRYPT_RESULT_FAILED_CRYPT_FILE = 3;
  CRYPT_RESULT_FAILED_CRYPT_DB   = 4;
  CRYPT_RESULT_PASS_INCORRECT    = 5;
  CRYPT_RESULT_PASS_DIFFERENT    = 6;
  CRYPT_RESULT_ALREADY_CRYPT     = 7;
  CRYPT_RESULT_ALREADY_DECRYPT   = 8;

function CryptImageByFileName(FileName: String; ID: integer; Password : String; Options : Integer; DoEvent : boolean = true) : integer;
function ResetPasswordImageByFileName(FileName: String; ID: integer; Password : String; DoEvent : boolean = true) : integer;
function CryptTStrings(TS : TStrings; Pass : String) : String;
function DeCryptTStrings(S : String; Pass : String) : TStrings;
function CryptDBRecordByID(ID : integer; Password : String) : integer;

implementation

uses JPEG, CommonDBSupport;

function CryptDBRecordByID(ID : integer; Password : String) : integer;
var
  Query : TDataSet;
  JPEG : TJPEGImage;
  MS : TMemoryStream;
begin
  Result := CRYPT_RESULT_UNDEFINED;
  if GetDBType=DB_TYPE_MDB then
  begin
    Query:=GetQuery;
    try
      SetSQL(Query,'Select thum from $DB$ where ID = '+IntToStr(ID));
      Query.Open;
      JPEG:=TJPEGImage.Create;
      try
        JPEG.Assign(Query.FieldByName('thum'));
        MS := TMemoryStream.Create;
        try
          CryptGraphicImage(JPEG, Password, MS);
          SetSQL(Query, 'Update $DB$ Set thum = :thum where ID = ' + IntToStr(ID));
          LoadParamFromStream(Query, 0, MS, ftBlob);
        finally
          MS.Free;
        end;
      finally
        JPEG.Free;
      end;
      ExecSQL(Query);
    finally
      FreeDS(Query);
    end;
    Result:=CRYPT_RESULT_OK;
  end;
end;

function ResetPasswordDBRecordByID(ID : integer; Password : String) : integer;
var
  Query : TDataSet;
  JPEG : TJPEGImage;
begin
  Result := CRYPT_RESULT_UNDEFINED;

  if GetDBType = DB_TYPE_MDB then
  begin
    Query := GetQuery;
    try
      SetSQL(Query, 'Select thum from $DB$ where ID = ' + IntToStr(ID));
      Query.Open;
      JPEG := TJpegImage.Create;
      try
        if DeCryptBlobStreamJPG(Query.FieldByName('thum'), Password, JPEG) then
        begin
          SetSQL(Query,'Update $DB$ Set thum = :thum where ID = ' + IntToStr(ID));
          AssignParam(Query, 0, JPEG);
          ExecSQL(Query);
        end;
      finally
        JPEG.Free;
      end;
    finally
      FreeDS(Query);
    end;
    Result := CRYPT_RESULT_OK;
  end;
end;

function CryptImageByFileName(FileName: String; ID: integer; Password : String; Options : Integer; DoEvent : boolean = true) : integer;
var
  info : TEventValues;
begin
 info.Crypt:=true;
 Result:=CRYPT_RESULT_UNDEFINED;
 if ValidCryptGraphicFile(FileName) and FileExists(FileName) then
 begin
  Result:=CRYPT_RESULT_ALREADY_CRYPT;
  exit;
 end;

 if FileExists(FileName) then
 if not CryptGraphicFileV2(FileName, Password, Options) then
 begin
  Result:=CRYPT_RESULT_FAILED_CRYPT_FILE;
  exit;
 end;
 if ID<>0 then
 if CryptDBRecordByID(ID, Password)<>CRYPT_RESULT_OK then
 begin
  Result:=CRYPT_RESULT_FAILED_CRYPT_DB;
 end;

 if Result=CRYPT_RESULT_UNDEFINED then info.Crypt:=true else info.Crypt:=false;
 
 if ID<>0 then
 if DoEvent then
 DBKernel.DoIDEvent(nil,ID,[EventID_Param_Crypt],info) else
 begin
  info.NewName:=FileName;  
  if DoEvent then
  DBKernel.DoIDEvent(nil,ID,[EventID_Param_Name],info)
 end;
 if Result=CRYPT_RESULT_UNDEFINED then Result:=CRYPT_RESULT_OK;
end;

function ResetPasswordImageByFileName(FileName: String; ID: integer; Password : String; DoEvent : boolean = true) : integer;
var
  info : TEventValues;
begin
 info.Crypt:=false;
 Result:=CRYPT_RESULT_UNDEFINED;
 if not ValidCryptGraphicFile(FileName) and FileExists(FileName) then
 begin
  Result:=CRYPT_RESULT_ALREADY_DECRYPT;
  exit;
 end;
      
 if FileExists(FileName) then
 if not ResetPasswordInGraphicFile(FileName, Password) then
 begin
  Result:=CRYPT_RESULT_FAILED_CRYPT_FILE;
  exit;
 end;

 if ID<>0 then
 if ResetPasswordDBRecordByID(ID, Password)<>CRYPT_RESULT_OK then
 begin
  Result:=CRYPT_RESULT_FAILED_CRYPT_DB;
 end;


 if Result=CRYPT_RESULT_UNDEFINED then info.Crypt:=false else info.Crypt:=true;

 if ID<>0 then
 begin
  if DoEvent then
  DBKernel.DoIDEvent(nil,ID,[EventID_Param_Crypt],info)
 end else
 begin
  info.NewName:=FileName;  
  if DoEvent then
  DBKernel.DoIDEvent(nil,ID,[EventID_Param_Name],info)
 end;
 
 if Result=CRYPT_RESULT_UNDEFINED then
 Result:=CRYPT_RESULT_OK;
end;

function DeCryptTStrings(S : String; Pass : String) : TStrings;
var
 x : array of byte;
 i, Lpass : integer;
 CRC : Cardinal;
 TempStream, MS : TMemoryStream;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
begin
 Result:=TStringList.Create;
 MS:=TMemoryStream.Create;
 MS.WriteBuffer(Pointer(s)^,Length(S));
 MS.Seek(0,soFromBeginning);
 MS.Read(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 if GraphicHeader.ID<>'.PHDBCRT' then
 begin
  MS.Free;
  exit;
 end;
 if GraphicHeader.Version=1 then
 begin
  MS.Read(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
  CalcStringCRC32(Pass,CRC);
  if GraphicHeaderV1.PassCRC<>CRC then
  begin
   MS.Free;
   exit;
  end;
  if GraphicHeaderV1.Displacement>0 then
  MS.Seek(GraphicHeaderV1.Displacement,soCurrent);
  SetLength(x,GraphicHeaderV1.FileSize);
  MS.Read(Pointer(x)^,GraphicHeaderV1.FileSize);
  MS.Free;
  Lpass:=Length(Pass);
  for i:=0 to Length(x)-1 do
  x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4+1] xor Byte(Pass[i mod Lpass+1]));
  TempStream := TMemoryStream.Create;
  TempStream.Seek(0,soFromBeginning);
  TempStream.WriteBuffer(Pointer(x)^,Length(x));
  TempStream.Seek(0,soFromBeginning);
  try
  Result.LoadFromStream(TempStream);
  except
  end;
  TempStream.Free;
 end;
end;

function CryptTStrings(TS : TStrings; Pass : String) : String;
var
 MS : TMemoryStream;
 x : array of byte;
 i, LPass : integer;
 GraphicHeader : TGraphicCryptFileHeader;
 GraphicHeaderV1 : TGraphicCryptFileHeaderV1;
begin
 Result:='';
 MS:=TMemoryStream.Create;
 TS.SaveToStream(MS);
 SetLength(x,MS.Size);
 MS.Seek(0,soFromBeginning);
 MS.Read(GraphicHeader,SizeOf(GraphicHeader));
 if GraphicHeader.ID='.PHDBCRT' then
 begin
  MS.Free;
  exit;
 end;
 MS.Seek(0,soFromBeginning);
 MS.Read(Pointer(x)^,MS.Size);
 MS.Free;
 LPass:=length(Pass);
 Randomize;

{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
 GraphicHeaderV1.Magic:=Random(High(Cardinal));
 for i:=0 to Length(x)-1 do
 x[i]:=x[i] xor (TMagicByte(GraphicHeaderV1.Magic)[i mod 4+1] xor Byte(Pass[i mod Lpass+1]));
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}

 MS:=TMemoryStream.Create;
 MS.Seek(0,soFromBeginning);
 GraphicHeader.ID:='.PHDBCRT';
 GraphicHeader.Version:=1;
 GraphicHeader.DBVersion:=0;
 MS.Write(GraphicHeader,SizeOf(TGraphicCryptFileHeader));
 GraphicHeaderV1.Version:=1;
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
 MS.Write(GraphicHeaderV1,SizeOf(TGraphicCryptFileHeaderV1));
 MS.Write(Pointer(x)^,Length(x));
 SetLength(Result,MS.Size);
 MS.Seek(0,soFromBeginning);
 MS.ReadBuffer(Pointer(Result)^,MS.Size);
 MS.Free;
end;

end.
