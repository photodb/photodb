unit DropText;

interface
                                                         
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, DropSource, DropTarget, ActiveX;

type
  TFormText = class(TForm)
    Memo1: TMemo;
    DropSource1: TDropTextSource;
    btnClose: TButton;
    Edit2: TEdit;
    StatusBar1: TStatusBar;
    Memo2: TMemo;
    Edit1: TEdit;
    btnClipboard: TButton;
    Panel1: TPanel;
    DropTextTarget1: TDropTextTarget;
    DropTextTarget2: TDropTextTarget;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnClipboardClick(Sender: TObject);
    procedure Edit2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DropTextTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure DropTextTarget2Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
  private
    //used by top example
    DragPoint: TPoint;

    //used by bottom example
    OldEdit2WindowProc: TWndMethod;
    procedure NewEdit2WindowProc(var Msg : TMessage);

    function MouseIsOverEdit2Selection(XPos: integer): boolean;
    procedure StartEdit2Drag;
  public
    { Public declarations }
  end;

var
  FormText: TFormText;


implementation

{$R *.DFM}

//----------------------------------------------------------------------------
// TFormText methods
//----------------------------------------------------------------------------

//******************* TFormText.FormCreate *************************
procedure TFormText.FormCreate(Sender: TObject);
begin
  //Register the target TWinControls...
  DropTextTarget1.Register(Edit1);
  DropTextTarget2.Register(Edit2);

  //Used for Bottom Text Drag example...
  //Hook edit window so we can intercept WM_LBUTTONDOWN messages!
  OldEdit2WindowProc := Edit2.WindowProc;
  Edit2.WindowProc := NewEdit2WindowProc;
end;

//******************* TFormText.FormDestroy *************************
procedure TFormText.FormDestroy(Sender: TObject);
begin
  //Unregister the target TWinControls...
  DropTextTarget1.UnRegister;
  DropTextTarget2.UnRegister;

  //Used by Bottom Text Drag example...
  //Undo hooking...
  Edit2.WindowProc := OldEdit2WindowProc;
end;

//******************* TFormText.btnCloseClick *************************
procedure TFormText.btnCloseClick(Sender: TObject);
begin
  close;
end;

//----------------------------------------------------------------------------
// The following 4 methods are all that are needed
// for the TOP Text Drop SOURCE and TARGET examples.
//----------------------------------------------------------------------------

//******************* TFormText.Edit1MouseDown *************************
procedure TFormText.Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DragPoint := Point(X,Y);
end;

//******************* TFormText.Edit1MouseMove *************************
procedure TFormText.Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Res: TDragResult;
begin
  Edit1.sellength := 0;

  if (Shift <> [ssLeft]) or (Edit1.text = '') then exit;
  //Make sure mouse has moved at least 10 pixels before starting drag ...
  if (abs(DragPoint.X - X) <10) and (abs(DragPoint.Y - Y) <10) then exit;

  Statusbar1.simpletext := '';
  DropTextTarget1.DragTypes := []; //Disable Edit1 as a target temporarily.

  DropSource1.Text := Edit1.Text;
//--------------------------
  Res := DropSource1.Execute; //Do it here - dragging FROM edit1
//--------------------------

  DropTextTarget1.DragTypes := [dtCopy]; //Enable Edit1 as a drop target again.

  //Display in statusbar whether the drag was successful or not...
  with Statusbar1 do
    case Res of
      drDropCopy: simpletext := 'Copied successfully';
      drDropLink: simpletext := 'Scrap file created successfully';
      drCancel: simpletext := 'Drop cancelled';
      drOutMemory: simpletext := 'Can''t drop, out of memory.';
    else simpletext := 'Can''t drop - unknown reason.';
    end;

end;

//--------------------------
// TARGET event...
//--------------------------

//******************* TFormText.DropTextTarget1Drop *************************
procedure TFormText.DropTextTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  Edit1.text := DropTextTarget1.Text; //Dragging TO edit1.
end;

//--------------------------
// SOURCE CopyToClipboard...
//--------------------------

//******************* TFormText.btnClipboardClick *************************
procedure TFormText.btnClipboardClick(Sender: TObject);
begin
  if Edit1.Text = '' then exit;
  DropSource1.Text := Edit1.Text;
//--------------------------
  DropSource1.CopyToClipboard;
//--------------------------
  StatusBar1.simpletext := 'Text copied to clipboard.';
end;

//----------------------------------------------------------------------------
// The following methods are used for the BOTTOM Text Drop SOURCE and TARGET examples.
// The DropSource code is almost identical. However, the Edit2 control
// has been hooked to override the default WM_LBUTTONDOWN message handling.
// Using the normal OnMouseDown event method does not work for this example.
//----------------------------------------------------------------------------

// The new WindowProc for Edit2 which intercepts WM_LBUTTONDOWN messages
// before ANY OTHER processing...
//******************* TFormText.NewEdit2WindowProc *************************
procedure TFormText.NewEdit2WindowProc(var Msg : TMessage);
begin
  with TWMMouse(Msg) do
    if (Msg = WM_LBUTTONDOWN) and
      MouseIsOverEdit2Selection(XPos) then
    begin
      StartEdit2Drag; //Just a locally declared procedure.
      result := 0;
      exit;
    end;
  //Otherwise do everything as before...
  OldEdit2WindowProc(Msg);
end;

//******************* TFormText.MouseIsOverEdit2Selection *************************
function TFormText.MouseIsOverEdit2Selection(XPos: integer): boolean;
var
  dc: HDC;
  SavedFont: HFont;
  size1, size2: TSize;
  s1,s2: string;
begin
  with edit2 do
  begin
    result := false;
    if (sellength = 0) or (not focused) then exit;

    dc := GetDC(0);
    SavedFont := SelectObject(dc, Font.Handle);
    s1 := copy(text,1,selstart);
    s2 := s1 + seltext;
    GetTextExtentPoint32(dc,pchar(s1),length(s1),size1);
    GetTextExtentPoint32(dc,pchar(s2),length(s2),size2);
    SelectObject(dc, SavedFont);
    ReleaseDC(0,dc);
    if (XPos >= size1.cx) and (XPos <= size2.cx) then
      result := true;
  end;
end;

//******************* TFormText.StartEdit2Drag *************************
procedure TFormText.StartEdit2Drag;
var
  Res: TDragResult;
begin
  with Edit2 do
  begin
    Statusbar1.simpletext := '';

    DropSource1.Text := Edit2.SelText;
//--------------------------
    Res := DropSource1.Execute; //Do it here!!!!!
//--------------------------

    with Statusbar1 do
      case Res of
        drDropCopy: simpletext := 'Copied successfully';
        drDropLink: simpletext := 'Scrap file created successfully';
        drCancel: simpletext := 'Drop cancelled';
        drOutMemory: simpletext := 'Can''t drop, out of memory.';
      else simpletext := 'Can''t drop - unknown reason.';
      end;
  end; //with edit2 ...
end;

//This method just changes mouse cursor to crHandPoint if over selected text...
//******************* TFormText.Edit2MouseMove *************************
procedure TFormText.Edit2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  with Edit2 do
    if MouseIsOverEdit2Selection(X) then
      cursor := crHandPoint else
      cursor := crDefault;
end;

//--------------------------
// TARGET event...
//--------------------------

//******************* TFormText.DropTextTarget2Drop *************************
procedure TFormText.DropTextTarget2Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  Edit2.seltext := DropTextTarget2.Text; //Dragging TO edit2.
end;

end.
