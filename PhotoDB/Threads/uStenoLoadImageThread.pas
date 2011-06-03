unit uStenoLoadImageThread;

interface

uses
  Classes, Graphics, uAssociations, uFileUtils, UnitDBKernel, SysUtils,
  uDBThread, uStrongCrypt, GraphicCrypt, uDBForm, uShellIntegration,
  uConstants, uGraphicUtils, uMemory, UnitDBCommonGraphics, UnitDBCommon;

type
  TErrorLoadingImageHandler = procedure(FileName: string) of object;
  TSetPreviewLoadingImageHandler = procedure(Width, Height: Integer; var Bitmap: TBitmap; Preview: TBitmap; Password: string) of object;

  TStenoLoadImageThread = class(TDBThread)
  private
    { Private declarations }
    FBitmapParam: TBitmap;
    FFileName: string;
    FErrorHandler: TErrorLoadingImageHandler;
    FCallBack: TSetPreviewLoadingImageHandler;
    FPassword: string;
    FWidth, FHeight: Integer;
    FBitmapImage: TBitmap;
    FColor: TColor;
  protected
    procedure Execute; override;
    procedure AskUserForPassword;
    procedure HandleError;
    procedure UpdatePreview;
    function GetThreadID: string; override;
  public
    constructor Create(OwnerForm: TDBForm; FileName: string; Color: TColor;
      ErrorHandler: TErrorLoadingImageHandler;
      CallBack: TSetPreviewLoadingImageHandler);
  end;

implementation

uses
  UnitPasswordForm;

{ TStenoLoadImageThread }

procedure TStenoLoadImageThread.AskUserForPassword;
begin
  FPassword := GetImagePasswordFromUser(FFileName);
end;

constructor TStenoLoadImageThread.Create(OwnerForm: TDBForm; FileName: string;
  Color: TColor;
  ErrorHandler: TErrorLoadingImageHandler;
  CallBack: TSetPreviewLoadingImageHandler);
begin
  inherited Create(OwnerForm, False);
  FFileName := FileName;
  FErrorHandler := ErrorHandler;
  FCallBack := CallBack;
  FPassword := '';
  FColor := Color;
end;

procedure TStenoLoadImageThread.Execute;
var
  GraphicClass: TGraphicClass;
  Graphic: TGraphic;
  B32,
  PreviewImage: TBitmap;
  W, H: Integer;
begin
  inherited;
  FreeOnTerminate := True;

  try
    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FFileName));
    if GraphicClass = nil then
      Exit;

    Graphic := nil;
    try
      if ValidCryptGraphicFile(FFileName) then
      begin
        FPassword := DBkernel.FindPasswordForCryptImageFile(FFileName);
        if FPassword = '' then
          SynchronizeEx(AskUserForPassword);

        if FPassword <> '' then
        begin
          Graphic := DeCryptGraphicFile(FFileName, FPassword);
        end else
        begin
          SynchronizeEx(HandleError);
          Exit;
        end;
      end else
      begin
        Graphic := GraphicClass.Create;
        Graphic.LoadFromFile(FFileName);
      end;

      if Graphic = nil then
        Exit;

      FWidth := Graphic.Width;
      FHeight := Graphic.Height;
      FBitmapImage := TBitmap.Create;
      try
        AssignGraphic(FBitmapImage, Graphic);
        F(Graphic);
        FBitmapImage.PixelFormat := pf24bit;

        PreviewImage := TBitmap.Create;
        try
          W := FBitmapImage.Width;
          H := FBitmapImage.Height;
          ProportionalSize(146, 146, W, H);
          DoResize(W, H, FBitmapImage, PreviewImage);
          B32 := TBitmap.Create;
          try
            DrawShadowToImage(B32, PreviewImage);
            LoadBMPImage32bit(B32, PreviewImage, FColor);
            FBitmapParam := PreviewImage;
            SynchronizeEx(UpdatePreview);
          finally
            F(B32);
          end;
        finally
          F(PreviewImage);
        end;
      finally
        F(FBitmapImage);
      end;
    finally
      F(Graphic);
    end;
  except
    SynchronizeEx(HandleError);
  end;
end;

function TStenoLoadImageThread.GetThreadID: string;
begin
  Result := 'Steganography';
end;

procedure TStenoLoadImageThread.HandleError;
begin
  MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FFileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
  if Assigned(FErrorHandler) then
    FErrorHandler(FFileName);
end;

procedure TStenoLoadImageThread.UpdatePreview;
begin
  if Assigned(FCallBack) then
    FCallBack(FWidth, FHeight, FBitmapImage, FBitmapParam, FPassword);
end;

end.
