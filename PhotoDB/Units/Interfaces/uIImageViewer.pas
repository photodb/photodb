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
  TBeginLoadingImageEvent = procedure(Sender: TObject; NewImage: Boolean) of object;

type
  IImageViewer = interface(IFaceResultForm)
    procedure AttachTo(OwnerForm: TThreadForm; Control: TWinControl; X, Y: Integer);
    procedure LoadFiles(FileList: TDBPopupMenuInfo);
    procedure LoadPreviousFile;
    procedure LoadNextFile;
    function GetText: string;
    procedure SetText(Text: string);
    procedure ResizeTo(Width, Height: Integer);
    procedure SetStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure SetAnimatedImage(Image: TGraphic; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure FailedToLoadImage;
    procedure ZoomOut;
    procedure ZoomIn;

    procedure SetFaceDetectionControls(AWlFaceCount: TWebLink; ALsDetectingFaces: TLoadingSign; ATbrActions: TToolBar);
    procedure FinishDetectionFaces;
    procedure SelectPerson(PersonID: Integer);
    procedure ResetPersonSelection;
    procedure StartPersonSelection;
    procedure StopPersonSelection;

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

    procedure SetOnBeginLoadingImage(Event: TBeginLoadingImageEvent);
    function GetOnBeginLoadingImage: TBeginLoadingImageEvent;
    procedure SetOnRequestNextImage(Event: TNotifyEvent);
    function GetOnRequestNextImage: TNotifyEvent;
    procedure SetOnRequestPreviousImage(Event: TNotifyEvent);
    function GetOnRequestPreviousImage: TNotifyEvent;
    procedure SetOnDblClick(Event: TNotifyEvent);
    function GetOnDblClick: TNotifyEvent;
    procedure SetOnPersonsFoundOnImage(Event: TPersonsFoundOnImageEvent);
    function GetOnPersonsFoundOnImage: TPersonsFoundOnImageEvent;
    procedure SetOnStopPersonSelection(Event: TNotifyEvent);
    function GetOnStopPersonSelection: TNotifyEvent;

    property OnBeginLoadingImage: TBeginLoadingImageEvent read GetOnBeginLoadingImage write SetOnBeginLoadingImage;
    property OnRequestNextImage: TNotifyEvent read GetOnRequestNextImage write SetOnRequestNextImage;
    property OnRequestPreviousImage: TNotifyEvent read GetOnRequestPreviousImage write SetOnRequestPreviousImage;
    property OnDblClick: TNotifyEvent read GetOnDblClick write SetOnDblClick;
    property OnPersonsFoundOnImage: TPersonsFoundOnImageEvent read GetOnPersonsFoundOnImage write SetOnPersonsFoundOnImage;
    property OnStopPersonSelection: TNotifyEvent read GetOnStopPersonSelection write SetOnStopPersonSelection;
    property Text: string read GetText write SetText;
  end;

implementation

end.

