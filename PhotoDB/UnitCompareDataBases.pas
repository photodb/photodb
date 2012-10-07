unit UnitCompareDataBases;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.CheckLst,
  Vcl.ExtCtrls,
  Data.DB,

  Dmitry.Utils.System,
  Dmitry.Controls.WatermarkedEdit,

  CmpUnit,
  Dolphin_DB,
  CommonDBSupport,
  UnitDBKernel,

  uConstants,
  uShellIntegration,
  uDBForm,
  uRuntime;

type
  TImportDataBaseForm = class(TDBForm)
    LbDatabase: TLabel;
    EdDatabase: TWatermarkedEdit;
    Button2: TButton;
    ClbOptions: TCheckListBox;
    GroupBox1: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    BtnOk: TButton;
    BtnCancel: TButton;
    Label5: TLabel;
    MemIgnoreKeywords: TMemo;
    Label4: TLabel;
    EdAuthor: TEdit;
    OpenDialog1: TOpenDialog;
    CbScanByName: TCheckBox;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Execute;
    Function DBsNormal : Boolean;
    Procedure CheckEnabled;
    procedure BtnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
  end;

var
  ImportDataBaseForm: TImportDataBaseForm;

implementation

uses
  UnitCompareProgress, UnitCmpDB;

{$R *.dfm}

procedure TImportDataBaseForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TImportDataBaseForm.FormCreate(Sender: TObject);
begin
  OpenDialog1.Filter := L('Photo Database files (*.photodb)|*.photodb');
  MemIgnoreKeywords.Lines.Clear;
  CheckEnabled;
  EdAuthor.Text := GetWindowsUserName;
  LoadLanguage;
  ClbOptions.Checked[0] := True;
  ClbOptions.Checked[1] := False;
  ClbOptions.Checked[2] := True;
  ClbOptions.Checked[3] := True;
  ClbOptions.Checked[4] := True;
  ClbOptions.Checked[5] := True;
  ClbOptions.Checked[6] := True;
  ClbOptions.Checked[7] := True;
  ClbOptions.Checked[8] := True;
  ClbOptions.Checked[9] := True;
  ClbOptions.Checked[10] := True;
  ClbOptions.Checked[11] := True;
  ClbOptions.Checked[12] := False;
end;

procedure TImportDataBaseForm.Button2Click(Sender: TObject);
var
  DBTestOK: Boolean;
begin
  if OpenDialog1.Execute then
  begin
    DBTestOK := DBKernel.TestDB(OpenDialog1.FileName);
    if AnsiUpperCase(OpenDialog1.FileName) = AnsiUpperCase(Dbname) then
    begin
      MessageBoxDB(Handle, L('Please, choose different collections'), L('Warning'), TD_BUTTON_OK, TD_ICON_INFORMATION);
      DBTestOK := False;
    end;
    if DBTestOK then
    begin
      EdDatabase.Text := OpenDialog1.FileName;
      LbDatabase.Caption := Format(L('Add collection (%d items)'), [GetRecordsCount(OpenDialog1.FileName)]);
    end else
      EdDatabase.Text := L('No file');
  end;
  CheckEnabled;
end;

procedure TImportDataBaseForm.Execute;
begin
  Show;
end;

function TImportDataBaseForm.DBsNormal: Boolean;
begin
  Result := DBKernel.TestDB(EdDatabase.Text);
end;

procedure TImportDataBaseForm.CheckEnabled;
begin
  BtnOk.Enabled := DBsNormal;
end;

procedure TImportDataBaseForm.BtnOkClick(Sender: TObject);
var
  Options: TCompOptions;
begin
  with Options do
  begin
    AddNewRecords := ClbOptions.Checked[0];
    AddRecordsWithoutFiles := ClbOptions.Checked[1];
    AddRating := ClbOptions.Checked[2];
    AddRotate := ClbOptions.Checked[3];
    AddPrivate := ClbOptions.Checked[4];
    AddKeyWords := ClbOptions.Checked[5];
    AddGroups := ClbOptions.Checked[6];
    AddNilComment := ClbOptions.Checked[7];
    AddComment := ClbOptions.Checked[8];
    AddNamedComment := ClbOptions.Checked[9];
    AddDate := ClbOptions.Checked[10];
    AddLinks := ClbOptions.Checked[11];
    IgnoreWords := ClbOptions.Checked[12];
    IgWords := MemIgnoreKeywords.Text;
    Autor := EdAuthor.Text;
    UseScanningByFileName := CbScanByName.Checked;
  end;
  Application.CreateForm(TImportProgressForm, ImportProgressForm);
  Hide;
  Application.ProcessMessages;
  ImportProgressForm.Show;
  CmpDBTh.Create(ImportProgressForm, Options, EdAuthor.Text, MemIgnoreKeywords.Text, EdDatabase.Text);

  Close;
end;

function TImportDataBaseForm.GetFormID: string;
begin
  Result := 'ImportDB';
end;

procedure TImportDataBaseForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import settings');
    EdDatabase.WatermarkText := L('Please, choose collection');
    ClbOptions.Clear;
    ClbOptions.Items.Add(L('Add new items'));
    ClbOptions.Items.Add(L('Add items without files'));
    ClbOptions.Items.Add(L('Add rating'));
    ClbOptions.Items.Add(L('Add rotate'));
    ClbOptions.Items.Add(L('Add private'));
    ClbOptions.Items.Add(L('Add keywords'));
    ClbOptions.Items.Add(L('Add groups'));
    ClbOptions.Items.Add(L('Add empty comments'));
    ClbOptions.Items.Add(L('Add comments'));
    ClbOptions.Items.Add(L('Add comments with author'));
    ClbOptions.Items.Add(L('Add date'));
    ClbOptions.Items.Add(L('Add links'));
    ClbOptions.Items.Add(L('Ignore keywords'));
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    GroupBox1.Caption := L('Replace');
    Label9.Caption := L('to');
    Label10.Caption := L('to');
    Label11.Caption := L('to');
    Label12.Caption := L('to');
    LbDatabase.Caption := L('Add collection') + ':';
    Label4.Caption := L('Author');
    Label5.Caption := L('List of ignored words') + ':';
    CbScanByName.Caption := L('Advanced search if file names equals');
  finally
    EndTranslate;
  end;
end;

procedure TImportDataBaseForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ImportDataBaseForm := nil;
  Release;
end;

end.
