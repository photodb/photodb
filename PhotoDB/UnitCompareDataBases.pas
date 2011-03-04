unit UnitCompareDataBases;

interface

uses
  CmpUnit, Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, CheckLst, DB, CommonDBSupport, ExtCtrls,
  uConstants, UnitDBKernel, uShellIntegration, uSysUtils, uDBForm;

type
  TImportDataBaseForm = class(TDBForm)
    Label3: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    CheckListBox1: TCheckListBox;
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
    Button4: TButton;
    Button5: TButton;
    Label5: TLabel;
    Memo1: TMemo;
    Label4: TLabel;
    Edit4: TEdit;
    OpenDialog1: TOpenDialog;
    CheckBox1: TCheckBox;
    DestroyTimer: TTimer;
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Execute;
    Function DBsNormal : Boolean;
    Procedure CheckEnabled;
    procedure Button4Click(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
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

procedure TImportDataBaseForm.Button5Click(Sender: TObject);
begin
  Close;
end;

procedure TImportDataBaseForm.FormCreate(Sender: TObject);
var
  Filter: string;
begin
  Filter := 'Access files (*.photodb;*.mdb)|*.photodb;*.mdb';
  OpenDialog1.Filter := Filter;
  Memo1.Lines.Clear;
  CheckEnabled;
  Edit4.Text := GetWindowsUserName;
  LoadLanguage;
  CheckListBox1.Checked[0] := True;
  CheckListBox1.Checked[1] := True;
  CheckListBox1.Checked[2] := True;
  CheckListBox1.Checked[3] := True;
  CheckListBox1.Checked[4] := True;
  CheckListBox1.Checked[5] := True;
  CheckListBox1.Checked[6] := True;
  CheckListBox1.Checked[7] := True;
  CheckListBox1.Checked[8] := True;
  CheckListBox1.Checked[9] := True;
  CheckListBox1.Checked[10] := True;
  CheckListBox1.Checked[11] := True;
  CheckListBox1.Checked[12] := False;
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
      Edit2.Text := OpenDialog1.FileName;
      Label3.Caption := Format(L('Add collection (%d items)'), [GetRecordsCount(OpenDialog1.FileName)]);
    end
    else
      Edit2.Text := L('No file'); // TODO: in XML
  end;
  CheckEnabled;
end;

procedure TImportDataBaseForm.Execute;
begin
  Show;
end;

function TImportDataBaseForm.DBsNormal: Boolean;
begin
  Result := DBKernel.TestDB(Edit2.Text);
end;

procedure TImportDataBaseForm.CheckEnabled;
begin
  Button4.Enabled := DBsNormal;
end;

procedure TImportDataBaseForm.Button4Click(Sender: TObject);
var
  Options: TCompOptions;
begin
  with Options do
  begin
    AddNewRecords := CheckListBox1.Checked[0];
    AddRecordsWithoutFiles := CheckListBox1.Checked[1];
    AddRating := CheckListBox1.Checked[2];
    AddRotate := CheckListBox1.Checked[3];
    AddPrivate := CheckListBox1.Checked[4];
    AddKeyWords := CheckListBox1.Checked[5];
    AddGroups := CheckListBox1.Checked[6];
    AddNilComment := CheckListBox1.Checked[7];
    AddComment := CheckListBox1.Checked[8];
    AddNamedComment := CheckListBox1.Checked[9];
    AddDate := CheckListBox1.Checked[10];
    AddLinks := CheckListBox1.Checked[11];
    IgnoreWords := CheckListBox1.Checked[12];
    IgWords := Memo1.Text;
    Autor := Edit4.Text;
    UseScanningByFileName := CheckBox1.Checked;
  end;
  UnitCmpDB.SourceTableName := Edit2.Text;
  UnitCmpDB.Options := Options;
  UnitCmpDB.IgnoredWords := Memo1.Text;
  Application.CreateForm(TImportProgressForm, ImportProgressForm);
  Hide;
  Application.ProcessMessages;
  ImportProgressForm.Show;
  CmpDBTh.Create(False);
  Close; // ?
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
    CheckListBox1.Clear;
    CheckListBox1.Items.Add(L('Add new items'));
    CheckListBox1.Items.Add(L('Add items without files'));
    CheckListBox1.Items.Add(L('Add rating'));
    CheckListBox1.Items.Add(L('Add rotate'));
    CheckListBox1.Items.Add(L('Add private'));
    CheckListBox1.Items.Add(L('Add keywords'));
    CheckListBox1.Items.Add(L('Add groups'));
    CheckListBox1.Items.Add(L('Add empty comments'));
    CheckListBox1.Items.Add(L('Add comments'));
    CheckListBox1.Items.Add(L('Add comments with author'));
    CheckListBox1.Items.Add(L('Добавлять дату'));
    CheckListBox1.Items.Add(L('Add links'));
    CheckListBox1.Items.Add(L('Ignore keywords'));
    Button5.Caption := L('Cancel');
    Button4.Caption := L('Ok');
    GroupBox1.Caption := L('Replace');
    Label9.Caption := L('to');
    Label10.Caption := L('to');
    Label11.Caption := L('to');
    Label12.Caption := L('to');
    Label3.Caption := L('Add collection');
    Label4.Caption := L('Author');
    Label5.Caption := L('List of ignored words') + ':';
    CheckBox1.Caption := L('Advanced search if file names equals');
  finally
    EndTranslate;
  end;
end;

procedure TImportDataBaseForm.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  ImportDataBaseForm := nil;
  Release;
end;

procedure TImportDataBaseForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyTimer.Enabled := True;
end;

end.
