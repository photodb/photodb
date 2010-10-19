unit UnitSearchBigImagesLoaderThread;

interface

uses
  Windows, Classes, Forms, Dolphin_DB, SysUtils, Graphics, GraphicCrypt, Math,
  RAWImage, UnitDBDeclare, UnitDBCommonGraphics, UnitDBCommon, ImageConverting,
  UnitCDMappingSupport, uThreadForm, uLogger, uThreadEx, uMemory,
  uMultiCPUThreadManager;

type
  TSearchBigImagesLoaderThread = class(TMultiCPUThread)
  private
    { Private declarations }
    FSender: TThreadForm;
    FOnDone: TNotifyEvent;
    FPictureSize : Integer;
    FVisibleFiles : TArStrings;
    BoolParam : Boolean;
    StrParam : string;
    OldInformationText : string;
    IntParam : Integer;
    BitmapParam : TBitmap;
    FI : Integer;
    FMainThread : Boolean;
    FData : TDBPopupMenuInfo;
    FImageFileName : string;
    FImageRotation : Integer;
  protected
    procedure Execute; override;
    function IsVirtualTerminate : Boolean; override;
    procedure DoMultiProcessorTask; override;
    procedure ExtractBigImage(PictureSize : Integer; FileName: string; Rotation : Integer);
  public
    constructor Create(Sender : TThreadForm; SID : TGUID;
      OnDone : TNotifyEvent; PictureSize : Integer; Data : TDBPopupMenuInfo; MainThread : Boolean);
    destructor Destroy; override;
    procedure VisibleUp(TopIndex: integer);
    procedure GetVisibleFiles;
    procedure FileNameExists;
    procedure InitializeLoadingBigImages;
    procedure SetProgressPosition;
    procedure ReplaceBigBitmap;
    procedure EndLoading;
    property ImageFileName : string read FImageFileName write FImageFileName;
    property PictureSize : Integer read FPictureSize write FPictureSize;
    property ImageRotation : Integer read FImageRotation write FImageRotation;
  end;

var
  SearchUpdateBigImageThreadsCount: Integer = 0;

implementation

uses Searching, Language, uSearchThreadPool;

constructor TSearchBigImagesLoaderThread.Create(Sender: TThreadForm; SID: TGUID; OnDone: TNotifyEvent; PictureSize: integer;
  Data : TDBPopupMenuInfo; MainThread : Boolean);
begin
  inherited Create(Sender, SID);
  FSender := Sender;
  FOnDone := OnDone;
  FPictureSize := PictureSize;
  FData := Data;
  FMainThread := MainThread;
end;

procedure TSearchBigImagesLoaderThread.VisibleUp(TopIndex: integer);
var
  I, C: Integer;
  J: Integer;
  Temp: TDBPopupMenuInfoRecord;
begin
  C := TopIndex;
  for I := 0 to Length(FVisibleFiles) - 1 do
    for J := TopIndex to FData.Count - 1 do
    begin
      if FVisibleFiles[I] = FData[J].FileName then
      begin
        if C >= FData.Count then
          Break;
        Temp := FData[C];
        FData[C] := FData[J];
        FData[J] := Temp;
        Inc(C);
      end;
    end;
end;

procedure TSearchBigImagesLoaderThread.Execute;
var
  I : Integer;
begin
  FreeOnTerminate := True;

  if not FMainThread then
  begin
    StartMultiThreadWork;
    Exit;
  end;

  while SearchUpdateBigImageThreadsCount > (ProcessorCount + 1) do
    Sleep(10);

  Inc(SearchUpdateBigImageThreadsCount);
  try

    SynchronizeEx(InitializeLoadingBigImages);

    for I := 0 to FData.Count - 1 do
    begin

      if I mod 5 = 0 then
      begin
        Synchronize(GetVisibleFiles);
        VisibleUp(I);
      end;

      if Terminated then
        Break;

      if ProcessorCount > 1 then
        TSearchThreadPool.Instance.CreateBigImage(Self, FPictureSize, FData[I].FileName, FData[I].Rotation)
      else
        ExtractBigImage(FPictureSize, FData[I].FileName, FData[I].Rotation);

      FI := I + 1;
      IntParam := FI;

      SynchronizeEx(SetProgressPosition);
    end;

    SynchronizeEx(EndLoading);

  finally
    Dec(SearchUpdateBigImageThreadsCount);
  end;
end;

procedure TSearchBigImagesLoaderThread.ExtractBigImage(PictureSize: Integer;
  FileName: string; Rotation : Integer);
var
  FGraphicClass : TGraphicClass;
  FGraphic : TGraphic;
  PassWord : String;
  FBit, TempBitmap : TBitmap;
  W, H : integer;
begin
  FileName := ProcessPath(FileName);

  FGraphicClass := GetGraphicClass(ExtractFileExt(FileName), False);
  if FGraphicClass = nil then
    Exit;

  FGraphic := FGraphicClass.Create;
  try

    if GraphicCrypt.ValidCryptGraphicFile(FileName) then
    begin
      PassWord:=DBKernel.FindPasswordForCryptImageFile(FileName);
      if PassWord = '' then
        Exit;

      F(FGraphic);
      FGraphic := DeCryptGraphicFile(FileName, PassWord);
    end else
    begin
      if FGraphic is TRAWImage then
      begin
        if not (FGraphic as TRAWImage).LoadThumbnailFromFile(FileName, FPictureSize, FPictureSize) then
          (FGraphic as TRAWImage).LoadFromFile(FileName);
      end else
        FGraphic.LoadFromFile(FileName);

    end;

    FBit := TBitmap.Create;
    try
      FBit.PixelFormat := pf24bit;
      JPEGScale(FGraphic, PictureSize, PictureSize);

      if Min(FGraphic.Height, FGraphic.Width) > 1 then
        LoadImageX(FGraphic, FBit, clWindow);

      TempBitmap:=TBitmap.Create;
      try
        TempBitmap.PixelFormat := pf24bit;
        W := FBit.Width;
        H := FBit.Height;
        ProportionalSize(PictureSize, PictureSize, W, H);
        TempBitmap.Width := W;
        TempBitmap.Height := H;
        DoResize(W, H, FBit, TempBitmap);
        ApplyRotate(TempBitmap, Rotation);
        BitmapParam := TempBitmap;
        StrParam := FileName;
        SynchronizeEx(ReplaceBigBitmap);
        TempBitmap := BitmapParam;
      finally
        F(TempBitmap);
      end;
    finally
      F(FBit);
    end;
  finally
    F(FGraphic);
  end;
end;

procedure TSearchBigImagesLoaderThread.InitializeLoadingBigImages;
begin
  with (FSender as TSearchForm) do
  begin
    PbProgress.Position:=0;
    PbProgress.MaxValue:=intparam;
    //Saving text information
    OldInformationText:=Label7.Caption;
    Label7.Caption:= L('Loading previews');
    PbProgress.Text:=format(L('Loading previews (%s)'),[IntToStr(intparam)]);
    (FSender as TSearchForm).tbStopOperation.Enabled:=true;
  end;
end;

function TSearchBigImagesLoaderThread.IsVirtualTerminate: Boolean;
begin
  Result := not FMainThread;
end;

procedure TSearchBigImagesLoaderThread.FileNameExists;
begin
  BoolParam := (FSender as TSearchForm).FileNameExistsInList(StrParam);
end;

procedure TSearchBigImagesLoaderThread.GetVisibleFiles;
begin
  FVisibleFiles:=(FSender as TSearchForm).GetVisibleItems;
end;

procedure TSearchBigImagesLoaderThread.SetProgressPosition;
begin
  (FSender as TSearchForm).PbProgress.MaxValue:=fData.Count;
  (FSender as TSearchForm).PbProgress.Position:=IntParam;
  (FSender as TSearchForm).PbProgress.text:=TEXT_MES_PROGRESS_PR;
end;

procedure TSearchBigImagesLoaderThread.ReplaceBigBitmap;
begin
  if (FSender as TSearchForm).ReplaceBitmapWithPath(StrParam, BitmapParam) then
    BitmapParam := nil;
end;

destructor TSearchBigImagesLoaderThread.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TSearchBigImagesLoaderThread.DoMultiProcessorTask;
begin
  if Mode <> 0 then
    ExtractBigImage(PictureSize, FImageFileName, ImageRotation);
end;

procedure TSearchBigImagesLoaderThread.EndLoading;
begin
  if (FSender as TSearchForm).tbStopOperation.Enabled then
  begin
   (FSender as TSearchForm).tbStopOperation.Click;
   (FSender as TSearchForm).PbProgress.Text:=TEXT_MES_DONE;
   (FSender as TSearchForm).Label7.Caption:=OldInformationText;
   (FSender as TSearchForm).PbProgress.Position:=0;
   (FSender as TSearchForm).PbProgress.MaxValue:=1;
  end;
end;

end.
