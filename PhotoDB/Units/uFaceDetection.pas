unit uFaceDetection;

interface

uses
  Windows, SysUtils, Classes, uMemory, Graphics, SyncObjs, u2DUtils;

type
  CvSize = record
    Width: longint;
    Height: longint;
  end;

  CvRect = record
    X: Longint;
    Y: Longint;
    Width: Longint;
    Height: Longint;
  end;

  PCvRect = ^CvRect;

  HaarFutureStruct = record
    R: CvRect;
    Weight: Single;
  end;

  CvHaarFeature = record
    Tilted: Longint;
    Rect1: HaarFutureStruct;
    Rect2: HaarFutureStruct;
    Rect3: HaarFutureStruct;
  end;

  PCvHaarFeature = ^CvHaarFeature;

  CvHaarClassifier = record
    Count: Longint;
    Haar_feature: PCvHaarFeature;
    Threshold: PSingle;
    Left: Plongint;
    Right: PLongint;
    Alpha: PSingle;
  end;

  PCvHaarClassifier = ^CvHaarClassifier;

  CvHaarStageClassifier = record
    Count: Longint;
    Threshold: Single;
    Classifier: PCvHaarClassifier;
    Next: Longint;
    Child: Longint;
    Parent: Longint;
  end;

  PCvHaarStageClassifier = ^CvHaarStageClassifier;

  /// //////////////////////////////////////
  // Здесь обратить внимание, непонятен тип
  CvHidHaarClassifierCascade = record

  end;

  PCvHidHaarClassifierCascade = ^CvHidHaarClassifierCascade;
  /// //////////////////////////////////////

  CvHaarClassifierCascade = record
    Flags: Longint;
    Count: Longint;
    Orig_window_size: CvSize;
    Real_window_size: CvSize;
    Scale: Double;
    Stage_classifier: PCvHaarStageClassifier;
    Hid_cascade: PCvHidHaarClassifierCascade;
  end;

  PCvHaarClassifierCascade = ^CvHaarClassifierCascade;

  PCvMemBlock = ^CvMemBlock;

  CvMemBlock = record
    Prev: PCvMemBlock;
    Next: PCvMemBlock;
  end;

  PCvMemStorage = ^CvMemStorage;

  CvMemStorage = record
    Signature: Longint;
    Bottom: PCvMemBlock; // * First allocated block.                   */
    Top: PCvMemBlock; // * Current memory block - top of the stack. */
    Parent: PCvMemStorage; // * We get new blocks from parent as needed. */
    Block_size: Longint; // * Block size.                              */
    Free_space: Longint; // * Remaining free space in current block.   */
  end;

  PIplROI = ^IplROI;

  IplROI = record
    Coi: Longint; // * 0 - no COI (all channels are selected), 1 - 0th channel is selected ...*/
    XOffset: Longint;
    YOffset: Longint;
    Width: Longint;
    Height: Longint;
  end;

  PIplTileInfo = ^IplTileInfo;

  IplTileInfo = record

  end;

  PIplImage = ^IplImage;

  T4ByteArray = array [0 .. 3] of Byte;

  IplImage = record
    NSize: Longint; // * sizeof(IplImage) */
    ID: Longint; // * version (=0)*/
    NChannels: Longint; // * Most of OpenCV functions support 1,2,3 or 4 channels */
    AlphaChannel: Longint; // * Ignored by OpenCV */
    Depth: Longint; // * Pixel depth in bits: IPL_DEPTH_8U, IPL_DEPTH_8S, IPL_DEPTH_16S,
    // IPL_DEPTH_32S, IPL_DEPTH_32F and IPL_DEPTH_64F are supported.  */
    ColorModel: T4ByteArray; // * Ignored by OpenCV */
    ChannelSeq: T4ByteArray; // * ditto */
    DataOrder: Longint; // * 0 - interleaved color channels, 1 - separate color channels.
    // cvCreateImage can only create interleaved images */
    Origin: Longint; // * 0 - top-left origin,
    // 1 - bottom-left origin (Windows bitmaps style).  */
    Align: Longint; // * Alignment of image rows (4 or 8).
    // OpenCV ignores it and uses widthStep instead.    */
    Width: Longint; // * Image width in pixels.                           */
    Height: Longint; // * Image height in pixels.                          */
    Roi: PIplROI; // * Image ROI. If NULL, the whole image is selected. */
    MaskROI: PIplImage; // * Must be NULL. */
    ImageId: Pointer; // * "           " */
    TileInfo: PIplTileInfo; // * "           " */
    ImageSize: Longint; // * Image data size in bytes
    // (==image->height*image->widthStep
    // in case of interleaved data)*/
    ImageData: PChar; // * Pointer to aligned image data.         */
    WidthStep: Longint; // * Size of aligned image row in bytes.    */
    BorderMode: array [0 .. 3] of Longint; // * Ignored by OpenCV.                     */
    BorderConst: array [0 .. 3] of Longint; // * Ditto.                                 */
    ImageDataOrigin: PChar; // * Pointer to very origin of image data
    // (not necessarily aligned) -
    // needed for correct deallocation */
  end;

  Schar = -128 .. 127;
  Pschar = ^Schar;

  PNode_type = ^CvSeq;

  PCvSeqBlock = ^CvSeqBlock;

  CvSeqBlock = record
    Prev: PCvSeqBlock; // * Previous sequence block.                   */
    Next: PCvSeqBlock; // * Next sequence block.                       */
    Start_index: Longint; // * Index of the first element in the block +  */
    // * sequence->first->start_index.              */
    Count: Longint; // * Number of elements in the block.           */
    Data: Pschar; // * Pointer to the first element of the block. */
  end;

  PCvSeq = ^CvSeq;

  CvSeq = record
    Flags: Longint; // * Miscellaneous flags.     */      \
    Header_size: Longint; // * Size of sequence header. */      \
    H_prev: Pnode_type; // * Previous sequence.       */      \
    H_next: Pnode_type; // * Next sequence.           */      \
    V_prev: Pnode_type; // * 2nd previous sequence.   */      \
    V_next: Pnode_type; // * 2nd next sequence.       */
    Total: Longint; // * Total number of elements.            */  \
    Elem_size: Longint; // * Size of sequence element in bytes.   */  \
    Block_max: Pschar; // * Maximal bound of the last block.     */  \
    Ptr: Pschar; // * Current write pointer.               */  \
    Delta_elems: Longint; // * Grow seq this many at a time.        */  \
    Storage: PCvMemStorage; // * Where the seq is stored.             */  \
    Free_blocks: PCvSeqBlock; // * Free blocks list.                    */  \
    First: PCvSeqBlock; // * Pointer to the first sequence block. */

  end;

  CvPoint = record
    X: Longint;
    Y: Longint;
  end;

  CvScalar = record
    B: Double;
    G: Double;
    R: Double;
    Depth: Double;
  end;

  PPChar = ^PChar;
  CvArr = Pointer;
  PCvArr = ^CvArr;

const
  CascadesDirectoryMask = 'Cascades';

type
  TClonableObject = class(TObject)
    function Clone: TClonableObject; virtual; abstract;
  end;

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
    procedure RecalculateNewImageSize(NewSize: TSize);
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
    property Items[Index: Integer]: TFaceDetectionResultItem read GetItem; default;
    property Count: Integer read GetCount;
    property Page: Integer read FPage write FPage;
    property Size: Int64 read FSize write FSize;
    property DateModified: TDateTime read FDateModified write FDateModified;
    property PersistanceFileName: string read FPersistanceFileName write FPersistanceFileName;
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
    procedure FacesDetection(Bitmap: TBitmap; Page: Integer; var Faces: TFaceDetectionResult; Method: string);
    constructor Create;
    destructor Destroy; override;
    property IsActive: Boolean read GetIsActive;
    property Cascades[FileName: string]: PCvHaarClassifierCascade read GetCascadeByFileName;
  end;

type
  TCvLoad = function(Filename: PAnsiChar; Memstorage: PCvMemStorage; name: PChar; Real_name: PAnsiChar): Pointer; cdecl;
  TCvCreateImage = function(Size: CvSize; Depth: Longint; Channels: Longint): PIplImage; cdecl;
  TCvRectangle = procedure(Img: Pointer; Pt1: CvPoint; Pt2: CvPoint; Color: CvScalar; Thickness: Longint; Line_type: Longint; Shift: Longint); cdecl;
  TCvCreateMemStorage = function(Block_size: Longint): PCvMemStorage; cdecl;
  TCvLoadImage = function(Filename: PAnsiChar; Iscolor: Longint): PIplImage; cdecl;
  TCvShowImage = procedure(name: PAnsiChar; Image: PIplImage); cdecl;
  TCvNamedWindow = function(name: PAnsiChar; Flags: Longint): Longint; cdecl;
  TCvHaarDetectObjects = function(Img: PCvArr; Cascade: PCvHaarClassifierCascade; Storage: PCvMemStorage;
    Scale_factor: Double; Min_neighbors: Longint; Flags: Longint; Min_size: CvSize): PCvSeq; cdecl;
  TCvGetSeqElem = function(Seq: PCvSeq; index: Longint): Pschar; cdecl;
  TCvClearMemStorage = procedure(Storage: PCvMemStorage); cdecl;
  TCvSetImageROI = procedure(Image: PIplImage; Rect: CvRect); cdecl;
  TCvResetImageROI = procedure(Image: PIplImage); cdecl;
  TCvCopy = procedure(Src: PCvArr; Dst: PCvArr; Mask: PCvArr); cdecl;

var
  CvLoad: TCvLoad;
  CvCreateImage: TCvCreateImage;
  CvRectangle: TCvRectangle;
  CvCreateMemStorage: TCvCreateMemStorage;
  CvLoadImage: TCvLoadImage;
  CvShowImage: TCvShowImage;
  CvNamedWindow: TCvNamedWindow;
  CvHaarDetectObjects: TCvHaarDetectObjects;
  CvGetSeqElem: TCvGetSeqElem;
  CvClearMemStorage: TCvClearMemStorage;
  CvSetImageROI: TCvSetImageROI;
  CvResetImageROI: TCvResetImageROI;
  CvCopy: TCvCopy;
  FCVDLLHandle: THandle = 0;

function FaceDetectionManager: TFaceDetectionManager;

implementation

var
  FManager: TFaceDetectionManager = nil;

function FaceDetectionManager: TFaceDetectionManager;
begin
  if FManager = nil then
    FManager := TFaceDetectionManager.Create;

  Result := FManager;
end;

procedure InitCVLib;
begin
  FCVDLLHandle := LoadLibrary('VCOpenCV.dll');
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
  end;
end;

{-----------------------------------------------------------------------------
  Procedure:  IplImage2Bitmap
  Author:     De Sanctis
  Date:       23-set-2005
  Arguments:  iplImg: PIplImage; bitmap: TBitmap
  Description: convert a IplImage to a Windows bitmap
  ----------------------------------------------------------------------------- }
procedure IplImage2Bitmap(IplImg: PIplImage; Bitmap: TBitmap);
const
 IPL_ORIGIN_TL = 0;
 IPL_ORIGIN_BL = 1;

var
  I: INTEGER;
  J: INTEGER;
  Offset: Longint;
  DataByte: PByteArray;
  RowIn: PByteArray;

  function ToString(A: T4ByteArray): string;
  var
    I: Integer;
  begin
    SetLength(Result, 4);
    for I := 0 to 3 do
      Result[I + 1] := Char(A[I]);

    Result := Trim(Result);
  end;

begin
  Assert((iplImg.Depth = 8) and (iplImg.NChannels = 3), 'IplImage2Bitmap: Not a 24 bit color iplImage!');

  Bitmap.Height := IplImg.Height;
  Bitmap.Width := IplImg.Width;
  for J := 0 to Bitmap.Height - 1 do
  begin
    // origin BL = Bottom-Left
    if (Iplimg.Origin = IPL_ORIGIN_BL) then
      RowIn := Bitmap.Scanline[Bitmap.Height - 1 - J]
    else
      RowIn := Bitmap.Scanline[J];

    Offset := Longint(Iplimg.ImageData) + IplImg.WidthStep * J;
    DataByte := Pbytearray(Offset);

    if (ToString(IplImg.ChannelSeq) = 'BGR') then
    begin
      { direct copy of the iplImage row bytes to bitmap row }
      CopyMemory(Rowin, DataByte, IplImg.WidthStep);
    end else if (ToString(IplImg.ChannelSeq) = 'GRAY') then
    begin
      for I := 0 to Bitmap.Width - 1 do
      begin
        RowIn[3 * I] := Databyte[I];
        RowIn[3 * I + 1] := Databyte[I];
        RowIn[3 * I + 2] := Databyte[I];
      end
    end else
    begin
      for I := 0 to 3 * Bitmap.Width - 1 do
      begin
        RowIn[I] := Databyte[I + 2];
        RowIn[I + 1] := Databyte[I + 1];
        RowIn[I + 2] := Databyte[I];
      end;
    end;
  end;
end; { IplImage2Bitmap }

{-----------------------------------------------------------------------------
  Procedure:  IplImage2Bitmap
  Author:     De Sanctis
  Date:       23-set-2005
  Arguments:  iplImg: PIplImage; bitmap: TBitmap
  Description: convert a IplImage to a Windows bitmap
  ----------------------------------------------------------------------------- }
procedure Bitmap2IplImage(IplImg: PIplImage; Bitmap: TBitmap);
const
 IPL_ORIGIN_TL = 0;
 IPL_ORIGIN_BL = 1;

var
  I: INTEGER;
  J: INTEGER;
  Offset: Longint;
  DataByte: PByteArray;
  RowIn: PByteArray;

  function ToString(A: T4ByteArray): string;
  var
    I: Integer;
  begin
    SetLength(Result, 4);
    for I := 0 to 3 do
      Result[I + 1] := Char(A[I]);

    Result := Trim(Result);
  end;

begin
  Assert((iplImg.Depth = 8) and (iplImg.NChannels = 3), 'IplImage2Bitmap: Not a 24 bit color iplImage!');

  Bitmap.Height := IplImg.Height;
  Bitmap.Width := IplImg.Width;
  for J := 0 to Bitmap.Height - 1 do
  begin
    // origin BL = Bottom-Left
    if (Iplimg.Origin = IPL_ORIGIN_BL) then
      RowIn := Bitmap.Scanline[Bitmap.Height - 1 - J]
    else
      RowIn := Bitmap.Scanline[J];

    Offset := Longint(Iplimg.ImageData) + IplImg.WidthStep * J;
    DataByte := Pbytearray(Offset);

    if (ToString(IplImg.ChannelSeq) = 'BGR') then
    begin
      { direct copy of the iplImage row bytes to bitmap row }
      CopyMemory(DataByte, Rowin, IplImg.WidthStep);
    end else if (ToString(IplImg.ChannelSeq) = 'GRAY') then
    begin
      for I := 0 to Bitmap.Width - 1 do
        Databyte[I] := (RowIn[3 * I] * 77  + RowIn[3 * I + 1] * 151 + RowIn[3 * I + 2] * 28) shr 8;
    end else
    begin
      for I := 0 to 3 * Bitmap.Width - 1 do
      begin
        Databyte[I + 2] := RowIn[I];
        Databyte[I + 1] := RowIn[I + 1];
        Databyte[I] := RowIn[I + 2];
      end;
    end;
  end;
end; { IplImage2Bitmap }

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

procedure TFaceDetectionManager.FacesDetection(Bitmap: TBitmap; Page: Integer; var Faces: TFaceDetectionResult; Method: string);
var
  StorageType: Integer;
  Img: PIplImage;
  Storage: PCvMemStorage;
	I, J: LongInt;
  ImSize: CvSize;
  R: PCvRect;
  FacesSeq: PCvSeq;
  RctIn, RctOut: TRect;
  FCascadeFaces: PCvHaarClassifierCascade;
begin
  FCascadeFaces := Cascades[Method];

  if FCascadeFaces = nil then
    Exit;

  FSync.Enter;
  try
    StorageType := 0;
    Storage := CvCreateMemStorage(StorageType);

    ImSize.Width := Bitmap.Width;
    ImSize.Height := Bitmap.Height;
    Img := CvCreateImage(ImSize, 8, 3);
    try
      Bitmap2IplImage(Img, Bitmap);

      //* detect faces */
      ImSize := FCascadeFaces.Orig_window_size;

      FacesSeq := cvHaarDetectObjects(PCvArr(img), FCascadeFaces, Storage, 1.2, 2, 1, ImSize);

      if (FacesSeq = nil) or (FacesSeq.total = 0) then
        Exit;

      for I := 0 to FacesSeq.total - 1 do
      begin
        R := PCvRect(CvGetSeqElem(FacesSeq, I));

        Faces.AddFace(R.X, R.Y, R.Width, R.Height, Bitmap.Width, Bitmap.Height, Page);
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
      cvResetImageROI(img);
    end;
  finally
    FSync.Leave;
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

  if FCVDLLHandle > 0 then
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
  Result := FCVDLLHandle <> 0;
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

function TFaceDetectionResultItem.GetImageSize: TSize;
begin
  Result.cx := ImageWidth;
  Result.cy := ImageHeight;
end;

procedure TFaceDetectionResultItem.RecalculateNewImageSize(NewSize: TSize);
var
  MX, MY: Double;
begin
  if (ImageWidth <> 0) and (ImageHeight <> 0) then
  begin
    MX := NewSize.cx / ImageWidth;
    MY := NewSize.cy / ImageHeight;
    X := Round(X * MX);
    Y := Round(Y * MY);
    Width := Round(Width * MX);
    Height := Round(Height * MY);
    ImageWidth := NewSize.cx;
    ImageHeight := NewSize.cy;
  end;
end;

function TFaceDetectionResultItem.GetRect: TRect;
begin
  Result := Classes.Rect(X, Y, X + Width, Y + Height);
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

initialization

finalization
  F(FManager);

end.
