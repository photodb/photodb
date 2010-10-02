unit FloatPanelFullScreen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ImgList, TLayered_bitmap, ExtCtrls;

type
  TFloatPanel = class(TForm)
    NormalImageList: TImageList;
    HotImageList: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    DisabledImageList: TImageList;
    DestroyTimer: TTimer;
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure RecreateImLists;
    procedure FormCreate(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
  FClosed : Boolean;
    { Public declarations }
  end;

  var
    FloatPanel: TFloatPanel;

implementation

uses SlideShowFullScreen, SlideShow, UnitDBkernel, Dolphin_DB;

{$R *.dfm}

procedure TFloatPanel.ToolButton1Click(Sender: TObject);
begin
 Viewer.MTimer1Click(Sender);
end;

procedure TFloatPanel.ToolButton4Click(Sender: TObject);
begin
 Viewer.Pause;
 Viewer.PreviousImageClick(Sender);
end;

procedure TFloatPanel.ToolButton5Click(Sender: TObject);
begin
 Viewer.Pause;
 Viewer.NextImageClick(Sender);
end;

procedure TFloatPanel.ToolButton7Click(Sender: TObject);
begin
 DestroyTimer.Enabled:=true;
end;

procedure TFloatPanel.RecreateImLists;
var
  Icons: array [0 .. 1, 0 .. 4] of TIcon;
  I, J: Integer;
  B: TBitmap;
  Imlists: array [0 .. 2] of TImageList;
  Lb: TLayeredBitmap;
Const
  Names : array [0..1,0..4] of String = (('Z_PLAY_NORM','Z_PAUSE_NORM','Z_PREVIOUS_NORM','Z_NEXT_NORM','Z_CLOSE_NORM'),('Z_PLAY_HOT','Z_PAUSE_HOT','Z_PREVIOUS_HOT','Z_NEXT_HOT','Z_CLOSE_HOT'));

begin
 for i:=0 to 1 do
 for j:=0 to 4 do
 begin
  icons[i,j] := TIcon.Create;
  icons[i,j].Handle := LoadIcon(DBKernel.IconDllInstance, PWideChar(Names[I, J]));
 end;
 imlists[0]:=NormalImageList;
 imlists[1]:=HotImageList;
 imlists[2]:=DisabledImageList;
 for i:=0 to 2 do
 begin
  imlists[i].Clear;
  imlists[i].BkColor:=ClBtnFace;
 end;
 for i:=0 to 1 do
 for j:=0 to 4 do
 begin
  imlists[i].AddIcon(icons[i,j]);
  if i=0 then
  begin
   lb := TLayeredBitmap.Create;
   b:=TBitmap.create;
   b.Width:=16;
   b.Height:=16;
   b.Canvas.Brush.Color:=ClBtnFace;
   b.Canvas.Pen.Color:=ClBtnFace;
   b.Canvas.Rectangle(0,0,16,16);
   lb.DoStreachDraw(0,0,16,16,b);
   imlists[2].Add(b,nil);
   b.free;
   lb.free;
  end;
 end;
 for i:=0 to 1 do
 for j:=0 to 4 do
 begin
  icons[i,j].free;
 end;
end;

procedure TFloatPanel.FormCreate(Sender: TObject);
begin
 FClosed:=false;
 RecreateImLists;
 if Length(CurrentInfo.ItemFileNames)<2 then
 begin
  ToolButton4.Enabled:=false;
  ToolButton5.Enabled:=false;
  ToolButton1.Enabled:=false;
  ToolButton2.Enabled:=false;
 end else
 begin
  ToolButton4.Enabled:=True;
  ToolButton5.Enabled:=True;
  ToolButton1.Enabled:=True;
  ToolButton2.Enabled:=True;
 end;
end;

procedure TFloatPanel.DestroyTimerTimer(Sender: TObject);
begin
 FClosed:=true;
 DestroyTimer.Enabled:=false;
 Viewer.Exit1Click(Sender);
end;

procedure TFloatPanel.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=not FullScreenNow and not SlideShowNow;
end;

procedure TFloatPanel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if not FClosed then
 begin
  FClosed:=true;
  DestroyTimer.Enabled:=true;
 end;
end;

end.
