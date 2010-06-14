unit UnitThCreator;

interface

uses
  UnitDBKernel, dm, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, DmProgress, DB, DBTables,
  ExtCtrls, jpeg, math;

type
  ThCreator = class(TThread)
  private
  fQuery: TQuery;
  ffile : string;
  fbmp,fb:tbitmap;
  fpic:tpicture;
  fh,fw:integer;
  flog: string;
  ffile_onlyname : string;
  terminated_, active:boolean;
  finfo_width, finfo_height : integer;
  ftype : integer;
  FID : integer;
  FComment : string;
  FKeyWords : string;
  Faccess : integer;
  FRating : integer;
  FRotate : integer;
   b1:tbitmap;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure doexit;
    function isvalidth_thread:boolean;
    function getfileDBinfo(filename:string):integer;
    procedure setthimage;
    procedure setinfoA;
    procedure regID;
    procedure unregid;
    procedure unregidA;
    procedure okadd;
    procedure canceladd;
    procedure generating;
    procedure draw;
  published
  end;

  var
  work_ : tstrings;
  fImage : TImage;
  ffilename : string;
  
implementation

uses Searching, dolphin_db;

{ ThCreator }

procedure ThCreator.canceladd;
begin
 form4.AddFile1.Visible:=false;
 form4.n1.Visible:=false;
end;

procedure ThCreator.doexit;
begin
 fQuery.free;
 freeandnil(fpic);
 freeandnil(fb);
 freeandnil(fbmp);
 active:=false;
 terminated_:=false;
end;

procedure ThCreator.Execute;
var ic:ticon;
 tb : tbitmap;

 i,j,h,k,p,w:integer;  s,d:tbitmap;   p2,p1: pargb;
col,r,g,b,dobx,doby,t1,t2 : integer;
begin
 fid:=0;
 synchronize(unregidA);
 synchronize(canceladd);
 ffile:=work_[work_.count-1];
 ffile_onlyname:=getfilename(ffile);
 CurrentRecord.ItemFileName:=ffile;
 if fileexists(ffile) then
 ftype:=4;
 if directoryexists(ffile) then
 ftype:=1;
 fQuery:=TQuery.Create(nil);
 fQuery.DatabaseName:=DBAliasName;
 finfo_width:=0;
 finfo_height:=0;
 synchronize(setinfoA);
 active:=true;
 terminated_:=false;
 fbmp:=nil;
 fpic:=nil;
 fb:=nil;
 fb:=Tbitmap.create;
 fb.PixelFormat:=pf24bit;
 fbmp:=Tbitmap.create;
 fbmp.PixelFormat:=pf24bit;
 fw:=100;
 fh:=100;
 fb.Width:=fw;
 fb.Height:=fh;
 synchronize(generating);
 fpic:=tpicture.create;
 if not isvalidth_thread then begin doexit; exit; end;
 synchronize(setthimage);
 if not isvalidth_thread then begin doexit; exit; end;
 if extinmask('|BMP|JPG|JPEG|',getext(ffile)) then
 if fileexists(ffile) then
 begin
  fpic.LoadFromFile(ffile);
  if fpic.Graphic is tjpegimage then ftype:=2;
  if fpic.Graphic is tbitmap then ftype:=3;
  finfo_width:=fpic.graphic.width;
  finfo_height:=fpic.graphic.height;
  synchronize(setinfoA);
 if not isvalidth_thread then begin doexit; exit; end;
  if fpic.Graphic.Width>fpic.Graphic.Height then
  begin
   fw:=100;
   if fpic.Graphic.Width<>0 then
   fH:=round(100*(fpic.Graphic.Height/fpic.Graphic.Width)) else
   fh:=100;
  end else
  begin
   if fpic.Graphic.Height<>0 then
   fW:=round(100*(fpic.Graphic.Width/fpic.Graphic.Height)) else
   fw:=100;
   fh:=100;
  end;
  b1:=Tbitmap.create;
  b1.PixelFormat:=pf24bit;
  b1.Width:=fw;
  b1.height:=fh;
  synchronize(draw);
  freeandnil(b1);
  if not isvalidth_thread then begin doexit; exit; end;
  if getfileDBinfo(ffile)=0 then
  begin
   ic:=ticon.create;
   ic.Handle:=loadicon(hinstance,'TH_NEW');
   fb.Canvas.Draw(60,60,ic);
   ic.free;
   synchronize(okadd);
  end else
  begin
  case frotate of
     DB_IMAGE_ROTETED_90  :  Rotate90A(fb);
     DB_IMAGE_ROTETED_180 :  Rotate180A(fb);
     DB_IMAGE_ROTETED_270 :  Rotate270A(fb);
     end;
   if (faccess=db_access_private) and dbkernel.UserRights.ShowPrivate then
   fb.Canvas.Draw(60,60,f_ic_private);
  end;
  if not isvalidth_thread then begin doexit; exit; end;
  synchronize(setinfoA);
  synchronize(setthimage);
  end else begin
  fb:=Tbitmap.create;
  fb.PixelFormat:=pf24bit;
  fw:=100;
  fh:=100;
  fb.Width:=fw;
  fb.Height:=fh;
  fb.Canvas.Brush.Color:=Theme_MainColor;
  fb.Canvas.Pen.Color:=Theme_MainColor;
  fb.Canvas.Rectangle(0,0,fw,fh);
  fb.Canvas.Pen.Color:=Theme_MainFontColor;
  fb.Canvas.TextOut(10,40,'No avaliable thumbs');
  ic:=ticon.create;
  ic.Handle:=loadicon(hinstance,'TH_NOT_VAL');
  fb.Canvas.Draw(50,50,ic);
  if not isvalidth_thread then begin doexit; exit; end;
  synchronize(setthimage);
  ic.free;
 end;
 doexit;
end;

function delnakl(s:string):string;
var j:integer;
begin
 result:=s;
 for j:=1 to length(result) do
 if result[j]='\' then result[j]:='_';
end;

function ThCreator.getfileDBinfo(filename: string): integer;
begin
 fQuery.Active:=false;
 fQuery.sql.text:='SELECT * FROM "'+dbname+'"'+' WHERE FFileName like :ffilename';
 fQuery.Params[0].AsString:=delnakl(filename);
 fQuery.active:=true;
 if fQuery.RecordCount<>0 then
 begin
 fid:=fQuery.FieldByName('ID').AsInteger;
 Fcomment:=fQuery.FieldByName('Comment').AsString;
 FkeyWords:=fQuery.FieldByName('KeyWords').AsString;
 Faccess:=fQuery.FieldByName('Access').AsInteger;
 FRating:=fQuery.FieldByName('Rating').AsInteger;
 FRotate:=fQuery.FieldByName('Rotated').AsInteger;
 end else
 begin
  fid:=0;
  Fcomment:='';
  FkeyWords:='';
  Faccess:=0;
 end;
 result:=fQuery.RecordCount;
end;

function ThCreator.isvalidth_thread: boolean;
begin
 if work_[work_.count-1]=ffile then result:=true else result:=false;
end;

procedure ThCreator.okadd;
begin
 form4.AddFile1.Visible:=dbkernel.UserRights.Add;
 form4.n1.Visible:=dbkernel.UserRights.Add;
end;

procedure ThCreator.regID;
begin
AddForm.CurrentRecord.ItemId:=fid;
form4.registrID;
end;

procedure ThCreator.setinfoA;
var s:string;
begin
 unregid;
 case ftype of
  0: s:='Uncnown type';
  1: s:='Directory';
  2: s:='Jpeg Image';
  3: s:='Bitmap Image';
  4: s:='File';
 end;
 if (ftype=2) or (ftype=3) then
 with form4 do
 begin
  Label_type.caption:=s;
  Label_width.caption:=inttostr(finfo_width)+' pixels';
  Label_height.caption:=inttostr(finfo_height)+' pixels';
 end else  with form4 do
 begin
  Label_type.caption:=s;
  Label_width.caption:='No information';
  Label_height.caption:='No information';
 end;
 with form4 do
 begin
  Name_label.caption:=ffile_onlyname;
  if fid<>0 then
  begin
   regid;
   SearchForIt1.Visible:=true;
   id_label.Show;
   Label5.Show;
   if Faccess=db_access_private then
   begin
    private1.Caption:='Common';
    private1.ImageIndex:=DB_IC_COMMON;
   end else begin
    private1.Caption:='Private';
    private1.ImageIndex:=DB_IC_PRIVATE;
   end;
   AddForm.CurrentRecord.ItemRotate:=frotate;
   private1.Visible:=dbkernel.UserRights.SetPrivate;
   Rating1.Visible:=dbkernel.UserRights.SetRating;
   Rotate1.Visible:=dbkernel.UserRights.SetInfo;
   PopupMenu1.tag:=Fid;
   Rating1.tag:=Fid;
   Rotate1.tag:=Fid;
   None1.Default:=false;
   N90CW1.Default:=false;
   N1801.Default:=false;
   N90CCW1.Default:=false;
   Case frotate of
   0: None1.Default:=true;
   1: N90CW1.Default:=true;
   2: N1801.Default:=true;
   3: N90CCW1.Default:=true;
   end;
   N01.Default:=false;
   N11.Default:=false;
   N21.Default:=false;
   N31.Default:=false;
   N41.Default:=false;
   N51.Default:=false;
   Case frating of
   0: N01.Default:=true;
   1: N11.Default:=true;
   2: N21.Default:=true;
   3: N31.Default:=true;
   4: N41.Default:=true;
   5: N51.Default:=true;
   end;
   id_label.Caption:=inttostr(FID);
   AddForm.CurrentRecord.ItemId:=FID;
  end else
  begin
   SearchForIt1.Visible:=false;
   id_label.Hide;
   Label5.Hide;
   private1.Visible:=false;
   Rating1.Visible:=false;
   Rotate1.Visible:=false;
   id_label.Caption:='';
   AddForm.CurrentRecord.ItemId:=0;
  end;
 end;
end;

procedure ThCreator.setthimage;
begin
  if fImage.picture.graphic<>nil then
  if not (fImage.picture.graphic is tbitmap) then
  fImage.picture.Bitmap:=Tbitmap.create;
  if fImage.picture.graphic=nil then fImage.picture.Bitmap:=Tbitmap.create;
  fImage.picture.Bitmap.Assign(fb);
  fImage.Refresh;
end;

procedure ThCreator.unregid;
begin
 AddForm.CurrentRecord.ItemId:=fid;
 form4.unregistrID;
end;

procedure ThCreator.unregidA;
begin
 form4.unregistrID;
end;

procedure ThCreator.generating;
begin
 fb.Canvas.Brush.Color:=Theme_MainColor;
 fb.Canvas.Pen.Color:=Theme_MainColor;
 fb.Canvas.Rectangle(0,0,fw,fh);
 fb.Canvas.TextOut(20,50,'Generating...');
end;

procedure ThCreator.draw;
begin
 b1.Canvas.StretchDraw(rect(0,0,fw,fh),fpic.graphic);
 fb.Canvas.Draw(50-b1.Width div 2, 50-b1.height div 2,b1);
end;

initialization

work_:=tstringlist.Create;

end.
