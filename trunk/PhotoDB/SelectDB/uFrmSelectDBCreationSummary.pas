unit uFrmSelectDBCreationSummary;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, StdCtrls, UnitDBDeclare, UnitDBKernel,
  CommonDBSupport, uShellIntegration, uConstants, uDBUtils, uInterfaces;

type
  TFrmSelectDBCreationSummary = class(TFrameWizardBase)
    MemInfo: TMemo;
  private
    { Private declarations }
    function GetDBFile: TPhotoDBFile;
    procedure WriteNewDBOptions;
    function GetImageOptions: TImageDBOptions;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Execute; override;
    function IsFinal: Boolean; override;
    property DBFile: TPhotoDBFile read GetDBFile;
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
  MemInfo.Lines.Add(Format(L('Collection name: "%s"'), [DBFile.Name]));
  MemInfo.Lines.Add(Format(L('Path to collection: "%s"'), [DBFile.FileName]));
  MemInfo.Lines.Add(Format(L('Path to icon: "%s"'), [DBFile.Icon]));
  MemInfo.Lines.Add('');
  MemInfo.Lines.Add(Format(L('Size of collection previews: %dpx'),
      [ImageOptions.ThSize]));
  MemInfo.Lines.Add(Format(L('Quality of images: %dpx'),
      [ImageOptions.DBJpegCompressionQuality]));
  MemInfo.Lines.Add(Format(L('Preview size: %dpx'),
      [ImageOptions.ThHintSize]));
  MemInfo.Lines.Add(Format(L('Small preview size: %dpx'),
      [ImageOptions.ThSizePanelPreview]));
end;

procedure TFrmSelectDBCreationSummary.Execute;
var
  SettingsFrame: TFrmSelectDBNewPathAndIcon;
begin
  inherited;
  SettingsFrame := Manager.GetStepByType(TFrmSelectDBNewPathAndIcon) as TFrmSelectDBNewPathAndIcon;

  DBKernel.CreateDBbyName(DBFile.FileName);
  CommonDBSupport.ADOCreateSettingsTable(DBFile.FileName);
  ImageOptions.Description := SettingsFrame.EdName.Text;
  CommonDBSupport.UpdateImageSettings(DBFile.FileName, ImageOptions);
  if SettingsFrame.CbAddDefaultGroups.Checked then
    CreateExampleGroups(DBFile.FileName, Application.ExeName + ',0',
      ExtractFileDir(Application.ExeName));

  if SettingsFrame.CbSetAsDefaultDB.Checked then
    DBKernel.SetDataBase(DBFile.FileName);

  MessageBoxDB(Handle, Format(L('Collection "%s" successfully created!'),
      [DBFile.FileName]), L('Information'), TD_BUTTON_OK,
    TD_ICON_INFORMATION);

  IsStepComplete := True;
  Changed;
end;

function TFrmSelectDBCreationSummary.GetDBFile: TPhotoDBFile;
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
