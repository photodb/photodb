unit uFaceRecognizerService;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,

  OpenCV.Utils,
  Dmitry.Utils.Files,

  uConstants,
  uMemory,
  uBitmapUtils,
  uConfiguration,
  uFaceDetection,
  uFaceRecognizer,
  uFaceAnalyzer,
  uDBEntities;

type
  IFoundPerson = interface
    function ExtractBitmap: TBitmap;
    function GetPersonId: Integer;
    function GetStars: Byte;
    function GetPercents: Byte;
  end;

  IRelatedPersonsCollection = interface
    function Count: Integer;
    function GetPerson(Index: Integer): IFoundPerson;
    function GetPersonById(PersonId: Integer): IFoundPerson;
    function HasMatches: Boolean;
  end;

  TFaceDetectonOption = (fdoImage);
  TFaceDetectonOptions = set of TFaceDetectonOption;

type
  TFoundPerson = class(TInterfacedObject, IFoundPerson)
  private
    FImage: TBitmap;
    FPersonId: Integer;
    FPercents: Byte;
    FStars: Integer;
  public
    constructor Create(Stars: Integer; FDR: TFaceRecognitionResult);
    destructor Destroy; override;
    function ExtractBitmap: TBitmap;
    function GetPersonId: Integer;
    function GetPercents: Byte;
    function GetStars: Byte;
  end;

  TRelatedPersonsCollection = class(TInterfacedObject, IRelatedPersonsCollection)
  private
    FPersons: TList<IFoundPerson>;
  public
    constructor Create(FDRs: TFaceRecognitionResults);
    destructor Destroy; override;
    function Count: Integer;
    function GetPerson(Index: Integer): IFoundPerson;
    function GetPersonById(PersonId: Integer): IFoundPerson;
    function HasMatches: Boolean;
  end;

type
  TFaceRecognizerService = class
  private
    FRecognizer: IFaceRecognizer;
    FDetector: TFaceDetectionManager;
    function CacheDirectory: string;
  public
    constructor Create;
    destructor Destroy; override;
    function HasFaceArea(AreaId: Integer): Boolean;
    function UserSelectedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
    function UserChangedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
    function UserRemovedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
    function FindRelatedPersons(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): IRelatedPersonsCollection;
    //For The Future, currently detection rate is too low to use automatic detection 2014/01/05
    function DetectPersonId(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Integer;
    function IsActive: Boolean;
  end;

function UIFaceRecognizerService: TFaceRecognizerService;

implementation

const    
  MaxFaces = 80;
  FacesPerPerson = 10;
  MinFaceScore = 0;//60;
  FaceWidth = 64;
  FaceHeight = 64;
  MaxPersonsToSearch = 5;

var
  AUIFaceRecognizerService: TFaceRecognizerService = nil;

function UIFaceRecognizerService: TFaceRecognizerService;
begin
  if AUIFaceRecognizerService = nil then
    AUIFaceRecognizerService := TFaceRecognizerService.Create;

  Result := AUIFaceRecognizerService;
end;

{ TFaceRecognizerService }

function TFaceRecognizerService.CacheDirectory: string;
begin
  Result := GetAppDataDirectory + FaceTrainCacheDirectory;
end;

constructor TFaceRecognizerService.Create;
begin
  if not HasOpenCV then
    Exit;

  FRecognizer := TFaceEigenRecognizer.Create(FaceWidth, FaceHeight, FacesPerPerson, MaxFaces);
  FDetector := TFaceDetectionManager.Create;
  FRecognizer.LoadState(CacheDirectory);
end;

destructor TFaceRecognizerService.Destroy;
begin
  if not HasOpenCV then
    Exit;

  DeleteDirectoryWithFiles(CacheDirectory);
  FRecognizer.SaveState(CacheDirectory);
  FRecognizer := nil;
  F(FDetector);
end;

function TFaceRecognizerService.DetectPersonId(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Integer;
begin
  raise ENotSupportedException.Create('Detection currently is not supported!');
end;

function TFaceRecognizerService.FindRelatedPersons(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): IRelatedPersonsCollection;
var
  FDR: TFaceRecognitionResults;
  DR: TFaceScoreResults;
  FaceSample: TBitmap;
begin
  if not HasOpenCV then
    Exit;

  DR := ProcessFaceAreaOnImage(MI, Image, Area, FDetector, MinFaceScore);
  try
    if DR = nil then
      Exit;

    FaceSample := TBitmap.Create;
    try
      DR.GenerateSample(FaceSample, FaceWidth, FaceHeight);

      FDR := FRecognizer.RecognizeFace(FaceSample, MaxPersonsToSearch);
      try
        Result := TRelatedPersonsCollection.Create(FDR);
      finally
        F(FDR);
      end;

    finally
      F(FaceSample);
    end;
  finally
    F(DR);
  end;
end;

function TFaceRecognizerService.HasFaceArea(AreaId: Integer): Boolean;
begin
  if not HasOpenCV then
    Exit(False);

  Result := FRecognizer.HasFace(AreaId);
end;

function TFaceRecognizerService.IsActive: Boolean;
begin
  Result := HasOpenCV;
end;

function TFaceRecognizerService.UserChangedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
begin
  if not HasOpenCV then
    Exit(False);

  Result := FRecognizer.MoveFaceToAnotherPerson(Area.ID, Area.PersonID);
end;

function TFaceRecognizerService.UserRemovedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
begin
  if not HasOpenCV then
    Exit(False);

  Result := FRecognizer.RemoveFaceById(Area.ID);
end;

function TFaceRecognizerService.UserSelectedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
var
  DR: TFaceScoreResults;
  FaceSample, FaceImage: TBitmap;
begin
  Result := False;

  if not HasOpenCV then
    Exit;

  DR := ProcessFaceAreaOnImage(MI, Image, Area, FDetector, MinFaceScore);
  try
    if DR = nil then
      Exit;

    FaceSample := TBitmap.Create;
    try
      DR.GenerateSample(FaceSample, FaceWidth, FaceHeight);

      FaceImage := nil;
      if DR.FaceImage <> nil then
      begin
        FaceImage := TBitmap.Create;
        FaceImage.Assign(DR.FaceImage);
      end;
      Result := FRecognizer.TrainFace(FaceSample, FaceImage, Area.PersonID, Area.ID, DR.TotalScore);
    finally
      F(FaceSample);
    end;
  finally
    F(DR);
  end;
end;

{ TRelatedPersonsCollection }

function TRelatedPersonsCollection.Count: Integer;
begin
  Result := FPersons.Count;
end;

constructor TRelatedPersonsCollection.Create(FDRs: TFaceRecognitionResults);
var
  I: Integer;
begin
  FPersons := TList<IFoundPerson>.Create;
  for I := 0 to FDRs.Count - 1 do
    FPersons.Add(TFoundPerson.Create(FDRs.Count - I, FDRs[I]));
end;

destructor TRelatedPersonsCollection.Destroy;
begin
  F(FPersons);
  inherited;
end;

function TRelatedPersonsCollection.GetPerson(Index: Integer): IFoundPerson;
begin
  Result := FPersons[Index];
end;

function TRelatedPersonsCollection.GetPersonById(PersonId: Integer): IFoundPerson;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPersons.Count - 1 do
    if FPersons[I].GetPersonId = PersonId then
      Exit(FPersons[I]);
end;

function TRelatedPersonsCollection.HasMatches: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FPersons.Count - 1 do
    if FPersons[I].GetPercents > 0 then
      Exit(True);
end;

{ TFoundPerson }

constructor TFoundPerson.Create(Stars: Integer; FDR: TFaceRecognitionResult);
begin
  FImage := FDR.ExtractBitmap;
  FPersonId := FDR.PersonId;
  FPercents := Ceil(FDR.Percents);
  FStars := Stars;
end;

destructor TFoundPerson.Destroy;
begin
  F(FImage);
  inherited;
end;

function TFoundPerson.ExtractBitmap: TBitmap;
begin
  Result := FImage;
  FImage := nil;
end;

function TFoundPerson.GetPercents: Byte;
begin
  Result := FPercents;
end;

function TFoundPerson.GetPersonId: Integer;
begin
  Result := FPersonId;
end;

function TFoundPerson.GetStars: Byte;
begin
  Result := FStars;
end;

initialization
finalization
  F(AUIFaceRecognizerService);

end.
