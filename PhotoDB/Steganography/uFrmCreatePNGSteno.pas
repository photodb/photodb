unit uFrmCreatePNGSteno;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, StdCtrls, WatermarkedEdit, ExtCtrls, ShlObj,
  uMemory, UnitDBFileDialogs, pngimage, uFileUtils, uConstants, uStenography,
  GraphicCrypt, dolphin_db, UnitDBKernel, uAssociations, uShellIntegration;

type
  TFrmCreatePNGSteno = class(TFrameWizardBase)
    LbImageSize: TLabel;
    LbJpegFileSize: TLabel;
    ImJpegFile: TImage;
    LbJpegFileInfo: TLabel;
    Gbptions: TGroupBox;
    LbPassword: TLabel;
    Label1: TLabel;
    CbEncryptdata: TCheckBox;
    EdPassword: TWatermarkedEdit;
    EdPasswordConfirm: TWatermarkedEdit;
    CbIncludeCRC: TCheckBox;
    LbSelectFile: TLabel;
    WatermarkedEdit1: TWatermarkedEdit;
    LbFileSize: TLabel;
    LbResultImageSize: TLabel;
    BtnChooseFile: TButton;
    CbFilter: TComboBox;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    procedure OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
      var Include: Boolean);
  private
    { Private declarations }
    MaxFileSize: Integer;
    NormalFileSize: Integer;
    GoodFileSize: Integer;
    FBitmapImage: TBitmap;
    function MaxDataFileSize: Cardinal;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsFinal: Boolean; override;
    procedure Execute; override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
  end;

implementation

uses
  UnitPasswordForm,
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

constructor TFrmCreatePNGSteno.Create(AOwner: TComponent);
begin
  inherited;
  FBitmapImage := nil;
end;

procedure TFrmCreatePNGSteno.Execute;
var
  Size: Integer;
  Bitmap : TBitmap;
  N : Integer;
  Options : TOpenOptions;
  S: string;
  DialogFileSize: Integer;
  PNG: TPngImage;
  Opt: TCryptImageOptions;
  SavePictureDialog: DBSavePictureDialog;
  FileName: string;
  InfoStream : TMemoryStream;
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
  begin
    FileName := OpenDialog1.FileName;
    Size := GetFileSizeByName(FileName);
    //Memo1.Text := FileName;
    //Label5.Caption := Format(L('File size = %s'), [SizeInText(Size)]);
    //S := ExtractFileName(PictureFileName);

    SavePictureDialog := DBSavePictureDialog.Create;
    try
      SavePictureDialog.Filter := L('PNG Images (*.png)|*.png|Bitmaps (*.bmp)|*.bmp');
      SavePictureDialog.FilterIndex := 1;
      //S := ExtractFilePath(PictureFileName) + GetFileNameWithoutExt(S) + '.png';

      SavePictureDialog.SetFileName(S);
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
        {Opt := GetPassForCryptImageFile(FileName);
        if Opt.Password = '' then
          MessageBoxDB(Handle, L('Information in the file will not be encrypted!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);

        InfoStream := TMemoryStream.Create;
        try
          SaveFileToCryptedStream(FileName, Opt.Password, InfoStream, False);
          N := GetMaxPixelsInSquare(FileName, ImPreview.Picture.Graphic);
          if N < 0 then
          begin
            MessageBoxDB(Handle, L('File is too large!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);
            Exit;
          end;
          Bitmap := TBitmap.Create;
          try
            if not SaveInfoToBmpFile(ImPreview.Picture.Graphic, Bitmap, InfoStream, N) then
              Exit;

            if SavePictureDialog.GetFilterIndex = 0 then
            begin
              Bitmap.SaveToFile(SavePictureDialog.FileName);
              if ImagePassword <> '' then
                CryptGraphicFileV2(SavePictureDialog.FileName, ImagePassword, CRYPT_OPTIONS_NORMAL);
              ImageSaved := True;
            end else
            begin
              PNG := TPngImage.Create;
              try
                PNG.Assign(Bitmap);
                PNG.SaveToFile(SavePictureDialog.FileName);
                if ImagePassword <> '' then
                  CryptGraphicFileV2(SavePictureDialog.FileName, ImagePassword, CRYPT_OPTIONS_NORMAL);
                ImageSaved := True;
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
        }
      end;
    finally
      F(SavePictureDialog);
    end;
  end;
end;

function TFrmCreatePNGSteno.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmCreatePNGSteno.OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
  var Include: Boolean);
var
  FileName: string;
  Sr: TStrRet;
  SHigh, SLow: Cardinal;
  IDL: PItemIDList;
begin
  Include := True; // На всяк пожарный
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
    Include := False; // На всяк пожарный
    try
      // IDL^.mkid.cb:=0; //приводит к утечкам
      IDL^.Mkid.AbID[0] := 0;
    except // На всяк пожарный - а то вдруг и вправду привелегий не будет
    end;
  end;
end;

procedure TFrmCreatePNGSteno.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
var
  B: TBitmap;
  Password,
  FileName: string;
  Graphic: TGraphic;
  GraphicClass: TGraphicClass;
begin
  inherited;

  F(FBitmapImage);
  FBitmapImage := TBitmap.Create;
  FileName := TFrmSteganographyLanding(Manager.GetStepByType(TFrmSteganographyLanding)).ImageFileName;

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
  if GraphicClass = nil then
    Exit;

  Graphic := nil;
  try
    if ValidCryptGraphicFile(FileName) then
    begin
      Password := DBkernel.FindPasswordForCryptImageFile(FileName);
      if Password = '' then
        Password := GetImagePasswordFromUser(FileName);

      if Password <> '' then
      begin
        Graphic := DeCryptGraphicFile(FileName, Password);
      end else
      begin
        MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        Exit;
      end;
    end else
    begin
      Graphic := GraphicClass.Create;
      Graphic.LoadFromFile(FileName);
    end;

    B.Assign(Graphic);

  finally
    F(Graphic);
  end;
end;

procedure TFrmCreatePNGSteno.Unload;
begin
  inherited;
  F(FBitmapImage);
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
