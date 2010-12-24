unit uExplorerThreadPool;

interface

uses Windows, Math, Classes, SysUtils, SyncObjs,
     dolphin_db, ExplorerTypes, UnitDBDeclare,
     uMultiCPUThreadManager, uThreadForm, uThreadEx, uTime, uMemory,
     uConstants, UnitDBCommon;

type
  TExplorerThreadPool = class(TThreadPoolCustom)
  protected
    procedure AddNewThread(Thread : TMultiCPUThread); override;
  public
    class function Instance : TExplorerThreadPool;
    procedure ExtractImage(Sender : TMultiCPUThread; Info: TOneRecordInfo; CryptedFile: Boolean; FileID : TGUID);
    procedure ExtractDirectoryPreview(Sender : TMultiCPUThread; DirectoryPath: string; FileID : TGUID);
    procedure ExtractBigImage(Sender : TMultiCPUThread; FileName: string; Rotated : Integer; FileID : TGUID);
  end;

implementation

uses ExplorerThreadUnit, ExplorerUnit;

var
   ExplorerThreadPool : TExplorerThreadPool = nil;

{ TExplorerThreadPool }

procedure TExplorerThreadPool.AddNewThread(Thread: TMultiCPUThread);
begin
  if (Thread <> nil) and (AvaliableThreadsCount + BusyThreadsCount < Min(MAX_THREADS_USE, ProcessorCount + 1)) then
    AddAvaliableThread(TExplorerThread.Create('', '', THREAD_TYPE_THREAD_PREVIEW, TExplorerThread(Thread).ExplorerInfo, TExplorerForm(Thread.ThreadForm), TExplorerThread(Thread).FUpdaterInfo, Thread.StateID));
end;

procedure TExplorerThreadPool.ExtractImage(Sender : TMultiCPUThread; Info: TOneRecordInfo; CryptedFile: Boolean; FileID : TGUID);
var
  Thread : TExplorerThread;
  Avaliablethread : TExplorerThread;
begin
  FSync.Enter;
  try
    Thread := Sender as TExplorerThread;
    if Thread = nil then
      raise Exception.Create('Sender is not TExplorerThread!');

    Avaliablethread := TExplorerThread(GetAvaliableThread(Sender));

    if Avaliablethread <> nil then
    begin
      Avaliablethread.ThreadForm := Sender.ThreadForm;
      Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
      Avaliablethread.FUpdaterInfo := Thread.FUpdaterInfo;
      if Thread.FUpdaterInfo.FileInfo <> nil then
        Avaliablethread.FUpdaterInfo.FileInfo := TExplorerFileInfo(Thread.FUpdaterInfo.FileInfo.Copy);
      Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
      Avaliablethread.StateID := Thread.StateID;
      Avaliablethread.FInfo := Info;
      Avaliablethread.IsCryptedFile := CryptedFile;
      Avaliablethread.FFileID := FileID;
      Avaliablethread.Mode := THREAD_PREVIEW_MODE_IMAGE;
      Avaliablethread.OwnerThreadType := Thread.ThreadType;

      StartThread(Thread, Avaliablethread);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerThreadPool.ExtractBigImage(Sender: TMultiCPUThread;
  FileName: string; Rotated: Integer; FileID: TGUID);
var
  Thread : TExplorerThread;
  Avaliablethread : TExplorerThread;
begin
  FSync.Enter;
  try
    Thread := Sender as TExplorerThread;
    if Thread = nil then
      raise Exception.Create('Sender is not TExplorerThread!');

    Avaliablethread := TExplorerThread(GetAvaliableThread(Sender));

    if Avaliablethread <> nil then
    begin
      Avaliablethread.ThreadForm := Sender.ThreadForm;
      Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
      Avaliablethread.FUpdaterInfo := Thread.FUpdaterInfo;
      if Thread.FUpdaterInfo.FileInfo <> nil then
        Avaliablethread.FUpdaterInfo.FileInfo := TExplorerFileInfo(Thread.FUpdaterInfo.FileInfo.Copy);
      Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
      Avaliablethread.StateID := Thread.StateID;
      Avaliablethread.FInfo.ItemFileName := FileName;
      Avaliablethread.FInfo.ItemRotate := Rotated;
      Avaliablethread.IsCryptedFile := False;
      Avaliablethread.FFileID := FileID;
      Avaliablethread.Mode := THREAD_PREVIEW_MODE_BIG_IMAGE;
      Avaliablethread.OwnerThreadType := Thread.ThreadType;

      StartThread(Thread, Avaliablethread);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerThreadPool.ExtractDirectoryPreview(Sender: TMultiCPUThread;
  DirectoryPath: string; FileID: TGUID);
var
  Thread : TExplorerThread;
  Avaliablethread : TExplorerThread;
begin
  FSync.Enter;
  try
    Thread := Sender as TExplorerThread;
    if Thread = nil then
      raise Exception.Create('Sender is not TExplorerThread!');

    Avaliablethread := TExplorerThread(GetAvaliableThread(Sender));

    if Avaliablethread <> nil then
    begin
      Avaliablethread.ThreadForm := Sender.ThreadForm;
      Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
      Avaliablethread.FUpdaterInfo := Thread.FUpdaterInfo;
      if Thread.FUpdaterInfo.FileInfo <> nil then
        Avaliablethread.FUpdaterInfo.FileInfo := TExplorerFileInfo(Thread.FUpdaterInfo.FileInfo.Copy);
      Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
      Avaliablethread.StateID := Thread.StateID;
      Avaliablethread.FInfo.ItemFileName := DirectoryPath;
      Avaliablethread.IsCryptedFile := False;
      Avaliablethread.FFileID := FileID;
      Avaliablethread.Mode := THREAD_PREVIEW_MODE_DIRECTORY;
      Avaliablethread.OwnerThreadType := Thread.ThreadType;

      StartThread(Thread, Avaliablethread);
    end;
  finally
    FSync.Leave;
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
