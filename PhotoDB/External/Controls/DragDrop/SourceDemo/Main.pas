unit Main;
// -----------------------------------------------------------------------------
// Project:         Drag and Drop Component Suite
// Authors:         Angus Johnson,   ajohnson@rpi.net.au
//                  Anders Melander, anders@melander.dk
//                                   http://www.melander.dk
// Copyright        © 1997-99 Angus Johnson & Anders Melander
// -----------------------------------------------------------------------------
// You are free to use this source but please give us credit for our work.
// If you make improvements or derive new components from this code,
// we would very much like to see your improvements. FEEDBACK IS WELCOME.
// -----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DropSource, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    Button1: TButton;
    DropFileSource1: TDropFileSource;
    ListView1: TListView;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    DragPoint: TPoint;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  path: string;
  sr: TSearchRec;
  res: integer;
  NewItem : TListItem;
begin
  //Fill listview with list of files in current directory...
  path := extractfilepath(paramstr(0));
  res := FindFirst(path+'*.*', 0, sr);
  with Listview1.items do
    try
      while (res = 0) do
      begin
        if (sr.name <> '.') and (sr.name <> '..') then
        begin
          NewItem := Add;
          NewItem.Caption := lowercase(path+sr.name);
        end;
        res := FindNext(sr);
      end;
    finally
      FindClose(sr);
    end;
end;

procedure TForm1.ListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DragPoint := Point(X,Y);
end;

procedure TForm1.ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i: integer;
begin
  //Make sure mouse has moved at least 10 pixels before starting drag ...
  if (DragPoint.X = -1) or ((Shift <> [ssLeft]) and (Shift <> [ssRight])) or
     ((abs(DragPoint.X - X) <10) and (abs(DragPoint.Y - Y) <10)) then exit;
  //If no files selected then exit...
  if Listview1.SelCount = 0 then exit;

  //Delete anything from a previous dragdrop...
  DropFileSource1.Files.clear;

  //Fill DropSource1.Files with selected files in ListView1
  for i := 0 to Listview1.items.Count-1 do
    if (Listview1.items.item[i].Selected) then
      DropFileSource1.Files.Add(Listview1.items.item[i].caption);

  //Start the dragdrop...
  //Note: DropFileSource1.DragTypes = [dtCopy]
  DropFileSource1.execute;
end;

end.
