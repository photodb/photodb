unit uFrmCreatePNGSteno;

interface

uses
  Winapi.Windows,
  Winapi.ShlObj,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.Menus,
  Vcl.Imaging.pngimage,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.LoadingSign,

  UnitDBFileDialogs,
  GraphicCrypt,
  DBCMenu,

  uConstants,
  uStenography,
  uAssociations,
  uShellIntegration,
  uTranslateUtils,
  uCryptUtils,
  uMemory,
  uFrameWizardBase,
  uDBUtils,
  uDBContext,
  uDBEntities,
  uDBManager,
  uDBBaseTypes,
  uProgramStatInfo,
  uPortableDeviceUtils;

type
  TFrmCreatePNGSteno = class(TFrameWizardBase)
    LbImageSize: TLabel;
    LbImageFileSize: TLabel;
    ImImageFile: TImage;
    LbImageFileInfo: TLabel;
    GbOptions: TGroupBox;
    LbPassword: TLabel;
    LbPasswordConfirm: TLabel;
    CbEncryptdata: TCheckBox;
    EdPassword: TWatermarkedEdit;
    EdPasswordConfirm: TWatermarkedEdit;
    CbIncludeCRC: TCheckBox;
    LbSelectFile: TLabel;
    EdDataFileName: TWatermarkedEdit;
    LbFileSize: TLabel;
    BtnChooseFile: TButton;
    CbFilter: TComboBox;
    LbFilter: TLabel;
    OpenDialog1: TOpenDialog;
    WblMethod: TWebLink;
    PmCryptMethod: TPopupActionBar;
    LsImage: TLoadingSign;
    procedure OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
      var Include: Boolean);
    procedure ImImageFileContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure BtnChooseFileClick(Sender: TObject);
    procedure CbEncryptdataClick(Sender: TObject);
  private
    { Private declarations }
    MaxFileSize: Integer;
    NormalFileSize: Integer;
    GoodFileSize: Integer;
    FBitmapImage: TBitmap;
    FImagePassword: string;
    FMethodChanger: TPasswordMethodChanger;
    function MaxDataFileSize: Cardinal;
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
    function IsFinal: Boolean; override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    function ValidateStep(Silent: Boolean): Boolean; override;
    procedure Execute; override;
    property ImageFileName: string read GetFileName;
  end;

implementation

uses
  UnitPasswordForm,
  uFrmSteganographyLanding,
  uStenoLoadImageThread;

{$R *.dfm}

function FileExists(const EFile: string; var SHigh, SLow: Cardinal): Integer;
var
  Sf: string;
  Fesr: TSearchRec;
  SfAttr: Integer;
begin
  Sf := Trim(EFile);
  Result := 3;
  if (Length(Sf) = 0) or (Sf[Length(Sf)] = '\') then
    Exit;
  SfAttr := $FFE7;
  Result := FindFirst(Sf, SfAttr, Fesr);
  if Result = 0 then
  begin
    Result := 2;
    repeat
      if (((Fesr.Attr and $10) <> $10) and ((Fesr.Attr and $8) <> $8)) then
      begin
        Result := 0;
        SHigh := Fesr.FindData.NFileSizeHigh;
        SLow := Fesr.FindData.NFileSizeLow;
      end;
    until (Result = 0) or (FindNext(Fesr) <> 0);
    FindClose(Fesr);
  end;
end;

procedure TFrmCreatePNGSteno.BtnChooseFileClick(Sender: TObject);
var
  DialogFileSize: Integer;
  Options : TOpenOptions;
begin
  inherited;
  DialogFileSize := MaxDataFileSize;
  if DialogFileSize <= 0 then
  begin
    MessageBoxDB(Handle, L('Please choose larger image for this action!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  if MaxFileSize < 0 then
    Exit;
  Options := OpenDialog1.Options;
  Include(Options, OfEnableIncludeNotify);
  Exclude(Options, OfOldStyleDialog);
  OpenDialog1.Options := Options;
  OpenDialog1.Filter := Format(L('All files (Size < %s)|*?*'), [SizeInText(DialogFileSize)]);
  if OpenDialog1.Execute then
    EdDataFileName.Text := OpenDialog1.FileName;

  CountResultFileSize;
  Changed;
end;

procedure TFrmCreatePNGSteno.CbEncryptdataClick(Sender: TObject);
begin
  EdPassword.Enabled := CbEncryptdata.Checked;
  EdPasswordConfirm.Enabled := CbEncryptdata.Checked;
  WblMethod.Enabled := CbEncryptdata.Checked;
end;

procedure TFrmCreatePNGSteno.CountResultFileSize;
var
  FileSize: Int64;
begin
  FileSize := 0;
  if EdDataFileName.Text <> '' then
    FileSize := GetFileSize(EdDataFileName.Text);

  LbFileSize.Caption := Format(L('File size: %s'), [SizeInText(FileSize)]);
end;

constructor TFrmCreatePNGSteno.Create(AOwner: TComponent);
begin
  inherited;
  FBitmapImage := nil;
  FImagePassword := '';
end;

procedure TFrmCreatePNGSteno.ErrorLoadingImageHandler(FileName: string);
begin
  IsBusy := False;
  Changed;
  Manager.PrevStep;
end;

procedure TFrmCreatePNGSteno.Execute;
var
  Bitmap : TBitmap;
  N : Integer;
  PNG: TPngImage;
  SavePictureDialog: DBSavePictureDialog;
  FileName: string;
  InfoStream : TMemoryStream;
begin
  inherited;

  //statistics
  ProgramStatistics.StegoUsed;

  FileName := EdDataFileName.Text;

  SavePictureDialog := DBSavePictureDialog.Create;
  try
    SavePictureDialog.Filter := TFileAssociations.Instance.GetFilter('.bmp|.png', True, False);
    SavePictureDialog.FilterIndex := 1;

    SavePictureDialog.SetFileName(ChangeFileExt(ImageFileName, '.png'));
    if SavePictureDialog.Execute then
    begin
      if SavePictureDialog.GetFilterIndex = 0 then
      begin
        if GetExt(SavePictureDialog.FileName) <> 'BMP' then
          SavePictureDialog.SetFileName(SavePictureDialog.FileName + '.bmp');
      end;
      if SavePictureDialog.GetFilterIndex = 1 then
      begin
        if GetExt(SavePictureDialog.FileName) <> 'PNG' then
          SavePictureDialog.SetFileName(SavePictureDialog.FileName + '.png');
      end;

      if not CbEncryptdata.Checked then
        MessageBoxDB(Handle, L('Information in the file will not be encrypted!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);

      InfoStream := TMemoryStream.Create;
      try
        if CbEncryptdata.Checked then
          SaveFileToCryptedStream(FileName, EdPassword.Text, InfoStream, False)
        else
          SaveFileToCryptedStream(FileName, '', InfoStream, False);

        N := GetMaxPixelsInSquare(FileName, FBitmapImage);
        if N < 0 then
        begin
          MessageBoxDB(Handle, L('File is too large!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);
          Exit;
        end;
        Bitmap := TBitmap.Create;
        try
          if not SaveInfoToBmpFile(FBitmapImage, Bitmap, InfoStream, N) then
            Exit;

          if SavePictureDialog.GetFilterIndex = 0 then
          begin
            Bitmap.SaveToFile(SavePictureDialog.FileName);
            if FImagePassword <> '' then
              CryptGraphicFileV3(SavePictureDialog.FileName, FImagePassword, CRYPT_OPTIONS_NORMAL);
            IsStepComplete := True;
            Changed;
          end else
          begin
            PNG := TPngImage.Create;
            try
              PNG.Assign(Bitmap);
              PNG.SaveToFile(SavePictureDialog.FileName);
              if FImagePassword <> '' then
                CryptGraphicFileV3(SavePictureDialog.FileName, FImagePassword, CRYPT_OPTIONS_NORMAL);
              IsStepComplete := True;
              Changed;
            finally
              F(PNG);
            end;
          end;
        finally
          F(Bitmap);
        end;
      finally
        F(InfoStream);
      end;
    end;
  finally
    F(SavePictureDialog);
  end;
end;

function TFrmCreatePNGSteno.GetFileName: string;
begin
  Result := TFrmSteganographyLanding(Manager.GetStepByType(TFrmSteganographyLanding)).ImageFileName;
end;

function TFrmCreatePNGSteno.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmCreatePNGSteno.LoadLanguage;
begin
  inherited;
  CbFilter.Items[0] := L('Max size (worse quality, big noise)');
  CbFilter.Items[1] := L('Standard size (almost imperceptibly)');
  CbFilter.Items[2] := L('Best size (imperceptibly)');

  LbImageFileInfo.Caption := L('Original image preview') + ':';
  GbOptions.Caption := L('Options');
  LbFilter.Caption := L('Filter') + ':';
  CbIncludeCRC.Caption := L('Add checksum (CRC)');
  CbEncryptdata.Caption := L('Encrypt data');
  LbPassword.Caption := L('Password') + ':';
  EdPassword.WatermarkText := L('Password');
  LbPasswordConfirm.Caption := L('Password confirm') + ':';
  EdPasswordConfirm.WatermarkText := L('Password confirm');

  LbSelectFile.Caption := L('File to hide') + ':';
  EdDataFileName.WatermarkText := L('Please select a file');

  CountResultFileSize;
  CbFilter.ItemIndex := 1;
end;

procedure TFrmCreatePNGSteno.LoadOtherImageHandler(Sender: TObject);
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

procedure TFrmCreatePNGSteno.OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
  var Include: Boolean);
var
  FileName: string;
  Sr: TStrRet;
  SHigh, SLow: Cardinal;
  IDL: PItemIDList;
begin
  Include := True; // Will not work :(
  Ofn.Psf.GetDisplayNameOf(Ofn.Pidl, SHGDN_FORPARSING, Sr);
  case Sr.UType of
    STRRET_CSTR:
      FileName := string(Sr.CStr);
    STRRET_WSTR:
      FileName := Sr.POleStr;
    STRRET_OFFSET:
      FileName := PChar(Cardinal(Ofn.Pidl) + Sr.UOffset);
  end;
  IDL := Ofn.Pidl;
  if (FileExists(FileName, SHigh, SLow) = 0) and ((SHigh > 0) or (SLow > MaxDataFileSize)) then
  begin
    Include := False; // Will not work :(
    try
      IDL^.Mkid.AbID[0] := 0;
    except
    end;
  end;
end;

procedure TFrmCreatePNGSteno.SetPreviewLoadingImageHandler(Width,
  Height: Integer; var Bitmap: TBitmap; Preview: TBitmap; Password: string);
begin
  F(FBitmapImage);
  FBitmapImage := Bitmap;
  Bitmap := nil;
  ImImageFile.Picture.Graphic := Preview;
  LbImageSize.Caption := Format(L('Image size: %dx%d px.'), [Width, Height]);
  LbImageSize.Show;

  MaxFileSize := MaxSizeInfoInGraphic(FBitmapImage, 2);
  NormalFileSize := MaxSizeInfoInGraphic(FBitmapImage, 5);
  GoodFileSize := MaxSizeInfoInGraphic(FBitmapImage, 8);

  FImagePassword := Password;

  LsImage.Hide;
  IsBusy := False;
  Changed;
end;

procedure TFrmCreatePNGSteno.ImImageFileContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Info: TMediaItemCollection;
  Rec: TMediaItem;
  Menus: TArMenuItem;
  Context: IDBContext;
  MediaRepository: IMediaRepository;
begin
  Info := TMediaItemCollection.Create;
  try
    Rec := TMediaItem.CreateFromFile(ImageFileName);

    Context := DBManager.DBContext;
    MediaRepository := Context.Media;
    MediaRepository.UpdateMediaFromDB(Rec, False);

    Rec.Selected := True;

    Info.IsPlusMenu := False;
    Info.IsListItem := False;
    Info.Add(Rec);
    Setlength(Menus, 1);
    Menus[0] := TMenuItem.Create(nil);
    Menus[0].Caption := L('Load other image');
    Menus[0].ImageIndex := DB_IC_LOADFROMFILE;
    Menus[0].OnClick := LoadOtherImageHandler;
    TDBPopupMenu.Instance.ExecutePlus(Manager.Owner, ImImageFile.ClientToScreen(MousePos).X, ImImageFile.ClientToScreen(MousePos).Y, Info,
      Menus);
  finally
    F(Info);
  end;
end;

procedure TFrmCreatePNGSteno.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
var
  FPassIcon: HIcon;
  FileSize: Int64;
begin
  inherited;

  if FirstInitialization then
  begin
    FMethodChanger := TPasswordMethodChanger.Create(WblMethod, PmCryptMethod);
    FPassIcon := LoadIcon(HInstance, PChar('PASSWORD'));
    try
      WblMethod.LoadFromHIcon(FPassIcon);
    finally
      DestroyIcon(FPassIcon);
    end;
  end else
  begin
    if not IsDevicePath(ImageFileName) then
      FileSize := GetFileSize(ImageFileName)
    else
      FileSize := GetDeviceItemSize(ImageFileName);

    LbImageFileSize.Caption := Format(L('File size: %s'), [SizeInText(FileSize)]);

    F(FBitmapImage);
    if ImImageFile.Picture.Graphic = nil then
      LsImage.Show;
    TStenoLoadImageThread.Create(Manager.Owner, ImageFileName, Color, ErrorLoadingImageHandler, SetPreviewLoadingImageHandler);
    IsBusy := True;
    Changed;
  end;
end;

procedure TFrmCreatePNGSteno.Unload;
begin
  inherited;
  F(FBitmapImage);
  F(FMethodChanger);
end;

function TFrmCreatePNGSteno.ValidateStep(Silent: Boolean): Boolean;
begin
  Result := (EdDataFileName.Text <> '') and (ImImageFile.Picture.Graphic <> nil);
  if CbEncryptdata.Checked then
  begin
    Result := Result and (EdPassword.Text = EdPasswordConfirm.Text) and
      (EdPassword.Text <> '');
  end;
  if not Silent and (ImImageFile.Picture.Graphic = nil) then
    LoadOtherImageHandler(Self)
  else if not Silent and not FileExistsSafe(EdDataFileName.Text) then
    BtnChooseFileClick(Self);
end;

function TFrmCreatePNGSteno.MaxDataFileSize: Cardinal;
begin
  case CbFilter.ItemIndex of
    0:
      Result := MaxFileSize;
    1:
      Result := NormalFileSize;
  else
    Result := GoodFileSize;
  end;
end;

end.
