unit uDBForm;

interface

uses
  Generics.Collections,
  Windows,
  Controls,
  Forms,
  Types,
  Classes,
  uTranslate,
  Graphics,
  SyncObjs,
  Messages,
  ActiveX,
  uVistaFuncs,
  uMemory,
  uGOM,
  uImageSource,
  SysUtils,
  uSysUtils,
  Themes,
  DwmApi,
  {$IFDEF PHOTODB}
  uFastLoad,
  Menus,
  uMainMenuStyleHook,
  uThemesUtils,
  {$ENDIF}
  MultiMon;

type
  TDBForm = class(TForm)
  private
    FWindowID: string;
    FWasPaint: Boolean;
    function GetTheme: {$IFDEF PHOTODB}TDatabaseTheme{$ELSE}TObject{$ENDIF};
  protected
    procedure WndProc(var Message: TMessage); override;
    function GetFormID: string; virtual; abstract;
    procedure DoCreate; override;
    procedure ApplyStyle; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function L(StringToTranslate: string): string; overload;
    function L(StringToTranslate: string; Scope: string): string; overload;
    function LF(StringToTranslate: string; Args: array of const): string;
    procedure BeginTranslate;
    procedure EndTranslate;
    procedure FixFormPosition;
    property FormID: string read GetFormID;
    property WindowID: string read FWindowID;
    property Theme: {$IFDEF PHOTODB}TDatabaseTheme{$ELSE}TObject{$ENDIF} read GetTheme;
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
    procedure GetForms<T: TDBForm>(Forms: TList<T>);
    function Count: Integer;
    property Forms[Index: Integer]: TDBForm read GetFormByIndex; default;
  end;

implementation

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

{ TDBForm }

procedure TDBForm.ApplyStyle;
begin
end;

procedure TDBForm.BeginTranslate;
begin
  TTranslateManager.Instance.BeginTranslate;
end;

constructor TDBForm.Create(AOwner: TComponent);
begin
  inherited;
  FWindowID := GUIDToString(GetGUID);
  TFormCollection.Instance.RegisterForm(Self);
  GOM.AddObj(Self);
  {$IFDEF PHOTODB}
  {$ENDIF}
end;

destructor TDBForm.Destroy;
begin
  GOM.RemoveObj(Self);
  TFormCollection.Instance.UnRegisterForm(Self);
  inherited;
end;

procedure TDBForm.DoCreate;
begin
  inherited;
  {$IFDEF PHOTODB}
  if Menu is TMainMenu then
    TMainMenuStyleHook.RegisterMenu(TMainMenu(Menu));
  if ClassName <> 'TFormManager' then
    TLoad.Instance.RequaredStyle;
  ApplyStyle;
  {$ENDIF}
end;

procedure TDBForm.EndTranslate;
begin
  TTranslateManager.Instance.EndTranslate;
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

function TDBForm.GetTheme: {$IFDEF PHOTODB}TDatabaseTheme{$ELSE}TObject{$ENDIF};
begin
  Result := {$IFDEF PHOTODB}uThemesUtils.Theme{$ELSE}nil{$ENDIF};
end;

function TDBForm.L(StringToTranslate: string; Scope: string): string;
begin
  Result := TTranslateManager.Instance.SmartTranslate(StringToTranslate, Scope)
end;

function TDBForm.LF(StringToTranslate: string; Args: array of const): string;
begin
  Result := FormatEx(L(StringToTranslate), args);
end;

procedure TDBForm.WndProc(var Message: TMessage);
var
  Canvas: TCanvas;
  LDetails: TThemedElementDetails;
  pfEnabled: BOOL;
begin
  //when styles enabled and form is visible -> white rectangle in all client rect
  //it causes flicking on black theme if Aero is enabled
  //this is fix for form startup
  if (Message.Msg = WM_NCPAINT) and StyleServices.Enabled and not FWasPaint then
  begin
    if (Win32MajorVersion >= 6) then
    begin
      DwmIsCompositionEnabled(pfEnabled);
      if pfEnabled then
      begin
        Canvas := TCanvas.Create;
        try
          Canvas.Handle := GetWindowDC(Handle);
          LDetails.Element := teWindow;
          LDetails.Part := 0;
          StyleServices.DrawElement(Canvas.Handle, LDetails, Rect(0, 0, Width, Height));
        finally
          ReleaseDC(Self.Handle, Canvas.Handle) ;
          F(Canvas);
        end;
      end;
    end;
  end;
  if (Message.Msg = WM_PAINT) and StyleServices.Enabled then
    FWasPaint := True;
  inherited;
end;

function TDBForm.L(StringToTranslate: string): string;
begin
  Result := TTranslateManager.Instance.SmartTranslate(StringToTranslate, GetFormID);
end;

var
  FInstance: TFormCollection = nil;

{ TFormManager }

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
    SetVistaFonts(Form);
end;

procedure TFormCollection.UnRegisterForm(Form: TDBForm);
begin
  FForms.Remove(Form);
end;

initialization

finalization
  F(FInstance);

end.
