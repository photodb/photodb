unit uFrmImportImagesOptions;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,


  Dmitry.Controls.WatermarkedEdit,




  uFrameWizardBase,
  uSettings;

type
  TFrmImportImagesOptions = class(TFrameWizardBase)
    LbStepInfo: TLabel;
    CbDontAddSmallImages: TCheckBox;
    EdMinWidth: TEdit;
    Label3: TLabel;
    EdMinHeight: TEdit;
    Label5: TLabel;
    Label9: TLabel;
    CbDefaultAction: TComboBox;
    procedure CbDontAddSmallImagesClick(Sender: TObject);
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    function InitNextStep: Boolean; override;
    function DefaultActionIndex: Integer;
  end;

implementation

{$R *.dfm}

{ TFrmImportImagesOptions }

procedure TFrmImportImagesOptions.CbDontAddSmallImagesClick(Sender: TObject);
begin
  inherited;
  EdMinWidth.Enabled := CbDontAddSmallImages.Checked;
  EdMinHeight.Enabled := CbDontAddSmallImages.Checked;
end;

function TFrmImportImagesOptions.DefaultActionIndex: Integer;
begin
  Result := CbDefaultAction.ItemIndex;
end;

function TFrmImportImagesOptions.InitNextStep: Boolean;
begin
  Result := inherited;
  Settings.WriteBool('Options', 'DontAddSmallImages', CbDontAddSmallImages.Checked);
  Settings.WriteString('Options', 'DontAddSmallImagesWidth', EdMinWidth.Text);
  Settings.WriteString('Options', 'DontAddSmallImagesHeight', EdMinHeight.Text);
end;

procedure TFrmImportImagesOptions.LoadLanguage;
begin
  inherited;
  CbDontAddSmallImages.Caption := L('Do not add files to collection if size less than') + ':';
  Label3.Caption := L('Width');
  Label5.Caption := L('Height');
  LbStepInfo.Caption := L('Please, select additional options of import');
  CbDefaultAction.Clear;
  CbDefaultAction.Items.Add(L('Ask me'));
  CbDefaultAction.Items.Add(L('Add all'));
  CbDefaultAction.Items.Add(L('Skip all'));
  CbDefaultAction.Items.Add(L('Replace all'));
  CbDefaultAction.ItemIndex := 1;
  Label9.Caption := L('If duplicates are found') + ':';
end;

end.
