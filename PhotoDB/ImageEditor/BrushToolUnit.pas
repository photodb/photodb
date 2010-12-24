unit BrushToolUnit;

interface

uses Windows, ToolsUnit, WebLink, Classes, Controls, Graphics,
     Language, Math, Forms, ComCtrls, StdCtrls, SysUtils,
     Dialogs, GraphicsCool, GraphicsBaseTypes, EffectsLanguage,
     UnitDBKernel, ExtCtrls, uEditorTypes, uMemory;

type
  TBrushToolClass = class(TToolsPanelClass)
  private
    { Private declarations }
    BrushSizeCaption: TStaticText;
    BrushSizeTrackBar: TTrackBar;
    BrusTransparencyCaption: TStaticText;
    BrusTransparencyTrackBar: TTrackBar;
    BrushColorCaption: TStaticText;
    BrushColorChooser: TShape;
    BrushColorChooserDialog: TColorDialog;
    FButtonCustomColor: TButton;
    LabelMethod: TLabel;
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    SaveSettingsLink: TWebLink;
    Drawing: Boolean;
    BeginPoint, EndPoint: TPoint;
    FProcRecteateImage: TNotifyEvent;
    FOwner: TObject;
    NewImage: TBitmap;
    Cur: HIcon;
    Initialized: Boolean;
    FButtonPressed: Boolean;
    procedure SetProcRecteateImage(const Value: TNotifyEvent);
    procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
  protected
    function LangID: string; override;
  public
    { Public declarations }
    MethodDrawChooser: TComboBox;
    FDrawlayer: PARGB32Array;
    LastRect: TRect;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClosePanelEvent(Sender: TObject);
    procedure ClosePanel; override;
    procedure MakeTransform; override;
    procedure DoMakeImage(Sender: TObject);
    procedure SetBeginPoint(P: TPoint);
    procedure SetNextPoint(P: TPoint);
    procedure SetEndPoint(P: TPoint);
    procedure DrawBrush;
    property ProcRecteateImage: TNotifyEvent read FProcRecteateImage write SetProcRecteateImage;
    procedure SetOwner(AOwner: TObject);
    procedure Initialize;
    procedure NewCursor;
    procedure BrushSizeChanged(Sender: TObject);
    procedure BrushTransparencyChanged(Sender: TObject);
    function GetCur: HIcon;
    procedure ColorClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoSaveSettings(Sender: TObject);
    class function ID: string; override;
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
  end;

implementation

{ TBrushToolClass }

procedure TBrushToolClass.ClosePanel;
begin
  if Assigned(OnClosePanel) then
    OnClosePanel(Self);
  inherited;
end;

procedure TBrushToolClass.ClosePanelEvent(Sender: TObject);
begin
  CancelTempImage(True);
  ClosePanel;
end;

constructor TBrushToolClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel, IcoSave: TIcon;
begin
  inherited;
  Cur := 0;
  Align := AlClient;
  FButtonPressed := False;
  Drawing := False;
  Initialized := False;
  BrushSizeCaption := TStaticText.Create(AOwner);
  BrushSizeCaption.Top := 5;
  BrushSizeCaption.Left := 8;
  BrushSizeCaption.Caption := L('Brush size [%d]');
  BrushSizeCaption.Parent := Self;

  BrushSizeTrackBar := TTrackBar.Create(AOwner);
  BrushSizeTrackBar.Top := BrushSizeCaption.Top + BrushSizeCaption.Height + 5;
  BrushSizeTrackBar.Left := 8;
  BrushSizeTrackBar.Width := 160;
  BrushSizeTrackBar.OnChange := BrushSizeChanged;
  BrushSizeTrackBar.Min := 1;
  BrushSizeTrackBar.Max := 300;
  BrushSizeTrackBar.Position := DBKernel.ReadInteger('Editor', 'BrushToolSize', 30);
  BrushSizeTrackBar.Parent := Self;

  BrusTransparencyCaption := TStaticText.Create(AOwner);
  BrusTransparencyCaption.Top := BrushSizeTrackBar.Top + BrushSizeTrackBar.Height + 3;
  BrusTransparencyCaption.Left := 8;
  BrusTransparencyCaption.Caption := L('Transparency');
  BrusTransparencyCaption.Parent := Self;

  BrusTransparencyTrackBar := TTrackBar.Create(AOwner);
  BrusTransparencyTrackBar.Top := BrusTransparencyCaption.Top + BrusTransparencyCaption.Height + 5;
  BrusTransparencyTrackBar.Left := 8;
  BrusTransparencyTrackBar.Width := 160;
  BrusTransparencyTrackBar.OnChange := BrushTransparencyChanged;
  BrusTransparencyTrackBar.Min := 1;
  BrusTransparencyTrackBar.Max := 100;
  BrusTransparencyTrackBar.Position := DBKernel.ReadInteger('Editor', 'BrushTransparency', 100);
  BrusTransparencyTrackBar.Parent := Self;

  BrusTransparencyCaption.Caption := Format(L('Transparency [%d]'), [BrusTransparencyTrackBar.Position]);

  LabelMethod := TLabel.Create(AOwner);
  LabelMethod.Left := 8;
  LabelMethod.Top := BrusTransparencyTrackBar.Top + BrusTransparencyTrackBar.Height + 5;
  LabelMethod.Parent := Self;
  LabelMethod.Caption := L('Method') + ':';

  MethodDrawChooser := TComboBox.Create(AOwner);
  MethodDrawChooser.Top := LabelMethod.Top + LabelMethod.Height + 5;
  MethodDrawChooser.Left := 8;
  MethodDrawChooser.Width := 150;
  MethodDrawChooser.Height := 20;
  MethodDrawChooser.Parent := Self;
  MethodDrawChooser.Style := CsDropDownList;

  MethodDrawChooser.Items.Add(L('Normal'));
  MethodDrawChooser.Items.Add(L('Color replace'));
  MethodDrawChooser.ItemIndex := DBKernel.ReadInteger('Editor', 'BrushToolStyle', 0);
  MethodDrawChooser.OnChange := BrushTransparencyChanged;

  BrushColorChooser := TShape.Create(AOwner);
  BrushColorChooser.Top := MethodDrawChooser.Top + MethodDrawChooser.Height + 12;
  BrushColorChooser.Left := 10;
  BrushColorChooser.Width := 20;
  BrushColorChooser.Height := 20;
  BrushColorChooser.Brush.Color := DBKernel.ReadInteger('Editor', 'BrushToolColor', 0);
  BrushColorChooser.OnMouseDown := ColorClick;
  BrushColorChooser.Parent := Self;

  BrushColorCaption := TStaticText.Create(AOwner);
  BrushColorCaption.Top := MethodDrawChooser.Top + MethodDrawChooser.Height + 15;
  BrushColorCaption.Left := BrushColorChooser.Left + BrushColorChooser.Width + 5;
  BrushColorCaption.Caption := L('Brush color');
  BrushColorCaption.Parent := Self;

  FButtonCustomColor := TButton.Create(Self);
  FButtonCustomColor.Parent := Self;
  FButtonCustomColor.Top := BrushColorCaption.Top + BrushColorCaption.Height + 5;
  FButtonCustomColor.Width := 80;
  FButtonCustomColor.Height := 21;
  FButtonCustomColor.Left := 8;
  FButtonCustomColor.Caption := L('Choose color');
  FButtonCustomColor.OnMouseDown := ButtonMouseDown;
  FButtonCustomColor.OnMouseMove := ButtonMouseMove;
  FButtonCustomColor.OnMouseUp := ButtonMouseUp;

  BrushColorChooserDialog := TColorDialog.Create(AOwner);

  IcoOK := TIcon.Create;
  IcoCancel := TIcon.Create;
  IcoSave := TIcon.Create;
  IcoOK.Handle := LoadIcon(DBKernel.IconDllInstance, 'DOIT');
  IcoCancel.Handle := LoadIcon(DBKernel.IconDllInstance, 'CANCELACTION');
  IcoSave.Handle := LoadIcon(DBKernel.IconDllInstance, 'SAVETOFILE');

  SaveSettingsLink := TWebLink.Create(Self);
  SaveSettingsLink.Parent := AOwner as TWinControl;
  SaveSettingsLink.Text := L('Save settings');
  SaveSettingsLink.Top := FButtonCustomColor.Top + FButtonCustomColor.Height + 15;
  SaveSettingsLink.Left := 10;
  SaveSettingsLink.Visible := True;
  SaveSettingsLink.Color := ClBtnface;
  SaveSettingsLink.OnClick := DoSaveSettings;
  SaveSettingsLink.Icon := IcoSave;
  IcoSave.Free;

  MakeItLink := TWebLink.Create(Self);
  MakeItLink.Parent := AOwner as TWinControl;
  MakeItLink.Text := L('Apply');
  MakeItLink.Top := SaveSettingsLink.Top + SaveSettingsLink.Height + 5;
  MakeItLink.Left := 10;
  MakeItLink.Visible := True;
  MakeItLink.Color := ClBtnface;
  MakeItLink.OnClick := DoMakeImage;
  MakeItLink.Icon := IcoOK;
  MakeItLink.ImageCanRegenerate := True;
  IcoOK.Free;

  CloseLink := TWebLink.Create(Self);
  CloseLink.Parent := AOwner as TWinControl;
  CloseLink.Text := L('Close tool');
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  CloseLink.Left := 10;
  CloseLink.Visible := True;
  CloseLink.Color := ClBtnface;
  CloseLink.OnClick := ClosePanelEvent;
  CloseLink.Icon := IcoCancel;
  IcoCancel.Free;

  CloseLink.ImageCanRegenerate := True;
end;

destructor TBrushToolClass.Destroy;
begin
  F(BrushSizeCaption);
  F(BrushSizeTrackBar);
  F(BrusTransparencyCaption);
  F(BrusTransparencyTrackBar);
  F(BrushColorCaption);
  F(BrushColorChooser);
  F(BrushColorChooserDialog);
  if Cur <> 0 then
    DestroyIcon(Cur);
  F(MakeItLink);
  F(CloseLink);
  inherited;
end;

procedure TBrushToolClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

procedure TBrushToolClass.DrawBrush;
var
  R, G, B: Byte;
  Rad: Integer;
begin
  R := GetRValue(BrushColorChooser.Brush.Color);
  G := GetGValue(BrushColorChooser.Brush.Color);
  B := GetBValue(BrushColorChooser.Brush.Color);
  Rad := Max(1, Round(BrushSizeTrackBar.Position));
  DoBrush(FDrawlayer, Image.Width, Image.Height, BeginPoint.X, BeginPoint.Y, EndPoint.X, EndPoint.Y, R, G, B, Rad);
  LastRect := Rect(BeginPoint.X, BeginPoint.Y, EndPoint.X, EndPoint.Y);
  LastRect := NormalizeRect(LastRect);

  LastRect.Top := Max(0, LastRect.Top - Rad div 2);
  LastRect.Left := Max(0, LastRect.Left - Rad div 2);
  LastRect.Bottom := Min(Image.Height - 1, LastRect.Bottom + Rad div 2);
  LastRect.Right := Min(Image.Width - 1, LastRect.Right + Rad div 2);
  Editor.Transparency := BrusTransparencyTrackBar.Position / 100;
  if Assigned(FProcRecteateImage) then
    FProcRecteateImage(Self);
end;

procedure TBrushToolClass.Initialize;
begin
  NewImage := TBitmap.Create;
  NewImage.Assign(Image);
  SetTempImage(NewImage);
  Initialized:=true;
end;

function TBrushToolClass.LangID: string;
begin
  Result := 'BrushTool';
end;

procedure TBrushToolClass.MakeTransform;
var
  I: Integer;
  P: PARGBArray;
begin
  inherited;
  SetLength(P, Image.Height);
  for I := 0 to Image.Height - 1 do
    P[I] := NewImage.ScanLine[I];
  StretchFastATrans(0, 0, Image.Width, Image.Height, Image.Width, Image.Height, FDrawlayer, P,
    BrusTransparencyTrackBar.Position / 100, MethodDrawChooser.ItemIndex);
  ImageHistory.Add(NewImage, '{' + ID + '}[' + GetProperties + ']');
  SetImagePointer(NewImage);
  ClosePanel;
end;

procedure TBrushToolClass.SetBeginPoint(P: TPoint);
begin
  Drawing := True;
  BeginPoint := P;
  EndPoint := P;
  DrawBrush;
end;

procedure TBrushToolClass.SetEndPoint(P: TPoint);
begin
  Drawing := False;
end;

procedure TBrushToolClass.SetNextPoint(P: TPoint);
begin
  if Drawing then
  begin
    BeginPoint := EndPoint;
    EndPoint := P;
    DrawBrush;
  end;
end;

procedure TBrushToolClass.SetOwner(AOwner: TObject);
begin
  FOwner := AOwner;
end;

procedure TBrushToolClass.SetProcRecteateImage(const Value: TNotifyEvent);
begin
  FProcRecteateImage := Value;
end;

procedure TBrushToolClass.NewCursor;
var
  CurSize : integer;
  AndMask : TBitmap;
  IconInfo : TIconInfo;
  bit : TBitmap;
begin
  if not Initialized then
    Exit;

  CurSize := Min(500, Max(2, Round(BrushSizeTrackBar.Position * Editor.Zoom)));
  if not Editor.VirtualBrushCursor then
 begin
  bit:=TBitmap.Create;
  bit.PixelFormat:=pf1bit;
  bit.Width:=CurSize;
  bit.Height:=CurSize;
  bit.PixelFormat:=pf4bit;
  AndMask := TBitmap.Create;
  AndMask.Monochrome := true;
  AndMask.width:=CurSize;
  AndMask.height:=CurSize;
  AndMask.Canvas.Brush.Color := $ffffff;
  AndMask.Canvas.pen.Color:=$ffffff;
  AndMask.Canvas.FillRect(Rect(0, 0, bit.width, bit.height));
  bit.Canvas.pen.color:=$0;
  bit.Canvas.Brush.Color:=$0;
  bit.Canvas.FillRect(Rect(0, 0, bit.width, bit.height));
  bit.Canvas.pen.color:=$ffffff;
  bit.Canvas.ellipse(Rect(0, 0, bit.width, bit.height));
  IconInfo.fIcon := true;
  IconInfo.xHotspot := 1;
  IconInfo.yHotspot := 1;
  IconInfo.hbmMask := AndMask.Handle;
  IconInfo.hbmColor := bit.Handle;
  if Cur<>0 then DestroyIcon(Cur);
  Cur:=0;
  Cur:=CreateIconIndirect(IconInfo);
  AndMask.free;
  bit.Free;
  Screen.Cursors[67]:=Cur;
 end else
 begin
  ClearBrush(Editor.VBrush);
  MakeRadialBrush(Editor.VBrush,CurSize div 2);
 end;
end;

procedure TBrushToolClass.BrushSizeChanged(Sender: TObject);
begin
  BrushSizeCaption.Caption := Format(L('Brush size [%d]'), [BrushSizeTrackBar.Position]);
  NewCursor;
end;

function TBrushToolClass.GetCur: HIcon;
begin
  Result := Cur;
end;

procedure TBrushToolClass.ColorClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  BrushColorChooserDialog.Color := BrushColorChooser.Brush.Color;
  if BrushColorChooserDialog.Execute then
    BrushColorChooser.Brush.Color := BrushColorChooserDialog.Color;
end;

procedure TBrushToolClass.DoSaveSettings(Sender: TObject);
begin
  DBKernel.WriteInteger('Editor', 'BrushToolStyle', MethodDrawChooser.ItemIndex);
  DBKernel.WriteInteger('Editor', 'BrushToolColor', BrushColorChooser.Brush.Color);
  DBKernel.WriteInteger('Editor', 'BrushToolSize', BrushSizeTrackBar.Position);
  DBKernel.WriteInteger('Editor', 'BrushTransparency', BrusTransparencyTrackBar.Position);
end;

procedure TBrushToolClass.BrushTransparencyChanged(Sender: TObject);
begin
  if not Initialized then
    Exit;

  BrusTransparencyCaption.Caption := Format(L('Transparency [%d]'), [BrusTransparencyTrackBar.Position]);
  Editor.Transparency := BrusTransparencyTrackBar.Position / 100;

  if Assigned(FProcRecteateImage) then
    FProcRecteateImage(Self);
end;

procedure TBrushToolClass.ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Screen.Cursor := CrCross;
  FButtonPressed := True;
end;

procedure TBrushToolClass.ButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  C: TCanvas;
  P: TPoint;
begin
  if FButtonPressed then
  begin
    C := TCanvas.Create;
    GetCursorPos(P);
    C.Handle := GetDC(GetWindow(GetDesktopWindow, GW_OWNER));
    BrushColorChooser.Brush.Color := C.Pixels[P.X, P.Y];
    C.Free;
  end;
end;

procedure TBrushToolClass.ButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Screen.Cursor := CrDefault;
  FButtonPressed := False;
end;

function TBrushToolClass.GetProperties: string;
begin
  Result := '';
end;

class function TBrushToolClass.ID: string;
begin
  Result := '{542FC0AD-A013-4973-90D4-E6D6E9F65D2C}';
end;

procedure TBrushToolClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin

end;

procedure TBrushToolClass.SetProperties(Properties: String);
begin

end;

end.
