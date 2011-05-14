unit UnitStenoGraphia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ExtDlgs, ExtCtrls, uStenography, ShlObj, UnitDBKernel,
  Math, PngImage, GraphicEx, uConstants, uAssociations, uMemoryEx,
  GraphicCrypt, UnitDBFileDialogs, uCDMappingTypes, uFileUtils, uMemory,
  uShellIntegration, uDBForm, uStrongCrypt, DECUtil, DECCipher, win32crc,
  Dolphin_DB;

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
    BtnOpenImage: TButton;
    BtnAddInfo: TButton;
    BtnExtractData: TButton;
    Label6: TLabel;
    ComboBox1: TComboBox;
    Label7: TLabel;
    procedure BtnOpenImageClick(Sender: TObject);
    procedure LoadImage(FileName: String; CloseIfOk : Boolean = False);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    PictureFileName, FileName: string;
    ImagePassword: string;
    MaxFileSize: Integer;
    NormalFileSize: Integer;
    GoodFileSize: Integer;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    ImageSaved: Boolean;
  end;

implementation

uses
  UnitPasswordForm, UnitCryptImageForm;

{$R *.dfm}


procedure TFormSteno.BtnOpenImageClick(Sender: TObject);
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
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
//  if MaxFileSize > 0 then
//    BtnExtractDataClick(Self);
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
    BtnOpenImage.Caption := L('Open image');
    BtnAddInfo.Caption := L('Hide file and save image');
    BtnExtractData.Caption := L('Extract file');
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

end.
