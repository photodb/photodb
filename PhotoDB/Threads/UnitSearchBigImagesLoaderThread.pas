unit UnitSearchBigImagesLoaderThread;

interface

uses
  Windows, Classes, Forms, Dolphin_DB, SysUtils, Graphics, GraphicCrypt, Math,
  RAWImage, UnitDBDeclare, UnitDBCommonGraphics, UnitDBCommon,
  UnitCDMappingSupport, uThreadForm, uLogger;

type
  TSearchBigImagesLoaderThread = class(TThread)
  private
   fSender: TThreadForm;
   fSID : TGUID;
   fOnDone: TNotifyEvent;
   fPictureSize : integer;
   FVisibleFiles : TArStrings;
   BoolParam : boolean;
   StrParam : String;
   OldInformationText : String;
   intparam : integer;
   BitmapParam : TBitmap;
   FI : integer;
   FUpdating : boolean;
   fData : TSearchRecordArray;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; Sender : TThreadForm; SID : TGUID;
      aOnDone : TNotifyEvent; PictureSize : integer; Data : TSearchRecordArray; Updating : boolean = false);
    destructor Destroy; override;
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
    SearchUpdateBigImageThreadsCount : integer = 0;    

//  GettingProcNum

implementation

uses Searching, Language, ExplorerThreadUnit;

constructor TSearchBigImagesLoaderThread.Create(CreateSuspennded: Boolean;
  Sender: TThreadForm; SID: TGUID; aOnDone: TNotifyEvent; PictureSize: integer;
  Data : TSearchRecordArray; Updating : boolean = false);
begin    
 inherited create(true);
 fSender:=Sender;
 fSID:=SID;
 fOnDone:=aOnDone;
 fPictureSize:=PictureSize;
 fData:=Data;
 FUpdating:=Updating;
 if not CreateSuspennded then Resume;
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
  i : integer;
  FPic : TPicture;
  PassWord : String;
  fbit, TempBitmap : TBitmap;
  w, h : integer;
  ProcNum : integer;
begin
 FPic:=nil;
 ProcNum:=GettingProcNum;
 FreeOnTerminate:=True;

 Repeat
  sleep(100);
 until SearchUpdateBigImageThreadsCount<(ProcNum+1);

 SearchUpdateBigImageThreadsCount:=SearchUpdateBigImageThreadsCount+1;

 if not fUpdating then
 Synchronize(InitializeLoadingBigImages);


 for i:=0 to fData.Count-1 do
 begin

  if i mod 5=0 then
  begin
   Priority:=tpNormal;
   Synchronize(GetVisibleFiles);
   VisibleUp(i);
   Sleep(5);
  end;
  Synchronize(ValidateThread);
  if BoolParam=false then break;

  StrParam:=fData[i].FileName;
  Synchronize(FileNameExists);

  if BoolParam then
  begin
   try
    FPic := TPicture.Create;
   except
    if FPic<>nil then
    FPic.Free;
    FPic:=nil;
    continue;
   end;
   try
    if GraphicCrypt.ValidCryptGraphicFile(ProcessPath(StrParam)) then
    begin
     PassWord:=DBKernel.FindPasswordForCryptImageFile(ProcessPath(StrParam));
     if PassWord='' then
     begin
      if FPic<>nil then FPic.Free;
      FPic:=nil;
      continue;
     end;
     FPic.Graphic:=GraphicCrypt.DeCryptGraphicFile(ProcessPath(StrParam),PassWord);
    end else
    begin
     if IsRAWImageFile(StrParam) then
     begin
      FPic.Graphic:=TRAWImage.Create;
      if not (FPic.Graphic as TRAWImage).LoadThumbnailFromFile(ProcessPath(StrParam),FPictureSize,FPictureSize) then
      FPic.Graphic.LoadFromFile(ProcessPath(StrParam));
     end else
     FPic.LoadFromFile(ProcessPath(StrParam));
    end;
   except
    if FPic<>nil then
    FPic.Free;
    FPic:=nil;
    continue;
   end;
   fbit:=nil;
   fbit:=TBitmap.create;
   fbit.PixelFormat:=pf24bit;
   JPEGScale(Fpic.Graphic,FPictureSize,FPictureSize);

   if Min(Fpic.Height,Fpic.Width)>1 then
   try
    LoadImageX(Fpic.Graphic,fbit,Theme_ListColor);
   except                     
    on e : Exception do EventLog(':TSearchBigImagesLoaderThread::Execute()/LoadImageX throw exception: '+e.Message);
   end;
   Fpic.Free;
   Fpic:=nil;

   TempBitmap:=TBitmap.create;
   TempBitmap.PixelFormat:=pf24bit;
   w:=fbit.Width;
   h:=fbit.Height;
   ProportionalSize(FPictureSize,FPictureSize,w,h);
   TempBitmap.Width:=w;
   TempBitmap.Height:=h;
   try
    DoResize(w,h,fbit,TempBitmap);
   except
   end;
   fbit.Free;
   fbit:=nil;
   ApplyRotate(TempBitmap, fData[i].Rotation);
   BitmapParam:=TempBitmap;
   FI:=i+1;
   IntParam:=FI;
         
   if not fUpdating then
   Synchronize(SetProgressPosition);
   Synchronize(ReplaceBigBitmap);
   TempBitmap.Free;
  end;
 end;

 if not fUpdating then
 Synchronize(EndLoading);
end;

procedure TSearchBigImagesLoaderThread.InitializeLoadingBigImages;
begin
  if not Terminated then
    if FSender.IsActualState(FSID) then
 with (FSender as TSearchForm) do
 begin
  PbProgress.Position:=0;
  PbProgress.MaxValue:=intparam;
  //Saving text information    
  OldInformationText:=Label7.Caption;
  Label7.Caption:=TEXT_MES_LOADING_BIG_IMAGES;
  PbProgress.Text:=format(TEXT_MES_LOADING_BIG_IMAGES_F,[IntToStr(intparam)]);
  (FSender as TSearchForm).ToolButton14.Enabled:=true;
 end;
end;

procedure TSearchBigImagesLoaderThread.FileNameExists;
begin
 BoolParam:=false;
  if not Terminated then
    if FSender.IsActualState(FSID) then
 if (FSender as TSearchForm).FileNameExistsInList(StrParam) then
 begin
  BoolParam:=true;
 end;
end;

procedure TSearchBigImagesLoaderThread.GetVisibleFiles;
begin

  if not Terminated then
    if FSender.IsActualState(FSID) then
 begin
  FVisibleFiles:=(FSender as TSearchForm).GetVisibleItems;    
  if not FSender.Active then Priority:=tpLowest;
 end
end;

procedure TSearchBigImagesLoaderThread.SetProgressPosition;
begin
  if not Terminated then
    if FSender.IsActualState(FSID) then
 begin
  (FSender as TSearchForm).PbProgress.MaxValue:=fData.Count;
  (FSender as TSearchForm).PbProgress.Position:=IntParam;
  (FSender as TSearchForm).PbProgress.text:=TEXT_MES_PROGRESS_PR;
 end;
end;

procedure TSearchBigImagesLoaderThread.ReplaceBigBitmap;
begin
  if not Terminated then
    if FSender.IsActualState(FSID) then
 if (FSender as TSearchForm).FileNameExistsInList(StrParam) then
 begin
  (FSender as TSearchForm).ReplaceBitmapWithPath(StrParam,BitmapParam);
 end;
end;

procedure TSearchBigImagesLoaderThread.EndLoading;
begin
  if not Terminated then
    if FSender.IsActualState(FSID) then
 begin
  if (FSender as TSearchForm).ToolButton14.Enabled then
  begin
   (FSender as TSearchForm).ToolButton14.Click;
   (FSender as TSearchForm).PbProgress.Text:=TEXT_MES_DONE;
   (FSender as TSearchForm).Label7.Caption:=OldInformationText;
   (FSender as TSearchForm).PbProgress.Position:=0;
   (FSender as TSearchForm).PbProgress.MaxValue:=1;
  end;
 end;
end;

destructor TSearchBigImagesLoaderThread.Destroy;
begin
 SearchUpdateBigImageThreadsCount:=SearchUpdateBigImageThreadsCount-1;
 inherited Destroy;
end;


procedure TSearchBigImagesLoaderThread.ValidateThread;
begin
 BoolParam:=false;
  if not Terminated then
    if FSender.IsActualState(FSID) then
 begin
  BoolParam:=true;
 end;
end;

end.
