unit UnitDBKernel;

interface

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
  CommonDBSupport,
  UnitINI,

  Dmitry.CRC32,
  Dmitry.Utils.Files,
  Dmitry.Utils.System,

  uMemory,
  uShellIntegration,
  uDBScheme,
  uLogger,
  uConstants,
  uTime,
  uCollectionEvents,
  uSplashThread,
  uShellUtils,
  uAppUtils,
  uTranslate,
  uDBForm,
  uGroupTypes,
  UnitGroupsWork,
  uRuntime,
  uStringUtils,
  uSettings,
  uProgramStatInfo,
  uVCLHelpers,
  uDBContext;

type
  TDBKernel = class(TObject)
  private
    { Private declarations }
    FDBContext: IDBContext;
    procedure HandleError(E: Exception);
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    class procedure AddDB(DBName, DBFile, DBIco: string);
    class procedure LoadDBs(Collections: TList<TDatabaseInfo>);
    class procedure SaveDBs(Collections: TList<TDatabaseInfo>);

    function CreateDBbyName(FileName: string): Integer;
    procedure SetDataBase(DatabaseFileName: string);
    procedure ReadDBOptions;
    function LoadDefaultCollection: Boolean;
    function CreateSampleDefaultCollection: string;
    function SelectDB(Caller: TDBForm; DB: string): Boolean;
    procedure CreateExampleDB(FileName: string);
  end;

var
  DBKernel: TDBKernel = nil;

implementation

{ TDBKernel }

constructor TDBKernel.Create;
begin
  inherited;
  FDBContext := nil;
end;

function TDBKernel.CreateDBbyName(FileName: string): Integer;
begin
  Result := 0;
  CreateDirA(ExtractFileDir(FileName));
  try
    if FileExistsSafe(FileName) then
      DeleteFile(FileName);

    if FileExistsSafe(FileName) then
    begin
      Result := 1;
      Exit;
    end;
    Result := 1;

    TDBScheme.CreateCollection(FileName);
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

procedure TDBKernel.CreateExampleDB(FileName: string);
var
  NewGroup: TGroup;
  ImagesDir: string;
begin
  DBKernel.CreateDBbyName(FileName);

  ImagesDir := ExtractFilePath(Application.ExeName) + 'Images\';
  if FileExists(ImagesDir + 'Me.jpg') then
  begin
    try
      NewGroup.GroupName := GetWindowsUserName;
      NewGroup.GroupCode := CreateNewGroupCode;
      NewGroup.GroupImage := TJPEGImage.Create;
      try
        NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Me.jpg');
        NewGroup.GroupDate := Now;
        NewGroup.GroupComment := '';
        NewGroup.GroupFaces := '';
        NewGroup.GroupAccess := 0;
        NewGroup.GroupKeyWords := NewGroup.GroupName;
        NewGroup.AutoAddKeyWords := True;
        NewGroup.RelatedGroups := '';
        NewGroup.IncludeInQuickList := True;
        AddGroupW(NewGroup, FileName);
      finally
        NewGroup.GroupImage.Free;
      end;
    except
      on E: Exception do
        EventLog(':CreateExampleDB() throw exception: ' + E.message);
    end;
  end;

  if FileExists(ImagesDir + 'Friends.jpg') then
  begin
    try
      NewGroup.GroupName := TA('Friends', 'Setup');
      NewGroup.GroupCode := CreateNewGroupCode;
      NewGroup.GroupImage := TJPEGImage.Create;
      try
        NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Friends.jpg');
        NewGroup.GroupDate := Now;
        NewGroup.GroupComment := '';
        NewGroup.GroupFaces := '';
        NewGroup.GroupAccess := 0;
        NewGroup.GroupKeyWords := TA('Friends', 'Setup');
        NewGroup.AutoAddKeyWords := True;
        NewGroup.RelatedGroups := '';
        NewGroup.IncludeInQuickList := True;
        AddGroupW(NewGroup, FileName);
      finally
        NewGroup.GroupImage.Free;
      end;
    except
      on E: Exception do
        EventLog(':CreateExampleDB() throw exception: ' + E.message);
    end;
  end;

  if FileExists(ImagesDir + 'Family.jpg') then
  begin
    try
      NewGroup.GroupName := TA('Family', 'Setup');
      NewGroup.GroupCode := CreateNewGroupCode;
      NewGroup.GroupImage := TJPEGImage.Create;
      try
        NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Family.jpg');
        NewGroup.GroupDate := Now;
        NewGroup.GroupComment := '';
        NewGroup.GroupFaces := '';
        NewGroup.GroupAccess := 0;
        NewGroup.GroupKeyWords := TA('Family', 'Setup');
        NewGroup.AutoAddKeyWords := True;
        NewGroup.RelatedGroups := '';
        NewGroup.IncludeInQuickList := True;
        AddGroupW(NewGroup, FileName);
      finally
        NewGroup.GroupImage.Free;
      end;
    except
      on E: Exception do
        EventLog(':CreateExampleDB() throw exception: ' + E.message);
    end;
  end;
end;

destructor TDBKernel.Destroy;
begin
  FDBContext := nil;
  inherited;
end;

function TDBKernel.SelectDB(Caller: TDBForm; DB: string): Boolean;
var
  EventInfo: TEventValues;
begin
  Result := False;
  if FileExists(DB) then
  begin
    if TDBScheme.IsValidCollectionFile(DB) then
    begin
      dbname := DB;
      DBKernel.SetDataBase(DB);
      EventInfo.FileName := dbname;
      CollectionEvents.DoIDEvent(Caller, 0, [EventID_Param_DB_Changed], EventInfo);
      Result := True;
      Exit;
    end
  end;
end;

procedure TDBKernel.SetDataBase(DatabaseFileName: string);
var
  Reg: TBDRegistry;
begin
  if not FileExistsSafe(DatabaseFileName) then
    Exit;

  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot, True);
    Reg.WriteString('DBDefaultName', DatabaseFileName);

    dbname := DatabaseFileName;
  finally
    F(Reg);
  end;
  ReadDBOptions;
end;

function TDBKernel.LoadDefaultCollection: Boolean;
var
  CollectionFileName: string;
begin
  if FolderView then
  begin
    CollectionFileName := ExtractFilePath(Application.ExeName) + 'FolderDB.photodb';

    if FileExistsSafe(ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb') then
      CollectionFileName := ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb';
  end else
  begin
    CollectionFileName := Settings.DataBase;

    if not FileExistsSafe(CollectionFileName) then
      CreateSampleDefaultCollection;
  end;

  FDBContext := TDBContext.Create(CollectionFileName);
  Result := FDBContext.IsValid;

  dbname := FDBContext.CollectionFileName;
end;

function TDBKernel.CreateSampleDefaultCollection: string;
begin
  //if program was uninstalled with registered databases - restore database or create new database
  Result := IncludeTrailingBackslash(GetMyDocumentsPath) + TA('My collection') + '.photodb';
  if not FileExistsSafe(Result) then
    CreateExampleDB(Result);

  DBKernel.AddDB(TA('My collection'), Result, Application.ExeName + ',0');
  DBKernel.SetDataBase(Result);
end;

class procedure TDBKernel.LoadDBs(Collections: TList<TDatabaseInfo>);
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

class procedure TDBKernel.SaveDBs(Collections: TList<TDatabaseInfo>);
var
  Reg: TBDRegistry;
  List: TStrings;
  I: Integer;
  DB: TDatabaseInfo;
  Settings: TImageDBOptions;
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
      begin
        Reg.CloseKey;
        Reg.OpenKey(RegRoot + 'dbs\' + DB.Title, True);
        Reg.WriteString('FileName', DB.Path);
        Reg.WriteString('Icon', DB.Icon);
        Reg.WriteString('Description', DB.Description);
        Reg.WriteInteger('Order', Collections.IndexOf(DB));

        Settings := CommonDBSupport.GetImageSettingsFromTable(DB.Path);
        try
          Settings.Name := DB.Title;
          Settings.Description := DB.Description;
          CommonDBSupport.UpdateImageSettings(DB.Path, Settings);
        finally
          F(Settings);
        end;
      end;

    finally
      F(Reg);
    end;
  finally
    F(List);
  end;
end;

class procedure TDBKernel.AddDB(DBName, DBFile, DBIco: string);
var
  Collections: TList<TDatabaseInfo>;
begin
  Collections := TList<TDatabaseInfo>.Create;
  try
    LoadDBs(Collections);
    Collections.Add(TDatabaseInfo.Create(DBName, DBFile, DBIco, ''));
    SaveDBs(Collections);
  finally
    FreeList(Collections);
  end;
end;

procedure TDBKernel.ReadDBOptions;
var
  FImageOptions: TImageDBOptions;
begin
  FImageOptions := CommonDBSupport.GetImageSettingsFromTable(DBName);
  try
    DBJpegCompressionQuality := FImageOptions.DBJpegCompressionQuality;
    ThSize := FImageOptions.ThSize + 2;
    ThImageSize := FImageOptions.ThSize;
    ThHintSize := FImageOptions.ThHintSize;
  finally
    F(FImageOptions);
  end;
end;

procedure TDBKernel.HandleError(E: Exception);
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
  F(DBKernel);

end.
