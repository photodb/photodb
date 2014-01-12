unit uFaceRecognizer;

interface

uses
  Winapi.Windows,
  Generics.Defaults,
  Generics.Collections,
  System.Math,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.IOUtils,
  System.Types,
  Vcl.Graphics,
  Xml.xmldom,

  OpenCV.Core,
  OpenCV.Utils,
  OpenCV.ImgProc,
  OpenCV.Legacy,
  OpenCV.HighGUI,

  Dmitry.Utils.System,

  uMemory,
  uGuidUtils,
  uLogger;

type
  TFaceRecognitionResult = class
  private
    FFace: TBitmap;
    function GetPercent: Double;
    function GetIsValid: Boolean;
  public
    PersonId: Integer;
    Index: Integer;
    FaceId: Integer;
    HasNegative: Boolean;
    Distance: Double;
    Threshold: Double;
    constructor Create;
    destructor Destroy; override;
    procedure SetFace(Face: TBitmap);
    function ExtractBitmap: TBitmap;
    property Percents: Double read GetPercent;
    property IsValid: Boolean read GetIsValid;
  end;

  TFaceRecognitionResults = class
  private
    FData: TList<TFaceRecognitionResult>;
    function GetCount: Integer;
    function GetItemByIndex(Index: Integer): TFaceRecognitionResult;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Item: TFaceRecognitionResult);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TFaceRecognitionResult read GetItemByIndex; default;
  end;

  TEigenThresholdFunction = reference to function(CountOfFaces: Integer): Double;

  IFaceRecognizer = Interface
    ['{4084C125-FB9B-4DED-9732-EE6B7B90D0FA}']
    function SaveState(Path: string): Boolean;
    function LoadState(Path: string): Boolean;

    function Train: Boolean;
    //simple add face to detection collection
    function HasPerson(PersonId: Integer): Boolean;
    function RemoveFaceById(FaceId: Integer): Boolean;
    function MoveFaceToAnotherPerson(FaceId: Integer; PersonId: Integer): Boolean;
    function TrainFace(Face: TBitmap; Image: TBitmap; PersonId: Integer; FaceId: Integer; Quality: Byte): Boolean; overload;
    function TrainFace(Face: pIplImage; Image: TBitmap; PersonId: Integer; FaceId: Integer; Quality: Byte): Boolean; overload;
    //resolve person by image
    function RecognizeFace(Face: TBitmap; PersonsToSearch: Integer): TFaceRecognitionResults; overload;
    function RecognizeFace(Face: TBitmap): Integer; overload;
    function RecognizeFace(Face: pIplImage): Integer; overload;

    function GetFacesCount: Integer;
  end;

  TPersonFaces = class;

  TPersonFace = class
  private
    FFaceImage: pIplImage;
    FSuccessCount: Integer;
    FFailedCound: Integer;
    FFaces: TPersonFaces;
    FQuality: Byte;
    FImageId: Integer;
    FFaceId: Integer;
    FAreaRect: TRect;
    FUID: TGUID;
    FLastUsedDate: TDateTime;
    FImage: TBitmap;
    function GetScore: Double;
  public
    destructor Destroy; override;
    constructor Create(FaceImage: pIplImage; Image: TBitmap; FaceId: Integer; Quality: Byte; Faces: TPersonFaces);
    constructor CreateFromFile(XmlFileName: string);
    procedure SaveToFile(XmlFileName: string);
    procedure IncSuccess;
    procedure IncFail;
    property Face: pIplImage read FFaceImage;
    property Person: TPersonFaces read FFaces;
    property Quality: Byte read FQuality;
    property Score: Double read GetScore;
    property UID: TGUID read FUID;
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
    function AddFace(Face: pIplImage; Image: TBitmap; FaceId: Integer; Quality: Byte): TPersonFace;
    procedure Add(Face: TPersonFace);
    function AddNotFoundFace(Face: pIplImage; Image: TBitmap; FaceId: Integer; Quality: Byte): TPersonFace;
    procedure CleanUp;
    procedure IncFail;
    property Id: Integer read FPersonId;
    property FacesCount: Integer read GetFacesCount;
    property Faces[Index: Integer]: TPersonFace read GetFace;
    property MinQuality: Byte read GetMinQuality;
  end;

  TFaceRecognitionInternalResult = record
    PersonId: Integer;
    Index: Integer;
    Distance: Double;
    HasNegative: Boolean;
    Face: TPersonFace;
  end;
  TFaceRecognitionInternalResults = array of TFaceRecognitionInternalResult;

  TFaceEigenRecognizer = class(TInterfacedObject, IFaceRecognizer)
  private
    FSync: TCriticalSection;
    FSize: TCvSize;
    FMaxFacesPerPerson: Integer;
    FMaxFaces: Integer;
    FPersons: TList<TPersonFaces>;

    FTrainedFacesCount: Integer;
    FTrainedFaces: array of TPersonFace;
    FIsTrained: Boolean;
    FEigImg: array of pIplImage;
    FMeanImg: pIplImage; // Average face (float point)
    FCoeffs: array of array of Float;
    FEigenVals: pCvMat;
    FThresholdFunc: TEigenThresholdFunction;
    procedure ClearTrainingMemory;
    function FindFaces(FaceImage: pIplImage; MaxItems: Integer): TFaceRecognitionInternalResults;
    function FindFace(FaceImage: pIplImage): TPersonFace;
    function FindPerson(PersonId: Integer): TPersonFaces;
    function AddPerson(FaceImage: pIplImage; Image: TBitmap; Quality: Byte; PersonId, FaceId: Integer): TPersonFaces; overload;
    function AddPerson(PersonId: Integer; Face: TPersonFace): TPersonFaces; overload;
    procedure CleanUp1Face;
  public
    constructor Create(Width, Height: Integer; MaxFacesPerPerson, MaxFaces: Integer; ThresholdFunc: TEigenThresholdFunction = nil);
    destructor Destroy; override;

    function SaveState(Path: string): Boolean;
    function LoadState(Path: string): Boolean;

    function Train: Boolean;

    function HasPerson(PersonId: Integer): Boolean;
    function RemoveFaceById(FaceId: Integer): Boolean;
    function MoveFaceToAnotherPerson(FaceId: Integer; PersonId: Integer): Boolean;
    function TrainFace(Face: TBitmap; Image: TBitmap; PersonId: Integer; FaceId: Integer; Quality: Byte): Boolean; overload;
    function TrainFace(Face: pIplImage; Image: TBitmap;  PersonId: Integer; FaceId: Integer; Quality: Byte): Boolean; overload;
    function RecognizeFace(Face: TBitmap): Integer; overload;
    function RecognizeFace(Face: pIplImage): Integer; overload;
    function RecognizeFace(Face: TBitmap; PersonsToSearch: Integer): TFaceRecognitionResults; overload;

    function GetFacesCount: Integer;
  end;

implementation

{ TPersonFace }

constructor TPersonFace.Create(FaceImage: pIplImage; Image: TBitmap; FaceId: Integer; Quality: Byte; Faces: TPersonFaces);
begin
  FFaceImage := cvCreateImage(CvSize(FaceImage.width, FaceImage.height), FaceImage.depth, FaceImage.nChannels);
  cvSplit(FaceImage, FFaceImage, nil, nil, nil);

  FUID := GetGUID;
  FQuality := Quality;
  FSuccessCount := 0;
  FFailedCound := 0;
  FFaces := Faces;
  FLastUsedDate := Now;
  FFaceId := FaceId;
  FImage := Image;
end;

constructor TPersonFace.CreateFromFile(XmlFileName: string);
var
  Doc: IDOMDocument;
  DocumentElement: IDOMElement;
  ImageFileName: string;
  B: TBitmap;
  Size: TCvSize;
begin
  Doc := GetDOM.createDocument('', '', nil);
  try
    (Doc as IDOMPersist).load(XmlFileName);
    DocumentElement := Doc.documentElement;

    FSuccessCount := StrToInt(DocumentElement.attributes.getNamedItem('SuccessCount').nodeValue);
    FFailedCound := StrToInt(DocumentElement.attributes.getNamedItem('FailedCound').nodeValue);
    FQuality := StrToInt(DocumentElement.attributes.getNamedItem('Quality').nodeValue);
    FImageId := StrToInt(DocumentElement.attributes.getNamedItem('ImageId').nodeValue);
    FFaceId := StrToInt(DocumentElement.attributes.getNamedItem('FaceId').nodeValue);
    FUID := StringToGUID(DocumentElement.attributes.getNamedItem('UID').nodeValue);
    FAreaRect := Rect(
      StrToInt(DocumentElement.attributes.getNamedItem('Left').nodeValue),
      StrToInt(DocumentElement.attributes.getNamedItem('Top').nodeValue),
      StrToInt(DocumentElement.attributes.getNamedItem('Right').nodeValue),
      StrToInt(DocumentElement.attributes.getNamedItem('Bottom').nodeValue)
    );

    ImageFileName := ExtractFilePath(XmlFileName) + GUIDToString(FUID) + '_face.bmp';
    B := TBitmap.Create;
    try
      B.LoadFromFile(ImageFileName);
      Size := CvSize(B.Width, B.Height);
      FFaceImage := cvCreateImage(Size, IPL_DEPTH_8U, 1);
      Bitmap2IplImage(FFaceImage, B);
    finally
      F(B);
    end;

    ImageFileName := ExtractFilePath(XmlFileName) + GUIDToString(FUID) + '_image.bmp';
    FImage := TBitmap.Create;
    FImage.LoadFromFile(ImageFileName);
  except
    on e: Exception do
      EventLog(e);
  end;
end;

procedure TPersonFace.SaveToFile(XmlFileName: string);
var
  Doc: IDOMDocument;
  DocumentElement: IDOMElement;
  FaceNode: IDOMNode;
  ImageFileName: string;
  FaceImage: TBitmap;

  procedure AddXmlProperty(Name: string; Value: string);
  var
    Attr: IDOMAttr;
  begin
    Attr := Doc.createAttribute(Name);
    Attr.value := Value;
    FaceNode.attributes.setNamedItem(Attr);
  end;

begin
  Doc := GetDOM.createDocument('', '', nil);
  try
    DocumentElement := Doc.createElement('faces');
    Doc.documentElement := DocumentElement;

    FaceNode := DocumentElement;
    AddXmlProperty('SuccessCount', IntToStr(FSuccessCount));
    AddXmlProperty('FailedCound', IntToStr(FFailedCound));
    AddXmlProperty('Quality', IntToStr(FQuality));
    AddXmlProperty('ImageId', IntToStr(FImageId));
    AddXmlProperty('FaceId', IntToStr(FFaceId));
    AddXmlProperty('UID', GUIDToString(FUID));
    AddXmlProperty('Left', IntToStr(FAreaRect.Left));
    AddXmlProperty('Top', IntToStr(FAreaRect.Top));
    AddXmlProperty('Right', IntToStr(FAreaRect.Right));
    AddXmlProperty('Bottom', IntToStr(FAreaRect.Bottom));

    (Doc as IDOMPersist).save(XmlFileName);

    FaceImage := TBitmap.Create;
    try
      FaceImage.PixelFormat := pf24Bit;
      IplImage2Bitmap(FFaceImage, FaceImage);
      ImageFileName := ChangeFileExt(ExtractFilePath(XmlFileName) + GUIDToString(FUID), '_face.bmp');

      FaceImage.SaveToFile(ImageFileName);

      if (FImage <> nil) and not FImage.Empty then
      begin
        ImageFileName := ChangeFileExt(ExtractFilePath(XmlFileName) + GUIDToString(FUID), '_image.bmp');
        FImage.SaveToFile(ImageFileName);
      end;
    finally
      F(FaceImage);
    end;
  except
    on e: Exception do
      EventLog(e);
  end;
end;

destructor TPersonFace.Destroy;
begin
  cvReleaseImage(FFaceImage);
  F(FImage);
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
  FLastUsedDate := Now;
end;

{ TPersonFaces }

procedure TPersonFaces.Add(Face: TPersonFace);
begin
  Face.FFaces := Self;
  FFaces.Add(Face);
end;

function TPersonFaces.AddFace(Face: pIplImage; Image: TBitmap; FaceId: Integer; Quality: Byte): TPersonFace;
begin
  Result := TPersonFace.Create(Face, Image, FaceId, Quality, Self);
  Result.IncSuccess;
  FFaces.Add(Result);

  CleanUp();
end;

function TPersonFaces.AddNotFoundFace(Face: pIplImage; Image: TBitmap; FaceId: Integer; Quality: Byte): TPersonFace;
begin
  IncFail;

  Result := TPersonFace.Create(Face, Image, FaceId, Quality, Self);
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

  CleanUp;
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

constructor TFaceEigenRecognizer.Create(Width, Height: Integer; MaxFacesPerPerson, MaxFaces: Integer; ThresholdFunc: TEigenThresholdFunction = nil);
begin
  FSize.width := Width;
  FSize.height := Height;
  FMaxFacesPerPerson := MaxFacesPerPerson;
  FMaxFaces := MaxFaces;
  FSync := TCriticalSection.Create;
  FPersons := TList<TPersonFaces>.Create;
  FTrainedFacesCount := 0;
  FIsTrained := False;
  FThresholdFunc := ThresholdFunc;
  if not Assigned(FThresholdFunc) then
    FThresholdFunc := function(N: Integer): Double
    begin
      //Result := LogN(9, N - 1) / 2.2;
      Result := LogN(3.9, N - 1) / 3;
      //2% Fail Result := LogN(3, N - 1) / 7.2;
    end;

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

function TFaceEigenRecognizer.AddPerson(PersonId: Integer; Face: TPersonFace): TPersonFaces;
begin
  FIsTrained := False;
  Result := TPersonFaces.Create(PersonId, FMaxFacesPerPerson);
  Result.Add(Face);
  FPersons.Add(Result);
end;

function TFaceEigenRecognizer.AddPerson(FaceImage: pIplImage; Image: TBitmap; Quality: Byte; PersonId, FaceId: Integer): TPersonFaces;
begin
  FIsTrained := False;
  Result := TPersonFaces.Create(PersonId, FMaxFacesPerPerson);
  Result.AddFace(FaceImage, Image, FaceId, Quality);
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

function TFaceEigenRecognizer.GetFacesCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FPersons.Count - 1 do
    Inc(Result, FPersons[I].FacesCount);
end;

function TFaceEigenRecognizer.HasPerson(PersonId: Integer): Boolean;
begin
  Result := FindPerson(PersonId) <> nil;
end;

function TFaceEigenRecognizer.RecognizeFace(Face: TBitmap; PersonsToSearch: Integer): TFaceRecognitionResults;
var
  Results: TFaceRecognitionInternalResults;
  MaxDistance: Double;
  I: Integer;
  CvFaceImage, CvTestImage: pIplImage;
  ResultItem: TFaceRecognitionResult;
begin
  Result := TFaceRecognitionResults.Create;

  FSync.Enter;
  try

    CvFaceImage := cvCreateImage(FSize, IPL_DEPTH_8U, 3);
    try
      Bitmap2IplImage(CvFaceImage, Face);

      CvTestImage := cvCreateImage(FSize, IPL_DEPTH_8U, 1);
      try
        cvCvtColor(CvFaceImage, CvTestImage, CV_BGR2GRAY );
        cvEqualizeHist(CvTestImage, CvTestImage);

        Results := FindFaces(CvTestImage, PersonsToSearch);
        MaxDistance := FThresholdFunc(GetFacesCount);

        for I := 0 to Length(Results) - 1 do
        begin
          ResultItem := TFaceRecognitionResult.Create;
          Result.Add(ResultItem);

          ResultItem.PersonId := Results[I].PersonId;
          ResultItem.Index := Results[I].Index;
          ResultItem.Threshold := MaxDistance;
          ResultItem.Distance := Results[I].Distance;
          ResultItem.HasNegative := Results[I].HasNegative;
          ResultItem.SetFace(Results[I].Face.FImage);
        end;

      finally
        cvReleaseImage(CvTestImage);
      end;
    finally
      cvReleaseImage(CvFaceImage);
    end;

  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.RecognizeFace(Face: pIplImage): Integer;
var
  Results: TFaceRecognitionInternalResults;
begin
  Result := 0;

  FSync.Enter;
  try
    Results := FindFaces(Face, 1);

    if Length(Results) > 0 then
      Exit(Results[0].PersonId);
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.RecognizeFace(Face: TBitmap): Integer;
var
  CvFaceImage, CvTestImage: pIplImage;
begin
  CvFaceImage := cvCreateImage(FSize, IPL_DEPTH_8U, 3);
  try
    Bitmap2IplImage(CvFaceImage, Face);

    CvTestImage := cvCreateImage(FSize, IPL_DEPTH_8U, 1);
    try
      cvCvtColor(CvFaceImage, CvTestImage, CV_BGR2GRAY );
      cvEqualizeHist(CvTestImage, CvTestImage);

      Result := RecognizeFace(CvTestImage);
    finally
      cvReleaseImage(CvTestImage);
    end;
  finally
    cvReleaseImage(CvFaceImage);
  end;
end;

procedure TFaceEigenRecognizer.CleanUp1Face;
var
  I, J: Integer;
  MinScore: Double;
  FMinPerson: TPersonFaces;
  FMinFace: TPersonFace;
begin
  MinScore := MaxDouble;
  FMinPerson := nil;
  FMinFace := nil;
  for I := 0 to FPersons.Count - 1 do
  begin
    for J := 0 to FPersons[I].FacesCount - 1 do
    begin
      if MinScore > FPersons[I].Faces[J].Score then
      begin 
        MinScore := FPersons[I].Faces[J].Score;
        FMinPerson := FPersons[I];
        FMinFace := FPersons[I].Faces[J];
      end;
    end;
  end;

  if FMinPerson <> nil then
  begin
    FMinPerson.FFaces.Remove(FMinFace);
    F(FMinFace);
    FIsTrained := False;
  end;
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

function TFaceEigenRecognizer.SaveState(Path: string): Boolean;
var
  I, J: Integer;
  P: TPersonFaces;
  Face: TPersonFace;
  PersonDirectory, FaceXmlFileName: string;
begin
  Result := True;

  CreateDir(Path);

  FSync.Enter;
  try
    for I := 0 to FPersons.Count - 1 do
    begin
      P := FPersons[I];
      PersonDirectory := IncludeTrailingBackslash(Path) + IntToStr(P.FPersonId);
      CreateDir(PersonDirectory);

      for J := 0 to P.FacesCount - 1 do
      begin
        Face := P.Faces[J];
        FaceXmlFileName := IncludeTrailingBackslash(PersonDirectory) + GUIDToString(Face.UID) + '.xml';

        Face.SaveToFile(FaceXmlFileName);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.LoadState(Path: string): Boolean;
var
  PersonId: Integer;
  P: TPersonFaces;
  Face: TPersonFace;
  PersonDir, FaceFileName: string;
begin
  Result := True;
  FSync.Enter;
  try

    if TDirectory.Exists(Path) then
      for PersonDir in TDirectory.GetDirectories(Path) do
      begin
        P := nil;
        PersonId := StrToIntDef(ExtractFileName(PersonDir), 0);
        if PersonId > 0 then
        begin
          for FaceFileName in TDirectory.GetFiles(PersonDir, '*.xml') do
          begin
            Face := TPersonFace.CreateFromFile(FaceFileName);
            if Face.FFaceImage <> nil then
            begin
              if P = nil then
              begin
                P := TPersonFaces.Create(PersonId, FMaxFacesPerPerson);
                FPersons.Add(P);
              end;
              P.Add(Face);
            end
            else
              Face.Free;
          end;
        end;
      end;

  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.MoveFaceToAnotherPerson(FaceId, PersonId: Integer): Boolean;
var
  I, J: Integer;
  Face: TPersonFace;
  Person: TPersonFaces;
begin
  Result := False;
  FSync.Enter;
  try
    for I := 0 to FPersons.Count - 1 do
    begin
      for J := FPersons[I].FacesCount - 1 downto 0 do
        if FPersons[I].Faces[J].FFaceId = FaceId then
        begin
          Face := FPersons[I].Faces[J];
          FPersons[I].FFaces.Remove(Face);

          Person := FindPerson(PersonId);
          if Person <> nil then
            Person.Add(Face)
           else
            AddPerson(PersonId, Face);

          FIsTrained := False;
          Result := True;
        end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.RemoveFaceById(FaceId: Integer): Boolean;
var
  I, J: Integer;
  Face: TPersonFace;
begin
  Result := False;
  FSync.Enter;
  try
    for I := 0 to FPersons.Count - 1 do
    begin
      for J := FPersons[I].FacesCount - 1 downto 0 do
        if FPersons[I].Faces[J].FFaceId = FaceId then
        begin
          Face := FPersons[I].Faces[J];
          FPersons[I].FFaces.Remove(Face);
          F(Face);
          FIsTrained := False;
          Result := True;
        end;
    end;
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
  if GetFacesCount < 2 then
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

      {$IFDEF DEBUG}
      try
      SavePIplImageAsBitmap(FTrainedFaces[Length(FTrainedFaces) - 1].Face, 'D:\trainset\' + IntToStr(Length(FTrainedFaces) - 1) + '.bmp');
      except
      end;
      {$ENDIF}
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

function TFaceEigenRecognizer.TrainFace(Face: TBitmap; Image: TBitmap; PersonId: Integer; FaceId: Integer; Quality: Byte): Boolean;
var
  CvFace, CvSampleFace: pIplImage;
begin
  CvFace :=  cvCreateImage(FSize, IPL_DEPTH_8U, 3);
  Bitmap2IplImage(CvFace, Face);

  CvSampleFace := cvCreateImage(FSize, IPL_DEPTH_8U, 1);

  cvCvtColor(CvFace, CvSampleFace, CV_BGR2GRAY );
  cvEqualizeHist(CvSampleFace, CvSampleFace);

  Result := TrainFace(CvSampleFace, Image, PersonId, FaceId, Quality);

  cvReleaseImage(CvFace);
  cvReleaseImage(CvSampleFace);
end;

function TFaceEigenRecognizer.TrainFace(Face: pIplImage; Image: TBitmap; PersonId: Integer; FaceId: Integer; Quality: Byte): Boolean;
var
  Person: TPersonFaces;
  FaceItem: TPersonFace;
begin
  Result := FTrainedFacesCount > 2;

  FSync.Enter;
  try
    if GetFacesCount > FMaxFaces then
      CleanUp1Face;

    FaceItem := FindFace(Face);

    if FaceItem = nil then
    begin
      Person := FindPerson(PersonId);
      if Person = nil then
        AddPerson(Face, Image, Quality, PersonId, FaceId)
      else
      begin
        Person.AddNotFoundFace(Face, Image, FaceId, Quality);
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
        Person.AddFace(Face, Image, FaceId, Quality);
      end else
        F(Image);

      Exit;
    end;

    FaceItem.IncFail;
    Person := FindPerson(PersonId);
    if Person = nil then
    begin
      FIsTrained := False;
      AddPerson(Face, Image, Quality, PersonId, FaceId);
      Exit;
    end;

    FIsTrained := False;
    Person.AddNotFoundFace(Face, Image, FaceId, Quality);
  finally
    FSync.Leave;
  end;
end;

function TFaceEigenRecognizer.FindFace(FaceImage: pIplImage): TPersonFace;
var
  Results: TFaceRecognitionInternalResults;
  MaxDistance: Double;
begin
  Result := nil;
  MaxDistance := FThresholdFunc(GetFacesCount);

  Results := FindFaces(FaceImage, 1);
  if (Length(Results) > 0) and (MaxDistance > Results[0].Distance) then
    Result := Results[0].Face;
end;

function TFaceEigenRecognizer.FindFaces(FaceImage: pIplImage; MaxItems: Integer): TFaceRecognitionInternalResults;
type
  TFaceDistance = record
    Face: TPersonFace;
    Distance: Double;
    Index: Integer;
  end;
var
  ProjectedTestFaces: array of Float;
  FL: Float;
  I, NEigens, ITrain: Integer;
  DI, DistSq: Double;
  FD: TFaceDistance;
  FaceDistances: TList<TFaceDistance>;
  HasNegative: Boolean;

  function PersonExistsInResults(Res: TFaceRecognitionInternalResults; PersonId: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Length(Res) - 1 do
      if Res[I].PersonId = PersonId then
        Exit(True);
  end;

begin
  SetLength(Result, 0);

  if not FIsTrained and not Train then
    Exit;

  HasNegative := False;

  // -----------------------------------------------------------
  // Load test image
  // -----------------------------------------------------------
  SetLength(
    ProjectedTestFaces,
    FTrainedFacesCount);

  cvEigenDecomposite(
    FaceImage,
    FTrainedFacesCount,
    FEigImg,
    CV_EIGOBJ_NO_CALLBACK,
    nil,
    FMeanImg,
    @ProjectedTestFaces[0]);

  // -----------------------------------------------------------

  FaceDistances := TList<TFaceDistance>.Create;
  try
    NEigens := FTrainedFacesCount - 1;
    for ITrain := 0 to FTrainedFacesCount - 1 do
    begin
      DistSq := 0;
      for I := 0 to NEigens - 1 do
      begin
        DI := ProjectedTestFaces[I] - FCoeffs[ITrain][I];
        FL := pFloat(FEigenVals.Data)[I];
        if FL < 0 then
        begin
          HasNegative := True;
          FL := Abs(FL);
        end;

        if IsNan(FL) or (FL = 0) then
          DistSq := DBL_MAX
        else
          DistSq := DistSq + DI * DI / FL;
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
      for I := 0 to FaceDistances.Count - 1 do
      begin
        if not PersonExistsInResults(Result, FaceDistances[I].Face.Person.FPersonId) then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1].PersonId := FaceDistances[I].Face.Person.FPersonId;
          Result[Length(Result) - 1].Distance := FaceDistances[I].Distance;
          Result[Length(Result) - 1].Index := I;
          Result[Length(Result) - 1].HasNegative := HasNegative;
          Result[Length(Result) - 1].Face := FaceDistances[I].Face;

          if Length(Result) = MaxItems then
            Break;
        end;

        {$IFDEF DEBUG}
        if I = 0 then
        begin
          cvNamedWindow('SearchFor', 0);
          cvNamedWindow('Found', 0);
          cvShowImage('SearchFor', FaceImage);
          cvShowImage('Found', FaceDistances[I].Face.FFaceImage);
          cvWaitKey(10);
        end;
        {$ENDIF}
      end;
    end;

  finally
    F(FaceDistances);
  end;

end;

{ TFaceRecognitionResults }

procedure TFaceRecognitionResults.Add(Item: TFaceRecognitionResult);
begin
  FData.Add(Item);
end;

constructor TFaceRecognitionResults.Create;
begin
  FData := TList<TFaceRecognitionResult>.Create;
end;

destructor TFaceRecognitionResults.Destroy;
begin
  FreeList(FData);
  inherited;
end;

function TFaceRecognitionResults.GetCount: Integer;
begin
  Result := FData.Count;
end;

function TFaceRecognitionResults.GetItemByIndex(Index: Integer): TFaceRecognitionResult;
begin
  Result := FData[Index];
end;

{ TFaceRecognitionResult }

constructor TFaceRecognitionResult.Create;
begin
  FFace := nil;
end;

destructor TFaceRecognitionResult.Destroy;
begin
  F(FFace);
  inherited;
end;

function TFaceRecognitionResult.ExtractBitmap: TBitmap;
begin
  Result := FFace;
  FFace := nil;
end;

function TFaceRecognitionResult.GetIsValid: Boolean;
begin
  Result := Percents > 0;
end;

function TFaceRecognitionResult.GetPercent: Double;
begin
  Result := 100 * (Threshold - Distance) / Threshold;
  if Result < 0 then
    Result := 0;
end;

procedure TFaceRecognitionResult.SetFace(Face: TBitmap);
begin
  if (Face <> nil) and not Face.Empty then
  begin
    FFace := TBitmap.Create;
    FFace.Assign(Face);
    Exit;
  end;
  FFace := Face;
end;

end.
