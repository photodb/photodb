unit ImageHistoryUnit;

interface

uses Graphics, Classes, uMemory;

type
  THistoryAct = (THA_Redo, THA_Undo, THA_Add, THA_Unknown);
  THistoryAction = set of THistoryAct;

  TNotifyHistoryEvent = procedure(Sender: TObject; Action: THistoryAction) of object;

type
  TBitmapHistoryItem = class(TObject)
  private
    FBitmap : TBitmap;
    FAction : string;
  public
    constructor Create(ABitmap : TBitmap; AAction : string);
    destructor Destroy; override;
    property Bitmap : TBitmap read FBitmap;
    property Action : string read FAction;
  end;

  TBitmapHistory = class(TObject)
  private
    { Private declarations }
    FArray: TList;
    FPosition: Integer;
    FOnChange: TNotifyHistoryEvent;
    procedure SetOnChange(const Value: TNotifyHistoryEvent);
    function GetImageByIndex(Index: Integer): TBitmap;
    function GetCount: Integer;
    function GetItemByIndex(Index: Integer): TBitmapHistoryItem;
    function GetActionByIndex(Index: Integer): string;
  protected
    property Items[Index : Integer] : TBitmapHistoryItem read GetItemByIndex;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Add(Image: TBitmap; Action: string);
    function CanBack: Boolean;
    function CanForward: Boolean;
    function GetCurrentPos: Integer;
    function DoBack: TBitmap;
    function DoForward: TBitmap;
    function LastImage: TBitmap;
    procedure Clear;
    property OnHistoryChange: TNotifyHistoryEvent read FOnChange write SetOnChange;
    property Images[Index : Integer] : TBitmap read GetImageByIndex;
    property Actions[Index : Integer] : string read GetActionByIndex;
    property Count : Integer read GetCount;
    property Position : Integer read FPosition;
  end;

implementation

{ TBitmapHistory }

procedure TBitmapHistory.Add(Image: TBitmap; Action : String);
var
  I: Integer;

  procedure AddImage;
  var
    Item : TBitmapHistoryItem;
  begin
    Item := TBitmapHistoryItem.Create(Image, Action);
    FArray.Add(Item);
    FPosition := FArray.Count - 1;
  end;

begin
  if FPosition = FArray.Count - 1 then
    AddImage
  else
  begin
    for I := FArray.Count - 1 downto FPosition + 1 do
    begin
      Items[I].Free;
      FArray.Delete(I);
    end;
    AddImage;
  end;

  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self, [THA_Add]);
end;

function TBitmapHistory.CanBack: Boolean;
begin
  if Fposition = -1 then
  begin
    Result := False;
  end else
  begin
    if FPosition > 0 then
      Result := True
    else
      Result := False;
  end;
end;

function TBitmapHistory.CanForward: Boolean;
begin
  if FPosition = -1 then
  begin
    Result := False;
    Exit;
  end else
  begin
    if (Fposition <> FArray.Count - 1) and (FArray.Count <> 1) then
      Result := True
    else
      Result := False;
  end;
end;

procedure TBitmapHistory.Clear;
var
  I: Integer;
begin
  Fposition := -1;
  for I := 0 to Count - 1 do
    Items[I].Free;

  FArray.Clear;
end;

constructor TBitmapHistory.create;
begin
  inherited;
  FPosition := -1;
  FArray := TList.Create;
  FOnChange := nil;
end;

destructor TBitmapHistory.Destroy;
begin
  Clear;
  F(FArray);
  inherited;
end;

function TBitmapHistory.DoBack: TBitmap;
begin
  Result := nil;
  if FPosition = -1 then
    Exit;
  if FPosition = 0 then
    Result := FArray[0]
  else
  begin
    Dec(FPosition);
    Result := FArray[FPosition];
  end;
  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self, [THA_Undo]);
end;

function TBitmapHistory.DoForward: TBitmap;
begin
  Result := nil;
  if FPosition = -1 then
    Exit;
  if (Fposition = FArray.Count - 1) or (FArray.Count = 1) then
    Result := Items[FArray.Count - 1].Bitmap
  else
  begin
    Inc(FPosition);
    Result := Items[FPosition].Bitmap;
  end;
  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self, [THA_Redo]);
end;

function TBitmapHistory.GetActionByIndex(Index: Integer): string;
begin
  Result := Items[Index].Action;
end;

function TBitmapHistory.GetCount: Integer;
begin
  Result := FArray.Count;
end;

function TBitmapHistory.GetCurrentPos: integer;
begin
  Result := FPosition + 1;
end;

function TBitmapHistory.GetImageByIndex(Index: Integer): TBitmap;
begin
  Result := Items[Index].Bitmap;
end;

function TBitmapHistory.GetItemByIndex(Index: Integer): TBitmapHistoryItem;
begin
  Result := FArray[Index];
end;

function TBitmapHistory.LastImage: TBitmap;
begin
  Result := nil;
  if FPosition = -1 then
    Exit;
  Result := Items[FPosition].Bitmap;
end;

procedure TBitmapHistory.SetOnChange(const Value: TNotifyHistoryEvent);
begin
  FOnChange := Value;
end;

{ TBitmapHistoryItem }

constructor TBitmapHistoryItem.Create(ABitmap: TBitmap; AAction: string);
begin
  FBitmap := TBitmap.Create;
  FBitmap.Assign(ABitmap);
  FAction := AAction;
end;

destructor TBitmapHistoryItem.Destroy;
begin
  F(FBitmap);
  inherited;
end;

end.
