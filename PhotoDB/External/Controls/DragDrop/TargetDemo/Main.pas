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
  StdCtrls, DropSource, DropTarget, ComCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    Button1: TButton;
    DropFileTarget1: TDropFileTarget;
    ListView1: TListView;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
  private
    { Private declarations }
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
begin
  DropFileTarget1.register(Listview1);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DropFileTarget1.unregister;
end;

procedure TForm1.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  i: integer;
  NewItem: TListItem;
begin
  with DropFileTarget1 do
    for i := 0 to files.count-1 do
    begin
      NewItem := Listview1.items.add;
      NewItem.caption := files[i];
    end;
end;

end.
