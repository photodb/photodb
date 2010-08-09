unit CommonDBSupport;

interface

//{$DEFINE DEBUG}

uses
{$IFNDEF DEBUG}
Dolphin_DB, ReplaseLanguageInScript, ReplaseIconsInScript, uScript, UnitScripts,
UnitDBDeclare, uLogger, uTime, SyncObjs, win32crc, UnitDBCommon,
{$ENDIF}
 Windows, ADODB, SysUtils, DB, ActiveX, Variants, Classes, ComObj,
 UnitINI;

const

 DB_TYPE_UNKNOWN = 0;
 DB_TYPE_MDB     = 1;

 DB_TABLE_UNKNOWN  = 0;
 DB_TABLE_GROUPS   = 1;
 DB_TABLE_IMAGES   = 2;
 DB_TABLE_LOGIN    = 3;
 DB_TABLE_SETTINGS = 4;

 type
  TADODBConnection = class(TObject)
  public
    ADOConnection : TADOConnection;
    FileName : string;
    RefCount : Integer;
    ThreadID : THandle;
  end;

  TADOConnections = class(TObject)
  private
    FConnections : TList;
    FSync : TCriticalSection;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TADODBConnection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RemoveAt(Index : Integer);
    function Add : TADODBConnection;
    property Count : Integer read GetCount;
    property Items[Index: Integer]: TADODBConnection read GetValueByIndex; default;
  end;

  TDBParam = class(TObject)
  private
    FName : string;
  public
    property Name : string read FName write FName;
  end;

  TDBStringParam = class(TDBParam)
    Value : string;
  end;

  TDBIntegerParam = class(TDBParam)
    Value : Integer;
  end;

  TDBDateTimeParam = class(TDBParam)
    Value : TDateTime;
  end;

  TDBQueryParams = class(TObject)
  private
    FParamList : TList;
    FQuery : string;
  public
    function AddDateTimeParam(Name : string; Value : TDateTime) : TDBDateTimeParam;
    constructor Create; 
    destructor Destroy; override;
    procedure ApplyToDS(DS : TDataSet);
    property Query : string read FQuery write FQuery;
  end;

var
  ADOConnections : TADOConnections = nil;
  
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
{$ENDIF}

function GetDBType : integer; overload;
function GetDBType(dbname : string) : integer; overload;

procedure FreeDS(var DS : TDataSet);
function ADOInitialize(dbname : String; ForseNewConnection : Boolean = False) : TADOConnection;

function GetTable : TDataSet; overload;
function GetTable(Table : String; TableID : integer = DB_TABLE_UNKNOWN) : TDataSet; overload;

function ActiveTable(Table : TDataSet; Active : boolean) : boolean;

function GetConnectionString(dbname : String) : String; overload;
function GetConnectionString : String; overload;

function GetQuery(IsolateThread : Boolean = False) : TDataSet; overload;
function GetQuery(TableName : string; IsolateThread : Boolean = False) : TDataSet; overload;
function GetQuery(TableName : string; TableType : integer; IsolateThread : Boolean = False) : TDataSet; overload;

procedure SetSQL(SQL : TDataSet; SQLText : String);
procedure ExecSQL(SQL : TDataSet);

function GetBoolParam(Query : TDataSet; index : integer) : boolean;

procedure LoadParamFromStream(Query : TDataSet; index : integer; Stream : TStream; FT : TFieldType);
procedure SetDateParam(Query : TDataSet; Name : string; Date : TDateTime);
procedure SetBoolParam(Query : TDataSet; index : integer; Bool : Boolean);
procedure SetStrParam(Query : TDataSet; index : integer; Str : String);
procedure SetIntParam(Query : TDataSet; index : integer; int : integer);
function QueryParamsCount(Query : TDataSet) : integer;

function GetQueryText(Query : TDataSet) : string;
procedure AssignParams(S,D : TDataSet);
function GetDefDBName : string;
function GetBlobStream(F : TField; Mode : TBlobStreamMode) : TStream;
procedure AssignParam(Query : TDataSet; index : integer; Value : TPersistent);

function ADOCreateImageTable(TableName : string) : boolean;

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
function GetPathCRC(FileFullPath : string) : Integer;

implementation

//{$IFNDEF DEBUG}
 uses UnitGroupsWork;
//{$ENDIF}

function GetBlobStream(F : TField; Mode : TBlobStreamMode) : TStream;
begin
 Result:=nil;
 if (F is TBlobField) and (F.DataSet is TADOQuery) then Result:=TADOBlobStream.Create(TBlobField(F),Mode);
 if (F is TBlobField) and (F.DataSet is TADODataSet) then Result:=TADOBlobStream.Create(TBlobField(F),Mode);
end;

procedure AssignParams(S, D : TDataSet);
begin
 if (S is TADOQuery) then (D as TADOQuery).Parameters.Assign((S as TADOQuery).Parameters);
end;

function GetQueryText(Query : TDataSet) : string;
begin
 Result:='';
 if (Query is TADOQuery) then Result:=(Query as TADOQuery).SQL.Text;
end;

function QueryParamsCount(Query : TDataSet) : integer;
begin
 Result:=0;
 if (Query is TADOQuery) then Result:=(Query as TADOQuery).Parameters.Count;
end;

procedure LoadParamFromStream(Query : TDataSet; index : integer; Stream : TStream; FT : TFieldType);
begin
 Stream.Seek(0,soFromBeginning);
 if (Query is TADOQuery) then
   (Query as TADOQuery).Parameters[index].LoadFromStream(Stream,FT);
end;

procedure AssignParam(Query : TDataSet; index : integer; Value : TPersistent);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Assign(Value);
end;

function GetBoolParam(Query : TDataSet; index : integer) : boolean;
begin
 Result:=false;
 if (Query is TADOQuery) then Result:=(Query as TADOQuery).Parameters[index].Value;
end;

procedure SetBoolParam(Query : TDataSet; index : integer; Bool : Boolean);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Value:=Bool;
end;

procedure SetDateParam(Query : TDataSet; Name : string; Date : TDateTime);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters.FindParam(Name).Value:=Date;
end;

procedure SetIntParam(Query : TDataSet; index : integer; int : integer);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Value:=int;
end;

procedure SetStrParam(Query : TDataSet; index : integer; Str : String);
begin
 if (Query is TADOQuery) then (Query as TADOQuery).Parameters[index].Value:=Str;
end;

function GetDBType : integer;
begin
 Result:=DB_TYPE_UNKNOWN;
 if AnsiLowerCase(ExtractFileExt(dbname))='.mdb' then Result:=DB_TYPE_MDB;
 if AnsiLowerCase(ExtractFileExt(dbname))='.photodb' then Result:=DB_TYPE_MDB;
end;

function GetDBType(dbname : string) : integer;
begin
 Result:=DB_TYPE_UNKNOWN;
 if AnsiLowerCase(ExtractFileExt(dbname))='.mdb' then Result:=DB_TYPE_MDB;  
 if AnsiLowerCase(ExtractFileExt(dbname))='.photodb' then Result:=DB_TYPE_MDB;
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
   Break;
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

function GetQuery(IsolateThread : Boolean = False) : TDataSet;
begin
 Result:=GetQuery(dbname, GetDBType, IsolateThread);
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
end;

function GetQuery(TableName : string; IsolateThread : Boolean = False) : TDataSet;
begin
 Result:=GetQuery(TableName, GetDBType(TableName), IsolateThread);
end;

function GetQuery(TableName : string; TableType : integer; IsolateThread : Boolean = False) : TDataSet;
begin
 Result:=nil;
 if TableType=DB_TYPE_UNKNOWN then TableType:=GetDBType;
 if TableType=DB_TYPE_MDB then
 begin
  Result:=TADOQuery.Create(nil);
  (Result as TADOQuery).Connection:=ADOInitialize(TableName, IsolateThread);
 end;
end;

function GetTable : TDataSet;
begin
 Result:=GetTable(dbname,DB_TABLE_IMAGES);
end;

function GetTable(Table : String; TableID : integer = DB_TABLE_UNKNOWN) : TDataSet;
begin
 Result:=nil;
 if GetDBType(Table)=DB_TYPE_MDB then
 begin

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
 if (GetDBType(Table)=DB_TYPE_MDB) then
 begin
  FTable:=GetQuery(Table);            //ONLY MDB
  SetSQL(FTable,'Select count(*) as RecordsCount from ImageTable');
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
 fQuery:=GetQuery(TableName, True);
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
  I : integer;
begin
  dbname := AnsiLowerCase(dbname);
  for I:=0 to ADOConnections.Count - 1 do
  begin
    if ADOConnections[I].FileName=dbname then
    if (ADOConnections[I].RefCount = 0) or Delete then
    begin
      ADOConnections[I].ADOConnection.Close;
      ADOConnections.RemoveAt(I);
      exit;
    end;
  end;
end;

procedure RemoveADORef(ADOConnection : TADOConnection);
var
  I  : integer;
begin
  for I := 0 to ADOConnections.Count - 1 do
  begin
    if ADOConnections[I].ADOConnection = ADOConnection then
    begin
      Dec(ADOConnections[I].RefCount);
      if ADOConnections[I].RefCount = 0 then
      begin
        ADOConnections[I].ADOConnection.Close;
        ADOConnections.RemoveAt(I);
      end;
      Exit;
    end;
  end;
end;

function ADOInitialize(dbname : String; ForseNewConnection : Boolean = False) : TADOConnection;
var
  I : integer;
  DBConnection : TADODBConnection;
begin
  dbname := AnsiLowerCase(dbname);
  if not ForseNewConnection then
    for I := 0 to ADOConnections.Count - 1 do
    begin
      if ADOConnections[I].FileName = dbname then
      begin
        Result:=ADOConnections[I].ADOConnection;
        Inc(ADOConnections[I].RefCount);
        exit;
      end;
    end;
  DBConnection := ADOConnections.Add;
  DBConnection.FileName := AnsiLowerCase(dbname);
  DBConnection.RefCount := 1;
  DBConnection.ADOConnection := TADOConnection.Create(nil);
  DBConnection.ADOConnection.ConnectionString := GetConnectionString(dbname);
  DBConnection.ADOConnection.LoginPrompt := False;
  DBConnection.ADOConnection.Provider := MDBProvider;
 // DBConnection.ADOConnection.KeepConnection:=false;
  Result := DBConnection.ADOConnection;
end;

procedure FreeDS(var DS : TDataSet);
var
  Connection : TADOConnection;
begin
 if DS=nil then exit;
 if DS is TADOQuery then begin Connection:=(DS as TADOQuery).Connection; DS.Free{OnRelease}; DS:=nil; RemoveADORef(Connection);{(DS as TADOQuery).Connection.Free;} exit; end;
 if DS is TADODataSet then begin Connection:=(DS as TADODataSet).Connection; DS.Free{OnRelease}; DS:=nil; RemoveADORef(Connection);{(DS as TADODataSet).Connection.Free;} exit; end;
end;

//TODO: remove function, replace on %DB% in queries
function GetDefDBName : string;
begin
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
begin
 if (GetDBType(dbname)=DB_TYPE_MDB) then
 begin
  CommonDBSupport.TryRemoveConnection(dbname,true);
  CompactDatabase_JRO(dbname,'','')
 end;
end;

Procedure InitializeDBLoadScript;
var
  LoadInteger : integer;
begin
 EventLog(':InitializeDBLoadScript()');
 if DBLoadInitialized then exit;
 {$IFNDEF DEBUG}
 begin
  TW.I.Start('InitializeDB -> aScript');
    aScript := TScript.Create('InitializeDBLoadScript');
    try
    AddScriptFunction(aScript.PrivateEnviroment,'ReadFile', F_TYPE_FUNCTION_STRING_IS_STRING, @UnitScripts.ReadFile);

  SetNamedValue(aScript,'$PortableWork','False'); 
  SetNamedValue(aScript,'$InitialString',DBFConnectionString);
  SetNamedValue(aScript,'$Provider',MDBProvider);
  LoadScript:='';
  TW.I.Start('InitializeDB -> Load.dbini');
  try
   aFS := TFileStream.Create(ProgramDir+'scripts\Load.dbini',fmOpenRead);
   SetLength(LoadScript,aFS.Size);
   aFS.Read(LoadScript[1],aFS.Size);
   for LoadInteger:=Length(LoadScript) downto 1 do
   begin
    if LoadScript[LoadInteger]=#10 then LoadScript[LoadInteger]:=' ';
    if LoadScript[LoadInteger]=#13 then LoadScript[LoadInteger]:=' ';
   end;
   aFS.Free;
  except
   on e : Exception do EventLog(':InitializeDBLoadScript() at Loading Script exception : '+e.Message);
  end;
  TW.I.Start('InitializeDB -> ExecuteScript');
  try
   ExecuteScript(nil, aScript, LoadScript, LoadInteger, nil);
  except
   on e : Exception do EventLog(':InitializeDBLoadScript() at Executing Script exception : '+e.Message);
  end;        
  TW.I.Start('InitializeDB -> Read vars');
  PortableWork:=AnsiUpperCase(GetNamedValueString(aScript,'$PortableWork'))='TRUE';
  DBFConnectionString:=GetNamedValueString(aScript,'$InitialString');
  MDBProvider:=GetNamedValueString(aScript,'$Provider');
  finally
    aScript.Free;
  end;
 end;   
  TW.I.Start('InitializeDBLoadScript - end');
 EventLog(':InitializeDBLoadScript() return true');
 DBLoadInitialized:=true;
 {$ENDIF}
end;

{ TADOConnections }

function TADOConnections.Add: TADODBConnection;
begin
  Result := FConnections[FConnections.Add(TADODBConnection.Create)];
end;

constructor TADOConnections.Create;
begin
  FSync := TCriticalSection.Create;
  FConnections := TList.Create;
end;

destructor TADOConnections.Destroy;
var
  I : Integer;
begin
  for I := 0 to FConnections.Count - 1 do
    TADODBConnection(FConnections[I]).Free;
  FConnections.Free;
  FSync.Free;
  inherited;
end;

function TADOConnections.GetCount: Integer;
begin
  Result := FConnections.Count;
end;

function TADOConnections.GetValueByIndex(Index: Integer): TADODBConnection;
begin
  Result := FConnections[Index];
end;

procedure TADOConnections.RemoveAt(Index: Integer);
begin
  if (Index > -1) and (Index < FConnections.Count) then
    FConnections.Delete(Index);
end;

function GetPathCRC(FileFullPath : string) : Integer;
var
  Folder : string;
  CRC : Cardinal;
begin
  Folder:=SysUtils.ExtractFileDir(AnsiLowerCase(FileFullPath));
  CalcStringCRC32(AnsiLowerCase(Folder), CRC);
  Result := Integer(CRC);
end;

{ TDBQueryParams }

function TDBQueryParams.AddDateTimeParam(Name: string; Value: TDateTime) : TDBDateTimeParam;
begin
  Result := TDBDateTimeParam.Create;
  Result.Name := Name;
  Result.Value := Value;
  FParamList.Add(Result);
end;

procedure TDBQueryParams.ApplyToDS(DS: TDataSet);
var
  I : Integer;
  Paramert : TParameter;
  DBParam : TDBParam;
begin
  SetSQL(DS, Query);
  for I := 0 to FParamList.Count - 1 do
  begin
    DBParam := FParamList[I];
    Paramert := nil;
    if DS is TADOQuery then
      Paramert := TADOQuery(DS).Parameters.FindParam(DBParam.Name);
    if Paramert <> nil then
    begin
      if DBParam is TDBDateTimeParam then
        Paramert.Value := TDBDateTimeParam(DBParam).Value;
    end;
  end;
end;

constructor TDBQueryParams.Create;
begin
  FParamList := TList.Create;
end;

destructor TDBQueryParams.Destroy;
var
  I : Integer;
begin
  for I := 0 to FParamList.Count - 1 do
    TObject(FParamList[I]).Free;

  FParamList.Free;
  inherited;
end;

initialization

 ADOConnections := TADOConnections.Create;

 {$IFNDEF DEBUG}

 if GetDBViewMode then
 begin
  if DBReadOnly then
  DBFConnectionString:=DBViewConnectionString;
 end;

 {$ENDIF}

finalization

 ADOConnections.Free;

end.
