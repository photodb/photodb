unit UnitCDExportThread;

interface

uses
  Windows,
  Classes,
  Forms,
  DB,
  Graphics,
  ActiveX,
  SysUtils,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  UnitCDMappingSupport,
  UnitDBKernel,
  CommonDBSupport,

  uLogger,
  uConstants,
  uShellIntegration,
  uDBBaseTypes,
  uDBForm,
  uDBThread,
  uMobileUtils,
  uMemory,
  uDBEntities,
  uDBUtils,
  uDBContext,
  uCDMappingTypes,
  uTranslate,
  uResourceUtils,
  uDBShellUtils,
  uRuntime;

type
  TCDExportOptions = record
    ToDirectory: string;
    DeleteFiles: Boolean;
    ModifyDB: Boolean;
    CreatePortableDB: Boolean;
    OnEnd: TNotifyEvent;
  end;

type
  TCDExportThread = class(TDBThread)
  private
    { Private declarations }
    FContext: IDBContext;
    Mapping: TCDIndexMapping;
    Options: TCDExportOptions;
    DBRemapping: TDBFilePathArray;
    DS: TDataSet;
    ExtDS: TDataSet;
    DBUpdated: Boolean;
    CRC: Cardinal;
    FRegGroups: TGroups;
    FGroupsFounded: TGroups;
    IntParam, CopiedSize: Int64;
    StrParam: string;
    ProgressWindow: TForm;
    IsClosedParam: Boolean;
    FOwner: TDBForm;
    procedure CreateAutorunFile(Directory: string);
  protected
    { Protected declarations }
    procedure Execute; override;
    function GetThreadID: string; override;
  public
    { Public declarations }
    constructor Create(Owner: TDBForm; Context: IDBContext; AMapping: TCDIndexMapping; AOptions: TCDExportOptions);
    procedure DoErrorDeletingFiles;
    procedure ShowError;
    procedure DoOnEnd;
    procedure ShowCopyError;
    procedure CreatePortableDB;
    procedure InitializeProgress;
    procedure OnProgress(Sender: TObject; var Info: TProgressCallBackInfo);
    procedure SetProgressAsynch;
    procedure IfBreakOperation;
    procedure DestroyProgress;
    procedure SetProgressOperation;
    procedure SetMaxPosition;
    procedure SetPosition;
  end;

implementation

uses
  UnitSaveQueryThread,
  ProgressActionUnit;

{ TCDExportThread }

constructor TCDExportThread.Create(Owner: TDBForm; Context: IDBContext; AMapping: TCDIndexMapping; AOptions: TCDExportOptions);
begin
  inherited Create(Owner, False);
  FContext := Context;
  FOwner := Owner;
  Mapping := AMapping;
  Options := AOptions;
  IsClosedParam := False;
  CopiedSize := 0;
end;

procedure TCDExportThread.CreatePortableDB;
var
  NewIcon: TIcon;
  IcoTempName, ExeFileName: string;
  Language: Integer;
begin
  StrParam := IncludeTrailingBackslash(StrParam);
  ExeFileName := StrParam + Mapping.CDLabel + '.exe';
  CreateMobileDBFilesInDirectory(ExeFileName);

  if ID_YES = MessageBoxDB(GetForegroundWindow, TA('Do you want to change the icon for the final collection?', 'Mobile'), TA('Question'),
    TD_BUTTON_YESNO, TD_ICON_QUESTION) then
  begin
    NewIcon := TIcon.Create;
    try
      if GetIconForFile(NewIcon, IcoTempName, Language) then
      begin
        NewIcon.SaveToFile(IcoTempName);

        ReplaceIcon(StrParam, PChar(IcoTempName));

        if FileExistsSafe(IcoTempName) then
          DeleteFile(IcoTempName);

      end;
    finally
      F(NewIcon);
    end;
  end;
end;

procedure TCDExportThread.DoErrorDeletingFiles;
begin
  MessageBoxDB(Handle, L('Unable to delete original files! Check if you have right to delete the files. Please try again later manually delete these files.'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
end;

procedure TCDExportThread.DoOnEnd;
begin
  Options.OnEnd(Self);
end;

procedure TCDExportThread.InitializeProgress;
begin
  ProgressWindow := GetProgressWindow(True);
  with ProgressWindow as TProgressActionForm do
  begin
    CanClosedByUser := True;
    OneOperation := False;
    OperationCount := 4;
    OperationPosition := 1;
    MaxPosCurrentOperation := IntParam;
    XPosition := 0;
    Show;
  end;
end;

procedure TCDExportThread.CreateAutorunFile(Directory: string);
var
  FS: TFileStream;
  SW: TStreamWriter;
begin
  try
    FS := TFileStream.Create(Directory + Mapping.CDLabel + '\AutoRun.inf', FmOpenWrite or FmCreate);
    try
      SW := TStreamWriter.Create(FS);
      try
        SW.Write('[autorun]');
        SW.WriteLine;
        SW.Write('icon=' + Mapping.CDLabel + '.exe,0');
        SW.WriteLine;
        SW.Write('open=' + Mapping.CDLabel + '.exe');
        SW.WriteLine;
      finally
        F(SW);
      end;
    finally
      F(FS);
    end
  except
    on E: Exception do
    begin
      EventLog(':TCDExportThread::Execute()/ExtDS.Open throw exception: ' + E.message);
      StrParam := E.message;
      Synchronize(ShowError);
    end;
  end;
end;

procedure TCDExportThread.Execute;
var
  I, J: Integer;
  S, Directory, DestinationCollectionPath: string;
  ImageSettings: TSettings;
  FDestination: IDBContext;
  SettingsRSrc, SettingsRDest: ISettingsRepository;
  GroupsRSrc, GroupsRDest: IGroupsRepository;
begin
  inherited;
  FreeOnTerminate := True;
  try
    CoInitializeEx(nil, COM_MODE);
    try
      IntParam := Mapping.GetCDSize;
      Synchronize(InitializeProgress);
      try
        Options.ToDirectory := IncludeTrailingBackslash(Options.ToDirectory);
        IntParam := 1;
        Synchronize(SetProgressOperation);

        if not Mapping.CreateStructureToDirectory(Options.ToDirectory, OnProgress) then
        begin
          Synchronize(ShowCopyError);
          Exit;
        end;

        Mapping.PlaceMapFile(Options.ToDirectory);
        CreateAutorunFile(Options.ToDirectory);

        IntParam := 2;
        Synchronize(SetProgressOperation);
        IntParam := 0;
        Synchronize(SetPosition);

        if not IsClosedParam and Options.DeleteFiles then
          if not Mapping.DeleteOriginalStructure(OnProgress) then
            Synchronize(DoErrorDeletingFiles);

        IntParam := 3;
        Synchronize(SetProgressOperation);

        Directory := ExtractFileDir(Options.ToDirectory);
        Directory := IncludeTrailingBackslash(Directory) + Mapping.CDLabel + '\';

        if not IsClosedParam and Options.CreatePortableDB then
        begin
          StrParam := Directory;
          Synchronize(CreatePortableDB);
          DestinationCollectionPath := Directory + Mapping.CDLabel + '.photodb';
          if DBKernel.CreateDBbyName(DestinationCollectionPath) = 0 then
          begin
            FDestination := TDBContext.Create(DestinationCollectionPath);

            SettingsRSrc := FContext.Settings;
            SettingsRDest := FDestination.Settings;

            ImageSettings := SettingsRSrc.Get;
            try
              SettingsRDest.Update(ImageSettings);
            finally
              F(ImageSettings);
            end;

            DBRemapping := Mapping.GetDBRemappingArray;
            ExtDS := GetTable(DestinationCollectionPath, DB_TABLE_IMAGES);

            try
              ExtDS.Open;
            except
              on E: Exception do
              begin
                EventLog(':TCDExportThread::Execute()/ExtDS.Open throw exception: ' + E.message);
                StrParam := E.message;
                Synchronize(ShowError);
              end;
            end;
            if ExtDS.Active then
            begin
              DS := FContext.CreateQuery;
              DBUpdated := True;

              IntParam := Length(DBRemapping) - 1;
              Synchronize(SetMaxPosition);

              for I := 0 to Length(DBRemapping) - 1 do
              begin
                IntParam := I;
                Synchronize(SetPosition);
                if IsClosedParam then
                  Break;

                SetSQL(DS, 'Select * from $DB$  Where ID = :ID');
                SetIntParam(DS, 0, DBRemapping[I].ID);
                try
                  DS.Open;
                except
                  Break;
                end;
                if DS.RecordCount = 1 then
                begin
                  ExtDS.Append;

                  S := DBRemapping[I].FileName;
                  Delete(S, 1, Length(Mapping.CDLabel) + 5);

                  CopyRecordsW(DS, ExtDS, True, True, S, FGroupsFounded);
                  ExtDS.Post;
                end;

              end;
              FreeDS(DS);
            end;
            FreeDS(ExtDS);
          end;

          Directory := ExtractFilePath(Options.ToDirectory);
          Directory := Directory + Mapping.CDLabel + '\';

          GroupsRSrc := FContext.Groups;
          GroupsRDest := FDestination.Groups;

          FRegGroups := GroupsRSrc.GetAll(True, True);
          try
            IntParam := FGroupsFounded.Count - 1;
            Synchronize(SetMaxPosition);
            for I := 0 to FGroupsFounded.Count - 1 do
            begin
              IntParam := I;
              Synchronize(SetPosition);
              if IsClosedParam then
                Break;

              for J := 0 to FRegGroups.Count - 1 do
                if FRegGroups[J].GroupCode = FGroupsFounded[I].GroupCode then
                begin
                  GroupsRDest.Add(FRegGroups[J]);
                  Break;
                end;
            end;
          finally
            F(FRegGroups);
          end;
        end;

        IntParam := 4;
        Synchronize(SetProgressOperation);

        if not IsClosedParam and Options.ModifyDB then
        begin
          DBRemapping := Mapping.GetDBRemappingArray;
          DS := FContext.CreateQuery;
          try
            DBUpdated := True;
            IntParam := Length(DBRemapping) - 1;
            Synchronize(SetMaxPosition);
            for I := 0 to Length(DBRemapping) - 1 do
            begin
              IntParam := I;
              Synchronize(SetPosition);
              if IsClosedParam then
                Break;

              Directory := ExtractFileDir(DBRemapping[I].FileName);
              CalcStringCRC32(AnsiLowerCase(Directory), Crc);

              SetSQL(DS, 'Update $DB$ Set FFileName = :FileName, FolderCRC = :FolderCRC Where ID = :ID');
              SetStrParam(DS, 0, DBRemapping[I].FileName);
              SetIntParam(DS, 1, Integer(Crc));
              SetIntParam(DS, 2, DBRemapping[I].ID);
              try
                ExecSQL(DS);
              except
                DBUpdated := False;
              end;
            end;
          finally
            FreeDS(DS);
          end;
        end;

        TryRemoveConnection(DestinationCollectionPath, True);
      finally
        Synchronize(DestroyProgress);
      end;
    finally
      Synchronize(DoOnEnd);
      CoUninitialize;
    end;
  except
    on E: Exception do
    begin
      EventLog(':TCDExportThread::Execute() throw exception: ' + E.message);
      StrParam := E.message;
      Synchronize(ShowError);
    end;
  end;
end;

function TCDExportThread.GetThreadID: string;
begin
  Result := 'CDExport';
end;

procedure TCDExportThread.ShowCopyError;
begin
  MessageBoxDB(FOwner.Handle, L('Unable to copy files to the final location! Check if there are write permissions to the specified directory!'), L('Warning'), TD_BUTTON_OK,
    TD_ICON_WARNING);
end;

procedure TCDExportThread.ShowError;
begin
  MessageBoxDB(FOwner.Handle, Format(L('An unexpected error occurred: %s'), [StrParam]), L('Error'),
    TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TCDExportThread.OnProgress(Sender: TObject; var Info: TProgressCallBackInfo);
begin
  CopiedSize := CopiedSize + Info.Position;
  Synchronize(SetProgressAsynch);
  Info.Terminate := IsClosedParam;
end;

procedure TCDExportThread.SetProgressAsynch;
begin
  with ProgressWindow as TProgressActionForm do
  begin
    XPosition := CopiedSize;
  end;
  IfBreakOperation;
end;

procedure TCDExportThread.DestroyProgress;
begin
  (ProgressWindow as TProgressActionForm).WindowCanClose := True;
  ProgressWindow.Release;
end;

procedure TCDExportThread.IfBreakOperation;
begin
  IsClosedParam := (ProgressWindow as TProgressActionForm).Closed;
end;

procedure TCDExportThread.SetProgressOperation;
begin
  (ProgressWindow as TProgressActionForm).OperationPosition := IntParam;
end;

procedure TCDExportThread.SetMaxPosition;
begin
  (ProgressWindow as TProgressActionForm).MaxPosCurrentOperation := IntParam;
end;

procedure TCDExportThread.SetPosition;
begin
  (ProgressWindow as TProgressActionForm).XPosition := IntParam;
end;

end.
