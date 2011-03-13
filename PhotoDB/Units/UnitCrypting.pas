unit UnitCrypting;

interface

uses
  dolphin_db, GraphicCrypt, DB, Windows, SysUtils,
  UnitDBKernel, Classes, Win32Crc, UnitDBDeclare, uFileUtils,
  uDBForm, uMemory;

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

function CryptImageByFileName(Caller : TDBForm; FileName: String; ID: integer; Password : String; Options : Integer; DoEvent : boolean = true) : integer;
function ResetPasswordImageByFileName(Caller : TObject; FileName: String; ID: integer; Password : String) : integer;
function CryptTStrings(TS : TStrings; Pass : String) : String;
function DeCryptTStrings(S : String; Pass : String) : TStrings;
function CryptDBRecordByID(ID : integer; Password : String) : integer;

implementation

uses
  JPEG, CommonDBSupport;

function CryptDBRecordByID(ID : integer; Password : String) : integer;
var
  Query : TDataSet;
  JPEG : TJPEGImage;
  MS : TMemoryStream;
begin
  Result := CRYPT_RESULT_UNDEFINED;
  if GetDBType = DB_TYPE_MDB then
  begin
    Query := GetQuery;
    try
      SetSQL(Query,'Select thum from $DB$ where ID = '+IntToStr(ID));
      Query.Open;
      JPEG := TJPEGImage.Create;
      try
        JPEG.Assign(Query.FieldByName('thum'));
        MS := TMemoryStream.Create;
        try
          CryptGraphicImage(JPEG, Password, MS);
          SetSQL(Query, 'Update $DB$ Set thum = :thum where ID = ' + IntToStr(ID));
          LoadParamFromStream(Query, 0, MS, ftBlob);
        finally
          F(MS);
        end;
      finally
        F(JPEG);
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
        F(JPEG);
      end;
    finally
      FreeDS(Query);
    end;
    Result := CRYPT_RESULT_OK;
  end;
end;

function CryptImageByFileName(Caller: TDBForm; FileName: string; ID: Integer; Password: string; Options: Integer;
  DoEvent: Boolean = True): Integer;
var
  Info: TEventValues;
begin
  Info.Crypt := True;
  Result := CRYPT_RESULT_UNDEFINED;
  if ValidCryptGraphicFile(FileName) and FileExistsSafe(FileName) then
  begin
    Result := CRYPT_RESULT_ALREADY_CRYPT;
    Exit;
  end;

  if FileExistsSafe(FileName) then
    if not CryptGraphicFileV2(FileName, Password, Options) then
    begin
      Result := CRYPT_RESULT_FAILED_CRYPT_FILE;
      Exit;
    end;
  if ID <> 0 then
    if CryptDBRecordByID(ID, Password) <> CRYPT_RESULT_OK then
    begin
      Result := CRYPT_RESULT_FAILED_CRYPT_DB;
    end;

  if Result = CRYPT_RESULT_UNDEFINED then
    Info.Crypt := True
  else
    Info.Crypt := False;

  if ID <> 0 then
    if DoEvent then
      DBKernel.DoIDEvent(Caller, ID, [EventID_Param_Crypt], Info)
    else
    begin
      Info.NewName := FileName;
      if DoEvent then
        DBKernel.DoIDEvent(Caller, ID, [EventID_Param_Name], Info)
    end;
  if Result = CRYPT_RESULT_UNDEFINED then
    Result := CRYPT_RESULT_OK;
end;

function ResetPasswordImageByFileName(Caller: TObject; FileName: string; ID: Integer; Password: string): Integer;

begin
  Result := CRYPT_RESULT_OK;
  if not ValidCryptGraphicFile(FileName) and FileExistsSafe(FileName) then
  begin
    Result := CRYPT_RESULT_ALREADY_DECRYPT;
    Exit;
  end;

  if FileExistsSafe(FileName) then
    if not ResetPasswordInGraphicFile(FileName, Password) then
    begin
      Result := CRYPT_RESULT_FAILED_CRYPT_FILE;
      Exit;
    end;

  if ID <> 0 then
    if ResetPasswordDBRecordByID(ID, Password) <> CRYPT_RESULT_OK then
      Result := CRYPT_RESULT_FAILED_CRYPT_DB;

end;

function DeCryptTStrings(S : String; Pass : String) : TStrings;
var
  X: array of Byte;
  I, Lpass: Integer;
  CRC: Cardinal;
  TempStream, MS: TMemoryStream;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := TStringList.Create;
  MS := TMemoryStream.Create;
  try
    MS.WriteBuffer(Pointer(S)^, Length(S));
    MS.Seek(0, SoFromBeginning);
    MS.Read(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    if GraphicHeader.ID <> '.PHDBCRT' then
      Exit;

    if GraphicHeader.Version = 1 then
    begin
      MS.Read(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
      CalcStringCRC32(Pass, CRC);
      if GraphicHeaderV1.PassCRC <> CRC then
        Exit;

      if GraphicHeaderV1.Displacement > 0 then
        MS.Seek(GraphicHeaderV1.Displacement, SoCurrent);
      SetLength(X, GraphicHeaderV1.FileSize);
      MS.Read(Pointer(X)^, GraphicHeaderV1.FileSize);
      F(MS);

      Lpass := Length(Pass);
      for I := 0 to Length(X) - 1 do
        X[I] := X[I] xor (TMagicByte(GraphicHeaderV1.Magic)[I mod 4 + 1] xor Byte(Pass[I mod Lpass + 1]));
      TempStream := TMemoryStream.Create;
      try
        TempStream.Seek(0, SoFromBeginning);
        TempStream.WriteBuffer(Pointer(X)^, Length(X));
        TempStream.Seek(0, SoFromBeginning);
        try
          Result.LoadFromStream(TempStream);
        except
        end;
      finally
        F(TempStream);
      end;
    end;
  finally
    F(MS);
  end;
end;

function CryptTStrings(TS: TStrings; Pass: string): string;
var
  MS: TMemoryStream;
  X: array of Byte;
  I, LPass: Integer;
  GraphicHeader: TGraphicCryptFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := '';
  MS := TMemoryStream.Create;
  try
    TS.SaveToStream(MS);
    SetLength(X, MS.Size);
    MS.Seek(0, SoFromBeginning);
    MS.read(GraphicHeader, SizeOf(GraphicHeader));
    if GraphicHeader.ID = '.PHDBCRT' then
      Exit;

    MS.Seek(0, SoFromBeginning);
    MS.Read(Pointer(X)^, MS.Size);
  finally
    F(MS);
  end;
  LPass := Length(Pass);
  Randomize;
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
  GraphicHeaderV1.Magic := Random( high(Cardinal));
  for I := 0 to Length(X) - 1 do
    X[I] := X[I] xor (TMagicByte(GraphicHeaderV1.Magic)[I mod 4 + 1] xor Byte(Pass[I mod Lpass + 1]));
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
  MS := TMemoryStream.Create;
  try
    MS.Seek(0, SoFromBeginning);
    GraphicHeader.ID := '.PHDBCRT';
    GraphicHeader.Version := 1;
    GraphicHeader.DBVersion := 0;
    MS.write(GraphicHeader, SizeOf(TGraphicCryptFileHeader));
    GraphicHeaderV1.Version := 1;
    GraphicHeaderV1.FileSize := Length(X);
    CalcStringCRC32(Pass, GraphicHeaderV1.PassCRC);
    GraphicHeaderV1.CRCFileExists := False;
    GraphicHeaderV1.CRCFile := 0;
    GraphicHeaderV1.TypeExtract := 0;
    GraphicHeaderV1.CryptFileName := False;
    GraphicHeaderV1.CFileName := '';
    GraphicHeaderV1.TypeFileNameExtract := 0;
    GraphicHeaderV1.FileNameCRC := 0;
    GraphicHeaderV1.Displacement := 0;
    MS.write(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    MS.write(Pointer(X)^, Length(X));
    SetLength(Result, MS.Size);
    MS.Seek(0, SoFromBeginning);
    MS.ReadBuffer(Pointer(Result)^, MS.Size);
  finally
    F(MS);
  end;
end;

end.
