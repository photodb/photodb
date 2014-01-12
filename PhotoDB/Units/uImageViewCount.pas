unit uImageViewCount;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SyncObjs,

  uMemory,
  uRuntime,
  uDBThread,
  uDBContext;

type
  TImageViewInfo = class
  public
    DBContext: IDBContext;
    ID: Integer;
    constructor Create(DBContext: IDBContext; ID: Integer);
  end;

  TImageViewCounter = class
  private
    FData: TQueue<TImageViewInfo>;
    FSync: TCriticalSection;
  protected
    procedure AddImageViewInfo(Info: TImageViewInfo);
    procedure ExtractImageInfos(Count: Integer; Infos: TList<TImageViewInfo>);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ImageViewed(DBContext: IDBContext; ID: Integer);
  end;

  TImageViewUpdater = class(TDBThread)
    procedure Execute; override;
  end;

  function ImageViewCounter: TImageViewCounter;

implementation

var
  FImageViewCounter: TImageViewCounter = nil;

function ImageViewCounter: TImageViewCounter;
begin
  if FImageViewCounter = nil then
    FImageViewCounter := TImageViewCounter.Create;

  Result := FImageViewCounter;
end;

{ TImageViewCounter }

procedure TImageViewCounter.AddImageViewInfo(Info: TImageViewInfo);
begin
  FSync.Enter;
  try
    FData.Enqueue(Info);
  finally
    FSync.Leave;
  end;
end;

constructor TImageViewCounter.Create;
begin
  FSync := TCriticalSection.Create;
  FData := TQueue<TImageViewInfo>.Create;
  TImageViewUpdater.Create(nil, False);
end;

destructor TImageViewCounter.Destroy;
begin
  F(FSync);
  FreeList(FData);
  inherited;
end;

procedure TImageViewCounter.ExtractImageInfos(Count: Integer;
  Infos: TList<TImageViewInfo>);
var
  CollectionFileName: string;
begin
  FSync.Enter;
  try
    CollectionFileName := '';

    while (FData.Count > 0)
      and ((CollectionFileName = '') or (FData.Peek.DBContext.CollectionFileName = CollectionFileName))
      and (Infos.Count < Count) do
    begin
      CollectionFileName := FData.Peek.DBContext.CollectionFileName;
      Infos.Add(FData.Dequeue);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TImageViewCounter.ImageViewed(DBContext: IDBContext; ID: Integer);
begin
  AddImageViewInfo(TImageViewInfo.Create(DBContext, ID));
end;

{ TImageViewUpdater }

procedure TImageViewUpdater.Execute;
var
  Infos: TList<TImageViewInfo>;
  FMediaRepository: IMediaRepository;

begin
  inherited;
  FreeOnTerminate := True;

  Infos := TList<TImageViewInfo>.Create;
  try
    while not DBTerminating do
    begin
      Sleep(100);

      if uRuntime.BlockClosingOfWindows then
        Continue;

      ImageViewCounter.ExtractImageInfos(1, Infos);
      if Infos.Count > 0 then
      begin
        FMediaRepository := Infos[0].DBContext.Media;

        FMediaRepository.IncMediaCounter(Infos[0].ID);
        FreeList(Infos, False);
      end;
    end;
  finally
    FreeList(Infos);
  end;
end;

{ TImageViewInfo }

constructor TImageViewInfo.Create(DBContext: IDBContext; ID: Integer);
begin
  Self.DBContext := DBContext;
  Self.ID := ID;
end;

initialization
finalization
  F(FImageViewCounter);

end.
