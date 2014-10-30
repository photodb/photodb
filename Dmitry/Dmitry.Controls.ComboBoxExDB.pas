unit Dmitry.Controls.ComboBoxExDB;

interface

uses
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Graphics,
  Vcl.Themes,
  Dmitry.Memory,
  Dmitry.Graphics.LayeredBitmap;

{$R-}

type
  TOnGetAdditionalImageEvent = procedure(Sender: TObject; Index: Integer; HDC: THandle; var Top, Left: Integer) of object;

  TComboBoxExDBStyleHook = class(TComboBoxStyleHook)
  strict private
    FDroppedDown: Boolean;
    FComboBoxHandle: HWnd;
    FComboBoxInstance: Pointer;
    FDefComboBoxProc: Pointer;
    procedure InitComboBoxWnd;
    procedure PaintComboBoxWnd;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPaint;
    procedure WMParentNotify(var Message: TMessage); message WM_ParentNotify;
  strict protected
    procedure ComboBoxWndProc(var Msg: TMessage); virtual;
    procedure DoHotTrackTimer(Sender: TObject); override;
    procedure DrawComboBox(DC: HDC); virtual;
    procedure MouseLeave; override;
    procedure DrawListBoxItem(ADC: HDC; ARect: TRect; AIndex: Integer; ASelected: Boolean);
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
    destructor Destroy; override;
  end;

type
  TComboBoxExDB = class(TComboBoxEx)
  private
    { Private declarations }
    FShowDropDownMenu: Boolean;
    FLastItemIndex: Integer;
    FOnEnterDown: TNotifyEvent;
    FNullText: string;
    FStartText: string;
    FOnGetAdditionalImage: TOnGetAdditionalImageEvent;
    FShowEditIndex: Integer;
    FDefaultIcon: TIcon;
    FEditInnerMouse: Boolean;
    FText: string;
    FHideItemIcons: Boolean;
    FDefaultImage: TLayeredBitmap;
    FCanClickIcon: Boolean;
    FIconInnerMouse: Boolean;
    FPressed: Boolean;
    FIconClick: TNotifyEvent;
    procedure SetShowDropDownMenu(const Value: Boolean);
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure WMDrawItem(var Message: TWMDrawItem); message WM_DRAWITEM;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure CMMouseLeave(var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TWMNoParams); message CM_MOUSEENTER;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WmSetFocus(var Message: TMessage); message WM_SETFOCUS;
    procedure WmKillFocus(var Message: TMessage); message WM_KILLFOCUS;
    procedure SetOnEnterDown(const Value: TNotifyEvent);
    procedure SetNullText(const Value: string);
    procedure SetOnGetAdditionalImage(const Value: TOnGetAdditionalImageEvent);
    procedure SetLastItemIndex(const Value: integer);
    procedure SetShowEditIndex(const Value: integer);
    procedure SetDefaultIcon(const Value: TIcon);
    procedure SetHideItemIcons(const Value: Boolean);
    procedure SetCanClickIcon(const Value: Boolean);
  protected
    { Protected declarations }
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd;  ComboProc: Pointer); override;
    procedure WndProc(var Message: TMessage); override;
    procedure DrawEditIcon(DC: HDC);
  public
    { Public declarations }
    class constructor Create;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AdjustDropDown; override;
    procedure SetItemIndex(const Value: Integer); override;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property ShowDropDownMenu: Boolean read FShowDropDownMenu write SetShowDropDownMenu;
    property LastItemIndex: Integer read FLastItemIndex write SetLastItemIndex;
    property OnEnterDown: TNotifyEvent read FOnEnterDown write SetOnEnterDown;
    property NullText: string read FNullText write SetNullText;
    property ShowEditIndex: Integer read FShowEditIndex write SetShowEditIndex;
    property OnGetAdditionalImage: TOnGetAdditionalImageEvent read FOnGetAdditionalImage write SetOnGetAdditionalImage;
    property StartText: string read FStartText write FStartText;
    property DefaultIcon: TIcon read FDefaultIcon write SetDefaultIcon;
    property HideItemIcons: Boolean read FHideItemIcons write SetHideItemIcons;
    property CanClickIcon: Boolean read FCanClickIcon write SetCanClickIcon;
    property IconClick: TNotifyEvent read FIconClick write FIconClick;
    property ListHandle: HWND read FListHandle;
    property EditHandle: HWND read FEditHandle;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TComboBoxExDB]);
end;

{ TComboBoxExDB }

function ColorDiv2(Color1, Color2 : TColor) : TColor;
begin
  Result:=RGB((GetRValue(Color1) + GetRValue(Color2)) div 2,
    (GetGValue(Color1) + GetGValue(Color2)) div 2,
    (GetBValue(Color1) + GetBValue(Color2)) div 2);
end;

procedure TComboBoxExDB.AdjustDropDown;
var
  Count: Integer;
  aItemHeight: integer;
begin
  if not ShowDropDownMenu then
    Exit;
  Count := ItemCount;
  if Count > DropDownCount then Count := DropDownCount;
  if Count < 1 then
    Count := 1;
  FDroppingDown := True;
  try
    aItemHeight := 32;
    SetWindowPos(FDropHandle, 0, 0, 0, Width, aItemHeight * Count +
      Height + 2, SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_HIDEWINDOW);
  finally
    FDroppingDown := False;
  end;
  SetWindowPos(FDropHandle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or
    SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW);
end;

procedure TComboBoxExDB.CMMouseEnter(var Message: TWMNoParams);
begin
  FEditInnerMouse := True;
  inherited;
end;

procedure TComboBoxExDB.CMMouseLeave(var Message: TWMNoParams);
begin
  FEditInnerMouse := False;
  FPressed := False;
  inherited;
end;

procedure TComboBoxExDB.CMTextChanged(var Message: TMessage);
begin
  FText := Text;
end;

procedure TComboBoxExDB.CNCommand(var Message: TWMCommand);
begin
  inherited;
  case Message.NotifyCode of
    CBN_SELCHANGE:
      FText := Items[ItemIndex];
  end;
end;

procedure TComboBoxExDB.ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
  ComboProc: Pointer);
var
  rcItem: TRect;
  DC: HDC;
  Bitmap: TBitmap;
  PS: TPaintStruct;
  C, FC: TColor;
begin
  if ComboWnd = FEditHandle then
  begin
    if not Focused and (Message.Msg <> WM_GETTEXT) and Visible and (FText = '') then
    begin
      if (Message.Msg = WM_PAINT) or (Message.Msg = WM_ERASEBKGND) then
      begin
        rcItem := Rect(1, 0, Width, Height);
        Bitmap := TBitmap.Create;
        try

          if StyleServices.Enabled then
          begin
            C := StyleServices.GetStyleColor(scEdit);
            FC := StyleServices.GetStyleFontColor(sfEditBoxTextNormal);
          end else
          begin
            C := Color;
            FC := Font.Color;
          end;

          Bitmap.Canvas.Font.Assign(Font);
          Bitmap.Canvas.Font.Color := ColorDiv2(ColorToRGB(C), ColorToRGB(FC));
          Bitmap.Canvas.Brush.Color := C;
          Bitmap.Canvas.Pen.Color := C;
          Bitmap.Width := Width;
          Bitmap.Height := Height;
          Bitmap.Canvas.Rectangle(0, 0, Width, Height);
          DrawText(Bitmap.Canvas.Handle, PChar(FStartText), Length(FStartText), rcItem, DT_TOP);

          DC := BeginPaint(FEditHandle, PS);
          try
            BitBlt(DC, 0, 0, Width, Height, Bitmap.Canvas.Handle, 0, 0, SrcCopy);
          finally
            EndPaint(Handle, PS);
          end;
        finally
          F(Bitmap);
        end;
        Exit;
      end
    end;
  end else
  begin
    if Message.Msg = WM_MOUSEMOVE then
    begin
      if FCanClickIcon then
      begin
        rcItem := Rect(3, 3, 3 + FDefaultImage.Width, 3 + FDefaultImage.Height);
        FIconInnerMouse := PtInRect(rcItem, Point(TWMMouse(Message).XPos, TWMMouse(Message).YPos));
        if FIconInnerMouse then
          Perform(CBEM_SETIMAGELIST, 0, Images.Handle);
      end;
    end else if Message.Msg = WM_MOUSELEAVE then
    begin
      if FCanClickIcon then
      begin
        FIconInnerMouse := False;
        FPressed := False;
        rcItem := Rect(3, 3, 3 + FDefaultImage.Width, 3 + FDefaultImage.Height);
      end;
    end else if Message.Msg = WM_LBUTTONDOWN then
    begin
      if FCanClickIcon then
      begin
        FPressed := True;
        Perform(CBEM_SETIMAGELIST, 0, Images.Handle);
      end;
    end else if Message.Msg = WM_LBUTTONUP then
    begin
      if FCanClickIcon then
      begin
        if FIconInnerMouse and FCanClickIcon and Assigned(FIconClick) then
          FIconClick(Self);
        FPressed := False;
      end;
    end;
  end;

  if ComboWnd <> 0 then
    inherited;

  if (ComboWnd = FEditHandle) and (Message.Msg = WM_KEYDOWN) then
    PostMessage(Handle, CM_TEXTCHANGED, 0, 0);
end;

class constructor TComboBoxExDB.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TComboBoxExDB, TComboBoxExDBStyleHook);
end;

constructor TComboBoxExDB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaultImage := TLayeredBitmap.Create;
  FShowDropDownMenu := True;
  FOnEnterDown := nil;
  fShowEditIndex := -1;
  FDefaultIcon := TIcon.Create;
  FEditInnerMouse := False;
  FHideItemIcons := False;
  FPressed := False;
end;

destructor TComboBoxExDB.Destroy;
begin
  F(FDefaultIcon);
  F(FDefaultImage);
  inherited;
end;

procedure TComboBoxExDB.DrawEditIcon(DC: HDC);
var
  BIco: TBitmap;
begin
  FDefaultImage.LoadFromHIcon(FDefaultIcon.Handle);
  BIco := TBitmap.Create;
  try
    BIco.PixelFormat := pf24bit;
    BIco.SetSize(FDefaultImage.Width, FDefaultImage.Height);

    if StyleServices.Enabled then
    begin
      BIco.Canvas.Brush.Color := StyleServices.GetStyleColor(scEdit);
      BIco.Canvas.Pen.Color := StyleServices.GetStyleColor(scEdit);
    end else
    begin
      BIco.Canvas.Brush.Color := clWindow;
      BIco.Canvas.Pen.Color := clWindow;
    end;
    BIco.Canvas.Rectangle(0, 0, FDefaultImage.Width, FDefaultImage.Height);

    if FCanClickIcon then
    begin
      if FIconInnerMouse then
        FDefaultImage.DoLayeredDraw(0, 0, 255, BIco)
      else
        FDefaultImage.DoLayeredDraw(0, 0, 127, BIco);

      if FPressed and FIconInnerMouse then
        DrawFocusRect(BIco.Canvas.Handle, Rect(0, 0, BIco.Width - 1, BIco.Height - 1));
    end else
      FDefaultImage.DoLayeredDraw(0, 0, 255, BIco);

    BitBlt(DC, 3, 3, Width, Height, BIco.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    F(BIco);
  end;
end;

procedure TComboBoxExDB.SetCanClickIcon(const Value: Boolean);
begin
  FCanClickIcon := Value;
  PostMessage(Handle, WM_PAINT, 0, 0);
end;

procedure TComboBoxExDB.SetDefaultIcon(const Value: TIcon);
begin
  if Value <> nil then
    FDefaultIcon.Assign(Value);
end;

procedure TComboBoxExDB.SetHideItemIcons(const Value: Boolean);
begin
  FHideItemIcons := Value;
end;

procedure TComboBoxExDB.SetItemIndex(const Value: Integer);
begin
  inherited;
  PostMessage(Handle, CM_TEXTCHANGED, 0, 0);
  PostMessage(Handle, WM_PAINT, 0, 0);
end;

procedure TComboBoxExDB.SetLastItemIndex(const Value: integer);
begin
  FLastItemIndex := Value;
end;

procedure TComboBoxExDB.SetNullText(const Value: string);
begin
  FNullText := Value;
end;

procedure TComboBoxExDB.SetOnEnterDown(const Value: TNotifyEvent);
begin
  FOnEnterDown := Value;
end;

procedure TComboBoxExDB.SetOnGetAdditionalImage(
  const Value: TOnGetAdditionalImageEvent);
begin
  FOnGetAdditionalImage := Value;
end;

procedure TComboBoxExDB.SetShowDropDownMenu(const Value: boolean);
begin
  FShowDropDownMenu := Value;
end;

procedure TComboBoxExDB.SetShowEditIndex(const Value: integer);
begin
  FShowEditIndex := Value;
end;

procedure TComboBoxExDB.WMDrawItem(var Message: TWMDrawItem);
var
  OldState, State: TOwnerDrawState;
  Bitmap: TBitmap;
  OldRect: TRect;
  ItemID: Cardinal;
  ABrush: TBrush;
  DC: HDC;
  S: string;
begin
  if Images = nil then
  begin
    inherited;
    Exit;
  end;

  DC := message.DrawItemStruct^.hDC;
  ItemID := message.DrawItemStruct^.itemID;
  OldState := TOwnerDrawState(LongRec(message.DrawItemStruct^.ItemState).Lo);
  State := OldState - [OdNoFocusRect, OdFocused];
  if OdComboBoxEdit in State then
    State := State - [OdSelected];

  LongRec(message.DrawItemStruct^.ItemState).Lo := Word(State);

  if Int64(ItemID) >= Int64(MaxInt) then
    ItemID := FLastItemIndex;

  if (not(OdComboBoxEdit in State)) and HideItemIcons then
  begin

    ABrush := TBrush.Create;
    try
      ABrush.Style := bsSolid;
      if OdSelected in OldState then
        ABrush.Color := clHighlight
      else
        ABrush.Color := clWindow;

      FillRect(DC, message.DrawItemStruct^.rcItem, ABrush.Handle);

      InflateRect(message.DrawItemStruct^.rcItem, -5, 0);

      SetBkColor(DC, COLORREF(ABrush.Color));
      SetBkMode(DC, BS_NULL);
      if Integer(ItemID) < ItemsEx.Count then
        S := ItemsEx[ItemID].Caption
      else
        S := Name;
      DrawText(DC, PChar(S), Length(S), message.DrawItemStruct^.RcItem, DT_TOP);
    finally
      F(ABrush);
    end;

  end else
    DefaultHandler(Message);

  Bitmap := TBitmap.Create;
  try
    if Int64(ItemID) >= (MaxInt) then
      ItemID := FLastItemIndex
    else
    begin
      if OdComboBoxEdit in State then
      begin
        if FShowEditIndex <> -1 then
        begin
          if (FShowEditIndex < Images.Count) then
            ItemID := FShowEditIndex
          else
            ItemID := FLastItemIndex;
        end else
          FLastItemIndex := ItemID;
      end;
    end;
    Images.GetBitmap(ItemID, Bitmap);

    if not (FHideItemIcons and (not(OdComboBoxEdit in State))) then
    begin
      if OdComboBoxEdit in State then
      begin
        if not Bitmap.Empty then
          BitBlt(DC, message.DrawItemStruct^.RcItem.Left, message.DrawItemStruct^.RcItem.Top, 32, 32, Bitmap.Canvas.Handle, 0, 0, SRCCOPY)
        else begin
          DrawEditIcon(DC);
        end;
      end else
        BitBlt(DC, message.DrawItemStruct^.RcItem.Left + 3, message.DrawItemStruct^.RcItem.Top, 32, 32, Bitmap.Canvas.Handle, 0, 0, SRCCOPY);

      OldRect := message.DrawItemStruct^.RcItem;
      OldRect.Left := message.DrawItemStruct^.RcItem.Left + 3 + Images.Width;
      message.DrawItemStruct^.RcItem.Top := message.DrawItemStruct^.RcItem.Top + 1;
      message.DrawItemStruct^.RcItem.Left := message.DrawItemStruct^.RcItem.Left + 16 + Images.Width;
    end else
      OldRect := message.DrawItemStruct^.RcItem;

    if Int64(ItemID) < Int64(ItemsEx.Count) then
      if ItemsEx[ItemID].Caption = '' then
      begin
        if not(OdComboBoxEdit in State) then
        begin
          SetBkMode(DC, BS_NULL);
          SetDCPenColor(DC, ColorDiv2(Font.Color, Color));
          DrawText(DC, PChar(FNullText), Length(FNullText), message.DrawItemStruct^.RcItem, DT_TOP);
        end;
      end;
  finally
    F(Bitmap);
  end;

  if not(OdComboBoxEdit in State) then
    if Assigned(FOnGetAdditionalImage) then
      FOnGetAdditionalImage(Self, ItemID, message.DrawItemStruct^.HDC, message.DrawItemStruct^.RcItem.Top, message.DrawItemStruct^.RcItem.Left);
end;

procedure TComboBoxExDB.WMKeyDown(var Message: TWMKeyDown);
begin
  case Message.CharCode of
    VK_RETURN:
      begin
        if Assigned(FOnEnterDown) then
          FOnEnterDown(Self);
        Message.Msg := 0;
      end;
  end;
  inherited;
end;

procedure TComboBoxExDB.WmKillFocus(var Message: TMessage);
begin
  PostMessage(Handle, WM_PAINT, 0, 0);
  inherited;
end;

procedure TComboBoxExDB.WmSetFocus(var Message: TMessage);
begin
  PostMessage(Handle, WM_PAINT, 0, 0);
  inherited;
end;

procedure TComboBoxExDB.WndProc(var Message: TMessage);
begin
  inherited;
  ComboWndProc(Message, 0, nil);
end;

{ TComboBoxExDBStyleHook }

constructor TComboBoxExDBStyleHook.Create(AControl: TWinControl);
begin
  inherited;
  OverridePaint := False;
  OverridePaintNC := False;
  FDroppedDown := False;

  FComboBoxHandle := 0;
  FComboBoxInstance := MakeObjectInstance(ComboBoxWndProc);
  FDefComboBoxProc := nil;
end;

destructor TComboBoxExDBStyleHook.Destroy;
begin
  if FComboBoxHandle  <> 0 then
    SetWindowLong(FComboBoxHandle, GWL_WNDPROC, IntPtr(FDefComboBoxProc));
  FreeObjectInstance(FComboBoxInstance);
  inherited;
end;

procedure TComboBoxExDBStyleHook.WMParentNotify(var Message: TMessage);
begin
  if TStyleManager.SystemStyle.Enabled then inherited;
end;

procedure TComboBoxExDBStyleHook.WndProc(var Message: TMessage);
begin
  // Reserved for potential updates
  inherited;
  if Message.Msg = CM_RECREATEWND then
  begin
    MouseInControl := False;
    MouseLeave;
  end;
end;

procedure TComboBoxExDBStyleHook.DoHotTrackTimer;
var
  P: TPoint;
begin
  GetCursorPos(P);
  if WindowFromPoint(P) <> FComboBoxHandle then
  begin
    StopHotTrackTimer;
    MouseInControl := False;
    MouseLeave;
  end;
end;

procedure TComboBoxExDBStyleHook.MouseLeave;
begin
  MouseOnButton := False;
  PaintComboBoxWnd;
end;

procedure TComboBoxExDBStyleHook.DrawListBoxItem(ADC: HDC; ARect: TRect; AIndex: Integer; ASelected: Boolean);
var
  Canvas: TCanvas;
  Offset: Integer;
  IconX, IconY: Integer;
  Buffer: TBitMap;
  LCaption: String;
  R: TRect;
begin
  if (AIndex < 0) or (AIndex >= TComboBoxEx(Control).ItemsEx.Count) then Exit;
  Canvas := TCanvas.Create;
  Canvas.Handle := ADC;
  Buffer := TBitmap.Create;
  Buffer.Width := ARect.Width;
  Buffer.Height := ARect.Height;
  try
    Buffer.Canvas.Font.Assign(TComboBoxEx(Control).Font);
    with Buffer.Canvas do
    begin
      // draw item background
      Brush.Style := bsSolid;
      if ASelected then
      begin
        Brush.Color := clHighLight;
        Font.Color := clHighLightText;
      end
      else
      begin
        Brush.Color := StyleServices.GetStyleColor(scComboBox);
        Font.Color := StyleServices.GetStyleFontColor(sfComboBoxItemNormal);
      end;
      FillRect(Rect(0, 0, Buffer.Width, Buffer.Height));
      Offset := TComboExItem(TComboBoxEx(Control).ItemsEx[AIndex]).Indent;
      if Offset > 0 then Offset := (Offset * 10) + 5
      else Offset := 5;
      // draw item image
      if (TComboBoxEx(Control).Images <> nil) and not TComboBoxExDB(Control).HideItemIcons then
      with TComboBoxEx(Control) do
      begin
        IconX := Offset;
        IconY := Buffer.Height div 2 - Images.Height div 2;
        if IconY < 0 then IconY := 0;
        if (ItemsEx[AIndex].ImageIndex >= 0) and
           (ItemsEx[AIndex].ImageIndex < Images.Count) then
            Images.Draw(Buffer.Canvas, IconX, IconY,
            ItemsEx[AIndex].ImageIndex, True);
        Offset := Offset + Images.Width + 5;
      end;
      // draw item text
      R := Rect(Offset, 0, Buffer.Width, Buffer.Height);
      Buffer.Canvas.Brush.Style := bsClear;
      LCaption := TComboBoxEx(Control).ItemsEx[AIndex].Caption;
      if LCaption <> '' then
         DrawText(Buffer.Canvas.Handle, PWideChar(LCaption), Length(LCaption), R,
           DT_LEFT OR DT_VCENTER or DT_SINGLELINE);
    end;
    Canvas.Draw(ARect.Left, ARect.Top, Buffer);
  finally
    Buffer.Free;
    Canvas.Handle := 0;
    Canvas.Free;
  end;
end;

procedure TComboBoxExDBStyleHook.ComboBoxWndProc(var Msg: TMessage);
var
  FCallOldProc: Boolean;
  PS: TPaintStruct;
  DC, PaintDC: HDC;
  P: TPoint;
  FOldMouseOnButton: Boolean;
  R: TRect;
begin
  FCallOldProc := True;
  case Msg.Msg of
    WM_ERASEBKGND:
      begin
        Msg.Result := 1;
        FCallOldProc := False;
      end;
    WM_CTLCOLORLISTBOX:
     if (ListHandle = 0) and (Msg.LParam <> 0) and (ListBoxInstance = nil) then
       HookListBox(Msg.LParam);
    WM_DRAWITEM:
    begin
      with TWMDrawItem(Msg) do
      begin
        DrawListBoxItem(DrawItemStruct.hDC,
        DrawItemStruct.rcItem,
        DrawItemStruct.itemID,
        DrawItemStruct.itemState and ODS_SELECTED <> 0);
      end;
      FCallOldProc := False;
    end;
    WM_PAINT:
      begin
        DC := HDC(Msg.WParam);
        if DC <> 0 then
          PaintDC := DC
        else
          PaintDC := BeginPaint(FComboBoxHandle, PS);
        try
          DrawComboBox(PaintDC);
        finally
          if DC = 0 then
            EndPaint(FComboBoxHandle, PS);
        end;
        FCallOldProc := False;
      end;
    WM_MOUSEMOVE:
      begin
        if not MouseInControl then
        begin
          MouseInControl := True;
          StartHotTrackTimer;
          MouseEnter;
        end;
        P := Point(TWMMouse(Msg).XPos, TWMMouse(Msg).YPos);
        FOldMouseOnButton := MouseOnButton;
        R := ButtonRect;
        if PtInRect(R, P) then
          MouseOnButton := True
        else
          MouseOnButton := False;
        if FOldMouseOnButton <> MouseOnButton then
          InvalidateRect(FComboBoxHandle, @R, False);
     end;
  end;
  if FCallOldProc then
    with Msg do
      Result := CallWindowProc(FDefComboBoxProc, FComboBoxHandle, Msg, WParam, LParam);
end;

procedure TComboBoxExDBStyleHook.PaintComboBoxWnd;
begin
  RedrawWindow(FComboBoxHandle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
end;

procedure TComboBoxExDBStyleHook.WMNCPaint(var Message: TMessage);
begin
  if FComboBoxHandle = 0 then
    InitComboBoxWnd;
end;

procedure TComboBoxExDBStyleHook.WMCommand(var Message: TWMCommand);
begin
  CallDefaultProc(TMessage(Message));
  case Message.NotifyCode of
    CBN_SELCHANGE, CBN_SELENDOK,
    CBN_SETFOCUS, CBN_KILLFOCUS:
      PaintComboBoxWnd;
    CBN_DROPDOWN:
      begin
        FDroppedDown := True;
        PaintComboBoxWnd;
      end;
     CBN_CLOSEUP:
      begin
        FDroppedDown := False;
        PaintComboBoxWnd;
      end;
  end;
  Handled := True;
end;

procedure TComboBoxExDBStyleHook.DrawComboBox(DC: HDC);
var
  Canvas: TCanvas;
  DrawState: TThemedComboBox;
  Details: TThemedElementDetails;
  R: TRect;
  BtnDrawState: TThemedComboBox;
  IconX, IconY: Integer;
  LCaption: string;
  Buffer: TBitmap;
begin
  if not StyleServices.Available or (Control.Width = 0) or (Control.Height = 0) then
    Exit;

  Canvas := TCanvas.Create;
  try
    Canvas.Handle := DC;
    Buffer := TBitMap.Create;
    try
      Buffer.Width := Control.Width;
      Buffer.Height := Control.Height;
      if not Control.Enabled then
        DrawState := tcBorderDisabled
      else if MouseInControl then
        DrawState := tcBorderHot
      else if Focused then
        DrawState := tcBorderFocused
      else
        DrawState := tcBorderNormal;

      R := Rect(0, 0, Control.Width, Control.Height);
      Details := StyleServices.GetElementDetails(DrawState);
      StyleServices.DrawElement(Buffer.Canvas.Handle, Details, R);

      if not Control.Enabled then
        BtnDrawState := tcDropDownButtonDisabled
      else if FDroppedDown then
        BtnDrawState := tcDropDownButtonPressed
      else if MouseOnButton then
        BtnDrawState := tcDropDownButtonHot
      else
        BtnDrawState := tcDropDownButtonNormal;

      if TCustomComboBoxEx(Control).Style <> csExSimple then
      begin
        Details := StyleServices.GetElementDetails(BtnDrawState);
        StyleServices.DrawElement(Buffer.Canvas.Handle, Details, ButtonRect);
      end;

      R := Control.ClientRect;
      InflateRect(R, -3, -3);
      R.Right := ButtonRect.Left - 2;
      Buffer.Canvas.Font.Assign(TComboBoxEx(Control).Font);
      if Control.Enabled then
        Buffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfComboBoxItemNormal)
      else
        Buffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfComboBoxItemDisabled);
      if TComboBoxEx(Control).Style = csExDropDownList then
      begin
         if TComboBoxEx(Control).Focused then
           with Buffer.Canvas do
           begin
             if TComboBoxEx(Control).ItemIndex <> -1 then
             begin
               Brush.Color := clHighLight;
               Brush.Style := bsSolid;
               FillRect(R);
               Font.Color := clHighLightText;
             end;
             DrawFocusRect(R);
           end
         else
           with Buffer.Canvas do
           begin
             Brush.Color := Self.Brush.Color;
             Brush.Style := bsSolid;
             FillRect(R);
           end;
      end;

      if TComboBoxEx(Control).Style <> csExSimple then
      begin
        // draw image
        if TComboBoxExDB(Control).CanClickIcon then
          TComboBoxExDB(Control).DrawEditIcon(Buffer.Canvas.Handle)
        else
        begin
          if (TComboBoxEx(Control).Images <> nil) and
             (TComboBoxEx(Control).ItemIndex <> -1) then
            with TComboBoxEx(Control) do
            begin
              IconX := 5;
              IconY := R.Top + R.Height div 2 - Images.Height div 2;
              if IconY < R.Top then IconY := R.Top;

              if (ItemsEx[ItemIndex].ImageIndex >= 0) and
                 (ItemsEx[ItemIndex].ImageIndex < Images.Count) then
                Images.Draw(Buffer.Canvas, IconX, IconY,
                  ItemsEx[ItemIndex].ImageIndex, Control.Enabled);

              R.Left := IconX + IMages.Width + 5;
            end
          else
            Inc(R.Left, 5);
          // draw text
          if (TComboBoxEx(Control).ItemIndex <> -1) then
          begin
            Buffer.Canvas.Brush.Style := bsClear;
            LCaption := TComboBoxEx(Control).ItemsEx[TComboBoxEx(Control).ItemIndex].Caption;
            if LCaption <> '' then
              DrawText(Buffer.Canvas.Handle, PWideChar(LCaption), Length(LCaption), R,
                DT_LEFT OR DT_VCENTER or DT_SINGLELINE);
          end;
        end;
      end;

      Canvas.Draw(0, 0, Buffer);
    finally
      Buffer.Free;
    end;
  finally
    Canvas.Handle := 0;
    Canvas.Free;
  end;
  Handled := True;
end;

procedure TComboBoxExDBStyleHook.InitComboBoxWnd;
begin
  if FComboBoxHandle = 0 then
  begin
    FComboBoxHandle := SendMessage(Handle, CBEM_GETCOMBOCONTROL, 0, 0);
    if FComboBoxHandle <> 0 then
    begin
      FDefComboBoxProc := Pointer(GetWindowLong(FComboBoxHandle, GWL_WNDPROC));
      SetWindowLong(FComboBoxHandle, GWL_WNDPROC, IntPtr(FComboBoxInstance));
    end;
  end;
end;

end.
