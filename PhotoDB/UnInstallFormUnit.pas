unit UnInstallFormUnit;

interface

uses
  Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes, Graphics,
   Controls, Forms, uVistaFuncs,
  Dialogs, StdCtrls, CheckLst, DmProgress, uConstants;

type
  TUnInstallForm = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    CheckListBox1: TCheckListBox;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

var
  UnInstallForm: TUnInstallForm;

implementation

uses UnitUnInstallThread, SetupProgressUnit, Language;

{$R *.dfm}

procedure TUnInstallForm.Button1Click(Sender: TObject);
begin
  Button1.Enabled := False;
  Hide;
  Application.ProcessMessages;
  UnitUnInstallThread.Options.Program_Files := CheckListBox1.Checked[0];
  UnitUnInstallThread.Options.DataBase_Files := CheckListBox1.Checked[1];
  UnitUnInstallThread.Options.Registry_Entries := CheckListBox1.Checked[2];
  UnitUnInstallThread.Options.Chortcuts := CheckListBox1.Checked[3];
  UnitUnInstallThread.Options.PlugIns := CheckListBox1.Checked[4];
  UnitUnInstallThread.Options.Scripts := CheckListBox1.Checked[5];
  UnitUnInstallThread.Options.Actions := CheckListBox1.Checked[6];
  if SetupProgressForm = nil then
    Application.CreateForm(TSetupProgressForm, SetupProgressForm);
  UnitUnInstallThread.UnInstallThread.Create(False);
  SetupProgressForm.ShowModal;
  SetupProgressForm.Release;
  SetupProgressForm.Free;
  SetupProgressForm := nil;
  Close;
end;

procedure TUnInstallForm.FormCreate(Sender: TObject);
var
  I: Integer;
  HSemaphore: THandle;
begin
  HSemaphore := CreateSemaphore(nil, 0, 1, PWideChar(DBID));
  if ((HSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    MessageBoxDB(GetActiveFormHandle, TEXT_MES_CLOSE_OPENED_PROGRAM, TEXT_MES_UNINSTALL, TD_BUTTON_OK, TD_ICON_WARNING);
    Halt;
  end;
  for I := 0 to CheckListBox1.Count - 1 do
    CheckListBox1.Checked[I] := True;
  CheckListBox1.Checked[1] := False;
  LoadLanguage;
end;

procedure TUnInstallForm.FormShow(Sender: TObject);
begin
  Application.Restore;
  Show;
end;

procedure TUnInstallForm.LoadLanguage;
begin
  Label1.Caption := 'UnInstall ' + ProductName;
  Label2.Caption := TEXT_MES_UNINSTALL_LIST + ':';
  Button2.Caption := TEXT_MES_EXIT;
  Button1.Caption := TEXT_MES_UNINSTALL;
  Caption := TEXT_MES_UNINSTALL_CAPTION;
  CheckListBox1.Items[0] := TEXT_MES_PROGRAM_FILES;
  CheckListBox1.Items[1] := TEXT_MES_DB_FILES;
  CheckListBox1.Items[2] := TEXT_MES_REG_ENTRIES;
  CheckListBox1.Items[3] := TEXT_MES_CHORTCUTS;
  CheckListBox1.Items[5] := TEXT_MES_SCRIPTS;
  CheckListBox1.Items[6] := TEXT_MES_ACTIONS;
end;

procedure TUnInstallForm.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
