unit uFormUtils;

interface

uses
  System.Types,
  System.Classes,
  Winapi.Windows,
  Vcl.Graphics;

procedure RenderForm(FormHandle: THandle; Bitmap32: TBitmap; Transparenty: Byte; UpdateFormStyle: Boolean = True); overload;

implementation

procedure RenderForm(FormHandle: THandle; Bitmap32: TBitmap; Transparenty: Byte; UpdateFormStyle: Boolean = True);
var
  zSize: TSize;
  zPoint: TPoint;
  zBf: TBlendFunction;
  TopLeft: TPoint;
  Bounds : TRect;
begin
  if UpdateFormStyle then
    SetWindowLong(FormHandle, GWL_EXSTYLE, GetWindowLong(FormHandle, GWL_EXSTYLE) or WS_EX_LAYERED);

  zSize.cx := Bitmap32.Width;
  zSize.cy := Bitmap32.Height;
  zPoint := Point(0, 0);

  with zBf do
  begin
    BlendOp := AC_SRC_OVER;
    BlendFlags := 0;
    AlphaFormat := AC_SRC_ALPHA;
    SourceConstantAlpha := Transparenty;
  end;
  GetWindowRect(FormHandle, Bounds);

  TopLeft := Point(Bounds.Left, Bounds.Top);

  UpdateLayeredWindow(FormHandle, GetDC(0), @TopLeft, @zSize,
    Bitmap32.Canvas.Handle, @zPoint, 0, @zBf, ULW_ALPHA);
end;

end.
