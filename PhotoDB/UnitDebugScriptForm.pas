unit UnitDebugScriptForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, ValEdit, uStringUtils;

type
  TDebugScriptForm = class(TForm)
    ListBox1: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Timer: TTimer;
    ValueListEditor1: TStringGrid;
    Splitter1: TSplitter;
    Panel4: TPanel;
    Button4: TButton;
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ValueListEditor1DblClick(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure ValueListEditor1SelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure ValueListEditor1SetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: String);
    procedure FormDestroy(Sender: TObject);
  private
   ActiveLine : integer;
   fWaiting : boolean;
   fCanClose : boolean;
   p : Pointer;
    { Private declarations }
  public
   anil : boolean;
   procedure LoadScript(aScript : string);
   procedure SetActiveLine(Line : integer);
   Procedure SetScript(ap : pointer);
   procedure Wait;
   procedure Stop;
   Function Working : boolean;
   Function Waitind : boolean;
    { Public declarations }
  end;

implementation

uses uScript, UnitScripts;

{$R *.dfm}

procedure TDebugScriptForm.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
 if ActiveLine=Index+1 then
 begin
  ListBox1.Canvas.Pen.Color:=ClRed;
  ListBox1.Canvas.Brush.Color:=ClRed;
  ListBox1.Canvas.Rectangle(Rect);
  ListBox1.Canvas.TextOut(Rect.Left,Rect.Top,ListBox1.Items[index]);
  ListBox1.Canvas.Font.Color:=ClWhite;
 end else
 begin
  ListBox1.Canvas.Brush.Color:=ClWhite;
  ListBox1.Canvas.Pen.Color:=ClWhite;
  ListBox1.Canvas.Rectangle(Rect);
  ListBox1.Canvas.TextOut(Rect.Left,Rect.Top,ListBox1.Items[index]);
  ListBox1.Canvas.Font.Color:=ClBlack;
 end;
end;

procedure TDebugScriptForm.LoadScript(aScript: string);
var
  p, oldp : integer;
  sub : string;
begin
 oldp:=1;
 repeat
  p:=PosExS(';',aScript,oldp);
  sub:=Copy(aScript,oldp,p-oldp+1);
  ListBox1.Items.Add(sub);
  oldp:=p+1;
 until p=0;
// ListBox1.Items.Text:=aScript;
end;

procedure TDebugScriptForm.SetActiveLine(Line: integer);
begin
 ActiveLine:=Line;
 ListBox1.Refresh;
end;

procedure TDebugScriptForm.Wait;
var
  Variable, Val : string;
  i : integer;
begin
 for i:=1 to ValueListEditor1.RowCount do
 begin
  Variable:=ValueListEditor1.Cells[0,i];
  if Variable<>'' then
  begin
   Val:=VarValue(TScript(p),Variable);
   ValueListEditor1.Cells[1,i]:=Val;
  end;
 end;
  fCanClose:=false;
  fWaiting:=true;
  Repeat
   Application.ProcessMessages;
  until not fWaiting;
  fCanClose:=true;
end;

procedure TDebugScriptForm.FormCreate(Sender: TObject);
begin
 anil:=false;
 fWaiting:=false;
 fCanClose:=true;
 ValueListEditor1.Cells[0,0]:='Variable';
 ValueListEditor1.Cells[1,0]:='Value';
end;

procedure TDebugScriptForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 fWaiting:=false;
 Timer.Enabled:=true;
//  Repeat
//   Application.ProcessMessages;
//  until fCanClose;
end;

procedure TDebugScriptForm.Button1Click(Sender: TObject);
begin
 fWaiting:=false;
 Timer.Enabled:=true;
{  Repeat
   Application.ProcessMessages;
  until fCanClose;  }
end;

procedure TDebugScriptForm.Stop;
begin
 fWaiting:=false;
 Timer.Enabled:=true;
{  Repeat
   Application.ProcessMessages;
  until fCanClose;   }
end;

function TDebugScriptForm.Working: boolean;
begin
 Result:=not fCanClose;
end;

procedure TDebugScriptForm.TimerTimer(Sender: TObject);
begin
 if fCanClose then
 begin
  Timer.Enabled:=false;
  fCanClose:=false;
  anil:=true;
  Release;
  Free;
 end;
end;

procedure TDebugScriptForm.ValueListEditor1DblClick(Sender: TObject);
var
  p : TPoint;
  c,r : integer;
begin
// ValueListEditor1.EditorMode:=true;
 GetCursorPos(p);
 p:=ValueListEditor1.ScreenToClient(p);
 ValueListEditor1.MouseToCell(p.x,p.y,c,r);
 if (c<0) or (r<0) then
 begin
  ValueListEditor1.RowCount:= ValueListEditor1.RowCount+1;
 end;
end;

procedure TDebugScriptForm.Panel2Resize(Sender: TObject);
begin
 ValueListEditor1.ColWidths[0]:=Panel2.Width div 2-5;
 ValueListEditor1.ColWidths[1]:=Panel2.Width div 2-5;
end;

procedure TDebugScriptForm.ValueListEditor1SelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if (ACol=1) then CanSelect:=false;
end;

procedure TDebugScriptForm.ValueListEditor1SetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: String);
var
  Variable, Val : string;
begin
 Variable:=ValueListEditor1.Cells[ACol,ARow];
 Val:=VarValue(TScript(p^),Variable);
 ValueListEditor1.Cells[ACol+1,ARow]:=Val;
//
end;

procedure TDebugScriptForm.SetScript(ap: pointer);
begin
 p:=ap;
end;

function TDebugScriptForm.Waitind: boolean;
begin
 Result:=fWaiting;
end;

procedure TDebugScriptForm.FormDestroy(Sender: TObject);
begin
 anil:=false;
end;

end.
