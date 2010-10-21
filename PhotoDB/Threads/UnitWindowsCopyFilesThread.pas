unit UnitWindowsCopyFilesThread;

interface

uses
  Classes, Windows, DBCommon, SysUtils, Forms, Dolphin_DB, uFileUtils, uMemory,
  uLogger;

type
  TWindowsCopyFilesThread = class(TThread)
  private
    { Private declarations }
    FHandle: Hwnd;
    FSrc: TStrings;
    FDest: string;
    FMove, FAutoRename: Boolean;
    FCallBack: TCorrectPathProc;
    FOwnerExplorerForm: TForm;
  protected
    procedure Execute; override;
  public
    constructor Create(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean;
      AutoRename: Boolean; CallBack: TCorrectPathProc; OwnerExplorerForm: TForm);
    destructor Destroy; override;
  end;

implementation

uses ExplorerUnit;

{ TWindowsCopyFilesThread }

constructor TWindowsCopyFilesThread.Create(Handle: Hwnd; Src: TStrings; Dest: string; Move, AutoRename: Boolean;
  CallBack: TCorrectPathProc; OwnerExplorerForm: TForm);
var
  I: Integer;
begin
  inherited Create(False);
  FHandle := Handle;
  FSrc := TStringList.Create;
  FSrc.Assign(Src);
  FDest := Dest;
  FMove := Move;
  FAutoRename := AutoRename;
  FCallBack := CallBack;
  FOwnerExplorerForm := OwnerExplorerForm;
end;

destructor TWindowsCopyFilesThread.Destroy;
begin
  F(FSrc);
  inherited;
end;

procedure TWindowsCopyFilesThread.Execute;
var
  Res: Boolean;
begin
  FreeOnTerminate := True;
  Res := False;
  try
    Res := CopyFilesSynch(0, FSrc, FDest, FMove, FAutoRename) = 0;
  except
    on e : Exception do
      EventLog(e.Message);
  end;
  if Res then
  begin
    if FOwnerExplorerForm <> nil then
    begin
      if ExplorerManager.IsExplorer(TExplorerForm(FOwnerExplorerForm)) then
        FCallBack(FOwnerExplorerForm, FSrc, FDest);
    end else
      FCallBack(FOwnerExplorerForm, FSrc, FDest);
  end;
end;

end.

