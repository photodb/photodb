unit UnitPanelLoadingBigImagesThread;

interface

uses
  Windows, Classes, SysUtils, Forms, Graphics, Math, GraphicCrypt, Dolphin_DB,
  UnitDBDeclare, RAWImage, UnitDBCommonGraphics, UnitDBCommon,
  UnitCDMappingSupport, uLogger;

type
  TPanelLoadingBigImagesThread = class(TThread)
  private     
  { Private declarations }
   fSender: TForm;
   fSID : TGUID;
   fOnDone: TNotifyEvent;
   fPictureSize : integer;
   fFiles : TImageContRecordArray;   
   FVisibleFiles : TArStrings;
   BoolParam : boolean;
   StrParam : String;
   OldInformationText : String;
   intparam : integer;
   BitmapParam : TBitmap;
   FI : integer;
   FUpdating : boolean;
    ////////////////////////////////
    procedure VisibleUp(TopIndex: integer);
    procedure FileNameExists;
    procedure GetVisibleFiles;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; Sender : TForm; SID : TGUID;
      aOnDone : TNotifyEvent; PictureSize : integer; Files : TImageContRecordArray; Updating : boolean = false);
    procedure ReplaceBigBitmap;     
    procedure DoStopLoading;
    destructor Destroy; override;
  end;

  var
    PanelUpdateBigImageThreadsCount : integer = 0;
    PanelUpdateBigImageThreadsCountByID : integer = 0;

implementation

uses UnitFormCont;

{ TPanelLoadingBigImagesThread }

constructor TPanelLoadingBigImagesThread.Create(CreateSuspennded: Boolean; Sender : TForm; SID : TGUID;
      aOnDone : TNotifyEvent; PictureSize : integer; Files : TImageContRecordArray; Updating : boolean = false);
begin
 inherited create(true);
 fSender:=Sender;
 fSID:=SID;
 fOnDone:=aOnDone;
 fPictureSize:=PictureSize;
 fFiles:=Files;
 FUpdating:=Updating;
 if not CreateSuspennded then Resume;
end;

procedure TPanelLoadingBigImagesThread.VisibleUp(TopIndex: integer);
var
  i, c : integer;
  j : integer;
  temp : TImageContRecord;
begin
 c:=TopIndex;
 for i:=0 to Length(FVisibleFiles)-1 do
 for j:=TopIndex to Length(FFiles)-1 do
 begin
  if FVisibleFiles[i]=FFiles[j].FileName then
  begin
   temp:=FFiles[c];
   FFiles[c]:=FFiles[j];
   FFiles[j]:=temp;
   inc(c);
  end;
 end;   
end;

procedure TPanelLoadingBigImagesThread.Execute;
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


 if not fUpdating then
 begin

  Repeat
   sleep(100);
  until PanelUpdateBigImageThreadsCount<(ProcNum+1);

  PanelUpdateBigImageThreadsCount:=PanelUpdateBigImageThreadsCount+1;

  for i:=0 to Length(FFiles)-1 do
  begin

   if i mod 5=0 then
   begin
    Priority:=tpNormal;
    Synchronize(GetVisibleFiles);
    VisibleUp(i);
    Sleep(5);
   end;

   StrParam:=FFiles[i].FileName;
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
      PassWord:=DBKernel.FindPasswordForCryptImageFile(StrParam);
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
       if not (FPic.Graphic as TRAWImage).LoadThumbnailFromFile(StrParam,FPictureSize,FPictureSize) then
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
     on e : Exception do EventLog(':TPanelLoadingBigImagesThread::Execute()/LoadImageX throw exception: '+e.Message);
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

    ApplyRotate(TempBitmap, fFiles[i].Rotation);
    BitmapParam:=TempBitmap;
    FI:=i+1;
    IntParam:=FI;

    Synchronize(ReplaceBigBitmap);
    TempBitmap.Free;
   end;
  end;
 end else
 begin
  Repeat
   sleep(100);
  until PanelUpdateBigImageThreadsCountByID<(ProcNum+1);

  PanelUpdateBigImageThreadsCountByID:=PanelUpdateBigImageThreadsCountByID+1;
  //?

 end;
 Synchronize(DoStopLoading);
end;

procedure TPanelLoadingBigImagesThread.FileNameExists;
begin
  BoolParam:=false;
  if ManagerPanels.IsPanelForm(FSender) then
    if IsEqualGUID((FSender as TFormCont).BigImagesSID, FSID) then
      if (FSender as TFormCont).FileNameExistsInList(StrParam) then
        BoolParam:=true;
end;

procedure TPanelLoadingBigImagesThread.GetVisibleFiles;
begin
  If ManagerPanels.IsPanelForm(FSender) then
  begin
    FVisibleFiles:=(FSender as TFormCont).GetVisibleItems;
    if not FSender.Active then
      Priority:=tpLowest;
  end
end;

destructor TPanelLoadingBigImagesThread.Destroy;
begin
 if not fUpdating then
 begin
  Dec(PanelUpdateBigImageThreadsCount);
 end else
 begin
  Dec(PanelUpdateBigImageThreadsCountByID);
 end;
 inherited Destroy;
end;

procedure TPanelLoadingBigImagesThread.ReplaceBigBitmap;
begin
  if ManagerPanels.IsPanelForm(FSender) then
    if IsEqualGUID((FSender as TFormCont).BigImagesSID, FSID) then
    begin
      (FSender as TFormCont).ReplaseBitmapWithPath(StrParam,BitmapParam);
    end;
end;

procedure TPanelLoadingBigImagesThread.DoStopLoading;
begin
 if ManagerPanels.ExistsPanel(FSender,fSID) then
 (FSender as TFormCont).DoStopLoading(fSID) else
 begin
  exit;
 end;
end;

end.
