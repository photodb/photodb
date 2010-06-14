unit UnitSendMessageWithTimeoutThread;

interface

uses
  Windows, Classes, Dolphin_DB, Forms;

type
  TSendMessageWithTimeoutThread = class(TThread)
  private
    fhWnd: HWND;
    fMsg: UINT;
    fwParam: WPARAM;
    flParam: LPARAM;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM);
    destructor Destroy; override;
  end;

  var
    SendMessageMessageWork : boolean = false;
    SendMessageResult : boolean = false;

  function SendMessageEx(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM) : boolean;

implementation

  function SendMessageEx(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM) : boolean;
  var
    BeginTime : Cardinal;
    i : integer;
  begin
   
   EventLog(':SendMessageEx()...');
   while SendMessageMessageWork do
    Application.ProcessMessages;

   SendMessageMessageWork:=true;
   SendMessageResult:=false;
   BeginTime:=Windows.GetTickCount;
   TSendMessageWithTimeoutThread.Create(false,hWnd,Msg,wParam,lParam);
   i:=0;
   while SendMessageMessageWork do
   begin
    Inc(i);
    Application.ProcessMessages;
    Sleep(1);
    if (i=100) then
    begin
     if Windows.GetTickCount-BeginTime>5000 then
     begin
      Result:=false;
      exit;
     end;
     i:=0;
    end;
   end;
   Result:=SendMessageResult;
  end;

{ TSendMessageWithTimeoutThread }

constructor TSendMessageWithTimeoutThread.Create(CreateSuspennded: Boolean;
  hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM);
begin
 inherited Create(true);
 fhWnd:= hWnd;
 fMsg:= Msg;
 fwParam:=fwParam;
 flParam:=lParam;
 if not CreateSuspennded then Resume;
end;

destructor TSendMessageWithTimeoutThread.Destroy;
begin
  SendMessageMessageWork:=false;
  inherited;
end;

procedure TSendMessageWithTimeoutThread.Execute;
begin
 FreeOnTerminate:=true;
 SendMessage(fhWnd, fMsg, fwParam, flParam);
 SendMessageResult:=true;
end;

end.
