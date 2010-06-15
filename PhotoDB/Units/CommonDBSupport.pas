unit CommonDBSupport;

interface

//{$DEFINE DEBUG}

uses
{$IFNDEF DEBUG}
Dolphin_DB, ReplaseLanguageInScript, ReplaseIconsInScript, UnitScripts,
UnitDBDeclare,
{$ENDIF}
 Windows, ADODB, SysUtils, DB, DBTables, ActiveX, Variants, Classes, ComObj,
 UnitINI, BDE;

const

 DB_TYPE_UNKNOWN = 0;
 DB_TYPE_BDE     = 1;
 DB_TYPE_MDB     = 2;

 DB_TABLE_UNKNOWN  = 0;
 DB_TABLE_GROUPS   = 1;
 DB_TABLE_IMAGES   = 2;
 DB_TABLE_LOGIN    = 3;
 DB_TABLE_SETTINGS = 4;

 type
  TADOConnectionX = record
   ADOConnection : TADOConnection;
   FileName : string;
   RefCount : integer;
  end;

var
  ADOConnections : array of TADOConnectionX;
{$IFNDEF DEBUG}
  aScript : TScript;
{$ENDIF}
  LoadInteger : integer;
  aFS : TFileStream;
  LoadScript : string;
  DBFConnectionString : string = 'Provider=Microsoft.Jet.OLEDB.4.0;Password="";User ID=Admin;'+
                            'Data Source=%s;Mode=Share Deny None;Extended Properties="";'+
                            'Jet OLEDB:System database="";Jet OLEDB:Registry Path="";'+
                            'Jet OLEDB:Database Password="";Jet OLEDB:Engine Type=5;'+
                            'Jet OLEDB:Database Locking Mode=1;'+
                            'Jet OLEDB:Global Partial Bulk Ops=2;'+
                            'Jet OLEDB:Global Bulk Transactions=1;'+
                            'Jet OLEDB:New Database Password="";'+
                            'Jet OLEDB:Create System Database=False;'+
                            'Jet OLEDB:Encrypt Database=False;'+        
                            'Jet OLEDB:Don''t Copy Locale on Compact=False;'+
                            'Jet OLEDB:Compact Without Replica Repair=False;'+
                            'Jet OLEDB:SFP=False';

  // Read Only String
  DBViewConnectionString : string =
  'Provider=Microsoft.Jet.OLEDB.4.0;Password="";'+
  'User ID=Admin;Data Source=%s;'+
  'Mode=Share Deny Write;Extended Properties="";'+
  'Jet OLEDB:System database="";Jet OLEDB:Registry Path="";'+
  'Jet OLEDB:Database Password="";Jet OLEDB:Engine Type=0;'+
  'Jet OLEDB:Database Locking Mode=1;Jet OLEDB:Global Partial Bulk Ops=2;'+
  'Jet OLEDB:Global Bulk Transactions=1;Jet OLEDB:New Database Password="";'+
  'Jet OLEDB:Create System Database=False;Jet OLEDB:Encrypt Database=False;'+
  'Jet OLEDB:Don''t Copy Locale on Compact=False;Jet OLEDB:'+
  'Compact Without Replica Repair=False;Jet OLEDB:SFP=False';
  
  MDBProvider : string = 'Microsoft.Jet.OLEDB.4.0';

{$IFDEF DEBUG}
 var dbname : string = 'D:\Dmitry\ImagesDB\dolphin.db';
 BDEIsInstalled : boolean = true;
{$ENDIF}

function GetDBType : integer; overload;
function GetDBType(dbname : string) : integer; overload;

procedure FreeDS(var DS : TDataSet);
function ADOInitialize(dbname : String) : TADOConnection;

function GetTable : TDataSet; overload;
function GetTable(Table : String; TableID : integer = DB_TABLE_UNKNOWN) : TDataSet; overload;

function ActiveTable(Table : TDataSet; Active : boolean) : boolean;

function GetConnectionString(dbname : String) : String; overload;
function GetConnectionString : String; overload;

function GetQuery : TDataSet; overload;
function GetQuery(TableName : string) : TDataSet; overload;
function GetQuery(TableName : string; TableType : integer) : TDataSet; overload;

procedure SetSQL(SQL : TDataSet; SQLText : String);
procedure ExecSQL(SQL : TDataSet);

function GetBoolParam(Query : TDataSet; index : integer) : boolean;

procedure LoadParamFromStream(Query : TDataSet; index : integer; Stream : TStream; FT : TFieldType);
procedure SetDateParam(Query : TDataSet; index : integer; Date : TDateTime);
procedure SetBoolParam(Query : TDataSet; index : integer; Bool : Boolean);
procedure SetStrParam(Query : TDataSet; index : integer; Str : String);
procedure SetIntParam(Query : TDataSet; index : integer; int : integer);
function QueryParamsCount(Query : TDataSet) : integer;

function GetQueryText(Query : TDataSet) : string;
procedure AssignParams(S,D : TDataSet);
function GetDefDBName : string;
function GetBlobStream(F : TField; Mode : TBlobStreamMode) : TStream;
procedure AssignParam(Query : TDataSet; index : integer; Value : TPersistent);
procedure FlushBuffers(DS : TDataSet);

function BDECreateImageTable(TableName : string) : boolean;
function ADOCreateImageTable(TableName : string) : boolean;

function BDECreateGroupsTable(TableName : string) : boolean;
function ADOCreateGroupsTable(TableName : string) : boolean;

//ADO Only
function ADOCreateSettingsTable(TableName : string) : boolean;

procedure CreateMSAccessDatabase(FileName: string);
procedure TryRemoveConnection(dbname : string; Delete : boolean = false);
procedure RemoveADORef(ADOConnection : TADOConnection);

function GetTableNameByFileName(FileName : string) : string;
Procedure AssingQuery(var QueryS, QueryD : TDataSet);

function GetRecordsCount(Table : string) : integer;
Procedure InitializeDBLoadScript;
function UpdateImageSettings(TableName : String; Settings : TImageDBOptions) : boolean;
function GetImageSettingsFromTable(TableName : string) : TImageDBOptions;
procedure PackTable(FileName : string);
function GetDefaultImageDBOptions : TImageDBOptions;

implementation

//{$IFNDEF DEBUG}
 uses UnitGroupsWork;
//{$ENDIF}

procedure FlushBuffers(DS : TDataSet);
begin
 if (DS is TTable) then (DS as TTable).FlushBuffers;
end;

function GetBlobStream(F : TField; Mode : TBlobStreamMode) : TStream;
begin
 Result:=nil;
 if (F is TBlobField) and (F.DataSet is TQuery) then Result:=TBlobStream.Create(TBlobField(F),Mode);
 if (F is TBlobField) and (F.DataSet is TADOQuery) then Result:=TADOBlobStream.Create(TBlobField(F),Mode);
 if (F is TBlobField) and (F.DataSet is TTable) then Result:=TBlobStream.Create(TBlobField(F),Mode);
 if (F is TBlobField) and (F.DataSet is TADODataSet) then Result:=TADOBlobStream.Create(TBlobField(F),Mode);
end;

procedure AssignParams(S,D : TDataSet);
begin
 if (S is TADOQuery) then (D as TADOQuery).Parameters.Assign((S as TADOQuery).Parameters);
 if (S is TQuery) then (D as TQuery).Params.Assign((S as TQuery).Params);
end;

function GetQueryText(Query : TDataSet) : string;
begin
 Result:='';
 if (Query is TADOQuery) then Result:=(Query as TADOQuery).SQL.Text;
 if (Query is TQuery) then Result:=(Query as TQuery).SQL.Text;
end;

function QueryParamsCount(Query : TDataSet) : integer;
begin
 Result:=0;
 if (Query is TADOQuery) then Result:=(Query as TADOQuery).Parameters.Count;
 if (Query is TQuery) then Result:=(Query as TQuery).Params.Count;
end;

procedure LoadParamFromStream(Query : TDataSet; index : integer; Stream : TStream; FT : TFieldType);
begin
 Stream.Seek(0,soFromBeginning);
 if (Query is TADOQuery) then
   (Query as TADOQuery).Parameters[index].LoadFromStream(Stream,FT);
 if (Query is TQuery) then
   (Query as TQuery).Params[index].LoadFromStream(Stream,FT);
end;

procedure AssignParam(Query : TDataSet; index : integer; Value : TPersistent);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Assign(Value);
 if (Query is TQuery) then (Query as TQuery).Params[index].Assign(Value);
end;

function GetBoolParam(Query : TDataSet; index : integer) : boolean;
begin
 Result:=false;
 if (Query is TADOQuery) then Result:=(Query as TADOQuery).Parameters[index].Value;
 if (Query is TQuery) then Result:=(Query as TQuery).Params[index].AsBoolean;
end;

procedure SetBoolParam(Query : TDataSet; index : integer; Bool : Boolean);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Value:=Bool;
 if (Query is TQuery) then (Query as TQuery).Params[index].AsBoolean:=Bool;
end;

procedure SetDateParam(Query : TDataSet; index : integer; Date : TDateTime);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Value:=Date;
 if (Query is TQuery) then (Query as TQuery).Params[index].AsDateTime:=Date;
end;

procedure SetIntParam(Query : TDataSet; index : integer; int : integer);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Value:=int;
 if (Query is TQuery) then (Query as TQuery).Params[index].AsInteger:=int;
end;

procedure SetStrParam(Query : TDataSet; index : integer; Str : String);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Value:=Str;
 if (Query is TQuery) then (Query as TQuery).Params[index].AsString:=Str;
end;

function GetDBType : integer;
begin
 Result:=DB_TYPE_UNKNOWN;
{ if dbname<>'' then
 if dbname[1]='"' then dbname:=Copy(dbname,2,Length(dbname)-2);        }
 if AnsiLowerCase(ExtractFileExt(dbname))='.db' then Result:=DB_TYPE_BDE;
 if AnsiLowerCase(ExtractFileExt(dbname))='.mdb' then Result:=DB_TYPE_MDB; 
 if AnsiLowerCase(ExtractFileExt(dbname))='.photodb' then Result:=DB_TYPE_MDB;
 if AnsiLowerCase(ExtractFileExt(dbname))='.dll' then Result:=DB_TYPE_BDE;
 if AnsiLowerCase(ExtractFileExt(dbname))='.ocx' then Result:=DB_TYPE_MDB;
end;

function GetDBType(dbname : string) : integer;
begin
 Result:=DB_TYPE_UNKNOWN;
{ if dbname<>'' then
 if dbname[1]='"' then dbname:=Copy(dbname,2,Length(dbname)-2);   }
 if AnsiLowerCase(ExtractFileExt(dbname))='.db' then Result:=DB_TYPE_BDE;
 if AnsiLowerCase(ExtractFileExt(dbname))='.mdb' then Result:=DB_TYPE_MDB;  
 if AnsiLowerCase(ExtractFileExt(dbname))='.photodb' then Result:=DB_TYPE_MDB;
 if AnsiLowerCase(ExtractFileExt(dbname))='.dll' then Result:=DB_TYPE_BDE;
 if AnsiLowerCase(ExtractFileExt(dbname))='.ocx' then Result:=DB_TYPE_MDB;
end;

function GetConnectionString : String;
begin
 Result:=Format(DBFConnectionString,[dbname]);
end;

function GetConnectionString(dbname : String) : String;
begin
 Result:=Format(DBFConnectionString,[dbname]);
end;

procedure ExecSQL(SQL : TDataSet);
begin
 if (SQL is TADOQuery) then (SQL as TADOQuery).ExecSQL;
 if (SQL is TQuery) then (SQL as TQuery).ExecSQL;
end;

procedure SetSQL(SQL : TDataSet; SQLText : String);
var
  i : integer;
begin
 for i:=1 to 20 do
 begin
  try
   if (SQL is TADOQuery) then
   begin
    (SQL as TADOQuery).SQL.Text:=SQLText;
    (SQL as TADOQuery).Parameters.ParseSQL((SQL as TADOQuery).SQL.Text, true);
   end;
   if (SQL is TQuery) then (SQL as TQuery).SQL.Text:=SQLText;
   break;
  except  
   on e : Exception do
   begin
    EventLog(':SetSQL() throw exception: '+e.Message);
    Sleep(50);
   end;
  end;
 end;
end;

function ActiveSQL(SQL : TDataSet; Active : boolean) : boolean;
begin
 try
  if (SQL is TADOQuery) then (SQL as TADOQuery).Active:=Active;
  if (SQL is TQuery) then (SQL as TQuery).Active:=Active;
 except
  on e : Exception do
  begin
   EventLog(':ActiveSQL() throw exception: '+e.Message);
   Result:=false;
   exit;
  end;
 end;
 Result:=SQL<>nil;
end;

function ActiveTable(Table : TDataSet; Active : boolean) : boolean;
begin
 try
 if (Table is TADODataSet) then (Table as TADODataSet).Active:=Active;
 if (Table is TTable) then (Table as TTable).Active:=Active;
 except
  on e : Exception do
  begin
   EventLog(':ActiveTable() throw exception: '+e.Message);
   Result:=false;
   exit;
  end;
 end;
 Result:=Table<>nil;
end;

function GetQuery : TDataSet;
begin
 Result:=GetQuery(dbname,GetDBType);
end;

function GetTableNameByFileName(FileName : string) : string;
begin
 if GetDBType(FileName)=DB_TYPE_MDB then
 Result:='ImageTable' else
 Result:='"'+FileName+'"';
end;

Procedure AssingQuery(var QueryS, QueryD : TDataSet);
begin
 if (QueryS is TADOQuery) then
 begin
  SetSQL(QueryD,(QueryS as TADOQuery).SQL.Text);
  (QueryS as TADOQuery).Parameters.Assign((QueryD as TADOQuery).Parameters);
 end;
 if (QueryS is TQuery) then
 begin
  (QueryD as TQuery).SQL.Assign((QueryS as TQuery).SQL);
  (QueryD as TQuery).Params.Assign((QueryS as TQuery).Params);
 end;
end;

function GetQuery(TableName : string) : TDataSet;
begin
 Result:=GetQuery(TableName,GetDBType(TableName));
end;

function GetQuery(TableName : string; TableType : integer) : TDataSet;
begin
 Result:=nil;
 if TableType=DB_TYPE_UNKNOWN then TableType:=GetDBType;
 if TableType=DB_TYPE_BDE then
 begin
  Result:=TQuery.Create(nil);
 end;
 if TableType=DB_TYPE_MDB then
 begin
  CoInitialize(nil);
  Result:=TADOQuery.Create(nil);
  (Result as TADOQuery).Connection:=ADOInitialize(TableName);
 end;
end;

function GetTable : TDataSet;
begin
 Result:=GetTable(dbname,DB_TABLE_IMAGES);
end;

function GetTable(Table : String; TableID : integer = DB_TABLE_UNKNOWN) : TDataSet;
begin
 Result:=nil;
 if (GetDBType(Table)=DB_TYPE_BDE) and BDEIsInstalled then
 begin
  Result:=TTable.Create(nil);
  if Table<>'' then if Table[1]='"' then Table:=Copy(Table,2,Length(Table)-2);
  if TableID=DB_TABLE_IMAGES then (Result as TTable).TableName:=Table;
  if TableID=DB_TABLE_GROUPS then
  begin
   (Result as TTable).TableName:=GroupsTableFileNameW(Table);
  end;
  {$IFNDEF DEBUG}
  if TableID=DB_TABLE_LOGIN then (Result as TTable).TableName:=Table;
  {$ENDIF}
 end;
 if GetDBType(Table)=DB_TYPE_MDB then
 begin
  CoInitialize(nil);
  Result:=TADODataSet.Create(nil);
  (Result as TADODataSet).Connection:=ADOInitialize(Table);
  (Result as TADODataSet).CommandType:=cmdTable;
  if TableID=DB_TABLE_GROUPS then (Result as TADODataSet).CommandText:='Groups';
  if TableID=DB_TABLE_IMAGES then (Result as TADODataSet).CommandText:='ImageTable';
  if TableID=DB_TABLE_LOGIN then (Result as TADODataSet).CommandText:='Login';        
  if TableID=DB_TABLE_SETTINGS then (Result as TADODataSet).CommandText:='DBSettings';
 end;
end;

function GetRecordsCount(Table : string) : integer;
var
  FTable : TDataSet;
begin
 Result:=0;
 if (GetDBType(Table)=DB_TYPE_BDE) and BDEIsInstalled then
 begin
  FTable:=TTable.Create(nil);
  (FTable as TTable).TableName:=Table;
  FTable.Active:=True;
  Result:=FTable.RecordCount;
  FTable.Free;
 end;
 if (GetDBType(Table)=DB_TYPE_MDB) then
 begin
  FTable:=GetQuery(Table);            //ONLY MDB
  SetSQL(FTable,'Select count(*)as RecordsCount from ImageTable');
  FTable.Open;
  Result:=FTable.FieldByName('RecordsCount').AsInteger;
  FreeDS(FTable);
 end;

end;

function ADOCreateGroupsTable(TableName : string) : boolean;
var
  SQL : string;
  fQuery : TDataSet;
begin
 Result:=true;
 fQuery:=GetQuery(TableName);
 SQL:= 'CREATE TABLE Groups ( '+
       'ID Autoincrement , '+
       'GroupCode Memo , ' +
       'GroupName Memo , ' +
       'GroupComment Memo , '+
       'GroupDate Date , ' +
       'Groupfaces Memo , ' +
       'GroupAccess INTEGER , ' +
       'GroupImage LONGBINARY, ' +
       'GroupKW Memo , ' +
       'RelatedGroups Memo , ' +
       'IncludeInQuickList Logical , ' +
       'GroupAddKW Logical)';
 SetSQL(fQuery,SQL);
 try
  ExecSQL(fQuery);
 except
  on e : Exception do
  begin
   EventLog(':ADOCreateGroupsTable() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 FreeDS(FQuery); 
end;

function UpdateImageSettings(TableName : String; Settings : TImageDBOptions) : boolean;
var
  SQL : string;
  fQuery : TDataSet;
begin
 Result:=true;
 fQuery:=GetQuery(TableName);

 SQL:= 'Update DBSettings Set Version='+IntToStr(Settings.Version)+
       ', DBJpegCompressionQuality = '+IntToStr(Settings.DBJpegCompressionQuality)+
       ', ThSizePanelPreview = '+IntToStr(Settings.ThSizePanelPreview)+','+
        'ThImageSize = '+IntToStr(Settings.ThSize)+
        ', ThHintSize = '+IntToStr(Settings.ThHintSize)+
        ', DBName = "'+Settings.Name+'"'+
        ', DBDescription = "'+Settings.Description+'"';
 SetSQL(fQuery,SQL);
 try
  ExecSQL(fQuery);
 except
  on e : Exception do
  begin
   EventLog(':UpdateImageSettings() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
end;

{
  TImageDBOptions = record
    DBJpegCompressionQuality : byte;
    ThSize : integer;
    ThSizePanelPreview : integer;
    ThHintSize : integer;
  end;

var
        // Image sizes
        DBJpegCompressionQuality : integer = 75;
        ThSize : integer = 152;
        ThSizeExplorerPreview : integer = 100;
        ThSizePropertyPreview : integer = 100;
        ThSizePanelPreview : integer = 75;
        ThImageSize : integer = 150;
        ThHintSize : integer = 300;
}
function GetDefaultImageDBOptions : TImageDBOptions;
begin
 Result.DBJpegCompressionQuality:=75;
 Result.ThSize  := 150;
 Result.ThSizePanelPreview := 75;
 Result.ThHintSize := 300;
end;

function GetImageSettingsFromTable(TableName : string) : TImageDBOptions;
var
  SQL : string;
  fQuery : TDataSet;
begin
 Result:=GetDefaultImageDBOptions;
 fQuery:=GetQuery(TableName);
 SQL:= 'Select * from DBSettings';
 try
  SetSQL(fQuery,SQL);
  ActiveSQL(fQuery,true);
  if fQuery.Active then
  begin
   Result.DBJpegCompressionQuality:=fQuery.FieldByName('DBJpegCompressionQuality').AsInteger;
   Result.ThSize:=fQuery.FieldByName('ThImageSize').AsInteger;
   Result.ThSizePanelPreview:=fQuery.FieldByName('ThSizePanelPreview').AsInteger;
   Result.ThHintSize:=fQuery.FieldByName('ThHintSize').AsInteger;
   Result.Name:=fQuery.FieldByName('DBName').AsString;
   Result.Description:=fQuery.FieldByName('DBDescription').AsString;
  end;
 except
  on e : Exception do
  begin
   EventLog(':GetImageSettingsFromTable() throw exception: '+e.Message);
   try
    ADOCreateSettingsTable(TableName);
    UpdateImageSettings(TableName,Result);
   except
    on e : Exception do EventLog(':GetImageSettingsFromTable()/Restore throw exception: '+e.Message);
   end;
  end;
 end;
 FreeDS(fQuery);
end;

function ADOCreateSettingsTable(TableName : string) : boolean;
var
  SQL : string;
  fQuery : TDataSet;
begin
 Result:=true;
 fQuery:=GetQuery(TableName);

{
        DBJpegCompressionQuality = 75;
        ThSize = 152;
        ThSizeExplorerPreview = 100;
        ThSizePropertyPreview = 100;
        ThSizePanelPreview = 75;
        ThImageSize = 150;
        ThHintSize = 300;
}
 SQL:= 'DROP TABLE DBSettings';

 SetSQL(fQuery,SQL);
 try
  ExecSQL(fQuery);
 except
  on e : Exception do
  begin
   EventLog(':ADOCreateSettingsTable() throw exception: '+e.Message);
  end;
 end;

 SQL:= 'CREATE TABLE DBSettings ( '+
       'Version INTEGER , '+
       'DBName Character(255) , '+
       'DBDescription Character(255) , '+
       'DBJpegCompressionQuality INTEGER , ' +
       'ThSizePanelPreview INTEGER , ' +
       'ThImageSize INTEGER , ' +
       'ThHintSize INTEGER)';

 SetSQL(fQuery,SQL);
 try
  ExecSQL(fQuery);
 except
  on e : Exception do
  begin
   EventLog(':ADOCreateSettingsTable() throw exception: '+e.Message);
   Result:=false;
  end;
 end;

{ SQL:= 'Insert (Version, DBJpegCompressionQuality, ThSizePanelPreview,'+
        'ThImageSize, ThHintSize) Into DBSettings Values (:Version,'+
        ':DBJpegCompressionQuality,:ThSizePanelPreview,:ThImageSize,:ThHintSize)';  }

 SQL:= 'Insert Into DBSettings  (Version, DBJpegCompressionQuality, ThSizePanelPreview,'+
        'ThImageSize, ThHintSize, DBName, DBDescription) Values (1,75,75,150,300,"","")';
 SetSQL(fQuery,SQL);
 try
  ExecSQL(fQuery);
 except
  on e : Exception do
  begin
   EventLog(':ADOCreateSettingsTable() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 try
  ExecSQL(fQuery);
 except    
  on e : Exception do
  begin
   EventLog(':ADOCreateSettingsTable() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 FreeDS(FQuery); 
end;

function BDECreateGroupsTable(TableName : string) : boolean;
var
  SQL : string;
  fQuery : TDataSet;
begin
 FQuery:=GetQuery(TableName,DB_TABLE_GROUPS);
 SQL:= 'CREATE TABLE "'+GroupsTableFileNameW(TableName)+'" ( '+
       'ID AUTOINC , '+
       'GroupCode BLOB(240,1) , ' +
       'GroupName BLOB(240,1) , ' +
       'GroupComment BLOB(240,1) , '+
       'GroupDate Date , ' +
       'Groupfaces BLOB(240,1) , ' +
       'GroupAccess INTEGER , ' +
       'GroupImage BLOB(1,2), ' +
       'GroupKW BLOB(240,1) , ' +
       'RelatedGroups BLOB(240,1) , ' +
       'IncludeInQuickList BOOLEAN , ' +
       'GroupAddKW BOOLEAN)';
 SetSQL(FQuery,SQL);
 try
  ExecSQL(FQuery);
 except
  on e : Exception do
  begin
   EventLog(':BDECreateGroupsTable() throw exception: '+e.Message);
   Result:=False;
   exit;
  end;
 end;
 Result:=True;
 FreeDS(FQuery);
end;

procedure CreateMSAccessDatabase(FileName: string);
var
  DAO: Variant;
  i: integer; 
const Engines: array[0..2] of string = ('DAO.DBEngine.36', 'DAO.DBEngine.35', 'DAO.DBEngine'); 

  function CheckClass(OLEClassName: string): boolean;
  var
    Res: HResult;
    G : TGUID;
  begin
    G:=ProgIDToClassID(OLEClassName);
    Res := CoCreateInstance(G, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IDispatch, Res);
    Result:=Res = S_OK;
  end;
begin 
  for i := 0 to 2 do 
    if CheckClass(Engines[i]) then
      begin 
        DAO := CreateOleObject(Engines[i]); 
        DAO.Workspaces[0].CreateDatabase(FileName, ';LANGID=0x0409;CP=1252;COUNTRY=0', 32);
        exit;
      end;
  raise Exception.Create('DAO engine could not be initialized'); 
end; 

function BDECreateImageTable(TableName : string) : boolean;
var
  SQL : string;
  fQuery : TQuery;
begin
 fQuery:=TQuery.Create(nil);
 sql:= 'CREATE TABLE "'+TableName+'" ( '+
       'ID  AUTOINC , '+
       'Name CHAR(255) , '+
       'FFileName BLOB(240,1) , ' +
       'Comment BLOB(240,1) , ' +
       'IsDate BOOLEAN , ' +
       'DateToAdd Date , ' +
       'Owner CHAR(255) , '+
       'Rating INTEGER , ' +
       'Thum BLOB(1,2) , '+   
       'FileSize INTEGER , '+
       'KeyWords BLOB(240,1) , '+
       'Groups BLOB(240,1) , '+
       'StrTh CHAR(255) , '+
       'Attr INTEGER , ' +
       'Collection CHAR(255) , '+
       'Access INTEGER , '+
       'Width INTEGER , '+
       'Height INTEGER , '+
       'Colors INTEGER , '+
       'Include BOOLEAN , '+
       'Links BLOB(1,1) , '+
       'aTime TIME , '+
       'IsTime BOOLEAN , ' +
       'Rotated INTEGER )';
 fQuery.sql.text:=sql;
 try
  fQuery.ExecSQL;
 except
  on e : Exception do
  begin
   EventLog(':BDECreateImageTable() throw exception: '+e.Message);
   Result:=false;
   exit;
  end;
 end;
 fQuery.free;
 Result:=true;
end;

function ADOCreateImageTable(TableName : string) : boolean;
var
  SQL : string;
  fQuery : TDataSet;
begin
 Result:=false;
 try
  CreateMSAccessDatabase(TableName);
 except
  on e : Exception do EventLog(':ADOCreateImageTable() throw exception: '+e.Message);
 end;
 fQuery:=GetQuery(TableName,GetDBType(TableName));
 SQL:= 'CREATE TABLE ImageTable ('+
       'ID Autoincrement,'+
       'Name Character(255),'+
       'FFileName Memo,'+
       'Comment Memo,'+
       'IsDate Logical,'+
       'DateToAdd Date ,'+
       'Owner  Character(255),'+
       'Rating INTEGER ,'+
       'Thum  LONGBINARY,'+
       'FileSize INTEGER ,'+
       'KeyWords Memo,'+
       'Groups Memo,'+
       'StrTh  Memo,'+  //Character fault when special characters
       'StrThCrc INTEGER , '+
       'Attr INTEGER,'+
       'Collection  Character(255),'+
       'Access INTEGER ,'+
       'Width INTEGER ,'+
       'Height INTEGER ,'+
       'Colors INTEGER ,'+
       'Include Logical,'+
       'Links Memo,'+
       'aTime TIME,'+
       'IsTime Logical,'+
       'FolderCRC INTEGER,'+
       'Rotated INTEGER )';
 SetSQL(fQuery,SQL);
 try
  ExecSQL(fQuery);
 except   
  on e : Exception do
  begin
   EventLog(':ADOCreateImageTable() throw exception: '+e.Message);
   FreeDS(fQuery);
   exit;
  end;
 end;
 Result:=true;
 FreeDS(fQuery);

 fQuery:=GetQuery(TableName,GetDBType(TableName));
 try
  SQL:='CREATE INDEX aID ON ImageTable(ID)';
  SetSQL(fQuery,SQL);
  ExecSQL(fQuery);
  //DROP INDEX <Index name>;
  SQL:='CREATE INDEX aFolderCRC ON ImageTable(FolderCRC)';
  SetSQL(fQuery,SQL);
  ExecSQL(fQuery);

  SQL:='CREATE INDEX aStrThCrc ON ImageTable(StrThCrc)';
  SetSQL(fQuery,SQL);
  ExecSQL(fQuery);
                       
 finally
  FreeDS(fQuery);
 end;
end;

procedure TryRemoveConnection(dbname : string; Delete : boolean = false);
var
  i, j, l : integer;
begin
 dbname:=AnsiLowerCase(dbname);
 l:=Length(ADOConnections);
 for i:=0 to l-1 do
 begin
  if ADOConnections[i].FileName=dbname then
  if (ADOConnections[i].RefCount=0) or Delete then
  begin
   ADOConnections[i].ADOConnection.Close;
   for j:=i to l-2 do
   ADOConnections[i]:=ADOConnections[i+1];
   exit;
  end;
 end;
end;

procedure RemoveADORef(ADOConnection : TADOConnection);
var
  i, j, l : integer;
begin
 l:=Length(ADOConnections);
 for i:=0 to l-1 do
 begin
  if ADOConnections[i].ADOConnection=ADOConnection then
  begin
   dec(ADOConnections[i].RefCount);
   //exit;
   if ADOConnections[i].RefCount=0 then
   begin
    //l:=ADOConnections[i].ADOConnection.DataSetCount;
    l:=Length(ADOConnections);
    ADOConnections[i].ADOConnection.Close;
    for j:=i to l-2 do
    ADOConnections[j]:=ADOConnections[j+1];
    SetLength(ADOConnections,Length(ADOConnections)-1);
   end;
   exit;
  end;
 end;
end;

function ADOInitialize(dbname : String) : TADOConnection;
var
  i, l : integer;
begin
 dbname:=AnsiLowerCase(dbname);
 l:=Length(ADOConnections);
 for i:=0 to l-1 do
 begin
  if ADOConnections[i].FileName=dbname then
  begin
   Result:=ADOConnections[i].ADOConnection;
   inc(ADOConnections[i].RefCount);
   exit;
  end;
 end;
 SetLength(ADOConnections,l+1);
 ADOConnections[l].ADOConnection:= TADOConnection.Create(nil);
 ADOConnections[l].ADOConnection.ConnectionString:=GetConnectionString(dbname);
 ADOConnections[l].ADOConnection.LoginPrompt:=false;
 ADOConnections[l].ADOConnection.Provider:=MDBProvider;
// ADOConnections[i].ADOConnection.KeepConnection:=false;
 Result:=ADOConnections[l].ADOConnection;
 ADOConnections[l].FileName:=AnsiLowerCase(dbname);
 ADOConnections[l].RefCount:=1;
end;

procedure FreeDS(var DS : TDataSet);
var
  Connection : TADOConnection;
begin
 if DS=nil then exit;
 if DS is TQuery then begin DS.Free; DS:=nil; exit; end;
 if DS is TTable then begin DS.Free; DS:=nil; exit; end;
 if DS is TADOQuery then begin Connection:=(DS as TADOQuery).Connection; DS.Free{OnRelease}; DS:=nil; RemoveADORef(Connection);{(DS as TADOQuery).Connection.Free;} exit; end;
 if DS is TADODataSet then begin Connection:=(DS as TADODataSet).Connection; DS.Free{OnRelease}; DS:=nil; RemoveADORef(Connection);{(DS as TADODataSet).Connection.Free;} exit; end;
end;

function GetDefDBName : string;
begin
 if GetDBType(dbname)=DB_TYPE_BDE then Result:='"'+DBName+'"';
 if GetDBType(dbname)=DB_TYPE_MDB then Result:='ImageTable';
end;

function OpenConnection(ConnectionString: AnsiString): Integer;  
var
  ADODBConnection: OleVariant;  
begin  
  ADODBConnection := CreateOleObject('ADODB.Connection');
  ADODBConnection.CursorLocation := 3; // User client
  ADODBConnection.ConnectionString := ConnectionString;
  Result          := 0;  
  try  
    ADODBConnection.Open;  
  except  
    Result := -1;  
  end;  
end;

function DataBaseConnection_Test(bMessage: Boolean): AnsiString;  
var  
  asTimeout, asUserName, asPassword, asDataSource, ConnectionString: AnsiString;  
  iReturn: Integer;  
begin  
  asTimeout     := '150';
  asUserName    := 'NT_Server';  
  asPassword    := 'SA';  
  asDataSource  := 'SQL Server - Photo DataBase';

  ConnectionString := 'Data Source = ' + asDataSource +
    'User ID = ' + asUserName +  
    'Password = ' + asPassword +
    'Mode = Read|Write;Connect Timeout = ' + asTimeout;
  try  
    iReturn := OpenConnection(ConnectionString);  

    if (bMessage) then  
    begin  
      if (iReturn = 0) then
        MessageBox(0,'Connection OK!', 'Information', MB_OK)
      else if (iReturn = -1) then  
        MessageBox(0,'Connection Error!', 'Error', MB_ICONERROR + MB_OK);
    end;

    if (iReturn = 0) then  
      Result := ConnectionString  
    else if (iReturn = -1) then  
      Result := '';  
  finally
  end;
end;

function dgPackDbaseTable(tLog: TTable): DBIResult;
var 
  TblDesc: CRTblDesc; 
  Dir: string;
  hDb: hDbiDb;
begin
 tLog.Active := False;
 SetLength(Dir, dbiMaxNameLen + 1);
 DbiGetDirectory(tLog.DBHandle, False, PChar(Dir));
 SetLength(Dir, StrLen(PChar(Dir)));
 DbiOpenDatabase(nil, nil, dbiReadWrite, dbiOpenExcl, nil, 0, nil, nil, hDb);
 DbiSetDirectory(hDb, PChar(Dir));
 FillChar(TblDesc, sizeof(CRTblDesc), 0);
 StrPCopy(TblDesc.szTblName, tLog.TableName);
 StrCopy(TblDesc.szTblType, szParadox);
 TblDesc.bPack := TRUE;
 Result:=DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, False);
 DbiCloseDatabase(hDb);
end;

procedure CompactDatabase_JRO(DatabaseName:string;DestDatabaseName:string='';Password:string='');
const
   Provider = 'Provider=Microsoft.Jet.OLEDB.4.0;'; 
var 
  TempName : array[0..MAX_PATH] of Char; // имя временного файла 
  TempPath : string; // путь до него 
  Name : string; 
  Src,Dest : WideString; 
  V : Variant; 
begin
   try 
       Src := Provider + 'Data Source=' + DatabaseName; 
       if DestDatabaseName<>'' then 
           Name:=DestDatabaseName 
       else begin 
           // выходная база не указана - используем временный файл 
           // получаем путь для временного файла 
           TempPath:=ExtractFilePath(DatabaseName); 
           if TempPath='' Then TempPath:=GetCurrentDir; 
           //получаем имя временного файла 
           GetTempFileName(PChar(TempPath),'mdb',0,TempName); 
           Name:=StrPas(TempName);
       end; 
       DeleteFile(PChar(Name));// этого файла не должно существовать :))
       Dest := Provider + 'Data Source=' + Name;
       if Password<>'' then begin
           Src := Src + ';Jet OLEDB:Database Password=' + Password;
           Dest := Dest + ';Jet OLEDB:Database Password=' + Password;
       end; 

       V:=CreateOleObject('jro.JetEngine');
       try 
           V.CompactDatabase(Src,Dest);// сжимаем 
       finally 
           V:=0; 
       end; 
       if DestDatabaseName='' then begin // т.к. выходная база не указана
           DeleteFile(PChar(DatabaseName)); //то удаляем не упакованную базу
           RenameFile(Name,DatabaseName); // и переименовываем упакованную базу 
       end; 
   except
    on e : Exception do EventLog(':CompactDatabase_JRO() throw exception: '+e.Message);
    // выдаем сообщение об исключительной ситуации 
   end;
end;

procedure PackTable(FileName : string);
var
  FTable : TTable;
begin
 FTable := TTable.Create(nil);
 FTable.TableName:=dbname;
 if (GetDBType(dbname)=DB_TYPE_BDE) and BDEIsInstalled then
 begin
  dgPackDbaseTable(FTable);
  FTable.TableName:=GroupsTableFileNameW(dbname);
  dgPackDbaseTable(FTable);
 end;

 if (GetDBType(dbname)=DB_TYPE_MDB) then
 begin
  CoInitialize(nil);
  CommonDBSupport.TryRemoveConnection(dbname,true);
  CompactDatabase_JRO(dbname,'','')
 end;
 FTable.Free;
end;

Procedure InitializeDBLoadScript;
var
  LoadInteger : integer;
begin
 EventLog(':InitializeDBLoadScript()');
 if DBLoadInitialized then exit;
 {$IFNDEF DEBUG}
 begin
  InitializeScript(aScript);
  LoadBaseFunctions(aScript);
  SetNamedValue(aScript,'$PortableWork','False');
  LoadScript:='';
  try
   aFS := TFileStream.Create(ProgramDir+'scripts\Load.dbini',fmOpenRead);
   SetLength(LoadScript,aFS.Size);
   aFS.Read(LoadScript[1],aFS.Size);
   for LoadInteger:=Length(LoadScript) downto 1 do
   begin
    if LoadScript[LoadInteger]=#10 then LoadScript[LoadInteger]:=' ';
    if LoadScript[LoadInteger]=#13 then LoadScript[LoadInteger]:=' ';
   end;
   LoadScript:=AddLanguage(LoadScript);
   LoadScript:=AddIcons(LoadScript);
   aFS.Free;
  except
   on e : Exception do EventLog(':InitializeDBLoadScript() at Loading Script exception : '+e.Message);
  end;
  try
   ExecuteScript(nil,aScript,LoadScript,LoadInteger,nil);
  except
   on e : Exception do EventLog(':InitializeDBLoadScript() at Executing Script exception : '+e.Message);
  end;
  PortableWork:=AnsiUpperCase(GetNamedValueString(aScript,'$PortableWork'))='TRUE';
 end;
 EventLog(':InitializeDBLoadScript() return true');
 DBLoadInitialized:=true;
 {$ENDIF}
end;

initialization

 SetLength(ADOConnections,0);
 {$IFNDEF DEBUG}

 if GetDBViewMode then
 begin
  if DBReadOnly then
  DBFConnectionString:=DBViewConnectionString;
 end;

 If AnsiUpperCase(paramStr(1))<>'/SAFEMODE' then
 if not GetDBViewMode then
 begin
  InitializeScript(aScript);
  LoadBaseFunctions(aScript);
  SetNamedValue(aScript,'$InitialString',DBFConnectionString);
  SetNamedValue(aScript,'$Provider',MDBProvider);
  LoadScript:='';
  try
   aFS := TFileStream.Create(ProgramDir+'scripts\Load.dbini',fmOpenRead);
   SetLength(LoadScript,aFS.Size);
   aFS.Read(LoadScript[1],aFS.Size);
   for LoadInteger:=Length(LoadScript) downto 1 do
   begin
    if LoadScript[LoadInteger]=#10 then LoadScript[LoadInteger]:=' ';
    if LoadScript[LoadInteger]=#13 then LoadScript[LoadInteger]:=' ';
   end;
   LoadScript:=AddLanguage(LoadScript);
   LoadScript:=AddIcons(LoadScript);
   aFS.Free;
  except
   on e : Exception do EventLog(':CommonDBSupport::initialization() throw exception : '+e.Message);
  end;
  try
   ExecuteScript(nil,aScript,LoadScript,LoadInteger,nil);
  except  
   on e : Exception do EventLog(':CommonDBSupport::initialization()/ExecuteScript throw exception : '+e.Message);
  end;
  DBFConnectionString:=GetNamedValueString(aScript,'$InitialString');
  MDBProvider:=GetNamedValueString(aScript,'$Provider');
 end;
 {$ENDIF}

end.
