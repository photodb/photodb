unit uImageViewer;

interface

uses
  Controls,
  Messages,
  SysUtils,
  Graphics,
  UnitDBDeclare,
  uMemory,
  uIImageViewer,
  uDBPopupMenuInfo,
  uImageViewerControl,
  uImageSource;

type
  TImageViewer = class(TInterfacedObject, IImageViewer)
  private
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
    procedure Resize;
    procedure LoadFile(FileInfo: TDBPopupMenuInfoRecord);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AttachTo(Control: TWinControl; X, Y: Integer);
    procedure SetImageSource(Source: IImageSource);
    procedure LoadFiles(FileList: TDBPopupMenuInfo);
    procedure ResizeTo(Width, Height: Integer);
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetLeft: Integer;
  end;

implementation

{ TImageViewer }

procedure TImageViewer.AttachTo(Control: TWinControl; X, Y: Integer);
begin
  if Control = nil then
    raise EArgumentNilException.Create('Control is null!');
  FOwner := Control;
  FTop := Y;
  FLeft := X;

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
end;

destructor TImageViewer.Destroy;
begin
  F(FFiles);
end;

function TImageViewer.GetHeight: Integer;
begin
  Result := FHeight;
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
begin
  //
  if FImageSource <> nil then
  begin
    Width := 0;
    Height := 0;
    Bitmap := TBitmap.Create;
    try
      if FImageSource.GetImage(FileInfo.FileName, Bitmap, Width, Height) then
      begin
        FImageControl.FastLoadImage(Bitmap);
      end;
    finally
      F(Bitmap);
    end;
  end;
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

procedure TImageViewer.Resize;
begin
  //
end;

procedure TImageViewer.ResizeTo(Width, Height: Integer);
begin
  FWidth := Width;
  FHeight := Height;
  FImageControl.Width := Width;
  FImageControl.Height := Height;
  
  Resize;
end;

procedure TImageViewer.SetImageSource(Source: IImageSource);
begin
  FImageSource := Source;
end;

end.
