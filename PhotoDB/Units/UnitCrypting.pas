unit UnitCrypting;

interface

uses
  Windows,
  SysUtils,
  DB,
  Classes,
  JPEG,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  UnitDBDeclare,
  uCollectionEvents,
  CommonDBSupport,
  uDBForm,
  uMemory,
  uDBAdapter,
  uStrongCrypt,
  GraphicCrypt,
  uErrors;

function EncryptImageByFileName(Caller: TDBForm; FileName: string; ID: Integer; Password: string; Options: Integer;
  DoEvent: Boolean = True; Progress: TFileProgress = nil): Integer;
function ResetPasswordImageByFileName(Caller: TObject; FileName: string; ID: Integer; Password: string; Progress: TFileProgress = nil): Integer;
function CryptTStrings(TS: TStrings; Pass: string): string;
function DeCryptTStrings(S: string; Pass: string): TStrings;
function CryptDBRecordByID(ID: Integer; Password: string): Integer;

implementation

function CryptDBRecordByID(ID: Integer; Password: string): Integer;
var
  Query: TDataSet;
  JPEG: TJPEGImage;
  MS: TMemoryStream;
  DA: TImageTableAdapter;
begin
  Result := CRYPT_RESULT_UNDEFINED;

  Query := GetQuery;
  DA := TImageTableAdapter.Create(Query);
  try
    SetSQL(Query,'Select thum from $DB$ where ID = ' + IntToStr(ID));
    Query.Open;
    JPEG := TJPEGImage.Create;
    try
      JPEG.Assign(DA.Thumb);
      MS := TMemoryStream.Create;
      try
        EncryptGraphicImage(JPEG, Password, MS);
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
    F(DA);
    FreeDS(Query);
  end;
  Result := CRYPT_RESULT_OK;
end;

function ResetPasswordDBRecordByID(ID: integer; Password: String): Integer;
var
  Query: TDataSet;
  JPEG: TJPEGImage;
  DA: TImageTableAdapter;
begin
  Result := CRYPT_RESULT_UNDEFINED;

  Query := GetQuery;
  DA := TImageTableAdapter.Create(Query);
  try
    SetSQL(Query, 'Select thum from $DB$ where ID = ' + IntToStr(ID));
    Query.Open;
    JPEG := TJpegImage.Create;
    try
      if DeCryptBlobStreamJPG(DA.Thumb, Password, JPEG) then
      begin
        SetSQL(Query,'Update $DB$ Set thum = :thum where ID = ' + IntToStr(ID));
        AssignParam(Query, 0, JPEG);
        ExecSQL(Query);
      end;
    finally
      F(JPEG);
    end;
  finally
    F(DA);
    FreeDS(Query);
  end;
  Result := CRYPT_RESULT_OK;
end;

function EncryptImageByFileName(Caller: TDBForm; FileName: string; ID: Integer; Password: string; Options: Integer;
  DoEvent: Boolean = True; Progress: TFileProgress = nil): Integer;
var
  Info: TEventValues;
  ErrorCode: Integer;
begin
  Info.IsEncrypted := True;
  Result := CRYPT_RESULT_UNDEFINED;
  if ValidCryptGraphicFile(FileName) and FileExistsSafe(FileName) then
  begin
    Result := CRYPT_RESULT_ALREADY_CRYPT;
    Exit;
  end;

  if FileExistsSafe(FileName) then
  begin
    ErrorCode := CryptGraphicFileV3(FileName, Password, Options, Progress);
    if ErrorCode <> CRYPT_RESULT_OK then
    begin
      Result := ErrorCode;
      Exit;
    end;
  end;
  if ID <> 0 then
    if CryptDBRecordByID(ID, Password) <> CRYPT_RESULT_OK then
    begin
      Result := CRYPT_RESULT_FAILED_CRYPT_DB;
    end;

  if Result = CRYPT_RESULT_UNDEFINED then
    Info.IsEncrypted := True
  else
    Info.IsEncrypted := False;

  if ID <> 0 then
    if DoEvent then
      CollectionEvents.DoIDEvent(Caller, ID, [EventID_Param_Crypt], Info)
    else
    begin
      Info.NewName := FileName;
      if DoEvent then
        CollectionEvents.DoIDEvent(Caller, ID, [EventID_Param_Name], Info)
    end;
  if Result = CRYPT_RESULT_UNDEFINED then
    Result := CRYPT_RESULT_OK;
end;

function ResetPasswordImageByFileName(Caller: TObject; FileName: string; ID: Integer; Password: string; Progress: TFileProgress = nil): Integer;
begin
  if not FileExistsSafe(FileName) then
    Exit(CRYPT_RESULT_ERROR_READING_FILE);

  if not ValidCryptGraphicFile(FileName) then
  begin
    Result := CRYPT_RESULT_ALREADY_DECRYPTED;
    Exit;
  end;

  Result := ResetPasswordInGraphicFile(FileName, Password, Progress);
  if Result <> CRYPT_RESULT_OK then
    Exit;

  if ID <> 0 then
    if ResetPasswordDBRecordByID(ID, Password) <> CRYPT_RESULT_OK then
      Result := CRYPT_RESULT_FAILED_CRYPT_DB;
end;

function DeCryptTStrings(S: string; Pass: string): TStrings;
var
  X: array of Byte;
  I, Lpass: Integer;
  CRC: Cardinal;
  TempStream, MS: TMemoryStream;
  GraphicHeader: TEncryptedFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := TStringList.Create;
  MS := TMemoryStream.Create;
  try
    MS.WriteBuffer(Pointer(S)^, Length(S));
    MS.Seek(0, SoFromBeginning);
    MS.Read(GraphicHeader, SizeOf(TEncryptedFileHeader));
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
  GraphicHeader: TEncryptedFileHeader;
  GraphicHeaderV1: TGraphicCryptFileHeaderV1;
begin
  Result := '';
  MS := TMemoryStream.Create;
  try
    TS.SaveToStream(MS);
    SetLength(X, MS.Size);
    MS.Seek(0, SoFromBeginning);
    MS.Read(GraphicHeader, SizeOf(GraphicHeader));
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
  GraphicHeaderV1.Magic := Random(High(Integer));
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
    MS.write(GraphicHeader, SizeOf(TEncryptedFileHeader));
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
    MS.Write(GraphicHeaderV1, SizeOf(TGraphicCryptFileHeaderV1));
    MS.Write(Pointer(X)^, Length(X));
    SetLength(Result, MS.Size);
    MS.Seek(0, SoFromBeginning);
    MS.ReadBuffer(Pointer(Result)^, MS.Size);
  finally
    F(MS);
  end;
end;

end.
