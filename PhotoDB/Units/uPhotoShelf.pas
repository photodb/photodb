unit uPhotoShelf;

interface

uses
  System.Classes,
  System.SysUtils,

  UnitDBDeclare,

  uMemory,
  uCollectionEvents,
  uDBForm,
  uSettings,
  uRWLock,
  uProgramStatInfo,
  uLogger;

type
  TPhotoShelf = class(TObject)
  private
    FSync: IReadWriteSync;
    FItems: TStringList;
    function GetCount: Integer;
    function InternalPathInShelf(Path: string): Integer;
    function InternalRemoveFromShelf(Path: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadSavedItems;
    procedure SaveItems;
    procedure AddToShelf(Path: string);
    function RemoveFromShelf(Path: string): Boolean;
    function PathInShelf(Path: string): Integer;
    procedure AddItems(Sender: TDBForm; Items: TStrings);
    procedure DeleteItems(Sender: TDBForm; Items: TStrings);
    procedure GetItems(Items: TStrings);
    procedure Clear;
    property Count: Integer read GetCount;
  end;

function PhotoShelf: TPhotoShelf;

implementation

var
  FPhotoShelf: TPhotoShelf = nil;

function PhotoShelf: TPhotoShelf;
begin
  if FPhotoShelf = nil then
  begin
    FPhotoShelf := TPhotoShelf.Create;
    FPhotoShelf.LoadSavedItems;
  end;

  Result := FPhotoShelf;
end;

{ TPhotoShelf }

procedure TPhotoShelf.AddItems(Sender: TDBForm; Items: TStrings);
var
  S: string;
  AddedItems: TStrings;
begin
  //statistics
  ProgramStatistics.ShelfUsed;

  AddedItems := TStringList.Create;
  try
    FSync.BeginWrite;
    try
      for S in Items do
        if InternalPathInShelf(S) = -1 then
        begin
          FItems.Add(S);
          AddedItems.Add(S);
        end;
    finally
      FSync.EndWrite;
    end;
    TThread.Synchronize(nil,
      procedure
      var
        EventInfo: TEventValues;
        I: Integer;
      begin
        EventInfo.ID := 0;
        CollectionEvents.DoIDEvent(Sender, 0, [EventID_ShelfChanged], EventInfo);

        for I := 0 to AddedItems.Count - 1 do
        begin
          EventInfo.FileName := AddedItems[I];
          CollectionEvents.DoIDEvent(Sender, 0, [EventID_ShelfItemAdded], EventInfo);
        end;
      end
    );
  finally
    F(AddedItems);
  end;
end;

procedure TPhotoShelf.AddToShelf(Path: string);
begin
  //statistics
  ProgramStatistics.ShelfUsed;

  FSync.BeginWrite;
  try
    if InternalPathInShelf(Path) = -1 then
      FItems.Add(Path);
  finally
    FSync.EndWrite;
  end;
end;

procedure TPhotoShelf.Clear;
begin
  FSync.BeginWrite;
  try
    FItems.Clear;
  finally
    FSync.EndWrite;
  end;
end;

constructor TPhotoShelf.Create;
begin
  FSync := CreateRWLock;
  FItems := TStringList.Create;
end;

procedure TPhotoShelf.DeleteItems(Sender: TDBForm; Items: TStrings);
var
  S: string;
  RemovedItems: TStrings;
begin
  //statistics
  ProgramStatistics.ShelfUsed;

  RemovedItems := TStringList.Create;
  try
    FSync.BeginWrite;
    try
      for S in Items do
        if InternalRemoveFromShelf(S) then
          RemovedItems.Add(S);
    finally
      FSync.EndWrite;
    end;

    TThread.Synchronize(nil,
      procedure
      var
        EventInfo: TEventValues;
        I: Integer;
      begin
        EventInfo.ID := 0;
        CollectionEvents.DoIDEvent(Sender, 0, [EventID_ShelfChanged], EventInfo);

        for I := 0 to RemovedItems.Count - 1 do
        begin
          EventInfo.FileName := RemovedItems[I];
          CollectionEvents.DoIDEvent(Sender, 0, [EventID_ShelfItemRemoved], EventInfo);
        end;
      end
    );
  finally
    F(RemovedItems);
  end;
end;

destructor TPhotoShelf.Destroy;
begin
  SaveItems;
  FSync := nil;
  F(FItems);
  inherited;
end;

function TPhotoShelf.GetCount: Integer;
begin
  FSync.BeginRead;
  try
    Result := FItems.Count;
  finally
    FSync.EndRead;
  end;
end;

procedure TPhotoShelf.GetItems(Items: TStrings);
var
  S: string;
begin
  FSync.BeginRead;
  try
    for S in FItems do
      Items.Add(S);
  finally
    FSync.EndRead;
  end;
end;

function TPhotoShelf.InternalPathInShelf(Path: string): Integer;
var
  S: string;
  I: Integer;
begin
  Result := -1;
  S := AnsiUpperCase(Path);
  for I := 0 to FItems.Count - 1 do
    if AnsiUpperCase(FItems[I]) = S then
    begin
      Result := I;
      Exit;
    end;
end;

function TPhotoShelf.PathInShelf(Path: string): Integer;
begin
  FSync.BeginRead;
  try
    Result := InternalPathInShelf(Path);
  finally
    FSync.EndRead;
  end;
end;

function TPhotoShelf.InternalRemoveFromShelf(Path: string): Boolean;
var
  Index: Integer;
begin
  Result := False;

  Index := InternalPathInShelf(Path);
  if Index > -1 then
  begin
    FItems.Delete(Index);
    Result := True;
  end;
end;

function TPhotoShelf.RemoveFromShelf(Path: string): Boolean;
var
  Index: Integer;
begin
  //statistics
  ProgramStatistics.ShelfUsed;

  FSync.BeginWrite;
  try
    Result := InternalRemoveFromShelf(Path);
  finally
    FSync.EndWrite;
  end;
end;

procedure TPhotoShelf.LoadSavedItems;
begin
  FSync.BeginWrite;
  try
    FItems.Delimiter := '|';
    try
      FItems.DelimitedText := AppSettings.ReadString('Settings', 'Shelf', '');
    except
      on e: Exception do
        EventLog(e);
    end;
  finally
    FSync.EndWrite;
  end;
end;

procedure TPhotoShelf.SaveItems;
begin
  FSync.BeginWrite;
  try
    FItems.Delimiter := '|';
    try
      AppSettings.WriteString('Settings', 'Shelf', FItems.DelimitedText);
    except
      on e: Exception do
        EventLog(e);
    end;
  finally
    FSync.EndWrite;
  end;

end;

initialization

finalization
  F(FPhotoShelf);

end.
