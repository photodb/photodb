unit uSplashThread;

interface

uses
   Classes, Windows, Messages, JPEG, Graphics, DmProgress, uTime,
   uConstants, uResources, Language, UnitDBCommonGraphics;

type
  TSplashThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

var
  SplashThread : TThread = nil;

procedure SetSplashProgress(ProgressValue : Byte);

implementation

{ TSplashThread }

const
  SplWidth = 480;
  SplHeight = 500;

var
  SplashWindowClass : TWndClass;
  hSplashWnd : HWND;
  hSplashProgress : Byte = 0;
  IsFirstDraw : Boolean = True;

procedure SetSplashProgress(ProgressValue : Byte);
var
  Rectangle : TRect;
begin
  hSplashProgress := ProgressValue;
  Rectangle := Rect(0, SplHeight - 30, SplWidth, SplHeight);
  InvalidateRect(hSplashWnd, @Rectangle, False);
  PostMessage(hSplashWnd, WM_PAINT, 0, 0);
end;

procedure DrawOurStuff(DrawDC: HDC);
const
  DrawTextOpt = DT_NOPREFIX + DT_WORDBREAK + DT_LEFT;
var
  J : TJPEGImage;
  BMP : TBitmap;
  TP : TDmProgress;
  brushInfo : tagLOGBRUSH;
  Brush : HBrush;
  InfoText : TStringList;
  R : TRect;
  hf, oldFont: HFONT;
begin
  brushInfo.lbStyle := BS_SOLID;
  brushInfo.lbColor := 0;

  if IsFirstDraw then
  begin
    Brush := CreateBrushIndirect(brushInfo);
    FillRect(DrawDC, Rect(0, 0, SplWidth, SplHeight), Brush);
    DeleteObject(Brush);
    J := GetLogoPicture;
    try
      BMP := TBitmap.Create;
      try
        BMP.Canvas.Brush.Color := 0;
        BMP.Canvas.Pen.Color := 0;
        BMP.Height := SplHeight;
        BMP.Width := SplWidth;
        AssignJpeg(BMP, J);
        BitBlt(DrawDC, 200, 0, SplWidth, SplHeight, BMP.Canvas.Handle, 0, 0, SRCCOPY);
      finally
        BMP.Free;
      end;
    finally
      J.Free;
    end;
    InfoText := TStringList.Create;
    try
      InfoText.Add(ProductName);
      InfoText.Add('About project:');
      InfoText.Add('All copyrights to this program are');
      InfoText.Add('exclusively owned by the author:');
      InfoText.Add('Veresov Dmitry © 2002-2011');
      InfoText.Add('Studio "Illusion Dolphin".');
      InfoText.Add('You can''t emulate, clone, rent, lease,');
      InfoText.Add('sell, modify, decompile, disassemble,');
      InfoText.Add('otherwise, reverse engineer, transfer');
      InfoText.Add('this software.');
      InfoText.Add('');
      InfoText.Add('HomePage:');
      InfoText.Add(HomeURL);
      InfoText.Add('');
      InfoText.Add('E-Mail:');
      InfoText.Add(ProgramMail);

      R := Rect(10, 10, SplWidth, SplHeight);
      SetBkColor(DrawDC, clBlack);
      SetTextColor(DrawDC, clWhite);
      hf := CreateFont(14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Times New Roman');
      oldFont := SelectObject(DrawDC, hf);
      DrawTextA(DrawDC, PChar(InfoText.Text), Length(InfoText.Text), R, DrawTextOpt);
      SelectObject(DrawDC, oldFont);
      if(hf > 0) then
        DeleteObject(hf);
    finally
      InfoText.Free;
    end;

    IsFirstDraw := False;
  end;

  TP := TDmProgress.Create(nil);
  try
    TP.Visible := False;
    TP.MaxValue := 100;
    TP.Position := hSplashProgress;
    TP.Width := SplWidth - 20;
    TP.Height := 17;
    TP.BorderColor := clGray;
    TP.Color := clBlack;
    TP.Text := TEXT_MES_LOADING_PHOTODB;
    TP.Font.Color := clWhite; 
    TP.Font.Name := 'Times New Roman';
    TP.CoolColor := clNavy;
    TP.DoDraw(DrawDC, 10, SplHeight - TP.Height - 10);
  finally
    TP.Free;
  end;
end;

function SplashWindowProc(hWnd : HWND; uMsg : UINT; wParam : WPARAM;
                    lParam : LPARAM) : LRESULT; stdcall;
var
  ps: TPaintStruct;
  DrawDC: HDC;
begin
  case uMsg of
    WM_DESTROY:
      begin
        PostQuitMessage(0); // stop message loop
        Result := 0;
        Exit;
      end;
    WM_PAINT:
      begin
         // note: g_Handle is the handle to our window, got from CreateWindow
         // tell Windows we're painting the window
         DrawDC := BeginPaint(hSplashWnd, ps);
         try
           DrawOurStuff(DrawDC);
         finally
           EndPaint(hSplashWnd, ps); // we've stopped painting now
         end;
         Result := 0;
         Exit;
       end;
  end;
  Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
end; // SplashWindowProc
               
procedure TSplashThread.Execute;
const
  ClassName = 'PhotoDB Splash';
var
  Instance : Thandle;
  Msg: TMsg; // declare this too, for later
begin
  SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  SetThreadPriority(MainThreadID, THREAD_PRIORITY_TIME_CRITICAL);

  Instance := GetModuleHandle(nil);
  SplashWindowClass.style := CS_HREDRAW or CS_VREDRAW;
  SplashWindowClass.lpfnWndProc := @SplashWindowProc;
  SplashWindowClass.hInstance := Instance;
  SplashWindowClass.hIcon := LoadIcon(0, IDI_APPLICATION);
  SplashWindowClass.hCursor := LoadCursor(0, IDC_ARROW);
  SplashWindowClass.hbrBackground := COLOR_BTNFACE + 1;
  SplashWindowClass.lpszClassName := ClassName;

  RegisterClass(SplashWindowClass);
  try
    hSplashWnd := CreateWindowEx(WS_EX_TOOLWINDOW or WS_EX_TOPMOST, ClassName, 'SplashScreen',
                                 WS_POPUP,
                                 GetSystemMetrics(SM_CXSCREEN) div 2 - SplWidth div 2,
                                 GetSystemMetrics(SM_CYSCREEN) div 2 - SplHeight div 2,
                                 SplWidth, SplHeight, 0, 0, Instance, nil);
    try
      ShowWindow(hSplashWnd, SW_SHOWNOACTIVATE);
      UpdateWindow(hSplashWnd);

      while True do
      begin
        if Terminated then
          Break;
        if PeekMessage(Msg, hSplashWnd, 0,0, PM_REMOVE) then
        begin
          if Msg.message = WM_QUIT then
            Break;
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end else
        begin
          // Do rendering here if a real-time app
        end;
        Sleep(1);
      end;
    finally
      DestroyWindow(hSplashWnd);
    end;
  finally
    UnregisterClass(ClassName, Instance);
  end;      
  TW.I.Start('SPLASH THREAD END');
end; // ShowSplashWindow

initialization

  //if not GetParamStrDBBool('/NoLogo') then
  begin
    TW.I.Start('TSplashThread');
    SplashThread := TSplashThread.Create(False);
    TW.I.Start('TSplashThread - Created');
  end;

end.
