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
  u2DUtils,
  uBitmapUtils,

  uFaceDetection,
  uFaceRecognizer,

  Core_c,
  Core.types_c,
  imgproc_c,
  imgproc.types_c;

type
  TFaceRecornizerTrainer = class
  public
    procedure Train;
  end;

  TFaceScoreResults = class
  private
    FFace: TFaceDetectionResultItem;
    FMouth: TFaceDetectionResultItem;
    FLeftEye: TFaceDetectionResultItem;
    FNose: TFaceDetectionResultItem;
    FRightEye: TFaceDetectionResultItem;
    FFaceImage: TBitmap;
    function GetTotalScore: Byte;
    function GetHasBothEyes: Boolean;
    function GetEyesAngle: Double;
    function GetHasSingleEye: Boolean;
    function GetHasMouth: Boolean;
    function GetHasNose: Boolean;
    function GetMouseNouseAngle: Double;
    function GetEyeMouthAngle: Double;
    function GetFaceAngle: Double;
  public
    constructor Create(FaceImage: pIplImage; AFace, ALeftEye, ARightEye, ANose, AMouth: TFaceDetectionResultItem);
    destructor Destroy; override;

    procedure GenerateSample(Bitmap: TBitmap; Width, Height: Integer);

    property FaceImage: TBitmap read FFaceImage;

    property Face: TFaceDetectionResultItem read FFace;
    property LeftEye: TFaceDetectionResultItem read FLeftEye;
    property RightEye: TFaceDetectionResultItem read FRightEye;
    property Nose: TFaceDetectionResultItem read FNose;
    property Mouth: TFaceDetectionResultItem read FMouth;
    property TotalScore: Byte read GetTotalScore;

    property HasBothEyes: Boolean read GetHasBothEyes;
    property HasSingleEye: Boolean read GetHasSingleEye;
    property HasMouth: Boolean read GetHasMouth;
    property HasNose: Boolean read GetHasNose;

    //all angles in Rad
    property FaceAngle: Double read GetFaceAngle;
    property EyesAngle: Double read GetEyesAngle;
    //should be about 25% (statistics) - canculate difference
    property EyeMouthAngle: Double read GetEyeMouthAngle;
    property MouseNouseAngle: Double read GetMouseNouseAngle;
  end;

procedure TrainIt;

implementation

const
  FaceWidthToLoad = 128;
  FaceHeightToLoad = 128;
  FaceWidth = 64;
  FaceHeight = 64;

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

procedure Swap(var P1, P2: Pointer);
var
  X: Pointer;
begin
  X := P1;
  P1 := P2;
  P2 := X;
end;

function CalculateRectOnImage(Area: TPersonArea; ImageSize: TSize): TRect;
var
  P1, P2: TPoint;
  S: TSize;
begin
  Result := Rect(Area.X, Area.Y, Area.X + Area.Width, Area.Y + Area.Height);
  P1 := Result.TopLeft;
  P2 := Result.BottomRight;
  S.cx := Area.FullWidth;
  S.cy := Area.FullHeight;

  P1 := PxMultiply(P1, S, ImageSize);
  P2 := PxMultiply(P2, S, ImageSize);
  Result := Rect(P1, P2);
end;

function ClipRectToRect(RectToClip, Rect: TRect): TRect;
begin
  if RectToClip.Top < Rect.Top then
    RectToClip.Top := Rect.Top;
  if RectToClip.Left < Rect.Left then
    RectToClip.Left := Rect.Left;
  if RectToClip.Right > Rect.Right then
    RectToClip.Right := Rect.Right;
  if RectToClip.Bottom > Rect.Bottom then
    RectToClip.Bottom := Rect.Bottom;

  Result := RectToClip;
end;

procedure DrawDetectRect(Bitmap: TBitmap; Rect: TFaceDetectionResultItem; Color: TColor);
begin
  if Rect = nil then
    Exit;
  Bitmap.Canvas.Pen.Color := Color;
  Bitmap.Canvas.Brush.Style := bsClear;
  Bitmap.Canvas.Rectangle(Rect.Rect);
end;

procedure DrawDetectRects(Bitmap: TBitmap; Rects: TFaceDetectionResult; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to Rects.Count - 1 do
    DrawDetectRect(Bitmap, Rects[I], Color);
end;

procedure DrawDetectRectFace(Bitmap: TBitmap; Rect: TFaceDetectionResultItem; Color: TColor);
const
  W = 5;
  H = 7;
var
  I: Integer;
  R: TRect;
begin
  R := Rect.Rect;
  Bitmap.Canvas.Pen.Color := Color;
  Bitmap.Canvas.Brush.Style := bsClear;
  Bitmap.Canvas.Rectangle(R);
  for I := 1 to W - 1 do
  begin
    Bitmap.Canvas.MoveTo(R.Left + (I * R.Width) div W, R.Top);
    Bitmap.Canvas.LineTo(R.Left + (I * R.Width) div W, R.Height + R.Top);
  end;
  for I := 1 to H - 1 do
  begin
    Bitmap.Canvas.MoveTo(R.Left, (I * R.Height) div H + R.Top);
    Bitmap.Canvas.LineTo(R.Left + R.Width, (I * R.Height) div H + R.Top);
  end;
  Bitmap.Canvas.MoveTo(R.Left + (R.Width) div 2, R.Top);
  Bitmap.Canvas.LineTo(R.Left + (R.Width) div 2, R.Height + R.Top);
  Bitmap.Canvas.MoveTo(R.Left, (R.Height) div 2 + R.Top);
  Bitmap.Canvas.LineTo(R.Left + R.Width, (R.Height) div 2 + R.Top);
end;

procedure DrawDetectRectsFace(Bitmap: TBitmap; Rects: TFaceDetectionResult; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to Rects.Count - 1 do
    DrawDetectRectFace(Bitmap, Rects[I], Color);
end;

procedure TrimResultsToRect(Rect: TRect; Results: TFaceDetectionResult);
var
  I: Integer;
begin
  for I := Results.Count - 1 downto 0 do
  begin
    if not RectInRect(Rect, Results[I].Rect) then
      Results.DeleteAt(I);
  end;
end;

function ProcessFaceOnImage(FaceImage: PIplImage; Detector: TFaceDetectionManager): TFaceScoreResults;
var
  I: Integer;
  D, DMin, DMax: Double;
  FaceRect, MouthRect, MouthRectShouldBe, EyeRect: TRect;
  FaceItem, NoseRectItem, MouthRectItem, LeftEyeItem, RightEyeItem: TFaceDetectionResultItem;
  FaceRects, NoseRects, MouthRects, EyeRects: TFaceDetectionResult;

  function Distance(P1, P2: TPoint): Double;
  begin
    Result := Sqrt(Sqr(P1.X - P2.X) + Sqr(P1.Y - P2.Y));
  end;

  function FindEyeToCenterDistance(FaceAreaRect: TRect; Eye: TRect): double;
  var
    D: Double;

    procedure ProcessPoint(P: TPoint);
    begin
      if PtInRect(FaceAreaRect, Eye.CenterPoint) then
      begin
        D := Distance(P, FaceAreaRect.CenterPoint);
        if D < Result then
          Result := D;
      end;
    end;

  begin
    Result := MaxDouble;

    ProcessPoint(Eye.TopLeft);
    ProcessPoint(Point(Eye.Top, Eye.Right));
    ProcessPoint(Eye.BottomRight);
    ProcessPoint(Point(Eye.Bottom, Eye.Left));
  end;

begin
  Result := nil;
  NoseRectItem := nil;
  MouthRectItem := nil;
  LeftEyeItem := nil;
  RightEyeItem := nil;

  FaceRects := TFaceDetectionResult.Create;
  NoseRects := TFaceDetectionResult.Create;
  MouthRects := TFaceDetectionResult.Create;
  EyeRects := TFaceDetectionResult.Create;
  try
    Detector.FacesDetection(FaceImage, 1, FaceRects, 'haarcascade_frontalface_alt.xml');
    if (FaceRects.Count = 0) then
      Exit;

    FaceItem := FaceRects[0];
    for I := 1 to FaceRects.Count - 1 do
    begin
      if (FaceRects[I].Width > FaceItem.Rect.Width) or (FaceRects[I].Height > FaceItem.Rect.Height) then
        FaceItem := FaceRects[I];
    end;
    FaceRect := FaceItem.Rect;

    Detector.FacesDetection(FaceImage, 1, NoseRects, 'haarcascade_mcs_nose.xml');
    TrimResultsToRect(FaceRect, NoseRects);

    if NoseRects.Count > 0 then
    begin
      //search for nose in the center
      NoseRectItem := NoseRects[0];
      DMin := Distance(FaceRect.CenterPoint, NoseRectItem.Rect.CenterPoint);
      for I := 1 to NoseRects.Count - 1 do
      begin
        D := Distance(FaceRect.CenterPoint, NoseRects[I].Rect.CenterPoint);
        if D < DMin then
        begin
          DMin := D;
          NoseRectItem := NoseRects[I];
        end;
      end;
      for I := NoseRects.Count - 1 downto 0 do
        if NoseRects[I] <> NoseRectItem then
          NoseRects.DeleteAt(I);
    end;

    Detector.FacesDetection(FaceImage, 1, MouthRects, 'haarcascade_mcs_mouth.xml');
    MouthRect := Rect(FaceRect.Left, FaceRect.Top + FaceRect.Height div 2, FaceRect.Right, FaceRect.Bottom);
    TrimResultsToRect(MouthRect, MouthRects);
    //select mouth
    if MouthRects.Count > 0 then
    begin
      MouthRectShouldBe := Rect(
        FaceRect.Left + (FaceRect.Width * 2) div 5, FaceRect.Top + (FaceRect.Height * 5) div 7,
        FaceRect.Left + (FaceRect.Width * 3) div 5, FaceRect.Top + (FaceRect.Height * 6) div 7);
      MouthRectItem := MouthRects[0];
      DMax := RectIntersectWithRectPercent(MouthRectShouldBe, MouthRectItem.Rect);
      for I := 1 to MouthRects.Count - 1 do
      begin
        D := RectIntersectWithRectPercent(MouthRectShouldBe, MouthRects[I].Rect);
        if D > DMax then
        begin
          DMax := D;
          MouthRectItem := MouthRects[I];
        end;
      end;
      for I := MouthRects.Count - 1 downto 0 do
        if MouthRects[I] <> MouthRectItem then
          MouthRects.DeleteAt(I);
    end;

    Detector.FacesDetection(FaceImage, 1, EyeRects, 'haarcascade_eye.xml');
    EyeRect := Rect(FaceRect.Left, FaceRect.Top, FaceRect.Right, FaceRect.Top + Round((FaceRect.Height * 5.5) / 7));
    TrimResultsToRect(EyeRect, EyeRects);
    //remove eyes in nose
    if NoseRectItem <> nil then
    begin
      for I := EyeRects.Count - 1 downto 0 do
        if PtInRect(NoseRectItem.Rect, EyeRects[I].Rect.CenterPoint) then
          EyeRects.DeleteAt(I);
    end;
    if EyeRects.Count > 0 then
    begin
      //left eye (actually right)
      EyeRect := Rect(FaceRect.Left, FaceRect.Top, FaceRect.Left + FaceRect.Height div 2, FaceRect.Top + FaceRect.Height div 2);
      DMin := MaxDouble;
      for I := 0 to EyeRects.Count - 1 do
      begin
        D := FindEyeToCenterDistance(EyeRect, EyeRects[I].Rect);
        if D < DMin then
        begin
          DMin := D;
          LeftEyeItem := EyeRects[I];
        end;
      end;

      //right eye (actually left)
      EyeRect := Rect(FaceRect.Left + FaceRect.Width div 2, FaceRect.Top, FaceRect.Right, FaceRect.Top + FaceRect.Height div 2);
      DMin := MaxDouble;
      for I := 0 to EyeRects.Count - 1 do
      begin
        D := FindEyeToCenterDistance(EyeRect, EyeRects[I].Rect);
        if D < DMin then
        begin
          DMin := D;
          RightEyeItem := EyeRects[I];
        end;
      end;

      for I := EyeRects.Count - 1 downto 0 do
        if (EyeRects[I] <> RightEyeItem) and (EyeRects[I] <> LeftEyeItem) then
          EyeRects.DeleteAt(I);
    end;

    Result := TFaceScoreResults.Create(FaceImage, FaceItem, LeftEyeItem, RightEyeItem, NoseRectItem, MouthRectItem);
  finally
    F(FaceRects);
    F(NoseRects);
    F(MouthRects);
    F(EyeRects);
  end;
end;

procedure ApplyMask(Image, Mask: TBitmap);
var
  SmallMask, SmoothImage: TBitmap;
  I, J: Integer;
  CvImage, CvImageSmooth: pIplImage;
  PO, PG, PM: PARGB;
  W, W1: Byte;
begin
  SmallMask := TBitmap.Create;
  SmoothImage := TBitmap.Create;
  try
    SmallMask.PixelFormat := pf24bit;
    SmoothImage.PixelFormat := pf24bit;
    SmoothImage.SetSize(Image.Width, Image.Height);
    DoResize(Image.Width, Image.Height, Mask, SmallMask);

    CvImage := cvCreateImage(CvSize(Image.Width, Image.Height), IPL_DEPTH_8U, 3);     
    CvImageSmooth := cvCreateImage(CvSize(Image.Width, Image.Height), IPL_DEPTH_8U, 3);  
    try
      Bitmap2IplImage(CvImage, Image);
      cvSmooth(CvImage, CvImageSmooth, CV_GAUSSIAN, 9, 9, 300);
      IplImage2Bitmap(CvImageSmooth, SmoothImage);
      
      for I := 0 to Image.Height - 1 do
      begin
        PO := Image.ScanLine[I];  
        PG := SmoothImage.ScanLine[I];
        PM := SmallMask.ScanLine[I];
        
        for J := 0 to Image.Width - 1 do
        begin
          W := PM[J].B;
          W1 := 255 - W;
          PO[J].R := (PO[J].R * W1 + 255 * W + $7F) div $FF;
          PO[J].G := (PO[J].G * W1 + 255 * W + $7F) div $FF;
          PO[J].B := (PO[J].B * W1 + 255 * W + $7F) div $FF;

         { PO[J].R := (PO[J].R * W1 + PG[J].R * W + $7F) div $FF;
          PO[J].G := (PO[J].G * W1 + PG[J].G * W + $7F) div $FF;
          PO[J].B := (PO[J].B * W1 + PG[J].B * W + $7F) div $FF;  }
        end;
      end;
    finally
      cvReleaseImage(CvImage); 
      cvReleaseImage(CvImageSmooth);
    end;
  finally
    F(SmallMask);
    F(SmoothImage);
  end;
end;

function ProcessFaceAreaOnImage(MI: TMediaItem; Bitmap: TBitmap; Area: TPersonArea; Detector: TFaceDetectionManager; MinScore: Byte): TFaceScoreResults;
const
  LoadFaceCf = 1.5;
var
  ImageRect, R: TRect;
  FaceBitmap: TBitmap;
  FaceImage: pIplImage;
  ImageSize: TSize;
  FaceSize: TCvSize;
  DetectionResult, DR: TFaceScoreResults;
  Angle: Double;
  RotMat: pCvMat;
  RotCenter: TcvPoint2D32f;
  Scale: Double;
  RotatedImage: pIplImage;
  FileName: string;

  procedure DrawDetectionDebugInfo(Bitmap: TBitmap; DetectionInfo: TFaceScoreResults);
  begin
    DrawTransparentColor(Bitmap, clWhite, 0, 0, Bitmap.Width, Bitmap.Height, 127);
    DrawDetectRectFace(Bitmap, DetectionInfo.Face, clRed);
    DrawDetectRect(Bitmap, DetectionInfo.Nose, clWhite);
    DrawDetectRect(Bitmap, DetectionInfo.Mouth, clGreen);
    DrawDetectRect(Bitmap, DetectionInfo.LeftEye, clBlue);
    DrawDetectRect(Bitmap, DetectionInfo.RightEye, clBlue);
    Bitmap.Canvas.TextOut(10, 10, IntToStr(DetectionInfo.TotalScore));
  end;

begin
  Result := nil;
  FaceBitmap := TBitmap.Create;
  try
    FaceBitmap.PixelFormat := pf24bit;
    ImageSize.Width := Bitmap.Width;
    ImageSize.Height := Bitmap.Height;
    ImageRect := Rect(0, 0, ImageSize.Width, ImageSize.Height);

    R := CalculateRectOnImage(Area, ImageSize);
    InflateRect(R, Round(R.Width / (2 * LoadFaceCf)), Round(R.Height / (2 * LoadFaceCf)));
    R := ClipRectToRect(R, ImageRect);
    FaceBitmap.SetSize(R.Width, R.Height);
    DrawImageExRect(FaceBitmap, Bitmap, R.Left, R.Top, R.Width, R.Height, 0, 0);

    FaceSize.width := FaceBitmap.Width;
    FaceSize.height := FaceBitmap.Height;
    FaceImage := cvCreateImage(FaceSize, IPL_DEPTH_8U, 3);
    try
      Bitmap2IplImage(FaceImage, FaceBitmap);
      DetectionResult := ProcessFaceOnImage(FaceImage, Detector);
      try
        if DetectionResult = nil then
          Exit;

        if DetectionResult.TotalScore < MinScore then
          Exit;

        //try to rotate
        Angle := DetectionResult.FaceAngle;

        if Angle <> 0 then
        begin
          // Rotate image
          RotMat := cvCreateMat(2, 3, CV_32FC1);
          // Rotate with base in center
          RotCenter.x := FaceImage.width div 2;
          RotCenter.y := FaceImage.height div 2;
          Scale := 1;
          cv2DRotationMatrix(RotCenter, Angle * 180 / PI, Scale, RotMat);

          RotatedImage := cvCreateImage(cvSize(FaceImage.width, FaceImage.height), FaceImage.depth, FaceImage.nChannels);
          try
            // Apply rotation
            cvWarpAffine(FaceImage, RotatedImage, RotMat, CV_INTER_LINEAR or CV_WARP_FILL_OUTLIERS, cvScalarAll(0));

            DR := ProcessFaceOnImage(RotatedImage, Detector);
            try
              if (DR <> nil) and (DR.TotalScore > DetectionResult.TotalScore) then
              begin
                Swap(Pointer(DetectionResult), Pointer(DR));
                IplImage2Bitmap(RotatedImage, FaceBitmap);
              end;
            finally
              F(DR);
            end;

          finally
            cvReleaseImage(RotatedImage);
          end;
        end;

        DrawDetectionDebugInfo(FaceBitmap, DetectionResult);
        FaceBitmap.Canvas.TextOut(10, 30, FloatToStrEx(DetectionResult.FaceAngle * 180 / PI, 2));

        FileName := FormatEx('d:\Faces\{0}', [Area.PersonID]);
        CreateDirA(FileName);
        FileName := FileName + FormatEx('\Face_{0}_{1}_{2}_dbg.bmp', [DetectionResult.TotalScore, Area.ID, Area.ImageID]);
        FaceBitmap.SaveToFile(FileName);

        Swap(Pointer(Result), Pointer(DetectionResult));
      finally
        F(DetectionResult);
      end;
    finally
      cvReleaseImage(FaceImage);
    end;
  finally
    F(FaceBitmap);
  end;
end;

procedure ProcessFacesOnImage(MI: TMediaItem; Bitmap: TBitmap; ImageAreas: TPersonAreaCollection; Detector: TFaceDetectionManager; Recognizer: IFaceRecognizer; MinFaceScore: Byte; Logger: TStrings);
var
  I, J, PersonId: Integer;
  Area: TPersonArea;
  DR: TFaceScoreResults;
  FaceSample: TBitmap;
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

      PersonFound := False;
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

        PersonId := 0;
        PersonResults := Recognizer.DetectFace(FaceSample, DR.TotalScore, 5);
        if Length(PersonResults) > 0 then
        begin
          PersonId := PersonResults[0].PersonId;

          DistanceLimit := Log10(Recognizer.GetFacesCount - 1) / 2.3;
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
            for J := 0 to Length(PersonResults) - 1 do
              if PersonResults[J].PersonId = Area.PersonID then
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

        //TODO do not train always?
        if not IsSuccess then
        begin
          if Recognizer.TrainFace(FaceSample, Area.PersonID, DR.TotalScore) then
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

    MaxFaces := 70;
    FacesPerPerson := 20;
    PicturesToProcess := 10000;
    FaceScore := 60;

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
          //Recognizer.SaveState('D:\TrainSaved');
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

{ TFaceScoreResults }

constructor TFaceScoreResults.Create(FaceImage: pIplImage; AFace, ALeftEye, ARightEye, ANose,
  AMouth: TFaceDetectionResultItem);
var
  R: TRect;
  B: TBitmap;
begin
  FFace := AFace.Copy;

  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    B.SetSize(FaceImage.width, FaceImage.height);
    IplImage2Bitmap(FaceImage, B);

    FFaceImage := TBitmap.Create;
    FFaceImage.PixelFormat := pf24Bit;
    FFaceImage.SetSize(AFace.Width, AFace.Height);
    R := FFace.Rect;
    DrawImageExRect(FFaceImage, B, R.Left, R.Top, R.Width, R.Height, 0, 0);
  finally
    F(B);
  end;

  FLeftEye := nil;
  FRightEye := nil;
  FNose := nil;
  FMouth := nil;

  if ALeftEye <> nil then
    FLeftEye := ALeftEye.Copy;

  if ARightEye <> nil then
    FRightEye := ARightEye.Copy;

  if ANose <> nil then
    FNose := ANose.Copy;

  if AMouth <> nil then
    FMouth := AMouth.Copy;
end;

destructor TFaceScoreResults.Destroy;
begin
  F(FFaceImage);
  F(FFace);
  F(FLeftEye);
  F(FRightEye);
  F(FNose);
  F(FMouth);
  inherited;
end;

procedure TFaceScoreResults.GenerateSample(Bitmap: TBitmap; Width, Height: Integer);
var
  FaceMask: TBitmap;
{  Face: TBitmap;
  R: TRect;
  Dx, Dy: Integer;
  Proportions: Double;  }

  procedure UpdateBitmap(Source: TBitmap);
  begin
    DoResize(Width, Height, Source, Bitmap);
    FaceMask := TBitmap.Create;
    try
      FaceMask.LoadFromFile('D:\Dmitry\Delphi exe\mask.bmp');
      FaceMask.PixelFormat := pf24bit;

      ApplyMask(Bitmap, FaceMask);
    finally
      F(FaceMask);
    end;
  end;

begin
  {if TotalScore >= 80 then
  begin
    R := Rect(FFaceImage.Width div 2, FFaceImage.Height div 2, FFaceImage.Width div 2, FFaceImage.Height div 2);
    if FLeftEye <> nil then
      UnionRect(R, R, FLeftEye.Rect);
    if FRightEye <> nil then
      UnionRect(R, R, FRightEye.Rect);
    if FNose <> nil then
      UnionRect(R, R, FNose.Rect);
    if FMouth <> nil then
      UnionRect(R, R, FNose.Rect);

    Face := TBitmap.Create;
    try

      Proportions := Width / Height;
      if R.Width / R.Height > Proportions then
      begin
        Dy := Round(R.Width / Proportions - R.Height);
        InflateRect(R, 0, Dy div 2);
      end else
      begin
        Dx := Round(R.Height * Proportions - R.Width);
        InflateRect(R, Dx div 2, 0);
      end;

      Face.SetSize(R.Width, R.Height);
      Face.PixelFormat := pf24bit;

      DrawImageExRect(Face, FFaceImage, R.Left, R.Top, R.Width, R.Height, 0, 0);
      UpdateBitmap(Face);
    finally
      F(Face);
    end;
    Exit;
  end;}

  UpdateBitmap(FFaceImage);
end;

function TFaceScoreResults.GetEyeMouthAngle: Double;
const
  SHOULD_BE_ANGLE = 25 * PI / 180;
var
  P1, P2: TPoint;
begin
  Result := 0;
  if HasSingleEye and HasMouth then
  begin
    if FLeftEye <> nil then
    begin
      P1 := LeftEye.Rect.CenterPoint;
      P2 := FMouth.Rect.CenterPoint;
      if (P1.X <> P2.X) then
        Result := SHOULD_BE_ANGLE - ArcTan((P1.X - P2.X) / (P1.Y - P2.Y));

    end;
    if FRightEye <> nil then
    begin
      P1 := FRightEye.Rect.CenterPoint;
      P2 := FMouth.Rect.CenterPoint;
      if (P1.X <> P2.X) then
        Result := - SHOULD_BE_ANGLE - ArcTan((P1.X - P2.X) / (P1.Y - P2.Y));

    end;
  end;
end;

function TFaceScoreResults.GetEyesAngle: Double;
var
  P1, P2: TPoint;
begin
  Result := 0;
  if HasBothEyes then
  begin
    P1 := LeftEye.Rect.CenterPoint;
    P2 := RightEye.Rect.CenterPoint;
    if (P1.Y <> P2.Y) then
      Result := ArcTan((P1.Y - P2.Y) / (P1.X - P2.X));
  end;
end;

function TFaceScoreResults.GetFaceAngle: Double;
begin
  Result := 0;
  if (HasBothEyes) then
    Result := EyesAngle
  else if HasSingleEye and HasMouth then
    Result := EyeMouthAngle
  else if HasMouth and HasNose then
    Result := MouseNouseAngle;
end;

function TFaceScoreResults.GetMouseNouseAngle: Double;
var
  P1, P2: TPoint;
begin
  Result := 0;
  if HasMouth and HasNose then
  begin
    P1 := FNose.Rect.CenterPoint;
    P2 := FMouth.Rect.CenterPoint;
    if (P1.X <> P2.X) then
      Result := ArcTan((P1.X - P2.X) / (P1.Y - P2.Y));
  end;
end;

function TFaceScoreResults.GetHasBothEyes: Boolean;
begin
  Result := (FLeftEye <> nil) and (FRightEye <> nil);
end;

function TFaceScoreResults.GetHasMouth: Boolean;
begin
  Result := FMouth <> nil;
end;

function TFaceScoreResults.GetHasNose: Boolean;
begin
  Result := FNose <> nil;
end;

function TFaceScoreResults.GetHasSingleEye: Boolean;
begin
  Result := not HasBothEyes and ((FLeftEye <> nil) or (FRightEye <> nil));
end;

function TFaceScoreResults.GetTotalScore: Byte;
begin
  Result := 0;
  if FLeftEye <> nil then
    Inc(Result, 30);
  if FRightEye <> nil then
    Inc(Result, 30);
  if FMouth <> nil then
    Inc(Result, 20);
  if FNose <> nil then
    Inc(Result, 20);

  Result := Round(Result / (1 + Abs(FaceAngle)));
end;

end.
