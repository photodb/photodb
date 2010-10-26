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
    FOwnerExplorerForm: TForm;
  protected
    procedure Execute; override;
  public
    constructor Create(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean;
      AutoRename: Boolean; OwnerExplorerForm: TForm);
    destructor Destroy; override;
  end;

implementation

uses ExplorerUnit;

{ TWindowsCopyFilesThread }

constructor TWindowsCopyFilesThread.Create(Handle: Hwnd; Src: TStrings; Dest: string; Move, AutoRename: Boolean;
   OwnerExplorerForm: TForm);
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
  FOwnerExplorerForm := OwnerExplorerForm;
end;

destructor TWindowsCopyFilesThread.Destroy;
begin
  F(FSrc);
  inherited;
end;

procedure CorrectPath(Owner : TObject; Src: TStrings; Dest: string);
var
  I : Integer;
  FN, Adest : string;
begin
  UnforMatDir(Dest);
  for I := 0 to Src.Count - 1 do
  begin
    FN := Dest + '\' + ExtractFileName(Src[I]);
    if DirectoryExists(FN) then
    begin
      Adest := Dest + '\' + ExtractFileName(Src[I]);
      RenameFolderWithDB(Owner, Src[I], Adest, False);
    end;
    if FileExists(FN) then
    begin
      Adest := Dest + '\' + ExtractFileName(Src[I]);
      RenameFileWithDB(Owner, Src[I], Adest, GetIDByFileName(Src[I]), True);
    end;
  end;
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
  if Res and (FOwnerExplorerForm <> nil) then
    CorrectPath(FOwnerExplorerForm, FSrc, FDest);
end;

end.

