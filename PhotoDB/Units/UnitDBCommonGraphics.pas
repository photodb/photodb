unit UnitDBCommonGraphics;

interface

 uses Windows, Classes, Messages, Controls, Forms, StdCtrls, Graphics,
      GraphicEx, ShellApi, JPEG, CommCtrl, uMemory,
{$IFDEF PHOTODB}
      DmProgress,
      GIFImage,
      RAWImage,
{$ENDIF}
      UnitDBDeclare, Language, UnitDBCommon, SysUtils,
      GraphicsBaseTypes, Effects, Math, uMath;

 type
   TJPEGX = class(TJpegImage)
   public
     function InnerBitmap : TBitmap;
   end;

 const
    PSDTransparent = false;
    //Image processiong options
    ZoomSmoothMin = 0.4;

{$IFDEF PHOTODB}
  procedure DoInfoListBoxDrawItem(ListBox: TListBox; Index: Integer; aRect: TRect; State: TOwnerDrawState;
    ItemsData : TList; Icons : array of TIcon; FProgressEnabled : boolean; TempProgress : TDmProgress;
    Infos : TArStrings);
{$ENDIF}
  procedure BeginScreenUpdate(hwnd: THandle);
  procedure EndScreenUpdate(hwnd: THandle; erase: Boolean);
  function CalcJpegResampledSize(Jpeg : TJpegImage; Size : integer; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
  function CalcBitmapToJPEGCompressSize(Bitmap : TBitmap; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
  procedure LoadImageX(Image : TGraphic; Bitmap : TBitmap; BackGround : TColor);
  procedure LoadBMPImage32bit(S : TBitmap; D : TBitmap; BackGroundColor : TColor);
  procedure QuickReduce(NewWidth, NewHeight : integer; BmpIn, BmpOut : TBitmap);
  procedure StretchCool(x, y, Width, Height : Integer; S, D : TBitmap); overload;
  procedure StretchCool(Width, Height : integer; S,D : TBitmap); overload;
  Procedure QuickReduceWide(Width, Height : integer; S,D : TBitmap);
  procedure DoResize(Width,Height : integer; S,D : TBitmap);
  procedure Interpolate(x, y, Width, Height : Integer; Rect : TRect; S, D : TBitmap);
  procedure Rotate180A(Bitmap : TBitmap);
  procedure Rotate270A(Bitmap : TBitmap);
  procedure Rotate90A(Bitmap : TBitmap);
  procedure FillColorEx(Bitmap : TBitmap; Color : TColor);
  procedure DrawImageEx(Dest, Src : TBitmap; X, Y : Integer);
  procedure DrawImageEx32(Dest32, Src32 : TBitmap; X, Y : Integer);
  procedure DrawImageEx32To24(Dest24, Src32 : TBitmap; X, Y : Integer);
  procedure DrawImageEx24To32(Dest32, Src24 : TBitmap; X, Y : Integer; NewTransparent : Byte = 0);
  procedure FillTransparentColor(Bitmap : TBitmap; Color : TColor; TransparentValue : Byte = 0);
  procedure DrawTransparent(s, d : TBitmap; Transparent : byte);
  procedure GrayScale(Image : TBitmap);
  procedure SelectedColor(Image : TBitmap; Color : TColor);
  procedure AssignJpeg(Bitmap : TBitmap; Jpeg : TJPEGImage);
  procedure AssignBitmap(Dest : TBitmap; Src : TBitmap);
  procedure AssignGraphic(Dest : TBitmap; Src : TGraphic);
  procedure RemoveBlackColor(Bitmap : TBitmap);
  function ExtractSmallIconByPath(IconPath: string; Big: Boolean = False): HIcon;
  procedure SetIconToPictureFromPath(Picture : TPicture; IconPath : string);
  procedure AddIconToListFromPath(ImageList : TImageList; IconPath : string);
  procedure DrawWatermark(Bitmap : TBitmap; XBlocks, YBlocks : Integer; Text : string; AAngle : Integer; Color : TColor; Transparent : Byte);
  procedure DrawText32Bit(Bitmap32 : TBitmap; Text : string; Font : TFont; ARect : TRect; DrawTextOptions : Cardinal);
  procedure DrawColorMaskTo32Bit(Dest, Mask : TBitmap; Color : TColor; X, Y : Integer);
  procedure DrawShadowToImage(Dest32, Src : TBitmap; Transparenty : Byte = 0);
  procedure DrawRoundGradientVert(Dest32 : TBitmap; Rect : TRect; ColorFrom, ColorTo, BorderColor : TColor; RoundRect : Integer; TransparentValue : Byte = 220);
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
    BitRound.Width := Dest32.Width;
    BitRound.Height := Dest32.Height;
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
    BitRound.Free;
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
  Dest32.Width := SW + 4;
  Dest32.Height := SH + 4;
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
  Bitmap : TBitmap;
  R : TRect;
begin
  Bitmap32.PixelFormat := pf32bit;
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24Bit;
    Bitmap.Canvas.Font.Assign(Font);
    Bitmap.Canvas.Font.Color := ClBlack;
    Bitmap.Canvas.Brush.Color := clWhite;
    Bitmap.Canvas.Pen.Color := clWhite;
    Bitmap.Width := ARect.Right - ARect.Left;
    Bitmap.Height := ARect.Bottom - ARect.Top;
    R := Rect(0, 0, Bitmap.Width, Bitmap.Height);
    DrawText(Bitmap.Canvas.Handle, PWideChar(Text), Length(Text), R, DrawTextOptions);
    DrawColorMaskTo32Bit(Bitmap32, Bitmap, Font.Color, ARect.Left, ARect.Top);
  finally
    Bitmap.Free;
  end;
end;

procedure DrawWatermark(Bitmap : TBitmap; XBlocks, YBlocks : Integer; Text : string; AAngle : Integer; Color : TColor; Transparent : Byte);
var
  lf: TLogFont;
  I, J : Integer;
  X, Y, Width, Height, W, H, TextLength : Integer;
  Angle : Integer;
  Mask : TBitmap;
  PS, PD : PARGB;
  R, G, B : Byte;
  L, L1 : Byte;
begin
  if Text = '' then
    Exit;
  Bitmap.PixelFormat := pf24bit;
  Width := Round(Bitmap.Width / XBlocks);
  Height := Round(Bitmap.Height / YBlocks);
  TextLength := Round(Sqrt(Width * Width + Height * Height));
  Angle :=  Round(10 * 180 * ArcTan(Height / Width) / PI);

  FillChar(lf, SizeOf(lf), 0);
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);

  with lf do begin
    // Ширина буквы
    lfWidth := Round(TextLength * 0.9 / Length(Text));
    // Высота буквы
    lfHeight := Round(lfWidth * 1.5);
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
    StrCopy(lfFaceName, 'Arial');
  end;

  Mask := TBitmap.Create;
  try
    Mask.PixelFormat := pf24bit;
    Mask.Width := Bitmap.Width;
    Mask.Height := Bitmap.Height;

    for I := 0 to Mask.Height - 1 do
    begin
      PS := Mask.ScanLine[I];
      FillChar(PS[0], Mask.Width * 3, $FF);
    end;

    //TODO: thread-safe ?
    Mask.Canvas.Font.Handle := CreateFontIndirect(lf);
    Mask.Canvas.Font.Color := clBlack;
    W := Mask.Canvas.TextWidth(Text);
    H := Mask.Canvas.TextHeight(Text);
    for I := 1 to XBlocks do
      for J := 1 to YBlocks do
      begin
        X := (I - 1) * Width + Round(Width * 0.05);
        Y := (J - 1) * Height - Round(Height * 0.05);
        Mask.Canvas.TextOut(X, Y + Height - H, Text);
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
        PD[J].B := (PD[J].B * L1+ B * L + $7F) div 255;
      end;
    end;
  finally
    Mask.Free;
  end;
end;

procedure BeginScreenUpdate(hwnd: THandle);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 0, 0);
end;

procedure EndScreenUpdate(hwnd: THandle; erase: Boolean);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 1, 0);
  RedrawWindow(hwnd, nil, 0, {DW_FRAME + }RDW_INVALIDATE +
    RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
  if (erase) then
    Windows.InvalidateRect(hwnd, nil, True);
end;

procedure SelectedColor(Image : TBitmap; Color : TColor);
var
  I, J, R, G, B : integer;
  p : PARGB;
begin
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  if Image.PixelFormat<>pf24bit then
    Image.PixelFormat:=pf24bit;

  for I := 0 to Image.Height - 1 do
  begin
    p:=image.ScanLine[I];
    for J:=0 to Image.Width - 1 do
      if Odd(I + J) then
      begin
        p[J].R := R;
        p[J].G := G;
        p[J].B := B;
      end;
  end;
end;

function MixBytes(FG, BG, TRANS: byte): byte;
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

  for i := 0 to Image.Height - 1 do
  begin
    p := Image.ScanLine[I];
    for J:=0 to Image.Width - 1 do
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
  i, j : integer;
  p1, p2 : Pargb;
  G : Byte;
  W1, W2 : Byte;
begin
  W1 := Round((N / 100)*255);
  W2 := 255 - W1;
  for I := 0 to S.Height - 1 do
  begin
    p1 := S.ScanLine[I];
    p2 := D.ScanLine[I];
    for j:=0 to S.Width-1 do
    begin
      G := (p1[j].R * 77 + p1[j].G * 151 + p1[j].B * 28) shr 8;
      p2[j].R := (W2 * p2[j].R + W1 * G) shr 8;
      p2[j].G := (W2 * p2[j].G + W1 * G) shr 8;
      p2[j].B := (W2 * p2[j].B + W1 * G) shr 8;
    end;
  end;
end;

procedure DrawTransparent(S, D : TBitmap; Transparent : byte);
var
  W1, W2, I, J : Integer;
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

{$IFDEF PHOTODB}
procedure DoInfoListBoxDrawItem(ListBox: TListBox; Index: Integer; aRect: TRect; State: TOwnerDrawState;
ItemsData : TList; Icons : array of TIcon; FProgressEnabled : boolean; TempProgress : TDmProgress;
Infos : TArStrings);
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
 ItemData:=PInteger(ItemsData[Index])^;
 if odSelected in State then
 ListBox.Canvas.Brush.Color:=$A0A0A0 else
 ListBox.Canvas.Brush.Color:=ClWhite;
 //clearing rect
 ListBox.Canvas.Pen.Color:=ListBox.Canvas.Brush.Color;
 ListBox.Canvas.Rectangle(aRect);

 ListBox.Canvas.Pen.Color:=ClBlack;
 ListBox.Canvas.Font.Color:=ClBlack;
 Text:=ListBox.Items[index];

 //first Record
 if Index=0 then
 begin
  if TempProgress<>nil then
  begin
   DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexProgressRecord].Handle,16,16,0,0,DI_NORMAL);
   aRect.Left:=aRect.Left+20;
   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=TEXT_MES_PROSESSING_;
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PWideChar(InfoText),Length(InfoText), r ,0);
   if FProgressEnabled then
   begin
    TempProgress.Text:='';
    TempProgress.Width:=aRect.Right-aRect.Left- ListBox.Canvas.TextWidth(InfoText)-10-ListBox.ScrollWidth;
    TempProgress.Height:=ListBox.Canvas.TextHeight('Iy');
    TempProgress.DoPaintOnXY(ListBox.Canvas,r.Left+ListBox.Canvas.TextWidth(InfoText)+10,r.Top);
   end;
  end;
  ListBox.Canvas.Font.Style:=[];
 end;

 if ItemData=LINE_INFO_OK then
 begin
  if Infos[index]<>'' then
  begin
   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PWideChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];
  end;
  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexProcessedRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
 end;

 if ItemData=LINE_INFO_DB then
 begin
  if Infos[index]<>'' then
  begin
   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PWideChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];
  end;

  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexDBRecord].Handle,16,16,0,0,DI_NORMAL);
  aRect.Left:=aRect.Left+20;
 end;


 if ItemData=LINE_INFO_GREETING then
 begin

   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PWideChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];

  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexAdminToolsRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
  Text:='';
 end;


 if ItemData=LINE_INFO_PLUS then
 begin
  if Infos[index]<>'' then
  begin
   aRect.Left:=aRect.Left+10;
   r:=Rect(aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PWideChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];
  end;

  DrawIconEx(ListBox.Canvas.Handle,aRect.Left+10,aRect.Top,Icons[IndexPlusRecord].Handle,16,16,0,0,DI_NORMAL);
  aRect.Left:=aRect.Left+30;
 end;

 if ItemData=LINE_INFO_WARNING then
 begin
  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexWarningRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
  r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
  aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
  InfoText:=TEXT_MES_WARNING+':';
  ListBox.Canvas.Font.Style:=[fsBold];
  DrawText(ListBox.Canvas.Handle,PWideChar(InfoText),Length(InfoText), r ,0);
  ListBox.Canvas.Font.Style:=[];
 end;

 if ItemData=LINE_INFO_ERROR then
 begin
  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexErrorRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
  r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
  aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
  InfoText:=TEXT_MES_ERROR+':';
  ListBox.Canvas.Font.Style:=[fsBold];
  DrawText(ListBox.Canvas.Handle,PWideChar(InfoText),Length(InfoText), r ,0);
  ListBox.Canvas.Font.Style:=[];
 end;

 DrawText(ListBox.Canvas.Handle,PWideChar(Text),Length(Text), aRect,DT_NOPREFIX+DT_LEFT+DT_WORDBREAK);
end;
{$ENDIF}

function CalcBitmapToJPEGCompressSize(Bitmap : TBitmap; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
var
  Jpeg: TJpegImage;
  ms: TMemoryStream;
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

    ms:=TMemoryStream.Create;
    try
      Jpeg.SaveToStream(ms);
      F(Jpeg);
      JpegImageResampled := TJpegImage.Create;
      ms.Seek(0, soFromBeginning);
      JpegImageResampled.LoadFromStream(ms);
      Result := ms.Size;
    finally
      F(ms);
    end;
  finally
    F(Jpeg);
  end;
end;

function CalcJpegResampledSize(Jpeg : TJpegImage; Size : integer; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
var
  Bitmap, OutBitmap : TBitmap;
  w, h : integer;
begin
  Bitmap:=TBitmap.Create;
  try
   Bitmap.Assign(Jpeg);
   OutBitmap:=TBitmap.Create();
   try
      w:=Jpeg.Width;
      h:=Jpeg.Height;
      ProportionalSize(Size,Size,w,h);
      DoResize(w,h,Bitmap,OutBitmap);
      Result:=CalcBitmapToJPEGCompressSize(OutBitmap,CompressionRate,JpegImageResampled);
    finally
      OutBitmap.Free;
    end;
  finally
    Bitmap.Free;
  end;
end;

procedure DrawColorMaskTo32Bit(Dest, Mask : TBitmap; Color : TColor; X, Y : Integer);
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
      pD[XD].L := SumL(pD[XD].L, W);
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
  I, J : integer;
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
  I, J : integer;
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
  D.Width := S.Width;
  D.Height := S.Height;

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

procedure LoadGIFImage32bit(GIF : TGIFSubImage; Bitmap : TBitmap; BackGroundColorIndex : integer; BackGroundColor : TColor);
var
  i, j : integer;
  p : PARGB;
  r,g,b : byte;
begin
  BackGroundColor := ColorToRGB(BackGroundColor);
 r:=GetRValue(BackGroundColor);
 g:=GetGValue(BackGroundColor);
 b:=GetBValue(BackGroundColor);
 Bitmap.PixelFormat:=pf24bit;
 for i:=0 to GIF.Top-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=0 to Bitmap.Width-1 do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=GIF.Top+GIF.Height to Bitmap.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=0 to Bitmap.Width-1 do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=GIF.Top to GIF.Top+GIF.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=0 to GIF.Left-1 do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=GIF.Top to GIF.Top+GIF.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=GIF.Left+GIF.Width-1 to Bitmap.Width-2  do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=0 to GIF.Height-1 do
 begin
  p:=Bitmap.ScanLine[i+GIF.Top];
  for j:=0 to GIF.Width-1 do
  begin
   if GIF.Pixels[j,i]=BackGroundColorIndex then
   begin
    p[j+GIF.Left].r:=r;
    p[j+GIF.Left].g:=g;
    p[j+GIF.Left].b:=b;
   end;
  end;
 end;
end;

procedure AssignBitmap(Dest : TBitmap; Src : TBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  PS32, PD32: PARGB32;
begin
  if Src.PixelFormat <> pf32bit then
  begin
    Src.PixelFormat := pf24bit;
    Dest.PixelFormat := pf24bit;
    Dest.Width := Src.Width;
    Dest.Height := Src.Height;

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
    Dest.Width := Src.Width;
    Dest.Height := Src.Height;

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
  if (Src is TBitmap) and (TBitmap(Src).PixelFormat = pf32Bit) then
    Dest.PixelFormat := pf32Bit
  else
    Dest.PixelFormat := pf24Bit;

  if Src is TJpegImage then
    AssignJpeg(Dest, TJpegImage(Src))
  else if Src is TRAWImage then
    Dest.Assign(TRAWImage(Src))
  else if Src is TBitmap then
    AssignBitmap(Dest, TBitmap(Src))
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
  p1: pargb;
  col,r,g,b : integer;
  Sh, Sw : Extended;
  Xp : array of PARGB;
  s_h, s_w : integer;
begin
 s.PixelFormat:=pf24bit;
 d.PixelFormat:=pf24bit;
 if width+x>d.Width then
 d.Width:=width+x;
 if Height+y>d.Height then
 d.Height:=height+y;
 Sh:=S.height/height;
 Sw:=S.width/width;
 Sheight1:=S.height-1;
 SetLength(Xp,S.height);
 for i:=0 to Sheight1 do
 Xp[i]:=s.ScanLine[i];
 s_w := S.Width-1;
 s_h := S.Height-1;
 for i:=Max(0,y) to height+y-1 do
 begin
  p1:=d.ScanLine[i];
  for j:=0 to  width-1 do
  begin
   col:=0;
   r:=0;
   g:=0;
   b:=0;
   for k:=Round(Sh*(i-y)) to Round(Sh*(i+1-y))-1 do
   begin
    if k > s_h then break;
    if k < 0 then continue;
    for p:=Round(Sw*j) to Round(Sw*(j+1))-1 do
    begin
     if p > s_w then break;
     inc(col);
     inc(r,Xp[k,p].r);
     inc(g,Xp[k,p].g);
     inc(b,Xp[k,p].b);
    end;
   end;
   if (col<>0) and (j+x>0) then
   begin
    p1[j+x].r:=r div col;
    p1[j+x].g:=g div col;
    p1[j+x].b:=b div col;
   end;
  end;
 end;
end;

procedure Interpolate(x, y, Width, Height : Integer; Rect : TRect; S, D : TBitmap);
var
  z1, z2: single;
  k: single;
  i, j: integer;
  dw,dh, xo, yo: integer;
  x1r,y1r : extended;
  Xs, Xd : array of PARGB;
  dx, dy : Extended;
begin
  S.PixelFormat:=Pf24bit;
  D.PixelFormat:=Pf24bit;
  D.Width:=Math.Max(D.Width,x+Width);
  D.height:=Math.Max(D.height,y+Height);
  dw:=Math.Min(D.Width-x,x+Width);
  dh:=Math.Min(D.height-y,y+Height);
  dx:=(Width)/(Rect.Right-Rect.Left-1);
  dy:=(Height)/(Rect.Bottom-Rect.Top-1);
  if (dx<1) and (dy<1) then exit;
  SetLength(Xs,S.Height);
  for i:=0 to S.Height - 1 do
  Xs[i]:=S.scanline[i];
  SetLength(Xd,D.Height);
  for i:=0 to D.Height - 1 do
  Xd[i]:=D.scanline[i];
  try

  for i := 0 to min(Round((Rect.Bottom-Rect.Top-1)*dy)-1,dh-1) do begin
      yo := FastTrunc(i / dy)+Rect.Top;
      y1r:= FastTrunc(i / dy) * dy;
      if yo>S.height then Break;
    for j := 0 to min(Round((Rect.Right-Rect.Left-1)*dx)-1,dw-1) do begin
      xo := FastTrunc(j / dx)+Rect.Left;
      x1r:= FastTrunc(j / dx) * dx;
      if xo>S.Width then Continue;
      begin
       if i+y<0 then continue;
       if j+x<0 then continue;
       z1 := ((Xs[yo ,xo+ 1].r - Xs[yo,xo].r)/ dx)*(j - x1r) + Xs[yo,xo].r;
       z2 := ((Xs[yo+1,xo+1].r - Xs[yo+1,xo].r) / dx)*(j - x1r) + Xs[yo+1,xo].r;
       k := (z2 - z1) / dy;
       Xd[i+y,j+x].r := Round(i * k + z1 - y1r * k);
       z1 := ((Xs[yo ,xo+ 1].g - Xs[yo,xo].g)/ dx)*(j - x1r) + Xs[yo,xo].g;
       z2 := ((Xs[yo+1,xo+1].g - Xs[yo+1,xo].g) / dx)*(j - x1r) + Xs[yo+1,xo].g;
       k := (z2 - z1) / dy;
       Xd[i+y,j+x].g := Round(i * k + z1 - y1r * k);
       z1 := ((Xs[yo ,xo+ 1].b - Xs[yo,xo].b)/ dx)*(j - x1r) + Xs[yo,xo].b;
       z2 := ((Xs[yo+1,xo+1].b - Xs[yo+1,xo].b) / dx)*(j - x1r) + Xs[yo+1,xo].b;
       k := (z2 - z1) / dy;
       Xd[i+y,j+x].b := Round(i * k + z1 - y1r * k);
      end;
    end;
  end;
 except
  end;
end;

procedure Rotate180A(Bitmap : TBitmap);
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
      Bitmap.Width := Image.Height;
      Bitmap.Height := Image.Width;
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
      Bitmap.Width := Image.Height;
      Bitmap.Height := Image.Width;
      SetLength(PA, Image.Width);
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
      Bitmap.Width := Image.Height;
      Bitmap.Height := Image.Width;
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
      Bitmap.Width := Image.Height;
      Bitmap.Height := Image.Width;
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
 sumr, sumb, sumg, pixcnt : dword;
 adrIn, adrOut, adrLine0, deltaLine, deltaLine2 : Integer;
begin
 {$R-}
 BmpIn.PixelFormat := pf24bit;
 BmpOut.PixelFormat := pf24bit;
 BmpOut.Width := NewWidth;
 BmpOut.Height := NewHeight;
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

  if S.PixelFormat = pf24bit then
  begin
    SetLength(XP, S.height);
    for I := 0 to Sheight1 do
      XP[I] := S.ScanLine[I];

    for I := 0 to Height - 1 do
    begin
      P := D.ScanLine[I];
      for J := 0 to Width - 1 do
      begin
        Count := 0;
        R := 0;
        G := 0;
        B := 0;
        for K := Round(SH * I) to MinI32(SHI - 1, Round(SH * (I + 1)) - 1) do
        begin
          for F := Round(SW * J) to MinI32(SWI - 1, Round(SW * (J + 1)) - 1) do
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
      for J := 0 to Width - 1 do
      begin
        Count := 0;
        R := 0;
        G := 0;
        B := 0;
        L := 0;
        for K := Round(SH * I) to MinI32(SHI - 1, Round(SH * (I + 1)) - 1) do
        begin
          for F := Round(SW * J) to MinI32(SWI - 1, Round(SW * (J + 1)) - 1) do
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
