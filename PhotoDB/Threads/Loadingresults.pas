unit Loadingresults;

interface

uses
  UnitDBKernel,
  dolphin_db,
  jpeg,
  ComCtrls,
  CommCtrl,
  windows,
  Classes,
  Math,
  DB,
  SysUtils,
  Controls,
  Graphics,
  Dialogs,
  GraphicCrypt,
  Forms,
  StrUtils,
  win32crc,
  EasyListview,
  DateUtils,
  UnitSearchBigImagesLoaderThread,
  UnitDBDeclare,
  UnitPasswordForm,
  UnitDBCommonGraphics,
  uThreadForm,
  uThreadEx,
  uLogger,
  uJpegUtils,
  CommonDBSupport,
  uFileUtils,
  uTranslate,
  uMemory,
  ActiveX,
  uBitmapUtils,
  uAssociatedIcons,
  uDBPopupMenuInfo,
  uConstants,
  uGraphicUtils,
  uDBBaseTypes,
  uDBFileTypes,
  uRuntime,
  uDBGraphicTypes,
  uSysUtils,
  uTime,
  uDBUtils,
  uDatabaseSearch,
  uFormInterfaces;

type
  SearchThread = class(TThreadEx)
  private
    { Private declarations }
    FPictureSize: Integer;
    FErrorMsg: string;
    StrParam: string;
    IntParam: Integer;
    ExtendedParam: Extended;
    FDataParam: TDBPopupMenuInfo;
    FDS: TDatabaseSearch;
    procedure ErrorSQL;
    procedure DoOnDone;
    procedure GetPassForFile;
    procedure StartLoadingList;
    procedure SetPercentProgress(Value: Extended);
    procedure SetPercentProgressSync;
    procedure NotifySearchEnd;
  protected
    FOnDone: TNotifyEvent;
    BitmapParam: TBitmap;
    procedure Execute; override;
    procedure UpdateQueryEstimateCount;
    procedure SendDataPacketToForm;
    procedure NitifyEstimateStart;
    procedure NitifyEstimateEnd;

    //handlers
    procedure OnEstimateCountUpdate(Sender: TDatabaseSearch; Count: Integer);
    function OnGetFilePassword(Sender: TDatabaseSearch; FileName: string): string;
    procedure OnError(Sender: TDatabaseSearch; Text: string);
    procedure OnProgress(Sender: TDatabaseSearch; Progress: Extended);
    procedure OnPacketReady(Sender: TDatabaseSearch; Packet: TDBPopupMenuInfo);
  public
    constructor Create(Sender: TThreadForm; SID: TGUID; SearchParams: TSearchQuery; OnDone: TNotifyEvent; PictureSize: Integer);
    destructor Destroy; override;
  end;

implementation

uses
  Searching;

constructor SearchThread.Create(Sender: TThreadForm; SID: TGUID; SearchParams: TSearchQuery; OnDone: TNotifyEvent;
  PictureSize: Integer);
begin
  inherited Create(Sender, SID);
  FPictureSize := PictureSize;
  //LastYear := 0;
  FOnDone := OnDone;
  FDS := TDatabaseSearch.Create(Self, SearchParams);
  FDS.OnEstimateCountUpdate := OnEstimateCountUpdate;
  FDS.OnGetFilePassword := OnGetFilePassword;
  FDS.OnPacketReady := OnPacketReady;
  Start;
end;

procedure SearchThread.ErrorSQL;
begin
  (ThreadForm as TSearchForm).ErrorQSL(FErrorMsg);
end;

procedure SearchThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    if FDS.SearchParams.IsEstimate then
      SynchronizeEx(NitifyEstimateStart)
    else
      SynchronizeEx(StartLoadingList);

    try
      //#8 - invalid query identify, needed from script executing
      if FDS.SearchParams.Query = #8 then
        Exit;

      FDS.ExecuteSearch;
    finally
      if not FDS.SearchParams.IsEstimate then
      begin
        SynchronizeEx(NotifySearchEnd);
        SynchronizeEx(DoOnDone);
      end else
        SynchronizeEx(NitifyEstimateEnd);
    end;
  finally
    CoUninitialize;
  end;
end;

destructor SearchThread.Destroy;
begin
  F(FDS);
  inherited;
end;

procedure SearchThread.DoOnDone;
begin
  (ThreadForm as TSearchForm).StopLoadingList;
  if FDS.CurrentQueryType = QT_W_SCAN_FILE then
  begin
    (ThreadForm as TSearchForm).DoSetSearchByComparing;
    (ThreadForm as TSearchForm).Decremect1.Checked := True;
    (ThreadForm as TSearchForm).SortbyCompare1Click((ThreadForm as TSearchForm).SortbyCompare1);
  end else
  begin
    if (ThreadForm as TSearchForm).SortbyCompare1.Checked then
      (ThreadForm as TSearchForm).SortbyDate1Click((ThreadForm as TSearchForm).SortbyDate1);
  end;

  //Loading big images
  if FPictureSize <> ThImageSize then
    (ThreadForm as TSearchForm).ReloadBigImages
  else
    if Assigned(FOnDone) then
      FOnDone(Self);
end;

procedure SearchThread.GetPassForFile;
begin
  StrParam := RequestPasswordForm.ForImage(StrParam);
end;

procedure SearchThread.NitifyEstimateStart;
begin
  (ThreadForm as TSearchForm).NitifyEstimateStart;
end;

procedure SearchThread.NitifyEstimateEnd;
begin
  (ThreadForm as TSearchForm).NitifyEstimateEnd;
end;

procedure SearchThread.SendDataPacketToForm;
begin
  (ThreadForm as TSearchForm).LoadDataPacket(FDataParam);
end;

procedure SearchThread.StartLoadingList;
begin
  (ThreadForm as TSearchForm).NotifySearchingStart;
end;

procedure SearchThread.NotifySearchEnd;
begin
  (ThreadForm as TSearchForm).NotifySearchingEnd;
end;

procedure SearchThread.UpdateQueryEstimateCount;
begin
  (ThreadForm as TSearchForm).UpdateEstimateState(IntParam);
end;

procedure SearchThread.SetPercentProgress(Value: Extended);
begin
  ExtendedParam := Value;
  SynchronizeEx(SetPercentProgressSync);
end;

procedure SearchThread.SetPercentProgressSync;
begin
  (ThreadForm as TSearchForm).UpdateProgressState(ExtendedParam);
end;

procedure SearchThread.OnError(Sender: TDatabaseSearch; Text: string);
begin
  FErrorMsg := Text;
  SynchronizeEx(ErrorSQL);
end;

procedure SearchThread.OnEstimateCountUpdate(Sender: TDatabaseSearch;
  Count: Integer);
begin
  IntParam := Count;
  SynchronizeEx(UpdateQueryEstimateCount);
end;

function SearchThread.OnGetFilePassword(Sender: TDatabaseSearch;
  FileName: string): string;
begin
  StrParam := FileName;
  SynchronizeEx(GetPassForFile);
  Result := StrParam;
end;

procedure SearchThread.OnPacketReady(Sender: TDatabaseSearch;
  Packet: TDBPopupMenuInfo);
begin
  FDataParam := Packet;
  SynchronizeEx(SendDataPacketToForm);
end;

procedure SearchThread.OnProgress(Sender: TDatabaseSearch; Progress: Extended);
begin
  SetPercentProgress(Progress);
end;

end.
