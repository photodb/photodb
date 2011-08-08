unit uBitmapUtils;

interface

uses
  Graphics, uConstants;

procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
procedure Rotate180A(Bitmap: TBitmap);
procedure Rotate270A(Bitmap: TBitmap);
procedure Rotate90A(Bitmap: TBitmap);
procedure AssignBitmap(Dest: TBitmap; Src: TBitmap);

implementation

procedure AssignBitmap(Dest: TBitmap; Src: TBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  PS32, PD32: PARGB32;
begin
  if Src.PixelFormat <> pf32bit then
  begin
    Src.PixelFormat := pf24bit;
    Dest.PixelFormat := pf24bit;
    Dest.SetSize(Src.Width, Src.Height);

    for I := 0 to Src.Height - 1 do
    begin
      PD := Dest.ScanLine[I];
      PS := Src.ScanLine[I];
      for J := 0 to Src.Width - 1 do
        PD[J] := PS[J];
    end;
  end else
  begin
    Src.PixelFormat := pf32bit;
    Dest.PixelFormat := pf32bit;
    Dest.SetSize(Src.Width, Src.Height);

    for I := 0 to Src.Height - 1 do
    begin
      PD32 := Dest.ScanLine[I];
      PS32 := Src.ScanLine[I];
      for J := 0 to Src.Width - 1 do
        PD32[J] := PS32[J];
    end;
  end;
end;

procedure Rotate180A(Bitmap: TBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  PS32, PD32: PARGB32;
  Image: TBitmap;
begin
  Image := TBitmap.Create;
  try
    if Bitmap.PixelFormat <> pf32bit then
    begin
      Bitmap.PixelFormat := pf24bit;
      AssignBitmap(Image, Bitmap);
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[I];
        PD := Bitmap.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PD[J] := PS[Image.Width - 1 - J];
      end;
    end else
    begin
      AssignBitmap(Image, Bitmap);
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[I];
        PD32 := Bitmap.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PD32[J] := PS32[Image.Width - 1 - J];
      end;
    end;
  finally
    F(Image);
  end;
end;

procedure Rotate270A(Bitmap: TBitmap);
var
  I, J: Integer;
  PS: PARGB;
  PS32: PARGB32;
  PA: array of PARGB;
  PA32: array of PARGB32;
  Image: TBitmap;
begin
  Image := TBitmap.Create;
  try
    if Bitmap.PixelFormat <> pf32bit then
    begin
      Bitmap.PixelFormat := pf24bit;
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA[I] := Bitmap.ScanLine[Bitmap.Height - 1 - I];
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[I];
        for J := 0 to Image.Width - 1 do
          PA[J, I] := PS[J];
      end;
    end else
    begin
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA32, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA32[I] := Bitmap.ScanLine[Bitmap.Height - 1 - I];
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[I];
        for J := 0 to Image.Width - 1 do
          PA32[J, I] := PS32[J];
      end;
    end;
  finally
    F(Image);
  end;
end;

procedure Rotate90A(Bitmap: TBitmap);
var
  I, J: Integer;
  PS: PARGB;
  PS32: PARGB32;
  PA: array of PARGB;
  PA32: array of PARGB32;
  Image: TBitmap;
begin
  Image := TBitmap.Create;
  try
    if Bitmap.PixelFormat <> pf32bit then
    begin
      Bitmap.PixelFormat := pf24bit;
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA[I] := Bitmap.ScanLine[I];
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PA[J, I] := PS[J];
      end;
    end else
    begin
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA32, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA32[I] := Bitmap.ScanLine[I];
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PA32[J, I] := PS32[J];
      end;
    end;
  finally
    F(Image);
  end;
end;

procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
begin
  case RotateValue of
    DB_IMAGE_ROTATE_270,
    - 10 * DB_IMAGE_ROTATE_270:
      Rotate270A(Bitmap);
    DB_IMAGE_ROTATE_90,
    - 10 * DB_IMAGE_ROTATE_90:
      Rotate90A(Bitmap);
    DB_IMAGE_ROTATE_180,
    - 10 * DB_IMAGE_ROTATE_180:
      Rotate180A(Bitmap);
  end;
end;

end.
