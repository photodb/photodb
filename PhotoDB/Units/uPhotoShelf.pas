unit uPhotoShelf;

interface

uses
  uMemory,
  UnitDBDeclare,
  UnitDBKernel,
  uDBForm,
  Classes,
  SysUtils,
  SyncObjs,
  uSettings,
  uProgramStatInfo,
  uLogger;

type
  TPhotoShelf = class(TObject)
  private
    FSync: TCriticalSection;
    FItems: TStringList;
    function GetCount: Integer;
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
    FSync.Enter;
    try
      for S in Items do
        if PathInShelf(S) = -1 then
        begin
          FItems.Add(S);
          AddedItems.Add(S);
        end;
    finally
      FSync.Leave;
    end;
    TThread.Synchronize(nil,
      procedure
      var
        EventInfo: TEventValues;
        I: Integer;
      begin
        EventInfo.ID := 0;
        DBKernel.DoIDEvent(Sender, 0, [EventID_ShelfChanged], EventInfo);

        for I := 0 to AddedItems.Count - 1 do
        begin
          EventInfo.FileName := AddedItems[I];
          DBKernel.DoIDEvent(Sender, 0, [EventID_ShelfItemAdded], EventInfo);
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

  FSync.Enter;
  try
    if PathInShelf(Path) = -1 then
      FItems.Add(Path);
  finally
    FSync.Leave;
  end;
end;

procedure TPhotoShelf.Clear;
begin
  FSync.Enter;
  try
    FItems.Clear;
  finally
    FSync.Leave;
  end;
end;

constructor TPhotoShelf.Create;
begin
  FSync := TCriticalSection.Create;
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
    FSync.Enter;
    try
      for S in Items do
        if RemoveFromShelf(S) then
          RemovedItems.Add(S);
    finally
      FSync.Leave;
    end;

    TThread.Synchronize(nil,
      procedure
      var
        EventInfo: TEventValues;
        I: Integer;
      begin
        EventInfo.ID := 0;
        DBKernel.DoIDEvent(Sender, 0, [EventID_ShelfChanged], EventInfo);

        for I := 0 to RemovedItems.Count - 1 do
        begin
          EventInfo.FileName := RemovedItems[I];
          DBKernel.DoIDEvent(Sender, 0, [EventID_ShelfItemRemoved], EventInfo);
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
  F(FSync);
  F(FItems);
  inherited;
end;

function TPhotoShelf.GetCount: Integer;
begin
  FSync.Enter;
  try
    Result := FItems.Count;
  finally
    FSync.Leave;
  end;
end;

procedure TPhotoShelf.GetItems(Items: TStrings);
var
  S: string;
begin
  FSync.Enter;
  try
    for S in FItems do
      Items.Add(S);
  finally
    FSync.Leave;
  end;
end;

function TPhotoShelf.PathInShelf(Path: string): Integer;
var
  S: string;
  I: Integer;
begin
  Result := -1;
  S := AnsiUpperCase(Path);
  FSync.Enter;
  try
    for I := 0 to FItems.Count - 1 do
      if AnsiUpperCase(FItems[I]) = S then
      begin
        Result := I;
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

function TPhotoShelf.RemoveFromShelf(Path: string): Boolean;
var
  Index: Integer;
begin
  Result := False;

  //statistics
  ProgramStatistics.ShelfUsed;

  FSync.Enter;
  try
    Index := PathInShelf(Path);
    if Index > -1 then
    begin
      FItems.Delete(Index);
      Result := True;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TPhotoShelf.LoadSavedItems;
begin
  FSync.Enter;
  try
    FItems.Delimiter := '|';
    try
      FItems.DelimitedText := Settings.ReadString('Settings', 'Shelf', '');
    except
      on e: Exception do
        EventLog(e);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TPhotoShelf.SaveItems;
begin
  FSync.Enter;
  try
    FItems.Delimiter := '|';
    try
      Settings.WriteString('Settings', 'Shelf', FItems.DelimitedText);
    except
      on e: Exception do
        EventLog(e);
    end;
  finally
    FSync.Leave;
  end;

end;

initialization

finalization
  F(FPhotoShelf);

end.
