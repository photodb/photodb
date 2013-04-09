unit UnitSaveQueryThread;

interface

uses
  Windows,
  SysUtils,
  Classes,
  DB,
  ActiveX,
  Graphics,
  Forms,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  CommonDBSupport,
  UnitDBKernel,

  uConstants,
  uDBUtils,
  uShellIntegration,
  uMemory,
  uTranslate,
  uDBThread,
  uDBContext,
  uDBEntities,
  uResourceUtils,
  uThreadForm,
  uThreadEx,
  uMobileUtils,
  uTime,
  uLogger,
  uDBShellUtils,
  uRuntime,
  uProgramStatInfo,
  uFormInterfaces;

type
  TSaveQueryThread = class(TThreadEx)
  private
    { Private declarations }
    FDBContext: IDBContext;
    FDestinationPath, DBFolder: string;
    FIntParam: Integer;
    FRegGroups: TGroups;
    FGroupsFound: TGroups;
    FSubFolders: Boolean;
    FFileList: TStrings;
    SaveToDBName: string;
    NewIcon: TIcon;
    OutIconName: string;
    OriginalIconLanguage: Integer;
  protected
    { Protected declarations }
    function GetThreadID: string; override;
    procedure Execute; override;
    procedure SetMaxValue(Value: integer);
    procedure SetMaxValueA;
    procedure SetProgress(Value: integer);
    procedure SetProgressA;
    Procedure Done;
    procedure LoadCustomDBName;
    procedure ReplaceIconAction;  
    procedure SaveLocation(Src, Dest: TDataSet);
  public
    { Public declarations }
    constructor Create(DBContext: IDBContext; DestinationPath : String; OwnerForm: TThreadForm;
                       SubFolders: boolean; FileList: TStrings; State: TGUID);
    destructor Destroy; override;
  end;

implementation

uses
  UnitSavingTableForm;

{ TSaveQueryThread }

constructor TSaveQueryThread.Create(DBContext: IDBContext;DestinationPath: string; OwnerForm: TThreadForm;
  SubFolders: Boolean; FileList: TStrings; State: TGUID);
begin
  inherited Create(OwnerForm, State);
  FDBContext := DBContext;
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
      CopyRecordsW(Src, Dest, True, False, DBFolder, FGroupsFound);
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
  ImageSettings: TSettings;
  FQuery: TDataSet;
  FTable: TDataSet;
  Destination: IDBContext;
  SettingsRSrc, SettingsRDest: ISettingsRepository;
  GroupsSrc, GroupsDest: IGroupsRepository;
begin
  inherited;
  FreeOnTerminate := True;
  try
    try
      CoInitializeEx(nil, COM_MODE);
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

        Destination := TDBContext.Create(FDBFileName);

        SettingsRSrc := FDBContext.Settings;
        SettingsRDest := Destination.Settings;
        ImageSettings := SettingsRSrc.Get;
        try
          SettingsRDest.Update(ImageSettings);
        finally
          F(ImageSettings);
        end;

        GroupsSrc := FDBContext.Groups;
        GroupsDest := Destination.Groups;

        FTable := GetTable(FDBFileName, DB_TABLE_IMAGES);
        try
          FTable.Active := True;

          DBFolder := ExtractFilePath(FDBFileName);

          FGroupsFound := TGroups.Create;
          try
            for I := 0 to FFileList.Count - 1 do
            begin
              FQuery := FDBContext.CreateQuery;
              try
                LoadLocation(FQuery, FFileList[I], FSubFolders);
                SaveLocation(FQuery, FTable);
              finally
                FreeDS(FQuery);
              end;
            end;

            //statistics
            ProgramStatistics.PortableUsed;

            SetMaxValue(FGroupsFound.Count);
            FRegGroups := GroupsSrc.GetAll(True, True);
            try
              for I := 0 to FGroupsFound.Count - 1 do
              begin
                if IsTerminated then
                  Break;
                SetProgress(I);
                for J := 0 to FRegGroups.Count - 1 do
                  if FRegGroups[J].GroupCode = FGroupsFound[I].GroupCode then
                  begin
                    GroupsDest.Add(FRegGroups[J]);
                    Break;
                  end;
              end;
            finally
              F(FRegGroups);
            end;
          finally
            F(FGroupsFound);
          end;
        finally
          FreeDS(FTable);
        end;
        TryRemoveConnection(Destination.CollectionFileName, True);

        TW.I.Check('Copy File');

        FExeFileName := ExtractFilePath(FDBFileName) + SaveToDBName + '.exe';

        CopyFile(PChar(Application.Exename), PChar(FExeFileName), False);
        TW.I.Check('Update File Resources');
        UpdateExeResources(FExeFileName);

        TW.I.Check('Change File Icon');
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
  except
    on e: Exception do
    begin
      MessageBoxDB(0, E.Message, TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      EventLog(e);
    end;
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
  if StringPromtForm.Query(L('Collection name'), L('Please enter name for new collection') + ':', S) then
    if S <> '' then
      SaveToDBName := S;
end;

procedure TSaveQueryThread.ReplaceIconAction;
begin
  if ID_YES = MessageBoxDB(0, TA('Do you want to change the icon for the final collection?', 'Mobile'), TA('Question'),
    TD_BUTTON_YESNO, TD_ICON_QUESTION) then
    GetIconForFile(NewIcon, OutIconName, OriginalIconLanguage);
end;

end.
