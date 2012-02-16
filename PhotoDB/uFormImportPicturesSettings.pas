unit uFormImportPicturesSettings;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  uVCLHelpers,
  uDBForm,
  uSettings;

type
  TFormImportPicturesSettings = class(TDBForm)
    LbDirectoryFormat: TLabel;
    CbFormatCombo: TComboBox;
    CbOnlyImages: TCheckBox;
    CbDeleteAfterImport: TCheckBox;
    CbAddToCollection: TCheckBox;
    BtnOk: TButton;
    BtnCancel: TButton;
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure ReadOptions;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFormImportPicturesSettings.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormImportPicturesSettings.BtnOkClick(Sender: TObject);
begin
  Settings.WriteString('ImportPictures', 'Pattern', CbFormatCombo.Value);
  Settings.WriteBool('ImportPictures', 'OnlyImages', CbOnlyImages.Checked);
  Settings.WriteBool('ImportPictures', 'DeleteFiles', CbDeleteAfterImport.Checked);
  Settings.WriteBool('ImportPictures', 'AddToCollection', CbAddToCollection.Checked);
  Close;
end;

procedure TFormImportPicturesSettings.FormCreate(Sender: TObject);
begin
  ReadOptions;
  LoadLanguage;
end;

function TFormImportPicturesSettings.GetFormID: string;
begin
  Result := 'ImportPictures';
end;

procedure TFormImportPicturesSettings.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import settings');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    LbDirectoryFormat.Caption := L('Directory format') + ':';
    CbOnlyImages.Caption := L('Import only supported images');
    CbDeleteAfterImport.Caption := L('Delete files after import');
    CbAddToCollection.Caption := L('Add files to collection after copying files');
  finally
    EndTranslate;
  end;
end;

procedure TFormImportPicturesSettings.ReadOptions;
begin
  CbFormatCombo.Value := Settings.ReadString('ImportPictures', 'Pattern', '');
  CbOnlyImages.Checked := Settings.ReadBool('ImportPictures', 'OnlyImages', False);
  CbDeleteAfterImport.Checked := Settings.ReadBool('ImportPictures', 'DeleteFiles', True);
  CbAddToCollection.Checked := Settings.ReadBool('ImportPictures', 'AddToCollection', True);
end;

end.
