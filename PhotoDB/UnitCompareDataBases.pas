unit UnitCompareDataBases;

interface

uses
  CmpUnit, Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, CheckLst, DB, CommonDBSupport, ExtCtrls,
  uVistaFuncs;

type
  TImportDataBaseForm = class(TForm)
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
    procedure FormDestroy(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

var
  ImportDataBaseForm: TImportDataBaseForm;

implementation

uses UnitCompareProgress, UnitCmpDB, Language;

{$R *.dfm}

procedure TImportDataBaseForm.Button5Click(Sender: TObject);
begin
 Close;
end;

procedure TImportDataBaseForm.FormCreate(Sender: TObject);
var
  Filter : String;
begin
 Filter:='Access files (*.photodb;*.mdb)|*.photodb;*.mdb';
 OpenDialog1.Filter:=Filter;
 DBKernel.RegisterForm(ImportDataBaseForm);
 Memo1.Lines.Clear;
 CheckEnabled;
 Edit4.text:=InstalledUserName;
 LoadLanguage;
 CheckListBox1.Checked[0]:=True;
 CheckListBox1.Checked[1]:=True;
 CheckListBox1.Checked[2]:=True;
 CheckListBox1.Checked[3]:=True;
 CheckListBox1.Checked[4]:=True;
 CheckListBox1.Checked[5]:=True;
 CheckListBox1.Checked[6]:=True;
 CheckListBox1.Checked[7]:=True;
 CheckListBox1.Checked[8]:=True;
 CheckListBox1.Checked[9]:=True;
 CheckListBox1.Checked[10]:=True;
 CheckListBox1.Checked[11]:=True;
 CheckListBox1.Checked[12]:=False;
end;

procedure TImportDataBaseForm.Button2Click(Sender: TObject);
var
  DBTestOK : boolean;
begin
 if OpenDialog1.execute then
 begin
  DBTestOK:=DBKernel.testDB(OpenDialog1.FileName);
  if AnsiUpperCase(OpenDialog1.FileName)=AnsiUpperCase(dbname) then
  begin
   MessageBoxDB(Handle,TEXT_MES_MAIN_DB_AND_ADD_SAME,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
   DBTestOK:=false;
  end;
  if DBTestOK then
  begin
   Edit2.Text:= OpenDialog1.FileName;
   Label3.Caption:=Format(TEXT_MES_ADD_DB_RECS_FORMAT,[IntToStr(GetRecordsCount(OpenDialog1.FileName))]);
  end else
  edit2.Text:=TEXT_MES_NO_DB_FILE;
 end;
 CheckEnabled;
end;

procedure TImportDataBaseForm.Execute;
begin
 Show;
end;

function TImportDataBaseForm.DBsNormal: Boolean;
begin
 if DBKernel.TestDB(edit2.Text) then Result:=True else Result:=False;
end;

procedure TImportDataBaseForm.CheckEnabled;
begin
 If DBsNormal then
 Button4.Enabled:=True else
 Button4.Enabled:=False;
end;

procedure TImportDataBaseForm.Button4Click(Sender: TObject);
var
  Options : TCompOptions;
begin
 With Options do
 begin
  AddNewRecords := CheckListBox1.Checked[0];
  AddRecordsWithoutFiles := CheckListBox1.Checked[1];
  AddRating :=CheckListBox1.Checked[2];
  AddRotate :=CheckListBox1.Checked[3];
  AddPrivate :=CheckListBox1.Checked[4];
  AddKeyWords:=CheckListBox1.Checked[5];
  AddGroups:=CheckListBox1.Checked[6];
  AddNilComment :=CheckListBox1.Checked[7];
  AddComment :=CheckListBox1.Checked[8];
  AddNamedComment:=CheckListBox1.Checked[9];
  AddDate :=CheckListBox1.Checked[10];
  AddLinks :=CheckListBox1.Checked[11];
  IgnoreWords :=CheckListBox1.Checked[12];
  IgWords := Memo1.Text;
  Autor := edit4.Text;
  UseScanningByFileName:=CheckBox1.Checked;
 end;
 UnitCmpDB.SourceTableName:=Edit2.text;
 UnitCmpDB.Options :=  Options;
 UnitCmpDB.IgnoredWords:= Memo1.Text;
 Application.CreateForm(TImportProgressForm,ImportProgressForm);
 Hide;
 Application.ProcessMessages;
 ImportProgressForm.Show;
 CmpDBTh.Create(false);
 Close; //?
end;

procedure TImportDataBaseForm.FormDestroy(Sender: TObject);
begin
 DBkernel.UnRegisterForm(ImportDataBaseForm);
end;

procedure TImportDataBaseForm.LoadLanguage;
begin
 Caption:=TEXT_MES_IMPORTING_OPTIONS_CAPTION;
 CheckListBox1.Clear;
 CheckListBox1.Items.Add(TEXT_MES_ADD_NEW_RECS);
 CheckListBox1.Items.Add(TEXT_MES_ADD_REC_WITHOUT_FILES);
 CheckListBox1.Items.Add(TEXT_MES_ADD_RATING);
 CheckListBox1.Items.Add(TEXT_MES_ADD_ROTATE);
 CheckListBox1.Items.Add(TEXT_MES_ADD_PRIVATE);
 CheckListBox1.Items.Add(TEXT_MES_ADD_KEYWORDS);
 CheckListBox1.Items.Add(TEXT_MES_ADD_GROUPS);
 CheckListBox1.Items.Add(TEXT_MES_ADD_NIL_COMMENT);
 CheckListBox1.Items.Add(TEXT_MES_ADD_COMMENT);
 CheckListBox1.Items.Add(TEXT_MES_ADD_NAMED_COMMENT);
 CheckListBox1.Items.Add(TEXT_MES_ADD_DATE);
 CheckListBox1.Items.Add(TEXT_MES_ADD_LINKS);
 CheckListBox1.Items.Add(TEXT_MES_IGNORE_KEYWORDS);
 Button5.Caption:=TEXT_MES_CANCEL;
 Button4.Caption:=TEXT_MES_OK;
 GroupBox1.Caption:=TEXT_MES_REPLACE_GROUP_BOX;
 Label9.Caption:=TEXT_MES_ON__REPLACE_;
 Label10.Caption:=TEXT_MES_ON__REPLACE_;
 Label11.Caption:=TEXT_MES_ON__REPLACE_;
 Label12.Caption:=TEXT_MES_ON__REPLACE_;

 Label3.Caption:= TEXT_MES_ADD_DB;
 Label4.Caption:= TEXT_MES_BY_AUTHOR;
 Label5.Caption:= TEXT_MES_LIST_IGNORE_WORDS;
 CheckBox1.Caption:= TEXT_MES_USE_SCANNING_BY_FILENAME;
end;

procedure TImportDataBaseForm.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 ImportDataBaseForm:=nil;
 Release;
end;

procedure TImportDataBaseForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
end;

end.
