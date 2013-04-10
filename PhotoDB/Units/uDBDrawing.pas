unit uDBDrawing;

interface

uses
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Vcl.Graphics,

  Dmitry.Utils.Files,
  Dmitry.Graphics.LayeredBitmap,

  UnitDBDeclare,

  uDBIcons,
  uConstants,
  uRuntime,
  uMemory;

type
  TDrawAttributesOption = (daoEXIF, daoNonImage);
  TDrawAttributesOptions = set of TDrawAttributesOption;

procedure DrawAttributes(Bitmap: TBitmap; PistureSize: Integer; Info: TMediaItem);
procedure DrawAttributesEx(HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TMediaItem; Options: TDrawAttributesOptions = []);
procedure DrawAttributesExWide(Bitmap: TBitmap; HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TMediaItem; Options: TDrawAttributesOptions = []);
function GetListItemBorderColor(Data: TLVDataObject): TColor;
function RectInRect(const R1, R2: TRect): Boolean;

implementation

uses
  uManagerExplorer;

procedure DrawAttributes(Bitmap: TBitmap; PistureSize: Integer; Info: TMediaItem);
var
  DeltaX: Integer;
begin
  DeltaX := PistureSize - 100;
  DrawAttributesExWide(Bitmap, 0, DeltaX, 0, Info);
end;

procedure DrawAttributesEx(HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TMediaItem; Options: TDrawAttributesOptions = []);
begin
  DrawAttributesExWide(nil, HCanvas, DeltaX, DeltaY, Info, Options);
end;

procedure DrawAttributesExWide(Bitmap: TBitmap; HCanvas: THandle; DeltaX, DeltaY: Integer; Info: TMediaItem; Options: TDrawAttributesOptions = []);
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
      Icon := Icons.IconsEx[Index];
      if not Disabled then
        Icon.Icon.DoDraw(xLeft, yTop, Bitmap, False)
      else
        Icon.GrayIcon.DoDraw(xLeft, yTop, Bitmap);
    end else
    begin
      if not Disabled then
        DrawIconEx(HCanvas, xLeft, yTop, Icons[Index], 16, 16, 0, 0, DI_NORMAL)
      else
      begin
        Icon := Icons.IconsEx[Index];
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
      DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTATED_90, RotationNotInDB);
    DB_IMAGE_ROTATE_180:
      DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTATED_180, RotationNotInDB);
    DB_IMAGE_ROTATE_270:
      DoDrawIconEx(HCanvas, 60 + DeltaX, DeltaY, DB_IC_ROTATED_270, RotationNotInDB);
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

function GetListItemBorderColor(Data: TLVDataObject): TColor;
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

end.
