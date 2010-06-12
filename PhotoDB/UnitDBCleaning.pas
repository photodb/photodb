unit UnitDBCleaning;

interface

uses
  Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, SaveWindowPos;

type
  TDBCleaningForm = class(TForm)
    DmProgress1: TDmProgress;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    SaveWindowPos1: TSaveWindowPos;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure VerifyEnabledToSave;
    procedure CheckBox4MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

var
  DBCleaningForm: TDBCleaningForm;

implementation

uses UnitCleanUpThread, Language;

{$R *.dfm}

procedure TDBCleaningForm.FormCreate(Sender: TObject);
begin
 SaveWindowPos1.Key:=RegRoot+'Cleaning';
 SaveWindowPos1.SetPosition;
 CheckBox1.Checked:=DBKernel.ReadBool('Options','DeleteNotValidRecords',True);
 CheckBox2.Checked:=DBKernel.ReadBool('Options','VerifyDublicates',False);
 CheckBox3.Checked:=DBKernel.ReadBool('Options','MarkDeletedFiles',True);
 CheckBox4.Checked:=DBKernel.ReadBool('Options','AllowAutoCleaning',false);
 CheckBox5.Checked:=DBKernel.ReadBool('Options','AllowFastCleaning',False);
 CheckBox6.Checked:=DBKernel.ReadBool('Options','FixDateAndTime',True);
 DBKernel.RegisterForm(DBCleaningForm);
 DBKernel.RecreateThemeToForm(DBCleaningForm);
 Button3.Enabled:=not UnitCleanUpThread.Active;
 Button4.Enabled:=UnitCleanUpThread.Active;
 DmProgress1.MaxValue:=UnitCleanUpThread.Share_MaxPosition;
 DmProgress1.Position:=UnitCleanUpThread.Share_Position;
 LoadLanguage;
end;

procedure TDBCleaningForm.FormDestroy(Sender: TObject);
begin
 SaveWindowPos1.SavePosition;
 DBKernel.UnRegisterForm(Self);
end;

procedure TDBCleaningForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Hide;
end;

procedure TDBCleaningForm.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TDBCleaningForm.Button1Click(Sender: TObject);
begin
 DBKernel.WriteBool('Options','DeleteNotValidRecords',CheckBox1.Checked);
 DBKernel.WriteBool('Options','VerifyDublicates',CheckBox2.Checked);
 DBKernel.WriteBool('Options','MarkDeletedFiles',CheckBox3.Checked);
 DBKernel.WriteBool('Options','AllowAutoCleaning',CheckBox4.Checked);
 DBKernel.WriteBool('Options','AllowFastCleaning',CheckBox5.Checked);
 DBKernel.WriteBool('Options','FixDateAndTime',CheckBox6.Checked);
 VerifyEnabledToSave;
end;

procedure TDBCleaningForm.VerifyEnabledToSave;
begin
 if (CheckBox1.Checked=DBKernel.ReadBool('Options','DeleteNotValidRecords',True)) and (CheckBox2.Checked=DBKernel.ReadBool('Options','VerifyDublicates',False)) and (CheckBox3.Checked=DBKernel.ReadBool('Options','MarkDeletedFiles',True)) and (CheckBox4.Checked=DBKernel.ReadBool('Options','AllowAutoCleaning',True)) and (CheckBox5.Checked=DBKernel.ReadBool('Options','AllowFastCleaning',False)) and (CheckBox6.Checked=DBKernel.ReadBool('Options','FixDateAndTime',True)) then
 Button1.Enabled:=False else
 Button1.Enabled:=True;
end;

procedure TDBCleaningForm.CheckBox4MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 VerifyEnabledToSave;
end;

procedure TDBCleaningForm.CheckBox4Click(Sender: TObject);
begin
 VerifyEnabledToSave;
end;

procedure TDBCleaningForm.Button3Click(Sender: TObject);
begin
 Button1Click(Sender);
 CleanUpThread.Create(False);
 Button3.Enabled:=False;
 Button4.Enabled:=True;
end;

procedure TDBCleaningForm.Button4Click(Sender: TObject);
begin
 UnitCleanUpThread.Termitating:=True;
end;

procedure TDBCleaningForm.LoadLanguage;
begin
 Caption := TEXT_MES_CLEANING_CAPTION;
 DmProgress1.Text:=TEXT_MES_PROGRESS_PR;
 CheckBox1.Caption:= TEXT_MES_DELETE_NOT_VALID_RECS;
 CheckBox2.Caption:= TEXT_MES_VERIFY_DUBLICATES;
 CheckBox3.Caption:= TEXT_MES_MARK_DELETED_FILES;
 CheckBox4.Caption:= TEXT_MES_ALLOW_AUTO_CLEANING;
 CheckBox5.Caption:= TEXT_MES_ALLOW_FAST_CLEANING;
 CheckBox6.Caption:= TEXT_MES_FIX_DATE_AND_TIME;
 Button1.Caption:= TEXT_MES_SAVE;
 Button2.Caption:= TEXT_MES_CLOSE;
 Button3.Caption:= TEXT_MES_START_NOW;
 Button4.Caption:= TEXT_MES_STOP_NOW;
end;

initialization

 DBCleaningForm:=nil;

end.
