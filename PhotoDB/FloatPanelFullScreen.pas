unit FloatPanelFullScreen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ImgList, TLayered_bitmap, ExtCtrls, uMemory;

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
    { Public declarations }
    FClosed : Boolean;
  end;

var
  FloatPanel: TFloatPanel;

implementation

uses
  SlideShowFullScreen, SlideShow, UnitDBKernel, Dolphin_DB;

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
  Close;
end;

procedure TFloatPanel.RecreateImLists;
var
  Icons: array [0 .. 1, 0 .. 4] of TIcon;
  I, J: Integer;
  B: TBitmap;
  Imlists: array [0 .. 2] of TImageList;
  Lb: TLayeredBitmap;
const
  Names: array [0 .. 1, 0 .. 4] of string = (('Z_PLAY_NORM', 'Z_PAUSE_NORM', 'Z_PREVIOUS_NORM', 'Z_NEXT_NORM',
      'Z_CLOSE_NORM'), ('Z_PLAY_HOT', 'Z_PAUSE_HOT', 'Z_PREVIOUS_HOT', 'Z_NEXT_HOT', 'Z_CLOSE_HOT'));

begin
  for I := 0 to 1 do
    for J := 0 to 4 do
    begin
      Icons[I, J] := TIcon.Create;
      Icons[I, J].Handle := LoadIcon(DBKernel.IconDllInstance, PWideChar(Names[I, J]));
    end;
  Imlists[0] := NormalImageList;
  Imlists[1] := HotImageList;
  Imlists[2] := DisabledImageList;
  for I := 0 to 2 do
  begin
    Imlists[I].Clear;
    Imlists[I].BkColor := ClBtnFace;
  end;
  for I := 0 to 1 do
    for J := 0 to 4 do
    begin
      Imlists[I].AddIcon(Icons[I, J]);
      if I = 0 then
      begin
        Lb := TLayeredBitmap.Create;
        try
          B := TBitmap.Create;
          try
            B.Width := 16;
            B.Height := 16;
            B.Canvas.Brush.Color := clBtnFace;
            B.Canvas.Pen.Color := clBtnFace;
            B.Canvas.Rectangle(0, 0, 16, 16);
            Lb.DoStreachDraw(0, 0, 16, 16, B);
            Imlists[2].Add(B, nil);
          finally
            F(B);
          end;
        finally
          F(Lb);
        end;
      end;
    end;
  for I := 0 to 1 do
    for J := 0 to 4 do
    begin
      Icons[I, J].Free;
    end;
end;

procedure TFloatPanel.FormCreate(Sender: TObject);
begin
  FClosed := false;
  RecreateImLists;
  if Viewer.CurrentInfo.Count < 2 then
  begin
    ToolButton4.Enabled := false;
    ToolButton5.Enabled := false;
    ToolButton1.Enabled := false;
    ToolButton2.Enabled := false;
  end else
  begin
    ToolButton4.Enabled := true;
    ToolButton5.Enabled := true;
    ToolButton1.Enabled := true;
    ToolButton2.Enabled := true;
  end;
end;

procedure TFloatPanel.DestroyTimerTimer(Sender: TObject);
begin
  FClosed := true;
  Viewer.Exit1Click(Sender);
end;

procedure TFloatPanel.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Viewer.FullScreenNow and not Viewer.SlideShowNow;
end;

procedure TFloatPanel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //
end;

end.
