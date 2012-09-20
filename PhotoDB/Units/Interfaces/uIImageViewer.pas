unit uIImageViewer;

interface

uses
  Controls,
  uDBPopupMenuInfo;

type
  IImageViewer = interface
    procedure AttachTo(Control: TWinControl; X, Y: Integer);
    procedure LoadFiles(FileList: TDBPopupMenuInfo);
    procedure ResizeTo(Width, Height: Integer);
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetLeft: Integer;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Top: Integer read GetTop;
    property Left: Integer read GetLeft;
  end;

implementation

end.
