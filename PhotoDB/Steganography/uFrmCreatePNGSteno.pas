unit uFrmCreatePNGSteno;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, StdCtrls, WatermarkedEdit, ExtCtrls, ShlObj,
  uMemory, UnitDBFileDialogs, pngimage, uFileUtils, uConstants, uStenography,
  GraphicCrypt, dolphin_db, UnitDBKernel, uAssociations, uShellIntegration,
  UnitDBCommonGraphics, UnitDBCommon, uGraphicUtils, uDBPopupMenuInfo,
  UnitDBDeclare, DBCMenu;

type
  TFrmCreatePNGSteno = class(TFrameWizardBase)
    LbImageSize: TLabel;
    LbJpegFileSize: TLabel;
    ImImageFile: TImage;
    LbImageFileInfo: TLabel;
    Gbptions: TGroupBox;
    LbPassword: TLabel;
    Label1: TLabel;
    CbEncryptdata: TCheckBox;
    EdPassword: TWatermarkedEdit;
    EdPasswordConfirm: TWatermarkedEdit;
    CbIncludeCRC: TCheckBox;
    LbSelectFile: TLabel;
    EdDataFileName: TWatermarkedEdit;
    LbFileSize: TLabel;
    LbResultImageSize: TLabel;
    BtnChooseFile: TButton;
    CbFilter: TComboBox;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    procedure OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
      var Include: Boolean);
    procedure ImImageFileContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure BtnChooseFileClick(Sender: TObject);
  private
    { Private declarations }
    MaxFileSize: Integer;
    NormalFileSize: Integer;
    GoodFileSize: Integer;
    FBitmapImage: TBitmap;
    FImagePassword: string;
    function MaxDataFileSize: Cardinal;
    function GetFileName: string;
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsFinal: Boolean; override;
    procedure Execute; override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    function ValidateStep(Silent: Boolean): Boolean; override;
    property ImageFileName: string read GetFileName;
  end;

implementation

uses
  UnitPasswordForm,
  UnitCryptImageForm,
  uFrmSteganographyLanding;

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
  if MaxFileSize < 0 then
    Exit;
  Options := OpenDialog1.Options;
  Include(Options, OfEnableIncludeNotify);
  Exclude(Options, OfOldStyleDialog);
  OpenDialog1.Options := Options;
  OpenDialog1.Filter := Format(L('All files (Size < %s)|*?*'), [SizeInText(DialogFileSize)]);
  if OpenDialog1.Execute then
    EdDataFileName.Text := OpenDialog1.FileName;
  Changed;
end;

constructor TFrmCreatePNGSteno.Create(AOwner: TComponent);
begin
  inherited;
  FBitmapImage := nil;
  FImagePassword := '';
end;

procedure TFrmCreatePNGSteno.Execute;
var
  Bitmap : TBitmap;
  N : Integer;
  PNG: TPngImage;
  Opt: TCryptImageOptions;
  SavePictureDialog: DBSavePictureDialog;
  FileName: string;
  InfoStream : TMemoryStream;
begin
  inherited;

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
      Opt := GetPassForCryptImageFile(FileName);
      if Opt.Password = '' then
        MessageBoxDB(Handle, L('Information in the file will not be encrypted!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);

      InfoStream := TMemoryStream.Create;
      try
        SaveFileToCryptedStream(FileName, Opt.Password, InfoStream, False);
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
              CryptGraphicFileV2(SavePictureDialog.FileName, FImagePassword, CRYPT_OPTIONS_NORMAL);
            IsStepComplete := True;
            Changed;
          end else
          begin
            PNG := TPngImage.Create;
            try
              PNG.Assign(Bitmap);
              PNG.SaveToFile(SavePictureDialog.FileName);
              if FImagePassword <> '' then
                CryptGraphicFileV2(SavePictureDialog.FileName, FImagePassword, CRYPT_OPTIONS_NORMAL);
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

procedure TFrmCreatePNGSteno.ImImageFileContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Info: TDBPopupMenuInfo;
  Rec: TDBPopupMenuInfoRecord;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    Rec := TDBPopupMenuInfoRecord.CreateFromFile(ImageFileName);
    Info.Add(Rec);
    Info.AttrExists := False;
    TDBPopupMenu.Instance.Execute(Manager.Owner, ImImageFile.ClientToScreen(MousePos).X, ImImageFile.ClientToScreen(MousePos).Y, Info);
  finally
    F(Info);
  end;
end;

procedure TFrmCreatePNGSteno.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
var
  PreviewImage, B32: TBitmap;
  W, H: Integer;
  Graphic: TGraphic;
  GraphicClass: TGraphicClass;
begin
  inherited;

  F(FBitmapImage);
  FBitmapImage := TBitmap.Create;

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(ImageFileName));
  if GraphicClass = nil then
    Exit;

  Graphic := nil;
  try
    if ValidCryptGraphicFile(ImageFileName) then
    begin
      FImagePassword := DBkernel.FindPasswordForCryptImageFile(ImageFileName);
      if FImagePassword = '' then
        FImagePassword := GetImagePasswordFromUser(ImageFileName);

      if FImagePassword <> '' then
      begin
        Graphic := DeCryptGraphicFile(ImageFileName, FImagePassword);
      end else
      begin
        MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [ImageFileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        Exit;
      end;
    end else
    begin
      Graphic := GraphicClass.Create;
      Graphic.LoadFromFile(ImageFileName);
    end;

    JPEGScale(Graphic, Screen.Width, Screen.Height);
    FBitmapImage.Assign(Graphic);
    F(Graphic);
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
        ImImageFile.Picture.Graphic := PreviewImage;
      finally
        F(B32);
      end;
    finally
      F(PreviewImage);
    end;

  finally
    F(Graphic);
  end;

  MaxFileSize := MaxSizeInfoInGraphic(FBitmapImage, 2);
  NormalFileSize := MaxSizeInfoInGraphic(FBitmapImage, 5);
  GoodFileSize := MaxSizeInfoInGraphic(FBitmapImage, 8);
end;

procedure TFrmCreatePNGSteno.Unload;
begin
  inherited;
  F(FBitmapImage);
end;

function TFrmCreatePNGSteno.ValidateStep(Silent: Boolean): Boolean;
begin
  Result := EdDataFileName.Text <> '';
  if CbEncryptdata.Checked then
  begin
    Result := Result and (EdPassword.Text = EdPasswordConfirm.Text) and
      (EdPassword.Text <> '');
  end;
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
