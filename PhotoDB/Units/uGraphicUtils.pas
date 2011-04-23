unit uGraphicUtils;

interface

uses
  Windows, SysUtils, Classes, Graphics, Jpeg, Math, uConstants,
  UnitDBCommonGraphics, GraphicsBaseTypes, uDBGraphicTypes, uAssociations,
  RAWImage, uMemory;

type
  TCompareArray = array [0 .. 99, 0 .. 99, 0 .. 2] of Integer;

  TCompareImageInfo = class
  public
    X2_0, X2_90, X2_180, X2_270: TCompareArray;
    B2_0: TBitmap;
    constructor Create(Image: TGraphic; Quick, FSpsearch_ScanFileRotate: Boolean);
    destructor Destroy; override;
  end;

function MixColors(Color1, Color2: TColor; Percent: Integer): TColor;
function MakeDarken(BaseColor : TColor; Multiply : Extended) : TColor; overload;
function MakeDarken(Color: TColor): TColor; overload;
procedure JPEGScale(Graphic: TGraphic; Width, Height: Integer);
procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
function ColorDiv2(Color1, COlor2: TColor): TColor;
function ColorDarken(Color: TColor): TColor;
function CompareImages(Image1, Image2: TGraphic; var Rotate: Integer; FSpsearch_ScanFileRotate: Boolean = True;
  Quick: Boolean = False; Raz: Integer = 60): TImageCompareResult;
function CompareImagesEx(Image1: TGraphic; Image2Info: TCompareImageInfo; var Rotate: Integer; FSpsearch_ScanFileRotate: Boolean = True;
  Quick: Boolean = False; Raz: Integer = 60): TImageCompareResult;
function IsRAWImageFile(FileName : String) : Boolean;

implementation

function ColorDiv2(Color1, COlor2: TColor): TColor;
begin
  Color1 := ColorToRGB(Color1);
  Color2 := ColorToRGB(Color2);
  Result := RGB((GetRValue(Color1) + GetRValue(Color2)) div 2, (GetGValue(Color1) + GetGValue(Color2)) div 2,
    (GetBValue(Color1) + GetBValue(Color2)) div 2);
end;

function ColorDarken(Color: TColor): TColor;
begin
  Color := ColorToRGB(Color);
  Result := RGB(Round(GetRValue(Color) / 1.2), (Round(GetGValue(Color) / 1.2)), (Round(GetBValue(Color) / 1.2)));
end;

procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
begin
  case RotateValue of
    DB_IMAGE_ROTATE_270:
      Rotate270A(Bitmap);
    DB_IMAGE_ROTATE_90:
      Rotate90A(Bitmap);
    DB_IMAGE_ROTATE_180:
      Rotate180A(Bitmap);
  end;
end;

procedure JPEGScale(Graphic: TGraphic; Width, Height: Integer);
var
  ScaleX, ScaleY, Scale: Extended;
begin
  if (Graphic is TJpegImage) then
  begin
    (Graphic as TJpegImage).Performance := jpBestSpeed;
    (Graphic as TJpegImage).ProgressiveDisplay := False;
    ScaleX:= Graphic.Width / Width;
    ScaleY := Graphic.Height / Height;
    Scale := Max(ScaleX, ScaleY);
    if Scale < 2 then
      (Graphic as TJpegImage).Scale := JsFullSize;
    if (Scale >= 2) and (Scale < 4) then
      (Graphic as TJpegImage).Scale := JsHalf;
    if (Scale >= 4) and (Scale < 8) then
      (Graphic as TJpegImage).Scale := JsQuarter;
    if Scale >= 8 then
      (Graphic as TJpegImage).Scale := JsEighth;
  end;
end;

function MakeDarken(BaseColor : TColor; Multiply : Extended) : TColor;
var
  R, G, B : Byte;
begin
  BaseColor := ColorToRGB(BaseColor);
  R := GetRValue(BaseColor);
  G := GetGValue(BaseColor);
  B := GetBValue(BaseColor);
  R := Byte(Round(R * Multiply));
  G := Byte(Round(G * Multiply));
  B := Byte(Round(B * Multiply));
  Result := RGB(R, G, B);
end;

function MakeDarken(Color: TColor): TColor;
begin
  Color := ColorToRGB(Color);
  Result := RGB(Round(0.75 * GetRValue(Color)), Round(0.75 * GetGValue(Color)), Round(0.75 * GetBValue(Color)));
end;

function MixColors(Color1, Color2: TColor; Percent: Integer): TColor;
var
  R, G, B: Byte;
  P: Extended;
begin
  Color1 := ColorToRGB(Color1);
  Color2 := ColorToRGB(Color2);
  P := (Percent / 100);
  R := Round(P * GetRValue(Color1) + (P - 1) * GetRValue(Color2));
  G := Round(P * GetGValue(Color1) + (P - 1) * GetGValue(Color2));
  B := Round(P * GetBValue(Color1) + (P - 1) * GetBValue(Color2));
  Result := RGB(R, G, B);
end;

procedure StretchA(Width, Height: Integer; S, D: TBitmap);
var
  I, J: Integer;
  P1: PARGB;
  Sh, Sw: Extended;
  Xp: array of PARGB;
  Y : Integer;
  XAr: array of Integer;
begin
  D.SetSize(100, 100);
  Sw := S.Width / Width;
  Sh := S.Height / Height;
  SetLength(Xp, S.Height);
  for I := 0 to S.Height - 1 do
    Xp[I] := S.ScanLine[I];

  SetLength(XAr, Width);
  for J := 0 to Width - 1 do
    XAr[J] := Round(Sw * J);

  for I := 0 to Height - 1 do
  begin
    P1 := D.ScanLine[I];
    Y := Round(Sh * I);
    for J := 0 to Width - 1 do
      P1[J] := Xp[Y, XAr[J]];
  end;
end;

function Gistogramma(W, H: Integer; S: PARGBArray): TGistogrammData;
var
  I, J, Max: Integer;
  Ps: PARGB;
  LGray, LR, LG, LB: Byte;
begin

  /// сканирование изображение и подведение статистики
  for I := 0 to 255 do
  begin
    Result.Red[I] := 0;
    Result.Green[I] := 0;
    Result.Blue[I] := 0;
    Result.Gray[I] := 0;
  end;
  for I := 0 to H - 1 do
  begin
    Ps := S[I];
    for J := 0 to W - 1 do
    begin
      LR := Ps[J].R;
      LG := Ps[J].G;
      LB := Ps[J].B;
      LGray :=  (LR * 77 + LG * 151 + LB * 28) shr 8;
      Inc(Result.Gray[LGray]);
      Inc(Result.Red[LR]);
      Inc(Result.Green[LG]);
      Inc(Result.Blue[LB]);
    end;
  end;

  /// поиск максимума
  Max := 1;
  Result.Max := 0;
  for I := 5 to 250 do
  begin
    if Max < Result.Red[I] then
    begin
      Max := Result.Red[I];
      Result.Max := I;
    end;
  end;
  for I := 5 to 250 do
  begin
    if Max < Result.Green[I] then
    begin
      Max := Result.Green[I];
      Result.Max := I;
    end;
  end;
  for I := 5 to 250 do
  begin
    if Max < Result.Blue[I] then
    begin
      Max := Result.Blue[I];
      Result.Max := I;
    end;
  end;

  /// в основном диапозоне 0..100
  for I := 0 to 255 do
    Result.Red[I] := Round(100 * Result.Red[I] / Max);

  // max:=1;
  for I := 0 to 255 do
    Result.Green[I] := Round(100 * Result.Green[I] / Max);

  // max:=1;
  for I := 0 to 255 do
    Result.Blue[I] := Round(100 * Result.Blue[I] / Max);

  // max:=1;
  for I := 0 to 255 do
    Result.Gray[I] := Round(100 * Result.Gray[I] / Max);

  /// ограничение на значение - изза нахождения максимума не во всём диапозоне
  for I := 0 to 255 do
    if Result.Red[I] > 255 then
      Result.Red[I] := 255;

  for I := 0 to 255 do
    if Result.Green[I] > 255 then
      Result.Green[I] := 255;

  for I := 0 to 255 do
    if Result.Blue[I] > 255 then
      Result.Blue[I] := 255;

  for I := 0 to 255 do
    if Result.Gray[I] > 255 then
      Result.Gray[I] := 255;

  // получаем границы диапозона
  Result.LeftEffective := 0;
  Result.RightEffective := 255;
  for I := 0 to 254 do
  begin
    if (Result.Gray[I] > 10) and (Result.Gray[I + 1] > 10) then
    begin
      Result.LeftEffective := I;
      Break;
    end;
  end;
  for I := 255 downto 1 do
  begin
    if (Result.Gray[I] > 10) and (Result.Gray[I - 1] > 10) then
    begin
      Result.RightEffective := I;
      Break;
    end;
  end;

end;

function CompareImagesByGistogramm(Image1, Image2: TBitmap): Byte;
var
  PRGBArr: PARGBArray;
  I: Integer;
  Diff: Byte;
  Data1, Data2, Data: TGistogrammData;
  Mx_r, Mx_b, Mx_g: Integer;
  ResultExt: Extended;

  function AbsByte(B1, B2: Integer): Integer; inline;
  begin
    // if b1<b2 then Result:=b2-b1 else Result:=b1-b2;
    Result := B2 - B1;
  end;

  procedure RemovePicks;
  const
    InterpolateWidth = 10;
  var
    I, J, R, G, B: Integer;
    Ar, Ag, Ab: array [0 .. InterpolateWidth - 1] of Integer;
  begin
    Mx_r := 0;
    Mx_g := 0;
    Mx_b := 0;
    /// выкидываем пики резкие и сглаживаем гистограмму
    for J := 0 to InterpolateWidth - 1 do
    begin
      Ar[J] := 0;
      Ag[J] := 0;
      Ab[J] := 0;
    end;

    for I := 1 to 254 do
    begin
      Ar[I mod InterpolateWidth] := Data.Red[I];
      Ag[I mod InterpolateWidth] := Data.Green[I];
      Ab[I mod InterpolateWidth] := Data.Blue[I];

      R := 0;
      G := 0;
      B := 0;
      for J := 0 to InterpolateWidth - 1 do
      begin
        R := Ar[J] + R;
        G := Ag[J] + G;
        B := Ab[J] + B;
      end;
      Data.Red[I] := R div InterpolateWidth;
      Data.Green[I] := G div InterpolateWidth;
      Data.Blue[I] := B div InterpolateWidth;

      Mx_r := Mx_r + Data.Red[I];
      Mx_g := Mx_g + Data.Green[I];
      Mx_b := Mx_b + Data.Blue[I];
    end;

    Mx_r := Mx_r div 254;
    Mx_g := Mx_g div 254;
    Mx_b := Mx_b div 254;
  end;

begin
  Mx_r := 0;
  Mx_g := 0;
  Mx_b := 0;
  SetLength(PRGBArr, Image1.Height);
  for I := 0 to Image1.Height - 1 do
    PRGBArr[I] := Image1.ScanLine[I];
  Data1 := Gistogramma(Image1.Width, Image1.Height, PRGBArr);

  // ???GetGistogrammBitmapX(150,0,Data1.Red,a,a).SaveToFile('c:\w1.bmp');

  SetLength(PRGBArr, Image2.Height);
  for I := 0 to Image2.Height - 1 do
    PRGBArr[I] := Image2.ScanLine[I];
  Data2 := Gistogramma(Image2.Width, Image2.Height, PRGBArr);

  // ???GetGistogrammBitmapX(150,0,Data2.Red,a,a).SaveToFile('c:\w2.bmp');

  for I := 0 to 255 do
  begin
    Data.Green[I] := AbsByte(Data1.Green[I], Data2.Green[I]);
    Data.Blue[I] := AbsByte(Data1.Blue[I], Data2.Blue[I]);
    Data.Red[I] := AbsByte(Data1.Red[I], Data2.Red[I]);
  end;

  // ???GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w.bmp');

  RemovePicks;

  // ???GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w_pick.bmp');

  for I := 0 to 255 do
  begin
    Data.Green[I] := Abs(Data.Green[I] - Mx_g);
    Data.Blue[I] := Abs(Data.Blue[I] - Mx_b);
    Data.Red[I] := Abs(Data.Red[I] - Mx_r);
  end;

  // ?GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w_mx.bmp');

  ResultExt := 10000;
  if Abs(Data2.Max - Data2.Max) > 20 then
    ResultExt := ResultExt / (Abs(Data2.Max - Data1.Max) / 20);

  if (Data2.LeftEffective > Data1.RightEffective) or (Data1.LeftEffective > Data2.RightEffective) then
  begin
    ResultExt := ResultExt / 10;
  end;
  if Abs(Data2.LeftEffective - Data1.LeftEffective) > 5 then
    ResultExt := ResultExt / (Abs(Data2.LeftEffective - Data1.LeftEffective) / 20);
  if Abs(Data2.RightEffective - Data1.RightEffective) > 5 then
    ResultExt := ResultExt / (Abs(Data2.RightEffective - Data1.RightEffective) / 20);

  for I := 0 to 255 do
  begin
    Diff := Round(Sqrt(Sqr(0.3 * Data.Red[I]) + Sqr(0.58 * Data.Green[I]) + Sqr(0.11 * Data.Blue[I])));
    if (Diff > 5) and (Diff < 10) then
      ResultExt := ResultExt * (1 - Diff / 1024);
    if (Diff >= 10) and (Diff < 20) then
      ResultExt := ResultExt * (1 - Diff / 512);
    if (Diff >= 20) and (Diff < 100) then
      ResultExt := ResultExt * (1 - Diff / 255);
    if Diff >= 100 then
      ResultExt := ResultExt * Sqr(1 - Diff / 255);
    if Diff = 0 then
      ResultExt := ResultExt * 1.02;
    if Diff = 1 then
      ResultExt := ResultExt * 1.01;
    if Diff = 2 then
      ResultExt := ResultExt * 1.001;
  end;
  // Result in 0..10000
  if ResultExt > 10000 then
    ResultExt := 10000;
  Result := Round(Power(101, ResultExt / 10000) - 1); // Result in 0..100
end;

procedure FillArray(Image: TBitmap; var AArray: TCompareArray);
var
  I, J: Integer;
  PC, P1, D: Integer;
begin
  P1 := Integer(Image.ScanLine[0]);
  D := Integer(Image.ScanLine[1]) - P1;
  for I := 0 to 99 do
  begin
    PC := P1;
    for J := 0 to 99 do
    begin
      AArray[I, J, 0] := PRGB(PC)^.R;
      AArray[I, J, 1] := PRGB(PC)^.G;
      AArray[I, J, 2] := PRGB(PC)^.B;
      Inc(PC, 3);
    end;
    Inc(P1, D);
  end;
end;

function CompareImages(Image1, Image2: TGraphic; var Rotate: Integer; FSpsearch_ScanFileRotate: Boolean = True;
  Quick: Boolean = False; Raz: Integer = 60): TImageCompareResult;
var
  CI: TCompareImageInfo;

begin
  if Image2.Empty then
  begin
    Result.ByGistogramm := 0;
    Result.ByPixels := 0;
    Exit;
  end;
  CI := TCompareImageInfo.Create(Image2, Quick, FSpsearch_ScanFileRotate);
  try
    Result := CompareImagesEx(Image1, CI, Rotate, FSpsearch_ScanFileRotate, Quick, Raz);
  finally
    F(CI);
  end;
end;

{ TCompareImageInfo }

constructor TCompareImageInfo.Create(Image: TGraphic; Quick, FSpsearch_ScanFileRotate: Boolean);
var
  B2: TBitmap;
begin
  B2_0 := TBitmap.Create;
  B2_0.PixelFormat := pf24bit;

  B2 := TBitmap.Create;
  try
    B2.PixelFormat := pf24bit;
    B2.Assign(Image);

    if Quick then
    begin
      if (B2.Width = 100) and (B2.Height = 100) then
      begin
        B2_0.Assign(B2);
      end else
        StretchA(100, 100, B2, B2_0);

      FillArray(B2_0, X2_0);
    end else
    begin
      if (B2.Width >= 100) and (B2.Height >= 100) then
        StretchCool(100, 100, B2, B2_0)
      else
        Interpolate(0, 0, 100, 100, Rect(0, 0, B2.Width, B2.Height), B2, B2_0);

      FillArray(B2_0, X2_0);
    end;
  finally
    B2.Free;
  end;

  if FSpsearch_ScanFileRotate then
  begin
    Rotate90A(B2_0);
    FillArray(B2_0, X2_90);
    Rotate90A(B2_0);
    FillArray(B2_0, X2_180);
    Rotate90A(B2_0);
    FillArray(B2_0, X2_270);
  end;
end;

destructor TCompareImageInfo.Destroy;
begin
  F(B2_0);
  inherited;
end;

function CompareImagesEx(Image1: TGraphic; Image2Info: TCompareImageInfo; var Rotate: Integer; FSpsearch_ScanFileRotate: Boolean = True;
  Quick: Boolean = False; Raz: Integer = 60): TImageCompareResult;
var
  B1, B1_: TBitmap;
  X1: TCompareArray;
  I: Integer;
  Res: array [0 .. 3] of TImageCompareResult;

  function CmpImages(Image1, Image2: TCompareArray): Byte;
  var
    X: TCompareArray;
    I, J, K: Integer;
    ResultExt: Extended;
    Diff: Integer;
  begin
    ResultExt := 10000;
    for I := 0 to 99 do
      for J := 0 to 99 do
        for K := 0 to 2 do
        begin
          X[I, J, K] := Abs(Image1[I, J, K] - Image2[I, J, K]);
        end;

    for I := 0 to 99 do
      for J := 0 to 99 do
      begin
        Diff :=  (X[I, J, 0] * 77 + X[I, J, 1] * 151 + X[I, J, 2] * 28) shr 8;
        if Diff > Raz then
          ResultExt := ResultExt * (1 - Diff / 1024)
        else if Diff = 0 then
          ResultExt := ResultExt * 1.05
        else if Diff = 1 then
          ResultExt := ResultExt * 1.01
        else if Diff < 10 then
          ResultExt := ResultExt * 1.001;
      end;
    if ResultExt > 10000 then
      ResultExt := 10000;
    Result := Round(Power(101, ResultExt / 10000) - 1); // Result in 0..100
  end;

begin
  Result.ByGistogramm := 0;
  Result.ByPixels := 0;
  if Image1.Empty then
    Exit;

  B1_ := TBitmap.Create;
  try
    B1_.PixelFormat := pf24bit;

    B1 := TBitmap.Create;
    try
      B1.PixelFormat := pf24bit;
      AssignGraphic(B1, Image1);

      if Quick then
      begin
        if (B1.Width = 100) and (B1.Height = 100) then
        begin
          AssignBitmap(B1_, B1);
        end else
          StretchA(100, 100, B1, B1_);

        FillArray(B1_, X1);

      end else
      begin
        if (B1.Width >= 100) and (B1.Height >= 100) then
          StretchA(100, 100, B1, B1_)
        else
          Interpolate(0, 0, 100, 100, Rect(0, 0, B1.Width, B1.Height), B1, B1_);

        FillArray(B1_, X1);
      end;
    finally
      F(B1);
    end;
    if not Quick then
      Result.ByGistogramm := CompareImagesByGistogramm(B1_, Image2Info.B2_0);

  finally
    F(B1_);
  end;

  Res[0].ByPixels := CmpImages(X1, Image2Info.X2_0);
  if FSpsearch_ScanFileRotate then
  begin
    Res[3].ByPixels := CmpImages(X1, Image2Info.X2_90);
    Res[2].ByPixels := CmpImages(X1, Image2Info.X2_180);
    Res[1].ByPixels := CmpImages(X1, Image2Info.X2_270);
  end;
  Rotate := 0;
  Result.ByPixels := Res[0].ByPixels;
  if FSpsearch_ScanFileRotate then
    for I := 0 to 3 do
    begin
      if Res[I].ByPixels > Result.ByPixels then
      begin
        Result.ByPixels := Res[I].ByPixels;
        Rotate := I;
      end;
    end;
end;

function IsRAWImageFile(FileName : String) : Boolean;
begin
  Result := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName)) = TRAWImage;
end;

end.
