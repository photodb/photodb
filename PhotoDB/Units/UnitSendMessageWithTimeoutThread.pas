unit UnitSendMessageWithTimeoutThread;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Forms,

  uLogger,
  uDBThread;

type
  TSendMessageWithTimeoutThread = class(TDBThread)
  private
    { Private declarations }
    FhWnd: HWND;
    FMsg: UINT;
    FwParam: WPARAM;
    FlParam: LPARAM;
  protected
    procedure Execute; override;
  public
    constructor Create(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM);
    destructor Destroy; override;
  end;

function SendMessageEx(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM) : boolean;

implementation

var
  SendMessageMessageWork: Boolean = false;
  SendMessageResult: Boolean = false;

function SendMessageEx(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM) : boolean;
var
  SendMessageThread: TThread;
begin

  EventLog(':SendMessageEx()...');
  while SendMessageMessageWork do
    Application.ProcessMessages;

  SendMessageMessageWork := True;
  SendMessageResult:= False;
  SendMessageThread := TSendMessageWithTimeoutThread.Create(hWnd, Msg, wParam, lParam);
  WaitForSingleObject(SendMessageThread.Handle, 5000);

  Result := SendMessageResult;
end;

{ TSendMessageWithTimeoutThread }

constructor TSendMessageWithTimeoutThread.Create(
  hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM);
begin
  inherited Create(nil, False);
  FhWnd := HWnd;
  FMsg := Msg;
  FwParam := FwParam;
  FlParam := LParam;
end;

destructor TSendMessageWithTimeoutThread.Destroy;
begin
  SendMessageMessageWork := False;
  inherited;
end;

procedure TSendMessageWithTimeoutThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  SendMessage(FhWnd, FMsg, FwParam, FlParam);
  SendMessageResult := True;
end;

end.
