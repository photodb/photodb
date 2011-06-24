unit uDBDrawing;

interface

uses
  Windows, SysUtils, Graphics, UnitDBDeclare, CCR.Exif, UnitDBCommon, Math,
  Classes, GraphicsBaseTypes, uConstants, uMemory, uFileUtils, Effects,
  uRuntime, TLayered_Bitmap, SyncObjs;

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

procedure DrawAttributes(Bitmap: TBitmap; PistureSize: Integer; Rating, Rotate, Access: Integer; FileName: string;
  Crypted: Boolean; var Exists: Integer; ID: Integer = 0);
procedure DrawAttributesEx(HCanvas: THandle; DeltaX, DeltaY: Integer; Rating, Rotate, Access: Integer;
  FileName: string; Crypted: Boolean; var Exists: Integer; ID: Integer = 0);
function GetListItemBorderColor(Data: TDataObject): TColor;
function RectInRect(const R1, R2: TRect): Boolean;
procedure DrawAttributesExWide(Bitmap: TBitmap; HCanvas: THandle; DeltaX, DeltaY: Integer;
  Rating, Rotate, Access: Integer; FileName: string; Crypted: Boolean; var Exists: Integer; ID: Integer = 0);

implementation

uses
  UnitDBKernel, ExplorerUnit, MPCommonUtilities;

var
  FIcons: TIconsEx = nil;

function Icons: TIconsEx;
begin
  if FIcons = nil then
    FIcons := TIconsEx.Create;

  Result := FIcons;
end;

procedure DrawAttributes(Bitmap: TBitmap; PistureSize: Integer; Rating, Rotate, Access: Integer; FileName: string;
  Crypted: Boolean; var Exists: Integer; ID: Integer = 0);
var
  DeltaX: Integer;
begin
  DeltaX := PistureSize - 100;
  DrawAttributesExWide(Bitmap, 0, DeltaX, 0, Rating, Rotate, Access, FileName, Crypted, Exists, ID);
end;

procedure DrawAttributesEx(HCanvas: THandle; DeltaX, DeltaY: Integer; Rating, Rotate, Access: Integer;
  FileName: string; Crypted: Boolean; var Exists: Integer; ID: Integer = 0);
begin
  DrawAttributesExWide(nil, HCanvas, DeltaX, DeltaY, Rating, Rotate, Access, FileName, Crypted, Exists, ID);
end;

procedure DrawAttributesExWide(Bitmap: TBitmap; HCanvas: THandle; DeltaX, DeltaY: Integer;
  Rating, Rotate, Access: Integer; FileName: string; Crypted: Boolean; var Exists: Integer; ID: Integer = 0);
var
  FE: Boolean;
  ExifData: TExifData;

  procedure DoDrawIconEx(HCanvas: HDC; xLeft, yTop: Integer; Index: Integer; Disabled: Boolean = False);
  var
    Icon: TIconEx;
    bf : BLENDFUNCTION;
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
        Windows.AlphaBlend(HCanvas, xLeft, yTop, GrayIco.Width, GrayIco.Height,
          GrayIco.Canvas.Handle, 0, 0, GrayIco.Width, GrayIco.Height, bf);

       { if HasMMX then
          MPCommonUtilities.AlphaBlend(Icon.FIcon.Canvas.Handle, HCanvas,
                  Rect(0, 0, Icon.FIcon.Width, Icon.FIcon.Height), Point(xLeft, yTop),
                  cbmPerPixelAlpha, $FF, $FFFFFF)
        else
          DrawIconEx(HCanvas, xLeft, yTop, UnitDBKernel.Icons[Index + 1], 16, 16, 0, 0, DI_NORMAL)
      }end;
    end;
  end;

begin

  if ID = 0 then
    DoDrawIconEx(HCanvas, DeltaX, DeltaY, DB_IC_NEW);

  if Exists = 0 then
  begin
    FE := FileExistsSafe(FileName);
    if FE then
      Exists := 1
    else
      Exists := -1;
  end;
  FE := Exists <> -1;

  if FolderView then
    if not FE then
    begin
      FileName := ProgramDir + FileName;
      FE := FileExistsSafe(FileName);
    end;

  if (ExplorerManager <> nil) and ExplorerManager.ShowEXIF then
  begin

    ExifData := TExifData.Create;
    try
      try
        ExifData.LoadFromGraphic(FileName);
        if not ExifData.Empty then
        begin
          if ID = 0 then
            DoDrawIconEx(HCanvas, 20 + DeltaX, DeltaY, DB_IC_EXIF)
          else
            DoDrawIconEx(HCanvas, 0 + DeltaX, DeltaY,  DB_IC_EXIF);
        end;
      except
        //header not found, it's ok
      end;
    finally
      F(ExifData);
    end;
  end;

  if Crypted then
    DoDrawIconEx(HCanvas, 20 + DeltaX, DeltaY, DB_IC_KEY);

  case Rating of
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

  case Rotate of
    DB_IMAGE_ROTATE_90:   DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_90);
    DB_IMAGE_ROTATE_180:  DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_180);
    DB_IMAGE_ROTATE_270:  DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_270);
    -10 * DB_IMAGE_ROTATE_90:  DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_90, True);
    -10 * DB_IMAGE_ROTATE_180: DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_180, True);
    -10 * DB_IMAGE_ROTATE_270: DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTETED_270, True);
  end;
  if Access = db_access_private then
    DoDrawIconEx(HCanvas, 40 + DeltaX, DeltaY, DB_IC_PRIVATE);

  if not FE then
  begin
    if Copy(FileName,1,2) = '::' then
      DoDrawIconEx(HCanvas, 0 + DeltaX, DeltaY, DB_IC_CD_IMAGE )
    else
      DoDrawIconEx(HCanvas, 0 + DeltaX, DeltaY, DB_IC_DELETE_INFO);
  end;
end;

function GetListItemBorderColor(Data : TDataObject) : TColor;
begin
  if not Data.Include then
    Result := $00FFFF
  else
    Result := clHighlight;
end;

function RectInRect(const R1, R2 : TRect) : Boolean;
begin
 Result := PtInRect(R2,R1.TopLeft) or PtInRect(R2,R1.BottomRight) or PtInRect(R1,R2.TopLeft) or PtInRect(R1,R2.BottomRight);
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
