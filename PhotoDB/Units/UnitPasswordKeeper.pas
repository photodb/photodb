unit UnitPasswordKeeper;

interface

uses Windows, Classes, Dolphin_DB, win32crc, GraphicCrypt, UnitDBDeclare;

type
 TPasswordKeeper = class(TObject)
 private
  PasswordList : TList;
  OKList : TArInteger;
 public
  constructor Create;
  destructor Destroy; override;
  procedure AddPassword(PasswordRecord : TPasswordRecord);
  procedure RemoveRecordsByPasswordCRC(CRC : Cardinal);
  function PasswordOKForRecords(Password : string) : TList;
  function GetActiveFiles(Sender : TObject) : TList;
  procedure AddCryptFileToListProc(Sender : TObject; Rec : TPasswordRecord);
  function Count : integer;
  function GetPasswords : TArCardinal;
  procedure TryGetPasswordFromUser(PasswordCRC : Cardinal);
  function PasswordOKForFiles(PasswordCRC: Cardinal): TArStrings;
  function GetAvaliableCryptFileList(Sender : TObject) : TArInteger;
  procedure AddToOKList(PasswordCRC : Cardinal);   
end;

implementation

uses UnitPasswordForm;

{ TPasswordKeeper }

procedure TPasswordKeeper.AddCryptFileToListProc(Sender: TObject;
  Rec : TPasswordRecord);
begin
 AddPassword(Rec);
end;

procedure TPasswordKeeper.AddPassword(PasswordRecord: TPasswordRecord);
var
  p : PPasswordRecord;
  L : integer;
begin
 GetMem(p, SizeOf(TPPasswordRecord));
 p^.CRC:=PasswordRecord.CRC;

 L:=Length(PasswordRecord.FileName);
 GetMem(p^.FileName,Length(PasswordRecord.FileName)+1);
 p^.FileName[L]:=#0;
 lstrcpyn(p^.FileName,PChar(PasswordRecord.FileName),L+1);

 PasswordList.Add(p);
end;

procedure TPasswordKeeper.AddToOKList(PasswordCRC: Cardinal);
var
  i : integer;
  p : PPasswordRecord;
begin
 for i:=PasswordList.Count-1 downto 0 do
 begin
  p:=PPasswordRecord(PasswordList[i]);
  if (p^.CRC = PasswordCRC) then
  begin
   SetLength(OKList,Length(OKList)+1);
   OKList[Length(OKList)-1]:=p^.ID;
  end;
 end;
end;

function TPasswordKeeper.Count: integer;
begin
 Result:=PasswordList.Count;
end;

constructor TPasswordKeeper.Create;
begin
 inherited Create;
 SetLength(OKList,0);
 PasswordList:= TList.Create;
end;

destructor TPasswordKeeper.Destroy;
begin
 PasswordList.Free;
 inherited Destroy;
end;

function TPasswordKeeper.GetActiveFiles(Sender : TObject): TList;
var
  i, L : integer;
  p,Cp : PPasswordRecord;
begin
 Result:=TList.Create;
 for i:=PasswordList.Count-1 downto 0 do
 begin
  p:=PPasswordRecord(PasswordList[i]);
  GetMem(Cp, SizeOf(TPPasswordRecord));
  Cp^.CRC:=p^.CRC;

  L:=Length(p^.FileName);
  GetMem(Cp^.FileName,Length(p^.FileName)+1);
  Cp^.FileName[L]:=#0;
  lstrcpyn(Cp^.FileName,p^.FileName,L+1);

  Result.Add(Cp);
 end;
end;

function TPasswordKeeper.GetAvaliableCryptFileList(
  Sender: TObject): TArInteger;
begin
 Result:=Copy(OKList);
end;

function TPasswordKeeper.GetPasswords: TArCardinal;
var
  i : integer;
  p : PPasswordRecord;
  Res :  TArCardinal;

  function FileCRCExists(CRC : Cardinal) : boolean;
  var
    j : integer;
  begin
   Result:=false;
   for j:=0 to Length(Res)-1 do
   if Res[j]=CRC then
   begin
    Result:=true;
    break;
   end;
  end;
begin
 SetLength(Res,0);
 for i:=PasswordList.Count-1 downto 0 do
 begin    
  p:=PPasswordRecord(PasswordList[i]);
  if not FileCRCExists(p^.CRC) then
  begin
   SetLength(Res,Length(Res)+1);
   Res[Length(Res)-1]:=p^.CRC;
  end;
 end;
 Result:=Res;
end;

function TPasswordKeeper.PasswordOKForFiles(PasswordCRC: Cardinal): TArStrings;
var
  i : integer;
  p : PPasswordRecord;
begin
 SetLength(Result,0);
 for i:=PasswordList.Count-1 downto 0 do
 begin
  p:=PPasswordRecord(PasswordList[i]);
  if p^.CRC=PasswordCRC then
  begin
   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:=p^.FileName;
  end;
 end;
end;

function TPasswordKeeper.PasswordOKForRecords(Password: string): TList;
var
  CRC : Cardinal;
  i, L : integer;
  p,Cp : PPasswordRecord;
begin
 Result:=TList.Create;
 CalcStringCRC32(Password,CRC);
 for i:=PasswordList.Count-1 downto 0 do
 begin
  p:=PPasswordRecord(PasswordList[i]);
  if p^.CRC=CRC then
  begin
   GetMem(Cp, SizeOf(TPPasswordRecord));
   Cp^.CRC:=p^.CRC;

   L:=Length(p^.FileName);
   GetMem(Cp^.FileName,Length(p^.FileName)+1);
   Cp^.FileName[L]:=#0;
   lstrcpyn(Cp^.FileName,p^.FileName,L+1);

   Result.Add(Cp);
  end;
 end;
end;

procedure TPasswordKeeper.RemoveRecordsByPasswordCRC(CRC: Cardinal);
var
  i : integer;     
  p : PPasswordRecord;
begin
 for i:=PasswordList.Count-1 downto 0 do
 begin
  p:=PPasswordRecord(PasswordList[i]);
  if p^.CRC=CRC then
  begin
   PasswordList.Remove(p);
  end;
 end;
end;

procedure TPasswordKeeper.TryGetPasswordFromUser(PasswordCRC: Cardinal);
var
  FileList : TArStrings;
  FileOkList : TList;
  Password : string;
  Skip : boolean;
  i : integer;       
  p : PPasswordRecord;
begin
 FileList:=PasswordOKForFiles(PasswordCRC);
 if Length(FileList)>0 then
 begin
  Skip:=false;
  Password:=GetImagePasswordFromUserForManyFiles(FileList,PasswordCRC,Skip);
  if Password<>'' then
  begin
   DBKernel.AddTemporaryPasswordInSession(Password);

   //moving from password list to OKpassword list FILES

   FileOkList:=PasswordOKForRecords(Password);
   for i:=0 to FileOkList.Count-1 do
   begin
    p:=FileOkList[i];
    AddToOKList(p^.ID);
   end;
   RemoveRecordsByPasswordCRC(PasswordCRC);
  end;

  if Skip then
  begin
   RemoveRecordsByPasswordCRC(PasswordCRC);
  end;
 end;
end;

end.
