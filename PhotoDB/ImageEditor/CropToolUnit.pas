unit CropToolUnit;

interface

uses
  Windows, ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, uSettings,
  GraphicsBaseTypes, UnitDBKernel, Menus, uMemory;

type
  TCropToolPanelClass = class(TToolsPanelClass)
  private
    { Private declarations }
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    SaveSettingsLink: TWebLink;
    EditWidth: TEdit;
    EditHeight: TEdit;
    EditWidthLabel: TLabel;
    EditHeightLabel: TLabel;
    FFirstPoint: TPoint;
    FSecondPoint: TPoint;
    FMakingRect: Boolean;
    FResizingRect: Boolean;
    FxTop: Boolean;
    FxLeft: Boolean;
    FxRight: Boolean;
    FxBottom: Boolean;
    FxCenter: Boolean;
    FBeginDragPoint: TPoint;
    FBeginFirstPoint: TPoint;
    FBeginSecondPoint: TPoint;
    EditLock: Boolean;
    FProcRecteateImage: TNotifyEvent;
    CheckProportions: TCheckBox;
    EditPrWidth: TEdit;
    EditPrHeight: TEdit;
    EditPrWidthLabel: TLabel;
    EditPrHeightLabel: TLabel;
    FKeepProportions: Boolean;
    FProportionsWidth: Integer;
    FProportionsHeight: Integer;
    ComboBoxProp: TComboBox;
    ComboBoxPropLabel : TLabel;
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
    procedure SetKeepProportions(const Value: boolean);
    procedure SetProportionsHeight(const Value: Integer);
    procedure SetProportionsWidth(const Value: Integer);
  protected
    function LangID: string; override;
  public
    { Public declarations }
    class function ID: string; override;
    function GetProperties: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClosePanel; override;
    procedure ClosePanelEvent(Sender: TObject);
    procedure CheckProportionsClick(Sender: TObject);
    procedure EditPrWidthChange(Sender: TObject);
    procedure EditPrHeightChange(Sender: TObject);
    procedure DoSaveSettings(Sender: TObject);
    property FirstPoint: TPoint read FFirstPoint write SetFirstPoint;
    property SecondPoint: TPoint read FSecondPoint write SetSecondPoint;
    property MakingRect: Boolean read FMakingRect write SetMakingRect;
    property ResizingRect: Boolean read FResizingRect write SetResizingRect;
    procedure DoCropToolToImage(Image: TBitmap; Rect: TRect);
    procedure ChangeSize(Sender: TObject);
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
    property KeepProportions: Boolean read FKeepProportions write SetKeepProportions;
    property ProportionsWidth: Integer read FProportionsWidth write SetProportionsWidth;
    property ProportionsHeight: Integer read FProportionsHeight write SetProportionsHeight;

    procedure SetProperties(Properties: string); override;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
  end;

implementation

uses
  ImEditor;

{ TCropToolPanelClass }

procedure TCropToolPanelClass.CheckProportionsClick(Sender: TObject);
begin
  KeepProportions := CheckProportions.Checked;
  EditPrWidth.Enabled := CheckProportions.Checked;
  EditPrHeight.Enabled := CheckProportions.Checked;
end;

procedure TCropToolPanelClass.ClosePanel;
begin
  if Assigned(OnClosePanel) then
    OnClosePanel(Self);
  inherited;
end;

procedure TCropToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
  ClosePanel;
end;

constructor TCropToolPanelClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel, IcoSave: TIcon;
begin
  inherited;
  Align := AlClient;
  FMakingRect := False;
  FResizingRect := False;
  EditLock := False;
  FProcRecteateImage := nil;
  KeepProportions := False;
  FProportionsWidth := 15;
  FProportionsHeight := 10;

  EditWidth := TEdit.Create(AOwner);
  EditWidth.OnChange := EditWidthChanged;
  EditWidth.Top := 25;
  EditWidth.Width := 60;
  EditWidth.Left := 10;
  EditWidth.Text := '0';
  EditWidth.Parent := Self;

  EditHeight := TEdit.Create(AOwner);
  EditHeight.OnChange := EditHeightChanged;
  EditHeight.Top := 25;
  EditHeight.Width := 60;
  EditHeight.Left := EditWidth.Left + EditWidth.Width + 10;
  EditHeight.Parent := Self;
  EditHeight.Text := '0';

  EditWidthLabel := TLabel.Create(AOwner);
  EditWidthLabel.Caption := L('Width');
  EditWidthLabel.Top := 10;
  EditWidthLabel.Left := 10;
  EditWidthLabel.Parent := Self;

  EditHeightLabel := TLabel.Create(AOwner);
  EditHeightLabel.Caption := L('Height');
  EditHeightLabel.Top := 10;
  EditHeightLabel.Left := EditWidth.Left + EditWidth.Width + 10;
  EditHeightLabel.Parent := Self;

  CheckProportions := TCheckBox.Create(AOwner);
  CheckProportions.Top := EditWidth.Top + EditWidth.Height + 5;
  CheckProportions.Left := 10;
  CheckProportions.Width := 150;
  CheckProportions.Caption := L('Keep proportions');
  CheckProportions.Enabled := True;
  CheckProportions.Parent := Self;
  CheckProportions.OnClick := CheckProportionsClick;

  EditPrWidthLabel := TLabel.Create(AOwner);
  EditPrWidthLabel.Caption := L('Width');
  EditPrWidthLabel.Left := 10;
  EditPrWidthLabel.Top := CheckProportions.Top + CheckProportions.Height + 5;
  EditPrWidthLabel.Parent := Self;

  EditPrWidth := TEdit.Create(AOwner);
  EditPrWidth.OnChange := EditWidthChanged;
  EditPrWidth.Top := EditPrWidthLabel.Top + EditPrWidthLabel.Height + 5;
  EditPrWidth.Width := 60;
  EditPrWidth.Left := 10;
  EditPrWidth.Text := IntToStr(FProportionsWidth);
  EditPrWidth.Enabled := False;
  EditPrWidth.OnChange := EditPrWidthChange;
  EditPrWidth.Parent := Self;

  EditPrHeight := TEdit.Create(AOwner);
  EditPrHeight.OnChange := EditHeightChanged;
  EditPrHeight.Top := EditPrWidthLabel.Top + EditPrWidthLabel.Height + 5;
  EditPrHeight.Width := 60;
  EditPrHeight.Left := EditPrWidth.Left + EditPrWidth.Width + 10;
  EditPrHeight.Text := IntToStr(FProportionsHeight);
  EditPrHeight.Enabled := False;
  EditPrHeight.OnChange := EditPrHeightChange;
  EditPrHeight.Parent := Self;

  EditPrHeightLabel := TLabel.Create(AOwner);
  EditPrHeightLabel.Caption := L('Height');
  EditPrHeightLabel.Top := CheckProportions.Top + CheckProportions.Height + 5;
  EditPrHeightLabel.Left := EditPrWidth.Left + EditPrWidth.Width + 10;
  EditPrHeightLabel.Parent := Self;

  ComboBoxPropLabel := TLabel.Create(AOwner);
  ComboBoxPropLabel.Caption := L('Proportions') + ':';
  ComboBoxPropLabel.Top := EditPrHeight.Top + EditPrHeight.Height + 5;
  ComboBoxPropLabel.Left := 8;
  ComboBoxPropLabel.Parent := Self;

  ComboBoxProp := TComboBox.Create(AOwner);
  ComboBoxProp.Top := ComboBoxPropLabel.Top + ComboBoxPropLabel.Height + 5;
  ComboBoxProp.Left := 8;
  ComboBoxProp.Width := 170;
  ComboBoxProp.Parent := AOwner as TWinControl;
  ComboBoxProp.OnChange := ChangeSize;
  ComboBoxProp.Style := CsDropDownList;
  ComboBoxProp.Items.Add('1/1');
  ComboBoxProp.Items.Add('1/2');
  ComboBoxProp.Items.Add('2/3');
  ComboBoxProp.Items.Add('3/4');
  ComboBoxProp.Items.Add('8/12');
  ComboBoxProp.Items.Add('9/13');
  ComboBoxProp.Items.Add('10/15');
  ComboBoxProp.Items.Add('13/18');
  ComboBoxProp.Items.Add('20/25');
  ComboBoxProp.Items.Add('2/1');
  ComboBoxProp.Items.Add('3/2');
  ComboBoxProp.Items.Add('4/3');
  ComboBoxProp.Items.Add('12/8');
  ComboBoxProp.Items.Add('13/9');
  ComboBoxProp.Items.Add('15/10');
  ComboBoxProp.Items.Add('18/13');
  ComboBoxProp.Items.Add('25/20');
  ComboBoxProp.ItemIndex := 0;

  IcoSave := TIcon.Create;
  IcoSave.Handle := LoadIcon(HInstance, 'SAVETOFILE');

  SaveSettingsLink := TWebLink.Create(nil);
  SaveSettingsLink.Parent := AOwner as TWinControl;
  SaveSettingsLink.Text := L('Save settings');
  SaveSettingsLink.Top := ComboBoxProp.Top + ComboBoxProp.Height + 10;
  SaveSettingsLink.Left := 10;
  SaveSettingsLink.Visible := True;
  SaveSettingsLink.Color := ClBtnface;
  SaveSettingsLink.OnClick := DoSaveSettings;
  SaveSettingsLink.Icon := IcoSave;
  SaveSettingsLink.LoadImage;
  IcoSave.Free;

  IcoOK := TIcon.Create;
  IcoCancel := TIcon.Create;
  IcoOK.Handle := LoadIcon(HInstance, 'DOIT');
  IcoCancel.Handle := LoadIcon(HInstance, 'CANCELACTION');

  MakeItLink := TWebLink.Create(Self);
  MakeItLink.Parent := Self;
  MakeItLink.Text := L('Apply');
  MakeItLink.Top := SaveSettingsLink.Top + SaveSettingsLink.Height + 5;
  MakeItLink.Left := 10;
  MakeItLink.Visible := True;
  MakeItLink.Color := ClBtnface;
  MakeItLink.OnClick := DoMakeImage;
  MakeItLink.Icon := IcoOK;
  MakeItLink.LoadImage;
  IcoOK.Free;

  CloseLink := TWebLink.Create(Self);
  CloseLink.Parent := Self;
  CloseLink.Text := L('Close tool');
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  CloseLink.Left := 10;
  CloseLink.Visible := True;
  CloseLink.Color := ClBtnface;
  CloseLink.OnClick := ClosePanelEvent;
  CloseLink.Icon := IcoCancel;
  CloseLink.LoadImage;
  IcoCancel.Free;

  ComboBoxProp.ItemIndex := Settings.ReadInteger('Editor', 'Crop_Tool_PropSelect', 0);
  EditPrWidth.Text := IntToStr(Settings.ReadInteger('Editor', 'Crop_Tool_Prop_W', 15));
  EditPrHeight.Text := IntToStr(Settings.ReadInteger('Editor', 'Crop_Tool_Prop_H', 10));
  CheckProportions.Checked := Settings.ReadBool('Editor', 'Crop_Tool_Save_Prop', False);
end;

destructor TCropToolPanelClass.Destroy;
begin
  F(ComboBoxProp);
  F(ComboBoxPropLabel);
  F(CheckProportions);
  F(EditPrWidth);
  F(EditPrHeight);
  F(EditPrWidthLabel);
  F(EditPrHeightLabel);
  F(EditWidthLabel);
  F(EditHeightLabel);
  F(EditWidth);
  F(EditHeight);
  F(CloseLink);
  F(SaveSettingsLink);

  inherited;
end;

procedure TCropToolPanelClass.DoCropToolToImage(Image: TBitmap; Rect: TRect);
var
  W, H, I, J: Integer;
  Xdp: array of PARGB;
  Rc, Gc, Bc: Byte;
  Rct: TRect;

  procedure Darkness(var RGB: TRGB); inline;
  begin
    RGB.R := RGB.R div 3;
    RGB.G := RGB.G div 3;
    RGB.B := RGB.B div 3;
  end;

  procedure Border(I, J: Integer; var RGB: TRGB); inline;
  begin
    if Odd((I + J) div 3) then
    begin
      RGB.R := RGB.R div 5;
      RGB.G := RGB.G div 5;
      RGB.B := RGB.B div 5;
    end else
    begin
      RGB.R := RGB.R xor $FF;
      RGB.G := RGB.G xor $FF;
      RGB.B := RGB.B xor $FF;
    end;
  end;

  procedure Center(var RGB: TRGB); inline;
  begin
    RGB.R := not RGB.R;
    RGB.G := not RGB.G;
    RGB.B := not RGB.B;
  end;

begin
  Rct.Top := Min(Rect.Top, Rect.Bottom);
  Rct.Bottom := Max(Rect.Top, Rect.Bottom);
  Rct.Left := Min(Rect.Left, Rect.Right);
  Rct.Right := Max(Rect.Left, Rect.Right);
  Rect := Rct;
  Rc := GetRValue(ColorToRGB(Color));
  Gc := GetGValue(ColorToRGB(Color));
  Bc := GetBValue(ColorToRGB(Color));
  Image.PixelFormat := Pf24bit;

  SetLength(Xdp, Image.Height);
  for I := 0 to Image.Height - 1 do
    Xdp[I] := Image.ScanLine[I];
  for I := 0 to Min(Rect.Top - 1, Image.Height - 1) do
  begin
    for J := 0 to Image.Width - 1 do
    begin
      if (I = Rect.Top - 1) and (J > Rect.Left) and (J < Rect.Right) then
        Border(I, J, Xdp[I, J])
      else
        Darkness(Xdp[I, J]);

    end;
  end;
  for I := Max(0, Rect.Bottom) to Image.Height - 1 do
    for J := 0 to Image.Width - 1 do
    begin
      if (I = Rect.Bottom) and (J > Rect.Left) and (J < Rect.Right) then
        Border(I, J, Xdp[I, J])
      else
        Darkness(Xdp[I, J]);

    end;
  for I := Max(0, Rect.Top) to Min(Rect.Bottom - 1, Image.Height - 1) do
  begin
    for J := 0 to Min(Rect.Left - 1, Image.Width - 1) do
      Darkness(Xdp[I, J]);

    J := Max(0, Min(Rect.Left - 1, Image.Width - 1));
    Border(I, J, Xdp[I, J]);
  end;
  for I := Max(0, Rect.Top) to Min(Rect.Bottom - 1, Image.Height - 1) do
  begin
    for J := Max(0, Rect.Right) to Image.Width - 1 do
      Darkness(Xdp[I, J]);

    J := Min(Image.Width - 1, Max(0, Rect.Right));
    Border(I, J, Xdp[I, J]);
  end;

  H := Abs(Rect.Top - Rect.Bottom) div 8;
  W := Abs(Rect.Left - Rect.Right) div 8;

  if ((Rect.Top + Rect.Bottom) div 2 < Image.Height - 1) and ((Rect.Top + Rect.Bottom) div 2 > 0) then
    for I := (Rect.Left + Rect.Right) div 2 - W to (Rect.Left + Rect.Right) div 2 + W do
      if (I > 0) and (I < Image.Width - 1) then
        Center(Xdp[(Rect.Top + Rect.Bottom) div 2, I]);

  if ((Rect.Left + Rect.Right) div 2 < Image.Width - 1) and ((Rect.Left + Rect.Right) div 2 > 0) then
    for I := (Rect.Top + Rect.Bottom) div 2 - H to (Rect.Top + Rect.Bottom) div 2 + H do
      if (I > 0) and (I < Image.Height - 1) then
        Center(Xdp[I, (Rect.Left + Rect.Right) div 2]);

end;

procedure TCropToolPanelClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

procedure TCropToolPanelClass.EditheightChanged(Sender: TObject);
var
  Point1, Point2, P: TPoint;
  W, H: Integer;
  Prop: Extended;

  function Znak(X: Extended): Extended;
  begin
    if X >= 0 then
      Result := 1
    else
      Result := -1;
  end;

begin
  if not EditLock then
  begin
    if Image = nil then
      Exit;
    H := StrToIntDef(EditHeight.Text, 15);
    Point1.X := Max(0, Min(FirstPoint.X, SecondPoint.X));
    Point1.Y := Max(0, Min(FirstPoint.Y, SecondPoint.Y));
    Point2.X := Min(Max(FirstPoint.X, SecondPoint.X), Image.Width);
    Point2.Y := Min(Max(FirstPoint.Y, SecondPoint.Y), Image.Height);
    FFirstPoint := Point1;
    FSecondPoint := Point2;

    P.X := Math.Min(Image.Width, Math.Max(0, SecondPoint.X));
    P.Y := Math.Min(Image.Height, Math.Max(0, FirstPoint.Y + H));

    if KeepProportions then
    begin
      W := 1;
      H := -(FirstPoint.Y - P.Y);
      if W * H = 0 then
        Exit;
      if ProportionsHeight <> 0 then
        Prop := ProportionsWidth / ProportionsHeight
      else
        Prop := 1;
      if Abs(W / H) < Abs(Prop) then
      begin
        if W < 0 then
          W := -Round(Abs(H) * (Prop))
        else
          W := Round(Abs(H) * (Prop));
        if FirstPoint.X + W > Image.Width then
        begin
          W := Image.Width - FirstPoint.X;
          H := Round(Znak(H) * W / Prop);
        end;
        if FirstPoint.X + W < 0 then
        begin
          W := -FirstPoint.X;
          H := -Round(Znak(H) * W / Prop);
        end;
        EditLock := True;
        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
        EditLock := False;
      end
      else
      begin
        if H < 0 then
          H := -Round(Abs(W) * (1 / Prop))
        else
          H := Round(Abs(W) * (1 / Prop));
        if FirstPoint.Y + H > Image.Height then
        begin
          H := Image.Height - FirstPoint.Y;
          W := Round(Znak(W) * (H * Prop));
        end;
        if FirstPoint.Y + H < 0 then
        begin
          H := -FirstPoint.Y;
          W := -Round(Znak(W) * (H * Prop));
        end;
        EditLock := True;
        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
        EditLock := False;
      end;
    end else
    begin
      EditLock := True;
      SecondPoint := P;
      EditLock := False;
    end;

    if Assigned(FProcRecteateImage) then
      FProcRecteateImage(Self);
  end;
end;

procedure TCropToolPanelClass.EditPrWidthChange(Sender: TObject);
begin
  FProportionsWidth := StrToIntDef(EditPrWidth.Text, 1);
end;

procedure TCropToolPanelClass.EditPrHeightChange(Sender: TObject);
begin
  FProportionsHeight := StrToIntDef(EditPrHeight.Text, 1);
end;

procedure TCropToolPanelClass.EditWidthChanged(Sender: TObject);
var
  Point1, Point2, P: TPoint;
  W, H: Integer;
  Prop: Extended;

  function Znak(X: Extended): Extended;
  begin
    if X >= 0 then
      Result := 1
    else
      Result := -1;
  end;

begin
  if not EditLock then
  begin
    if Image = nil then
      Exit;
    W := StrToIntDef(EditWidth.Text, 15);
    Point1.X := Max(0, Min(FirstPoint.X, SecondPoint.X));
    Point1.Y := Max(0, Min(FirstPoint.Y, SecondPoint.Y));
    Point2.X := Min(Max(FirstPoint.X, SecondPoint.X), Image.Width);
    Point2.Y := Min(Max(FirstPoint.Y, SecondPoint.Y), Image.Height);
    FFirstPoint := Point1;
    FSecondPoint := Point2;
    P.X := Math.Min(Image.Width, Math.Max(0, FirstPoint.X + W));
    P.Y := Math.Min(Image.Height, Math.Max(0, SecondPoint.Y));

    if KeepProportions then
    begin
      W := -(FirstPoint.X - P.X);
      H := 1;
      if W * H = 0 then
        Exit;
      if ProportionsHeight <> 0 then
        Prop := ProportionsWidth / ProportionsHeight
      else
        Prop := 1;
      if Abs(W / H) < Abs(Prop) then
      begin
        if W < 0 then
          W := -Round(Abs(H) * (Prop))
        else
          W := Round(Abs(H) * (Prop));
        if FirstPoint.X + W > Image.Width then
        begin
          W := Image.Width - FirstPoint.X;
          H := Round(Znak(H) * W / Prop);
        end;
        if FirstPoint.X + W < 0 then
        begin
          W := -FirstPoint.X;
          H := -Round(Znak(H) * W / Prop);
        end;
        EditLock := True;
        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
        EditLock := False;
      end else
      begin
        if H < 0 then
          H := -Round(Abs(W) * (1 / Prop))
        else
          H := Round(Abs(W) * (1 / Prop));
        if FirstPoint.Y + H > Image.Height then
        begin
          H := Image.Height - FirstPoint.Y;
          W := Round(Znak(W) * (H * Prop));
        end;
        if FirstPoint.Y + H < 0 then
        begin
          H := -FirstPoint.Y;
          W := -Round(Znak(W) * (H * Prop));
        end;
        EditLock := True;
        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
        EditLock := False;
      end;
    end else
    begin
      EditLock := True;
      SecondPoint := P;
      EditLock := False;
    end;

    if Assigned(FProcRecteateImage) then
      FProcRecteateImage(Self);
  end;
end;

procedure TCropToolPanelClass.MakeTransform;
var
  Bitmap: TBitmap;
  Point1, Point2: TPoint;
  I, J: Integer;
  Ps, Pd: PARGB;
begin
  inherited;
  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat := Pf24bit;
  Point1.X := Max(0, Min(FirstPoint.X, SecondPoint.X));
  Point1.Y := Max(0, Min(FirstPoint.Y, SecondPoint.Y));
  Point2.X := Min(Max(FirstPoint.X, SecondPoint.X), Image.Width);
  Point2.Y := Min(Max(FirstPoint.Y, SecondPoint.Y), Image.Height);
  Bitmap.Width := Point2.X - Point1.X;
  Bitmap.Height := Point2.Y - Point1.Y;

  for I := Point1.Y to Point2.Y - 1 do
  begin
    Ps := Image.ScanLine[I];
    Pd := Bitmap.ScanLine[I - (Point1.Y)];
    for J := Point1.X to Point2.X - 1 do
    begin
      Pd[J - Point1.X] := Ps[J];
    end;

  end;
  Image.Free;
  ImageHistory.Add(Bitmap, '{' + ID + '}[' + GetProperties + ']');
  SetImagePointer(Bitmap);
  ClosePanel;
end;

procedure TCropToolPanelClass.SetBeginDragPoint(const Value: TPoint);
begin
  FBeginDragPoint := Value;
end;

procedure TCropToolPanelClass.SetBeginFirstPoint(const Value: TPoint);
begin
  FBeginFirstPoint := Value;
end;

procedure TCropToolPanelClass.SetBeginSecondPoint(const Value: TPoint);
begin
  FBeginSecondPoint := Value;
end;

procedure TCropToolPanelClass.SetFirstPoint(const Value: TPoint);
begin
  FFirstPoint := Value;
  EditLock := True;
  EditWidth.Text := IntToStr(Abs(FFirstPoint.X - FSecondPoint.X));
  Editheight.Text := IntToStr(Abs(FFirstPoint.Y - FSecondPoint.Y));
  EditLock := False;
end;

procedure TCropToolPanelClass.SetKeepProportions(const Value: boolean);
begin
 FKeepProportions := Value;
end;

procedure TCropToolPanelClass.SetMakingRect(const Value: Boolean);
begin
  FMakingRect := Value;
end;

procedure TCropToolPanelClass.SetProcRecteateImage(
  const Value: TNotifyEvent);
begin
  FProcRecteateImage := Value;
end;

procedure TCropToolPanelClass.SetProportionsHeight(const Value: Integer);
begin
  FProportionsHeight := Value;
end;

procedure TCropToolPanelClass.SetProportionsWidth(const Value: Integer);
begin
  FProportionsWidth := Value;
end;

procedure TCropToolPanelClass.SetResizingRect(const Value: Boolean);
begin
  FResizingRect := Value;
end;

procedure TCropToolPanelClass.SetSecondPoint(const Value: TPoint);
begin
  FSecondPoint := Value;
  EditLock := True;
  EditWidth.Text := IntToStr(Abs(FFirstPoint.X - FSecondPoint.X));
  Editheight.Text := IntToStr(Abs(FFirstPoint.Y - FSecondPoint.Y));
  EditLock := False;
end;

procedure TCropToolPanelClass.SetxBottom(const Value: Boolean);
begin
  FxBottom := Value;
end;

procedure TCropToolPanelClass.SetxCenter(const Value: boolean);
begin
  FxCenter := Value;
end;

procedure TCropToolPanelClass.SetxLeft(const Value: Boolean);
begin
  FxLeft := Value;
end;

procedure TCropToolPanelClass.SetxRight(const Value: Boolean);
begin
  FxRight := Value;
end;

procedure TCropToolPanelClass.SetxTop(const Value: Boolean);
begin
  FxTop := Value;
end;

procedure TCropToolPanelClass.DoSaveSettings(Sender: TObject);
begin
  Settings.WriteInteger('Editor', 'Crop_Tool_PropSelect', ComboBoxProp.ItemIndex);
  Settings.WriteInteger('Editor', 'Crop_Tool_Prop_W', StrToIntDef(EditPrWidth.Text, 15));
  Settings.WriteInteger('Editor', 'Crop_Tool_Prop_H', StrToIntDef(EditPrHeight.Text, 10));
  Settings.WriteBool('Editor', 'Crop_Tool_Save_Prop', CheckProportions.Checked);
end;

procedure TCropToolPanelClass.ChangeSize(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  S := ComboBoxProp.Text;
  for I := 1 to Length(S) do
    if S[I] = '/' then
    begin
      EditPrHeight.Text := Copy(S, 1, I - 1);
      EditPrWidth.Text := Copy(S, I + 1, Length(S) - I);
      CheckProportions.Checked := True;
      Break;
    end;
end;

class function TCropToolPanelClass.ID: string;
begin
  Result := '{5AA5CA33-220E-4D1D-82C2-9195CE6DF8E4}';
end;

function TCropToolPanelClass.LangID: string;
begin
  Result := 'CropTool';
end;

function TCropToolPanelClass.GetProperties: string;
begin
//
end;

procedure TCropToolPanelClass.SetProperties(Properties: String);
begin
//
end;

procedure TCropToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin
//
end;

end.
