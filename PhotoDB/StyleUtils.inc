{*******************************************************}
{                                                       }
{            Delphi Visual Component Library            }
{                                                       }
{ Copyright(c) 2010-2011 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}


//TODO -oUnassigned -cImplement : x64 : Implement PlatformNotImplemented in this unit or disable for x64.
{$IFDEF CPUX64}
  {$DEFINE PUREPASCAL}
{$ENDIF CPUX64}

{$POINTERMATH ON}

{ from SkinBitmap.pas }

const

  seNone                = $33333333;
  seTransparent         = $007F007F;

type

  { Color type }

  PseColor = ^TseColor;
  TseColor = type cardinal;

  PseColorRec = ^TseColorRec;
  TseColorRec = packed record
    case Cardinal of
      0: (Color: Cardinal);
      2: (HiWord, LoWord: Word);
      3: (B, G, R, A: Byte);
    end;

  PseColorArray = ^TseColorArray;
  TseColorArray = array [0..0] of TseColor;

  PseColorRecArray = ^TseColorRecArray;
  TseColorRecArray = array [0..0] of TseColorRec;

{ TseBitmap }
  TseBitmapLink = class;

  TseBitmap = class(TBitmap)
  private
    FName: string;
    FAlphaBlend: boolean;
  published
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear(Color: TseColor);
    procedure ClearAlpha(Alpha: byte);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure Draw(Canvas: TCanvas; X, Y: integer); reintroduce; overload;
    procedure Draw(Canvas: TCanvas; X, Y: integer; const SrcRect: TRect); reintroduce; overload;
    procedure Draw(Canvas: TCanvas; const DstRect: TRect); reintroduce; overload;
    procedure Draw(Canvas: TCanvas; const DstRect, SrcRect: TRect); reintroduce; overload;
    procedure Tile(Canvas: TCanvas; const DstRect, SrcRect: TRect);
    procedure TileClip(ACanvas: TCanvas; const DstRect, DstClip, SrcRect: TRect);
    procedure FlipVert;
    procedure Rotate90_1(Dest: TseBitmap);
    procedure Rotate90_2(Dest: TseBitmap);
    function GetBitmapLink(const Rect: TRect): TseBitmapLink; overload;
    function GetBitmapLink(const Rect: string): TseBitmapLink; overload;
    property AlphaBlend: boolean read FAlphaBlend write FAlphaBlend;
    property Name: string read FName write FName;
  end;

{ TseBitmapLink }

  TseBitmapLink = class(TPersistent)
  private
    FImage: TseBitmap;
    FRect: TRect;
    FName: string;
    FMaskedBorder: boolean;
    FMaskedAngles: boolean;
    FMasked: boolean;
    function GetBottom: integer;
    function GetLeft: integer;
    function GetRight: integer;
    function GetTop: integer;
    procedure SetBottom(const Value: integer);
    procedure SetLeft(const Value: integer);
    procedure SetRight(const Value: integer);
    procedure SetTop(const Value: integer);
    function GetAssigned: boolean;
  public
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    procedure CheckingMasked; overload;
    procedure CheckingMasked(const Margin: TRect); overload;

    procedure Draw(Canvas: TCanvas; X, Y: integer); overload;
    procedure Draw(Bitmap: TseBitmap; X, Y: integer); overload;

    property Assigned: boolean read GetAssigned;
    property Image: TseBitmap read FImage write FImage;
    property Rect: TRect read FRect write FRect;
    property Masked: boolean read FMasked write FMasked;
    property MaskedBorder: boolean read FMaskedBorder write FMaskedBorder;
    property MaskedAngles: boolean read FMaskedAngles write FMaskedAngles;
  published
    property Name: string read FName write FName;
    property Left: integer read GetLeft write SetLeft;
    property Top: integer read GetTop write SetTop;
    property Right: integer read GetRight write SetRight;
    property Bottom: integer read GetBottom write SetBottom;
  end;

  TseBitmapList = class(TList)
  private
    function GetImage(index: integer): TseBitmap;
    function GetBitmapByName(index: string): TseBitmap;
  protected
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear; override;

    function GetBitmapLink(Image: TseBitmap; const Rect: TRect): TseBitmapLink; overload;
    function GetBitmapLink(const Name: string; const Rect: TRect): TseBitmapLink; overload;
    function GetBitmapLink(const Name, Rect: string): TseBitmapLink; overload;

    property Bitmaps[index: integer]: TseBitmap read GetImage; default;
    property BitmapByName[index: string]: TseBitmap read GetBitmapByName;
  end;

function SeColorToColor(Color32: longword): TColor; forward;

{ end StyleBitmap.pas}

type
  TTokenSeparators = TSysCharSet;

function GetToken(var S: string): string; overload; forward;
function GetToken(var S: string; const Separators: string): string; overload; forward;
function GetToken(var S: string; Separators: TTokenSeparators): string; overload; forward;

//TODO: Change to string
function ReadString(S: TStream): string; forward;
//TODO: Change to string
procedure WriteString(S: TStream; const Value: string); forward;

function RectToString(const R: TRect): string; forward;
function StringToRect(const Str: string): TRect; forward;

{ Rect, Point and Polygon }

function RectCenter(var R: TRect; const Bounds: TRect): TRect; forward;
function MarginRect(const ARect, AMargin: TRect): TRect; forward;

{ Mouse capture }

var
  CaptureHandle: Hwnd = 0;

procedure CaptureMouse(const Wnd: HWND); forward;
procedure EndCapture; forward;

{ Drawing }

function DrawText(ACanvas: TCanvas; const AText: string; var Bounds: TRect; Flag: Cardinal): Integer; overload; forward;
function DrawText(ACanvas: TCanvas; const AText: string; X, Y: Integer): Integer; overload; forward;
function DrawVerticalText(Canvas: TCanvas; const AText: string; const Bounds: TRect; Flag: Cardinal; FromTop: boolean): Integer; forward;

function TextWidth(Canvas: TCanvas; const AText: string; Flags: Integer = 0): Integer; forward;
function TextHeight(Canvas: TCanvas; const AText: string): Integer; forward;

procedure FillRect(Canvas: TCanvas; const Rect: TRect; Color: TColor); overload; forward;
procedure FillRect(Canvas: TCanvas; ALeft, ATop, ARight, ABottom: integer; Color: TColor); overload; forward;
procedure FillRect(DC: HDC; ALeft, ATop, ARight, ABottom: integer; Color: TColor); overload; forward;

procedure DrawRect(Canvas: TCanvas; const Rect: TRect; Color: TColor); overload; forward;
procedure DrawRect(Canvas: TCanvas; ALeft, ATop, ARight, ABottom: integer; Color: TColor); overload; forward;

procedure FillRoundRect(Canvas: TCanvas; const ARect: TRect; Radius: integer; Color: TColor); forward;

procedure DrawFrameControlGlyph(Canvas: TCanvas; const ARect: TRect; AType, AStyle: cardinal; Color: TColor); forward;

procedure DrawFocusRect(Canvas: TCanvas; const Rect: TRect; Color: TColor); forward;

procedure StyleUtilsDrawEdge(Canvas: TCanvas; const Rect: TRect; RaisedColor, SunkenColor: TColor); overload; forward;
procedure StyleUtilsDrawEdge(Canvas: TCanvas; ALeft, ATop, ARight, ABottom: integer; RaisedColor, SunkenColor: TColor); overload; forward;

function TrimStr(DC: HDC; const S: string; Width: integer): string; forward;

{ Region }

function CreateRegionFromBitmap(Bitmap: TSeBitmap; Left, Top: integer): HRgn; forward;


{ implementation }


function GetToken(var S: string): string;
{ Return first token and remove it from S }
var
  i: byte;
  CopyS: string;
begin
  Result := '';
  CopyS := S;
  for i := 1 to Length(CopyS) do
  begin
    Delete(S, 1, 1);
    if CharInSet(CopyS[i], [',', ' ', '(', ')', ';', ':', '=']) then Break;
    Result := Result + CopyS[i];
  end;
  Result := Trim(Result);
  S := Trim(S);
end;

function GetToken(var S: string; const Separators: string): string;
var
  i: byte;
  CopyS: string;
begin
  Result := '';
  CopyS := S;
  for i := 1 to Length(CopyS) do
  begin
    Delete(S, 1, 1);
    if Pos(CopyS[i], Separators) > 0 then Break;
    Result := Result + CopyS[i];
  end;
  Result := Trim(Result);
  S := Trim(S);
end;

function GetToken(var S: string; Separators: TTokenSeparators): string;
var
  i: byte;
  CopyS: string;
begin
  Result := '';
  CopyS := S;
  for i := 1 to Length(CopyS) do
  begin
    Delete(S, 1, 1);
    if CharInSet(CopyS[i], Separators) then
      Break;
    Result := Result + CopyS[i];
  end;
  Result := Trim(Result);
  S := Trim(S);
end;

function ReadString(S: TStream): string;
var
  L: Integer;
begin
  L := 0;
  S.Read(L, SizeOf(L));
  SetLength(Result, L);
  S.Read(Pointer(Result)^, L * 2);
end;

procedure WriteString(S: TStream; const Value: string);
var
  L: Integer;
begin
  L := Length(Value);
  S.Write(L, SizeOf(L));
  S.Write(Pointer(Value)^, L * 2);
end;

function RectToString(const R: TRect): string;
{ Convert TRect to string }
begin
  Result := '(' + IntToStr(R.Left) + ',' + IntToStr(R.Top) + ',' + IntToStr(R.Right) + ',' +
    IntToStr(R.Bottom) + ')';
end;

function StringToRect(const Str: string): TRect;
{ Convert string to TRect }
var
  S: string;
begin
  S := Str;
  try
    Result.Left := StrToInt(GetToken(S));
    Result.Top := StrToInt(GetToken(S));
    Result.Right := StrToInt(GetToken(S));
    Result.Bottom := StrToInt(GetToken(S));
  except
    Result := Rect(0, 0, 0, 0);
  end;
end;

{ Rect and Point ==============================================================}

function RectCenter(var R: TRect; const Bounds: TRect): TRect;
begin
  OffsetRect(R, -R.Left, -R.Top);
  OffsetRect(R, (Bounds.Width - R.Width) div 2, (Bounds.Height - R.Height) div 2);
  OffsetRect(R, Bounds.Left, Bounds.Top);

  Result := R;
end;

function MarginRect(const ARect, AMargin: TRect): TRect;
var
  Dx: single;
begin
  Result := ARect;

  if (AMargin.Left > ARect.Width) or (AMargin.Right > ARect.Width) or (AMargin.Left + AMargin.Right > ARect.Width) then
  begin
    if (AMargin.Left + AMargin.Right) <> 0 then
      Dx := ARect.Width / (AMargin.Left + AMargin.Right)
    else
      Dx := 1;
    Result.Left := Result.Left + Round(AMargin.Left * Dx);
    Result.Top := Result.Top + AMargin.Top;
    Result.Right := Result.Right - Round(AMargin.Right * Dx);
    Result.Bottom := Result.Bottom - AMargin.Bottom;
  end
  else
  if (AMargin.Top > ARect.Height) or (AMargin.Bottom > ARect.Height) or (AMargin.Top + AMargin.Bottom > ARect.Height) then
  begin
    if (AMargin.Top + AMargin.Bottom) <> 0 then
      Dx := ARect.Height / (AMargin.Top + AMargin.Bottom)
    else
      Dx := 1;
    Result.Left := Result.Left + AMargin.Left;
    Result.Top := Result.Top + Round(AMargin.Top * Dx);
    Result.Right := Result.Right - AMargin.Right;
    Result.Bottom := Result.Bottom - Round(AMargin.Bottom * Dx);
  end
  else
  begin
    Result.Left := Result.Left + AMargin.Left;
    Result.Top := Result.Top + AMargin.Top;
    Result.Right := Result.Right - AMargin.Right;
    Result.Bottom := Result.Bottom - AMargin.Bottom;
  end;
end;

{ Capture =====================================================================}

var
  CaptureCount: integer = 0;

procedure CaptureMouse(const Wnd: HWND);
begin
  if CaptureCount = 0 then
  begin
    CaptureHandle := Wnd;
    SetCapture(CaptureHandle);
  end;
  Inc(CaptureCount);
end;

procedure EndCapture;
begin
  Dec(CaptureCount);
  if CaptureCount = 0 then
  begin
    if GetCapture = CaptureHandle then
      ReleaseCapture;
    CaptureHandle := 0;
  end;
end;

{ Drawing }

function DrawText(ACanvas: TCanvas; const AText: string; var Bounds: TRect; Flag: Cardinal): Integer;
begin
  SetBkMode(ACanvas.Handle, TRANSPARENT);
  Result := Winapi.Windows.DrawText(ACanvas.Handle, PChar(AText), Length(AText), Bounds, Flag)
end;

function DrawText(ACanvas: TCanvas; const AText: string; X, Y: Integer): Integer;
var
  R: TRect;
begin
  R := Rect(X, Y, X + TextWidth(ACanvas, AText), Y + ACanvas.TextExtent(AText).cy);
  Result := DrawText(ACanvas, AText, R, 0);
end;

function DrawVerticalText(Canvas: TCanvas; const AText: string; const Bounds: TRect; Flag: Cardinal; FromTop: boolean): Integer;
var
  R, R1: TRect;
  VertBuf, HorzBuf: TSeBitmap;
  i, j: Integer;
  HorzPixel: TseColor;
  TempCanvas: TCanvas;
  SaveFont: HFont;
begin
  R := Bounds;

  VertBuf := TSeBitmap.Create;
  HorzBuf := TSeBitmap.Create;
  SaveFont := SelectObject(HorzBuf.Canvas.Handle, Canvas.Font.Handle);
  try
    HorzBuf.SetSize(R.Height, R.Width);
    VertBuf.SetSize(R.Width, R.Height);

    FillRect(VertBuf.Canvas, Rect(0, 0, VertBuf.Width, VertBuf.Height), TColor(seTransparent));
    FillRect(HorzBuf.Canvas, Rect(0, 0, HorzBuf.Width, HorzBuf.Height), TColor(seTransparent));

    R1 := Rect(0, 0, HorzBuf.Width, HorzBuf.Height);
    TempCanvas := TCanvas.Create;
    TempCanvas.Handle := HorzBuf.Canvas.Handle;
    Result := DrawText(TempCanvas, AText, R1, Flag);
    TempCanvas.Handle := 0;
    TempCanvas.Free;

    for i := 0 to HorzBuf.Width - 1 do
      for j := 0 to HorzBuf.Height - 1 do
      begin
        HorzPixel := HorzBuf.Canvas.Pixels[i, j];
        if HorzPixel = seTransparent then Continue;

        if not FromTop then
          VertBuf.Canvas.Pixels[j, (VertBuf.Height - i)] := HorzPixel
        else
          VertBuf.Canvas.Pixels[(VertBuf.Width - j), i] := HorzPixel;
      end;

    VertBuf.Transparent := true;
    VertBuf.Draw(Canvas, Bounds.Left, Bounds.Top);
  finally
    SelectObject(HorzBuf.Canvas.Handle, SaveFont);
    VertBuf.Free;
    HorzBuf.Free;
  end;
end;

function TextWidth(Canvas: TCanvas; const AText: string; Flags: Integer = 0): Integer;
var
  R: TRect;
begin
  R := Rect(0, 0, 0, 0);
  Winapi.Windows.DrawText(Canvas.Handle, PChar(AText), Length(AText), R, DT_CALCRECT or Flags);
  Result := R.Right;
end;

function TextHeight(Canvas: TCanvas; const AText: string): Integer;
var
  Size: TSize;
begin
  GetTextExtentPoint32W(Canvas.Handle, PChar(AText), Length(AText), Size);
  Result := Size.cy;
end;

procedure FillRect(Canvas: TCanvas; const Rect: TRect; Color: TColor);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect);
end;

procedure FillRect(Canvas: TCanvas; ALeft, ATop, ARight, ABottom: integer; Color: TColor); overload;
begin
  FillRect(Canvas, Rect(ALeft, ATop, ARight, ABottom), Color);
end;

procedure FillRect(DC: HDC; ALeft, ATop, ARight, ABottom: integer; Color: TColor);
var
  C: TCanvas;
begin
  C := TCanvas.Create;
  C.Handle := DC;
  FillRect(C, Rect(ALeft, ATop, ARight, ABottom), Color);
  C.Handle := 0;
  C.Free;
end;

procedure DrawRect(Canvas: TCanvas; const Rect: TRect; Color: TColor);
begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := Color;
  with Rect do
    Canvas.Rectangle(Left, Top, Right, Bottom);
end;

procedure DrawRect(Canvas: TCanvas; ALeft, ATop, ARight, ABottom: integer; Color: TColor); overload;
begin
  DrawRect(Canvas, Rect(ALeft, ATop, ARight, ABottom), Color);
end;

procedure FillRoundRect(Canvas: TCanvas; const ARect: TRect; Radius: integer; Color: TColor);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := Canvas.Brush.Color;
  Canvas.RoundRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, Radius, Radius);
end;

procedure DrawFrameControlGlyph(Canvas: TCanvas; const ARect: TRect; AType, AStyle: cardinal; Color: TColor);
var
  B: TSeBitmap;
  i, j: integer;
begin
  { Draw only glyph }
  B := TSeBitmap.Create;
  B.SetSize(ARect.Width, ARect.Height);

  DrawFrameControl(B.Canvas.Handle, Rect(0, 0, B.Width, B.Height), AType, AStyle);

  for i := 0 to B.Width - 1 do
    for j := 0 to B.Height - 1 do
    begin
      if B.Canvas.Pixels[i, j] = 0 then
        B.Canvas.Pixels[i, j] := Color
      else
        B.Canvas.Pixels[i, j] := TColor(seTransparent);
    end;

  B.Transparent := true;
  B.Draw(Canvas, ARect.Left, ARect.Top);

  B.Free;
end;

procedure DrawFocusRect(Canvas: TCanvas; const Rect: TRect; Color: TColor);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  Canvas.DrawFocusRect(Rect);
end;

procedure StyleUtilsDrawEdge(Canvas: TCanvas; const Rect: TRect; RaisedColor, SunkenColor: TColor);
begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Style := psSolid;

  Canvas.Pen.Color := RaisedColor;
  Canvas.MoveTo(Rect.Left, Rect.Bottom - 2);
  Canvas.LineTo(Rect.Left, Rect.Top);
  Canvas.LineTo(Rect.Right - 1, Rect.Top);

  Canvas.Pen.Color := SunkenColor;
  Canvas.MoveTo(Rect.Right - 1, Rect.Top);
  Canvas.LineTo(Rect.Right - 1, Rect.Bottom - 1);
  Canvas.LineTo(Rect.Left - 1, Rect.Bottom - 1);
end;

procedure StyleUtilsDrawEdge(Canvas: TCanvas; ALeft, ATop, ARight, ABottom: integer; RaisedColor, SunkenColor: TColor);
begin
  StyleUtilsDrawEdge(Canvas, Rect(ALeft, ATop, ARight, ABottom), RaisedColor, SunkenColor);
end;

function TrimStr(DC: HDC; const S: string; Width: integer): string;
var
  i: integer;
  Size: TSize;
  Ts: string;
begin
  Result := S;
  FillChar(Size, SizeOf(Size), 0);
  GetTextExtentPoint32W(DC, PWideChar(S), Length(S), Size);

  if Size.cx <= Width then Exit;

  Result := '';
  for i := 1 to Length(S) do
  begin
    Ts := Result + S[i] + '...';
    GetTextExtentPoint32W(DC, PWideChar(Ts), Length(Ts), Size);
    if Size.cx > Width then Break;
    Result := Result + S[i];
  end;
  Result := Result + '...'
end;

{ Region routines =============================================================}

var
  Rts: array [0..5000] of TRect;

function CreateRegionDataFromBitmap(Bitmap: TSeBitmap; var RgnData: PRgnData;
  Left, Top: integer): HRgn;
var
  j, i, i1: integer;
  Line: PseColor;
  C: PseColor;
  Count: integer;
begin
  Result := 0;

  if Bitmap.Empty then Exit;
  if Bitmap.Width * Bitmap.Height = 0 then Exit;

  Count := 0;
  for j := 0 to Bitmap.Height-1 do
  begin
    Line := Bitmap.Scanline[j];
    i := -1;
    while i < Bitmap.Width do
    begin
      repeat
        Inc(i);
        C := @Line[i];
        if i >= Bitmap.Width then Break;
      until not (C^ = $7F007F);

      if i >= Bitmap.Width then Break;

      i1 := i;
      repeat
        Inc(i1);
        If (i1 >= Bitmap.Width) Then Break;
        C := @Line[i1];
      until (C^ = $7F007F);

      if i <> i1 then
      begin
        Rts[Count] := Rect(Left + i, Top + j, Left + i1, Top + j + 1);
        Inc(Count);
      end;
      i := i1;
    end;
  end;
  { Make Region data }
  Result := Count * SizeOf(TRect);
  GetMem(Rgndata, SizeOf(TRgnDataHeader) + Result);
  RgnData^.rdh.dwSize := SizeOf(TRgnDataHeader);
  RgnData^.rdh.iType := RDH_RECTANGLES;
  RgnData^.rdh.nCount := Count;
  RgnData^.rdh.nRgnSize := 0;
  RgnData^.rdh.rcBound := Rect(0, 0, Bitmap.Width, Bitmap.Height);
  { Update New Region }
  Move(Rts, RgnData^.Buffer, Result);
  Result := SizeOf(TRgnDataHeader) + Count * SizeOf(TRect);
end;

function CreateRegionFromBitmap(Bitmap: TSeBitmap; Left, Top: integer): HRgn;
var
  RgnData: PRgnData;
  Size: integer;
begin
  RgnData := nil;
  Size := CreateRegionDataFromBitmap(Bitmap, RgnData, Left, Top);
  Result := ExtCreateRegion(nil, Size, RgnData^);
  if RgnData <> nil then FreeMem(RgnData, Size);
end;

{  from StyleBitmap.pas }

function SeColorToColor(Color32: longword): TColor;
begin
  Result := Color32;
  TseColorRec(Result).R := TseColorRec(Color32).B;
  TseColorRec(Result).B := TseColorRec(Color32).R;
end;


{ TseBitmap ===================================================================}

{ BitmapLink }

function TseBitmap.GetBitmapLink(const Rect: TRect): TseBitmapLink;
begin
  Result := TseBitmapLink.Create;
  Result.Image := Self;
  Result.Name := Name;
  Result.Rect := Rect;
end;

function TseBitmap.GetBitmapLink(const Rect: string): TseBitmapLink;
begin
  Result := TseBitmapLink.Create;
  Result.Image := Self;
  Result.Name := Name;
  Result.Rect := StringToRect(Rect);
end;

{ Draw }

procedure TseBitmap.Assign(Source: TPersistent);
begin
  if Source is TseBitmap then
  begin
    SetSize(TseBitmap(Source).Width, TseBitmap(Source).Height);
    Move(TseBitmap(Source).ScanLine[TseBitmap(Source).Height - 1]^,
      ScanLine[Height - 1]^, Width * Height * 4);
  end
  else
    inherited;
end;

procedure FillLongword(Src: Pointer; Count: Integer; Value: Longword);
var
  I: Integer;
  S: PseColorArray;
begin
  if Value = 0 then
    FillChar(Src^, Count * 4, 0)
  else if Value = $FFFFFFFF then
    FillChar(Src^, Count * 4, $FF)
  else
  begin
    S := PseColorArray(Src);
    for I := 0 to Count - 1 do
      S[I] := Value;
  end;
end;

procedure TseBitmap.Clear(Color: TseColor);
begin
  FillLongword(Scanline[Height - 1], Width * Height, Color);
end;

procedure FillAlpha(Src: Pointer; Count: Integer; Alpha: byte);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    PseColorRecArray(Src)[I].A := Alpha;
end;

procedure TseBitmap.ClearAlpha(Alpha: byte);
begin
  FillAlpha(Scanline[Height - 1], Width * Height, Alpha);
end;

constructor TseBitmap.Create;
begin
  inherited;
  PixelFormat := pf32bit;
  HandleType := bmDIB;
end;

procedure TseBitmap.Draw(Canvas: TCanvas; X, Y: integer);
begin
  Draw(Canvas, Rect(X, Y, X + Width, Y + Height), Rect(0, 0, Width, Height));
end;

procedure TseBitmap.Draw(Canvas: TCanvas; X, Y: integer; const SrcRect: TRect);
begin
  Draw(Canvas, Rect(X, Y, X + SrcRect.Width, Y + SrcRect.Height), SrcRect);
end;

procedure TseBitmap.Draw(Canvas: TCanvas; const DstRect: TRect);
begin
  Draw(Canvas, DstRect, Rect(0, 0, Width, Height));
end;

procedure TseBitmap.Draw(Canvas: TCanvas; const DstRect, SrcRect: TRect);
var
  BF: TBlendFunction;
begin
  SetStretchBltMode(Canvas.Handle, COLORONCOLOR);
  if AlphaBlend then
  begin
    BF.BlendOp := AC_SRC_OVER;
    BF.BlendFlags := 0;
    BF.SourceConstantAlpha := 255;
    BF.AlphaFormat := AC_SRC_ALPHA;
    Winapi.Windows.AlphaBlend(Canvas.Handle, DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top,
      Self.Canvas.Handle, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, BF);
  end
  else
  if Transparent then
  begin
    Winapi.Windows.TransparentBlt(Canvas.Handle, DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top,
      Self.Canvas.Handle, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, seTransparent);
  end
  else
  begin
    Winapi.Windows.StretchBlt(Canvas.Handle, DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top,
      Self.Canvas.Handle, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, SRCCOPY);
  end;
end;

procedure TseBitmap.Tile(Canvas: TCanvas; const DstRect, SrcRect: TRect);
var
  i, j: integer;
  R, R1, SrcR: TRect;
  Cx, Cy: integer;
  W, H, DW, DH: integer;
begin
  W := SrcRect.Width;
  H := SrcRect.Height;
  if (W=0) or (H=0) then Exit;

  SrcR := Rect(0, 0, W, H);
  OffsetRect(SrcR, DstRect.Left, DstRect.Top);

  Cx := DstRect.Width div W;
  if DstRect.Width mod W <> 0 then Inc(Cx);
  Cy := DstRect.Height div H;
  if DstRect.Height mod H <> 0 then Inc(Cy);

  for i := 0 to Cx do
    for j := 0 to Cy do
    begin
      R := SrcR;
      OffsetRect(R, i * W, j * H);

      IntersectRect(R, R, DstRect);

      DW := R.Width;
      DH := R.Height;

      if (DW = 0) or (DH = 0) then Break;

      R1 := SrcRect;
      if (DW <> W) or (DH <> H) then
      begin
        R1.Right := R1.Left + DW;
        R1.Bottom := R1.Top + DH;
        Draw(Canvas, R, R1);
      end
      else
        Draw(Canvas, R, R1);
    end;
end;

procedure TseBitmap.TileClip(ACanvas: TCanvas; const DstRect, DstClip, SrcRect: TRect);
var
  i, j: integer;
  R, R1, ClipRes, SrcR: TRect;
  Cx, Cy: integer;
  W, H, DW, DH: integer;
  IsClip: boolean;
begin
  W := SrcRect.Width;
  H := SrcRect.Height;
  if W * H = 0 then Exit;

  SrcR := Rect(0, 0, W, H);
  OffsetRect(SrcR, DstRect.Left, DstRect.Top);

  if IsRectEmpty(DstClip) then
    IsClip := false
  else
    IsClip := true;

  Cx := DstRect.Width div W;
  if DstRect.Width mod W <> 0 then Inc(Cx);
  Cy := DstRect.Height div H;
  if DstRect.Height mod H <> 0 then Inc(Cy);

  for i := 0 to Cx do
    for j := 0 to Cy do
    begin
      R := SrcR;
      OffsetRect(R, i * W, j * H);

      IntersectRect(R, R, DstRect);

      DW := R.Width;
      DH := R.Height;

      if (DW = 0) or (DH = 0) then Break;

      if (DW <> W) or (DH <> H) then
      begin
        R1 := SrcRect;
        R1.Right := R1.Left + DW;
        R1.Bottom := R1.Top + DH;
        if IsClip then
        begin
          if IntersectRect(ClipRes, DstClip, R) then
            Draw(ACanvas, R, R1);
        end
        else
          Draw(ACanvas, R, R1);
      end
      else
        if IsClip then
        begin
          if IntersectRect(ClipRes, DstClip, R) then
            Draw(ACanvas, R, SrcRect);
        end
        else
          Draw(ACanvas, R, SrcRect);
    end;
end;

procedure TseBitmap.LoadFromStream(Stream: TStream);
var
  W, H: integer;
begin
  FName := ReadString(Stream);
  Stream.Read(W, SizeOf(Integer));
  Stream.Read(H, SizeOf(Integer));
  if (H > 0) then
  begin
    SetSize(W, H);
    if (Width = W) and (Height = H) then
    begin
      Stream.Read(Scanline[Height - 1]^, Width * Height * SizeOf(Longword));
    end;
  end;
end;

procedure TseBitmap.SaveToStream(Stream: TStream);
var
  W, H: integer;
begin
  W := Width;
  H := Height;
  WriteString(Stream, FName);
  Stream.Write(W, SizeOf(Integer));
  Stream.Write(H, SizeOf(Integer));
  Stream.Write(Scanline[Height - 1]^, Width * Height * SizeOf(Longword));
end;

procedure TseBitmap.Rotate90_1(Dest: TseBitmap);
var
 x, y: Integer;
 P1, P2: PseColor;
begin
  for y := 0 to Height - 1 do
    for x := 0 to Width - 1 do
    begin
      P1 := (PseColor(Dest.Scanline[Width - 1 - x]) + y);
      P2 := (PseColor(Scanline[y]) + x);
      P1^ := P2^;
    end;
end;

procedure TseBitmap.Rotate90_2(Dest: TseBitmap);
var
 x, y: Integer;
 P1, P2: PseColor;
begin
  for y := 0 to Height - 1 do
    for x := 0 to Width - 1 do
    begin
      P1 := (PseColor(Dest.Scanline[x]) + Height - 1 - y);
      P2 := (PseColor(Scanline[y]) + x);
      P1^ := P2^;
    end;
end;

procedure TseBitmap.FlipVert;
var
 J, J2: Integer;
 Buffer: PseColorArray;
 P1, P2: PseColor;
begin
  J2 := Height - 1;
  GetMem(Buffer, Width shl 2);
  for J := 0 to Height div 2 - 1 do
  begin
    P1 := Scanline[J];
    P2 := Scanline[J2];
    Move(P1^, PseColor(Buffer)^, Width * 4);
    Move(P2^, P1^, Width * 4);
    Move(PseColor(Buffer)^, P2^, Width * 4);
    Dec(J2);
  end;
  FreeMem(Buffer);
end;

{ TseBitmapLink ===============================================================}

procedure TseBitmapLink.Assign(Source: TPersistent);
begin
  if Source is TseBitmapLink then
  begin
    FImage := (Source as TseBitmapLink).FImage;
    FRect := (Source as TseBitmapLink).FRect;
    FName := (Source as TseBitmapLink).FName;
    FMasked := (Source as TseBitmapLink).FMasked;
    FMaskedBorder := (Source as TseBitmapLink).FMaskedBorder;
    FMaskedAngles := (Source as TseBitmapLink).FMaskedAngles;
  end
  else
    inherited;
end;

procedure TseBitmapLink.LoadFromStream(Stream: TStream);
begin
  FName := ReadString(Stream);
  Stream.Read(FRect, SizeOf(FRect));
end;

procedure TseBitmapLink.SaveToStream(Stream: TStream);
begin
  WriteString(Stream, FName);
  Stream.Write(FRect, SizeOf(FRect));
end;

procedure TseBitmapLink.CheckingMasked(const Margin: TRect);
var
  i, j: integer;
  P: TseColor;
  Pt: TPoint;
begin
  FMasked := false;
  FMaskedBorder := false;
  FMaskedAngles := false;

  if (Margin.Left = 0) and (Margin.Top = 0) and (Margin.Right = 0) and (Margin.Right = 0) then
  begin
    for i := Left to Right - 1 do
      for j := Top to Bottom - 1 do
      begin
        if (FImage.Scanline[FImage.Height - 1] <> nil) and (i >= 0) and (j >= 0) and (i < FImage.Width) and (j < FImage.Height) then
        begin
          P := (PseColor(FImage.Scanline[j]) + i)^;
          if P = seTransparent then
          begin
            FMasked := true;
            Exit;
          end;
          if TseColorRec(P).A < $FF then
          begin
            FMasked := true;
            Exit;
          end;
        end;
      end;
  end
  else
  begin
    for i := Left to Right - 1 do
      for j := Top to Bottom - 1 do
      begin
        if (FImage.Scanline[FImage.Height - 1] <> nil) and (i >= 0) and (j >= 0) and (i < FImage.Width) and (j < FImage.Height) then
          P := (PseColor(FImage.Scanline[j]) + i)^
        else
          Continue;

        if P <> seNone then
        begin
          if (P = seTransparent) or (TseColorRec(P).A < $FF) then
          begin
            Pt := Point(i - Left, j - Top);
            { Check angles }
            if PtInRect(TRect.Create(0, 0, Margin.Left, Margin.Top), Pt) then
              FMaskedAngles := true;
            if PtInRect(TRect.Create(Right - Margin.Right, 0, Right, Margin.Top), Pt) then
              FMaskedAngles := true;
            if PtInRect(TRect.Create(Right - Margin.Right, Bottom - Margin.Bottom, Right, Bottom), Pt) then
              FMaskedAngles := true;
            if PtInRect(TRect.Create(0, Bottom - Margin.Bottom, Margin.Left, Bottom), Pt) then
              FMaskedAngles := true;

            { Check borders }
            if PtInRect(TRect.Create(Margin.Left, 0, Right - Margin.Right, Margin.Top), Pt) then
              FMaskedBorder := true;
            if PtInRect(TRect.Create(Margin.Left, Bottom - Margin.Bottom, Right - Margin.Right, Bottom), Pt) then
              FMaskedBorder := true;
            if PtInRect(TRect.Create(0, Margin.Top, Margin.Left, Bottom - Margin.Bottom), Pt) then
              FMaskedBorder := true;
            if PtInRect(TRect.Create(Right - Margin.Right, Margin.Top, Right, Bottom - Margin.Bottom), Pt) then
              FMaskedBorder := true;

            if PtInRect(TRect.Create(Margin.Left, Margin.Top, Right - Margin.Right, Bottom - Margin.Bottom), Pt) then
              FMasked := true;
          end;
        end;
      end;
  end;
end;

procedure TseBitmapLink.CheckingMasked;
begin
  CheckingMasked(TRect.Create(0, 0, 0, 0));
end;

procedure TseBitmapLink.Draw(Bitmap: TseBitmap; X, Y: integer);
begin
  if FImage = nil then Exit;
  if FImage.Empty then Exit;
  if FRect.Right - FRect.Left <= 0 then Exit;
  if FRect.Bottom - FRect.Top <= 0 then Exit;
  FImage.Canvas.CopyRect(TRect.Create(X, Y, FRect.Right - FRect.Left, FRect.Bottom - FRect.Top), Image.Canvas, FRect);
end;

procedure TseBitmapLink.Draw(Canvas: TCanvas; X, Y: integer);
begin
  if FImage = nil then Exit;
  if FImage.Empty then Exit;
  if FRect.Right - FRect.Left <= 0 then Exit;
  if FRect.Bottom - FRect.Top <= 0 then Exit;
  FImage.Canvas.CopyRect(TRect.Create(X, Y, FRect.Right - FRect.Left, FRect.Bottom - FRect.Top), Canvas, FRect);
end;

function TseBitmapLink.GetAssigned: boolean;
begin
  Result := (FImage <> nil) and ((FRect.Right - FRect.Left) * (FRect.Bottom - FRect.Top) > 0);
end;

function TseBitmapLink.GetBottom: integer;
begin
  Result := FRect.Bottom;
end;

function TseBitmapLink.GetLeft: integer;
begin
  Result := FRect.Left;
end;

function TseBitmapLink.GetRight: integer;
begin
  Result := FRect.Right;
end;

function TseBitmapLink.GetTop: integer;
begin
  Result := FRect.Top;
end;

procedure TseBitmapLink.SetBottom(const Value: integer);
begin
  FRect.Bottom := Value;
end;

procedure TseBitmapLink.SetLeft(const Value: integer);
begin
  FRect.Left := Value;
end;

procedure TseBitmapLink.SetRight(const Value: integer);
begin
  FRect.Right := Value;
end;

procedure TseBitmapLink.SetTop(const Value: integer);
begin
  FRect.Top := Value;
end;

{ TseBitmapList ===============================================================}

constructor TseBitmapList.Create;
begin
  inherited Create;
end;

destructor TseBitmapList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TseBitmapList.Clear;
var
  i: integer;
begin
  {$WARNINGS OFF}
  for i := 0 to Count-1 do
    TseBitmap(Items[i]).Free;
  {$WARNINGS ON}

  inherited Clear;
end;

function TseBitmapList.GetImage(index: integer): TseBitmap;
begin
  {$WARNINGS OFF}
  if (index >= 0) and (index < Count) then
    Result := TseBitmap(Items[index])
  else
    Result := nil;
  {$WARNINGS ON}
end;

function TseBitmapList.GetBitmapLink(Image: TseBitmap; const Rect: TRect): TseBitmapLink;
var
  i: integer;
begin
  Result := nil;

  { Create BitmapLink }
  for i := 0 to Count - 1 do
    if Bitmaps[i] = Image then
    begin
      Result := Bitmaps[i].GetBitmapLink(Rect);
      Exit;
    end;
end;

function TseBitmapList.GetBitmapLink(const Name: string; const Rect: TRect): TseBitmapLink;
var
  i: integer;
begin
  Result := nil;

  { Create BitmapLink }
  for i := 0 to Count - 1 do
    if CompareText(Bitmaps[i].Name, Name) = 0 then
    begin
      Result := Bitmaps[i].GetBitmapLink(Rect);
      Exit;
    end;
end;

function TseBitmapList.GetBitmapLink(const Name, Rect: string): TseBitmapLink;
var
  i: integer;
begin
  Result := nil;

  { Create BitmapLink }
  for i := 0 to Count - 1 do
    if CompareText(Bitmaps[i].Name, Name) = 0 then
    begin
      Result := Bitmaps[i].GetBitmapLink(Rect);
      Exit;
    end;
end;

function TseBitmapList.GetBitmapByName(index: string): TseBitmap;
var
  i: integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if CompareText(Bitmaps[i].Name, index) = 0 then
    begin
      Result := Bitmaps[i];
      Exit;
    end;
end;

{ end StyleBitmap.pas }
