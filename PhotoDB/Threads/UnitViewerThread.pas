unit UnitViewerThread;

interface

uses
  Windows, Classes, Graphics, GraphicCrypt, Dolphin_DB, SysUtils, Forms,
  GIFImage, GraphicEx, DB, GraphicsBaseTypes, CommonDBSupport, TiffImageUnit,
  ActiveX, UnitDBCommonGraphics, UnitDBCommon, uFileUtils, ImageConverting, JPEG,
  uMemory;

type
  TViewerThread = class(TThread)
  private
    FFileName: string;
    FRotate: Byte;
    FFullImage: Boolean;
    FBeginZoom: Extended;
    FSID: TGUID;
    Graphic: TGraphic;
    PassWord: string;
    Crypted: Boolean;
    FRealWidth, FRealHeight: Integer;
    FRealZoomScale: Extended;
    Bitmap: TBitmap;
    FIsForward: Boolean;
    FTransparent: Boolean;
    FBooleanResult: Boolean;
    FInfo: TOneRecordInfo;
    FUpdateInfo: Boolean;
    FPage: Word;
    FPages: Word;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure GetPassword;
    procedure GetPasswordSynch;
    procedure SetNOImage;
    procedure SetAnimatedImage;
    procedure SetStaticImage;
    procedure SetNOImageAsynch;
    procedure SetStaticImageAsynch;
    procedure SetAnimatedImageAsynch;
    function TestThread : Boolean;
    procedure TestThreadSynch;
    procedure UpdateRecord;
  public
   constructor Create(CreateSuspennded: Boolean; FileName : String; Rotate : Byte; FullImage : Boolean; BeginZoom : Extended; SID : TGUID; IsForward, UpdateInfo : Boolean; Page : Word);
   destructor Destroy; override;
  end;

implementation

uses UnitPasswordForm, SlideShow;

{ TViewerThread }

constructor TViewerThread.Create(CreateSuspennded: Boolean;
  FileName: String; Rotate: Byte; FullImage : Boolean; BeginZoom : Extended; SID : TGUID; IsForward, UpdateInfo : Boolean; Page : Word);
begin
  inherited Create(True);
  FPage := Page;
  FFileName := FileName;
  FRotate := Rotate;
  FFullImage := FullImage;
  FBeginZoom := BeginZoom;
  FSID := SID;
  FIsForward := IsForward;
  FUpdateInfo := UpdateInfo;
  if not CreateSuspennded then Resume;
end;

destructor TViewerThread.Destroy;
begin

  inherited;
end;

procedure TViewerThread.Execute;
var
  PNG : TPNGGraphic;
  TransparentColor : TColor;
  GraphicClass : TGraphicClass;
  MS : TMemoryStream;
  BMP : TBitmap;
begin
  FPages := 0;
  Priority := TpHigher;
  FInfo.ItemFileName := FFileName;
  if FullScreenNow then
    TransparentColor := 0
  else
    TransparentColor := Theme_MainColor;

  FTransparent := False;
  FreeOnTerminate := True;
  if not FileExistsEx(FFileName) then
  begin
    SetNOImageAsynch;
    Exit;
  end;

  GetPassword;
  if Crypted and (PassWord = '') then
  begin
    SetNOImageAsynch;
    Exit;
  end;
 Graphic := TGraphic.Create;
  try


 try
  if PassWord<>'' then
  begin
   F(Graphic);
   Graphic:=DeCryptGraphicFileEx(FFileName,PassWord,fPages,false,fPage);
  end else
  begin
   if Crypted and (PassWord='') then
   begin
    SetNOImageAsynch;
    exit;
   end else
   begin
    GraphicClass := GetGraphicClass(GetExt(FFileName), False);
    if GraphicClass = TiffImageUnit.TTiffGraphic then
    begin
     Graphic:=TiffImageUnit.TTiffGraphic.Create;
     (Graphic as TiffImageUnit.TTiffGraphic).Page:=fPage;
     (Graphic as TiffImageUnit.TTiffGraphic).LoadFromFile(FFileName);
    end else
    Graphic.LoadFromFile(FFileName);
   end;
  end;
 except
  SetNOImageAsynch;
  exit;
 end;
 if FUpdateInfo then
 UpdateRecord;



 FRealWidth:=Graphic.Width;
 FRealHeight:=Graphic.Height;
 if not FFullImage then
 JPEGScale(Graphic,Screen.Width,Screen.Height);
 FRealZoomScale:=FRealWidth/Graphic.Width;
 if Graphic is TGIFImage then
 begin
  SetAnimatedImageAsynch;
 end else
 begin
  Bitmap := TBitmap.Create;
  try
   if PassWord='' then
   if Graphic is TiffImageUnit.TTiffGraphic then
   begin
    fPages:=(Graphic as TiffImageUnit.TTiffGraphic).Pages;
    //TODO: (Graphic as TiffImageUnit.TTiffGraphic).GetPagesCount()
   end;
   if Graphic is TPNGGraphic then
   begin
    FTransparent:=true;
    PNG:=(Graphic as TPNGGraphic);
    if PNG.PixelFormat=pf32bit then
    begin
     LoadPNGImage32bit(PNG,Bitmap,TransparentColor);
    end else AssignGraphic(Bitmap, Graphic);
   end else
   begin
    if (Graphic is TBitmap) then
    begin
     if not (Graphic is TPSDGraphic) or PSDTransparent then
     begin
      if (Graphic as TBitmap).PixelFormat=pf32bit then
      begin
       FTransparent := True;
       LoadBMPImage32bit(Graphic as TBitmap,Bitmap,TransparentColor);
      end else AssignGraphic(Bitmap, Graphic);
     end else AssignGraphic(Bitmap, Graphic);
    end else AssignGraphic(Bitmap, Graphic);
   end;
   Bitmap.PixelFormat:=pf24bit;
  except
   Bitmap.Free;
   SetNOImageAsynch;
   exit;
  end;

      ApplyRotate(Bitmap, FRotate);
      SetStaticImageAsynch;
    end;
  finally
    F(Graphic);
  end;

end;

procedure TViewerThread.GetPassword;
begin
 PassWord:='';
 if ValidCryptGraphicFile(FFileName) then
 begin
  Crypted := True;
  PassWord:=DBKernel.FindPasswordForCryptImageFile(FFileName);
  if PassWord='' then
  begin
   if not FIsForward then
   Synchronize(GetPasswordSynch) else
   begin
    Repeat
     if Viewer=nil then break;
     if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then break;
     if not Viewer.ForwardThreadExists then break;
     if Viewer.ForwardThreadNeeds then
     begin
      Synchronize(GetPasswordSynch);
      exit;
     end;
     Sleep(10);
    until false;
   end;
  end;
 end else Crypted := False;
end;

procedure TViewerThread.GetPasswordSynch;
begin
 if not FullScreenNow then
 PassWord:=GetImagePasswordFromUser(FFileName);
end;

procedure TViewerThread.SetAnimatedImage;
begin
 if Viewer<>nil then
 if (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or (IsEqualGUID(Viewer.ForwardThreadSID, FSID) and FIsForward) then begin
  RealImageHeight:=FRealHeight;
  RealImageWidth:=FRealWidth;
  RealZoomInc:=FRealZoomScale;
  if FUpdateInfo then
  Viewer.UpdateInfo(FSID, FInfo);
  Viewer.SetFullImageState(FFullImage,FBeginZoom,1,0);
  Viewer.SetAnimatedImage(Graphic);
  Pointer(Graphic) := nil;
 end;
end;

procedure TViewerThread.SetAnimatedImageAsynch;
begin
 if not FIsForward then
 begin
  Synchronize(SetAnimatedImage);
  exit;
 end else
 begin
  Repeat
   if Viewer=nil then break;
   if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then break;
   if not Viewer.ForwardThreadExists then break;
   if Viewer.ForwardThreadNeeds then
   begin
    Synchronize(SetAnimatedImage);
    exit;
   end;
   sleep(10);
  until false;
 end;
end;

procedure TViewerThread.SetNOImage;
begin
 if Viewer<>nil then
 if (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or (IsEqualGUID(Viewer.ForwardThreadSID, FSID) and FIsForward) then begin
  RealImageHeight:=FRealHeight;
  RealImageWidth:=FRealWidth;
  RealZoomInc:=FRealZoomScale;
  if FUpdateInfo then
  Viewer.UpdateInfo(FSID,FInfo);
  Viewer.ImageExists:=false;
  Viewer.SetFullImageState(FFullImage,FBeginZoom,1,0);
  Viewer.LoadingFailed(FFileName);
 end;
end;

procedure TViewerThread.SetNOImageAsynch;
begin
 if not FIsForward then
 begin
  Synchronize(SetNOImage);
  Exit;
 end else
 begin
  Repeat
   if Viewer=nil then break;
   if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then break;
   if not Viewer.ForwardThreadExists then break;
   if Viewer.ForwardThreadNeeds then
   begin
    Synchronize(SetNOImage);
    exit;
   end;
   sleep(10);
  until False;
 end;
end;

procedure TViewerThread.SetStaticImage;
begin
  if Viewer<>nil then
  if (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or (IsEqualGUID(Viewer.ForwardThreadSID, FSID) and FIsForward) then
  begin
    RealImageHeight := FRealHeight;
    RealImageWidth := FRealWidth;
    RealZoomInc := FRealZoomScale;
    if FUpdateInfo then
      Viewer.UpdateInfo(FSID, FInfo);
    Viewer.SetFullImageState(FFullImage, FBeginZoom, fPages, fPage);
    Viewer.SetStaticImage(Bitmap, FTransparent);
  end else Bitmap.Free;
end;

procedure TViewerThread.SetStaticImageAsynch;
begin
  if not FIsForward then
  begin
   Synchronize(SetStaticImage);
   exit;
  end else
  begin
    Repeat
   if Viewer=nil then break;
   if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then break;
   if not Viewer.ForwardThreadExists then break;
   if Viewer.ForwardThreadNeeds then
   begin
    Synchronize(SetStaticImage);
    exit;
   end;
   Sleep(10);
  until false;
  Bitmap.Free;
 end;
end;

function TViewerThread.TestThread: Boolean;
begin
  FBooleanResult:=false;
  Synchronize(TestThreadSynch);
  Result:=FBooleanResult;
end;

procedure TViewerThread.TestThreadSynch;
begin
  if Viewer=nil then
  begin
    FBooleanResult:=false;
    Exit;
  end;
  FBooleanResult := (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or (IsEqualGUID(Viewer.ForwardThreadSID, FSID) and FIsForward) and (Viewer<>nil);
end;

procedure TViewerThread.UpdateRecord;
var
  Query : TDataSet;
begin
 CoInitialize(nil);
 try
 Query := GetQuery;
 try
  Query.Active:=false;
  SetSQL(Query,'SELECT * FROM $DB$ WHERE FolderCRC = '+IntToStr(GetPathCRC(FFileName))+' AND FFileName LIKE :FFileName');
  SetStrParam(Query,0,delnakl(AnsiLowerCase(FFileName)));
  Query.active:=true;
  if Query.RecordCount<>0 then
  begin
   FInfo:=RecordInfoOne(Query.FieldByName('FFileName').AsString,Query.FieldByName('ID').AsInteger,Query.FieldByName('Rotated').AsInteger,Query.FieldByName('Rating').AsInteger,Query.FieldByName('Access').AsInteger,Query.FieldByName('FileSize').AsInteger,Query.FieldByName('Comment').AsString,Query.FieldByName('KeyWords').AsString,'','',Query.FieldByName('Groups').AsString,Query.FieldByName('DateToAdd').AsDateTime,Query.FieldByName('IsDate').AsBoolean,Query.FieldByName('IsTime').AsBoolean,Query.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(Query.FieldByName('thum')),Query.FieldByName('Include').AsBoolean,true,Query.FieldByName('Links').AsString);
   FRotate:=FInfo.ItemRotate;
  end else FUpdateInfo:=false;
  Query.Close;
 finally
  FreeDS(Query);
 end;
 FInfo.ItemFileName:=FFileName;
 finally
   CoUnInitialize;
 end;
end;

end.
