unit UnitSearchBigImagesLoaderThread;

interface

uses
  Windows, Classes, Forms, Dolphin_DB, SysUtils, Graphics, GraphicCrypt, Math,
  RAWImage, UnitDBDeclare, UnitDBCommonGraphics, UnitDBCommon, ImageConverting,
  UnitCDMappingSupport, uThreadForm, uLogger, uThreadEx, uMemory;

type
  TSearchBigImagesLoaderThread = class(TThreadEx)
  private
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
    FUpdating : Boolean;
    FData : TSearchRecordArray;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(Sender : TThreadForm; SID : TGUID;
      OnDone : TNotifyEvent; PictureSize : integer; Data : TSearchRecordArray; Updating : boolean = false);
    procedure VisibleUp(TopIndex: integer);
    procedure GetVisibleFiles;  
    procedure FileNameExists;  
    procedure InitializeLoadingBigImages;  
    procedure SetProgressPosition;
    procedure ReplaceBigBitmap;
    procedure EndLoading;
    procedure ValidateThread;
  end;

  var
    SearchUpdateBigImageThreadsCount : Integer = 0;

implementation

uses Searching, Language, ExplorerThreadUnit;

constructor TSearchBigImagesLoaderThread.Create(Sender: TThreadForm; SID: TGUID; OnDone: TNotifyEvent; PictureSize: integer;
  Data : TSearchRecordArray; Updating : Boolean = false);
begin    
  inherited Create(Sender, SID);
  FSender := Sender;
  FOnDone := OnDone;
  FPictureSize := PictureSize;
  FData := Data;
  FUpdating := Updating;
  Resume;
end;

procedure TSearchBigImagesLoaderThread.VisibleUp(TopIndex: integer);
var
  i, c : integer;
  j : integer;
  temp : TSearchRecord;
begin
 c:=TopIndex;
 for i:=0 to Length(FVisibleFiles)-1 do
 for j:=TopIndex to fData.Count-1 do
 begin
  if FVisibleFiles[i]=fData[j].FileName then
  begin
   if c>=fData.Count then break;
   temp:=fData[c];
   fData[c]:=fData[j];
   fData[j]:=temp;
   inc(c);
  end;
 end;   
end;

procedure TSearchBigImagesLoaderThread.Execute;
var
  I : Integer;
  FGraphicClass : TGraphicClass;
  FGraphic : TGraphic;
  PassWord, FileName : String;
  FBit, TempBitmap : TBitmap;
  W, H : integer;
begin
  FreeOnTerminate := True;

  while SearchUpdateBigImageThreadsCount < (ProcessorCount + 1) do
    Sleep(10);

  Inc(SearchUpdateBigImageThreadsCount);
  try

  if not FUpdating then
    SynchronizeEx(InitializeLoadingBigImages);

  for I := 0 to FData.Count - 1 do
  begin

    if I mod 5 = 0 then
    begin
      Priority := tpNormal;
      Synchronize(GetVisibleFiles);
      VisibleUp(I);
    end;

    Synchronize(ValidateThread);

    if Terminated then
      Break;

    FileName := ProcessPath(FData[I].FileName);

    FGraphicClass := GetGraphicClass(ExtractFileExt(FData[I].FileName), False);
    FGraphic := FGraphicClass.Create;
    try

      if GraphicCrypt.ValidCryptGraphicFile(FileName) then
      begin
        PassWord:=DBKernel.FindPasswordForCryptImageFile(FileName);
        if PassWord = '' then
          Continue;

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
        JPEGScale(FGraphic, FPictureSize, FPictureSize);

        if Min(FGraphic.Height, FGraphic.Width) > 1 then
          LoadImageX(FGraphic, FBit, Theme_ListColor);

        TempBitmap:=TBitmap.Create;
        try
          TempBitmap.PixelFormat := pf24bit;
          W := FBit.Width;
          H := FBit.Height;
          ProportionalSize(FPictureSize, FPictureSize, W, H);
          TempBitmap.Width := W;
          TempBitmap.Height := H;
          DoResize(W, H, FBit, TempBitmap);
          ApplyRotate(TempBitmap, FData[I].Rotation);
          BitmapParam := TempBitmap;

          SynchronizeEx(ReplaceBigBitmap);
        finally
          F(TempBitmap);
        end;
      finally
        F(FBit);
      end;
    finally
      F(FGraphic);
    end;

    FI := I + 1;
    IntParam := FI;

    if not FUpdating then
      SynchronizeEx(SetProgressPosition);
  end;

  if not FUpdating then
    SynchronizeEx(EndLoading);

  finally
    Dec(SearchUpdateBigImageThreadsCount);
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
    Label7.Caption:=TEXT_MES_LOADING_BIG_IMAGES;
    PbProgress.Text:=format(TEXT_MES_LOADING_BIG_IMAGES_F,[IntToStr(intparam)]);
    (FSender as TSearchForm).tbStopOperation.Enabled:=true;
  end;
end;

procedure TSearchBigImagesLoaderThread.FileNameExists;
begin
  BoolParam := (FSender as TSearchForm).FileNameExistsInList(StrParam);
end;

procedure TSearchBigImagesLoaderThread.GetVisibleFiles;
begin
  FVisibleFiles:=(FSender as TSearchForm).GetVisibleItems;
  if not FSender.Active then Priority:=tpLowest;
end;

procedure TSearchBigImagesLoaderThread.SetProgressPosition;
begin
  (FSender as TSearchForm).PbProgress.MaxValue:=fData.Count;
  (FSender as TSearchForm).PbProgress.Position:=IntParam;
  (FSender as TSearchForm).PbProgress.text:=TEXT_MES_PROGRESS_PR;
end;

procedure TSearchBigImagesLoaderThread.ReplaceBigBitmap;
begin
 (FSender as TSearchForm).ReplaceBitmapWithPath(StrParam,BitmapParam);
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

procedure TSearchBigImagesLoaderThread.ValidateThread;
begin
  //Empty method
end;

end.
