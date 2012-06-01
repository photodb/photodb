unit UnitPasswordKeeper;

interface

uses
  Windows,
  Classes,
  UnitDBKernel,
  win32crc,
  GraphicCrypt,
  UnitDBDeclare,
  SyncObjs,
  uDBBaseTypes,
  uMemory,
  uFormInterfaces;

type
  TPasswordKeeper = class(TObject)
  private
    PasswordList: TList;
    OKList: TArInteger;
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddPassword(PasswordRecord: TPasswordRecord);
    procedure RemoveRecordsByPasswordCRC(CRC: Cardinal);
    function PasswordOKForRecords(Password: string): TList;
    function GetActiveFiles(Sender: TObject): TList;
    procedure AddCryptFileToListProc(Sender: TObject; Rec: TPasswordRecord);
    function Count: Integer;
    function GetPasswords: TArCardinal;
    procedure TryGetPasswordFromUser(PasswordCRC: Cardinal);
    procedure PasswordOKForFiles(PasswordCRC: Cardinal; FileList : TStrings);
    function GetAvaliableCryptFileList(Sender: TObject): TArInteger;
    procedure AddToOKList(PasswordCRC: Cardinal);
  end;

implementation

{ TPasswordKeeper }

procedure TPasswordKeeper.AddCryptFileToListProc(Sender: TObject; Rec: TPasswordRecord);
begin
  AddPassword(Rec);
end;

procedure TPasswordKeeper.AddPassword(PasswordRecord: TPasswordRecord);
begin
  FSync.Enter;
  try
    PasswordList.Add(PasswordRecord);
  finally
    FSync.Leave;
  end;
end;

procedure TPasswordKeeper.AddToOKList(PasswordCRC: Cardinal);
var
  I: Integer;
  P: TPasswordRecord;
begin
  FSync.Enter;
  try
    for I := PasswordList.Count - 1 downto 0 do
    begin
      P := TPasswordRecord(PasswordList[I]);
      if (P.CRC = PasswordCRC) then
      begin
        SetLength(OKList, Length(OKList) + 1);
        OKList[Length(OKList) - 1] := P.ID;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPasswordKeeper.Count: Integer;
begin
  Result := PasswordList.Count;
end;

constructor TPasswordKeeper.Create;
begin
  inherited;
  FSync:= TCriticalSection.Create;
  SetLength(OKList, 0);
  PasswordList := TList.Create;
end;

destructor TPasswordKeeper.Destroy;
begin
  FreeList(PasswordList);
  F(FSync);
end;

function TPasswordKeeper.GetActiveFiles(Sender : TObject): TList;
var
  I: Integer;
  P, Cp: TPasswordRecord;
begin
  FSync.Enter;
  try
    Result := TList.Create;
    for I := PasswordList.Count - 1 downto 0 do
    begin
      P := TPasswordRecord(PasswordList[I]);
      Cp := TPasswordRecord.Create;
      Cp.CRC := P.CRC;
      Cp.FileName := P.FileName;
      Cp.ID := P.ID;
      Result.Add(Cp);
    end;
  finally
    FSync.Leave;
  end;
end;

function TPasswordKeeper.GetAvaliableCryptFileList(Sender: TObject): TArInteger;
begin
  FSync.Enter;
  try
    Result := Copy(OKList);
  finally
    FSync.Leave;
  end;
end;

function TPasswordKeeper.GetPasswords: TArCardinal;
var
  I: Integer;
  P: TPasswordRecord;
  Res: TArCardinal;

  function FileCRCExists(CRC: Cardinal): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to Length(Res) - 1 do
      if Res[J] = CRC then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  FSync.Enter;
  try
    SetLength(Res, 0);
    for I := PasswordList.Count - 1 downto 0 do
    begin
      P := TPasswordRecord(PasswordList[I]);
      if not FileCRCExists(P.CRC) then
      begin
        SetLength(Res, Length(Res) + 1);
        Res[Length(Res) - 1] := P.CRC;
      end;
    end;
    Result := Res;
  finally
    FSync.Leave;
  end;
end;

procedure TPasswordKeeper.PasswordOKForFiles(PasswordCRC: Cardinal; FileList : TStrings);
var
  I: Integer;
  P: TPasswordRecord;
begin
  FSync.Enter;
  try
    FileList.Clear;
    for I := PasswordList.Count - 1 downto 0 do
    begin
      P := TPasswordRecord(PasswordList[I]);
      if P.CRC = PasswordCRC then
        FileList.Add(P.FileName);

    end;
  finally
    FSync.Leave;
  end;
end;

function TPasswordKeeper.PasswordOKForRecords(Password: string): TList;
var
  CRC: Cardinal;
  I: Integer;
  P, Cp: TPasswordRecord;
begin
  FSync.Enter;
  try
    Result := TList.Create;
    CalcStringCRC32(Password, CRC);
    for I := PasswordList.Count - 1 downto 0 do
    begin
      P := TPasswordRecord(PasswordList[I]);
      if P.CRC = CRC then
      begin
        Cp := TPasswordRecord.Create;
        Cp.CRC := P.CRC;
        Cp.FileName := P.FileName;
        Cp.ID := P.ID;
        Result.Add(Cp);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TPasswordKeeper.RemoveRecordsByPasswordCRC(CRC: Cardinal);
var
  I: Integer;
  P: TPasswordRecord;
begin
  FSync.Enter;
  try
    for I := PasswordList.Count - 1 downto 0 do
    begin
      P := TPasswordRecord(PasswordList[I]);
      if P.CRC = CRC then
      begin
        P.Free;
        PasswordList.Remove(P);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TPasswordKeeper.TryGetPasswordFromUser(PasswordCRC: Cardinal);
var
  FileList: TStrings;
  FileOkList: TList;
  Password: string;
  Skip: Boolean;
  I: Integer;
  P: TPasswordRecord;
begin
  FileList := TStringList.Create;
  try
    PasswordOKForFiles(PasswordCRC, FileList);
    if FileList.Count > 0 then
    begin
      Skip := False;
      Password := RequestPasswordForm.ForManyFiles(FileList, PasswordCRC, Skip);
      if Password <> '' then
      begin
        DBKernel.AddTemporaryPasswordInSession(Password);

        // moving from password list to OKpassword list FILES
        FileOkList := PasswordOKForRecords(Password);
        try
          for I := 0 to FileOkList.Count - 1 do
          begin
            P := FileOkList[I];
            AddToOKList(P.ID);
          end;
        finally
          FreeList(FileOkList);
        end;
        RemoveRecordsByPasswordCRC(PasswordCRC);
      end;

      if Skip then
        RemoveRecordsByPasswordCRC(PasswordCRC);
    end;
  finally
    F(FileList);
  end;
end;

end.
