unit uInterfaces;

interface

uses
  UnitDBDeclare,
  CommonDBSupport,
  uFaceDetection;

type
  IObjectSource = interface(IInterface)
    function GetObject: TObject;
  end;

  IDBImageSettings = interface(IInterface)
  ['{97343698-242E-4EB5-8972-5C443A97E1EA}']
    function GetImageOptions: TImageDBOptions;
  end;

  IFaceResultForm = interface(IObjectSource)
  ['{E31CA018-DE43-4508-A075-4CB130448581}']
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
  end;

  IEncryptErrorHandlerForm = interface(IInterface)
  ['{B734F360-B4DE-4F29-8658-B51D32BB44AE}']
    procedure HandleEncryptionError(FileName: string; ErrorMessage: string);
  end;

implementation

end.
