unit Dmitry.Graphics.LayeredBitmap;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  Winapi.Windows,
  Winapi.CommCtrl,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Dmitry.Memory,
  Dmitry.Graphics.Types;

type
  TLayeredBitmap = class(TBitmap)
  private
    FIsLayered: Boolean;
    FHightliteArray: array[0..255] of Byte;
    procedure SetIsLayered(const Value: Boolean);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromBitmap(Bitmap: TBitmap);
    procedure InvertLayeredChannel;
    procedure SaveToBitmap(Bitmap: TBitmap);
    procedure LoadLayered(Bitmap: TBitmap; Mode: Integer);
    procedure DoDraw(X, Y: Integer; Bitmap: TBitmap; IsHightLite: Boolean = False);
    procedure DoDrawGrayscale(X, Y: Integer; Bitmap: TBitmap);
    procedure DoLayeredDraw(X, Y: Integer; Layered: Byte; Bitmap: TBitmap);
    procedure DoStreachDraw(X, Y, NewWidth, NewHeight: Integer; Bitmap: TBitmap);
    procedure DoStreachDrawGrayscale(X, Y, Newwidth, Newheight: Integer; Bitmap: TBitmap);
    procedure LoadFromHIcon(Icon: HIcon; FWidth: Integer = 0; FHeight: Integer = 0; Background: TColor = clBlack);
    procedure Load(Image: TLayeredBitmap);
    procedure GrayScale;
    property IsLayered: Boolean read FIsLayered write SetIsLayered;
  end;

implementation

constructor TLayeredBitmap.Create;
var
  I: Integer;
begin
  inherited;
  FIsLayered := False;
  PixelFormat := pf32Bit;
  for I := 0 to 255 do
    FHightliteArray[I] := Round(255 * Power(I / 255, 0.8));
end;

destructor TLayeredBitmap.Destroy;
begin
  inherited;
end;

procedure TLayeredBitmap.DoDraw(X, Y: Integer; Bitmap: TBitmap; IsHightLite: Boolean = False);
var
  I, J, H, W, X1: Integer;
  BeginY, EndY, BeginX, EndX: Integer;
  PD: PARGB;
  PS: PARGB32;
  CL, LI: Integer;
  R, G, B: Byte;
begin
  HandleNeeded;
  Bitmap.PixelFormat := pf24bit;
  H := Bitmap.Height;
  W := Bitmap.Width;
  BeginX := Max(0, X);
  BeginY := Max(0, Y);
  EndX := Min(W, X + Width) - 1;
  EndY := Min(H, Y + Height) - 1;
  for I := BeginY to EndY do
  begin
    PD := Bitmap.ScanLine[I];
    PS := Scanline[I - Y];

    if IsHightLite and FIsLayered then
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        R := PS[X1].R;
        G := PS[X1].G;
        B := PS[X1].B;
        R := FHightliteArray[R];
        G := FHightliteArray[G];
        B := FHightliteArray[B];
        CL := PS[X1].L;
        LI := 255 - CL;
        PD[J].R := (PD[J].R * LI + R * CL + 127) div 255;
        PD[J].G := (PD[J].G * LI + G * CL + 127) div 255;
        PD[J].B := (PD[J].B * LI + B * CL + 127) div 255;
      end;
    end else if IsHightLite and not FIsLayered then
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        R := PS[X1].R;
        G := PS[X1].G;
        B := PS[X1].B;
        R := FHightliteArray[R];
        G := FHightliteArray[G];
        B := FHightliteArray[B];
        PD[J].R := R;
        PD[J].G := G;
        PD[J].B := B;
      end;
    end else if not IsHightLite and FIsLayered then
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        R := PS[X1].R;
        G := PS[X1].G;
        B := PS[X1].B;
        CL := PS[X1].L;
        LI := 255 - CL;
        PD[J].R := (PD[J].R * LI + R * CL + 127) div 255;
        PD[J].G := (PD[J].G * LI + G * CL + 127) div 255;
        PD[J].B := (PD[J].B * LI + B * CL + 127) div 255;
      end;
    end else
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        R := PS[X1].R;
        G := PS[X1].G;
        B := PS[X1].B;
        PD[J].R := R;
        PD[J].G := G;
        PD[J].B := B;
      end;
    end;
  end;
end;

procedure TLayeredBitmap.DoDrawGrayscale(X, Y: Integer; Bitmap: TBitmap);
var
  I, J, H, W, X1: Integer;
  BeginY, EndY, BeginX, EndX: Integer;
  PD: PARGB;
  PS: PARGB32;
  C, CL, LI: Integer;
begin
  HandleNeeded;
  Bitmap.PixelFormat := pf24bit;
  H := Bitmap.Height;
  W := Bitmap.Width;
  BeginX := Max(0, X);
  BeginY := Max(0, Y);
  EndX := Min(W, X + Width) - 1;
  EndY := Min(H, Y + Height) - 1;
  for I := BeginY to EndY do
  begin
    PD := Bitmap.ScanLine[I];
    PS := Scanline[I - Y];
    if FIsLayered then
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        CL := PS[X1].L;
        LI := 255 - CL;
        C := (PS[X1].R * 77 + PS[X1].G * 151 + PS[X1].B * 28) shr 8;
        PD[J].R := (PD[J].R * LI + C * CL + 127) div 255;
        PD[J].G := (PD[J].G * LI + C * CL + 127) div 255;
        PD[J].B := (PD[J].B * LI + C * CL + 127) div 255;
      end;
    end else
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        PD[J].R := PS[X1].R;
        PD[J].G := PS[X1].G;
        PD[J].B := PS[X1].B;
      end;
    end;
  end;
end;

procedure TLayeredBitmap.DoLayeredDraw(X, Y: Integer; Layered: Byte; Bitmap: TBitmap);
var
  I, J, H, W, X1: Integer;
  BeginY, EndY, BeginX, EndX: Integer;
  PD: PARGB;
  PS: PARGB32;
  CL, LI: Integer;
begin
  HandleNeeded;
  Bitmap.PixelFormat := pf24bit;
  H := Bitmap.Height;
  W := Bitmap.Width;
  BeginX := Max(0, X);
  BeginY := Max(0, Y);
  EndX := Min(W, X + Width) - 1;
  EndY := Min(H, Y + Height) - 1;
  for I := BeginY to EndY do
  begin
    PD := Bitmap.ScanLine[I];
    PS := Scanline[I - Y];
    if FIsLayered then
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        LI := PS[X1].L * Layered div 255;
        CL := 255 - LI;
        PD[J].R := (PD[J].R * CL + PS[X1].R * LI + 127) div 255;
        PD[J].G := (PD[J].G * CL + PS[X1].G * LI + 127) div 255;
        PD[J].B := (PD[J].B * CL + PS[X1].B * LI + 127) div 255;
      end
    end else
    begin
      for J := BeginX to EndX do
      begin
        X1 := J - X;
        PD[J].R := PS[X1].R;
        PD[J].G := PS[X1].G;
        PD[J].B := PS[X1].B;
      end;
    end;
  end;
end;

procedure TLayeredBitmap.DoStreachDraw(X, Y, NewWidth, NewHeight: Integer; Bitmap: TBitmap);
var
  I, J, H, W: Integer;
  BeginY, EndY, BeginX, EndX: Integer;
  PS: array of PARGB32;
  PD: PARGB;
  Ccw, Cch: Integer;
  ScaleX, ScaleY: Extended;
  Cr, Cg, Cb, Cl, Ccc: Integer;
  DX, DY: Integer;
  LI: Byte;
begin
  if (Height = 0) or (Width = 0) then
    Exit;

  HandleNeeded;
  if (NewWidth = Width) and (NewHeight = Height) then
  begin
    DoDraw(X, Y, Bitmap);
    Exit;
  end;

  SetLength(PS, Height);
  for I := 0 to Height - 1 do
    PS[I] := ScanLine[I];

  Bitmap.PixelFormat := pf24bit;
  H := Bitmap.Height;
  W := Bitmap.Width;
  ScaleX := NewWidth / Width;
  ScaleY := NewHeight / Height;

  if ScaleX > 1 then DX := 0 else DX := 1;
  if ScaleY > 1 then DY := 0 else DY := 1;

  BeginY := Max(0, Y);
  BeginX := Max(0, X);
  EndY := Min(H, Y + NewHeight) - 1;
  EndX := Min(W, X + NewWidth) - 1;
  for I := BeginY to EndY do
  begin
    PD := Bitmap.ScanLine[I];
    for J := BeginX to EndX do
    begin
      CCC := 0;
      CR := 0;
      CG := 0;
      CB := 0;
      CL := 0;
      for cch := Round(((I - Y) / ScaleY)) to Min(Round(((I - Y + 1) / ScaleY)) - DY, Height - 1) do
      for ccw := Round(((J - X) / ScaleX)) to Min(Round(((J - X + 1) / ScaleX)) - DY, Width - 1) do
      begin
        Inc(CCC);
        Inc(CR, PS[cch][ccw].R);
        Inc(CG, PS[cch][ccw].G);
        Inc(CB, PS[cch][ccw].B);
        Inc(CL, PS[cch][ccw].L);
      end;

      if ccc = 0 then
        Continue;

      CR := CR div ccc;
      CG := CG div ccc;
      CB := CB div ccc;
      CL := CL div ccc;

      if FIsLayered then
      begin
        LI := 255 - CL;
        PD[J].R := (PD[J].R * LI + CR * CL + 127) div 255;
        PD[J].G := (PD[J].G * LI + CG * CL + 127) div 255;
        PD[J].B := (PD[J].B * LI + CB * CL + 127) div 255;
      end else
      begin
        PD[J].R := CR;
        PD[J].G := CG;
        PD[J].B := CB;
      end;
    end;
  end;
end;

procedure TLayeredBitmap.DoStreachDrawGrayscale(X, Y, NewWidth, NewHeight: integer;
  Bitmap: TBitmap);
var
  I, J, H, W, C: Integer;
  BeginY, EndY, BeginX, EndX: Integer;
  PS: array of PARGB32;
  PD: PARGB;
  CCW, CCH: Integer;
  ScaleX, ScaleY: Extended;
  CR, CG, CB, CL, CCC: Integer;
  DX, DY: Integer;
  LI: Byte;
begin
  if (Height = 0) or (Width = 0) then
    Exit;

  HandleNeeded;
  if (NewWidth = Width) and (NewHeight = Height) then
  begin
    DoDrawGrayscale(X, Y, Bitmap);
    Exit;
  end;

  SetLength(PS, Height);
  for I := 0 to Height - 1 do
    PS[I] := ScanLine[I];

  Bitmap.PixelFormat := pf24bit;
  H := Bitmap.Height;
  W := Bitmap.Width;
  ScaleX := NewWidth / Width;
  ScaleY := NewHeight / Height;

  if ScaleX > 1 then DX := 0 else DX := 1;
  if ScaleY > 1 then DY := 0 else DY := 1;

  BeginY := Max(0, Y);
  BeginX := Max(0, X);
  EndY := Min(H, Y + NewHeight) - 1;
  EndX := Min(W, X + NewWidth) - 1;
  for I := BeginY to EndY do
  begin
    PD := Bitmap.ScanLine[I];
    for J := BeginX to EndX do
    begin
      CCC := 0;
      CR := 0;
      CG := 0;
      CB := 0;
      CL := 0;
      for CCH := Round(((I - Y) / ScaleY)) to Min(Round(((I - X + 1) / ScaleY)) - DY, Height - 1) do
      for CCW := Round(((J - X) / ScaleX)) to Min(Round(((I - X + 1) / ScaleX)) - DY, Width - 1) do
      begin
        Inc(CCC);
        Inc(CR, PS[CCH][CCW].R);
        Inc(CG, PS[CCH][CCW].G);
        Inc(CB, PS[CCH][CCW].B);
        Inc(CL, PS[CCH][CCW].L);
      end;

      if CCC = 0 then
        Continue;

      CR := CR div CCC;
      CG := CG div CCC;
      CB := CB div CCC;
      CL := CL div CCC;

      C := (CR * 77 + CG * 151 + CB * 28) shr 8;

      if FIsLayered then
      begin
        LI := 255 - CL;
        PD[J].R := (PD[J].R * CL + C * LI + 127) div 255;
        PD[J].G := (PD[J].G * CL + C * LI + 127) div 255;
        PD[J].B := (PD[J].B * CL + C * LI + 127) div 255;
      end else
      begin
        PD[J].R := C;
        PD[J].G := C;
        PD[J].B := C;
      end;
    end;
  end;
end;

procedure TLayeredBitmap.GrayScale;
var
  P: PARGB32;
  I, J, C: Integer;
begin
  HandleNeeded;
  for I := 0 to Height - 1 do
  begin
    P := ScanLine[I];
    for J := 0 to Width - 1 do
    begin
      C := (P[J].R * 77 + P[J].G * 151 + P[J].B * 28) shr 8;
      P[J].R := C;
      P[J].G := C;
      P[J].B := C;
    end;
  end;
end;

procedure TLayeredBitmap.InvertLayeredChannel;
var
  P: PARGB32;
  I, J: Integer;
begin
  HandleNeeded;
  for I := 0 to Height - 1 do
  begin
    P := ScanLine[I];
    for J := 0 to Width - 1 do
      P[J].L := 255 - P[J].L;
  end;
end;

procedure TLayeredBitmap.Load(Image: TLayeredBitmap);
var
  I, J: Integer;
  PS, PD: PARGB32;
begin
  if Image = nil then
    Exit;

  HandleNeeded;
  SetSize(Image.Width, Image.Height);
  IsLayered := Image.IsLayered;

  if (Height = 0) or (Width = 0) then
    Exit;

  for I := 0 to Height - 1 do
  begin
    PS := Image.ScanLine[I];
    PD := ScanLine[I];
    for J := 0 to Width - 1 do
      PD[J] := PS[J];

  end;
end;

procedure TLayeredBitmap.LoadFromBitmap(Bitmap: TBitmap);
var
  I, J: Integer;
  PS: PARGB;
  PD, PS32: PARGB32;
begin
  HandleNeeded;
  SetSize(Bitmap.Width, Bitmap.Height);

  if Bitmap.PixelFormat = pf24Bit then
  begin
    for I := 0 to Height - 1 do
    begin
      PS := Bitmap.ScanLine[I];
      PD := ScanLine[I];
      for J := 0 to Width - 1 do
      begin
        PD[J].R := PS[J].R;
        PD[J].G := PS[J].G;
        PD[J].B := PS[J].B;
        PD[J].L := 255;
      end;
    end;
  end else
  begin
    for I := 0 to Height - 1 do
    begin
      PS32 := Bitmap.ScanLine[I];
      PD := ScanLine[I];
      for J := 0 to Width - 1 do
        PD[J] := PS32[J];
    end;
  end;
end;

procedure TLayeredBitmap.LoadFromHIcon(Icon: HIcon; FWidth: Integer = 0; FHeight: Integer = 0; Background: TColor = clBlack);
var
  BMask1, BMask2: TBitmap;
  PMask1, PMask2: PARGB;
  PD: PARGB32;
  I, J: Integer;
  piconinfo: TIconInfo;
  DIB: TDIBSection;
begin
  HandleNeeded;
  IsLayered := True;

  if FHeight = 0 then
  begin
    FWidth := 16;
    FHeight := 16;
    SetSize(FWidth, 16);
  end;

  if GetIconInfo(Icon, piconinfo) then
  begin
    try
      GetObject(piconinfo.hbmColor, SizeOf(DIB), @DIB);
      if (DIB.dsBm.bmWidth = FWidth) and (DIB.dsBm.bmHeight = FHeight) then
      begin
        Handle := piconinfo.hbmColor;
        MaskHandle := piconinfo.hbmMask;
        PixelFormat := pf32Bit;
        AlphaFormat := afDefined;
        Exit;
      end;
    finally
      DeleteObject(piconinfo.hbmMask);
      DeleteObject(piconinfo.hbmColor);
    end;
  end;

  BMask1 := TBitmap.Create;
  BMask2 := TBitmap.Create;
  try
    BMask1.PixelFormat := pf24bit;
    BMask1.Canvas.Brush.Color := clWhite;
    BMask1.Canvas.Pen.Color := clWhite;
    BMask2.PixelFormat := pf24bit;
    BMask2.Canvas.Brush.Color := clBlack;
    BMask2.Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := Background;
    Canvas.Pen.Color := Background;
    Canvas.Rectangle(0, 0, Width, Height);

    SetSize(FWidth, FHeight);

    BMask1.Width := Width;
    BMask1.Height := Height;
    BMask1.Canvas.Rectangle(0, 0, Width, Height);
    BMask2.Width := Width;
    BMask2.Height := Height;
    BMask2.Canvas.Rectangle(0, 0, Width, Height);
    DrawIconEx(Canvas.Handle, 0, 0, Icon, FWidth, FHeight, 0, 0, DI_NORMAL);
    DrawIconEx(BMask1.Canvas.Handle, 0, 0, Icon, FWidth, FHeight, 0, 0, DI_NORMAL);
    DrawIconEx(BMask2.Canvas.Handle, 0, 0, Icon, FWidth, FHeight, 0, 0, DI_NORMAL);

    for I := 0 to Height - 1 do
    begin
      PD := ScanLine[I];
      PMask1 := BMask1.ScanLine[I];
      PMask2 := BMask2.ScanLine[I];
      for J := 0 to Width - 1 do
        PD[J].L := 255 - ((PMask1[J].R + PMask1[J].G + PMask1[J].B) div 3 - (PMask2[J].R + PMask2[J].G + PMask2[J].B) div 3);

    end;
  finally
    F(BMask1);
    F(BMask2);
  end;
end;

procedure TLayeredBitmap.LoadLayered(Bitmap: TBitmap; Mode: integer);
var
  I, J: Integer;
  PD: PARGB32;
  PS: PARGB;
begin
  HandleNeeded;
  Bitmap.PixelFormat := pf24bit;
  SetSize(Bitmap.Width, Bitmap.Height);
  for I := 0 to Height - 1 do
  begin
    PS := Bitmap.ScanLine[I];
    PD := ScanLine[I];
    for J := 0 to Width - 1 do
      PD[J].L := 255 - (PS[J].R + PS[J].G + PS[J].B) div 3;

  end;
end;

procedure TLayeredBitmap.SaveToBitmap(Bitmap: TBitmap);
var
  I, J: Integer;
  PS: PARGB32;
  PD: PARGB;
begin
  HandleNeeded;
  SetSize(Bitmap.Width, Bitmap.Height);
  for I := 0 to Height - 1 do
  begin
    PD := Bitmap.ScanLine[I];
    PS := ScanLine[I];
    for J := 0 to Width - 1 do
    begin
      PD[J].R := PS[J].R;
      PD[J].G := PS[J].G;
      PD[J].B := PS[J].B;
    end;
  end;
end;

procedure TLayeredBitmap.SetIsLayered(const Value: boolean);
begin
  FIsLayered := Value;
end;

end.










