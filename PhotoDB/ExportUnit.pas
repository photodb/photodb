unit ExportUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, Dolphin_db, ExtCtrls, uVistaFuncs;

type
  TExportForm = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    DmProgress1: TDmProgress;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SaveDialog1: TSaveDialog;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    Button3: TButton;
    DestroyTimer: TTimer;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure SetRecordText(Value : String);
    procedure SetProgressMaxValue(Value : Integer);
    procedure SetProgressPosition(Value : Integer);
    procedure SetProgressText(Value : String);
    procedure Edit1Change(Sender: TObject);
    procedure DoExit(Sender: TObject);
    procedure Execute;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CheckBox5Click(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

var
  ExportForm: TExportForm;
  Working : Boolean = false;

implementation

uses UnitExportThread, Language;

{$R *.dfm}

procedure TExportForm.Button2Click(Sender: TObject);
var
  Options: TExportOptions;
  F : TextFile;
begin
 System.Assign(F,Edit1.text);
 {$I-}
 System.Rewrite(F);
 {$I+}
 if IOResult<>0 then
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_CANNOT_CREATE_FILE_F,[Edit1.text]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  exit;
 end;
 System.Close(F);
 Button1.Enabled:=false;
 Button2.Enabled:=false;
 Options.ExportPrivate:=CheckBox1.Checked;
 Options.ExportRatingOnly:=CheckBox2.Checked;
 Options.ExportNoFiles:=CheckBox3.Checked;
 Options.ExportGroups:=CheckBox4.Checked;
 Options.ExportCrypt:=CheckBox5.Checked;
 Options.ExportCryptIfPassFinded:=CheckBox6.Checked and CheckBox5.Enabled;;
 Options.FileName:=Edit1.text;
 CheckBox1.Enabled:=false;
 CheckBox2.Enabled:=false;
 CheckBox3.Enabled:=false;
 CheckBox4.Enabled:=false;
 CheckBox5.Enabled:=false;
 CheckBox6.Enabled:=false;
 Working:=true;
 ExportThread.Create(false,Options);
 Button3.Enabled:=true;
end;

procedure TExportForm.Button1Click(Sender: TObject);
begin
 If SaveDialog1.Execute then
 begin
  if not ValidDBPath(SaveDialog1.FileName) then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_PATH_INVALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   exit;
  end;
{  if SaveDialog1.FilterIndex=2 then
  if GetExt(SaveDialog1.FileName)<>'DB' then
  SaveDialog1.FileName:=SaveDialog1.FileName+'.db';
  if SaveDialog1.FilterIndex=1 then   }
  
  if GetExt(SaveDialog1.FileName)<>'PHOTODB' then
  SaveDialog1.FileName:=SaveDialog1.FileName+'.photodb';

  if FileExists(SaveDialog1.FileName) then
  if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_1,[SaveDialog1.FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
  Edit1.text:=SaveDialog1.FileName;
 end;
end;

procedure TExportForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#8 then
 if not Working then
 begin
  Edit1.Text:=TEXT_MES_NO_FILEA;
 end;
end;

procedure TExportForm.SetRecordText(Value: String);
begin
 Label2.caption:=Value;
end;

procedure TExportForm.Edit1Change(Sender: TObject);
begin
 If Edit1.text=TEXT_MES_NO_FILEA then
 Button2.Enabled:=false else
 Button2.Enabled:=true;
end;

procedure TExportForm.Execute;
begin
 Edit1Change(nil);
 ShowModal;
end;

procedure TExportForm.FormCreate(Sender: TObject);
begin
 DBKernel.RecreateThemeToForm(Self);
 LoadLanguage;
end;

procedure TExportForm.SetProgressMaxValue(Value: Integer);
begin
 DmProgress1.MaxValue:=Value;
end;

procedure TExportForm.SetProgressPosition(Value: Integer);
begin
 DmProgress1.Position:=Value;
end;

procedure TExportForm.SetProgressText(Value: String);
begin
 DmProgress1.Text:=Value;
end;

procedure TExportForm.DoExit(Sender: TObject);
begin
 Working:=false;
 Close;
end;

procedure TExportForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 If Working then CanClose:=false;
end;

procedure TExportForm.LoadLanguage;
begin
 Caption:=TEXT_MES_EXPORT_WINDOW_CAPTION;
 CheckBox1.Caption:=TEXT_MES_EXPORT_PRIVATE;
 CheckBox2.Caption:=TEXT_MES_EXPORT_ONLY_RATING;
 CheckBox3.Caption:=TEXT_MES_EXPORT_REC_WITHOUT_FILES;
 CheckBox4.Caption:=TEXT_MES_EXPORT_GROUPS;
 CheckBox5.Caption:=TEXT_MES_EXPORT_CRYPTED;
 CheckBox6.Caption:=TEXT_MES_EXPORT_CRYPTED_IF_PASSWORD_EXISTS;
 Button2.Caption:=TEXT_MES_BEGIN_EXPORT;
 Button3.Caption:=TEXT_MES_BREAK_BUTTON;
 Label1.caption:=TEXT_MES_REC+':';
 DmProgress1.Text:=TEXT_MES_PROGRESS_PR;
end;

procedure TExportForm.CheckBox5Click(Sender: TObject);
begin
 CheckBox6.Enabled:=CheckBox5.Checked;
end;

procedure TExportForm.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
 ExportForm:=nil;
end;

procedure TExportForm.Button3Click(Sender: TObject);
begin
 UnitExportThread.StopExport:=true;
end;

end.
