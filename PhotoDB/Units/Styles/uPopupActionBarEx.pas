unit uPopupActionBarEx;

interface

uses
  Winapi.Windows,
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  System.Actions,
  Vcl.Graphics,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan,
  Vcl.ActnMenus,
  Vcl.ActnCtrls,
  Vcl.Controls,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.XPActnCtrls,
  Vcl.ThemedActnCtrls,
  Vcl.Forms;

type
  TPlatformDefaultStyleActionBarsEx = class(TPlatformDefaultStyleActionBars)
  public
    function GetControlClass(ActionBar: TCustomActionBar;
      AnItem: TActionClientItem): TCustomActionControlClass; override;
  end;

  TThemedMenuItemEx = class(TThemedMenuItem)
  private
    FPaintRect: TRect;
    procedure DoDrawText(DC: HDC; const Text: string; var Rect: TRect; Flags: Longint);
  protected
    procedure DrawBackground(var PaintRect: TRect); override;
    procedure DrawText(var Rect: TRect; var Flags: Cardinal; Text: string); override;
  end;

implementation

uses
  Vcl.ListActns,
  Vcl.Themes,
  Vcl.StdActnMenus;

var
  PlatformDefaultStyleOld: TPlatformDefaultStyleActionBars;

{ TMenuAction }

type
  TActionControlStyle = (csStandard, csXPStyle, csThemed);

function GetActionControlStyle: TActionControlStyle;
begin
  if TStyleManager.IsCustomStyleActive then
    Result := csThemed
  else if TOSVersion.Check(6) then
  begin
    if StyleServices.Theme[teMenu] <> 0 then
      Result := csThemed
    else
      Result := csXPStyle;
  end
  else if TOSVersion.Check(5, 1) then
    Result := csXPStyle
  else
    Result := csStandard;
end;

{ TPlatformDefaultStyleActionBarsEx }

function TPlatformDefaultStyleActionBarsEx.GetControlClass(
  ActionBar: TCustomActionBar;
  AnItem: TActionClientItem): TCustomActionControlClass;
begin
  if ActionBar is TCustomActionToolBar then
  begin
    if AnItem.HasItems then
      case GetActionControlStyle of
        csStandard: Result := TStandardDropDownButton;
        csXPStyle: Result := TXPStyleDropDownBtn;
      else
        Result := TThemedDropDownButton;
      end
    else
      if (AnItem.Action is TStaticListAction) or
         (AnItem.Action is TVirtualListAction) then
        Result := TCustomComboControl
      else
        case GetActionControlStyle of
          csStandard: Result := TStandardButtonControl;
          csXPStyle: Result := TXPStyleButton;
        else
          Result := TThemedButtonControl;
        end
  end
  else if ActionBar is TCustomActionMainMenuBar then
    case GetActionControlStyle of
      csStandard: Result := TStandardMenuButton;
      csXPStyle: Result := TXPStyleMenuButton;
    else
      Result := TThemedMenuButton;
    end
  else if ActionBar is TCustomizeActionToolBar then
  begin
    with TCustomizeActionToolbar(ActionBar) do
      if not Assigned(RootMenu) or
         (AnItem.ParentItem <> TCustomizeActionToolBar(RootMenu).AdditionalItem) then
        case GetActionControlStyle of
          csStandard: Result := TStandardMenuItem;
          csXPStyle: Result := TXPStyleMenuItem;
        else
          Result := TThemedMenuItem;
        end
      else
        case GetActionControlStyle of
          csStandard: Result := TStandardAddRemoveItem;
          csXPStyle: Result := TXPStyleAddRemoveItem;
        else
          Result := TThemedAddRemoveItem;
        end
  end
  else if ActionBar is TCustomActionPopupMenu then
    case GetActionControlStyle of
      csStandard: Result := TStandardMenuItem;
      csXPStyle: Result := TXPStyleMenuItem;
    else
      Result := TThemedMenuItemEx;
    end
  else
    case GetActionControlStyle of
      csStandard: Result := TStandardButtonControl;
      csXPStyle: Result := TXPStyleButton;
    else
      Result := TThemedButtonControl;
    end
end;

{ TThemedMenuItemEx }

// Get font from DC to Canvas method
function GetFontFromDC(ADC: HDC): TGDIHandleRecall;
var
  OldFontHandle: HFont;
  LogFont: TLogFont;
begin
  Result := TGDIHandleRecall.Create(ADC, OBJ_FONT);
  OldFontHandle := SelectObject(ADC, Result.Canvas.Font.Handle);
  FillChar(LogFont, SizeOf(LogFont), 0);
  GetObject(OldFontHandle, SizeOf(LogFont), @LogFont);
  Result.Canvas.Font.Handle := CreateFontIndirect(LogFont);
end;

procedure TThemedMenuItemEx.DoDrawText(DC: HDC; const Text: string;
  var Rect: TRect; Flags: Integer);
const
  MenuStates: array[Boolean] of TThemedMenu = (tmPopupItemDisabled, tmPopupItemNormal);
const
  CFlags: array[TTextFormats] of Cardinal = (
    DT_BOTTOM, DT_CALCRECT, DT_CENTER, DT_EDITCONTROL, DT_END_ELLIPSIS,
    DT_PATH_ELLIPSIS, DT_EXPANDTABS, DT_EXTERNALLEADING, DT_LEFT,
    DT_MODIFYSTRING, DT_NOCLIP, DT_NOPREFIX, DT_RIGHT, DT_RTLREADING,
    DT_SINGLELINE, DT_TOP, DT_VCENTER, DT_WORDBREAK, DT_HIDEPREFIX,
    DT_NOFULLWIDTHCHARBREAK, DT_PREFIXONLY, DT_TABSTOP, DT_WORD_ELLIPSIS,
    MASK_TF_COMPOSITED {tfComposited});
var
  LDrawTextFlag: TTextFormats;

  LCaption: string;
  LFormats: TTextFormat;
  LColor: TColor;
  LDetails: TThemedElementDetails;
  DrawFlags: Cardinal;
  Canvas: TCanvas;
  LFontRecall: TGDIHandleRecall;

begin
  // get format and color
  LFormats := TTextFormatFlags(Flags);
  if Selected and Enabled then
    LDetails := StyleServices.GetElementDetails(tmPopupItemHot)
  else
    LDetails := StyleServices.GetElementDetails(MenuStates[Enabled or ActionBar.DesignMode]);

  if not StyleServices.GetElementColor(LDetails, ecTextColor, LColor) or (LColor = clNone) then
    LColor := ActionBar.ColorMap.FontColor;

  // tweak text
  LCaption := Text;
  if (tfCalcRect in LFormats) and ( (LCaption = '') or (LCaption[1] = cHotkeyPrefix) and (LCaption[2] = #0) ) then
    LCaption := LCaption + ' ';

  LFormats := LFormats - [tfCenter];
  DrawFlags := 0;
  for LDrawTextFlag := Low(TTextFormats) to High(TTextFormats) do
    if (LDrawTextFlag in LFormats) then
      DrawFlags := DrawFlags or CFlags[LDrawTextFlag];

  Canvas := TCanvas.Create;
  try
    Canvas.Handle := DC;
    // Draw menu item text
    SetBkMode(DC, Winapi.Windows.TRANSPARENT);
    LFontRecall := TGDIHandleRecall.Create(DC, OBJ_FONT);
    try
      LFontRecall.Canvas.Font.Color := LColor;
      if Self.ActionClient.Default then
        LFontRecall.Canvas.Font.Style := [fsBold];
      SetBkMode(LFontRecall.Canvas.Handle, Winapi.Windows.TRANSPARENT);
      Winapi.Windows.DrawText(LFontRecall.Canvas.Handle, LCaption, Length(LCaption), Rect, DrawFlags);
    finally
      LFontRecall.Free;
    end;
  finally
    Canvas.Free;
  end;
end;

procedure TThemedMenuItemEx.DrawBackground(var PaintRect: TRect);
begin
  FPaintRect := PaintRect;
  inherited;
end;

procedure TThemedMenuItemEx.DrawText(var Rect: TRect; var Flags: Cardinal;
  Text: string);
var
  LRect: TRect;
begin
  // Draw menu highlight
  if Selected and Enabled then
    StyleServices.DrawElement(Canvas.Handle, StyleServices.GetElementDetails(tmPopupItemHot), FPaintRect)
  else if Selected then
    StyleServices.DrawElement(Canvas.Handle, StyleServices.GetElementDetails(tmPopupItemDisabledHot), FPaintRect);

  // Draw menu item text
  if (Parent is TCustomActionBar) and (not ActionBar.PersistentHotkeys) then
    Text := FNoPrefix;
  Canvas.Font := Screen.MenuFont;
  if ActionClient.Default then
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
  LRect := FPaintRect;
  DoDrawText(Canvas.Handle, Text, LRect, Flags or DT_CALCRECT or DT_NOCLIP);
  OffsetRect(LRect, Rect.Left,
    ((FPaintRect.Bottom - FPaintRect.Top) - (LRect.Bottom - LRect.Top)) div 2);
  //LRect.Left := 5;
  DoDrawText(Canvas.Handle, Text, LRect, Flags);

  // Draw shortcut
  if ShowShortCut and ((ActionClient <> nil) and not ActionClient.HasItems) then
  begin
    Flags := DrawTextBiDiModeFlags(DT_RIGHT);
    LRect := TRect.Create(ShortCutBounds.Left, LRect.Top, ShortCutBounds.Right, LRect.Bottom);
    LRect.Offset(Width, 0);
    DoDrawText(Canvas.Handle, ActionClient.ShortCutText, LRect, Flags);
  end;
end;

initialization
  PlatformDefaultStyleOld := PlatformDefaultStyle;
  UnregisterActnBarStyle(PlatformDefaultStyleOld);

  PlatformDefaultStyle := TPlatformDefaultStyleActionBarsEx.Create;
  DefaultActnBarStyle := PlatformDefaultStyle.GetStyleName;
  RegisterActnBarStyle(PlatformDefaultStyle);

finalization
  UnregisterActnBarStyle(PlatformDefaultStyle);
  PlatformDefaultStyle.Free;
  PlatformDefaultStyle := PlatformDefaultStyleOld;
  RegisterActnBarStyle(PlatformDefaultStyleOld);

end.
