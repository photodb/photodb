unit uFaceAnalyzer;

interface

uses
  Winapi.Windows,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Imaging.pngImage,

  Dmitry.Utils.System,
  Dmitry.Graphics.Types,

  OpenCV.Utils,

  uMemory,
  uDBEntities,
  u2DUtils,
  uBitmapUtils,
  uResources,
  uFaceDetection,

  Core_c,
  Core.types_c,
  imgproc_c,
  imgproc.types_c;

type
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

function ProcessFaceAreaOnImage(MI: TMediaItem; Bitmap: TBitmap; Area: TPersonArea; Detector: TFaceDetectionManager; MinScore: Byte): TFaceScoreResults;
function CalculateRectOnImage(Area: TPersonArea; ImageSize: TSize): TRect;

implementation

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
  SmallMask: TBitmap;
  I, J: Integer;
  CvImage: pIplImage;
  PO, PM: PARGB;
  W, W1: Byte;
begin
  SmallMask := TBitmap.Create;
  try
    SmallMask.PixelFormat := pf24bit;
    DoResize(Image.Width, Image.Height, Mask, SmallMask);

    CvImage := cvCreateImage(CvSize(Image.Width, Image.Height), IPL_DEPTH_8U, 3);
    try
      Bitmap2IplImage(CvImage, Image);

      for I := 0 to Image.Height - 1 do
      begin
        PO := Image.ScanLine[I];
        PM := SmallMask.ScanLine[I];

        for J := 0 to Image.Width - 1 do
        begin
          W := PM[J].B;
          W1 := 255 - W;
          PO[J].R := (PO[J].R * W1 + 255 * W + $7F) div $FF;
          PO[J].G := (PO[J].G * W1 + 255 * W + $7F) div $FF;
          PO[J].B := (PO[J].B * W1 + 255 * W + $7F) div $FF;
        end;
      end;
    finally
      cvReleaseImage(CvImage);
    end;
  finally
    F(SmallMask);
  end;
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

procedure Swap(var P1, P2: Pointer);
var
  X: Pointer;
begin
  X := P1;
  P1 := P2;
  P2 := X;
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
  //FileName: string;

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

    KeepProportions(FaceBitmap, 128, 128);
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

        (*

        DrawDetectionDebugInfo(FaceBitmap, DetectionResult);
        FaceBitmap.Canvas.TextOut(10, 30, FloatToStrEx(DetectionResult.FaceAngle * 180 / PI, 2));

        FileName := FormatEx('d:\Faces\{0}', [Area.PersonID]);
        CreateDirA(FileName);
        FileName := FileName + FormatEx('\Face_{0}_{1}_{2}_dbg.bmp', [DetectionResult.TotalScore, Area.ID, Area.ImageID]);
        FaceBitmap.SaveToFile(FileName);

        *)

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

procedure TFaceScoreResults.GenerateSample(Bitmap: TBitmap; Width, Height: Integer);
var
  FaceMask: TBitmap;
{  Face: TBitmap;
  R: TRect;
  Dx, Dy: Integer;
  Proportions: Double;  }

  procedure UpdateBitmap(Source: TBitmap);
  var
    MaskPng: TPngImage;
  begin
    DoResize(Width, Height, Source, Bitmap);
    FaceMask := TBitmap.Create;
    try
      MaskPng := GetFaceMaskImage;
      try
        FaceMask.Assign(MaskPng);
        FaceMask.PixelFormat := pf24bit;
        ApplyMask(Bitmap, FaceMask);
      finally
        F(MaskPng);
      end;
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

end.
