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
  Vcl.ExtCtrls,

  Dmitry.Utils.System,
  Dmitry.Graphics.Types,

  uMemory,
  uGOM,
  {$IFNDEF EXTERNAL}
  uTranslate,
  {$ENDIF}
  uVistaFuncs,
  {$IFDEF PHOTODB}
  uFastLoad,
  uGraphicUtils,
  {$ENDIF}
  uIDBForm,
  uThemesUtils;

{$R-}

type
  TDBForm = class;

  TDBForm = class(TForm, IInterface, IDBForm)
  private
    FWindowID: string;
    FWasPaint: Boolean;
    FDoPaintBackground: Boolean;
    FRefCount: Integer;
    FIsRestoring: Boolean;
    FIsMinimizing: Boolean;
    FIsMaximizing: Boolean;

    {$IFDEF PHOTODB}
    FMaskPanel: TPanel;
    FMaskImage: TImage;
    FMaskCount: Integer;
    {$ENDIF PHOTODB}
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
    function CanUseMaskingForModal: Boolean; virtual;
    function DisableMasking: Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Restore;
    function L(StringToTranslate: string): string; overload;
    function L(StringToTranslate: string; Scope: string): string; overload;
    function LF(StringToTranslate: string; Args: array of const): string;
    procedure BeginTranslate;
    procedure EndTranslate;
    procedure FixFormPosition;
    function QueryInterfaceEx(const IID: TGUID; out Obj): HResult;

    procedure PrepaireMask;
    procedure ShowMask;
    procedure HideMask;
    function ShowModal: Integer; override;

    property FormID: string read GetFormID;
    property WindowID: string read FWindowID;
    property Theme: TDatabaseTheme read GetTheme;
    property IsRestoring: Boolean read FIsRestoring;
    property IsMinimizing: Boolean read FIsMinimizing;
    property IsMaximizing: Boolean read FIsMaximizing;
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
  if GetCurrentThreadId <> MainThreadID then
    raise Exception.Create('Can''t create form from non-main thread!');

  FRefCount := 0;
  FWindowID := GUIDToString(GetGUID);
  TFormCollection.Instance.RegisterForm(Self);
  GOM.AddObj(Self);

  FIsMaximizing := False;
  FIsMinimizing := False;
  FIsRestoring := False;
  FDoPaintBackground := False;
  {$IFDEF PHOTODB}
  FMaskPanel := nil;
  FMaskImage := nil;
  FMaskCount := 0;
  {$ENDIF}
end;

function TDBForm.CanUseMaskingForModal: Boolean;
begin
  Result := True;
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

function TDBForm.DisableMasking: Boolean;
begin
  Result := False;
end;

procedure TDBForm.DoCreate;
begin
  inherited;
  {$IFDEF PHOTODB}
  if ClassName <> 'TFormManager' then
    TLoad.Instance.RequiredStyle;

  if IsWindowsVista then
  begin
    Updating;
    DisableAlign;
    SetVistaFonts(Self);
    EnableAlign;
    Updated;
  end;

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

procedure TDBForm.HideMask;
begin
  {$IFDEF PHOTODB}
  Dec(FMaskCount);
  if FMaskCount = 0 then
  begin
    BeginScreenUpdate(Handle);
    try
      FMaskPanel.Hide;
      FMaskImage.Picture.Graphic := nil;
    finally
      EndScreenUpdate(Handle, False);
    end;
  end;
  {$ENDIF}
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

procedure BitmapBlur(Bitmap: TBitmap);
var
  x, y: Integer;
  yLine,
  xLine: PByteArray;
begin
  for y := 1 to Bitmap.Height -2 do begin
    yLine := Bitmap.ScanLine[y -1];
    xLine := Bitmap.ScanLine[y];
    for x := 1 to Bitmap.Width -2 do begin
      xLine^[x * 3] := (
        xLine^[x * 3 -3] + xLine^[x * 3 +3] +
        yLine^[x * 3 -3] + yLine^[x * 3 +3] +
        yLine^[x * 3] + xLine^[x * 3 -3] +
        xLine^[x * 3 +3] + xLine^[x * 3]) div 8;
      xLine^[x * 3 +1] := (
        xLine^[x * 3 -2] + xLine^[x * 3 +4] +
        yLine^[x * 3 -2] + yLine^[x * 3 +4] +
        yLine^[x * 3 +1] + xLine^[x * 3 -2] +
        xLine^[x * 3 +4] + xLine^[x * 3 +1]) div 8;
      xLine^[x * 3 +2] := (
        xLine^[x * 3 -1] + xLine^[x * 3 +5] +
        yLine^[x * 3 -1] + yLine^[x * 3 +5] +
        yLine^[x * 3 +2] + xLine^[x * 3 -1] +
        xLine^[x * 3 +5] + xLine^[x * 3 +2]) div 8;
    end;
  end;
end;

procedure TDBForm.PrepaireMask;
{$IFDEF PHOTODB}
var
 Mask: TBitmap;
 I, J: Integer;
 P: PARGB;
 R, G, B, W, W1: Byte;
 Color: TColor;
{$ENDIF}
begin
{$IFDEF PHOTODB}
  Inc(FMaskCount);
  if FMaskCount <> 1 then
    Exit;

  Color := StyleServices.GetStyleColor(scWindow);
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  Mask := TBitmap.Create;
  try
    Mask.PixelFormat := pf24Bit;
    Mask.SetSize(ClientWidth, ClientHeight);
    Mask.Canvas.CopyRect(ClientRect, Canvas, ClientRect);

    W := 128;
    W1 := 255 - W;
    for I := 0 to Mask.Height - 1 do
    begin
      P := Mask.ScanLine[I];
      for J := 0 to Mask.Width - 1 do
      begin
        P[J].R := (R * W + P[J].R * W1) shr 8;
        P[J].G := (G * W + P[J].G * W1) shr 8;
        P[J].B := (B * W + P[J].B * W1) shr 8;
      end;
    end;
    BitmapBlur(Mask);

    if FMaskPanel = nil then
    begin
      FMaskPanel := TPanel.Create(Self);
      FMaskPanel.Visible := False;
      FMaskPanel.Parent := Self;
      FMaskPanel.BevelOuter := bvNone;
      FMaskPanel.ParentBackground := False;
      FMaskPanel.DoubleBuffered := True;
    end;
    FMaskPanel.SetBounds(0, 0, ClientWidth, ClientHeight);

    if FMaskImage = nil then
    begin
      FMaskImage := TImage.Create(Self);
      FMaskImage.Parent := FMaskPanel;
      FMaskImage.Align := alClient;
    end;

    FMaskImage.Picture.Graphic := Mask;
  finally
    Mask.Free;
  end;
  FMaskPanel.BringToFront;
  FMaskPanel.Show;
{$ENDIF}
end;

procedure TDBForm.ShowMask;
begin
{$IFDEF PHOTODB}
  FMaskPanel.Show;
{$ENDIF}
end;

function TDBForm.ShowModal: Integer;
var
  I: Integer;
  Form: TDBForm;
  Forms: TList<TDBForm>;
begin
  if Self.DisableMasking then
    Exit(inherited ShowModal);

  Forms := TList<TDBForm>.Create;
  try
    for I := 0 to Screen.FormCount - 1 do
    begin
      if (Screen.Forms[I] is TDBForm) and (Screen.Forms[I] <> Self) and (Screen.Forms[I].Visible) then
      begin
        Form := TDBForm(Screen.Forms[I]);

        if Form.CanUseMaskingForModal then
          Forms.Add(Form);
      end;
    end;

    for Form in Forms do
      Form.PrepaireMask;

    for Form in Forms do
      Form.ShowMask;

    try
      Result := inherited ShowModal;
    finally
      for Form in Forms do
        Form.HideMask;
    end;

  finally
    F(Forms);
  end;
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
  if Message.SizeType = SIZE_MAXIMIZED then
    FIsMaximizing := True;
  try
    inherited;
  finally
    FIsMinimizing := False;
    FIsRestoring := False;
    if FIsMaximizing then
    begin
      FIsMaximizing := False;
      SendMessage(Handle, WM_NCPAINT, 0, 0);
    end;
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
  if ClassName <> 'TFormManager' then
  begin
    if StyleServices.Enabled and FDoPaintBackground and not FWasPaint then
    begin
      if (Message.Msg = WM_NCPAINT) and (Win32MajorVersion >= 6) then
      begin
        FDoPaintBackground := False;
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
  end else
  begin
    if Message.Msg = WM_SIZE then
      Message.Msg := 0;
  end;

  if (Message.Msg = WM_PAINT) and StyleServices.Enabled then
    FWasPaint := True;

  if (Message.Msg = WM_NCACTIVATE) and StyleServices.Enabled then
    FDoPaintBackground := True;

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
{$IFDEF PHOTODB}
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
{$ENDIF}
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
end;

procedure TFormCollection.UnRegisterForm(Form: TDBForm);
begin
  FForms.Remove(Form);
end;

initialization

finalization
  F(FInstance);

end.
