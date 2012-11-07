unit uIImageViewer;

interface

uses
  Generics.Collections,
  System.Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ComCtrls,

  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WebLink,

  UnitDBDeclare,

  uMemory,
  uInterfaces,
  uDBPopupMenuInfo,
  uFaceDetection,
  uThreadForm;

type
  TImageViewerButton = (ivbPrevious, ivbNext, ivbRotateCW, ivbRotateCCW, ivbRating, ivbZoomIn, ivbZoomOut);
  TImageViewerButtonState = (ivbsVisible, ivbsEnabled);
  TImageViewerButtonStates = set of TImageViewerButtonState;

  TButtonState = class
  private
    FButton: TImageViewerButton;
    FStates: TImageViewerButtonStates;
  public
    constructor Create(Button: TImageViewerButton; States: TImageViewerButtonStates = []);
    function AddState(State: TImageViewerButtonState): TButtonState;
    function HasState(State: TImageViewerButtonState): Boolean;
    property Button: TImageViewerButton read FButton;
    property States: TImageViewerButtonStates read FStates;
  end;

  TButtonStates = class
  private
    FButtons: TList<TButtonState>;
    function GetButtonByType(Index: TImageViewerButton): TButtonState;
  public
    constructor Create;
    destructor Destroy; override;
    property Buttons[Index: TImageViewerButton]: TButtonState read GetButtonByType; default;
  end;

  TPersonsFoundOnImageEvent = procedure(Sender: TObject; FileName: string; Items: TFaceDetectionResult) of object;
  TBeginLoadingImageEvent = procedure(Sender: TObject; NewImage: Boolean) of object;
  TUpdateButtonsStateEvent = procedure(Sender: TObject; Buttons: TButtonStates) of object;

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

    procedure RotateCW;
    procedure RotateCCW;

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
    function GetIsAnimatedImage: Boolean;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Top: Integer read GetTop;
    property Left: Integer read GetLeft;
    property ActiveThreadId: TGUID read GetActiveThreadId;
    property Item: TDBPopupMenuInfoRecord read GetItem;
    property DisplayBitmap: TBitmap read GetDisplayBitmap;
    property CurentFile: string read GetCurentFile;
    property IsAnimatedImage: Boolean read GetIsAnimatedImage;

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
    procedure SetOnUpdateButtonsState(Event: TUpdateButtonsStateEvent);
    function GetOnUpdateButtonsState: TUpdateButtonsStateEvent;

    property OnBeginLoadingImage: TBeginLoadingImageEvent read GetOnBeginLoadingImage write SetOnBeginLoadingImage;
    property OnRequestNextImage: TNotifyEvent read GetOnRequestNextImage write SetOnRequestNextImage;
    property OnRequestPreviousImage: TNotifyEvent read GetOnRequestPreviousImage write SetOnRequestPreviousImage;
    property OnDblClick: TNotifyEvent read GetOnDblClick write SetOnDblClick;
    property OnPersonsFoundOnImage: TPersonsFoundOnImageEvent read GetOnPersonsFoundOnImage write SetOnPersonsFoundOnImage;
    property OnStopPersonSelection: TNotifyEvent read GetOnStopPersonSelection write SetOnStopPersonSelection;
    property OnUpdateButtonsState: TUpdateButtonsStateEvent read GetOnUpdateButtonsState write SetOnUpdateButtonsState;
    property Text: string read GetText write SetText;
  end;

implementation

{ TButtonState }

function TButtonState.AddState(State: TImageViewerButtonState): TButtonState;
begin
  FStates := FStates + [State];
  Result := Self;
end;

constructor TButtonState.Create(Button: TImageViewerButton;
  States: TImageViewerButtonStates = []);
begin
  FButton := Button;
  FStates := States;
end;

function TButtonState.HasState(State: TImageViewerButtonState): Boolean;
begin
  Result := [State] * FStates <> [];
end;

{ TButtonStates }

constructor TButtonStates.Create;
begin
  FButtons := TList<TButtonState>.Create;
end;

destructor TButtonStates.Destroy;
begin
  FreeList(FButtons);
  inherited;
end;

function TButtonStates.GetButtonByType(Index: TImageViewerButton): TButtonState;
var
  I: Integer;
begin
  for I := 0 to FButtons.Count - 1 do
  begin
    if FButtons[I].Button = Index then
      Exit(FButtons[I]);
  end;

  Result := TButtonState.Create(Index);
  FButtons.Add(Result);
end;

end.

