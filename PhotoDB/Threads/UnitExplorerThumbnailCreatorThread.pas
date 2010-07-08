unit UnitExplorerThumbnailCreatorThread;

interface

uses GraphicCrypt, Windows, Graphics, Classes, Dolphin_DB, ExplorerUnit,
     SysUtils, Math, ComObj, ActiveX, ShlObj,CommCtrl,RAWImage,
     Effects, UnitDBCommonGraphics, UnitCDMappingSupport, uLogger;

type
  TExplorerThumbnailCreator = class(TThread)
  private
   FFileSID : TGUID;
   FFileName : String;
   TempBitmap : TBitmap;
   Info : TOneRecordInfo;
   FOwner : TExplorerForm;
   GraphicParam : TGraphic;
   Fpic : Tpicture;
   Fbit, TempBit : TBitmap;
   SendInfo : TOneRecordInfo;
   StringParam : String;
  protected
    procedure Execute; override;
    procedure SetInfo;
    procedure SetImage;
    procedure DrawAttributes;
    procedure FindPassword;
  public
    constructor Create(CreateSuspennded: Boolean; FileName : string; FileSID: TGUID; Owner : TExplorerForm);
  end;

implementation

uses Searching, FormManegerUnit, ExplorerThreadUnit;

{ TExplorerThumbnailCreator }

constructor TExplorerThumbnailCreator.Create(CreateSuspennded: Boolean;
  FileName : string; FileSID: TGUID; Owner : TExplorerForm);
begin
 inherited Create(True);
 FFileName := FileName;
 FFileSID := FileSID;                                                                   
 FOwner := Owner;
 Priority:=tpLowest;
 If not CreateSuspennded then Resume;
end;

procedure TExplorerThumbnailCreator.DrawAttributes;
var
  Exists : integer;
begin
 Exists:=1;
 Searching.DrawAttributes(TempBitmap,ThSizeExplorerPreview,info.ItemRating,info.ItemRotate,info.ItemAccess,info.ItemFileName,info.ItemCrypted,Exists,info.ItemId);
end;

procedure TExplorerThumbnailCreator.Execute;
var
  w, h : Integer;
begin       
  FreeOnTerminate:=True;
  CoInitialize(nil);
  try
    TempBitmap:=Tbitmap.create;
    try                     
      TempBitmap.PixelFormat:=pf24Bit;      
      TempBitmap.Width := ThSizeExplorerPreview;
      TempBitmap.Height := ThSizeExplorerPreview;
      FillColorEx(TempBitmap, Theme_MainColor);

      Info:=GetInfoByFileNameA(FFileName,true);

      If Info.Image<>nil then
      begin

      SendInfo:=Info;
      if (Info.Image.Width>ThSizeExplorerPreview) or (Info.Image.Height>ThSizeExplorerPreview) then
      begin
       Fbit:=TBitmap.create;
       Fbit.PixelFormat:=pf24bit;
       TempBit:=TBitmap.Create;
       TempBit.PixelFormat:=pf24bit;
       TempBit.Assign(Info.Image);
       w:=TempBit.Width;
       h:=TempBit.Height;
       ProportionalSize(ThSizeExplorerPreview,ThSizeExplorerPreview,w,h);
       try
        DoResize(w,h,TempBit,Fbit);
       except
       end;
       TempBit.free;

       DrawImageEx(TempBitmap, Fbit, ThSizeExplorerPreview div 2 - Fbit.Width div 2, ThSizeExplorerPreview div 2 - Fbit.Height div 2);

       Info.Image.Free;
      end else
      begin        
       TempBit:=TBitmap.Create;
       TempBit.PixelFormat:=pf24bit;
       TempBit.Assign(Info.Image);
       DrawImageEx(TempBitmap, TempBit, ThSizeExplorerPreview div 2 - Info.Image.Width div 2, ThSizeExplorerPreview div 2 - Info.Image.Height div 2);
       TempBit.Free;
       Info.Image.Free;
      end;
      ApplyRotate(TempBitmap, Info.ItemRotate);
      end else
      begin
       DoProcessPath(FFileName);
       if FolderView then
       if not FileExists(FFileName) then
       FFileName:=ProgramDir+FFileName;

       If FileExists(FFileName) and ExtInMask(SupportedExt,GetExt(FFileName)) then
       Fpic:=TPicture.Create else exit;
       try
        if ValidCryptGraphicFile(FFileName) then
        begin
        Info.ItemCrypted:=true;
        StringParam:=FFileName;
        Synchronize(FindPassword);
         try
          if StringParam<>'' then
          Fpic.Graphic:=DeCryptGraphicFile(FFileName,StringParam) else
          begin
           Fpic.Free; 
           CoUninitialize;
           exit;
          end;
         except
          Fpic.Free;
          CoUninitialize;
          exit;
         end;
        end else
        begin
         if IsRAWImageFile(FFileName) then
         begin
          Fpic.Graphic:=TRAWImage.Create;
          if not (Fpic.Graphic as TRAWImage).LoadThumbnailFromFile(FFileName) then
          Fpic.Graphic.LoadFromFile(FFileName);
         end else
         Fpic.LoadFromFile(FFileName);
        end;
    
       except
        Fpic.Free;  
        CoUninitialize;
        exit;
       end;
       Fbit:=TBitmap.create;
       Fbit.PixelFormat:=pf24bit;
       TempBit:=TBitmap.create;
       SendInfo.ItemHeight:=Fpic.Graphic.Height;
       SendInfo.ItemWidth:=Fpic.Graphic.Width;
       JPEGScale(Fpic.Graphic,ThSizeExplorerPreview,ThSizeExplorerPreview);
       if Min(Fpic.Height,Fpic.Width)>1 then
       try
        LoadImageX(Fpic.Graphic,TempBit,Theme_MainColor);
       except
        on e : Exception do EventLog(':TExplorerThumbnailCreator::Execute()/LoadImageX throw exception: '+e.Message);
       end;
       Fpic.Free;
       TempBit.PixelFormat:=pf24bit;
       w:=TempBit.Width;
       h:=TempBit.Height;
       If Max(w,h)<ThSizeExplorerPreview then Fbit.Assign(TempBit) else
       begin
        ProportionalSize(ThSizeExplorerPreview,ThSizeExplorerPreview,w,h);
        try
         DoResize(w,h,TempBit,Fbit);
        except
        end;
       end;
       TempBit.Free;
       DrawImageEx(TempBitmap, Fbit, ThSizeExplorerPreview div 2-Fbit.Width div 2, ThSizeExplorerPreview div 2-Fbit.height div 2);
       Fbit.free;
      end;
      Synchronize(DrawAttributes);
      try
      Synchronize(SetInfo);
      Synchronize(SetImage);
      except
      end;
    finally
      TempBitmap.free;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TExplorerThumbnailCreator.FindPassword;
begin
 StringParam:=DBKernel.FindPasswordForCryptImageFile(StringParam);
end;

procedure TExplorerThumbnailCreator.SetImage;
begin
 If ExplorerManager.IsExplorer(FOwner) then
 (FOwner as TExplorerForm).SetPanelImage(TempBitmap, FFileSID);
end;

procedure TExplorerThumbnailCreator.SetInfo;
begin
 If ExplorerManager.IsExplorer(FOwner) then
 (FOwner as TExplorerForm).SetPanelInfo(SendInfo, FFileSID);
end;

end.
