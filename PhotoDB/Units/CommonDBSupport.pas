unit CommonDBSupport;

interface

uses
  Windows,
  ADODB,
  SysUtils,
  DB,
  ActiveX,
  Classes,
  ComObj,
  UnitINI,
  SyncObjs,
  win32crc,
  uConstants,
  uRuntime,
  uMemory,
  uLogger,
  uTime,
  uFileUtils,
  uSysUtils,
  uShellIntegration,
  uTranslate,

  ReplaseIconsInScript,
  uScript,

  UnitDBCommon;

const
  DB_TYPE_UNKNOWN = 0;
  DB_TYPE_MDB     = 1;

  DB_TABLE_UNKNOWN         = 0;
  DB_TABLE_GROUPS          = 1;
  DB_TABLE_IMAGES          = 2;
  DB_TABLE_PERSONS         = 3;
  DB_TABLE_PERSON_MAPPING  = 4;
  DB_TABLE_SETTINGS        = 5;

type
  TImageDBOptions = class
  public
    Version: Integer;
    DBJpegCompressionQuality: Byte;
    ThSize: Integer;
    ThSizePanelPreview: Integer;
    ThHintSize: Integer;
    Description: string;
    Name: string;
    constructor Create;
    function Copy: TImageDBOptions;
  end;

type
  TADODBConnection = class(TObject)
  public
    ADOConnection: TADOConnection;
    FileName: string;
    RefCount: Integer;
    ThreadID: THandle;
    Isolated: Boolean;
  end;

  TADOConnections = class(TObject)
  private
    FConnections: TList;
    FSync: TCriticalSection;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TADODBConnection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RemoveAt(Index: Integer);
    function Add: TADODBConnection;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TADODBConnection read GetValueByIndex; default;
  end;

  TDBParam = class(TObject)
  private
    FName: string;
  public
    property Name: string read FName write FName;
  end;

  TDBStringParam = class(TDBParam)
    Value: string;
  end;

  TDBIntegerParam = class(TDBParam)
    Value: Integer;
  end;

  TDBDateTimeParam = class(TDBParam)
    Value: TDateTime;
  end;

type
  TQueryType = (
    QT_TEXT
    //QT_W_SCAN_FILE //unsupported :(
  );

  TDBQueryParams = class(TObject)
  private
    FParamList: TList;
    FQuery: string;
    FQueryType: TQueryType;
    FCanBeEstimated: Boolean;
    FData: TObject;
    procedure SetData(const Value: TObject);
  public
    function AddDateTimeParam(Name: string; Value: TDateTime) : TDBDateTimeParam;
    function AddIntParam(Name: string; Value: Integer) : TDBIntegerParam;
    function AddStringParam(Name: string; Value: string) : TDBStringParam;
    constructor Create;
    destructor Destroy; override;
    procedure ApplyToDS(DS: TDataSet);
    property Query: string read FQuery write FQuery;
    property QueryType: TQueryType read FQueryType write FQueryType;
    property CanBeEstimated: Boolean read FCanBeEstimated write FCanBeEstimated;
    property Data: TObject read FData write SetData;
  end;

var
  ADOConnections: TADOConnections = nil;
  DBLoadInitialized: Boolean = False;
  FSync: TCriticalSection = nil;

const
  {$ifdef cpux64}
  MDBProvider = 'Microsoft.ACE.OLEDB.12.0';
  {$endif}
  {$ifndef cpux64}
  MDBProvider = 'Microsoft.Jet.OLEDB.4.0';
  {$endif}

var
  DBFConnectionString: string = 'Provider=' + MDBProvider + ';Password="";User ID=Admin;'+
                            'Data Source=%s;Mode=%MODE%;Extended Properties="";'+
                            'Jet OLEDB:System database="";Jet OLEDB:Registry Path="";'+
                            'Jet OLEDB:Database Password="";Jet OLEDB:Engine Type=5;'+
                            'Jet OLEDB:Database Locking Mode=1;'+
                            'Jet OLEDB:Global Partial Bulk Ops=2;'+
                            'Jet OLEDB:Global Bulk Transactions=2;'+
                            'Jet OLEDB:New Database Password="";'+
                            'Jet OLEDB:Create System Database=False;'+
                            'Jet OLEDB:Encrypt Database=False;'+
                            'Jet OLEDB:Don''t Copy Locale on Compact=False;'+
                            'Jet OLEDB:Compact Without Replica Repair=False;'+
                            'Jet OLEDB:SFP=False';

  // Read Only String
  DBViewConnectionString: string =
    'Provider=' + MDBProvider + ';Password="";'+
    'User ID=Admin;Data Source=%s;'+
    'Mode=Share Deny Write;Extended Properties="";'+
    'Jet OLEDB:System database="";Jet OLEDB:Registry Path="";'+
    'Jet OLEDB:Database Password="";Jet OLEDB:Engine Type=0;'+
    'Jet OLEDB:Database Locking Mode=1;Jet OLEDB:Global Partial Bulk Ops=1;'+
    'Jet OLEDB:Global Bulk Transactions=1;Jet OLEDB:New Database Password="";'+
    'Jet OLEDB:Create System Database=False;Jet OLEDB:Encrypt Database=False;'+
    'Jet OLEDB:Don''t Copy Locale on Compact=False;Jet OLEDB:'+
    'Compact Without Replica Repair=False;Jet OLEDB:SFP=False';

function GetDBType: Integer; overload;
function GetDBType(Dbname: string): Integer; overload;

procedure FreeDS(var DS: TDataSet);
function ADOInitialize(Dbname: string; ForseNewConnection: Boolean = False): TADOConnection;

function GetTable: TDataSet; overload;
function GetTable(Table: string; TableID: Integer = DB_TABLE_UNKNOWN): TDataSet; overload;

function ActiveTable(Table: TDataSet; Active: Boolean): Boolean;

function GetConnectionString(Dbname: string; ReadOnly: Boolean): string; overload;
function GetConnectionString: string; overload;

function GetQuery(IsolateThread: Boolean = False): TDataSet; overload;
function GetQuery(TableName: string; IsolateThread: Boolean = False): TDataSet; overload;
function GetQuery(TableName: string; TableType: Integer; IsolateThread: Boolean = False): TDataSet; overload;

procedure SetSQL(SQL: TDataSet; SQLText: String);
procedure ExecSQL(SQL: TDataSet);

function GetBoolParam(Query: TDataSet; Index: integer) : boolean;

procedure LoadParamFromStream(Query: TDataSet; index: Integer; Stream: TStream; FT: TFieldType);
procedure SetDateParam(Query: TDataSet; name: string; Date: TDateTime);
procedure SetBoolParam(Query: TDataSet; Index: Integer; Bool: Boolean);
procedure SetStrParam(Query: TDataSet; Index: Integer; Value: string);
procedure SetIntParam(Query: TDataSet; Index: Integer; Value: Integer);
function QueryParamsCount(Query: TDataSet): Integer;

function GetQueryText(Query : TDataSet) : string;
procedure AssignParams(S,D : TDataSet);
function GetBlobStream(F : TField; Mode : TBlobStreamMode) : TStream;
procedure AssignParam(Query : TDataSet; index : integer; Value : TPersistent);

function ADOCreateImageTable(TableName : string) : boolean;

function ADOCreateGroupsTable(TableName: string): Boolean;

// ADO Only
function ADOCreateSettingsTable(TableName: string): Boolean;

procedure CreateMSAccessDatabase(FileName: string);
procedure TryRemoveConnection(Dbname: string; Delete: Boolean = False);
procedure RemoveADORef(ADOConnection: TADOConnection);

function GetTableNameByFileName(FileName: string): string;
procedure AssingQuery(var QueryS, QueryD: TDataSet);

function GetRecordsCount(Table: string): Integer;
function UpdateImageSettings(TableName: string; Settings: TImageDBOptions): Boolean;
function GetImageSettingsFromTable(TableName: string): TImageDBOptions;
procedure PackTable(FileName: string);
function GetDefaultImageDBOptions: TImageDBOptions;
function GetPathCRC(FileFullPath: string; IsFile: Boolean): Integer;
function NormalizeDBString(S: string): string;
function NormalizeDBStringLike(S: string): string;
function TryOpenCDS(DS: TDataSet): Boolean;
procedure ForwardOnlyQuery(DS: TDataSet);
procedure ReadOnlyQuery(DS: TDataSet);
function DBReadOnly: Boolean;
function GroupsTableFileNameW(FileName: string): string;

implementation

function GroupsTableFileNameW(FileName: string): string;
begin
  if GetDBType(FileName) = DB_TYPE_MDB then
    Result := FileName;
end;

procedure ForwardOnlyQuery(DS: TDataSet);
begin
  TADOQuery(DS).CursorType := ctOpenForwardOnly;
  TADOQuery(DS).CursorLocation := clUseServer;
  ReadOnlyQuery(DS);
end;

procedure ReadOnlyQuery(DS: TDataSet);
begin
  TADOQuery(DS).LockType := ltReadOnly;
end;

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

procedure SetDateParam(Query: TDataSet; Name: string; Date: TDateTime);
begin
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters.FindParam(name).Value := Date;
end;

procedure SetIntParam(Query: TDataSet; Index: Integer; Value: integer);
begin
  if (Query is TADOQuery) then
    (Query as TADOQuery).Parameters[Index].Value := Value;
end;

procedure SetStrParam(Query: TDataSet; Index: Integer; Value : string);
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

function GetConnectionString(Dbname: string; ReadOnly: Boolean): string;
begin
  Result := StringReplace(DBFConnectionString, '%MODE%', IIF(ReadOnly, 'Read', 'Share Deny None'), [rfReplaceAll, rfIgnoreCase]);
  Result := Format(Result, [Dbname]);
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

function ActiveSQL(SQL : TDataSet; Active: Boolean): Boolean;
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

function ActiveTable(Table : TDataSet; Active: Boolean): Boolean;
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

procedure AssingQuery(var QueryS, QueryD: TDataSet);
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

function GetQuery(TableName: string; TableType: Integer; IsolateThread: Boolean = False) : TDataSet;
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
      if DBReadOnly then
        ReadOnlyQuery(Result);
    end;
  finally
    FSync.Leave;
  end;
end;

function GetTable : TDataSet;
begin
  Result:=GetTable(dbname,DB_TABLE_IMAGES);
end;

function GetTable(Table: String; TableID: Integer = DB_TABLE_UNKNOWN) : TDataSet;
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
      if TableID = DB_TABLE_PERSONS then
        (Result as TADODataSet).CommandText := 'Persons';
      if TableID = DB_TABLE_PERSON_MAPPING then
        (Result as TADODataSet).CommandText := 'PersonMapping';
    end;
  finally
    FSync.Leave;
  end;
end;

function GetRecordsCount(Table: string) : integer;
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
  FQuery := GetQuery(TableName, True);
  try
    SQL := 'Update DBSettings Set DBJpegCompressionQuality = ' + IntToStr
      (Settings.DBJpegCompressionQuality) + ', ThSizePanelPreview = ' + IntToStr(Settings.ThSizePanelPreview)
      + ',' + 'ThImageSize = ' + IntToStr(Settings.ThSize) + ', ThHintSize = ' + IntToStr(Settings.ThHintSize)
      + ', DBName = ' + NormalizeDBString(Settings.name)  + ', DBDescription = ' + NormalizeDBString(Settings.Description);
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
  Result := TImageDBOptions.Create;
  Result.DBJpegCompressionQuality := 75;
  Result.ThSize := 200;
  Result.ThSizePanelPreview := 100;
  Result.ThHintSize := 400;
end;

function GetImageSettingsFromTable(TableName: string): TImageDBOptions;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := GetDefaultImageDBOptions;
  if TableName = '' then
     Exit;

  FQuery := GetQuery(TableName, True);
  try
    ReadOnlyQuery(FQuery);
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
        Result.Name := FQuery.FieldByName('DBName').AsString;
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

function ADOCreateSettingsTable(TableName: string): Boolean;
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
      'ThImageSize, ThHintSize, DBName, DBDescription) Values (2,75,100,200,400,"","")';
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
  finally
    FreeDS(FQuery);
  end;
end;

function BDECreateGroupsTable(TableName: string): Boolean;
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
  DAO,
  WS: Variant;
  I,
  Code: Integer;
  ErrorString: string;
  const Engines: array[0..3] of string = ('DAO.DBEngine.120', 'DAO.DBEngine.36', 'DAO.DBEngine.35', 'DAO.DBEngine');

  function CheckClass(OLEClassName: string): Boolean;
  var
    HR: HResult;
    G: TGUID;
    I: IInterface;
  begin
    HR := CLSIDFromProgID(PWideChar(WideString(OLEClassName)), G);

    if Failed(HR) then
      Exit(False);

    HR := CoCreateInstance(G, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IDispatch, I);
    Result := HR = S_OK;
  end;

begin
  Code := 0;
  for I := Low(Engines) to High(Engines) do
    if CheckClass(Engines[I]) then
      begin
        try
          DAO := CreateOleObject(Engines[I]);
          Code := 1;
          WS := DAO.Workspaces[0];
          Code := 2;
          WS.CreateDatabase(FileName, ';LANGID=0x0409;CP=1252;COUNTRY=0', 64);
          Exit;
        except
          on E: Exception do
          begin
            ErrorString := 'Error creating database! Engine: ' + Engines[I] + ', ERROR: ' + E.message + ', file: ' + FileName + ', code = ' + IntToStr(Code);
            EventLog(ErrorString);
            TThread.Synchronize(nil,
              procedure
              begin
                MessageBoxDB(0, ErrorString, TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
              end
            );
          end;
        end;
      end;
  raise Exception.Create('DAO engine could not be initialized');
end;

function ADOCreateImageTable(TableName: string) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := False;
  try
    CreateMSAccessDatabase(TableName);
  except
    on E: Exception do
    begin
      EventLog(':ADOCreateImageTable() throw exception: ' + E.message);
      raise;
    end;
  end;
  FQuery := GetQuery(TableName, GetDBType(TableName));
  try
    SQL := 'CREATE TABLE ImageTable (' + 'ID Autoincrement,' + 'Name Character(255),' + 'FFileName Memo,' +
      'Comment Memo,' + 'IsDate Logical,' + 'DateToAdd Date ,' + 'Owner  Character(255),' + 'Rating INTEGER ,' +
      'Thum  LONGBINARY,' + 'FileSize INTEGER ,' + 'KeyWords Memo,' + 'Groups Memo,' + 'StrTh Character(100),' +
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
  for I := ADOConnections.Count - 1 downto 0 do
  begin
    if ADOConnections[I].FileName = Dbname then
      if (ADOConnections[I].RefCount = 0) and Delete then
      begin
        ADOConnections[I].ADOConnection.Close;
        ADOConnections[I].ADOConnection.Free;
        ADOConnections[I].Free;
        ADOConnections.RemoveAt(I);
        Exit;
      end;
  end;
end;

procedure RemoveADORef(ADOConnection: TADOConnection);
var
  I, J, Count: Integer;
begin
  for I := 0 to ADOConnections.Count - 1 do
  begin
    if ADOConnections[I].ADOConnection = ADOConnection then
    begin
      Dec(ADOConnections[I].RefCount);
      //and try to keep one opened connection

      Count := 0;
      for J := 0 to ADOConnections.Count - 1 do
        if not ADOConnections[J].Isolated then
          Inc(Count);

      if (ADOConnections[I].RefCount = 0) and ((Count > 1) or ADOConnections[I].Isolated) then
      begin
        ADOConnections[I].ADOConnection.Free;
        ADOConnections[I].Free;
        ADOConnections.RemoveAt(I);
      end;
      Exit;
    end;
  end;
end;

function ADOInitialize(dbname: String; ForseNewConnection: Boolean = False): TADOConnection;
var
  I: Integer;
  DBConnection: TADODBConnection;
  ThreadId: THandle;
begin
  dbname := AnsiLowerCase(dbname);
  ThreadId := GetCurrentThreadId;
  if not ForseNewConnection then
    for I := 0 to ADOConnections.Count - 1 do
    begin
      if (ADOConnections[I].FileName = dbname) and not ADOConnections[I].Isolated then
      begin
        Result := ADOConnections[I].ADOConnection;
        Inc(ADOConnections[I].RefCount);
        Exit;
      end;
    end;
  DBConnection := ADOConnections.Add;
  DBConnection.FileName := AnsiLowerCase(dbname);
  DBConnection.RefCount := 1;
  DBConnection.Isolated := ForseNewConnection;
  DBConnection.ThreadID := ThreadId;
  DBConnection.ADOConnection := TADOConnection.Create(nil);
  DBConnection.ADOConnection.ConnectionString := GetConnectionString(dbname, ForseNewConnection);
  DBConnection.ADOConnection.LoginPrompt := False;
  DBConnection.ADOConnection.Provider := MDBProvider;
  if ForseNewConnection then
    DBConnection.ADOConnection.IsolationLevel := ilReadCommitted;

  Result := DBConnection.ADOConnection;
end;

procedure FreeDS(var DS: TDataSet);
var
  Connection: TADOConnection;
begin
  if DS = nil then
    Exit;
  FSync.Enter;
  try
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
  Result := 0;
  try
    ADODBConnection.Open;
  except
    Result := -1;
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
    on e : Exception do
      EventLog(':CompactDatabase_JRO() throw exception: '+e.Message);
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

function GetPathCRC(FileFullPath : string; IsFile: Boolean) : Integer;
var
  Folder, ApplicationPath : string;
  CRC: Cardinal;
begin
  if IsFile then
    // c:\Folder\1.EXE => c:\Folder\
    Folder := SysUtils.ExtractFileDir(FileFullPath)
  else
    Folder := FileFullPath;

  // c:\Folder\ => c:\folder
  Folder := AnsiLowerCase(ExcludeTrailingBackslash(Folder));

  if FolderView then
  begin
    //C:\photodb.exe => c:
    ApplicationPath := ExcludeTrailingBackslash(AnsiLowerCase(ExtractFileDir(ParamStr(0))));

    //c:\folder => \folder
    if (Length(ApplicationPath) <= Length(Folder)) and (Pos(ApplicationPath, Folder) = 1) then
      Delete(Folder, 1, Length(ApplicationPath));

    // \folder => folder
    if (Folder <> '') and (Folder[1] = '\') then
      Delete(Folder, 1, 1);
  end;
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

function TDBQueryParams.AddStringParam(Name, Value: string): TDBStringParam;
begin
  Result := TDBStringParam.Create;
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
      Paramert := TADOQuery(DS).Parameters.FindParam(DBParam.name);
    if Paramert <> nil then
    begin
      if DBParam is TDBDateTimeParam then
        Paramert.Value := TDBDateTimeParam(DBParam).Value;
      if DBParam is TDBIntegerParam then
        Paramert.Value := TDBIntegerParam(DBParam).Value;
      if DBParam is TDBStringParam then
        Paramert.Value := TDBStringParam(DBParam).Value;
    end;
  end;
end;

constructor TDBQueryParams.Create;
begin
  FParamList := TList.Create;
  FQueryType := QT_TEXT;
  FCanBeEstimated := True;
  FData := nil;
end;

destructor TDBQueryParams.Destroy;
begin
  FreeList(FParamList);
  F(FData);
  inherited;
end;

procedure TDBQueryParams.SetData(const Value: TObject);
begin
  F(FData);
  FData := Value;
end;

function DBReadOnly: Boolean;
var
  Attr: Integer;
  ProgramDir: string;
begin
  Result := False;
  if not FolderView then
    Exit;

  ProgramDir := IncludeTrailingBackSlash(ExtractFileDir(ParamStr(0)));

  if FileExists(ProgramDir + 'FolderDB.photodb') then
  begin
    Attr := Windows.GetFileAttributes(PChar(ProgramDir + 'FolderDB.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
    begin
      Result := True;
      Exit;
    end;
  end;

  if FileExists(ProgramDir + GetFileNameWithoutExt(ParamStr(0)) + '.photodb') then
  begin
    Attr := Windows.GetFileAttributes
      (PChar(ProgramDir + GetFileNameWithoutExt(ParamStr(0)) + '.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      Result := True;
  end;
end;

{ TImageDBOptions }

function TImageDBOptions.Copy: TImageDBOptions;
begin
  Result := TImageDBOptions.Create;
  Result.Version := Version;
  Result.DBJpegCompressionQuality := DBJpegCompressionQuality;
  Result.ThSize := ThSize;
  Result.ThSizePanelPreview := ThSizePanelPreview;
  Result.ThHintSize := ThHintSize;
  Result.Description := Description;
  Result.Name := Name;
end;

constructor TImageDBOptions.Create;
begin
  Version := 0;
end;

initialization

  FSync := TCriticalSection.Create;
  ADOConnections := TADOConnections.Create;

  if FolderView then
  begin
    if DBReadOnly then
      DBFConnectionString := DBViewConnectionString;
  end;

finalization

  F(ADOConnections);
  F(FSync);

end.
