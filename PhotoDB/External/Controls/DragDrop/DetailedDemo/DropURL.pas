unit DropURL;

interface

{$include DragDrop.inc}

uses
{$ifdef VER12_PLUS}
  ImgList,
{$endif}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, dropsource, DropTarget, DropBMPTarget,
  DropBMPSource, DropURLSource, DropURLTarget, ActiveX, CommCtrl;

type
  TFormURL = class(TForm)
    Panel1: TPanel;
    btnClose: TButton;
    StatusBar1: TStatusBar;
    Edit1: TEdit;
    Memo2: TMemo;
    DropURLTarget1: TDropURLTarget;
    DropURLSource1: TDropURLSource;
    DropBMPSource1: TDropBMPSource;
    DropBMPTarget1: TDropBMPTarget;
    Panel2: TPanel;
    Image2: TImage;
    Panel3: TPanel;
    Memo1: TMemo;
    Panel4: TPanel;
    Image1: TImage;
    Label1: TLabel;
    ImageList1: TImageList;
    Panel5: TPanel;
    Image3: TImage;
    DropDummy1: TDropDummy;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DropURLTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure DropBMPTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure Image3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    DragPoint: TPoint;
  public
    { Public declarations }
  end;

var
  FormURL: TFormURL;

implementation

{$R *.DFM}

//******************* GetColorFromBottomLeft *************************
function GetColorFromBottomLeft(const bmp: TBitmap): TColor;
begin
  if not assigned(bmp) or bmp.empty then Result := clWhite
  else Result := bmp.Canvas.pixels[0,bmp.Height-1];
end;

//******************* TFormURL.FormCreate *************************
procedure TFormURL.FormCreate(Sender: TObject);
begin
  //Register the URL and BMP DropTarget windows...
  DropURLTarget1.Register(Edit1);
  DropBMPTarget1.Register(Panel2);
  //This enables the dragged image to be visible
  //over the whole form, not just the target panel...
  DropDummy1.Register(self);
end;

//******************* TFormURL.FormDestroy *************************
procedure TFormURL.FormDestroy(Sender: TObject);
begin
  //UnRegister the DropTarget windows...
  DropURLTarget1.UnRegister;
  DropBMPTarget1.UnRegister;
  DropDummy1.UnRegister;
end;

//******************* TFormURL.btnCloseClick *************************
procedure TFormURL.btnCloseClick(Sender: TObject);
begin
  close;
end;

//------------------------------------------------------------------------------
// URL stuff ...
//------------------------------------------------------------------------------

//******************* TFormURL.Edit1MouseDown *************************
procedure TFormURL.Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DragPoint := Point(X,Y);
end;

//******************* TFormURL.Edit1MouseMove *************************
procedure TFormURL.Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Shift <> [ssLeft]) or (Edit1.text = '') then exit;
  //Make sure mouse has moved at least 10 pixels before starting drag ...
  if (abs(DragPoint.X - X) <10) and (abs(DragPoint.Y - Y) <10) then exit;

  DropURLSource1.Title := Edit1.text;
  DropURLSource1.URL := Label1.caption;
  DropURLTarget1.DragTypes := []; //Disable Edit1 as a target temporarily.
//--------------------------
  DropURLSource1.Execute;
//--------------------------
  DropURLTarget1.DragTypes := [dtLink]; //Enable Edit1 as a drop target again.
end;

//******************* TFormURL.DropURLTarget1Drop *************************
procedure TFormURL.DropURLTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  edit1.text := DropURLTarget1.Title;
  label1.caption := DropURLTarget1.URL;
end;

//------------------------------------------------------------------------------
// BMP stuff ...
//------------------------------------------------------------------------------

//******************* TFormURL.Image1MouseDown *************************
procedure TFormURL.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with Image1.picture do
  begin
    if (graphic = nil) then exit;
    DropBMPSource1.Bitmap.assign(graphic);
    //this just demonstrates dynamically allocating a drag image...
    //Note: DropBMPSource1.Images = ImageList1
    ImageList1.ReplaceMasked(0, Bitmap, GetColorFromBottomLeft(Bitmap));
  end;
  //start the drag...
  if DropBMPSource1.execute = drDropMove then
    Image1.picture.graphic := nil;
end;

//same as above, just a different image to drag...
//******************* TFormURL.Image3MouseDown *************************
procedure TFormURL.Image3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with Image3.picture do
  begin
    if (graphic = nil) then exit;
    DropBMPSource1.Bitmap.assign(graphic);
    ImageList1.ReplaceMasked(0, Bitmap, GetColorFromBottomLeft(Bitmap));
  end;
  //start the drag...
  if DropBMPSource1.execute = drDropMove then
    Image3.picture.graphic := nil;
end;

//******************* TFormURL.DropBMPTarget1Drop *************************
procedure TFormURL.DropBMPTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  //an image has just been dropped into the target...
  Image2.picture.assign(DropBMPTarget1.bitmap);
end;

end.
