unit uFrmSelectDBNewPathAndIcon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, StdCtrls, ExtCtrls, uMemory, UnitDBDeclare,
  uShellIntegration, UnitDBCommonGraphics, uConstants, UnitDBFileDialogs,
  uFileUtils, WatermarkedEdit;

type
  TFrmSelectDBNewPathAndIcon = class(TFrameWizardBase)
    GroupBox1: TGroupBox;
    ImageIconPreview: TImage;
    LbIconPreview: TLabel;
    LbNewDBFile: TLabel;
    LbNewDBName: TLabel;
    LbDBDescription: TLabel;
    BtnChooseIcon: TButton;
    EdPath: TWatermarkedEdit;
    EdName: TWatermarkedEdit;
    BtnSelectFile: TButton;
    EdDBDescription: TWatermarkedEdit;
    CbSetAsDefaultDB: TCheckBox;
    CbAddDefaultGroups: TCheckBox;
    procedure BtnChooseIconClick(Sender: TObject);
    procedure BtnSelectFileClick(Sender: TObject);
    procedure EdNameChange(Sender: TObject);
    procedure EdPathChange(Sender: TObject);
  private
    { Private declarations }
    function GetDBFile: TPhotoDBFile;
    procedure SetIcon(Path: string);
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    function ValidateStep(Silent: Boolean): Boolean; override;
    function InitNextStep: Boolean; override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    property DBFile: TPhotoDBFile read GetDBFile;
  end;

implementation

uses
  UnitSelectDB,
  uFrmConvertationSettings;

{$R *.dfm}

{ TFrmSelectDBNewPathAndIcon }

procedure TFrmSelectDBNewPathAndIcon.BtnSelectFileClick(Sender: TObject);
var
  FA: Integer;
  FileName: string;
  SaveDialog: DBSaveDialog;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');

    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;

      if GetExt(FileName) <> 'PHOTODB' then
        FileName := FileName + '.photodb';

      FA := FileGetAttr(FileName);
      if FileExistsSafe(FileName) and ((FA and SysUtils.faReadOnly) <> 0) then
      begin
        MessageBoxDB(Handle, TFormSelectDB(Manager.Owner).LReadOnly, L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
        Exit;
      end;
      EdPath.Text := FileName;
    end;

  finally
    F(SaveDialog);
  end;
end;

procedure TFrmSelectDBNewPathAndIcon.EdNameChange(Sender: TObject);
begin
  Changed;
end;

procedure TFrmSelectDBNewPathAndIcon.EdPathChange(Sender: TObject);
begin
  Changed;
end;

procedure TFrmSelectDBNewPathAndIcon.BtnChooseIconClick(Sender: TObject);
var
  IcoName: string;
begin
  IcoName := DBFile.Icon;
  if ChangeIconDialog(Handle, IcoName) then
  begin
    DBFile.Icon := IcoName;
    SetIcon(IcoName);
  end;
end;

procedure TFrmSelectDBNewPathAndIcon.SetIcon(Path: string);
var
  Ico: TIcon;
begin
  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(Path);
    ImageIconPreview.Picture.Graphic := Ico;
  finally
    F(Ico);
  end;
end;

function TFrmSelectDBNewPathAndIcon.GetDBFile: TPhotoDBFile;
begin
  Result := TFormSelectDB(Manager.Owner).DBFile;
end;

procedure TFrmSelectDBNewPathAndIcon.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    DBFile.Icon := Application.ExeName + ',0';
    SetIcon(DBFile.Icon);
  end;
end;

function TFrmSelectDBNewPathAndIcon.InitNextStep: Boolean;
begin
  Result := inherited;
  Manager.AddStep(TFrmConvertationSettings);
end;

procedure TFrmSelectDBNewPathAndIcon.LoadLanguage;
begin
  inherited;
  GroupBox1.Caption := L('File name and location');
  LbNewDBName.Caption := L('Select name for new collection') + ':';
  LbNewDBFile.Caption := L('Choose file for new collection') + ':';
  BtnSelectFile.Caption := L('Select file');
  LbIconPreview.Caption := L('Icon preview') + ':';
  BtnChooseIcon.Caption := L('Choose an icon');
  EdName.WatermarkText := L('New collection');
  EdPath.WatermarkText := L('No file');
  CbSetAsDefaultDB.Caption := L('Use as default collection');
  LbDBDescription.Caption := L('Display name');
  EdDBDescription.WatermarkText := L('Short DB description');
  CbAddDefaultGroups.Caption := L('Add standard groups');
end;

function TFrmSelectDBNewPathAndIcon.ValidateStep(Silent: Boolean): Boolean;
begin
  if EdPath.Text <> '' then
  begin
    DBFile.FileName := EdPath.Text;
    DBFile.Name := EdName.Text;
  end else
  begin
    if not Silent then
    begin
      MessageBoxDB(Handle, L(
          'File isn''t selected! Please, select an file and try again.'),
        L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
      BtnSelectFileClick(Self);
    end;
  end;
  Result := (EdPath.Text <> '') and (EdName.Text <> '');
  if EdName.Text = '' then
    EdName.SetFocus;

end;

end.
