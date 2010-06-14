unit UnitWindowsCopyFilesThread;

interface

uses
  Classes, Windows, DBCommon, Forms;

type
  TCorrectPathProc = procedure(Src : array of string; Dest : string) of object;

type
  TWindowsCopyFilesThread = class(TThread)
  private
   FHandle: Hwnd;
   FSrc: array of string;
   FDest: string;
   FMove, FAutoRename: Boolean;
   fCallBack : TCorrectPathProc;
   fOwnerExplorerForm : TForm;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure DoCallBack;
  public
    constructor Create(CreateSuspennded: Boolean; Handle : Hwnd; Src : array of string;
  Dest : string; Move : Boolean; AutoRename : Boolean; CallBack : TCorrectPathProc; OwnerExplorerForm : TForm);
  end;

implementation

uses Dolphin_DB, ExplorerUnit;

{ TWindowsCopyFilesThread }

constructor TWindowsCopyFilesThread.Create(CreateSuspennded: Boolean;
  Handle: Hwnd; Src: array of string; Dest: string; Move,
  AutoRename: Boolean; CallBack : TCorrectPathProc; OwnerExplorerForm : TForm);
var
  i : integer;
begin
 inherited create(true);
 FHandle:=Handle;
 SetLength(FSrc,Length(Src));
 for i:=0 to Length(FSrc)-1 do
 FSrc[i]:=Src[i];
 FDest:=Dest;
 FMove:=Move;
 FAutoRename:=AutoRename;
 FCallBack := CallBack;
 fOwnerExplorerForm:=OwnerExplorerForm;
 if not CreateSuspennded then Resume;
end;

procedure TWindowsCopyFilesThread.DoCallBack;
begin
 if Assigned(FCallBack) then
 FCallBack(FSrc,FDest);
end;

procedure TWindowsCopyFilesThread.Execute;
var
  res : boolean;
begin
 FreeOnTerminate:=true;
 res:=false;
 try
  res:=CopyFilesSynch(0,FSrc,FDest,FMove,FAutoRename)=0;
 except
 end;
 if res then
 begin
  if fOwnerExplorerForm<>nil then
  begin
   if ExplorerManager.IsExplorer(TExplorerForm(fOwnerExplorerForm)) then
   Synchronize(DoCallBack);
  end else Synchronize(DoCallBack);
 end;
end;

end.
