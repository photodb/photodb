unit uVCLHelpers;

interface

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.Themes,
  Vcl.ActnPopup,
  Vcl.StdCtrls,
  Vcl.ImgList,

  Dmitry.Utils.Files,

  uRuntime,
  uMemory,
  uConstants,
  uLogger,
  uSettings,
  uConfiguration;

type
  TTimerHelper = class helper for TTimer
  public
    procedure Restart;
  end;

type
  TButtonHelper = class helper for TButton
  public
    procedure AdjustButtonWidth;
    procedure SetEnabledEx(Value: Boolean);
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
    procedure AdjustWidth;
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
    function FindChildByTag<T: TControl>(Tag: NativeInt): T;
    function FindChildByType<T: TControl>: T;
    function HasHandle(Handle: THandle): Boolean;
    property BoundsRectScreen: TRect read GetBoundsRectScreen;
  end;

  TControlHelper = class helper for TControl
    function AfterTop(Padding: Integer): Integer;
    function AfterRight(Padding: Integer): Integer;
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

procedure TTimerHelper.Restart;
begin
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

procedure TCheckBoxHelper.AdjustWidth;
var
  TextSize: TSize;
  ADC: HDC;
begin
  aDC := GetDC(Handle);
  try
    SelectObject(ADC, Font.Handle);
    GetTextExtentPoint32(ADC, PChar(Caption), Length(Caption), TextSize);
    Width := TextSize.Cx + GetSystemMetrics(SM_CXMENUCHECK) + GetSystemMetrics(SM_CXEDGE) * 2;
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
begin
  //XE2 crahed here
  //TODO: remove method
  Self.Default := Value;
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
begin
  Result := True;
  FileName := GetAppDataDirectoryFromSettings + CommonCacheDirectory + CacheFileName + '.imlist';
  FS := nil;
  try
    try
      FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
      TCustomImageListEx(Self).ReadData(FS);
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

end.
