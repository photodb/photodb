unit uExplorerThreadPool;

interface

uses Windows, Math, Classes, SysUtils, SyncObjs, dolphin_db, ExplorerTypes, uThreadForm, uThreadEx, uTime;

type
  TExplorerThreadPool = class(TObject)
  private
    FAvaliableThreadList : TList;
    FBusyThreadList : TList;
    FSync : TCriticalSection;
    procedure ThreadsCheck(Thread : TThreadEx);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TExplorerThreadPool;
    procedure ExtractImage(Sender : TThreadEx; Info: TOneRecordInfo; CryptedFile: Boolean; FileID : TGUID);   
    procedure ExtractDirectoryPreview(Sender : TThreadEx; DirectoryPath: string; FileID : TGUID);
  end;

implementation

uses ExplorerThreadUnit, ExplorerUnit;

var
   ExplorerThreadPool : TExplorerThreadPool = nil;

{ TExplorerThreadPool }

constructor TExplorerThreadPool.Create;
begin
  FAvaliableThreadList := TList.Create;
  FBusyThreadList := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TExplorerThreadPool.Destroy;
begin
  FSync.Free;
  FAvaliableThreadList.Free;
  FBusyThreadList.Free;
  inherited;
end;   

procedure TExplorerThreadPool.ThreadsCheck(Thread : TThreadEx);
const
  MAX = 4;
var
  ThreadHandles : array[0 .. MAX - 1] of THandle;
  I : Integer;
  s : string;
begin
  if FAvaliableThreadList.Count + FBusyThreadList.Count < Min(MAX, ProcessorCount) then
    FAvaliableThreadList.Add(TExplorerThread.Create('', '', THREAD_TYPE_THREAD_PREVIEW, TExplorerThread(Thread).ExplorerInfo, TExplorerForm(Thread.ThreadForm), TExplorerThread(Thread).FUpdaterInfo, Thread.StateID));

  while FAvaliableThreadList.Count = 0 do
  begin
    for I := FBusyThreadList.Count - 1 downto 0 do
    begin   
      if TExplorerThread(FBusyThreadList[I]).Suspended then
      begin
        FAvaliableThreadList.Add(FBusyThreadList[I]);
        FBusyThreadList.Delete(I);
      end else
        TExplorerThread(FBusyThreadList[I]).Resume;
    end;

    if FAvaliableThreadList.Count > 0 then
      Break;

    for I := 0 to FBusyThreadList.Count - 1 do
      ThreadHandles[I] := TExplorerThread(FBusyThreadList[I]).FEvent;

    s := 'WaitForMultipleObjects: ' + IntToStr(FBusyThreadList.Count) + ' - ';
    for I := 0 to FBusyThreadList.Count - 1 do
      s := s + ',' + IntToStr(TExplorerThread(FBusyThreadList[I]).FEvent);
    TW.I.Start(s);
    WaitForMultipleObjects(FBusyThreadList.Count, @ThreadHandles[0], False, 1000);
    Sleep(1);
    TW.I.Start('WaitForMultipleObjects END');
  end;
end;

procedure TExplorerThreadPool.ExtractImage(Sender : TThreadEx; Info: TOneRecordInfo; CryptedFile: Boolean; FileID : TGUID);
var
  Thread : TExplorerThread;
  Avaliablethread : TExplorerThread;
begin
  FSync.Enter;
  try
    Thread := Sender as TExplorerThread;
    if Thread = nil then
      raise Exception.Create('Sender is not TExplorerThread!');

    ThreadsCheck(Sender);

    if FAvaliableThreadList.Count > 0 then
    begin
      Avaliablethread := FAvaliableThreadList[0];
      FAvaliableThreadList.Remove(Avaliablethread);
      FBusyThreadList.Add(Avaliablethread);     
      Avaliablethread.Priority := tpNormal; 
      Avaliablethread.ThreadForm := Sender.ThreadForm;
      Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
      Avaliablethread.FUpdaterInfo := Thread.FUpdaterInfo;
      Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
      Avaliablethread.StateID := Thread.StateID;
      Avaliablethread.FInfo := Info;
      Avaliablethread.IsCryptedFile := CryptedFile;
      Avaliablethread.FFileID := FileID;
      Avaliablethread.FThreadPreviewMode := THREAD_PREVIEW_MODE_IMAGE;
      Avaliablethread.FPreviewInProgress := True;  
      Thread.RegisterSubThread(Avaliablethread);
      TW.I.Start('Resume thread:' + IntToStr(Avaliablethread.ThreadID));
      Avaliablethread.Resume;
    end
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerThreadPool.ExtractDirectoryPreview(Sender: TThreadEx;
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

    ThreadsCheck(Sender);

    if FAvaliableThreadList.Count > 0 then
    begin
      Avaliablethread := FAvaliableThreadList[0];
      FAvaliableThreadList.Remove(Avaliablethread);
      FBusyThreadList.Add(Avaliablethread);     
      Avaliablethread.Priority := tpNormal; 
      Avaliablethread.ThreadForm := Sender.ThreadForm;
      Avaliablethread.FSender := TExplorerForm(Sender.ThreadForm);
      Avaliablethread.FUpdaterInfo := Thread.FUpdaterInfo;
      Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
      Avaliablethread.StateID := Thread.StateID;
      Avaliablethread.FInfo.ItemFileName := DirectoryPath;
      Avaliablethread.IsCryptedFile := False;
      Avaliablethread.FFileID := FileID;
      Avaliablethread.FThreadPreviewMode := THREAD_PREVIEW_MODE_DIRECTORY;  
      Avaliablethread.FPreviewInProgress := True;
      Thread.RegisterSubThread(Avaliablethread);
      TW.I.Start('Resume thread:' + IntToStr(Avaliablethread.ThreadID));
      Avaliablethread.Resume;
    end
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

  if ExplorerThreadPool <> nil then
    FreeAndNil(ExplorerThreadPool);

end.
