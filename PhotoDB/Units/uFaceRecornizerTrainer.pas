unit uFaceRecornizerTrainer;

interface

uses
  Winapi.Windows,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,  
  Dmitry.Graphics.Types,

  OpenCV.Utils,

  GraphicCrypt,

  uLogger,
  uMemory,
  uDBClasses,
  uDBContext,
  uDBManager,
  uDBEntities,
  uImageLoader,

  uFaceDetection,
  uFaceAnalyzer,
  uFaceRecognizer;

type
  TFaceRecornizerTrainer = class
  public
    procedure Train;
  end;

procedure TrainIt;

implementation

const
  FaceWidth = 64;
  FaceHeight = 64;
  FaceWidthToLoad = 128;
  FaceHeightToLoad = 128;

var
  TotalSuccess, TotalFail, PartialSuccess, Fail, Success, FailQuaility, SuccessQuality, TotalFaces: Integer;

procedure TrainIt;
var
  FR: TFaceRecornizerTrainer;
begin
  FR := TFaceRecornizerTrainer.Create;
  try
    FR.Train;
  finally
    F(FR);
  end;
end;

procedure ProcessFacesOnImage(MI: TMediaItem; Bitmap: TBitmap; ImageAreas: TPersonAreaCollection; Detector: TFaceDetectionManager; Recognizer: IFaceRecognizer; MinFaceScore: Byte; Logger: TStrings);
var
  I, J, PersonId: Integer;
  Area: TPersonArea;
  DR: TFaceScoreResults;
  FaceSample, FaceImage: TBitmap;
  FileName: string;
  PersonResults: TFaceRecognitionResults;
  DistanceLimit: Double;
  PersonFound, HasPartialSuccess, IsFail, IsSuccess: Boolean;
  PartialPosition: Integer;
begin
  for I := 0 to ImageAreas.Count - 1 do
  begin
    Area := ImageAreas[I];

    DR := ProcessFaceAreaOnImage(MI, Bitmap, Area, Detector, MinFaceScore);
    try
      if DR = nil then
        Continue;

      Inc(TotalFaces);

      IsFail := False;
      IsSuccess := False;
      HasPartialSuccess := False;
      PartialPosition := 0;

      FaceSample := TBitmap.Create;
      try
        DR.GenerateSample(FaceSample, FaceWidth, FaceHeight);

        FileName := FormatEx('d:\Faces\{0}', [Area.PersonID]);
        CreateDirA(FileName);
        FileName := FileName + FormatEx('\Face_{0}_{1}_{2}.bmp', [DR.TotalScore, Area.ID, Area.ImageID]);
        FaceSample.SaveToFile(FileName);

        PersonResults := Recognizer.RecognizeFace(FaceSample, 5);
        try
          if PersonResults.Count > 0 then
          begin
            PersonId := PersonResults[0].PersonId;

            DistanceLimit := LogN(9, Recognizer.GetFacesCount - 1) / 2.2;
            PersonFound := PersonId = Area.PersonID;

            if PersonFound then
            begin
              Inc(TotalSuccess);
              Inc(SuccessQuality, DR.TotalScore);
            end
            else
            begin
              Inc(TotalFail);
              Inc(FailQuaility, DR.TotalScore);
            end;

            if (PersonResults[0].Distance <= DistanceLimit) then
            begin
              if PersonFound then
                IsSuccess := True
              else
                IsFail := True;
            end;

            if not PersonFound then
            begin
              for J := 0 to PersonResults.Count - 1 do
                if PersonResults[J].IsValid and (PersonResults[J].PersonId = Area.PersonID) then
                begin
                  HasPartialSuccess := True;
                  PartialPosition := J + 1;
                end;
            end;

            if IsSuccess then
              Inc(Success);
            if IsFail then
              Inc(Fail);
            if HasPartialSuccess then
              Inc(PartialSuccess);

            //1: Faces: XXX
            //2: MinDistance: XXX
            //3: Threshold: XXX
            //4: IsFailed: 1/0
            //5: IsSuccess: 1/0
            //6: Position: 0-5

            Logger.Add(FormatEx('{1}{0}{2}{0}{3}{0}{4}{0}{5}{0}{6}{0}{7}{0}{8}', [#9,
              Recognizer.GetFacesCount,
              PersonResults[0].Distance,
              DistanceLimit,
              not PersonFound,
              PersonFound,
              HasPartialSuccess,
              PartialPosition,
              PersonResults[0].HasNegative
            ]));
            Logger.SaveToFile('D:\train.txt');
          end;
        finally
          F(PersonResults);
        end;

        //TODO do not train always?
        if not IsSuccess then
        begin
          FaceImage := nil;
          if DR.FaceImage <> nil then
          begin
            FaceImage := TBitmap.Create;
            FaceImage.Assign(DR.FaceImage);
          end;
          if Recognizer.TrainFace(FaceSample, FaceImage, Area.PersonID, Area.ID, DR.TotalScore) then
          begin
            //PersonId := Recognizer.DetectFace(FaceSample, DR.TotalScore);
            //if (PersonId <> Area.PersonID) and (PersonId > 0) then
            //  Inc(TotalFail);
          end;
        end;
      finally
        F(FaceSample);
      end;

    finally
      F(DR);
    end;
  end;
end;

{ TFaceRecornizerTrainer }

procedure TFaceRecornizerTrainer.Train;
var
  N, I, J: Integer;
  DBContext: IDBContext;
  Media: IMediaRepository;
  People: IPeopleRepository;
  TopImages: TMediaItemCollection;
  ImageAreas: TPersonAreaCollection;
  Area, MinArea: TPersonArea;
  MI: TMediaItem;
  ImageInfo: ILoadImageInfo;
  FaceMinSize, ImageSize, RequiredImageSize: TSize;
  Proportions: Double;
  FaceRect: TRect;
  B: TBitmap;
  Detector: TFaceDetectionManager;
  Recognizer: IFaceRecognizer;

  MaxFaces: Integer;
  FacesPerPerson: Integer;
  PicturesToProcess: Integer;
  FaceScore: Integer;

  Infos: TStrings;
begin
  Infos := TStringList.Create;
  try

    MaxFaces := 80;
    FacesPerPerson := 10;
    PicturesToProcess := 10000;
    FaceScore := 0;

    for N in [1] do
    begin
      Infos.Add(FormatEx('SEPARATOR:{0}', [#9]));
      Infos.Add(FormatEx('MaxFaces = {0}, FacesPerPerson = {1}, PicturesToProcess = {2}, FaceScore = {3}', [MaxFaces, FacesPerPerson, PicturesToProcess, FaceScore]));

      Detector := TFaceDetectionManager.Create;
      Recognizer := TFaceEigenRecognizer.Create(FaceWidth, FaceHeight, FacesPerPerson, MaxFaces);
      try
        TotalSuccess := 0;
        TotalFail := 0;
        FailQuaility := 0;
        SuccessQuality := 0;
        Success := 0;
        Fail := 0;
        PartialSuccess := 0;
        TotalFaces := 0;
        DBContext := DBManager.DBContext;
        Media := DBContext.Media;
        People := DBContext.People;
        TopImages := Media.GetTopImagesWithPersons(Now - 2000, PicturesToProcess);
        try
          for I := 0 to TopImages.Count - 1 do
          begin
            MI := TopImages[I];
            if FileExists(MI.FileName) and not ValidCryptGraphicFile(MI.FileName) then
            begin
              ImageAreas := People.GetAreasOnImage(MI.ID);
              try

                if (ImageAreas.Count > 0) then
                begin
                  ImageSize.Width := MI.Width;
                  ImageSize.Height := MI.Height;
                  FaceMinSize := ImageSize;

                  MinArea := ImageAreas[0];

                  //search for minimum face
                  for J := 0 to ImageAreas.Count - 1 do
                  begin
                    Area := ImageAreas[J];
                    if ((Area.Width < FaceMinSize.Width) or (Area.Height < FaceMinSize.Height)) and (FaceMinSize.Height > 0) and (FaceMinSize.Height > 0) then
                      MinArea := Area;
                  end;

                  FaceRect := CalculateRectOnImage(MinArea, ImageSize);

                  if (FaceRect.Width > 0) and (FaceRect.Height > 0) then
                  begin
                    //calculate proportions to load image to reach min image size with required size of person image
                    Proportions := Min(FaceRect.Width / FaceWidthToLoad, FaceRect.Height / FaceHeightToLoad);
                    RequiredImageSize.Width := Floor(ImageSize.Width / Proportions);
                    RequiredImageSize.Height := Floor(ImageSize.Height / Proportions);

                    if LoadImageFromPath(MI, 1, '', [ilfGraphic, ilfDontUpdateInfo, ilfUseCache], ImageInfo, RequiredImageSize.Width, RequiredImageSize.Height) then
                    begin
                      B := ImageInfo.GenerateBitmap(MI, RequiredImageSize.Width, RequiredImageSize.Height, pf24Bit, clBlack, [ilboFreeGraphic, ilboRotate]);
                      try
                        ProcessFacesOnImage(MI, B, ImageAreas, Detector, Recognizer, FaceScore, Infos);
                      finally
                        F(B);
                      end;
                    end;
                  end;
                end;

              finally
                F(ImageAreas);
              end;

            end;
          end;
        finally
          F(TopImages);
        end;
        Recognizer.SaveState('D:\TrainSaved');
      finally
        F(Detector);
        Recognizer := nil;
      end;

      Infos.Add(FormatEx('DONE', []));
      Infos.Add(FormatEx('TotalSuccess{0}TotalFail{0}Success{0}Fail{0}PartialSuccess{0}TotalFaces', [#9]));
      Infos.Add(FormatEx('{1}{0}{2}{0}{3}{0}{4}{0}{5}{0}{6}', [#9, TotalSuccess, TotalFail, Success, Fail, PartialSuccess, TotalFaces]));
      Infos.SaveToFile('D:\train.txt');
    end;
  finally
    F(Infos);
  end;
end;

end.
