unit uExplorerThreadPool;

interface

uses
  Windows,
  Math,
  Classes,
  SysUtils,
  SyncObjs,
  ExplorerTypes,
  UnitDBDeclare,
  uMultiCPUThreadManager,
  uThreadEx,
  uTime,
  uMemory,
  uConstants,
  uRuntime;

type
  TExplorerThreadPool = class(TThreadPoolCustom)
  protected
    procedure AddNewThread(Thread: TMultiCPUThread); override;
  public
    class function Instance: TExplorerThreadPool;
    procedure ExtractImage(Sender: TMultiCPUThread; Info: TMediaItem; CryptedFile: Boolean; FileID: TGUID);
    procedure ExtractDirectoryPreview(Sender: TMultiCPUThread; DirectoryPath: string; FileID: TGUID);
    procedure ExtractBigImage(Sender: TMultiCPUThread; FileName: string; ID, Rotated: Integer; FileID: TGUID);
  end;

implementation

uses
  ExplorerThreadUnit,
  ExplorerUnit;

var
   ExplorerThreadPool: TExplorerThreadPool = nil;

{ TExplorerThreadPool }

procedure TExplorerThreadPool.AddNewThread(Thread: TMultiCPUThread);
var
  ExplorerViewInfo: TExplorerViewInfo;
begin
  ExplorerViewInfo := TExplorerThread(Thread).ExplorerInfo;
  ExplorerViewInfo.View := -1;
  ExplorerViewInfo.PictureSize := 0;
  if (Thread <> nil) and (AvaliableThreadsCount + BusyThreadsCount < Min(MAX_THREADS_USE, ProcessorCount + 1)) then
    AddAvaliableThread(TExplorerThread.Create(nil, '', '', THREAD_TYPE_THREAD_PREVIEW, ExplorerViewInfo, nil, TUpdaterInfo.Create, Thread.StateID));
end;

procedure TExplorerThreadPool.ExtractImage(Sender: TMultiCPUThread; Info: TMediaItem; CryptedFile: Boolean; FileID: TGUID);
var
  Thread: TExplorerThread;
  Avaliablethread: TExplorerThread;
begin
  Thread := Sender as TExplorerThread;
  if Thread = nil then
    raise Exception.Create('Sender is not TExplorerThread!');

  Avaliablethread := TExplorerThread(GetAvaliableThread(Sender));

  if Avaliablethread <> nil then
  begin
    Avaliablethread.ThreadForm := Sender.ThreadForm;
    Avaliablethread.FContext := Thread.FContext;
    Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
    Avaliablethread.UpdaterInfo.Assign(Thread.UpdaterInfo);
    Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
    Avaliablethread.StateID := Thread.StateID;
    Avaliablethread.FInfo.Assign(Info, True);
    Avaliablethread.IsCryptedFile := CryptedFile;
    Avaliablethread.FFileID := FileID;
    Avaliablethread.Mode := THREAD_PREVIEW_MODE_IMAGE;
    Avaliablethread.OwnerThreadType := Thread.ThreadType;
    Avaliablethread.LoadingAllBigImages := Thread.LoadingAllBigImages;

    StartThread(Thread, Avaliablethread);
  end;
end;

procedure TExplorerThreadPool.ExtractBigImage(Sender: TMultiCPUThread;
  FileName: string; ID, Rotated: Integer; FileID: TGUID);
var
  Thread : TExplorerThread;
  Avaliablethread : TExplorerThread;
begin
  Thread := Sender as TExplorerThread;
  if Thread = nil then
    raise Exception.Create('Sender is not TExplorerThread!');

  Avaliablethread := TExplorerThread(GetAvaliableThread(Sender));

  if Avaliablethread <> nil then
  begin
    Avaliablethread.ThreadForm := Sender.ThreadForm;
    Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
    Avaliablethread.UpdaterInfo.Assign(Thread.UpdaterInfo);
    Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
    Avaliablethread.StateID := Thread.StateID;
    Avaliablethread.FInfo.FileName := FileName;
    Avaliablethread.FInfo.Rotation := Rotated;
    Avaliablethread.FInfo.ID := ID;
    Avaliablethread.IsCryptedFile := False;
    Avaliablethread.FFileID := FileID;
    Avaliablethread.Mode := THREAD_PREVIEW_MODE_BIG_IMAGE;
    Avaliablethread.OwnerThreadType := Thread.ThreadType;
    Avaliablethread.LoadingAllBigImages := Thread.LoadingAllBigImages;

    StartThread(Thread, Avaliablethread);
  end;
end;

procedure TExplorerThreadPool.ExtractDirectoryPreview(Sender: TMultiCPUThread;
  DirectoryPath: string; FileID: TGUID);
var
  Thread : TExplorerThread;
  Avaliablethread : TExplorerThread;
begin

  Thread := Sender as TExplorerThread;
  if Thread = nil then
    raise Exception.Create('Sender is not TExplorerThread!');

  Avaliablethread := TExplorerThread(GetAvaliableThread(Sender));

  if Avaliablethread <> nil then
  begin
    Avaliablethread.ThreadForm := Sender.ThreadForm;
    Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
    Avaliablethread.UpdaterInfo.Assign(Thread.UpdaterInfo);
    Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
    Avaliablethread.StateID := Thread.StateID;
    Avaliablethread.FInfo.FileName := DirectoryPath;
    Avaliablethread.IsCryptedFile := False;
    Avaliablethread.FFileID := FileID;
    Avaliablethread.Mode := THREAD_PREVIEW_MODE_DIRECTORY;
    Avaliablethread.OwnerThreadType := Thread.ThreadType;
    Avaliablethread.LoadingAllBigImages := Thread.LoadingAllBigImages;

    StartThread(Thread, Avaliablethread);
  end;
end;

class function TExplorerThreadPool.Instance: TExplorerThreadPool;
begin
  if ExplorerThreadPool = nil then
    ExplorerThreadPool := TExplorerThreadPool.Create;

  Result := ExplorerThreadPool;
end;

initialization

finalization

  F(ExplorerThreadPool);

end.
