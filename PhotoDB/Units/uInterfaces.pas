unit uInterfaces;

interface

uses
  UnitDBDeclare,
  CommonDBSupport,
  uFaceDetection;

type
  IDBImageSettings = interface(IInterface)
  ['{97343698-242E-4EB5-8972-5C443A97E1EA}']
    function GetImageOptions: TImageDBOptions;
  end;

  IFaceResultForm = interface(IInterface)
  ['{E31CA018-DE43-4508-A075-4CB130448581}']
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
  end;

implementation

end.
