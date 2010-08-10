unit uDBDrawing;

interface

uses Windows, SysUtils, Graphics, UnitDBDeclare, Exif, UnitDBCommon, Math,
     GraphicsBaseTypes;

procedure DrawAttributes(Bitmap : TBitmap; PistureSize : integer; Rating, Rotate, Access : Integer; FileName : String; Crypted : Boolean; var Exists : integer; ID : integer = 0);
function GetListItemBorderColor(Data : TDataObject) : TColor;
function RectInRect(const R1, R2 : TRect) : Boolean;

implementation

uses UnitDBKernel, Dolphin_DB, ExplorerUnit;

procedure DrawAttributes(Bitmap : TBitmap; PistureSize : integer; Rating,Rotate, Access : Integer; FileName : String; Crypted : Boolean; var Exists : integer; ID : integer = 0);
var
  FExif : TExif;
  failture : boolean;
  DeltaX : integer;
  FE : boolean;
begin
  DeltaX := PistureSize - 100;
  if ID = 0 then
    DrawIconEx(Bitmap.Canvas.Handle, 0 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_NEW+1], 16, 16, 0, 0, DI_NORMAL);

  FE:=true;
  if Exists = 0 then
  begin
    FE:=FileExists(FileName);
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

  if ExplorerManager.ShowEXIF then
  begin
    FExif := TExif.Create;
    try
      Failture := False;
      try
        FExif.ReadFromFile(FileName);
      except
        Failture:=true;
      end;
      if FExif.Valid and not failture then
      begin
        if Id=0 then
          DrawIconEx(Bitmap.Canvas.Handle, 20 + DeltaX, 0, UnitDBKernel.icons[DB_IC_EXIF + 1], 16, 16, 0, 0, DI_NORMAL)
        else
          DrawIconEx(Bitmap.Canvas.Handle, 0 + DeltaX, 0,  UnitDBKernel.icons[DB_IC_EXIF + 1], 16, 16, 0, 0, DI_NORMAL);
      end;
    finally
      FExif.Free;
    end;
  end;

  if Crypted then
    DrawIconEx(Bitmap.Canvas.Handle, 20 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_KEY + 1], 16, 16, 0, 0, DI_NORMAL);

  case Rating of
    1: DrawIconEx(Bitmap.Canvas.Handle, 80 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_RATING_1 + 1], 16, 16, 0, 0, DI_NORMAL);
    2: DrawIconEx(Bitmap.Canvas.Handle, 80 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_RATING_2 + 1], 16, 16, 0, 0, DI_NORMAL);
    3: DrawIconEx(Bitmap.Canvas.Handle, 80 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_RATING_3 + 1], 16, 16, 0, 0, DI_NORMAL);
    4: DrawIconEx(Bitmap.Canvas.Handle, 80 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_RATING_4 + 1], 16, 16, 0, 0, DI_NORMAL);
    5: DrawIconEx(Bitmap.Canvas.Handle, 80 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_RATING_5 + 1], 16, 16, 0, 0, DI_NORMAL);
  end;

  case Rotate of
    DB_IMAGE_ROTATED_90: DrawIconEx(Bitmap.Canvas.Handle,  60 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_ROTETED_90 + 1], 16, 16, 0, 0, DI_NORMAL);
    DB_IMAGE_ROTATED_180: DrawIconEx(Bitmap.Canvas.Handle, 60 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_ROTETED_180 + 1], 16, 16, 0, 0, DI_NORMAL);
    DB_IMAGE_ROTATED_270: DrawIconEx(Bitmap.Canvas.Handle, 60 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_ROTETED_270 + 1], 16, 16, 0, 0, DI_NORMAL);
  end;
  if Access = db_access_private then
    DrawIconEx(Bitmap.Canvas.Handle, 40 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_PRIVATE + 1], 16, 16, 0, 0, DI_NORMAL);

  if not FE then
  begin
    if Copy(FileName,1,2) = '::' then
      DrawIconEx(Bitmap.Canvas.Handle, 0 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_CD_IMAGE + 1], 16, 16, 0, 0, DI_NORMAL)
    else
      DrawIconEx(Bitmap.Canvas.Handle, 0 + DeltaX, 0, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 16, 16, 0, 0, DI_NORMAL);
  end;
end;

function GetListItemBorderColor(Data : TDataObject) : TColor;
begin
  if not Data.Include then
    Result := $00FFFF
  else
    Result := Theme_ListSelectColor;
end;

function RectInRect(const R1, R2 : TRect) : Boolean;
begin
 Result := PtInRect(R2,R1.TopLeft) or PtInRect(R2,R1.BottomRight) or PtInRect(R1,R2.TopLeft) or PtInRect(R1,R2.BottomRight);
end;

end.
