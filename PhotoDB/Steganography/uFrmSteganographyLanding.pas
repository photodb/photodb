unit uFrmSteganographyLanding;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, uFrameWizardBase, pngimage, uStenography, UnitDBFileDialogs,
  GraphicCrypt, DECUtil, DECCipher, win32crc, UnitDBKernel, uShellIntegration,
  uConstants, uFileUtils, uMemory, uStrongCrypt, uAssociations;

type
  TFrmSteganographyLanding = class(TFrameWizardBase)
    RbHideDataInImage: TRadioButton;
    LbHideDataInImageInfo: TLabel;
    RbHideDataInJPEGFile: TRadioButton;
    LbHideDataInJPEGFileInfo: TLabel;
    LbStepInfo: TLabel;
    RbExtractDataFromImage: TRadioButton;
    procedure RbHideDataInImageClick(Sender: TObject);
  private
    { Private declarations }
    FImageFileName: string;
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    function IsFinal: Boolean; override;
    function InitNextStep: Boolean; override;
    procedure Execute; override;
    function LoadInfoFromFile(FileName: String) : Boolean;
    property ImageFileName: string read FImageFileName write FImageFileName;
  end;

implementation

{$R *.dfm}

uses
  UnitPasswordForm, UnitCryptImageForm, uFrmCreateJPEGSteno, uFrmCreatePNGSteno;

procedure TFrmSteganographyLanding.Execute;
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  inherited;
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.GetFilter('.png|.jpg|.bmp', True, True);
    OpenPictureDialog.FilterIndex := 1;
    if OpenPictureDialog.Execute then
      if LoadInfoFromFile(OpenPictureDialog.FileName) then
      begin
        IsStepComplete := True;
        Changed;
      end;
  finally
    F(OpenPictureDialog);
  end;
end;

procedure TFrmSteganographyLanding.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if not FirstInitialization then
    FImageFileName := '';
end;

function TFrmSteganographyLanding.InitNextStep: Boolean;
var
  OpenPictureDialog: DBOpenPictureDialog;
  Filter: string;
begin
  Result := True;

  Filter := '';
  if FImageFileName = '' then
  begin
    if RbHideDataInImage.Checked then
      Filter := TFileAssociations.Instance.FullFilter;
    if RbHideDataInJPEGFile.Checked then
      Filter := TFileAssociations.Instance.GetFilter('.jpg', True, True);

    if Filter <> '' then
    begin
      FImageFileName := '';
      OpenPictureDialog := DBOpenPictureDialog.Create;
      try
        OpenPictureDialog.Filter := Filter;
        OpenPictureDialog.FilterIndex := 1;
        if OpenPictureDialog.Execute then
          FImageFileName := OpenPictureDialog.FileName
        else
          Result := False;

      finally
        F(OpenPictureDialog);
      end;
    end;
  end;

  if Result then
  begin
    if RbHideDataInImage.Checked then
      Manager.AddStep(TFrmCreatePNGSteno);
    if RbHideDataInJPEGFile.Checked then
      Manager.AddStep(TFrmCreateJPEGSteno);
  end;
end;

function TFrmSteganographyLanding.IsFinal: Boolean;
begin
  Result := RbExtractDataFromImage.Checked;
end;

function TFrmSteganographyLanding.LoadInfoFromFile(FileName: String) : Boolean;
var
  Bitmap: TBitmap;
  PNG: TPngImage;
  Info, Data: TMemoryStream;
  Header: StenographyHeader;
  Password: string;
  CRC: Cardinal;
  SaveDialog: DBSaveDialog;
  Chipper : TDECCipherClass;

  function LoadCryptFile(FileName: string; _class: TGraphicClass): TGraphic;
  var
    Password: string;
  begin
    Result := nil;
    if ValidCryptGraphicFile(FileName) then
    begin
      Password := DBkernel.FindPasswordForCryptImageFile(FileName);
      if Password = '' then
        Password := GetImagePasswordFromUser(FileName);

      if Password <> '' then
        Result := DeCryptGraphicFile(FileName, Password)
      else
      begin
        MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        Exit;
      end;
    end else
    begin
      Result := _class.Create;
      Result.LoadFromFile(FileName);
    end;
  end;

begin
  Bitmap := nil;
  PNG := nil;
  try
    if GetExt(FileName) <> 'BMP' then
    begin
      try
        PNG := TPngImage(LoadCryptFile(FileName, TPngImage));
        try
          Bitmap := TBitmap.Create;
          Bitmap.Assign(PNG);
        finally
          F(PNG);
        end;
      finally
        F(PNG);
      end;
    end else
      Bitmap := TBitmap(LoadCryptFile(FileName, TBitmap));

    Info := TMemoryStream.Create;
    try
      Result := ExtractInfoFromBitmap(Info, Bitmap);
      Info.Seek(0, soFromBeginning);
      FillChar(Header, SizeOf(Header), 0);
      if (Info.Size > SizeOf(Header)) then
        Info.Read(Header, SizeOf(Header));

      if not Result or (Header.ID <> StenoHeaderId) then
      begin
        MessageBoxDB(Handle, L('The image does not contain hidden information, or this format is not supported!'), L('Warning'), TD_BUTTON_OK,
          TD_ICON_WARNING);
        Exit;
      end;

      if Header.Version = 1 then
      begin
        Password := GetImagePasswordFromUserStenoraphy(Header.FileName, Header.PassCRC);
        if Password = '' then
        begin
          Result := False;
          Exit;
        end;

        Data := TMemoryStream.Create;
        try
          if not Header.IsCrypted then
          begin
            Data.CopyFrom(Info, Header.FileSize);
          end else
          begin
            Chipper := CipherByIdentity(Header.Chiper);
            DeCryptStreamV2(Info, Data, Password, SeedToBinary(Header.Seed), Header.FileSize, Chipper);
          end;
          CalcBufferCRC32(TMemoryStream(Data).Memory, Data.Size, CRC);

          if CRC <> Header.DataCRC then
            MessageBoxDB(Handle, L('Information in the file is corrupted! Checksum did not match!'), L('Information'), TD_BUTTON_OK,
              TD_ICON_WARNING);

          SaveDialog := DBSaveDialog.Create;
          try
            SaveDialog.SetFileName(Header.FileName);
            if SaveDialog.Execute then
            begin
              Data.SaveToFile(SaveDialog.FileName);
              Result := True;
            end;
          finally
            F(SaveDialog);
          end;

        finally
          F(Data);
        end;

      end else
        MessageBoxDB(Handle, Format(L('The image contains hidden information, but this format is not supported (version = %d)!'), [Header.Version]), L('Warning'), TD_BUTTON_OK,
          TD_ICON_WARNING);
    finally
      F(Info);
    end;
  finally
    F(Bitmap);
  end;
end;

procedure TFrmSteganographyLanding.LoadLanguage;
begin
  inherited;
  LbStepInfo.Caption := L('This wizard helps to create images files with hidden information inside them. Please, choose nesessary option:');
  RbHideDataInImage.Caption := L('Hide information inside image');
  LbHideDataInImageInfo.Caption := L('Information will be stored in raster graphics, image will be modified!');
  RbHideDataInJPEGFile.Caption := L('Hide information inside JPEG file');
  LbHideDataInJPEGFileInfo.Caption := L('Information will be stored in file after JPEG image information');
  RbExtractDataFromImage.Caption := L('Extract hidden information from image file');
end;

procedure TFrmSteganographyLanding.RbHideDataInImageClick(Sender: TObject);
begin
  inherited;
  Changed;
end;

end.
