unit uFaceDetectionThread;

interface

uses
  Classes, Graphics, uThreadEx, uThreadForm, uFaceDetection, uMemory;

type
  TFaceDetectionThread = class(TThreadEx)
  private
    FBitmap: TBitmap;
    FFaces: TFaceDetectionResult;
  protected
    procedure Execute; override;
    procedure UpdateFaceList;
  public
    constructor Create(AOwnerForm: TThreadForm; AState: TGUID; Bitmap: TBitmap);
    destructor Destroy; override;
  end;

implementation

uses
  SlideShow;

{ TFaceDetectionThread }

constructor TFaceDetectionThread.Create(AOwnerForm : TThreadForm; AState: TGUID; Bitmap: TBitmap);
begin
  inherited Create(AOwnerForm, AState);
  FBitmap := TBitmap.Create;
  FBitmap.Assign(Bitmap);
end;

destructor TFaceDetectionThread.Destroy;
begin
  F(FBitmap);
  inherited;
end;

procedure TFaceDetectionThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  Priority := tpLowest;
  FFaces := TFaceDetectionResult.Create;
  try
    FaceDetectionManager.FacesDetection(FBitmap, FFaces);
    if FFaces.Count > 0 then
      SynchronizeEx(UpdateFaceList);
  finally
    F(FFaces);
  end;
end;

procedure TFaceDetectionThread.UpdateFaceList;
begin
  TViewer(OwnerForm).UpdateFaces(FFaces);
end;

end.
