unit uVistaFuncs;

interface

uses
  System.Types,
  System.Classes,
  System.HelpIntfs,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.MultiMon,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.Themes,

  Dmitry.Utils.System,
  {$IFNDEF EXTERNAL}
  uTranslate,
  {$ENDIF}
  uConstants;

type
  TChangeWindowMessageFilter = function(msg: Cardinal; action: Word): BOOL; stdcall;

procedure SetVistaFonts(const AForm: TCustomForm);
procedure SetVistaContentFonts(const AFont: TFont; Increment: Integer = 2);
procedure SetDesktopIconFonts(const AFont: TFont);
procedure ExtendGlass(const AHandle: THandle; const AMargins: TRect);
function CompositingEnabled: Boolean;
function TaskDialog(Handle: THandle; AContent, ATitle, ADescription: string; Buttons, Icon: Integer): Integer;
procedure SetVistaTreeView(const AHandle: THandle);

function DoTaskMessageDlgPosHelpEx(const Instruction, Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string; DefaultButton: TMsgDlgBtn): Integer; overload;

function DoTaskMessageDlgPosHelpEx(const Instruction, Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer; overload;

procedure AllowDragAndDrop;

const
  VistaFont = 'Segoe UI';
  VistaContentFont = 'Calibri';
  XPContentFont = 'Verdana';
  XPFont = 'Tahoma';

var
  CheckOSVerForFonts: Boolean = True;

implementation

uses
  SysUtils,
  Controls,
  UxTheme;

{$IFDEF EXTERNAL}
function TA(S: string): string;
begin
  Result := S;
end;
{$ENDIF}

procedure SetVistaTreeView(const AHandle: THandle);
begin
  if IsWindowsVista then
    SetWindowTheme(AHandle, 'explorer', nil);
end;

procedure AllowDragAndDrop;
var
  User32Handle: THandle;
  ChangeWindowMessageFilter: TChangeWindowMessageFilter;

const
   MSGFLT_ALLOW = 1;
begin
  User32Handle := LoadLibrary(user32);
  @ChangeWindowMessageFilter := GetProcAddress(User32Handle, 'ChangeWindowMessageFilter');
  if Assigned(ChangeWindowMessageFilter) then
  begin
    //WM_COMMAND for taskbar
    ChangeWindowMessageFilter (WM_COMMAND, MSGFLT_ALLOW);
    ChangeWindowMessageFilter (WM_DROPFILES, MSGFLT_ALLOW);
    ChangeWindowMessageFilter (WM_COPYDATA, MSGFLT_ALLOW);
    ChangeWindowMessageFilter ($0049, MSGFLT_ALLOW);
  end;
  FreeLibrary(User32Handle);
end;

procedure SetVistaFonts(const AForm: TCustomForm);
begin
  if (IsWindowsVista or not CheckOSVerForFonts)
    and not SameText(AForm.Font.Name, VistaFont)
    and (Screen.Fonts.IndexOf(VistaFont) >= 0) then
  begin
    AForm.Font.Size := AForm.Font.Size + 1;
    AForm.Font.Name := VistaFont;
  end;
end;

procedure SetVistaContentFonts(const AFont: TFont; Increment: Integer = 2);
begin
  if (IsWindowsVista or not CheckOSVerForFonts)
    and not SameText(AFont.Name, VistaContentFont)
    and (Screen.Fonts.IndexOf(VistaContentFont) >= 0) then
  begin
    AFont.Size := AFont.Size + Increment;
    AFont.Name := VistaContentFont;
  end;
end;

procedure SetDefaultFonts(const AFont: TFont);
begin
  AFont.Handle := GetStockObject(DEFAULT_GUI_FONT);
end;

procedure SetDesktopIconFonts(const AFont: TFont);
var
  LogFont: TLogFont;
begin
  if SystemParametersInfo(SPI_GETICONTITLELOGFONT, SizeOf(LogFont),
    @LogFont, 0) then
    AFont.Handle := CreateFontIndirect(LogFont)
  else
    SetDefaultFonts(AFont);
end;

const
  dwmapi = 'dwmapi.dll';
  DwmIsCompositionEnabledSig = 'DwmIsCompositionEnabled';
  DwmExtendFrameIntoClientAreaSig = 'DwmExtendFrameIntoClientArea';
  TaskDialogSig = 'TaskDialog';

function CompositingEnabled: Boolean;
var
  DLLHandle: THandle;
  DwmIsCompositionEnabledProc: function(pfEnabled: PBoolean): HRESULT; stdcall;
  Enabled: Boolean;
begin
  Result := False;
  if IsWindowsVista then
  begin
    DLLHandle := LoadLibrary(dwmapi);

    if DLLHandle <> 0 then
    begin
      @DwmIsCompositionEnabledProc := GetProcAddress(DLLHandle,
        DwmIsCompositionEnabledSig);

      if (@DwmIsCompositionEnabledProc <> nil) then
      begin
        DwmIsCompositionEnabledProc(@Enabled);
        Result := Enabled;
      end;

      FreeLibrary(DLLHandle);
    end;
  end;
end;

//from http://www.delphipraxis.net/topic93221,next.html
procedure ExtendGlass(const AHandle: THandle; const AMargins: TRect);
type
  _MARGINS = packed record
    cxLeftWidth: Integer;
    cxRightWidth: Integer;
    cyTopHeight: Integer;
    cyBottomHeight: Integer;
  end;
  PMargins = ^_MARGINS;
  TMargins = _MARGINS;
var
  DLLHandle: THandle;
  DwmExtendFrameIntoClientAreaProc: function(destWnd: HWND; const pMarInset:
    PMargins): HRESULT; stdcall;
  Margins: TMargins;
begin
  if IsWindowsVista and CompositingEnabled then
  begin
    DLLHandle := LoadLibrary(dwmapi);

    if DLLHandle <> 0 then
    begin
      @DwmExtendFrameIntoClientAreaProc := GetProcAddress(DLLHandle,
        DwmExtendFrameIntoClientAreaSig);

      if (@DwmExtendFrameIntoClientAreaProc <> nil) then
      begin
        ZeroMemory(@Margins, SizeOf(Margins));
        Margins.cxLeftWidth := AMargins.Left;
        Margins.cxRightWidth := AMargins.Right;
        Margins.cyTopHeight := AMargins.Top;
        Margins.cyBottomHeight := AMargins.Bottom;

        DwmExtendFrameIntoClientAreaProc(AHandle, @Margins);
      end;

      FreeLibrary(DLLHandle);
    end;
  end;
end;



function GetButtonCaption(DlgBtn: TMsgDlgBtn): string;
begin
  Result := '';
  case DlgBtn of
    TMsgDlgBtn.mbYes:
      Result := TA('Yes');
    TMsgDlgBtn.mbNo:
      Result := TA('No');
    TMsgDlgBtn.mbOK:
      Result := TA('Ok');
    TMsgDlgBtn.mbCancel:
      Result := TA('Cancel');
    TMsgDlgBtn.mbAbort:
      Result := TA('Abort');
    TMsgDlgBtn.mbRetry:
      Result := TA('Retry');
    TMsgDlgBtn.mbIgnore:
      Result := TA('Ignore');
    TMsgDlgBtn.mbAll:
      Result := TA('All');
    TMsgDlgBtn.mbNoToAll:
      Result := TA('No to all');
    TMsgDlgBtn.mbYesToAll:
      Result := TA('Yes to all');
    TMsgDlgBtn.mbHelp:
      Result := TA('Help');
    TMsgDlgBtn.mbClose:
      Result := TA('Close');
  end;
end;

function GetCaptions(MsgDlgType: TMsgDlgType): string;
begin
  case MsgDlgType of
    mtWarning:
      Result := TA('Warning');
    mtError:
      Result := TA('Error');
    mtInformation:
      Result := TA('Information');
    mtConfirmation:
      Result := TA('Confirm');
    mtCustom:
      Result := TA('Custom');
  end;
end;
 // Captions: array[TMsgDlgType] of Pointer = (@SMsgDlgWarning, @SMsgDlgError,
 //   @SMsgDlgInformation, @SMsgDlgConfirm, nil);

{ TaskDialog based message dialog; requires Windows Vista or later }

type
  TTaskMessageDialog = class(TCustomTaskDialog)
  private
    FHelpFile: string;
    FParentWnd: HWND;
    FPosition: TPoint;
  strict protected
    procedure DoOnButtonClicked(AModalResult: Integer; var CanClose: Boolean); override;
    procedure DoOnDialogCreated; override;
    procedure DoOnHelp; override;
  public
    function Execute(ParentWnd: HWND): Boolean; overload; override;
    property HelpFile: string read FHelpFile write FHelpFile;
    property Position: TPoint read FPosition write FPosition;
  end;

const
  tdbHelp = -1;

procedure TTaskMessageDialog.DoOnButtonClicked(AModalResult: Integer;
  var CanClose: Boolean);
begin
  if AModalResult = tdbHelp then
  begin
    CanClose := False;
    DoOnHelp;
  end;
end;

procedure TTaskMessageDialog.DoOnDialogCreated;
var
  Rect: TRect;
  LX, LY: Integer;
  LHandle: HMONITOR;
  LMonitorInfo: TMonitorInfo;
begin
  LX := Position.X;
  LY := Position.Y;
  LHandle := MonitorFromWindow(FParentWnd, MONITOR_DEFAULTTONEAREST);
  LMonitorInfo.cbSize := SizeOf(LMonitorInfo);
  if GetMonitorInfo(LHandle, {$IFNDEF CLR}@{$ENDIF}LMonitorInfo) then
    with LMonitorInfo do
    begin
      GetWindowRect(Handle, Rect);
      if LX < 0 then
        LX := ((rcWork.Right - rcWork.Left) - (Rect.Right - Rect.Left)) div 2;
      if LY < 0 then
        LY := ((rcWork.Bottom - rcWork.Top) - (Rect.Bottom - Rect.Top)) div 2;
      Inc(LX, rcWork.Left);
      Inc(LY, rcWork.Top);
      SetWindowPos(Handle, 0, LX, LY, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
    end;
end;

procedure TTaskMessageDialog.DoOnHelp;
var
  LHelpFile: string;
  LHelpSystem: IHelpSystem;
begin
  if HelpContext <> 0 then
  begin
    if FHelpFile = '' then
      LHelpFile := Application.HelpFile
    else
      LHelpFile := HelpFile;
    if System.HelpIntfs.GetHelpSystem(LHelpSystem) then
    try
      LHelpSystem.Hook(Application.Handle, LHelpFile, HELP_CONTEXT, HelpContext);
    except
      on E: Exception do
        ShowHelpException(E);
    end;
  end;
end;

function TTaskMessageDialog.Execute(ParentWnd: HWND): Boolean;
begin
  FParentWnd := ParentWnd;
  Result := inherited Execute(ParentWnd);
end;

function DoTaskMessageDlgPosHelpEx(const Instruction, Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string; DefaultButton: TMsgDlgBtn): Integer;
const
  IconMap: array[TMsgDlgType] of TTaskDialogIcon = (tdiWarning, tdiError,
    tdiInformation, tdiInformation, tdiNone);
  LModalResults: array[TMsgDlgBtn] of Integer = (mrYes, mrNo, mrOk, mrCancel,
    mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll, mrYesToAll, tdbHelp, mrClose);
var
  DlgBtn: TMsgDlgBtn;
  LTaskDialog: TTaskMessageDialog;
begin
  Application.ModalStarted;
  LTaskDialog := TTaskMessageDialog.Create(nil);
  try
    // Assign buttons
    for DlgBtn := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if DlgBtn in Buttons then
        with LTaskDialog.Buttons.Add do
        begin
{$IF DEFINED(CLR)}
          Caption := ButtonCaptions[DlgBtn];
{$ELSE}
          Caption := GetButtonCaption(DlgBtn);
{$IFEND}
          if DlgBtn = DefaultButton then
            Default := True;
          ModalResult := LModalResults[DlgBtn];
        end;

    // Set dialog properties
    with LTaskDialog do
    begin
      if DlgType <> mtCustom then
{$IF DEFINED(CLR)}
        Caption := Captions[DlgType]
{$ELSE}
        Caption := GetCaptions(DlgType)
{$IFEND}
      else
        Caption := Application.Title;
      CommonButtons := [];
      if Application.UseRightToLeftReading then
        Flags := Flags + [tfRtlLayout];
      HelpContext := HelpCtx;
      HelpFile := HelpFileName;
      MainIcon :=  IconMap[DlgType];
      Position := Point(X, Y);
      Text := Msg;
      Title := Instruction;
    end;

    // Show dialog and return result
    Result := mrNone;
    if LTaskDialog.Execute then
      Result := LTaskDialog.ModalResult;
  finally
    LTaskDialog.Free;
    Application.ModalFinished;
  end;
end;

function DoTaskMessageDlgPosHelpEx(const Instruction, Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
var
  DefaultButton: TMsgDlgBtn;
begin
  if mbOk in Buttons then DefaultButton := mbOk else
    if mbYes in Buttons then DefaultButton := mbYes else
      DefaultButton := mbRetry;
  Result := DoTaskMessageDlgPosHelpEx(Instruction, Msg, DlgType, Buttons, HelpCtx,
    X, Y, HelpFileName, DefaultButton);
end;

function DoMessageDlgPosHelpEx(MessageDialog: TForm; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
begin
  with MessageDialog do
    try
      HelpContext := HelpCtx;
      HelpFile := HelpFileName;
      if X >= 0 then Left := X;
      if Y >= 0 then Top := Y;
      if (Y < 0) and (X < 0) then Position := poScreenCenter;
      Result := ShowModal;
    finally
      Free;
    end;
end;

function MessageDlgPosHelpEx(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
var
  Frm: TForm;
  Button: TButton;
  I: Integer;
  S, NS: string;
begin
  if TOSVersion.Check(6) and UseLatestCommonDialogs and
     StyleServices.Enabled and StyleServices.IsSystemStyle then
    Result := DoTaskMessageDlgPosHelpEx('', Msg, DlgType, Buttons,
      HelpCtx, X, Y, HelpFileName)
  else
  begin
    Frm := CreateMessageDialog(Msg, DlgType, Buttons);
    Frm.Caption := GetCaptions(DlgType);

    {$IFNDEF EXTERNAL}
    for I := 0 to Frm.ComponentCount - 1 do
    begin
      { If the object is of type TButton, then }
      { Wenn es ein Button ist, dann... }
      if (Frm.Components[I] is TButton) then
      begin
        Button := TButton(Frm.Components[I]);
        S := StringReplace(Button.Caption, '&', '', []);
        NS := TA(S);
        if NS <> S then
          Button.Caption := NS;
      end;
    end;
    {$ENDIF}

    Result := DoMessageDlgPosHelpEx(Frm, HelpCtx, X, Y, HelpFileName);
  end;
end;

function MessageDlgEx(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
begin
  Result := MessageDlgPosHelpEx(Msg, DlgType, Buttons, HelpCtx, -1, -1, '');
end;

function TaskDialog(Handle: THandle; AContent, ATitle, ADescription: string;
  Buttons, Icon: Integer): Integer;
var
  VerInfo: TOSVersioninfo;
  DLLHandle: THandle;
  res: integer;
  wTitle,wDescription,wContent: array[0..1024] of widechar;
  Btns: TMsgDlgButtons;
  DlgType: TMsgDlgType;

  TaskDialogProc: function(HWND: THandle; hInstance: THandle; cTitle, cDescription, cContent: pwidechar; Buttons: Integer; Icon: integer;
       ResButton: pinteger): integer; cdecl stdcall;

begin
  Result := 0;

  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(verinfo);

  if (verinfo.dwMajorVersion >= 6) and not TStyleManager.IsCustomStyleActive then
  begin
    DLLHandle := LoadLibrary('comctl32.dll');
    if DLLHandle >= 32 then
    begin
      @TaskDialogProc := GetProcAddress(DLLHandle,'TaskDialog');

      if Assigned(TaskDialogProc) then
      begin
        StringToWideChar(ATitle, wTitle, sizeof(wTitle));
        StringToWideChar(ADescription, wDescription, sizeof(wDescription));
        StringToWideChar(AContent, wContent, sizeof(wContent));
        TaskDialogProc(Handle, 0, wTitle, wDescription, wContent, Buttons,Icon,@res);

        Result := ID_OK;
        case res of
          TD_RESULT_CANCEL : Result := ID_Cancel;
          TD_RESULT_RETRY : Result := ID_Retry;
          TD_RESULT_YES : Result := ID_Yes;
          TD_RESULT_NO : Result := ID_No;
          TD_RESULT_CLOSE : Result := ID_Abort;
        end;
      end;
      FreeLibrary(DLLHandle);
    end;
  end
  else
  begin
    Btns := [];
    if Buttons and TD_BUTTON_OK = TD_BUTTON_OK then
      Btns := Btns + [MBOK];

    if Buttons and TD_BUTTON_YES = TD_BUTTON_YES then
      Btns := Btns + [MBYES];

    if Buttons and TD_BUTTON_NO = TD_BUTTON_NO then
      Btns := Btns + [MBNO];

    if Buttons and TD_BUTTON_CANCEL = TD_BUTTON_CANCEL then
      Btns := Btns + [MBCANCEL];

    if Buttons and TD_BUTTON_RETRY = TD_BUTTON_RETRY then
      Btns := Btns + [MBRETRY];

    if Buttons and TD_BUTTON_CLOSE = TD_BUTTON_CLOSE then
      Btns := Btns + [MBABORT];

    DlgType := mtCustom;

    case Icon of
      TD_ICON_WARNING:
        DlgType := mtWarning;
      TD_ICON_QUESTION:
        DlgType := mtConfirmation;
      TD_ICON_ERROR:
        DlgType := mtError;
      TD_ICON_INFORMATION:
        DlgType := mtInformation;
    end;

    Result := MessageDlgEx(AContent, DlgType, Btns, 0);
  end;
end;

end.
