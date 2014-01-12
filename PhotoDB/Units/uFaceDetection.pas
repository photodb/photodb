unit uFaceDetection;

interface

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Vcl.Graphics,

  OpenCV.Core,
  OpenCV.ImgProc,
  OpenCV.Utils,
  OpenCV.ObjDetect,
  OpenCV.Legacy,

  UnitDBDeclare,

  uRuntime,
  uMemory,
  u2DUtils,
  uSettings;

const
  CascadesDirectoryMask = 'Cascades';

type
  TFaceDetectionResultItem = class
  private
    FData: TClonableObject;
    procedure SetData(const Value: TClonableObject);
    function GetImageSize: TSize;
    function GetRect: TRect;
    procedure SetRect(const Value: TRect);
  public
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
    ImageWidth: Integer;
    ImageHeight: Integer;
    Page: Integer;
    function Copy: TFaceDetectionResultItem;
    constructor Create;
    destructor Destroy; override;
    procedure RotateLeft;
    procedure RotateRight;
    function EqualsTo(Item: TFaceDetectionResultItem): Boolean;
    function InTheSameArea80(RI: TFaceDetectionResultItem): Boolean;
    property Data: TClonableObject read FData write SetData;
    property ImageSize: TSize read GetImageSize;
    property Rect: TRect read GetRect write SetRect;
  end;

  TFaceDetectionResult = class
  private
    FList: TList;
    FPage: Integer;
    FSize: Int64;
    FDateModified: TDateTime;
    FPersistanceFileName: string;
    FTagEx: string;
    function GetItem(Index: Integer): TFaceDetectionResultItem;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Source: TFaceDetectionResult);
    procedure DeleteAt(I: Integer);
    procedure Remove(Item: TFaceDetectionResultItem);
    function AddFace(X, Y, Width, Height, ImageWidth, ImageHeight, Page: Integer): TFaceDetectionResultItem;
    procedure Add(Face: TFaceDetectionResultItem);
    procedure RotateLeft;
    procedure RotateRight;
    property Items[Index: Integer]: TFaceDetectionResultItem read GetItem; default;
    property Count: Integer read GetCount;
    property Page: Integer read FPage write FPage;
    property Size: Int64 read FSize write FSize;
    property DateModified: TDateTime read FDateModified write FDateModified;
    property PersistanceFileName: string read FPersistanceFileName write FPersistanceFileName;
    property TagEx: string read FTagEx write FTagEx;
  end;

  TCascadeData = class
    FileName: string;
    Cascade: PCvHaarClassifierCascade;
  end;

  TFaceDetectionManager = class
  private
    FSync: TCriticalSection;
    FCascades: TList;
    procedure Init;
    function GetIsActive: Boolean;
    function GetCascadeByFileName(FileName: string): PCvHaarClassifierCascade;
  public
    procedure FacesDetection(Bitmap: TBitmap; Page: Integer; var Faces: TFaceDetectionResult; Method: string); overload;
    procedure FacesDetection(Image: pIplImage; Page: Integer; var Faces: TFaceDetectionResult; Method: string); overload;
    constructor Create;
    destructor Destroy; override;
    property IsActive: Boolean read GetIsActive;
    property Cascades[FileName: string]: PCvHaarClassifierCascade read GetCascadeByFileName;
  end;

function FaceDetectionManager: TFaceDetectionManager;

function PxMultiply(P: TPoint; OriginalSize: TSize; Image: TBitmap): TPoint; overload;
function PxMultiply(P: TPoint; Image: TBitmap; OriginalSize: TSize): TPoint; overload;
function PxMultiply(P: TPoint; FromSize, ToSize: TSize): TPoint; overload;

implementation

var
  FManager: TFaceDetectionManager = nil;
  GlobalSync: TCriticalSection = nil;

function FaceDetectionManager: TFaceDetectionManager;
begin
  GlobalSync.Enter;
  try
    if FManager = nil then
      FManager := TFaceDetectionManager.Create;

    Result := FManager;
  finally
    GlobalSync.Leave;
  end;
end;

procedure InitCVLib;
begin
{  FCVDLLHandle := LoadLibrary('VCOpenCV.dll');
  if FCVDLLHandle <> 0 then
  begin
    CvLoad := GetProcAddress(FCVDLLHandle, 'cvLoad');
    CvCreateImage := GetProcAddress(FCVDLLHandle, 'cvCreateImage');
    CvRectangle := GetProcAddress(FCVDLLHandle, 'cvRectangle');
    CvCreateMemStorage := GetProcAddress(FCVDLLHandle, 'cvCreateMemStorage');
    CvLoadImage := GetProcAddress(FCVDLLHandle, 'cvLoadImage');
    CvShowImage := GetProcAddress(FCVDLLHandle, 'cvShowImage');
    CvNamedWindow := GetProcAddress(FCVDLLHandle, 'cvNamedWindow');
    CvHaarDetectObjects := GetProcAddress(FCVDLLHandle, 'cvHaarDetectObjects');
    CvGetSeqElem := GetProcAddress(FCVDLLHandle, 'cvGetSeqElem');
    CvClearMemStorage := GetProcAddress(FCVDLLHandle, 'cvClearMemStorage');
    CvSetImageROI := GetProcAddress(FCVDLLHandle, 'cvSetImageROI');
    CvResetImageROI := GetProcAddress(FCVDLLHandle, 'cvResetImageROI');
    CvCopy := GetProcAddress(FCVDLLHandle, 'cvCopy');
  end;  }
end;

{ TFaceDetectionResult }

procedure TFaceDetectionResult.Add(Face: TFaceDetectionResultItem);
begin
  FList.Add(Face);
end;

function TFaceDetectionResult.AddFace(X, Y, Width, Height, ImageWidth, ImageHeight, Page: Integer): TFaceDetectionResultItem;
begin
  Result := TFaceDetectionResultItem.Create;
  FList.Add(Result);
  Result.X := X;
  Result.Y := Y;
  Result.Width := Width;
  Result.Height := Height;
  Result.ImageWidth := ImageWidth;
  Result.ImageHeight := ImageHeight;
  Result.Page := Page;
end;

procedure TFaceDetectionResult.Assign(Source: TFaceDetectionResult);
var
  I: Integer;
begin
  Clear;

  FPage := Source.Page;
  FPersistanceFileName := Source.FPersistanceFileName;

  for I := 0 to Source.Count - 1 do
    FList.Add(Source[I].Copy);
end;

procedure TFaceDetectionResult.Clear;
begin
  FreeList(FList, False);
end;

constructor TFaceDetectionResult.Create;
begin
  FPersistanceFileName := '';
  FList := TList.Create;
end;

procedure TFaceDetectionResult.DeleteAt(I: Integer);
begin
  Items[I].Free;
  FList.Delete(I);
end;

destructor TFaceDetectionResult.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TFaceDetectionResult.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TFaceDetectionResult.GetItem(Index: Integer): TFaceDetectionResultItem;
begin
  Result := FList[Index];
end;

procedure TFaceDetectionResult.Remove(Item: TFaceDetectionResultItem);
begin
  FList.Remove(Item);
  F(Item);
end;

procedure TFaceDetectionResult.RotateLeft;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TFaceDetectionResultItem(FList[I]).RotateLeft;
end;

procedure TFaceDetectionResult.RotateRight;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TFaceDetectionResultItem(FList[I]).RotateRight;
end;

{ TFaceDetectionManager }

constructor TFaceDetectionManager.Create;
begin
  FSync := TCriticalSection.Create;
  FCascades := TList.Create;
  Init;
end;

destructor TFaceDetectionManager.Destroy;
begin
  F(FSync);
  FreeList(FCascades);
  inherited;
end;


procedure TFaceDetectionManager.Init;
begin
  InitCVLib;
end;

procedure TFaceDetectionManager.FacesDetection(Image: pIplImage; Page: Integer; var Faces: TFaceDetectionResult; Method: string);
var
  StorageType: Integer;
  Storage: PCvMemStorage;
	I, J: LongInt;
  ImSize, MaxSize: TCvSize;
  R: PCvRect;
  FacesSeq: PCvSeq;
  RctIn, RctOut: TRect;
  FCascadeFaces: PCvHaarClassifierCascade;
  GrayImage: pIplImage;
begin
  GrayImage := cvCreateImage(CvSize(Image.width, Image.height), image.depth, 1);
  try
    cvCvtColor(Image, GrayImage, CV_BGR2GRAY);

    FCascadeFaces := Cascades[Method];

    if FCascadeFaces = nil then
      Exit;

    FSync.Enter;
    try
      StorageType := 0;
      Storage := CvCreateMemStorage(StorageType);

        //* detect faces */
        ImSize := FCascadeFaces.Orig_window_size;
        MaxSize.width := Image.Width;
        MaxSize.height := Image.Height;

        FacesSeq := cvHaarDetectObjects(GrayImage, FCascadeFaces, Storage, 1.2, 2, CV_HAAR_DO_CANNY_PRUNING, ImSize, MaxSize);

        if (FacesSeq = nil) or (FacesSeq.total = 0) then
          Exit;

        for I := 0 to FacesSeq.total - 1 do
        begin
          R := PCvRect(CvGetSeqElem(FacesSeq, I));

          Faces.AddFace(R.X, R.Y, R.Width, R.Height, Image.Width, Image.Height, Page);
        end;

        for I := Faces.Count - 1 downto 0 do
        begin
          for J := Faces.Count - 1 downto 0 do
          if I <> J then
            begin
              RctIn := Rect(Faces[I].X, Faces[I].Y, Faces[I].X + Faces[I].Width, Faces[I].Y + Faces[I].Height);
              RctOut := Rect(Faces[J].X, Faces[J].Y, Faces[J].X + Faces[J].Width, Faces[J].Y + Faces[J].Height);
              if RectInRectPercent(RctOut, RctIn) > 25 then
              begin
                Faces.DeleteAt(I);
                Break;
              end;
            end;
        end;

        Faces.FPage := Page;
    finally
      FSync.Leave;
    end;
  finally
    cvReleaseImage(GrayImage);
  end;
end;

procedure TFaceDetectionManager.FacesDetection(Bitmap: TBitmap; Page: Integer; var Faces: TFaceDetectionResult; Method: string);
var
  Img: PIplImage;
  ImSize: TCvSize;
begin
  ImSize.Width := Bitmap.Width;
  ImSize.Height := Bitmap.Height;
  Img := CvCreateImage(ImSize, 8, 3);
  try
    Bitmap2IplImage(Img, Bitmap);
	
    FacesDetection(Img, Page, Faces, Method);
  finally
    cvResetImageROI(img);
  end;
end;

function TFaceDetectionManager.GetCascadeByFileName(
  FileName: string): PCvHaarClassifierCascade;
var
  I: Integer;
  FaceDetectionSeqFileName: string;
  CD: TCascadeData;
begin
  Result := nil;

  for I := 0 to FCascades.Count - 1 do
  begin
    if TCascadeData(FCascades[I]).FileName = FileName then
    begin
      Result := TCascadeData(FCascades[I]).Cascade;
      Exit;
    end;
  end;

  if HasOpenCV then
  begin
    FaceDetectionSeqFileName := ExtractFilePath(ParamStr(0)) + CascadesDirectoryMask + '\' + FileName;
    CD := TCascadeData.Create;
    FCascades.Add(CD);
    CD.FileName := FileName;
    CD.Cascade := CvLoad(PAnsiChar(AnsiString(FaceDetectionSeqFileName)), nil, nil, nil);
    Result := CD.Cascade;
  end;
end;

function TFaceDetectionManager.GetIsActive: Boolean;
begin
  Result := (HasOpenCV or FolderView) and AppSettings.Readbool('Options', 'ViewerFaceDetection', True);
end;

{ TFaceDetectionResultItem }

function TFaceDetectionResultItem.Copy: TFaceDetectionResultItem;
begin
  Result := TFaceDetectionResultItem.Create;
  Result.X := X;
  Result.Y := Y;
  Result.Width := Width;
  Result.Height := Height;
  Result.ImageWidth := ImageWidth;
  Result.ImageHeight := ImageHeight;
  Result.Page := Page;
  if Data <> nil then
    Result.Data := Data.Clone;
end;

constructor TFaceDetectionResultItem.Create;
begin
  FData := nil;
  X := 0;
  Y := 0;
  Width := 0;
  Height := 0;
end;

destructor TFaceDetectionResultItem.Destroy;
begin
  F(FData);
  inherited;
end;

function TFaceDetectionResultItem.EqualsTo(Item: TFaceDetectionResultItem): Boolean;
begin
  Result := (X = Item.X) and (Y = Item.Y) and (Width = Item.Width) and (Height = Item.Height) and (ImageWidth = Item.ImageWidth) and (ImageHeight = Item.ImageHeight) and (Page = Item.Page);
end;

function TFaceDetectionResultItem.GetImageSize: TSize;
begin
  Result.cx := ImageWidth;
  Result.cy := ImageHeight;
end;

procedure TFaceDetectionResultItem.RotateRight;
var 
  NW, NH, NImageW, NImageH, NX, NY: Integer;
begin
  NImageH := ImageWidth;
  NImageW := ImageHeight;

  NW := Height;
  NH := Width;

  NX := ImageHeight - Y - Height;
  NY := X;

  ImageWidth := NImageW;
  ImageHeight := NImageH;

  Width := NW;
  Height := NH;

  X := NX;
  Y := NY;
end;

procedure TFaceDetectionResultItem.RotateLeft;
var 
  NW, NH, NImageW, NImageH, NX, NY: Integer;
begin
  NImageH := ImageWidth;
  NImageW := ImageHeight;

  NW := Height;
  NH := Width;

  NX := Y;
  NY := ImageWidth - X - Width;
   
  ImageWidth := NImageW;
  ImageHeight := NImageH;

  Width := NW;
  Height := NH;

  X := NX;
  Y := NY;
end;

function TFaceDetectionResultItem.GetRect: TRect;
begin
  Result := System.Classes.Rect(X, Y, X + Width, Y + Height);
end;

function TFaceDetectionResultItem.InTheSameArea80(
  RI: TFaceDetectionResultItem): Boolean;
  var
    RA, RF: TRect;
  begin
    RA.Left   := Round(Self.X * 1000 / Self.ImageWidth);
    RA.Top    := Round(Self.Y * 1000 / Self.ImageHeight);
    RA.Right  := Round((Self.X + Self.Width)  * 1000 / Self.ImageWidth);
    RA.Bottom := Round((Self.Y + Self.Height) * 1000 / Self.ImageHeight);

    RF.Left   := Round(RI.X * 1000 / RI.ImageWidth);
    RF.Top    := Round(RI.Y * 1000 / RI.ImageHeight);
    RF.Right  := Round((RI.X + RI.Width)  * 1000 / RI.ImageWidth);
    RF.Bottom := Round((RI.Y + RI.Height) * 1000 / RI.ImageHeight);

    Result := RectIntersectWithRectPercent(RA, RF) > 80;
  end;

procedure TFaceDetectionResultItem.SetData(const Value: TClonableObject);
begin
  F(FData);
  FData := Value;
end;

procedure TFaceDetectionResultItem.SetRect(const Value: TRect);
begin
  X := Value.Left;
  Y := Value.Top;
  Width := Value.Right - Value.Left;
  Height := Value.Bottom - Value.Top;
end;

//functions

function PxMultiply(P: TPoint; FromSize, ToSize: TSize): TPoint; overload;
begin
  Result := P;
  if (FromSize.cx <> 0) and (FromSize.cy <> 0) then
  begin
    Result.X := Round(P.X * ToSize.Width / FromSize.cx);
    Result.Y := Round(P.Y * ToSize.Height / FromSize.cy);
  end;
end;

function PxMultiply(P: TPoint; OriginalSize: TSize; Image: TBitmap): TPoint; overload;
begin
  Result := P;
  if (OriginalSize.cx <> 0) and (OriginalSize.cy <> 0) then
  begin
    Result.X := Round(P.X * Image.Width / OriginalSize.cx);
    Result.Y := Round(P.Y * Image.Height / OriginalSize.cy);
  end;
end;

function PxMultiply(P: TPoint; Image: TBitmap; OriginalSize: TSize): TPoint; overload;
begin
  Result := P;
  if (Image.Width <> 0) and (Image.Height <> 0) then
  begin
    Result.X := Round(P.X * OriginalSize.cx / Image.Width);
    Result.Y := Round(P.Y * OriginalSize.cy / Image.Height);
  end;
end;

initialization
  GlobalSync := TCriticalSection.Create;

finalization
  F(FManager);
  F(GlobalSync);

end.
