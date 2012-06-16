unit uFrmSelectDBLanding;

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
  ExtCtrls,
  uFrameWizardBase,
  uConstants,
  UnitDBFileDialogs,
  uFileUtils,
  uShellIntegration,
  uDBUtils,
  UnitDBKernel,
  uMemory,
  UnitDBDeclare;

type
  TFrmSelectDBLanding = class(TFrameWizardBase)
    RgMode: TRadioGroup;
    procedure RgModeClick(Sender: TObject);
  private
    { Private declarations }
    FIsFinal: Boolean;
    procedure SetOptions(Options: Integer);
    function GetOptions: Integer;
    function GetDBFile: TPhotoDBFile;
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Execute; override;
    function InitNextStep: Boolean; override;
    function IsFinal: Boolean; override;
    property Options: Integer read GetOptions;
    property DBFile: TPhotoDBFile read GetDBFile;
  end;

implementation

uses
  UnitSelectDB,
  uFrmSelectDBNewPathAndIcon,
  uFrmSelectDBExistedFile,
  uFrmSelectDBFromList;

{$R *.dfm}

{ TFrmSelectDBLanding }

function TFrmSelectDBLanding.GetDBFile: TPhotoDBFile;
begin
  Result := TFormSelectDB(Manager.Owner).DBFile;
end;

function TFrmSelectDBLanding.GetOptions: Integer;
begin
  Result := TFormSelectDB(Manager.Owner).Options;
end;

procedure TFrmSelectDBLanding.Execute;
var
  SaveDialog : DBSaveDialog;
  FileName : string;
  FA : integer;
begin
  inherited;
  if (RgMode.ItemIndex = 3) or ((RgMode.ItemIndex = 2) and
      (Options = SELECT_DB_OPTION_GET_DB)) then
  begin
    // Sample DB
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
          MessageBoxDB(Handle, TFormSelectDB(Manager.Owner).LReadOnly, L('Warning'), TD_BUTTON_OK,
            TD_ICON_WARNING);
          Exit;
        end;

        CreateExampleDB(FileName, Application.ExeName + ',0',
          ExtractFileDir(Application.ExeName));

        DBFile.Name := DBKernel.NewDBName(L('My collection'));
        DBFile.FileName := FileName;
        DBFile.Icon := Application.ExeName + ',0';
        DBKernel.AddDB(DBFile.Name, DBFile.FileName, DBFile.Icon);

        MessageBoxDB(Handle, Format(L('Collection "%s" successfully created!'),
            [FileName]), L('Information'), TD_BUTTON_OK, TD_ICON_INFORMATION);
        IsStepComplete := True;
        Changed;
      end;
    finally
      F(SaveDialog);
    end;
  end;
end;

procedure TFrmSelectDBLanding.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    FIsFinal := False;
    SetOptions(Options);
    RgMode.ItemIndex := RgMode.Items.Count - 1;
  end;
end;

function TFrmSelectDBLanding.InitNextStep: Boolean;
begin
  Result := inherited;
  case RgMode.ItemIndex of
    0:
      begin
        Manager.AddStep(TFrmSelectDBNewPathAndIcon);
      end;
    1:
      begin
        Manager.AddStep(TFrmSelectDBExistedFile);
      end;
    2:
      begin
        if Options = SELECT_DB_OPTION_GET_DB_OR_EXISTS then
          Manager.AddStep(TFrmSelectDBFromList);
      end;
  end;
end;

function TFrmSelectDBLanding.IsFinal: Boolean;
begin
  Result := FIsFinal;
end;

procedure TFrmSelectDBLanding.LoadLanguage;
begin
  RgMode.Caption := L('Select an action') + ':';
end;

procedure TFrmSelectDBLanding.RgModeClick(Sender: TObject);
begin
  FIsFinal := (RgMode.ItemIndex = 3) or
    ((RgMode.ItemIndex = 2) and
      (Options = SELECT_DB_OPTION_GET_DB));
  Changed;
end;

procedure TFrmSelectDBLanding.SetOptions(Options: Integer);
begin
  RgMode.Items.Clear;
  RgMode.Items.Add(L('Create new collection'));
  RgMode.Items.Add(L('Select existing collection from hard disk'));
  if SELECT_DB_OPTION_GET_DB_OR_EXISTS = Options then
    RgMode.Items.Add(L('Use other registered collection'));
  RgMode.Items.Add(L('Create standard collection*'));
end;

end.
