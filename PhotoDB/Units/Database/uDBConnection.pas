unit uDBConnection;

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
  uAppUtils,
  uSettings,
  uResources,
  uDBBaseTypes,
  uSplashThread,
  uShellUtils;

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
  TADOConnectionEx = class(TADOConnection)
  private
    FFileName: string;
  public
    property FileName: string read FFileName write FFileName;
  end;

type
  TDBConnection = class(TObject)
  private
    FFileName: string;
    FFreeOnClose: Boolean;
    FThreadID: DWORD;
    FIsolationLevel: TDBIsolationLevel;
    FIsBusy: Boolean;
    FADOConnection: TADOConnectionEx;
  public
    constructor Create(FileName: string; IsolationLevel: TDBIsolationLevel);
    destructor Destroy; override;

    procedure Reuse;
    procedure Detach;

    property FreeOnClose: Boolean read FFreeOnClose write FFreeOnClose;
    property ThreadID: DWORD read FThreadID;
    property FileName: string read FFileName;
    property IsolationLevel: TDBIsolationLevel read FIsolationLevel;
    property IsBusy: Boolean read FIsBusy;
    property Connection: TADOConnectionEx read FADOConnection;
  end;

  TConnectionManager = class(TObject)
  private
    FConnections: TList;
    FSync: TCriticalSection;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TDBConnection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RemoveAt(Index: Integer);
    function Add(FileName: string; IsolationLevel: TDBIsolationLevel): TDBConnection;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TDBConnection read GetValueByIndex; default;
  end;

var
  ADOConnections: TConnectionManager = nil;
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


function GetTable(Table: string; TableID: Integer = DB_TABLE_UNKNOWN): TDataSet;
function GetQuery(TableName: string; CreateNewConnection: Boolean = False; IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet;

function TryOpenCDS(DS: TDataSet): Boolean;
function OpenDS(DS: TDataSet): Boolean;
procedure ForwardOnlyQuery(DS: TDataSet);
procedure ReadOnlyQuery(DS: TDataSet);
procedure SetSQL(SQL: TDataSet; SQLText: string);
procedure ExecSQL(SQL: TDataSet);

procedure FreeDS(var DS: TDataSet);

procedure LoadParamFromStream(Query: TDataSet; index: Integer; Stream: TStream; FT: TFieldType);
procedure SetDateParam(Query: TDataSet; name: string; Date: TDateTime);
procedure SetBoolParam(Query: TDataSet; Index: Integer; Bool: Boolean);
procedure SetStrParam(Query: TDataSet; Index: Integer; Value: string);
procedure SetIntParam(Query: TDataSet; Index: Integer; Value: Integer);
function GetBlobStream(F: TField; Mode: TBlobStreamMode) : TStream;
procedure AssignParam(Query: TDataSet; Index: Integer; Value: TPersistent);

procedure CreateMSAccessDatabase(FileName: string);
procedure TryRemoveConnection(FileName: string; Delete: Boolean = False);
procedure PackTable(FileName: string; Progress: TSimpleCallBackProgressRef);

function GetPathCRC(FileFullPath: string; IsFile: Boolean): Integer;
function NormalizeDBString(S: string): string;
function NormalizeDBStringLike(S: string): string;

function DBReadOnly: Boolean;
procedure NotifyOleException(E: Exception);

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

function IsProviderValidAndCanBeUsed(ProviderName: string): Boolean;
var
  DBFileName, ConnectionString: string;
  Connection: TADOConnectionEx;
  List: TStrings;
begin
  Result := True;

  DBFileName := GetTempFileName;

  CreateMSAccessDatabase(DBFileName);
  try
    //test database by reading it
    Connection := TADOConnectionEx.Create(nil);
    try
      Connection.FileName  := DBFileName;
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

function ConnectionString: string;
var
  Provider: string;
begin
  Provider := DataBaseProvider;

  Result := GetProviderConnectionString(Provider);
end;

function GetConnection(FileName: string; ForseNewConnection: Boolean = False; IsolationLevel: TDBIsolationLevel = dbilReadWrite): TADOConnection;
var
  I: Integer;
  DBConnection: TDBConnection;
begin
  FileName := AnsiLowerCase(FileName);

  if not ForseNewConnection then
    for I := 0 to ADOConnections.Count - 1 do
    begin
      DBConnection := ADOConnections[I];
      if (DBConnection.FileName = FileName) and (DBConnection.IsolationLevel = IsolationLevel) and not DBConnection.IsBusy and not DBConnection.FreeOnClose then
      begin
        DBConnection.Reuse;
        Result := DBConnection.Connection;
        Exit;
      end;
    end;

  DBConnection := ADOConnections.Add(FileName, IsolationLevel);
  Result := DBConnection.Connection;
end;

procedure TryRemoveConnection(FileName: string; Delete: Boolean = false);
var
  I: Integer;
begin
  FileName := AnsiLowerCase(FileName);
  for I := ADOConnections.Count - 1 downto 0 do
  begin
    if ADOConnections[I].FileName = FileName then
      if (not ADOConnections[I].IsBusy) and Delete then
      begin
        ADOConnections[I].Free;
        ADOConnections.RemoveAt(I);
        Exit;
      end;
  end;
end;

procedure RemoveADORef(ADOConnection: TADOConnectionEx);
const
  MaxConnectionPoolRead = 5;
  MaxConnectionPoolWrite = 1;

var
  I: Integer;
  Connection: TDBConnection;
  MaxConnectionPoolByLevel: Integer;
  FileName: string;

  function GetConnectionsCount(IsolationLevel: TDBIsolationLevel): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to ADOConnections.Count - 1 do
      if (not ADOConnections[I].IsBusy) and (ADOConnections[I].IsolationLevel = IsolationLevel) then
        Inc(Result);
  end;

begin
  if ADOConnections = nil then
    Exit;

  FileName := ADOConnection.FileName;
  MaxConnectionPoolByLevel := 0;

  for I := 0 to ADOConnections.Count - 1 do
  begin
    Connection := ADOConnections[I];
    if Connection.Connection = ADOConnection then
    begin
      if Connection.IsolationLevel = dbilRead then
        MaxConnectionPoolByLevel := MaxConnectionPoolRead;
      if Connection.IsolationLevel = dbilReadWrite then
        MaxConnectionPoolByLevel := MaxConnectionPoolWrite;

      Connection.Detach;
      Break;
    end;
  end;

  //close old connections
  for I := ADOConnections.Count - 1 downto 0 do
  begin
    Connection := ADOConnections[I];
    if (not Connection.IsBusy) and (Connection.FreeOnClose) then
    begin
      Connection.Free;
      ADOConnections.RemoveAt(I);
      Break;
    end;
  end;

  for I := ADOConnections.Count - 1 downto 0 do
  begin
    Connection := ADOConnections[I];
    if (Connection.FileName = FileName) and not Connection.IsBusy and (GetConnectionsCount(Connection.IsolationLevel) > MaxConnectionPoolByLevel) then
    begin
      Connection.Free;
      ADOConnections.RemoveAt(I);
    end;
  end;
end;

procedure CloseReadOnlyConnections(ADOConnection: TADOConnectionEx);
var
  I: Integer;
  Connection: TDBConnection;
begin
  for I := ADOConnections.Count - 1 downto 0 do
  begin
    Connection := ADOConnections[I];
    if (Connection.FileName = ADOConnection.FileName) and (Connection.IsolationLevel = dbilRead) then
      Connection.FreeOnClose := True;
  end;
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

procedure ExecSQL(SQL: TDataSet);
begin
  if (SQL is TADOQuery) then
  begin
    (SQL as TADOQuery).ExecSQL;
    CloseReadOnlyConnections((SQL as TADOQuery).Connection as TADOConnectionEx);
  end;
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

function GetQuery(TableName: string; CreateNewConnection: Boolean = False; IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet;
begin
  FSync.Enter;
  try
    Result := TADOQuery.Create(nil);
    if IsolationLevel = dbilReadWrite then
      IsolationLevel := dbilReadWrite;
    (Result as TADOQuery).Connection := GetConnection(TableName, CreateNewConnection, IsolationLevel);
    if DBReadOnly then
      ReadOnlyQuery(Result);
  finally
    FSync.Leave;
  end;
end;

function GetTable(Table: String; TableID: Integer = DB_TABLE_UNKNOWN): TDataSet;
begin
  FSync.Enter;
  try
    Result := TADODataSet.Create(nil);
    (Result as TADODataSet).Connection := GetConnection(Table);
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
      RemoveADORef(Connection as TADOConnectionEx);
      Exit;
    end;
    if DS is TADODataSet then
    begin
      Connection := (DS as TADODataSet).Connection;
      F(DS);
      RemoveADORef(Connection as TADOConnectionEx);
      Exit;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure CompactDatabase_JRO(DatabaseName:string; DestDatabaseName: string; Password: string;
  Progress: TSimpleCallBackProgressRef);
const
   Provider = 'Provider=Microsoft.Jet.OLEDB.4.0;';
var
  TempName: array[0..MAX_PATH] of Char; // имя временного файла
  TempPath: string; // путь до него
  Name: string;
  Src,Dest : WideString;
  V: Variant;
  WatchThread: TThread;
  PackInProgress: Boolean;
  TotalSize: Int64;
begin
  try
    TotalSize := GetFileSize(DatabaseName);

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

    PackInProgress := True;
    WatchThread := TThread.CreateAnonymousThread(
      procedure
      var
        CurrentSize: Int64;
      begin
        while PackInProgress do
        begin
          Sleep(50);
          if Assigned(Progress) then
          begin
            CurrentSize := GetFileSizeByName(Name);
            if CurrentSize > TotalSize then
              CurrentSize := TotalSize;

            Progress(nil, TotalSize, CurrentSize);
          end;
        end;
      end
    );
    WatchThread.Start;
    WatchThread.FreeOnTerminate := True;

    PackInProgress := True;
    try

      V := CreateOleObject('jro.JetEngine');
      try
        V.CompactDatabase(Src, Dest);// сжимаем
      finally
        V := 0;
      end;

    finally
      PackInProgress := False;
    end;

    if DestDatabaseName='' then
    begin
      DeleteFile(DatabaseName); //то удаляем не упакованную базу
      RenameFile(Name, DatabaseName); // и переименовываем упакованную базу
    end;
  except
   on e: Exception do
     EventLog(':CompactDatabase_JRO() throw exception: ' + e.Message);
  end;
end;

procedure PackTable(FileName: string; Progress: TSimpleCallBackProgressRef);
begin
  TryRemoveConnection(FileName, True);

  CompactDatabase_JRO(FileName, '', '', Progress);
end;

{ TADOConnections }

function TConnectionManager.Add(FileName: string; IsolationLevel: TDBIsolationLevel): TDBConnection;
begin
  Result := TDBConnection.Create(FileName, IsolationLevel);
  FConnections.Add(Result);
end;

constructor TConnectionManager.Create;
begin
  FSync := TCriticalSection.Create;
  FConnections := TList.Create;
end;

destructor TConnectionManager.Destroy;
begin
  FreeList(FConnections);
  F(FSync);
  inherited;
end;

function TConnectionManager.GetCount: Integer;
begin
  Result := FConnections.Count;
end;

function TConnectionManager.GetValueByIndex(Index: Integer): TDBConnection;
begin
  Result := FConnections[Index];
end;

procedure TConnectionManager.RemoveAt(Index: Integer);
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

{ TDBConnection }

constructor TDBConnection.Create(FileName: string; IsolationLevel: TDBIsolationLevel);
begin
  FFileName := AnsiLowerCase(FileName);
  FIsolationLevel := IsolationLevel;
  FThreadID := GetCurrentThreadId;
  FreeOnClose := False;
  FIsBusy := True;

  FADOConnection := TADOConnectionEx.Create(nil);
  FADOConnection.FileName := FileName;
  FADOConnection.ConnectionString := GetConnectionString(ConnectionString, FileName, IsolationLevel);
  FADOConnection.LoginPrompt := False;
  if IsolationLevel = dbilRead then
    FADOConnection.IsolationLevel := ilReadCommitted;
end;

destructor TDBConnection.Destroy;
begin
  F(FADOConnection);
  inherited;
end;

procedure TDBConnection.Detach;
begin
  FIsBusy := False;
end;

procedure TDBConnection.Reuse;
begin
  if FreeOnClose then
    raise Exception.Create(FormatEx('Connection should be destroyed! ThreadId = {0}', [ThreadID]));

  if IsBusy then
    raise Exception.Create(FormatEx('Connection is already in use in thread {0}!', [ThreadID]));

  FIsBusy := True;
  FThreadID := GetCurrentThreadId;
end;

initialization
  FSync := TCriticalSection.Create;
  ADOConnections := TConnectionManager.Create;

finalization
  F(ADOConnections);
  F(FSync);

end.
