unit UnitBitmapImageList;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  uMemory,
  uBitmapUtils,
  uPathProviders,
  Vcl.ImgList,
  Winapi.CommCtrl;

type
  TBitmapImageList = class;

  TBitmapImageListImage = class
  private
    FOwner: TBitmapImageList;
    FMemoryStream: TMemoryStream;
    FIsIcon: Boolean;
    FBitmap: TBitmap;
    FIcon: TIcon;
    function GetGraphic: TGraphic;
    procedure SetGraphic(const Value: TGraphic);
    function GetBitmap: TBitmap;
    function GetIcon: TIcon;
    procedure SetBitmap(const Value: TBitmap);
  protected
    procedure SaveToMemory;
    procedure LoadFromMemory;
  public
    IsBitmap: Boolean;
    SelfReleased: Boolean;
    Ext: string;
    procedure AddToImageList(ImageList: TCustomImageList);
    procedure UpdateIcon(Icon: TIcon; IsSelfReleased: Boolean);
    constructor Create(AOwner: TBitmapImageList);
    destructor Destroy; override;
    procedure DetachImage;
    property Graphic: TGraphic read GetGraphic write SetGraphic;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property Icon: TIcon read GetIcon;
 end;

  TBitmapImageList = Class(TObject)
  private
    FImages: TList;
    FUseList: TList;
    function GetBitmapByIndex(Index: Integer): TBitmapImageListImage;
  protected
    procedure UsedImage(Image: TBitmapImageListImage);
    procedure RemoveImage(Image: TBitmapImageListImage);
  public
    constructor Create;
    destructor Destroy; override;
    function AddBitmap(Bitmap: TBitmap; CopyPointer: Boolean = True): Integer;
    function AddIcon(Icon: TIcon; SelfReleased: Boolean; Ext: string = ''): Integer;
    function AddHIcon(Icon: HIcon): Integer;
    function AddPathImage(Image: TPathImage; FreeImage: Boolean = False): Integer;
    procedure Clear;
    procedure ClearImagesList;
    procedure ClearItems;
    function Count: Integer;
    procedure Delete(Index: Integer);
    property Items[Index: Integer]: TBitmapImageListImage read GetBitmapByIndex; default;
  end;

const
  BITMAP_IL_MAX_ITEMS = 500;
  BITMAP_IL_ITEMS_TO_SWAP_AT_TIME = 50;

implementation

{ BitmapImageList }

function TBitmapImageList.AddBitmap(Bitmap: TBitmap; CopyPointer: Boolean = True): Integer;
var
  Item: TBitmapImageListImage;
begin    
  Item := TBitmapImageListImage.Create(Self);
  Item.IsBitmap := True;
  Item.FIcon := nil;
  Item.Ext := '';
  if Bitmap <> nil then
  begin
    if CopyPointer then
      Pointer(Item.FBitmap) := Pointer(Bitmap)
    else begin
      Item.FBitmap := TBitmap.Create;
      AssignBitmap(Item.FBitmap, Bitmap);
    end;
    Item.SelfReleased := True;
  end else
  begin
    Item.FBitmap := nil;
    Item.SelfReleased := False;
  end;
  Result := FImages.Add(Item);
  UsedImage(Item);
end;

function TBitmapImageList.AddHIcon(Icon: HIcon): Integer;
var
  Ic: TIcon;
begin
  Ic := TIcon.Create;
  Ic.Handle := Icon;
  Result := AddIcon(Ic, True, '');
end;

function TBitmapImageList.AddIcon(Icon: TIcon; SelfReleased: Boolean; Ext: string = ''): Integer;
var
  Item: TBitmapImageListImage;
begin
  Item := TBitmapImageListImage.Create(Self);
  Item.Graphic := Icon;
  Item.SelfReleased := SelfReleased;
  Item.Ext := Ext;
  Result := FImages.Add(Item);
  UsedImage(Item);
end;

function TBitmapImageList.AddPathImage(Image: TPathImage;
  FreeImage: Boolean): Integer;
begin
  Result := -1;

  if Image = nil then
    Exit;

  if Image.HIcon <> 0 then
    Result := AddHIcon(Image.HIcon)
  else if Image.Bitmap <> nil then
    Result := AddBitmap(Image.Bitmap)
  else if Image.Icon <> nil then
    Result := AddIcon(Image.Icon, True, '');

  Image.DetachImage;
  if FreeImage then
    F(Image);

  UsedImage(Items[Result]);
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
  FUseList.Clear;
end;

procedure TBitmapImageList.ClearImagesList;
var
  I: Integer;
begin
  for I := 0 to FImages.Count - 1 do
    TBitmapImageListImage(FImages[I]).Free;

  FImages.Clear;
  FUseList.Clear;
end;

function TBitmapImageList.Count: Integer;
begin
  Result := FImages.Count;
end;

constructor TBitmapImageList.Create;
begin
  inherited;
  FImages := TList.Create;
  FUseList := TList.Create;
end;

procedure TBitmapImageList.Delete(Index: Integer);
var
  Item: TBitmapImageListImage;
begin

  Item := FImages[Index];
  FUseList.Remove(Item);
  Item.Graphic := nil;
  F(Item);

  FImages.Delete(Index);

end;

procedure TBitmapImageList.ClearItems;
begin
  FImages.Clear;
  FUseList.Clear;
end;

destructor TBitmapImageList.Destroy;
begin
  Clear;
  F(FImages);
  F(FUseList);
  inherited;
end;

function TBitmapImageList.GetBitmapByIndex(
  Index: Integer): TBitmapImageListImage;
begin
  Result := FImages[Index];
end;

procedure TBitmapImageList.RemoveImage(Image: TBitmapImageListImage);
begin
  FUseList.Remove(Image);
end;

procedure TBitmapImageList.UsedImage(Image: TBitmapImageListImage);
var
  I: Integer;
begin
  RemoveImage(Image);
  FUseList.Add(Image);
  if FUseList.Count > BITMAP_IL_MAX_ITEMS then
  begin
    for I := BITMAP_IL_ITEMS_TO_SWAP_AT_TIME - 1 downto 0 do
    begin
      TBitmapImageListImage(FUseList[I]).SaveToMemory;
      FUseList.Delete(I);
    end;
  end;
end;

{ TBitmapImageListImage }

constructor TBitmapImageListImage.Create(AOwner: TBitmapImageList);
begin
  FOwner := AOwner;
  FMemoryStream := nil;
  DetachImage;
  FBitmap := nil;
  FIcon := nil;
  FIsIcon := False;
end;

destructor TBitmapImageListImage.Destroy;
begin
  inherited;
  F(FMemoryStream);
end;

procedure TBitmapImageListImage.DetachImage;
begin
  F(FMemoryStream);
  SelfReleased := False;
  IsBitmap := True;
  FBitmap := nil;
  FIcon := nil;
end;

function TBitmapImageListImage.GetBitmap: TBitmap;
begin
  FOwner.UsedImage(Self);
  LoadFromMemory;
  Result := FBitmap;
end;

function TBitmapImageListImage.GetGraphic: TGraphic;
begin
  if IsBitmap then
    Result := Bitmap
  else
    Result := Icon;
end;

function TBitmapImageListImage.GetIcon: TIcon;
begin
  FOwner.UsedImage(Self);
  LoadFromMemory;
  Result := FIcon;
end;

procedure TBitmapImageListImage.LoadFromMemory;
begin
  if FMemoryStream = nil then
    Exit;

  FMemoryStream.Seek(0, soFromBeginning);
  if FIsIcon then
  begin
    FIcon := TIcon.Create;
    FIcon.LoadFromStream(FMemoryStream);
  end else
  begin
    FBitmap := TBitmap.Create;
    FBitmap.LoadFromStream(FMemoryStream);
  end;

  F(FMemoryStream);
end;

procedure TBitmapImageListImage.SaveToMemory;
begin
  if not SelfReleased then
    Exit;

  if (FBitmap = nil) and (FIcon = nil) then
    Exit;

  if FMemoryStream <> nil then
    Exit;

  FMemoryStream := TMemoryStream.Create;

  if FBitmap <> nil then
    FBitmap.SaveToStream(FMemoryStream)
  else if FIcon <> nil then
    FIcon.SaveToStream(FMemoryStream);

  FIsIcon := FBitmap = nil;

  F(FBitmap);
  F(FIcon);
end;

procedure TBitmapImageListImage.SetBitmap(const Value: TBitmap);
begin
  F(FMemoryStream);
  FBitmap := Value;
end;

procedure TBitmapImageListImage.SetGraphic(const Value: TGraphic);
begin
  LoadFromMemory;
  if SelfReleased then
  begin
    F(FBitmap);
    F(FIcon);
  end;
  FIcon := nil;
  FBitmap := nil;
  IsBitmap := Value is TBitmap;
  if IsBitmap then
    FBitmap := Value as TBitmap
  else
    FIcon := Value as TIcon;
end;

procedure TBitmapImageListImage.AddToImageList(ImageList: TCustomImageList);
begin
  FOwner.UsedImage(Self);
  LoadFromMemory;

  if FIcon <> nil then
    ImageList_ReplaceIcon(ImageList.Handle, -1, FIcon.Handle)
  else if FBitmap <> nil then
    ImageList.Add(FBitmap, nil);
end;

procedure TBitmapImageListImage.UpdateIcon(Icon: TIcon;
  IsSelfReleased: Boolean);
begin
  SetGraphic(Icon);
  SelfReleased := IsSelfReleased;
end;

end.
