unit UnitSaveQueryThread;

interface

uses
  Windows, SysUtils, UnitGroupsWork, UnitExportThread, Classes, DB, Dolphin_DB,
  CommonDBSupport, Forms, win32crc, ActiveX, acWorkRes, Graphics, Dialogs,
  acDlgSelect, uVistaFuncs, UnitDBDeclare, uFileUtils, uConstants,
  uShellIntegration, UnitDBKernel, uDBBaseTypes, uMemory, uTranslate,
  uDBThread;

type
  TSaveQueryThread = class(TDBThread)
  private
    { Private declarations }
    FQuery: TDataSet;
    FTable: TDataSet;
    FFileName, DBFolder: string;
    FIntParam: Integer;
    FOwner: TForm;
    FRegGroups: TGroups;
    FGroupsFounded: TGroups;
    FolderSave: Boolean;
    FSubFolders: Boolean;
    FFileList: TArStrings;
    SaveToDBName: string;
    NewIcon: TIcon;
    OutIconName: string;
    OriginalIconLanguage: Integer;
  protected
    function GetThreadID : string; override;
    procedure Execute; override;
    procedure SetMaxValue(Value : integer);
    procedure SetMaxValueA;
    procedure SetProgress(Value : integer);
    procedure SetProgressA;
    Procedure Done;
    procedure CopyRecordsW(OutTable, InTable: TDataSet);
    procedure LoadCustomDBName;
    procedure ReplaceIconAction;
  public
    constructor Create(CreateSuspennded: Boolean; Query : TDataSet; FileName : String; OwnerForm : TForm; SubFolders : boolean; FileList : TArStrings);
    Destructor Destroy; override;
  end;

function CreateMobileDBFIlesInDirectory(Directory, SaveToDBName: string): Boolean;

implementation

uses UnitSavingTableForm, UnitStringPromtForm;

{ TSaveQueryThread }

function C_GetTempPath: string;
var
  Buffer: array [0 .. 1023] of Char;
begin
  SetString(Result, Buffer, GetTempPath(Sizeof(Buffer) - 1, Buffer));
end;

function C_GetTempPathIco: string;
begin
  Result := C_GetTempPath + '\$temp$.ico';
end;

function ReplaceIconForFileQuestion(out IcoTempName: string; out Language: Integer): TIcon;
var
  LoadIconDLG: TOpenDialog;
  FN: string;
  index: Integer;
  ResIcoNameW: PWideChar;
  Update: DWORD;
  Ig: TPIconGroup;

  function FindIconEx(FileName: string; index: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    try
      Update := BeginUpdateResourceW(PChar(FileName), False, False);
      if Update = 0 then
      begin
        Exit;
      end;
      ResIcoNameW := GetNameIcon(Update, index);
      Language := -1;
      Ig := nil;
      for I := 0 to $FFFFF do
      begin
        if GetIconGroupResourceW(Update, ResIcoNameW, I, Ig) then
        begin
          Language := I;
          Break;
        end;
        if Ig <> nil then
        begin
          FreeMem(Ig);
          Ig := nil;
        end;
      end;
      if Language <> 0 then
        SaveIconGroupResourceW(Update, ResIcoNameW, Language, PWideChar(IcoTempName))
      else
      begin
        EndUpdateResourceW(Update, True);
        Exit;
      end;
      EndUpdateResourceW(Update, True);
    except
      Exit;
    end;
    Result := True;
  end;

begin
  Result := nil;
  if ID_YES = MessageBoxDB(GetActiveFormHandle, TA('Do you want to change the icon for the ultimate database?', 'Mobile'), TA('Question'),
    TD_BUTTON_YESNO, TD_ICON_QUESTION) then
  begin
    LoadIconDLG := TOpenDialog.Create(nil);
    LoadIconDLG.Filter := TA('All supported formats|*.exe;*.ico;*.dll;*.ocx;*.scr|Icons (*.ico)|*.ico|Executable files (*.exe)|*.exe|Dll files (*.dll)|*.dll', 'Mobile');
    if LoadIconDLG.Execute then
    begin
      FN := LoadIconDLG.FileName;
      if GetEXT(FN) = 'ICO' then
      begin
        Result := TIcon.Create;
        Result.LoadFromFile(FN);
      end;
      if (GetEXT(FN) = 'EXE') or (GetEXT(FN) = 'DLL') or (GetEXT(FN) = 'OCX') or (GetEXT(FN) = 'SCR') then
      begin
        if ChangeIconDialog(Application.Handle, FN, index) then
        begin
          IcoTempName := C_GetTempPathIco + IntToStr(Random(10000000)) + '.ico';
          FindIconEx(FN, index);
          Result := TIcon.Create;
          Result.LoadFromFile(IcoTempName);
          DeleteFile(IcoTempName);
        end;
      end;
    end;
  end;
end;

function ReplaceIcon(FileName: string; IcoTempNameW: PWideChar; OriginalIconLanguage: Integer): Boolean;
var
  Update: DWORD;
  ResIcoNameW: PWideChar;
begin
  Result := False;
  try
    Update := BeginUpdateResourceW(PChar(FileName), False);
    ResIcoNameW := GetNameIcon(Update, 0);
    if not LoadIconGroupResourceW(Update, ResIcoNameW, OriginalIconLanguage, IcoTempNameW) then
    begin
      EndUpdateResourceW(Update, False);
      Exit;
    end;
    EndUpdateResourceW(Update, False);
  except
    Exit;
  end;
  Result := True;
end;

function CreateMobileDBFilesInDirectory(Directory, SaveToDBName  : string) : boolean;
var
  NewIcon : TIcon;
  IcoTempName : string;
  Language : integer;
begin
  Directory := IncludeTrailingBackslash(Directory);
  CopyFile(PChar(Application.Exename), PChar(Directory + SaveToDBName + '.exe'), False);

  NewIcon := nil;
  try
    NewIcon := ReplaceIconForFileQuestion(IcoTempName, Language);
    if NewIcon <> nil then
    begin
      NewIcon.SaveToFile(IcoTempName);

      ReplaceIcon(Directory + SaveToDBName + '.exe', PChar(IcoTempName), Language);

      if FileExistsSafe(IcoTempName) then
        DeleteFile(IcoTempName);

    end;
  finally
    F(NewIcon);
  end;
  Result := True;
end;

constructor TSaveQueryThread.Create(CreateSuspennded: Boolean; Query: TDataSet; FileName: string; OwnerForm: TForm;
  SubFolders: Boolean; FileList: TArStrings);
begin
  inherited Create(False);
  FSubFolders := SubFolders;
  FolderSave := False;
  FFileName := FileName;
  Fowner := OwnerForm;
  FFileList := FileList;
  if Query <> nil then
    FQuery := GetQuery;
  FTable := nil;
  if Query <> nil then
    AssingQuery(Query, FQuery)
  else
    FolderSave := True;
end;

destructor TSaveQueryThread.Destroy;
begin

 inherited;
end;

procedure TSaveQueryThread.Done;
begin
  FOwner.OnCloseQuery := nil;
  FOwner.Close;
end;

procedure TSaveQueryThread.Execute;
var
  i, j : integer;
  AndWhere, FromSQL : string;
  crc : Cardinal;
  ImageSettings : TImageDBOptions;

  procedure DoExit;
  begin
    CoUninitialize;
    try
      FreeDS(FQuery);
      if FTable <> nil then
        FreeDS(FTable);
    except
    end;
    Synchronize(Done);
  end;

  procedure LoadLocation(Location: string);
  var
    LocationFolder: string;
  begin
    if FileExistsSafe(Location) then
      LocationFolder := ExtractFileDir(Location)
    else
      LocationFolder := Location;

    LocationFolder := ExcludeTrailingBackslash(LocationFolder);
    FQuery := GetQuery;
    if not FSubFolders then
    begin
      AndWhere := ' and not (FFileName like :FolderB) ';
      CalcStringCRC32(AnsiLowerCase(LocationFolder), Crc);
      FromSQL := '(Select * from $DB$ where FolderCRC=' + Inttostr(Integer(Crc)) + ')';
    end
    else
    begin
      FromSQL := '$DB$';
      AndWhere := '';
    end;
    if GetDBType = DB_TYPE_MDB then
      SetSQL(FQuery, 'Select * From ' + FromSQL + ' where (FFileName Like :FolderA)' + AndWhere);

    LocationFolder := IncludeTrailingBackslash(LocationFolder);
    if FileExistsSafe(Location) then
      SetStrParam(FQuery, 0, '%' + AnsiLowerCase(Location) + '%')
    else
      SetStrParam(FQuery, 0, '%' + LocationFolder + '%');
    if not FSubFolders then
      SetStrParam(FQuery, 1, '%' + LocationFolder + '%\%');
  end;

  procedure SaveLocation;
  begin
    try
      FQuery.Active := True;
    except
      DoExit;
      Exit;
    end;
    SetMaxValue(FQuery.RecordCount);
    FQuery.First;
    repeat
      if (FOwner as TSavingTableForm).FTerminating then
        Break;
      FTable.Append;
      CopyRecordsW(FQuery, FTable);
      FTable.Post;
      SetProgress(FQuery.RecNo);
      FQuery.Next;
    until FQuery.Eof;
  end;

begin
  FreeOnTerminate := True;

  RandomIze;
  CoInitialize(nil);
  SaveToDBName := GetFileNameWithoutExt(FFileName);
  if SaveToDBName <> '' then
    if Length(SaveToDBName) > 1 then
      if SaveToDBName[2] = ':' then
        SaveToDBName := SaveToDBName[1] + '_drive';
  Synchronize(LoadCustomDBName);
  if FQuery = nil then
    FFileName := IncludeTrailingBackslash(FFileName);
  if FQuery = nil then
    if DBKernel.CreateDBbyName(FFileName + SaveToDBName + '.photodb') <> 0 then
    begin
      DoExit;
      Exit;
    end;

  ImageSettings := CommonDBSupport.GetImageSettingsFromTable(DBName);
  CommonDBSupport.UpdateImageSettings(FFileName + SaveToDBName + '.photodb', ImageSettings);

  if FQuery <> nil then
    if DBKernel.CreateDBbyName(FFileName) <> 0 then
    begin
      DoExit;
      Exit;
    end;

  if FQuery <> nil then
    FTable := GetTable(FFileName, DB_TABLE_IMAGES)
  else
    FTable := GetTable(ExtractFilePath(FFileName) + SaveToDBName + '.photodb', DB_TABLE_IMAGES);

  try
    FTable.Active := True;
  except
    DoExit;
    Exit;
  end;

  if FileExistsSafe(FFileName) then
    DBFolder := ExtractFilePath(FFileName)
  else
    DBFolder := FFileName;

  Setlength(FGroupsFounded, 0);

  if FQuery = nil then
  begin
    for I := 0 to Length(FFileList) - 1 do
    begin
      LoadLocation(FFileList[I]);
      SaveLocation;
    end;
  end
  else
  begin
    SaveLocation;
  end;

  SetMaxValue(Length(FGroupsFounded));
  FRegGroups := GetRegisterGroupList(True);
  CreateGroupsTableW(GroupsTableFileNameW(ExtractFilePath(FFileName) + SaveToDBName + '.photodb'));

  for I := 0 to Length(FGroupsFounded) - 1 do
  begin
    if (FOwner as TSavingTableForm).FTerminating then
      Break;
    SetProgress(I);
    for J := 0 to Length(FRegGroups) - 1 do
      if FRegGroups[J].GroupCode = FGroupsFounded[I].GroupCode then
      begin
        AddGroupW(FRegGroups[J], GroupsTableFileNameW(ExtractFilePath(FFileName) + SaveToDBName + '.photodb'));
        Break;
      end;
  end;

  if FolderSave then
  begin
    FFileName := IncludeTrailingBackslash(FFileName);
    CopyFile(PChar(Application.Exename), PChar(ExtractFilePath(FFileName) + SaveToDBName + '.exe'), False);
    try
      Synchronize(ReplaceIconAction);
      if NewIcon <> nil then
      begin

        NewIcon.SaveToFile(OutIconName);
        NewIcon.Free;

        ReplaceIcon(ExtractFilePath(FFileName) + SaveToDBName + '.exe', PWideChar(OutIconName),
          OriginalIconLanguage);
        try
          if FileExistsSafe(OutIconName) then
            DeleteFile(OutIconName);
        except
        end;
      end;
    except
      DoExit;
      F(NewIcon);
      Exit;
    end;
  end;

  DoExit;
end;

function TSaveQueryThread.GetThreadID: string;
begin
  Result := 'Mobile';
end;

procedure TSaveQueryThread.SetMaxValue(Value: Integer);
begin
  FIntParam := Value;
  Synchronize(SetMaxValueA);
end;

procedure TSaveQueryThread.SetMaxValueA;
begin
  (FOwner as TSavingTableForm).DmProgress1.MaxValue := FIntParam;
end;

procedure TSaveQueryThread.SetProgress(Value: Integer);
begin
  FIntParam := Value;
  Synchronize(SetProgressA);
end;

procedure TSaveQueryThread.SetProgressA;
begin
  (FOwner as TSavingTableForm).DmProgress1.Position := FIntParam;
end;

procedure TSaveQueryThread.CopyRecordsW(OutTable, InTable: TDataSet);
var
  S, Folder: string;
  Crc: Cardinal;
begin
  InTable.FieldByName('Name').AsString := OutTable.FieldByName('Name').AsString;
  if FolderSave then
  begin
    // subfolder crc neened
    S := OutTable.FieldByName('FFileName').AsString;
    Delete(S, 1, Length(DBFolder));
    InTable.FieldByName('FFileName').AsString := S;

    if Pos('\', S) > 0 then
      Folder := ExtractFileDir(S)
    else
      Folder := '';

    CalcStringCRC32(Folder, Crc);
{$R-}
    InTable.FieldByName('FolderCRC').AsInteger := Crc;
{$R+}
  end else
  begin
    InTable.FieldByName('FFileName').AsString := OutTable.FieldByName('FFileName').AsString;
    if GetDBType = DB_TYPE_MDB then
      InTable.FieldByName('FolderCRC').AsInteger := OutTable.FieldByName('FolderCRC').AsInteger;
  end;
  InTable.FieldByName('Comment').AsString := OutTable.FieldByName('Comment').AsString;
  InTable.FieldByName('DateToAdd').AsDateTime := OutTable.FieldByName('DateToAdd').AsDateTime;
  InTable.FieldByName('Owner').AsString := OutTable.FieldByName('Owner').AsString;
  InTable.FieldByName('Rating').AsInteger := OutTable.FieldByName('Rating').AsInteger;
  InTable.FieldByName('Thum').AsVariant := OutTable.FieldByName('Thum').AsVariant;
  InTable.FieldByName('FileSize').AsInteger := OutTable.FieldByName('FileSize').AsInteger;
  InTable.FieldByName('KeyWords').AsString := OutTable.FieldByName('KeyWords').AsString;
  InTable.FieldByName('StrTh').AsString := OutTable.FieldByName('StrTh').AsString;
  if FileExistsSafe(InTable.FieldByName('FFileName').AsString) then
    InTable.FieldByName('Attr').AsInteger := Db_attr_norm
  else
    InTable.FieldByName('Attr').AsInteger := Db_attr_not_exists;
  InTable.FieldByName('Attr').AsInteger := OutTable.FieldByName('Attr').AsInteger;
  InTable.FieldByName('Collection').AsString := OutTable.FieldByName('Collection').AsString;
  if OutTable.FindField('Groups') <> nil then
  begin
    S := OutTable.FieldByName('Groups').AsString;
    AddGroupsToGroups(FGroupsFounded, EnCodeGroups(S));
    InTable.FieldByName('Groups').AsString := S;
  end;
  InTable.FieldByName('Groups').AsString := OutTable.FieldByName('Groups').AsString;
  InTable.FieldByName('Access').AsInteger := OutTable.FieldByName('Access').AsInteger;
  InTable.FieldByName('Width').AsInteger := OutTable.FieldByName('Width').AsInteger;
  InTable.FieldByName('Height').AsInteger := OutTable.FieldByName('Height').AsInteger;
  InTable.FieldByName('Colors').AsInteger := OutTable.FieldByName('Colors').AsInteger;
  InTable.FieldByName('Rotated').AsInteger := OutTable.FieldByName('Rotated').AsInteger;
  InTable.FieldByName('IsDate').AsBoolean := OutTable.FieldByName('IsDate').AsBoolean;
  if OutTable.FindField('Include') <> nil then
    InTable.FieldByName('Include').AsBoolean := OutTable.FieldByName('Include').AsBoolean;
  if OutTable.FindField('aTime') <> nil then
    InTable.FieldByName('aTime').AsDateTime := OutTable.FieldByName('aTime').AsDateTime;
  if OutTable.FindField('IsTime') <> nil then
    InTable.FieldByName('IsTime').AsBoolean := OutTable.FieldByName('IsTime').AsBoolean;
  if OutTable.FindField('Links') <> nil then
    InTable.FieldByName('Links').AsString := OutTable.FieldByName('Links').AsString;

end;

procedure TSaveQueryThread.LoadCustomDBName;
var
  S: string;
begin
  S := SaveToDBName;
  if PromtString(L('Collection name'), L('Please enter name for new collection') + ':', S) then
    if S <> '' then
      SaveToDBName := S;
end;

procedure TSaveQueryThread.ReplaceIconAction;
begin
  NewIcon := ReplaceIconForFileQuestion(OutIconName, OriginalIconLanguage);
end;

end.
