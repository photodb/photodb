unit uMainMenuStyleHook;

interface

uses
  Windows,
  Graphics,
  Classes,
  Controls,
  VCL.ComCtrls,
  Menus,
  Themes;

type
  TMainMenuStyleHook = class(TObject)
  private
    procedure HookMenu(MenuItem: TMenuItem);
    procedure AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; State: TOwnerDrawState);
    procedure MenuChanged(Sender: TObject; Source: TMenuItem;
      Rebuild: Boolean);
  public
    class procedure RegisterMenu(Menu: TMainMenu);
  end;

implementation

var
  FMainMenuStyleHook: TMainMenuStyleHook = nil;

{ TMainMenuStyleHook }

procedure TMainMenuStyleHook.AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; State: TOwnerDrawState);
var
  Details: TThemedElementDetails;
  CheckBox: TThemedButton;
  MI: TMenuItem;
  Menu: TMenu;
begin
  MI := TMenuItem(Sender);

  if odSelected in State then
  begin
    ACanvas.Brush.Color := StyleServices.GetStyleColor(scButtonFocused);
    ACanvas.Pen.Color := StyleServices.GetStyleColor(scButtonFocused);
  end else
  begin
    ACanvas.Brush.Color := StyleServices.GetStyleColor(scButtonNormal);
    ACanvas.Pen.Color := StyleServices.GetStyleColor(scButtonNormal);
  end;
  ACanvas.Rectangle(ARect);

  if MI.Caption = '-' then
  begin
    Details := StyleServices.GetElementDetails(tmPopupSeparator);
    StyleServices.DrawElement(ACanvas.Handle, Details, Rect(ARect.Left + 18, ARect.Top, ARect.Right - 3, ARect.Bottom));
    Exit;
  end;

  if MI.ImageIndex <> -1 then
  begin
    Menu := MI.GetParentMenu;
    if (Menu <> nil) and (Menu.Images <> nil) then
      Menu.Images.Draw(ACanvas, ARect.Left + 1, ARect.Top + 1, MI.ImageIndex, MI.Enabled);

  end else
  begin
    if odChecked in State then
    begin
      if not MI.RadioItem then
      begin
        if odSelected in State then
          CheckBox := tbCheckBoxCheckedHot
        else
          CheckBox := tbCheckBoxCheckedNormal;
      end else
      begin
        if odSelected in State then
          CheckBox := tbRadioButtonCheckedHot
        else
          CheckBox := tbRadioButtonCheckedNormal;
      end;

      Details := StyleServices.GetElementDetails(CheckBox);
      StyleServices.DrawElement(ACanvas.Handle, Details, Rect(ARect.Left + 2, ARect.Top + 2, ARect.Left + 18, ARect.Top + 18))
    end;
  end;

  if odSelected in State then
    ACanvas.Font.Color := StyleServices.GetStyleFontColor(sfPopupMenuItemTextSelected)
  else
    ACanvas.Font.Color := StyleServices.GetStyleFontColor(sfPopupMenuItemTextNormal);

  if odDefault in State then
    ACanvas.Font.Style := ACanvas.Font.Style + [fsBold]
  else
    ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
  ACanvas.Brush.Style := bsClear;
  ARect.Left := ARect.Left + 16 + 4;
  DrawText(ACanvas.Handle, TMenuItem(Sender).Caption, Length(TMenuItem(Sender).Caption), ARect, DT_SINGLELINE or DT_VCENTER );
end;

procedure TMainMenuStyleHook.HookMenu(MenuItem: TMenuItem);
var
  I: Integer;
begin
  if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
  begin
    MenuItem.OnAdvancedDrawItem := AdvancedDrawItem;
    for I := 0 to MenuItem.Count - 1 do
      HookMenu(MenuItem.Items[I]);
  end;
end;

procedure TMainMenuStyleHook.MenuChanged(Sender: TObject; Source: TMenuItem;
  Rebuild: Boolean);
begin
  HookMenu(TMainMenu(Sender).Items);
end;

class procedure TMainMenuStyleHook.RegisterMenu(Menu: TMainMenu);
begin
  if FMainMenuStyleHook = nil then
    FMainMenuStyleHook := TMainMenuStyleHook.Create;

  Menu.OwnerDraw := True;
  FMainMenuStyleHook.HookMenu(Menu.Items);
  Menu.OnChange := FMainMenuStyleHook.MenuChanged;
end;

initialization

finalization
  if FMainMenuStyleHook <> nil then
    FMainMenuStyleHook.Free;

end.

