unit uDBDrawing;

interface

uses Windows, SysUtils, Graphics, UnitDBDeclare, CCR.Exif, UnitDBCommon, Math,
     Classes, GraphicsBaseTypes, uConstants, uMemory;

procedure DrawAttributes(Bitmap : TBitmap; PistureSize : integer; Rating, Rotate, Access : Integer; FileName : String; Crypted : Boolean; var Exists : integer; ID : integer = 0);
procedure DrawAttributesEx(HCanvas : THandle; DeltaX, DeltaY : Integer; Rating, Rotate, Access : Integer; FileName : String; Crypted : Boolean; var Exists : Integer; ID : Integer = 0);
function GetListItemBorderColor(Data : TDataObject) : TColor;
function RectInRect(const R1, R2 : TRect) : Boolean;

implementation

uses UnitDBKernel, Dolphin_DB, ExplorerUnit;

procedure DrawAttributes(Bitmap : TBitmap; PistureSize : Integer; Rating, Rotate, Access : Integer; FileName : String; Crypted : Boolean; var Exists : Integer; ID : Integer = 0);
var
  DeltaX : Integer;
begin
  DeltaX := PistureSize - 100;
  DrawAttributesEx(Bitmap.Canvas.Handle, DeltaX, 0, Rating, Rotate, Access, FileName, Crypted, Exists, ID);
end;

procedure DrawAttributesEx(HCanvas : THandle; DeltaX, DeltaY : Integer; Rating, Rotate, Access : Integer; FileName : String; Crypted : Boolean; var Exists : Integer; ID : Integer = 0);
var
  FS: TFileStream;
  FE : boolean;
begin
  if ID = 0 then
    DrawIconEx(HCanvas, DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_NEW+1], 16, 16, 0, 0, DI_NORMAL);

  if Exists = 0 then
  begin
    FE := FileExists(FileName);
    if FE then
      Exists := 1
    else
      Exists := -1;
  end;
  FE := Exists <> -1;

  if FolderView then
  if not FE then
  begin
    FileName:=ProgramDir + FileName;
    FE := FileExists(FileName);
  end;

  if (ExplorerManager <> nil) and ExplorerManager.ShowEXIF then
  begin
    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      if HasExifHeader(FS) then
      begin
        F(FS);
        if ID = 0 then
          DrawIconEx(HCanvas, 20 + DeltaX, DeltaY, UnitDBKernel.icons[DB_IC_EXIF + 1], 16, 16, 0, 0, DI_NORMAL)
        else
          DrawIconEx(HCanvas, 0 + DeltaX, DeltaY,  UnitDBKernel.icons[DB_IC_EXIF + 1], 16, 16, 0, 0, DI_NORMAL);
      end;
    finally
      F(FS);
    end;
  end;

  if Crypted then
    DrawIconEx(HCanvas, 20 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_KEY + 1], 16, 16, 0, 0, DI_NORMAL);

  case Rating of
    -1: DrawIconEx(HCanvas, 80 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_RATING_STAR + 1], 16, 16, 0, 0, DI_NORMAL);
    1:  DrawIconEx(HCanvas, 80 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_RATING_1 + 1], 16, 16, 0, 0, DI_NORMAL);
    2:  DrawIconEx(HCanvas, 80 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_RATING_2 + 1], 16, 16, 0, 0, DI_NORMAL);
    3:  DrawIconEx(HCanvas, 80 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_RATING_3 + 1], 16, 16, 0, 0, DI_NORMAL);
    4:  DrawIconEx(HCanvas, 80 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_RATING_4 + 1], 16, 16, 0, 0, DI_NORMAL);
    5:  DrawIconEx(HCanvas, 80 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_RATING_5 + 1], 16, 16, 0, 0, DI_NORMAL);
  end;

  case Rotate of
    DB_IMAGE_ROTATE_90: DrawIconEx(HCanvas,  60 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_ROTETED_90 + 1], 16, 16, 0, 0, DI_NORMAL);
    DB_IMAGE_ROTATE_180: DrawIconEx(HCanvas, 60 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_ROTETED_180 + 1], 16, 16, 0, 0, DI_NORMAL);
    DB_IMAGE_ROTATE_270: DrawIconEx(HCanvas, 60 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_ROTETED_270 + 1], 16, 16, 0, 0, DI_NORMAL);
  end;
  if Access = db_access_private then
    DrawIconEx(HCanvas, 40 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_PRIVATE + 1], 16, 16, 0, 0, DI_NORMAL);

  if not FE then
  begin
    if Copy(FileName,1,2) = '::' then
      DrawIconEx(HCanvas, 0 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_CD_IMAGE + 1], 16, 16, 0, 0, DI_NORMAL)
    else
      DrawIconEx(HCanvas, 0 + DeltaX, DeltaY, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 16, 16, 0, 0, DI_NORMAL);
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

end.
