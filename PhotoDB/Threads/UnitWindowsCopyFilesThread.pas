unit UnitWindowsCopyFilesThread;

interface

uses
  Classes, Windows, DBCommon, SysUtils, Forms, Dolphin_DB, uFileUtils, uMemory,
  uLogger, uDBUtils, uDBForm, UnitDBDeclare, UnitDBKernel, uDBThread, ActiveX,
  ProgressActionUnit;

type
  TWindowsCopyFilesThread = class(TDBThread)
  private
    { Private declarations }
    FHandle: Hwnd;
    FSrc: TStrings;
    FDest: string;
    FMove, FAutoRename: Boolean;
    FOwnerForm: TDBForm;
    FID: Integer;
    FIntParam: Integer;
    FParams: TEventFields;
    FValue: TEventValues;
    FOnDone: TNotifyEvent;
    FProgressWindow: TProgressActionForm;
    procedure CorrectPath(Owner : TDBForm; Src: TStrings; Dest: string);
    procedure KernelEventCallBack(ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure KernelEventCallBackSync;
    procedure DoOnDone;
  protected
    procedure Execute; override;
    procedure CreateProgress(MaxCount: Integer);
    procedure ShowProgress(Sender: TObject);
    procedure UpdateProgress(Position: Integer);
    procedure CloseProgress(Sender: TObject);

    procedure CreateProgressSync;
    procedure ShowProgressSync;
    procedure UpdateProgressSync;
    procedure CloseProgressSync;
  public
    constructor Create(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean;
      AutoRename: Boolean; OwnerForm: TDBForm; OnDone: TNotifyEvent = nil);
    destructor Destroy; override;
  end;

implementation

uses ExplorerUnit;

{ TWindowsCopyFilesThread }

constructor TWindowsCopyFilesThread.Create(Handle: Hwnd; Src: TStrings; Dest: string; Move, AutoRename: Boolean;
   OwnerForm: TDBForm; OnDone: TNotifyEvent = nil);
begin
  inherited Create(nil, False);
  FOnDone := OnDone;
  FHandle := Handle;
  FSrc := TStringList.Create;
  FSrc.Assign(Src);
  FDest := Dest;
  FMove := Move;
  FAutoRename := AutoRename;
  FOwnerForm := OwnerForm;
  FProgressWindow := nil;
end;

destructor TWindowsCopyFilesThread.Destroy;
begin
  F(FSrc);
  inherited;
end;

procedure TWindowsCopyFilesThread.DoOnDone;
begin
  FOnDone(Self);
end;

procedure TWindowsCopyFilesThread.CorrectPath(Owner: TDBForm; Src: TStrings; Dest: string);
var
  I : Integer;
  FN, Adest : string;
begin
  Dest := ExcludeTrailingBackslash(Dest);
  for I := 0 to Src.Count - 1 do
  begin
    FN := Dest + '\' + ExtractFileName(Src[I]);
    if DirectoryExists(FN) then
    begin
      Adest := Dest + '\' + ExtractFileName(Src[I]);
      RenameFolderWithDB(KernelEventCallBack, CreateProgress, ShowProgress, UpdateProgress, CloseProgress, Src[I], Adest, False);
    end;
    if FileExistsSafe(FN) then
    begin
      Adest := Dest + '\' + ExtractFileName(Src[I]);
      RenameFileWithDB(KernelEventCallBack, Src[I], Adest, GetIDByFileName(Src[I]), True);
    end;
  end;
end;

procedure TWindowsCopyFilesThread.Execute;
var
  Res: Boolean;
begin
  inherited;
  FreeOnTerminate := True;
  try
    CoInitialize(nil);
    try
      Res := CopyFilesSynch(FHandle, FSrc, FDest, FMove, FAutoRename) = 0;

      if Res and (FOwnerForm <> nil) and FMove then
        CorrectPath(FOwnerForm, FSrc, FDest);
    finally
      CoUninitialize;
    end;
  except
    on e : Exception do
      EventLog(e.Message);
  end;
  if Assigned(FOnDone) then
    SynchronizeEx(DoOnDone);
end;

procedure TWindowsCopyFilesThread.KernelEventCallBack(ID: Integer;
  Params: TEventFields; Value: TEventValues);
begin
  FID := ID;
  FParams := Params;
  FValue := Value;
  Synchronize(KernelEventCallBackSync);
end;

procedure TWindowsCopyFilesThread.KernelEventCallBackSync;
begin
  DBKernel.DoIDEvent(FOwnerForm, FID, FParams, FValue);
end;

procedure TWindowsCopyFilesThread.CreateProgress(MaxCount: Integer);
begin
  FIntParam := MaxCount;
  SynchronizeEx(CreateProgressSync);
end;

procedure TWindowsCopyFilesThread.ShowProgress(Sender: TObject);
begin
  SynchronizeEx(ShowProgressSync);
end;

procedure TWindowsCopyFilesThread.UpdateProgress(Position: Integer);
begin
  FIntParam := Position;
  SynchronizeEx(UpdateProgressSync);
end;

procedure TWindowsCopyFilesThread.CloseProgress(Sender: TObject);
begin
  SynchronizeEx(CloseProgressSync);
end;

procedure TWindowsCopyFilesThread.CreateProgressSync;
begin
  FProgressWindow := GetProgressWindow;
  FProgressWindow.OneOperation := True;
  FProgressWindow.MaxPosCurrentOperation := FIntParam;
end;

procedure TWindowsCopyFilesThread.ShowProgressSync;
begin
  FProgressWindow.Show;
  FProgressWindow.Repaint;
  FProgressWindow.DoubleBuffered := True;
end;

procedure TWindowsCopyFilesThread.UpdateProgressSync;
begin
  FProgressWindow.XPosition := FIntParam;
  FProgressWindow.Repaint;
end;

procedure TWindowsCopyFilesThread.CloseProgressSync;
begin
  FProgressWindow.Release;
end;

end.

