unit UnitSaveQueryThread;

interface

uses
  Windows, SysUtils, UnitGroupsWork, UnitExportThread, Classes, DB, Dolphin_DB,
  CommonDBSupport, Forms, win32crc, ActiveX, acWorkRes, Graphics, Dialogs,
  acDlgSelect, uVistaFuncs, UnitDBDeclare, uFileUtils, uConstants, uDBUtils,
  uShellIntegration, UnitDBKernel, uDBBaseTypes, uMemory, uTranslate,
  uDBThread, uResourceUtils, uThreadForm, uThreadEx, uMobileUtils;

type
  TSaveQueryThread = class(TThreadEx)
  private
    { Private declarations }
    FDestinationPath, DBFolder: string;
    FIntParam: Integer;
    FRegGroups: TGroups;
    FGroupsFounded: TGroups;
    FSubFolders: Boolean;
    FFileList: TStrings;
    SaveToDBName: string;
    NewIcon: TIcon;
    OutIconName: string;
    OriginalIconLanguage: Integer;
  protected
    { Protected declarations }
    function GetThreadID : string; override;
    procedure Execute; override;
    procedure SetMaxValue(Value : integer);
    procedure SetMaxValueA;
    procedure SetProgress(Value : integer);
    procedure SetProgressA;
    Procedure Done;
    procedure LoadCustomDBName;
    procedure ReplaceIconAction;  
    procedure SaveLocation(Src, Dest: TDataSet);
  public
    { Public declarations }
    constructor Create(DestinationPath : String; OwnerForm : TThreadForm; 
                       SubFolders : boolean; FileList : TStrings; State: TGUID);
    destructor Destroy; override;
  end;

implementation

uses UnitSavingTableForm, UnitStringPromtForm;

{ TSaveQueryThread }

constructor TSaveQueryThread.Create(DestinationPath: string; OwnerForm: TThreadForm;
  SubFolders: Boolean; FileList: TStrings; State: TGUID);
begin
  inherited Create(OwnerForm, State);
  FSubFolders := SubFolders;
  FDestinationPath := DestinationPath;
  FFileList := TStringList.Create;
  FFileList.Assign(FileList);
end;

destructor TSaveQueryThread.Destroy;
begin
  F(FFileList);
  inherited;
end;

procedure TSaveQueryThread.Done;
begin
  ThreadForm.OnCloseQuery := nil;
  ThreadForm.Close;
end;

procedure LoadLocation(Query: TDataSet; Location: string; WithSubflders: Boolean);
var
  LocationFolder: string; 
  AndWhere, FromSQL: string; 
  Crc: Cardinal;
begin
  if FileExistsSafe(Location) then
    LocationFolder := ExtractFileDir(Location)
  else
    LocationFolder := Location;

  LocationFolder := ExcludeTrailingBackslash(LocationFolder);

  if not WithSubflders then
  begin
    AndWhere := ' and not (FFileName like :FolderB) ';
    CalcStringCRC32(AnsiLowerCase(LocationFolder), Crc);
    FromSQL := '(Select * from $DB$ where FolderCRC=' + Inttostr(Integer(Crc)) + ')';
  end else
  begin
    FromSQL := '$DB$';
    AndWhere := '';
  end;

  SetSQL(Query, 'Select * From ' + FromSQL + ' where (FFileName Like :FolderA)' + AndWhere);

  LocationFolder := IncludeTrailingBackslash(LocationFolder);
  if FileExistsSafe(Location) then
    SetStrParam(Query, 0, '%' + AnsiLowerCase(Location) + '%')
  else
    SetStrParam(Query, 0, '%' + LocationFolder + '%');
  if not WithSubflders then
    SetStrParam(Query, 1, '%' + LocationFolder + '%\%');

  Query.Active := True;
end;

procedure TSaveQueryThread.SaveLocation(Src, Dest: TDataSet);
begin
  if not Src.Eof then
  begin
    SetMaxValue(Src.RecordCount);
    Src.First;
    repeat
      if IsTerminated then
        Break;
      Dest.Append;
      CopyRecordsW(Src, Dest, True, DBFolder, FGroupsFounded);
      Dest.Post;
      SetProgress(Src.RecNo);
      Src.Next;
    until Src.Eof;
  end;
end;

procedure TSaveQueryThread.Execute;
var
  I, J: Integer;
  FDBFileName,
  FExeFileName: string;
  ImageSettings: TImageDBOptions;
  FQuery: TDataSet;
  FTable: TDataSet;
begin
  FreeOnTerminate := True;
  try
    CoInitialize(nil);
    try
      SaveToDBName := GetFileNameWithoutExt(FDestinationPath);
      if SaveToDBName <> '' then
        if Length(SaveToDBName) > 1 then
          if SaveToDBName[2] = ':' then
            SaveToDBName := SaveToDBName[1] + '_drive';
      SynchronizeEx(LoadCustomDBName);

      FDestinationPath := IncludeTrailingBackslash(FDestinationPath);

      FDBFileName := FDestinationPath + SaveToDBName + '.photodb';
      if DBKernel.CreateDBbyName(FDBFileName) <> 0 then
        Exit;

      ImageSettings := CommonDBSupport.GetImageSettingsFromTable(DBName);
      CommonDBSupport.UpdateImageSettings(FDBFileName, ImageSettings);

      FTable := GetTable(FDBFileName, DB_TABLE_IMAGES);

      try
        FTable.Active := True;

        DBFolder := ExtractFilePath(FDBFileName);

        Setlength(FGroupsFounded, 0);

        for I := 0 to FFileList.Count - 1 do
        begin
          FQuery := GetQuery;
          try
            LoadLocation(FQuery, FFileList[I], FSubFolders);
            SaveLocation(FQuery, FTable);
          finally
            FreeDS(FQuery);
          end;
        end;

        SetMaxValue(Length(FGroupsFounded));
        FRegGroups := GetRegisterGroupList(True);
        try
          CreateGroupsTableW(GroupsTableFileNameW(FDBFileName));

          for I := 0 to Length(FGroupsFounded) - 1 do
          begin
            if IsTerminated then
              Break;
            SetProgress(I);
            for J := 0 to Length(FRegGroups) - 1 do
              if FRegGroups[J].GroupCode = FGroupsFounded[I].GroupCode then
              begin
                AddGroupW(FRegGroups[J], GroupsTableFileNameW(ExtractFilePath(FDBFileName) + SaveToDBName + '.photodb'));
                Break;
              end;
          end;
        finally
          FreeGroups(FRegGroups);
        end;
      finally
        FreeDS(FTable);
      end;
      TryRemoveConnection(FDBFileName, True);

      FExeFileName := ExtractFilePath(FDBFileName) + SaveToDBName + '.exe';
      CopyFile(PChar(Application.Exename), PChar(FExeFileName), False);
      UpdateExeResources(FExeFileName);

      NewIcon := TIcon.Create;
      try
        SynchronizeEx(ReplaceIconAction);
        if not NewIcon.Empty then
        begin
          NewIcon.SaveToFile(OutIconName);
          F(NewIcon);

          ReplaceIcon(FExeFileName, PWideChar(OutIconName));

          if FileExistsSafe(OutIconName) then
            DeleteFile(OutIconName);

        end;
      finally
        F(NewIcon);
      end;

    finally
      CoUninitialize;
    end;
  finally
    SynchronizeEx(Done);
  end;
end;

function TSaveQueryThread.GetThreadID: string;
begin
  Result := 'Mobile';
end;

procedure TSaveQueryThread.SetMaxValue(Value: Integer);
begin
  FIntParam := Value;
  SynchronizeEx(SetMaxValueA);
end;

procedure TSaveQueryThread.SetMaxValueA;
begin
  TSavingTableForm(ThreadForm).DmProgress1.MaxValue := FIntParam;
end;

procedure TSaveQueryThread.SetProgress(Value: Integer);
begin
  FIntParam := Value;
  SynchronizeEx(SetProgressA);
end;

procedure TSaveQueryThread.SetProgressA;
begin
  TSavingTableForm(ThreadForm).DmProgress1.Position := FIntParam;
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
  if ID_YES = MessageBoxDB(GetActiveFormHandle, TA('Do you want to change the icon for the final collection?', 'Mobile'), TA('Question'),
    TD_BUTTON_YESNO, TD_ICON_QUESTION) then
    GetIconForFile(NewIcon, OutIconName, OriginalIconLanguage);
end;

end.
