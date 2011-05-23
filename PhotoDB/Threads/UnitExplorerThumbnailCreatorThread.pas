unit UnitExplorerThumbnailCreatorThread;

interface

uses GraphicCrypt, Windows, Graphics, Classes, ExplorerUnit, JPEG,
     SysUtils, Math, ComObj, ActiveX, ShlObj, CommCtrl, RAWImage, uDBDrawing,
     Effects, UnitDBCommonGraphics, uCDMappingTypes, uLogger, UnitDBCommon,
     uMemory, UnitDBDeclare, uGraphicUtils, UnitDBKernel,
     uRuntime, uDBUtils, uFileUtils, uAssociations, uDBThread;

type
  TExplorerThumbnailCreator = class(TDBThread)
  private
    FFileSID: TGUID;
    FFileName: string;
    TempBitmap: TBitmap;
    Info: TDBPopupMenuInfoRecord;
    FOwner: TExplorerForm;
    FGraphic: TGraphic;
    FBit, TempBit: TBitmap;
  protected
    procedure Execute; override;
    procedure SetInfo;
    procedure SetImage;
    procedure DoDrawAttributes;
  public
    constructor Create(FileName: string; FileSID: TGUID; Owner: TExplorerForm);
    destructor Destroy; override;
  end;

implementation

uses ExplorerThreadUnit;

{ TExplorerThumbnailCreator }

constructor TExplorerThumbnailCreator.Create(FileName : string; FileSID: TGUID; Owner: TExplorerForm);
begin
  inherited Create(Owner, False);
  Info := TDBPopupMenuInfoRecord.Create;
  FFileName := FileName;
  FFileSID := FileSID;
  FOwner := Owner;
  Priority := tpLowest;
end;

procedure TExplorerThumbnailCreator.Execute;
var
  W, H : Integer;
  Password : string;
  GraphicClass : TGraphicClass;
  ShadowImage : TBitmap;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    TempBitmap := TBitmap.Create;
    try
      TempBitmap.PixelFormat := pf32Bit;
      TempBitmap.SetSize(ThSizeExplorerPreview + 4, ThSizeExplorerPreview + 4);
      FillTransparentColor(TempBitmap, clBtnFace);

      Info.Image := TJPEGImage.Create;
      try
        GetInfoByFileNameA(FFileName, True, Info);

        if (Info.Image <> nil) and not Info.Image.Empty then
        begin
          if (Info.Image.Width > ThSizeExplorerPreview) or (Info.Image.Height > ThSizeExplorerPreview) then
          begin
            TempBit := TBitmap.Create;
            try
              TempBit.PixelFormat := pf24bit;
              AssignJpeg(TempBit, Info.Image);
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
              AssignJpeg(TempBit, Info.Image);
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
          ApplyRotate(TempBitmap, Info.Rotation);
        end else
        begin
          DoProcessPath(FFileName);
          if FolderView then
          if not FileExistsSafe(FFileName) then
            FFileName := ProgramDir + FFileName;

          if not (FileExistsSafe(FFileName) or not IsGraphicFile(FFileName)) then
            Exit;

          GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FFileName));
          if GraphicClass = nil then
            Exit;

          FGraphic := GraphicClass.Create;
          try
            if ValidCryptGraphicFile(FFileName) then
            begin
              Info.Crypted := True;
              Password := DBKernel.FindPasswordForCryptImageFile(FFileName);

              if Password <> '' then
              begin
                F(FGraphic);
                FGraphic := DeCryptGraphicFile(FFileName, Password)
              end else
                Exit;
            end else
            begin
              if FGraphic is TRAWImage then
              begin
                if not(FGraphic as TRAWImage).LoadThumbnailFromFile(FFileName, ThSizeExplorerPreview, ThSizeExplorerPreview) then
                  FGraphic.LoadFromFile(FFileName);
              end else
                FGraphic.LoadFromFile(FFileName);
            end;

            FBit := TBitmap.Create;
            try
              FBit.PixelFormat := pf24bit;
              Info.Height := FGraphic.Height;
              Info.Width := FGraphic.Width;
              JPEGScale(FGraphic, ThSizeExplorerPreview, ThSizeExplorerPreview);

              TempBit := TBitmap.Create;
              try

                LoadImageX(FGraphic, TempBit, clBtnFace);
                F(FGraphic);
                W := TempBit.Width;
                H := TempBit.Height;
                if Max(W,H) < ThSizeExplorerPreview then
                  AssignBitmap(FBit, TempBit)
                else begin
                  ProportionalSize(ThSizeExplorerPreview, ThSizeExplorerPreview, W, H);
                  DoResize(W, H, TempBit, FBit);
                end;
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
        F(Info.Image);
      end;
    finally
      F(TempBitmap);
    end;
  finally
    CoUninitialize;
  end;
end;

destructor TExplorerThumbnailCreator.Destroy;
begin
  F(Info);
  inherited;
end;

procedure TExplorerThumbnailCreator.DoDrawAttributes;
var
  Exists : integer;
begin
  Exists := 1;
  DrawAttributes(TempBitmap, ThSizeExplorerPreview, Info.Rating, Info.Rotation, Info.Access,
    Info.FileName, Info.Crypted, Exists, Info.ID);
end;

procedure TExplorerThumbnailCreator.SetImage;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).SetPanelImage(TempBitmap, FFileSID);
end;

procedure TExplorerThumbnailCreator.SetInfo;
begin
  if ExplorerManager.IsExplorer(FOwner) then
    (FOwner as TExplorerForm).SetPanelInfo(Info, FFileSID);
end;

end.

