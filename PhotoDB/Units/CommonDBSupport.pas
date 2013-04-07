unit CommonDBSupport;

interface

uses
  Winapi.Windows,
  Winapi.ShellApi,
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Win.ComObj,
  Data.DB,
  Data.Win.ADODB,

  Dmitry.CRC32,
  Dmitry.Utils.System,
  Dmitry.Utils.Files,

  uConstants,
  uRuntime,
  uMemory,
  uLogger,
  uTime,
  uShellIntegration,
  uTranslate,
  uResources,
  uAppUtils,
  uSettings,
  uSplashThread,
  uShellUtils,

  UnitDBCommon;

const
  DB_TABLE_UNKNOWN         = 0;
  DB_TABLE_GROUPS          = 1;
  DB_TABLE_IMAGES          = 2;
  DB_TABLE_PERSONS         = 3;
  DB_TABLE_PERSON_MAPPING  = 4;
  DB_TABLE_SETTINGS        = 5;

type
  TDBIsolationLevel = (dbilReadWrite, dbilRead, dbilExclusive);

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
    property Data: TObject read FData;
  end;

var
  ADOConnections: TADOConnections = nil;
  DBLoadInitialized: Boolean = False;
  FSync: TCriticalSection = nil;

const
 ErrorCodeProviderNotFound = $800A0E7A;

  Jet40ProviderName = 'Microsoft.Jet.OLEDB.4.0';
  ACE12ProviderName = 'Microsoft.ACE.OLEDB.12.0';
  ACE14ProviderName = 'Microsoft.ACE.OLEDB.14.0';

  Jet40ConnectionString: string =
                            'Provider=Microsoft.Jet.OLEDB.4.0;Password="";User ID=Admin;'+
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
  Jet40ReadOnlyConnectionString: string =
                            'Provider=Microsoft.Jet.OLEDB.4.0;Password="";'+
                            'User ID=Admin;Data Source=%s;'+
                            'Mode=Share Deny Write;Extended Properties="";'+
                            'Jet OLEDB:System database="";Jet OLEDB:Registry Path="";'+
                            'Jet OLEDB:Database Password="";Jet OLEDB:Engine Type=0;'+
                            'Jet OLEDB:Database Locking Mode=1;Jet OLEDB:Global Partial Bulk Ops=1;'+
                            'Jet OLEDB:Global Bulk Transactions=1;Jet OLEDB:New Database Password="";'+
                            'Jet OLEDB:Create System Database=False;Jet OLEDB:Encrypt Database=False;'+
                            'Jet OLEDB:Don''t Copy Locale on Compact=False;Jet OLEDB:'+
                            'Compact Without Replica Repair=False;Jet OLEDB:SFP=False';

  ACE12ConnectionString: string =
                            'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=%s;Persist Security Info=False';
  ACE14ConnectionString: string =
                            'Provider=Microsoft.ACE.OLEDB.14.0;Data Source=%s;Persist Security Info=False';

procedure FreeDS(var DS: TDataSet);
function ADOInitialize(Dbname: string; ForseNewConnection: Boolean = False; IsolationLevel: TDBIsolationLevel = dbilReadWrite): TADOConnection;

function GetTable(Table: string; TableID: Integer = DB_TABLE_UNKNOWN): TDataSet; overload;

function GetConnectionString(ConnectionString: string; Dbname: string; IsolationMode: TDBIsolationLevel): string; overload;
function GetConnectionString(Dbname: string; IsolationMode: TDBIsolationLevel): string; overload;

function GetQuery(TableName: string; CreateNewConnection: Boolean = False; IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet; overload;

procedure SetSQL(SQL: TDataSet; SQLText: String);
procedure ExecSQL(SQL: TDataSet);

procedure LoadParamFromStream(Query: TDataSet; index: Integer; Stream: TStream; FT: TFieldType);
procedure SetDateParam(Query: TDataSet; name: string; Date: TDateTime);
procedure SetBoolParam(Query: TDataSet; Index: Integer; Bool: Boolean);
procedure SetStrParam(Query: TDataSet; Index: Integer; Value: string);
procedure SetIntParam(Query: TDataSet; Index: Integer; Value: Integer);

function GetBlobStream(F : TField; Mode : TBlobStreamMode) : TStream;
procedure AssignParam(Query : TDataSet; index : integer; Value : TPersistent);

procedure CreateMSAccessDatabase(FileName: string);
procedure TryRemoveConnection(Dbname: string; Delete: Boolean = False);
procedure RemoveADORef(ADOConnection: TADOConnection);

procedure PackTable(FileName: string);
function GetPathCRC(FileFullPath: string; IsFile: Boolean): Integer;
function NormalizeDBString(S: string): string;
function NormalizeDBStringLike(S: string): string;
function TryOpenCDS(DS: TDataSet): Boolean;     
function OpenDS(DS: TDataSet): Boolean;
procedure ForwardOnlyQuery(DS: TDataSet);
procedure ReadOnlyQuery(DS: TDataSet);
function DBReadOnly: Boolean;
procedure NotifyOleException(E: Exception);
function GetProviderConnectionString(ProviderName: string): string;

implementation

var
  FIsBrowserWithNotifyUserAboutErorrsInProvidersOpened: Boolean = False; 
  FIsMessageBoxForUserAboutErorrsInProvidersOpened: Boolean = False;

procedure NotifyOleException(E: Exception);
var
  ErrorCode: HRESULT;
begin
  ErrorCode := 0;
  if E is EOleException then
    ErrorCode := EOleException(E).ErrorCode;

  ShellExecute(0, 'open', PWideChar(ResolveLanguageString(ActionHelpPageURL) + 'ole-exception&code=' + IntToHex(ErrorCode, 8) + '&msg=' + E.Message), nil, nil, SW_NORMAL);
end;

procedure NotifyUserAboutErorrsInProviders;
begin
  if not FIsBrowserWithNotifyUserAboutErorrsInProvidersOpened then
  begin
    FIsBrowserWithNotifyUserAboutErorrsInProvidersOpened := True;
    ShellExecute(0, 'open', PWideChar(ResolveLanguageString(ActionHelpPageURL) + 'provider-not-found'), nil, nil, SW_NORMAL);
  end;
end;

procedure RaiseProviderNotFoundException;
var
  ProvidersList: string;
begin
  //close splash screen if it's being shown
  CloseSplashWindow;

  //reset provider
  AppSettings.WriteString('Settings', 'DatabaseProvider', '');

  //create error message

  if not FIsMessageBoxForUserAboutErorrsInProvidersOpened then
  begin   
    FIsMessageBoxForUserAboutErorrsInProvidersOpened := True;                                                          
    ProvidersList := Jet40ProviderName + ', ' + ACE12ProviderName + ', ' + ACE14ProviderName;
    MessageBoxDB(0, FormatEx(TA('Fatal error: at least one provider should be registered: {0}', 'Errors'), [ProvidersList]), TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
  end;
  //try to send user to page with detailed information
  NotifyUserAboutErorrsInProviders;
end;

function IsProviderValidAndCanBeUsed(ProviderName: string): Boolean;
var
  DBFileName, ConnectionString: string;
  Connection: TADOConnection;
  List: TStrings;
begin
  Result := True;

  DBFileName := GetTempFileName;

  CreateMSAccessDatabase(DBFileName);
  try
    //test database by reading it
    Connection := TADOConnection.Create(nil);
    try
      Connection := TADOConnection.Create(nil);

      ConnectionString := GetProviderConnectionString(ProviderName);
      ConnectionString := GetConnectionString(ConnectionString, DBFileName, dbilReadWrite);

      Connection.ConnectionString := ConnectionString;
      Connection.LoginPrompt := False;
      Connection.IsolationLevel := ilReadCommitted;
      List := TStringList.Create;
      try
        try
          Connection.GetTableNames(List, True);
        except
          on e: Exception do
          begin
            EventLog(e);
            Exit(False);
          end;
        end;
      finally
        F(List);
      end;
    finally
      F(Connection);
    end;
  finally
    DeleteFile(DBFileName);
  end;
end;

function DataBaseProvider: string;
const
  ProviderList: array[0..2] of string = (Jet40ProviderName, ACE12ProviderName, ACE14ProviderName);

var
  S: TStrings;
  I, J: Integer;
begin
  Result := AppSettings.ReadString('Settings', 'DatabaseProvider');
  if Result <> '' then
    Exit(Result);

  S := TStringList.Create;
  try
    try
      GetProviderNames(S);
    except
      on E: Exception do
      begin
        MessageBoxDB(0, E.Message, TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        NotifyOleException(E);
      end;
    end;

    for I := Low(ProviderList) to High(ProviderList) do
    begin
      for J := 0 to S.Count - 1 do
      begin
        if AnsiLowerCase(S[J]) = AnsiLowerCase(ProviderList[I]) then
          if IsProviderValidAndCanBeUsed(ProviderList[I]) then
          begin
            AppSettings.WriteString('Settings', 'DatabaseProvider', ProviderList[I]);
            Exit(ProviderList[I]);
          end;
      end;
    end;
  finally
    F(S);
  end;
end;

function GetProviderConnectionString(ProviderName: string): string;
begin
  if ProviderName = '' then
    RaiseProviderNotFoundException;

  if (ProviderName = ACE12ProviderName) or GetParamStrDBBool('/ace12') then
    Exit(ACE12ConnectionString);

  if (ProviderName = ACE14ProviderName) or GetParamStrDBBool('/ace14') then
    Exit(ACE14ConnectionString);

  if FolderView and DBReadOnly then
    Exit(Jet40ReadOnlyConnectionString);

  Result := Jet40ConnectionString;
end;

function ConnectionString: string;
var
  Provider: string;
begin
  Provider := DataBaseProvider;

  Result := GetProviderConnectionString(Provider);
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
      on e: Exception do
      begin
        Result := False;
        if E is EOleException then
        begin
          if (EOleException(E).ErrorCode and $FFFFFFFF) = ErrorCodeProviderNotFound then
          begin
            RaiseProviderNotFoundException;
            Exit;
          end;
        end;
      end;
    end;
    if Result then
      Break;
    Sleep(DelayExecuteSQLOperation);
  end;
end;      

function OpenDS(DS: TDataSet): Boolean;
begin
  try
    DS.Open;
    Result := True;
  except
    on e: EOleException do
    begin
      if (E.ErrorCode and $FFFFFFFF) = ErrorCodeProviderNotFound then
        RaiseProviderNotFoundException;

      raise;
    end;
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

function GetBlobStream(F: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := nil;
  if (F is TBlobField) and (F.DataSet is TADOQuery) then
    Result := TADOBlobStream.Create(TBlobField(F), Mode);
  if (F is TBlobField) and (F.DataSet is TADODataSet) then
    Result := TADOBlobStream.Create(TBlobField(F), Mode);
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

function GetConnectionString(ConnectionString: string; Dbname: string; IsolationMode: TDBIsolationLevel): string;
var
  Isolation: string;
begin
  Isolation := 'Share Deny None';
  if IsolationMode = dbilRead then
    Isolation := 'Read';
  if IsolationMode = dbilExclusive then
    Isolation := 'Share Exclusive';

  Result := StringReplace(ConnectionString, '%MODE%', Isolation, [rfReplaceAll, rfIgnoreCase]);
  Result := Format(Result, [Dbname]);
end;

function GetConnectionString(Dbname: string; IsolationMode: TDBIsolationLevel): string;
begin
  Result := GetConnectionString(ConnectionString, Dbname, IsolationMode);
end;

procedure ExecSQL(SQL: TDataSet);
begin
  if (SQL is TADOQuery) then
    (SQL as TADOQuery).ExecSQL;
end;

procedure SetSQL(SQL: TDataSet; SQLText : String);
var
  I: Integer;
begin
  for I := 1 to 20 do
  begin
    try
      if (SQL is TADOQuery) then
      begin
        SQLText := StringReplace(SQLText, '$DB$', 'ImageTable', [RfReplaceAll, RfIgnoreCase]);
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

function GetQuery(TableName: string; CreateNewConnection: Boolean = False; IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet;
begin
  FSync.Enter;
  try
    Result := TADOQuery.Create(nil);
    (Result as TADOQuery).Connection := ADOInitialize(TableName, CreateNewConnection, IsolationLevel);
    if DBReadOnly then
      ReadOnlyQuery(Result);
  finally
    FSync.Leave;
  end;
end;

function GetTable(Table: String; TableID: Integer = DB_TABLE_UNKNOWN) : TDataSet;
begin
  FSync.Enter;
  try
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
  finally
    FSync.Leave;
  end;
end;

procedure CreateMSAccessDatabase(FileName: string);
var
  MS: TMemoryStream;
  FS: TFileStream;
begin
  MS := GetRCDATAResourceStream('SampleDB');
  try
    FS := TFileStream.Create(FileName, fmCreate, fmExclusive);
    try
      FS.CopyFrom(MS, MS.Size);
    finally
      F(FS);
    end;
  finally
    F(MS);
  end;
end;

procedure TryRemoveConnection(dbname: string; Delete: Boolean = false);
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
  if ADOConnections = nil then
    Exit;

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

function ADOInitialize(dbname: String; ForseNewConnection: Boolean = False; IsolationLevel: TDBIsolationLevel = dbilReadWrite): TADOConnection;
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
  DBConnection.ADOConnection.ConnectionString := GetConnectionString(dbname, IsolationLevel);
  DBConnection.ADOConnection.LoginPrompt := False;
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

procedure CompactDatabase_JRO(DatabaseName:string; DestDatabaseName: string = ''; Password: string = '');
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
     if DestDatabaseName <> '' then
       Name := DestDatabaseName
     else
     begin
       TempPath := ExtractFilePath(DatabaseName);
       if TempPath = '' then
         TempPath:=GetCurrentDir;

       Winapi.Windows.GetTempFileName(PWideChar(TempPath), 'mdb' , 0, TempName);
       Name := StrPas(TempName);
     end;
     DeleteFile(Name);
     Dest := Provider + 'Data Source=' + Name;
     if Password<>'' then
     begin
       Src := Src + ';Jet OLEDB:Database Password=' + Password;
       Dest := Dest + ';Jet OLEDB:Database Password=' + Password;
     end;

     V := CreateOleObject('jro.JetEngine');
     try
       V.CompactDatabase(Src,Dest);// сжимаем
     finally
       V := 0;
     end;
     if DestDatabaseName='' then
     begin
       DeleteFile(DatabaseName); //то удаляем не упакованную базу
       RenameFile(Name,DatabaseName); // и переименовываем упакованную базу
     end;
   except
    on e: Exception do
      EventLog(':CompactDatabase_JRO() throw exception: '+e.Message);
   end;
end;

procedure PackTable(FileName: string);
begin
  CommonDBSupport.TryRemoveConnection(FileName, True);
  CompactDatabase_JRO(FileName, '', '')
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
  I: Integer;
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

function GetPathCRC(FileFullPath: string; IsFile: Boolean): Integer;
var
  Folder, ApplicationPath : string;
  CRC: Cardinal;
begin
  if IsFile then
    // c:\Folder\1.EXE => c:\Folder\
    Folder := ExtractFileDir(FileFullPath)
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
    Attr := GetFileAttributes(PChar(ProgramDir + 'FolderDB.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
    begin
      Result := True;
      Exit;
    end;
  end;

  if FileExists(ProgramDir + GetFileNameWithoutExt(ParamStr(0)) + '.photodb') then
  begin
    Attr := GetFileAttributes(PChar(ProgramDir + GetFileNameWithoutExt(ParamStr(0)) + '.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      Result := True;
  end;
end;

initialization

  FSync := TCriticalSection.Create;
  ADOConnections := TADOConnections.Create;

finalization

  F(ADOConnections);
  F(FSync);

end.
