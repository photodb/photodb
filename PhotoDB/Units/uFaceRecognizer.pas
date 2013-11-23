unit uFaceRecognizer;

interface

uses
  Winapi.Windows,
  Generics.Defaults,
  Generics.Collections,
  System.Math,
  System.SysUtils,
  System.SyncObjs,
  Vcl.Graphics,

  OpenCV.Utils,

  highgui_c,
  Core.types_c,
  imgproc.types_c,
  imgproc_c,
  core_c,
  legacy,

  uMemory;

type
  IFaceRecognizer = Interface
    ['{4084C125-FB9B-4DED-9732-EE6B7B90D0FA}']
    function SaveState(Path: string): Boolean;
    function LoadState(Path: string): Boolean;

    function Train: Boolean;
    //simple add face to detection collection
    function HasPerson(PersonId: Integer): Boolean;
    function TrainFace(Face: TBitmap; PersonId: Integer; Quality: Byte): Boolean; overload;
    function TrainFace(Face: pIplImage; PersonId: Integer; Quality: Byte): Boolean; overload;
    //resolve person by image
    function DetectFace(Face: TBitmap; Quality: Byte): Integer; overload;
    function DetectFace(Face: pIplImage; Quality: Byte): Integer; overload;
  end;

  TPersonFaces = class;

  TPersonFace = class
  private
    FFaceImage: pIplImage;
    FSuccessCount: Integer;
    FFailedCound: Integer;
    FFaces: TPersonFaces;
    FQuality: Byte;
    function GetScore: Double;
  public
    destructor Destroy; override;
    constructor Create(FaceImage: pIplImage; Quality: Byte; Faces: TPersonFaces);
    procedure IncSuccess;
    procedure IncFail;
    property Face: pIplImage read FFaceImage;
    property Person: TPersonFaces read FFaces;
    property Quality: Byte read FQuality;
    property Score: Double read GetScore;
  end;

  TPersonFaces = class
  private
    FPersonId: Integer;
    FFaces: TList<TPersonFace>;
    FCapacity: Integer;
    function GetFacesCount: Integer;
    function GetFace(Index: Integer): TPersonFace;
    function GetMinQuality: Byte;
  public
    constructor Create(PersonId: Integer; Capacity: Integer);
    destructor Destroy; override;
    function AddFace(Image: pIplImage; Quality: Byte): TPersonFace;
    function AddNotFoundFace(Image: pIplImage; Quality: Byte): TPersonFace;
    procedure CleanUp;
    procedure IncFail;
    property Id: Integer read FPersonId;
    property FacesCount: Integer read GetFacesCount;
    property Faces[Index: Integer]: TPersonFace read GetFace;
    property MinQuality: Byte read GetMinQuality;
  end;

  TFaceEigenRecognizer = class(TInterfacedObject, IFaceRecognizer)
  private
    FSync: TCriticalSection;
    FSize: TCvSize;
    FMaxFacesPerPerson: Integer;
    FPersons: TList<TPersonFaces>;

    FTrainedFacesCount: Integer;
    FTrainedFaces: array of TPersonFace;
    FIsTrained: Boolean;
    FEigImg: array of pIplImage;
    FMeanImg: pIplImage; // Average face (float point)
    FCoeffs: array of array of Float;
    FEigenVals: pCvMat;
    procedure ClearTrainingMemory;
    function FindFace(FaceImage: pIplImage): TPersonFace;
    function FindPerson(PersonId: Integer): TPersonFaces;
    function AddPerson(FaceImage: pIplImage; Quality: Byte; PersonId: Integer): TPersonFaces;
  public
    constructor Create(Width, Height: Integer; MaxFacesPerPerson: Integer);
    destructor Destroy; override;

    function SaveState(Path: string): Boolean;
    function LoadState(Path: string): Boolean;

    function Train: Boolean;

    function HasPerson(PersonId: Integer): Boolean;
    function TrainFace(Face: TBitmap; PersonId: Integer; Quality: Byte): Boolean; overload;
    function TrainFace(Face: pIplImage; PersonId: Integer; Quality: Byte): Boolean; overload;
    function DetectFace(Face: TBitmap; Quality: Byte): Integer; overload;
    function DetectFace(Face: pIplImage; Quality: Byte): Integer; overload;

  end;

implementation

{ TPersonFace }

constructor TPersonFace.Create(FaceImage: pIplImage; Quality: Byte; Faces: TPersonFaces);
begin
  FFaceImage := cvCreateImage(CvSize(FaceImage.width, FaceImage.height), FaceImage.depth, FaceImage.nChannels);
  cvSplit(FaceImage, FFaceImage, nil, nil, nil);

  FQuality := Quality;
  FSuccessCount := 0;
  FFailedCound := 0;
  FFaces := Faces;
end;

destructor TPersonFace.Destroy;
begin
  cvReleaseImage(FFaceImage);
  inherited;
end;

function TPersonFace.GetScore: Double;
begin
  if FFailedCound > 0 then
    Result := (FSuccessCount / (1.1 - (Quality / 100)) - FFailedCound) / FFailedCound
  else
    Result := FSuccessCount / (1.1 - (Quality / 100));
end;

procedure TPersonFace.IncFail;
begin
  Inc(FFailedCound);
end;

procedure TPersonFace.IncSuccess;
begin
  Inc(FSuccessCount);
end;

{ TPersonFaces }

function TPersonFaces.AddFace(Image: pIplImage; Quality: Byte): TPersonFace;
begin
  Result := TPersonFace.Create(Image, Quality, Self);
  Result.IncSuccess;
  FFaces.Add(Result);

  CleanUp();
end;

function TPersonFaces.AddNotFoundFace(Image: pIplImage; Quality: Byte): TPersonFace;
begin
  IncFail;

  Result := TPersonFace.Create(Image, Quality, Self);
  Result.IncSuccess;
  FFaces.Add(Result);

  CleanUp();
end;

procedure TPersonFaces.IncFail;
var
  I: Integer;
begin
  for I := 0 to FacesCount - 1 do
    Faces[I].IncFail;
end;

procedure TPersonFaces.CleanUp;
var
  I: Integer;
  MinScore, Score: Double;
  FaceToRemove: TPersonFace;
begin
  if FacesCount <= FCapacity then
    Exit;

  MinScore := MaxDouble;
  FaceToRemove := nil;
  for I := 0 to FacesCount - 1 do
  begin
    Score := Faces[I].Score;
    if Score < MinScore then
    begin
      FaceToRemove := Faces[I];
      MinScore := Score;
    end;
  end;

  if FaceToRemove <> nil then
  begin
    FFaces.Remove(FaceToRemove);
    F(FaceToRemove);
  end;
end;

constructor TPersonFaces.Create(PersonId: Integer; Capacity: Integer);
begin
  FPersonId := PersonId;
  FCapacity := Capacity;
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

function TPersonFaces.GetMinQuality: Byte;
var
  I: Integer;
begin
  Result := 255;
  for I := 0 to FacesCount - 1 do
    if Faces[I].Quality < Result then
      Result := Faces[I].Quality;
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

function TFaceEigenRecognizer.TrainFace(Face: TBitmap; PersonId: Integer; Quality: Byte): Boolean;
var
  CvFace, CvSampleFace: pIplImage;
begin
  CvFace :=  cvCreateImage(FSize, IPL_DEPTH_8U, 3);
  Bitmap2IplImage(CvFace, Face);

  CvSampleFace := cvCreateImage(FSize, IPL_DEPTH_8U, 1);

  cvCvtColor(CvFace, CvSampleFace, CV_BGR2GRAY );
  cvEqualizeHist(CvSampleFace, CvSampleFace);

  Result := TrainFace(CvSampleFace, PersonId, Quality);

  cvReleaseImage(CvFace);
  cvReleaseImage(CvSampleFace);
end;

function TFaceEigenRecognizer.AddPerson(FaceImage: pIplImage; Quality: Byte; PersonId: Integer): TPersonFaces;
begin
  FIsTrained := False;
  Result := TPersonFaces.Create(PersonId, FMaxFacesPerPerson);
  Result.AddFace(FaceImage, Quality);
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

function TFaceEigenRecognizer.HasPerson(PersonId: Integer): Boolean;
begin
  Result := FindPerson(PersonId) <> nil;
end;

function TFaceEigenRecognizer.DetectFace(Face: pIplImage; Quality: Byte): Integer;
var
  FaceItem: TPersonFace;
begin
  Result := 0;

  FSync.Enter;
  try
    FaceItem := FindFace(Face);

    if FaceItem <> nil then
      Exit(FaceItem.Person.Id);
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.DetectFace(Face: TBitmap; Quality: Byte): Integer;
var
  CvFaceImage, CvTestImage: pIplImage;
begin
  CvFaceImage := cvCreateImage(FSize, IPL_DEPTH_8U, 3);
  Bitmap2IplImage(CvFaceImage, Face);

  CvTestImage := cvCreateImage(FSize, IPL_DEPTH_8U, 1);
  cvCvtColor(CvFaceImage, CvTestImage, CV_BGR2GRAY );
  cvEqualizeHist(CvTestImage, CvTestImage);

  Result := DetectFace(CvTestImage, Quality);

  cvReleaseImage(CvFaceImage);
  cvReleaseImage(CvTestImage);
end;

procedure TFaceEigenRecognizer.ClearTrainingMemory;
var
  I: Integer;
  Image: pIplImage;
begin
  if Assigned(FEigenVals) then
    cvReleaseMat(FEigenVals);

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

function TFaceEigenRecognizer.Train: Boolean;
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
  if FPersons.Count < 2 then
    Exit(False);

  for I := 0 to FPersons.Count - 1 do
  begin
    Person := FPersons[I];
    for J := 0 to Person.FacesCount - 1 do
    begin
      SetLength(SamplesArray, Length(SamplesArray) + 1);
      SamplesArray[Length(SamplesArray) - 1] := Person.Faces[J].Face;

      SetLength(FTrainedFaces, Length(FTrainedFaces) + 1);
      FTrainedFaces[Length(FTrainedFaces) - 1] := Person.Faces[J];

      try
      SavePIplImageAsBitmap(FTrainedFaces[Length(FTrainedFaces) - 1].Face, 'D:\trainset\' + IntToStr(Length(FTrainedFaces) - 1) + '.bmp');
      except
      end;
    end;
  end;
  SamplesCount := Length(SamplesArray);

  FMeanImg := cvCreateImage(FSize, IPL_DEPTH_32F, 1);

  // -----------------------------------
  // Set criteria to terminate process
  // -----------------------------------
  Tc.cType := CV_TERMCRIT_NUMBER or CV_TERMCRIT_EPS;

  // TODO: check different parameters
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
  Result := True;
end;

function TFaceEigenRecognizer.TrainFace(Face: pIplImage; PersonId: Integer; Quality: Byte): Boolean;
var
  Person: TPersonFaces;
  FaceItem: TPersonFace;
begin
  Result := FTrainedFacesCount > 2;

  FSync.Enter;
  try
    FaceItem := FindFace(Face);
    if FaceItem = nil then
    begin
      Person := FindPerson(PersonId);
      if Person = nil then
        AddPerson(Face, Quality, PersonId)
      else
      begin
        Person.AddNotFoundFace(Face, Quality);
        FIsTrained := False;
      end;

      Exit;
    end;

    Person := FaceItem.Person;
    if FaceItem.Person.Id = PersonId then
    begin
      FaceItem.IncSuccess;
      if Quality > Person.MinQuality then
      begin
        FIsTrained := False;
        Person.AddFace(Face, Quality);
      end;

      Exit;
    end;

    FaceItem.IncFail;
    Person := FindPerson(PersonId);
    if Person = nil then
    begin
      FIsTrained := False;
      AddPerson(Face, Quality, PersonId);
      Exit;
    end;

    if Quality > Person.MinQuality then
    begin
      FIsTrained := False;
      Person.AddNotFoundFace(Face, Quality);
    end;
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.FindFace(FaceImage: pIplImage): TPersonFace;
type
  TFaceDistance = record
    Face: TPersonFace;
    Distance: Double;
    Index: Integer;
  end;
var
  ProjectedTestFace: array of Float;
  FL: Float;
  I, NEigens, ITrain, INearest, Id: Integer;
  S, DI, DistSq, LeastDistSq: Double;
  FD: TFaceDistance;
  FaceDistances: TList<TFaceDistance>;
  Scores: TDictionary<Integer, Double>;
  ScorePair: TPair<Integer, Double>;
begin
  Result := nil;

  if not FIsTrained and not Train then
    Exit;

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
  INearest    := -1;

  FaceDistances := TList<TFaceDistance>.Create;
  try
    NEigens := FTrainedFacesCount - 1;
    for ITrain := 0 to FTrainedFacesCount - 1 do
    begin
      DistSq := 0;
      for I := 0 to NEigens - 1 do
      begin
        DI := ProjectedTestFace[I] - FCoeffs[ITrain][I];
        FL := pFloat(FEigenVals.Data)[I];
        if IsNan(FL) or (FL = 0) then
          DistSq := DBL_MAX
        else
          DistSq := DistSq + DI * DI / FL;
      end;
      if DistSq < LeastDistSq then
      begin
        leastDistSq := DistSq;
        INearest    := ITrain;
      end;
      FD.Face := FTrainedFaces[ITrain];
      FD.Distance := DistSq;
      FD.Index := ITrain;
      FaceDistances.Add(FD);
    end;

    FaceDistances.Sort(TComparer<TFaceDistance>.Construct(
       function (const L, R: TFaceDistance): Integer
       begin
         if L.Distance = R.Distance then
           Exit(0);

         Result := IIF(Abs(L.Distance) - Abs(R.Distance) < 0, -1, 1);
       end
    ));

    if (FaceDistances.Count > 0) then
    begin
      Result := FaceDistances[0].Face;

      cvNamedWindow('SearchFor', 0);
      cvNamedWindow('Found', 0);
      cvShowImage('SearchFor', FaceImage);
      cvShowImage('Found', Result.FFaceImage);
      cvWaitKey(10);;
    end;

  finally
    F(FaceDistances);
  end;

end;

end.
