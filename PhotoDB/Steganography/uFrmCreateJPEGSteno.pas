unit uFrmCreateJPEGSteno;

interface

uses
  Windows,
  Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.Themes,
  Vcl.Imaging.jpeg,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.LoadingSign,

  CCR.Exif,

  UnitDBDeclare,
  GraphicCrypt,
  DBCMenu,
  UnitDBKernel,
  UnitDBCommon,
  UnitDBCommonGraphics,
  Dolphin_db,
  UnitDBFileDialogs,

  uFrameWizardBase,
  uDBPopupMenuInfo,
  uDBUtils,
  uMemory,
  uJpegUtils,
  uShellIntegration,
  uConstants,
  uGraphicUtils,
  uCryptUtils,
  uDBBaseTypes,
  uAssociations,
  uStenography,
  uPortableDeviceUtils,
  uFormInterfaces;

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
    PmCryptMethod: TPopupActionBar;
    CbConvertImage: TCheckBox;
    WblJpegOptions: TWebLink;
    LsImage: TLoadingSign;
    procedure ImJpegFileContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure CbEncryptdataClick(Sender: TObject);
    procedure BtnChooseFileClick(Sender: TObject);
    procedure WblJpegOptionsClick(Sender: TObject);
    procedure CbConvertImageClick(Sender: TObject);
  private
    { Private declarations }
    FImagePassword: string;
    FImageFileSize: Int64;
    FDataFileSize: Int64;
    FMethodChanger: TPasswordMethodChanger;
    FBitmapImage: TBitmap;
    function GetFileName: string;
    procedure CountResultFileSize;
    procedure LoadOtherImageHandler(Sender: TObject);
    procedure ErrorLoadingImageHandler(FileName: string);
    procedure SetPreviewLoadingImageHandler(Width, Height: Integer; var Bitmap: TBitmap; Preview: TBitmap; Password: string);
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    function IsFinal: Boolean; override;
    function ValidateStep(Silent: Boolean): Boolean; override;
    procedure Execute; override;
    property ImageFileName: string read GetFileName;
  end;

implementation

uses
  uStenoLoadImageThread,
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

procedure TFrmCreateJPEGSteno.CbConvertImageClick(Sender: TObject);
begin
  inherited;
  WblJpegOptions.Enabled := CbConvertImage.Checked;
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

constructor TFrmCreateJPEGSteno.Create(AOwner: TComponent);
begin
  inherited;
  FBitmapImage := nil;
end;

procedure TFrmCreateJPEGSteno.ErrorLoadingImageHandler(FileName: string);
begin
  IsBusy := False;
  Changed;
  Manager.PrevStep;
end;

procedure TFrmCreateJPEGSteno.Execute;
var
  SavePictureDialog: DBSavePictureDialog;
  J: TJpegImage;
  EXIFSection: TExifData;
  MS: TMemoryStream;
begin
  inherited;
  SavePictureDialog := DBSavePictureDialog.Create;
  try
    SavePictureDialog.Filter := TFileAssociations.Instance.GetFilter('.jpg', True, False);
    SavePictureDialog.FilterIndex := 1;
    SavePictureDialog.SetFileName(ChangeFileExt(ImageFileName, '.jpg'));
    if SavePictureDialog.Execute then
    begin
      if TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(SavePictureDialog.FileName)) <> TJPEGImage  then
        SavePictureDialog.SetFileName(SavePictureDialog.FileName + '.jpg');

      if CbConvertImage.Checked then
      begin
        J := TJpegImage.Create;
        try
          J.Assign(FBitmapImage);
          JpegOptionsForm.Execute('JpegSteganography');
          SetJPEGGraphicSaveOptions('JpegSteganography', J);
          J.Compress;

          EXIFSection := TExifData.Create;
          try
            EXIFSection.LoadFromGraphic(ImageFileName);

            MS := TMemoryStream.Create;
            try
              J.SaveToStream(MS);
              MS.Seek(0, soFromBeginning);

              if not CbEncryptdata.Checked then
              begin
                MessageBoxDB(Handle, L('Information in the file will not be encrypted!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);
                CreateJPEGStenoEx(EdDataFileName.Text, SavePictureDialog.FileName, MS, '');
              end else
                CreateJPEGStenoEx(EdDataFileName.Text, SavePictureDialog.FileName, MS, EdPassword.Text);

              if not EXIFSection.Empty then
                EXIFSection.SaveToGraphic(SavePictureDialog.FileName);

              IsStepComplete := True;
              Changed;
            finally
              F(MS);
            end;

          finally
            F(EXIFSection);
          end;
        finally
          F(J);
        end;
      end else
      begin
        if not CbEncryptdata.Checked then
        begin
          MessageBoxDB(Handle, L('Information in the file will not be encrypted!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);
          CreateJPEGSteno(EdDataFileName.Text, SavePictureDialog.FileName, ImageFileName, '');
        end else
          CreateJPEGSteno(EdDataFileName.Text, SavePictureDialog.FileName, ImageFileName, EdPassword.Text);
        IsStepComplete := True;
        Changed;
      end;
    end;
  finally
    F(SavePictureDialog);
  end;
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
  Menus: TArMenuItem;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    Rec := TDBPopupMenuInfoRecord.CreateFromFile(ImageFileName);
    uDBUtils.GetInfoByFileNameA(ImageFileName, False, Rec);
    Rec.Selected := True;

    Info.IsPlusMenu := False;
    Info.IsListItem := False;
    Info.Add(Rec);
    Setlength(Menus, 1);
    Menus[0] := TMenuItem.Create(nil);
    Menus[0].Caption := L('Load other image');
    Menus[0].ImageIndex := DB_IC_LOADFROMFILE;
    Menus[0].OnClick := LoadOtherImageHandler;
    TDBPopupMenu.Instance.ExecutePlus(Manager.Owner, ImJpegFile.ClientToScreen(MousePos).X, ImJpegFile.ClientToScreen(MousePos).Y, Info,
      Menus);
  finally
    F(Info);
  end;
end;

procedure TFrmCreateJPEGSteno.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
var
  FPassIcon: HIcon;
  GraphicClass: TGraphicClass;
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

    if StyleServices.Enabled then
    begin
      ParentBackground := True;
      ParentColor := True;
    end;
  end else
  begin

    if not IsDevicePath(ImageFileName) then
      FImageFileSize := GetFileSize(ImageFileName)
    else
      FImageFileSize := GetDeviceItemSize(ImageFileName);

    LbJpegFileSize.Caption := Format(L('File size: %s'), [SizeInText(FImageFileSize)]);

    F(FBitmapImage);
    if ImJpegFile.Picture.Graphic = nil then
      LsImage.Show;
    TStenoLoadImageThread.Create(Manager.Owner, ImageFileName, Color,
      ErrorLoadingImageHandler, SetPreviewLoadingImageHandler);

    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(ImageFileName));
    if GraphicClass = TJPEGImage then
    begin
      CbConvertImage.Checked := False;
      CbConvertImage.Enabled := True;
    end else
    begin
      CbConvertImage.Checked := True;
      CbConvertImage.Enabled := False;
    end;
    CbConvertImageClick(Self);
    IsBusy := True;
    Changed;
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

  WblJpegOptions.Text := L('JPEG Options');
  CbConvertImage.Caption := L('Convert image');

  CountResultFileSize;
end;

procedure TFrmCreateJPEGSteno.LoadOtherImageHandler(Sender: TObject);
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
   OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
    OpenPictureDialog.FilterIndex := 1;
    if OpenPictureDialog.Execute then
    begin
      TFrmSteganographyLanding(Manager.GetStepByType(TFrmSteganographyLanding)).ImageFileName := OpenPictureDialog.FileName;
      Init(Manager, False);
    end;

  finally
    F(OpenPictureDialog);
  end;
end;

procedure TFrmCreateJPEGSteno.SetPreviewLoadingImageHandler(Width,
  Height: Integer; var Bitmap: TBitmap; Preview: TBitmap; Password: string);
begin
  F(FBitmapImage);
  FBitmapImage := Bitmap;
  Bitmap := nil;

  ImJpegFile.Picture.Graphic := Preview;
  LbImageSize.Caption := Format(L('Image size: %dx%d px.'), [Width, Height]);
  LbImageSize.Show;

  FImagePassword := Password;

  LsImage.Hide;
  IsBusy := False;
  Changed;
end;

procedure TFrmCreateJPEGSteno.Unload;
begin
  inherited;
  F(FMethodChanger);
  F(FBitmapImage);
end;

function TFrmCreateJPEGSteno.ValidateStep(Silent: Boolean): Boolean;
begin
  Result := FileExistsSafe(EdDataFileName.Text) and (ImJpegFile.Picture.Graphic <> nil);
  if CbEncryptdata.Checked then
  begin
    Result := Result and (EdPassword.Text = EdPasswordConfirm.Text) and
      (EdPassword.Text <> '');
  end;
  if not Silent and (ImJpegFile.Picture.Graphic = nil) then
    LoadOtherImageHandler(Self)
  else if not Silent and not FileExistsSafe(EdDataFileName.Text) then
    BtnChooseFileClick(Self);
end;

procedure TFrmCreateJPEGSteno.WblJpegOptionsClick(Sender: TObject);
begin
  inherited;
  JpegOptionsForm.Execute('JpegSteganography');
end;

end.
