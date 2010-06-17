unit UnitFileExistsThread;

interface

uses
  Windows, Classes, SysUtils, Forms, Dolphin_DB, UnitDBCommon, uLogger;

type
  TFileExistsThread = class(TThread)
  private
   fFileName : string;
   fIsDirectory : boolean;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; FileName : string; IsDirectory : boolean);
    destructor Destroy; override;
  end;

  function CheckFileExistsWithMessageEx(FileName : string; IsDirectory : boolean) : boolean;
  function CheckFileExistsWithSleep(FileName : string; IsDirectory : boolean) : boolean;

  var
    CheckFileExistsWithMessageWork : boolean = false;  
    CheckFileExistsWithMessageResult : boolean = false;

  const
    FileCheckTimeOut = 5000;

implementation

  function CheckFileExistsWithSleep(FileName : string; IsDirectory : boolean) : boolean;
  var
    BeginTime : Cardinal;
    i : integer;
  begin

   EventLog(':CheckFileExistsWithMessageEx()...');
   while CheckFileExistsWithMessageWork do
    Sleep(10);

   CheckFileExistsWithMessageWork:=true;
   CheckFileExistsWithMessageResult:=false;
   BeginTime:=Windows.GetTickCount;
   TFileExistsThread.Create(false,FileName,IsDirectory);
   i:=0;
   while CheckFileExistsWithMessageWork do
   begin
    Inc(i);
    Sleep(10);
    if (i=100) then
    begin
     if Windows.GetTickCount-BeginTime>FileCheckTimeOut then
     begin
      Result:=false;
      exit;
     end;
     i:=0;
    end;
   end;
   Result:=CheckFileExistsWithMessageResult;
  end;

  function CheckFileExistsWithMessageEx(FileName : string; IsDirectory : boolean) : boolean;
  var
    BeginTime, NowTime : Cardinal;
    i : integer;
  begin

   EventLog(':CheckFileExistsWithMessageEx()...');
   while CheckFileExistsWithMessageWork do
    Application.ProcessMessages;

   CheckFileExistsWithMessageWork:=true;
   CheckFileExistsWithMessageResult:=false;
   BeginTime:=Windows.GetTickCount;
   TFileExistsThread.Create(false,FileName,IsDirectory);
   i:=0;
   while CheckFileExistsWithMessageWork do
   begin
    Inc(i);
    Sleep(1);
    if (i=100) then
    begin
     if Windows.GetTickCount-BeginTime>FileCheckTimeOut then
     begin
      Result:=false;
      exit;
     end;
     i:=0;
    end;
   end;
   Result:=CheckFileExistsWithMessageResult;
  end;
  
{ TFileExistsThread }

constructor TFileExistsThread.Create(CreateSuspennded: Boolean;
  FileName: string; IsDirectory : boolean);
begin
 inherited Create(true);
 fFileName:=FileName;
 fIsDirectory:=IsDirectory;
 if not CreateSuspennded then Resume;
end;

destructor TFileExistsThread.Destroy;
begin
  CheckFileExistsWithMessageWork:=false;
  inherited;
end;

procedure TFileExistsThread.Execute;
var
  oldMode : Cardinal;
begin
 FreeOnTerminate:=true;
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 if fIsDirectory then
 CheckFileExistsWithMessageResult:=DirectoryExists(fFileName) else
 CheckFileExistsWithMessageResult:=FileExistsEx(fFileName);
 SetErrorMode(oldMode);
end;

end.
 