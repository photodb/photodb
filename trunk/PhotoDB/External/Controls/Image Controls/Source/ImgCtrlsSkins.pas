
{*******************************************************}
{                                                       }
{       Image Controls                                  }
{       Библиотека для работы с изображениями           }
{                                                       }
{       Copyright (c) 2004-2005, Михаил Мостовой        }
{                               (s-mike)                }
{       http://forum.sources.ru                         }
{       http://mikesoft.front.ru                        }
{                                                       }
{*******************************************************}

{
@abstract(Вспомогательные процедуры для заполнения изображения текстурой
Используются в @link(TTexturePanel).)
@author(Михаил Мостовой <mikesoft@front.ru>)
@created(февраль 2005)
@lastmod(19 марта, 2005)
}

unit ImgCtrlsSkins;

interface

uses Types, Graphics;

{ Простое заполнение изображения текстурой. }
procedure FillRectWithBitmap(Skin: TBitmap; Canvas: TCanvas; const Dest: TRect);
{ Заполнение путем размноения центральной и крайних частей изображения. }
procedure FillRectWithSkin(Skin: TBitmap; Canvas: TCanvas; const Dest: TRect);

implementation

procedure FillRectWithBitmap(Skin: TBitmap; Canvas: TCanvas; const Dest: TRect);
var
  I, N, SkinWidth, SkinHeight, ClientWidth, ClientHeight: Integer;
  R: TRect;
begin
  if Assigned(Skin) then
  begin
    SkinWidth := Skin.Width;
    SkinHeight := Skin.Height;
    if (SkinWidth = 0) or (SkinHeight = 0) then Exit;

    ClientWidth := Dest.Right - Dest.Left;
    ClientHeight := Dest.Bottom - Dest.Top;

    R := Skin.Canvas.ClipRect;
    I := 0;
    while I < ClientWidth do
    begin
      N := 0;
      while N < ClientHeight do
      begin
        Canvas.CopyRect(Rect(I, N, I + SkinWidth, N + SkinHeight), Skin.Canvas, R);

        Inc(N, SkinHeight);
      end;
      Inc(I, SkinWidth);
    end;
  end;
end;

procedure FillRectWithSkin(Skin: TBitmap; Canvas: TCanvas; const Dest: TRect);
var
  I, N, PartWidth, PartHeight, HPartsCount, VPartsCount,
  ClientWidth, ClientHeight: Integer;
  R: TRect;
begin
  if Assigned(Skin) then
  begin
    PartWidth := Skin.Width div 3;
    PartHeight := Skin.Height div 3;
    if (PartWidth = 0) or (PartHeight = 0) then Exit;

    ClientWidth := Dest.Right - Dest.Left;
    ClientHeight := Dest.Bottom - Dest.Top;
    HPartsCount := ClientWidth div PartWidth;
    VPartsCount := ClientHeight div PartHeight;

    R := Rect(PartWidth, PartHeight, PartWidth * 2, PartHeight * 2);
    I := 0;
    while I < ClientWidth do
    begin
      N := 0;
      while N < ClientHeight do
      begin
        Canvas.CopyRect(Rect(I, N, I + PartWidth, N + PartHeight), Skin.Canvas, R);

        Inc(N, PartHeight);
      end;
      Inc(I, PartWidth);
    end;

    N := 0;
    R := Rect(PartWidth, 0, PartWidth * 2, PartHeight);
    for I := 1 to HPartsCount do
    begin
      Canvas.CopyRect(Rect(N, 0, N + PartWidth, PartHeight), Skin.Canvas, R);
      Inc(N, PartWidth);
    end;
    N := 0;
    R := Rect(PartWidth, Skin.Height - PartHeight, PartWidth * 2, Skin.Height);
    for I := 1 to HPartsCount do
    begin
      Canvas.CopyRect(Rect(N, ClientHeight - PartHeight, N + PartWidth, ClientHeight), Skin.Canvas, R);
      Inc(N, PartWidth);
    end;

    N := 0;
    R := Rect(0, PartHeight, PartWidth, Skin.Height - PartHeight);
    for I := 1 to VPartsCount do
    begin
      Canvas.CopyRect(Rect(0, N, PartWidth, N + PartHeight), Skin.Canvas, R);
      Inc(N, PartHeight);
    end;
    N := 0;
    R := Rect(Skin.Width - PartWidth, PartHeight, Skin.Width, Skin.Height - PartHeight);
    for I := 1 to VPartsCount do
    begin
      Canvas.CopyRect(Rect(ClientWidth - PartWidth, N, ClientWidth, N + PartHeight), Skin.Canvas, R);
      Inc(N, PartHeight);
    end;

    R := Rect(0, 0, PartWidth, PartHeight);
    Canvas.CopyRect(R, Skin.Canvas, R);
    Canvas.CopyRect(Rect(ClientWidth - PartWidth, 0, ClientWidth, PartHeight), Skin.Canvas, Rect(Skin.Width - PartWidth, 0, Skin.Width, PartHeight));
    Canvas.CopyRect(Rect(0, ClientHeight - PartHeight, PartWidth, ClientHeight), Skin.Canvas, Rect(0, Skin.Height - PartHeight, PartWidth, Skin.Height));
    Canvas.CopyRect(Rect(ClientWidth - PartWidth, ClientHeight - PartHeight, ClientWidth, ClientHeight), Skin.Canvas, Rect(Skin.Width - PartWidth, Skin.Height - PartHeight, Skin.Width, Skin.Height));
  end;
end;

end.
