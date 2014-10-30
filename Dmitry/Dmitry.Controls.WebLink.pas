unit Dmitry.Controls.WebLink;

interface

uses
  Generics.Collections,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.ImgList,
  Dmitry.Memory,
  Dmitry.Utils.System,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.Controls.Base,
  Dmitry.PathProviders;

type
  TGetBackGroundProc = procedure(Sender: TObject; X, Y, W, H: Integer; Bitmap: TBitmap) of object;

type
  TWebLink = class(TBaseWinControl)
  private
    { Private declarations }
    FCanvas: TCanvas;
    FShowenBitmap: TBitmap;
    FOnClick: TNotifyEvent;
    Loading: Boolean;
    FImageIndex: Integer;
    FImageList: TCustomImageList;
    FIcon: TIcon;
    FIconStream: TMemoryStream;
    FIconWidth: Integer;
    FIconHeight: Integer;
    FImage: TLayeredBitmap;
    FEnterColor: TColor;
    FEnterBould: Boolean;
    FUseEnterColor: Boolean;
    FTopIconIncrement: Integer;
    FGetBackGround: TGetBackGroundProc;
    FImageCanRegenerate: Boolean;
    FIconChanged: Boolean;
    FUseSpecIconSize: Boolean;
    FIsHover: Boolean;
    FHightliteImage: Boolean;
    FFontStyles: TFontStyles;
    FFontName: string;
    FFontSize: Integer;
    FFontColor: TColor;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FStretchImage: Boolean;
    FCanClick: Boolean;
    FIsGDIFree: Boolean;
    FPainted: Boolean;
    FUseEndEllipsis: Boolean;
    procedure SetOnClick(const Value: TNotifyEvent);
    procedure SetImageIndex(const Value: Integer);
    procedure SetImageList(const Value: TCustomImageList);
    procedure SetIcon(const Value: TIcon);
    procedure SetIconWidth(const Value: Integer);
    procedure SetIconHeight(const Value: Integer);
    procedure SetEnterColor(const Value: TColor);
    procedure SetEnterBould(const Value: Boolean);
    procedure SetUseEnterColor(const Value: Boolean);
    procedure SetTopIconIncrement(const Value: integer);
    procedure SetGetBackGround(const Value: TGetBackGroundProc);
    procedure SetHightliteImage(const Value: Boolean);
    procedure SetStretchImage(const Value: Boolean);
    function GetIcon: TIcon;
    procedure SetUseEndEllipsis(const Value: Boolean);
  protected
    { Protected declarations }
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMSize(var Message: TSize); message WM_SIZE;
    procedure WMMouseDown(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure CMMouseLeave(var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TWMNoParams); message CM_MOUSEENTER;
    procedure CMFontChanged(var Message: TWMNoParams); message CM_FONTCHANGED;
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CNCtlColorStatic(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    procedure IconChanged(Sender: TObject);
    procedure Loaded; override;
    procedure FreeGDI;
    procedure LoadGDI;
    procedure SaveIconToStream;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromHIcon(Icon: HIcon);
    procedure LoadFromResource(ResourceName: string);
    procedure RefreshBuffer(Force: Boolean = False);
    procedure Refresh;
    procedure SetDefault;
    procedure LoadIconSize(Icon: TIcon; Width, Height: Integer);
    procedure LoadBitmap(Bitmap: TBitmap);
    procedure LoadFromPathImage(Image: TPathImage);
    procedure CreateImageFromIcon;
    procedure LoadImage;
    procedure CalculateLinkSize;
    procedure StartChanges;
    property Canvas: TCanvas read FCanvas;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property Enabled;
    property OnContextPopup;
    property Font;
    property PopupMenu;
    property Color;
    property ParentColor;
    property Text;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property Visible;
    property OnMouseDown;
    property OnMouseUp;
    property OnClick: TNotifyEvent read FOnClick write SetOnClick;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;

    property ImageList: TCustomImageList read FImageList write SetImageList;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property IconWidth: Integer read FIconWidth write SetIconWidth default 16;
    property IconHeight: Integer read FIconHeight write SetIconHeight default 16;
    property UseEnterColor: Boolean read FUseEnterColor write SetUseEnterColor;
    property EnterColor: TColor read FEnterColor write SetEnterColor;
    property EnterBould: Boolean read FEnterBould write SetEnterBould;
    property TopIconIncrement: Integer read FTopIconIncrement write SetTopIconIncrement;
    property GetBackGround: TGetBackGroundProc read FGetBackGround write SetGetBackGround;
    property Icon: TIcon read GetIcon write SetIcon;
    property UseSpecIconSize: Boolean read FUseSpecIconSize write FUseSpecIconSize;
    property HightliteImage: Boolean read FHightliteImage write SetHightliteImage;
    property StretchImage: Boolean read FStretchImage write SetStretchImage;
    property CanClick: Boolean read FCanClick write FCanClick;
    property UseEndEllipsis: Boolean read FUseEndEllipsis write SetUseEndEllipsis default false;
  end;

type
  TWebLinkManager = Class(TObject)
  private
    FLinks: TList<TWebLink>;
    FUseList: TList<TWebLink>;
  protected
    procedure UsedLink(Link: TWebLink);
    procedure RemoveLink(Link: TWebLink);
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  LINK_IL_MAX_ITEMS = 200;
  LINK_IL_ITEMS_TO_SWAP_AT_TIME = 20;

procedure Register;

implementation

var
  FWebLinkList: TWebLinkManager = nil;

function WebLinkList: TWebLinkManager;
begin
  if FWebLinkList = nil then
    FWebLinkList := TWebLinkManager.Create;

  Result := FWebLinkList;
end;

procedure Register;
begin
  RegisterComponents('Dm', [TWebLink]);
end;

{ TWebLink }

procedure TWebLink.CMFONTCHANGED(var Message: TWMNoParams);
begin
  LoadGDI;

  FFontStyles := Font.Style;
  FFontColor := Font.Color;

  if IsStyleEnabled then
    FFontColor := StyleServices.GetStyleFontColor(sfButtonTextFocused)
  else
    FFontColor := Font.Color;

  FFontName := Font.Name;
  FFontSize := Font.Size;
  FShowenBitmap.Canvas.Font.Assign(Font);
  RefreshBuffer;
end;

procedure TWebLink.CMMOUSEEnter(var Message: TWMNoParams);
begin
  if not FCanClick then
    Exit;

  LoadGDI;
  FIsHover := True;

  if EnterBould then
    FShowenBitmap.Canvas.Font.Style := FFontStyles + [fsUnderline, fsBold];
  RefreshBuffer;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
  inherited;
end;

procedure TWebLink.CMMOUSELEAVE(var Message: TWMNoParams);
begin
  LoadGDI;

  FIsHover := False;
  FShowenBitmap.Canvas.Font.Style := FFontStyles;

  RefreshBuffer;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
  inherited;
end;

procedure TWebLink.CMTextChanged(var Message: TMessage);
begin
  RefreshBuffer;
end;

procedure TWebLink.CNCtlColorStatic(var Message: TWMCtlColorStatic);
begin
  with StyleServices do
    if ThemeControl(Self) then
    begin
      if (Parent <> nil) and Parent.DoubleBuffered then
        PerformEraseBackground(Self, Message.ChildDC)
      else
        DrawParentBackground(Handle, Message.ChildDC, nil, False);
      { Return an empty brush to prevent Windows from overpainting we just have created. }
      Message.Result := GetStockObject(NULL_BRUSH);
    end
    else
      inherited;
end;

constructor TWebLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPainted := False;
  FIconStream := nil;
  WebLinkList.UsedLink(Self);
  FIsGDIFree := False;
  FIconChanged := False;
  FIsHover := False;
  FImageCanRegenerate := False;
  GetBackGround := nil;
  FOnMouseEnter := nil;
  FOnMouseLeave := nil;
  ControlStyle := ControlStyle - [csDoubleClicks] + [csParentBackground];
  Loading := True;
  FUseEnterColor := False;
  FIcon := TIcon.Create;
  FIcon.OnChange := IconChanged;
  UseSpecIconSize := True;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  FImageList := nil;
  FImage := TLayeredBitmap.Create;
  FImage.IsLayered := True;
  FIconWidth := 16;
  FIconHeight := 16;
  FTopIconIncrement := 0;
  DoubleBuffered := True;
  FShowenBitmap := TBitmap.Create;
  FShowenBitmap.PixelFormat := pf24bit;
  FEnterColor := 0;
  FStretchImage := True;
  FCanClick := True;
  Loading := False;
  FEnterBould := False;
  Cursor := crHandPoint;
end;

destructor TWebLink.Destroy;
begin
  WebLinkList.RemoveLink(Self);
  F(FCanvas);
  F(FIconStream);
  F(FShowenBitmap);
  F(FImage);
  F(FIcon);
  inherited;
end;

procedure TWebLink.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TWebLink.LoadFromHIcon(Icon: HIcon);
var
  TempIcon: TIcon;
begin
  if Icon = 0 then
    Exit;
  TempIcon := TIcon.Create;
  try
    TempIcon.Handle := CopyIcon(Icon);
    LoadIconSize(TempIcon, FIconWidth, FIconHeight);
  finally
    F(TempIcon);
  end;
end;

procedure TWebLink.LoadFromPathImage(Image: TPathImage);
begin
  if Image.HIcon <> 0 then
    LoadFromHIcon(Image.HIcon)
  else if Image.Icon <> nil then
    LoadIconSize(Image.Icon, Image.Icon.Width, Image.Icon.Height)
  else if Image.Bitmap <> nil then
    LoadBitmap(Image.Bitmap);
end;

procedure TWebLink.LoadFromResource(ResourceName: string);
var
  Icon: HIcon;
begin
  Icon := Winapi.Windows.LoadImage(HInstance, PChar(ResourceName), IMAGE_ICON, FIconWidth, FIconHeight, 0);
  try
    if Icon <> 0 then
      LoadFromHIcon(Icon);
  finally
    DestroyIcon(Icon);
  end;
end;

procedure TWebLink.FreeGDI;
begin
  if FIsGDIFree then
    Exit;

  FShowenBitmap.Dormant;
  FImage.Dormant;
  F(FCanvas);

  FIsGDIFree := True;
end;

function TWebLink.GetIcon: TIcon;
begin
  LoadGDI;
  Result := FIcon;
end;

procedure TWebLink.LoadGDI;
begin
  if FIsGDIFree then
  begin
    FCanvas := TControlCanvas.Create;
    TControlCanvas(FCanvas).Control := Self;

    FShowenBitmap.Canvas.Font.Name := FFontName;
    FShowenBitmap.Canvas.Font.Style := FFontStyles;
    if IsStyleEnabled then
      FShowenBitmap.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal)
    else
      FShowenBitmap.Canvas.Font.Color := FFontColor;
    FShowenBitmap.Canvas.Font.Size := FFontSize;

    FIsGDIFree := False;
  end;
  if FIconStream <> nil then
  begin
    F(FIcon);
    FIcon := TIcon.Create;
    FIconStream.Seek(0, soFromBeginning);
    try
      FIcon.LoadFromStream(FIconStream);
    except
      //ignore possible deserealization errors
    end;
    F(FIconStream);
  end;
  WebLinkList.UsedLink(Self);
end;

procedure TWebLink.LoadIconSize(Icon: TIcon; Width, Height: Integer);
begin
  LoadGDI;

  FIcon.Assign(Icon);
  FImage.LoadFromHIcon(FIcon.Handle, Width, Height);

  SaveIconToStream;

  RefreshBuffer;
end;

procedure TWebLink.LoadImage;
begin
  RefreshBuffer(True);
end;

procedure TWebLink.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  if not FPainted then
  begin
    FPainted := True;
    RefreshBuffer(True);
  end;
  DC := BeginPaint(Handle, PS);
  BitBlt(DC, 0, 0, ClientRect.Right, ClientRect.Bottom, FShowenBitmap.Canvas.Handle, 0, 0, SRCCOPY);
  EndPaint(Handle, PS);
end;

procedure TWebLink.RefreshBuffer(Force: Boolean);
var
  Drawrect: TRect;
  L: Integer;
begin
  if (csReading in ComponentState) then
    Exit;
  if (csLoading in ComponentState) then
    Exit;

  if not FPainted and not Force then
    Exit;

  if FIconChanged then
  begin
    FIconChanged := False;
    CreateImageFromIcon;
  end;

  CalculateLinkSize;

  if FPainted then
  begin
    if Assigned(FGetBackGround) then
      FGetBackGround(Self, Left, Top, Width, Height, FShowenBitmap)
    else
      DrawBackground(FShowenBitmap.Canvas);

    if FIsHover then
    begin
      FShowenBitmap.Canvas.Font.Style := FFontStyles + [fsUnderline];
      if UseEnterColor or IsStyleEnabled then
      begin
        if IsStyleEnabled then
          FShowenBitmap.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfCheckBoxTextHot)
        else
          FShowenBitmap.Canvas.Font.Color := EnterColor;
      end;
    end else
    begin
      if IsStyleEnabled then
        FShowenBitmap.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfCheckBoxTextNormal)
      else
        FShowenBitmap.Canvas.Font.Color := FFontColor;
    end;

    FShowenBitmap.Canvas.Brush.Style := bsClear;
    if ((FImageList = nil) or (ImageIndex = -1)) and (FIcon = nil) then
      FShowenBitmap.Canvas.TextOut(0, Height div 2 - FShowenBitmap.Canvas.TextHeight(Text) div 2, Text)

    else if (FImageList <> nil) and (ImageIndex <> -1) then
    begin
      FImageList.Draw(FShowenBitmap.Canvas, 0, 0, FImageIndex, dsTransparent, itImage, True);
      FShowenBitmap.Canvas.TextOut(FImageList.Width + 5, Height div 2 - FShowenBitmap.Canvas.TextHeight(Text) div 2, Text);
    end else if (FIcon <> nil) then
    begin
      if Enabled then
      begin
        if not FStretchImage then
          FImage.DoDraw(IconHeight div 2 - FImage.Height div 2, FTopIconIncrement + IconWidth div 2 - FImage.Width div 2,
            FShowenBitmap, FIsHover and HightliteImage)
        else
          FImage.DoStreachDraw(0, FTopIconIncrement + FShowenBitmap.Height div 2 - FImage.Height div 2, IconWidth, IconHeight, FShowenBitmap)
      end else
      begin
        if (IconWidth = FImage.Width) and (IconHeight = FImage.Height) then
          FImage.DoDrawGrayscale(0, FTopIconIncrement + FShowenBitmap.Height div 2 - FImage.Height div 2, FShowenBitmap)
        else
          FImage.DoStreachDrawGrayscale(0, FTopIconIncrement + FShowenBitmap.Height div 2 - FImage.Height div 2, IconWidth, IconHeight, FShowenBitmap);
      end;

      L := FIconWidth + IIF(IconWidth <> 0, 5, 0);

      if Assigned(FGetBackGround) then
      begin
        DrawRect := Rect(L, Height div 2 - FShowenBitmap.Canvas.TextHeight(Text) div 2, Width, Height);
        DrawText(FShowenBitmap.Canvas.Handle, PChar(Text), Length(Text), DrawRect, DT_NOCLIP or DT_CENTER or DT_VCENTER or IIF(UseEndEllipsis, DT_END_ELLIPSIS, 0));
      end else
      begin
        DrawRect := Rect(L, Height div 2 - FShowenBitmap.Canvas.TextHeight(Text) div 2, Width, Height);
        FShowenBitmap.Canvas.FillRect(DrawRect);
        DrawText(FShowenBitmap.Canvas.Handle, PChar(Text), Length(Text), DrawRect, DT_NOCLIP or DT_VCENTER or IIF(UseEndEllipsis, DT_END_ELLIPSIS, 0));
      end;
    end;
    Invalidate;
  end;
end;

procedure TWebLink.Refresh;
begin
  RefreshBuffer(True);
  if not (csReadingState in ControlState) then
    Invalidate;
end;

procedure TWebLink.SaveIconToStream;
begin
  FIconStream := TMemoryStream.Create;
  FIcon.SaveToStream(FIconStream);
  F(FIcon);
end;

procedure TWebLink.SetDefault;
begin
  LoadGDI;

  if UseEnterColor then
    FShowenBitmap.Canvas.Font.Color := EnterColor;
  FShowenBitmap.Canvas.Font.Style := FFontStyles;
  RefreshBuffer;
end;

procedure TWebLink.SetEnterBould(const Value: boolean);
begin
  FEnterBould := Value;
end;

procedure TWebLink.SetEnterColor(const Value: TColor);
begin
  FEnterColor := Value;
end;

procedure TWebLink.SetGetBackGround(const Value: TGetBackGroundProc);
begin
  FGetBackGround := Value;
end;

procedure TWebLink.SetHightliteImage(const Value: Boolean);
begin
  if FHightliteImage <> Value then
  begin
    FHightliteImage := Value;
    RefreshBuffer;
  end;
end;

procedure TWebLink.SetIcon(const Value: TIcon);
begin
  LoadGDI;
  FIcon.Assign(Value);
  CreateImageFromIcon;
end;

procedure TWebLink.SetIconHeight(const Value: Integer);
begin
  if FIconHeight <> Value then
  begin
    FIconHeight := Value;
    RefreshBuffer;
  end;
end;

procedure TWebLink.SetIconWidth(const Value: Integer);
begin
  if FIconWidth <> Value then
  begin
    FIconWidth := Value;
    RefreshBuffer;
  end;
end;

procedure TWebLink.SetImageIndex(const Value: Integer);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    RefreshBuffer;
  end;
end;

procedure TWebLink.SetImageList(const Value: TCustomImageList);
begin
  if FImageList <> Value then
  begin
    FImageList := Value;
    RefreshBuffer;
  end;
end;

procedure TWebLink.SetOnClick(const Value: TNotifyEvent);
begin
  FOnClick := Value;
end;

procedure TWebLink.SetStretchImage(const Value: Boolean);
begin
  FStretchImage := Value;
  RefreshBuffer;
end;

procedure TWebLink.SetTopIconIncrement(const Value: integer);
begin
  FTopIconIncrement := Value;
end;

procedure TWebLink.SetUseEnterColor(const Value: boolean);
begin
  FUseEnterColor := Value;
end;

procedure TWebLink.StartChanges;
begin
  FPainted := False;
end;

procedure TWebLink.SetUseEndEllipsis(const Value: Boolean);
begin
  FUseEndEllipsis := Value;
end;

procedure TWebLink.WMMouseDown(var Message: Tmessage);
begin
  inherited;
  if Enabled and FCanClick and Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TWebLink.WMSize(var Message: TSize);
begin
  if (Message.cx <> Width) or (Message.cy <> Height)  then
    RefreshBuffer;
end;

procedure TWebLink.IconChanged(Sender: TObject);
begin
  if (csReading in ComponentState) or not FPainted then
    FIconChanged := True
  else
    RefreshBuffer(True);
end;

procedure TWebLink.CreateImageFromIcon;
begin
  LoadGDI;

  if UseSpecIconSize then
    FImage.LoadFromHIcon(FIcon.Handle, FIconWidth, FIconHeight)
  else
    FImage.LoadFromHIcon(FIcon.Handle);

  SaveIconToStream;
end;

procedure TWebLink.LoadBitmap(Bitmap: TBitmap);
begin
  LoadGDI;
  FImage.LoadFromBitmap(Bitmap);
end;

procedure TWebLink.Loaded;
begin
  inherited;
end;

procedure TWebLink.CalculateLinkSize;
begin
  LoadGDI;
  if (FIcon <> nil) then
  begin
    if not UseEndEllipsis then
      Width := FShowenBitmap.Canvas.TextWidth(Text) + FIconWidth + IIF(FIconWidth > 0, 5, 0);
    Height := Max(FShowenBitmap.Canvas.TextHeight(Text + ' '), FIconHeight);
  end else if (FImageList <> nil) then
  begin
    if not UseEndEllipsis then
      Width := FShowenBitmap.Canvas.TextWidth(Text);
    Height := FShowenBitmap.Canvas.TextHeight(Text + ' ');
  end else if (FImageList <> nil) and (ImageIndex <> -1) then
  begin
    if not UseEndEllipsis then
      Width := FShowenBitmap.Canvas.TextWidth(Text) + FImageList.Width + 5;
    Height := Max(FShowenBitmap.Canvas.TextHeight(Text + ' '), FImageList.Height);
  end else
  begin
    if not UseEndEllipsis then
      Width := FShowenBitmap.Canvas.TextWidth(Text) + 5;
    Height := FShowenBitmap.Canvas.TextHeight(Text + ' ');
  end;

  FShowenBitmap.SetSize(Width, Height);
end;

procedure TWebLink.CMColorChanged(var Message: TMessage);
begin
  LoadGDI;

  FShowenBitmap.Canvas.Brush.Color := Color;
  FShowenBitmap.Canvas.Pen.Color := Color;
  RefreshBuffer;
end;

procedure TWebLink.CMEnabledChanged(var Message: TMessage);
begin
  RefreshBuffer;
  inherited;
end;

{ TWebLinkManager }

constructor TWebLinkManager.Create;
begin
  FLinks := TList<TWebLink>.Create;
  FUseList := TList<TWebLink>.Create;
end;

destructor TWebLinkManager.Destroy;
begin
  F(FLinks);
  F(FUseList);
  inherited;
end;

procedure TWebLinkManager.RemoveLink(Link: TWebLink);
begin
  FUseList.Remove(Link);
end;

procedure TWebLinkManager.UsedLink(Link: TWebLink);
var
  I: Integer;
begin
  RemoveLink(Link);
  FUseList.Add(Link);
  if FUseList.Count > LINK_IL_MAX_ITEMS then
  begin
    for I := LINK_IL_ITEMS_TO_SWAP_AT_TIME - 1 downto 0 do
    begin
      FUseList[I].FreeGDI;
      FUseList.Delete(I);
    end;
  end;
end;

initialization

finalization
  F(FWebLinkList);

end.





