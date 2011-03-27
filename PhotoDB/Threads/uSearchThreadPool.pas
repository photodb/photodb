unit uSearchThreadPool;

interface

uses
  Classes, SysUtils, Math, uMemory, uMultiCPUThreadManager, UnitDBCommon;

type
  TSearchThreadPool = class(TThreadPoolCustom)
  private
    { Private declarations }
  protected
    procedure AddNewThread(Thread : TMultiCPUThread); override;
  public
    { Public declarations }
    class function Instance : TSearchThreadPool;
    procedure CreateBigImage(Sender : TMultiCPUThread;
      PictureSize: Integer; FileName: string; Rotation : Integer);
  end;

implementation

uses UnitSearchBigImagesLoaderThread;

var
  SearchThreadPool : TSearchThreadPool = nil;

{ TSearchThreadPool }

procedure TSearchThreadPool.AddNewThread(Thread: TMultiCPUThread);
var
  SearchThread : TSearchBigImagesLoaderThread;
begin
  SearchThread := TSearchBigImagesLoaderThread(Thread);
  if (Thread <> nil) and (AvaliableThreadsCount + BusyThreadsCount < Min(MAX_THREADS_USE, ProcessorCount + 1)) then
    AddAvaliableThread(TSearchBigImagesLoaderThread.Create(
      SearchThread.ThreadForm,
      SearchThread.StateID,
      nil, 0, nil, False));
end;

procedure TSearchThreadPool.CreateBigImage(Sender: TMultiCPUThread;
  PictureSize: Integer; FileName: string; Rotation : Integer);
var
  Thread : TSearchBigImagesLoaderThread;
  AvaliableThread : TSearchBigImagesLoaderThread;
begin
  Lock;
  try
    Thread := Sender as TSearchBigImagesLoaderThread;
    if Thread = nil then
      raise Exception.Create('Sender is not TSearchBigImagesLoaderThread!');

    AvaliableThread := TSearchBigImagesLoaderThread(GetAvaliableThread(Sender));

    if Avaliablethread <> nil then
    begin
      AvaliableThread.ThreadForm := Sender.ThreadForm;
      AvaliableThread.StateID := Sender.StateID;
      AvaliableThread.Mode := MaxInt;
      AvaliableThread.PictureSize := PictureSize;
      AvaliableThread.ImageRotation := Rotation;
      AvaliableThread.ImageFileName := FileName;
      Avaliablethread.IsTerminated := False;
      StartThread(Thread, AvaliableThread);
    end;

  finally
    Unlock;
  end;
end;

class function TSearchThreadPool.Instance: TSearchThreadPool;
begin
  if SearchThreadPool = nil then
    SearchThreadPool := TSearchThreadPool.Create;

  Result := SearchThreadPool;
end;

initialization

finalization

  F(SearchThreadPool);

end.
