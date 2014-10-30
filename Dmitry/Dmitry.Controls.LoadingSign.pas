unit Dmitry.Controls.LoadingSign;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.Themes,
  Vcl.Imaging.PngImage,
  Dmitry.Memory,
  Dmitry.Controls.Base,
  Dmitry.Graphics.Types;

type
  TGetBackGroundProc = procedure(Sender: TObject; X, Y, W, H: Integer; Bitmap : TBitmap) of object;

type
  TLoadingSign = class(TBaseWinControl)
  private
    { Private declarations }
    FActive: Boolean;
    FTimer: TTimer;
    FVisibleTimer: TTimer;
    FBuffer: TBitmap;
    FCanvas: TCanvas;
    FDrawState: Extended;
    FFillPercent: Byte;
    FSignColor: TColor;
    FGetBackGround: TGetBackGroundProc;
    FResourcePNGRCDataImage: string;
    FImage: TBitmap;
    FVisibility: Integer;
    FVisibilityInc: Integer;
    FMaxTransparencity: Byte;
    procedure SetActive(const Value: Boolean);
    procedure OnTimer(Sender : TObject);
    procedure SetFillPercent(const Value: Byte);
    procedure SetSignColor(const Value: TColor);
    procedure SetGetBackGround(const Value: TGetBackGroundProc);
    procedure SetResourcePNGRCDataImage(const Value: string);
    procedure DoTransparentHide;
  protected
    { Protected declarations }
    function DrawElement(DC: HDC): Boolean; override;
    procedure OnChangeSize( var msg : Tmessage); message WM_SIZE;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
     { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RecteateImage;
    procedure Refresh;
    procedure DoHide;
    procedure DoShow;
    property Buffer: TBitmap read FBuffer;
  published
    { Published declarations }
    property Visible;
    property Active: Boolean read FActive write SetActive;
    property FillPercent: Byte read FFillPercent write SetFillPercent;
    property Color;
    property ParentColor;
    property Align;
    property Anchors;
    property Cursor;
    property OnClick;
    property OnDblClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property SignColor : TColor read FSignColor write SetSignColor;
    property MaxTransparencity : Byte read FMaxTransparencity write FMaxTransparencity;
    property ResourcePNGRCDataImage: string read FResourcePNGRCDataImage write SetResourcePNGRCDataImage;
    property GetBackGround : TGetBackGroundProc read FGetBackGround write SetGetBackGround;
  end;

procedure DrawLoadingSignImage(Left, Top, SizeFrom, SizeTo: Integer; Image32: TBitmap; Color: TColor; var DrawState: Extended; Transparencity: Byte); overload;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TLoadingSign]);
end;

function GetRCDATAResourceStream(ResName: string): TMemoryStream;
var
  MyRes  : Integer;
  MyResP : Pointer;
  MyResS : Integer;
begin
  Result := nil;
  MyRes := FindResource(HInstance, PWideChar(ResName), RT_RCDATA);
  if MyRes <> 0 then begin
    MyResS := SizeOfResource(HInstance,MyRes);
    MyRes := LoadResource(HInstance,MyRes);
    if MyRes <> 0 then begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then begin
        Result := TMemoryStream.Create;
        with Result do begin
          Write(MyResP^, MyResS);
          Seek(0, soFromBeginning);
        end;
        UnLockResource(MyRes);
      end;
      FreeResource(MyRes);
    end
  end;
end;

{$DEFINE ANTIALIAZING}

procedure DrawLoadingSignImage(Left, Top, SizeFrom, SizeTo: Integer; Image32: TBitmap; Color: TColor; var DrawState: Extended; Transparencity: Byte); overload;
var
  P: PARGB32;
  SM, SM1, SD2, SD21, X, Y, I, J, JL: Integer;
  Angle, Distance, T: Extended;
  RB, GB, BB, W, W1, SDY2, SDY21, SDX2, SDX21, A, XR, XG, XB, T1: Byte;
  MaskArray : array[0..255] of byte;
  FrontColor : TColor;
  BackGround : TBitmap;
begin
  InitSumLMatrix;

  DrawState := DrawState + (1 / 30) * 2 * PI;
  if DrawState > 2 * PI then
    DrawState := 0;

  T1 := 255 - Transparencity;
  for I := 0 to 255 do
    MaskArray[I] := Round(255 * Sqrt(I / 255));

  SM := SizeFrom;
  SM1 := Max(0, SM - 1);
  SD2 := SizeTo div 2;
  SD21 := SizeTo div 2 - 1;

  Color := ColorToRGB(Color);
  RB := GetRValue(Color);
  GB := GetGValue(Color);
  BB := GetBValue(Color);

  for I := 0 to SizeTo - 1 do
  begin
    P := Image32.ScanLine[I + Top];
    Y := SD2 - I;
    for J := 0 to SizeTo - 1 do
    begin
      X := SD2 - J;
      Angle := ArcTan2(Y, X);
      Distance := Hypot(X, Y);
      T := (Angle - DrawState) / (2 * PI);

      if Distance < SM1 then
        W := $FF
        {$IFDEF ANTIALIAZING}
      else if Distance < SM then
      begin
        W := Byte(Round(T * 255));
        W := Round(W * (1 - (SM - Distance)) + $FF * (SM - Distance));
        W := MaskArray[W];
      end
        {$ENDIF}
      else if Distance < SD21 then
      begin
        W := Byte(Round(T * 255));
        {$IFDEF ANTIALIAZING}
        if W > 240 then
          W := 240 - Round(240 * ((W - 240) / (255 - 240)) );
        W := MaskArray[W];
      end else if Distance < SD2 then
      begin
        W := Byte(Round(T * 255));
        W := Round(W * (SD2 - Distance) + $FF * (1 - (SD2 - Distance)));
        W := MaskArray[W];
        {$ENDIF}
      end else
        W := $FF;

      W1 := 255 - W;

      JL := J + Left;
      P[JL].L := SumL(W1, P[JL].L);
      P[JL].R := (P[JL].R * W + RB * W1 + 127) div $FF;
      P[JL].G := (P[JL].G * W + GB * W1 + 127) div $FF;
      P[JL].B := (P[JL].B * W + BB * W1 + 127) div $FF;
    end;
  end;

end;

procedure DrawLoadingSignImage(Sender: TControl; Canvas: TCanvas; Image: TBitmap; BackColor: TColor; var DrawState: Extended; FGetBackGround: TGetBackGroundProc; Transparencity: Byte); overload;
var
  B : TBitmap;
  P, PB : PARGB;
  PI32: PARGB32;
  X, Y, I, J: Integer;
  Angle, Distance, T: Extended;
  RB, GB, BB, W, W1, SDY2, SDY21, SDX2, SDX21, A, XR, XG, XB, T1: Byte;
  SM: Byte;
  MaskArray: array [0 .. 255] of Byte;
  FrontColor: TColor;
  BackGround: TBitmap;
begin
  DrawState := DrawState + (1 / 30) * 2 * PI;
  if DrawState > 2 * PI then
    DrawState := 0;

  T1 := 255 - Transparencity;
  for I := 0 to 255 do
    MaskArray[I] := Round(255 * Sqrt(I / 255));

  BackColor := ColorToRGB(BackColor);

  BackGround := TBitmap.Create;
  try
    BackGround.PixelFormat := pf24bit;

    BackGround.Canvas.Brush.Color := BackColor;
    BackGround.Canvas.Pen.Color := BackColor;
    BackGround.SetSize(Image.Width, Image.Height);
    if Assigned(FGetBackGround) then
      FGetBackGround(Sender, Sender.Left, Sender.Top, Image.Width, Image.Height, BackGround)
    else
      BackGround.Canvas.Rectangle(0, 0, Image.Width, Image.Height);

   	BackGround.PixelFormat := pf24bit;

    SDX2 := Image.Width div 2;
    SDX21 := Image.Width div 2 - 1;
    SDY2 := Image.Height div 2;
    SDY21 := Image.Height div 2 - 1;

    B := TBitmap.Create;
    try
      B.PixelFormat := pf24bit;
      B.SetSize(Image.Width, Image.Height);
      for I := 0 to B.Height - 1 do
      begin
        P := B.ScanLine[I];
        PB := BackGround.ScanLine[I];
        PI32 := Image.ScanLine[I];
        Y := SDY2 - I;
        for J := 0 to B.Width - 1 do
        begin
          X := SDX2 - J;
          Angle := ArcTan2 (Y, X);
          Distance := Hypot(X, Y);
          T := (Angle - DrawState) / (2 * PI);

          if Distance < SDX21 then
          begin
            W := Byte(Round(T * 255));
            {$IFDEF ANTIALIAZING}
            if W > 240 then
              W := 240 - Round(240 * ((W - 240) / (255 - 240)) );
            W := MaskArray[W];
          end else if Distance < SDX2 then
          begin
            W := Byte(Round(T * 255));
            W := Round(W * (SDX2 - Distance) + $FF * (1 - (SDX2 - Distance)));
            W := MaskArray[W];
            {$ENDIF}
          end else
            W := MaskArray[$FF];

          RB := PB[J].R;
          GB := PB[J].G;
          BB := PB[J].B;

          A := (PI32[J].R * 77 + PI32[J].G * 151 + PI32[J].B * 28) shr 8;

          W1 := 255 - W;
          XR := (A * W1 + PI32[J].R * W + 127) div $FF;
          XG := (A * W1 + PI32[J].G * W + 127) div $FF;
          XB := (A * W1 + PI32[J].B * W + 127) div $FF;

          W := (PI32[J].L * Transparencity + 127) div $FF;

          W1 := 255 - W;
          P[J].R := (RB * W1 + XR * W + 127) div $FF;
          P[J].G := (GB * W1 + XG * W + 127) div $FF;
          P[J].B := (BB * W1 + XB * W + 127) div $FF;
        end;
      end;

      Canvas.Draw(0, 0, B);
    finally
      F(B);
    end;
  finally
    F(BackGround);
  end;
end;

procedure DrawLoadingSign(Sender: TControl; Canvas: TCanvas; DX, DY: Integer; BackColor, SignColor: TColor; SizeFrom, SizeTo: Integer; var DrawState: Extended; FGetBackGround: TGetBackGroundProc; Transparencity: Byte);
var
  B: TBitmap;
  P, PB: PARGB;
  X, Y, I, J: Integer;
  Angle, Distance, T: Extended;
  RB, GB, BB, W, W1, SD2, SD21, FR, FG, FB: Byte;
  SM1, SM: Byte;
  MaskArray: array [0 .. 255] of Byte;
  FrontColor: TColor;
  BackGround: TBitmap;
begin
  if SizeTo = 0 then
    Exit;

  DrawState := DrawState - (1 / 30) * 2 * PI;
  if DrawState < 0 then
    DrawState := 2 * PI;

  for I := 0 to 255 do
    MaskArray[I] := Round(255 * Sqrt(I / 255));

  SM := SizeFrom;
  SM1 := Max(0, SM - 1);

  FrontColor := ColorToRGB(SignColor);
  FR := GetRValue(FrontColor);
  FG := GetGValue(FrontColor);
  FB := GetBValue(FrontColor);

  BackGround := TBitmap.Create;
  try
    BackGround.Canvas.Brush.Color := BackColor;
    BackGround.Canvas.Pen.Color := BackColor;
    BackGround.PixelFormat := pf24bit;
    BackGround.SetSize(SizeTo, SizeTo);
    if Assigned(FGetBackGround) then
      FGetBackGround(Sender, Sender.Left, Sender.Top, SizeTo, SizeTo, BackGround)
    else
    begin
      if Sender is TBaseWinControl then
        TBaseWinControl(Sender).DrawBackground(BackGround.Canvas)
      else
        BackGround.Canvas.Rectangle(0, 0, SizeTo, SizeTo);
    end;
    BackGround.PixelFormat := pf24bit;

    SD2 := SizeTo div 2;
    SD21 := SizeTo div 2 - 1;

    B := TBitmap.Create;
    try
      B.PixelFormat := pf24bit;
      B.SetSize(SizeTo, SizeTo);
      for I := 0 to B.Height - 1 do
      begin
        P := B.ScanLine[I];
        PB := BackGround.ScanLine[I];
        Y := SD2 - I;
        for J := 0 to B.Width - 1 do
        begin
          X := SD2 - J;
          Angle := 2 * PI - ArcTan2 (Y, X);
          Distance := Hypot(X, Y);
          T := (Angle - DrawState) / (2 * PI);

          if Distance < SM1 then
            W := $FF
            {$IFDEF ANTIALIAZING}
          else if Distance < SM then
          begin
            W := Byte(Round(T * 255));
            W := Round(W * (1 - (SM - Distance)) + $FF * (SM - Distance));
            W := MaskArray[W];
          end
            {$ENDIF}
          else if Distance < SD21 then
          begin
            W := Byte(Round(T * 255));
            {$IFDEF ANTIALIAZING}
            if W > 240 then
              W := 240 - Round(240 * ((W - 240) / (255 - 240)) );
            W := MaskArray[W];
          end else if Distance < SD2 then
          begin
            W := Byte(Round(T * 255));
            W := Round(W * (SD2 - Distance) + $FF * (1 - (SD2 - Distance)));
            W := MaskArray[W];
            {$ENDIF}
          end else
            W := $FF;

          RB := PB[J].R;
          GB := PB[J].G;
          BB := PB[J].B;

          W1 := 255 - W;
          P[J].R := (FR * W1 + RB * W + 127) div $FF;
          P[J].G := (FG * W1 + GB * W + 127) div $FF;
          P[J].B := (FB * W1 + BB * W + 127) div $FF;
        end;
      end;

      Canvas.Draw(DX, DY, B);
    finally
      F(B);
    end;
  finally
    F(BackGround);
  end;
end;

{ TLoadingSign }

procedure TLoadingSign.CMColorChanged(var Message: TMessage);
begin
  RecteateImage;
end;

constructor TLoadingSign.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FResourcePNGRCDataImage := '';

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf24bit;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  ControlStyle := ControlStyle + [csOpaque, csPaintBlackOpaqueOnGlass];

  FVisibleTimer := TTimer.Create(Self);
  FVisibleTimer.Interval := 20;
  FVisibleTimer.Enabled := False;
  FVisibleTimer.OnTimer := OnTimer;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 30;
  FTimer.Enabled := False;
  FTimer.OnTimer := OnTimer;

  FFillPercent := 0;
  FGetBackGround := nil;
  FImage := TBitmap.Create;
  FVisibilityInc := 0;
  FVisibility := 255;
  FMaxTransparencity := 255;
end;

destructor TLoadingSign.Destroy;
begin
  F(FCanvas);
  F(FBuffer);
  F(FTimer);
  F(FImage);
  inherited;
end;

procedure TLoadingSign.DoHide;
begin
  FVisibilityInc := -50;
  FVisibleTimer.Enabled := True;
  OnTimer(FVisibleTimer);
end;

procedure TLoadingSign.DoShow;
begin
  RecteateImage;
  FVisibilityInc := 10;
  FVisibleTimer.Enabled := True;
end;

procedure TLoadingSign.DoTransparentHide;
begin
  FVisibility := 0;
  Refresh;
end;

procedure TLoadingSign.OnChangeSize(var msg: Tmessage);
begin
  Height := Width;
  FBuffer.Height := Height;
  FBuffer.Width := Width;
  Refresh;
end;

procedure TLoadingSign.OnTimer(Sender: TObject);
begin

  if Sender = FVisibleTimer then
  begin
    if (FVisibilityInc > 0) and (FVisibility < FMaxTransparencity) then
      Inc(FVisibility, FVisibilityInc);
    if (FVisibilityInc < 0) and (FVisibility > 0) then
      Inc(FVisibility, FVisibilityInc);

    FVisibility := Max(0, Min(FMaxTransparencity, FVisibility));
    if (FVisibility = 0) or (FVisibility >= FMaxTransparencity) then
    begin
      if (FVisibility = 0) then
        DoTransparentHide;
      FVisibleTimer.Enabled := False;
    end;
  end;

  if Sender = FTimer then
  begin
    if not Visible then
      Exit;
    Refresh;
  end;
end;

function TLoadingSign.DrawElement(DC: HDC): Boolean;
begin
  Result := BitBlt(DC, 0, 0, Buffer.Width, Buffer.Height, Buffer.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TLoadingSign.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TLoadingSign.RecteateImage;
var
  C, SC: TColor;
begin
  if not HandleAllocated then
    Exit;

  if csLoading in ComponentState then
  begin
    if FBuffer <> nil then
      FBuffer.Canvas.Rectangle(0, 0, FBuffer.Width, FBuffer.Height);
    Exit;
  end;

  if IsStyleEnabled then
  begin
    C := StyleServices.GetStyleColor(scPanel);
    SC := StyleServices.GetStyleFontColor(sfPanelTextNormal);
  end else
  begin
    C := Color;
    SC := SignColor;
  end;

  if (FResourcePNGRCDataImage <> '') then
    DrawLoadingSignImage(Self, FBuffer.Canvas, FImage, C, FDrawState, FGetBackGround, FVisibility)
  else
    DrawLoadingSign(Self, FBuffer.Canvas, 0, 0, C, SC, Round((Width div 2) * FFillPercent / 100), Width, FDrawState, FGetBackGround, FVisibility);
end;

procedure TLoadingSign.Refresh;
begin
  RecteateImage;

  if HandleAllocated and not (csReadingState in ControlState) then
    Invalidate;
end;

procedure TLoadingSign.SetActive(const Value: Boolean);
begin
  FActive := Value;
  FTimer.Enabled := Value;
  Refresh;
end;

procedure TLoadingSign.SetFillPercent(const Value: Byte);
begin
  FFillPercent := Min(100, Value);
end;

procedure TLoadingSign.SetGetBackGround(const Value: TGetBackGroundProc);
begin
  FGetBackGround := Value;
end;

procedure TLoadingSign.SetResourcePNGRCDataImage(const Value: string);
var
  MS: TMemoryStream;
  FPngImage: TPngImage;
begin
  FResourcePNGRCDataImage := Value;

  MS := GetRCDATAResourceStream(FResourcePNGRCDataImage);
  try
    if MS = nil then
    begin
      FImage.PixelFormat := pf32Bit;
      FImage.SetSize(Width, Height);
      FImage.Canvas.Pen.Color := Color;
      FImage.Canvas.Brush.Color := Color;
      FImage.Canvas.Rectangle(0, 0, Width, Height);
      Exit;
    end;

    try
      FPngImage := TPngImage.Create;
      try
        MS.Seek(0, soFromBeginning);
        FPngImage.LoadFromStream(MS);
        FImage.PixelFormat := pf32Bit;
        FImage.SetSize(FPngImage.Width, FPngImage.Height);
        FImage.Assign(FPngImage);
        Width := FPngImage.Width;
        Height := FPngImage.Height;
      finally
        F(FPngImage);
      end;
    finally
      F(MS);
    end;
  finally
    Refresh;
  end;

end;

procedure TLoadingSign.SetSignColor(const Value: TColor);
begin
  FSignColor := Value;
  Refresh;
end;

end.
