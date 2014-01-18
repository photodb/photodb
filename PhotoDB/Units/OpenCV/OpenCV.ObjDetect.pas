unit OpenCV.ObjDetect;

interface

uses
  Winapi.Windows,
  OpenCV.Lib,
  OpenCV.Core;

const
  CV_HAAR_FEATURE_MAX = 3;

const
  CV_HAAR_DO_CANNY_PRUNING = 1;
  CV_HAAR_SCALE_IMAGE = 2;
  CV_HAAR_FIND_BIGGEST_OBJECT = 4;
  CV_HAAR_DO_ROUGH_SEARCH = 8;

type
  TSumType = integer;
  pSumType = ^TSumType;

  Tsqsumtype = Double;
  psqsumtype = ^Tsqsumtype;

  TCvHidHaarFeatureRect = packed record
    p0, p1, p2, p3: pSumType;
  end;

  TCvHidHaarFeature = array [0 .. CV_HAAR_FEATURE_MAX - 1] of TCvHidHaarFeatureRect;

  pCvHidHaarTreeNode = ^TCvHidHaarTreeNode;

  TCvHidHaarTreeNode = packed record
    feature: TCvHidHaarFeature;
    threshold: Single;
    left: integer;
    right: integer;
  end;

  pCvHidHaarClassifier = ^TCvHidHaarClassifier;

  TCvHidHaarClassifier = packed record
    count: integer;
    // CvHaarFeature* orig_feature;
    node: pCvHidHaarTreeNode;
    alpha: pSingle;
  end;

  pCvHidHaarStageClassifier = ^TCvHidHaarStageClassifier;

  TCvHidHaarStageClassifier = packed record
    count: integer;
    threshold: Single;
    classifier: pCvHidHaarClassifier;
    two_rects: integer;

    next: pCvHidHaarStageClassifier;
    child: pCvHidHaarStageClassifier;
    parent: pCvHidHaarStageClassifier;
  end;

  TCvHidHaarClassifierCascade = packed record
    count: integer;
    isStumpBased: integer;
    has_tilted_features: integer;
    is_tree: integer;
    inv_window_area: Real;
    sum, sqsum, tilted: TCvMat;
    stage_classifier: pCvHidHaarStageClassifier;
    pq0, pq1, pq2, pq3: psqsumtype;
    p0, p1, p2, p3: pSumType;
    ipp_stages: pPointer;
  end;


  (*
  //****************************************************************************************\
  //*                         Haar-like Object Detection functions                           *
  //****************************************************************************************/
*)
Const
  CV_HAAR_MAGIC_VAL = $42500000;
  CV_TYPE_NAME_HAAR = 'opencv-haar-classifier';

  // #define CV_IS_HAAR_CLASSIFIER( haar )                                                    \
  // ((haar) != NULL &&                                                                   \
  // (((const CvHaarClassifierCascade*)(haar))->flags & CV_MAGIC_MASK)==CV_HAAR_MAGIC_VAL)

type
  THaarFeature = record
    r: TCvRect;
    weight: Single;
  end;

  pCvHaarFeature = ^TCvHaarFeature;

  TCvHaarFeature = packed record
    tilted: Integer;
    rect: array [0 .. CV_HAAR_FEATURE_MAX - 1] of THaarFeature;
  end;

  pCvHaarClassifier = ^TCvHaarClassifier;

  TCvHaarClassifier = packed record
    count: Integer;
    haar_feature: pCvHaarFeature;
    threshold: pSingle;
    left: pInteger;
    right: pInteger;
    alpha: pSingle;
  end;

  pCvHaarStageClassifier = ^TCvHaarStageClassifier;

  TCvHaarStageClassifier = packed record
    count: Integer;
    threshold: Single;
    classifier: pCvHaarClassifier;
    next: Integer;
    child: Integer;
    parent: Integer;
  end;

  // TCvHidHaarClassifierCascade = TCvHidHaarClassifierCascade;
  pCvHidHaarClassifierCascade = ^TCvHidHaarClassifierCascade;

  pCvHaarClassifierCascade = ^TCvHaarClassifierCascade;

  TCvHaarClassifierCascade = packed record
    flags: Integer;
    count: Integer;
    orig_window_size: TCvSize;
    real_window_size: TCvSize;
    scale: Real;
    stage_classifier: pCvHaarStageClassifier;
    hid_cascade: pCvHidHaarClassifierCascade;
  end;

  TCvAvgComp = packed record
    rect: TCvRect;
    neighbors: Integer;
  end;

var
{
  // Loads haar classifier cascade from a directory.
  // It is obsolete: convert your cascade to xml and use cvLoad instead
  CVAPI(CvHaarClassifierCascade*) cvLoadHaarClassifierCascade(
  const char* directory,
  CvSize orig_window_size);
}
  cvLoadHaarClassifierCascade: function(const directory: pCVChar; orig_window_size: TCvSize): pCvHaarClassifierCascade; cdecl = nil;

// CVAPI(void) cvReleaseHaarClassifierCascade( CvHaarClassifierCascade** cascade );
  cvReleaseHaarClassifierCascade: procedure(Var cascade: pCvHaarClassifierCascade); cdecl = nil;

{
  CVAPI(CvSeq*) cvHaarDetectObjects(
  const CvArr* image,
  CvHaarClassifierCascade* cascade,
  CvMemStorage* storage,
  double scale_factor CV_DEFAULT(1.1),
  int min_neighbors CV_DEFAULT(3),
  int flags CV_DEFAULT(0),
  CvSize min_size CV_DEFAULT(cvSize(0,0)),
  CvSize max_size CV_DEFAULT(cvSize(0,0)));
}
  cvHaarDetectObjects: function(
  { } const image: pIplImage;
  { } cascade: pCvHaarClassifierCascade;
  { } storage: pCvMemStorage;
  { } scale_factor: double { =1.1 };
  { } min_neighbors: Integer { =3 };
  { } flags: Integer { = 0 };
  { } min_size: TCvSize { =CV_DEFAULT(cvSize(0,0)) };
  { } max_size: TCvSize { =CV_DEFAULT(cvSize(0,0)) } ): pCvSeq; cdecl = nil;

function CvLoadObjDetectLib: Boolean;

implementation

var
  FObjDetectLib: THandle = 0;

function CvLoadObjDetectLib: Boolean;
begin
  Result := False;
  FObjDetectLib := LoadLibrary(objdetect_dll);
  if FObjDetectLib > 0 then
  begin
    Result := True;
    cvLoadHaarClassifierCascade := GetProcAddress(FObjDetectLib, 'cvLoadHaarClassifierCascade');
    cvReleaseHaarClassifierCascade := GetProcAddress(FObjDetectLib, 'cvReleaseHaarClassifierCascade');
    cvHaarDetectObjects := GetProcAddress(FObjDetectLib, 'cvHaarDetectObjects');
  end;
end;

end.
