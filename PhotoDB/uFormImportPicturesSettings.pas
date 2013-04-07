unit uFormImportPicturesSettings;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  uVCLHelpers,
  uDBForm,
  uConstants,
  uSettings,
  uMemoryEx;

type
  TFormImportPicturesSettings = class(TDBForm)
    LbDirectoryFormat: TLabel;
    CbFormatCombo: TComboBox;
    CbOnlyImages: TCheckBox;
    CbDeleteAfterImport: TCheckBox;
    CbAddToCollection: TCheckBox;
    BtnOk: TButton;
    BtnCancel: TButton;
    WlFilter: TWebLink;
    BtnChangePatterns: TButton;
    CbOpenDestination: TCheckBox;
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnChangePatternsClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure ReadOptions;
    procedure ReadPatternList;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

implementation

uses
  uPicturesImportPatternEdit;

{$R *.dfm}

procedure TFormImportPicturesSettings.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormImportPicturesSettings.BtnChangePatternsClick(Sender: TObject);
var
  PicturesImportPatternEdit: TPicturesImportPatternEdit;
begin
  PicturesImportPatternEdit := TPicturesImportPatternEdit.Create(Self);
  try
    PicturesImportPatternEdit.ShowModal;
    if PicturesImportPatternEdit.ModalResult = mrOk then
      ReadPatternList;
  finally
    R(PicturesImportPatternEdit);
  end;
end;

procedure TFormImportPicturesSettings.BtnOkClick(Sender: TObject);
begin
  AppSettings.WriteString('ImportPictures', 'Pattern', CbFormatCombo.Value);
  AppSettings.WriteBool('ImportPictures', 'OnlyImages', CbOnlyImages.Checked);
  AppSettings.WriteBool('ImportPictures', 'DeleteFiles', CbDeleteAfterImport.Checked);
  AppSettings.WriteBool('ImportPictures', 'AddToCollection', CbAddToCollection.Checked);
  AppSettings.WriteBool('ImportPictures', 'OpenDestination', CbOpenDestination.Checked);
  Close;
  ModalResult := mrOk;
end;

procedure TFormImportPicturesSettings.FormCreate(Sender: TObject);
begin
  ReadOptions;
  LoadLanguage;
  ModalResult := mrCancel;
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
    CbOnlyImages.AdjustWidth;
    WlFilter.Left := CbOnlyImages.Left + CbOnlyImages.Width + 10;
    WlFilter.Top := CbOnlyImages.Top + CbOnlyImages.Height div 2 - WlFilter.Height div 2;
    CbOpenDestination.Caption := L('Open destination directory after import');
  finally
    EndTranslate;
  end;
end;

procedure TFormImportPicturesSettings.ReadOptions;
begin
  ReadPatternList;
  CbOnlyImages.Checked := AppSettings.ReadBool('ImportPictures', 'OnlyImages', False);
  CbDeleteAfterImport.Checked := AppSettings.ReadBool('ImportPictures', 'DeleteFiles', True);
  CbAddToCollection.Checked := AppSettings.ReadBool('ImportPictures', 'AddToCollection', True);
  CbOpenDestination.Checked := AppSettings.ReadBool('ImportPictures', 'OpenDestination', True);
end;

procedure TFormImportPicturesSettings.ReadPatternList;
begin
  CbFormatCombo.Items.Text := AppSettings.ReadString('ImportPictures', 'PatternList', DefaultImportPatternList);
  if CbFormatCombo.Items.Count > 0 then
    CbFormatCombo.ItemIndex := 0;
  CbFormatCombo.Value := AppSettings.ReadString('ImportPictures', 'Pattern', DefaultImportPattern);
end;

end.
