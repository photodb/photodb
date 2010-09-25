unit UnitSendMessageWithTimeoutThread;

interface

uses
  Windows, Classes, Dolphin_DB, Forms, uLogger;

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
    constructor Create(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM);
    destructor Destroy; override;
  end;

  var
    SendMessageMessageWork : boolean = false;
    SendMessageResult : boolean = false;

  function SendMessageEx(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM) : boolean;

implementation

  function SendMessageEx(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM) : boolean;
  var
    SendMessageThread : TThread;
  begin
   
   EventLog(':SendMessageEx()...');
   while SendMessageMessageWork do
    Application.ProcessMessages;

   SendMessageMessageWork := True;
   SendMessageResult:=false;          
   SendMessageThread := TSendMessageWithTimeoutThread.Create(hWnd, Msg, wParam, lParam);
   WaitForSingleObject(SendMessageThread.Handle, 5000);

   Result:=SendMessageResult;
  end;

{ TSendMessageWithTimeoutThread }

constructor TSendMessageWithTimeoutThread.Create(
  hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM);
begin
 inherited Create(True);
 fhWnd:= hWnd;
 fMsg:= Msg;
 fwParam:=fwParam;
 flParam:=lParam;
end;

destructor TSendMessageWithTimeoutThread.Destroy;
begin
  SendMessageMessageWork:=false;
  inherited;
end;

procedure TSendMessageWithTimeoutThread.Execute;
begin
 FreeOnTerminate:=True;
 SendMessage(fhWnd, fMsg, fwParam, flParam);
 SendMessageResult:=True;
end;

end.
