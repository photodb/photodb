{*******************************************************}
{                                                       }
{       Run-time Library for Borland Delphi 5           }
{       TImButton - Image Button                        }
{                                                       }
{       Copyright (c)  2001-2002 by Veresov Dmitry      }
{                                                       }
{     *****                                             }
{     **   **                                           }
{     **    **       ************                       }
{     **    **     **     **     **                     }
{     **    **     **     **     **                     }
{     **   **      **     **     **                     }
{     *****        ***    ***    ****                   }
{                                                       }
{*******************************************************}

unit Dmitry.Controls.ImButton;

interface

uses 
  Winapi.Windows, 
  Winapi.Messages,
  System.Types,
  System.SysUtils, 
  System.Classes, 
  System.Math, 
  Vcl.Dialogs,
  Vcl.ExtCtrls, 
  Vcl.Graphics, 
  Vcl.Controls,
  Vcl.Forms, 
  Dmitry.Graphics.Types;

type
  TDmImageButtonView = (DmIm_Left, DmIm_Right, DmIm_Home_Standart, DmIm_None, DmIm_Minimize, DmIm_Maximize, DmIm_Normalize, DmIm_Close, DmIm_Help);
  TDmImageState = (ImSt_Normal, ImSt_Enter, ImSt_Click, ImSt_Disabled);
  TDmImageAnimate = set of TDmImageState;

TXFilter = procedure(var Image : TBitmap) of object;

type
  TImButton = class(TWinControl)
  private
    { Private declarations }
    FCanvas: TCanvas;
    Fstate: TDmImageState;
    Fdown: Boolean;
    Fonclick: TNotifyEvent;
    Fimage1: TPicture;
    Fimage2: TPicture;
    Fimage3: TPicture;
    Fimage4: TPicture;
    FTransparent: Boolean;
    FView: TDmImageButtonView;
    FEnabled: Boolean;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FMouseInClientZone: Boolean;
    FShowCaption: Boolean;
    FFontNormal: TFont;
    FFontEnter: TFont;
    FPixelsBetweenPictureAndText: Integer;
    FFadeDelay: Integer;
    Ffadenowpicture: Tbitmap;
    Fpicture: TBitmap;
    FTimer: Ttimer;
    Fstep: Integer;
    Fsteps: Integer;
    Fdefaultcolor: Tcolor;
    Fspicture: Tbitmap;
    Fanimations: TDmImageAnimate;
    Flock: Boolean;
    FAniShow: Boolean;
    Fbackground: TBitmap;
    FaHide: Boolean;
    Fnowshow: Boolean;
    Fb: Tbitmap;
    FOnEndFade: TNotifyEvent;
    FOnEndFadeOnShow: TNotifyEvent;
    FBeginHide: TNotifyEvent;
    FOnBeginShow: TNotifyEvent;
    FMaskImage: TGraphicControl;
    Fautosetimage: Boolean;
    Fusecoolfont: Boolean;
    Fcoolcolor: Tcolor;
    FCoolColorSize: Integer;
    Ffilter: TXFilter;
    FMaskBitmap: TBitmap;
    FVirtualDraw: Boolean;
  procedure CMTextChanged(var message: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var message: TMessage); message CM_FontCHANGED;
    procedure Setimage1(const Value: TPicture);
    procedure Setimage2(const Value: TPicture);
    procedure Setimage3(const Value: TPicture);
    procedure Setimage4(const Value: TPicture);
    procedure SetTransparent(const Value: Boolean);
    procedure Setview(const Value: TDmImageButtonView);
    procedure SetImEnabled(const Value: Boolean);
    procedure SetOnMouseEnter(const Value: TNotifyEvent);
    procedure SetOnMouseleave(const Value: TNotifyEvent);
    procedure SetShowCaption(const Value: Boolean);
    procedure SetFontNormal(const Value: TFont);
    procedure SetFontEnter(const Value: TFont);
    procedure SetPixelsBetweenPictureAndText(const Value: Integer);
    procedure SetFadeDelay(const Value: Integer);
    procedure Fadenow(Sender: Tobject);
    procedure Setsteps(const Value: Integer);
    procedure Setdefaultcolor(const Value: Tcolor);
    procedure Newstatepicture(State: TDmImageState);
    procedure Setanimations(const Value: TDmImageAnimate);
    procedure SetAniShow(const Value: Boolean);
    procedure SetOnEndFade(const Value: TNotifyEvent);
    procedure SetOnEndFadeOnShow(const Value: TNotifyEvent);
    procedure SetBeginHide(const Value: TNotifyEvent);
    procedure SetOnBeginShow(const Value: TNotifyEvent);
    procedure Fontch(Sender: TObject);
    procedure SetMaskImage(const Value: TGraphicControl);
    procedure Setautosetimage(const Value: Boolean);
    procedure Setusecoolfont(const Value: Boolean);
    procedure Setcoolcolor(const Value: Tcolor);
    procedure SetCoolColorSize(const Value: Integer);
    procedure Setfilter(const Value: TXFilter);
    procedure SetMaskBitmap(const Value: TBitmap);
    procedure SetVirtualDraw(const Value: Boolean);
  protected
    { Protected declarations }
    procedure Paint(var Msg: Tmessage); message Wm_paint;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: Tcomponent); override;
    destructor Destroy; override;
    procedure CMMOUSELEAVE(var message: TWMNoParams); message CM_MOUSELEAVE;
    procedure CMMOUSEEnter(var message: TWMNoParams); message CM_MOUSEenter;
    procedure WMSIZE(var Msg: Tmessage); message Wm_size;
  published
    { Published declarations }
    property Hint;
    property ShowHint;
    property Top;
    property Left;
    property Width;
    property Height;
    property ImageNormal: TPicture read Fimage1 write Setimage1;
    property ImageEnter: TPicture read Fimage2 write Setimage2;
    property ImageClick: TPicture read Fimage3 write Setimage3;
    property ImageDisabled: TPicture read Fimage4 write Setimage4;
    property OnClick: TNotifyEvent read Fonclick write Fonclick;
    property Transparent: Boolean read FTransparent write SetTransparent;
    property View: TDmImageButtonView read FView write Setview;
    property Enabled: Boolean read FEnabled write SetImEnabled;
    property Visible;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write SetOnMouseleave;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write SetOnMouseEnter;
    property OnBeginShow: TNotifyEvent read FOnBeginShow write SetOnBeginShow;
    property OnBeginHide: TNotifyEvent read FBeginHide write SetBeginHide;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption;
    property Caption;
    property Color;
    property FontNormal: TFont read FFontNormal write SetFontNormal;
    property FontEnter: TFont read FFontEnter write SetFontEnter;
    property PixelsBetweenPictureAndText
      : Integer read FPixelsBetweenPictureAndText write SetPixelsBetweenPictureAndText;
    property FadeDelay: Integer read FFadeDelay write SetFadeDelay;
    property FadeSteps: Integer read Fsteps write Setsteps;
    procedure SetNewPicture(Image: Tbitmap);
    procedure SetNewPictureWithoutFade(Image: Tbitmap);
    property Defaultcolor: Tcolor read Fdefaultcolor write Setdefaultcolor;
    property Animations: TDmImageAnimate read Fanimations write Setanimations;
    property AnimatedShow: Boolean read FAniShow write SetAniShow;
    procedure Animatedshownow;
    property Filter: TXFilter read Ffilter write Setfilter;
    procedure Animatedhide;
    procedure Show;
    procedure Setallanmations;
    property OnEndFadeOnHide: TNotifyEvent read FOnEndFade write SetOnEndFade;
    property OnEndFadeOnShow: TNotifyEvent read FOnEndFadeOnShow write SetOnEndFadeOnShow;
    property MaskImage: TGraphicControl read FMaskImage write SetMaskImage;
    property Autosetimage: Boolean read Fautosetimage write Setautosetimage;
    property Usecoolfont: Boolean read Fusecoolfont write Setusecoolfont;
    property Coolcolor: Tcolor read Fcoolcolor write Setcoolcolor;
    property CoolColorSize: Integer read FCoolColorSize write SetCoolColorSize;
    property MaskBitmap: TBitmap read FMaskBitmap write SetMaskBitmap;
    procedure Refresh;
    procedure RefreshBackGround(X: Integer = 0; Y: Integer = 0; Bitmap: TBitmap = nil);
    property VirtualDraw: Boolean read FVirtualDraw write SetVirtualDraw;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [Timbutton]);
end;

{ Timbutton }

{$R CaptionButtons.res}

procedure CoolDrawText(Bitmap: Tbitmap; X, Y: Integer; Text: string; Coolcount: Integer; Coolcolor: Tcolor);
var
  Drawrect: Trect;
  C: Integer;
  Tempb, Temp: Tbitmap;
  I, J, K: Integer;
  P, P1, Pv, Pn, Pc: PARGB;
begin
  Tempb := Tbitmap.Create;
  Tempb.PixelFormat := Pf24bit;
  Tempb.Canvas.Font.Assign(Bitmap.Canvas.Font);
  Tempb.Canvas.Brush.Color := $FFFFFF;
  Tempb.Width := Tempb.Canvas.TextWidth(Text) + 2 * Coolcount;
  Tempb.Height := Tempb.Canvas.Textheight(Text) + 2 * Coolcount;
  Tempb.Canvas.Brush.Style := BsClear;
  Tempb.Canvas.Font.Color := $0;
  DrawRect := Rect(Point(Coolcount, 0), Point(Tempb.Width + Coolcount, Tempb.Height + Coolcount));
  DrawText(Tempb.Canvas.Handle, PChar(Text), Length(Text), DrawRect, DT_NOCLIP);
  Temp := Tbitmap.Create;
  Temp.PixelFormat := pf24bit;
  Temp.Canvas.Brush.Color := $0;
  Temp.Width := Tempb.Canvas.TextWidth(Text) + Coolcount;
  Temp.Height := Tempb.Canvas.Textheight(Text) + Coolcount;
  Tempb.Canvas.Font.Assign(Bitmap.Canvas.Font);
  for I := 0 to Temp.Height - 1 do
  begin
    P1 := Temp.ScanLine[I];
    P := Tempb.ScanLine[I];
    for J := 0 to Temp.Width - 1 do
    begin
      if P[J].R <> $FF then
      begin
        P1[J].R := $FF;
        P1[J].G := $FF;
        P1[J].B := $FF;
      end;
    end;
  end;
  Tempb.Canvas.Brush.Color := $0;
  Tempb.Canvas.Pen.Color := $0;
  Tempb.Canvas.Rectangle(0, 0, Tempb.Width, Tempb.Height);
  for K := 1 to Coolcount do
  begin
    for I := 1 to Temp.Height - 2 do
    begin
      P := Tempb.ScanLine[I];
      Pv := Temp.ScanLine[I - 1];
      Pc := Temp.ScanLine[I];
      Pn := Temp.ScanLine[I + 1];
      for J := 1 to Temp.Width - 2 do
      begin
        C := 9;
        if (Pv[J - 1].R <> 0) then
          Dec(C);
        if (Pv[J + 1].R <> 0) then
          Dec(C);
        if (Pn[J - 1].R <> 0) then
          Dec(C);
        if (Pn[J + 1].R <> 0) then
          Dec(C);
        if (Pc[J - 1].R <> 0) then
          Dec(C);
        if (Pc[J + 1].R <> 0) then
          Dec(C);
        if (Pn[J].R <> 0) then
          Dec(C);
        if (Pv[J].R <> 0) then
          Dec(C);
        if C <> 9 then
        begin
          P[J].R := Min($FF, P[J].R + (Pv[J - 1].R + Pv[J + 1].R + Pn[J - 1].R + Pn[J + 1].R + Pc[J - 1].R + Pc[J + 1]
                .R + Pn[J].R + Pv[J].R) div (C + 1));
          P[J].G := Min($FF, P[J].G + (Pv[J - 1].G + Pv[J + 1].G + Pn[J - 1].G + Pn[J + 1].G + Pc[J - 1].G + Pc[J + 1]
                .G + Pn[J].G + Pv[J].G) div (C + 1));
          P[J].B := Min($FF, P[J].B + (Pv[J - 1].B + Pv[J + 1].B + Pn[J - 1].B + Pn[J + 1].B + Pc[J - 1].B + Pc[J + 1]
                .B + Pn[J].B + Pv[J].B) div (C + 1));
        end;
      end;
    end;
    Temp.Assign(Tempb);
  end;
  Bitmap.PixelFormat := Pf24bit;
  if Bitmap.Width = 0 then
    Exit;
  for I := Max(0, Y) to Min(Tempb.Height - 1 + Y, Bitmap.Height - 1) do
  begin
    P := Bitmap.ScanLine[I];
    P1 := Tempb.ScanLine[I - Y];
    for J := Max(0, X) to Min(Tempb.Width + X - 1, Bitmap.Width - 1) do
    begin
      P[J].R := Min(Round(P[J].R * (1 - P1[J - X].R / 255)) + Round(Getrvalue(Coolcolor) * P1[J - X].R / 255), 255);
      P[J].G := Min(Round(P[J].G * (1 - P1[J - X].G / 255)) + Round(Getgvalue(Coolcolor) * P1[J - X].G / 255), 255);
      P[J].B := Min(Round(P[J].B * (1 - P1[J - X].B / 255)) + Round(Getbvalue(Coolcolor) * P1[J - X].B / 255), 255);
    end;
  end;
  DrawRect := Rect(Point(X + Coolcount, Y), Point(X + Temp.Width + Coolcount, Temp.Height + Y + Coolcount));
  Bitmap.Canvas.Brush.Style := BsClear;
  DrawText(Bitmap.Canvas.Handle, PChar(Text), Length(Text), DrawRect, DT_NOCLIP);
  Temp.Free;
  Tempb.Free;
end;

procedure Copyrectfromimage(S, D: TBitmap; Top, Left, Width, Height: Integer);
var
  I, J: Integer;
  P1, P2: Pargb;
  H, W: Integer;
begin
  D.Width := Width;
  D.Height := Height;
  D.PixelFormat := Pf24bit;
  if S = nil then
    Exit;
  if S.Width = 0 then
    Exit;
  if S.Height = 0 then
    Exit;
  if Left + Width > S.Width then
    Exit;
  if Top + Height > S.Height then
    Exit;
  S.PixelFormat := Pf24bit;
  H := Min(Top + Height, S.Height);
  W := Min(Left + Width, S.Width);
  for I := Top to H - 1 do
  begin
    P1 := S.ScanLine[I];
    P2 := D.ScanLine[I - Top];
    for J := Left to W - 1 do
      P2[J - Left] := P1[J];
  end;
end;

procedure Timbutton.CMMOUSEEnter(var message: TWMNoParams);
begin
  FMouseInClientZone := True;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
  FCanvas.Font.Assign(FFontEnter);
  if FEnabled then
  begin
    if Fdown then
      Fstate := ImSt_Click
    else
      Fstate := ImSt_Enter;
    Newstatepicture(Fstate);
  end;
end;

procedure Timbutton.CMMOUSELEAVE(var message: TWMNoParams);
begin
  FMouseInClientZone := False;
  FCanvas.Font.Assign(FFontNormal);
  if FEnabled then
  begin
    if Fstate = ImSt_click then
      Fdown := True;
    Fstate := ImSt_normal;
    Newstatepicture(Fstate);
  end;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

constructor Timbutton.Create(AOwner: Tcomponent);
begin
  inherited;
  Fcoolcolor := $0;
  VirtualDraw := False;
  FCoolColorSize := 3;
  Fusecoolfont := False;
  Fautosetimage := True;
  Fnowshow := False;
  Fahide := False;
  FMaskBitmap := nil;
  Flock := True;
  Fdefaultcolor := Clbtnface;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  Fbackground := TBitmap.Create;
  Fbackground.Pixelformat := Pf24bit;
  if FMaskBitmap <> nil then
  begin
    Copyrectfromimage(FMaskBitmap, Fbackground,
      { (FMaskImage as timage).ScreenToClient(ClientToScreen(Point(top, left))).x } Top,
      { ScreenToClient(ClientToScreen(Point(top, left))).y } Left, Width, Height);
  end
  else
  begin
    if AOwner is Timage then
    begin
      FMaskImage := AOwner as Timage;
    end;
    if FMaskImage is Timage then
      if (FMaskImage as Timage).Picture.Bitmap <> nil then
        Copyrectfromimage((FMaskImage as Timage).Picture.Bitmap, Fbackground,
          { (FMaskImage as timage).ScreenToClient(ClientToScreen(Point(top, left))).x } Top,
          { ScreenToClient(ClientToScreen(Point(top, left))).y } Left, Width, Height);
  end;
  Fstep := 0;
  FTimer := Ttimer.Create(Self);
  Ftimer.Enabled := False;
  Ftimer.Ontimer := Fadenow;
  Ftimer.Interval := 55;
  Ffadedelay := 10;
  Fsteps := 20;
  FMouseInClientZone := False;
  FPixelsBetweenPictureAndText := 10;
  Fimage1 := TPicture.Create;
  Fimage2 := TPicture.Create;
  Fimage3 := TPicture.Create;
  Fimage4 := TPicture.Create;
  Fb := Tbitmap.Create;
  Fb.Pixelformat := Pf24bit;
  FPicture := TBitmap.Create;
  FPicture.Pixelformat := pf24bit;
  FSPicture := TBitmap.Create;
  FSPicture.Pixelformat := pf24bit;
  Ffadenowpicture := Tbitmap.Create;
  Ffadenowpicture.Pixelformat := pf24bit;
  FView := DmIm_Right;
  Ffadenowpicture.Handle := Loadbitmap(Hinstance, 'RIGHT_NORMAL');
  Fpicture.Handle := Loadbitmap(Hinstance, 'RIGHT_NORMAL');
  Fimage1.Bitmap.Handle := Loadbitmap(Hinstance, 'RIGHT_NORMAL');
  Fimage2.Bitmap.Handle := Loadbitmap(Hinstance, 'RIGHT_ENTER');
  Fimage3.Bitmap.Handle := Loadbitmap(Hinstance, 'RIGHT_CLICK');
  Fimage4.Bitmap.Handle := Loadbitmap(Hinstance, 'RIGHT_DISABLED');
  Fstate := ImSt_normal;
  FCanvas.Brush.Style := BsClear;
  FFontNormal := TFont.Create;
  FFontEnter := TFont.Create;
  FFontNormal.OnChange := Fontch;
  FFontEnter.OnChange := Fontch;
  FShowCaption := False;
  Height := Fimage1.Graphic.Height;
  FEnabled := True;
  Flock := False;
  Fanimations := [ImSt_Normal] + [ImSt_Enter] + [ImSt_Click] + [ImSt_Disabled];
end;

destructor Timbutton.Destroy;
begin
  inherited;
  FImage1.Free;
  FImage2.Free;
  FImage3.Free;
  FImage4.Free;
  FCanvas.Free;
  Fb.Free;
  Fbackground.Free;
  FPicture.Free;
  FSPicture.Free;
  Ffadenowpicture.Free;
  FFontNormal.Free;
  FFontEnter.Free;
end;

procedure Timbutton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);
  if FEnabled then
  begin
    if Button = MbLeft then
    begin
      Fstate := ImSt_click;
      Newstatepicture(Fstate);
    end;
  end;
end;

procedure Timbutton.Mouseup(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Click: Boolean;
begin
  if Assigned(Onmouseup) then
    Onmouseup(Self, Button, Shift, X, Y);
  if FEnabled then
  begin
    if Button = Mbleft then
    begin
      Click := False;
      if CsCaptureMouse in ControlStyle then
        MouseCapture := False;
      if Fstate = ImSt_click then
        Click := True
      else
        Fstate := ImSt_normal;
      Fdown := False;
      if Fstate = ImSt_normal then
        Click := False;
      if Click then
      begin
        Fstate := ImSt_enter;
        if Assigned(FOnclick) and not(SsCtrl in Shift) then
          FOnclick(Owner);
      end
      else
        Fmouseinclientzone := False;
    end;
    Newstatepicture(Fstate);
  end;
end;

procedure Timbutton.Paint;
begin
  inherited;
  if not FVirtualDraw then
    Fcanvas.Draw(0, 0, Fspicture);
end;

procedure Timbutton.SetImEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if not FEnabled then
      FState := ImSt_disabled
    else
      FState := ImSt_normal;
    Newstatepicture(Fstate);
  end;
end;

procedure Timbutton.Setimage1(const Value: TPicture);
begin
  Fimage1.Assign(Value);
  if FMouseInClientZone then
    Fb.Canvas.Font.Assign(FFontEnter)
  else
    Fb.Canvas.Font.Assign(FFontNormal);

  if ShowCaption then
    Width := FImage1.Graphic.Width + Fb.Canvas.TextWidth(Caption) + FPixelsBetweenPictureAndText;
  Height := Fimage1.Height;
  View := DmIm_None;
  Newstatepicture(Fstate);
end;

procedure Timbutton.Setimage2(const Value: TPicture);
begin
  Fimage2.Assign(Value);
  View := DmIm_None;
end;

procedure Timbutton.Setimage3(const Value: TPicture);
begin
  Fimage3.Assign(Value);
  View := DmIm_None;
end;

procedure Timbutton.SetTransparent(const Value: Boolean);
begin
  FTransparent := Value;
  FImage1.Graphic.Transparent := Value;
  FImage2.Graphic.Transparent := Value;
  FImage3.Graphic.Transparent := Value;
  FImage4.Graphic.Transparent := Value;
  Newstatepicture(Fstate);
end;

procedure Timbutton.Setview(const Value: TDmImageButtonView);
var
  S: string;
begin
  begin
    case Value of
      DmIm_Home_Standart:
        S := 'NONE_';
      DmIm_Minimize:
        S := 'MINIMIZE_';
      DmIm_Maximize:
        S := 'MAXIMIZE_';
      DmIm_Normalize:
        S := 'NORMALIZE_';
      DmIm_Close:
        S := 'CLOSE_';
      DmIm_Help:
        S := 'HELP_';
      DmIm_Right:
        S := 'RIGHT_';
      DmIm_Left:
        S := 'LEFT_';
    end;
    if S <> '' then
    begin
      Fimage1.Bitmap.Handle := LoadBitmap(HInstance, PChar(S + 'NORMAL'));
      Fimage2.Bitmap.Handle := LoadBitmap(HInstance, PChar(S + 'ENTER'));
      Fimage3.Bitmap.Handle := LoadBitmap(HInstance, PChar(S + 'CLICK'));
      Fimage4.Bitmap.Handle := LoadBitmap(HInstance, PChar(S + 'DISABLED'));
      if FMouseInClientZone then
        Fb.Canvas.Font.Assign(FFontEnter)
      else
        Fb.Canvas.Font.Assign(FFontNormal);

      if ShowCaption then
        Width := FImage1.Graphic.Width + Fb.Canvas.TextWidth(Caption) + FPixelsBetweenPictureAndText
      else
        Width := FImage1.Graphic.Width;
      Height := Fimage1.Graphic.Height;
    end;
    FView := Value;
    Newstatepicture(Fstate);
  end;
end;

procedure Timbutton.WMSIZE(var Msg: Tmessage);
begin
  if FMouseInClientZone then
    Fb.Canvas.Font.Assign(FFontEnter)
  else
    Fb.Canvas.Font.Assign(FFontNormal);

  if ShowCaption then
    Width := FImage1.Graphic.Width + Fb.Canvas.TextWidth(Caption) + FPixelsBetweenPictureAndText
  else
    Width := FImage1.Graphic.Width;
  Height := Fimage1.Graphic.Height;
end;

procedure Timbutton.Setimage4(const Value: TPicture);
begin
  Fimage4.Assign(Value);
  View := DmIm_None;
  Newstatepicture(Fstate);
end;

procedure TImButton.SetOnMouseEnter(const Value: TNotifyEvent);
begin
  FOnMouseEnter := Value;
end;

procedure TImButton.SetOnMouseleave(const Value: TNotifyEvent);
begin
  FOnMouseLeave := Value;
end;

procedure TImButton.SetShowCaption(const Value: Boolean);
begin
  FShowCaption := Value;
  if FMouseInClientZone then
    Fb.Canvas.Font.Assign(FFontEnter)
  else
    Fb.Canvas.Font.Assign(FFontNormal);
  if ShowCaption then
    Width := FImage1.Graphic.Width + Fb.Canvas.TextWidth(Caption) + FPixelsBetweenPictureAndText
  else
    Width := FImage1.Graphic.Width;
  Newstatepicture(Fstate);
end;

procedure TImButton.CMTextChanged(var message: TMessage);
var
  W0: Integer;
begin
  if Parent <> nil then
    if FMouseInClientZone then
      Fb.Canvas.Font.Assign(FFontEnter)
    else
      Fb.Canvas.Font.Assign(FFontNormal);
  if FShowCaption then
  begin
    W0 := FImage1.Graphic.Width + Fb.Canvas.TextWidth(Caption) + FPixelsBetweenPictureAndText;
    if W0 > Width then
    begin

      if FMaskBitmap <> nil then
      begin
        Copyrectfromimage(FMaskBitmap, Fbackground,
          { (FMaskImage as timage).ScreenToClient(ClientToScreen(Point(top, left))).x } Top,
          { ScreenToClient(ClientToScreen(Point(top, left))).y } Left, Width, Height);
      end
      else
      begin
        if FMaskImage is Timage then
          if (FMaskImage as Timage).Picture.Bitmap <> nil then
            Copyrectfromimage((FMaskImage as Timage).Picture.Bitmap, Fbackground,
              { (FMaskImage as timage).ScreenToClient(ClientToScreen(Point(top, left))).x } Top,
              { ScreenToClient(ClientToScreen(Point(top, left))).y } Left, Width, Height);
      end;
    end;
    Width := W0;
  end
  else
    Width := FImage1.Graphic.Width;
  Newstatepicture(Fstate);
end;

procedure TImButton.SetFontNormal(const Value: TFont);
var
  Msg: Tmessage;
begin
  FFontNormal.Assign(Value);
  if FMouseInClientZone then
    Fb.Canvas.Font.Assign(FFontEnter)
  else
    Fb.Canvas.Font.Assign(FFontNormal);
  if ShowCaption then
    Width := FImage1.Graphic.Width + Fb.Canvas.TextWidth(Caption) + FPixelsBetweenPictureAndText
  else
    Width := FImage1.Graphic.Width;
  Paint(Msg);
end;

procedure TImButton.SetFontEnter(const Value: TFont);
var
  Msg: Tmessage;
begin
  FFontEnter.Assign(Value);
  if FMouseInClientZone then
    Fb.Canvas.Font.Assign(FFontEnter)
  else
    Fb.Canvas.Font.Assign(FFontNormal);
  if ShowCaption then
    Width := FImage1.Graphic.Width + Fb.Canvas.TextWidth(Caption) + FPixelsBetweenPictureAndText
  else
    Width := FImage1.Graphic.Width;
  Paint(Msg);
end;

procedure TImButton.SetPixelsBetweenPictureAndText(const Value: Integer);
begin
  FPixelsBetweenPictureAndText := Value;
  if (FPixelsBetweenPictureAndText < 0) or (FPixelsBetweenPictureAndText > 99) then
    FPixelsBetweenPictureAndText := 3;
  Newstatepicture(Fstate);
end;

procedure TImButton.CMFontChanged(var message: TMessage);
begin
  Newstatepicture(Fstate);
end;

procedure TImButton.SetNewPicture(Image: Tbitmap);
begin
  if Image = nil then
    Exit
  else
  begin
    FStep := 1;
    FsPicture.Canvas.Brush.Color := Fdefaultcolor;
    FPicture.Canvas.Brush.Color := Fdefaultcolor;
    FPicture.Assign(FsPicture);
    FfadenowPicture.Assign(Image);
    if Assigned(Ffilter) then
      Ffilter(FfadenowPicture);
    FTimer.Enabled := True;
    FsPicture.Width := FfadenowPicture.Width;
    FsPicture.Height := FfadenowPicture.Height;
    FPicture.Width := FfadenowPicture.Width;
    FPicture.Height := FfadenowPicture.Height;
  end;
end;

procedure TImButton.SetNewPictureWithoutFade(Image: Tbitmap);
begin
  Ftimer.Enabled := False;
  Fspicture.Assign(Image);
  if Assigned(Ffilter) then
    Ffilter(Fspicture);
  if not Flock and (Parent <> nil) then
    if not FVirtualDraw then
      Fcanvas.Draw(0, 0, Image);
end;

procedure TImButton.SetFadeDelay(const Value: Integer);
begin
  FFadeDelay := Value;
  Ftimer.Interval := Value;
end;

procedure TImButton.Fadenow(Sender: Tobject);
var
  I, J: Integer;
  P1, P2, P3: Pargb;
begin
  Inc(Fstep);
  for I := 0 to Ffadenowpicture.Height - 1 do
  begin
    P2 := FfadenowPicture.Scanline[I];
    P1 := FPicture.ScanLine[I];
    P3 := Fspicture.ScanLine[I];
    for J := 0 to Ffadenowpicture.Width - 1 do
    begin
      P3[J].R := P1[J].R - Round((P1[J].R - P2[J].R) * FStep / FSteps);
      P3[J].G := P1[J].G - Round((P1[J].G - P2[J].G) * FStep / FSteps);
      P3[J].B := P1[J].B - Round((P1[J].B - P2[J].B) * FStep / FSteps);
    end;
  end;
  if Fcanvas <> nil then
    with Fcanvas do
      Draw(0, 0, Fspicture);
  if FStep >= FSteps then
  begin
    FTimer.Enabled := False;
    FStep := 0;
    FPicture.Assign(FfadenowPicture);
    if Fnowshow then
      if Assigned(FOnEndFadeOnShow) then
        FOnEndFadeOnShow(Self);
    Fnowshow := False;
    if Fahide then
    begin

      LockWindowUpdate(Parent.Handle);
      Hide;
      LockWindowUpdate(0);
      if Assigned(FOnEndFade) then
        FOnEndFade(Self);
    end;
  end;
end;

procedure TImButton.Setsteps(const Value: Integer);
begin
  Fsteps := Value;
end;

procedure TImButton.Setdefaultcolor(const Value: Tcolor);
begin
  Fdefaultcolor := Value;
  Newstatepicture(Fstate);
end;

procedure TImButton.Newstatepicture(State: TDmImageState);
var
  Drawrect: TRect;
begin
  if Fahide then
    Exit;
  Fb.Canvas.Brush.Color := Fdefaultcolor;
  Fb.Canvas.Pen.Color := Fdefaultcolor;
  Fb.Height := Self.Height;
  if FMouseInClientZone then
    Fb.Canvas.Font.Assign(FFontEnter)
  else
    Fb.Canvas.Font.Assign(FFontNormal);
  Fb.Width := Self.Width;
  Drawrect.Left := Fimage1.Width + FPixelsBetweenPictureAndText;
  Drawrect.Top := Height div 2 - Fb.Canvas.TextHeight(Caption) div 2;
  if Drawrect.Top < 0 then
    Drawrect.Top := 0;
  Drawrect.Bottom := Fb.Canvas.TextWidth(Caption);
  Drawrect.Right := Fb.Canvas.TextHeight(Caption);

  if FMaskBitmap <> nil then
  begin
    Copyrectfromimage(FMaskBitmap, Fbackground, Top, Left, Width, Height);
  end else
  begin
    if FMaskImage is Timage then
    begin
      if (FMaskImage as Timage).Picture.Bitmap <> nil then
      begin
        Copyrectfromimage((FMaskImage as Timage).Picture.Bitmap, Fbackground,
          Top,  Left, Width, Height);
      end else
      begin
        Fbackground.Canvas.Brush.Color := Color;
        Fbackground.Canvas.Pen.Color := Color;
        Fbackground.Canvas.Rectangle(0, 0, Fbackground.Width, Fbackground.Height);
      end;
    end else
    begin
      Fbackground.Canvas.Brush.Color := Color;
      Fbackground.Canvas.Pen.Color := Color;
      Fbackground.Canvas.Rectangle(0, 0, Fbackground.Width, Fbackground.Height);
    end;
  end;
  if Fbackground.Width = 0 then
  begin
    Fb.Canvas.Brush.Color := Color;
    Fb.Canvas.Pen.Color := Color;
    Fb.Canvas.Rectangle(0, 0, Fb.Width, Fb.Height);
  end else
    Fb.Canvas.Draw(0, 0, Fbackground);
  Fb.Canvas.Brush.Style := BsClear;
  if not Fusecoolfont then
    DrawText(Fb.Canvas.Handle, PChar(Caption), Length(Caption), DrawRect, DT_NOCLIP)
  else if Fshowcaption then
    Cooldrawtext(Fb, Drawrect.Left - 2 * CoolColorSize, Drawrect.Top, Caption, 3, Coolcolor);
  if State = ImSt_normal then
    Fb.Canvas.Draw(0, 0, Fimage1.Bitmap);
  if State = ImSt_enter then
    Fb.Canvas.Draw(0, 0, Fimage2.Bitmap);
  if State = ImSt_click then
    Fb.Canvas.Draw(0, 0, Fimage3.Bitmap);
  if State = ImSt_disabled then
    Fb.Canvas.Draw(0, 0, Fimage4.Bitmap);
  if State in Fanimations then
    SetNewPicture(Fb)
  else
    SetNewPicturewithoutfade(Fb);
end;

procedure TImButton.Setanimations(const Value: TDmImageAnimate);
begin
  Fanimations := Value;
end;

procedure TImButton.SetAniShow(const Value: Boolean);
begin
  FAniShow := Value;
end;

procedure TImButton.Animatedshownow;
var
  ParentDC: HDC;
begin
  if Assigned(Onbeginshow) then
    Onbeginshow(Self);
  Fahide := False;
  Fbackground.Width := Width;
  Fbackground.Height := Height;
  Fbackground.PixelFormat := Pf24bit;
  if FMaskBitmap <> nil then
  begin
    Copyrectfromimage(FMaskBitmap, Fbackground, Top, Left, Width, Height);
  end
  else
  begin
    if (FMaskImage as Timage).Picture.Bitmap <> nil then
    begin
      Copyrectfromimage((FMaskImage as Timage).Picture.Bitmap, Fbackground,
        Top, Left, Width, Height)
    end else
    begin
      ParentDC := GetDC(Parent.Handle);
      BitBlt(Fbackground.Canvas.Handle, 0, 0, Width, Height, ParentDC, Left, Top, SRCCOPY);
      ReleaseDC(0, ParentDC);
    end;
  end;

  Fspicture.Assign(Fbackground);
  Newstatepicture(Fstate);
  Fcanvas.Draw(0, 0, Fbackground);
  LockWindowUpdate(Parent.Handle);
  Show;
  LockWindowUpdate(0);
end;

procedure TImButton.Animatedhide;
begin
  if Assigned(Onbeginhide) then
    Onbeginhide(Self);
  Fahide := True;
  Setnewpicture(Fbackground);
end;

procedure TImButton.Show;
begin
  if Assigned(Onbeginshow) then
    Onbeginshow(Self);
  Fnowshow := True;
  Fahide := False;
  LockWindowUpdate(Parent.Handle);
  Visible := True;
  LockWindowUpdate(0);
end;

procedure TImButton.Setallanmations;
begin
  Fanimations := [ImSt_Normal] + [ImSt_Enter] + [ImSt_Click] + [ImSt_Disabled];
end;

procedure TImButton.SetOnEndFade(const Value: TNotifyEvent);
begin
  FOnEndFade := Value;
end;

procedure TImButton.SetOnEndFadeOnShow(const Value: TNotifyEvent);
begin
  FOnEndFadeOnShow := Value;
end;

procedure TImButton.SetBeginHide(const Value: TNotifyEvent);
begin
  FBeginHide := Value;
end;

procedure TImButton.SetOnBeginShow(const Value: TNotifyEvent);
begin
  FOnBeginShow := Value;
end;

procedure TImButton.Fontch(Sender: TObject);
var
  M: TMessage;
begin
  CMTextChanged(M);
end;

procedure TImButton.SetMaskImage(const Value: TGraphicControl);
begin
  FMaskImage := Value;
  Newstatepicture(Fstate);
end;

procedure TImButton.Setautosetimage(const Value: Boolean);
begin
  Fautosetimage := Value;
end;

procedure TImButton.Setusecoolfont(const Value: Boolean);
begin
  Fusecoolfont := Value;
end;

procedure TImButton.Setcoolcolor(const Value: Tcolor);
begin
  Fcoolcolor := Value;
end;

procedure TImButton.SetCoolColorSize(const Value: Integer);
begin
  FCoolColorSize := Value;
end;

procedure TImButton.Refresh;
begin
  Newstatepicture(Fstate);
end;

procedure TImButton.Setfilter(const Value: TXFilter);
begin
  Ffilter := Value;
end;

procedure TImButton.SetMaskBitmap(const Value: TBitmap);
begin
  FMaskBitmap := Value;
end;

procedure TImButton.RefreshBackGround(X: Integer = 0; Y: Integer = 0; Bitmap: TBitmap = nil);
var
  Drawrect: TRect;
begin
  if Fahide then
    Exit;
  Fb.Canvas.Brush.Color := Fdefaultcolor;
  Fb.Canvas.Pen.Color := Fdefaultcolor;
  Fb.Height := Self.Height;
  if FMouseInClientZone then
    Fb.Canvas.Font.Assign(FFontEnter)
  else
    Fb.Canvas.Font.Assign(FFontNormal);
  Fb.Width := Self.Width;
  Drawrect.Left := Fimage1.Width + FPixelsBetweenPictureAndText;
  Drawrect.Top := Height div 2 - Fb.Canvas.TextHeight(Caption) div 2;
  if Drawrect.Top < 0 then
    Drawrect.Top := 0;
  Drawrect.Bottom := Fb.Canvas.TextWidth(Caption);
  Drawrect.Right := Fb.Canvas.TextHeight(Caption);

  if FMaskBitmap <> nil then
  begin
    Copyrectfromimage(FMaskBitmap, Fbackground, Top, Left, Width, Height);
  end  else
  begin
    if FMaskImage is Timage then
      if (FMaskImage as Timage).Picture.Bitmap <> nil then
        Copyrectfromimage((FMaskImage as Timage).Picture.Bitmap, Fbackground,
          Top, Left, Width, Height);
  end;

  Fb.Canvas.Draw(0, 0, Fbackground);
  Fb.Canvas.Brush.Style := BsClear;
  if not Fusecoolfont then
    DrawText(Fb.Canvas.Handle, PChar(Caption), Length(Caption), DrawRect, DT_NOCLIP)
  else if Fshowcaption then
    Cooldrawtext(Fb, Drawrect.Left - 2 * CoolColorSize, Drawrect.Top, Caption, 3, Coolcolor);

  if Fstate = ImSt_normal then
    Fb.Canvas.Draw(0, 0, Fimage1.Bitmap);
  if Fstate = ImSt_enter then
    Fb.Canvas.Draw(0, 0, Fimage2.Bitmap);
  if Fstate = ImSt_click then
    Fb.Canvas.Draw(0, 0, Fimage3.Bitmap);
  if Fstate = ImSt_disabled then
    Fb.Canvas.Draw(0, 0, Fimage4.Bitmap);
  if Assigned(Ffilter) then
    Ffilter(Fb);
  if VirtualDraw then
    Bitmap.Canvas.Draw(X, Y, Fb)
  else
    Fcanvas.Draw(0, 0, Fb);

  Ftimer.Enabled := False;
  Fspicture.Assign(Fb);

end;

procedure TImButton.SetVirtualDraw(const Value: Boolean);
begin
  FVirtualDraw := Value;
end;

end.
