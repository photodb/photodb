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

  Dmitry.Utils.Files,
  Dmitry.Controls.WatermarkedEdit,

  UnitDBFileDialogs,
  UnitDBKernel,

  uFrameWizardBase,
  uShellIntegration,
  uConstants,
  uMemory,
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
    RbUpdateCurrentDB: TRadioButton;
    RbNewCollection: TRadioButton;
    Label7: TLabel;
    EdDBPath: TWatermarkedEdit;
    BtnChooseNewDBFile: TButton;
    procedure CbDontAddSmallImagesClick(Sender: TObject);
    procedure RbNewCollectionClick(Sender: TObject);
    procedure BtnChooseNewDBFileClick(Sender: TObject);
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
  RbUpdateCurrentDB.Caption := L('Current collection');
  RbNewCollection.Caption := L('Create new collection');
  Label7.Caption := L('File with collection') + ':';
  LbStepInfo.Caption := L('Please, select additional options of import');
  CbDefaultAction.Clear;
  CbDefaultAction.Items.Add(L('Ask me'));
  CbDefaultAction.Items.Add(L('Add all'));
  CbDefaultAction.Items.Add(L('Skip all'));
  CbDefaultAction.Items.Add(L('Replace all'));
  CbDefaultAction.ItemIndex := 1;
  Label9.Caption := L('If duplicates are found') + ':';
  EdDBPath.WatermarkText := L('New collection path');
end;

procedure TFrmImportImagesOptions.RbNewCollectionClick(Sender: TObject);
begin
  inherited;
  EdDBPath.Enabled := RbNewCollection.Checked;
  BtnChooseNewDBFile.Enabled := RbNewCollection.Checked;
end;

procedure TFrmImportImagesOptions.BtnChooseNewDBFileClick(Sender: TObject);
var
  SaveDialog: DBSaveDialog;
  FileName: string;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');
    SaveDialog.FilterIndex := 0;

    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;

      if SaveDialog.GetFilterIndex = 2 then
        if GetExt(FileName) <> 'DB' then
          FileName := FileName + '.db';
      if SaveDialog.GetFilterIndex = 1 then
        if GetExt(FileName) <> 'PHOTODB' then
          FileName := FileName + '.photodb';

      if FileExistsSafe(FileName) and (ID_OK <> MessageBoxDB(Handle,
          Format(L('File "%s" already exists! $nl$Replace?'), [FileName]), L('Warning'),
          TD_BUTTON_OKCANCEL, TD_ICON_WARNING)) then
        Exit;
      begin
        DBKernel.CreateDBbyName(FileName);
        if DBKernel.TestDB(FileName) then
          EdDBPath.Text := FileName;
      end;
    end;
  finally
    F(SaveDialog);
  end;
end;

end.
