unit uFrmSelectDBExistedFile;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  uRuntime,
  WebLink,
  StdCtrls,
  ExtCtrls,
  uFrameWizardBase,
  UnitDBKernel,
  uShellIntegration,
  UnitDBCommonGraphics,
  uMemory,
  UnitDBDeclare,
  uIconUtils,
  UnitDBFileDialogs,
  uFileUtils,
  uConstants,
  WatermarkedEdit,
  uBaseWinControl;

type
  TFrmSelectDBExistedFile = class(TFrameWizardBase)
    GroupBox3: TGroupBox;
    LbName: TLabel;
    LbDBType: TLabel;
    LbIconPreview: TLabel;
    ImageIconPreview: TImage;
    LbDisplayName: TLabel;
    EdFileName: TWatermarkedEdit;
    EdDBType: TWatermarkedEdit;
    BtnChooseIcon: TButton;
    BtnChangeDBOptions: TButton;
    BtnSelectFile: TButton;
    WlDBOptions: TWebLink;
    EdInternalName: TWatermarkedEdit;
    procedure SetIconImage(Icon: string);
    procedure BtnChooseIconClick(Sender: TObject);
    procedure BtnSelectFileClick(Sender: TObject);
    procedure EdInternalNameChange(Sender: TObject);
    procedure BtnChangeDBOptionsClick(Sender: TObject);
    procedure WlDBOptionsClick(Sender: TObject);
  private
    function GetDBFile: TPhotoDBFile;
    { Private declarations }
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    function IsFinal: Boolean; override;
    property DBFile: TPhotoDBFile read GetDBFile;
    function ValidateStep(Silent: Boolean): Boolean; override;
    procedure Execute; override;
  end;

implementation

uses
  UnitSelectDB, UnitConvertDBForm, UnitDBOptions;

{$R *.dfm}

{ TFrmSelectDBExistedFile }

function TFrmSelectDBExistedFile.GetDBFile: TPhotoDBFile;
begin
  Result := TFormSelectDB(Manager.Owner).DBFile;
end;

procedure TFrmSelectDBExistedFile.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    DBFile.Icon := Application.ExeName + ',0';
    SetIconImage(DBFile.Icon);
  end;
end;

procedure TFrmSelectDBExistedFile.EdInternalNameChange(Sender: TObject);
begin
  DBFile.Name := EdInternalName.Text;
end;

procedure TFrmSelectDBExistedFile.Execute;
begin
  inherited;
  DBKernel.AddDB(DBFile.Name, DBFile.FileName, DBFile.Icon);
  IsStepComplete := True;
  Changed;
end;

function TFrmSelectDBExistedFile.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmSelectDBExistedFile.LoadLanguage;
begin
  inherited;
  GroupBox3.Caption := L('Select an file');
  LbName.Caption := L('File name') + ':';
  LbDBType.Caption := L('Collection type') + ':';
  LbIconPreview.Caption := L('Icon preview') + ':';
  BtnChooseIcon.Caption := L('Choose icon');
  BtnChangeDBOptions.Caption := L('Change Collection Settings');
  BtnSelectFile.Caption := L('Select file');
  BtnChooseIcon.Caption := L('Choose an icon');
  LbDisplayName.Caption := L('Display name');
  EdFileName.WatermarkText := L('No file');
  EdDBType.WatermarkText := L('No file');
  EdInternalName.WatermarkText := L('Short collection description');
  EdInternalName.Text := DBKernel.NewDBName(L('New collection'));
  WlDBOptions.Text := L('Change the size and quality of previews');
end;

procedure TFrmSelectDBExistedFile.BtnChangeDBOptionsClick(Sender: TObject);
begin
  if DBKernel.ValidDBVersion(DBFile.FileName,
    DBKernel.TestDBEx(DBFile.FileName)) then
    ChangeDBOptions('', DBFile.FileName)
  else
  begin
    MessageBoxDB(Handle, L('Please select any collection at first!'), L('Warning'),
      TD_BUTTON_OK, TD_ICON_WARNING);
  end;
end;

procedure TFrmSelectDBExistedFile.BtnChooseIconClick(Sender: TObject);
var
  IcoName: string;
begin
  IcoName := DBFile.Icon;
  if ChangeIconDialog(Handle, IcoName) then
  begin
    DBFile.Icon := IcoName;
    SetIconImage(IcoName);
  end;
end;

procedure TFrmSelectDBExistedFile.SetIconImage(Icon: string);
var
  Ico: TIcon;
begin
  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(Icon);
    ImageIconPreview.Picture.Graphic := Ico;
  finally
    F(Ico);
  end;
end;

function TFrmSelectDBExistedFile.ValidateStep(Silent: Boolean): Boolean;
begin
  if EdFileName.Text <> '' then
  begin
    DBFile.FileName := EdFileName.Text;
    DBFile.Name := ExtractFileName(EdFileName.Text);
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
  Result := (EdFileName.Text <> '');
end;

procedure TFrmSelectDBExistedFile.BtnSelectFileClick(Sender: TObject);
var
  DBVersion : Integer;
  DialogResult : Integer;
  FA : Integer;
  OpenDialog : DBOpenDialog;
  FileName : string;
  DBTestOK : boolean;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');

    if FileExistsSafe(dbname) then
      OpenDialog.SetFileName(dbname);

    if OpenDialog.Execute then
    begin
      FileName := OpenDialog.FileName;

      FA := FileGetAttr(FileName);
      if (FA and SysUtils.faReadOnly) <> 0 then
      begin
        MessageBoxDB(Handle, TFormSelectDB(Manager.Owner).LReadOnly, L('Warning'), TD_BUTTON_OK,
          TD_ICON_WARNING);
        Exit;
      end;

      DBVersion := DBKernel.TestDBEx(FileName);
      if DBVersion > 0 then
        if not DBKernel.ValidDBVersion(FileName, DBVersion) then
        begin
          DialogResult := MessageBoxDB(Handle,
            'This database may not be used without conversion, ie it is designed to work with older versions of the program. Run the wizard to convert database?', L('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING);
          if ID_YES = DialogResult then
            ConvertDB(FileName);

        end;
      DBTestOK := DBKernel.TestDB(FileName);
      if DBTestOK then
      begin
        DBFile.FileName := FileName;
        EdFileName.Text := FileName;
        EdDBType.Text := DBKernel.StringDBVersion(DBKernel.TestDBEx(FileName));
      end else
        EdFileName.Text := L('No file');

    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TFrmSelectDBExistedFile.WlDBOptionsClick(Sender: TObject);
begin
  if DBKernel.TestDBEx(DBFile.FileName) > 0 then
  begin
    ConvertDB(DBFile.FileName);
  end else
  begin
    MessageBoxDB(Handle, L('Please select any collection at first!'), L('Warning'),
      TD_BUTTON_OK, TD_ICON_WARNING);
  end;
end;

end.
