unit uExplorerThreadPool;

interface

uses Windows, Math, Classes, SysUtils, SyncObjs, dolphin_db, ExplorerTypes, uThreadForm, uThreadEx;

type
  TExplorerThreadPool = class(TObject)
  private
    FAvaliableThreadList : TList;
    FBusyThreadList : TList;
    FSync : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TExplorerThreadPool;
    procedure ExtractImage(Sender : TThreadEx; Info: TOneRecordInfo; CryptedFile: Boolean; FileID : TGUID);
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

procedure TExplorerThreadPool.ExtractImage(Sender : TThreadEx; Info: TOneRecordInfo; CryptedFile: Boolean; FileID : TGUID);
const
  MAX = 4;
var
  Thread : TExplorerThread;
  Avaliablethread : TExplorerThread;
  ThreadHandles : array[0 .. MAX - 1] of THandle;
  I : Integer;
begin
  FSync.Enter;
  try
    Thread := Sender as TExplorerThread;
    if Thread = nil then
      raise Exception.Create('Sender is not TExplorerThread!');

    if FAvaliableThreadList.Count + FBusyThreadList.Count < Min(MAX, ProcessorCount) then
      FAvaliableThreadList.Add(TExplorerThread.Create('', '::THREAD_IMAGES', THREAD_TYPE_THREAD_IMAGE, Thread.ExplorerInfo, TExplorerForm(Thread.ThreadForm), Thread.FUpdaterInfo, Thread.StateID));

    while FAvaliableThreadList.Count = 0 do
    begin     
      for I := FBusyThreadList.Count - 1 downto 0 do
      begin
        if TThread(FBusyThreadList[I]).Suspended then
        begin
          FAvaliableThreadList.Add(FBusyThreadList[I]);
          FBusyThreadList.Delete(I);
        end;
      end;

      if FAvaliableThreadList.Count > 0 then
        Break;

      for I := 0 to FBusyThreadList.Count - 1 do
        ThreadHandles[I] := TExplorerThread(FBusyThreadList[I]).FEvent;
      
      WaitForMultipleObjects(FBusyThreadList.Count, @ThreadHandles[0], False, INFINITE);
    end;

    if FAvaliableThreadList.Count > 0 then
    begin
      Avaliablethread := FAvaliableThreadList[0];
      FAvaliableThreadList.Remove(Avaliablethread);
      FBusyThreadList.Add(Avaliablethread);
      Avaliablethread.FUpdaterInfo := Thread.FUpdaterInfo;
      Avaliablethread.ExplorerInfo := Thread.ExplorerInfo;
      Avaliablethread.StateID := Thread.StateID;
      Avaliablethread.FInfo := Info;
      Avaliablethread.IsCryptedFile := CryptedFile;
      Avaliablethread.FFileID := FileID;
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
