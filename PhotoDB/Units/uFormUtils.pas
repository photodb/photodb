unit uFormUtils;

interface

uses Windows, Graphics, Forms, Classes;

procedure RenderForm(Form : TForm; Bitmap32 : TBitmap; Transparenty : Byte);

implementation

procedure RenderForm(Form : TForm; Bitmap32 : TBitmap; Transparenty : Byte);
var
  zSize: TSize;
  zPoint: TPoint;
  zBf: TBlendFunction;
  TopLeft: TPoint;
begin
  SetWindowLong(Form.Handle, GWL_EXSTYLE,
    GetWindowLong(Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);

  Form.Width := Bitmap32.Width;
  Form.Height := Bitmap32.Height;

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
  TopLeft := Form.BoundsRect.TopLeft;

  UpdateLayeredWindow(Form.Handle, GetDC(0), @TopLeft, @zSize,
    Bitmap32.Canvas.Handle, @zPoint, 0, @zBf, ULW_ALPHA);
end;


end.
