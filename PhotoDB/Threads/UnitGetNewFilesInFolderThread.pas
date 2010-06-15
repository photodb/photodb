unit UnitGetNewFilesInFolderThread;

interface

uses
  Classes, SysUtils, CommonDBSupport, DB, Dolphin_DB, win32crc, UnitDBDeclare;

type
  TGetNewFilesInFolderThread = class(TThread)
  private
  FFolder : string;
  FQuery : TDataSet;
    { Private declarations }
  protected
    procedure Execute; override;
  public
   constructor Create(CreateSuspennded: Boolean; Folder : string);
  end;

  TArrayOfString = array of string;

  procedure ScanDBForFilesInFolder(Directory : string; var DS : TDataSet);
  function GetNewFiles(Folder : string; DS : TDataSet) : TArStrings;

implementation

constructor TGetNewFilesInFolderThread.Create(CreateSuspennded: Boolean;
  Folder: string);
begin
 inherited Create(true);
 FFolder:=Folder;
 if not CreateSuspennded then Resume;
end;

function GetDirImageListing(Dir : String) : TArrayOfString;
var
  Found  : integer;
  SearchRec : TSearchRec;
begin
  SetLength(Result,0);
  If dir[length(dir)]<>'\' then dir:=dir+'\';
  Found := FindFirst(dir+'*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   if ExtInMask(GetExt(SearchRec.Name),SupportedExt) then
   begin
    SetLength(Result,length(Result)+1);
    Result[length(Result)-1]:=dir+SearchRec.Name;
   end;
   Found := sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

function GetNewFiles(Folder : string; DS : TDataSet) : TArStrings;
var
  i, j, c, cc : integer;
  Files : TArrayOfString;
begin
 DS.First;
 Files:=GetDirImageListing(Folder);
 c:=0;
 for i:=1 to DS.RecordCount do
 begin
  for j:=0 to Length(Files)-1 do
  begin
   if Files[j]=DS.FieldByName('FFileName').AsString then
   begin
    inc(c);
    Files[j]:='';
    break;
   end;
  end;
  DS.Next;
 end;
 SetLength(Result,Length(Files)-c);
 cc:=0;
 for j:=0 to Length(Files)-1 do
 if Files[j]<>'' then
 begin
  inc(cc);
  Result[cc-1]:=Files[j];
 end;
end;

procedure ScanDBForFilesInFolder(Directory : string; var DS : TDataSet);
var
  DBFolder : string;
  crc : Cardinal;
begin
 AnsiLowerCase(Directory);
 UnFormatDir(Directory);
 CalcStringCRC32(AnsiLowerCase(Directory),crc);
 FormatDir(Directory);

 DBFolder:=AnsiLowerCase(Directory);
 DBFolder:=NormalizeDBString(DBFolder);

 if GetDBType=DB_TYPE_BDE then SetSQL(DS,'Select FFileName From '+GetDefDBname+' where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
 if GetDBType=DB_TYPE_MDB then SetSQL(DS,'Select FFileName From (Select * from '+GetDefDBname+' where FolderCRC='+inttostr(Integer(crc))+') where (FFileName Like :FolderA) and not (FFileName like :FolderB)');

 SetStrParam(DS,0,'%'+DBFolder+'%');
 SetStrParam(DS,1,'%'+DBFolder+'%\%');
 try
  DS.Active:=True;
 except
 end;
end;

procedure TGetNewFilesInFolderThread.Execute;
var
  DBFolder : string;
  NewFiles : TArStrings;
  crc : Cardinal;
begin
 FreeOnTerminate:=true;

 AnsiLowerCase(FFolder);
 UnFormatDir(FFolder);
 CalcStringCRC32(AnsiLowerCase(FFolder),crc);
 FormatDir(FFolder);

 DBFolder:=AnsiLowerCase(FFolder);
 DBFolder:=NormalizeDBString(DBFolder);
 FQuery:=GetQuery;
 if GetDBType=DB_TYPE_BDE then SetSQL(FQuery,'Select FFileName From '+GetDefDBname+' where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
 if GetDBType=DB_TYPE_MDB then SetSQL(FQuery,'Select FFileName From (Select * from '+GetDefDBname+' where FolderCRC='+inttostr(Integer(crc))+') where (FFileName Like :FolderA) and not (FFileName like :FolderB)');

 SetStrParam(FQuery,0,'%'+DBFolder+'%');
 SetStrParam(FQuery,1,'%'+DBFolder+'%\%');
 try
  FQuery.Active:=True;
 except
 end;
 NewFiles:=GetNewFiles(FFolder,FQuery);

 FreeDS(FQuery);

end;

end.
