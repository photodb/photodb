unit CustomSelectTool;

interface

uses
  Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, Effects, ComCtrls,
  GraphicsBaseTypes, UnitDBKernel, uMemory;

type
  TCustomSelectToolClass = class(TToolsPanelClass)
  private
    { Private declarations }
    EditWidthLabel: TStaticText;
    EditHeightLabel: TStaticText;
    FFirstPoint: TPoint;
    FSecondPoint: TPoint;
    FMakingRect: Boolean;
    FResizingRect: Boolean;
    FxTop: Boolean;
    FxLeft: Boolean;
    FxRight: Boolean;
    FxBottom: Boolean;
    FxCenter: boolean;
    FBeginDragPoint: TPoint;
    FBeginFirstPoint: TPoint;
    FBeginSecondPoint: TPoint;
    EditLock : Boolean;
    FTerminating : Boolean;
    FAnyRect: boolean;
    procedure SetFirstPoint(const Value: TPoint);
    procedure SetSecondPoint(const Value: TPoint);
    procedure SetMakingRect(const Value: Boolean);
    procedure SetResizingRect(const Value: Boolean);
    procedure SetxBottom(const Value: Boolean);
    procedure SetxLeft(const Value: Boolean);
    procedure SetxRight(const Value: Boolean);
    procedure SetxTop(const Value: Boolean);
    procedure SetxCenter(const Value: boolean);
    procedure SetBeginDragPoint(const Value: TPoint);
    procedure SetBeginFirstPoint(const Value: TPoint);
    procedure SetBeginSecondPoint(const Value: TPoint);
    procedure EditWidthChanged(Sender : TObject);
    procedure EditheightChanged(Sender : TObject);
    procedure SetProcRecteateImage(const Value: TNotifyEvent);
    procedure SetAnyRect(const Value: boolean);
  protected
    function LangID: string; override;
  public
    { Public declarations }
    FProcRecteateImage: TNotifyEvent;
    EditWidth: TEdit;
    EditHeight: TEdit;
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    SaveSettingsLink: TWebLink;
    function GetProperties: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClosePanel; override;
    procedure ClosePanelEvent(Sender: TObject);
    property FirstPoint: TPoint read FFirstPoint write SetFirstPoint;
    property SecondPoint: TPoint read FSecondPoint write SetSecondPoint;
    property MakingRect: Boolean read FMakingRect write SetMakingRect;
    property ResizingRect: Boolean read FResizingRect write SetResizingRect;
    procedure DoEffect(Image: TBitmap; Rect: TRect; FullImage: Boolean); virtual; abstract;
    procedure DoSaveSettings(Sender: TObject); virtual; abstract;
    property XTop: Boolean read FxTop write SetxTop;
    property XLeft: Boolean read FxLeft write SetxLeft;
    property XBottom: Boolean read FxBottom write SetxBottom;
    property XRight: Boolean read FxRight write SetxRight;
    property XCenter: Boolean read FxCenter write SetxCenter;
    property BeginDragPoint: TPoint read FBeginDragPoint write SetBeginDragPoint;
    property BeginFirstPoint: TPoint read FBeginFirstPoint write SetBeginFirstPoint;
    property BeginSecondPoint: TPoint read FBeginSecondPoint write SetBeginSecondPoint;
    property ProcRecteateImage: TNotifyEvent read FProcRecteateImage write SetProcRecteateImage;
    procedure MakeTransform; override;
    procedure DoMakeImage(Sender: TObject);
    procedure DoBorder(Bitmap: TBitmap; Rect: TRect); virtual; abstract;
    function GetZoom: Extended;
    function Termnating: Boolean;
    property AnyRect: Boolean read FAnyRect write SetAnyRect;
  end;

implementation

{ TRedEyeToolPanelClass }

uses ImEditor;

procedure TCustomSelectToolClass.ClosePanel;
begin
  if Assigned(OnClosePanel) then
    OnClosePanel(Self);
  inherited;
end;

procedure TCustomSelectToolClass.ClosePanelEvent(Sender: TObject);
begin
  ClosePanel;
end;

constructor TCustomSelectToolClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel, IcoSave: TIcon;
begin
  inherited;
  FAnyRect := False;
  FTerminating := False;
  Align := AlClient;
  FMakingRect := False;
  FResizingRect := False;
  EditLock := False;
  FProcRecteateImage := nil;

  EditWidthLabel := TStaticText.Create(AOwner);
  EditWidthLabel.Caption := L('Width');
  EditWidthLabel.Top := 8;
  EditWidthLabel.Left := 8;
  EditWidthLabel.Parent := AOwner as TWinControl;

  EditWidth := TEdit.Create(AOwner);
  EditWidth.OnChange := EditWidthChanged;
  EditWidth.Top := EditWidthLabel.Top + EditWidthLabel.Height + 5;
  EditWidth.Width := 60;
  EditWidth.Left := 8;
  EditWidth.Parent := AOwner as TWinControl;

  EditHeight := TEdit.Create(AOwner);
  EditHeight.OnChange := EditHeightChanged;
  EditHeight.Top := EditWidthLabel.Top + EditWidthLabel.Height + 5;
  EditHeight.Width := 60;
  EditHeight.Left := EditWidth.Left + EditWidth.Width + 5;
  EditHeight.Parent := AOwner as TWinControl;

  EditHeightLabel := TStaticText.Create(AOwner);
  EditHeightLabel.Caption := L('Height');
  EditHeightLabel.Top := 8;
  EditHeightLabel.Left := EditHeight.Left;
  EditHeightLabel.Parent := AOwner as TWinControl;

  IcoOK := TIcon.Create;
  IcoCancel := TIcon.Create;
  IcoSave := TIcon.Create;
  IcoOK.Handle := LoadIcon(DBKernel.IconDllInstance, 'DOIT');
  IcoCancel.Handle := LoadIcon(DBKernel.IconDllInstance, 'CANCELACTION');
  IcoSave.Handle := LoadIcon(DBKernel.IconDllInstance, 'SAVETOFILE');

  SaveSettingsLink := TWebLink.Create(Self);
  SaveSettingsLink.Parent := AOwner as TWinControl;
  SaveSettingsLink.Text := L('Save settings');
  SaveSettingsLink.Top := 120;
  SaveSettingsLink.Left := 10;
  SaveSettingsLink.Visible := True;
  SaveSettingsLink.Color := ClBtnface;
  SaveSettingsLink.OnClick := DoSaveSettings;
  SaveSettingsLink.Icon := IcoSave;
  SaveSettingsLink.ImageCanRegenerate := True;
  IcoSave.Free;

  MakeItLink := TWebLink.Create(Self);
  MakeItLink.Parent := AOwner as TWinControl;
  MakeItLink.Text := L('Apply');
  MakeItLink.Top := 140;
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
  CloseLink.Top := 160;
  CloseLink.Left := 10;
  CloseLink.Visible := True;
  CloseLink.Color := ClBtnface;
  CloseLink.OnClick := ClosePanelEvent;
  CloseLink.Icon := IcoCancel;
  CloseLink.ImageCanRegenerate := True;
  IcoCancel.Free;

end;

destructor TCustomSelectToolClass.Destroy;
begin
  F(EditWidthLabel);
  F(EditHeightLabel);
  F(EditWidth);
  F(EditHeight);
  F(CloseLink);
  F(SaveSettingsLink);
  inherited;
end;

procedure TCustomSelectToolClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

procedure TCustomSelectToolClass.EditheightChanged(Sender: TObject);
begin
  if not EditLock then
  begin
    if FFirstPoint.Y < FSecondPoint.Y then
      FSecondPoint.Y := FFirstPoint.Y + StrToIntDef(EditHeight.Text, 10)
    else
      FFirstPoint.Y := FSecondPoint.Y + StrToIntDef(EditHeight.Text, 10);
    if Assigned(FProcRecteateImage) then
      FProcRecteateImage(Self);
  end;
end;

procedure TCustomSelectToolClass.EditWidthChanged(Sender: TObject);
begin
  if not EditLock then
  begin
    if FFirstPoint.X < FSecondPoint.X then
      FSecondPoint.X := FFirstPoint.X + StrToIntDef(EditWidth.Text, 10)
    else
      FFirstPoint.X := FSecondPoint.X + StrToIntDef(EditWidth.Text, 10);
    if Assigned(FProcRecteateImage) then
      FProcRecteateImage(Self);
  end;
end;

function TCustomSelectToolClass.GetProperties: string;
begin
//
end;

function TCustomSelectToolClass.GetZoom: Extended;
begin
  Result := Editor.Zoom;
end;

function TCustomSelectToolClass.LangID: string;
begin
  Result := 'SelectionTool';
end;

procedure TCustomSelectToolClass.MakeTransform;
var
  Bitmap: TBitmap;
  Point1, Point2: TPoint;
begin
  inherited;
  FTerminating := True;
  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat := Pf24bit;
  Bitmap.Assign(Image);
  if FAnyRect then
  begin
    Point1.X := Min(FirstPoint.X, SecondPoint.X);
    Point1.Y := Min(FirstPoint.Y, SecondPoint.Y);
    Point2.X := Max(FirstPoint.X, SecondPoint.X);
    Point2.Y := Max(FirstPoint.Y, SecondPoint.Y);
  end else
  begin
    Point1.X := Max(1, Min(FirstPoint.X, SecondPoint.X));
    Point1.Y := Max(1, Min(FirstPoint.Y, SecondPoint.Y));
    Point2.X := Min(Max(FirstPoint.X, SecondPoint.X), Image.Width);
    Point2.Y := Min(Max(FirstPoint.Y, SecondPoint.Y), Image.Height);
  end;
  DoEffect(Bitmap, Rect(Point1, Point2), True);
  Image.Free;
  ImageHistory.Add(Bitmap, '{' + ID + '}[' + GetProperties + ']');
  SetImagePointer(Bitmap);
  ClosePanel;
end;

procedure TCustomSelectToolClass.SetAnyRect(const Value: boolean);
begin
  FAnyRect := Value;
end;

procedure TCustomSelectToolClass.SetBeginDragPoint(const Value: TPoint);
begin
  FBeginDragPoint := Value;
end;

procedure TCustomSelectToolClass.SetBeginFirstPoint(const Value: TPoint);
begin
  FBeginFirstPoint := Value;
end;

procedure TCustomSelectToolClass.SetBeginSecondPoint(const Value: TPoint);
begin
 FBeginSecondPoint := Value;
end;

procedure TCustomSelectToolClass.SetFirstPoint(const Value: TPoint);
begin
  FFirstPoint := Value;
  EditLock := True;
  EditWidth.Text := IntToStr(Abs(FFirstPoint.X - FSecondPoint.X));
  Editheight.Text := IntToStr(Abs(FFirstPoint.Y - FSecondPoint.Y));
  EditLock := False;
end;

procedure TCustomSelectToolClass.SetMakingRect(const Value: Boolean);
begin
  FMakingRect := Value;
end;

procedure TCustomSelectToolClass.SetProcRecteateImage(
  const Value: TNotifyEvent);
begin
  FProcRecteateImage := Value;
end;

procedure TCustomSelectToolClass.SetResizingRect(const Value: Boolean);
begin
  FResizingRect := Value;
end;

procedure TCustomSelectToolClass.SetSecondPoint(const Value: TPoint);
begin
  FSecondPoint := Value;
  EditLock := True;
  EditWidth.Text := IntToStr(Abs(FFirstPoint.X - FSecondPoint.X));
  Editheight.Text := IntToStr(Abs(FFirstPoint.Y - FSecondPoint.Y));
  EditLock := False;
end;

procedure TCustomSelectToolClass.SetxBottom(const Value: Boolean);
begin
  FxBottom := Value;
end;

procedure TCustomSelectToolClass.SetxCenter(const Value: boolean);
begin
  FxCenter := Value;
end;

procedure TCustomSelectToolClass.SetxLeft(const Value: Boolean);
begin
  FxLeft := Value;
end;

procedure TCustomSelectToolClass.SetxRight(const Value: Boolean);
begin
  FxRight := Value;
end;

procedure TCustomSelectToolClass.SetxTop(const Value: Boolean);
begin
  FxTop := Value;
end;

function TCustomSelectToolClass.Termnating: Boolean;
begin
  Result := FTerminating;
end;

end.
