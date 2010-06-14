unit UnitPropertyLoadImageThread;

interface

uses
  Windows, Classes, Messages, Forms, Graphics, SysUtils, RAWImage, 
  Dolphin_DB, UnitDBKernel, GraphicCrypt, UnitDBCommonGraphics;

type
  TPropertyLoadImageThreadOptions = record
   FileName : String;
   Owner : TForm;
   SID : String;
   OnDone : TNotifyEvent;
  end;

type
  TPropertyLoadImageThread = class(TThread)
  private
   fOptions : TPropertyLoadImageThreadOptions;
   fPic : TPicture;
   StrParam : String;
   IntParamW : integer;
   IntParamH : integer; 
   Password : string;
   BitmapParam : TBitmap;
   DrawBitmapParam : TBitmap;

    { Private declarations }
  protected
    procedure Execute; override;  
  public
    constructor Create(CreateSuspennded: Boolean;
      Options : TPropertyLoadImageThreadOptions);
    procedure SetCurrentPassword;
    procedure GetPasswordFromUserSynch;
    procedure SetImage;
    procedure SetSizes;
  end;

implementation

uses PropertyForm, UnitPasswordForm;

{ TPropertyLoadImageThread }

constructor TPropertyLoadImageThread.Create(CreateSuspennded: Boolean;
  Options: TPropertyLoadImageThreadOptions);
begin
 inherited create(true);
 fOptions:=Options;
 if not CreateSuspennded then Resume;
end;

procedure TPropertyLoadImageThread.Execute;
var
  fb, fb1, TempBitmap : TBitmap;
begin
 FreeOnTerminate:=True;
 fPic:=TPicture.create;
 try
  if ValidCryptGraphicFile(fOptions.FileName) then
  begin
   PassWord:=DBkernel.FindPasswordForCryptImageFile(fOptions.FileName);
   if PassWord='' then
   begin
    StrParam:=fOptions.FileName;
    Synchronize(GetPasswordFromUserSynch);
    PassWord:=StrParam;
   end;
   if PassWord<>'' then
   begin
    fPic.Graphic:=DeCryptGraphicFile(fOptions.FileName,PassWord);
    StrParam:=PassWord;
    Synchronize(SetCurrentPassword);
   end
   else
   begin
    fPic.free;
    Exit;
   end
  end else
  begin
   if IsRAWImageFile(fOptions.FileName) then
   begin
    fPic.Graphic:=TRAWImage.Create;
    if not (fPic.Graphic as TRAWImage).LoadThumbnailFromFile(fOptions.FileName) then
    fPic.Graphic.LoadFromFile(fOptions.FileName);
   end else
   fPic.LoadFromFile(fOptions.FileName);
  end;
 except
  fPic.free;
  Exit;
 End;

 IntParamW:=fPic.Graphic.Width;
 IntParamH:=fPic.Graphic.Height;
 Synchronize(SetSizes);

 JPEGScale(fPic.Graphic,ThSizePropertyPreview,ThSizePropertyPreview);

 fb:=Graphics.TBitmap.create;
 fb.PixelFormat:=pf24bit;

 fb1:=Graphics.Tbitmap.create;
 fb1.PixelFormat:=pf24bit;
 fb1.Width:=ThSizePropertyPreview;
 fb1.Height:=ThSizePropertyPreview;

 if fPic.Graphic.Width>fPic.Graphic.Height then
 begin
  fb.Width:=ThSizePropertyPreview;
  fb.Height:=round(ThSizePropertyPreview*(fPic.Graphic.Height/fPic.Graphic.Width));
 end else
 begin
  fb.Width:=round(ThSizePropertyPreview*(fPic.Graphic.Width/fPic.Graphic.Height));
  fb.Height:=ThSizePropertyPreview;
 end;

 TempBitmap:=TBitmap.Create;
 TempBitmap.Assign(fpic.Graphic);
 DoResize(fb.Width,fb.Height,TempBitmap,fb);
 TempBitmap.Free;
 BitmapParam:=fb1;
 DrawBitmapParam:=fb;
 Synchronize(SetImage);
 fb1.Free;
 fpic.Free;
 fb.free;
end;

procedure TPropertyLoadImageThread.GetPasswordFromUserSynch;
begin                     
 if PropertyManager.IsPropertyForm(fOptions.Owner) then
 if (fOptions.Owner as TPropertiesForm).SID=fOptions.SID then
 StrParam:=GetImagePasswordFromUser(StrParam);
end;

procedure TPropertyLoadImageThread.SetCurrentPassword;
begin
 if PropertyManager.IsPropertyForm(fOptions.Owner) then
 if (fOptions.Owner as TPropertiesForm).SID=fOptions.SID then
 (fOptions.Owner as TPropertiesForm).FCurrentPass:=StrParam;
end;

procedure TPropertyLoadImageThread.SetImage;
begin
 if PropertyManager.IsPropertyForm(fOptions.Owner) then
 if (fOptions.Owner as TPropertiesForm).SID=fOptions.SID then
 begin

  BitmapParam.Canvas.Brush.color:=Theme_MainColor;
  BitmapParam.Canvas.Pen.color:=Theme_MainColor;
  BitmapParam.Canvas.Rectangle(0,0,ThSizePropertyPreview,ThSizePropertyPreview);
  BitmapParam.Canvas.Draw(ThSizePropertyPreview div 2-DrawBitmapParam.Width div 2,ThSizePropertyPreview div 2- DrawBitmapParam.Height div 2,DrawBitmapParam);
  if PassWord<>'' then DrawIconEx(BitmapParam.Canvas.Handle,20,0,UnitDBKernel.icons[DB_IC_KEY+1].Handle,18,18,0,0,DI_NORMAL);
  DrawIconEx(BitmapParam.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_NEW+1].Handle,18,18,0,0,DI_NORMAL);

  With (fOptions.Owner as TPropertiesForm) do
  begin
   ImageLoadingFile.Visible:=false;
   if not (image1.Picture.Graphic is Graphics.TBitmap) then
   begin
    if image1.Picture.Graphic<>nil then image1.Picture.Graphic.free else
    image1.Picture.bitmap:=Graphics.Tbitmap.create;
   end;
   image1.Picture.bitmap.Assign(BitmapParam);
   image1.Refresh;
  end;
 end;
end;

procedure TPropertyLoadImageThread.SetSizes;
begin
 if PropertyManager.IsPropertyForm(fOptions.Owner) then
 if (fOptions.Owner as TPropertiesForm).SID=fOptions.SID then
 begin
  (fOptions.Owner as TPropertiesForm).WidthMemo.Text:=IntToStr(IntParamW)+'px.';
  (fOptions.Owner as TPropertiesForm).HeightMemo.Text:=IntToStr(IntParamH)+'px.';
 end;
end;

end.
