unit uVCLHelpers;

interface

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Dwmapi,
  Winapi.Commctrl,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.Themes,
  Vcl.ActnPopup,
  Vcl.StdCtrls,
  Vcl.ImgList,
  Vcl.ComCtrls,

  Dmitry.Utils.Files,

  uRuntime,
  uMemory,
  uConstants,
  uLogger,
  uIDBForm,
  uSettings,
  uConfiguration;

type
  TTimerHelper = class helper for TTimer
  public
    procedure Restart(NewInterval: Integer = 0);
  end;

type
  TButtonHelper = class helper for TButton
  public
    procedure AdjustButtonWidth;
    procedure SetEnabledEx(Value: Boolean);
    procedure AdjustButtonHeight;
  end;

type
  TComboBoxHelper = class helper for TComboBox
  private
    function GetValue: string;
    procedure SetValue(const Value: string);
  public
    property Value: string read GetValue write SetValue;
  end;

type
  TCheckBoxHelper = class helper for TCheckBox
  public
    procedure AdjustWidth(AdditionalWidth: Integer = 0);
  end;

type
  TMenuItemHelper = class helper for TMenuItem
  public
    procedure ExSetDefault(Value: Boolean);
    function ExGetDefault: Boolean;
  end;

type
  TPopupActionBarHelper = class helper for TPopupActionBar
  public
    procedure DoPopupEx(X, Y: Integer);
  end;

  TWinControlHelper = class helper for TWinControl
  private
    function GetBoundsRectScreen: TRect;
  public
    function FindChildByName<T: TControl>(Name: string): T;
    function FindChildByTag<T: TControl>(Tag: NativeInt): T;
    function FindChildByType<T: TControl>: T;
    function HasHandle(Handle: THandle): Boolean;
    property BoundsRectScreen: TRect read GetBoundsRectScreen;
  end;

  TControlHelper = class helper for TControl
    function AfterTop(Padding: Integer): Integer;
    function AfterRight(Padding: Integer): Integer;
    procedure BeforeLeft(Control: TControl; Padding: Integer);
    procedure BeforeRight(Control: TControl);
    function FormBounds: TRect;
    function ScreenBelow: TPoint;
    function OwnerForm: TForm;
  end;

  TCustomImageListHelper = class helper for TCustomImageList
  public
    function LoadFromCache(CacheFileName: string): Boolean;
    procedure SaveToCache(CacheFileName: string);
  end;

  TPictureHelper = class helper for TPicture
  public
    procedure SetGraphicEx(Value: TGraphic);
  end;

type
  TPictureX = class(TInterfacedPersistent, IStreamPersist)
  private
    FGraphic: TGraphic;
  public
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
  end;

  TListBoxHelper = class helper for TListBox
  private
    function GetSelectedIndex: Integer;
  public
    property SelectedIndex: Integer read GetSelectedIndex;
  end;

  TToolBarHelper = class helper for TToolBar
  public
    procedure DisableToolBarForButtons;
    procedure EnableToolBarForButtons;
  end;

  TStatusBarHelper = class helper for TStatusBar
    function CreateProgressBar(Index: Integer): TProgressBar;
  end;

  TScreenHelper = class helper for TScreen
    function ActiveFormHandle: THandle;
    function CurrentImageFileName: string;
  end;

type
  TNotifyEventRef = reference to procedure(Sender: TObject);
  TKeyEventRef = reference to procedure(Sender: TObject; var Key: Word; Shift: TShiftState);
  TMessageEventRef = reference to procedure(var Msg: TMsg; var Handled: Boolean);

function MakeNotifyEvent(const ANotifyRef: TNotifyEventRef): TNotifyEvent;
function MakeKeyEvent(const ANotifyRef: TKeyEventRef): TKeyEvent;
function MakMessageEvent(const ANotifyRef: TMessageEventRef): TMessageEvent;
function IsPopupMenuActive: Boolean;

implementation

function IsPopupMenuActive: Boolean;
begin
  //todo: review functionality if possible
  Result := BlockClosingOfWindows;
end;

procedure MethRefToMethPtr(const MethRef; var MethPtr);
type
  TVtable = array[0..3] of Pointer;
  PVtable = ^TVtable;
  PPVtable = ^PVtable;
begin
  // 3 is offset of Invoke, after QI, AddRef, Release
  TMethod(MethPtr).Code := PPVtable(MethRef)^^[3];
  TMethod(MethPtr).Data := Pointer(MethRef);
end;

function MakeNotifyEvent(const ANotifyRef: TNotifyEventRef): TNotifyEvent;
begin
  MethRefToMethPtr(ANotifyRef, Result);
end;

function MakeKeyEvent(const ANotifyRef: TKeyEventRef): TKeyEvent;
begin
  MethRefToMethPtr(ANotifyRef, Result);
end;

function MakMessageEvent(const ANotifyRef: TMessageEventRef): TMessageEvent;
begin
  MethRefToMethPtr(ANotifyRef, Result);
end;

type
  TCustomButtonEx = class(TButton);

procedure TButtonHelper.AdjustButtonHeight;
const
  PaddingLeft = 40;
  PaddingTop = 15;

var
  DrawRect: TRect;
  TextRect: TRect;
  Surface: TBitmap;
  ACanvas: TCanvas;
  DrawOptions,
  CaptionHeight: Integer;

begin
  DrawRect := Self.ClientRect;
  Surface := TBitmap.Create;
  try
    ACanvas := Surface.Canvas;

    DrawRect := Rect(0, 0, 0, 0);
    if (GetWindowLong(Self.Handle, GWL_STYLE) and BS_COMMANDLINK) = BS_COMMANDLINK then
    begin
      TextRect := Self.ClientRect;
      Dec(TextRect.Right, PaddingLeft + 15);
      Dec(TextRect.Bottom, PaddingTop + 15);
      TextRect.Bottom := MaxInt;

      ACanvas.Font := TCustomButtonEx(Self).Font;
      ACanvas.Font.Style := [];
      ACanvas.Font.Size := 12;
      DrawText(ACanvas.Handle, PChar(Self.Caption), Length(Self.Caption), TextRect, DT_LEFT or DT_SINGLELINE or DT_CALCRECT);

      CaptionHeight := TextRect.Height + 2;

      OffsetRect(TextRect, PaddingLeft, PaddingTop);
      UnionRect(DrawRect, DrawRect, TextRect);

      ACanvas.Font.Size := 8;
      TextRect := Self.ClientRect;
      Dec(TextRect.Right, PaddingLeft);
      Dec(TextRect.Bottom, PaddingTop);
      TextRect.Bottom := MaxInt;
      DrawText(ACanvas.Handle, PChar(Self.CommandLinkHint), Length(Self.CommandLinkHint), TextRect, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
      OffsetRect(TextRect, PaddingLeft, PaddingTop + CaptionHeight);

      UnionRect(DrawRect, DrawRect, TextRect);

      Self.SetBounds(Self.Left, Self.Top, Self.Width, DrawRect.Height + PaddingTop + 15);
    end else
    begin
      TextRect := Self.ClientRect;
      DrawOptions := DT_LEFT or DT_CALCRECT;

      if TCustomButtonEx(Self).WordWrap then
        DrawOptions := DrawOptions or DT_WORDBREAK;

      DrawText(ACanvas.Handle, PChar(Self.Caption), Length(Self.Caption), TextRect, DrawOptions);

      Self.SetBounds(Self.Left, Self.Top, Self.Width, TextRect.Height + 10);
    end;

  finally
    Surface.Free;
  end;
end;

procedure TButtonHelper.AdjustButtonWidth;
var
  TextSize: TSize;
  ADC: HDC;
begin
  aDC := GetDC(Handle);
  try
    SelectObject(ADC, Font.Handle);
    GetTextExtentPoint32(ADC, PChar(Caption), Length(Caption), TextSize);
    Width := TextSize.Cx + 10;
  finally
    ReleaseDc(Handle, ADC);
  end;
end;

{ TTimerHelper }

procedure TTimerHelper.Restart(NewInterval: Integer = 0);
begin
  if NewInterval <> 0 then
    Interval := NewInterval;
  Enabled := False;
  Enabled := True;
end;

{ TComboBoxHelper }

function TComboBoxHelper.GetValue: string;
begin
  Result := '';
  if ItemIndex > -1 then
    Result := Items[ItemIndex];
end;

procedure TComboBoxHelper.SetValue(const Value: string);
var
  I: Integer;
begin
  if Items.Count > 0 then
    ItemIndex := 0;
  for I := 0 to Items.Count - 1 do
    if Items[I] = Value then
    begin
      ItemIndex := I;
      Break;
    end;
end;

{ TCheckBoxHelper }

procedure TCheckBoxHelper.AdjustWidth(AdditionalWidth: Integer = 0);
var
  TextSize: TSize;
  ADC: HDC;
begin
  aDC := GetDC(Handle);
  try
    SelectObject(ADC, Font.Handle);
    GetTextExtentPoint32(ADC, PChar(Caption), Length(Caption), TextSize);
    Width := TextSize.Cx + GetSystemMetrics(SM_CXMENUCHECK) + GetSystemMetrics(SM_CXEDGE) * 2 + AdditionalWidth;
  finally
    ReleaseDc(Handle, ADC);
  end;
end;

{ TMenuItemHelper }

function TMenuItemHelper.ExGetDefault: Boolean;
begin
  if TStyleManager.Enabled and TStyleManager.IsCustomStyleActive then
    Result := Checked
  else
    Result := Default;
end;

procedure TMenuItemHelper.ExSetDefault(Value: Boolean);
var
  I: Integer;

  function IsStyledItem: Boolean;
  begin
    Result := TStyleManager.Enabled;

    if GetParentMenu is TMainMenu then
      Result := False;

    if (Owner is TMenuItem) then
      if (Owner as TMenuItem).GetParentMenu is TMainMenu then
        Result := False;
  end;

begin
  if not Value then
  begin
    if IsStyledItem then
      Self.Checked := False
    else
      Self.Default := False;

    Exit;
  end;
  if IsStyledItem then
  begin
    Self.Checked := True;
    if Parent <> nil then
    begin
      for I := 0 to Parent.Count - 1 do
      begin
        if Parent.Items[I] <> Self then
          Parent.Items[I].Checked := False;
      end;
    end;
  end else
  begin
    Self.Default := True;
  end;
end;

{ TPopupActionBarHelper }

procedure TPopupActionBarHelper.DoPopupEx(X, Y: Integer);
begin
  BlockClosingOfWindows := True;
  try
    Popup(X, Y);
  finally
    BlockClosingOfWindows := False;
  end;
end;

{ TWinControlHelper }

function TWinControlHelper.FindChildByName<T>(Name: string): T;
var
  I: Integer;
begin
  Result := default(T);
  for I := 0 to ControlCount - 1 do
  begin
    if Controls[I].Name = Name then
    begin
      Result := Controls[I] as T;
      Exit;
    end;
  end;
end;

function TWinControlHelper.FindChildByTag<T>(Tag: NativeInt): T;
var
  I: Integer;
begin
  Result := default(T);
  for I := 0 to ControlCount - 1 do
  begin
    if Controls[I].Tag = Tag then
    begin
      Result := Controls[I] as T;
      Exit;
    end;
  end;
end;

function TWinControlHelper.FindChildByType<T>: T;
var
  I: Integer;
begin
  Result := default(T);
  for I := 0 to ControlCount - 1 do
  begin
    if Controls[I] is T then
    begin
      Result := Controls[I] as T;
      Exit;
    end;
  end;
end;

function TWinControlHelper.GetBoundsRectScreen: TRect;
var
  P1, P2: TPoint;
begin
  P1 := BoundsRect.TopLeft;
  P2 := BoundsRect.BottomRight;

  P1 := ClientToScreen(P1);
  P2 := ClientToScreen(P2);

  Result := Rect(P1, P2);
end;

function TWinControlHelper.HasHandle(Handle: THandle): Boolean;
var
  Control: TControl;
  I: Integer;
begin
  if Self.Handle = Handle then
    Exit(True);

  for I := 0 to ControlCount - 1 do
  begin
    Control := Controls[I];
    if Control is TWinControl then
      if TWinControl(Control).HasHandle(Handle) then
        Exit(True);
  end;

  Exit(False);
end;

procedure TButtonHelper.SetEnabledEx(Value: Boolean);
begin
  Enabled := Value;
  if not Value then
    Perform(CM_RECREATEWND, 0, 0);
end;

{ TCustomImageListHelper }

type
  TCustomImageListEx = class(TCustomImageList);

function TCustomImageListHelper.LoadFromCache(CacheFileName: string): Boolean;
var
  FileName: string;
  FS: TFileStream;

  procedure ReadData(Stream: TFileStream);
  var
    LAdapter: TStreamAdapter;
  begin
    LAdapter := TStreamAdapter.Create(Stream);
    try
      Handle := ImageList_Read(LAdapter);
    finally
      LAdapter.Free;
    end;

    ImageList_SetImageCount(Handle, ImageList_GetImageCount(Handle));
  end;

begin
  Result := True;
  FileName := GetAppDataDirectoryFromSettings + CommonCacheDirectory + CacheFileName + '.imlist';
  FS := nil;
  try
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
      ReadData(FS);
      //TCustomImageListEx(Self).ReadData(FS);
    except
      on e: Exception do
      begin
        EventLog(e);
        Result := False;
      end;
    end;
  finally
    F(FS);
  end;
end;

procedure TCustomImageListHelper.SaveToCache(CacheFileName: string);
var
  Directory, FileName: string;
  FS: TFileStream;
begin
  Directory := GetAppDataDirectoryFromSettings + CommonCacheDirectory;
  CreateDirA(Directory);
  FileName := Directory + CacheFileName + '.imlist';
  FS := nil;
  try
    try
      FS := TFileStream.Create(FileName, fmCreate);
      TCustomImageListEx(Self).WriteData(FS);
    except
      on e: Exception do
        EventLog(e);
    end;
  finally
    F(FS);
  end;
end;

{ TPictureHelper }

procedure TPictureHelper.SetGraphicEx(Value: TGraphic);
begin
  if TPictureX(Self).FGraphic <> nil then
    TPictureX(Self).FGraphic.Free;

  TPictureX(Self).FGraphic := Value;
end;

{ TPictureX }

procedure TPictureX.LoadFromStream(Stream: TStream);
begin
end;

procedure TPictureX.SaveToStream(Stream: TStream);
begin
end;

{ TListBoxHelper }

function TListBoxHelper.GetSelectedIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Self.Items.Count - 1 do
  begin
    if Self.Selected[I] then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TControlHelper }

function TControlHelper.AfterRight(Padding: Integer): Integer;
begin
  Result := Left + Width + Padding;
end;

function TControlHelper.AfterTop(Padding: Integer): Integer;
begin
  Result := Top + Height + Padding;
end;

procedure TControlHelper.BeforeLeft(Control: TControl; Padding: Integer);
begin
  Left := Control.Left - Width - Padding;
end;

procedure TControlHelper.BeforeRight(Control: TControl);
var
  W: Integer;
begin
  if Control is TForm then
  begin
    W := Control.ClientWidth;
    if (TForm(Control).BorderStyle = bsSingle) and DwmCompositionEnabled then
      W := W - GetSystemMetrics(SM_CXSIZEFRAME);
  end
  else
    W := Control.Width;

  Left := Control.Left + W - Width;
end;

function TControlHelper.FormBounds: TRect;
var
  Control: TControl;
  X, Y: Integer;
begin
  Control := Self;
  X := 0;
  Y := 0;
  while (Control <> nil) and not (Control is TForm) do
  begin
    Inc(X, Control.Left);
    Inc(Y, Control.Top);
    Control := Control.Parent;
  end;
  Result := Rect(X, Y, X + Width, Y + Height);
end;

function TControlHelper.OwnerForm: TForm;
var
  Owner: TComponent;
begin
  Owner := Self.Owner;
  while (Owner.Owner <> nil) and not (Owner is TForm) do
    Owner := Owner.Owner;

  Result := Owner as TForm;
end;

function TControlHelper.ScreenBelow: TPoint;
begin
  Result := Point(Left, BoundsRect.Bottom);
  Result := Parent.ClientToScreen(Result);
end;

{ TToolBarHelper }

type
  TToolBarButtonEx = class(TToolButton);

procedure TToolBarHelper.DisableToolBarForButtons;
var
  I: Integer;
begin
  for I := 0 to Self.ButtonCount - 1 do
    TToolBarButtonEx(Self.Buttons[I]).FToolBar := nil;
end;

procedure TToolBarHelper.EnableToolBarForButtons;
var
  I: Integer;
begin
  for I := 0 to Self.ButtonCount - 1 do
  begin
    TToolBarButtonEx(Self.Buttons[I]).FToolBar := Self;
    Perform(TB_CHANGEBITMAP, Buttons[I].Index, LPARAM(Buttons[I].ImageIndex));
  end;
end;

{ TStatusBarHelper }

function TStatusBarHelper.CreateProgressBar(Index: Integer): TProgressBar;
var
  Findleft: Integer;
  I: Integer;
begin
  Result := TProgressBar.Create(Self);
  Result.Parent := Self;
  Result.Visible := True;
  Result.Top := 2;
  FindLeft := 0;
  for I := 0 to index - 1 do
    FindLeft := FindLeft + Self.Panels[I].Width + 1;
  Result.Left := Findleft;
  Result.Width := Self.Panels[index].Width - 4;
  Result.Height := Self.Height - 2;
end;

{ TScreenHelper }

function TScreenHelper.ActiveFormHandle: THandle;
begin
  if Self.ActiveForm <> nil then
    Result := Self.ActiveForm.Handle
  else
    Result := 0;
end;

function TScreenHelper.CurrentImageFileName: string;
var
  I: Integer;
  Form: IDBForm;
  Source: ICurrentImageSource;
begin
  Result := '';
  for I := 0 to FormCount - 1 do
  begin
    if not Supports(Forms[I], IDBForm, Form) then
      Continue;

    if Form.QueryInterfaceEx(ICurrentImageSource, Source) = S_OK then
    begin
      Result := Source.GetCurrentImageFileName;
      if Result <> '' then
        Break;
     end;
  end;
end;

end.
