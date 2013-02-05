unit uDBForm;

interface

uses
  Generics.Collections,
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.SyncObjs,
  System.Classes,
  Winapi.Windows,
  Winapi.CommCtrl,
  Winapi.DwmApi,
  Winapi.MultiMon,
  Winapi.Messages,
  Winapi.ActiveX,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Menus,

  Dmitry.Utils.System,

  uMemory,
  uGOM,
  {$IFNDEF EXTERNAL}
  uTranslate,
  {$ENDIF}
  uVistaFuncs,
  {$IFDEF PHOTODB}
  uFastLoad,
  uMainMenuStyleHook,
  {$ENDIF}
  uThemesUtils,
  uImageSource;

{$R-}

type
  TDBForm = class;

  TFormStyleHookEx = class(TFormStyleHook)
  strict private type
    {$REGION 'TMainMenuBarStyleHook'}
    TMainMenuBarStyleHook = class
    strict private type
      TMenuBarButton = record
        Index: Integer;
        State: TThemedWindow;
        ItemRect: TRect;
      end;
    public type
      TMenuBarItem = record
        Index: Integer;
        State: TThemedMenu;
        MenuItem: TMenuItem;
        ItemRect: TRect;
      end;
    strict private
      class var FCurrentMenuItem: TMenuItem;
      class var FMenuBarHook: TMainMenuBarStyleHook;
      class function PopupMenuHook(Code: Integer; WParam: WPARAM; var Msg: TMsg): LRESULT; stdcall; static;
    strict private
      FActiveItem: Integer;
      FBoundsRect: TRect;
      FEnterWithKeyboard: Boolean;
      FFormHook: TFormStyleHookEx;
      FIcon: TIcon;
      FIconHandle: HICON;
      FInMenuLoop: Boolean;
      FItemCount: Integer;
      FItems: array of TMenuBarItem;
      FHotMDIButton, FOldMDIHotButton: Integer;
      FMDIButtons: array[0..2] of TMenuBarButton;
      FMDIChildSysMenuActive: Boolean;
      FMDIChildSystemMenuTracking: Boolean;
      FMenuActive: Boolean;
      FMenuHook: HHOOK;
      FMenuPush: Boolean;
      FMouseInMainMenu: Boolean;
      FMustActivateMDIChildSysMenu: Boolean;
      FMustActivateMenuItem: Boolean;
      FMustActivateSysMenu: Boolean;
      FOldActiveItem: Integer;
      FOldCursorPos: TPoint;
      FPressedMDIButton: Integer;
      FSelectFirstItem: Boolean;
      FShowMDIButtons: Boolean;
      FSysMenuActive: Boolean;
      FSystemMenuTracking: Boolean;
      function CanFindPriorItem(AMenuItem: TMenuItem): Boolean;
      function CanFindNextItem(AMenuItem: TMenuItem): Boolean;
      function CanTrackMDISystemMenu: Boolean;
      function CanTrackSystemMenu: Boolean;
      procedure DrawItem(AItem: TMenuBarItem; ACanvas: TCanvas);
      function FindFirstMenuItem(AUpdateMenu: Boolean): Integer;
      function FindFirstRightMenuItem(AUpdateMenu: Boolean): Integer;
      function FindHotKeyItem(CharCode: Integer; AUpdateMenu: Boolean): Integer;
      function FindItem(Value: NativeUInt; Kind: TFindItemKind): TMenuItem;
      function FindNextMenuItem(AUpdateMenu: Boolean): Integer;
      function FindPriorMenuItem(AUpdateMenu: Boolean): Integer;
      function GetIcon: TIcon;
      function GetIconFast: TIcon;
      function GetMenuItemWidth(AMenuItem: TMenuItem; ACanvas: TCanvas): Integer;
      function GetTrackMenuPos(AItem: TMenuBarItem): TPoint;
      procedure HookMenus;
      function IsSubMenuItem(AMenuItem: TMenuItem): Boolean;
      function ItemFromCursorPos: Integer;
      function ItemFromPoint(X, Y: Integer): Integer;
      function MainMenu: TMainMenu;
      procedure MenuExit;
      function MDIButtonFromPoint(X, Y: Integer): Integer;
      procedure MDIChildClose;
      procedure MDIChildMinimize;
      procedure MDIChildRestore;
      procedure SetBoundsRect(const ABoundsRect: TRect);
      procedure SetShowMDIButtons(Value: Boolean);
      procedure TrackMenuFromItem;
      procedure UnHookMenus;
    public
      constructor Create(FormHook: TFormStyleHookEx);
      destructor Destroy; override;
      function CheckHotKeyItem(ACharCode: Word): Boolean;
      function GetMenuHeight(AWidth: Integer): Integer;
      procedure Invalidate;
      procedure MenuEnter(ATrackMenu: Boolean);
      procedure MouseDown(X, Y: Integer);
      procedure MouseMove(X, Y: Integer);
      procedure MouseUp(X, Y: Integer);
      procedure Paint(Canvas: TCanvas);
      procedure ProcessMenuLoop(ATrackMenu: Boolean);
      procedure TrackSystemMenu;
      procedure TrackMDIChildSystemMenu;
      property BoundsRect: TRect read FBoundsRect write SetBoundsRect;
      property InMenuLoop: Boolean read FInMenuLoop write FInMenuLoop;
      property EnterWithKeyboard: Boolean read FEnterWithKeyboard write FEnterWithKeyboard;
      property MenuActive: Boolean read FMenuActive write FMenuActive;
      property MustActivateMDIChildSysMenu: Boolean read FMustActivateMDIChildSysMenu write FMustActivateMDIChildSysMenu;
      property MustActivateSysMenu: Boolean read FMustActivateSysMenu write FMustActivateSysMenu;
      property MustActivateMenuItem: Boolean read FMustActivateMenuItem write FMustActivateMenuItem;
      property ShowMDIButtons: Boolean read FShowMDIButtons write SetShowMDIButtons;
      property MouseInMainMenu: Boolean read FMouseInMainMenu;
    end;
    {$ENDREGION}
  strict private const
    WM_NCUAHDRAWCAPTION = $00AE;
  strict private
    FCaptionRect: TRect;
    FChangeSizeCalled: Boolean;
    FChangeVisibleChildHandle: HWND;
    FCloseButtonRect: TRect;
    FFormActive: Boolean;
    FHotButton: Integer;
    FHeight: Integer;
    FHelpButtonRect: TRect;
    FIcon: TIcon;
    FIconHandle: HICON;
    FMainMenuBarHook: TMainMenuBarStyleHook;
    FMaxButtonRect: TRect;
    FMDIClientInstance: Pointer;
    FMDIHorzScrollBar: TWinControl; { TScrollBar }
    FMDIPrevClientProc: Pointer;
    FMDIScrollSizeBox: TWinControl;
    FMDIStopHorzScrollBar: Boolean;
    FMDIStopVertScrollBar: Boolean;
    FMDIVertScrollBar: TWinControl; { TScrollBar }
    FMinButtonRect: TRect;
    FLeft: Integer;
    FNeedsUpdate: Boolean;
    FOldHorzSrollBarPosition: Integer;
    FOldVertSrollBarPosition: Integer;
    FPressedButton: Integer;
    FRegion: HRGN;
    FStopCheckChildMove: Boolean;
    FSysMenuButtonRect: TRect;
    FTop: Integer;
    FWidth: Integer;
    FCaptionEmulation: Boolean;
    procedure AdjustMDIScrollBars;
    procedure ChangeSize;
    function IsStyleBorder: Boolean;
    function GetBorderSize: TRect;
    function GetForm: TDBForm; inline;
    function GetIconFast: TIcon;
    function GetIcon: TIcon;
    function GetHitTest(P: TPoint): Integer;
    procedure GetMDIScrollInfo(SetRange: Boolean);
    function GetMDIWorkArea: TRect;
    function GetRegion: HRgn;
    procedure InitMDIScrollBars;
    function MDIChildMaximized: Boolean;
    procedure MDIHorzScroll(Offset: Integer);
    procedure MDIVertScroll(Offset: Integer);
    function NormalizePoint(P: TPoint): TPoint;
    procedure UpdateForm;
    procedure OnMDIHScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure OnMDIVScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure CMDialogChar(var Message: TWMKey); message CM_DIALOGCHAR;
    procedure CMMenuChanged(var Message: TMessage); message CM_MENUCHANGED;
    procedure WMInitMenu(var Message: TMessage); message WM_INITMENU;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCActivate(var Message: TMessage); message WM_NCACTIVATE;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMSize(var Message: TWMSIZE); message WM_SIZE;
    procedure WMMove(var Message: TWMMOVE); message WM_MOVE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCMouseMove(var Message: TWMNCHitMessage); message WM_NCMOUSEMOVE;
    procedure WMNCLButtonDown(var Message: TWMNCHitMessage); message WM_NCLBUTTONDOWN;
    procedure WMNCRButtonDown(var Message: TWMNCHitMessage); message WM_NCRBUTTONDOWN;
    procedure WMNCLButtonUp(var Message: TWMNCHitMessage); message WM_NCLBUTTONUP;
    procedure WMNCRButtonUp(var Message: TWMNCHitMessage); message WM_NCRBUTTONUP;
    procedure WMNCLButtonDblClk(var Message: TWMNCHitMessage); message WM_NCLBUTTONDBLCLK;
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure WMNCUAHDrawCaption(var Message: TMessage); message WM_NCUAHDRAWCAPTION;
    procedure WMShowWindow(var Message: TWMShowWindow); message WM_SHOWWINDOW;
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WMSetText(var Message: TMessage); message WM_SETTEXT;
    procedure WMMDIChildMove(var Message: TMessage); message WM_MDICHILDMOVE;
    procedure WMMDIChildClose(var Message: TMessage); message WM_MDICHILDCLOSE;
    procedure WMSysCommand(var Message: TMessage); message WM_SYSCOMMAND;
    procedure WMDestroy(var Message: TMessage); message WM_DESTROY;
  strict protected
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure PaintBackground(Canvas: TCanvas); override;
    procedure PaintNC(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
    property Form: TDBForm read GetForm;
  public
    constructor Create(AControl: TWinControl); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    property Handle;
  end;

  TDBForm = class(TForm, IInterface)
  private
    FWindowID: string;
    FWasPaint: Boolean;
    FRefCount: Integer;
    FIsRestoring: Boolean;
    FIsMinimizing: Boolean;
    function GetTheme: TDatabaseTheme;
    function GetFrameWidth: Integer;
  protected
    procedure WndProc(var Message: TMessage); override;
    function GetFormID: string; virtual; abstract;
    procedure DoCreate; override;
    procedure ApplyStyle; virtual;
    procedure ApplySettings; virtual;
    procedure FixLayout; virtual;
    procedure CustomFormAfterDisplay; virtual;

    procedure WMSize(var Message: TWMSize); message WM_SIZE;

    function IInterface.QueryInterface = QueryInterfaceInternal;
    function QueryInterfaceInternal(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure InterfaceDestroyed; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class constructor Create;
    class destructor Destroy;

    procedure Restore;
    function L(StringToTranslate: string): string; overload;
    function L(StringToTranslate: string; Scope: string): string; overload;
    function LF(StringToTranslate: string; Args: array of const): string;
    procedure BeginTranslate;
    procedure EndTranslate;
    procedure FixFormPosition;
    function QueryInterfaceEx(const IID: TGUID; out Obj): HResult;
    property FormID: string read GetFormID;
    property WindowID: string read FWindowID;
    property Theme: TDatabaseTheme read GetTheme;
    property IsRestoring: Boolean read FIsRestoring;
    property IsMinimizing: Boolean read FIsMinimizing;
    property FrameWidth: Integer read GetFrameWidth;
  end;

type
  TFormCollection = class(TObject)
  private
    FSync: TCriticalSection;
    FForms: TList<TDBForm>;
    constructor Create;
    function GetFormByIndex(Index: Integer): TDBForm;
  public
    destructor Destroy; override;
    class function Instance: TFormCollection;
    procedure UnRegisterForm(Form: TDBForm);
    procedure RegisterForm(Form: TDBForm);
    function GetImage(BaseForm: TDBForm; FileName: string; Bitmap: TBitmap; var Width: Integer;
      var Height: Integer): Boolean;
    function GetFormByBounds<T: TDBForm>(BoundsRect: TRect): TDBForm;
    function GetForm(WindowID: string): TDBForm;
    procedure ApplySettings;
    procedure GetForms<T: TDBForm>(Forms: TList<T>);
    function Count: Integer;
    property Forms[Index: Integer]: TDBForm read GetFormByIndex; default;
  end;

type
  TAnchorsArray = TDictionary<TControl, TAnchors>;

implementation

{$IFDEF PHOTODB}
uses
  uFormInterfaces;
{$ENDIF}

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

procedure DisableAnchors(ParentControl: TWinControl; Storage: TAnchorsArray);
var
  I: Integer;
  ChildControl: TControl;
begin
  for I := 0 to ParentControl.ControlCount - 1 do
  begin
    ChildControl := ParentControl.Controls[I];

    Storage.Add(ChildControl, ChildControl.Anchors);

    ChildControl.Anchors := [];
  end;

  //Add children
  for I := 0 to ParentControl.ControlCount - 1 do
  begin
    ChildControl := ParentControl.Controls[I];
    if ChildControl is TWinControl then
       DisableAnchors(TWinControl(ChildControl), Storage);
  end;
end;

procedure EnableAnchors(Storage: TAnchorsArray);
var
  Pair: TPair<TControl, TAnchors>;
begin
  for Pair in Storage do
   Pair.Key.Anchors := Pair.Value;
end;

{ TDBForm }

procedure TDBForm.ApplySettings;
begin
  //Calls after applying new settings and after form create
end;

procedure TDBForm.ApplyStyle;
begin
end;

procedure TDBForm.BeginTranslate;
begin
  {$IFNDEF EXTERNAL}
  TTranslateManager.Instance.BeginTranslate;
  {$ENDIF}
end;

constructor TDBForm.Create(AOwner: TComponent);
begin
  inherited;
  FRefCount := 0;
  FWindowID := GUIDToString(GetGUID);
  TFormCollection.Instance.RegisterForm(Self);
  GOM.AddObj(Self);

  FIsMinimizing := False;
  FIsRestoring := False;
  {$IFDEF PHOTODB}
  {$ENDIF}
end;

class constructor TDBForm.Create;
begin
  if Assigned(TStyleManager.Engine) then
  begin
    TStyleManager.Engine.UnRegisterStyleHook(TCustomForm, TFormStyleHook);
    TStyleManager.Engine.UnRegisterStyleHook(TForm, TFormStyleHook);
    TStyleManager.Engine.RegisterStyleHook(TCustomForm, TFormStyleHookEx);
    TStyleManager.Engine.RegisterStyleHook(TForm, TFormStyleHookEx);    
  end;
end;

procedure TDBForm.CustomFormAfterDisplay;
begin
 //
end;

destructor TDBForm.Destroy;
begin
  {$IFDEF PHOTODB}
  FormInterfaces.RemoveSingleInstance(Self);
  {$ENDIF}
  GOM.RemoveObj(Self);
  TFormCollection.Instance.UnRegisterForm(Self);
  inherited;
end;

class destructor TDBForm.Destroy;
begin
  if Assigned(TStyleManager.Engine) then
  begin
    TStyleManager.Engine.UnRegisterStyleHook(TCustomForm, TFormStyleHookEx);
    TStyleManager.Engine.UnRegisterStyleHook(TForm, TFormStyleHookEx);
    TStyleManager.Engine.RegisterStyleHook(TCustomForm, TFormStyleHook);
    TStyleManager.Engine.RegisterStyleHook(TForm, TFormStyleHook);    
  end;
end;

procedure TDBForm.DoCreate;
begin
  inherited;
  {$IFDEF PHOTODB}
  if Menu is TMainMenu then
    TMainMenuStyleHook.RegisterMenu(TMainMenu(Menu));
  if ClassName <> 'TFormManager' then
    TLoad.Instance.RequiredStyle;
  FixLayout;
  ApplyStyle;
  ApplySettings;
  {$ENDIF}
end;

procedure TDBForm.EndTranslate;
begin
  {$IFNDEF EXTERNAL}
  TTranslateManager.Instance.EndTranslate;
  {$ENDIF}
end;

procedure TDBForm.FixFormPosition;
var
  I: Integer;
  Form: TDBForm;
  X, Y: Integer;
  R: TRect;
  FoundForm: Boolean;

  function BRect(X, Y, Width, Height: Integer): TRect;
  begin
    Result := Rect(X, Y, X + Width, Y + Height);
  end;

  function CalculateFormRect: TRect;
  var
    AppMon, WinMon: HMONITOR;
    I, J: Integer;
    ALeft, ATop: Integer;
    LRect: TRect;
  begin
    Result := BRect(Left, Top, Width, Height);
    if (DefaultMonitor <> dmDesktop) and (Application.MainForm <> nil) then
    begin
      AppMon := 0;
      if DefaultMonitor = dmMainForm then
        AppMon := Application.MainForm.Monitor.Handle
      else if (DefaultMonitor = dmActiveForm) and (Screen.ActiveCustomForm <> nil) then
        AppMon := Screen.ActiveCustomForm.Monitor.Handle
      else if DefaultMonitor = dmPrimary then
        AppMon := Screen.PrimaryMonitor.Handle;
      WinMon := Monitor.Handle;
      for I := 0 to Screen.MonitorCount - 1 do
        if (Screen.Monitors[I].Handle = AppMon) then
          if (AppMon <> WinMon) then
          begin
            for J := 0 to Screen.MonitorCount - 1 do
            begin
              if (Screen.Monitors[J].Handle = WinMon) then
              begin
                if Position = poScreenCenter then
                begin
                  LRect := Screen.Monitors[I].WorkareaRect;
                  Result := BRect(LRect.Left + ((RectWidth(LRect) - Width) div 2),
                    LRect.Top + ((RectHeight(LRect) - Height) div 2), Width, Height);
                end
                else
                if Position = poMainFormCenter then
                begin
                  Result := BRect(Screen.Monitors[I].Left + ((Screen.Monitors[I].Width - Width) div 2),
                    Screen.Monitors[I].Top + ((Screen.Monitors[I].Height - Height) div 2),
                     Width, Height)
                end
                else
                begin
                  ALeft := Screen.Monitors[I].Left + Left - Screen.Monitors[J].Left;
                  if ALeft + Width > Screen.Monitors[I].Left + Screen.Monitors[I].Width then
                    ALeft := Screen.Monitors[I].Left + Screen.Monitors[I].Width - Width;
                  ATop := Screen.Monitors[I].Top + Top - Screen.Monitors[J].Top;
                  if ATop + Height > Screen.Monitors[I].Top + Screen.Monitors[I].Height then
                    ATop := Screen.Monitors[I].Top + Screen.Monitors[I].Height - Height;
                  Result := BRect(ALeft, ATop, Width, Height);
                end;
              end;
            end;
          end else
          begin
            if Position = poScreenCenter then
            begin
              LRect := Screen.Monitors[I].WorkareaRect;
              Result := BRect(LRect.Left + ((RectWidth(LRect) - Width) div 2),
                LRect.Top + ((RectHeight(LRect) - Height) div 2), Width, Height);
            end;
          end;
    end;
  end;


begin
  if Self.WindowState = wsMaximized then
    Exit;

  R := CalculateFormRect;

  while True do
  begin
    FoundForm := False;
    for I := 0 to TFormCollection.Instance.Count - 1 do
    begin
      Form := TFormCollection.Instance[I];
      if (Form.BoundsRect.Left = R.Left) and (Form.BoundsRect.Top = R.Top) and Form.Visible and (Form <> Self) then
      begin
        X := R.Left + 20;
        Y := R.Top + 20;
        if (X + Width < Form.Monitor.BoundsRect.Right) and (Y + Height < Form.Monitor.BoundsRect.Bottom) then
        begin
          Position := poDesigned;
          Left := X;
          Top := Y;
          R.Left := X;
          R.Top := Y;
          FoundForm := True;
        end;
      end;
    end;
    if not FoundForm then
      Break;
  end;

  if Position <> poDesigned then
  begin
    SetBounds(R.Left, R.Top, RectWidth(R), RectHeight(R));
    Position := poDesigned;
  end;
end;

procedure TDBForm.FixLayout;
var
  StoredAnchors: TAnchorsArray;
begin
  if ((BorderStyle = bsSingle) or (BorderStyle = bsToolWindow)) and StyleServices.Enabled then
  begin
    StoredAnchors := TAnchorsArray.Create;
    try
      DisableAlign;
      DisableAnchors(Self, StoredAnchors);
      try
        ClientWidth := ClientWidth + FrameWidth;
      finally
        EnableAnchors(StoredAnchors);
        EnableAlign;
      end;
    finally
      StoredAnchors.Free;
    end;
  end;
end;

function TDBForm.GetFrameWidth: Integer;
var
  Size: TSize;
  Details: TThemedElementDetails;
begin
  Details := StyleServices.GetElementDetails(twFrameLeftActive);
  StyleServices.GetElementSize(0, Details, esActual, Size);

  Result := Size.cx;
end;

function TDBForm.GetTheme: TDatabaseTheme;
begin
  Result := {$IFDEF PHOTODB}uThemesUtils.Theme{$ELSE}nil{$ENDIF};
end;

procedure TDBForm.InterfaceDestroyed;
begin
  //do nothing
end;

function TDBForm.L(StringToTranslate: string; Scope: string): string;
begin
  Result := {$IFDEF EXTERNAL}StringToTranslate{$ELSE}TTranslateManager.Instance.SmartTranslate(StringToTranslate, Scope){$ENDIF};
end;

function TDBForm.LF(StringToTranslate: string; Args: array of const): string;
begin
  Result := FormatEx(L(StringToTranslate), args);
end;

function TDBForm.QueryInterfaceInternal(const IID: TGUID; out Obj): HResult;
begin
  Result := inherited QueryInterface(IID, Obj);
end;

procedure TDBForm.Restore;
begin
  if IsIconic(Handle) then
    ShowWindow(Handle, SW_RESTORE);
end;

function TDBForm.QueryInterfaceEx(const IID: TGUID; out Obj): HResult;
begin
  Result := inherited QueryInterface(IID, Obj);
end;

procedure TDBForm.WMSize(var Message: TWMSize);
begin
  if Message.SizeType = SIZE_RESTORED then
    FIsRestoring := True;
  if Message.SizeType = SIZE_MINIMIZED then
    FIsMinimizing := True;
  try
    inherited;
  finally
    FIsMinimizing := False;
    FIsRestoring := False;
  end;
end;

procedure TDBForm.WndProc(var Message: TMessage);
var
  Canvas: TCanvas;
  LDetails: TThemedElementDetails;
  WindowRect: TRect;
begin
  //when styles enabled and form is visible -> white rectangle in all client rect
  //it causes flicking on black theme if Aero is enabled
  //this is fix for form startup
  if StyleServices.Enabled and not FWasPaint then
  begin
    if (Message.Msg = WM_NCPAINT) and (Win32MajorVersion >= 6) then
    begin
      if DwmCompositionEnabled then
      begin
        Canvas := TCanvas.Create;
        try
          Canvas.Handle := GetWindowDC(Handle);
          LDetails.Element := teWindow;
          LDetails.Part := 0;
          //get window size from API because VCL size not correct at this moment
          GetWindowRect(Handle, WindowRect);
          StyleServices.DrawElement(Canvas.Handle, LDetails, Rect(0, 0, WindowRect.Width, WindowRect.Height));
        finally
          ReleaseDC(Self.Handle, Canvas.Handle);
          F(Canvas);
        end;
        CustomFormAfterDisplay;
      end;
    end;
  end;
  if (Message.Msg = WM_PAINT) and StyleServices.Enabled then
    FWasPaint := True;

  inherited;
end;

function TDBForm._AddRef: Integer;
begin
  inherited _AddRef;
  Result := AtomicIncrement(FRefCount);
end;

function TDBForm._Release: Integer;
begin
  inherited _Release;
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
    InterfaceDestroyed;
end;

function TDBForm.L(StringToTranslate: string): string;
begin
  Result := {$IFDEF EXTERNAL}StringToTranslate{$ELSE}TTranslateManager.Instance.SmartTranslate(StringToTranslate, GetFormID){$ENDIF};
end;

var
  FInstance: TFormCollection = nil;

{ TFormManager }

procedure TFormCollection.ApplySettings;
var
  I: Integer;
begin
  for I := 0 to FForms.Count - 1 do
    FForms[I].ApplySettings;
end;

function TFormCollection.Count: Integer;
begin
  Result := FForms.Count;
end;

constructor TFormCollection.Create;
begin
  FSync := TCriticalSection.Create;
  FForms := TList<TDBForm>.Create;
end;

destructor TFormCollection.Destroy;
begin
  F(FSync);
  F(FForms);
  inherited;
end;

function TFormCollection.GetForm(WindowID: string): TDBForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FForms.Count - 1 do
  begin
    if FForms[I].WindowID = WindowID then
      Result := FForms[I];
  end;
end;

function TFormCollection.GetFormByBounds<T>(BoundsRect: TRect): TDBForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FForms.Count - 1 do
  begin
    if (FForms[I] is T) and EqualRect(FForms[I].BoundsRect, BoundsRect)  then
      Result := TDBForm(FForms[I]);
  end;
end;

function TFormCollection.GetFormByIndex(Index: Integer): TDBForm;
begin
  Result := FForms[Index];
end;

procedure TFormCollection.GetForms<T>(Forms: TList<T>);
var
  I: Integer;
begin
  for I := 0 to FForms.Count - 1 do
  begin
    if FForms[I] is T then
      Forms.Add(FForms[I] as T);
  end;
end;

function TFormCollection.GetImage(BaseForm: TDBForm; FileName: string;
  Bitmap: TBitmap; var Width, Height: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if GOM.IsObj(BaseForm) and Supports(BaseForm, IImageSource) then
    Result := (BaseForm as IImageSource).GetImage(FileName, Bitmap, Width, Height);

  if Result then
    Exit;

  for I := 0 to FForms.Count - 1 do
  begin
    if Supports(FForms[I], IImageSource) then
      Result := (FForms[I] as IImageSource).GetImage(FileName, Bitmap, Width, Height);
    if Result then
      Exit;

  end;
end;

class function TFormCollection.Instance: TFormCollection;
begin
  if FInstance = nil then
    FInstance := TFormCollection.Create;

  Result := FInstance;
end;

procedure TFormCollection.RegisterForm(Form: TDBForm);
begin
  if FForms.IndexOf(Form) > -1 then
    Exit;

  FForms.Add(Form);

  if IsWindowsVista then
  begin
    Form.Updating;
    SetVistaFonts(Form);
    Form.Updated;
  end;
end;

procedure TFormCollection.UnRegisterForm(Form: TDBForm);
begin
  FForms.Remove(Form);
end;

{ TFormStyleHookEx }

function RectVCenter(var R: TRect; Bounds: TRect): TRect;
begin
  OffsetRect(R, -R.Left, -R.Top);
  OffsetRect(R, 0, (Bounds.Height - R.Height) div 2);
  OffsetRect(R, Bounds.Left, Bounds.Top);

  Result := R;
end;


constructor TFormStyleHookEx.TMainMenuBarStyleHook.Create(FormHook: TFormStyleHookEx);
begin
  FFormHook := FormHook;
  FBoundsRect := Rect(0, 0, 0, 0);
  FIcon := nil;
  FItemCount := 0;
  FMenuActive := False;
  FMenuPush := False;
  FActiveItem := -1;
  FOldActiveItem := -1;
  FMouseInMainMenu := False;
  FMenuBarHook := nil;
  FOldCursorPos := Point(-1, -1);
  FEnterWithKeyboard := False;
  FSystemMenuTracking := False;
  FMDIChildSystemMenuTracking := False;
  FShowMDIButtons := False;
  FHotMDIButton := -1;
  FPressedMDIButton := -1;
  FOldMDIHotButton := -1;
  FMustActivateSysMenu := False;
  FMustActivateMenuItem := False;
  FMustActivateMDIChildSysMenu := False;
  FSysMenuActive := False;
  FMDIChildSysMenuActive := False;
end;

destructor TFormStyleHookEx.TMainMenuBarStyleHook.Destroy;
begin
  if FIcon <> nil then
    FreeAndNil(FIcon);
  inherited;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.GetIconFast: TIcon;
begin
  if (FIcon = nil) or (FIconHandle = 0) then
    Result := GetIcon
  else
    Result := FIcon;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.GetIcon: TIcon;
var
  IconX, IconY : Integer;
  TmpHandle: Integer;
  Inst: Cardinal;
  Info: TWndClassEx;
  Handle: HWnd;
  StrBuf: array [0..300] of Char;
begin
  if not CanTrackMDISystemMenu then
  begin
    Result := nil;
    Exit;
  end;

  Handle := FFormHook.Form.ActiveMDIChild.Handle;

  TmpHandle := 0;

  if TmpHandle = 0 then
    TmpHandle := SendMessage(Handle, WM_GETICON, ICON_SMALL, 0);
  if TmpHandle = 0 then
    TmpHandle := SendMessage(Handle, WM_GETICON, ICON_BIG, 0);
  if TmpHandle = 0 then
  begin
    { Get instance }
    GetClassName(Handle, @StrBuf, SizeOf(StrBuf));
    FillChar(Info, SizeOf(Info), 0);
    Info.cbSize := SizeOf(Info);

    Inst := GetWindowLong(Handle, GWL_HINSTANCE);
    if GetClassInfoEx(Inst, @StrBuf, Info) then
    begin
      TmpHandle := Info.hIconSm;
      if TmpHandle = 0 then
        TmpHandle := Info.hIcon;
    end
  end;

  if FIcon = nil then
    FIcon := TIcon.Create;
  if TmpHandle <> 0 then
  begin
    IconX := GetSystemMetrics(SM_CXSMICON);
    if IconX = 0 then
      IconX := GetSystemMetrics(SM_CXSIZE);
    IconY := GetSystemMetrics(SM_CYSMICON);
    if IconY = 0 then
      IconY := GetSystemMetrics(SM_CYSIZE);
    FIcon.Handle := CopyImage(TmpHandle, IMAGE_ICON, IconX, IconY, 0);
    FIconHandle := TmpHandle;
  end;

  Result := FIcon;
end;


function TFormStyleHookEx.TMainMenuBarStyleHook.CanTrackMDISystemMenu: Boolean;
begin
  Result := (FFormHook.Form.FormStyle = fsMDIForm) and
            (FFormHook.Form.ActiveMDIChild <> nil) and
            (biSystemMenu in FFormHook.Form.ActiveMDIChild.BorderIcons);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.CanTrackSystemMenu: Boolean;
begin
  Result := (biSystemMenu in FFormHook.Form.BorderIcons) and
    (FFormHook.Form.BorderStyle <> bsNone);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.SetShowMDIButtons(Value: Boolean);
begin
  if FShowMDIButtons <> Value then
  begin
    FShowMDIButtons := Value;
    FHotMDIButton := -1;
    FPressedMDIButton := -1;
    FOldMDIHotButton := -1;
    if not Value and (FIcon <> nil) then
      FreeAndNil(FIcon);
    Invalidate;
  end;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.IsSubMenuItem(AMenuItem: TMenuItem): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to FItemCount - 1 do
   if AMenuItem.Parent = FItems[I].MenuItem then
     Exit(False);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.CanFindPriorItem(AMenuItem: TMenuItem): Boolean;
begin
  Result := (AMenuItem = nil) or not IsSubMenuItem(AMenuItem);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.CanFindNextItem(AMenuItem: TMenuItem): Boolean;
begin
  Result := (AMenuItem = nil) or (AMenuItem.Count = 0);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.FindItem(Value: NativeUInt; Kind: TFindItemKind): TMenuItem;
begin
  Result := MainMenu.FindItem(Value, Kind);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.MenuEnter;
begin
  HideCaret(0);
  FMDIChildSysMenuActive := False;
  FSysMenuActive := False;
  if not ATrackMenu then
    FindFirstMenuItem(True);
  ProcessMenuLoop(ATrackMenu);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.MenuExit;
begin
  ShowCaret(0);
  FInMenuLoop := False;
  FMenuPush := False;
  FMenuActive := False;
  FEnterWithKeyboard := False;
  FMDIChildSysMenuActive := False;
  FSysMenuActive := False;
  if (FActiveItem <> -1) and
     (WindowFromPoint(Mouse.CursorPos) = FFormHook.Handle) and
     (ItemFromCursorPos <> -1) then
  begin
    FActiveItem := ItemFromCursorPos;
    FOldActiveItem := FActiveItem;
  end
  else
  begin
    FActiveItem := -1;
    FOldActiveItem := -1;
  end;
  Invalidate;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.CheckHotKeyItem(ACharCode: Word): Boolean;
var
  I: Integer;
begin
  Result := False;
  I := FindHotKeyItem(ACharCode, True);
  if (I <> -1) and (FActiveItem = I) then
  begin
    Result := True;
    if FItems[FActiveItem].MenuItem.Count = 0 then
    begin
      MenuExit;
      if FItems[I].MenuItem.GetParentMenu <> nil then
        FItems[I].MenuItem.GetParentMenu.DispatchCommand(FItems[I].MenuItem.Command);
    end
    else
    begin
      FEnterWithKeyboard := True;
      TrackMenuFromItem;
    end;
  end;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.ProcessMenuLoop;
var
  Msg: TMsg;
  FDispatchMessage: Boolean;
  I: Integer;
begin
  if FInMenuLoop then
    Exit;
  FInMenuLoop := True;

  repeat
    if ATrackMenu then
      TrackMenuFromItem;

    FDispatchMessage := False;

    if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
      case Msg.message of
        WM_MOUSEMOVE:
          begin
          end;
        WM_SYSKEYDOWN:
         begin
           if Msg.wParam = VK_MENU then
           begin
             FInMenuLoop := False;
             FDispatchMessage := True;
           end;
         end;
        WM_QUIT:
          begin
            FInMenuLoop := False;
            PostQuitMessage(Msg.wParam);
          end;
        WM_CLOSE, CM_RELEASE:
          begin
            FInMenuLoop := False;
            FDispatchMessage := True;
          end;
        WM_KEYDOWN:
          begin
            if not FEnterWithKeyboard then
            begin
              FEnterWithKeyboard := True;
              Invalidate;
            end;
            I := FindHotKeyItem(Msg.WParam, True);
            if (I <> -1) and (FActiveItem = I) then
            begin
              if FItems[FActiveItem].MenuItem.Count = 0 then
              begin
                MenuExit;
                if FItems[I].MenuItem.GetParentMenu <> nil then
                  FItems[I].MenuItem.GetParentMenu.DispatchCommand(FItems[I].MenuItem.Command);
              end
              else
                TrackMenuFromItem;
            end
            else
              case Msg.WParam of
                VK_ESCAPE:
                  MenuExit;
                VK_RIGHT:
                  if FFormHook.Control.BiDiMode = bdRightToLeft then
                    FindPriorMenuItem(True)
                  else
                    FindNextMenuItem(True);
                VK_LEFT:
                  if FFormHook.Control.BiDiMode = bdRightToLeft then
                    FindNextMenuItem(True)
                  else
                    FindPriorMenuItem(True);
                VK_RETURN, VK_DOWN:
                  if FMDIChildSysMenuActive then
                  begin
                    MenuExit;
                    TrackMDIChildSystemMenu;
                  end
                  else if FSysMenuActive then
                  begin
                    MenuExit;
                    TrackSystemMenu;
                  end
                  else if FActiveItem <> -1 then
                  begin
                    if FItems[FActiveItem].MenuItem.Count = 0 then
                    begin
                      I := FActiveItem;
                      MenuExit;
                      if FItems[I].MenuItem.GetParentMenu <> nil then
                        FItems[I].MenuItem.GetParentMenu.DispatchCommand(FItems[I].MenuItem.Command);
                    end
                    else
                      TrackMenuFromItem;
                  end;
              end;
            end;
        WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN,
        WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN, WM_NCMBUTTONDOWN,
        WM_LBUTTONUP, WM_RBUTTONUP, WM_MBUTTONUP,
        WM_NCLBUTTONUP, WM_NCRBUTTONUP, WM_NCMBUTTONUP,
        WM_ACTIVATE, WM_NCACTIVATE, WM_SETFOCUS, WM_KILLFOCUS,
        WM_CANCELMODE:
          begin
            FInMenuLoop := False;
            FDispatchMessage := True;
          end;
         else
           DispatchMessage(Msg);
      end;

  until not FInMenuLoop;

  if not FMustActivateMenuItem then
    MenuExit;
  if FDispatchMessage then
    DispatchMessage(Msg);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.FindFirstMenuItem;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FItemCount - 1 do
  begin
    if FItems[I].MenuItem.Visible and FItems[I].MenuItem.Enabled then
    begin
      Result := I;
      if AUpdateMenu then
      begin
        FActiveItem := I;
        Invalidate;
      end;
      Break;
    end;
  end;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.FindFirstRightMenuItem;
var
  I: Integer;
begin
  Result := -1;
  for I := FItemCount - 1 downto 0 do
  begin
    if FItems[I].MenuItem.Visible and FItems[I].MenuItem.Enabled then
    begin
      Result := I;
      if AUpdateMenu then
      begin
        FActiveItem := I;
        Invalidate;
      end;
      Break;
    end;
  end;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.FindHotKeyItem;
var
  i: Integer;
begin
  Result := -1;
  for I := 0 to FItemCount - 1 do
  begin
    if FItems[I].MenuItem.Visible and FItems[I].MenuItem.Enabled and
       IsAccel(CharCode, FItems[I].MenuItem.Caption) then
    begin
      Result := I;
      if AUpdateMenu then
      begin
        FActiveItem := I;
        Invalidate;
      end;
      Break;
    end;
  end;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.FindNextMenuItem;
var
  I, J: Integer;
begin
  Result := -1;
  if FActiveItem = -1 then J := 0 else  J := FActiveItem + 1;
  for I := J to FItemCount - 1 do
  begin
    if FItems[I].MenuItem.Visible and FItems[I].MenuItem.Enabled then
    begin
      Result := I;
      if AUpdateMenu then
      begin
        FActiveItem := I;
        Invalidate;
      end;
      Break;
    end;
  end;

  if (Result = -1) and not CanTrackSystemMenu then
    Result := FindFirstMenuItem(AUpdateMenu)
  else if (Result = -1) and CanTrackSystemMenu and not FMenuPush then
  begin
    if not FSysMenuActive and not FMDIChildSysMenuActive then
    begin
      FSysMenuActive := True;
      FMDIChildSysMenuActive := False;
      if AUpdateMenu then
        Invalidate;
    end
    else if CanTrackMDISystemMenu and not FMDIChildSysMenuActive then
    begin
      FSysMenuActive := False;
      FMDIChildSysMenuActive := True;
      if AUpdateMenu then
        Invalidate;
    end
    else
    begin
      FSysMenuActive := False;
      FMDIChildSysMenuActive := False;
      Result := FindFirstMenuItem(AUpdateMenu);
    end;
  end
  else if (Result = -1) and FMenuPush then
  begin
    if CanTrackSystemMenu and AUpdateMenu then
    begin
      MenuExit;
      TrackSystemMenu;
    end
    else if CanTrackMDISystemMenu and AUpdateMenu then
    begin
      MenuExit;
      TrackMDIChildSystemMenu;
    end
    else if FMenuHook = 0 then
      Result := FindFirstMenuItem(AUpdateMenu);
  end;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.FindPriorMenuItem;
var
  I, J: Integer;
begin
  Result := -1;
  if FActiveItem = -1 then
    J := FItemCount
  else
    J := FActiveItem - 1;

  for I := J downto 0 do
  begin
    if FItems[I].MenuItem.Visible and FItems[I].MenuItem.Enabled then
    begin
      Result := I;
      if AUpdateMenu then
      begin
        FActiveItem := I;
        Invalidate;
      end;
      Break;
    end;
  end;

  if (Result = -1) and not CanTrackSystemMenu then
    Result := FindFirstRightMenuItem(AUpdateMenu)
  else if (Result = -1) and CanTrackSystemMenu and not FMenuPush then
  begin
    if CanTrackMDISystemMenu and not FMDIChildSysMenuActive
       and not FSysMenuActive then
    begin
      FSysMenuActive := False;
      FMDIChildSysMenuActive := True;
      if AUpdateMenu then
        Invalidate;
    end
    else if not FSysMenuActive then
    begin
      FSysMenuActive := True;
      FMDIChildSysMenuActive := False;
      if AUpdateMenu then
        Invalidate;
    end
    else
    begin
      FSysMenuActive := False;
      FMDIChildSysMenuActive := False;
      Result := FindFirstRightMenuItem(AUpdateMenu);
    end;
  end
  else if (Result = -1) and FMenuPush then
  begin
    if CanTrackMDISystemMenu and AUpdateMenu then
    begin
      MenuExit;
      TrackMDIChildSystemMenu;
    end
    else if CanTrackSystemMenu and AUpdateMenu then
    begin
      MenuExit;
      TrackSystemMenu;
    end
    else if FMenuHook = 0 then
      Result := FindFirstRightMenuItem(AUpdateMenu);
  end;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.GetTrackMenuPos(AItem: TMenuBarItem): TPoint;
var
  RightPoint: TPoint;
begin
  Result := Point(AItem.ItemRect.Left, AItem.ItemRect.Top + AItem.ItemRect.Height);
  Result.X := Result.X + FFormHook.FLeft + FBoundsRect.Left;
  Result.Y := Result.Y + FFormHook.FTop + FBoundsRect.Top;
  RightPoint := Point(Result.X + AItem.ItemRect.Width, Result.Y);
  if Screen.MonitorFromPoint(Result) <> Screen.MonitorFromPoint(RightPoint)
  then
    begin
      if FFormHook.Control.BiDiMode <> bdRightToLeft then
        Result.X := Screen.MonitorFromPoint(RightPoint).WorkareaRect.Left
      else
        Result.X := Screen.MonitorFromPoint(Result).WorkareaRect.Right -
          AItem.ItemRect.Width - 1;
    end;
  if FFormHook.Control.BiDiMode = bdRightToLeft then
    Result.X := Result.X + AItem.ItemRect.Width;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.HookMenus;
begin
  FSelectFirstItem := True;
  FMenuBarHook := Self;
  FCurrentMenuItem := nil;
  if FMenuHook = 0 then
    FMenuHook := SetWindowsHookEx(WH_MSGFILTER, @PopupMenuHook, 0,
      GetCurrentThreadID);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.UnHookMenus;
begin
  if FMenuHook <> 0 then
    UnhookWindowsHookEx(FMenuHook);
  FMenuBarHook := nil;
  FCurrentMenuItem := nil;
  FMenuHook := 0;
  FSelectFirstItem := False;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.ItemFromCursorPos: Integer;
var
  P: TPoint;
begin
  P := Mouse.CursorPos;
  P.X := P.X - FFormHook.FLeft - FBoundsRect.Left;
  P.Y := P.Y - FFormHook.FTop - FBoundsRect.Top;
  Result := ItemFromPoint(P.X, P.Y);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.MDIChildClose;
begin
  if (FFormHook.Form.ActiveMDIChild <> nil) then
    SendMessage(FFormHook.Form.ActiveMDIChild.Handle,
      WM_SYSCOMMAND, SC_CLOSE, 0);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.MDIChildRestore;
begin
  if (FFormHook.Form.ActiveMDIChild <> nil) then
    SendMessage(FFormHook.Form.ActiveMDIChild.Handle,
      WM_SYSCOMMAND, SC_RESTORE, 0);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.MDIChildMinimize;
begin
  if (FFormHook.Form.ActiveMDIChild <> nil) then
    SendMessage(FFormHook.Form.ActiveMDIChild.Handle,
      WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.MDIButtonFromPoint(X, Y: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to 2 do
    if FMDIButtons[I].ItemRect.Contains(Point(X, Y)) then
      Exit(FMDIButtons[I].Index);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.ItemFromPoint(X, Y: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FItemCount - 1 do
    if FItems[I].MenuItem.Visible and FItems[I].MenuItem.Enabled and
       FItems[I].ItemRect.Contains(Point(X, Y)) then
      Exit(FItems[I].Index);
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.Invalidate;
begin
  FFormHook.InvalidateNC;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.MainMenu: TMainMenu;
begin
  if FFormHook.Form.FormStyle = fsMDIChild then
  begin
    Result := nil;
    Exit;
  end;
  Result := FFormHook.Form.Menu;
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.GetMenuHeight(AWidth: Integer): Integer;

function GetItemCount(AMenu, AChildMenu: TMainMenu): Integer;

procedure Insert(APos: Integer; var ACount: Integer; AItem: TMenuItem);
var
  I: Integer;
begin
  Inc(ACount);
  if APos = ACount - 1 then
    FItems[APos].MenuItem := AItem
  else
  begin
    for I := ACount - 1 downto APos + 1 do
      FItems[I].MenuItem := FItems[I - 1].MenuItem;
    FItems[APos].MenuItem := AItem;
  end;
end;

function CanAddItem(AItem: TMenuItem): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to AChildMenu.Items.Count - 1 do
    if AItem.GroupIndex = AChildMenu.Items[I].GroupIndex then
    begin
      Result := False;
      Break;
    end;
end;

var
  I, J, Count, Index: Integer;
begin
  if AMenu = nil then
    Exit(0);

  if AChildMenu <> nil then
  begin
    Count := AMenu.Items.Count + AChildMenu.Items.Count;
    SetLength(FItems, Count);
    Result := AChildMenu.Items.Count;
    {add items from child menu}
    for I := 0 to Result - 1 do
      FItems[I].MenuItem := AChildMenu.Items[I];
    {add items from menu}
    for I := AMenu.Items.Count - 1 downto 0 do
      if CanAddItem(AMenu.Items[I]) then
      begin
        Index := -1;
        for J := 0 to Result - 1 do
          if AMenu.Items[I].GroupIndex <= FItems[J].MenuItem.GroupIndex then
          begin
            Index := J;
            Break;
          end;
        if Index = -1 then Index := Result;
        Insert(Index, Result, AMenu.Items[I]);
      end;
  end
  else
  begin
    {add items from menu}
    Result := AMenu.Items.Count;
    SetLength(FItems, Result);
    for I := 0 to Result - 1 do
      FItems[I].MenuItem := AMenu.Items[I];
  end;
end;

var
  Buffer: TBitmap;
  I, LHeight: Integer;
  LWidth, LButtonWidth: Integer;
  LIconDraw: Boolean;
  FMenu, FChildMenu: TMainMenu;
begin
  Result := GetSystemMetrics(SM_CYMENU);
  if MainMenu = nil then
    Exit;

  if FShowMDIButtons then
    LButtonWidth := Result * 3
  else
    LButtonWidth := 0;

  {get menu}
  FMenu := MainMenu;
  {get mdi child menu}
  FChildMenu := nil;
  if FFormHook.Form.FormStyle = fsMDIForm then
    with FFormHook.Form do
      if (ActiveMDIChild <> nil) and (ActiveMDIChild.Menu <> nil) and
         (ActiveMDIChild.Menu.Items.Count > 0) and
         (ActiveMDIChild.Handle <> FFormHook.FChangeVisibleChildHandle) then
        FChildMenu := ActiveMDIChild.Menu;

  {initialize array of items}
  FItemCount := GetItemCount(FMenu, FChildMenu);

  {calculation sizes}
  Buffer := TBitMap.Create;
  try
    Buffer.Canvas.Font.Assign(Screen.MenuFont);
    LIconDraw := FShowMDIButtons and CanTrackMDISystemMenu;
    if LIconDraw then
      LHeight := GetSystemMetrics(SM_CYMENU)
    else
      LHeight := 0;
    for I := 0 to FItemCount  - 1 do
    begin
      LWidth := GetMenuItemWidth(FItems[I].MenuItem, Buffer.Canvas);
      LHeight := LHeight + LWidth;
      if (LHeight > AWidth) and (LHeight <> 0) then
      begin
        LHeight := LWidth;
        Result := Result + GetSystemMetrics(SM_CYMENU);
      end;
    end;
  finally
    Buffer.Free;
  end;
  if (LButtonWidth <> 0) and (LHeight + LButtonWidth > AWidth) then
    Result := Result + GetSystemMetrics(SM_CYMENU);
end;

function TFormStyleHookEx.TMainMenuBarStyleHook.GetMenuItemWidth(AMenuItem: TMenuItem; ACanvas: TCanvas): Integer;
var
  R: TRect;
begin
  if (AMenuItem.GetParentMenu = nil) or not AMenuItem.Visible then
    Exit(0);

  R := Rect(0, 0, 0, 0);
  DrawText(ACanvas.Handle, PChar(AMenuItem.Caption), Length(AMenuItem.Caption), R, DT_CALCRECT);
  Result := R.Width + 10;
  if (AMenuItem.GetParentMenu.Images <> nil) and (AMenuItem.ImageIndex >= 0) and
     (AMenuItem.ImageIndex < AMenuItem.GetParentMenu.Images.Count) then
    Result := Result + MainMenu.Images.Width + 6;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.DrawItem(AItem: TMenuBarItem; ACanvas: TCanvas);
var
  Details: TThemedElementDetails;
  SaveIndex: Integer;
  LWidth, LHeight: Integer;
  R: TRect;
  LTextColor: TColor;
  ItemMainMenu: TMenu;
  LStyle: TCustomStyleServices;
begin
  if AItem.MenuItem.GetParentMenu = nil then
    Exit;

  LStyle := StyleServices;
  ItemMainMenu := AItem.MenuItem.GetParentMenu;
  {check item state}
  if FActiveItem = AItem.Index then
  begin
    if FMenuPush then
      AItem.State := tmMenuBarItemPushed
    else if not FSysMenuActive and not FMDIChildSysMenuActive then
      AItem.State := tmMenuBarItemHot
    else
      AItem.State := tmMenuBarItemNormal;
  end
  else if AItem.MenuItem.Enabled then
    AItem.State := tmMenuBarItemNormal
  else
    AItem.State := tmMenuBarItemDisabled;
  Details := LStyle.GetElementDetails(AItem.State);
  {draw item body}
  SaveIndex := SaveDC(ACanvas.Handle);
  try
    LStyle.DrawElement(ACanvas.Handle, Details, AItem.ItemRect);
  finally
    RestoreDC(ACanvas.Handle, SaveIndex);
  end;
  R := AItem.ItemRect;
  if FFormHook.Control.BiDiMode <> bdRightToLeft then
    Inc(R.Left, 5)
  else
    Dec(R.Right, 5);
  {draw item image}
  if (ItemMainMenu.Images <> nil) and (AItem.MenuItem.ImageIndex >= 0) and
     (AItem.MenuItem.ImageIndex < MainMenu.Images.Count) then
  begin
    if FFormHook.Control.BiDiMode <> bdRightToLeft then
      LWidth := R.Left
    else
      LWidth := R.Right - ItemMainMenu.Images.Width;
    LHeight := R.Top + R.Height div  2 - ItemMainMenu.Images.Height div 2;
    ImageList_Draw(MainMenu.Images.Handle, AItem.MenuItem.ImageIndex,
      ACanvas.Handle, LWidth, LHeight, ILD_TRANSPARENT);
    if FFormHook.Control.BiDiMode <> bdRightToLeft then
      R.Left := R.Left + ItemMainMenu.Images.Width + 3
    else
      R.Right := R.Right - ItemMainMenu.Images.Width - 3;
  end;
  {draw item text}
  if LStyle.GetElementColor(Details, ecTextColor, LTextColor) then
    ACanvas.Font.Color := TColor(LTextColor);
  if (FMenuPush or FMenuActive) and FEnterWithKeyboard then
    DrawText(ACanvas.Handle, PChar(AItem.MenuItem.Caption), Length(AItem.MenuItem.Caption),
      R, FFormHook.Control.DrawTextBiDiModeFlags(DT_LEFT or DT_VCENTER or DT_SINGLELINE))
  else
    DrawText(ACanvas.Handle, PChar(AItem.MenuItem.Caption), Length(AItem.MenuItem.Caption),
      R, FFormHook.Control.DrawTextBiDiModeFlags(DT_LEFT or DT_VCENTER or DT_HIDEPREFIX or DT_SINGLELINE));
end;


type
  TMenuItemClass = class(TMenuItem);

procedure TFormStyleHookEx.TMainMenuBarStyleHook.Paint(Canvas: TCanvas);

function GetItemCount(AMenu, AMergedMenu: TMainMenu): Integer;

procedure Insert(APos: Integer; var ACount: Integer; AItem: TMenuItem);
var
  I: Integer;
begin
  Inc(ACount);
  if APos = ACount - 1 then
    FItems[APos].MenuItem := AItem
  else
  begin
    for I := ACount - 1 downto APos + 1 do
      FItems[I].MenuItem := FItems[I - 1].MenuItem;
    FItems[APos].MenuItem := AItem;
  end;
end;

function CanAddItem(AItem: TMenuItem): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to AMergedMenu.Items.Count - 1 do
    if AItem.GroupIndex = AMergedMenu.Items[I].GroupIndex then
    begin
      Result := False;
      Break;
    end;
end;

var
  I, J, Count, Index: Integer;
begin
  if AMenu = nil then
    Exit(0);

  if AMergedMenu <> nil then
  begin
    Count := AMenu.Items.Count + AMergedMenu.Items.Count;
    SetLength(FItems, Count);
    Result := AMergedMenu.Items.Count;
    {add items from child menu}
    for I := 0 to Result - 1 do
      FItems[I].MenuItem := AMergedMenu.Items[I];
    {add items from menu}
    for I := AMenu.Items.Count - 1 downto 0 do
      if CanAddItem(AMenu.Items[I]) then
      begin
        Index := -1;
        for J := 0 to Result - 1 do
          if AMenu.Items[I].GroupIndex <= FItems[J].MenuItem.GroupIndex then
          begin
            Index := J;
            Break;
          end;
        if Index = -1 then Index := Result;
        Insert(Index, Result, AMenu.Items[I]);
      end;
  end
  else
  begin
    {add items from menu}
    Result := AMenu.Items.Count;
    SetLength(FItems, Result);
    for I := 0 to Result - 1 do
      FItems[I].MenuItem := AMenu.Items[I];
  end;
end;

var
  Details: TThemedElementDetails;
  Buffer: TBitMap;
  FMenu, FMergedMenu: TMainMenu;
  I, X, Y, W, BW: Integer;
  SaveIndex: Integer;
  FIconDraw, FRightAlign: Boolean;
  LStyle: TCustomStyleServices;
  FMerged: TMenuItem;
begin
  if (FBoundsRect.Width = 0) or (FBoundsRect.Height = 0) then
    Exit;

  LStyle := StyleServices;
  if not LStyle.Available then
    Exit;

  {get main menu}
  FMenu := MainMenu;
  if FMenu = nil then
    Exit;

  {get merged menu}
  FMergedMenu := nil;

  FMerged := TMenuItemClass(FFormHook.Form.Menu.Items).Merged;
  if (FMerged <> nil) and (FMerged.Count > 0) and (FMerged.GetParentMenu is TMainMenu) then
    FMergedMenu := TMainMenu(FMerged.GetParentMenu);

  Buffer := TBitMap.Create;
  try
    Buffer.SetSize(FBoundsRect.Width, FBoundsRect.Height);
    {draw menu bar}
    SaveIndex := SaveDC(Buffer.Canvas.Handle);
    try
      Details := LStyle.GetElementDetails(tmMenuBarBackgroundActive);
      LStyle.DrawElement(Buffer.Canvas.Handle, Details,
      Rect(0, 0, Buffer.Width, Buffer.Height));
    finally
      RestoreDC(Buffer.Canvas.Handle, SaveIndex);
    end;
    Buffer.Canvas.Font.Assign(Screen.MenuFont);
    Buffer.Canvas.Brush.Style := bsClear;
    {draw mdi child icon}
    FIconDraw := FShowMDIButtons and CanTrackMDISystemMenu;
    if FIconDraw then
      DrawIconEx(Buffer.Canvas.Handle, 2, 2, GetIconFast.Handle, 0, 0, 0, 0, DI_NORMAL);

    {initialize array of items}
    FItemCount := GetItemCount(FMenu, FMergedMenu);

    {draw items}
    FRightAlign := FFormHook.Control.BiDiMode = bdRightToLeft;
    BW := GetSystemMetrics(SM_CYMENU);
    if not FRightAlign then
    begin
      if FIconDraw then
        X := BW
      else
        X := 0
    end
    else
    begin
      if FShowMDIButtons then
        X := FBoundsRect.Width - BW * 3
      else
        X := FBoundsRect.Width;
    end;
    Y := 0;
    for I := 0 to FItemCount - 1 do
    begin
      FItems[I].Index := I;
      W := GetMenuItemWidth(FItems[I].MenuItem, Buffer.Canvas);
      if W = 0 then
      begin
        FItems[I].ItemRect := Rect(0, 0, 0, 0);
        Continue;
      end;
      if not FRightAlign then
      begin
        FItems[I].ItemRect.Left := X;
        FItems[I].ItemRect.Right := FItems[I].ItemRect.Left + W;
        if (FItems[I].ItemRect.Right > FBoundsRect.Width) and (X <> 0) then
        begin
          Y := Y + GetSystemMetrics(SM_CYMENU);
          FItems[I].ItemRect.Left := 0;
          FItems[I].ItemRect.Right := W;
        end;
        X := FItems[I].ItemRect.Right;
      end
      else
      begin
        FItems[I].ItemRect.Left := X - W;
        FItems[I].ItemRect.Right := FItems[I].ItemRect.Left + W;
        if (FItems[I].ItemRect.Left < 0) and (X <> 0) then
        begin
          Y := Y + GetSystemMetrics(SM_CYMENU);
          if FShowMDIButtons then
            FItems[I].ItemRect.Right := FBoundsRect.Width - BW * 3
          else
            FItems[I].ItemRect.Right := FBoundsRect.Width;
          FItems[I].ItemRect.Left := FItems[I].ItemRect.Right - W;
        end;
        X := FItems[I].ItemRect.Left;
      end;
      FItems[I].ItemRect.Top := Y;
      FItems[I].ItemRect.Bottom := FItems[I].ItemRect.Top + GetSystemMetrics(SM_CYMENU);

      DrawItem(FItems[I], Buffer.Canvas);
    end;
    {draw mdi buttons}
    X := Buffer.Width;
    Y := Buffer.Height - BW;
    if FShowMDIButtons then
    begin
      for I := 0 to 2 do
      begin
        FMDIButtons[I].Index := I;
        case I of
          0:
            begin
              if (I = FHotMDIButton) and (I = FPressedMDIButton) then
                FMDIButtons[I].State := twMDICloseButtonPushed
              else if (I = FHotMDIButton) then
                FMDIButtons[I].State := twMDICloseButtonHot
              else
                FMDIButtons[I].State := twMDICloseButtonNormal;
            end;
          1:
            begin
              if (I = FHotMDIButton) and (I = FPressedMDIButton) then
                FMDIButtons[I].State := twMDIRestoreButtonPushed
              else if (I = FHotMDIButton) then
                FMDIButtons[I].State := twMDIRestoreButtonHot
              else
                FMDIButtons[I].State := twMDIRestoreButtonNormal;
            end;

         2:
            begin
              if (I = FHotMDIButton) and (I = FPressedMDIButton) then
                FMDIButtons[I].State := twMDIMinButtonPushed
              else if (I = FHotMDIButton) then
                FMDIButtons[I].State := twMDIMinButtonHot
              else
                FMDIButtons[I].State := twMDIMinButtonNormal;
            end;
        end;
        FMDIButtons[I].ItemRect := Rect(X - BW, Y, X, Y + BW);
        Details := LStyle.GetElementDetails(FMDIButtons[I].State);
        LStyle.DrawElement(Buffer.Canvas.Handle, Details,
          FMDIButtons[I].ItemRect);
        X := X - BW;
      end;
    end;
    {draw buffer}
    Canvas.Draw(FBoundsRect.Left, FBoundsRect.Top, Buffer);
  finally
    Buffer.Free;
  end;
end;

class function TFormStyleHookEx.TMainMenuBarStyleHook.PopupMenuHook(Code: Integer; WParam: WPARAM; var Msg: TMsg): LRESULT;
var
  FItem: Integer;
  FFindItemKind: TFindItemKind;
  P: TPoint;
  FOldActiveItem: Integer;
  I: Integer;
  CanFindItem: Boolean;
begin
  if (FMenuBarHook = nil) or
     ((FMenuBarHook <> nil) and (FMenuBarHook.MainMenu = nil)) then
    Exit(0);
  Result := CallNextHookEx(FMenuBarHook.FMenuHook, Code, WParam, IntPtr(@Msg));
  if Result <> 0 then
    Exit;

  if FMenuBarHook.FSelectFirstItem then
  begin
    FMenuBarHook.FSelectFirstItem := False;
    if Msg.Message <> WM_MENUSELECT then
      PostMessage(Msg.Hwnd, WM_KEYDOWN, VK_DOWN, 0);
  end;

  if Code = MSGF_MENU then
    case Msg.Message of
      WM_MOUSEMOVE:
        if (WindowFromPoint(Mouse.CursorPos) = FMenuBarHook.FFormHook.Handle) and
           not FMenuBarHook.FMustActivateMenuItem then
        begin
          P := Mouse.CursorPos;
          P.X := P.X - FMenuBarHook.FFormHook.Control.Left -
            FMenuBarHook.FBoundsRect.Left;
          P.Y := P.Y - FMenuBarHook.FFormHook.Control.Top -
            FMenuBarHook.FBoundsRect.Top;
          FOldActiveItem := FMenuBarHook.FActiveItem;
          FMenuBarHook.MouseMove(P.X, P.Y);
          if (FOldActiveItem <> FMenuBarHook.FActiveItem) and
             (FMenuBarHook.FActiveItem <> -1) then
          begin
            P := Mouse.CursorPos;
            FMenuBarHook.FMustActivateMenuItem := True;
            PostMessage(FMenuBarHook.FFormHook.Handle, WM_NCLBUTTONDOWN, MK_LBUTTON,
              Integer(PointToSmallPoint(P))); // 64-bit safe Integer cast
          end;
        end;
      WM_SYSKEYDOWN:
        if Msg.wParam = VK_MENU then
        begin
           FMenuBarHook.FMustActivateMenuItem := False;
           FMenuBarHook.MenuExit;
         end;
      WM_MENUSELECT:
        begin
          FFindItemKind := fkCommand;
          if (Msg.WParam shr 16) and MF_POPUP <> 0 then
            FFindItemKind := fkHandle;
          if FFindItemKind = fkHandle then
            FItem := GetSubMenu(HMENU(Msg.LParam), LoWord(Msg.WParam))
          else
            FItem := LoWord(Msg.WParam);
          FCurrentMenuItem := FMenuBarHook.FindItem(FItem, FFindItemKind);
        end;
      WM_KEYDOWN:
        begin
          if  FMenuBarHook.FFormHook.Control.BidiMode = bdRightToLeft then
          begin
            if Msg.WParam = VK_RIGHT then Msg.WParam := VK_LEFT else
              if Msg.WParam = VK_LEFT then Msg.WParam := VK_RIGHT;
          end;

          CanFindItem := False;

          if Msg.WParam = VK_RIGHT then
             CanFindItem := FMenuBarHook.CanFindNextItem(FCurrentMenuItem)
          else if Msg.WParam = VK_LEFT then
             CanFindItem := FMenuBarHook.CanFindPriorItem(FCurrentMenuItem);

          case Msg.WParam of
            VK_RIGHT:
             if CanFindItem then
             begin
               FMenuBarHook.FEnterWithKeyboard := True;
               if FMenuBarHook.FSystemMenuTracking and
                  FMenuBarHook.CanTrackMDISystemMenu then
               begin
                 P := Mouse.CursorPos;
                 FMenuBarHook.FMustActivateMDIChildSysMenu := True;
                 EndMenu;
                 PostMessage(FMenuBarHook.FFormHook.Handle, WM_NCLBUTTONDOWN, MK_LBUTTON,
                   Integer(PointToSmallPoint(P))); // 64-bit safe Integer cast
                 Exit;
               end
               else
                 if not FMenuBarHook.FSystemMenuTracking then
                   I := FMenuBarHook.FindNextMenuItem(False)
                 else
                   I := FMenuBarHook.FindFirstMenuItem(False);

               if I <> -1 then
               begin
                 FMenuBarHook.FActiveItem := I;
                 P := Mouse.CursorPos;
                 FMenuBarHook.FMustActivateMenuItem := True;
                 EndMenu;
                 PostMessage(FMenuBarHook.FFormHook.Handle, WM_NCLBUTTONDOWN, MK_LBUTTON,
                   Integer(PointToSmallPoint(P)));
               end
               else if not FMenuBarHook.FSystemMenuTracking then
               begin
                 P := Mouse.CursorPos;
                 FMenuBarHook.FMustActivateSysMenu := True;
                 EndMenu;
                 PostMessage(FMenuBarHook.FFormHook.Handle, WM_NCLBUTTONDOWN, MK_LBUTTON,
                   Integer(PointToSmallPoint(P))); // 64-bit safe Integer cast
               end;
             end;
           VK_LEFT:
           if CanFindItem then
             begin
               FMenuBarHook.FEnterWithKeyboard := True;
               if FMenuBarHook.FMDIChildSystemMenuTracking
               then
                 I := -1
               else if not FMenuBarHook.FSystemMenuTracking then
                 I := FMenuBarHook.FindPriorMenuItem(False)
               else
                 I := FMenuBarHook.FindFirstRightMenuItem(False);

               if I <> -1 then
               begin
                 FMenuBarHook.FActiveItem := I;
                 P := Mouse.CursorPos;
                 FMenuBarHook.FMustActivateMenuItem := True;
                 EndMenu;
                 PostMessage(FMenuBarHook.FFormHook.Handle, WM_NCLBUTTONDOWN, MK_LBUTTON,
                   Integer(PointToSmallPoint(P))); // 64-bit safe Integer cast
               end
               else if FMenuBarHook.CanTrackMDISystemMenu and
                    not FMenuBarHook.FMDIChildSystemMenuTracking then
               begin
                 P := Mouse.CursorPos;
                 FMenuBarHook.FMustActivateMDIChildSysMenu := True;
                 EndMenu;
                 PostMessage(FMenuBarHook.FFormHook.Handle, WM_NCLBUTTONDOWN, MK_LBUTTON,
                   Integer(PointToSmallPoint(P))); // 64-bit safe Integer cast
               end
               else if not FMenuBarHook.FSystemMenuTracking then
               begin
                 P := Mouse.CursorPos;
                 FMenuBarHook.FMustActivateSysMenu := True;
                 EndMenu;
                 PostMessage(FMenuBarHook.FFormHook.Handle, WM_NCLBUTTONDOWN, MK_LBUTTON,
                   Integer(PointToSmallPoint(P))); // 64-bit safe Integer cast
               end;
             end;
         end;
       end;
    end;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.SetBoundsRect(const ABoundsRect: TRect);
begin
  FBoundsRect := ABoundsRect;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.MouseUp(X, Y: Integer);
begin
  FActiveItem := ItemFromPoint(X, Y);
  if FActiveItem <> -1 then
  begin
    Invalidate;
    if FItems[FActiveItem].MenuItem.Count = 0 then
      MainMenu.DispatchCommand(FItems[FActiveItem].MenuItem.Command);
  end;

  if FShowMDIButtons then
  begin
    FHotMDIButton := MDIButtonFromPoint(X, Y);
    if (FHotMDIButton <> -1) and (FPressedMDIButton = FHotMDIButton) then
    begin
      FPressedMDIButton := -1;
      Invalidate;
      case FMDIButtons[FHotMDIButton].Index of
        0: MDIChildClose;
        1: MDIChildRestore;
        2: MDIChildMinimize;
      end;
    end
    else
      FPressedMDIButton := -1;
  end;
end;


procedure TFormStyleHookEx.TMainMenuBarStyleHook.MouseDown(X, Y: Integer);
begin

  FActiveItem := ItemFromPoint(X, Y);
  if FActiveItem <> -1 then
    MenuEnter(True)
  else
  begin
    if FShowMDIButtons and CanTrackMDISystemMenu and Rect(0, 0,
       GetSystemMetrics(SM_CYMENU), GetSystemMetrics(SM_CYMENU)).Contains(Point(X, Y)) then
      TrackMDIChildSystemMenu;
  end;

  if FShowMDIButtons then
  begin
    FHotMDIButton := MDIButtonFromPoint(X, Y);
    FPressedMDIButton := FHotMDIButton;
    if FPressedMDIButton <> -1 then
      Invalidate;
  end;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.MouseMove(X, Y: Integer);
begin
  if FMustActivateMenuItem  or ((FOldCursorPos = Mouse.CursorPos) and (FMenuActive or FMenuPush)) then
    Exit;

  FOldCursorPos := Mouse.CursorPos;

  FMouseInMainMenu := not ((X < 0) or (Y < 0));
  if FMenuPush then
  begin
    if ItemFromPoint(X, Y) <> -1 then
      FActiveItem := ItemFromPoint(X, Y);
  end
  else
    FActiveItem := ItemFromPoint(X, Y);

  if FActiveItem <> FOldActiveItem then
  begin
    Invalidate;
    FOldActiveItem := FActiveItem;
    if FMenuPush and  (FMenuHook = 0) and (FItems[FActiveItem].MenuItem.Count <> 0) then
      TrackMenuFromItem;
  end;

  if FShowMDIButtons then
  begin
    FHotMDIButton := MDIButtonFromPoint(X, Y);
    if FHotMDIButton <> FOldMDIHotButton then
    begin
      Invalidate;
      FOldMDIHotButton := FHotMDIButton;
    end;
    if FHotMDIButton = -1 then FPressedMDIButton := -1;
  end;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.TrackMDIChildSystemMenu;
var
  X, Y: Integer;
  Child: TCustomForm;
  P: TPoint;
  R: TRect;
begin
  FMDIChildSysMenuActive := False;
  FSysMenuActive := False;
  if FFormHook.Form.FormStyle <> fsMDIForm then
    Exit;

  Child := FFormHook.Form.ActiveMDIChild;
  if Child = nil then
    Exit;

  FMDIChildSystemMenuTracking := True;
  if Child.WindowState = wsMaximized then
  begin
    X := FFormHook.FLeft + FBoundsRect.Left;
    Y := FFormHook.FTop + FBoundsRect.Bottom;
  end
  else
  begin
    P := FFormHook.Control.ClientToScreen(Point(0, 0));
    R := FFormHook.GetMDIWorkArea;
    X := P.X + R.Left + Child.Left + FBoundsRect.Left;
    Y := P.Y + R.Top + Child.Top + FBoundsRect.Top;
  end;
  HookMenus;
  SendMessage(Child.Handle, $313, 0, MakeLong(X, Y));
  UnHookMenus;
  FMDIChildSystemMenuTracking := False;
  Invalidate;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.TrackSystemMenu;
var
  X, Y: Integer;
  LeftPoint, RightPoint: TPoint;
begin
  FMDIChildSysMenuActive := False;
  FSysMenuActive := False;
  FSystemMenuTracking := True;
  X := FFormHook.FLeft + FBoundsRect.Left;
  Y := FFormHook.FTop + FBoundsRect.Top;
  LeftPoint := Point(X, Y);
  RightPoint := Point(X + 50, Y);
  if Screen.MonitorFromPoint(LeftPoint) <> Screen.MonitorFromPoint(RightPoint)
  then
    X := Screen.MonitorFromPoint(RightPoint).WorkareaRect.Left;
  HookMenus;
  SendMessage(FFormHook.Handle, $313, 0, MakeLong(X, Y));
  UnHookMenus;
  FSystemMenuTracking := False;
  Invalidate;
end;

procedure TFormStyleHookEx.TMainMenuBarStyleHook.TrackMenuFromItem;
var
  P: TPoint;
  Cmd: Bool;
  FItem: TMenuItem;
begin
  FMDIChildSysMenuActive := False;
  FSysMenuActive := False;
  FMenuPush := True;
  Invalidate;
  if FItems[FActiveItem].MenuItem.Count = 0 then
    Exit;
  P := GetTrackMenuPos(FItems[FActiveItem]);

  HookMenus;
  if FFormHook.Control.BiDiMode <> bdRightToLeft then
    Cmd := TrackPopupMenu(FItems[FActiveItem].MenuItem.Handle,
      TPM_LEFTBUTTON  or TPM_RIGHTBUTTON or TPM_RETURNCMD or TPM_NOANIMATION,
        P.X, P.Y, 0, FFormHook.Handle, nil)
  else
    Cmd := TrackPopupMenu(FItems[FActiveItem].MenuItem.Handle,
      TPM_LEFTBUTTON  or TPM_RIGHTBUTTON or TPM_RETURNCMD or TPM_NOANIMATION or TPM_RIGHTALIGN,
        P.X, P.Y, 0, FFormHook.Handle, nil);
  UnHookMenus;

  FMenuPush := False;

  if Cmd then
  begin
    FItem := FindItem(IntPtr(Cmd), fkCommand);
    if FItem <> nil then
      FItem.GetParentMenu.DispatchCommand(FItem.Command)
    else
      PostMessage(FFormHook.Handle, WM_COMMAND, WParam(Cmd), 0);
    MenuExit;
  end
  else if not FMustActivateMenuItem then
  begin
    FMenuActive := True;
    FInMenuLoop := False;
    ProcessMenuLoop(False);
  end;

  Invalidate;
end;

{ TFormStyleHookEx }

constructor TFormStyleHookEx.Create(AControl: TWinControl);
begin
  inherited;
  FocusUpdate := False;

  if seClient in Form.StyleElements then
    OverrideEraseBkgnd := True;

  if IsStyleBorder then
    OverridePaintNC := True;

  FMainMenuBarHook := nil;
  FMDIHorzScrollBar := nil;
  FMDIVertScrollBar := nil;
  FMDIScrollSizeBox := nil;
  FMDIClientInstance := nil;
  FMDIPrevClientProc := nil;
  FChangeVisibleChildHandle := 0;
  FStopCheckChildMove := False;
  FOldHorzSrollBarPosition := 0;
  FOldVertSrollBarPosition := 0;

  FMDIStopHorzScrollBar := False;
  FMDIStopVertScrollBar := False;

  MouseInNCArea := True;
  FFormActive := False;
  FChangeSizeCalled := False;
  FRegion := 0;
  FLeft := Control.Left;
  FTop := Control.Top;
  FWidth := Control.Width;
  FHeight := Control.Height;
  FNeedsUpdate := True;
  FIcon := nil;
  FIconHandle := 0;
  FHotButton := 0;
  FPressedButton := 0;
  FCaptionEmulation := False;
end;

destructor TFormStyleHookEx.Destroy;
begin
  if FIcon <> nil then
    FreeAndNil(FIcon);
  if FRegion <> 0 then
  begin
    DeleteObject(FRegion);
    FRegion := 0;
  end;
  if FMDIClientInstance <> nil then
  begin
    SetWindowLong(TForm(Control).ClientHandle, GWL_WNDPROC, IntPtr(FMDIPrevClientProc));
    FreeObjectInstance(FMDIClientInstance);
  end;

  if FMainMenuBarHook <> nil then
    FreeAndNil(FMainMenuBarHook);
  if FMDIHorzScrollBar <> nil then
    FreeAndNil(FMDIHorzScrollBar);
  if FMDIVertScrollBar <> nil then
    FreeAndNil(FMDIVertScrollBar);
  if FMDIScrollSizeBox <> nil then
    FreeAndNil(FMDIScrollSizeBox);
  inherited;
end;

function TFormStyleHookEx.IsStyleBorder: Boolean;
begin
  Result := (TStyleManager.FormBorderStyle = fbsCurrentStyle) and (seBorder in Form.StyleElements);
end;

procedure TFormStyleHookEx.Invalidate;
begin
  // Prevent ancestor's Invalidate from executing
end;

procedure TFormStyleHookEx.MDIHorzScroll(Offset: Integer);
var
  I: Integer;
begin
  FStopCheckChildMove := True;
  try
    for I := 0 to Form.MDIChildCount -1 do
      if Form.MDIChildren[I].Visible then
        Form.MDIChildren[I].Left := Form.MDIChildren[I].Left + Offset;
  finally
    FStopCheckChildMove := False;
  end;
  GetMDIScrollInfo(False);
end;

procedure TFormStyleHookEx.MDIVertScroll(Offset: Integer);
var
  I: Integer;
begin
  FStopCheckChildMove := True;
  try
    for I := 0 to Form.MDIChildCount -1 do
      if Form.MDIChildren[I].Visible then
        Form.MDIChildren[I].Top := Form.MDIChildren[I].Top + Offset;
  finally
    FStopCheckChildMove := False;
  end;
  GetMDIScrollInfo(False);
end;

procedure TFormStyleHookEx.OnMDIHScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
var
  Offset: Integer;
begin
  if (FMDIStopHorzScrollBar) or (ScrollCode <> scEndScroll) then
    Exit;

  Offset := TScrollBar(FMDIHorzScrollBar).Position - FOldHorzSrollBarPosition;
  if Offset <> 0 then
    MDIHorzScroll(-Offset);
  FOldHorzSrollBarPosition := TScrollBar(FMDIHorzScrollBar).Position;
end;

procedure TFormStyleHookEx.OnMDIVScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
var
  Offset: Integer;
begin
  if (FMDIStopVertScrollBar) or (ScrollCode <> scEndScroll) then
    Exit;

  Offset := TScrollBar(FMDIVertScrollBar).Position - FOldVertSrollBarPosition;
  if Offset <> 0 then
    MDIVertScroll(-Offset);
  FOldVertSrollBarPosition := TScrollBar(FMDIVertScrollBar).Position;
end;

function TFormStyleHookEx.MDIChildMaximized: Boolean;
begin
  Result := (Form.ActiveMDIChild <> nil) and
    (Form.ActiveMDIChild.WindowState = wsMaximized);
end;

procedure TFormStyleHookEx.GetMDIScrollInfo(SetRange: Boolean);
var
  I, MinX, MinY, MaxX, MaxY, HPage, VPage: Integer;
  R, MDIR, MDICLR: TRect;
  ReCalcInfo: Boolean;
  LHorzScrollVisible, LVertScrollVisible: Boolean;
  LMDIHorzScrollBar: TScrollBar;
  LMDIVertScrollBar: TScrollBar;
begin
  LMDIHorzScrollBar := TScrollBar(FMDIHorzScrollBar);
  LMDIVertScrollBar := TScrollBar(FMDIVertScrollBar);
  if (LMDIHorzScrollBar = nil) or (LMDIVertScrollBar = nil) then
    Exit;

  if (not (LMDIVertScrollBar.HandleAllocated)) or
     (not LMDIHorzScrollBar.HandleAllocated) then
    Exit;

  if MDIChildMaximized then
  begin
    if IsWindowVisible(LMDIHorzScrollBar.Handle) then
      ShowWindow(LMDIHorzScrollBar.Handle, SW_HIDE);
    if IsWindowVisible(LMDIVertScrollBar.Handle) then
      ShowWindow(LMDIVertScrollBar.Handle, SW_HIDE);
    Exit;
  end;

  ReCalcInfo := False;
  R := GetMDIWorkArea;

  MinX := MaxInt;
  MinY := MaxInt;
  MaxX := -MaxInt;
  MaxY := -MaxInt;

  for I := 0 to Form.MDIChildCount -1 do
   if (Form.MDIChildren[I].Visible) and
      (Form.MDIChildren[I].Handle <> FChangeVisibleChildHandle) then
     with Form do
     begin
       GetWindowRect(MDIChildren[I].Handle, MDIR);
       GetWindowRect(TForm(Control).ClientHandle, MDICLR);
       OffsetRect(MDIR, -MDICLR.Left, -MDICLR.Top);
       if MinX > MDIR.Left then
         MinX := MDIR.Left;
       if MinY > MDIR.Top then
         MinY := MDIR.Top;
       if MaxX < MDIR.Left + MDIR.Width then
         MaxX := MDIR.Left + MDIR.Width;
       if MaxY < MDIR.Top + MDIR.Height then
         MaxY := MDIR.Top + MDIR.Height;
     end;

  LHorzScrollVisible := (MinX < 0) or (MaxX > R.Width);
  LVertScrollVisible := (MinY < 0) or (MaxY > R.Height);

  if LVertScrollVisible and not LHorzScrollVisible then
    LHorzScrollVisible := (MinX < 0) or (MaxX > R.Width - LMDIVertScrollBar.Width);

  if LHorzScrollVisible and not LVertScrollVisible then
    LVertScrollVisible := (MinY < 0) or (MaxY > R.Height - LMDIHorzScrollBar.Height);

  if LHorzScrollVisible and not IsWindowVisible(LMDIHorzScrollBar.Handle) then
  begin
    SetWindowPos(LMDIHorzScrollBar.Handle, HWND_TOP,
      R.Left, R.Bottom - LMDIHorzScrollBar.Height,
      R.Width, LMDIHorzScrollBar.Height, SWP_SHOWWINDOW);
    ShowWindow(LMDIHorzScrollBar.Handle, SW_SHOW);
    ReCalcInfo := True;
  end
  else if not LHorzScrollVisible and IsWindowVisible(LMDIHorzScrollBar.Handle) then
  begin
    ShowWindow(LMDIHorzScrollBar.Handle, SW_HIDE);
    ReCalcInfo := True;
  end;

  if LVertScrollVisible and not IsWindowVisible(LMDIVertScrollBar.Handle) then
  begin
    if LHorzScrollVisible
    then
      SetWindowPos(LMDIVertScrollBar.Handle, HWND_TOP,
        R.Right - LMDIVertScrollBar.Width,
        R.Top, LMDIVertScrollBar.Width, R.Height - LMDIHorzScrollBar.Height, SWP_SHOWWINDOW)
    else
      SetWindowPos(LMDIVertScrollBar.Handle, HWND_TOP,
        R.Right - LMDIVertScrollBar.Width,
        R.Top, LMDIVertScrollBar.Width, R.Height, SWP_SHOWWINDOW);
    ShowWindow(LMDIVertScrollBar.Handle, SW_SHOW);
    ReCalcInfo := True;
  end
  else if not LVertScrollVisible and IsWindowVisible(LMDIVertScrollBar.Handle) then
  begin
    ShowWindow(LMDIVertScrollBar.Handle, SW_HIDE);
    ReCalcInfo := True;
  end;

  HPage := R.Width;
  VPage := R.Height;

  AdjustMDIScrollBars;

  if IsWindowVisible(LMDIHorzScrollBar.Handle) then
  begin
    if MinX > 0 then
      MinX := 0;
    if MaxX < R.Width then
      MaxX := R.Width;
    if SetRange then
    begin
      FMDIStopHorzScrollBar := True;
      if IsWindowVisible(LMDIVertScrollBar.Handle) then
        LMDIHorzScrollBar.PageSize := HPage - LMDIVertScrollBar.Width
      else
        LMDIHorzScrollBar.PageSize := HPage;
      LMDIHorzScrollBar.SetParams(-MinX, 0, MaxX - MinX - 1);
      FOldHorzSrollBarPosition := LMDIHorzScrollBar.Position;
      FMDIStopHorzScrollBar := False;
    end;
    LMDIHorzScrollBar.LargeChange := LMDIHorzScrollBar.PageSize;
  end;

  if IsWindowVisible(LMDIVertScrollBar.Handle) then
  begin
    if MinY > 0 then
      MinY := 0;
    if MaxY < R.Height then
      MaxY := R.Height;
    if SetRange then
    begin
      FMDIStopVertScrollBar := True;
      if IsWindowVisible(LMDIHorzScrollBar.Handle) then
        LMDIVertScrollBar.PageSize := VPage - LMDIHorzScrollBar.Height
      else
        LMDIVertScrollBar.PageSize := VPage;
      LMDIVertScrollBar.SetParams(-MinY, 0, MaxY - MinY - 1);
      FOldVertSrollBarPosition := LMDIVertScrollBar.Position;
      FMDIStopVertScrollBar := False;
    end;
    LMDIVertScrollBar.LargeChange := LMDIVertScrollBar.PageSize;
  end;

  if (not IsWindowVisible(LMDIHorzScrollBar.Handle)) and
     (not IsWindowVisible(LMDIVertScrollBar.Handle)) then ReCalcInfo := False;

  if IsWindowVisible(LMDIHorzScrollBar.Handle) and IsWindowVisible(LMDIVertScrollBar.Handle) and
     not IsWindowVisible(FMDIScrollSizeBox.Handle) then
  begin
    SetWindowPos(FMDIScrollSizeBox.Handle, HWND_TOP,
      R.Right - LMDIVertScrollBar.Width, R.Bottom - LMDIHorzScrollBar.Height,
      LMDIVertScrollBar.Width, LMDIHorzScrollBar.Height, SWP_SHOWWINDOW);
    ShowWindow(FMDIScrollSizeBox.Handle, SW_SHOW);
  end
  else if not IsWindowVisible(LMDIHorzScrollBar.Handle) or not IsWindowVisible(LMDIVertScrollBar.Handle) and
     IsWindowVisible(FMDIScrollSizeBox.Handle) then
    ShowWindow(FMDIScrollSizeBox.Handle, SW_HIDE);

  if ReCalcInfo then
    GetMDIScrollInfo(SetRange);
end;

procedure TFormStyleHookEx.InitMDIScrollBars;
begin
  if FMDIHorzScrollBar = nil then
  begin
    FMDIHorzScrollBar := TScrollBar.CreateParented(Control.Handle);
    with TScrollBar(FMDIHorzScrollBar) do
    begin
      Kind := sbHorizontal;
      OnScroll := OnMDIHScroll;
      SetWindowPos(FMDIHorzScrollBar.Handle, HWND_TOP,
        0, 0, 0, GetSystemMetrics(SM_CYHSCROLL), SWP_NOREDRAW);
      ShowWindow(FMDIHorzScrollBar.Handle, SW_HIDE);
    end;
  end;

  if FMDIVertScrollBar = nil then
  begin
    FMDIVertScrollBar := TScrollBar.CreateParented(Control.Handle);
    with TScrollBar(FMDIVertScrollBar) do
    begin
      Kind := sbVertical;
      OnScroll := OnMDIVScroll;
      SetWindowPos(FMDIVertScrollBar.Handle, HWND_TOP,
        0, 0, GetSystemMetrics(SM_CXVSCROLL), 0, SWP_NOREDRAW);
      ShowWindow(FMDIVertScrollBar.Handle, SW_HIDE);
    end;
  end;

  if FMDIScrollSizeBox = nil
  then
    begin
      FMDIScrollSizeBox := TScrollBarStyleHook.TScrollWindow.CreateParented(Control.Handle);
      with TScrollBarStyleHook.TScrollWindow(FMDIScrollSizeBox) do
      begin
        SizeBox := True;
        SetWindowPos(FMDIScrollSizeBox.Handle, HWND_TOP,
          0, 0, GetSystemMetrics(SM_CXVSCROLL), GetSystemMetrics(SM_CYHSCROLL), SWP_NOREDRAW);
        ShowWindow(FMDIScrollSizeBox.Handle, SW_HIDE);
      end;
    end;
end;

procedure TFormStyleHookEx.AdjustMDIScrollBars;
var
  R: TRect;
begin
  R := GetMDIWorkArea;

  if (FMDIHorzScrollBar <> nil) and IsWindowVisible(FMDIHorzScrollBar.Handle)
  then
    begin
      if (FMDIVertScrollBar <> nil) and IsWindowVisible(FMDIVertScrollBar.Handle) then
        SetWindowPos(FMDIHorzScrollBar.Handle, HWND_TOP, R.Left,
          R.Bottom - FMDIHorzScrollBar.Height, R.Width - FMDIVertScrollBar.Width, FMDIHorzScrollBar.Height, SWP_SHOWWINDOW)
      else
        SetWindowPos(FMDIHorzScrollBar.Handle, HWND_TOP, R.Left,
          R.Bottom - FMDIHorzScrollBar.Height, R.Width, FMDIHorzScrollBar.Height, SWP_SHOWWINDOW);
    end;

  if (FMDIVertScrollBar <> nil) and IsWindowVisible(FMDIVertScrollBar.Handle) then
  begin
    if (FMDIHorzScrollBar <> nil) and IsWindowVisible(FMDIHorzScrollBar.Handle)
    then
      SetWindowPos(FMDIVertScrollBar.Handle, HWND_TOP,
        R.Right - FMDIVertScrollBar.Width,
        R.Top, FMDIVertScrollBar.Width, R.Height - FMDIHorzScrollBar.Height, SWP_SHOWWINDOW)
    else
      SetWindowPos(FMDIVertScrollBar.Handle, HWND_TOP,
        R.Right - FMDIVertScrollBar.Width,
        R.Top, FMDIVertScrollBar.Width, R.Height, SWP_SHOWWINDOW)
  end;

  if (FMDIScrollSizeBox <> nil) and IsWindowVisible(FMDIScrollSizeBox.Handle) and
     (FMDIVertScrollBar <> nil) and IsWindowVisible(FMDIVertScrollBar.Handle) and
     (FMDIHorzScrollBar <> nil) and IsWindowVisible(FMDIHorzScrollBar.Handle) then
    SetWindowPos(FMDIScrollSizeBox.Handle, HWND_TOP,
      R.Right - FMDIVertScrollBar.Width, R.Bottom - FMDIHorzScrollBar.Height,
      FMDIVertScrollBar.Width, FMDIHorzScrollBar.Height, SWP_SHOWWINDOW);
end;

function TFormStyleHookEx.GetMDIWorkArea: TRect;
var
  P: TPoint;
begin
  Result := Control.ClientRect;
  if TForm(Control).ClientHandle <> 0 then
  begin
    GetWindowRect(TForm(Control).ClientHandle, Result);
    P := Control.ClientToScreen(Point(0, 0));
    OffsetRect(Result, -P.X, -P.Y);
  end;
end;

procedure TFormStyleHookEx.PaintBackground(Canvas: TCanvas);
var
  Details: TThemedElementDetails;
  R: TRect;
begin
  if StyleServices.Available then
  begin
    Details.Element := teWindow;
    Details.Part := 0;
    R := Rect(0, 0, Control.ClientWidth, Control.ClientHeight);
    StyleServices.DrawElement(Canvas.Handle, Details, R);
  end;
end;

function TFormStyleHookEx.GetBorderSize: TRect;
var
  Size: TSize;
  Details: TThemedElementDetails;
  Detail: TThemedWindow;
begin
  Result := Rect(0, 0, 0, 0);
  if Form.BorderStyle = bsNone then Exit;

  if not StyleServices.Available then Exit;
  {caption height}
  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
    Detail := twCaptionActive
  else
    Detail := twSmallCaptionActive;
  Details := StyleServices.GetElementDetails(Detail);
  StyleServices.GetElementSize(0, Details, esActual, Size);
  Result.Top := Size.cy;
  {left border width}
  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
    Detail := twFrameLeftActive
  else
    Detail := twSmallFrameLeftActive;
  Details := StyleServices.GetElementDetails(Detail);
  StyleServices.GetElementSize(0, Details, esActual, Size);
  Result.Left := Size.cx;
  {right border width}
  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
    Detail := twFrameRightActive
  else
    Detail := twSmallFrameRightActive;
  Details := StyleServices.GetElementDetails(Detail);
  StyleServices.GetElementSize(0, Details, esActual, Size);
  Result.Right := Size.cx;
  {bottom border height}
  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
    Detail := twFrameBottomActive
  else
    Detail := twSmallFrameBottomActive;
  Details := StyleServices.GetElementDetails(Detail);
  StyleServices.GetElementSize(0, Details, esActual, Size);
  Result.Bottom := Size.cy;
end;

function TFormStyleHookEx.GetForm: TDBForm;
begin
  Result := TDBForm(Control);
end;

function TFormStyleHookEx.NormalizePoint(P: TPoint): TPoint;
var
  WindowPos, ClientPos: TPoint;
  HandleParent: HWnd;
begin
  if Form.FormStyle = fsMDIChild then
  begin
    HandleParent := GetParent(Control.Handle);
    WindowPos := Point(FLeft, FTop);
    ClientToScreen(HandleParent, WindowPos);
    ClientPos := Point(0, 0);
    ClientToScreen(Handle, ClientPos);
    Result := P;
    ScreenToClient(Handle, Result);
    Inc(Result.X, ClientPos.X - WindowPos.X);
    Inc(Result.Y, ClientPos.Y - WindowPos.Y);
  end
  else
  begin
    WindowPos := Point(FLeft, FTop);
    ClientPos := Point(0, 0);
    ClientToScreen(Handle, ClientPos);
    Result := P;
    ScreenToClient(Handle, Result);
    Inc(Result.X, ClientPos.X - WindowPos.X);
    Inc(Result.Y, ClientPos.Y - WindowPos.Y);
  end;
end;

function TFormStyleHookEx.GetHitTest(P: TPoint): Integer;
var
  FBorderSize: TRect;
  FTopLeftRect,  FTopRightRect,
  FBottomLeftRect, FBottomRightRect,
  FTopRect, FLeftRect, FRightRect, FBottomRect, FHitCaptionRect: TRect;
begin
  Result := HTCLIENT;
  if Form.BorderStyle = bsNone then
  begin
    if (FMainMenuBarHook <> nil) and FMainMenuBarHook.BoundsRect.Contains(P) then
      Exit(HTMENU)
    else
      Exit;
  end;

  FBorderSize := GetBorderSize;
  FHitCaptionRect := FCaptionRect;
  FHitCaptionRect.Top := FBorderSize.Left;
  FBorderSize.Top := FHitCaptionRect.Top;

  {check buttons}
  if (FMainMenuBarHook <> nil) and FMainMenuBarHook.BoundsRect.Contains(P) then
    Exit(HTMENU)
  else if FHitCaptionRect.Contains(P) then
    Exit(HTCAPTION)
  else if FCloseButtonRect.Contains(P) then
    Exit(HTCLOSE)
  else if FMaxButtonRect.Contains(P) then
    Exit(HTMAXBUTTON)
  else if FMinButtonRect.Contains(P) then
    Exit(HTMINBUTTON)
  else if FHelpButtonRect.Contains(P) then
    Exit(HTHELP)
  else if FSysMenuButtonRect.Contains(P) then
    Exit(HTSYSMENU);

  {check window state}
  if (Form.WindowState = wsMaximized) or
     (Form.WindowState = wsMinimized) then
    Exit;

  {check border}
  if (Form.BorderStyle = bsDialog) or
     (Form.BorderStyle = bsSingle) or
     (Form.BorderStyle = bsToolWindow) then
  begin
    if Rect(FBorderSize.Left, FBorderSize.Top,
       FWidth - FBorderSize.Right, FHeight - FBorderSize.Bottom).Contains(P) then
      Exit(HTCLIENT)
    else
      Exit(HTBORDER);
  end;

  FTopLeftRect := Rect(0, 0, FBorderSize.Left, FBorderSize.Top);
  FTopRightRect := Rect(FWidth - FBorderSize.Right, 0, FWidth, FBorderSize.Top);
  FBottomLeftRect := Rect(0, FHeight - FBorderSize.Bottom, FBorderSize.Left, FHeight);
  FBottomRightRect := Rect(FWidth - FBorderSize.Right, FHeight - FBorderSize.Bottom,
    FWidth, FHeight);
  FTopRect := Rect(FTopLeftRect.Right, 0, FTopRightRect.Left, FBorderSize.Top);
  FLeftRect := Rect(0, FTopLeftRect.Bottom, FBorderSize.Left, FBottomLeftRect.Top);
  FRightRect := Rect(FWidth - FBorderSize.Right, FTopRightRect.Bottom, FWidth, FBottomRightRect.Top);
  FBottomRect := Rect(FBottomLeftRect.Right, FHeight - FBorderSize.Bottom, FBottomRightRect.Left, FHeight);

  if FTopLeftRect.Contains(P) then
    Result := HTTOPLEFT
  else if FTopRightRect.Contains(P) then
    Result := HTTOPRIGHT
  else if FBottomLeftRect.Contains(P) then
    Result := HTBOTTOMLEFT
   else if FBottomRightRect.Contains(P) then
    Result := HTBOTTOMRIGHT
  else if FLeftRect.Contains(P) then
    Result := HTLEFT
  else if FRightRect.Contains(P) then
    Result := HTRIGHT
  else if FBottomRect.Contains(P) then
    Result := HTBOTTOM
  else if FTopRect.Contains(P) then
    Result := HTTOP;
end;

procedure TFormStyleHookEx.CMDialogChar(var Message: TWMKey);
begin
  if (FMainMenuBarHook <> nil) and
     (KeyDataToShiftState(Message.KeyData) = [ssAlt]) and
     FMainMenuBarHook.CheckHotKeyItem(Message.CharCode) then
  begin
    Message.Result := 1;
    Handled := True;
  end;
end;

procedure TFormStyleHookEx.WMSetText(var Message: TMessage);
var
  FRedraw: Boolean;
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;
  FRedraw := True;
  if not (fsShowing in Form.FormState) and IsWindowVisible(Form.Handle) then
  begin
    Application.ProcessMessages;
    FRedraw := False;
    SetRedraw(False);
  end;
  CallDefaultProc(Message);
  if not (fsShowing in Form.FormState) and not FRedraw then
  begin
    SetRedraw(True);
    InvalidateNC;
  end;
  Handled := True;
end;

procedure TFormStyleHookEx.WMMDIChildClose(var Message: TMessage);

function IsAnyMDIChildMaximized: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Form.MDIChildCount - 1 do
    if (FChangeVisibleChildHandle <> Form.MDIChildren[I].Handle) and
       (Form.MDIChildren[I].Visible) and
       (Form.MDIChildren[I].WindowState = wsMaximized) then
    begin
      Result := True;
      Break;
    end;
end;

begin
  FChangeVisibleChildHandle := Message.WParam;
  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) then
  begin
    if IsAnyMDIChildMaximized and not FMainMenuBarHook.ShowMDIButtons then
      FMainMenuBarHook.ShowMDIButtons := True
    else if not IsAnyMDIChildMaximized and FMainMenuBarHook.ShowMDIButtons then
      FMainMenuBarHook.ShowMDIButtons := False;
    InvalidateNC;
  end;
  GetMDIScrollInfo(True);
end;

procedure TFormStyleHookEx.WMDestroy(var Message: TMessage);
begin
 if not (csRecreating in Form.ControlState) and (Form.FormStyle = fsMDIChild) then
   PostMessage(Application.MainForm.Handle, WM_MDICHILDCLOSE, 0, 0);
end;

procedure TFormStyleHookEx.WMSysCommand(var Message: TMessage);
begin
  if IsStyleBorder then
    case Message.WParam  of
      SC_CLOSE:
        if Form.FormStyle = fsMDIChild then
         PostMessage(Application.MainForm.Handle, WM_MDICHILDCLOSE,
           Winapi.Windows.WPARAM(Form.Handle), 0);
      SC_MINIMIZE:
        if Form.FormStyle = fsMDIChild then
         FFormActive := False;
      SC_KEYMENU:
       begin
         if TMainMenuBarStyleHook(FMainMenuBarHook) <> nil then
         begin
           FMainMenuBarHook.MenuActive := True;
           FMainMenuBarHook.EnterWithKeyboard := True;
           FMainMenuBarHook.MenuEnter(False);
           Handled := True;
         end;
       end;
    end;
end;

procedure TFormStyleHookEx.WMInitMenu(var Message: TMessage);
begin
  if (WPARAM(GetMenu(Control.Handle)) = Message.wParam) and IsStyleBorder then
    SetMenu(Control.Handle, 0);
end;

procedure TFormStyleHookEx.CMMenuChanged(var Message: TMessage);
begin
  if IsStyleBorder then
  begin
    if GetMenu(Control.Handle) <> 0 then
      SetMenu(Control.Handle, 0);
     Handled := True;
  end;
end;

procedure TFormStyleHookEx.WMNCHitTest(var Message: TWMNCHitTest);
var
  P: TPoint;
begin
  if IsStyleBorder then
  begin
    P := NormalizePoint(Point(Message.XPos, Message.YPos));
    Message.Result := GetHitTest(P);
    Handled := True;
  end;
end;

procedure TFormStyleHookEx.WMNCCalcSize(var Message: TWMNCCalcSize);
var
  Params: PNCCalcSizeParams;
  R, MenuRect: TRect;
  MenuHeight: Integer;
  BorderSize: Integer;
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;
  {check menu info}
  if (Form.FormStyle = fsMDIChild) then
    TMainMenuBarStyleHook(FMainMenuBarHook) := nil
  else if (Form.Menu <> nil) and not Form.Menu.AutoMerge and
          (Form.Menu.Items.Count > 0) and (TMainMenuBarStyleHook(FMainMenuBarHook) = nil) then
    TMainMenuBarStyleHook(FMainMenuBarHook) := TFormStyleHookEx.TMainMenuBarStyleHook.Create(Self)
  else if ((Form.Menu = nil) or
          ((Form.Menu <> nil) and (Form.Menu.Items.Count = 0))) and
          (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) then
    TMainMenuBarStyleHook(FMainMenuBarHook) := nil;
  {calc NC info}
  if (Message.CalcValidRects and (Form.BorderStyle <> bsNone)) or
     ((Form.BorderStyle = bsNone) and (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil))
  then
  begin
    R := GetBorderSize;

    if TMainMenuBarStyleHook(FMainMenuBarHook) <> nil then
    begin
      MenuHeight := FMainMenuBarHook.GetMenuHeight(FWidth - R.Left - R.Right);
      MenuRect := Rect(R.Left, R.Top, FWidth - R.Right, R.Top + MenuHeight);
      FMainMenuBarHook.BoundsRect := MenuRect;
    end
    else
      MenuHeight := 0;
    Params := Message.CalcSize_Params;
    with Params^.rgrc[0] do
    begin
      Inc(Left, R.Left);
      Inc(Top, R.Top + MenuHeight);
      Dec(Right, R.Right);
      Dec(Bottom, R.Bottom);
              
      //hack of Aero Maximize
      if (Form.WindowState = wsMaximized) and DwmCompositionEnabled then
      begin
        BorderSize := GetSystemMetrics(SM_CXSIZEFRAME);
        Inc(Left, -R.Left + BorderSize);
        Dec(Right, -R.Right + BorderSize);
        Dec(Bottom, -R.Bottom + BorderSize);
      end;
    end;
    
    Handled := True;
  end;
end;

function TFormStyleHookEx.GetIconFast: TIcon;
begin
  if (FIcon = nil) or (FIconHandle = 0) then
    Result := GetIcon
  else
    Result := FIcon;
end;

function TFormStyleHookEx.GetIcon: TIcon;
var
  IconX, IconY: Integer;
  TmpHandle: THandle;
  Info: TWndClassEx;
  Buffer: array [0..255] of Char;
begin
  TmpHandle := THandle(SendMessage(Handle, WM_GETICON, ICON_SMALL, 0));
  if TmpHandle = 0 then
    TmpHandle := THandle(SendMessage(Handle, WM_GETICON, ICON_BIG, 0));
  if TmpHandle = 0 then
  begin
    { Get instance }
    GetClassName(Handle, @Buffer, SizeOf(Buffer));
    FillChar(Info, SizeOf(Info), 0);
    Info.cbSize := SizeOf(Info);

    if GetClassInfoEx(GetWindowLong(Handle, GWL_HINSTANCE), @Buffer, Info) then
    begin
      TmpHandle := Info.hIconSm;
      if TmpHandle = 0 then
        TmpHandle := Info.hIcon;
    end
  end;

  if FIcon = nil then
    FIcon := TIcon.Create;
  if TmpHandle <> 0 then
  begin
    IconX := GetSystemMetrics(SM_CXSMICON);
    if IconX = 0 then
      IconX := GetSystemMetrics(SM_CXSIZE);
    IconY := GetSystemMetrics(SM_CYSMICON);
    if IconY = 0 then
      IconY := GetSystemMetrics(SM_CYSIZE);
    FIcon.Handle := CopyImage(TmpHandle, IMAGE_ICON, IconX, IconY, 0);
    FIconHandle := TmpHandle;
  end;

  Result := FIcon;
end;

procedure TFormStyleHookEx.PaintNC(Canvas: TCanvas);
var
  Details, CaptionDetails, IconDetails: TThemedElementDetails;
  Detail: TThemedWindow;
  R, R1, DrawRect, ButtonRect, TextRect: TRect;
  CaptionBuffer: TBitmap;
  FButtonState: TThemedWindow;
  TextFormat: TTextFormat;
  LText: string;
  TextTopOffset: Integer;

  function GetTopOffset: Integer;
  var
    P: TPoint;
  begin
    P.X := Form.Left + Form.Width div 2;
    P.Y := Form.Top + Form.Height div 2;
    Result := Screen.MonitorFromPoint(P).WorkareaRect.Top;
    if Form.Top < Result then Result := Result - Form.Top else Result := 0;
  end;

  procedure CorrectRightButtonRect(var AButtonRect: TRect);
  var
    TopOffset, RightOffset: Integer;
    BS: TRect;
  begin
    if (Form.WindowState = wsMaximized) and (Form.FormStyle <> fsMDIChild) and (ButtonRect.Width > 0) then
    begin
      BS := GetBorderSize;
      TopOffset := GetTopOffset;
      RightOffset := -BS.Right;
      if ButtonRect.Top < TopOffset then
      begin
        TopOffset := TopOffset - ButtonRect.Top;
        OffsetRect(ButtonRect, RightOffset, TopOffset);
        TopOffset := ButtonRect.Bottom - BS.Top;
        if TopOffset > 0 then
          OffsetRect(ButtonRect, 0, -TopOffset);
      end; 
    end;
  end;

  procedure CorrectLeftButtonRect(var AButtonRect: TRect);
  var
    TopOffset, LeftOffset: Integer;
    BS: TRect;
  begin
    if (Form.WindowState = wsMaximized) and (Form.FormStyle <> fsMDIChild) and (ButtonRect.Width > 0) then
    begin
      BS := GetBorderSize;
      TopOffset := GetTopOffset;
      LeftOffset := BS.Left;
      if ButtonRect.Top < TopOffset then
      begin
        TopOffset := TopOffset - ButtonRect.Top;
        OffsetRect(ButtonRect, LeftOffset, TopOffset);
        TopOffset := ButtonRect.Bottom - BS.Top;
        if TopOffset > 0 then
          OffsetRect(ButtonRect, 0, -TopOffset);
      end; 
    end;
  end;

begin
  if Form.BorderStyle = bsNone then
  begin
    if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) then
      FMainMenuBarHook.Paint(Canvas);
    Exit;
  end;

  {init some parameters}
  FCloseButtonRect := Rect(0, 0, 0, 0);
  FMaxButtonRect := Rect(0, 0, 0, 0);
  FMinButtonRect := Rect(0, 0, 0, 0);
  FHelpButtonRect := Rect(0, 0, 0, 0);
  FSysMenuButtonRect := Rect(0, 0, 0, 0);
  FCaptionRect := Rect(0, 0, 0, 0);

  if not StyleServices.Available then
    Exit;
  R := GetBorderSize;

  {draw caption}

  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
  begin
    if FFormActive then
      Detail := twCaptionActive
    else
      Detail := twCaptionInActive
  end
  else
  begin
   if FFormActive then
      Detail := twSmallCaptionActive
    else
      Detail := twSmallCaptionInActive
  end;
  CaptionBuffer := TBitmap.Create;
  CaptionBuffer.SetSize(FWidth, R.Top);

  {draw caption border}
  DrawRect := Rect(0, 0, CaptionBuffer.Width, CaptionBuffer.Height);
  Details := StyleServices.GetElementDetails(Detail);
  StyleServices.DrawElement(CaptionBuffer.Canvas.Handle, Details, DrawRect);
  TextRect := DrawRect;
  CaptionDetails := Details;
  TextTopOffset := 3;

  {draw icon}
  if (biSystemMenu in Form.BorderIcons) and
     (Form.BorderStyle <> bsDialog) and
     (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
  begin
    IconDetails := StyleServices.GetElementDetails(twSysButtonNormal);
    if not StyleServices.GetElementContentRect(0, IconDetails, DrawRect, ButtonRect) then
      ButtonRect := Rect(0, 0, 0, 0);

    R1 := ButtonRect;

    if not StyleServices.HasElementFixedPosition(Details) then
    begin
      CorrectLeftButtonRect(ButtonRect);
      TextTopOffset := Abs(R1.Top - ButtonRect.Top);
      if TextTopOffset > R.Top then TextTopOffset := 3;
    end
    else
      TextTopOffset := 0;

    R1 := Rect(0, 0, GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON));
    RectVCenter(R1, ButtonRect);
    if ButtonRect.Width > 0 then
      DrawIconEx(CaptionBuffer.Canvas.Handle, R1.Left, R1.Top, GetIconFast.Handle, 0, 0, 0, 0, DI_NORMAL);
    Inc(TextRect.Left, ButtonRect.Width + 5);
    FSysMenuButtonRect := ButtonRect;
  end
  else
    Inc(TextRect.Left, R.Left);

  {draw buttons}
  if (biSystemMenu in Form.BorderIcons) then
  begin
    if (Form.BorderStyle <> bsToolWindow) and
       (Form.BorderStyle <> bsSizeToolWin) then
    begin
      if (FPressedButton = HTCLOSE) and (FHotButton = HTCLOSE) then
        FButtonState := twCloseButtonPushed
      else if FHotButton = HTCLOSE then
        FButtonState := twCloseButtonHot
      else
        if FFormActive then
          FButtonState := twCloseButtonNormal
        else
          FButtonState := twCloseButtonDisabled;
     end
    else
    begin
      if (FPressedButton = HTCLOSE) and (FHotButton = HTCLOSE) then
        FButtonState := twSmallCloseButtonPushed
      else if FHotButton = HTCLOSE then
        FButtonState := twSmallCloseButtonHot
      else
        if FFormActive then
          FButtonState := twSmallCloseButtonNormal
        else
          FButtonState := twSmallCloseButtonDisabled;
    end;

    Details := StyleServices.GetElementDetails(FButtonState);
    if not StyleServices.GetElementContentRect(0, Details, DrawRect, ButtonRect) then
      ButtonRect := Rect(0, 0, 0, 0);

    if not StyleServices.HasElementFixedPosition(Details) then
      CorrectRightButtonRect(ButtonRect);

    if ButtonRect.Width > 0 then
      StyleServices.DrawElement(CaptionBuffer.Canvas.Handle, Details, ButtonRect);

    if ButtonRect.Left > 0 then
      TextRect.Right := ButtonRect.Left;
    FCloseButtonRect := ButtonRect;
  end;

  if (biMaximize in Form.BorderIcons) and
     (biSystemMenu in Form.BorderIcons) and
     (Form.BorderStyle <> bsDialog) and
     (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
  begin
    if Form.WindowState = wsMaximized then
    begin
      if (FPressedButton = HTMAXBUTTON) and (FHotButton = HTMAXBUTTON) then
        FButtonState := twRestoreButtonPushed
      else if FHotButton = HTMAXBUTTON then
        FButtonState := twRestoreButtonHot
      else
      if FFormActive then
        FButtonState := twRestoreButtonNormal
      else
        FButtonState := twRestoreButtonDisabled;
    end
    else
    begin
      if (FPressedButton = HTMAXBUTTON) and (FHotButton = HTMAXBUTTON) then
        FButtonState := twMaxButtonPushed
      else if FHotButton = HTMAXBUTTON then
        FButtonState := twMaxButtonHot
      else
      if FFormActive then
        FButtonState := twMaxButtonNormal
      else
        FButtonState := twMaxButtonDisabled;
    end;
    Details := StyleServices.GetElementDetails(FButtonState);

    if not StyleServices.GetElementContentRect(0, Details, DrawRect, ButtonRect) then
      ButtonRect := Rect(0, 0, 0, 0);

    if not StyleServices.HasElementFixedPosition(Details) then
     CorrectRightButtonRect(ButtonRect);

    if ButtonRect.Width > 0 then
      StyleServices.DrawElement(CaptionBuffer.Canvas.Handle, Details, ButtonRect);
    if ButtonRect.Left > 0 then
      TextRect.Right := ButtonRect.Left;
    FMaxButtonRect := ButtonRect;
  end;

  if (biMinimize in Form.BorderIcons) and
     (biSystemMenu in Form.BorderIcons) and
     (Form.BorderStyle <> bsDialog) and
     (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
  begin
    if (FPressedButton = HTMINBUTTON) and (FHotButton = HTMINBUTTON) then
      FButtonState := twMinButtonPushed
    else if FHotButton = HTMINBUTTON then
      FButtonState := twMinButtonHot
    else
      if FFormActive then
        FButtonState := twMinButtonNormal
      else
        FButtonState := twMinButtonDisabled;

    Details := StyleServices.GetElementDetails(FButtonState);

    if not StyleServices.GetElementContentRect(0, Details, DrawRect, ButtonRect) then
      ButtonRect := Rect(0, 0, 0, 0);

    if not StyleServices.HasElementFixedPosition(Details) then
      CorrectRightButtonRect(ButtonRect);

    if ButtonRect.Width > 0 then
      StyleServices.DrawElement(CaptionBuffer.Canvas.Handle, Details, ButtonRect);
    if ButtonRect.Left > 0 then TextRect.Right := ButtonRect.Left;
    FMinButtonRect := ButtonRect;
  end;

  if (biHelp in Form.BorderIcons) and (biSystemMenu in Form.BorderIcons) and
     ((not (biMaximize in Form.BorderIcons) and
     not (biMinimize in Form.BorderIcons)) or (Form.BorderStyle = bsDialog))
  then
  begin
    if (FPressedButton = HTHELP) and (FHotButton = HTHELP) then
      FButtonState := twHelpButtonPushed
    else if FHotButton = HTHELP then
      FButtonState := twHelpButtonHot
    else
    if FFormActive then
      FButtonState := twHelpButtonNormal
    else
      FButtonState := twHelpButtonDisabled;
    Details := StyleServices.GetElementDetails(FButtonState);

    if not StyleServices.GetElementContentRect(0, Details, DrawRect, ButtonRect) then
      ButtonRect := Rect(0, 0, 0, 0);

    if not StyleServices.HasElementFixedPosition(Details) then
      CorrectRightButtonRect(ButtonRect);

    if ButtonRect.Width > 0 then
      StyleServices.DrawElement(CaptionBuffer.Canvas.Handle, Details, ButtonRect);

    if ButtonRect.Left > 0 then
      TextRect.Right := ButtonRect.Left;
    FHelpButtonRect := ButtonRect;
  end;

  {draw text}
  TextFormat := [tfLeft, tfSingleLine, tfVerticalCenter];
  if Control.UseRightToLeftReading then
    Include(TextFormat, tfRtlReading);
  // Important: Must retrieve Text prior to calling DrawText as it causes
  // CaptionBuffer.Canvas to free its handle, making the outcome of the call
  // to DrawText dependent on parameter evaluation order.
  LText := Text;

  if (Form.WindowState = wsMaximized) and (Form.FormStyle <> fsMDIChild) and
     (TextTopOffset <> 0) and (biSystemMenu in Form.BorderIcons) then
  begin
    Inc(TextRect.Left, R.Left);
    MoveWindowOrg(CaptionBuffer.Canvas.Handle, 0, TextTopOffset);
    StyleServices.DrawText(CaptionBuffer.Canvas.Handle, CaptionDetails, LText, TextRect, TextFormat);
    MoveWindowOrg(CaptionBuffer.Canvas.Handle, 0, -TextTopOffset);
  end
  else
    StyleServices.DrawText(CaptionBuffer.Canvas.Handle, CaptionDetails, LText, TextRect, TextFormat);

  FCaptionRect := TextRect;

  {draw caption buffer}

  Canvas.Draw(0, 0, CaptionBuffer);
  CaptionBuffer.Free;

  {draw menubar}
  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) then
    FMainMenuBarHook.Paint(Canvas);

  {draw left border}

  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
  begin
    if FFormActive then
      Detail := twFrameLeftActive
    else
      Detail := twFrameLeftInActive
  end
  else
  begin
    if FFormActive then
      Detail := twSmallFrameLeftActive
    else
      Detail := twSmallFrameLeftInActive
  end;
  DrawRect := Rect(0, R.Top, R.Left, FHeight - R.Bottom);   
  
  Details := StyleServices.GetElementDetails(Detail);

  if DrawRect.Bottom - DrawRect.Top > 0 then
    StyleServices.DrawElement(Canvas.Handle, Details, DrawRect);

  {draw right border}
  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
  begin
    if FFormActive then
      Detail := twFrameRightActive
    else
      Detail := twFrameRightInActive
  end
  else
  begin
   if FFormActive then
      Detail := twSmallFrameRightActive
    else
      Detail := twSmallFrameRightInActive
  end;
  DrawRect := Rect(FWidth - R.Right, R.Top, FWidth, FHeight - R.Bottom);   
  Details := StyleServices.GetElementDetails(Detail);

  if DrawRect.Bottom - DrawRect.Top > 0 then
    StyleServices.DrawElement(Canvas.Handle, Details, DrawRect);

  {draw Bottom border}
  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
  begin
    if FFormActive then
      Detail := twFrameBottomActive
    else
      Detail := twFrameBottomInActive
  end
  else
  begin
   if FFormActive then
      Detail := twSmallFrameBottomActive
    else
      Detail := twSmallFrameBottomInActive
  end;

  DrawRect := Rect(0, FHeight - R.Bottom, FWidth, FHeight);

  Details := StyleServices.GetElementDetails(Detail);

  if DrawRect.Bottom - DrawRect.Top > 0 then
    StyleServices.DrawElement(Canvas.Handle, Details, DrawRect);
end;

procedure TFormStyleHookEx.WMNCACTIVATE(var Message: TMessage);
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;

  FFormActive := Message.WParam > 0;

  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and FMainMenuBarHook.InMenuLoop then
    FMainMenuBarHook.InMenuLoop := False;

  if (Form.FormStyle = fsMDIChild) then
  begin
    if (Form.FormStyle = fsMDIChild) and (Win32MajorVersion >=6) then
      SetRedraw(False);

    CallDefaultProc(Message);

    if (Form.FormStyle = fsMDIChild) and (Win32MajorVersion >=6) then
    begin
      SetRedraw(True);
      if not (csDestroying in Control.ComponentState) and
         not (csLoading in Control.ComponentState) then
        RedrawWindow(Handle, nil, 0, RDW_INVALIDATE + RDW_ALLCHILDREN + RDW_UPDATENOW);
    end;
  end
  else
    Message.Result := 1;

  if Form.ClientHandle <> 0 then
    PostMessage(TForm(Control).ClientHandle, WM_NCACTIVATE, Message.WParam, Message.LParam);

  if (Form.BorderStyle <> bsNone) and
     not ((Form.FormStyle = fsMDIChild) and
     (Form.WindowState = wsMaximized)) then
    InvalidateNC;

  Handled := True;
end;

function TFormStyleHookEx.GetRegion: HRgn;
var
  R: TRect;
  Details: TThemedElementDetails;
  Detail: TThemedWindow;
  RWindow, RTheme: HRGN;
  BorderSize: Integer;
begin
  Result := 0;
  if not StyleServices.Available then
    Exit;

  R := Rect(0, 0, FWidth, FHeight);
  if (Form.BorderStyle <> bsToolWindow) and
     (Form.BorderStyle <> bsSizeToolWin) then
    Detail := twCaptionActive
  else
    Detail := twSmallCaptionActive;
  Details := StyleServices.GetElementDetails(Detail);
  StyleServices.GetElementRegion(Details, R, Result);

  //hack of Aero Maximize
  if DwmCompositionEnabled and (Form.BorderStyle = bsSizeable) then
  begin
    RTheme := Result;
    BorderSize := GetSystemMetrics(SM_CXSIZEFRAME);
    RWindow := CreateRectRgn(0, 0, Form.Monitor.WorkareaRect.Width + BorderSize, Form.Monitor.WorkareaRect.Height + BorderSize);
    Result := CreateRectRgn(0, 0, 0, 0);
    CombineRgn(Result, RTheme, RWindow, RGN_AND);
    DeleteObject(RTheme);
    DeleteObject(RWindow);
  end;
end;

procedure TFormStyleHookEx.ChangeSize;
var
  TempRegion: HRGN;
  R: TRect;
begin
  FChangeSizeCalled := True;
  try
    if IsIconic(Handle) then
     begin
       R := GetBorderSize;
       FHeight := R.Top + R.Bottom;
     end;

    if Form.BorderStyle <> bsNone then
    begin
      TempRegion := FRegion;
      try
        FRegion := GetRegion;
        SetWindowRgn(Handle, FRegion, True);
      finally
        if TempRegion <> 0 then
          DeleteObject(TempRegion);
     end;
    end
    else
    if (Form.BorderStyle = bsNone) and (FRegion <> 0) then
    begin
      SetWindowRgn(Handle, 0, True);
      DeleteObject(FRegion);
      FRegion := 0;
    end;
  finally
    FChangeSizeCalled := False;
  end;
end;

procedure TFormStyleHookEx.WMMove(var Message: TWMMOVE);
begin
  if Form.FormStyle = fsMDIChild then
  begin
    CallDefaultProc(TMessage(Message));
    SendMessage(Application.MainForm.Handle, WM_MDICHILDMOVE, 0, 0);
    Handled := True;
  end;
end;

procedure TFormStyleHookEx.WMMDIChildMove(var Message: TMessage);
begin
  if (Form.FormStyle = fsMDIForm) and not FStopCheckChildMove then
  begin
    FChangeVisibleChildHandle := Message.WParam;
    GetMDIScrollInfo(True);
    FChangeVisibleChildHandle := 0;
    if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and IsStyleBorder then
    begin

      if MDIChildMaximized and not FMainMenuBarHook.ShowMDIButtons then
        FMainMenuBarHook.ShowMDIButtons := True
      else if not MDIChildMaximized and FMainMenuBarHook.ShowMDIButtons then
        FMainMenuBarHook.ShowMDIButtons := False;
    end;
    Handled := True;
  end;
end;

procedure TFormStyleHookEx.WMSize(var Message: TWMSize);
begin
  if IsIconic(Handle) and (Application.MainForm.Handle <> Handle) and IsStyleBorder then
    InvalidateNC;

  if (FMDIClientInstance <> nil) then
  begin
    CallDefaultProc(TMessage(Message));
    GetMDIScrollInfo(True);
    Handled := True;
    Exit;
  end;

  if Form.FormStyle = fsMDIChild then
  begin
    CallDefaultProc(TMessage(Message));
    SendMessage(Application.MainForm.Handle, WM_MDICHILDMOVE, 0, 0);
    if IsIconic(Handle) and IsStyleBorder then
      InvalidateNC;
    Handled := True;
  end;

end;

procedure TFormStyleHookEx.WMWindowPosChanging(var Message: TWMWindowPosChanging);
var
  Changed: Boolean;
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;

  CallDefaultProc(TMessage(Message));

  Handled := True;
  Changed := False;

  if FChangeSizeCalled then
    Exit;

  if (Message.WindowPos^.flags and SWP_NOSIZE = 0) or
     (Message.WindowPos^.flags and SWP_NOMOVE = 0) then
  begin
    if (Message.WindowPos^.flags and SWP_NOMOVE = 0) then
    begin
      FLeft := Message.WindowPos^.x;
      FTop := Message.WindowPos^.y;
    end;
    if (Message.WindowPos^.flags and SWP_NOSIZE = 0) then
    begin
      Changed := ((Message.WindowPos^.cx <> FWidth) or (Message.WindowPos^.cy <> FHeight)) and
                 (Message.WindowPos^.flags and SWP_NOSIZE = 0);
      FWidth := Message.WindowPos^.cx;
      FHeight := Message.WindowPos^.cy;
    end;
  end;

  if (Message.WindowPos^.flags and SWP_FRAMECHANGED  <> 0) then
    Changed := True;

  if Changed then
  begin
    ChangeSize;
    if Form.BorderStyle <> bsNone then
      InvalidateNC;
  end;
end;

procedure TFormStyleHookEx.WndProc(var Message: TMessage);
begin
  // Reserved for potential updates
  inherited;
end;

procedure TFormStyleHookEx.UpdateForm;
begin
  if Form.BorderStyle = bsNone then Exit;

  Control.Width := Control.Width - 1;
  Control.Width := Control.Width + 1;
end;

procedure TFormStyleHookEx.WMNCMouseMove(var Message: TWMNCHitMessage);
var
  P: TPoint;
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;

  inherited;

  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and (Message.HitTest = HTMENU) then
  begin
    P := NormalizePoint(Point(Message.XCursor, Message.YCursor));
    P.X := P.X - FMainMenuBarHook.BoundsRect.Left;
    P.Y := P.Y - FMainMenuBarHook.BoundsRect.Top;
    FMainMenuBarHook.MouseMove(P.X, P.Y);
    Handled := True;
  end
  else if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and FMainMenuBarHook.MouseInMainMenu and (Message.HitTest <> HTMENU) then
    FMainMenuBarHook.MouseMove(-1, -1);


  if (Message.HitTest = HTCLOSE) or (Message.HitTest = HTMAXBUTTON) or
     (Message.HitTest = HTMINBUTTON) or (Message.HitTest = HTHELP) then
  begin
    if FHotButton <> Message.HitTest then
    begin
      FHotButton := Message.HitTest;
      InvalidateNC;
    end;
    Message.Result := 0;
    Message.Msg := WM_NULL;
    Handled := True;
  end
  else if FHotButton <> 0 then
   begin
     FHotButton := 0;
     InvalidateNC;
   end;
end;

procedure TFormStyleHookEx.WMNCRButtonDown(var Message: TWMNCHitMessage);
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;

  inherited;
  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and (Message.HitTest = HTMENU) then
    Handled := True;
end;

procedure TFormStyleHookEx.WMNCLButtonDown(var Message: TWMNCHitMessage);
var
  P: TPoint;
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;

  inherited;

  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and FMainMenuBarHook.MustActivateMDIChildSysMenu then
  begin
    FMainMenuBarHook.InMenuLoop := False;
    FMainMenuBarHook.MustActivateMDIChildSysMenu := False;
    FMainMenuBarHook.TrackMDIChildSystemMenu;
    Handled := True;
    Exit;
  end;

  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and FMainMenuBarHook.MustActivateSysMenu then
  begin
    FMainMenuBarHook.InMenuLoop := False;
    FMainMenuBarHook.MustActivateSysMenu := False;
    FMainMenuBarHook.TrackSystemMenu;
    Handled := True;
    Exit;
  end;

  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and FMainMenuBarHook.MustActivateMenuItem then
  begin
    FMainMenuBarHook.InMenuLoop := False;
    FMainMenuBarHook.MustActivateMenuItem := False;
    FMainMenuBarHook.ProcessMenuLoop(True);
    Handled := True;
    Exit;
  end;

  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and (Message.HitTest = HTMENU) then
  begin
    P := NormalizePoint(Point(Message.XCursor, Message.YCursor));
    P.X := P.X - FMainMenuBarHook.BoundsRect.Left;
    P.Y := P.Y - FMainMenuBarHook.BoundsRect.Top;
    FMainMenuBarHook.MouseDown(P.X, P.Y);
    Handled := True;
  end;

  if (Message.HitTest = HTCLOSE) or (Message.HitTest = HTMAXBUTTON) or
     (Message.HitTest = HTMINBUTTON) or (Message.HitTest = HTHELP) then
  begin
    FPressedButton := Message.HitTest;
    InvalidateNC;
    Message.Result := 0;
    Message.Msg := WM_NULL;
    Handled := True;
  end;

end;

procedure TFormStyleHookEx.WMNCRButtonUp(var Message: TWMNCHitMessage);
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;

  // call system menu
  if (Message.HitTest = HTCAPTION) and FCaptionEmulation then
  begin
    SendMessage(Handle, $313, 0,
      MakeLong(Message.XCursor, Message.YCursor));
  end;
end;

procedure TFormStyleHookEx.WMNCLButtonUp(var Message: TWMNCHitMessage);
var
  FWasPressedButton: Integer;
  P: TPoint;
begin
  if not IsStyleBorder then
  begin
    Handled := False;
    Exit;
  end;

  FWasPressedButton := FPressedButton;

  if FPressedButton <> 0 then
  begin
    FPressedButton := 0;
    InvalidateNC;
  end;

  if (TMainMenuBarStyleHook(FMainMenuBarHook) <> nil) and (Message.HitTest = HTMENU) then
  begin
    P := NormalizePoint(Point(Message.XCursor, Message.YCursor));
    P.X := P.X - FMainMenuBarHook.BoundsRect.Left;
    P.Y := P.Y - FMainMenuBarHook.BoundsRect.Top;
    FMainMenuBarHook.MouseUp(P.X, P.Y);
    Handled := True;
  end;

  if (Message.HitTest = HTTOP) or (Message.HitTest = HTBOTTOM) or (Message.HitTest = HTLEFT) or
     (Message.HitTest = HTRIGHT) or (Message.HitTest = HTCAPTION) or (Message.HitTest = HTTOPLEFT) or
     (Message.HitTest = HTTOPRIGHT) or (Message.HitTest = HTBOTTOMRIGHT) or
     (Message.HitTest = HTBOTTOMLEFT) or (Message.HitTest = HTSYSMENU) then
  begin
    Exit;
  end;

  if FWasPressedButton = FHotButton then
    if Message.HitTest = HTCLOSE then
      Close
    else if (Message.HitTest = HTMAXBUTTON) and (biMaximize in Form.BorderIcons) then
    begin
      if Form.WindowState <> wsMaximized then
        Maximize
      else
        Restore;
    end
    else if (Message.HitTest = HTMINBUTTON) and (biMinimize in Form.BorderIcons) then
    begin
      if Form.WindowState <> wsMinimized then
        Minimize
      else
        Restore;
    end
    else if (Message.HitTest = HTHELP) and (biHelp in Form.BorderIcons) then
      Help;

  Message.Result := 0;
  Message.Msg := WM_NULL;
  Handled := True;
end;

procedure TFormStyleHookEx.WMNCLButtonDblClk(var Message: TWMNCHitMessage);
begin
  inherited;

  if (Message.HitTest = HTTOP) or (Message.HitTest = HTBOTTOM) or (Message.HitTest = HTLEFT) or
     (Message.HitTest = HTRIGHT) or (Message.HitTest = HTCAPTION) or (Message.HitTest = HTTOPLEFT) or
     (Message.HitTest = HTTOPRIGHT) or (Message.HitTest = HTBOTTOMRIGHT) or (Message.HitTest = HTBOTTOMLEFT) then
  begin
    Exit;
  end;

  Message.Result := 0;
  Message.Msg := WM_NULL;
  Handled := True;
end;

procedure TFormStyleHookEx.MouseEnter;
begin
  inherited;
  FPressedButton := 0;
end;

procedure TFormStyleHookEx.MouseLeave;
begin
  inherited;
  if FHotButton <> 0 then
  begin
    FHotButton := 0;
    FPressedButton := 0;
    if Form.BorderStyle <> bsNone then
      InvalidateNC;
  end;
  if TMainMenuBarStyleHook(FMainMenuBarHook) <> nil then
    FMainMenuBarHook.MouseMove(-1, -1);
end;

procedure TFormStyleHookEx.WMActivate(var Message: TWMActivate);
begin
  if IsStyleBorder then
  begin
    CallDefaultProc(TMessage(Message));
    FFormActive := Message.Active > 0;
    Handled := True;
  end;
end;

procedure TFormStyleHookEx.WMNCUAHDrawCaption(var Message: TMessage);
begin
  if IsStyleBorder then
  begin
    InvalidateNC;
    Handled := True;
  end;
end;

procedure TFormStyleHookEx.WMShowWindow(var Message: TWMShowWindow);
begin
  if Message.Show and FNeedsUpdate then
  begin
    FNeedsUpdate := False;
    if (Control is TForm) and (TForm(Control).FormStyle = fsMDIForm) and (FMDIClientInstance = nil) then
    begin
      FMDIPrevClientProc := Pointer(GetWindowLong(TForm(Control).ClientHandle, GWL_WNDPROC));
      FMDIClientInstance := MakeObjectInstance(MDIClientWndProc);
      SetWindowLong(TForm(Control).ClientHandle, GWL_WNDPROC, IntPtr(FMDIClientInstance));
      InitMDIScrollBars;
      AdjustMDIScrollBars;
    end;
    if IsStyleBorder and not TStyleManager.SystemStyle.Enabled and (GetWindowLong(Handle, GWL_STYLE) and WS_CAPTION <> 0) and
       not (Form.FormStyle = fsMDIChild) then
    begin
      FCaptionEmulation := True;
      SetWindowLong(Handle, GWL_STYLE,
           GetWindowLong(Handle, GWL_STYLE) and not WS_CAPTION);
    end;
    UpdateForm;
  end;
end;

procedure TFormStyleHookEx.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  R: TRect;
  MM: PMinMaxInfo;
begin
  if IsStyleBorder then
  begin
    CallDefaultProc(TMessage(Message));
    R := GetBorderSize;
    MM := Message.MinMaxInfo;
    MM.ptMaxSize.Y := MM.ptMaxSize.Y;
    MM^.ptMinTrackSize.y := R.Top + R.Bottom;
    Handled := True;
  end;
end;

initialization

finalization
  F(FInstance);

end.
