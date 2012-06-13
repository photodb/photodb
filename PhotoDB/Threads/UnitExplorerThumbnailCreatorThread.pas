unit UnitExplorerThumbnailCreatorThread;

interface

uses
  GraphicCrypt,
  Windows,
  Graphics,
  Classes,
  ExplorerUnit,
  uManagerExplorer,
  JPEG,
  SysUtils,
  Math,
  ComObj,
  ActiveX,
  ShlObj,
  CommCtrl,
  RAWImage,
  uDBDrawing,
  Effects,
  uJpegUtils,
  uCDMappingTypes,
  uLogger,
  UnitDBCommon,
  uMemory,
  UnitDBDeclare,
  uGraphicUtils,
  UnitDBKernel,
  uExifUtils,
  uRuntime,
  uDBUtils,
  uFileUtils,
  uAssociations,
  uDBThread,
  CCR.Exif,
  uBitmapUtils,
  uShellIcons,
  ExplorerTypes,
  uThemesUtils,
  uConstants,
  uShellThumbnails,
  uAssociatedIcons,
  uImageLoader,
  uExifInfo,
  uDBGraphicTypes;

type
  TExplorerThumbnailCreator = class(TDBThread)
  private
    FFileSID: TGUID;
    TempBitmap: TBitmap;
    FHistogrammImage: TBitmap;
    FInfo: TExplorerFileInfo;
    FOwner: TExplorerForm;
    FGraphic: TGraphic;
    FBit, TempBit: TBitmap;
    FExifInfo: IExifInfo;
    Ico: HIcon;
    FLoadFullImage: Boolean;
  protected
    procedure Execute; override;
    procedure SetInfo;
    procedure SetImage;
    procedure DoDrawAttributes;
    procedure UpdatePreviewIcon;
  public
    constructor Create(Item: TExplorerFileInfo; FileSID: TGUID; Owner: TExplorerForm; LoadFullImage: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  ExplorerThreadUnit;

{ TExplorerThumbnailCreator }

constructor TExplorerThumbnailCreator.Create(Item: TExplorerFileInfo; FileSID: TGUID; Owner: TExplorerForm; LoadFullImage: Boolean);
begin
  inherited Create(Owner, False);
  FHistogrammImage := nil;
  FreeOnTerminate := True;
  FInfo := Item.Copy as TExplorerFileInfo;
  FFileSID := FileSID;
  FOwner := Owner;
  Priority := tpLower;
  FLoadFullImage := LoadFullImage;
end;

procedure TExplorerThumbnailCreator.Execute;
var
  W, H: Integer;
  ImageInfo: ILoadImageInfo;
  ShadowImage: TBitmap;
  Data: TObject;
  MinC, MaxC: Integer;
  FHistogramm: TGistogrammData;
begin
  inherited;
  CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  try
    if not FLoadFullImage then
    begin
      //load item icon for preview
      Ico := ExtractShellIcon(FInfo.FileName, 48);
      if not SynchronizeEx(UpdatePreviewIcon) then
        DestroyIcon(Ico);
      Exit;
    end;

    FHistogramm.Loaded := False;

    if (FInfo.FileType = EXPLORER_ITEM_GROUP) or
       (FInfo.FileType = EXPLORER_ITEM_PERSON) or
       (FInfo.FileType = EXPLORER_ITEM_DEVICE) or
       (FInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
       (FInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
    begin
      FBit := TBitmap.Create;
      try
        Data := nil;
        if FInfo.Provider.ExtractPreview(FInfo, ThSizeExplorerPreview, ThSizeExplorerPreview, FBit, Data) then
        begin
          TempBitmap := TBitmap.Create;
          try
            TempBitmap.PixelFormat := pf32Bit;
            TempBitmap.SetSize(ThSizeExplorerPreview + 4, ThSizeExplorerPreview + 4);
            FillTransparentColor(TempBitmap, Theme.PanelColor);

            ShadowImage := TBitmap.Create;
            try
              if (FInfo.FileType <> EXPLORER_ITEM_DEVICE) then
                DrawShadowToImage(ShadowImage, FBit)
              else
                ShadowImage.Assign(FBit);

              DrawImageEx32(TempBitmap, ShadowImage, TempBitmap.Width div 2 - ShadowImage.Width div 2,
                TempBitmap.Height div 2 - ShadowImage.Height div 2);
            finally
              F(ShadowImage);
            end;
            SynchronizeEx(SetImage);
          finally
            F(TempBitmap);
          end;
        end;
      finally
        F(FBit);
      end;
      Exit;
    end;

    if IsVideoFile(FInfo.FileName) then
    begin
      TempBitmap := TBitmap.Create;
      try
        if ExtractVideoThumbnail(FInfo.FileName, ThSizeExplorerPreview, TempBitmap) then
          SynchronizeEx(SetImage);
      finally
        F(TempBitmap);
      end;
      Exit;
    end;

    if FInfo.FileType = EXPLORER_ITEM_IMAGE then
    begin
      TempBitmap := TBitmap.Create;
      try
        TempBitmap.PixelFormat := pf32Bit;
        TempBitmap.SetSize(ThSizeExplorerPreview + 4, ThSizeExplorerPreview + 4);
        FillTransparentColor(TempBitmap, Theme.PanelColor);

        FInfo.Image := TJPEGImage.Create;
        try
          GetInfoByFileNameA(FInfo.FileName, True, FInfo);

          if FInfo.HasImage then
          begin
            if LoadImageFromPath(FInfo, -1, '', [ilfEXIF, ilfPassword, ilfICCProfile], ImageInfo) then
            begin
              ImageInfo.UpdateImageGeoInfo(FInfo);
              if ImageInfo.ExifData <> nil then
                FillExifInfo(ImageInfo.ExifData, FExifInfo);
            end;

            if (FInfo.Image.Width > ThSizeExplorerPreview) or (FInfo.Image.Height > ThSizeExplorerPreview) then
            begin
              TempBit := TBitmap.Create;
              try
                TempBit.PixelFormat := pf24bit;
                AssignJpeg(TempBit, FInfo.Image);

                W := TempBit.Width;
                H := TempBit.Height;
                ProportionalSize(ThSizeExplorerPreview, ThSizeExplorerPreview, W, H);
                FBit := TBitmap.Create;
                try
                  FBit.PixelFormat := pf24bit;
                  DoResize(W, H, TempBit, Fbit);
                  F(TempBit);
                  if ImageInfo <> nil then
                    ImageInfo.AppllyICCProfile(Fbit);

                  FHistogramm := FillHistogramma(Fbit);

                  ShadowImage := TBitmap.Create;
                  try
                    DrawShadowToImage(ShadowImage, Fbit);
                    DrawImageEx32(TempBitmap, ShadowImage, TempBitmap.Width div 2 - ShadowImage.Width div 2,
                      TempBitmap.Height div 2 - ShadowImage.Height div 2);
                  finally
                    F(ShadowImage);
                  end;
                finally
                  F(FBit);
                end;
              finally
                F(TempBit);
              end;
            end else
            begin
              TempBit := TBitmap.Create;
              try
                TempBit.PixelFormat := pf24bit;
                AssignJpeg(TempBit, FInfo.Image);

                if ImageInfo <> nil then
                  ImageInfo.AppllyICCProfile(TempBit);

                FHistogramm := FillHistogramma(TempBit);

                ShadowImage := TBitmap.Create;
                try
                  DrawShadowToImage(ShadowImage, TempBit);
                  DrawImageEx32(TempBitmap, ShadowImage, TempBitmap.Width div 2 - ShadowImage.Width div 2,
                    TempBitmap.Height div 2 - ShadowImage.Height div 2);
                finally
                  F(ShadowImage);
                end;
              finally
                F(TempBit);
              end;
            end;
            ApplyRotate(TempBitmap, FInfo.Rotation);
          end else
          begin
            DoProcessPath(FInfo.FileName);
            if FolderView and not FileExistsSafe(FInfo.FileName) then
              FInfo.FileName := ProgramDir + FInfo.FileName;

            if not (FileExistsSafe(FInfo.FileName) or not IsGraphicFile(FInfo.FileName)) then
              Exit;

            FGraphic := nil;
            try
              if not LoadImageFromPath(FInfo, -1, '', [ilfGraphic, ilfEXIF, ilfPassword, ilfICCProfile], ImageInfo, ThSizeExplorerPreview, ThSizeExplorerPreview) then
                Exit;

              FillExifInfo(ImageInfo.ExifData, FExifInfo);
              ImageInfo.UpdateImageGeoInfo(FInfo);
              ImageInfo.UpdateImageInfo(FInfo, False);

              FGraphic := ImageInfo.ExtractGraphic;

              if (FGraphic = nil) or FGraphic.Empty then
                Exit;

              FBit := TBitmap.Create;
              try
                FBit.PixelFormat := pf24bit;
                FInfo.Height := FGraphic.Height;
                FInfo.Width := FGraphic.Width;
                JPEGScale(FGraphic, ThSizeExplorerPreview, ThSizeExplorerPreview);

                TempBit := TBitmap.Create;
                try

                  LoadImageX(FGraphic, TempBit, Theme.PanelColor);
                  F(FGraphic);

                  ImageInfo.AppllyICCProfile(TempBit);
                  FHistogramm := FillHistogramma(TempBit);

                  W := TempBit.Width;
                  H := TempBit.Height;
                  FBit.PixelFormat := TempBit.PixelFormat;
                  if Max(W,H) < ThSizeExplorerPreview then
                    AssignBitmap(FBit, TempBit)
                  else begin
                    ProportionalSize(ThSizeExplorerPreview, ThSizeExplorerPreview, W, H);
                    DoResize(W, H, TempBit, FBit);
                  end;
                  ApplyRotate(FBit, FInfo.Rotation);
                finally
                  F(TempBit);
                end;

                ShadowImage := TBitmap.Create;
                try
                  DrawShadowToImage(ShadowImage, FBit);
                  DrawImageEx32(TempBitmap, ShadowImage, TempBitmap.Width div 2 - ShadowImage.Width div 2,
                    TempBitmap.Height div 2 - ShadowImage.Height div 2);
                finally
                  F(ShadowImage);
                end;
              finally
                F(FBit);
              end;

            finally
              F(FGraphic);
            end;
          end;

          if FHistogramm.Loaded then
          begin
            FHistogrammImage := TBitmap.Create;
            GetGistogrammBitmapWRGB(130, FHistogramm.Gray, FHistogramm.Red, FHistogramm.Green, FHistogramm.Blue, MinC, MaxC, FHistogrammImage, clGray);
          end;

          SynchronizeEx(DoDrawAttributes);
          SynchronizeEx(SetInfo);
          SynchronizeEx(SetImage);
        finally
          F(FInfo.Image);
        end;
      finally
        F(TempBitmap);
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

destructor TExplorerThumbnailCreator.Destroy;
begin
  F(FInfo);
  F(FHistogrammImage);
  inherited;
end;

procedure TExplorerThumbnailCreator.DoDrawAttributes;
begin
  DrawAttributes(TempBitmap, ThSizeExplorerPreview, FInfo);
end;

procedure TExplorerThumbnailCreator.SetImage;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).SetPanelImage(TempBitmap, FFileSID);
end;

procedure TExplorerThumbnailCreator.SetInfo;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).SetPanelInfo(FInfo, FExifInfo, FHistogrammImage, FFileSID);
end;

procedure TExplorerThumbnailCreator.UpdatePreviewIcon;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).UpdatePreviewIcon(Ico, FFileSID);
end;

end.
