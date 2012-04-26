unit InsertImageToolUnit;

interface

uses
  Windows,
  ToolsUnit,
  WebLink,
  Classes,
  Controls,
  Graphics,
  StdCtrls,
  GraphicsCool,
  SysUtils,
  ImageHistoryUnit,
  Effects,
  ComCtrls,
  Math,
  GraphicsBaseTypes,
  CustomSelectTool,
  Dialogs,
  ExtDlgs,
  uBitmapUtils,
  clipbrd,
  UnitDBFileDialogs,
  UnitDBCommonGraphics,
  uDBGraphicTypes,
  uAssociations,
  uMemory,
  uSettings;

type
  InsertImageToolPanelClass = class(TCustomSelectToolClass)
  private
    { Private declarations }
    Image: TBitmap;
    LoadImageButton: TButton;
    OpenFileDialog: DBOpenPictureDialog;
    MethodDrawChooser: TComboBox;
    LabelMethod: TLabel;
    TransparentEdit: TTrackBar;
    FLoading: Boolean;
  protected
    function LangID: string; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoEffect(Bitmap: TBitmap; ARect: TRect; FullImage: Boolean); override;
    procedure DoBorder(Bitmap: TBitmap; ARect: TRect); override;
    procedure DoSaveSettings(Sender: TObject); override;
    procedure DoLoadFileFromFile(Sender: TObject);
    procedure RecreateImage(Sender: TObject);
    class function ID: string; override;
    procedure SetProperties(Properties: string); override;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
  end;

implementation

{ TRedEyeToolPanelClass }

constructor InsertImageToolPanelClass.Create(AOwner: TComponent);
begin
  inherited;
  AnyRect := True;
  FLoading := True;
  Image := TBitmap.Create;
  Image.PixelFormat := pf32bit;
  if ClipBoard.HasFormat(CF_BITMAP) then
    Image.Assign(ClipBoard);
  OpenFileDialog := DBOpenPictureDialog.Create;
  OpenFileDialog.Filter := TFileAssociations.Instance.FullFilter;
  LoadImageButton := TButton.Create(AOwner);
  LoadImageButton.Parent := Self;
  LoadImageButton.Top := EditWidth.Top + EditWidth.Height + 5;
  LoadImageButton.Left := 8;
  LoadImageButton.Width := 150;
  LoadImageButton.Height := 21;
  LoadImageButton.Caption := L('Load image');
  LoadImageButton.OnClick := DoLoadFileFromFile;
  LoadImageButton.Show;

  LabelMethod := TLabel.Create(AOwner);
  LabelMethod.Left := 8;
  LabelMethod.Top := LoadImageButton.Top + LoadImageButton.Height + 5;
  LabelMethod.Parent := Self;
  LabelMethod.Caption := L('Method') + ':';

  MethodDrawChooser := TComboBox.Create(AOwner);
  MethodDrawChooser.Top := LabelMethod.Top + LabelMethod.Height + 5;
  MethodDrawChooser.Left := 8;
  MethodDrawChooser.Width := 150;
  MethodDrawChooser.Height := 20;
  MethodDrawChooser.Parent := Self;
  MethodDrawChooser.Style := CsDropDownList;
  MethodDrawChooser.Items.Add(L('Overlay'));
  MethodDrawChooser.Items.Add(L('Sum'));
  MethodDrawChooser.Items.Add(L('Dark'));
  MethodDrawChooser.Items.Add(L('Light'));
  MethodDrawChooser.Items.Add(L('Luminosity'));
  MethodDrawChooser.Items.Add(L('Inverse Luminosity'));
  MethodDrawChooser.Items.Add(L('Change color'));
  MethodDrawChooser.Items.Add(L('Difference'));

  MethodDrawChooser.ItemIndex := 0;
  MethodDrawChooser.OnChange := RecreateImage;

  LabelMethod := TLabel.Create(AOwner);
  LabelMethod.Left := 8;
  LabelMethod.Top := MethodDrawChooser.Top + MethodDrawChooser.Height + 5;
  LabelMethod.Parent := Self;
  LabelMethod.Caption := L('Transparency') + ':';

  TransparentEdit := TTrackBar.Create(AOwner);
  TransparentEdit.Top := LabelMethod.Top + LabelMethod.Height + 5;
  TransparentEdit.Left := 8;
  TransparentEdit.Width := 160;
  TransparentEdit.OnChange := RecreateImage;
  TransparentEdit.Min := 1;
  TransparentEdit.Max := 100;
  TransparentEdit.Position := Settings.ReadInteger('Editor', 'InsertImageTransparency', 100);
  TransparentEdit.Parent := Self;
  LabelMethod.Caption := Format(L('Transparency [%d]'), [TransparentEdit.Position]);
  SaveSettingsLink.Top := TransparentEdit.Top + TransparentEdit.Height + 5;
  MakeItLink.Top := SaveSettingsLink.Top + SaveSettingsLink.Height + 5;
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  FLoading := False;
end;

destructor InsertImageToolPanelClass.Destroy;
begin
  F(Image);
  F(OpenFileDialog);
  inherited;
end;

procedure InsertImageToolPanelClass.DoBorder(Bitmap: TBitmap; ARect: TRect);
var
  I, J: Integer;
  Rct: TRect;
  Xdp: TArPARGB;

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

begin
  Rct.Top := Min(ARect.Top, ARect.Bottom);
  Rct.Bottom := Max(ARect.Top, ARect.Bottom);
  Rct.Left := Min(ARect.Left, ARect.Right);
  Rct.Right := Max(ARect.Left, ARect.Right);
  ARect := Rct;

  SetLength(Xdp, Bitmap.Height);
  for I := 0 to Bitmap.Height - 1 do
    Xdp[I] := Bitmap.ScanLine[I];

  I := Min(Bitmap.Height - 1, Max(0, ARect.Top));
  if I = ARect.Top then
    for J := 0 to Bitmap.Width - 1 do
    begin
      if (J > ARect.Left) and (J < ARect.Right) then
        Border(I, J, Xdp[I, J]);

    end;

  I := Min(Bitmap.Height - 1, Max(0, ARect.Bottom));
  if I = ARect.Bottom then
    for J := 0 to Bitmap.Width - 1 do
    begin
      if (J > ARect.Left) and (J < ARect.Right) then
        Border(I, J, Xdp[I, J]);

    end;

  for I := Max(0, ARect.Top) to Min(ARect.Bottom - 1, Bitmap.Height - 1) do
  begin
    J := Max(0, Min(Bitmap.Width - 1, ARect.Left));
    if J = ARect.Left then
      Border(I, J, Xdp[I, J]);
  end;
  for I := Max(0, ARect.Top) to Min(ARect.Bottom - 1, Bitmap.Height - 1) do
  begin
    J := Min(Bitmap.Width - 1, Max(0, ARect.Right));
    if J = ARect.Right then
      Border(I, J, Xdp[I, J]);
  end;
end;

procedure DrawImageWithEffect(S, D: TBitmap; CodeEffect: Integer; Transparency: Extended);
var
  I, J: Integer;
  P1, P2: PARGB;
  IW, IH: Integer;
  L, Ld, W, W1: Byte;
  SQ : array[0..255, 0..255] of Byte;
begin
  W := Round(255 * Transparency / 100);
  W1 := 1 - W;
  IH := Min(S.Height, D.Height);
  IW := Min(S.Width, D.Width);

  if CodeEffect = 1 then
    for I := 0 to 255 do
      for J := 0 to 255 do
        SQ[I, J] := Round(Sqrt(I * J));

  for I := 0 to IH - 1 do
  begin
    P1 := S.ScanLine[I];
    P2 := D.ScanLine[I];
    for J := 0 to IW - 1 do
    begin
      case CodeEffect of
        0:
          begin
            P2[J].R := (P1[J].R * W + P2[J].R * W1) shr 8;
            P2[J].G := (P1[J].G * W + P2[J].G * W1) shr 8;
            P2[J].B := (P1[J].B * W + P2[J].B * W1) shr 8;
          end;

        1:
          begin
            P2[J].R := (SQ[P2[J].R, P1[J].R] * W + P2[J].R * W1) shr 8;
            P2[J].G := (SQ[P2[J].G, P1[J].G] * W + P2[J].G * W1) shr 8;
            P2[J].B := (SQ[P2[J].B, P1[J].B] * W + P2[J].B * W1) shr 8;
          end;

        2:
          begin
            P2[J].R := (((P2[J].R * P1[J].R) shr 8) * W + P2[J].R * W1) shr 8;
            P2[J].G := (((P2[J].G * P1[J].G) shr 8) * W + P2[J].G * W1) shr 8;
            P2[J].B := (((P2[J].B * P1[J].B) shr 8) * W + P2[J].B * W1) shr 8;
          end;

        3:
          begin
            L := (P1[J].R * 77 + P1[J].G * 151 + P1[J].B * 28) shr 8;
            P2[J].R := (((P2[J].R * (255 - L) + P1[J].R * (L)) shr 8) * W + P2[J].R * W1) shr 8;
            P2[J].G := (((P2[J].G * (255 - L) + P1[J].G * (L)) shr 8) * W + P2[J].G * W1) shr 8;
            P2[J].B := (((P2[J].B * (255 - L) + P1[J].B * (L)) shr 8) * W + P2[J].B * W1) shr 8;
          end;

        4:
          begin
            L := (P1[J].R * 77 + P1[J].G * 151 + P1[J].B * 28) shr 8;
            LD := (P2[J].R * 77 + P2[J].G * 151 + P2[J].B * 28) shr 8;
            P2[J].R := (((P2[J].R * (255 - L) + (Ld * L) ) shr 8) * W + P2[J].R * W1) shr 8;
            P2[J].G := (((P2[J].G * (255 - L) + (Ld * L) ) shr 8) * W + P2[J].G * W1) shr 8;
            P2[J].B := (((P2[J].B * (255 - L) + (Ld * L) ) shr 8) * W + P2[J].B * W1) shr 8;
          end;

        5:
          begin
            L := 255 - (P1[J].R * 77 + P1[J].G * 151 + P1[J].B * 28) shr 8;
            LD := (P2[J].R * 77 + P2[J].G * 151 + P2[J].B * 28) shr 8;
            P2[J].R := (((P2[J].R * (255 - L) + (LD * L) ) shr 8) * W + P2[J].R * W1) shr 8;
            P2[J].G := (((P2[J].G * (255 - L) + (LD * L) ) shr 8) * W + P2[J].G * W1) shr 8;
            P2[J].B := (((P2[J].B * (255 - L) + (LD * L) ) shr 8) * W + P2[J].B * W1) shr 8;
          end;

        6:
          begin
            L := 255 - (P1[J].R * 77 + P1[J].G * 151 + P1[J].B * 28) shr 8;
            LD := (P2[J].R * 77 + P2[J].G * 151 + P2[J].B * 28) shr 8;
            if L < 5 then
            begin
              P2[J] := P2[J];
            end else
            begin
              P2[J].R := Min(255, (((P1[J].R * LD) div L) * W + P2[J].R * W1) shr 8);
              P2[J].G := Min(255, (((P1[J].G * LD) div L) * W + P2[J].G * W1) shr 8);
              P2[J].B := Min(255, (((P1[J].B * LD) div L) * W + P2[J].B * W1) shr 8);
            end;
          end;

        7:
          begin
            P2[J].R := (Abs((P2[J].R - P1[J].R) * W + P2[J].R * W1)) shr 8;
            P2[J].G := (Abs((P2[J].G - P1[J].G) * W + P2[J].G * W1)) shr 8;
            P2[J].B := (Abs((P2[J].B - P1[J].B) * W + P2[J].B * W1)) shr 8;
          end;
      end;
    end;
  end;
end;

procedure InsertImageToolPanelClass.DoEffect(Bitmap: TBitmap; ARect: TRect; FullImage: Boolean);
var
  W, H, AWidth, AHeight: Integer;
  Rct, DrawRect: TRect;
  TempBitmap, RectBitmap: TBitmap;
begin
  Rct.Top := Min(ARect.Top, ARect.Bottom);
  Rct.Bottom := Max(ARect.Top, ARect.Bottom);
  Rct.Left := Min(ARect.Left, ARect.Right);
  Rct.Right := Max(ARect.Left, ARect.Right);
  ARect := Rct;
  W := Abs(ARect.Right - ARect.Left);
  H := Abs(ARect.Bottom - ARect.Top);
  if W * H = 0 then
    Exit;
  AWidth := Image.Width;
  AHeight := Image.Height;
  if AWidth * AHeight = 0 then
    Exit;
  ProportionalSizeX(W, H, AWidth, AHeight);
  DrawRect := Rect(ARect.Left + W div 2 - AWidth div 2, ARect.Top + H div 2 - AHeight div 2,
    ARect.Left + W div 2 + AWidth div 2, ARect.Top + H div 2 + AHeight div 2);
  if not FullImage then
  begin
    RectBitmap := TBitmap.Create;
    try
      RectBitmap.PixelFormat := pf24bit;
      RectBitmap.SetSize(AWidth, AHeight);
      RectBitmap.Canvas.CopyRect(Rect(0, 0, AWidth, AHeight), Bitmap.Canvas, DrawRect);
      TempBitmap := TBitmap.Create;
      try
        TempBitmap.PixelFormat := pf24bit;
        TempBitmap.SetSize(AWidth, AHeight);
        TempBitmap.Canvas.StretchDraw(Rect(0, 0, AWidth, AHeight), Image);
        if RectBitmap.Width * RectBitmap.Height = 0 then
          Exit;
        DrawImageWithEffect(TempBitmap, RectBitmap, MethodDrawChooser.ItemIndex, TransparentEdit.Position);
      finally
        F(TempBitmap);
      end;
      Bitmap.Canvas.StretchDraw(DrawRect, RectBitmap);
    finally
      F(RectBitmap);
    end;
  end else
  begin
    RectBitmap := TBitmap.Create;
    try
      RectBitmap.PixelFormat := pf24bit;
      RectBitmap.Width := AWidth;
      RectBitmap.Height := AHeight;
      RectBitmap.Canvas.CopyRect(Rect(0, 0, AWidth, AHeight), Bitmap.Canvas, DrawRect);
      TempBitmap := TBitmap.Create;
      try
        TempBitmap.PixelFormat := pf24bit;
        if (Image.Width / AWidth) > 1 then
          DoResize(AWidth, AHeight, Image, TempBitmap)
        else
          Interpolate(0, 0, AWidth, AHeight, Rect(0, 0, Image.Width, Image.Height), Image, TempBitmap);
        if RectBitmap.Width * RectBitmap.Height = 0 then
          Exit;
        DrawImageWithEffect(TempBitmap, RectBitmap, MethodDrawChooser.ItemIndex, TransparentEdit.Position);
      finally
        F(TempBitmap);
      end;
      Bitmap.Canvas.StretchDraw(DrawRect, RectBitmap);
    finally
      F(RectBitmap);
    end;
  end;
end;

procedure InsertImageToolPanelClass.DoLoadFileFromFile(Sender: TObject);
var
  Pic: TPicture;
begin
  if OpenFileDialog.Execute then
  begin
    Pic := TPicture.Create;
    try
      Pic.LoadFromFile(OpenFileDialog.FileName);
      Image.Assign(Pic.Graphic);
    finally
      F(Pic);
    end;
    ProcRecteateImage(Sender);
  end;
end;

procedure InsertImageToolPanelClass.DoSaveSettings(Sender: TObject);
begin
  Settings.WriteInteger('Editor', 'InsertImageTransparency', TransparentEdit.Position);
end;

procedure InsertImageToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin

end;

class function InsertImageToolPanelClass.ID: string;
begin
  Result := '{CA9E5AFD-E92D-4105-8F7B-978A6EBA9D74}';
end;

function InsertImageToolPanelClass.LangID: string;
begin
  Result := 'InsertImageTool';
end;

procedure InsertImageToolPanelClass.RecreateImage(Sender: TObject);
begin
  if FLoading then
    Exit;
  LabelMethod.Caption := Format(L('Transparency [%d]'), [TransparentEdit.Position]);
  ProcRecteateImage(Sender);
end;

procedure InsertImageToolPanelClass.SetProperties(Properties: String);
begin

end;

end.
