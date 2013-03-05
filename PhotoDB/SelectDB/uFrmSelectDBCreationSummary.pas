unit uFrmSelectDBCreationSummary;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,

  UnitDBDeclare,
  UnitDBKernel,
  CommonDBSupport,

  uFrameWizardBase,
  uShellIntegration,
  uConstants,
  uDBUtils,
  uLinkListEditorDatabases,
  uInterfaces;

type
  TFrmSelectDBCreationSummary = class(TFrameWizardBase)
    MemInfo: TMemo;
  private
    { Private declarations }
    function GetDBFile: TDatabaseInfo;
    procedure WriteNewDBOptions;
    function GetImageOptions: TImageDBOptions;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Execute; override;
    function IsFinal: Boolean; override;
    property DBFile: TDatabaseInfo read GetDBFile;
    property ImageOptions: TImageDBOptions read GetImageOptions;
  end;

implementation

uses
  UnitSelectDB,
  uFrmSelectDBNewPathAndIcon;

{$R *.dfm}

{ TFrmSelectDBCreationSummary }

procedure TFrmSelectDBCreationSummary.WriteNewDBOptions;
begin
  MemInfo.Clear;
  MemInfo.Lines.Add(L('The new collection will be created with the following settings:')+#13#13);
  MemInfo.Lines.Add('');
  MemInfo.Lines.Add(Format(L('Collection name: "%s"'), [DBFile.Title]));
  MemInfo.Lines.Add(Format(L('Path to collection: "%s"'), [DBFile.Path]));
  MemInfo.Lines.Add(Format(L('Path to icon: "%s"'), [DBFile.Icon]));
  MemInfo.Lines.Add('');
  MemInfo.Lines.Add(Format(L('Size of collection previews: %dpx'),
      [ImageOptions.ThSize]));
  MemInfo.Lines.Add(Format(L('Quality of images: %dpx'),
      [ImageOptions.DBJpegCompressionQuality]));
  MemInfo.Lines.Add(Format(L('Preview size: %dpx'),
      [ImageOptions.ThHintSize]));
end;

procedure TFrmSelectDBCreationSummary.Execute;
var
  SettingsFrame: TFrmSelectDBNewPathAndIcon;
begin
  inherited;
  SettingsFrame := Manager.GetStepByType(TFrmSelectDBNewPathAndIcon) as TFrmSelectDBNewPathAndIcon;

  DBKernel.CreateDBbyName(DBFile.Path);
  CommonDBSupport.ADOCreateSettingsTable(DBFile.Path);
  ImageOptions.Description := SettingsFrame.EdName.Text;
  CommonDBSupport.UpdateImageSettings(DBFile.Path, ImageOptions);
  if SettingsFrame.CbAddDefaultGroups.Checked then
    CreateExampleGroups(DBFile.Path, Application.ExeName + ',0',
      ExtractFileDir(Application.ExeName));

  if SettingsFrame.CbSetAsDefaultDB.Checked then
    DBKernel.SetDataBase(DBFile.Path);

  MessageBoxDB(Handle, Format(L('Collection "%s" successfully created!'), [DBFile.Path]), L('Information'), TD_BUTTON_OK,
    TD_ICON_INFORMATION);

  IsStepComplete := True;
  Changed;
end;

function TFrmSelectDBCreationSummary.GetDBFile: TDatabaseInfo;
begin
  Result := TFormSelectDB(Manager.Owner).DBFile;
end;

function TFrmSelectDBCreationSummary.GetImageOptions: TImageDBOptions;
begin
  Result := (Manager.Owner as IDBImageSettings).GetImageOptions;
end;

procedure TFrmSelectDBCreationSummary.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  WriteNewDBOptions;
end;

function TFrmSelectDBCreationSummary.IsFinal: Boolean;
begin
  Result := True;
end;

end.
