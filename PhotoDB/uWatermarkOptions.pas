unit uWatermarkOptions;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  Dmitry.Graphics.Types,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.WatermarkedEdit,

  UnitDBFileDialogs,

  uDBGraphicTypes,
  uConstants,
  uMemory,
  uDBForm,
  uBitmapUtils,
  uAssociations,
  uSettings,
  uDBEntities,
  uImageLoader;

const
  Settings_Watermark = 'Watermark settings';

type
  TFrmWatermarkOptions = class(TDBForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    PcWatermarkType: TPageControl;
    TsText: TTabSheet;
    TsImage: TTabSheet;
    LbBlocksX: TLabel;
    LbTextColor: TLabel;
    LbBlocksY: TLabel;
    LbTextTransparency: TLabel;
    LbWatermarkText: TLabel;
    LbFontName: TLabel;
    CbColor: TColorBox;
    SeBlocksX: TSpinEdit;
    SeBlocksY: TSpinEdit;
    SeTextTransparency: TSpinEdit;
    EdWatermarkText: TWatermarkedEdit;
    CbFonts: TComboBox;
    PnImageSettings: TPanel;
    PbImage: TPaintBox;
    LbInfo: TLabel;
    CbKeepProportions: TCheckBox;
    WlWatermarkedImage: TWebLink;
    SeImageTransparency: TSpinEdit;
    LbImageTransparency: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PcWatermarkTypeChange(Sender: TObject);
    procedure PbImageMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PbImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PbImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PbImagePaint(Sender: TObject);
    procedure WlWatermarkedImageClick(Sender: TObject);
    procedure SeImageTransparencyChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FWatermarkedFile: string;
    WatermarkedImage: TBitmap;

    FX: Integer;
    FY: Integer;

    ProportionsHeight: Integer;
    ProportionsWidth: Integer;

    FirstPoint: TPoint;
    SecondPoint: TPoint;
    MakingRect: Boolean;
    ResizingRect: Boolean;
    FxBottom: Boolean;
    FxTop: Boolean;
    FxCenter: Boolean;
    FxLeft: Boolean;
    FxRight: Boolean;
    FBeginSecondPoint: TPoint;
    FBeginFirstPoint: TPoint;
    FBeginDragPoint: TPoint;


    function BufferPointToImagePoint(P: TPoint): TPoint;
    procedure LoadLanguage;
    procedure SaveSettings;
    procedure LoadSettings;
    procedure LoadWatermarkImage(FileName: string);
    procedure CheckSaveEnabled;

    property XTop: Boolean read FxTop write FxTop;
    property XLeft: Boolean read FxLeft write FxLeft;
    property XBottom: Boolean read FxBottom write FxBottom;
    property XRight: Boolean read FxRight write FxRight;
    property XCenter: Boolean read FxCenter write FxCenter;

    property BeginDragPoint: TPoint read FBeginDragPoint write FBeginDragPoint;
    property BeginFirstPoint: TPoint read FBeginFirstPoint write FBeginFirstPoint;
    property BeginSecondPoint: TPoint read FBeginSecondPoint write FBeginSecondPoint;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
  end;

procedure ShowWatermarkOptions;

implementation

procedure ShowWatermarkOptions;
var
  FrmWatermarkOptions: TFrmWatermarkOptions;
begin
  Application.CreateForm(TFrmWatermarkOptions, FrmWatermarkOptions);
  try
    FrmWatermarkOptions.ShowModal;
  finally
    FrmWatermarkOptions.Release;
  end;
end;

function Znak(X: Extended): Extended;
begin
  if X >= 0 then
    Result := 1
  else
    Result := -1;
end;

{$R *.dfm}

procedure TFrmWatermarkOptions.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmWatermarkOptions.BtnOkClick(Sender: TObject);
begin
  SaveSettings;
  Close;
end;

function TFrmWatermarkOptions.BufferPointToImagePoint(P: TPoint): TPoint;
begin
  Result := P;
end;

procedure TFrmWatermarkOptions.CheckSaveEnabled;
begin
  if PcWatermarkType.ActivePageIndex = 0 then
    BtnOk.Enabled := FWatermarkedFile <> '';
  if PcWatermarkType.ActivePageIndex = 1 then
    BtnOk.Enabled := True;
end;

procedure TFrmWatermarkOptions.FormCreate(Sender: TObject);
begin
  Screen.Cursors[CUR_UPDOWN] := LoadCursor(HInstance, 'UPDOWN');
  Screen.Cursors[CUR_LEFTRIGHT] := LoadCursor(HInstance, 'LEFTRIGHT');
  Screen.Cursors[CUR_TOPRIGHT] := LoadCursor(HInstance, 'TOPLEFTBOTTOMRIGHT');
  Screen.Cursors[CUR_RIGHTBOTTOM] := LoadCursor(HInstance, 'TOPRIGHTLEFTBOTTOM');
  Screen.Cursors[CUR_HAND] := LoadCursor(HInstance, 'HAND');
  Screen.Cursors[CUR_CROP] := LoadCursor(HInstance, 'CROP');

  LoadLanguage;

  ProportionsHeight := 1;
  ProportionsWidth := 1;
  FirstPoint := Point(PbImage.Width div 4, PbImage.Height div 4);
  SecondPoint := Point(PbImage.Width div 4 * 3, PbImage.Height div 4 * 3);

  MakingRect := False;
  ResizingRect := False;
  WatermarkedImage := TBitmap.Create;

  CbFonts.Items := Screen.Fonts;
  if CbFonts.Items.Count > 0 then
    CbFonts.ItemIndex := 0;

  LoadSettings;
end;

procedure TFrmWatermarkOptions.FormDestroy(Sender: TObject);
begin
  F(WatermarkedImage);
end;

procedure TFrmWatermarkOptions.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    BtnOkClick(Sender);
  if Key = VK_ESCAPE then
    Close;
end;

function TFrmWatermarkOptions.GetFormID: string;
begin
  Result := 'WatermarkOptions';
end;

procedure TFrmWatermarkOptions.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Watermark options');
    LbWatermarkText.Caption := L('Watermark text') + ':';
    EdWatermarkText.WatermarkText := L('Sample text');
    LbBlocksX.Caption := L('Blocks horizontally') + ':';
    LbBlocksY.Caption := L('Blocks vertically') + ':';
    LbTextColor.Caption := L('Text color') + ':';
    LbImageTransparency.Caption := L('Transparency');
    LbTextTransparency.Caption := L('Transparency') + ':';
    LbFontName.Caption := L('Font Name') + ':';
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    CbKeepProportions.Caption := L('Keep proportions');

    TsText.Caption := L('Text');
    TsImage.Caption := L('Image');
    LbInfo.Caption := L('Use mouse to select area with watermark image');
    WlWatermarkedImage.Text := L('Click to select watermark image');
  finally
    EndTranslate;
  end;
end;

procedure TFrmWatermarkOptions.LoadSettings;
var
  I: Integer;
  FontName: string;
begin
  PcWatermarkType.ActivePageIndex := AppSettings.ReadInteger(Settings_Watermark, 'Mode', 0);

  EdWatermarkText.Text := AppSettings.ReadString(Settings_Watermark, 'Text', L('Sample text'));
  SeBlocksX.Value := AppSettings.ReadInteger(Settings_Watermark, 'BlocksX', 3);
  SeBlocksY.Value := AppSettings.ReadInteger(Settings_Watermark, 'BlocksY', 3);
  CbColor.Selected := AppSettings.ReadInteger(Settings_Watermark, 'Color', clWhite);
  SeTextTransparency.Value := AppSettings.ReadInteger(Settings_Watermark, 'TextTransparency', 25);
  SeImageTransparency.Value := AppSettings.ReadInteger(Settings_Watermark, 'ImageTransparency', 50);
  FontName := AnsiLowerCase(AppSettings.ReadString(Settings_Watermark, 'Font', 'Arial'));
  for I := 0 to CbFonts.Items.Count - 1 do
    if AnsiLowerCase(CbFonts.Items[I]) = FontName then
      CbFonts.ItemIndex := I;

  CbKeepProportions.Checked := AppSettings.ReadBool(Settings_Watermark, 'KeepProportions', True);

  FirstPoint.X := Round(AppSettings.ReadInteger(Settings_Watermark, 'ImageStartX', Round(FirstPoint.X * 100 / PbImage.Width)) * PbImage.Width / 100);
  FirstPoint.Y := Round(AppSettings.ReadInteger(Settings_Watermark, 'ImageStartY', Round(FirstPoint.Y * 100 / PbImage.Height)) * PbImage.Height / 100);

  SecondPoint.X := Round(AppSettings.ReadInteger(Settings_Watermark, 'ImageEndX', Round(SecondPoint.X * 100 / PbImage.Width)) * PbImage.Width / 100);
  SecondPoint.Y := Round(AppSettings.ReadInteger(Settings_Watermark, 'ImageEndY', Round(SecondPoint.Y * 100 / PbImage.Height)) * PbImage.Height / 100);

  FWatermarkedFile := AppSettings.ReadString(Settings_Watermark, 'WatermarkImage');
  LoadWatermarkImage(FWatermarkedFile);
end;

procedure TFrmWatermarkOptions.PbImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  De = 5;
var
  P, ImagePoint, TopLeftPoint, RightBottomPoint: TPoint;
  InImage: Boolean;
begin
  FX := X;
  FY := Y;

  ImagePoint := BufferPointToImagePoint(Point(X, Y));

  P.X := Min(PbImage.Width, Max(0, ImagePoint.X));
  P.Y := Min(PbImage.Height, Max(0, ImagePoint.Y));
  if (ImagePoint.X <> P.X) or (ImagePoint.Y <> P.Y) then
  begin
    PbImage.Cursor := crDefault;
    Exit;
  end;

  ImagePoint.X := Min(PbImage.Width, Max(0, ImagePoint.X));
  ImagePoint.Y := Min(PbImage.Height, Max(0, ImagePoint.Y));

  TopLeftPoint.X := Min(SecondPoint.X, FirstPoint.X);
  RightBottomPoint.X := Max(SecondPoint.X, FirstPoint.X);
  TopLeftPoint.Y := Min(SecondPoint.Y, FirstPoint.Y);
  RightBottomPoint.Y := Max(SecondPoint.Y, FirstPoint.Y);
  InImage := PtInRect(Rect(TopLeftPoint.X - De, TopLeftPoint.Y - De, RightBottomPoint.X + De,
      RightBottomPoint.Y + De), ImagePoint);
  XTop := (Abs(ImagePoint.Y - TopLeftPoint.Y) <= De) and InImage;
  XLeft := (Abs(ImagePoint.X - TopLeftPoint.X) <= De) and InImage;
  XRight := (Abs(ImagePoint.X - RightBottomPoint.X) <= De) and InImage;
  XBottom := (Abs(ImagePoint.Y - RightBottomPoint.Y) <= De) and InImage;
  XCenter := PtInRect(Rect(TopLeftPoint.X + De, TopLeftPoint.Y + De, RightBottomPoint.X - De,
      RightBottomPoint.Y - De), ImagePoint);
  BeginDragPoint := ImagePoint;
  BeginFirstPoint := FirstPoint;
  BeginSecondPoint := SecondPoint;
  if XTop or XLeft or XRight or XBottom or XCenter then
    ResizingRect := True;
  if not ResizingRect then
  begin
    FirstPoint := BufferPointToImagePoint(Point(X, Y));
    SecondPoint := BufferPointToImagePoint(Point(X, Y));
    MakingRect := True;
  end;
end;

procedure TFrmWatermarkOptions.PbImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  P, ImagePoint, TopLeftPoint, RightBottomPoint, P1, P2, P11, P22: TPoint;
  De, W, H, I, Ax, Ay, Ry: Integer;
  Prop: Extended;
  InImage: Boolean;
begin
  if MakingRect then
  begin
    ImagePoint := BufferPointToImagePoint(Point(X, Y));
    P.X := Min(PbImage.Width, Max(0, ImagePoint.X));
    P.Y := Min(PbImage.Height, Max(0, ImagePoint.Y));
    if CbKeepProportions.Checked then
    begin
      W := -(FirstPoint.X - P.X);
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
        if FirstPoint.X + W > PbImage.Width then
        begin
          W := PbImage.Width - FirstPoint.X;
          H := Round(Znak(H) * W / Prop);
        end;
        if FirstPoint.X + W < 0 then
        begin
          W := -FirstPoint.X;
          H := -Round(Znak(H) * W / Prop);
        end;

        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
      end else
      begin
        if H < 0 then
          H := -Round(Abs(W) * (1 / Prop))
        else
          H := Round(Abs(W) * (1 / Prop));
        if FirstPoint.Y + H > PbImage.Height then
        begin
          H := PbImage.Height - FirstPoint.Y;
          W := Round(Znak(W) * (H * Prop));
        end;
        if FirstPoint.Y + H < 0 then
        begin
          H := -FirstPoint.Y;
          W := -Round(Znak(W) * (H * Prop));
        end;

        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
      end;
    end else
      SecondPoint := P;

    PbImage.Repaint;
  end else
  begin
    ImagePoint := BufferPointToImagePoint(Point(X, Y));
    ImagePoint.X := Min(PbImage.Width, Max(0, ImagePoint.X));
    ImagePoint.Y := Min(PbImage.Height, Max(0, ImagePoint.Y));

    P := BufferPointToImagePoint(Point(X, Y));
    P.X := Min(PbImage.Width, Max(1, P.X));
    P.Y := Min(PbImage.Height, Max(1, P.Y));
    if CbKeepProportions.Checked then
    begin
      W := -(FirstPoint.X - P.X);
      H := -(FirstPoint.Y - P.Y);
      if W * H = 0 then
        Exit;
      if ProportionsHeight <> 0 then
        Prop := ProportionsWidth / ProportionsHeight
      else
        Prop := 1;
      if H = 0 then
        Exit;
      if Prop = 0 then
        Exit;
      if Abs(W / H) > Abs(Prop) then
      begin
        if W < 0 then
          W := -Round(Abs(H) * (Prop))
        else
          W := Round(Abs(H) * (Prop));
        P := Point(FirstPoint.X + W, FirstPoint.Y + H);
      end else
      begin
        if H < 0 then
          H := -Round(Abs(W) * (1 / Prop))
        else
          H := Round(Abs(W) * (1 / Prop));
        P := Point(FirstPoint.X + W, FirstPoint.Y + H);
      end;
    end;

    PbImage.Cursor := CUR_CROP;
    De := 5;
    if ResizingRect then
    begin
      if ResizingRect then
      begin
        if XCenter then
        begin
          W := ImagePoint.X - BeginDragPoint.X;
          H := ImagePoint.Y - BeginDragPoint.Y;
          W := Max(W, Max(-BeginFirstPoint.X, -BeginSecondPoint.X));
          H := Max(H, Max(-BeginFirstPoint.Y, -BeginSecondPoint.Y));
          W := Min(W, PbImage.Width - Max(BeginFirstPoint.X, BeginSecondPoint.X));
          H := Min(H, PbImage.Height - Max(BeginFirstPoint.Y, BeginSecondPoint.Y));
          FirstPoint := Point(BeginFirstPoint.X + W, BeginFirstPoint.Y + H);
          SecondPoint := Point(BeginSecondPoint.X + W, BeginSecondPoint.Y + H);
        end;

        if not CbKeepProportions.Checked then
        begin

          if XLeft and not XRight then
          begin
            if FirstPoint.X > SecondPoint.X then
              SecondPoint := Point(ImagePoint.X, SecondPoint.Y)
            else
              FirstPoint := Point(ImagePoint.X, FirstPoint.Y);
          end;
          if XTop and not XBottom then
          begin
            if FirstPoint.Y > SecondPoint.Y then
              SecondPoint := Point(SecondPoint.X, ImagePoint.Y)
            else
              FirstPoint := Point(FirstPoint.X, ImagePoint.Y);
          end;
          if XRight then
          begin
            if FirstPoint.X < SecondPoint.X then
              SecondPoint := Point(ImagePoint.X, SecondPoint.Y)
            else
              FirstPoint := Point(ImagePoint.X, FirstPoint.Y);
          end;
          if XBottom then
          begin
            if FirstPoint.Y < SecondPoint.Y then
              SecondPoint := Point(SecondPoint.X, ImagePoint.Y)
            else
              FirstPoint := Point(FirstPoint.X, ImagePoint.Y);
          end;

        end else
        begin

          if ProportionsHeight <> 0 then
            Prop := ProportionsWidth / ProportionsHeight
          else
            Prop := 1;

          P1 := Point(Min(FirstPoint.X, SecondPoint.X), Min(FirstPoint.Y, SecondPoint.Y));
          P2 := Point(Max(FirstPoint.X, SecondPoint.X), Max(FirstPoint.Y, SecondPoint.Y));

          if XLeft and not XTop and not XRight then
          begin
            P11 := Point(ImagePoint.X, P1.Y);
            P22 := Point(P2.X, P11.Y + Round((P2.X - P11.X) / Prop));
            if P22.Y > PbImage.Height then
            begin
              P22 := Point(P2.X, PbImage.Height);
              P11 := Point(P2.X - Round((PbImage.Height - P11.Y) * Prop), P1.Y);
            end;
            FirstPoint := P11;
            SecondPoint := P22;
          end;

          if XTop and not XLeft and not XBottom then
          begin
            P11 := Point(P1.X, ImagePoint.Y);
            P22 := Point(P11.X + Round((P2.Y - P11.Y) * Prop), P2.Y);
            if P22.X > PbImage.Width then
            begin
              P22 := Point(PbImage.Width, P2.Y);
              P11 := Point(P1.X, P2.Y - Round((PbImage.Width - P1.X) / Prop));
            end;
            FirstPoint := P11;
            SecondPoint := P22;
          end;

          if XTop and XLeft and not XBottom then
          begin
            W := Abs(P2.X - ImagePoint.X);
            H := Abs(P2.Y - ImagePoint.Y);
            if Abs(W / H) > Abs(Prop) then
              P11 := Point(ImagePoint.X, P2.Y - Round((P2.X - ImagePoint.X) / Prop))
            else
              P11 := Point(P2.X - Round((P2.Y - ImagePoint.Y) * Prop), ImagePoint.Y);

            if P11.X < 0 then
              P11 := Point(0, P2.Y - Round(P2.X / Prop));

            if P11.Y < 0 then
              P11 := Point(P2.X - Round(P2.Y * Prop), 0);

            P22 := Point(P2.X, P2.Y);
            FirstPoint := P11;
            SecondPoint := P22;
          end;

          if XRight and not XBottom then
          begin
            P22 := Point(ImagePoint.X, P2.Y);
            P11 := Point(P1.X, P22.Y - Round((P22.X - P1.X) / Prop));
            if P11.Y < 0 then
            begin
              P22 := Point(P1.X + Round(P2.Y * Prop), P2.Y);
              P11 := Point(P1.X, 0);
            end;
            FirstPoint := P11;
            SecondPoint := P22;
          end;

          if XBottom and not XRight then
          begin
            P22 := Point(P2.X, ImagePoint.Y);
            P11 := Point(P22.X - Round((P22.Y - P1.Y) * Prop), P1.Y);
            if P11.X < 0 then
            begin
              P22 := Point(P2.X, P1.Y + Round(P2.X / Prop));
              P11 := Point(0, P1.Y);
            end;
            FirstPoint := P11;
            SecondPoint := P22;
          end;

          if XBottom and XRight then
          begin
            W := Abs(P1.X - ImagePoint.X);
            H := Abs(P1.Y - ImagePoint.Y);
            if Abs(W / H) > Abs(Prop) then
              P22 := Point(ImagePoint.X, P1.Y - Round((P1.X - ImagePoint.X) / Prop))
            else
              P22 := Point(P1.X - Round((P1.Y - ImagePoint.Y) * Prop), ImagePoint.Y);

            if P22.X > PbImage.Width then
              P22 := Point(PbImage.Width, P1.Y + Round((PbImage.Width - P1.X) / Prop));

            if P22.Y > PbImage.Height then
              P22 := Point(P1.X + Round((PbImage.Height - P1.Y) * Prop), PbImage.Height);

            P11 := Point(P1.X, P1.Y);
            FirstPoint := P11;
            SecondPoint := P22;
          end;

        end;
        PbImage.Repaint;
      end;
    end else
    begin
      ImagePoint := BufferPointToImagePoint(Point(X, Y));
      P.X := Min(PbImage.Width, Max(0, ImagePoint.X));
      P.Y := Min(PbImage.Height, Max(0, ImagePoint.Y));
      if (ImagePoint.X <> P.X) or (ImagePoint.Y <> P.Y) then
      begin
        PbImage.Cursor := CrDefault;
        Exit;
      end;
      TopLeftPoint.X := Min(SecondPoint.X, FirstPoint.X);
      RightBottomPoint.X := Max(SecondPoint.X, FirstPoint.X);
      TopLeftPoint.Y := Min(SecondPoint.Y, FirstPoint.Y);
      RightBottomPoint.Y := Max(SecondPoint.Y, FirstPoint.Y);
      InImage := PtInRect(Rect(TopLeftPoint.X - De, TopLeftPoint.Y - De, RightBottomPoint.X + De,
          RightBottomPoint.Y + De), ImagePoint);
      XTop := (Abs(ImagePoint.Y - TopLeftPoint.Y) <= De) and InImage;
      XLeft := (Abs(ImagePoint.X - TopLeftPoint.X) <= De) and InImage;
      XRight := (Abs(ImagePoint.X - RightBottomPoint.X) <= De) and InImage;
      XBottom := (Abs(ImagePoint.Y - RightBottomPoint.Y) <= De) and InImage;
      XCenter := PtInRect(Rect(TopLeftPoint.X + De, TopLeftPoint.Y + De, RightBottomPoint.X - De,
          RightBottomPoint.Y - De), ImagePoint);
      BeginDragPoint := ImagePoint;
      BeginFirstPoint := FirstPoint;
      BeginSecondPoint := SecondPoint;

      if (XTop and XLeft) or (XRight and XBottom) then
        PbImage.Cursor := CUR_TOPRIGHT;

      if PbImage.Cursor = CUR_CROP then
        if (XBottom and XLeft) or (XRight and XTop) then
          PbImage.Cursor := CUR_RIGHTBOTTOM;

      if PbImage.Cursor = CUR_CROP then
        if XRight or XLeft then
          PbImage.Cursor := CUR_LEFTRIGHT;

      if PbImage.Cursor = CUR_CROP then
        if XTop or XBottom then
          PbImage.Cursor := CUR_UPDOWN;

      if (PbImage.Cursor = CUR_CROP) and XCenter then
        PbImage.Cursor := CUR_HAND;

    end;
  end;
end;

procedure TFrmWatermarkOptions.PbImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  W, H: Integer;
  Prop: Extended;
begin
  if MakingRect then
  begin
    P := BufferPointToImagePoint(Point(X, Y));
    P.X := Min(PbImage.Width, Max(0, P.X));
    P.Y := Min(PbImage.Height, Max(0, P.Y));

    if CbKeepProportions.Checked then
    begin
      W := -(FirstPoint.X - P.X);
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
        if FirstPoint.X + W > PbImage.Width then
        begin
          W := PbImage.Width - FirstPoint.X;
          H := Round(Znak(H) * W / Prop);
        end;
        if FirstPoint.X + W < 0 then
        begin
          W := -FirstPoint.X;
          H := -Round(Znak(H) * W / Prop);
        end;

        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
      end else
      begin
        if H < 0 then
          H := -Round(Abs(W) * (1 / Prop))
        else
          H := Round(Abs(W) * (1 / Prop));
        if FirstPoint.Y + H > PbImage.Height then
        begin
          H := PbImage.Height - FirstPoint.Y;
          W := Round(Znak(W) * (H * Prop));
        end;
        if FirstPoint.Y + H < 0 then
        begin
          H := -FirstPoint.Y;
          W := -Round(Znak(W) * (H * Prop));
        end;

        SecondPoint := Point(FirstPoint.X + W, FirstPoint.Y + H);
      end;
    end
    else
      SecondPoint := P;
  end;

  ResizingRect := False;
  MakingRect := False;
end;

procedure TFrmWatermarkOptions.PbImagePaint(Sender: TObject);
var
  B, WI: TBitmap;
  I, J, W, H,
  RightWidth, BottomHeight,
  StartX, StartY,
  DeltaX, DeltaY: Integer;
  P: PARGB;
  P1, P2: TPoint;
  Transparency: Byte;
begin
  B := TBitmap.Create;
  try
    B.SetSize(PbImage.Width, PbImage.Height);
    B.PixelFormat := pf24Bit;

    for I := 0 to B.Height - 1 do
    begin
      P := B.ScanLine[I];
      for J := 0 to B.Width - 1 do
      begin
        if Odd((J div 10) + (I div 10)) then
        begin
          P[J].R := $80;
          P[J].G := $80;
          P[J].B := $80;
        end else
        begin
          P[J].R := $AA;
          P[J].G := $AA;
          P[J].B := $AA;
        end;
      end;
    end;

    P1 := Point(Min(FirstPoint.X, SecondPoint.X), Min(FirstPoint.Y, SecondPoint.Y));
    P2 := Point(Max(FirstPoint.X, SecondPoint.X), Max(FirstPoint.Y, SecondPoint.Y));

    DrawTransparentColor(B, clRed, P1.X, P1.Y, P2.X - P1.X, P2.Y - P1.Y, $20);
    B.Canvas.Pen.Color := $FFFFFF;
    B.Canvas.Pen.Style := psDot;
    B.Canvas.Brush.Style := bsClear;
    B.Canvas.Rectangle(P1.X, P1.Y, P2.X, P2.Y);
    B.Canvas.Pen.Color := 0;
    B.Canvas.Rectangle(P1.X - 1, P1.Y - 1, P2.X + 1, P2.Y + 1);

    WI := TBitmap.Create;
    try
      WI.PixelFormat := WatermarkedImage.PixelFormat;
      DoResize(P2.X - P1.X, P2.Y - P1.Y, WatermarkedImage, WI);

      Transparency := Round(SeImageTransparency.Value * 255 / 100);
      if WI.PixelFormat = pf32bit then
        DrawImageEx32To24Transparency(B, WI, P1.X, P1.Y, Transparency);

      if WI.PixelFormat = pf24bit then
        DrawImageExTransparency(B, WI, P1.X, P1.Y, Transparency);
    finally
      F(WI);
    end;

    PbImage.Canvas.Draw(0, 0, B);
  finally
    F(B);
  end;
end;

procedure TFrmWatermarkOptions.PcWatermarkTypeChange(Sender: TObject);
begin
  CheckSaveEnabled;
end;

procedure TFrmWatermarkOptions.SaveSettings;
var
  P1, P2, SettingsStartPoint, SettingsEndPoint: TPoint;
begin
  AppSettings.WriteString(Settings_Watermark, 'Text', EdWatermarkText.Text);
  AppSettings.WriteInteger(Settings_Watermark, 'BlocksX', SeBlocksX.Value);
  AppSettings.WriteInteger(Settings_Watermark, 'BlocksY', SeBlocksY.Value);
  AppSettings.WriteInteger(Settings_Watermark, 'Color', CbColor.Selected);
  AppSettings.WriteInteger(Settings_Watermark, 'TextTransparency', SeTextTransparency.Value);
  AppSettings.WriteInteger(Settings_Watermark, 'ImageTransparency', SeImageTransparency.Value);
  AppSettings.WriteString(Settings_Watermark, 'Font', CbFonts.Items[CbFonts.ItemIndex]);
  AppSettings.WriteBool(Settings_Watermark, 'KeepProportions', CbKeepProportions.Checked);

  P1 := Point(Min(FirstPoint.X, SecondPoint.X), Min(FirstPoint.Y, SecondPoint.Y));
  P2 := Point(Max(FirstPoint.X, SecondPoint.X), Max(FirstPoint.Y, SecondPoint.Y));

  SettingsStartPoint := Point(Round(100 * P1.X / PbImage.Width), Round(100 * P1.Y / PbImage.Height));
  SettingsEndPoint := Point(Round(100 * P2.X / PbImage.Width), Round(100 * P2.Y / PbImage.Height));

  AppSettings.WriteInteger(Settings_Watermark, 'ImageStartX', SettingsStartPoint.X);
  AppSettings.WriteInteger(Settings_Watermark, 'ImageStartY', SettingsStartPoint.Y);
  AppSettings.WriteInteger(Settings_Watermark, 'ImageEndX', SettingsEndPoint.X);
  AppSettings.WriteInteger(Settings_Watermark, 'ImageEndY', SettingsEndPoint.Y);

  AppSettings.WriteString(Settings_Watermark, 'WatermarkImage', FWatermarkedFile);

  AppSettings.WriteInteger(Settings_Watermark, 'Mode', PcWatermarkType.ActivePageIndex);
end;

procedure TFrmWatermarkOptions.SeImageTransparencyChange(Sender: TObject);
begin
  PbImage.Repaint;
end;

procedure TFrmWatermarkOptions.WlWatermarkedImageClick(Sender: TObject);
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;

    if OpenPictureDialog.Execute then
      LoadWatermarkImage(OpenPictureDialog.FileName);
  finally
    F(OpenPictureDialog);
  end;
end;

procedure TFrmWatermarkOptions.LoadWatermarkImage(FileName: string);
var
  Info: TMediaItem;
  FImageInfo: ILoadImageInfo;
  Image: TBitmap;
begin
  Info := TMediaItem.CreateFromFile(FileName);
  try
    if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfPassword, ilfAskUserPassword, ilfUseCache], FImageInfo) then
    begin
      Image := FImageInfo.GenerateBitmap(Info, FImageInfo.GraphicWidth, FImageInfo.GraphicHeight, pf32Bit, clNone, [ilboFreeGraphic, ilboFullBitmap, ilboRotate, ilboApplyICCProfile]);

      if Image <> nil then
      begin
        F(WatermarkedImage);
        WatermarkedImage := Image;

        ProportionsHeight := WatermarkedImage.Height;
        ProportionsWidth := WatermarkedImage.Width;
        PbImage.Refresh;

        WlWatermarkedImage.Text := FileName;
        FWatermarkedFile := FileName;
        CheckSaveEnabled;
      end;
    end;
  finally
    F(Info);
  end;
end;


end.


