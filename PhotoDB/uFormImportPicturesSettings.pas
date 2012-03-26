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
  uConstants,
  uSettings,
  uMemoryEx,
  WebLink, uBaseWinControl;

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
  Settings.WriteString('ImportPictures', 'Pattern', CbFormatCombo.Value);
  Settings.WriteBool('ImportPictures', 'OnlyImages', CbOnlyImages.Checked);
  Settings.WriteBool('ImportPictures', 'DeleteFiles', CbDeleteAfterImport.Checked);
  Settings.WriteBool('ImportPictures', 'AddToCollection', CbAddToCollection.Checked);
  Settings.WriteBool('ImportPictures', 'OpenDestination', CbOpenDestination.Checked);
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
  CbOnlyImages.Checked := Settings.ReadBool('ImportPictures', 'OnlyImages', False);
  CbDeleteAfterImport.Checked := Settings.ReadBool('ImportPictures', 'DeleteFiles', True);
  CbAddToCollection.Checked := Settings.ReadBool('ImportPictures', 'AddToCollection', True);
  CbOpenDestination.Checked := Settings.ReadBool('ImportPictures', 'OpenDestination', True);
end;

procedure TFormImportPicturesSettings.ReadPatternList;
begin
  CbFormatCombo.Items.Text := Settings.ReadString('ImportPictures', 'PatternList', DefaultImportPatternList);
  if CbFormatCombo.Items.Count > 0 then
    CbFormatCombo.ItemIndex := 0;
  CbFormatCombo.Value := Settings.ReadString('ImportPictures', 'Pattern', DefaultImportPattern);
end;

end.
