unit ColorToolUnit;

interface

uses
  Windows, ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, ExtCtrls,
  ComCtrls, Effects, UnitDBKernel, UDBGraphicTypes,
  uMemory;

type
  TColorToolPanelClass = class(TToolsPanelClass)
  private
    { Private declarations }
    NewImage: TBitmap;
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    ContrastLabel: TStaticText;
    ContrastTrackBar: TTrackBar;
    BrightnessLabel: TStaticText;
    BrightnessTrackBar: TTrackBar;
    RLabel: TStaticText;
    RTrackBar: TTrackBar;
    GLabel: TStaticText;
    GTrackBar: TTrackBar;
    BLabel: TStaticText;
    BTrackBar: TTrackBar;
    Loading: Boolean;
    ApplyOnDone: Boolean;
    FOnDone: TNotifyEvent;
    PImage, PNewImage: TArPARGB;
    FOverageContrast : Integer;
  protected
    function LangID: string; override;
  public
    { Public declarations }
    procedure Init; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClosePanel; override;
    procedure MakeTransform; override;
    procedure ClosePanelEvent(Sender: TObject);
    procedure DoMakeImage(Sender: TObject);
    procedure SetLocalProperties(Sender: TObject);
    procedure RefreshInfo;
    function GetProperties: string; override;
    class function ID: string; override;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
    procedure SetProperties(Properties: string); override;
  end;

implementation

{ TColorToolPanelClass }

procedure TColorToolPanelClass.ClosePanel;
begin
  if Assigned(OnClosePanel) then
    OnClosePanel(Self);
  if not ApplyOnDone then
    inherited;
end;

procedure TColorToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
  CancelTempImage(True);
  ClosePanel;
end;

constructor TColorToolPanelClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel: TIcon;
begin
  inherited;
  ApplyOnDone := False;
  NewImage := nil;
  Loading := True;
  Align := AlClient;
  IcoOK := TIcon.Create;
  IcoCancel := TIcon.Create;
  IcoOK.Handle := LoadIcon(DBKernel.IconDllInstance, 'DOIT');
  IcoCancel.Handle := LoadIcon(DBKernel.IconDllInstance, 'CANCELACTION');

  ContrastLabel := TStaticText.Create(Self);

  ContrastLabel.Top := 8;
  ContrastLabel.Left := 8;
  ContrastLabel.Caption := L('Contract: [%d]');
  ContrastLabel.Parent := AOwner as TWinControl;

  ContrastTrackBar := TTrackBar.Create(Self);
  ContrastTrackBar.Top := ContrastLabel.Top + ContrastLabel.Height + 5;
  ContrastTrackBar.Left := 8;
  ContrastTrackBar.Width := 161;
  ContrastTrackBar.Min := -100;
  ContrastTrackBar.Max := 100;
  ContrastTrackBar.Position := 0;
  ContrastTrackBar.OnChange := SetLocalProperties;
  ContrastTrackBar.Parent := AOwner as TWinControl;

  BrightnessLabel := TStaticText.Create(Self);
  BrightnessLabel.Top := ContrastTrackBar.Top + ContrastTrackBar.Height + 5;
  BrightnessLabel.Left := 8;
  BrightnessLabel.Caption := L('Brightness : [%d]');
  BrightnessLabel.Parent := AOwner as TWinControl;

  BrightnessTrackBar := TTrackBar.Create(Self);
  BrightnessTrackBar.Top := BrightnessLabel.Top + BrightnessLabel.Height + 5;
  BrightnessTrackBar.Left := 8;
  BrightnessTrackBar.Width := 161;
  BrightnessTrackBar.Min := -255;
  BrightnessTrackBar.Max := 255;
  BrightnessTrackBar.Position := 0;
  BrightnessTrackBar.OnChange := SetLocalProperties;
  BrightnessTrackBar.Parent := AOwner as TWinControl;

  RLabel := TStaticText.Create(Self);
  RLabel.Top := BrightnessTrackBar.Top + BrightnessTrackBar.Height + 5;
  RLabel.Caption := 'R';

  RTrackBar := TTrackBar.Create(Self);
  RTrackBar.Orientation := TrVertical;
  RTrackBar.Top := RLabel.Top + RLabel.Height + 5;
  RTrackBar.Left := 15;
  RTrackBar.Min := -100;
  RTrackBar.Max := 100;
  RTrackBar.Position := 0;
  RTrackBar.OnChange := SetLocalProperties;
  RTrackBar.Parent := AOwner as TWinControl;

  RLabel.Left := RTrackBar.Left;
  RLabel.Parent := AOwner as TWinControl;

  GLabel := TStaticText.Create(Self);
  GLabel.Top := BrightnessTrackBar.Top + BrightnessTrackBar.Height + 5;
  GLabel.Caption := 'G';

  GTrackBar := TTrackBar.Create(Self);
  GTrackBar.Orientation := TrVertical;
  GTrackBar.Top := RLabel.Top + RLabel.Height + 5;
  GTrackBar.Left := RTrackBar.Left + RTrackBar.Width + 5;
  GTrackBar.Min := -100;
  GTrackBar.Max := 100;
  GTrackBar.Position := 0;
  GTrackBar.OnChange := SetLocalProperties;
  GTrackBar.Parent := AOwner as TWinControl;

  GLabel.Left := GTrackBar.Left;
  GLabel.Parent := AOwner as TWinControl;

  BLabel := TStaticText.Create(Self);
  BLabel.Top := BrightnessTrackBar.Top + BrightnessTrackBar.Height + 5;
  BLabel.Caption := 'B';

  BTrackBar := TTrackBar.Create(Self);
  BTrackBar.Orientation := TrVertical;
  BTrackBar.Top := RLabel.Top + RLabel.Height + 5;
  BTrackBar.Left := GTrackBar.Left + GTrackBar.Width + 5;
  BTrackBar.Min := -100;
  BTrackBar.Max := 100;
  BTrackBar.Position := 0;
  BTrackBar.OnChange := SetLocalProperties;
  BTrackBar.Parent := AOwner as TWinControl;

  BLabel.Left := BTrackBar.Left;
  BLabel.Parent := AOwner as TWinControl;

  MakeItLink := TWebLink.Create(Self);
  MakeItLink.Parent := AOwner as TWinControl;
  MakeItLink.Text := L('Apply');
  MakeItLink.Top := BTrackBar.Top + BTrackBar.Height + 5;
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
  CloseLink.ImageCanRegenerate := True;
  IcoCancel.Free;

  Loading := False;

  RefreshInfo;
  FOverageContrast := -1;
end;

procedure TColorToolPanelClass.Init;
var
  I : Integer;
begin
  NewImage := TBitmap.Create;
  NewImage.Assign(Image);
  SetLength(PImage, NewImage.Height);
  SetLength(PNewImage, Image.Height);
  for I := 0 to Image.Height - 1 do
    PImage[I] := Image.ScanLine[I];
  for I := 0 to NewImage.Height - 1 do
    PNewImage[I] := NewImage.ScanLine[I];
  SetTempImage(NewImage);
end;

destructor TColorToolPanelClass.Destroy;
begin
  F(ContrastLabel);
  F(ContrastTrackBar);
  F(BrightnessLabel);
  F(BrightnessTrackBar);
  F(RTrackBar);
  F(GTrackBar);
  F(BTrackBar);
  F(CloseLink);
  F(MakeItLink);
  F(RLabel);
  F(GLabel);
  F(BLabel);
  inherited;
end;

procedure TColorToolPanelClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

procedure TColorToolPanelClass.ExecuteProperties(Properties: string; OnDone: TNotifyEvent);
begin
  FOnDone := OnDone;
  ApplyOnDone := True;
  Loading := True;
  ContrastTrackBar.Position := StrToIntDef(GetValueByName(Properties, 'Contrast'), 0);
  BrightnessTrackBar.Position := StrToIntDef(GetValueByName(Properties, 'Brightness'), 0);
  RTrackBar.Position := StrToIntDef(GetValueByName(Properties, 'RValue'), 0);
  GTrackBar.Position := StrToIntDef(GetValueByName(Properties, 'GValue'), 0);
  BTrackBar.Position := StrToIntDef(GetValueByName(Properties, 'BValue'), 0);
  Loading := False;
  SetLocalProperties(Self);
  MakeTransform;
  if Assigned(FOnDone) then
    FOnDone(Self);
end;

function TColorToolPanelClass.GetProperties: string;
begin
  Result := 'Contrast=' + IntToStr(ContrastTrackBar.Position) + ';';
  Result := Result + 'Brightness=' + IntToStr(BrightnessTrackBar.Position) + ';';
  Result := Result + 'RValue=' + IntToStr(RTrackBar.Position) + ';';
  Result := Result + 'GValue=' + IntToStr(GTrackBar.Position) + ';';
  Result := Result + 'BValue=' + IntToStr(BTrackBar.Position) + ';';
end;

class function TColorToolPanelClass.ID: string;
begin
  Result := '{E20DDD6C-0E5F-4A69-A689-978763DE8A0A}';
end;

function TColorToolPanelClass.LangID: string;
begin
  Result := 'ColorTool';
end;

procedure TColorToolPanelClass.MakeTransform;
begin
  inherited;
  if NewImage <> nil then
  begin
    ImageHistory.Add(NewImage, '{' + ID + '}[' + GetProperties + ']');
    SetImagePointer(NewImage);
  end;
  ClosePanel;
end;

procedure TColorToolPanelClass.RefreshInfo;
begin
  ContrastLabel.Caption := Format(L('Contrast: [%d]'), [ContrastTrackBar.Position]);
  BrightnessLabel.Caption := Format(L('Brightness : [%d]'), [BrightnessTrackBar.Position]);
  RLabel.Caption := Format(L('R [%d]'), [RTrackBar.Position]);
  GLabel.Caption := Format(L('G [%d]'), [GTrackBar.Position]);
  BLabel.Caption := Format(L('B [%d]'), [BTrackBar.Position]);
end;

procedure TColorToolPanelClass.SetLocalProperties(Sender: TObject);
var
  Width, Height: Integer;
  ContrastValue: Extended;

  function Znak(X: Extended): Extended;
  begin
    if X >= 0 then
      Result := 1
    else
      Result := -1;
  end;

begin
  if Loading then
    Exit;
  Height := NewImage.Height;
  Width := NewImage.Width;
  ContrastValue := Znak(ContrastTrackBar.Position) * 100 * Power(Abs(ContrastTrackBar.Position) / 100, 2);
  SetContractBrightnessRGBChannelValue(PImage, PNewImage, Width, Height, ContrastValue, FOverageContrast, BrightnessTrackBar.Position, RTrackBar.Position, GTrackBar.Position, BTrackBar.Position);
  Editor.MakeImage;
  Editor.DoPaint;
  RefreshInfo;
end;

procedure TColorToolPanelClass.SetProperties(Properties: String);
begin

end;

end.

