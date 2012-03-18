unit uPhotoShelf;

interface

uses
  uMemory,
  uConstants,
  UnitDBDeclare,
  UnitDBKernel,
  uDBForm,
  Classes,
  SysUtils,
  SyncObjs,
  uSettings,
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
    procedure RemoveFromShelf(Path: string);
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
begin
  FSync.Enter;
  try
    for S in Items do
      if PathInShelf(S) = -1 then
        FItems.Add(S);
  finally
    FSync.Leave;
  end;
  TThread.Synchronize(nil,
    procedure
    var
      EventInfo: TEventValues;
    begin
      EventInfo.Image := nil;
      DBKernel.DoIDEvent(Sender, 0, [EventID_ShelfChanged], EventInfo);
    end
  );
end;

procedure TPhotoShelf.AddToShelf(Path: string);
begin
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
begin
  FSync.Enter;
  try
    for S in Items do
      RemoveFromShelf(S);
  finally
    FSync.Leave;
  end;

  TThread.Synchronize(nil,
    procedure
    var
      EventInfo: TEventValues;
    begin
      EventInfo.Image := nil;
      DBKernel.DoIDEvent(Sender, 0, [EventID_ShelfChanged], EventInfo);
    end
  );
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

procedure TPhotoShelf.RemoveFromShelf(Path: string);
var
  Index: Integer;
begin
  FSync.Enter;
  try
    Index := PathInShelf(Path);
    if Index > -1 then
      FItems.Delete(Index);
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
