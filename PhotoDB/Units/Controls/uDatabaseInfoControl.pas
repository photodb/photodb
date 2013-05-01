unit uDatabaseInfoControl;

interface

uses
  Winapi.Messages,
  System.Math,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Imaging.jpeg,
  Vcl.ExtCtrls,

  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  uMemory;

type
  TDatabaseInfoControl = class(TPanel)
  private
    FImage: TImage;
    FDatabaseName: TWebLink;
    FLoadingSign: TLoadingSign;
    FInfoLabel: TLabel;
    FSeparator: TBevel;
    FSelectImage: TImage;
    FMinimized: Boolean;
    FOnSelectClick: TNotifyEvent;
    procedure DoAlignInfo;
    procedure SelectDatabaseClick(Sender: TObject);
  protected
    procedure Resize; override;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadControl;
    property OnSelectClick: TNotifyEvent read FOnSelectClick write FOnSelectClick;
  end;

implementation

{ TDatabaseInfoControl }

constructor TDatabaseInfoControl.Create(AOwner: TComponent);
begin
  inherited;
  StyleElements := [seFont, seClient, seBorder];
  ParentBackground := False;
  BevelOuter := bvNone;
end;

procedure TDatabaseInfoControl.DoAlignInfo;
var
  L: Integer;
begin
  FMinimized := Height < 36;

  if FImage = nil then
    Exit;

  DisableAlign;
  try
    FImage.Height := Height - 2;
    FImage.Width := FImage.Height;
    if not FMinimized then
    begin
      FDatabaseName.Left := FImage.Left + FImage.Width + 3;
      FDatabaseName.Top := Height div 2 - (FDatabaseName.Height + 3 + FLoadingSign.Height) div 2;

      FLoadingSign.Left := FImage.Left + FImage.Width + 3;
      FLoadingSign.Top := FDatabaseName.Top + FDatabaseName.Height + 3;

      FInfoLabel.Visible := True;
      FInfoLabel.Top := FLoadingSign.Top + FLoadingSign.Height div 2 - FInfoLabel.Height div 2;
      FInfoLabel.Left := FLoadingSign.Left + FLoadingSign.Height + 3;
    end else
    begin
      FInfoLabel.Visible := False;
      FInfoLabel.Left := 0;

      FLoadingSign.Left := FImage.Left + FImage.Width + 3;
      FLoadingSign.Top := Height div 2 - FLoadingSign.Height div 2;

      FDatabaseName.Left := FLoadingSign.Left + FLoadingSign.Width + 3;
      FDatabaseName.Top := Height div 2 - FDatabaseName.Height div 2;
    end;

    L := Max(FDatabaseName.Left + FDatabaseName.Width, FInfoLabel.Left + FInfoLabel.Width);
    FSeparator.Left := L + 3;
    FSeparator.Height := Height;

    FSelectImage.Left := FSeparator.Left + FSeparator.Width;
    FSelectImage.Height := Height;

    Width := FSelectImage.Width + FSelectImage.Left + 2;
  finally
    EnableAlign;
  end;
end;

procedure TDatabaseInfoControl.LoadControl;
begin
  DisableAlign;
  try
    FImage := TImage.Create(Self);
    FImage.Parent := Self;
    FImage.Top := 1;
    FImage.Left := 1;
    FImage.Center := True;
    FImage.Stretch := True;
    FImage.Picture.LoadFromFile('C:\Users\dolphin.HOME\Desktop\PS\4250486 Николай Зиновьев - Ndutu gold.jpg');
    FImage.Proportional := True;

    FDatabaseName := TWebLink.Create(Self);
    FDatabaseName.Parent := Self;
    FDatabaseName.IconWidth := 0;
    FDatabaseName.IconHeight := 0;
    FDatabaseName.Font.Size := 11;
    FDatabaseName.Text := 'Database';
    FDatabaseName.RefreshBuffer(True);

    FLoadingSign := TLoadingSign.Create(Self);
    FLoadingSign.Parent := Self;
    FLoadingSign.Width := 16;
    FLoadingSign.Height := 16;
    FLoadingSign.FillPercent := 50;
    FLoadingSign.Active := True;

    FInfoLabel := TLabel.Create(Self);
    FInfoLabel.Parent := Self;
    FInfoLabel.Caption := '31k+';

    FSeparator := TBevel.Create(Self);
    FSeparator.Parent := Self;
    FSeparator.Width := 2;
    FSeparator.Top := 0;

    FSelectImage := TImage.Create(Self);
    FSelectImage.Parent := Self;
    FSelectImage.Picture.LoadFromFile('C:\Users\dolphin.HOME\Downloads\1367448137_navigate-down.png');
    FSelectImage.Width := 20;
    FSelectImage.Center := True;
    FSelectImage.Cursor := crHandPoint;
    FSelectImage.OnClick := SelectDatabaseClick;

    DoAlignInfo;
  finally
    EnableAlign;
  end;
end;

procedure TDatabaseInfoControl.Resize;
begin
  inherited;
  DoAlignInfo;
end;

procedure TDatabaseInfoControl.SelectDatabaseClick(Sender: TObject);
begin
  if Assigned(FOnSelectClick) then
    FOnSelectClick(Self);
end;

procedure TDatabaseInfoControl.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
 // Message.Result := 1;
end;

end.
