unit activation;

interface

uses
  UnitINI, Searching, dolphin_db, UnitDBKernel, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, uVistaFuncs,
  Dialogs, StdCtrls, jpeg, ExtCtrls;

type
  TActivateForm = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Edit3: TEdit;
    Label3: TLabel;
    Image1: TImage;
    Button3: TButton;
    HelpTimer: TTimer;
    HelpTimer2: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure execute;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure HelpTimerTimer(Sender: TObject);
    procedure HelpTimer2Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private        
    Hs, Nm : string;
    procedure WMMouseDown(var Message : TMessage); message WM_LBUTTONDOWN;
    { Private declarations }
  public
    procedure LoadLanguage;
    procedure HelpActivationNextClick(Sender: TObject);
    procedure HelpActivationCloseClick(Sender : TObject; var CanClose : Boolean);
    { Public declarations }
  end;

var
  ActivateForm: TActivateForm;

implementation

uses language, UnitHelp, FormManegerUnit;

{$R *.dfm}

procedure TActivateForm.FormCreate(Sender: TObject);
begin   
 LoadLanguage;
 Hs := DBKernel.ReadActivateKey;
 if not FolderView then
 Nm := DBKernel.ReadRegName;
 Edit1.text:=DBKernel.ApplicationCode;

 if not FolderView then
 if not DBKernel.ProgramInDemoMode then
 begin
  Edit2.text:=DBKernel.ReadActivateKey;
  Edit3.text:=DBKernel.ReadRegName;
 end;

end;

procedure TActivateForm.Button2Click(Sender: TObject);
var
  Reg : TBDRegistry;
begin
  if FolderView then
    Exit;
  Nm := Edit3.text;
  Hs := Edit2.text;
  Reg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Reg.OpenKey('\CLSID\' + ActivationID, True);
    Reg.WriteString('UserName', Nm);
    Reg.WriteString('Code', Hs);
  finally
    Reg.free;
  end;
  MessageBoxDB(Handle, TEXT_MES_KEY_SAVE,TEXT_MES_WARNING, TD_BUTTON_OK, TD_ICON_WARNING);
  Close;
end;

procedure TActivateForm.Execute;
begin
  ShowModal;
end;

procedure TActivateForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TActivateForm.WMMouseDown(var Message: TMessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, Message.lparam);
end;

procedure TActivateForm.LoadLanguage;
begin
 Label1.Caption:=TEXT_MES_PROGRAM_CODE;
 Label2.Caption:=TEXT_MES_ACTIVATION_KEY;
 Label3.Caption:=TEXT_MES_ACTIVATION_NAME;
 Button1.Caption:=TEXT_MES_CANCEL;
 Button2.Caption:=TEXT_MES_SET_CODE;
 Caption:=TEXT_MES_ACTIVATION_CAPTION;
 Button3.Caption:=TEXT_MES_GET_CODE;
end;

procedure TActivateForm.Button3Click(Sender: TObject);
begin
 DoGetCode(Edit1.Text);
 if HelpActivationNO=4 then
 begin
  HelpTimer2.Enabled:=true;
 end;
end;

procedure TActivateForm.HelpTimerTimer(Sender: TObject);
begin
 HelpTimer.Enabled:=false;
 if DBkernel.GetDemoMode then
 if HelpActivationNO=3 then
 DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_ACTIVATION_3,Point(0,0),Button3,HelpActivationNextClick,TEXT_MES_NEXT_HELP,HelpActivationCloseClick);
end;

procedure TActivateForm.HelpActivationCloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=ID_OK=MessageBoxDB(GetActiveFormHandle,TEXT_MES_CLOSE_HELP,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_INFORMATION);
 if CanClose then
 begin
  HelpActivationNO:=0;
  DBKernel.WriteBool('HelpSystem','ActivationHelp',False);
 end;
end;

procedure TActivateForm.HelpActivationNextClick(Sender: TObject);
begin
 HelpActivationNO:=HelpActivationNO+1;
end;

procedure TActivateForm.HelpTimer2Timer(Sender: TObject);
begin
 if not Active then exit;
 HelpTimer2.Enabled:=false;
 DoHelpHint(TEXT_MES_HELP_HINT,TEXT_MES_HELP_ACTIVATION_4,Point(0,0),Edit2);
 HelpActivationNO:=0;
 DBKernel.WriteBool('HelpSystem','ActivationHelp',False);
end;

procedure TActivateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not FolderView then
  DBKernel.SetActivateKey(Nm, Hs);
  FormManager.UnRegisterMainForm(ActivateForm)
end;

procedure TActivateForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //ESC
  if Key = 27 then Close();
end;

initialization

 ActivateForm:=nil;

end.
