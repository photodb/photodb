unit UnitSearchThreadLoadBigImage;

interface

uses
  Windows, Classes, Math, dolphin_db, Graphics, GraphicCrypt, Forms;

(*type
  TSearchThreadLoadBigImage = class(TThread)
  private
    { Private declarations }
    fSender : TForm;
    fSID : string;
    fRecordInfo : TOneRecordInfo;
    fPictureSize : integer;
    FPic : TPicture;
    BitmapParam : TBitmap;
  protected
    procedure Execute; override;   
    procedure ReplaceBigBitmap;
//    procedure DrawInfoBitmap;
  public
    constructor Create(CreateSuspennded: Boolean; Sender : TForm; SID : string; RecordInfo : TOneRecordInfo; PictureSize : integer);
  end;
       *)
implementation

uses ExplorerThreadUnit, Searching;

{ TSearchThreadLoadBigImage }
  (*
constructor TSearchThreadLoadBigImage.Create(CreateSuspennded: Boolean;
  Sender: TForm; SID: string; RecordInfo: TOneRecordInfo;
  PictureSize: integer);
begin
 inherited create(true);
 fSender := Sender;
 fSID := SID;
 fRecordInfo := RecordInfo;
 fPictureSize := PictureSize;
 if not CreateSuspennded then Resume;
end;

procedure TSearchThreadLoadBigImage.Execute;
var
  fbit, TempBitmap : TBitmap;
  PassWord : String;
  w,h : integer;
begin
 FreeOnTerminate:=true;

 FPic := TPicture.Create;

 try
  if GraphicCrypt.ValidCryptGraphicFile(fRecordInfo.ItemFileName) then
  begin
   PassWord:=DBKernel.FindPasswordForCryptImageFile(fRecordInfo.ItemFileName);
   if PassWord='' then
   begin
    if FPic<>nil then FPic.Free;
    FPic:=nil;
    exit;
   end;
   FPic.Graphic:=GraphicCrypt.DeCryptGraphicFile(fRecordInfo.ItemFileName,PassWord);
  end else FPic.LoadFromFile(fRecordInfo.ItemFileName);
 except
  if FPic<>nil then
  FPic.Free;
  FPic:=nil;
  exit;
 end;

 fbit:=TBitmap.create;
 fbit.PixelFormat:=pf24bit;
 JPEGScale(Fpic.Graphic,FPictureSize,FPictureSize);

 if Min(Fpic.Height,Fpic.Width)>1 then
 try
  LoadImageX(Fpic.Graphic,fbit,RGB(Round(GetRValue(Theme_ListColor)*0.9),Round(GetGValue(Theme_ListColor)*0.9),Round(GetBValue(Theme_ListColor)*0.9)));
 except
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

 case fRecordInfo.ItemRotate of
  DB_IMAGE_ROTATED_90  :  Rotate90A(TempBitmap);
  DB_IMAGE_ROTATED_180 :  Rotate180A(TempBitmap);
  DB_IMAGE_ROTATED_270 :  Rotate270A(TempBitmap);
 end;

 BitmapParam:=TempBitmap;    
//? Synchronize(DrawInfoBitmap);
 Synchronize(ReplaceBigBitmap);
 TempBitmap.Free;
end;

procedure TSearchThreadLoadBigImage.ReplaceBigBitmap;
begin
 if SearchManager.IsSearchForm(FSender) then
 if (FSender as TSearchForm).SID=FSID then
 if (FSender as TSearchForm).FileNameExistsInList(fRecordInfo.ItemFileName) then
 begin
  (FSender as TSearchForm).ReplaseBitmapWithPath(fRecordInfo.ItemFileName,BitmapParam);
 end;
end;

{procedure TSearchThreadLoadBigImage.DrawInfoBitmap;
var
  Exists : integer;
begin
 Exists:=0;
 Searching.DrawAttributes(BitmapParam,fRecordInfo.ItemRating,fRecordInfo.ItemRotate,fRecordInfo.ItemAccess,fRecordInfo.ItemFileName,fRecordInfo.ItemCrypted,Exists);
end;    }
        *)
end.
