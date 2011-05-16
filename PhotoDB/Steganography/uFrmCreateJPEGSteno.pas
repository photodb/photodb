unit uFrmCreateJPEGSteno;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, ExtCtrls, StdCtrls, WatermarkedEdit, Menus,
  WebLink, uDBPopupMenuInfo, UnitDBDeclare, uDBUtils, DBCMenu, uMemory, jpeg,
  uShellIntegration, GraphicCrypt, UnitDBKernel, uConstants, uGraphicUtils,
  UnitDBCommon, UnitDBCommonGraphics, uCryptUtils, Dolphin_db,
  UnitDBFileDialogs, uFileUtils;

type
  TFrmCreateJPEGSteno = class(TFrameWizardBase)
    ImJpegFile: TImage;
    LbJpegFileInfo: TLabel;
    LbJpegFileSize: TLabel;
    LbImageSize: TLabel;
    EdDataFileName: TWatermarkedEdit;
    LbSelectFile: TLabel;
    BtnChooseFile: TButton;
    LbFileSize: TLabel;
    LbResultImageSize: TLabel;
    GbOptions: TGroupBox;
    CbEncryptdata: TCheckBox;
    LbPassword: TLabel;
    EdPassword: TWatermarkedEdit;
    LbPasswordConfirm: TLabel;
    EdPasswordConfirm: TWatermarkedEdit;
    CbIncludeCRC: TCheckBox;
    WblMethod: TWebLink;
    PmCryptMethod: TPopupMenu;
    procedure ImJpegFileContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure CbEncryptdataClick(Sender: TObject);
    procedure BtnChooseFileClick(Sender: TObject);
  private
    { Private declarations }
    FImagePassword: string;
    FImageFileSize: Int64;
    FDataFileSize: Int64;
    FMethodChanger: TPasswordMethodChanger;
    function GetFileName: string;
    procedure CountResultFileSize;
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    function IsFinal: Boolean; override;
    property ImageFileName: string read GetFileName;
  end;

implementation

uses
  UnitPasswordForm,
  uFrmSteganographyLanding;

{$R *.dfm}

{ TFrmCreateJPEGSteno }

procedure TFrmCreateJPEGSteno.BtnChooseFileClick(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('All files (*.*)|*.*');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
    begin
      EdDataFileName.Text := OpenDialog.FileName;
      FDataFileSize := GetFileSize(OpenDialog.FileName);
      CountResultFileSize;
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TFrmCreateJPEGSteno.CbEncryptdataClick(Sender: TObject);
begin
  inherited;
  EdPassword.Enabled := CbEncryptdata.Checked;
  EdPasswordConfirm.Enabled := CbEncryptdata.Checked;
  WblMethod.Enabled := CbEncryptdata.Checked;
end;

procedure TFrmCreateJPEGSteno.CountResultFileSize;
begin
  LbFileSize.Caption := Format(L('File size: %s'), [SizeInText(FDataFileSize)]);
  LbResultImageSize.Caption := Format(L('Result file size: %s'), [SizeInText(FImageFileSize + FDataFileSize)]);
end;

function TFrmCreateJPEGSteno.GetFileName: string;
begin
  Result := TFrmSteganographyLanding(Manager.GetStepByType(TFrmSteganographyLanding)).ImageFileName;
end;

procedure TFrmCreateJPEGSteno.ImJpegFileContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Info: TDBPopupMenuInfo;
  Rec: TDBPopupMenuInfoRecord;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    Rec := TDBPopupMenuInfoRecord.CreateFromFile(ImageFileName);
    uDBUtils.GetInfoByFileNameA(ImageFileName, False, Rec);
    Rec.Selected := True;
    Info.Add(Rec);
    Info.AttrExists := False;
    TDBPopupMenu.Instance.Execute(Manager.Owner, ImJpegFile.ClientToScreen(MousePos).X, ImJpegFile.ClientToScreen(MousePos).Y, Info);
  finally
    F(Info);
  end;
end;

procedure TFrmCreateJPEGSteno.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
var
  JPEG: TJpegImage;
  B32,
  FBitmapImage,
  PreviewImage: TBitmap;
  W, H: Integer;
  FPassIcon: HIcon;
begin
  inherited;

  FDataFileSize := 0;

  if FirstInitialization then
  begin
    FMethodChanger := TPasswordMethodChanger.Create(WblMethod, PmCryptMethod);
    FPassIcon := LoadIcon(HInstance, PChar('PASSWORD'));
    try
      WblMethod.LoadFromHIcon(FPassIcon);
    finally
      DestroyIcon(FPassIcon);
    end;
  end;

  FImageFileSize := GetFileSize(ImageFileName);
  LbJpegFileSize.Caption := Format(L('File size: %s'), [SizeInText(FImageFileSize)]);

  FImagePassword := '';
  FBitmapImage := TBitmap.Create;
  try
    JPEG := nil;
    try
      if ValidCryptGraphicFile(ImageFileName) then
      begin
        FImagePassword := DBkernel.FindPasswordForCryptImageFile(ImageFileName);
        if FImagePassword = '' then
          FImagePassword := GetImagePasswordFromUser(ImageFileName);

        if FImagePassword <> '' then
        begin
          JPEG := DeCryptGraphicFile(ImageFileName, FImagePassword) as TJpegImage;
        end else
        begin
          MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [ImageFileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
          Manager.PrevStep;
          Exit;
        end;
      end else
      begin
        JPEG := TJpegImage.Create;
        JPEG.LoadFromFile(ImageFileName);
      end;

      LbImageSize.Caption := Format(L('Image size: %dx%d px.'), [JPEG.Width, JPEG.Height]);
      JPEGScale(JPEG, Screen.Width, Screen.Height);
      FBitmapImage.Assign(JPEG);
      F(JPEG);
      FBitmapImage.PixelFormat := pf24bit;

      PreviewImage := TBitmap.Create;
      try
        W := FBitmapImage.Width;
        H := FBitmapImage.Height;
        ProportionalSize(146, 146, W, H);
        DoResize(W, H, FBitmapImage, PreviewImage);
        B32 := TBitmap.Create;
        try
          DrawShadowToImage(B32, PreviewImage);
          LoadBMPImage32bit(B32, PreviewImage, Color);
          ImJpegFile.Picture.Graphic := PreviewImage;
        finally
          F(B32);
        end;
      finally
        F(PreviewImage);
      end;

    finally
      F(JPEG);
    end;
  finally
    F(FBitmapImage);
  end;
end;

function TFrmCreateJPEGSteno.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmCreateJPEGSteno.LoadLanguage;
begin
  inherited;
  LbJpegFileInfo.Caption := L('Original image preview') + ':';
  GbOptions.Caption := L('Options');
  CbIncludeCRC.Caption := L('Add checksum (CRC)');
  CbEncryptdata.Caption := L('Encrypt data');
  LbPassword.Caption := L('Password') + ':';
  EdPassword.WatermarkText := L('Password');
  LbPasswordConfirm.Caption := L('Password confirm') + ':';
  EdPasswordConfirm.WatermarkText := L('Password confirm');

  LbSelectFile.Caption := L('File to hide') + ':';
  EdDataFileName.WatermarkText := L('Please select a file');

  CountResultFileSize;
end;

procedure TFrmCreateJPEGSteno.Unload;
begin
  inherited;
  F(FMethodChanger);
end;

end.
