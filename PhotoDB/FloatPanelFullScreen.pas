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
    TbPlay: TToolButton;
    TbPause: TToolButton;
    ToolButton3: TToolButton;
    TbPrev: TToolButton;
    TbNext: TToolButton;
    ToolButton6: TToolButton;
    TbClose: TToolButton;
    DisabledImageList: TImageList;
    procedure TbPlayClick(Sender: TObject);
    procedure TbPrevClick(Sender: TObject);
    procedure TbNextClick(Sender: TObject);
    procedure TbCloseClick(Sender: TObject);
    procedure RecreateImLists;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    FClosed : Boolean;
    procedure SetButtonsEnabled(Enabled: Boolean);
  end;

var
  FloatPanel: TFloatPanel;

implementation

uses
  SlideShowFullScreen, SlideShow, UnitDBKernel, Dolphin_DB;

{$R *.dfm}

procedure TFloatPanel.TbPlayClick(Sender: TObject);
begin
  Viewer.MTimer1Click(Sender);
end;

procedure TFloatPanel.TbPrevClick(Sender: TObject);
begin
  Viewer.Pause;
  Viewer.PreviousImageClick(Sender);
end;

procedure TFloatPanel.TbNextClick(Sender: TObject);
begin
  Viewer.Pause;
  Viewer.NextImageClick(Sender);
end;

procedure TFloatPanel.TbCloseClick(Sender: TObject);
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
      Icons[I, J].Handle := LoadImage(HInstance, PWideChar(Names[I, J]), IMAGE_ICON, 16, 16, 0);
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
          Lb.LoadFromHIcon(Icons[I, J].Handle);
          Lb.GrayScale;
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
      Icons[I, J].Free;
end;

procedure TFloatPanel.SetButtonsEnabled(Enabled: Boolean);
begin
  TbPrev.Enabled := Enabled;
  TbNext.Enabled := Enabled;
  TbPlay.Enabled := Enabled;
  TbPause.Enabled := Enabled;
end;

procedure TFloatPanel.FormCreate(Sender: TObject);
begin
  FClosed := False;
  RecreateImLists;
  SetButtonsEnabled(Viewer.CurrentInfo.Count > 1);
end;

procedure TFloatPanel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FClosed := True;
  Viewer.Exit1Click(Sender);
end;

end.
