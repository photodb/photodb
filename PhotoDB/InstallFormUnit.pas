unit InstallFormUnit;

interface

uses
  Registry, UnitInstallThread, acDlgSelect, Dolphin_db, Windows, Messages,
  SysUtils, Variants, Classes, Graphics, Controls, Forms, uVistaFuncs,
  Dialogs, StdCtrls, jpeg, ExtCtrls, DmProgress, CheckLst, Menus, AppEvnts,
  UnitDBFileDialogs, uConstants, uFileUtils;

type
  TInstallForm = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    OpenDialog1: TOpenDialog;
    Step1: TPanel;
    CheckBox2: TCheckBox;
    Edit3: TEdit;
    Label4: TLabel;
    Edit2: TEdit;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    CheckBox1: TCheckBox;
    Memo1: TMemo;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    PopupMenu1: TPopupMenu;
    CheckAll1: TMenuItem;
    UnCheckAll1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Default1: TMenuItem;
    Button6: TButton;
    Button7: TButton;
    Step2: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Edit4: TEdit;
    CheckListBox1: TCheckListBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Label10: TLabel;
    CheckBox6: TCheckBox;
    ComboBox1: TComboBox;
    Label11: TLabel;
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit3KeyPress(Sender: TObject; var Key: Char);
    procedure CheckAll1Click(Sender: TObject);
    procedure UnCheckAll1Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Default1Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Edit4KeyPress(Sender: TObject; var Key: Char);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBox1Select(Sender: TObject);
  private
    { Private declarations }
  public
  QuickSelfInstall : boolean;
  Procedure LoadLanguage;
  Procedure SetQuickSelfInstallOption;
    { Public declarations }
  end;

var
  InstallForm: TInstallForm;

implementation

uses Language, SetupProgressUnit;

{$R *.dfm}

procedure TInstallForm.Button5Click(Sender: TObject);
begin
  OpenDialog1.Filter:='PhotoDB files (*.photodb;*.mdb)|*.photodb;*.mdb';
  if OpenDialog1.Execute then
  begin
   if DBKernel.TestDB(OpenDialog1.FileName) then
   begin
    Edit3.Text:=OpenDialog1.FileName;
    CheckBox2.Enabled:=true;
    Edit3.Enabled:=true;
   end else begin
    CheckBox2.Enabled:=false;
    MessageBoxDB(Handle,TEXT_MES_DB_FILE_NOT_VALID,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_WARNING);
   end;
  end;
end;

procedure TInstallForm.Button3Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_FOLDER_INSTALL,Dolphin_DB.UseSimpleSelectFolderDialog);
 If DirectoryExists(dir) then
 begin
  FormatDir(Dir);
  Edit1.Text:=dir+'Photo DataBase';
 end;
end;

procedure TInstallForm.Button4Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_FOLDER_DB_FILES,Dolphin_DB.UseSimpleSelectFolderDialog);
 If DirectoryExists(dir) then
 begin
  FormatDir(Dir);
  Edit2.Text:=dir+'Photo DataBase\DB';
 end;
end;

procedure TInstallForm.FormCreate(Sender: TObject);
var
  ProgramDir : string;
  hSemaphore : THandle;
  i, j : Integer;
begin
 QuickSelfInstall:=false;
 CheckBox6.Visible:=False;//TODO: delete FileExists(ProgramDir+'BdeInst.dll');

 Label1.Caption:=ProductName;
 hSemaphore := CreateSemaphore( nil, 0, 1, PWideChar(DBID));
 If ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) THEN
 begin
  MessageBoxDB(Handle,TEXT_MES_4,TEXT_MES_SETUP,TD_BUTTON_OK,TD_ICON_ERROR);
  Application.Terminate;
  DBTerminating:=True;
  OnClose:=nil;
  OnCloseQuery:=nil;
  Close;
  Exit;
 end;
 CloseHandle(hSemaphore);
 DoBeginInstall;
 UnitInstallThread.InstallDone:=true;
 try
  Memo1.Lines.LoadFromFile(GetDirectory(Application.ExeName)+'Licence.txt');
 except
  MessageBoxDB(Handle,TEXT_MES_LISENCE_FILE_BOT_FOUND,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  if not EmulationInstall then Halt;
 end;
 ProgramDir:=GetProgramFilesDir;
 UnFormatDir(ProgramDir);
 Edit1.text:=ProgramDir+'\Photo DataBase';
 Edit2.text:=StringReplace('%APPDATA%\DB','%APPDATA%',GetAppDataDirectory,[rfReplaceAll,rfIgnoreCase]);
 if InstalledUserName<>'' then
 Edit4.Text:=InstalledUserName else
 Edit4.Text:=TEXT_MES_NAMEA;

  ComboBox1.Enabled:=false;
  Edit3.Text:=TEXT_MES_NO_FILE;

 Edit3.Enabled:=False; //TODO: delete: BDEInstalled;

 If not Edit3.Enabled then
 Edit3.Text:=TEXT_MES_FILE_ONLY_MDB;//TEXT_MES_FILE_NOT_AVALIABLE_BDE;
 CheckListBox1.Items.Clear;
 For i:=1 to Length(SupportedExt) do
 begin
  if SupportedExt[i]='|' then
  for j:=i to length(SupportedExt) do
  begin
   If SupportedExt[j]='|' then
   If (j-i-1>0) and (i+1<length(SupportedExt)) then
   if (AnsiUpperCase(copy(SupportedExt,i+1,j-i-1))<>'') then
   begin
    CheckListBox1.Items.Add(AnsiUpperCase(copy(SupportedExt,i+1,j-i-1)));
    Break;
   end;
  end;
 end;
 Default1Click(Sender);
 LoadLanguage;
end;

procedure TInstallForm.Button2Click(Sender: TObject);
begin
 If ID_OK=MessageBoxDB(Handle,TEXT_MES_QUIT_SETUP,TEXT_MES_SETUP,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  OnCloseQuery:=nil;
  Close;
 end;
end;

procedure TInstallForm.CheckBox1Click(Sender: TObject);
begin
 Button7.Enabled:=CheckBox1.Checked;
end;

procedure TInstallForm.Button1Click(Sender: TObject);
Var
  i: Integer;
  DBDataDir : string;
begin
 If Edit4.Text=TEXT_MES_NAMEA then
 begin
  MessageBoxDB(Handle,TEXT_MES_ENTER_NAME_ERROR,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  Edit4.SetFocus;
  Edit4.SelectAll;
  Exit;
 end;
 If IsNewVersion then
 begin
  If ID_OK<>MessageBoxDB(Handle,TEXT_MES_PROG_IS_NEW,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
  exit;
 end else
 If IsInstalledApplication then
 begin
  If ID_OK<>MessageBoxDB(Handle,TEXT_MES_PROG_IS,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
  exit;
 end;
 DBDataDir:=StringReplace(Edit2.text,'%APPDATA%',GetAppDataDirectory,[rfReplaceAll,rfIgnoreCase]);
 try
  CreateDirA(Edit1.text);
  CreateDirA(DBDataDir);
 except
 end;
 If not DirectoryExists(Edit1.text) then
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_DIR_CR_FAILED,[Edit1.text]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  exit;
 end;
 If not DirectoryExists(DBDataDir) then
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_DIR_CR_FAILED,[DBDataDir]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  exit;
 end;
 OnCloseQuery:=nil;
 InstallForm.Close;
 InstallForm.Hide;
 Application.ProcessMessages;
 UnitInstallThread.OnDone:=SetupProgressUnit.SetupProgressForm.Done;
 UnitInstallThread.MovePrivate:=CheckBox2.Checked;
 UnitInstallThread.FEndDirectory:=Edit1.text;
 UnitInstallThread.FEndDBDirectory:=DBDataDir;
 UnitInstallThread.FDBFile:=Edit3.text;
 UnitInstallThread.InstUserName:=Edit4.text;
 UnitInstallThread.InstallBDEAnyway:=CheckBox6.Checked and CheckBox6.Visible;
 UnitInstallThread.DBType:=ComboBox1.ItemIndex;
 UnitInstallThread.QuickSelfInstall:=QuickSelfInstall;
 SetLength(UnitInstallThread.Exts,CheckListBox1.Items.Count);
 For i:=1 to CheckListBox1.Items.Count do
 begin
  UnitInstallThread.Exts[i-1].Ext:=CheckListBox1.Items[i-1];
  Case CheckListBox1.State[i-1] of
   cbUnchecked:  UnitInstallThread.Exts[i-1].InstallType:=InstallType_UnChecked;
   cbChecked:  UnitInstallThread.Exts[i-1].InstallType:=InstallType_Checked;
   cbGrayed:  UnitInstallThread.Exts[i-1].InstallType:=InstallType_Grayed;
  end;
 end;
 InstallThread.Create(false);
 Close;
 if SetupProgressForm=nil then
 Application.CreateForm(TSetupProgressForm, SetupProgressForm);
 SetupProgressForm.ShowModal;
 SetupProgressForm.Release;
 if UseFreeAfterRelease then
 SetupProgressForm.Free;
 SetupProgressForm:=nil;
end;

procedure TInstallForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 if UnitInstallThread.InstallDone then exit;
 Button2Click(Sender);
end;

procedure TInstallForm.Edit3KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#8 then
 begin
  Edit3.Text:=TEXT_MES_NO_FILE;
  CheckBox2.Checked:=false;
  CheckBox2.Enabled:=false;
 end;
 if key=#13 then Button7Click(Sender);
end;

procedure TInstallForm.CheckAll1Click(Sender: TObject);
var
  i : integer;
begin
 For i:=1 to CheckListBox1.Items.Count do
 CheckListBox1.State[i-1]:=cbChecked;
end;

procedure TInstallForm.UnCheckAll1Click(Sender: TObject);
var
  i : integer;
begin
 For i:=1 to CheckListBox1.Items.Count do
 CheckListBox1.State[i-1]:=cbUnChecked;
end;

procedure TInstallForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 If (Msg.hwnd=CheckBox3.Handle) or (Msg.hwnd=CheckBox4.Handle) or (Msg.hwnd=CheckBox5.Handle) then
 begin
  If Msg.message<>15 then
  If Msg.message<>512 then
  If Msg.message<>675 then
  If Msg.message<>514 then
  begin

  end;
  If Msg.message=513 then Msg.message:=0;
  If Msg.message=515 then Msg.message:=0;
 end;
end;

procedure TInstallForm.Default1Click(Sender: TObject);
Var
  i : Integer;
  Reg : TRegistry;
  S : String;
begin
 Reg:=TRegistry.Create;
 Reg.RootKey:=Windows.HKEY_CLASSES_ROOT;
 For i:=1 to CheckListBox1.Items.Count do
 begin
  Reg.OpenKey('\.'+CheckListBox1.Items[i-1],false);
  S:=Reg.ReadString('');
  Reg.CloseKey;
  Reg.OpenKey('\'+S+'\shell\open\command',false);
  If reg.ReadString('')='' then
  CheckListBox1.State[i-1]:=cbChecked else
  begin
   if FileRegisteredOnInstalledApplication(reg.ReadString('')) then
   CheckListBox1.State[i-1]:=cbChecked else
   CheckListBox1.State[i-1]:=cbGrayed;      
  end;
  Reg.CloseKey;
 end;
 Reg.Free;
end;

procedure TInstallForm.Button7Click(Sender: TObject);
begin
 Step1.Hide;
 Step2.Show;
 Button6.Show;
 Button7.Hide;
 Button1.Show;
 Edit4.SetFocus;
 Edit4.SelectAll;
end;

procedure TInstallForm.Button6Click(Sender: TObject);
begin
 Step2.Hide;
 Step1.Show;
 Button6.Hide;
 Button7.Show;
 Button1.Hide;
end;

procedure TInstallForm.LoadLanguage;
begin
 Label5.Caption:=TEXT_MES_ENTER_NAME+':';
 Label6.Caption:=TEXT_MES_SUPPORTED_TYPES;
 Label7.Caption:=TEXT_MES_SUPPORTED_TYPES_CHECKED;
 Label8.Caption:=TEXT_MES_SUPPORTED_TYPES_GRAYED;
 Label9.Caption:=TEXT_MES_SUPPORTED_TYPES_UNCHECKED;
 Label10.Caption:=TEXT_MES_TO_INSTALL;
 CheckAll1.Caption:=TEXT_MES_CHECK_ALL;
 UnCheckAll1.Caption:=TEXT_MES_UNCHECK_ALL;
 Default1.Caption:=TEXT_MES_DEFAULT;
 Button6.Caption:=TEXT_MES_BACK;
 Button7.Caption:=TEXT_MES_NEXT;
 Button2.Caption:=TEXT_MES_EXIT_SETUP;
 Button1.Caption:=TEXT_MES_INSTALL;
 Caption:=TEXT_MES_INSTALL_CAPTION;
 CheckBox1.Caption:=TEXT_MES_I_ACCEPT;
 Label2.Caption:=TEXT_MES_END_FOLDER;
 Label3.Caption:=TEXT_MES_END_DB_FOLDER;
 Label4.Caption:=TEXT_MES_DEF_DB;
 CheckBox2.Caption:=TEXT_MES_MOVE_PRIVATE;
 CheckBox6.Caption:=TEXT_MES_INSTALL_BDE_ANYWAY;
 Label11.Caption:=TEXT_MES_DB_TYPE;
end;

procedure TInstallForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  If ID_OK=MessageBoxDB(Handle,TEXT_MES_QUIT_SETUP,TEXT_MES_SETUP,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then CanClose:=True else CanClose:=false;
end;

procedure TInstallForm.Edit4KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#13 then
 Button1Click(Sender);
end;

procedure TInstallForm.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#13 then Button7Click(Sender);
end;

procedure TInstallForm.ComboBox1Select(Sender: TObject);
begin
 if ComboBox1.ItemIndex=1 then
 begin
  MessageBoxDB(Handle,TEXT_MES_DB_IS_OLD_DB,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
 end;
end;

procedure TInstallForm.SetQuickSelfInstallOption;
begin
 //TODO: remove this option.
 QuickSelfInstall:=true;
 //???ProgramDir:=GetProgramFilesDir;
 //?UnFormatDir(ProgramDir);
 Edit1.Text:=GetDirectory(Application.ExeName);
 Edit1.Enabled:=false;
 Edit2.text:='%APPDATA%\DB';
end;

end.
