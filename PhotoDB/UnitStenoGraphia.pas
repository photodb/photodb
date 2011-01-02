unit UnitStenoGraphia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ExtDlgs, ExtCtrls, SaveInfoToImage, ShlObj, UnitDBKernel,
  Math, ImageConverting, PngImage, GraphicEx, uVistaFuncs,
  GraphicCrypt, UnitDBFileDialogs, UnitCDMappingSupport, uFileUtils, uMemory,
  uShellIntegration, uDBForm, Dolphin_DB;

type
  TFormSteno = class(TDBForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    ImPreview: TImage;
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    LoadFromFile1: TMenuItem;
    AddInfo1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label6: TLabel;
    ComboBox1: TComboBox;
    Label7: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
      var Include: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    function LoadInfoFromFile(FileName: String) : boolean;
    procedure LoadImage(FileName: String; CloseIfOk : boolean = false);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    PictureFileName, FileName: string;
    ImagePassword: string;
    MaxFileSize: Integer;
    NormalFileSize: Integer;
    GoodFileSize: Integer;
    function GetMaxFileSize: Cardinal;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    ImageSaved: Boolean;
  end;

procedure DoDesteno(InitialFileName: string);
procedure DoSteno(InitialFileName: string);

implementation

uses
  UnitPasswordForm, UnitCryptImageForm;

{$R *.dfm}

procedure DoDesteno(InitialFileName : string);
var
  FormSteno: TFormSteno;
begin
  Application.CreateForm(TFormSteno, FormSteno);
  try
    FormSteno.LoadInfoFromFile(ProcessPath(InitialFileName));
  finally
    FormSteno.Release;
  end;
end;

procedure DoSteno(InitialFileName : string);
var
  FormSteno: TFormSteno;
begin
  Application.CreateForm(TFormSteno, FormSteno);
  try
    FormSteno.LoadImage(ProcessPath(InitialFileName), True);
    if not FormSteno.ImageSaved then
      FormSteno.ShowModal;
  finally
    R(FormSteno);
  end;
end;

procedure TFormSteno.Button3Click(Sender: TObject);
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try

    OpenPictureDialog.Filter := L('PNG Images (*.png)|*.png|Bitmaps (*.bmp)|*.bmp');
    OpenPictureDialog.FilterIndex := 1;

    if OpenPictureDialog.Execute then
      LoadInfoFromFile(OpenPictureDialog.FileName);

  finally
    F(OpenPictureDialog);
  end;
end;

function TFormSteno.LoadInfoFromFile(FileName: String) : Boolean;
var
  Bitmap: TBitmap;
  PNG: TPngImage;
  Info: TArByte;
  Header: InfoHeader;
  Password: string;
  CRC: Cardinal;
  SaveDialog: DBSaveDialog;

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
  Result := False;
  Bitmap := nil;
  PNG := nil;
  try
    if GetExt(FileName) <> 'BMP' then
    begin
      try
        PNG := TPngImage(LoadCryptFile(FileName, TPngImage));
        Bitmap := TBitmap.Create;
        Bitmap.Assign(PNG);
      finally
        F(PNG);
      end;
    end else
    begin
      Bitmap := TBitmap(LoadCryptFile(FileName, TBitmap));
    end;
    SetLength(Info, 0);
    LoadInfoFromBitmap(Info, Bitmap);
    if Length(Info) = 0 then
    begin
      MessageBoxDB(Handle, L('The image does not contain hidden information, or this format is not supported!'), L('Warning'), TD_BUTTON_OK,
        TD_ICON_WARNING);
      Exit;
    end;
    Header := GetHeaderFromInfo(Info);
    if Header.OK then
      if Header.Crypted then
      begin
        Password := GetImagePasswordFromUserStenoraphy(Header.FileName, Header.CRC);
        if Password = '' then
        begin
          Result := False;
          SetLength(Info, 0);
          Exit;
        end;
        DeCryptArray(Info, Password);
      end;
    if not Header.OK then
    begin
      Result := False;
      SetLength(Info, 0);
      MessageBoxDB(Handle, L('The image does not contain hidden information, or this format is not supported!'), L('Warning'), TD_BUTTON_OK,
        TD_ICON_WARNING);
      Exit;
    end;
    CRC := InfoCRC(Info);
    if CRC <> Header.DataCRC then
      MessageBoxDB(Handle, L('Information in the file is corrupted! Checksum did not match!'), L('Information'), TD_BUTTON_OK,
        TD_ICON_WARNING);

    SaveDialog := DBSaveDialog.Create;
    try
      SaveDialog.SetFileName(Header.FileName);
      if SaveDialog.Execute then
      begin
        SaveInfoToImage.SaveInfoToFile(Info, SaveDialog.FileName);
        Result := True;
      end;
    finally
      F(SaveDialog);
    end;
  finally
    SetLength(Info, 0);
    F(Bitmap);
  end;
end;

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

procedure TFormSteno.OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
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
  if (FileExists(FileName, SHigh, SLow) = 0) and ((SHigh > 0) or (SLow > GetMaxFileSize)) then
  begin
    Include := False; // На всяк пожарный
    try
      // IDL^.mkid.cb:=0; //приводит к утечкам
      IDL^.Mkid.AbID[0] := 0;
    except // На всяк пожарный - а то вдруг и вправду привелегий не будет
    end;
  end;
end;

procedure TFormSteno.Button2Click(Sender: TObject);
var
  Size: Integer;
  Info: TArByte;
  Bitmap : TBitmap;
  N : Integer;
  Options : TOpenOptions;
  S: string;
  DialogFileSize: Integer;
  PNG: TPngImage;
  Opt: TCryptImageOptions;
  SavePictureDialog: DBSavePictureDialog;
  FileName: string;
begin
  if ImPreview.Picture.Graphic = nil then
  begin
    Button1Click(Sender);
    if ImPreview.Picture.Graphic = nil then
      Exit;
  end;
  DialogFileSize := GetMaxFileSize;
  if MaxFileSize < 0 then
    Exit;
  Options := OpenDialog1.Options;
  Include(Options, OfEnableIncludeNotify);
  Exclude(Options, OfOldStyleDialog);
  OpenDialog1.Options := Options;
  OpenDialog1.Filter := Format(L('All files (Size < %s)|*?*'), [SizeInText(DialogFileSize)]);
  OpenDialog1.OnIncludeItem := OpenDialog1IncludeItem;
  if OpenDialog1.Execute then
  begin
    FileName := OpenDialog1.FileName;
    Size := GetFileSizeByName(FileName);
    Memo1.Text := FileName;
    Label5.Caption := Format(L('File size = %s'), [SizeInText(Size)]);
    S := ExtractFileName(PictureFileName);

    SavePictureDialog := DBSavePictureDialog.Create;
    try
      SavePictureDialog.Filter := 'PNG Images (*.png)|*.png|Bitmaps (*.bmp)|*.bmp';
      SavePictureDialog.FilterIndex := 1;
      S := ExtractFilePath(PictureFileName) + GetFileNameWithoutExt(S) + '.png';

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
        Opt := GetPassForCryptImageFile(FileName);
        if Opt.Password = '' then
          MessageBoxDB(Handle, L('Information in the file will not be encrypted!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);

        Info := SaveFileToInfo(FileName, Opt.Password);
        N := GetMaxPixelsInSquare(FileName, ImPreview.Picture.Graphic);
        if N < 0 then
        begin
          MessageBoxDB(Handle, L('File is too large!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);
          Exit;
        end;
        Bitmap := SaveInfoToBmpFile(ImPreview.Picture.Graphic, Info, N);
        if Bitmap = nil then
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
        F(Bitmap);
      end;
    finally
      F(SavePictureDialog);
    end;
  end;
end;

procedure TFormSteno.Button1Click(Sender: TObject);
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := GetGraphicFilter;
    OpenPictureDialog.FilterIndex := 1;

    if OpenPictureDialog.Execute then
      LoadImage(OpenPictureDialog.FileName);

  finally
    F(OpenPictureDialog);
  end;
end;

procedure TFormSteno.LoadImage(FileName: string; CloseIfOk: Boolean = False);
var
  Password : string;
  Graphic : TGraphic;
begin

 if ValidCryptGraphicFile(FileName) then
  begin
    Password := DBkernel.FindPasswordForCryptImageFile(FileName);
    if Password = '' then
      Password := GetImagePasswordFromUser(FileName);

    if Password <> '' then
    begin
      Graphic := DeCryptGraphicFile(FileName, Password);
      try
        ImPreview.Picture.Graphic := Graphic;
      finally
        F(Graphic);
      end;
      ImagePassword := Password;
    end else
    begin
      MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      Exit;
    end;
  end else
  begin
    ImPreview.Picture.LoadFromFile(FileName);
  end;

  MaxFileSize := MaxSizeInfoInGraphic(ImPreview.Picture.Graphic, 2) - 255;
  NormalFileSize := MaxSizeInfoInGraphic(ImPreview.Picture.Graphic, 5) - 255;
  GoodFileSize := MaxSizeInfoInGraphic(ImPreview.Picture.Graphic, 8) - 255;
  PictureFileName := FileName;

  Label1.Caption := Format(L('Max size = %s'),
    [SizeInText(Max(0, MaxSizeInfoInGraphic(ImPreview.Picture.Graphic, 2) - 255))]);
  Label2.Caption := Format(L('File name = "%s"'), [ExtractFileName(FileName)]);
  Label3.Caption := Format(L('Normal size = %s'),
    [SizeInText(Max(0, MaxSizeInfoInGraphic(ImPreview.Picture.Graphic, 5) - 255))]);
  Label7.Caption := Format(L('Best size = %s'),
    [SizeInText(Max(0, MaxSizeInfoInGraphic(ImPreview.Picture.Graphic, 8) - 255))]);
  if MaxFileSize > 0 then
    Button2Click(Self);
end;

procedure TFormSteno.FormCreate(Sender: TObject);
begin
  ImagePassword := '';
  ImageSaved := False;
  PictureFileName := '';
  FileName := '';
  MaxFileSize := 0;
  NormalFileSize := 0;
  LoadLanguage;
end;

procedure TFormSteno.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Data hiding');
    Label1.Caption:=Format(L('Max size = %s'), [SizeInText(0)]);
    Label2.Caption := Format(L('File name = "%s"'), ['']);
    Label3.Caption := Format(L('Normal size = %s'), [SizeInText(0)]);
    Label7.Caption := Format(L('Best size = %s'), [SizeInText(0)]);
    Label4.Caption := L('File to hide') + ':';
    Label5.Caption := Format(L('File size = %s'), [SizeInText(0)]);
    Label6.Caption := L('Use a filter when selecting a file') + ':';
    ComboBox1.Items[0] := L('Max size (worse quality, big noise)');
    ComboBox1.Items[1] := L('Standard size (almost imperceptibly)');
    ComboBox1.Items[2] := L('Best size (imperceptibly)');
    Button1.Caption := L('Open image');
    Button2.Caption := L('Hide file and save image');
    Button3.Caption := L('Extract file');
    LoadFromFile1.Caption := L('Open image');
    AddInfo1.Caption := L('Hide file and save image');
    ComboBox1.ItemIndex := 1;
  finally
    EndTranslate;
  end;
end;

function TFormSteno.GetFormID: string;
begin
  Result := 'Steganography';
end;

function TFormSteno.GetMaxFileSize: Cardinal;
begin
  case ComboBox1.ItemIndex of
    0:
      Result := MaxFileSize;
    1:
      Result := NormalFileSize;
  else
    Result := GoodFileSize;
  end;
end;

end.
