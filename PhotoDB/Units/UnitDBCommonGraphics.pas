unit UnitDBCommonGraphics;

interface

uses
  Windows, Classes, Messages, Controls, Forms, StdCtrls, Graphics,
  pngimage, ShellApi, JPEG, CommCtrl, uMemory,
  DmProgress, GIFImage, RAWImage,
  UnitDBDeclare, uTranslate, UnitDBCommon, SysUtils,
  GraphicsBaseTypes, Effects, Math, uMath, uPngUtils;

type
  TJPEGX = class(TJpegImage)
  public
    function InnerBitmap: TBitmap;
  end;

  TDrawTextAsyncProcedure = procedure(Bitmap: TBitmap; Rct: TRect; Text: string) of object;

const
  PSDTransparent = True;
  // Image processiong options
  ZoomSmoothMin = 0.4;

procedure DoInfoListBoxDrawItem(ListBox: TListBox; index: Integer; ARect: TRect; State: TOwnerDrawState;
  ItemsData: TList; Icons: array of TIcon; FProgressEnabled: Boolean; TempProgress: TDmProgress; Infos: TStrings);
procedure BeginScreenUpdate(Hwnd: THandle);
procedure EndScreenUpdate(Hwnd: THandle; Erase: Boolean);
function CalcJpegResampledSize(Jpeg: TJpegImage; Size: Integer; CompressionRate: Byte;
  out JpegImageResampled: TJpegImage): Int64;
function CalcBitmapToJPEGCompressSize(Bitmap: TBitmap; CompressionRate: Byte;
  out JpegImageResampled: TJpegImage): Int64;
procedure LoadImageX(Image: TGraphic; Bitmap: TBitmap; BackGround: TColor);
procedure LoadBMPImage32bit(S: TBitmap; D: TBitmap; BackGroundColor: TColor);
procedure QuickReduce(NewWidth, NewHeight: Integer; BmpIn, BmpOut: TBitmap);
procedure StretchCool(X, Y, Width, Height: Integer; S, D: TBitmap); overload;
procedure StretchCool(Width, Height: Integer; S, D: TBitmap); overload;
procedure QuickReduceWide(Width, Height: Integer; S, D: TBitmap);
procedure DoResize(Width, Height: Integer; S, D: TBitmap);
procedure Interpolate(X, Y, Width, Height: Integer; Rect: TRect; S, D: TBitmap);
procedure Rotate180A(Bitmap: TBitmap);
procedure Rotate270A(Bitmap: TBitmap);
procedure Rotate90A(Bitmap: TBitmap);
procedure FillColorEx(Bitmap: TBitmap; Color: TColor);
procedure DrawImageEx(Dest, Src: TBitmap; X, Y: Integer);
procedure DrawImageEx32(Dest32, Src32: TBitmap; X, Y: Integer);
procedure DrawImageEx32To24(Dest24, Src32: TBitmap; X, Y: Integer);
procedure DrawImageEx24To32(Dest32, Src24: TBitmap; X, Y: Integer; NewTransparent: Byte = 0);
procedure FillTransparentColor(Bitmap: TBitmap; Color: TColor; TransparentValue: Byte = 0);
procedure DrawTransparent(S, D: TBitmap; Transparent: Byte);
procedure GrayScale(Image: TBitmap);
procedure SelectedColor(Image: TBitmap; Color: TColor);
procedure AssignJpeg(Bitmap: TBitmap; Jpeg: TJPEGImage);
procedure AssignBitmap(Dest: TBitmap; Src: TBitmap);
procedure AssignGraphic(Dest: TBitmap; Src: TGraphic);
procedure RemoveBlackColor(Bitmap: TBitmap);
function ExtractSmallIconByPath(IconPath: string; Big: Boolean = False): HIcon;
procedure SetIconToPictureFromPath(Picture: TPicture; IconPath: string);
procedure AddIconToListFromPath(ImageList: TImageList; IconPath: string);
procedure DrawWatermark(Bitmap: TBitmap; XBlocks, YBlocks: Integer; Text: string; AAngle: Integer; Color: TColor;
  Transparent: Byte; FontName: string; SyncCallBack: TDrawTextAsyncProcedure);
procedure DrawText32Bit(Bitmap32: TBitmap; Text: string; Font: TFont; ARect: TRect; DrawTextOptions: Cardinal);
procedure DrawColorMaskTo32Bit(Dest, Mask: TBitmap; Color: TColor; X, Y: Integer);
procedure DrawShadowToImage(Dest32, Src: TBitmap; Transparenty: Byte = 0);
procedure DrawRoundGradientVert(Dest32: TBitmap; Rect: TRect; ColorFrom, ColorTo, BorderColor: TColor;
  RoundRect: Integer; TransparentValue: Byte = 220);
procedure InverseTransparenty(Bitmap32: TBitmap);

implementation

function MaxI8(A, B : Byte) : Byte; inline; overload;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function MinI8(A, B : Byte) : Byte; inline; overload;
begin
  if A > B then
    Result := B
  else
    Result := A;
end;

function MaxI32(A, B : Integer) : Integer; inline; overload;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function MinI32(A, B : Integer) : Integer; inline; overload;
begin
  if A > B then
    Result := B
  else
    Result := A;
end;

procedure DrawRoundGradientVert(Dest32 : TBitmap; Rect : TRect; ColorFrom, ColorTo, BorderColor : TColor; RoundRect : Integer; TransparentValue : Byte = 220);
var
  BitRound : TBitmap;
  PR : PARGB;
  PD : PARGB32;
  I, J : Integer;
  RF, GF, BF, RT, GT, BT, R, G, B, W, W1 : Byte;
  RB, GB, BB : Byte;
  S : Integer;
begin
  ColorFrom := ColorToRGB(ColorFrom);
  ColorTo := ColorToRGB(ColorTo);
  BorderColor := ColorToRGB(BorderColor);
  RF := GetRValue(ColorFrom);
  GF := GetGValue(ColorFrom);
  BF := GetBValue(ColorFrom);
  RT := GetRValue(ColorTo);
  GT := GetGValue(ColorTo);
  BT := GetBValue(ColorTo);
  RB := GetRValue(BorderColor);
  GB := GetGValue(BorderColor);
  BB := GetBValue(BorderColor);
  if BB = 255 then
    BB := 254;
  BorderColor := RGB(RB, GB, BB);
  Dest32.PixelFormat := pf32Bit;
  BitRound := TBitmap.Create;
  try
    BitRound.PixelFormat := pf24Bit;
    BitRound.SetSize(Dest32.Width, Dest32.Height);
    BitRound.Canvas.Brush.Color := clWhite;
    BitRound.Canvas.Pen.Color := clWhite;
    BitRound.Canvas.Rectangle(0, 0, Dest32.Width, Dest32.Height);
    BitRound.Canvas.Brush.Color := clBlack;
    BitRound.Canvas.Pen.Color := BorderColor;
    Windows.RoundRect(BitRound.Canvas.Handle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, RoundRect, RoundRect);

    for I := 0 to Dest32.Height - 1 do
    begin
      PR := BitRound.ScanLine[I];
      PD := Dest32.ScanLine[I];
      if (Rect.Top > I) or (I > Rect.Bottom) then
         Continue;

      W := Round(255 * (I + 1 - Rect.Top) / (Rect.Bottom - Rect.Top));
      W1 := 255 - W;
      R := (RF * W + RT * W1 + $7F) div 255;
      G := (GF * W + GT * W1 + $7F) div 255;
      B := (BF * W + BT * W1 + $7F) div 255;
      for J := 0 to Dest32.Width - 1 do
      begin
        S := (PR[J].R + PR[J].G + PR[J].B);
        if S <> 765 then //White
        begin
          PD[J].L := TransparentValue;
          //black - gradient
          if S = 0 then
          begin
            PD[J].R := R;
            PD[J].G := G;
            PD[J].B := B;
          end else //border
          begin
            PD[J].R := RB;
            PD[J].G := GB;
            PD[J].B := BB;
          end;
        end;
      end;
    end;

  finally
    F(BitRound);
  end;
end;

procedure DrawShadowToImage(Dest32, Src : TBitmap; Transparenty : Byte = 0);
var
  I, J : Integer;
  PS : PARGB;
  PS32 : PARGB32;
  PDA : array of PARGB32;
  SH, SW : Integer;
  AddrLineD, DeltaD, AddrD : Integer;
  PD : PRGB32;
  W, W1 : Byte;

const
  SHADOW : array[0..6, 0..6] of byte =
  ((8,14,22,26,22,14,8),
  (14,0,0,0,52,28,14),
  (22,0,0,0,94,52,22),
  (26,0,0,0,124,66,26),
  (22,52,94,{124}94,94,52,22),
  (14,28,52,66,52,28,14),
  (8,14,22,26,22,14,8));

begin
  //set new image size
  Dest32.PixelFormat := pf32Bit;
  SW := Src.Width;
  SH := Src.Height;
  Dest32.SetSize(SW + 4, SH + 4);
  SetLength(PDA, Dest32.Height);

  AddrLineD := Integer(Dest32.ScanLine[0]);
  DeltaD := Integer(Dest32.ScanLine[1])- AddrLineD;

  //buffer scanlines
  for I := 0 to Dest32.Height - 1 do
    PDA[I] := Dest32.ScanLine[I];

  //min size of shadow - 5x5 px
  //top-left
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I][J].R := 0;
      PDA[I][J].G := 0;
      PDA[I][J].B := 0;
      PDA[I][J].L := SHADOW[I, J];
    end;

  //top-bottom
  for I := 3 to Src.Height do
  begin
    PDA[I][0].R := 0;
    PDA[I][0].G := 0;
    PDA[I][0].B := 0;
    PDA[I][0].L := SHADOW[3, 0];
    for J := 0 to 2 do
    begin
      PDA[I][J + SW + 1].R := 0;
      PDA[I][J + SW + 1].G := 0;
      PDA[I][J + SW + 1].B := 0;
      PDA[I][J + SW + 1].L := SHADOW[4, 2 - J];
    end;
  end;

  //left-right
  for I := 3 to Src.Width do
  begin
    PDA[0][I].R := 0;
    PDA[0][I].G := 0;
    PDA[0][I].B := 0;
    PDA[0][I].L := SHADOW[0, 3];
    for J := 0 to 2 do
    begin
      PDA[J + SH + 1][I].R := 0;
      PDA[J + SH + 1][I].G := 0;
      PDA[J + SH + 1][I].B := 0;
      PDA[J + SH + 1][I].L := SHADOW[4, 2 - J];
    end;
  end;

  //left-bottom
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I + SH + 1][J].R := 0;
      PDA[I + SH + 1][J].G := 0;
      PDA[I + SH + 1][J].B := 0;
      PDA[I + SH + 1][J].L := SHADOW[I + 4, J];
    end;

  //top-right
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I][J + SW + 1].R := 0;
      PDA[I][J + SW + 1].G := 0;
      PDA[I][J + SW + 1].B := 0;
      PDA[I][J + SW + 1].L := SHADOW[I, J + 4];
    end;

  //bottom-right
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I + SH + 1][J + SW + 1].R := 0;
      PDA[I + SH + 1][J + SW + 1].G := 0;
      PDA[I + SH + 1][J + SW + 1].B := 0;
      PDA[I + SH + 1][J + SW + 1].L := SHADOW[I + 4, J + 4];
    end;

  //and draw image
  if Src.PixelFormat <> pf32bit then
  begin
    Src.PixelFormat := pf24bit;
    AddrLineD := AddrLineD + DeltaD;
    for I := 0 to Src.Height - 1 do
    begin
      PS := Src.ScanLine[I];
      AddrD := AddrLineD + 4; //from second fixel
      for J := 0 to Src.Width - 1 do
      begin
        PD := PRGB32(AddrD);
        PD.R := PS[J].R;
        PD.G := PS[J].G;
        PD.B := PS[J].B;
        PD.L := 255;
        AddrD := AddrD + 4;
      end;
      AddrLineD := AddrLineD + DeltaD;
    end;
  end else
  begin
    AddrLineD := AddrLineD + DeltaD;
    for I := 0 to Src.Height - 1 do
    begin
      PS32 := Src.ScanLine[I];
      AddrD := AddrLineD + 4; //from second fixel
      for J := 0 to Src.Width - 1 do
      begin
        PD := PRGB32(AddrD);
        W := PS32[J].L;
        W1 := 255 - W;
        PD.R := (PD.R * W1 + PS32[J].R * W + $7F) div $FF;
        PD.G := (PD.G * W1 + PS32[J].G * W + $7F) div $FF;
        PD.B := (PD.B * W1 + PS32[J].B * W + $7F) div $FF;
        PD.L := W;
        AddrD := AddrD + 4;
      end;
      AddrLineD := AddrLineD + DeltaD;
    end;
  end;
end;

procedure DrawText32Bit(Bitmap32 : TBitmap; Text : string; Font : TFont; ARect : TRect; DrawTextOptions : Cardinal);
var
  Bitmap: TBitmap;
  R: TRect;
begin
  Bitmap32.PixelFormat := pf32bit;
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24Bit;
    Bitmap.Canvas.Font.Assign(Font);
    Bitmap.Canvas.Font.Color := ClBlack;
    Bitmap.Canvas.Brush.Color := ClWhite;
    Bitmap.Canvas.Pen.Color := ClWhite;
    Bitmap.Width := ARect.Right - ARect.Left;
    Bitmap.Height := ARect.Bottom - ARect.Top;
    R := Rect(0, 0, Bitmap.Width, Bitmap.Height);
    DrawText(Bitmap.Canvas.Handle, PWideChar(Text), Length(Text), R, DrawTextOptions);
    DrawColorMaskTo32Bit(Bitmap32, Bitmap, Font.Color, ARect.Left, ARect.Top);
  finally
    F(Bitmap);
  end;
end;

procedure DrawWatermark(Bitmap : TBitmap; XBlocks, YBlocks : Integer;
  Text : string; AAngle : Integer; Color : TColor; Transparent : Byte; FontName: string;
  SyncCallBack: TDrawTextAsyncProcedure);
var
  lf: TLogFont;
  I, J : Integer;
  X, Y, Width, Height, H, TextLength : Integer;
  Angle : Integer;
  Mask : TBitmap;
  PS, PD : PARGB;
  R, G, B : Byte;
  L, L1 : Byte;
  RealAngle: Double;
  TextHeight, TextWidth: Integer;
  Dioganal: Integer;
  Rct: TRect;
  DX, DY: Integer;
begin
  if Text = '' then
    Exit;
  Bitmap.PixelFormat := pf24bit;
  Width := Round(Bitmap.Width / XBlocks);
  Height := Round(Bitmap.Height / YBlocks);
  TextHeight := 0;

  for I := 1 to 10 do
  begin
    Dioganal := Round(Sqrt(Width * Width + Height * Height));

    TextLength := Round(Dioganal * 0.82) - Round(TextHeight * Cos(RealAngle) * Cos(PI / 2 - RealAngle));

    TextWidth := Round(TextLength / (Length(Text) + 1));
    TextHeight := Round(TextWidth * 1.5);
  end;
  RealAngle := PI / 2;
  if (Width - TextHeight) <> 0 then
    RealAngle := ArcTan((Height - TextHeight) / (Width - TextHeight));
  Angle :=  Round(10 * 180 * RealAngle / PI);

  FillChar(lf, SizeOf(lf), 0);
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);

  Mask := TBitmap.Create;
  try

    Mask.PixelFormat := pf24bit;
    Mask.SetSize(Bitmap.Width, Bitmap.Height);

    GetObject(Mask.Canvas.Font.Handle, SizeOf(TLogFont), @lf);
    with lf do begin
      // Ширина буквы
      lfWidth := TextWidth;
      // Высота буквы
      lfHeight := TextHeight;
      // Угол наклона в десятых градуса
      if AAngle < 0 then
        lfEscapement := Angle
      else
        lfEscapement := AAngle;
       // Жирность 0..1000, 0 - по умолчанию
      lfWeight := 1000;
      // Курсив
      lfItalic := 0;
      // Подчеркнут
      lfUnderline := 0;
      // Зачеркнут
      lfStrikeOut := 0;
      // CharSet
      lfCharSet := DEFAULT_CHARSET;
      lfQuality := ANTIALIASED_QUALITY;
      // Название шрифта
      StrCopy(lfFaceName, PChar(FontName));
    end;

    //white mask
    for I := 0 to Mask.Height - 1 do
    begin
      PS := Mask.ScanLine[I];
      FillChar(PS[0], Mask.Width * 3, $FF);
    end;

    DX := Round(Sin(RealAngle) * TextWidth);
    DY := Round(Sin(RealAngle) * Sin(RealAngle) * (TextWidth));
    DX := Round(DX - (TextWidth / 1.7) * Sin((RealAngle)));
    DY := Round(DX + (TextWidth / 1.7) * Sin((RealAngle)));

    Mask.Canvas.Font.Handle := CreateFontIndirect(lf);
    Mask.Canvas.Font.Color := clBlack;
    H := Mask.Canvas.TextHeight(Text);
    for I := 1 to XBlocks do
      for J := 1 to YBlocks do
      begin
        X := (I - 1) * Width;
        Y := (J - 1) * Height;
        Rct := Rect(X - DX, Y, X + Width , Y + Height + DY);

        if Assigned(SyncCallBack) then
          SyncCallBack(Mask, Rct, Text)
        else
          Mask.Canvas.TextRect(Rct, Text, [tfBottom, tfSingleLine]);
      end;

    for I := 0 to Bitmap.Height - 1 do
    begin
      PS := Mask.ScanLine[I];
      PD := Bitmap.ScanLine[I];
      for J := 0 to Bitmap.Width - 1 do
      begin
        L := 255 - PS[J].R;
        L := L * Transparent div 255;
        L1 := 255 - L;
        PD[J].R := (PD[J].R * L1 + R * L + $7F) div 255;
        PD[J].G := (PD[J].G * L1 + G * L + $7F) div 255;
        PD[J].B := (PD[J].B * L1 + B * L + $7F) div 255;
      end;
    end;
  finally
    F(Mask);
  end;
end;

procedure BeginScreenUpdate(hwnd: THandle);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(Hwnd, WM_SETREDRAW, 0, 0);
end;

procedure EndScreenUpdate(Hwnd: THandle; Erase: Boolean);
begin
  if (Hwnd = 0) then
    Hwnd := Application.MainForm.Handle;
  SendMessage(Hwnd, WM_SETREDRAW, 1, 0);
  RedrawWindow(Hwnd, nil, 0, { DW_FRAME + } RDW_INVALIDATE + RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
  if (Erase) then
    Windows.InvalidateRect(Hwnd, nil, True);
end;

procedure SelectedColor(Image: TBitmap; Color: TColor);
var
  I, J, R, G, B: Integer;
  P: PARGB;
begin
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  if Image.PixelFormat <> Pf24bit then
    Image.PixelFormat := Pf24bit;

  for I := 0 to Image.Height - 1 do
  begin
    P := Image.ScanLine[I];
    for J := 0 to Image.Width - 1 do
      if Odd(I + J) then
      begin
        P[J].R := R;
        P[J].G := G;
        P[J].B := B;
      end;
  end;
end;

function MixBytes(FG, BG, TRANS: Byte): Byte;
 asm
  push bx  // push some regs
  push cx
  push dx
  mov DH,TRANS // remembering Transparency value (or Opacity - as you like)
  mov BL,FG    // filling registers with our values
  mov AL,DH    // BL = ForeGround (FG)
  mov CL,BG    // CL = BackGround (BG)
  xor AH,AH    // Clear High-order parts of regs
  xor BH,BH
  xor CH,CH
  mul BL       // AL=AL*BL
  mov BX,AX    // BX=AX
  xor AH,AH
  mov AL,DH
  xor AL,$FF   // AX=(255-TRANS)
  mul CL       // AL=AL*CL
  add AX,BX    // AX=AX+BX
  shr AX,8     // Fine! Here we have mixed value in AL
  pop dx       // Hm... No rubbish after us, ok?
  pop cx
  pop bx       // Bye, dear Assembler - we go home to Delphi!
end;

procedure GrayScale(Image : TBitmap);
var
  I, J, C : integer;
  P : PARGB;
begin
  Image.PixelFormat := pf24bit;

  for I := 0 to Image.Height - 1 do
  begin
    p := Image.ScanLine[I];
    for J := 0 to Image.Width - 1 do
    begin
      C := (p[J].R * 77 + p[J].G * 151 + p[J].B * 28) shr 8;
      p[J].R := C;
      p[J].G := C;
      p[J].B := C;
    end;
  end;
end;

procedure GrayScaleImage(S, D : TBitmap; N : integer);
var
  I, J : integer;
  p1, p2 : Pargb;
  G : Byte;
  W1, W2: Byte;
begin
  W1 := Round((N / 100) * 255);
  W2 := 255 - W1;
  for I := 0 to S.Height - 1 do
  begin
    P1 := S.ScanLine[I];
    P2 := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      G := (P1[J].R * 77 + P1[J].G * 151 + P1[J].B * 28) shr 8;
      P2[J].R := (W2 * P2[J].R + W1 * G) shr 8;
      P2[J].G := (W2 * P2[J].G + W1 * G) shr 8;
      P2[J].B := (W2 * P2[J].B + W1 * G) shr 8;
    end;
  end;
end;

procedure DrawTransparent(S, D: TBitmap; Transparent: Byte);
var
  W1, W2, I, J: Integer;
  PS, PD : PARGB;
begin
  W1 := Transparent;
  W2 := 255 - W1;
  for I := 0 to S.Height - 1 do
  begin
    PS := S.ScanLine[I];
    pd := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      PD[j].R := (PD[J].R * W2 + PS[J].R * W1 + $7F) div $FF;
      PD[j].G := (PD[J].G * W2 + PS[J].G * W1 + $7F) div $FF;
      PD[j].B := (PD[J].B * W2 + PS[J].B * W1 + $7F) div $FF;
    end;
  end;
end;

procedure DoInfoListBoxDrawItem(ListBox: TListBox; Index: Integer; aRect: TRect; State: TOwnerDrawState;
  ItemsData : TList; Icons : array of TIcon; FProgressEnabled : boolean; TempProgress : TDmProgress;
  Infos : TStrings);
var
  InfoText, Text : string;
  r : TRect;
  ItemData : integer;
const
  IndexAdminToolsRecord = 6;
  IndexProgressRecord = 4;
  IndexProcessedRecord = 0;
  IndexPlusRecord = 3;
  IndexWarningRecord = 2;
  IndexErrorRecord = 1;
  IndexDBRecord = 5;
begin
    //
  ItemData := PInteger(ItemsData[index])^;
  if OdSelected in State then
    ListBox.Canvas.Brush.Color := $A0A0A0
  else
    ListBox.Canvas.Brush.Color := ClWhite;
  // clearing rect
  ListBox.Canvas.Pen.Color := ListBox.Canvas.Brush.Color;
  ListBox.Canvas.Rectangle(ARect);

  ListBox.Canvas.Pen.Color := ClBlack;
  ListBox.Canvas.Font.Color := ClBlack;
  Text := ListBox.Items[index];

  // first Record
  if Index = 0 then
  begin
    if TempProgress <> nil then
    begin
      DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, Icons[IndexProgressRecord].Handle, 16, 16, 0, 0,
          DI_NORMAL);
      ARect.Left := ARect.Left + 20;
      R := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ListBox.Canvas.TextHeight('Iy'));
      ARect.Top := ARect.Top + ListBox.Canvas.TextHeight('Iy');
      InfoText := TA('Executing') + ':';
      ListBox.Canvas.Font.Style := [FsBold];
      DrawText(ListBox.Canvas.Handle, PWideChar(InfoText), Length(InfoText), R, 0);
      if FProgressEnabled then
      begin
        TempProgress.Text := '';
        TempProgress.Width := ARect.Right - ARect.Left - ListBox.Canvas.TextWidth(InfoText)
          - 10 - ListBox.ScrollWidth;
        TempProgress.Height := ListBox.Canvas.TextHeight('Iy');
        TempProgress.DoPaintOnXY(ListBox.Canvas, R.Left + ListBox.Canvas.TextWidth(InfoText) + 10, R.Top);
      end;
    end;
    ListBox.Canvas.Font.Style := [];
  end;

  if ItemData = LINE_INFO_OK then
  begin
    if Infos[index] <> '' then
    begin
      R := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ListBox.Canvas.TextHeight('Iy'));
      ARect.Top := ARect.Top + ListBox.Canvas.TextHeight('Iy');
      InfoText := Infos[index];
      ListBox.Canvas.Font.Style := [FsBold];
      DrawText(ListBox.Canvas.Handle, PWideChar(InfoText), Length(InfoText), R, 0);
      ListBox.Canvas.Font.Style := [];
    end;
    DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, Icons[IndexProcessedRecord].Handle, 16, 16, 0, 0,
      DI_NORMAL);

    ARect.Left := ARect.Left + 20;
  end;

  if ItemData = LINE_INFO_DB then
  begin
    if Infos[index] <> '' then
    begin
      R := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ListBox.Canvas.TextHeight('Iy'));
      ARect.Top := ARect.Top + ListBox.Canvas.TextHeight('Iy');
      InfoText := Infos[index];
      ListBox.Canvas.Font.Style := [FsBold];
      DrawText(ListBox.Canvas.Handle, PWideChar(InfoText), Length(InfoText), R, 0);
      ListBox.Canvas.Font.Style := [];
    end;

    DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, Icons[IndexDBRecord].Handle, 16, 16, 0, 0, DI_NORMAL);
    ARect.Left := ARect.Left + 20;
  end;

  if ItemData = LINE_INFO_GREETING then
  begin

    R := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ListBox.Canvas.TextHeight('Iy'));
    ARect.Top := ARect.Top + ListBox.Canvas.TextHeight('Iy');
    InfoText := Infos[index];
    ListBox.Canvas.Font.Style := [FsBold];
    DrawText(ListBox.Canvas.Handle, PWideChar(InfoText), Length(InfoText), R, 0);
    ListBox.Canvas.Font.Style := [];

    DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, Icons[IndexAdminToolsRecord].Handle, 16, 16, 0, 0,
      DI_NORMAL);

    ARect.Left := ARect.Left + 20;
    Text := '';
  end;

  if ItemData = LINE_INFO_PLUS then
  begin
    if Infos[index] <> '' then
    begin
      ARect.Left := ARect.Left + 10;
      R := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ListBox.Canvas.TextHeight('Iy'));
      ARect.Top := ARect.Top + ListBox.Canvas.TextHeight('Iy');
      InfoText := Infos[index];
      ListBox.Canvas.Font.Style := [FsBold];
      DrawText(ListBox.Canvas.Handle, PWideChar(InfoText), Length(InfoText), R, 0);
      ListBox.Canvas.Font.Style := [];
    end;

    DrawIconEx(ListBox.Canvas.Handle, ARect.Left + 10, ARect.Top, Icons[IndexPlusRecord].Handle, 16, 16, 0, 0,
      DI_NORMAL);
    ARect.Left := ARect.Left + 30;
  end;

  if ItemData = LINE_INFO_WARNING then
  begin
    DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, Icons[IndexWarningRecord].Handle, 16, 16, 0, 0,
      DI_NORMAL);

    ARect.Left := ARect.Left + 20;
    R := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ListBox.Canvas.TextHeight('Iy'));
    ARect.Top := ARect.Top + ListBox.Canvas.TextHeight('Iy');
    InfoText := TA('Warning') + ':';
    ListBox.Canvas.Font.Style := [FsBold];
    DrawText(ListBox.Canvas.Handle, PWideChar(InfoText), Length(InfoText), R, 0);
    ListBox.Canvas.Font.Style := [];
  end;

    if ItemData = LINE_INFO_ERROR then
    begin
      DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, Icons[IndexErrorRecord].Handle, 16, 16, 0, 0, DI_NORMAL);

      ARect.Left := ARect.Left + 20;
      R := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ListBox.Canvas.TextHeight('Iy'));
      ARect.Top := ARect.Top + ListBox.Canvas.TextHeight('Iy');
      InfoText := TA('Error') + ':';
      ListBox.Canvas.Font.Style := [FsBold];
      DrawText(ListBox.Canvas.Handle, PWideChar(InfoText), Length(InfoText), R, 0);
      ListBox.Canvas.Font.Style := [];
    end;

    DrawText(ListBox.Canvas.Handle, PWideChar(Text), Length(Text), ARect, DT_NOPREFIX + DT_LEFT + DT_WORDBREAK);
  end;

function CalcBitmapToJPEGCompressSize(Bitmap: TBitmap; CompressionRate: Byte; out JpegImageResampled: TJpegImage) : int64;
var
  Jpeg: TJpegImage;
  MS: TMemoryStream;
begin
  Jpeg := TJpegImage.Create;
  try
    Jpeg.Assign(Bitmap);
      if CompressionRate < 1 then
      CompressionRate := 1;
    if CompressionRate > 100 then
      CompressionRate := 100;
    Jpeg.CompressionQuality := CompressionRate;
    Jpeg.Compress;

    MS := TMemoryStream.Create;
    try
      Jpeg.SaveToStream(ms);
      F(Jpeg);
      JpegImageResampled := TJpegImage.Create;
      MS.Seek(0, soFromBeginning);
      JpegImageResampled.LoadFromStream(MS);
      Result := MS.Size;
    finally
      F(MS);
    end;
  finally
    F(Jpeg);
  end;
end;

function CalcJpegResampledSize(Jpeg : TJpegImage; Size : integer; CompressionRate : byte;
    out JpegImageResampled : TJpegImage): Int64;
var
  Bitmap, OutBitmap: TBitmap;
  W, H: Integer;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.Assign(Jpeg);
    OutBitmap := TBitmap.Create;
    try
      W := Jpeg.Width;
      H := Jpeg.Height;
      ProportionalSize(Size, Size, W, H);
      DoResize(W, H, Bitmap, OutBitmap);
      Result := CalcBitmapToJPEGCompressSize(OutBitmap, CompressionRate, JpegImageResampled);
    finally
      F(OutBitmap);
    end;
  finally
    F(Bitmap);
  end;
end;

procedure DrawColorMaskTo32Bit(Dest, Mask: TBitmap; Color: TColor; X, Y: Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW  : integer;
  pS : PARGB;
  pD : PARGB32;
  R, G, B, W, W1 : Byte;
begin
  Dest.PixelFormat := pf32bit;
  Mask.PixelFormat := pf24bit;
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  DH := Dest.Height;
  DW := Dest.Width;
  SH := Mask.Height;
  SW := Mask.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Mask.ScanLine[I];
    pD := Dest.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;

      W1 := pS[J].R;
      W := 255 - W1;
      pD[XD].R := (R * W + pD[XD].R * W1 + $7F) div $FF;
      pD[XD].G := (G * W + pD[XD].G * W1 + $7F) div $FF;
      pD[XD].B := (B * W + pD[XD].B * W1 + $7F) div $FF;
      pD[XD].L := ($FF * W + pD[XD].L * W1 + $7F) div $FF;
    end;
  end;
end;

procedure DrawImageEx24To32(Dest32, Src24 : TBitmap; X, Y : Integer; NewTransparent : Byte = 0);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW  : integer;
  pS : PARGB;
  pD : PARGB32;
begin
  DH := Dest32.Height;
  DW := Dest32.Width;
  SH := Src24.Height;
  SW := Src24.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src24.ScanLine[I];
    pD := Dest32.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;
      pD[XD].R := pS[J].R;
      pD[XD].G := pS[J].G;
      pD[XD].B := pS[J].B;
      pD[XD].L := NewTransparent;
    end;
  end;
end;

procedure InverseTransparenty(Bitmap32: TBitmap);
var
  I, J : Integer;
  P : PARGB32;
begin
  Bitmap32.PixelFormat := pf32Bit;
  for I := 0 to Bitmap32.Height - 1 do
  begin
    P := Bitmap32.ScanLine[I];
    for J := 0 to Bitmap32.Width - 1 do
      P[J].L := 255 - P[J].L;
  end;
end;

procedure DrawImageEx32To24(Dest24, Src32 : TBitmap; X, Y : Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW  : Integer;
  W1, W : Byte;
  pD : PARGB;
  pS : PARGB32;
begin
  DH := Dest24.Height;
  DW := Dest24.Width;
  SH := Src32.Height;
  SW := Src32.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src32.ScanLine[I];
    pD := Dest24.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;

      W := pS[J].L;
      W1 := 255 - W;
      pD[XD].R := (pD[XD].R * W1 + pS[J].R * W + $7F) div $FF;
      pD[XD].G := (pD[XD].G * W1 + pS[J].G * W + $7F) div $FF;
      pD[XD].B := (pD[XD].B * W1 + pS[J].B * W + $7F) div $FF;
    end;
  end;
end;

procedure DrawImageEx32(Dest32, Src32 : TBitmap; X, Y : Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW  : Integer;
  W1, W : Byte;
  pD, pS : PARGB32;
begin
  DH := Dest32.Height;
  DW := Dest32.Width;
  SH := Src32.Height;
  SW := Src32.Width;
  InitSumLMatrix;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src32.ScanLine[I];
    pD := Dest32.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;

      W := pS[J].L;
      W1 := 255 - W;
      pD[XD].R := (pD[XD].R * W1 + pS[J].R * W + $7F) div $FF;
      pD[XD].G := (pD[XD].G * W1 + pS[J].G * W + $7F) div $FF;
      pD[XD].B := (pD[XD].B * W1 + pS[J].B * W + $7F) div $FF;
      pD[XD].L := SumLMatrix[pD[XD].L, W];
    end;
  end;
end;

procedure DrawImageEx(Dest, Src : TBitmap; X, Y : Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW  : integer;
  pS : PARGB;
  pD : PARGB;
begin
  DH := Dest.Height;
  DW := Dest.Width;
  SH := Src.Height;
  SW := Src.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src.ScanLine[I];
    pD := Dest.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;
      pD[XD] := pS[J];
    end;
  end;
end;

procedure FillTransparentColor(Bitmap : TBitmap; Color : TColor; TransparentValue : Byte = 0);
var
  I, J : Integer;
  p : PARGB32;
  R, G, B : Byte;
begin
  Bitmap.PixelFormat := pf32Bit;
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  for I := 0 to Bitmap.Height - 1 do
  begin
    p := Bitmap.ScanLine[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      p[j].R := R;
      p[j].G := G;
      p[j].B := B;
      p[j].L := TransparentValue;
    end;
  end;
end;

procedure FillColorEx(Bitmap : TBitmap; Color : TColor);
var
  I, J : Integer;
  p : PARGB;
  R, G, B : Byte;
begin
  Bitmap.PixelFormat := Pf24Bit;
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  if Bitmap.PixelFormat = Pf24bit then
  begin
    for I := 0 to Bitmap.Height - 1 do
    begin
      P := Bitmap.ScanLine[I];
      for J := 0 to Bitmap.Width - 1 do
      begin
        P[J].R := R;
        P[J].G := G;
        P[J].B := B;
      end;
    end;
  end;
end;

procedure LoadBMPImage32bit(S: TBitmap; D: TBitmap; BackGroundColor: TColor);
var
  I, J, W1, W2: integer;
  PD : PARGB;
  PS : PARGB32;
  R, G, B : byte;
begin
  BackGroundColor := ColorToRGB(BackGroundColor);
  R := GetRValue(BackGroundColor);
  G := GetGValue(BackGroundColor);
  B := GetBValue(BackGroundColor);
  if D.PixelFormat <> pf24bit then
    D.PixelFormat := pf24bit;
  D.SetSize(S.Width, S.Height);

  for I := 0 to S.Height - 1 do
  begin
    PD := D.ScanLine[I];
    PS := S.ScanLine[I];
    for J:=0 to S.Width - 1 do
    begin
      W1 := PS[J].L;
      W2 := 255 - W1;
      PD[J].R := (R * W2 + PS[J].R * W1 + $7F) div $FF;
      PD[J].G := (G * W2 + PS[J].G * W1 + $7F) div $FF;
      PD[J].B := (B * W2 + PS[J].B * W1 + $7F) div $FF;
    end;
  end;
end;

procedure LoadGIFImage32bit(GIF : TGIFSubImage; Bitmap : TBitmap; BackGroundColorIndex : integer;
    BackGroundColor : TColor);
var
  I, J: Integer;
  P: PARGB;
  R, G, B: Byte;
begin
  BackGroundColor := ColorToRGB(BackGroundColor);
  R := GetRValue(BackGroundColor);
  G := GetGValue(BackGroundColor);
  B := GetBValue(BackGroundColor);
  Bitmap.PixelFormat := pf24bit;
  for I := 0 to GIF.Top - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := GIF.Top + GIF.Height to Bitmap.Height - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := GIF.Top to GIF.Top + GIF.Height - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := 0 to GIF.Left - 1 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := GIF.Top to GIF.Top + GIF.Height - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := GIF.Left + GIF.Width - 1 to Bitmap.Width - 2 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := 0 to GIF.Height - 1 do
  begin
    P := Bitmap.ScanLine[I + GIF.Top];
    for J := 0 to GIF.Width - 1 do
    begin
      if GIF.Pixels[J, I] = BackGroundColorIndex then
      begin
        P[J + GIF.Left].R := R;
        P[J + GIF.Left].G := G;
        P[J + GIF.Left].B := B;
      end;
    end;
  end;
end;

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

procedure AssignJpeg(Bitmap : TBitmap; Jpeg : TJPEGImage);
begin
  JPEG.Performance := jpBestSpeed;
  JPEG.DIBNeeded;
  AssignBitmap(Bitmap, TJPEGX(JPEG).InnerBitmap);
end;

procedure AssignGraphic(Dest : TBitmap; Src : TGraphic);
begin
  if ((Src is TBitmap) and (TBitmap(Src).PixelFormat = pf32Bit))
    or ((Src is TPngImage) and (TPngImage(Src).TransparencyMode <> ptmNone)) then
    Dest.PixelFormat := pf32Bit
  else
    Dest.PixelFormat := pf24Bit;

  if Src is TJpegImage then
    AssignJpeg(Dest, TJpegImage(Src))
  else if Src is TRAWImage then
    Dest.Assign(TRAWImage(Src))
  else if Src is TBitmap then
    AssignBitmap(Dest, TBitmap(Src))
  else if Src is TPngImage then
  begin
    if TPngImage(Src).TransparencyMode <> ptmNone then
      LoadPNGImageTransparent(TPngImage(Src), Dest)
    else
      LoadPNGImageWOTransparent(TPngImage(Src), Dest);
  end
  else
    Dest.Assign(Src);
end;

procedure LoadImageX(Image: TGraphic; Bitmap: TBitmap; BackGround: TColor);
begin
  if Image is TGIFImage then
  begin
    if not(Image as TGIFImage).Images[0].Empty then
      if (Image as TGIFImage).Images[0].Transparent then
      begin
        Bitmap.Assign(Image);
        if (Image as TGIFImage).Images[0].GraphicControlExtension <> nil then
          LoadGIFImage32bit((Image as TGIFImage).Images[0], Bitmap, (Image as TGIFImage).Images[0].GraphicControlExtension.TransparentColorIndex, BackGround);
        Exit;
      end;
  end;
  AssignGraphic(Bitmap, Image);
end;

procedure DoResize(Width,Height : integer; S,D : TBitmap);
begin
  if (Width = 0) or (Height = 0) then
    Exit;
  if (S.Width = 0) or (S.Height = 0) then
    Exit;

  if (S.PixelFormat = pf32bit) and (D.PixelFormat = pf32bit) then
  begin
    StretchCool(Width, Height, S, D);
    Exit;
  end;

  if (Width / S.Width > 1) or (Height / S.Height > 1) then
    Interpolate(0, 0, Width, Height, Rect(0, 0, S.Width, S.Height), S, D)
  else
  begin
    if ((S.Width div Width >= 8) or (S.Height div Height >= 8)) and
      (S.Width > 2) and (S.Height > 2) then
      QuickReduce(Width, Height, S, D)
    else
    begin
      if (Width / S.Width > ZoomSmoothMin) and (S.PixelFormat <> pf32bit) then
        SmoothResize(Width, Height, S, D)
      else
        StretchCool(Width, Height, S, D);
    end;
  end;
end;

procedure StretchCool(x, y, Width, Height : Integer; S, D : TBitmap);
var
  i,j,k,p,Sheight1:integer;
  P1: Pargb;
  Col, R, G, B: Integer;
  Sh, Sw: Extended;
  Xp: array of PARGB;
  S_h, S_w: Integer;
  XAW : array of Integer;
  YMin, YMax : Integer;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  Sh := S.Height / Height;
  Sw := S.Width / Width;
  Sheight1 := S.Height - 1;
  SetLength(Xp, S.Height);
  for I := 0 to Sheight1 do
    Xp[I] := S.ScanLine[I];
  S_w := S.Width - 1;
  S_h := S.Height - 1;
  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Max(0, Y) to Height + Y - 1 do
  begin
    P1 := D.ScanLine[I];
    YMin := Max(0, Round(Sh * (I - Y)));
    YMax := Min(S_h, Round(Sh * (I - Y + 1 )) - 1);
    for J := 0 to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XAW[J] to XAW[J + 1] - 1 do
        begin
          if P > S_w then
            Break;
          Inc(Col);
          Inc(R, Xp[K, P].R);
          Inc(G, Xp[K, P].G);
          Inc(B, Xp[K, P].B);
        end;
      end;
      if (Col <> 0) and (J + X > 0) then
      begin
        P1[J + X].R := R div Col;
        P1[J + X].G := G div Col;
        P1[J + X].B := B div Col;
      end;
    end;
  end;
end;

procedure Interpolate(X, Y, Width, Height: Integer; Rect: TRect; S, D: TBitmap);
var
  Z1, Z2: single;
  K: Single;
  I, J, SW: Integer;
  Dw, Dh, Xo, Yo: Integer;
  Y1r: Extended;
  Xs, Xd: array of PARGB;
  Dx, Dy, Dxjx1r: Extended;
  XAW : array of Integer;
  XAWD : array of Extended;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  D.SetSize(Math.Max(D.Width, X + Width), Math.Max(D.height, Y + Height));
  SW := S.Width;
  Dw := Math.Min(D.Width - X, X + Width);
  Dh := Math.Min(D.Height - y, Y + Height);
  Dx := Width / (Rect.Right - Rect.Left - 1);
  Dy := Height / (Rect.Bottom - Rect.Top - 1);
  if (Dx < 1) and (Dy < 1) then
    Exit;
  SetLength(Xs, S.Height);
  for I := 0 to S.Height - 1 do
    Xs[I] := S.Scanline[I];
  SetLength(Xd, D.Height);
  for I := 0 to D.Height - 1 do
    Xd[I] := D.Scanline[I];
  SetLength(XAW, Width + 1);
  SetLength(XAWD, Width + 1);
  for I := 0 to Width do
  begin
    XAW[I] := FastTrunc(I / Dx);
    XAWD[I] := I / Dx - XAW[I];
  end;

  for I := 0 to Min(Round((Rect.Bottom - Rect.Top - 1) * Dy) - 1, Dh - 1) do
  begin
    Yo := FastTrunc(I / Dy) + Rect.Top;
    Y1r := FastTrunc(I / Dy) * Dy;
    if Yo > S.Height then
      Break;
    if I + Y < 0 then
      Continue;

    for J := 0 to Min(Round((Rect.Right - Rect.Left - 1) * Dx) - 1, Dw - 1) do
    begin
      Xo := XAW[J] + Rect.Left;
      if xo > SW then
        Continue;
      if J + X < 0 then
        Continue;

      Dxjx1r := XAWD[J];

      Z1 := (Xs[Yo, Xo + 1].R - Xs[Yo, Xo].R) * Dxjx1r + Xs[Yo, Xo].R;
      Z2 := (Xs[Yo + 1, Xo + 1].R - Xs[Yo + 1, Xo].R) * Dxjx1r + Xs[Yo + 1, Xo].R;
      k := (z2 - Z1) / Dy;
      Xd[I + Y, J + X].R := Round(I * K + Z1 - Y1r * K);

      Z1 := (Xs[Yo, Xo + 1].G - Xs[Yo, Xo].G)* Dxjx1r + Xs[Yo, Xo].G;
      Z2 := (Xs[Yo + 1, Xo + 1].G - Xs[Yo + 1, Xo].G) * Dxjx1r + Xs[Yo + 1, Xo].G;
      K := (Z2 - Z1) / Dy;
      Xd[I + Y, J + X].G := Round(I * K + Z1 - Y1r * K);

      Z1 := (Xs[Yo, Xo + 1].B - Xs[Yo, Xo].B) * Dxjx1r + Xs[Yo, Xo].B;
      Z2 := (Xs[Yo + 1, Xo + 1].B - Xs[Yo + 1, Xo].B)  * Dxjx1r + Xs[Yo + 1, Xo].B;
      K := (Z2 - Z1) / Dy;
      Xd[I + Y, J + X].B := Round(I * K + Z1 - Y1r * K);
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
      Image.Assign(Bitmap);
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[I];
        PD := Bitmap.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PD[J] := PS[Image.Width - 1 - J];
      end;
    end else
    begin
      Image.Assign(Bitmap);
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[I];
        PD32 := Bitmap.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PD32[J] := PS32[Image.Width - 1 - J];
      end;
    end;
  finally
    Image.Free;
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
      Image.PixelFormat := pf24bit;
      Image.Assign(Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA, Image.Width);
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
      Image.Assign(Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA32, Image.Height);
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
    Image.Free;
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
    if Image.PixelFormat <> pf32bit then
    begin
      Bitmap.PixelFormat := pf24bit;
      Image.Assign(Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA, Image.Width);
      for I := 0 to Image.Width - 1 do
        PA[I] := Bitmap.ScanLine[I];
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PA[J, I] := PS[J];
      end;
    end else
    begin
      Image.Assign(Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA, Image.Width);
      for I := 0 to Image.Width - 1 do
        PA32[I] := Bitmap.ScanLine[I];
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PA32[J, I] := PS32[J];
      end;
    end;
  finally
    Image.Free;
  end;
end;

procedure QuickReduce(NewWidth, NewHeight : integer; BmpIn, BmpOut : TBitmap);
var
  x, y, xi1, yi1, xi2, yi2, xx, yy, lw1 : integer;
  bufw, bufh, outw, outh : integer;
  sumr, sumb, sumg, Pixcnt: Dword;
  AdrIn, AdrOut, AdrLine0, DeltaLine, DeltaLine2: Integer;
begin
{$R-}
  BmpIn.PixelFormat := pf24bit;
  BmpOut.PixelFormat := pf24bit;
  BmpOut.SetSize(NewWidth, NewHeight);
  bufw := BmpIn.Width;
  bufh := BmpIn.Height;
  outw := BmpOut.Width;
  outh := BmpOut.Height;
  adrLine0 := Integer(bmpIn.ScanLine[0]);
  deltaLine := Integer(BmpIn.ScanLine[1]) - adrLine0;
 yi2 := 0;
 for y := 0 to outh-1 do
 begin
   adrOut := DWORD(BmpOut.ScanLine[y]);
   yi1 := yi2 {+ 1};
   yi2 := ((y+1) * bufh) div outh - 1;
   if yi2 > bufh-1 then yi2 := bufh;
   xi2 := 0;
   for x := 0 to outw-1 do
   begin
     xi1 := xi2 {+ 1};
     xi2 := ((x+1) * bufw) div outw - 1;
     if xi2 > bufw-1 then xi2 := bufw-1; //
     lw1 := xi2-xi1+1;
     deltaLine2 := deltaLine - lw1*3;
     sumb := 0;
     sumg := 0;
     sumr := 0;
     adrIn := adrLine0 + yi1*deltaLine + xi1*3;
     for yy := yi1 to yi2 do
     begin
       for xx := 1 to lw1 do
       begin
         Inc(sumb, PByte(adrIn+0)^);
         Inc(sumg, PByte(adrIn+1)^);
         Inc(sumr, PByte(adrIn+2)^);
         Inc(adrIn, 3);
       end;
       Inc (adrIn, deltaLine2);
     end;
     pixcnt := (yi2-yi1+1)*lw1;
     if pixcnt<>0 then
     begin
      PByte(adrOut+0)^ := sumb div pixcnt;
      PByte(adrOut+1)^ := sumg div pixcnt;
      PByte(adrOut+2)^ := sumr div pixcnt;
     end;
     Inc(adrOut, 3);
   end;
 end;
end;

procedure StretchCool(Width, Height : Integer; S, D : TBitmap);
var
  I, J, K, F : Integer;
  P : PARGB;
  XP : array of PARGB;
  P32 : PARGB32;
  XP32 : array of PARGB32;
  Count, R, G, B, L, Sheight1, SHI, SWI : Integer;
  SH, SW : Extended;
  YMin, YMax : Integer;
  XAW : array of Integer;
begin
  if Width + Height = 0 then
    Exit;

  if S.PixelFormat = pf32bit then
    D.PixelFormat := pf32bit
  else
  begin
    S.PixelFormat := pf24bit;
    D.PixelFormat := pf24bit;
  end;
  D.Width := Width;
  D.Height := Height;
  SH := S.Height / Height;
  SW := S.Width / Width;
  Sheight1 := S.height - 1;
  SHI := S.Height;
  SWI := S.Width;

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  if S.PixelFormat = pf24bit then
  begin
    SetLength(XP, S.height);
    for I := 0 to Sheight1 do
      XP[I] := S.ScanLine[I];

    for I := 0 to Height - 1 do
    begin
      P := D.ScanLine[I];
      YMin := Round(SH * I);
      YMax := MinI32(SHI - 1, Round(SH * (I + 1)) - 1);
      for J := 0 to Width - 1 do
      begin
        Count := 0;
        R := 0;
        G := 0;
        B := 0;
        for K := YMin to YMax do
        begin
          for F := XAW[J] to MinI32(SWI - 1, XAW[J + 1] - 1) do
          begin
            Inc(Count);
            Inc(R, XP[K, F].R);
            Inc(G, XP[K, F].G);
            Inc(B, XP[K, F].B);
          end;
        end;
        if Count <> 0 then
        begin
          P[J].R := R div Count;
          P[J].G := G div Count;
          P[J].B := B div Count;
        end;
      end;
    end;
  end else
  begin
    SetLength(XP32, S.height);
    for I := 0 to Sheight1 do
      XP32[I] := S.ScanLine[I];

    for I := 0 to Height - 1 do
    begin
      P32 := D.ScanLine[I];
      YMin := Round(SH * I);
      YMax := MinI32(SHI - 1, Round(SH * (I + 1)) - 1);
      for J := 0 to Width - 1 do
      begin
        Count := 0;
        R := 0;
        G := 0;
        B := 0;
        L := 0;
        for K := YMin to YMax do
        begin
          for F := XAW[J] to MinI32(SWI - 1, XAW[J + 1] - 1) do
          begin
            Inc(Count);
            Inc(R, XP32[K, F].R);
            Inc(G, XP32[K, F].G);
            Inc(B, XP32[K, F].B);
            Inc(L, XP32[K, F].L);
          end;
        end;
        if Count <> 0 then
        begin
          P32[J].R := R div Count;
          P32[J].G := G div Count;
          P32[J].B := B div Count;
          P32[J].L := L div Count;
        end;
      end;
    end;
  end;
end;

procedure QuickReduceWide(Width, Height : integer; S,D : TBitmap);
begin
  if (Width=0) or (Height=0) then
    Exit;
  if ((S.Width div Width>=8) or (S.Height div Height>=8)) and (S.Width>2) and (S.Height>2) then
    QuickReduce(Width,Height,S,D)
  else
    StretchCool(Width,Height,S,D)
end;

procedure RemoveBlackColor(Bitmap : TBitmap);
var
  I, J : integer;
  P : PARGB;
begin
  for I := 0 to Bitmap.Height - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      if (P[J].R + P[J].G + P[J].B = 0)then
        P[J].G := 1;
    end;
  end;
end;

{ TJPEGX }

function TJPEGX.InnerBitmap: TBitmap;
begin
  Result := Bitmap;
end;

function ExtractSmallIconByPath(IconPath: string; Big: Boolean = False): HIcon;
var
  Path, Icon: string;
  IconIndex, I: Integer;
  Ico1, Ico2: HIcon;
begin
  I := Pos(',', IconPath);
  Path := Copy(IconPath, 1, I - 1);
  Icon := Copy(IconPath, I + 1, Length(IconPath) - I);
  IconIndex := StrToIntDef(Icon, 0);
  Ico1 := 0;

  ExtractIconEx(PWideChar(Path), IconIndex, Ico1, Ico2, 1);

  if Big then
  begin
    Result := Ico1;
    if Ico2 <> 0 then
      DestroyIcon(Ico2);
  end else
  begin
    Result := Ico2;
    if Ico1 <> 0 then
      DestroyIcon(Ico1);
  end;
end;

procedure SetIconToPictureFromPath(Picture : TPicture; IconPath : string);
var
  Icon : TIcon;
begin
  Icon := TIcon.Create;
  try
    Icon.Handle := ExtractSmallIconByPath(IconPath);
    Picture.Graphic := Icon;
  finally
    Icon.Free;
  end;
end;

procedure AddIconToListFromPath(ImageList : TImageList; IconPath : string);
var
  Icon : TIcon;
begin
  Icon := TIcon.Create;
  try
    Icon.Handle := ExtractSmallIconByPath(IconPath);
    ImageList.AddIcon(Icon);
  finally
    Icon.Free;
  end;
end;

end.
