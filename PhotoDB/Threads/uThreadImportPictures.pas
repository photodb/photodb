unit uThreadImportPictures;

interface

uses
  Generics.Collections,
  System.Classes,
  SysUtils,
  uMemory,
  uMemoryEx,
  Forms,
  uPathUtils,
  uPathProviders,
  uExplorerFSProviders,
  uFormMoveFilesProgress,
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
    function GetCount: Integer;
    function GetTaskByIndex(Index: Integer): TImportPicturesTask;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddTask(Task: TImportPicturesTask);
    property OnlySupportedImages: Boolean read FOnlySupportedImages write FOnlySupportedImages;
    property DeleteFilesAfterImport: Boolean read FDeleteFilesAfterImport write FDeleteFilesAfterImport;
    property AddToCollection: Boolean read FAddToCollection write FAddToCollection;
    property Caption: string read FCaption write FCaption;
    property TasksCount: Integer read GetCount;
    property Tasks[Index: Integer]: TImportPicturesTask read GetTaskByIndex;
  end;

  TThreadImportPictures = class(TDBThread)
  private
    { Private declarations }
    FOptions: TImportPicturesOptions;
    FProgress: TFormMoveFilesProgress;
  protected
    function GetThreadID: string; override;
    procedure Execute; override;
  public
    constructor Create(Options: TImportPicturesOptions);
    destructor Destroy; override;
  end;

implementation

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
end;

destructor TImportPicturesOptions.Destroy;
begin
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
  I, J: Integer;
  HR: Boolean;
  Source, Destination: string;
  D: TPathItem;
  Childs: TPathItemCollection;
  FSize: Integer;
  FileOperations, CurrentLevel, NextLevel: TList<TFileOperationTask>;
begin
  FreeOnTerminate := True;
  FSize := 0;

  if FOptions.TasksCount = 0 then
    Exit;

  if FOptions.Tasks[0].OperationsCount = 0 then
    Exit;

  Source := FOptions.Tasks[0].Operations[0].Source.Path;
  Destination := FOptions.Tasks[0].Operations[0].Destination.Path;

  HR := SynchronizeEx(
    procedure
    begin
      Application.CreateForm(TFormMoveFilesProgress, FProgress);
      FProgress.Title := L('Calculating...');
      FProgress.Options['Name'].SetDisplayName(L('Name')).SetValue(L('Calculating...'));
      FProgress.Options['From'].SetDisplayName(L('From')).SetValue(Source).SetImportant(True);
      FProgress.Options['To'].SetDisplayName(L('To')).SetValue(Destination).SetImportant(True);
      FProgress.Options['Items remaining'].SetDisplayName(L('Items remaining')).SetValue('2 (345 MB)');
      FProgress.Options['Speed'].SetDisplayName(L('Speed')).SetValue('49,5 MB/second');
      FProgress.RefreshOptionList;
      FProgress.Show;
    end
  );

  if HR then
  begin
    FileOperations := TList<TFileOperationTask>.Create;
    try

      CurrentLevel := TList<TFileOperationTask>.Create;
      NextLevel := TList<TFileOperationTask>.Create;
      try

        for I := 0 to FOptions.TasksCount - 1 do
        begin
          for J := 0 to FOptions.Tasks[I].OperationsCount - 1 do
            NextLevel.Add(FOptions.Tasks[I].Operations[J].Copy);
        end;

        while NextLevel.Count > 0 do
        begin
          CurrentLevel.AddRange(NextLevel);
          NextLevel.Clear;

          for I := 0 to CurrentLevel.Count - 1 do
          begin
            Childs := TPathItemCollection.Create;
            try
              CurrentLevel[I].Source.Provider.FillChilds(Self, CurrentLevel[I].Source, Childs, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);

              Destination := CurrentLevel[I].Destination.Path;
              for J := 0 to Childs.Count - 1 do
              begin

                if Childs[J].IsDirectoty then
                begin
                  D := TDirectoryItem.CreateFromPath(TPath.Combine(Destination, ExtractFileName(Childs[J].Path)), PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);
                  try
                    NextLevel.Add(TFileOperationTask.Create(Childs[J], D));
                  finally
                    F(D);
                  end;
                end else
                begin
                  D := TFileItem.CreateFromPath(TPath.Combine(Destination, ExtractFileName(Childs[J].Path)), PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);
                  try
                    FileOperations.Add(TFileOperationTask.Create(Childs[J], D));
                  finally
                    F(D);
                  end;
                end;
                FSize := FSize + Childs[J].FileSize;
              end;

              //notify updated size
            finally
              F(Childs);
            end;
          end;

        end

      finally
        FreeList(CurrentLevel);
        FreeList(NextLevel);
      end;

    finally
      FreeList(FileOperations);
    end;
  end;

  Sleep(20000);
end;

function TThreadImportPictures.GetThreadID: string;
begin
  Result := 'ImportPictures';
end;

end.
