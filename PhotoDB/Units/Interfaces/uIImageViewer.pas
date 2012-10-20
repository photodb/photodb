unit uIImageViewer;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ComCtrls,

  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WebLink,

  UnitDBDeclare,

  uInterfaces,
  uDBPopupMenuInfo,
  uFaceDetection,
  uThreadForm;

type
  TPersonsFoundOnImageEvent = procedure(Sender: TObject; FileName: string; Items: TFaceDetectionResult) of object;

type
  IImageViewer = interface(IFaceResultForm)
    procedure AttachTo(OwnerForm: TThreadForm; Control: TWinControl; X, Y: Integer);
    procedure LoadFiles(FileList: TDBPopupMenuInfo);
    procedure LoadPreviousFile;
    procedure LoadNextFile;
    procedure SetText(Text: string);
    procedure ResizeTo(Width, Height: Integer);
    procedure SetStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure SetAnimatedImage(Image: TGraphic; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure ZoomOut;
    procedure ZoomIn;

    procedure SetFaceDetectionControls(AWlFaceCount: TWebLink; ALsDetectingFaces: TLoadingSign; ATbrActions: TToolBar);
    procedure FinishDetectionFaces;
    procedure SelectPerson(PersonID: Integer);
    procedure ResetPersonSelection;

    procedure UpdateAvatar(PersonID: Integer);

    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetLeft: Integer;
    function GetActiveThreadId: TGUID;
    function GetItem: TDBPopupMenuInfoRecord;
    function GetDisplayBitmap: TBitmap;
    function GetCurentFile: string;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Top: Integer read GetTop;
    property Left: Integer read GetLeft;
    property ActiveThreadId: TGUID read GetActiveThreadId;
    property Item: TDBPopupMenuInfoRecord read GetItem;
    property DisplayBitmap: TBitmap read GetDisplayBitmap;
    property CurentFile: string read GetCurentFile;

    procedure SetOnBeginLoadingImage(Event: TNotifyEvent);
    function GetOnBeginLoadingImage: TNotifyEvent;
    procedure SetOnRequestNextImage(Event: TNotifyEvent);
    function GetOnRequestNextImage: TNotifyEvent;
    procedure SetOnRequestPreviousImage(Event: TNotifyEvent);
    function GetOnRequestPreviousImage: TNotifyEvent;
    procedure SetOnDblClick(Event: TNotifyEvent);
    function GetOnDblClick: TNotifyEvent;
    procedure SetOnPersonsFoundOnImage(Event: TPersonsFoundOnImageEvent);
    function GetOnPersonsFoundOnImage: TPersonsFoundOnImageEvent;

    property OnBeginLoadingImage: TNotifyEvent read GetOnBeginLoadingImage write SetOnBeginLoadingImage;
    property OnRequestNextImage: TNotifyEvent read GetOnRequestNextImage write SetOnRequestNextImage;
    property OnRequestPreviousImage: TNotifyEvent read GetOnRequestPreviousImage write SetOnRequestPreviousImage;
    property OnDblClick: TNotifyEvent read GetOnDblClick write SetOnDblClick;
    property OnPersonsFoundOnImage: TPersonsFoundOnImageEvent read GetOnPersonsFoundOnImage write SetOnPersonsFoundOnImage;
  end;

implementation

end.

