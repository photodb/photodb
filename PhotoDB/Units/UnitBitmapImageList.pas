unit UnitBitmapImageList;

interface

uses
  Windows, Classes, Graphics, uMemory, uBitmapUtils;

type
  TBitmapImageListImage = class
  private
    function GetGraphic: TGraphic;
    procedure SetGraphic(const Value: TGraphic);
  public
    Bitmap: TBitmap;
    IsBitmap: Boolean;
    Icon: TIcon;
    SelfReleased: Boolean;
    Ext: string;
    procedure UpdateIcon(Icon: TIcon; IsSelfReleased: Boolean);
    constructor Create;
    destructor Destroy; override;
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
    function AddBitmap(Bitmap : TBitmap; CopyPointer: Boolean = True) : Integer;
    function AddIcon(Icon : TIcon; SelfReleased: Boolean; Ext : string = '') : Integer;
    procedure Clear;
    procedure ClearImagesList;
    function Count: Integer;
    procedure Delete(Index: Integer);
    property Items[Index: Integer]: TBitmapImageListImage read GetBitmapByIndex; default;
 end;

implementation

{ BitmapImageList }

function TBitmapImageList.AddBitmap(Bitmap: TBitmap; CopyPointer: Boolean = True): Integer;
var
  Item: TBitmapImageListImage;
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
      AssignBitmap(Item.Bitmap, Bitmap);
    end;
    Item.SelfReleased := True;
  end else
  begin
    Item.Bitmap := nil;
    Item.SelfReleased := False;
  end;
  Result := FImages.Add(Item);
end;

function TBitmapImageList.AddIcon(Icon: TIcon; SelfReleased: Boolean; Ext: string = ''): Integer;
var
  Item: TBitmapImageListImage;
begin
  Item := TBitmapImageListImage.Create;
  Item.Graphic := Icon;
  Item.SelfReleased := SelfReleased;
  Item.Ext := Ext;
  Result := FImages.Add(Item);
end;

procedure TBitmapImageList.Clear;
var
  I: Integer;
  Item: TBitmapImageListImage;
begin
  for I := 0 to FImages.Count - 1 do
  begin
    Item := TBitmapImageListImage(FImages[I]);
    Item.Graphic := nil;
    F(Item);
  end;

  FImages.Clear;
end;

procedure TBitmapImageList.ClearImagesList;
var
  I : Integer;
begin
  for I := 0 to FImages.Count - 1 do
    TBitmapImageListImage(FImages[I]).Free;

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

destructor TBitmapImageListImage.Destroy;
begin
  inherited;
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

procedure TBitmapImageListImage.UpdateIcon(Icon: TIcon;
  IsSelfReleased: Boolean);
begin
  SetGraphic(Icon);
  SelfReleased := IsSelfReleased;
end;

end.
