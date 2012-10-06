unit uIImageViewer;

interface

uses
  Vcl.Controls,
  Vcl.Graphics,

  UnitDBDeclare,

  uInterfaces,
  uDBPopupMenuInfo,
  uThreadForm;

type
  IImageViewer = interface(IFaceResultForm)
    procedure AttachTo(OwnerForm: TThreadForm; Control: TWinControl; X, Y: Integer);
    procedure LoadFiles(FileList: TDBPopupMenuInfo);
    procedure LoadPreviousFile;
    procedure LoadNextFile;
    procedure ResizeTo(Width, Height: Integer);
    procedure SetStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure SetAnimatedImage(Image: TGraphic; RealWidth, RealHeight: Integer; Rotation: Integer; ImageScale: Double);
    procedure ZoomOut;
    procedure ZoomIn;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetLeft: Integer;
    function GetActiveThreadId: TGUID;
    function GetItem: TDBPopupMenuInfoRecord;
    function GetDisplayBitmap: TBitmap;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Top: Integer read GetTop;
    property Left: Integer read GetLeft;
    property ActiveThreadId: TGUID read GetActiveThreadId;
    property Item: TDBPopupMenuInfoRecord read GetItem;
    property DisplayBitmap: TBitmap read GetDisplayBitmap;
  end;

implementation

end.

