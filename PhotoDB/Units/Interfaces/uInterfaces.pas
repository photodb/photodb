unit uInterfaces;

interface

uses
  UnitDBDeclare,

  uDBEntities,
  uFaceDetection;

type
  IObjectSource = interface(IInterface)
    function GetObject: TObject;
  end;

  IDBImageSettings = interface(IInterface)
  ['{97343698-242E-4EB5-8972-5C443A97E1EA}']
    function GetImageOptions: TSettings;
  end;

  IFaceResultForm = interface(IObjectSource)
  ['{E31CA018-DE43-4508-A075-4CB130448581}']
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
  end;

  IEncryptErrorHandlerForm = interface(IInterface)
  ['{B734F360-B4DE-4F29-8658-B51D32BB44AE}']
    procedure HandleEncryptionError(FileName: string; ErrorMessage: string);
  end;

  IDirectoryWatcher = interface(IInterface)
    ['{887A08D0-3D36-4744-9241-9454BAAA9D53}']
    procedure DirectoryChanged(Sender: TObject; SID: TGUID; pInfos: TInfoCallBackDirectoryChangedArray; WatchType: TDirectoryWatchType);
    procedure TerminateWatcher(Sender: TObject; SID: TGUID; Folder: string);
  end;

implementation

end.
