unit UnitBitmapImageList;

interface

uses Classes, Graphics, uMemory;

type
  TBitmapImageListImage = class
  private
    function GetGraphic: TGraphic;
    procedure SetGraphic(const Value: TGraphic);
  public
    Bitmap : TBitmap;
    IsBitmap : Boolean;
    Icon : TIcon;
    SelfReleased : Boolean;
    Ext : string;
    constructor Create;
    property Graphic : TGraphic read GetGraphic write SetGraphic;
 end;

type
  TBitmapImageList = Class(TObject)
  private
    FImages : TList;
    function GetBitmapByIndex(Index: Integer): TBitmapImageListImage;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function AddBitmap(Bitmap : TBitmap; CopyPointer : Boolean = True) : Integer;
    procedure AddIcon(Icon : TIcon; SelfReleased : Boolean; Ext : string = '');
    procedure Clear;
    function Count : Integer;
    procedure Delete(Index : Integer);
    property Items[Index: Integer]: TBitmapImageListImage read GetBitmapByIndex; default;
 end;

implementation

{ BitmapImageList }

function TBitmapImageList.AddBitmap(Bitmap: TBitmap; CopyPointer : Boolean = True) : Integer;
var
  Item : TBitmapImageListImage;
begin    
  Item := TBitmapImageListImage.Create;
  Item.IsBitmap := True;
  Item.Icon := nil;     
  Item.Ext := '';
  if Bitmap <> nil then
  begin
    if CopyPointer then
      Pointer(Item.Bitmap) := Pointer(Bitmap)
    else begin
      Item.Bitmap := TBitmap.Create;
      Item.Bitmap.Assign(Bitmap);
    end;
    Item.SelfReleased := True;
  end else
  begin
    Item.Bitmap := nil;
    Item.SelfReleased := False;
  end;
  Result := FImages.Add(Item);
end;

procedure TBitmapImageList.AddIcon(Icon: TIcon; SelfReleased : Boolean; Ext : string = '');   
var
  Item : TBitmapImageListImage;
begin
  Item := TBitmapImageListImage.Create;
  Item.Graphic := Icon;
  Item.SelfReleased := SelfReleased;
  Item.Ext := Ext;
  FImages.Add(Item);
end;

procedure TBitmapImageList.Clear;
var
  I : Integer;
  Item : TBitmapImageListImage;
begin
  for I := 0 to FImages.Count - 1 do
  begin
    Item := TBitmapImageListImage(FImages[I]);
    Item.Graphic := nil;
    F(Item);
  end;

  FImages.Clear;
end;

function TBitmapImageList.Count: Integer;
begin
  Result := FImages.Count;
end;

constructor TBitmapImageList.Create;
begin
  inherited;
  FImages := TList.Create;
end;

procedure TBitmapImageList.Delete(Index: Integer);
var
  Item : TBitmapImageListImage;
begin
  Item := FImages[Index];
  Item.Graphic := nil;
  Item.Free;

  FImages.Delete(Index);
end;

destructor TBitmapImageList.Destroy;
begin
  Clear;
  FImages.Free;
  inherited;
end;

function TBitmapImageList.GetBitmapByIndex(
  Index: Integer): TBitmapImageListImage;
begin
  Result := FImages[Index];
end;

{ TBitmapImageListImage }

constructor TBitmapImageListImage.Create;
begin
  Bitmap := nil;
  Icon := nil;
  SelfReleased := False;
  IsBitmap := True;
end;

function TBitmapImageListImage.GetGraphic: TGraphic;
begin
  if IsBitmap then
    Result := Bitmap
  else
    Result := Icon;
end;

procedure TBitmapImageListImage.SetGraphic(const Value: TGraphic);
begin
  if SelfReleased then
  begin
    F(Bitmap);
    F(Icon);
  end;
  IsBitmap := Value is TBitmap;
  if IsBitmap then
    Bitmap := Value as TBitmap
  else
    Icon := Value as TIcon;
end;

end.
