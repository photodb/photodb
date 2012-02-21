unit uThreadImportPictures;

interface

uses
  Generics.Collections,
  System.Classes,
  SysUtils,
  uMemory,
  Windows,
  uMemoryEx,
  Forms,
  Dolphin_DB,
  uPathUtils,
  uPathProviders,
  uExplorerFSProviders,
  uFormMoveFilesProgress,
  uSysUtils,
  uCounters,
  uFileUtils,
  Math,
  uPortableDeviceUtils,
  uConstants,
  uPortableClasses,
  uExplorerPortableDeviceProvider,
  uTranslate,
  uAssociations,
  uImportPicturesUtils,
  ActiveX,
  ComObj,
  uDBThread;

type
  TFileOperationTask = class
  private
    { Private declarations }
    FIsDirectory: Boolean;
    FSource: TPathItem;
    FDestination: TPathItem;
  public
    function Copy: TFileOperationTask;
    constructor Create(ASource, ADestination: TPathItem);
    destructor Destroy; override;
    property Source: TPathItem read FSource;
    property Destination: TPathItem read FDestination;
    property IsDirectory: Boolean read FIsDirectory;
  end;

  TImportPicturesTask = class
  private
    { Private declarations }
    FOperationTasks: TList<TFileOperationTask>;
    function GetOperationByIndex(Index: Integer): TFileOperationTask;
    function GetOperationsCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddOperation(Operation: TFileOperationTask);
    property OperationsCount: Integer read GetOperationsCount;
    property Operations[Index: Integer]: TFileOperationTask read GetOperationByIndex;
  end;

  TImportPicturesOptions = class
  private
    { Private declarations }
    FTasks: TList<TImportPicturesTask>;
    FOnlySupportedImages: Boolean;
    FDeleteFilesAfterImport: Boolean;
    FAddToCollection: Boolean;
    FCaption: string;
    FSource: TPathItem;
    FDestination: TPathItem;
    FDate: TDateTime;
    FAutoSplit: Boolean;
    FNamePattern: string;
    function GetCount: Integer;
    function GetTaskByIndex(Index: Integer): TImportPicturesTask;
    procedure SetSource(const Value: TPathItem);
    procedure SetDestination(const Value: TPathItem);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddTask(Task: TImportPicturesTask);
    property Source: TPathItem read FSource write SetSource;
    property Destination: TPathItem read FDestination write SetDestination;
    property OnlySupportedImages: Boolean read FOnlySupportedImages write FOnlySupportedImages;
    property DeleteFilesAfterImport: Boolean read FDeleteFilesAfterImport write FDeleteFilesAfterImport;
    property AddToCollection: Boolean read FAddToCollection write FAddToCollection;
    property NamePattern: string read FNamePattern write FNamePattern;
    property Caption: string read FCaption write FCaption;
    property Date: TDateTime read FDate write FDate;
    property TasksCount: Integer read GetCount;
    property Tasks[Index: Integer]: TImportPicturesTask read GetTaskByIndex;
    property AutoSplit: Boolean read FAutoSplit write FAutoSplit;
  end;

  TThreadImportPictures = class(TDBThread)
  private
    { Private declarations }
    FOptions: TImportPicturesOptions;
    FProgress: TFormMoveFilesProgress;
    FSpeedCounter: TSpeedEstimateCounter;
    FTotalBytes: Int64;
    FBytesCopyed: Int64;
    FLastCopyPosition: Int64;
    FTotalItems, FCopiedItems: Integer;
    FDialogResult: Integer;
    FErrorMessage: string;
    FItemName: string;
    FCurrentItem: TPathItem;
    procedure PDItemCopyCallBack(Sender: TObject; BytesTotal, BytesDone: Int64; var Break: Boolean);
  protected
    function GetThreadID: string; override;
    procedure Execute; override;
    procedure CopyDeviceFile(Task: TFileOperationTask);
    procedure CopyFSFile(Task: TFileOperationTask);
    procedure ShowErrorMessage;
  public
    constructor Create(Options: TImportPicturesOptions);
    destructor Destroy; override;
  end;

implementation

uses
  UnitUpdateDB;

{ TFileOperationTask }

function TFileOperationTask.Copy: TFileOperationTask;
begin
  Result := TFileOperationTask.Create(FSource, FDestination);
end;

constructor TFileOperationTask.Create(ASource, ADestination: TPathItem);
begin
  FSource := ASource.Copy;
  FDestination := ADestination.Copy;
  FIsDirectory := ASource.IsDirectoty;
end;

destructor TFileOperationTask.Destroy;
begin
  F(FSource);
  F(FDestination);
end;

{ TImportPicturesOptions }

procedure TImportPicturesOptions.AddTask(Task: TImportPicturesTask);
begin
  FTasks.Add(Task);
end;

constructor TImportPicturesOptions.Create;
begin
  FTasks := TList<TImportPicturesTask>.Create;
  FSource := nil;
  FCaption := '';
  FDate := MinDateTime;
  FAutoSplit := True;
end;

destructor TImportPicturesOptions.Destroy;
begin
  F(FSource);
  F(FDestination);
  FreeList(FTasks);
  inherited;
end;

function TImportPicturesOptions.GetCount: Integer;
begin
  Result := FTasks.Count;
end;

function TImportPicturesOptions.GetTaskByIndex(
  Index: Integer): TImportPicturesTask;
begin
  Result := FTasks[Index];
end;

procedure TImportPicturesOptions.SetDestination(const Value: TPathItem);
begin
  F(FDestination);
  FDestination := Value.Copy;
end;

procedure TImportPicturesOptions.SetSource(const Value: TPathItem);
begin
  F(FSource);
  FSource := Value.Copy;
end;

{ TImportPicturesTask }

procedure TImportPicturesTask.AddOperation(Operation: TFileOperationTask);
begin
  FOperationTasks.Add(Operation);
end;

constructor TImportPicturesTask.Create;
begin
  FOperationTasks := TList<TFileOperationTask>.Create;
end;

destructor TImportPicturesTask.Destroy;
begin
  FreeList(FOperationTasks);
  inherited;
end;

function TImportPicturesTask.GetOperationByIndex(
  Index: Integer): TFileOperationTask;
begin
  Result := FOperationTasks[Index];
end;

function TImportPicturesTask.GetOperationsCount: Integer;
begin
  Result := FOperationTasks.Count;
end;

{ TThreadImportPictures }

procedure TThreadImportPictures.CopyDeviceFile(Task: TFileOperationTask);
var
  S, D: TPathItem;
  DestDirectory: string;
  FS: TFileStream;
  SE: TPortableItem;
  E: HRESULT;
begin
  FLastCopyPosition := 0;

  S := Task.Source;
  if S is TPortableItem then
    SE := TPortableItem(S)
  else
    Exit;

  if SE.Item = nil then
    raise Exception.Create(FormatEx(TA('Source file {0} not found!', 'ImportPictures'), [S.Path]));

  D := Task.Destination;
  DestDirectory := ExtractFileDir(D.Path);
  if not DirectoryExists(DestDirectory) then
    CreateDirA(DestDirectory);

  FLastCopyPosition := 0;
  FS := TFileStream.Create(D.Path, fmCreate);
  try

    if not SE.Item.SaveToStreamEx(FS, PDItemCopyCallBack) then
    begin
      E := SE.Item.ErrorCode;
      if Failed(E) then
        SE.ResetItem;

      OleCheck(E);
    end;
  finally
    F(FS);
  end;

  Inc(FBytesCopyed, S.FileSize);
  Inc(FCopiedItems);
  SynchronizeEx(
    procedure
    begin
      FProgress.Options['Time remaining'].SetValue(TimeIntervalInString(FSpeedCounter.GetTimeRemaining(FTotalBytes - FBytesCopyed)));
      FProgress.Options['Items remaining'].SetValue(FormatEx('{0} ({1}))', [FTotalItems - FCopiedItems, SizeInText(FTotalBytes - FBytesCopyed)]));
      FProgress.Options['Speed'].SetValue(SpeedInText(FSpeedCounter.CurrentSpeed / (1024 * 1024)) + ' ' + L('MB/second'));
      FProgress.ProgressValue := FBytesCopyed;
      FProgress.UpdateOptions(False);
      if FProgress.IsCanceled then
        Terminate;
    end
  );
end;

procedure TThreadImportPictures.CopyFSFile(Task: TFileOperationTask);
const
  BufferSize = 2 * 1024 * 1024;
var
  S, D: TPathItem;
  DestDirectory: string;
  FS, FD: TFileStream;
  Buff: PByte;
  Count: Int64;
  BytesRemaining: Int64;
  IsBreak: Boolean;
  Size: Int64;
begin
  IsBreak := False;
  S := Task.Source;
  D := Task.Destination;
  DestDirectory := ExtractFileDir(D.Path);
  if not DirectoryExists(DestDirectory) then
    CreateDirA(DestDirectory);

  FLastCopyPosition := 0;
  //todo: check if file already exists, check errors
  FD := TFileStream.Create(D.Path, fmCreate);
  try
    FS := TFileStream.Create(S.Path, fmOpenRead, fmShareDenyNone);
    try
      Size := FS.Size;
      GetMem(Buff, BufferSize);
      try

        BytesRemaining := FS.Size;
        repeat
          Count := Min(BufferSize, BytesRemaining);

          FS.ReadBuffer(Buff[0], Count);
          FD.WriteBuffer(Buff[0], Count);

          Dec(BytesRemaining, Count);
          PDItemCopyCallBack(Self, Size, FD.Size, IsBreak);

          if IsBreak then
            Break;
        until (BytesRemaining = 0);

      finally
        FreeMem(Buff);
      end;
    finally
      F(FS);
    end;
  finally
    F(FD);
  end;

  Inc(FBytesCopyed, Size);
  Inc(FCopiedItems);
  SynchronizeEx(
    procedure
    begin
      FProgress.Options['Time remaining'].SetValue(TimeIntervalInString(FSpeedCounter.GetTimeRemaining(FTotalBytes - FBytesCopyed)));
      FProgress.Options['Items remaining'].SetValue(FormatEx('{0} ({1}))', [FTotalItems - FCopiedItems, SizeInText(FTotalBytes - FBytesCopyed)]));
      FProgress.Options['Speed'].SetValue(SpeedInText(FSpeedCounter.CurrentSpeed / (1024 * 1024)) + ' ' + L('MB/second'));
      FProgress.ProgressValue := FBytesCopyed;
      FProgress.UpdateOptions(False);
      if FProgress.IsCanceled then
        Terminate;
    end
  );
end;

procedure TThreadImportPictures.PDItemCopyCallBack(Sender: TObject; BytesTotal,
  BytesDone: Int64; var Break: Boolean);
begin
  FSpeedCounter.AddSpeedInterval(BytesDone - FLastCopyPosition);
  SynchronizeEx(
    procedure
    begin
      FProgress.Options['Name'].SetDisplayName(L('Name')).SetValue(ExtractFileName(FCurrentItem.Path));
      FProgress.Options['Time remaining'].SetValue(TimeIntervalInString(FSpeedCounter.GetTimeRemaining(FTotalBytes - FBytesCopyed - BytesDone)));
      FProgress.Options['Items remaining'].SetValue(FormatEx('{0} ({1}))', [FTotalItems - FCopiedItems, SizeInText(FTotalBytes - FBytesCopyed - BytesDone)]));
      FProgress.Options['Speed'].SetValue(SpeedInText(FSpeedCounter.CurrentSpeed / (1024 * 1024)) + ' ' + L('MB/second'));
      FProgress.ProgressValue := FBytesCopyed + BytesDone;
      FProgress.UpdateOptions(False);
    end
  );
  FLastCopyPosition := BytesDone;
  Break := Terminated;
end;

procedure TThreadImportPictures.ShowErrorMessage;
begin
  FDialogResult := Application.MessageBox(PChar(FormatEx(L('Error processing item {0}: {1}'), [FItemName, FErrorMessage])), PWideChar(PWideChar(TA('Error'))), MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

constructor TThreadImportPictures.Create(Options: TImportPicturesOptions);
begin
  inherited Create(nil, False);
  FProgress := nil;
  FOptions := Options;
end;

destructor TThreadImportPictures.Destroy;
begin
  F(FOptions);
  SynchronizeEx(
    procedure
    begin
      R(FProgress)
    end
  );
  inherited;
end;

procedure TThreadImportPictures.Execute;
var
  I, J, ErrorCount: Integer;
  HR: Boolean;
  Source: string;
  Childs: TPathItemCollection;
  FileOperations: TList<TFileOperationTask>;
  CurrentLevel, NextLevel: TList<TPathItem>;
  FO: TFileOperationTask;
  Items: TPathItemCollection;
  PFO: TPathFeatureDeleteOptions;

  procedure AddToList(Item: TPathItem);
  var
    DestPath, Path: string;
    D: TPathItem;
    Operation: TFileOperationTask;
    Date: TDateTime;
  begin
    Date := GetImageDate(Item);
    Path := FOptions.Destination.Path + '\' + TPath.TrimPathDirectories(FormatPath(FOptions.NamePattern, Date, ''));

    DestPath := TPath.Combine(Path, ExtractFileName(Item.Path));
    D := TFileItem.CreateFromPath(DestPath, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);
    try
      Operation := TFileOperationTask.Create(Item, D);
      FileOperations.Add(Operation);
    finally
      F(D);
    end;
  end;

begin
  FreeOnTerminate := True;
  CoInitializeEx(nil, COINIT_MULTITHREADED);
  try

    FTotalItems := 0;
    FTotalBytes := 0;
    FBytesCopyed := 0;
    FCopiedItems := 0;

    if FOptions.TasksCount = 0 then
      Exit;

    if FOptions.Tasks[0].OperationsCount = 0 then
      Exit;

    Source := FOptions.Source.Path;

    if IsDevicePath(Source) then
      Delete(Source, 1, Length(cDevicesPath) + 1);

    HR := SynchronizeEx(
      procedure
      begin
        Application.CreateForm(TFormMoveFilesProgress, FProgress);
        FProgress.Title := L('Calculating...');
        FProgress.Options['Name'].SetDisplayName(L('Name')).SetValue(L('Calculating...'));
        FProgress.Options['From'].SetDisplayName(L('From')).SetValue(Source).SetImportant(True);
        FProgress.Options['To'].SetDisplayName(L('To')).SetValue(FOptions.Destination.Path).SetImportant(True);
        FProgress.Options['Items remaining'].SetDisplayName(L('Items remaining')).SetValue(L('Calculating...'));
        FProgress.Options['Time remaining'].SetDisplayName(L('Time remaining')).SetValue(L('Calculating...'));
        FProgress.Options['Speed'].SetDisplayName(L('Speed')).SetValue(L('Calculating...'));
        FProgress.IsCalculating := True;
        FProgress.RefreshOptionList;
        FProgress.Show;
      end
    );
    try

      FSpeedCounter := TSpeedEstimateCounter.Create(2 * 1000);
      try

        if HR then
        begin
          FileOperations := TList<TFileOperationTask>.Create;
          try

            CurrentLevel := TList<TPathItem>.Create;
            NextLevel := TList<TPathItem>.Create;
            try

              for I := 0 to FOptions.TasksCount - 1 do
              begin
                for J := 0 to FOptions.Tasks[I].OperationsCount - 1 do
                begin
                  FO := FOptions.Tasks[I].Operations[J];
                  if FO.IsDirectory then
                    NextLevel.Add(FO.Source.Copy)
                  else if IsGraphicFile(FO.Source.Path) or not FOptions.OnlySupportedImages then
                  begin
                    Inc(FTotalItems);
                    Inc(FTotalBytes, FO.Source.FileSize);
                    FileOperations.Add(TFileOperationTask.Create(FO.Source, FO.Destination));
                  end;
                end;
              end;

              while NextLevel.Count > 0 do
              begin
                FreeList(CurrentLevel, False);
                CurrentLevel.AddRange(NextLevel);
                NextLevel.Clear;

                for I := 0 to CurrentLevel.Count - 1 do
                begin
                  if Terminated then
                    Break;
                  Childs := TPathItemCollection.Create;
                  try
                    CurrentLevel[I].Provider.FillChilds(Self, CurrentLevel[I], Childs, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);

                    for J := 0 to Childs.Count - 1 do
                    begin
                      if Childs[J].IsDirectoty then
                      begin
                        NextLevel.Add(Childs[J].Copy);
                      end else
                      begin
                        if IsGraphicFile(Childs[J].Path) or not FOptions.OnlySupportedImages then
                        begin
                          AddToList(Childs[J]);

                          Inc(FTotalBytes, Childs[J].FileSize);
                          Inc(FTotalItems);

                          //notify updated size
                          SynchronizeEx(
                            procedure
                            begin
                              FProgress.Options['Items remaining'].SetValue(FormatEx('{0} ({1}))', [FTotalItems, SizeInText(FTotalBytes)]));
                              if FProgress.IsCanceled then
                                Terminate;
                            end
                          );
                        end;
                      end;
                    end;

                  finally
                    Childs.FreeItems;
                    F(Childs);
                  end;
                end;

              end

            finally
              FreeList(CurrentLevel);
              FreeList(NextLevel);
            end;

          FSpeedCounter.Reset;

          SynchronizeEx(
            procedure
            begin
              FProgress.Title := FormatEx(L('Importing {0} items ({1})'), [FTotalItems, SizeInText(FTotalBytes)]);
              FProgress.ProgressMax := FTotalBytes;
              FProgress.ProgressValue := 0;
              FProgress.IsCalculating := False;
              FProgress.UpdateOptions(True);
            end
          );

          //calculating done,
          for I := 0 to FileOperations.Count - 1 do
          begin
            if Terminated then
              Break;

            FO := FileOperations[I];
            if FO.IsDirectory then
              Continue;

            FCurrentItem := FO.Source;

            ErrorCount := 0;
            while True do
            begin
              try
                if IsDevicePath(FO.Source.Path) then
                  CopyDeviceFile(FO)
                else
                  CopyFSFile(FO);
              except
                on e: Exception do
                begin
                  Inc(ErrorCount);
                  if ErrorCount < 5 then
                  begin
                    Sleep(100);
                    Continue;
                  end;

                  FErrorMessage := e.Message;
                  Synchronize(ShowErrorMessage);

                  if FDialogResult = IDABORT then
                  begin
                    Exit;
                  end else if FDialogResult = IDRETRY then
                    Continue
                  else if FDialogResult = IDIGNORE then
                    Break;
                end;
              end;

              Break;
            end;

          end;

          if FOptions.DeleteFilesAfterImport then
          begin
            FBytesCopyed := 0;
            FCopiedItems := 0;
            F(FSpeedCounter);
            FSpeedCounter := TSpeedEstimateCounter.Create(10000);
            FSpeedCounter.Reset;

            SynchronizeEx(
              procedure
              begin
                FProgress.Title := FormatEx(L('Importing {0} items ({1})'), [FTotalItems, SizeInText(FTotalBytes)]);
                FProgress.ProgressMax := FTotalBytes;
                FProgress.ProgressValue := 0;
                FProgress.Options['Name'].SetVisible(False);
                FProgress.Options['Items remaining'].SetValue(FormatEx('{0} ({1}))', [FTotalItems, SizeInText(FTotalBytes)]));
                FProgress.Options['Time remaining'].SetDisplayName(L('Time remaining')).SetValue(L('Calculating...'));
                FProgress.Options['Speed'].SetVisible(False);
                FProgress.RefreshOptionList;
              end
            );

            for I := 0 to FileOperations.Count - 1 do
            begin
              if Terminated then
                Break;

              FO := FileOperations[I];
              if FO.IsDirectory then
                Continue;

              FCurrentItem := FO.Source;

              //delete item...
              PFO := TPathFeatureDeleteOptions.Create(True);
              try
                Items := TPathItemCollection.Create;
                try
                  Items.Add(FCurrentItem);
                  FCurrentItem.Provider.ExecuteFeature(Self, Items, PATH_FEATURE_DELETE, nil);
                finally
                  F(Items);
                end;
              finally
                F(PFO);
              end;

              Inc(FBytesCopyed, FCurrentItem.FileSize);
              Inc(FCopiedItems);
              FSpeedCounter.AddSpeedInterval(FBytesCopyed);
              SynchronizeEx(
                procedure
                begin
                  FProgress.Options['Time remaining'].SetValue(TimeIntervalInString(FSpeedCounter.GetTimeRemaining(FTotalItems - FCopiedItems)));
                  FProgress.Options['Items remaining'].SetValue(FormatEx('{0} ({1}))', [FTotalItems - FCopiedItems, SizeInText(FTotalBytes - FBytesCopyed)]));
                  FProgress.ProgressValue := FBytesCopyed;
                  FProgress.UpdateOptions(False);
                  if FProgress.IsCanceled then
                    Terminate;
                end
              );
            end;
          end;

          if FOptions.AddToCollection then
          begin
            for I := 0 to FileOperations.Count - 1 do
              UpdaterDB.AddFile(FileOperations[I].Destination.Path);
          end;

          finally
            FreeList(FileOperations);
          end;
        end;
      finally
        F(FSpeedCounter);
      end;
    finally
      SynchronizeEx(
        procedure
        begin
          R(FProgress);
        end
      );
    end;
  finally
    CoUninitialize;
  end;
end;

function TThreadImportPictures.GetThreadID: string;
begin
  Result := 'ImportPictures';
end;

end.
