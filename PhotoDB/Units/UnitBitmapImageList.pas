unit UnitBitmapImageList;

interface

uses Classes, Graphics;

type
 TBitmapImageListImage = class
  Bitmap : TBitmap;
  IsBitmap : Boolean;
  Icon : TIcon;
  SelfReleased : Boolean;
  Ext : string;
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
    procedure AddBitmap(Bitmap : TBitmap);
    procedure AddIcon(Icon : TIcon; SelfReleased : Boolean; Ext : string = '');
    procedure Clear;
    function Count : Integer;
    procedure Delete(Index : Integer);
    property Items[Index: Integer]: TBitmapImageListImage read GetBitmapByIndex; default;
 end;

implementation

{ BitmapImageList }

procedure TBitmapImageList.AddBitmap(Bitmap: TBitmap);
var
  Item : TBitmapImageListImage;
begin    
  Item := TBitmapImageListImage.Create;  
  Item.IsBitmap := True;
  Item.Icon := nil;     
  Item.Ext := '';
  if Bitmap <> nil then
  begin
    Pointer(Item.Bitmap) := Pointer(Bitmap);
    Item.SelfReleased := True;
  end else
  begin
    Item.Bitmap := nil;
    Item.SelfReleased := False;
  end;
  FImages.Add(Item);
end;

procedure TBitmapImageList.AddIcon(Icon: TIcon; SelfReleased : Boolean; Ext : string = '');   
var
  Item : TBitmapImageListImage;
begin      
  Item := TBitmapImageListImage.Create;
  Item.Bitmap := nil;
  Item.Icon := Icon;
  Item.IsBitmap := False;
  Item.SelfReleased := SelfReleased;
  Item.Ext := Ext;
  FImages.Add(Item);
end;

procedure TBitmapImageList.Clear;
var
  I : integer;
  Item : TBitmapImageListImage;
begin
  for I := 0 to FImages.Count - 1 do
  begin
    Item := FImages[I];
    if Item.SelfReleased then
    begin
      if Item.Bitmap <> nil then
        Item.Bitmap.Free;
    end else
    begin
      if Item.Icon <> nil then
        Item.Icon.Free;
    end;
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

  if Item.Bitmap <> nil then
    Item.Bitmap.Free;
    
  if Item.SelfReleased and (Item.Icon <> nil) then
    Item.Icon.Free;

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

end.
