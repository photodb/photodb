unit CommonDBSupport;

interface

uses
  Windows, ADODB, SysUtils, DB, ActiveX, Variants, Classes, ComObj,
  UnitINI, uConstants, ReplaseIconsInScript, uScript, UnitScripts,
  UnitDBDeclare, uLogger, uTime, SyncObjs, win32crc, UnitDBCommon, uMemory,
  uFileUtils, uRuntime;

const

 DB_TYPE_UNKNOWN = 0;
 DB_TYPE_MDB     = 1;

 DB_TABLE_UNKNOWN  = 0;
 DB_TABLE_GROUPS   = 1;
 DB_TABLE_IMAGES   = 2;
 DB_TABLE_SETTINGS = 3;

type
  TADODBConnection = class(TObject)
  public
    ADOConnection: TADOConnection;
    FileName: string;
    RefCount: Integer;
    ThreadID: THandle;
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
    function AddIntParam(Name : string; Value : Integer) : TDBIntegerParam;
    constructor Create;
    destructor Destroy; override;
    procedure ApplyToDS(DS : TDataSet);
    property Query : string read FQuery write FQuery;
  end;

var
  ADOConnections : TADOConnections = nil;
  DBLoadInitialized: Boolean = False;
  FSync : TCriticalSection = nil;
  aScript : TScript;
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

 var
   //TODO: delete it
   dbname : string = '';

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
procedure SetStrParam(Query : TDataSet; index : integer; Value : String);
procedure SetIntParam(Query : TDataSet; index : integer; Value : integer);
function QueryParamsCount(Query : TDataSet) : integer;

function GetQueryText(Query : TDataSet) : string;
procedure AssignParams(S,D : TDataSet);
//function GetDefDBName : string;
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
function NormalizeDBString(S: string): string;
function NormalizeDBStringLike(S: string): string;
function TryOpenCDS(DS: TDataSet): Boolean;
function GetDBViewMode: Boolean;

implementation

 uses UnitGroupsWork;

function TryOpenCDS(DS: TDataSet): Boolean;
var
  I: Integer;
begin
  for I := 1 to 20 do
  begin
    Result := True;
    try
      DS.Active := True;
    except
      Result := False;
    end;
    if Result then
      Break;
    Sleep(DelayExecuteSQLOperation);
  end;
end;

function NormalizeDBString(S: string): string;
begin
  Result := AnsiQuotedStr(S, '"')
end;

function NormalizeDBStringLike(S: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    if (S[I] = '[') or (S[I] = ']') or (S[I] = '\') then
      S[I] := '_';
  Result := S;
end;

function GetDefDBName: string;
begin
  if GetDBType(Dbname) = DB_TYPE_MDB then
    Result := 'ImageTable';
end;

function GetBlobStream(F: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := nil;
  if (F is TBlobField) and (F.DataSet is TADOQuery) then
    Result := TADOBlobStream.Create(TBlobField(F), Mode);
  if (F is TBlobField) and (F.DataSet is TADODataSet) then
    Result := TADOBlobStream.Create(TBlobField(F), Mode);
end;

procedure AssignParams(S, D: TDataSet);
begin
  if (S is TADOQuery) then
    (D as TADOQuery).Parameters.Assign((S as TADOQuery).Parameters);
end;

function GetQueryText(Query: TDataSet): string;
begin
  Result := '';
  if (Query is TADOQuery) then
    Result := (Query as TADOQuery).SQL.Text;
end;

function QueryParamsCount(Query: TDataSet): Integer;
begin
  Result := 0;
  if (Query is TADOQuery) then
    Result := (Query as TADOQuery).Parameters.Count;
end;

procedure LoadParamFromStream(Query: TDataSet; index: Integer; Stream: TStream; FT: TFieldType);
begin
  Stream.Seek(0, SoFromBeginning);
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters[index].LoadFromStream(Stream, FT);
end;

procedure AssignParam(Query : TDataSet; index : integer; Value : TPersistent);
begin
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters[index].Assign(Value);
end;

function GetBoolParam(Query: TDataSet; index: Integer): Boolean;
begin
  Result := False;
  if (Query is TADOQuery) then
    Result := (Query as TADOQuery).Parameters[index].Value;
end;

procedure SetBoolParam(Query: TDataSet; index: Integer; Bool: Boolean);
begin
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters[index].Value := Bool;
end;

procedure SetDateParam(Query : TDataSet; Name : string; Date : TDateTime);
begin
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters.FindParam(name).Value := Date;
end;

procedure SetIntParam(Query : TDataSet; Index : integer; Value : integer);
begin
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters[Index].Value := Value;
end;

procedure SetStrParam(Query : TDataSet; Index : integer; Value : String);
begin
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters[Index].Value := Value;
end;

function GetDBType: Integer;
begin
  Result := DB_TYPE_MDB;
end;

function GetDBType(DbName: string): Integer;
begin
  Result := DB_TYPE_MDB;
end;

function GetConnectionString: string;
begin
  Result := Format(DBFConnectionString, [Dbname]);
end;

function GetConnectionString(Dbname: string): string;
begin
  Result := Format(DBFConnectionString, [Dbname]);
end;

procedure ExecSQL(SQL: TDataSet);
begin
  if (SQL is TADOQuery) then
    (SQL as TADOQuery).ExecSQL;
end;

procedure SetSQL(SQL : TDataSet; SQLText : String);
var
  I: Integer;
begin
  for I := 1 to 20 do
  begin
    try
      if (SQL is TADOQuery) then
      begin
        SQLText := StringReplace(SQLText, '$DB$', GetDefDBName, [RfReplaceAll, RfIgnoreCase]);
        (SQL as TADOQuery).SQL.Text := SQLText;
        (SQL as TADOQuery).Parameters.ParseSQL((SQL as TADOQuery).SQL.Text, True);
      end;
      Break;
    except
      on E: Exception do
      begin
        EventLog(':SetSQL() throw exception: ' + E.message);
        Sleep(50);
      end;
    end;
  end;
end;

function ActiveSQL(SQL : TDataSet; Active : boolean) : boolean;
begin
  try
    if (SQL is TADOQuery) then
      (SQL as TADOQuery).Active := Active;
  except
    on E: Exception do
    begin
      EventLog(':ActiveSQL() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  Result := SQL <> nil;
end;

function ActiveTable(Table : TDataSet; Active : boolean) : boolean;
begin
  try
    if (Table is TADODataSet) then
      (Table as TADODataSet).Active := Active;
  except
    on E: Exception do
    begin
      EventLog(':ActiveTable() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  Result := Table <> nil;
end;

function GetQuery(IsolateThread: Boolean = False): TDataSet;
begin
  Result := GetQuery(Dbname, GetDBType, IsolateThread);
end;

function GetTableNameByFileName(FileName: string): string;
begin
  Result := '';
  if GetDBType(FileName) = DB_TYPE_MDB then
    Result := 'ImageTable';

end;

procedure AssingQuery(var QueryS, QueryD : TDataSet);
begin
  if (QueryS is TADOQuery) then
  begin
    SetSQL(QueryD, (QueryS as TADOQuery).SQL.Text);
    (QueryS as TADOQuery).Parameters.Assign((QueryD as TADOQuery).Parameters);
  end;
end;

function GetQuery(TableName: string; IsolateThread: Boolean = False): TDataSet;
begin
  Result := GetQuery(TableName, GetDBType(TableName), IsolateThread);
end;

function GetQuery(TableName : string; TableType : integer; IsolateThread : Boolean = False) : TDataSet;
begin
  FSync.Enter;
  try
    Result := nil;
    if TableType = DB_TYPE_UNKNOWN then
      TableType := GetDBType;
    if TableType = DB_TYPE_MDB then
    begin
      Result := TADOQuery.Create(nil);
      (Result as TADOQuery).Connection := ADOInitialize(TableName, IsolateThread);
    end;
  finally
    FSync.Leave;
  end;
end;

function GetTable : TDataSet;
begin
  Result:=GetTable(dbname,DB_TABLE_IMAGES);
end;

function GetTable(Table : String; TableID : integer = DB_TABLE_UNKNOWN) : TDataSet;
begin
  FSync.Enter;
  try
    Result := nil;
    if GetDBType(Table) = DB_TYPE_MDB then
    begin

      Result := TADODataSet.Create(nil);
      (Result as TADODataSet).Connection := ADOInitialize(Table);
      (Result as TADODataSet).CommandType := CmdTable;
      if TableID = DB_TABLE_GROUPS then
        (Result as TADODataSet).CommandText := 'Groups';
      if TableID = DB_TABLE_IMAGES then
        (Result as TADODataSet).CommandText := 'ImageTable';
      if TableID = DB_TABLE_SETTINGS then
        (Result as TADODataSet).CommandText := 'DBSettings';
    end;
  finally
    FSync.Leave;
  end;
end;

function GetRecordsCount(Table : string) : integer;
var
  FTable: TDataSet;
begin
  Result := 0;
  try
  if (GetDBType(Table) = DB_TYPE_MDB) then
  begin
    FTable := GetQuery(Table); // ONLY MDB
    try
      SetSQL(FTable, 'SELECT COUNT(*) AS RecordsCount FROM ImageTable');
      FTable.Open;
      Result := FTable.FieldByName('RecordsCount').AsInteger;
    finally
      FreeDS(FTable);
    end;
  end;
  except
    on e: Exception do
      TLogger.Instance.Message('GetRecordsCount throws an exception: ' + e.Message);
  end;
end;

function ADOCreateGroupsTable(TableName : string) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(TableName);
  try
    SQL := 'CREATE TABLE Groups ( ' + 'ID Autoincrement , ' + 'GroupCode Memo , ' + 'GroupName Memo , ' +
      'GroupComment Memo , ' + 'GroupDate Date , ' + 'Groupfaces Memo , ' + 'GroupAccess INTEGER , ' +
      'GroupImage LONGBINARY, ' + 'GroupKW Memo , ' + 'RelatedGroups Memo , ' + 'IncludeInQuickList Logical , ' +
      'GroupAddKW Logical)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateGroupsTable() throw exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function UpdateImageSettings(TableName : String; Settings : TImageDBOptions) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(TableName);
  try
    SQL := 'Update DBSettings Set Version=' + IntToStr(Settings.Version) + ', DBJpegCompressionQuality = ' + IntToStr
      (Settings.DBJpegCompressionQuality) + ', ThSizePanelPreview = ' + IntToStr(Settings.ThSizePanelPreview)
      + ',' + 'ThImageSize = ' + IntToStr(Settings.ThSize) + ', ThHintSize = ' + IntToStr(Settings.ThHintSize)
      + ', DBName = "' + Settings.name + '"' + ', DBDescription = "' + Settings.Description + '"';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':UpdateImageSettings() throw exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
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
function GetDefaultImageDBOptions: TImageDBOptions;
begin
  Result.DBJpegCompressionQuality := 75;
  Result.ThSize := 150;
  Result.ThSizePanelPreview := 75;
  Result.ThHintSize := 300;
end;

function GetImageSettingsFromTable(TableName : string) : TImageDBOptions;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := GetDefaultImageDBOptions;
  if TableName = '' then
     Exit;

  FQuery := GetQuery(TableName, True);
  try
    SQL := 'SELECT * FROM DBSettings';
    try
      SetSQL(FQuery, SQL);
      ActiveSQL(FQuery, True);
      if FQuery.Active then
      begin
        Result.DBJpegCompressionQuality := FQuery.FieldByName('DBJpegCompressionQuality').AsInteger;
        Result.ThSize := FQuery.FieldByName('ThImageSize').AsInteger;
        Result.ThSizePanelPreview := FQuery.FieldByName('ThSizePanelPreview').AsInteger;
        Result.ThHintSize := FQuery.FieldByName('ThHintSize').AsInteger;
        Result.name := FQuery.FieldByName('DBName').AsString;
        Result.Description := FQuery.FieldByName('DBDescription').AsString;
      end;
    except
      on E: Exception do
      begin
        EventLog(':GetImageSettingsFromTable() throw exception: ' + E.message);
        try
          ADOCreateSettingsTable(TableName);
          UpdateImageSettings(TableName, Result);
        except
          on E: Exception do
            EventLog(':GetImageSettingsFromTable()/Restore throw exception: ' + E.message);
        end;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function ADOCreateSettingsTable(TableName : string) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(TableName);
  try
    {
            DBJpegCompressionQuality = 75;
            ThSize = 152;
            ThSizeExplorerPreview = 100;
            ThSizePropertyPreview = 100;
            ThSizePanelPreview = 75;
            ThImageSize = 150;
            ThHintSize = 300;
    }
    SQL := 'DROP TABLE DBSettings';

    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
        EventLog(':ADOCreateSettingsTable() throw exception: ' + E.message);
    end;

    SQL := 'CREATE TABLE DBSettings ( ' + 'Version INTEGER , ' + 'DBName Character(255) , ' +
      'DBDescription Character(255) , ' + 'DBJpegCompressionQuality INTEGER , ' + 'ThSizePanelPreview INTEGER , ' +
      'ThImageSize INTEGER , ' + 'ThHintSize INTEGER)';

    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateSettingsTable() throw exception: ' + E.message);
        Result := False;
      end;
    end;

    { SQL:= 'Insert (Version, DBJpegCompressionQuality, ThSizePanelPreview,'+
      'ThImageSize, ThHintSize) Into DBSettings Values (:Version,'+
      ':DBJpegCompressionQuality,:ThSizePanelPreview,:ThImageSize,:ThHintSize)'; }

    SQL := 'Insert Into DBSettings  (Version, DBJpegCompressionQuality, ThSizePanelPreview,' +
      'ThImageSize, ThHintSize, DBName, DBDescription) Values (1,75,75,150,300,"","")';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateSettingsTable() throw exception: ' + E.message);
        Result := False;
      end;
    end;

    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateSettingsTable() throw exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function BDECreateGroupsTable(TableName : string) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  FQuery := GetQuery(TableName, DB_TABLE_GROUPS);
  try
    SQL := 'CREATE TABLE "' + GroupsTableFileNameW(TableName) + '" ( ' + 'ID AUTOINC , ' + 'GroupCode BLOB(240,1) , ' +
      'GroupName BLOB(240,1) , ' + 'GroupComment BLOB(240,1) , ' + 'GroupDate Date , ' + 'Groupfaces BLOB(240,1) , ' +
      'GroupAccess INTEGER , ' + 'GroupImage BLOB(1,2), ' + 'GroupKW BLOB(240,1) , ' + 'RelatedGroups BLOB(240,1) , ' +
      'IncludeInQuickList BOOLEAN , ' + 'GroupAddKW BOOLEAN)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':BDECreateGroupsTable() throw exception: ' + E.message);
        Result := False;
        Exit;
      end;
    end;
    Result := True;
  finally
    FreeDS(FQuery);
  end;
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
  for I := 0 to 2 do
    if CheckClass(Engines[i]) then
      begin
        DAO := CreateOleObject(Engines[i]);
        DAO.Workspaces[0].CreateDatabase(FileName, ';LANGID=0x0409;CP=1252;COUNTRY=0', 64);
        Exit;
      end;
  raise Exception.Create('DAO engine could not be initialized');
end;

function ADOCreateImageTable(TableName : string) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := False;
  try
    CreateMSAccessDatabase(TableName);
  except
    on E: Exception do
      EventLog(':ADOCreateImageTable() throw exception: ' + E.message);
  end;
  FQuery := GetQuery(TableName, GetDBType(TableName));
  try
    SQL := 'CREATE TABLE ImageTable (' + 'ID Autoincrement,' + 'Name Character(255),' + 'FFileName Memo,' +
      'Comment Memo,' + 'IsDate Logical,' + 'DateToAdd Date ,' + 'Owner  Character(255),' + 'Rating INTEGER ,' +
      'Thum  LONGBINARY,' + 'FileSize INTEGER ,' + 'KeyWords Memo,' + 'Groups Memo,' + 'StrTh  Memo,' +
    // Character fault when special characters
      'StrThCrc INTEGER , ' + 'Attr INTEGER,' + 'Collection  Character(255),' + 'Access INTEGER ,' + 'Width INTEGER ,' +
      'Height INTEGER ,' + 'Colors INTEGER ,' + 'Include Logical,' + 'Links Memo,' + 'aTime TIME,' + 'IsTime Logical,' +
      'FolderCRC INTEGER,' + 'Rotated INTEGER )';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateImageTable() throw exception: ' + E.message);
        FreeDS(FQuery);
        Exit;
      end;
    end;
    Result := True;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(TableName, GetDBType(TableName));
  try
    SQL := 'CREATE INDEX aID ON ImageTable(ID)';
    SetSQL(FQuery, SQL);
    ExecSQL(FQuery);
    // DROP INDEX <Index name>;
    SQL := 'CREATE INDEX aFolderCRC ON ImageTable(FolderCRC)';
    SetSQL(FQuery, SQL);
    ExecSQL(FQuery);

    SQL := 'CREATE INDEX aStrThCrc ON ImageTable(StrThCrc)';
    SetSQL(FQuery, SQL);
    ExecSQL(FQuery);

  finally
    FreeDS(FQuery);
  end;
end;

procedure TryRemoveConnection(dbname : string; Delete : boolean = false);
var
  I: Integer;
begin
  Dbname := AnsiLowerCase(Dbname);
  for I := 0 to ADOConnections.Count - 1 do
  begin
    if ADOConnections[I].FileName = Dbname then
      if (ADOConnections[I].RefCount = 0) or Delete then
      begin
        ADOConnections[I].ADOConnection.Close;
        ADOConnections[I].ADOConnection.Free;
        ADOConnections[I].Free;
        ADOConnections.RemoveAt(I);
        Exit;
      end;
  end;
end;

procedure RemoveADORef(ADOConnection : TADOConnection);
var
  I: Integer;
begin
  for I := 0 to ADOConnections.Count - 1 do
  begin
    if ADOConnections[I].ADOConnection = ADOConnection then
    begin
      Dec(ADOConnections[I].RefCount);
      if ADOConnections[I].RefCount = 0 then
      begin
        ADOConnections[I].ADOConnection.Free;
        ADOConnections[I].Free;
        ADOConnections.RemoveAt(I);
      end;
      Exit;
    end;
  end;
end;

function ADOInitialize(dbname : String; ForseNewConnection : Boolean = False) : TADOConnection;
var
  I : Integer;
  DBConnection : TADODBConnection;
begin
  dbname := AnsiLowerCase(dbname);
  if not ForseNewConnection then
    for I := 0 to ADOConnections.Count - 1 do
    begin
      if ADOConnections[I].FileName = dbname then
      begin
        Result := ADOConnections[I].ADOConnection;
        Inc(ADOConnections[I].RefCount);
        Exit;
      end;
    end;
  DBConnection := ADOConnections.Add;
  DBConnection.FileName := AnsiLowerCase(dbname);
  DBConnection.RefCount := 1;
  DBConnection.ADOConnection := TADOConnection.Create(nil);
  DBConnection.ADOConnection.ConnectionString := GetConnectionString(dbname);
  DBConnection.ADOConnection.LoginPrompt := False;
  DBConnection.ADOConnection.Provider := MDBProvider;
  Result := DBConnection.ADOConnection;
end;

procedure FreeDS(var DS : TDataSet);
var
  Connection: TADOConnection;
begin
  FSync.Enter;
  try
    if DS = nil then
      Exit;
    if DS is TADOQuery then
    begin
      Connection := (DS as TADOQuery).Connection;
      F(DS);
      RemoveADORef(Connection);
      Exit;
    end;
    if DS is TADODataSet then
    begin
      Connection := (DS as TADODataSet).Connection;
      F(DS);
      RemoveADORef(Connection);
      Exit;
    end;
  finally
    FSync.Leave;
  end;
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

{function DataBaseConnection_Test(bMessage: Boolean): AnsiString;
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
end; }

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
           GetTempFileName(PWideChar(TempPath),'mdb',0,TempName);
           Name:=StrPas(TempName);
       end;
       DeleteFile(Name);// этого файла не должно существовать :))
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
           DeleteFile(DatabaseName); //то удаляем не упакованную базу
           RenameFile(Name,DatabaseName); // и переименовываем упакованную базу
       end;
   except
    on e : Exception do EventLog(':CompactDatabase_JRO() throw exception: '+e.Message);
    // выдаем сообщение об исключительной ситуации
   end;
end;

procedure PackTable(FileName : string);
begin
  if (GetDBType(dbname) = DB_TYPE_MDB) then
  begin
    CommonDBSupport.TryRemoveConnection(dbname, True);
    CompactDatabase_JRO(dbname, '', '')
  end;
end;

Procedure InitializeDBLoadScript;
begin
 EventLog(':InitializeDBLoadScript()');
  if DBLoadInitialized then
    Exit;
{$IFNDEF DEBUG}
  begin
    TW.I.Start('InitializeDB -> aScript');
    AScript := TScript.Create('InitializeDBLoadScript');
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
  Result := TADODBConnection.Create;
  FConnections.Add(Result);
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
    TADODBConnection(FConnections[I]).ADOConnection.Free;
  FreeList(FConnections);
  F(FSync);
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

function TDBQueryParams.AddIntParam(Name: string;
  Value: Integer): TDBIntegerParam;
begin
  Result := TDBIntegerParam.Create;
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
      if DBParam is TDBIntegerParam then
        Paramert.Value := TDBIntegerParam(DBParam).Value;
    end;
  end;
end;

constructor TDBQueryParams.Create;
begin
  FParamList := TList.Create;
end;

destructor TDBQueryParams.Destroy;
begin
  FreeList(FParamList);
  inherited;
end;

function GetDBViewMode: Boolean;
var
  ProgramDir: string;
begin
  Result := False;
  ProgramDir := IncludeTrailingBackSlash(ExtractFileDir(ParamStr(0)));
  if not DBInDebug then
    if FileExists(ProgramDir + 'FolderDB.photodb') or FileExists
      (ProgramDir + AnsiLowerCase(GetFileNameWithoutExt(ParamStr(0))) + '.photodb') or FileExists
      (ProgramDir + AnsiLowerCase(GetFileNameWithoutExt(ParamStr(0))) + '.mdb') then
      Result := True;
end;

function DBReadOnly: Boolean;
var
  Attr: Integer;
  ProgramDir: string;
begin
  Result := False;
  ProgramDir := IncludeTrailingBackSlash(ExtractFileDir(ParamStr(0)));

  if FileExists(ProgramDir + 'FolderDB.photodb') then
  begin
    Attr := Windows.GetFileAttributes(PChar(ProgramDir + 'FolderDB.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      Result := True;
  end;

  if FileExists(ProgramDir + GetFileNameWithoutExt(ParamStr(0)) + '.photodb') then
  begin
    Attr := Windows.GetFileAttributes
      (PChar(ProgramDir + GetFileNameWithoutExt(ParamStr(0)) + '.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      Result := True;
  end;
end;

initialization

  FSync := TCriticalSection.Create;
  ADOConnections := TADOConnections.Create;

  if GetDBViewMode then
  begin
    if DBReadOnly then
      DBFConnectionString:=DBViewConnectionString;
  end;

finalization

  F(ADOConnections);
  F(FSync);

end.
