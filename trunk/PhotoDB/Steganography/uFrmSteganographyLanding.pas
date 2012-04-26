unit uFrmSteganographyLanding;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, uFrameWizardBase, pngimage, uStenography, UnitDBFileDialogs,
  GraphicCrypt,
  DECUtil,
  DECCipher,
  win32crc,
  UnitDBKernel,
  uShellIntegration,
  uConstants,
  uFileUtils,
  uMemory,
  uStrongCrypt,
  uAssociations,
  jpeg,
  uPortableDeviceUtils;

type
  TFrmSteganographyLanding = class(TFrameWizardBase)
    RbHideDataInImage: TRadioButton;
    LbHideDataInImageInfo: TLabel;
    RbHideDataInJPEGFile: TRadioButton;
    LbHideDataInJPEGFileInfo: TLabel;
    LbStepInfo: TLabel;
    RbExtractDataFromImage: TRadioButton;
    CbUseAnotherImage: TCheckBox;
    procedure RbHideDataInImageClick(Sender: TObject);
  private
    { Private declarations }
    FImageFileName: string;
    procedure SetImageFileName(const Value: string);
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
    property ImageFileName: string read FImageFileName write SetImageFileName;
  end;

implementation

{$R *.dfm}

uses
  UnitPasswordForm, UnitCryptImageForm, uFrmCreateJPEGSteno, uFrmCreatePNGSteno;

procedure TFrmSteganographyLanding.Execute;
var
  OpenPictureDialog: DBOpenPictureDialog;

  procedure LoadInfo;
  begin
    if LoadInfoFromFile(ImageFileName) then
    begin
      IsStepComplete := True;
      Changed;
    end;
  end;

begin
  inherited;

  if not CbUseAnotherImage.Checked and (ImageFileName <> '') then
  begin
    LoadInfo;
    Exit;
  end;

  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.GetFilter('.png|.jpg|.bmp', True, True);
    OpenPictureDialog.FilterIndex := 1;
    if OpenPictureDialog.Execute then
    begin
      ImageFileName := OpenPictureDialog.FileName;
      LoadInfo;
    end;
  finally
    F(OpenPictureDialog);
  end;
end;

procedure TFrmSteganographyLanding.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
end;

function TFrmSteganographyLanding.InitNextStep: Boolean;
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  Result := True;

  if CbUseAnotherImage.Checked then
    FImageFileName := '';

  if FImageFileName = '' then
  begin

    OpenPictureDialog := DBOpenPictureDialog.Create;
    try
      OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
      OpenPictureDialog.FilterIndex := 1;
      if OpenPictureDialog.Execute then
      begin
        CbUseAnotherImage.Checked := False;
        FImageFileName := OpenPictureDialog.FileName
      end else
        Result := False;

    finally
      F(OpenPictureDialog);
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
  Info: TMemoryStream;
  Header: StenographyHeader;
  Password: string;
  CRC: Cardinal;
  SaveDialog: DBSaveDialog;
  Chipper : TDECCipherClass;
  GraphicClass: TGraphicClass;
  J: TJPEGImage;
  MS, DevMS: TMemoryStream;
  FS: TFileStream;

  function LoadCryptFile(FileName: string; _class: TGraphicClass): TGraphic;
  var
    Password: string;
  begin
    Result := nil;
    if not IsDevicePath(FileName) and ValidCryptGraphicFile(FileName) then
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
      if not IsDevicePath(FileName) then
        Result.LoadFromFile(FileName)
      else
        Result.LoadFromDevice(FileName);
    end;
  end;

  procedure SaveData(Header: StenographyHeader; SourceStream: TStream);
  var
    Data: TMemoryStream;
  begin
    if Header.Version = 1 then
    begin
      if Header.IsCrypted then
      begin
        Password := GetImagePasswordFromUserStenoraphy(Header.FileName, Header.PassCRC);
        if Password = '' then
        begin
          Result := False;
          Exit;
        end;
      end;

      Data := TMemoryStream.Create;
      try
        if not Header.IsCrypted then
        begin
          Data.CopyFrom(SourceStream, Header.FileSize);
        end else
        begin
          Chipper := CipherByIdentity(Header.Chiper);
          DeCryptStreamV2(SourceStream, Data, Password, SeedToBinary(Header.Seed), Header.FileSize, Chipper);
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
  end;

  procedure ExtractJpegInfo(S: TStream);
  begin
    if not ExtractJPEGSteno(S, MS, Header) then
    begin
      MessageBoxDB(Handle, L('The image does not contain hidden information, or this format is not supported!'), L('Warning'), TD_BUTTON_OK,
        TD_ICON_WARNING);
      Exit;
    end;

    MS.Seek(0, soFromBeginning);
    SaveData(Header, MS);
  end;

begin
  StrongCryptInit;
  RbExtractDataFromImage.Checked := True;
  Result := False;

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));

  if (GraphicClass = TBitmap) or (GraphicClass = TPngImage) then
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

        SaveData(Header, Info);
      finally
        F(Info);
      end;
    finally
      F(Bitmap);
    end;
  end else if (GraphicClass = TJpegImage) then
  begin
    J := nil;
    try
      MS := TMemoryStream.Create;
      try;
        if not IsDevicePath(FileName) and ValidCryptGraphicFile(FileName) then
        begin
          Password := DBkernel.FindPasswordForCryptImageFile(FileName);
          if Password = '' then
            Password := GetImagePasswordFromUser(FileName);

          Info := TMemoryStream.Create;
          try
            if Password <> '' then
            begin
              if not DeCryptGraphicFileToStream(FileName, Password, Info) then
              begin
                MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
                Exit;
              end
            end else begin
              MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
              Exit;
            end;

            ExtractJpegInfo(Info);
          finally
            F(Info);
          end;

        end else
        begin
          if not IsDevicePath(FileName) then
          begin
            FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
            try
              ExtractJpegInfo(FS);
            finally
              F(FS);
            end;
          end else
          begin
            DevMS := TMemoryStream.Create;
            try
              ReadStreamFromDevice(FileName, DevMS);
              ExtractJpegInfo(DevMS);
            finally
              F(DevMS);
            end;
          end;
        end;
      finally
        F(MS);
      end;
    finally
      F(J);
    end;
  end else
    MessageBoxDB(Handle, L('The image does not contain hidden information, or this format is not supported!'), L('Warning'), TD_BUTTON_OK,
      TD_ICON_WARNING);
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
  CbUseAnotherImage.Caption := L('Use another image');
end;

procedure TFrmSteganographyLanding.RbHideDataInImageClick(Sender: TObject);
begin
  inherited;
  Changed;
end;

procedure TFrmSteganographyLanding.SetImageFileName(const Value: string);
var
  GC: TGraphicClass;
begin
  FImageFileName := Value;
  GC := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(ImageFileName));
  if GC = TJPEGImage then
    RbHideDataInJPEGFile.Checked := True;
end;

end.
