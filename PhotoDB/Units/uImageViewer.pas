unit uImageViewer;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,

  Dmitry.Utils.System,

  UnitDBDeclare,

  uMemory,
  uIImageViewer,
  uDBPopupMenuInfo,
  uImageViewerControl,
  uFaceDetection,
  uImageViewerThread,
  uThreadForm,
  uGUIDUtils,
  uImageSource;

type
  TImageViewer = class(TInterfacedObject, IImageViewer)
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
    FFiles: TDBPopupMenuInfo;
    FIsWaiting: Boolean;
    FActiveThreadId: TGUID;
    FItem: TDBPopupMenuInfoRecord;
    procedure Resize;
    procedure LoadFile(FileInfo: TDBPopupMenuInfoRecord);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AttachTo(OwnerForm: TThreadForm; Control: TWinControl; X, Y: Integer);
    procedure LoadFiles(FileList: TDBPopupMenuInfo);
    procedure LoadPreviousFile;
    procedure LoadNextFile;
    procedure ResizeTo(Width, Height: Integer);
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
    procedure SetStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure SetAnimatedImage(Image: TGraphic; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure ZoomOut;
    procedure ZoomIn;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetLeft: Integer;
    function GetActiveThreadId: TGUID;
    function GetItem: TDBPopupMenuInfoRecord;
    function GetDisplayBitmap: TBitmap;
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
  FImageControl.Top := Y;
  FImageControl.Left := X;
  FImageControl.Parent := Control;

  inherited;
end;

constructor TImageViewer.Create;
begin
  FFiles := nil;
  FImageSource := nil;
  FCurrentFile := '';
  FIsWaiting := False;
  FActiveThreadId := GetEmptyGUID;
  FItem := TDBPopupMenuInfoRecord.Create;
end;

destructor TImageViewer.Destroy;
begin
  F(FItem);
  F(FFiles);
end;

function TImageViewer.GetActiveThreadId: TGUID;
begin
  Result := FActiveThreadId;
end;

function TImageViewer.GetDisplayBitmap: TBitmap;
begin
  Result := FImageControl.FullImage;
end;

function TImageViewer.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TImageViewer.GetItem: TDBPopupMenuInfoRecord;
begin
  Result := FItem;
end;

function TImageViewer.GetLeft: Integer;
begin
  Result := FLeft;
end;

function TImageViewer.GetTop: Integer;
begin
  Result := FTop;
end;

function TImageViewer.GetWidth: Integer;
begin
  Result := FWidth;
end;

procedure TImageViewer.LoadFile(FileInfo: TDBPopupMenuInfoRecord);
var
  Width, Height: Integer;
  Bitmap: TBitmap;
  DisplaySize: TSize;
begin
  FActiveThreadId := GetGUID;

  if FImageSource <> nil then
  begin
    Width := 0;
    Height := 0;
    Bitmap := TBitmap.Create;
    try
      if FImageSource.GetImage(FileInfo.FileName, Bitmap, Width, Height) then
      begin
        FImageControl.LoadStaticImage(FileInfo, Bitmap, Width, Height, FileInfo.Rotation, 1);
        Bitmap := nil;
      end;
    finally
      F(Bitmap);
    end;
  end;

  F(FItem);
  FItem := FileInfo.Copy;

  DisplaySize.cx := FWidth;
  DisplaySize.cy := FHeight;

  TImageViewerThread.Create(FOwnerForm, Self, FActiveThreadId, FileInfo, DisplaySize, True, -1);
end;

procedure TImageViewer.LoadFiles(FileList: TDBPopupMenuInfo);
var
  Position: Integer;
begin
  F(FFiles);
  FFiles := FileList;

  Position := FFiles.Position;
  if Position > -1 then
    LoadFile(FFiles[Position]);
end;

procedure TImageViewer.LoadNextFile;
begin
  FFiles.NextSelected;
  if FFiles.Position > -1 then
    LoadFile(FFiles[FFiles.Position]);
end;

procedure TImageViewer.LoadPreviousFile;
begin
  FFiles.PrevSelected;
  if FFiles.Position > -1 then
    LoadFile(FFiles[FFiles.Position]);
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

procedure TImageViewer.SetAnimatedImage(Image: TGraphic; RealWidth,
  RealHeight: Integer; Rotation: Integer; ImageScale: Double);
begin
  if FFiles.Position < 0 then
    Exit;
  if FFiles.Position > FFiles.Count - 1 then
    Exit;

  FImageControl.LoadAnimatedImage(FFiles[FFiles.Position], Image, RealWidth, RealHeight, Rotation, ImageScale);
end;

procedure TImageViewer.SetStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
begin
  if FFiles.Position < 0 then
    Exit;
  if FFiles.Position > FFiles.Count - 1 then
    Exit;

  FImageControl.LoadStaticImage(FFiles[FFiles.Position], Image, RealWidth, RealHeight, Rotation, ImageScale);
end;

procedure TImageViewer.UpdateFaces(FileName: string;
  Faces: TFaceDetectionResult);
begin
  //TODO:
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
