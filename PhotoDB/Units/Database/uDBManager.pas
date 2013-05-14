unit uDBManager;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Generics.Defaults,
  Generics.Collections,
  Winapi.Windows,
  Winapi.CommCtrl,
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  Data.DB,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.ImgList,
  Vcl.Imaging.Jpeg,

  UnitDBDeclare,
  UnitINI,

  Dmitry.CRC32,
  Dmitry.Utils.Files,
  Dmitry.Utils.System,

  uMemory,
  uShellIntegration,
  uLogger,
  uConstants,
  uTime,
  uCollectionEvents,
  uShellUtils,
  uAppUtils,
  uTranslate,
  uDBForm,
  uDBConnection,
  uDBScheme,
  uDBContext,
  uDBEntities,
  uRuntime,
  uStringUtils,
  uSettings,
  uCollectionUtils,
  uProgramStatInfo,
  uVCLHelpers;

type
  TDBManager = class(TObject)
  private
    { Private declarations }
    FDBContext: IDBContext;
    class procedure HandleError(E: Exception);
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    class function CreateDBbyName(FileName: string): Boolean;
    function SetDataBase(DatabaseFileName: string): IDBContext;
    function LoadDefaultCollection: Boolean;
    function CreateSampleDefaultCollection: IDBContext;
    function SelectDB(Caller: TDBForm; CollectionFileName: string): Boolean;

    class function CreateExampleDB(FileName: string): Boolean;

    class procedure ReadUserCollections(Collections: TList<TDatabaseInfo>);
    class procedure SaveUserCollections(Collections: TList<TDatabaseInfo>);
    class procedure UpdateUserCollection(Collection: TDatabaseInfo; SortOrder: Integer = -1);
    class function UpdateDatabaseQuery(FileName: string): Boolean;

    property DBContext: IDBContext read FDBContext;
  end;

var
  DBManager: TDBManager = nil;

implementation

class function TDBManager.UpdateDatabaseQuery(FileName: string): Boolean;
var
  Msg: string;
begin
  Msg := FormatEx(TA('Collection "{0}" should be updated to work with this program version. After updating this collection may not work with previous program versions. Update now?', 'Explorer'), [FileName]);

  Result := ID_YES = MessageBoxDB(Screen.ActiveFormHandle, Msg, TA('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING);
end;

class procedure TDBManager.ReadUserCollections(Collections: TList<TDatabaseInfo>);
var
  Reg: TBDRegistry;
  List: TStrings;
  I: Integer;
  Icon, FileName, Description: string;
begin
  List := TStringList.Create;
  try
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(RegRoot + 'dbs', True);
      Reg.GetKeyNames(List);
      for I := 0 to List.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(RegRoot + 'dbs\' + List[I], True);
        if Reg.ValueExists('Icon') and Reg.ValueExists('FileName') then
        begin
          Icon := Reg.ReadString('Icon');
          FileName := Reg.ReadString('FileName');
          Description := Reg.ReadString('Description');
          Collections.Add(TDatabaseInfo.Create(List[I], FileName, Icon, Description, Reg.ReadInteger('Order')));
        end;
      end;
    finally
      F(Reg);
    end;
  finally
    F(List);
  end;

  Collections.Sort(TComparer<TDatabaseInfo>.Construct(
     function (const L, R: TDatabaseInfo): Integer
     begin
       Result := L.Order - R.Order;
     end
  ));
end;

class procedure TDBManager.UpdateUserCollection(Collection: TDatabaseInfo; SortOrder: Integer = -1);
var
  Reg: TBDRegistry;
  Settings: TSettings;
  Context: IDBContext;
  SettingsRepository: ISettingsRepository;
  EventValue: TEventValues;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    if SortOrder = -1 then
      Reg.DeleteKey(RegRoot + 'dbs\' + Collection.OldTitle);

    Reg.OpenKey(RegRoot + 'dbs\' + Collection.Title, True);
    Reg.WriteString('FileName', Collection.Path);
    Reg.WriteString('Icon', Collection.Icon);
    Reg.WriteString('Description', Collection.Description);
    if SortOrder > -1 then
      Reg.WriteInteger('Order', SortOrder)
    else
      Reg.WriteInteger('Order', Collection.Order);

    if FileExistsSafe(Collection.Path) then
    begin
      if TDBScheme.IsOldColectionFile(Collection.Path) then
      begin
        if UpdateDatabaseQuery(Collection.Path) then
          TDBScheme.UpdateCollection(Collection.Path, 0, True);
      end;

      if TDBScheme.IsValidCollectionFile(Collection.Path) then
      begin
        Context := TDBContext.Create(Collection.Path);
        SettingsRepository := Context.Settings;

        Settings := SettingsRepository.Get;
        try
          Settings.Name := Collection.Title;
          Settings.Description := Collection.Description;
          SettingsRepository.Update(Settings);
        finally
          F(Settings);
        end;
      end;

      if SortOrder = -1 then
      begin
        EventValue.NewName := Collection.Title;
        CollectionEvents.DoIDEvent(nil, 0, [EventID_CollectionInfoChanged], EventValue);
      end;
    end;
  finally
    F(Reg);
  end;
end;

class procedure TDBManager.SaveUserCollections(Collections: TList<TDatabaseInfo>);
var
  Reg: TBDRegistry;
  List: TStrings;
  I: Integer;
  DB: TDatabaseInfo;
  EventValue: TEventValues;
begin
  List := TStringList.Create;
  try
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(RegRoot + 'dbs', True);
      Reg.GetKeyNames(List);
      for I := 0 to List.Count - 1 do
        Reg.DeleteKey(List[I]);

      for DB in Collections do
        UpdateUserCollection(DB, Collections.IndexOf(DB));

      EventValue.NewName := '';
      CollectionEvents.DoIDEvent(nil, 0, [EventID_CollectionInfoChanged], EventValue);
    finally
      F(Reg);
    end;
  finally
    F(List);
  end;
end;

{ TDBManager }

constructor TDBManager.Create;
begin
  inherited;
  FDBContext := nil;
end;

class function TDBManager.CreateDBbyName(FileName: string): Boolean;
begin
  Result := False;
  CreateDirA(ExtractFileDir(FileName));
  try
    if FileExistsSafe(FileName) then
    begin
      if ID_YES <> MessageBoxDB(Screen.ActiveFormHandle, FormatEx(TA('Collection "{0}" already exists! Delete this collection file?', 'Explorer'), [FileName]), TA('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING) then
        Exit;
      DeleteFile(FileName);
    end;

    if FileExistsSafe(FileName) then
      Exit;

    TDBScheme.CreateCollection(FileName);
    Result := True;
  except
    on E: Exception do
    begin
      HandleError(E);
      EventLog(':TDBKernel::CreateDBbyName() throw exception: ' + E.message);
      Exit;
    end;
  end;

  ProgramStatistics.DBUsed;
end;

class function TDBManager.CreateExampleDB(FileName: string): Boolean;
var
  NewGroup: TGroup;
  ImagesDir: string;
  DBContext: IDBContext;
  GroupsRepository: IGroupsRepository;
begin
  Result := False;
  if not CreateDBbyName(FileName) then
    Exit;

  DBContext := TDBContext.Create(FileName);
  GroupsRepository := DBContext.Groups;

  ImagesDir := ExtractFilePath(Application.ExeName) + 'Images\';
  if FileExists(ImagesDir + 'Me.jpg') then
  begin
    NewGroup := TGroup.Create;
    try
      NewGroup.GroupName := GetWindowsUserName;
      NewGroup.GroupCode := TGroup.CreateNewGroupCode;
      NewGroup.GroupImage := TJPEGImage.Create;
      NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Me.jpg');
      NewGroup.GroupDate := Now;
      NewGroup.GroupComment := '';
      NewGroup.GroupFaces := '';
      NewGroup.GroupAccess := 0;
      NewGroup.GroupKeyWords := NewGroup.GroupName;
      NewGroup.AutoAddKeyWords := True;
      NewGroup.RelatedGroups := '';
      NewGroup.IncludeInQuickList := True;
      GroupsRepository.Add(NewGroup);
    finally
      F(NewGroup);
    end;
  end;

  if FileExists(ImagesDir + 'Friends.jpg') then
  begin
    NewGroup := TGroup.Create;
    try
      NewGroup.GroupName := TA('Friends', 'Setup');
      NewGroup.GroupCode := TGroup.CreateNewGroupCode;
      NewGroup.GroupImage := TJPEGImage.Create;
      NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Friends.jpg');
      NewGroup.GroupDate := Now;
      NewGroup.GroupComment := '';
      NewGroup.GroupFaces := '';
      NewGroup.GroupAccess := 0;
      NewGroup.GroupKeyWords := TA('Friends', 'Setup');
      NewGroup.AutoAddKeyWords := True;
      NewGroup.RelatedGroups := '';
      NewGroup.IncludeInQuickList := True;
      GroupsRepository.Add(NewGroup);
    finally
      F(NewGroup);
    end;
  end;

  if FileExists(ImagesDir + 'Family.jpg') then
  begin
    NewGroup := TGroup.Create;
    try
      NewGroup.GroupName := TA('Family', 'Setup');
      NewGroup.GroupCode := TGroup.CreateNewGroupCode;
      NewGroup.GroupImage := TJPEGImage.Create;
      NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Family.jpg');
      NewGroup.GroupDate := Now;
      NewGroup.GroupComment := '';
      NewGroup.GroupFaces := '';
      NewGroup.GroupAccess := 0;
      NewGroup.GroupKeyWords := TA('Family', 'Setup');
      NewGroup.AutoAddKeyWords := True;
      NewGroup.RelatedGroups := '';
      NewGroup.IncludeInQuickList := True;
      GroupsRepository.Add(NewGroup);
    finally
      F(NewGroup);
    end;
  end;

  Result := True;
end;

destructor TDBManager.Destroy;
begin
  FDBContext := nil;
  inherited;
end;

function TDBManager.SelectDB(Caller: TDBForm; CollectionFileName: string): Boolean;
var
  EventInfo: TEventValues;
begin
  if not FileExists(CollectionFileName) then
    raise Exception.Create(FormatEx(TA('Can''t find collection file: {0}!', 'Errors'), [CollectionFileName]));

  if not TDBScheme.IsValidCollectionFile(CollectionFileName) then
  begin
    if TDBManager.UpdateDatabaseQuery(CollectionFileName) then
      TDBScheme.UpdateCollection(CollectionFileName, 0, True);
  end;

  if TDBScheme.IsValidCollectionFile(CollectionFileName) then
  begin
    SetDataBase(CollectionFileName);
    CollectionEvents.DoIDEvent(Caller, 0, [EventID_Param_DB_Changed], EventInfo);
    Result := True;
    Exit;
  end else
    raise Exception.Create(FormatEx(TA('Can''t select old version of collection file!', 'Errors'), [CollectionFileName]));
end;

function TDBManager.SetDataBase(DatabaseFileName: string): IDBContext;
var
  Reg: TBDRegistry;
begin
  if not FileExistsSafe(DatabaseFileName) then
    Exit;

  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot, True);
    Reg.WriteString('DBDefaultName', DatabaseFileName);

    FDBContext := TDBContext.Create(DatabaseFileName);

    Result := FDBContext;
  finally
    F(Reg);
  end;
end;

function TDBManager.LoadDefaultCollection: Boolean;
var
  CollectionFileName: string;
begin
  FDBContext := nil;

  if FolderView then
  begin
    CollectionFileName := ExtractFilePath(Application.ExeName) + 'FolderDB.photodb';

    if FileExistsSafe(ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb') then
      CollectionFileName := ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb';
  end else
  begin
    CollectionFileName := AppSettings.DataBase;

    if not FileExistsSafe(CollectionFileName) then
      FDBContext := CreateSampleDefaultCollection;
  end;

  if FDBContext = nil then
    FDBContext := TDBContext.Create(CollectionFileName);

  Result := FDBContext.IsValid;
end;

function TDBManager.CreateSampleDefaultCollection: IDBContext;
var
  Collections: TList<TDatabaseInfo>;
  CollectionFile: string;
  SettingsRepository: ISettingsRepository;
  Settings: TSettings;

  function IsCollectionFile(FileName: string): Boolean;
  begin
    Result := TDBScheme.GetCollectionVersion(FileName) > 0;
  end;

begin
  //if program was uninstalled with registered databases - restore database or create new database
  CollectionFile := IncludeTrailingBackslash(GetMyDocumentsPath) + TA('My collection', 'CollectionSettings') + '.photodb';
  if not (FileExistsSafe(CollectionFile) and IsCollectionFile(CollectionFile)) then
  begin
    CollectionFile := IncludeTrailingBackslash(GetMyDocumentsPath) + FormatEx(TA('Photos - {0}', 'CollectionSettings'), [GetWindowsUserName]) + '.photodb';
    if not (FileExistsSafe(CollectionFile) and IsCollectionFile(CollectionFile)) then
      CreateExampleDB(CollectionFile);
  end;

  Collections := TList<TDatabaseInfo>.Create;
  try
    ReadUserCollections(Collections);
    Collections.Add(TDatabaseInfo.Create(FormatEx(TA('Photos - {0}', 'CollectionSettings'), [GetWindowsUserName]), CollectionFile, Application.ExeName + ',0', '', Collections.Count));
    SaveUserCollections(Collections);

    Result := SetDataBase(CollectionFile);

    if Result <> nil then
    begin
      SettingsRepository := Result.Settings;

      Settings := SettingsRepository.Get;
      try
        if Settings.Name = '' then
        begin
          Settings.Name := TA('Photos - {0}', 'CollectionSettings');
          Settings.Description := TA('My collection', 'CollectionSettings');

          SettingsRepository.Update(Settings);
        end;
      finally
        F(Settings);
      end;

      CheckDefaultSyncDirectoryForCollection(CollectionFile);
    end;

  finally
    FreeList(Collections);
  end;
end;

class procedure TDBManager.HandleError(E: Exception);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      MessageBoxDB(0, E.Message, TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      NotifyOleException(E);
    end
  );
  EventLog(E);
end;

initialization
finalization
  F(DBManager);

end.
