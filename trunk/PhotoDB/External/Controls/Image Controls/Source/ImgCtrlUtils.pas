
{*******************************************************}
{                                                       }
{       Image Controls                                  }
{       Библиотека для работы с изображениями           }
{                                                       }
{       Copyright (c) 2004-2005, Михаил Мостовой        }
{                               (s-mike)                }
{       http://mikesoft.front.ru                        }
{       http://forum.sources.ru                         }
{                                                       }
{*******************************************************}

{
@abstract(Различные процедуры для работы со стандартными классами изображений.)
@author(Михаил Мостовой <mikesoft@front.ru>)
@created(1 января, 2005)
@lastmod(10 апреля, 2005)
}

unit ImgCtrlUtils;

interface

uses Windows, Messages, Graphics, Controls;

const
  { Горизонтальный размер эскиза по умолчанию.
    Используется в процедурах для создания эскизов. }
  HSize = 150;
  { Вертикальный размер эскиза по умолчанию.
    Используется в процедурах для создания эскизов. }  
  VSize = 150;

{ Проверяет, является ли изображение, хранящееся в <b>APicture</b>, пустым. }
function IsEmptyPicture(APicture: TBitmap): Boolean;

{ Создает эскиз изображения. }
procedure MakeThumbNail(const Src, Dest: TBitmap);

{ Создает качественный эскиз изображения <b>SourceBmp</b> шириной и высотой
  не более чем <b>Width</b> и <b>Height</b>. }
function CreateThumbnail(SourceBmp: TBitmap; const Width: Integer = HSize; const Height: Integer = VSize): TBitmap;
{ Процедура, аналогичная по функциональности @link(CreateThumbnail),
  но качество созданного эскиза будет заметно хуже, зато работает быстрее. }
function StretchBitmap(SourceBmp: TBitmap; const Width: Integer = HSize; const Height: Integer = VSize): TBitmap;

{ Создает экземпляр класса TPicture, загружает в него
  изображение из файла <b>FileName</b> и возвращает ссылку на этот класс. }
function LoadPictureFromFile(const FileName: string): TPicture;
{ Загружает графику непосредственно в уже созданный TBitmap. }
procedure LoadGraphicToBitmap(const FileName: string; Bitmap: TBitmap);

{ Копирует часть фона под компонентом Control.
  Удобно для прозрачных компонентов. }
procedure CopyParentImage(Control: TControl; Dest: TCanvas);
    
implementation

uses Math, Types;

function IsEmptyPicture(APicture: TBitmap): Boolean;
begin
  Result := Assigned(APicture) and
              ((APicture.Width = 0) or
               (APicture.Height = 0));
end;

{
  Here is the routine I use in my thumbnail component and I belive it is quite
  fast.
  A tip to gain faster loading of jpegs is to use the TJpegScale.Scale
  property. You can gain a lot by using this correct.

  This routine can only downscale images no upscaling is supported and you
  must correctly set the dest image size. The src.image will be scaled to fit
  in dest bitmap.
}

 //Speed up by Renate Schaaf, Armido, Gary Williams...
procedure MakeThumbNail(const Src, Dest: TBitmap);
type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
var
  x, y, ix, iy: integer;
  x1, x2, x3: integer;

  xscale, yscale: single;
  iRed, iGrn, iBlu, iRatio: Longword;
  p, c1, c2, c3, c4, c5: tRGB24;
  pt, pt1: pRGB24;
  iSrc, iDst, s1: integer;
  i, j, r, g, b, tmpY: integer;

  RowDest, RowSource, RowSourceStart: integer;
  w, h: integer;
  dxmin, dymin: integer;
  ny1, ny2, ny3: integer;
  dx, dy: integer;
  lutX, lutY: array of integer;
begin
  if src.PixelFormat <> pf24bit then src.PixelFormat := pf24bit;
  if dest.PixelFormat <> pf24bit then dest.PixelFormat := pf24bit;
  w := Dest.Width;
  h := Dest.Height;

  if (src.Width <= dest.Width) and (src.Height <= dest.Height) then
  begin
    dest.Assign(src);
    exit;
  end;

  iDst := (w * 24 + 31) and not 31;
  iDst := iDst div 8; //BytesPerScanline
  iSrc := (Src.Width * 24 + 31) and not 31;
  iSrc := iSrc div 8;

  xscale := 1 / (w / src.Width);
  yscale := 1 / (h / src.Height);

  // X lookup table
  SetLength(lutX, w);
  x1 := 0;
  x2 := trunc(xscale);
  for x := 0 to w - 1 do
  begin
    lutX[x] := x2 - x1;
    x1 := x2;
    x2 := trunc((x + 2) * xscale);
  end;

  // Y lookup table
  SetLength(lutY, h);
  x1 := 0;
  x2 := trunc(yscale);
  for x := 0 to h - 1 do
  begin
    lutY[x] := x2 - x1;
    x1 := x2;
    x2 := trunc((x + 2) * yscale);
  end;

  dec(w);
  dec(h);
  RowDest := integer(Dest.Scanline[0]);
  RowSourceStart := integer(Src.Scanline[0]);
  RowSource := RowSourceStart;
  for y := 0 to h do
  begin
    dy := lutY[y];
    x1 := 0;
    x3 := 0;
    for x := 0 to w do
    begin
      dx:= lutX[x];
      iRed:= 0;
      iGrn:= 0;
      iBlu:= 0;
      RowSource := RowSourceStart;
      for iy := 1 to dy do
      begin
        pt := PRGB24(RowSource + x1);
        for ix := 1 to dx do
        begin
          iRed := iRed + pt.R;
          iGrn := iGrn + pt.G;
          iBlu := iBlu + pt.B;
          inc(pt);
        end;
        RowSource := RowSource - iSrc;
      end;
      iRatio := 65535 div (dx * dy);
      pt1 := PRGB24(RowDest + x3);
      pt1.R := (iRed * iRatio) shr 16;
      pt1.G := (iGrn * iRatio) shr 16;
      pt1.B := (iBlu * iRatio) shr 16;
      x1 := x1 + 3 * dx;
      inc(x3,3);
    end;
    RowDest := RowDest - iDst;
    RowSourceStart := RowSource;
  end;

  if dest.Height < 3 then exit;

  // Sharpening...
  s1 := integer(dest.ScanLine[0]);
  iDst := integer(dest.ScanLine[1]) - s1;
  ny1 := Integer(s1);
  ny2 := ny1 + iDst;
  ny3 := ny2 + iDst;
  for y := 1 to dest.Height - 2 do
  begin
    for x := 0 to dest.Width - 3 do
    begin
      x1 := x * 3;
      x2 := x1 + 3;
      x3 := x1 + 6;

      c1 := pRGB24(ny1 + x1)^;
      c2 := pRGB24(ny1 + x3)^;
      c3 := pRGB24(ny2 + x2)^;
      c4 := pRGB24(ny3 + x1)^;
      c5 := pRGB24(ny3 + x3)^;

      r := (c1.R + c2.R + (c3.R * -12) + c4.R + c5.R) div -8;
      g := (c1.G + c2.G + (c3.G * -12) + c4.G + c5.G) div -8;
      b := (c1.B + c2.B + (c3.B * -12) + c4.B + c5.B) div -8;

      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;

      pt1 := pRGB24(ny2 + x2);
      pt1.R := r;
      pt1.G := g;
      pt1.B := b;
    end;
    inc(ny1, iDst);
    inc(ny2, iDst);
    inc(ny3, iDst);
  end;
end;

function CreateThumbnail(SourceBmp: TBitmap; const Width: Integer = HSize; const Height: Integer = VSize): TBitmap;
var
  W, H: Integer;
  ZoomFactor: Extended;
begin
  Result := TBitmap.Create;
  ZoomFactor := Min(Width / SourceBmp.Width, Height / SourceBmp.Height);
  W := Trunc(SourceBmp.Width * ZoomFactor);
  H := Trunc(SourceBmp.Height * ZoomFactor);
  Result.Width := W;
  Result.Height := H;
  MakeThumbNail(SourceBmp, Result);
end;

function StretchBitmap(SourceBmp: TBitmap; const Width: Integer = HSize; const Height: Integer = VSize): TBitmap;
var
  W, H: Integer;
  ZoomFactor: Extended;
begin
  Result := TBitmap.Create;
  ZoomFactor := Min(Width / SourceBmp.Width, Height / SourceBmp.Height);
  W := Trunc(SourceBmp.Width * ZoomFactor);
  H := Trunc(SourceBmp.Height * ZoomFactor);
  Result.Width := W;
  Result.Height := H;
  Result.Canvas.StretchDraw(Rect(0, 0, W, H), SourceBmp);
end;

function LoadPictureFromFile(const FileName: string): TPicture;
begin
  Result := TPicture.Create;
  Result.LoadFromFile(FileName);
end;

procedure LoadGraphicToBitmap(const FileName: string; Bitmap: TBitmap);
var
  Picture: TPicture;
begin
  Picture := LoadPictureFromFile(FileName);
  try
    if Picture.Graphic <> nil then
    begin
      Bitmap.Width := Picture.Width;
      Bitmap.Height := Picture.Height;
      Bitmap.Canvas.Draw(0, 0, Picture.Graphic);
    end;
  finally
    Picture.Free;
  end;
end;

// Подло своровано из RX :-)

type
  TParentControl = class(TWinControl);

procedure CopyParentImage(Control: TControl; Dest: TCanvas);
var
  I, Count, X, Y, SaveIndex: Integer;
  DC: HDC;
  R, SelfR, CtlR: TRect;
begin
  if (Control = nil) or (Control.Parent = nil) then Exit;
  Count := Control.Parent.ControlCount;
  DC := Dest.Handle;
  with Control.Parent do ControlState := ControlState + [csPaintCopy];
  try
    with Control do begin
      SelfR := Bounds(Left, Top, Width, Height);
      X := -Left; Y := -Top;
    end;
    { Copy parent control image }
    SaveIndex := SaveDC(DC);
    try
      SetViewportOrgEx(DC, X, Y, nil);
      IntersectClipRect(DC, 0, 0, Control.Parent.ClientWidth,
        Control.Parent.ClientHeight);
      with TParentControl(Control.Parent) do begin
        Perform(WM_ERASEBKGND, DC, 0);
        PaintWindow(DC);
      end;
    finally
      RestoreDC(DC, SaveIndex);
    end;
    { Copy images of graphic controls }
    for I := 0 to Count - 1 do begin
      if Control.Parent.Controls[I] = Control then Break
      else if (Control.Parent.Controls[I] <> nil) and
        (Control.Parent.Controls[I] is TGraphicControl) then
      begin
        with TGraphicControl(Control.Parent.Controls[I]) do begin
          CtlR := Bounds(Left, Top, Width, Height);
          if Bool(IntersectRect(R, SelfR, CtlR)) and Visible then begin
            ControlState := ControlState + [csPaintCopy];
            SaveIndex := SaveDC(DC);
            try
              SaveIndex := SaveDC(DC);
              SetViewportOrgEx(DC, Left + X, Top + Y, nil);
              IntersectClipRect(DC, 0, 0, Width, Height);
              Perform(WM_PAINT, DC, 0);
            finally
              RestoreDC(DC, SaveIndex);
              ControlState := ControlState - [csPaintCopy];
            end;
          end;
        end;
      end;
    end;
  finally
    with Control.Parent do ControlState := ControlState - [csPaintCopy];
  end;
end;

end.
 