unit UnitOptimizeDublicatesThread;

interface

uses
  Classes, Language, Dolphin_DB, UnitLinksSupport, DB, SysUtils,
  CommonDBSupport, CmpUnit, UnitGroupsWork, win32crc,
  UnitDBDeclare;

type
  TThreadOptimizeDublicates = class(TThread)
  FStrParam : String;
  FIntParam : Integer;
  ResArray : TImageDBRecordAArray;
  fOptions : TOptimizeDublicatesThreadOptions;  
  ProgressInfo : TProgressCallBackInfo;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure DoExit;
    procedure TextOut;
    procedure TextOutEx; 
    procedure DoProgress;  
  public
    constructor Create(CreateSuspennded: Boolean;
            Options : TOptimizeDublicatesThreadOptions);
  end;

var
  TerminatingOptimizeDublicates: boolean;

implementation

uses CMDUnit;

{ TThreadOptimizeDublicates }

constructor TThreadOptimizeDublicates.Create(CreateSuspennded: Boolean;
  Options: TOptimizeDublicatesThreadOptions);
begin
 inherited Create(true);
 fOptions:=Options;
 if not CreateSuspennded then Resume;
end;

procedure TThreadOptimizeDublicates.DoExit;
begin
 fOptions.OnEnd(Self);
end;

procedure TThreadOptimizeDublicates.DoProgress;
begin
 FOptions.OnProgress(Self,ProgressInfo);
end;

procedure TThreadOptimizeDublicates.Execute;
var
  Table, SetQuery : TDataSet;
   FileName, Groups, Links, KeyWords, Comment, s, Folder, StrTh, SQLText, SetStr : String;
  i, ID, FileSize, Rating, Access, paramno, RecordCount, Attr : integer;
  Query : TDataSet;
  aFile : array of string;
  Include, Locked, Cont, FE : Boolean;
  crc : Cardinal;
  FromDB : string;
  f : File;    
  WideSearch : boolean;

  procedure DoUpdate;
  var
    i : integer;
  begin
   FStrParam:=Format(TEXT_MES_CURRENT_ITEM_UPDATED_DUBLICATES,[Table.FieldByName('ID').AsInteger,Trim(Table.FieldByname('Name').AsString)]);
   FIntParam:=LINE_INFO_OK;
   Synchronize(TextOutEx);
   Query.First;
   KeyWords:='';
   Query.First;
   For i:=1 to Query.RecordCount do
   begin
    FStrParam:=TEXT_MES_FILES_MERGED;
    FIntParam:=LINE_INFO_INFO;
    Synchronize(TextOutEx);

    FStrParam:=IntToStr(Query.FieldByName('ID').AsInteger)+' ['+Trim(Query.FieldByName('FFileName').AsString)+']';
    FIntParam:=LINE_INFO_PLUS;
    Synchronize(TextOutEx);
    Query.Next;
   end;

//   FStrParam:='----------------------------------------------';
//   Synchronize(TextOutEx);
  end;

  function NextParam : integer;
  begin
   Result:=paramno;
   inc(paramno);
  end;

  procedure DeleteRecordByID(ID : Integer);
  var
    DelQuery : TDataSet;
  begin
   DelQuery := GetQuery;
   SetSQL(DelQuery,'DELETE FROM '+GetDefDBName+' WHERE ID = '+IntToStr(ID));
   try
    ExecSQL(DelQuery);
   except
   end;
   FreeDS(DelQuery);
  end;

  procedure LockFile;
  begin
   if not FE then exit;
   Assignfile(f,FileName);
   Locked:=false;
   try
    Reset(f);
    Locked:=true;
   except
    Locked:=false;
   end;
  end;

  procedure UnLockFile;
  begin
   if not FE then exit;
   try
    if Locked then
    System.Close(f);
   except
   end;
   Locked:=false;
  end;

begin

 Locked:=false;
 TerminatingOptimizeDublicates:=false;
 Table := GetQuery;
 SetSQL(Table,'Select ID, StrTh, FFileName, Name From '+GetDefDBName+' ORDER BY ID');
 try
  Table.Active:=true;
  RecordCount:=CommonDBSupport.GetRecordsCount(dbname);
 except
  FStrParam:=TEXT_MES_ERROR;
  Synchronize(TextOut);
  FreeDS(Table);
  Synchronize(DoExit);
  exit;
 end;
 Table.First;
 WideSearch:=false;
 Repeat
  if TerminatingOptimizeDublicates or CMD_Command_Break then Break;

  FStrParam:=Format(TEXT_MES_CURRENT_ITEM_F,[IntToStr(Table.RecNo),IntToStr(RecordCount),Trim(Table.FieldByname('Name').AsString)]);
  FIntParam:=LINE_INFO_PROGRESS;
  Synchronize(TextOut);

  ProgressInfo.MaxValue:=Table.RecordCount;
  ProgressInfo.Position:=Table.RecNo;
  Synchronize(DoProgress);

  Query:=GetQuery;
  paramno:=0;
  if (GetDBType(dbname)=DB_TYPE_MDB) then
  begin
   if WideSearch then FromDB:=GetDefDBname else
   FromDB:='(Select * from '+GetDefDBname+' where StrThCrc=:StrThCrc)';

   SetSQL(Query,'SELECT * FROM '+FromDB+' WHERE StrTh = :StrTh ORDER BY ID');
   SetIntParam(Query,nextparam,StringCRC(Table.FieldByName('StrTh').AsString));
   if not WideSearch then 
   SetStrParam(Query,nextparam,Table.FieldByName('StrTh').AsString);
  end else
  begin
   SetSQL(Query,'SELECT * FROM '+GetDefDBname+' WHERE StrTh = :StrTh ORDER BY ID');
   SetStrParam(Query,nextparam,Table.FieldByName('StrTh').AsString);
  end;


  Query.Open;

  if Query.RecordCount<2 then
  begin
   if (Query.RecordCount=0) and not WideSearch then
   begin
    FStrParam:=TEXT_MES_WARNING;
    FIntParam:=LINE_INFO_INFO;
    Synchronize(TextOutEx);

    FStrParam:=Format(TEXT_MES_RECORD_NOT_FOUND_F,[Table.FieldByName('ID').AsInteger]);
    FIntParam:=LINE_INFO_WARNING;
    Synchronize(TextOutEx);
    WideSearch:=true;
    FreeDS(Query);
    Continue;
   end;
   if (Query.RecordCount=0) and WideSearch then
   begin
    FStrParam:=TEXT_MES_ERROR;
    FIntParam:=LINE_INFO_INFO;
    Synchronize(TextOutEx);

    FStrParam:=Format(TEXT_MES_RECORD_NOT_FOUND_ERROR_F,[Table.FieldByName('ID').AsInteger,Table.FieldByName('FFileName').AsString]);
    FIntParam:=LINE_INFO_ERROR;
    Synchronize(TextOutEx);
    WideSearch:=false;
   end;

   FreeDS(Query);
   Table.Next;
   Continue;
  end;
  WideSearch:=false;
  Query.First;
  Cont:=false;
  FileSize:=Query.FieldByName('FileSize').AsInteger;
  For i:=1 to Query.RecordCount do
  begin
   if FileSize<>Query.FieldByName('FileSize').AsInteger then
   begin
    FreeDS(Query);
    Table.Next;
    Cont:=true;
    Break;
   end;
   Query.Next;
  end;
  if Cont then Continue;

  //Filesizes and StrTh equal - its dublicates!
  //Finding Real FileName ( min(ID) and FileExists )

  DoUpdate;

  //FileName + min(ID)
  Query.First;
  FileName:=Query.FieldByName('FFileName').AsString;
  ID:=Query.FieldByName('ID').AsInteger;
  StrTh:=Query.FieldByName('StrTh').AsString;
  Rating:=0;
  FE:=false;
  For i:=1 to Query.RecordCount do
  begin
   if FileExists(Query.FieldByName('FFileName').AsString) then
   begin
    FileName:=Query.FieldByName('FFileName').AsString; 
    StrTh:=Query.FieldByName('StrTh').AsString;     
    ID:=Query.FieldByName('ID').AsInteger;
    FE:=true;
    break;
   end;
   Query.Next;
  end;

  //CRC
  Folder:=GetDirectory(FileName);
  UnFormatDir(Folder);
  CalcStringCRC32(Folder,crc);

  //Max Rating
  Query.First;
  Rating:=0;
  For i:=1 to Query.RecordCount do
  begin
   if Query.FieldByName('Rating').AsInteger>Rating then
   begin
    Rating:=Query.FieldByName('Rating').AsInteger;
    break;
   end;
   Query.Next;
  end;

  //KeyWords
  Query.First;
  KeyWords:='';
  For i:=1 to Query.RecordCount do
  begin
   AddWordsA( Query.FieldByName('KeyWords').AsString, KeyWords);
   Query.Next;
  end;

  //Comment
  Query.First;
  Comment:='';
  s:='';
  For i:=1 to Query.RecordCount do
  begin
   if s<>Query.FieldByName('Comment').AsString then
   begin
    if Comment='' then Comment:=Query.FieldByName('Comment').AsString else
    Comment:=Comment+#13+Query.FieldByName('Comment').AsString;
   end;
   s:=Query.FieldByName('KeyWords').AsString;
   Query.Next;
  end;

  //Groups
  Query.First;
  Groups:='';
  For i:=1 to Query.RecordCount do
  begin
   AddGroupsToGroups( Groups, Query.FieldByName('Groups').AsString);
   Query.Next;
  end;

  //Links
  Query.First;
  Links:='';
  For i:=1 to Query.RecordCount do
  begin
   ReplaceLinks('',Query.FieldByName('Links').AsString,Links);
   Query.Next;
  end;

  //Access
  Query.First;
  Access:=db_access_none;
  For i:=1 to Query.RecordCount do
  begin
   if Query.FieldByName('Access').AsInteger=db_access_private then
   begin
    Access:=db_access_private;
    break;
   end;
   Query.Next;
  end;

  //Include
  Query.First;
  Include:=false;
  For i:=1 to Query.RecordCount do
  begin
   if Query.FieldByName('Include').AsBoolean then
   begin
    Include:=true;
    break;
   end;
   Query.Next;
  end;

  //ATTR

  if FileExists(FileName) then
   Attr:=db_attr_norm else Attr:=db_attr_not_exists;

  paramno:=0;
  SetStr:='FFileName=:FFileName,';
  SetStr:=SetStr+'Name=:Name,';
  SetStr:=SetStr+'StrTh=:StrTh,';
  if GetDBType=DB_TYPE_MDB then    
  SetStr:=SetStr+'StrThCrc=:StrThCrc,';
  SetStr:=SetStr+'KeyWords=:KeyWords,';
  SetStr:=SetStr+'Comment=:Comment,';
  SetStr:=SetStr+'Links=:Links,';
  SetStr:=SetStr+'Groups=:Groups,';
  SetStr:=SetStr+'Access=:Access,';
  SetStr:=SetStr+'Include=:Include,';
  SetStr:=SetStr+'Rating=:Rating,';  ;  
  SetStr:=SetStr+'Attr=:Attr,';
  if GetDBType=DB_TYPE_MDB then
  SetStr:=SetStr+'FolderCRC=:FolderCRC';

  SetQuery:=GetQuery;
  SQLText:='Update '+GetDefDBname+' Set '+SetStr+' Where ID = '+IntToStr(ID);
  SetSQL(SetQuery,SQLText);

  SetStrParam(SetQuery,nextparam,AnsiLowerCase(FileName));
  SetStrParam(SetQuery,nextparam,ExtractFileName(FileName));
  SetStrParam(SetQuery,nextparam,StrTh);
  if GetDBType=DB_TYPE_MDB then
  SetIntParam(SetQuery,nextparam,Integer(StringCRC(StrTh)));
  SetStrParam(SetQuery,nextparam,KeyWords);
  SetStrParam(SetQuery,nextparam,Comment);
  SetStrParam(SetQuery,nextparam,Links);
  SetStrParam(SetQuery,nextparam,Groups);
  SetIntParam(SetQuery,nextparam,Access);
  SetBoolParam(SetQuery,nextparam,Include);
  SetIntParam(SetQuery,nextparam,Rating);
  SetIntParam(SetQuery,nextparam,Attr);
  if GetDBType=DB_TYPE_MDB then
  SetIntParam(SetQuery,nextparam,Integer(crc));

  try
   ExecSQL(SetQuery);
  except
   FreeDS(SetQuery);
   FreeDS(Query);
   Table.Next;
   Continue;
  end;

  //DELETING OTHER RECORDS AND FILES!
  SetLength(aFile,1);

  Query.First;
  LockFile;
  For i:=1 to Query.RecordCount do
  begin
   if Query.FieldByName('ID').AsInteger<>ID then
   begin
    DeleteRecordByID(Query.FieldByName('ID').AsInteger);
    aFile[0]:=Query.FieldByName('FFileName').AsString;
    try
     if FileExists(aFile[0]) then
     if AnsiLowerCase(aFile[0])<>AnsiLowerCase(FileName) then
     SilentDeleteFiles( 0, aFile , true, true);
    except
    end;
   end;
   Query.Next;
  end;
  FreeDS(Query);

  UnLockFile;

  Table.Next;
 Until Table.Eof;
 FreeDS(Table);
 Sleep(5000);
 Synchronize(DoExit);
end;

procedure TThreadOptimizeDublicates.TextOut;
begin            
 fOptions.WriteLineProc(Self,FStrParam,FIntParam);
end;

procedure TThreadOptimizeDublicates.TextOutEx;
begin
 fOptions.WriteLnLineProc(Self,FStrParam,FIntParam);
end;

end.
