unit UnitWindowsCopyFilesThread;

interface

uses
  Classes, Windows, DBCommon, Forms, uFileUtils;

type
  TCorrectPathProc = procedure(Src : array of string; Dest : string) of object;

type
  TWindowsCopyFilesThread = class(TThread)
  private
    FHandle: Hwnd;
    FSrc: array of string;
    FDest: string;
    FMove, FAutoRename: Boolean;
    FCallBack: TCorrectPathProc;
    FOwnerExplorerForm: TForm;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure DoCallBack;
  public
    constructor Create(Handle: Hwnd; Src: array of string; Dest: string; Move: Boolean;
      AutoRename: Boolean; CallBack: TCorrectPathProc; OwnerExplorerForm: TForm);
  end;

implementation

uses Dolphin_DB, ExplorerUnit;

{ TWindowsCopyFilesThread }

constructor TWindowsCopyFilesThread.Create(Handle: Hwnd; Src: array of string; Dest: string; Move, AutoRename: Boolean;
  CallBack: TCorrectPathProc; OwnerExplorerForm: TForm);
var
  I: Integer;
begin
  inherited Create(False);
  FHandle := Handle;
  SetLength(FSrc, Length(Src));
  for I := 0 to Length(FSrc) - 1 do
    FSrc[I] := Src[I];
  FDest := Dest;
  FMove := Move;
  FAutoRename := AutoRename;
  FCallBack := CallBack;
  FOwnerExplorerForm := OwnerExplorerForm;
end;

procedure TWindowsCopyFilesThread.DoCallBack;
begin
 if Assigned(FCallBack) then
 FCallBack(FSrc,FDest);
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
  end;
  if Res then
  begin
    if FOwnerExplorerForm <> nil then
    begin
      if ExplorerManager.IsExplorer(TExplorerForm(FOwnerExplorerForm)) then
        Synchronize(DoCallBack);
    end
    else
      Synchronize(DoCallBack);
  end;
end;

end.
