unit uFaceRecognizer;

interface

uses
  Winapi.Windows,
  Generics.Collections,
  System.SysUtils,
  System.SyncObjs,
  Vcl.Graphics,

  Core.types_c,
  core_c,
  legacy,

  uMemory;

type
  IFaceRecognizer = Interface
    ['{4084C125-FB9B-4DED-9732-EE6B7B90D0FA}']
    function SaveState(Path: string): Boolean;
    function LoadState(Path: string): Boolean;

    procedure Train;
    //simple add face to detection collection
    function AddNewFace(Face: TBitmap; PersonId: Integer): Boolean; overload;
    function AddNewFace(Face: pIplImage; PersonId: Integer): Boolean; overload;
    //resolve person by image
    function DetectFace(Face: TBitmap): Integer; overload;
    function DetectFace(Face: pIplImage): Integer; overload;

    //call-back from user
    //User updated face person, so we could train our system to match user's decision
    function ChangePerson(Face: TBitmap; DetectedPersonId: Integer; RealPersonId: Integer): Boolean;
  end;

  TPersonFace = class
  private
    FFaceImage: pIplImage;
    FSuccessCount: Integer;
    FFailedCound: Integer;
  public
    destructor Destroy; override;
    constructor Create(FaceImage: pIplImage);
    property Face: pIplImage read FFaceImage;
  end;

  TPersonFaces = class
  private
    FPersonId: Integer;
    FFaces: TList<TPersonFace>;
    function GetFacesCount: Integer;
    function GetFace(Index: Integer): TPersonFace;
  public
    constructor Create(PersonId: Integer);
    destructor Destroy; override;
    function AddFace(Image: pIplImage): TPersonFace;
    property Id: Integer read FPersonId;
    property FacesCount: Integer read GetFacesCount;
    property Faces[Index: Integer]: TPersonFace read GetFace;
  end;

  TFaceEigenRecognizer = class(TInterfacedObject, IFaceRecognizer)
  private
    FSync: TCriticalSection;
    FSize: TCvSize;
    FMaxFacesPerPerson: Integer;
    FPersons: TList<TPersonFaces>;

    FTrainedFacesCount: Integer;
    FTrainedFaces: array of Integer;
    FIsTrained: Boolean;
    FEigImg: array of pIplImage;
    FMeanImg: pIplImage; // Average face (float point)
    FCoeffs: array of array of Float;
    FEigenVals: pCvMat;
    procedure ClearTrainingMemory;
    function FindFace(FaceImage: pIplImage): TPersonFaces;
    function FindPerson(PersonId: Integer): TPersonFaces;
    function AddPerson(FaceImage: pIplImage; PersonId: Integer): TPersonFaces;
  public
    constructor Create(Width, Height: Integer; MaxFacesPerPerson: Integer);
    destructor Destroy; override;

    function SaveState(Path: string): Boolean;
    function LoadState(Path: string): Boolean;

    procedure Train;

    function AddNewFace(Face: TBitmap; PersonId: Integer): Boolean; overload;
    function AddNewFace(Face: pIplImage; PersonId: Integer): Boolean; overload;
    function DetectFace(Face: TBitmap): Integer; overload;
    function DetectFace(Face: pIplImage): Integer; overload;

    function ChangePerson(Face: TBitmap; DetectedPersonId: Integer; RealPersonId: Integer): Boolean;
  end;

implementation

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

  function ToString(A: TA4CVChar): string;
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

{ TPersonFace }

constructor TPersonFace.Create(FaceImage: pIplImage);
begin
  FFaceImage := FaceImage;
  FSuccessCount := 0;
  FFailedCound := 0;
end;

destructor TPersonFace.Destroy;
begin
  cvReleaseImage(FFaceImage);
  inherited;
end;

{ TPersonFaces }

function TPersonFaces.AddFace(Image: pIplImage): TPersonFace;
begin
  Result := TPersonFace.Create(Image);
  FFaces.Add(Result);
end;

constructor TPersonFaces.Create(PersonId: Integer);
begin
  FPersonId := PersonId;
  FFaces := TList<TPersonFace>.Create;
end;

destructor TPersonFaces.Destroy;
begin
  FreeList(FFaces);
  inherited;
end;

function TPersonFaces.GetFace(Index: Integer): TPersonFace;
begin
  Result := FFaces[Index];
end;

function TPersonFaces.GetFacesCount: Integer;
begin
  Result := FFaces.Count;
end;

{ TFaceDetector }

constructor TFaceEigenRecognizer.Create(Width, Height: Integer; MaxFacesPerPerson: Integer);
begin
  FSize.width := Width;
  FSize.height := Height;
  FMaxFacesPerPerson := MaxFacesPerPerson;
  FSync := TCriticalSection.Create;
  FPersons := TList<TPersonFaces>.Create;
  FTrainedFacesCount := 0;
  FIsTrained := False;

  SetLength(FEigImg, 0);
  SetLength(FTrainedFaces, 0);
  FMeanImg := nil; // Average face (float point)
end;

destructor TFaceEigenRecognizer.Destroy;
begin
  ClearTrainingMemory;
  FreeList(FPersons);
  F(FSync);
  inherited;
end;

function TFaceEigenRecognizer.AddNewFace(Face: TBitmap; PersonId: Integer): Boolean;
var
  CvFace, CvSampleFace: pIplImage;
begin
  CvFace :=  cvCreateImage(FSize, IPL_DEPTH_8U, 3);

  CvSampleFace := cvCreateImage(FSize, IPL_DEPTH_8U, 1);

  cvSplit(
    CvFace,
    CvSampleFace,
    nil,
    nil,
    nil);

  Result := AddNewFace(CvSampleFace, PersonId);

  cvReleaseImage(CvFace);
end;

function TFaceEigenRecognizer.AddNewFace(Face: pIplImage; PersonId: Integer): Boolean;
var
  Person: TPersonFaces;
begin
  FSync.Enter;
  try
    FIsTrained := False;

    Person := FindPerson(PersonId);
    if Person = nil then
      Person := AddPerson(Face, PersonId)
    else
      Person.AddFace(Face);

    Result := True;
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.AddPerson(FaceImage: pIplImage; PersonId: Integer): TPersonFaces;
begin
  Result := TPersonFaces.Create(PersonId);
  Result.AddFace(FaceImage);
  FPersons.Add(Result);
end;

function TFaceEigenRecognizer.FindPerson(PersonId: Integer): TPersonFaces;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPersons.Count - 1 do
    if FPersons[I].Id = PersonId then
      Exit(FPersons[I]);
end;


function TFaceEigenRecognizer.DetectFace(Face: pIplImage): Integer;
var
  Person: TPersonFaces;
begin
  Result := 0;

  FSync.Enter;
  try
    Person := FindFace(Face);

    if Person <> nil then
      Exit(Person.Id);
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.DetectFace(Face: TBitmap): Integer;
var
  CvFaceImage, CvTestImage: pIplImage;
begin
  CvFaceImage := cvCreateImage(FSize, IPL_DEPTH_8U, 3);
  Bitmap2IplImage(CvFaceImage, Face);

  CvTestImage := cvCreateImage(FSize, IPL_DEPTH_8U, 1);
  cvSplit(CvFaceImage, CvTestImage, nil, nil, nil);

  Result := DetectFace(CvTestImage);
end;

function TFaceEigenRecognizer.ChangePerson(Face: TBitmap; DetectedPersonId, RealPersonId: Integer): Boolean;
begin
  FSync.Enter;
  try
    Result := False;
  finally
    FSync.Leave;
  end;
end;

procedure TFaceEigenRecognizer.ClearTrainingMemory;
var
  I: Integer;
  Image: pIplImage;
begin
  if Assigned(FMeanImg) then
    cvReleaseImage(FMeanImg);

  for I := 0 to Length(FEigImg) - 1 do
  begin
    Image := FEigImg[I];
    cvReleaseImage(Image);
  end;
  SetLength(FEigImg, 0);
  SetLength(FTrainedFaces, 0);
end;

function TFaceEigenRecognizer.LoadState(Path: string): Boolean;
begin
  FSync.Enter;
  try
    raise Exception.Create('Not Implemented');
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.SaveState(Path: string): Boolean;
begin
  FSync.Enter;
  try
    raise Exception.Create('Not Implemented');
  finally
    FSync.Leave;
  end;
end;

procedure TFaceEigenRecognizer.Train;
var
  I, J: Integer;
  Tc: TCvTermCriteria;
  NEigens: Integer;
  SamplesArray: array of pIplImage;
  Person: TPersonFaces;
  SamplesCount: Integer;
begin
  ClearTrainingMemory;

  SetLength(SamplesArray, 0);
  for I := 0 to FPersons.Count - 1 do
  begin
    Person := FPersons[I];
    for J := 0 to Person.FacesCount - 1 do
    begin
      SetLength(SamplesArray, Length(SamplesArray) + 1);
      SamplesArray[Length(SamplesArray) - 1] := Person.Faces[J].Face;

      SetLength(FTrainedFaces, Length(FTrainedFaces) + 1);
      FTrainedFaces[Length(FTrainedFaces) - 1] := Person.Id;
    end;
  end;
  SamplesCount := Length(SamplesArray);

  FMeanImg := cvCreateImage(FSize, IPL_DEPTH_32F, 1);

  // -----------------------------------
  // Set criteria to terminate process
  // -----------------------------------
  Tc.cType := CV_TERMCRIT_NUMBER or CV_TERMCRIT_EPS;

  // TODO: chekc different parameters
  Tc.max_iter := 100;
  Tc.epsilon  := 0.001;

  // -----------------------------------------------------
  // Cound of basis vectors = #images - 1
  // -----------------------------------------------------
  NEigens := SamplesCount - 1;

  // This is a basis
  SetLength(FEigImg, SamplesCount);
  FEigenVals := cvCreateMat(1, NEigens, IPL_DEPTH_32F);

  // Get memory for basis
  for I := 0 to SamplesCount - 1 do
    FEigImg[I] := cvCreateImage(FSize, IPL_DEPTH_32F, 1);

  // Calculate basis
  cvCalcEigenObjects(
    SamplesCount,
    SamplesArray,
    FEigImg,
    CV_EIGOBJ_NO_CALLBACK,
    0,
    nil,
    @Tc,
    FMeanImg,
    pFloat(FEigenVals.Data));

  // -----------------------------------------------------------
  // Разложение тестируемого изображения по полученному базису
  // -----------------------------------------------------------
  SetLength(FCoeffs, SamplesCount);
  for I := 0 to SamplesCount - 1 do
  begin
    SetLength(FCoeffs[I], nEigens);

    cvEigenDecomposite(
      SamplesArray[I],
      NEigens,
      @FEigImg[0],
      CV_EIGOBJ_NO_CALLBACK,
      nil,
      FMeanImg,
      @FCoeffs[I][0]);
  end;

  SetLength(SamplesArray, 0);

  FTrainedFacesCount := SamplesCount;
  FIsTrained := True;
end;

function TFaceEigenRecognizer.FindFace(FaceImage: pIplImage): TPersonFaces;
var
  ProjectedTestFace: array Of Float;
  I, NEigens, ITrain, INearest, PersonId: Integer;
  DI, DistSq, LeastDistSq: Double;
begin
  Result := nil;

  if not FIsTrained then
    Train;

  // -----------------------------------------------------------
  // Load test image
  // -----------------------------------------------------------
  SetLength(
    ProjectedTestFace,
    FTrainedFacesCount);

  cvEigenDecomposite(
    FaceImage,
    FTrainedFacesCount,
    FEigImg,
    CV_EIGOBJ_NO_CALLBACK,
    nil,
    FMeanImg,
    @ProjectedTestFace[0]);

  // -----------------------------------------------------------
  LeastDistSq := DBL_MAX;
  ITrain      := 0;
  INearest    := -1;

  NEigens := FTrainedFacesCount - 1;
  for ITrain := 0 to FTrainedFacesCount - 1 do
  begin
    DistSq := 0;
    for I  := 0 to NEigens - 1 do
    begin
      DI    := ProjectedTestFace[I] - FCoeffs[ITrain][I];
      DistSq := DistSq + DI * DI / pFloat(FEigenVals.Data)[I];
    end;
    if DistSq < LeastDistSq then
    begin
      leastDistSq := DistSq;
      INearest    := ITrain;
    end;
  end;

  if INearest > 0 then
  begin
    PersonId := FTrainedFaces[INearest];
    for I := 0 to FPersons.Count - 1 do
      if FPersons[I].Id = PersonId then
        Exit(FPersons[I]);
  end;
end;

end.
