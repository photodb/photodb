unit uStenoLoadImageThread;

interface

uses
  Classes,
  Graphics,
  UnitDBDeclare,
  uAssociations,
  uFileUtils,
  SysUtils,
  uDBThread,
  uDBForm,
  uShellIntegration,
  uConstants,
  uMemory,
  uImageLoader;

type
  TErrorLoadingImageHandler = procedure(FileName: string) of object;
  TSetPreviewLoadingImageHandler = procedure(Width, Height: Integer; var Bitmap: TBitmap; Preview: TBitmap; Password: string) of object;

  TStenoLoadImageThread = class(TDBThread)
  private
    { Private declarations }
    FBitmapPreview: TBitmap;
    FFileName: string;
    FErrorHandler: TErrorLoadingImageHandler;
    FCallBack: TSetPreviewLoadingImageHandler;
    FPassword: string;
    FWidth, FHeight: Integer;
    FBitmapImage: TBitmap;
    FColor: TColor;
  protected
    procedure Execute; override;
    procedure HandleError;
    procedure UpdatePreview;
    function GetThreadID: string; override;
  public
    constructor Create(OwnerForm: TDBForm; FileName: string; Color: TColor;
      ErrorHandler: TErrorLoadingImageHandler;
      CallBack: TSetPreviewLoadingImageHandler);
  end;

implementation

{ TStenoLoadImageThread }

constructor TStenoLoadImageThread.Create(OwnerForm: TDBForm; FileName: string;
  Color: TColor;
  ErrorHandler: TErrorLoadingImageHandler;
  CallBack: TSetPreviewLoadingImageHandler);
begin
  inherited Create(OwnerForm, False);
  FreeOnTerminate := True;
  FFileName := FileName;
  FErrorHandler := ErrorHandler;
  FCallBack := CallBack;
  FPassword := '';
  FColor := Color;
end;

procedure TStenoLoadImageThread.Execute;
var
  ImageInfo: ILoadImageInfo;
  Info: TDBPopupMenuInfoRecord;
begin
  try
    Info := TDBPopupMenuInfoRecord.CreateFromFile(FFileName);
    try
      try
        if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword, ilfAskUserPassword], ImageInfo, 146, 146) then
        begin
          FWidth := ImageInfo.GraphicWidth;
          FHeight := ImageInfo.GraphicHeight;
          FBitmapPreview := ImageInfo.GenerateBitmap(Info, 146, 146, pf24Bit, FColor, [ilboFreeGraphic, ilboAddShadow, ilboRotate, ilboApplyICCProfile]);
          try
            FBitmapImage := ImageInfo.ExtractFullBitmap;
            try
              SynchronizeEx(UpdatePreview);
            finally
              F(FBitmapImage);
            end;
          finally
            F(FBitmapPreview);
          end;
        end;
      except
        SynchronizeEx(HandleError);
      end;
    finally
      F(Info);
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
  if Assigned(FCallBack) and (FBitmapImage <> nil) and (FBitmapPreview <> nil) then
    FCallBack(FWidth, FHeight, FBitmapImage, FBitmapPreview, FPassword);
end;

end.
