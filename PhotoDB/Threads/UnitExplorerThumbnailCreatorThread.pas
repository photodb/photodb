unit UnitExplorerThumbnailCreatorThread;

interface

uses
  GraphicCrypt, Windows, Graphics, Classes, ExplorerUnit, JPEG,
  SysUtils, Math, ComObj, ActiveX, ShlObj, CommCtrl, RAWImage, uDBDrawing,
  Effects, uJpegUtils, uCDMappingTypes, uLogger, UnitDBCommon,
  uMemory, UnitDBDeclare, uGraphicUtils, UnitDBKernel, uExifUtils,
  uRuntime, uDBUtils, uFileUtils, uAssociations, uDBThread, CCR.Exif,
  uBitmapUtils, uShellIcons, ExplorerTypes, uConstants;

type
  TExplorerThumbnailCreator = class(TDBThread)
  private
    FFileSID: TGUID;
    TempBitmap: TBitmap;
    FInfo: TExplorerFileInfo;
    FOwner: TExplorerForm;
    FGraphic: TGraphic;
    FBit, TempBit: TBitmap;
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
  FInfo := Item.Copy as TExplorerFileInfo;
  FFileSID := FileSID;
  FOwner := Owner;
  Priority := tpLowest;
  FLoadFullImage := LoadFullImage;
end;

procedure TExplorerThumbnailCreator.Execute;
var
  W, H: Integer;
  Password: string;
  GraphicClass: TGraphicClass;
  ShadowImage: TBitmap;
  Data: TObject;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    if not FLoadFullImage then
    begin
      //load item icon for preview
      Ico := ExtractShellIcon(FInfo.FileName, 48);
      if not SynchronizeEx(UpdatePreviewIcon) then
        DestroyIcon(Ico);
      Exit;
    end;

    if (FInfo.FileType = EXPLORER_ITEM_GROUP) or (FInfo.FileType = EXPLORER_ITEM_PERSON) or (FInfo.FileType = EXPLORER_ITEM_CAMERA_IMAGE) then
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
            FillTransparentColor(TempBitmap, clBtnFace);

            ShadowImage := TBitmap.Create;
            try
              DrawShadowToImage(ShadowImage, FBit);
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

    if FInfo.FileType = EXPLORER_ITEM_IMAGE then
    begin
      TempBitmap := TBitmap.Create;
      try
        TempBitmap.PixelFormat := pf32Bit;
        TempBitmap.SetSize(ThSizeExplorerPreview + 4, ThSizeExplorerPreview + 4);
        FillTransparentColor(TempBitmap, clBtnFace);

        FInfo.Image := TJPEGImage.Create;
        try
          GetInfoByFileNameA(FInfo.FileName, True, FInfo);

          if (FInfo.Image <> nil) and not FInfo.Image.Empty then
          begin
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
            UpdateImageRecordFromExif(FInfo, False);
            DoProcessPath(FInfo.FileName);
            if FolderView then
            if not FileExistsSafe(FInfo.FileName) then
              FInfo.FileName := ProgramDir + FInfo.FileName;

            if not (FileExistsSafe(FInfo.FileName) or not IsGraphicFile(FInfo.FileName)) then
              Exit;

            GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FInfo.FileName));
            if GraphicClass = nil then
              Exit;

            FGraphic := GraphicClass.Create;
            try
              if ValidCryptGraphicFile(FInfo.FileName) then
              begin
                FInfo.Crypted := True;
                Password := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);

                if Password <> '' then
                begin
                  F(FGraphic);
                  FGraphic := DeCryptGraphicFile(FInfo.FileName, Password)
                end else
                  Exit;
              end else
              begin
                if FGraphic is TRAWImage then
                begin
                  if not(FGraphic as TRAWImage).LoadThumbnailFromFile(FInfo.FileName, ThSizeExplorerPreview, ThSizeExplorerPreview) then
                    FGraphic.LoadFromFile(FInfo.FileName)
                  else
                    FInfo.Rotation := ExifDisplayButNotRotate(FInfo.Rotation);
                end else
                  FGraphic.LoadFromFile(FInfo.FileName);
              end;

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

                  LoadImageX(FGraphic, TempBit, clBtnFace);
                  F(FGraphic);
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
  inherited;
end;

procedure TExplorerThumbnailCreator.DoDrawAttributes;
var
  Exists : integer;
begin
  Exists := 1;
  DrawAttributes(TempBitmap, ThSizeExplorerPreview, FInfo.Rating, FInfo.Rotation, FInfo.Access,
    FInfo.FileName, FInfo.Crypted, Exists, FInfo.ID);
end;

procedure TExplorerThumbnailCreator.SetImage;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).SetPanelImage(TempBitmap, FFileSID);
end;

procedure TExplorerThumbnailCreator.SetInfo;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).SetPanelInfo(FInfo, FFileSID);
end;

procedure TExplorerThumbnailCreator.UpdatePreviewIcon;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).UpdatePreviewIcon(Ico, FFileSID);
end;

end.
