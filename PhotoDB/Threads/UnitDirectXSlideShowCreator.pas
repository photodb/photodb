unit UnitDirectXSlideShowCreator;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Math,
  Vcl.Graphics,
  Vcl.Forms,

  Dmitry.Graphics.Utils,

  RAWImage,
  GraphicCrypt,
  UnitDBKernel,

  uGraphicUtils,
  uMemory,
  uDXUtils,
  uConstants,
  uDBThread,
  uAssociations,
  uJpegUtils,
  uBitmapUtils,
  uAnimatedJPEG,
  uProgramStatInfo,
  uPortableDeviceUtils;

type
  TDirectXSlideShowCreator = class(TDirectXSlideShowCreatorCustomThread)
  private
    { Private declarations }
    FInfo: TDirectXSlideShowCreatorInfo;
    FSynchBitmap: TBitmap;
    FBooleanParam: Boolean;
    FMonWidth, FMonHeight: Integer;
  protected
    function GetThreadID: string; override;
    procedure Execute; override;
    procedure ValidThread;
    procedure ActualThread;
    procedure SendImage(ImageToSend: TBitmap);
    procedure SendImageSynch;
    procedure ShowError(ErrorText: string);
  public
    constructor Create(Info: TDirectXSlideShowCreatorInfo);
    destructor Destroy; override;
  end;

implementation

uses
  DX_Alpha;

constructor TDirectXSlideShowCreator.Create(Info: TDirectXSlideShowCreatorInfo);
begin
  inherited Create(Info);
  FMonWidth := Info.Form.Width;
  FMonHeight := Info.Form.Height;
  FInfo := Info;
  FInfo.Manager.AddThread(Self);
end;

procedure TDirectXSlideShowCreator.ValidThread;
begin
  FBooleanParam := TDirectShowForm(OwnerForm).IsValidThread(FInfo.SID);
end;

procedure TDirectXSlideShowCreator.ActualThread;
begin
  FBooleanParam := TDirectShowForm(OwnerForm).IsActualThread(FInfo.SID);
end;

procedure TDirectXSlideShowCreator.SendImage(ImageToSend: TBitmap);
var
  IsValid, IsActual: Boolean;
begin

  repeat
    SynchronizeEx(ValidThread);
    IsValid := FBooleanParam;

    SynchronizeEx(ActualThread);
    IsActual := FBooleanParam;

    if not IsValid then
      Exit;

    if IsActual then
      Break;

    Sleep(10);
  until False;

  FSynchBitmap := ImageToSend;
  SynchronizeEx(SendImageSynch);
end;

procedure TDirectXSlideShowCreator.SendImageSynch;
begin
  TDirectShowForm(OwnerForm).NewImage(FSynchBitmap);
end;

procedure TDirectXSlideShowCreator.ShowError(ErrorText: string);
var
  ScreenImage: TBitmap;
  Text: string;
  R: TRect;
begin
  ScreenImage := TBitmap.Create;
  try
    ScreenImage.Canvas.Pen.Color := 0;
    ScreenImage.Canvas.Brush.Color := 0;
    ScreenImage.Canvas.Font.Color := clWhite;
    ScreenImage.SetSize(FMonWidth, FMonHeight);
    Text := ErrorText;
    R := Rect(0, 0, FMonWidth, FMonHeight);
    ScreenImage.Canvas.TextRect(R, Text, [tfVerticalCenter, tfCenter]);
    FSynchBitmap := ScreenImage;
    SendImageSynch;
  finally
    F(ScreenImage);
  end;
end;

procedure TDirectXSlideShowCreator.Execute;
var
  W, H: Integer;
  Zoom: Extended;
  Image, TempImage, ScreenImage: TBitmap;
  GraphicClass: TGraphicClass;
  FilePassword: string;
  Text_error_out: string;
  Graphic: TGraphic;
begin
  FreeOnTerminate := True;

  Text_error_out := L('Unable to show file:');
  try
    if not IsDevicePath(FInfo.FileName) and ValidCryptGraphicFile(FInfo.FileName) then
    begin
      FilePassword := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
      if FilePassword = '' then
        Exit;
    end;

    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FInfo.FileName));
    if GraphicClass = nil then
      Exit;

    Graphic := GraphicClass.Create;
    try
      if not IsDevicePath(FInfo.FileName) and ValidCryptGraphicFile(FInfo.FileName) then
      begin
        F(Graphic);
        Graphic := DeCryptGraphicFile(FInfo.FileName, FilePassword, False);
      end else
      begin
        if Graphic is TRAWImage then
          TRAWImage(Graphic).IsPreview := True;

        if not IsDevicePath(FInfo.FileName) then
          Graphic.LoadFromFile(FInfo.FileName)
        else
          Graphic.LoadFromDevice(FInfo.FileName);
      end;
      case FInfo.Rotate and DB_IMAGE_ROTATE_MASK of
        DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_180:
          JPEGScale(Graphic, FMonWidth, FMonHeight);
        DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_270:
          JPEGScale(Graphic, FMonHeight, FMonWidth);
      end;

      //statistics
      if Graphic is TAnimatedJPEG then
        ProgramStatistics.Image3dUsed;

      Image := TBitmap.Create;
      try
        AssignGraphic(Image, Graphic);
        F(Graphic);

        ScreenImage := TBitmap.Create;
        try
          ScreenImage.Canvas.Pen.Color := 0;
          ScreenImage.Canvas.Brush.Color := 0;
          ScreenImage.SetSize(FMonWidth, FMonHeight);

          W := Image.Width;
          H := Image.Height;
          case FInfo.Rotate and DB_IMAGE_ROTATE_MASK of
            DB_IMAGE_ROTATE_0:
            begin
              ProportionalSize(FMonWidth, FMonHeight, W, H);
              if (Image.Width <> 0) and (Image.Height <> 0) then
                Zoom := Max(W / Image.Width, H / Image.Height)
              else
                Zoom := 1;

              if (Zoom < ZoomSmoothMin) then
                StretchCoolEx0(FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2, W, H, Image, ScreenImage, $000000)
              else
              begin
                XFillRect(FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2, W, H, ScreenImage, $000000);
                TempImage := TBitmap.Create;
                try
                  TempImage.PixelFormat := pf24bit;
                  TempImage.SetSize(W, H);
                  SmoothResize(W, H, Image, TempImage);
                  ThreadDraw(TempImage, ScreenImage, FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2);
                finally
                  F(TempImage);
                end;
              end;
            end;
            DB_IMAGE_ROTATE_270:
            begin
              ProportionalSize(FMonHeight, FMonWidth, W, H);
              StretchCoolEx270(FMonWidth div 2 - H div 2, FMonHeight div 2 - W div 2, W, H, Image, ScreenImage, $000000)
            end;
            DB_IMAGE_ROTATE_90:
            begin
              ProportionalSize(FMonHeight, FMonWidth, W, H);
              StretchCoolEx90(FMonWidth div 2 - H div 2, FMonHeight div 2 - W div 2, W, H, Image, ScreenImage, $000000)
            end;
            DB_IMAGE_ROTATE_180:
            begin
              ProportionalSize(FMonWidth, FMonHeight, W, H);
              StretchCoolEx180(FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2, W, H, Image, ScreenImage, $000000)
            end;
          end;
          F(Image);

          SendImage(ScreenImage);

        finally
          F(ScreenImage);
        end;

      finally
        F(Image);
      end;

    finally
      F(Graphic);
    end;

  except
    on e: Exception do
      ShowError(e.Message);
  end;
end;

destructor TDirectXSlideShowCreator.Destroy;
begin
  DirectXSlideShowCreatorManagers.RemoveThread(FInfo.Manager, Self);
  inherited;
end;

function TDirectXSlideShowCreator.GetThreadID: string;
begin
  Result := 'Viewer';
end;

end.
