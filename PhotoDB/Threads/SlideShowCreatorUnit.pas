unit SlideShowCreatorUnit;

interface

uses
  UnitUpdateDBThread, UnitDBKernel, Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, DmProgress, DB, DBTables,
  ExtCtrls, jpeg, GraphicCrypt, GIFImage;

type TEndCreateObject = Class(TObject)
 end;

type
  SlideShowCreator = class(TThread)
  ffileName : string;
  FOnDone : TNotifyEvent;
  fpic:Tpicture;
  FThbImage : TBitmap;
  fDoSetPicture :TNotifyEvent;
  noimage : boolean;
  frotate : integer;
  ffullscreen : boolean;
  FFullImage : Boolean;
  FBeginZoom : Extended;
  RealWidth, RealHeight : Integer;
  FilePass : String;
  function isvalidth_thread: boolean;
  procedure doexit;
  procedure SetImage;
  procedure ExecOnDone;
  procedure NowSetImage;
  procedure SetImageA;
  procedure GetPassword;
  procedure GetPasswordSynch;
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
   constructor Create(CreateSuspennded: Boolean;  FullImage : Boolean; BeginZoom : Extended);
  end;

  var
    OnDone, DoSetPicture : TNotifyEvent;
    Work_ : TStrings;
    Active, terminated_: boolean;
    Rotated_ : integer;

implementation

uses SlideShow, dolphin_db, Language, FormManegerUnit, UnitPasswordForm;

{ SlideShowCreator }

constructor SlideShowCreator.Create(CreateSuspennded, FullImage: Boolean; BeginZoom : Extended);
begin
 Inherited Create(True);
 FFullImage := FullImage;
 FBeginZoom := BeginZoom;
 If not CreateSuspennded then Resume;
end;

procedure SlideShowCreator.doexit;
begin
 fpic.free;
 FThbImage.free;
end;

procedure SlideShowCreator.ExecOnDone;
var
  EndObject : TEndCreateObject;
begin
 EndObject := TEndCreateObject.Create;
 if Viewer<>nil then
 If Assigned(FOnDone) then FOnDone(EndObject);
end;

procedure SlideShowCreator.Execute;
var
  w : Extended;
const
  text_out = TEXT_MES_CREATING+'...';
  text_error_out = TEXT_MES_UNABLE_SHOW_FILE;
begin
 FreeOnTerminate:=true;
 noimage:=false;
 frotate:=Rotated_;
 ffileName:=work_[work_.count-1];

 terminated_:=false;
 FOnDone:=OnDone;
 fDoSetPicture:=DoSetPicture;
 FThbImage:=Tbitmap.create;
 FThbImage.PixelFormat:=pf24bit;
 fpic:=Tpicture.create;
 if not isvalidth_thread then begin doexit; exit; end;
 FThbImage.Canvas.Brush.Color:=Theme_MainColor;
 FThbImage.Canvas.Pen.Color:=Theme_MainColor;

 if not isvalidth_thread then begin doexit; exit; end;
 noimage:=true;
 GetPassword;
 try
  If FileExists(ffilename) then
  begin
   if FilePass<>'' then
   begin
    try
     fpic.Graphic:=DeCryptGraphicFile(ffilename,FilePass);
     noimage:=false;
    except
    end;
   end else
   fpic.LoadFromFile(fFileName);
   noimage:=false;
  end;
  except
 end;
 if not isvalidth_thread then begin doexit; exit; end;
 if noimage then
 begin
  FThbImage.Canvas.Brush.Color:=Theme_MainColor;
  FThbImage.Canvas.Pen.Color:=Theme_MainColor;
  FThbImage.Width:=Max(FThbImage.Canvas.TextWidth(text_error_out)+4,FThbImage.Canvas.TextWidth(ffilename)+4);
  FThbImage.Height:=FThbImage.Canvas.Textheight(text_error_out)+6;
  FThbImage.Height:=FThbImage.Height+2*FThbImage.Canvas.Textheight(ffilename)+4;
  FThbImage.Canvas.Rectangle(0,0,FThbImage.Width,FThbImage.Height);
  FThbImage.Canvas.TextOut(FThbImage.Width div 2-FThbImage.Canvas.TextWidth(text_error_out) div 2,FThbImage.Height div 2-FThbImage.Canvas.Textheight(text_error_out) div 2,text_error_out);
  FThbImage.Canvas.TextOut(FThbImage.Width div 2-FThbImage.Canvas.TextWidth(ffilename) div 2,FThbImage.Height div 2-FThbImage.Canvas.Textheight(text_error_out) div 2+FThbImage.Canvas.Textheight(ffilename)+4,ffilename);
 end else
 begin
 if not isvalidth_thread then begin doexit; exit; end;
 w:=Fpic.Graphic.Width;
 RealWidth:=Fpic.Graphic.Width;
 RealHeight:=Fpic.Graphic.Height;
 if not FFullImage then
 JPEGScale(Fpic.Graphic,Screen.Width,Screen.Height);
 SlideShow.RealZoomInc:=w/Fpic.Graphic.Width;

 if not isvalidth_thread then begin doexit; exit; end;
 if not (FPic.Graphic is TGIFImage) then
 begin

  try
   FThbImage.Assign(fPic.Graphic);
  except
   on e : Exception do EventLog(':SlideShowCreator::Execute() throw exception: '+e.Message);
  end;
  if frotate<>DB_IMAGE_ROTATED_0 then
  begin
   if frotate=DB_IMAGE_ROTATED_270 then Rotate270A(FThbImage);
   if frotate=DB_IMAGE_ROTATED_90 then Rotate90A(FThbImage);
   if frotate=DB_IMAGE_ROTATED_180 then Rotate180A(FThbImage);
  end;
  if not isvalidth_thread then begin doexit; exit; end;
  synchronize(SetImage);
  fpic.free;
 end else
 begin

 end;
 end;

 Terminated_:=false;
 Synchronize(ExecOnDone);
end;

procedure SlideShowCreator.GetPassword;
begin
 FilePass:='';
 if ValidCryptGraphicFile(ffileName) then
 Synchronize(GetPasswordSynch);
end;

procedure SlideShowCreator.GetPasswordSynch;
begin
  FilePass:=DBKernel.FindPasswordForCryptImageFile(ffileName);
  if FilePass='' then
  FilePass:=GetImagePasswordFromUser(ffileName);
end;

function SlideShowCreator.isvalidth_thread: boolean;
begin
 if work_[work_.count-1]=ffileName then result:=true else result:=false;
 if Viewer=nil then Result:=false;
end;

procedure SlideShowCreator.NowSetImage;
begin
 if Viewer<>nil then
 If assigned(fDoSetPicture) then fDoSetPicture(self);
end;

procedure SlideShowCreator.SetImage;
begin
 SlideShow.RealImageWidth:=RealWidth;
 SlideShow.RealImageHeight:=RealHeight;
 if Viewer<>nil then
 begin
  SlideShow.FbImage.free;
  SlideShow.FbImage:=FThbImage;
 end else FThbImage.free;
 if FFullImage then
 begin
  SlideShow.ZoomerOn:=True;
  SlideShow.Zoom:=FBeginZoom;
 end else
 begin
  SlideShow.ZoomerOn:=False;
  SlideShow.Zoom:=1;
 end;
end;

procedure SlideShowCreator.SetImageA;
begin
 if Viewer<>nil then
 SlideShow.FbImage.assign(fpic.Graphic);
end;

initialization

work_:=tstringlist.Create;

end.
