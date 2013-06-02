unit uDecompressionProgressWindow;

interface

uses
  Windows,
  Messages,
  Classes,

  uConstants;

const
  WndClass = 'TProgressWinWnd';
  WndCaption = ProductName;
  ProgBrID = 1;
  PBS_MARQUEE = $08;
  PBM_SETMARQUEE  = WM_USER + 10;
  PrWinWidth: Integer = 300;
  PrWinHeight: Integer = 70;

const
  {$EXTERNALSYM PBS_SMOOTH}
  PBS_SMOOTH              = 01;
  {$EXTERNALSYM PBS_VERTICAL}
  PBS_VERTICAL            = 04;

  {$EXTERNALSYM PBM_SETRANGE}
  PBM_SETRANGE            = WM_USER+1;
  {$EXTERNALSYM PBM_SETPOS}
  PBM_SETPOS              = WM_USER+2;
  {$EXTERNALSYM PBM_DELTAPOS}
  PBM_DELTAPOS            = WM_USER+3;
  {$EXTERNALSYM PBM_SETSTEP}
  PBM_SETSTEP             = WM_USER+4;
  {$EXTERNALSYM PBM_STEPIT}
  PBM_STEPIT              = WM_USER+5;
  {$EXTERNALSYM PBM_SETRANGE32}
  PBM_SETRANGE32          = WM_USER+6;   // lParam = high, wParam = low
  {$EXTERNALSYM PBM_GETRANGE}
  PBM_GETRANGE            = WM_USER+7;   // lParam = PPBRange or Nil
					 // wParam = False: Result = high
					 // wParam = True: Result = low
  {$EXTERNALSYM PBM_GETPOS}
  PBM_GETPOS              = WM_USER+8;
  {$EXTERNALSYM PBM_SETBARCOLOR}
  PBM_SETBARCOLOR         = WM_USER+9;		// lParam = bar color

  {$EXTERNALSYM ICC_PROGRESS_CLASS}
  ICC_PROGRESS_CLASS     = $00000020; // progress

type
  {$EXTERNALSYM tagINITCOMMONCONTROLSEX}
  tagINITCOMMONCONTROLSEX = record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
  end;
  PInitCommonControlsEx = ^TInitCommonControlsEx;
  TInitCommonControlsEx = tagINITCOMMONCONTROLSEX;

procedure InitCommonControls; stdcall; external comctl32 name 'InitCommonControls';
function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool stdcall; external comctl32 name 'InitCommonControlsEx';
procedure CreateProgressWindow;
function SetProgressPos(Percents: Byte): Boolean;
procedure CloseProgress;

implementation

var
  Wnd: HWND = 0;
  ProgBr: hwnd = 0;
  IsClosed: Boolean = False;

function InitCommonControl(CC: Integer): Boolean;
var
  ICC: TInitCommonControlsEx;
begin
{$IFDEF CLR}
  ICC.dwSize := Marshal.SizeOf(TypeOf(TInitCommonControlsEx));
{$ELSE}
  ICC.dwSize := SizeOf(TInitCommonControlsEx);
{$ENDIF}
  ICC.dwICC := CC;
  Result := InitCommonControlsEx(ICC);
  if not Result then InitCommonControls;
end;

function WindowProc( Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM ): LRESULT; stdcall;
begin
  case Msg of
    WM_CLOSE,
    WM_DESTROY:
    begin
       PostQuitMessage( 0 );
       Result := 0;
       Exit;
    end;
    else
       Result := DefWindowProc(Wnd, Msg, wParam, lParam );
  end;
end;

procedure CreateProgressWindow;
var
  Wc: TWndClassEx;
  Msg: TMsg;
  F32BitMode: Boolean;
begin
  Wnd := 0;
  ProgBr := 0;
  TThread.CreateAnonymousThread(
    procedure
    begin
      with Wc do
      begin
        cbSize := SizeOf( Wc );
        style := CS_HREDRAW or CS_VREDRAW;
        lpfnWndProc := @WindowProc;
        cbClsExtra := 0;
        cbWndExtra := 0;
        hInstance := hInstance;
        hIcon := LoadIcon( 0, IDI_APPLICATION );
        hCursor := LoadCursor( 0, IDC_ARROW );
        hbrBackground := COLOR_WINDOW;
        lpszMenuName := nil;
        lpszClassName := WndClass;
      end;
      RegisterClassEx( Wc );
      Wnd := CreateWindowEx(0, WndClass, WndCaption, WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU,
                         GetSystemMetrics(SM_CXSCREEN) div 2 - PrWinWidth div 2,
                         GetSystemMetrics(SM_CYSCREEN) div 2 - PrWinHeight div 2,
                         PrWinWidth, PrWinHeight, 0, 0, hInstance, nil );

      F32BitMode := InitCommonControl(ICC_PROGRESS_CLASS);

      ProgBr := CreateWindowEx( 0, 'msctls_progress32', '', WS_CHILD or WS_VISIBLE , 10, 10, 275, 20, wnd, 0, hinstance, nil );
      SetWindowLong (ProgBr, GWL_STYLE, (GetWindowLong (ProgBr, GWL_STYLE)));

      if F32BitMode then SendMessage(ProgBr, PBM_SETRANGE32, 0, 100)
      else SendMessage(ProgBr, PBM_SETRANGE, 0, MakeLong(0, 100));

      SendMessage(ProgBr, PBM_SETPOS, 0, 0);
      ShowWindow( Wnd, SW_SHOWNORMAL );

      while GetMessage( Msg, 0, 0, 0 ) do
      begin
        TranslateMessage( Msg );
        DispatchMessage( Msg );
      end;

      IsClosed := True;
    end
  ).Start;
end;

function SetProgressPos(Percents: Byte): Boolean;
begin
  Result := not IsClosed;
  if ProgBr <> 0 then
    SendMessage(ProgBr, PBM_SETPOS, Percents, 0);
end;

procedure CloseProgress;
begin
  ShowWindow(Wnd, SW_HIDE);
  SendMessage(Wnd, WM_CLOSE, 0, 0);
end;

end.
