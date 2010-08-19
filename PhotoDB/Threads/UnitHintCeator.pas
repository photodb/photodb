unit UnitHintCeator;

interface

uses
  dolphin_db, UnitDBKernel, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, GIFImage, GraphicEx, Math, UnitDBCommonGraphics,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, DmProgress, RAWImage,
  ExtCtrls, jpeg, db, GraphicCrypt, UnitDBCommon;

type
  HintCeator = class(TThread)
  private
   ffile : string;
   fbmp,fb:tbitmap;
   G : TGraphic;
   fh,fw:integer;
   ffilesize : integer;
   finfo_width:integer;
   finfo_height:integer;
   fthrect : trect;
   FilePass : string;
   fSelfItem : TObject;
   frotate : integer;
   fhintreal : THintRealFucntion;
   FOwner : TForm;
   BooleanResult : Boolean;
   FHasAnimatedImage : Boolean;
   ValidImages : integer;
   FTransparent : boolean;
   GIF : TGIFImage;
   BitmapParam : TBitmap;
  function isvalidth_thread:boolean;
  procedure isvalidth_threada;
  procedure doexit;
  procedure ok;
  procedure DrawHintInfo;
  procedure GIFDraw;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean);
  end;

  var
  work_ : tstrings;
  active : boolean;
  threct : trect;
  fitem : TObject;
  hr : THintRealFucntion;
  Owner : TForm;
  fInfo : TOneRecordInfo;

implementation

uses searching, unitimhint, FormManegerUnit, UnitViewerThread;

{ HintcCeator }

constructor HintCeator.Create(CreateSuspennded: Boolean);
begin
 Inherited Create(true);
 FilePass:='';
 if ValidCryptGraphicFile(work_[work_.count-1]) then
 begin
  FilePass:=DBKernel.FindPasswordForCryptImageFile(work_[work_.count-1]);
  if FilePass='' then Terminate;
 end;
 if not CreateSuspennded then Resume;
end;

procedure HintCeator.DoExit;
begin
 if not FHasAnimatedImage then
 FreeAndNil(G);
 FreeAndNil(fb);
 active:=false;
end;

procedure HintCeator.DrawHintInfo;
var
  sm, y : Integer;
begin
 fb.PixelFormat:=pf24bit;
 y:=fb.Height-18;
 sm:=fb.Width-2;
 if (fb.Width<80) or (fb.Height<60) then exit;
 If fInfo.ItemAccess=db_access_private then
 begin
  Dec(sm,20);
  DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_PRIVATE+1],16,16,0,0,DI_NORMAL);
 end;
 Dec(sm,20);
 Case fInfo.ItemRotate of
  DB_IMAGE_ROTATED_90: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_ROTETED_90+1],16,16,0,0,DI_NORMAL);
  DB_IMAGE_ROTATED_180: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_ROTETED_180+1],16,16,0,0,DI_NORMAL);
  DB_IMAGE_ROTATED_270: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_ROTETED_270+1],16,16,0,0,DI_NORMAL);
 else Inc(sm,20);
 end;
 Dec(sm,20);
 Case fInfo.ItemRating of
  1: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_1+1],16,16,0,0,DI_NORMAL);
  2: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_2+1],16,16,0,0,DI_NORMAL);
  3: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_3+1],16,16,0,0,DI_NORMAL);
  4: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_4+1],16,16,0,0,DI_NORMAL);
  5: DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_5+1],16,16,0,0,DI_NORMAL);
 else Inc(sm,20);
 end;
 If FInfo.ItemCrypted then
 begin
  Dec(sm,20);
  DrawIconEx(fb.Canvas.Handle,sm,y,UnitDBKernel.icons[DB_IC_KEY+1],16,16,0,0,DI_NORMAL);
 end;
end;

procedure HintCeator.Execute;
var
  PNG : TPNGGraphic;
  i : Integer;
begin
 FTransparent:=false;
 FHasAnimatedImage:=false;
 if Terminated then exit;
 FOwner := Owner;
 FreeOnTerminate:=true;
 frotate:=fInfo.ItemRotate;
 fthrect:=threct;
 fselfitem:=fitem;
 fhintreal:=hr;
 ffile:=work_[work_.count-1];
 if not fileexists(ffile) then exit;
 active:=true;
 fbmp:=nil;
 G:=nil;
 fb:=nil;
 fb:=Tbitmap.create;
 fb.PixelFormat:=pf24bit;
 fw:=ThHintSize;
 fh:=ThHintSize;
 fb.Canvas.Brush.Color:=Theme_MainColor;
 fb.Canvas.Pen.Color:=Theme_MainColor;
 fb.Canvas.Rectangle(0,0,fw,fh);
 G:=nil;
 if not isvalidth_thread then begin doexit; exit; end;
 if not fileexists(ffile) then begin doexit; exit; end;
 if extinmask(SupportedExt,getext(ffile)) then
 begin
  FFileSize:=GetFileSizeByName(ffile);
  try
   if ValidCryptGraphicFile(ffile) then
   begin
    try
     G:=DeCryptGraphicFile(ffile,FilePass);
     FInfo.ItemCrypted:=true;
    except
     if G<>nil then G.Free;
     exit;
    end;
   end else
   begin
    FInfo.ItemCrypted:=false;
    if IsRAWImageFile(ffile) then
    begin
     G:=TRAWImage.Create;
     if not (G as TRAWImage).LoadThumbnailFromFile(ffile, ThHintSize, ThHintSize) then
     G.LoadFromFile(ffile);
    end else
    begin
     G:=GetGraphicClass(GetExt(FFile),false).Create;
     G.LoadFromFile(ffile);
    end;
   end;
  except
   if G<>nil then G.Free;
   exit;
  end;
  finfo_width:=G.width;
  finfo_height:=G.height;
  JPEGScale(G,ThHintSize,ThHintSize);
  if not isvalidth_thread then begin doexit; exit; end;
  fw:=G.Width;
  fh:=G.Height;
  if G is TGIFImage then
  begin
   GIF:=(G as TGIFImage);
   ValidImages:=0;
   for i:=0 to GIF.Images.count-1 do
   begin
    if not GIF.Images[i].Empty then
    ValidImages:=ValidImages+1;
    if not GIF.Images[i].Empty then
    if GIF.Images[i].Transparent then FTransparent:=true;
   end;
   if ValidImages>1 then
   begin
    FHasAnimatedImage:=true;
    Synchronize(ok);
    DoExit;
    exit;
   end;
  end;
  ProportionalSize(ThHintSize,ThHintSize,fw,fh);
  fb.Width:=fw;
  fb.Height:=fh;
  If Max(finfo_width,finfo_Height)>ThHintSize then
  begin
   fbmp:=Tbitmap.create;
   fbmp.PixelFormat:=pf24bit;
   fbmp.Width:=G.Width;
   fbmp.height:=G.height;
   if G is TGIFImage then
   begin
    GIF:=G as TGIFImage;
    BitmapParam:=fbmp;
    Synchronize(GIFDraw);
   end;
   if G is TPNGGraphic then
   begin
    PNG:=(G as TPNGGraphic);
    if PNG.PixelFormat=pf32bit then
    begin
     FTransparent:=true;
     LoadPNGImage32bit(PNG,fbmp,Theme_MainColor);
    end else
      AssignGraphic(FBMP, G);
   end;

   if not (G is TPNGGraphic) and not (G is TGIFImage) then
   begin
    if (G is TBitmap) then
    begin
     if not (G is TPSDGraphic) or PSDTransparent then
     begin
      if (G as TBitmap).PixelFormat=pf32bit then
      begin
       FTransparent:=true;
       LoadBMPImage32bit(G as TBitmap,fbmp,Theme_MainColor);
      end else AssignGraphic(FBMP, G);
     end else AssignGraphic(FBMP, G);
    end else AssignGraphic(FBMP, G);
   end;
   DoResize(fw,fh,fbmp,fb);
   fbmp.free;
  end else
  begin
   if G is TGIFImage then
   begin
    fb.PixelFormat:=pf24bit;
    fb.Width:=G.Width;
    fb.height:=G.height;
    GIF:=G as TGIFImage;
    BitmapParam:=fb;
    Synchronize(GIFDraw);
   end;
   if G is TPNGGraphic then
   begin
    PNG:=(G as TPNGGraphic);
    if PNG.PixelFormat=pf32bit then
    begin
     fb:=Tbitmap.create;
     fb.PixelFormat:=pf24bit;
     fb.Width:=G.Width;
     fb.height:=G.height;
     FTransparent:=true;
     LoadPNGImage32bit(PNG,fb,Theme_MainColor);
    end else
      AssignGraphic(FB, G);
   end;
   if not (G is TPNGGraphic) and not (G is TGIFImage) then
   begin
    if (G is TBitmap) then
    begin
     if (G as TBitmap).PixelFormat=pf32bit then
     begin
      FTransparent:=true;
      LoadBMPImage32bit(G as TBitmap,fb,Theme_MainColor);
     end else AssignGraphic(FB, G);
    end else AssignGraphic(FB, G);
   end;
  end;
  ApplyRotate(fb, fRotate);
  Synchronize(DrawHintInfo);
  if not isvalidth_thread then begin DoExit; exit; end;
  Synchronize(ok);
 end;
 DoExit;
end;

procedure HintCeator.GIFDraw;
var
  i : integer;
begin
 BitmapParam.Canvas.Pen.Color:=Theme_MainColor;
 BitmapParam.Canvas.Brush.Color:=Theme_MainColor;
 BitmapParam.Canvas.Rectangle(0,0,BitmapParam.Width,BitmapParam.Height);
 for i:=0 to GIF.Images.Count-1 do
 if not GIF.Images[i].Empty then
 begin
  FTransparent:=GIF.Images[i].Transparent;
  GIF.Images[i].Draw(BitmapParam.Canvas,Rect(0,0,GIF.Width,GIF.Height),FTransparent,false);
  break;
 end;
end;

function HintCeator.isvalidth_thread: boolean;
begin
 Synchronize(isvalidth_threada);
 Result:=BooleanResult;
end;

procedure HintCeator.isvalidth_threada;
begin
 if work_[work_.count-1]=ffile then BooleanResult:=true else BooleanResult:=false;
 if assigned(fhintreal) then
 if fhintreal(fitem) = false then exit;
end;

procedure HintCeator.ok;
begin
 fInfo.ItemSize:=ffilesize;
 if ImHint=nil then
 Application.CreateForm(TImHint, ImHint);
 ImHint.Execute(FOwner,not FHasAnimatedImage,FTransparent,fb,G,ValidImages,finfo_width,finfo_height,fthrect, fInfo, fselfitem, fhintreal);
end;

initialization

work_:=TStringList.Create;

end.
