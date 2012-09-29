unit UnitPropeccedFilesSupport;

interface

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Winapi.Windows,
  win32crc,
  uMemory;

type
  TCollectionItem = class
  public
    FileName: string;
    CRC: Cardinal;
    RefCount: integer;
    constructor Create;
    procedure AddRef;
    procedure RemoveRef;
  end;

type
  TProcessedFilesCollection = class
  private
    FData: TList;
    FSync: TCriticalSection;
  public
    function AddFile(FileName: String): TCollectionItem;
    procedure RemoveFile(FileName: String);
    function ExistsFile(FileName: String): TCollectionItem;
    constructor Create;
    destructor Destroy; override;
  end;

function ProcessedFilesCollection: TProcessedFilesCollection;

implementation

var
  FProcessedFilesCollection: TProcessedFilesCollection = nil;

function ProcessedFilesCollection: TProcessedFilesCollection;
begin
  if FProcessedFilesCollection = nil then
    FProcessedFilesCollection := TProcessedFilesCollection.Create;

  Result := FProcessedFilesCollection;
end;

{ TProcessedFilesCollection }

function TProcessedFilesCollection.AddFile(FileName: String) : TCollectionItem;
begin
  FSync.Enter;
  try
    Result := ExistsFile(FileName);
    if Result = nil then
    begin
      Result := TCollectionItem.Create;
      Result.FileName := AnsiLowerCase(FileName);
      CalcStringCRC32(Result.FileName, Result.CRC);
      FData.Add(Result);
    end else
      Result.AddRef;
  finally
    FSync.Leave;
  end;
end;

constructor TProcessedFilesCollection.Create;
begin
  FData := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TProcessedFilesCollection.Destroy;
begin
  FreeList(FData);
  F(FSync);
end;

function TProcessedFilesCollection.ExistsFile(FileName: String): TCollectionItem;
var
  I : Integer;
  CRC : Cardinal;
  Item : TCollectionItem;
begin
  Result := nil;
  FSync.Enter;
  try
    FileName := AnsiLowerCase(FileName);
    CalcStringCRC32(FileName, CRC);
    for I := 0 to FData.Count - 1 do
    begin
      Item := FData.Items[I];
      if (Item.CRC = CRC) and (Item.FileName = FileName) then
      begin
        Result := Item;
        Exit;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TProcessedFilesCollection.RemoveFile(FileName: String);
var
  Item: TCollectionItem;
begin
  FSync.Enter;
  try
    Item := ExistsFile(FileName);
    if Item <> nil then
    begin
      if Item.RefCount > 1 then
        Item.RemoveRef
      else
      begin
        FData.Remove(Item);
        F(Item);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

{ TCollectionItem }

procedure TCollectionItem.AddRef;
begin
  Inc(RefCount);
end;

constructor TCollectionItem.Create;
begin
  RefCount := 1;
end;

procedure TCollectionItem.RemoveRef;
begin
  Dec(RefCount);
end;

initialization

finalization
  F(FProcessedFilesCollection);

end.
