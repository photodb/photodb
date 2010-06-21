unit uSplachThread;


interface

uses
   Classes,windows, messages, JPEG, Graphics, DmProgress;

type
  TSplashThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ TSplashThread }

const
  SplWidth = 480;
  SplHeight = 500;

var
 SplashWindowClass : TWndClass;
 hSplashWnd, hSplashEvent, hSplashRoutineThread : HWND;

procedure DrawOurStuff(DrawDC: HDC);
const
  NUM_SHAPES = 4000;
  DrawTextOpt = DT_NOPREFIX+DT_WORDBREAK+DT_LEFT;
var
  i: Integer;
  OldPen, DrawPen: HPEN;
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
  Brush := CreateBrushIndirect(brushInfo);
  FillRect(DrawDC, Rect(0, 0, SplWidth, SplHeight), Brush);

  J :=TJPEGImage.Create;
  J.LoadFromFile('c:\1.jpg');
  BMP := TBitmap.Create;
  BMP.Canvas.Brush.Color := 0;
  BMP.Canvas.Pen.Color := 0;
  BMP.Height := SplHeight;
  BMP.Width := SplWidth;
  BMP.Assign(J);
  TP := TDmProgress.Create(nil);
  TP.Visible := False;
  TP.MaxValue := 100;
  TP.Position := 37;
  TP.Width := SplWidth - 20*2;
  TP.Height := 17;
  TP.BorderColor := clGray;
  TP.Color := clBlack;
  TP.Font.Color := clWhite; 
  TP.Font.Name := 'Times New Roman';
  TP.CoolColor := clNavy;
  TP.DoDraw(DrawDC, 10, SplHeight - TP.Height - 10);

  InfoText := TStringList.Create;
  InfoText.Add('PhotoDB 2.3');
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
  InfoText.Add('www');
  InfoText.Add('');
  InfoText.Add('E-Mail:');
  InfoText.Add('email');

  R := Rect(10, 10, SplWidth, SplHeight);
  SetBkColor(DrawDC, clBlack);
  SetTextColor(DrawDC, clWhite);
  hf := CreateFont(14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Times New Roman');
  oldFont := SelectObject(DrawDC, hf);
  DrawTextA(DrawDC, PChar(InfoText.Text), Length(InfoText.Text), R, DrawTextOpt);
  SelectObject(DrawDC, oldFont);
  if(hf > 0) then
    DeleteObject(hf);
  BitBlt(DrawDC, 200, 0, SplWidth, SplHeight, BMP.Canvas.Handle, 0, 0, SRCCOPY);

 { DrawPen := CreatePen(PS_SOLID, 1, RGB(Random(256), Random(256), Random(256)));
  // Create our pen to draw with. It will be a solid line style, of width 1 and
  // a completely random colour
  // Select our new pen into the DC, so lines will be drawn using it. Store
  // the old pen too
  OldPen := SelectObject(DrawDC, DrawPen);

  // Draw our lines
  for i := 0 to NUM_SHAPES - 1 do
    LineTo(DrawDC, Random(500), Random(500));

  // Select the old pen back again so Windows doesn't complain
  SelectObject(DrawDC, OldPen);

  // and kill the pen we created
  DeleteObject(DrawPen);            }
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
         DrawOurStuff(DrawDC);
         EndPaint(hSplashWnd, ps); // we've stopped painting now
         Result := 0;
         Exit;
       end;
  end;
end; // SplashWindowProc

procedure TSplashThread.Execute;
const
  ClassName = 'PhotoDB Splash';
var
  Instance : Thandle;
  Msg: TMsg; // declare this too, for later
begin
  Instance := GetModuleHandle(nil);
  SplashWindowClass.style := CS_HREDRAW or CS_VREDRAW;
  SplashWindowClass.lpfnWndProc := @SplashWindowProc;
  SplashWindowClass.hInstance := Instance;
  SplashWindowClass.hIcon := LoadIcon(0, IDI_APPLICATION);
  SplashWindowClass.hCursor := LoadCursor(0, IDC_ARROW);
  SplashWindowClass.hbrBackground := COLOR_BTNFACE + 1;
  SplashWindowClass.lpszClassName := ClassName;

  RegisterClass(SplashWindowClass);
  hSplashWnd := CreateWindow(ClassName, 'SplashScreen',
                             WS_POPUP or WS_EX_TOPMOST,
                             350, 300, 480, 500, 0, 0, Instance, NIL);
  ShowWindow(hSplashWnd, SW_SHOW);
  UpdateWindow(hSplashWnd);

  while True do
  begin
    if Terminated then
      Break;
    if PeekMessage(Msg, hSplashWnd,0,0, PM_REMOVE) then
    begin
      if Msg.message = WM_QUIT then
        break;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end else
    begin
      // Do rendering here if a real-time app
    end;
    Sleep(1);
  end;

  DestroyWindow(hSplashWnd);
  UnregisterClass(ClassName, Instance);
end; // ShowSplashWindow

end.
