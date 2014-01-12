unit uFaceRecognizerService;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,

  OpenCV.Core,
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
    function GetPercents: Byte;
  end;

  IRelatedPersonsCollection = interface
    function Count: Integer;
    function GetPerson(Index: Integer): IFoundPerson;
  end;

  TFaceDetectonOption = (fdoImage);
  TFaceDetectonOptions = set of TFaceDetectonOption;

type
  TFoundPerson = class(TInterfacedObject, IFoundPerson)
  private
    FImage: TBitmap;
    FPersonId: Integer;
    FPercents: Integer;
  public
    constructor Create(FDR: TFaceRecognitionResult);
    destructor Destroy; override;
    function ExtractBitmap: TBitmap;
    function GetPersonId: Integer;
    function GetPercents: Byte;
  end;

  TRelatedPersonsCollection = class(TInterfacedObject, IRelatedPersonsCollection)
  private
    FPersons: TList<IFoundPerson>;
  public
    constructor Create(FDRs: TFaceRecognitionResults);
    destructor Destroy; override;
    function Count: Integer;
    function GetPerson(Index: Integer): IFoundPerson;
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
    function UserSelectedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
    function UserChangedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
    function UserRemovedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
    function FindRelatedPersons(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): IRelatedPersonsCollection;
    //For The Future, currently detection rate is too low to use automatic detection 2014/01/05
    function DetectPersonId(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Integer;
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

function TFaceRecognizerService.UserChangedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
begin
  if not HasOpenCV then
    Exit;

  Result := FRecognizer.MoveFaceToAnotherPerson(Area.ID, Area.PersonID);
end;

function TFaceRecognizerService.UserRemovedPerson(MI: TMediaItem; Image: TBitmap; Area: TPersonArea): Boolean;
begin
  if not HasOpenCV then
    Exit;

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
    if FDRs[I].IsValid then
      FPersons.Add(TFoundPerson.Create(FDRs[I]));
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

{ TFoundPerson }

constructor TFoundPerson.Create(FDR: TFaceRecognitionResult);
begin
  FImage := FDR.ExtractBitmap;
  FPersonId := FDR.PersonId;
  FPercents := Ceil(FDR.Percents);
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

initialization
finalization
  F(AUIFaceRecognizerService);

end.
