unit uDBDrawing;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Vcl.Graphics,

  UnitDBDeclare,
  TLayered_Bitmap,

  uConstants,
  uRuntime,
  uMemory,
  uFileUtils;

type
  TIconEx = class
  private
    FIcon: TLayeredBitmap;
    FGrayIcon: TLayeredBitmap;
    FIconIndex: Integer;
    function GetGrayIcon: TLayeredBitmap;
  public
    constructor Create(AIconIndex: Integer);
    destructor Destroy; override;
    property IconIndex: Integer read FIconIndex;
    property GrayIcon: TLayeredBitmap read GetGrayIcon;
    property Icon: TLayeredBitmap read FIcon;
  end;

  TIconsEx = class
  private
    Icons: TList;
    FSync: TCriticalSection;
    function GetValueByIndex(Index: Integer): TIconEx;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[index: Integer]: TIconEx read GetValueByIndex; default;
  end;

  TDrawAttributesOption = (daoEXIF, daoNonImage);
  TDrawAttributesOptions = set of TDrawAttributesOption;

procedure DrawAttributes(Bitmap: TBitmap; PistureSize: Integer; Info: TDBPopupMenuInfoRecord);
procedure DrawAttributesEx(HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TDBPopupMenuInfoRecord; Options: TDrawAttributesOptions = []);
procedure DrawAttributesExWide(Bitmap: TBitmap; HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TDBPopupMenuInfoRecord; Options: TDrawAttributesOptions = []);
function GetListItemBorderColor(Data: TDataObject): TColor;
function RectInRect(const R1, R2: TRect): Boolean;

function Icons: TIconsEx;

implementation

uses
  UnitDBKernel,
  uManagerExplorer;

var
  FIcons: TIconsEx = nil;

function Icons: TIconsEx;
begin
  if FIcons = nil then
    FIcons := TIconsEx.Create;

  Result := FIcons;
end;

procedure DrawAttributes(Bitmap: TBitmap; PistureSize: Integer; Info: TDBPopupMenuInfoRecord);
var
  DeltaX: Integer;
begin
  DeltaX := PistureSize - 100;
  DrawAttributesExWide(Bitmap, 0, DeltaX, 0, Info);
end;

procedure DrawAttributesEx(HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TDBPopupMenuInfoRecord; Options: TDrawAttributesOptions = []);
begin
  DrawAttributesExWide(nil, HCanvas, DeltaX, DeltaY, Info, Options);
end;

procedure DrawAttributesExWide(Bitmap: TBitmap; HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TDBPopupMenuInfoRecord; Options: TDrawAttributesOptions = []);
var
  FE, RotationNotInDB: Boolean;
  FileName: string;

  procedure DoDrawIconEx(HCanvas: HDC; xLeft, yTop: Integer; Index: Integer; Disabled: Boolean = False);
  var
    Icon: TIconEx;
    bf: BLENDFUNCTION;
    GrayIco: TLayeredBitmap;
  begin
    if Bitmap <> nil then
    begin
      Icon := Icons[Index];
      if not Disabled then
        Icon.Icon.DoDraw(xLeft, yTop, Bitmap, False)
      else
        Icon.GrayIcon.DoDraw(xLeft, yTop, Bitmap);
    end else
    begin
      if not Disabled then
        DrawIconEx(HCanvas, xLeft, yTop, UnitDBKernel.Icons[Index + 1], 16, 16, 0, 0, DI_NORMAL)
      else
      begin
        Icon := Icons[Index];
        GrayIco := Icon.GrayIcon;

        bf.BlendOp := AC_SRC_OVER;
        bf.BlendFlags := 0;
        bf.AlphaFormat := AC_SRC_ALPHA;
        bf.SourceConstantAlpha := $FF;
        AlphaBlend(HCanvas, xLeft, yTop, GrayIco.Width, GrayIco.Height,
          GrayIco.Canvas.Handle, 0, 0, GrayIco.Width, GrayIco.Height, bf);

      end;
    end;
  end;

begin
  if (Info.ID = 0) and not (daoNonImage in Options) then
    DoDrawIconEx(HCanvas, DeltaX, DeltaY, DB_IC_NEW);

  FileName := Info.FileName;

  if Info.Exists = 0 then
  begin
    FE := FileExistsSafe(FileName);
    if FE then
      Info.Exists := 1
    else
      Info.Exists := -1;
  end;
  FE := Info.Exists <> -1;

  if FolderView then
    if not FE then
    begin
      FileName := Info.FileName;
      FE := FileExistsSafe(FileName);
    end;

  if (daoEXIF in Options) and Info.HasExifHeader then
  begin
    if Info.ID = 0 then
      DoDrawIconEx(HCanvas, 20 + DeltaX, DeltaY, DB_IC_EXIF)
    else
      DoDrawIconEx(HCanvas, 0 + DeltaX, DeltaY,  DB_IC_EXIF);
  end;

  if Info.Encrypted then
    DoDrawIconEx(HCanvas, 20 + DeltaX, DeltaY, DB_IC_KEY);

  case Info.Rating of
    -1:  DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_STAR);
    1:   DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_1);
    2:   DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_2);
    3:   DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_3);
    4:   DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_4);
    5:   DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_5);
    -10: DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_1, True);
    -20: DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_2, True);
    -30: DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_3, True);
    -40: DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_4, True);
    -50: DoDrawIconEx(HCanvas, 80 + DeltaX, DeltaY, DB_IC_RATING_5, True);
  end;

  RotationNotInDB := (Info.ID = 0) and (Info.Rotation and DB_IMAGE_ROTATE_NO_DB > 0);

  case Info.Rotation and DB_IMAGE_ROTATE_MASK of
    DB_IMAGE_ROTATE_90:
      DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_90, RotationNotInDB);
    DB_IMAGE_ROTATE_180:
      DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_180, RotationNotInDB);
    DB_IMAGE_ROTATE_270:
      DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_270, RotationNotInDB);
  end;

  if Info.Access = db_access_private then
    DoDrawIconEx(HCanvas, 40 + DeltaX, DeltaY, DB_IC_PRIVATE);
  if Info.Access = - 10 * db_access_private then
    DoDrawIconEx(HCanvas, 40 + DeltaX, DeltaY, DB_IC_PRIVATE, True);

  if not FE then
  begin
    if Copy(FileName, 1, 2) = '::' then
      DoDrawIconEx(HCanvas, 0 + DeltaX, DeltaY, DB_IC_CD_IMAGE )
    else
      DoDrawIconEx(HCanvas, 0 + DeltaX, DeltaY, DB_IC_DELETE_INFO);
  end;
end;

function GetListItemBorderColor(Data: TDataObject): TColor;
begin
  if not Data.Include then
    Result := $00FFFF
  else
    Result := clHighlight;
end;

function RectInRect(const R1, R2: TRect): Boolean;
begin
 Result := PtInRect(R2, R1.TopLeft) or PtInRect(R2, R1.BottomRight) or PtInRect(R1, R2.TopLeft) or PtInRect(R1, R2.BottomRight);
end;

{ TIconsEx }

constructor TIconsEx.Create;
begin
  Icons := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TIconsEx.Destroy;
begin
  FreeList(Icons);
  F(FSync);
  inherited;
end;

function TIconsEx.GetValueByIndex(Index: Integer): TIconEx;
var
  I: Integer;
  Item: TIconEx;
begin
  FSync.Enter;
  try
    for I := 0 to Icons.Count - 1 do
    begin
      Item := Icons[I];
      if Item.IconIndex = Index then
      begin
        Result := Item;
        Exit;
      end;
    end;
    Item := TIconEx.Create(Index);
    Icons.Add(Item);
    Result := Item;
  finally
    FSync.Leave;
  end;
end;

{ TIconEx }

constructor TIconEx.Create(AIconIndex: Integer);
begin
  FIconIndex := AIconIndex;
  FGrayIcon := nil;
  FIcon := TLayeredBitmap.Create;
  FIcon.LoadFromHIcon(UnitDBKernel.Icons[AIconIndex + 1]);
end;

destructor TIconEx.Destroy;
begin
  F(FIcon);
  F(FGrayIcon);
  inherited;
end;

function TIconEx.GetGrayIcon: TLayeredBitmap;
begin
  if FGrayIcon = nil then
  begin
    FGrayIcon := TLayeredBitmap.Create;
    FGrayIcon.Load(FIcon);
    FGrayIcon.GrayScale;
  end;
  Result := FGrayIcon;
end;

initialization

finalization
  F(FIcons);

end.
