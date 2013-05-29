unit uImageViewer;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ComCtrls,

  Dmitry.Utils.System,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WebLink,

  ExplorerTypes,

  uMemory,
  uGOM,
  uTime,
  uIImageViewer,
  uImageViewerControl,
  uFaceDetection,
  uImageViewerThread,
  uThreadForm,
  uGUIDUtils,
  uTranslate,
  uInterfaces,
  uFormInterfaces,
  uExifInfo,
  uDBEntities,
  uSessionPasswords;

type
  TImageViewerOption = (ivoInfo, ivoFaces);
  TImageViewerOptions = set of TImageViewerOption;

type
  TImageViewer = class(TInterfacedObject, IImageViewer, IFaceResultForm)
  private
    FOwnerForm: TThreadForm;
    FTop: Integer;
    FLeft: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FOwner: TWinControl;
    FImageSource: IImageSource;
    FImageControl: TImageViewerControl;
    FCurrentFile: string;
    FFiles: TMediaItemCollection;
    FIsWaiting: Boolean;
    FActiveThreadId: TGUID;
    FItem: TMediaItem;
    FOnBeginLoadingImage: TBeginLoadingImageEvent;
    FOnPersonsFoundOnImage: TPersonsFoundOnImageEvent;
    FOnUpdateButtonsState: TUpdateButtonsStateEvent;
    FImageViewerOptions: TImageViewerOptions;
    procedure Resize;
    procedure LoadFile(FileInfo: TMediaItem; NewImage: Boolean);
    procedure LoadImage(Sender: TObject; Item: TMediaItem; Width, Height: Integer);
    procedure NotifyButtonsUpdate;
    function IsDetectFacesEnabled: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    //IObjectSource Implementation
    function GetObject: TObject;
    //IObjectSource END

    procedure RefreshFaceDetestionState;
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
    procedure FinishDetectionFaces;
    procedure SetFaceDetectionControls(AWlFaceCount: TWebLink; ALsDetectingFaces: TLoadingSign; ATbrActions: TToolBar);
    procedure SelectPerson(PersonID: Integer);
    procedure ResetPersonSelection;
    procedure StartPersonSelection;
    procedure StopPersonSelection;
    procedure CheckFaceIndicatorVisibility;

    procedure UpdateAvatar(PersonID: Integer);

    procedure AttachTo(OwnerForm: TThreadForm; Control: TWinControl; X, Y: Integer);
    procedure LoadFiles(FileList: TMediaItemCollection);
    procedure LoadPreviousFile;
    procedure LoadNextFile;
    procedure ResizeTo(Width, Height: Integer);
    procedure SetOptions(Options: TImageViewerOptions);
    procedure SetStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
    procedure SetAnimatedImage(Image: TGraphic; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
    procedure FailedToLoadImage(ErrorMessage: string);

    procedure ZoomOut;
    procedure ZoomIn;

    procedure RotateCW;
    procedure RotateCCW;

    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetLeft: Integer;
    function GetActiveThreadId: TGUID;
    function GetItem: TMediaItem;
    function GetDisplayBitmap: TBitmap;
    function GetCurentFile: string;
    function GetIsAnimatedImage: Boolean;

    function GetText: string;
    procedure SetText(Text: string);
    function GetShowInfo: Boolean;
    procedure SetShowInfo(Value: Boolean);
    procedure SetOnBeginLoadingImage(Event: TBeginLoadingImageEvent);
    function GetOnBeginLoadingImage: TBeginLoadingImageEvent;
    procedure SetOnRequestNextImage(Event: TNotifyEvent);
    function GetOnRequestNextImage: TNotifyEvent;
    procedure SetOnRequestPreviousImage(Event: TNotifyEvent);
    function GetOnRequestPreviousImage: TNotifyEvent;
    procedure SetOnDblClick(Event: TNotifyEvent);
    function GetOnDblClick: TNotifyEvent;
    procedure SetOnPersonsFoundOnImage(Event: TPersonsFoundOnImageEvent);
    function GetOnPersonsFoundOnImage: TPersonsFoundOnImageEvent;
    procedure SetOnStopPersonSelection(Event: TNotifyEvent);
    function GetOnStopPersonSelection: TNotifyEvent;
    procedure SetOnUpdateButtonsState(Event: TUpdateButtonsStateEvent);
    function GetOnUpdateButtonsState: TUpdateButtonsStateEvent;
  end;

implementation

{ TImageViewer }

procedure TImageViewer.AttachTo(OwnerForm: TThreadForm; Control: TWinControl; X, Y: Integer);
begin
  if Control = nil then
    raise EArgumentNilException.Create('Control is null!');

  FOwner := Control;
  FTop := Y;
  FLeft := X;

  FOwnerForm := OwnerForm;
  FOwnerForm.GetInterface(IImageSource, FImageSource);

  FImageControl := TImageViewerControl.Create(Control);
  FImageControl.ImageViewer := Self;
  FImageControl.Top := Y;
  FImageControl.Left := X;
  FImageControl.OnImageRequest := LoadImage;
  FImageControl.Parent := Control;
  if FOwnerForm is TCustomExplorerForm then
     FImageControl.Explorer := TCustomExplorerForm(FOwnerForm);

  inherited;
end;

procedure TImageViewer.CheckFaceIndicatorVisibility;
begin
  FImageControl.CheckFaceIndicatorVisibility;
end;

constructor TImageViewer.Create;
begin
  GOM.AddObj(Self);
  FFiles := nil;
  FImageSource := nil;
  FCurrentFile := '';
  FIsWaiting := False;
  FActiveThreadId := GetEmptyGUID;
  FItem := TMediaItem.Create;

  FOnBeginLoadingImage := nil;
  FOnPersonsFoundOnImage := nil;

  FImageViewerOptions := [ivoInfo, ivoFaces];
end;

destructor TImageViewer.Destroy;
begin
  GOM.RemoveObj(Self);
  F(FItem);
  F(FFiles);
end;

procedure TImageViewer.FinishDetectionFaces;
begin
  FImageControl.FinishDetectingFaces;
end;

function TImageViewer.GetActiveThreadId: TGUID;
begin
  Result := FActiveThreadId;
end;

function TImageViewer.GetCurentFile: string;
begin
  Result := FItem.FileName;
end;

function TImageViewer.GetDisplayBitmap: TBitmap;
begin
  Result := FImageControl.FullImage;
end;

function TImageViewer.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TImageViewer.GetIsAnimatedImage: Boolean;
begin
  Result := FImageControl.IsAnimatedImage;
end;

function TImageViewer.GetItem: TMediaItem;
begin
  Result := FItem;
end;

function TImageViewer.GetLeft: Integer;
begin
  Result := FLeft;
end;

{$REGION IObjectSource}

function TImageViewer.GetObject: TObject;
begin
  Result := Self;
end;

function TImageViewer.GetOnBeginLoadingImage: TBeginLoadingImageEvent;
begin
  Result := FOnBeginLoadingImage;
end;

function TImageViewer.GetOnDblClick: TNotifyEvent;
begin
  Result := FImageControl.OnDblClick;
end;

function TImageViewer.GetOnPersonsFoundOnImage: TPersonsFoundOnImageEvent;
begin
  Result := FOnPersonsFoundOnImage;
end;

function TImageViewer.GetOnRequestNextImage: TNotifyEvent;
begin
  Result := FImageControl.OnRequestNextImage;
end;

function TImageViewer.GetOnRequestPreviousImage: TNotifyEvent;
begin
  Result := FImageControl.OnRequestPreviousImage;
end;

function TImageViewer.GetOnStopPersonSelection: TNotifyEvent;
begin
  Result := FImageControl.OnStopPersonSelection;
end;

function TImageViewer.GetOnUpdateButtonsState: TUpdateButtonsStateEvent;
begin
  Result := FOnUpdateButtonsState;
end;

function TImageViewer.GetShowInfo: Boolean;
begin
  Result := FImageControl.ShowInfo;
end;

{$ENDREGION}

function TImageViewer.GetText: string;
begin
  Result := FImageControl.Text;
end;

function TImageViewer.GetTop: Integer;
begin
  Result := FTop;
end;

function TImageViewer.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TImageViewer.IsDetectFacesEnabled: Boolean;
begin
  Result := ivoFaces in FImageViewerOptions;
end;

procedure TImageViewer.LoadFile(FileInfo: TMediaItem; NewImage: Boolean);
var
  Width, Height: Integer;
  Bitmap: TBitmap;
begin        
  FActiveThreadId := GetGUID;

  if FileInfo.Encrypted then
  begin
    if SessionPasswords.FindForFile(FileInfo.FileName) = '' then
    begin
      SetText(TA('File is encrypted', 'Explorer'));
      Exit;
    end;
  end;

  if FImageSource <> nil then
  begin
    Width := 0;
    Height := 0;
    Bitmap := TBitmap.Create;
    try
 TW.I.Start('LoadFile - GetImage');
      if FImageSource.GetImage(FileInfo.FileName, Bitmap, Width, Height) then
      begin
 TW.I.Start('LoadFile - LoadStaticImage');
        FImageControl.LoadStaticImage(FileInfo, Bitmap, Width, Height, FileInfo.Rotation, 1, nil);
        Bitmap := nil;
      end;
    finally
      F(Bitmap);
    end;
  end;

  F(FItem);
  FItem := FileInfo.Copy;

  if Assigned(FOnBeginLoadingImage) then
    FOnBeginLoadingImage(Self, NewImage);

 TW.I.Start('LoadFile - StartLoadingImage');
  FImageControl.StartLoadingImage;
  LoadImage(Self, FileInfo, FWidth, FHeight);
end;

procedure TImageViewer.LoadFiles(FileList: TMediaItemCollection);
var
  I, Position: Integer;
  TheSameFileList: Boolean;
begin
  TheSameFileList := (FFiles <> nil) and (FFiles.Count = FileList.Count) and (FImageControl.Text = '');
  if TheSameFileList then
  begin
    for I := 0 to FFiles.Count - 1 do
    begin
      if AnsiLowerCase(FFiles[I].FileName) <> AnsiLowerCase(FileList[I].FileName) then
      begin
        TheSameFileList := False;
        Break;
      end;
    end;
    if TheSameFileList then
      TheSameFileList := FFiles.Position = FileList.Position;
  end;

  F(FFiles);
  FFiles := FileList;

  if not TheSameFileList then
  begin
    Position := FFiles.Position;
    if Position > -1 then
      LoadFile(FFiles[Position], True);
  end else
  begin
    F(FItem);
    FItem := FFiles[FFiles.Position].Copy;
    FImageControl.UpdateItemInfo(FItem);
    if Assigned (FOnBeginLoadingImage) then
      FOnBeginLoadingImage(Self, False);
  end;
end;

procedure TImageViewer.LoadImage(Sender: TObject; Item: TMediaItem; Width, Height: Integer);
var
  DisplaySize: TSize;
begin
  DisplaySize.cx := Width;
  DisplaySize.cy := Height;
  TImageViewerThread.Create(FOwnerForm, Self, FActiveThreadId, Item, DisplaySize, True, -1, IsDetectFacesEnabled);
end;

procedure TImageViewer.LoadNextFile;
begin
  if FFiles = nil then
    Exit;

  FFiles.NextSelected;
  if FFiles.Position > -1 then
    LoadFile(FFiles[FFiles.Position], True);
end;

procedure TImageViewer.LoadPreviousFile;
begin
  if FFiles = nil then
    Exit;

  FFiles.PrevSelected;
  if FFiles.Position > -1 then
    LoadFile(FFiles[FFiles.Position], True);
end;

procedure TImageViewer.NotifyButtonsUpdate;
var
  Buttons: TButtonStates;
begin
  if not Assigned(FOnUpdateButtonsState) then
    Exit;

  Buttons := TButtonStates.Create;
  try
    if FImageControl.Text = '' then
    begin
      Buttons[ivbRating].AddState(ivbsVisible).AddState(ivbsEnabled);
      Buttons[ivbRotateCW].AddState(ivbsVisible).AddState(ivbsEnabled);
      Buttons[ivbRotateCCW].AddState(ivbsVisible).AddState(ivbsEnabled);

      Buttons[ivbInfo].AddState(ivbsVisible).AddState(ivbsEnabled);
      if FImageControl.ShowInfo then
        Buttons[ivbInfo].AddState(ivbsDown);
    end;
    Buttons[ivbPrevious].AddState(ivbsVisible).AddState(ivbsEnabled);
    Buttons[ivbNext].AddState(ivbsVisible).AddState(ivbsEnabled);

    FOnUpdateButtonsState(Self, Buttons);
  finally
    F(Buttons);
  end;
end;

procedure TImageViewer.ResetPersonSelection;
begin
  FImageControl.HightliteReset;
end;

procedure TImageViewer.Resize;
begin
  //TODO:
end;

procedure TImageViewer.ResizeTo(Width, Height: Integer);
begin
  FWidth := Width;
  FHeight := Height;
  FImageControl.Width := Width;
  FImageControl.Height := Height;
  
  Resize;
end;

procedure TImageViewer.RotateCCW;
begin
  FImageControl.RotateCCW;
end;

procedure TImageViewer.RotateCW;
begin
  FImageControl.RotateCW;
end;

procedure TImageViewer.SelectPerson(PersonID: Integer);
begin
  FImageControl.HightlitePerson(PersonID);
end;

procedure TImageViewer.FailedToLoadImage(ErrorMessage: string);
begin
  FImageControl.FailedToLoadImage(ErrorMessage);
  NotifyButtonsUpdate;
end;

procedure TImageViewer.SetFaceDetectionControls(AWlFaceCount: TWebLink;
  ALsDetectingFaces: TLoadingSign; ATbrActions: TToolBar);
begin
  FImageControl.SetFaceDetectionControls(AWlFaceCount, ALsDetectingFaces, ATbrActions);
end;

procedure TImageViewer.SetOnBeginLoadingImage(Event: TBeginLoadingImageEvent);
begin
  FOnBeginLoadingImage := Event;
end;

procedure TImageViewer.SetOnDblClick(Event: TNotifyEvent);
begin
  FImageControl.OnDblClick := Event;
end;

procedure TImageViewer.SetOnPersonsFoundOnImage(Event: TPersonsFoundOnImageEvent);
begin
  FOnPersonsFoundOnImage := Event;
end;

procedure TImageViewer.SetOnRequestNextImage(Event: TNotifyEvent);
begin
  FImageControl.OnRequestNextImage := Event;
end;

procedure TImageViewer.SetOnRequestPreviousImage(Event: TNotifyEvent);
begin
  FImageControl.OnRequestPreviousImage := Event;
end;

procedure TImageViewer.SetOnStopPersonSelection(Event: TNotifyEvent);
begin
  FImageControl.OnStopPersonSelection := Event;
end;

procedure TImageViewer.SetOnUpdateButtonsState(Event: TUpdateButtonsStateEvent);
begin
  FOnUpdateButtonsState := Event;
end;

procedure TImageViewer.SetOptions(Options: TImageViewerOptions);
begin
  FImageViewerOptions := Options;

  FImageControl.ShowInfo := ivoInfo in Options;
  FImageControl.DetectFaces := ivoFaces in Options;
end;

procedure TImageViewer.SetShowInfo(Value: Boolean);
begin
  FImageControl.ShowInfo := Value;
end;

procedure TImageViewer.SetStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
begin
  if FFiles.Position < 0 then
    Exit;
  if FFiles.Position > FFiles.Count - 1 then
    Exit;

  FImageControl.LoadStaticImage(FFiles[FFiles.Position], Image, RealWidth, RealHeight, Rotation, ImageScale, Exif);
  NotifyButtonsUpdate;
end;

procedure TImageViewer.SetAnimatedImage(Image: TGraphic; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
begin
  if FFiles.Position < 0 then
    Exit;
  if FFiles.Position > FFiles.Count - 1 then
    Exit;

  FImageControl.LoadAnimatedImage(FFiles[FFiles.Position], Image, RealWidth, RealHeight, Rotation, ImageScale, Exif);
  NotifyButtonsUpdate;
  if Assigned(FOnPersonsFoundOnImage) then
    FOnPersonsFoundOnImage(Self, '', nil);
end;

procedure TImageViewer.SetText(Text: string);
begin          
  FActiveThreadId := GetGUID;
  FImageControl.SetText(Text);
  NotifyButtonsUpdate;
end;

procedure TImageViewer.StartPersonSelection;
begin
  FImageControl.StartPersonSelection;
end;

procedure TImageViewer.StopPersonSelection;
begin
  FImageControl.StopPersonSelection;
end;

procedure TImageViewer.RefreshFaceDetestionState;
begin

end;

procedure TImageViewer.UpdateAvatar(PersonID: Integer);
begin
  FImageControl.UpdateAvatar(PersonID);
end;

procedure TImageViewer.UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
begin
  if AnsiLowerCase(FItem.FileName) <> AnsiLowerCase(FileName) then
    Exit;

  FImageControl.UpdateFaces(FileName, Faces);
  if Assigned(FOnPersonsFoundOnImage) then
    FOnPersonsFoundOnImage(Self, FileName, Faces);
end;

procedure TImageViewer.ZoomIn;
begin
  FImageControl.ZoomIn;
end;

procedure TImageViewer.ZoomOut;
begin
  FImageControl.ZoomOut;
end;

end.
