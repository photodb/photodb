unit uDBHint;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, ExtCtrls;

type
  THintStyle = (hsXP, hsVista);

type
   TDBHintWindow = class(THintWindow)
   private
    FBitmap: TBitmap;
    FRegion: THandle;
    procedure FreeRegion;
   protected
    procedure CreateParams (var Params: TCreateParams); override;
    procedure Paint; override;
    procedure Erase(var Message: TMessage); message WM_ERASEBKGND;
   public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     procedure ActivateHint(Rect: TRect; const AHint: String); Override;
   end;

var
  HintStyle: THintStyle = hsVista;

implementation

constructor TDBHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitmap := TBitmap.Create;
  FBitmap.PixelFormat := pf24bit;
end;

destructor TDBHintWindow.Destroy;
begin
  FBitmap.Free;
  FreeRegion;
  inherited;
end;

procedure TDBHintWindow.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $20000;
begin
  inherited;
  Params.Style := Params.Style - WS_BORDER;
  Params.WindowClass.Style := Params.WindowClass.style or CS_DROPSHADOW;
end;

procedure TDBHintWindow.FreeRegion;
begin
  if FRegion <> 0 then
  begin
    SetWindowRgn(Handle, 0, True);
    DeleteObject(FRegion);
    FRegion := 0;
  end;
end;

procedure TDBHintWindow.ActivateHint(Rect: TRect; const AHint: String);
var
  i: Integer;
begin
  Caption := AHint;
  Canvas.Font := Screen.HintFont;
  FBitmap.Canvas.Font := Screen.HintFont;
  DrawText(Canvas.Handle, PWideChar(Caption), Length(Caption), Rect, DT_CALCRECT  or DT_NOPREFIX);
  case HintStyle of
    hsVista:
      begin
        Width := (Rect.Right - Rect.Left) + 16;
        Height := (Rect.Bottom - Rect.Top) + 10;
      end;
    hsXP:
      begin
        Width := (Rect.Right - Rect.Left) + 10;
        Height := (Rect.Bottom - Rect.Top) + 6;
      end;
  end;
  FBitmap.Width := Width;
  FBitmap.Height := Height;
  Left := Rect.Left;
  Top := Rect.Top;
  FreeRegion;
  if HintStyle = hsVista then
  begin
    with Rect do
      FRegion := CreateRoundRectRgn(1, 1, Width, Height, 3, 3);
    if FRegion <> 0 then
      SetWindowRgn(Handle, FRegion, True);
    AnimateWindowProc(Handle, 300, AW_BLEND);
  end;
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, 0, 0, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOSIZE);
end;

procedure DrawGradientVertical(Canvas: TCanvas; Rect: TRect; FromColor, ToColor: TColor);
var
  i, Y: Integer;
  R, G, B: Byte;
begin
   i := 0;
   for Y := Rect.Top to Rect.Bottom - 1 do
   begin
      R := GetRValue(FromColor) + Ceil(((GetRValue(ToColor) - GetRValue(FromColor)) / Rect.Bottom-Rect.Top) * i);
      G := GetGValue(FromColor) + Ceil(((GetGValue(ToColor) - GetGValue(FromColor)) / Rect.Bottom-Rect.Top) * i);
      B := GetBValue(FromColor) + Ceil(((GetBValue(ToColor) - GetBValue(FromColor)) / Rect.Bottom-Rect.Top) * i);
      Canvas.Pen.Color := RGB(R, G, B);
      Canvas.MoveTo(Rect.Left, Y);
      Canvas.LineTo(Rect.Right, Y);
      Inc(i);
   end;
end;

procedure TDBHintWindow.Paint;
var
  CaptionRect: TRect;
begin
  case HintStyle of
    hsVista:
      begin
        DrawGradientVertical(FBitmap.Canvas, GetClientRect, RGB(255, 255, 255),  RGB(229, 229, 240));
        with FBitmap.Canvas do
        begin
          Font.Color := clGray;
          Brush.Style := bsClear;
          Pen.Color := RGB(118, 118, 118);
          RoundRect(1, 1, Width - 1, Height - 1, 6, 6);
          RoundRect(1, 1, Width - 1, Height - 1, 3, 3);
        end;
        CaptionRect := Rect(8, 5, Width, Height);
      end;
    hsXP:
      begin
        with FBitmap.Canvas do
        begin
          Font.Color := clBlack;
          Brush.Style := bsSolid;
          Brush.Color := clInfoBk;
          Pen.Color := RGB(0, 0, 0);
          Rectangle(0, 0, Width, Height);
        end;
        CaptionRect := Rect(5, 3, Width, Height);
      end;
  end;
  DrawText(FBitmap.Canvas.Handle, PWideChar(Caption), Length(Caption), CaptionRect, DT_WORDBREAK or DT_NOPREFIX);
  BitBlt(Canvas.Handle, 0, 0, Width, Height, FBitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TDBHintWindow.Erase(var Message: TMessage);
begin
  Message.Result := 0;
end;

end.
