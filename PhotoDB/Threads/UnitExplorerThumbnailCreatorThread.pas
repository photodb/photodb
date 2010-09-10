unit UnitExplorerThumbnailCreatorThread;

interface

uses GraphicCrypt, Windows, Graphics, Classes, Dolphin_DB, ExplorerUnit, JPEG,
     SysUtils, Math, ComObj, ActiveX, ShlObj, CommCtrl, RAWImage, uDBDrawing,
     Effects, UnitDBCommonGraphics, UnitCDMappingSupport, uLogger, UnitDBCommon,
     ImageConverting, uMemory;

type
  TExplorerThumbnailCreator = class(TThread)
  private
    FFileSID: TGUID;
    FFileName: string;
    TempBitmap: TBitmap;
    Info: TOneRecordInfo;
    FOwner: TExplorerForm;
    GraphicParam: TGraphic;
    FGraphic: TGraphic;
    FBit, TempBit: TBitmap;
    StringParam: string;
  protected
    procedure Execute; override;
    procedure SetInfo;
    procedure SetImage;
    procedure DoDrawAttributes;
  public
    constructor Create(FileName: string; FileSID: TGUID; Owner: TExplorerForm);
  end;

implementation

uses ExplorerThreadUnit;

{ TExplorerThumbnailCreator }

constructor TExplorerThumbnailCreator.Create(FileName : string; FileSID: TGUID; Owner : TExplorerForm);
begin
  inherited Create(True);
  FFileName := FileName;
  FFileSID := FileSID;
  FOwner := Owner;
  Priority := tpLowest;
  Resume;
end;

procedure TExplorerThumbnailCreator.Execute;
var
  W, H : Integer;
  Password : string;
  GraphicClass : TGraphicClass;

begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    TempBitmap := TBitmap.Create;
    try
      TempBitmap.PixelFormat:=pf24Bit;
      TempBitmap.Width := ThSizeExplorerPreview;
      TempBitmap.Height := ThSizeExplorerPreview;
      FillColorEx(TempBitmap, Theme_MainColor);

      Info.Image := TJPEGImage.Create;
      try
        GetInfoByFileNameA(FFileName, True, Info);

        if not Info.Image.Empty then
        begin
          if (Info.Image.Width > ThSizeExplorerPreview) or (Info.Image.Height > ThSizeExplorerPreview) then
          begin
            TempBit := TBitmap.Create;
            try
              TempBit.PixelFormat := Pf24bit;
              AssignJpeg(TempBit, Info.Image);
              W := TempBit.Width;
              H := TempBit.Height;
              ProportionalSize(ThSizeExplorerPreview, ThSizeExplorerPreview, W, H);
              FBit := TBitmap.Create;
              try
                FBit.PixelFormat := Pf24bit;
                DoResize(W, H, TempBit, Fbit);
                DrawImageEx(TempBitmap, Fbit, ThSizeExplorerPreview div 2 - Fbit.Width div 2,
                  ThSizeExplorerPreview div 2 - Fbit.Height div 2);
              finally
                FBit.Free;
              end;
            finally
              TempBit.Free;
            end;
          end else
          begin
            TempBit := TBitmap.Create;
            try
              TempBit.PixelFormat := Pf24bit;
              AssignJpeg(TempBit, Info.Image);
              DrawImageEx(TempBitmap, TempBit, ThSizeExplorerPreview div 2 - Info.Image.Width div 2,
                ThSizeExplorerPreview div 2 - Info.Image.Height div 2);
            finally
              TempBit.Free;
            end;
          end;
          ApplyRotate(TempBitmap, Info.ItemRotate);
        end else
        begin
          DoProcessPath(FFileName);
          if FolderView then
          if not FileExists(FFileName) then
            FFileName := ProgramDir + FFileName;

          if not (FileExists(FFileName) and ExtInMask(SupportedExt, GetExt(FFileName))) then
            Exit;

          GraphicClass := GetGraphicClass(ExtractFileExt(FFileName), False);
          if GraphicClass = nil then
            Exit;

          FGraphic := GraphicClass.Create;
          try
            if ValidCryptGraphicFile(FFileName) then
            begin
              Info.ItemCrypted := True;
              Password := DBKernel.FindPasswordForCryptImageFile(FFileName);

              if Password <> '' then
              begin
                //TODO: Memory leaks!!!
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
              Info.ItemHeight := FGraphic.Height;
              Info.ItemWidth := FGraphic.Width;
              JPEGScale(FGraphic, ThSizeExplorerPreview, ThSizeExplorerPreview);

              TempBit := TBitmap.Create;
              try
                LoadImageX(FGraphic, TempBit, Theme_MainColor);
                F(FGraphic);
                TempBit.PixelFormat := pf24bit;
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
              DrawImageEx(TempBitmap, FBit, ThSizeExplorerPreview div 2 - FBit.Width div 2, ThSizeExplorerPreview div 2 - FBit.height div 2);
            finally
              F(FBit);
            end;
          finally
            F(FGraphic);
          end;
        end;
        Synchronize(DoDrawAttributes);
        Synchronize(SetInfo);
        Synchronize(SetImage);
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

procedure TExplorerThumbnailCreator.DoDrawAttributes;
var
  Exists : integer;
begin
  Exists := 1;
  DrawAttributes(TempBitmap, ThSizeExplorerPreview, Info.ItemRating, Info.ItemRotate, Info.ItemAccess,
    Info.ItemFileName, Info.ItemCrypted, Exists, Info.ItemId);
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
