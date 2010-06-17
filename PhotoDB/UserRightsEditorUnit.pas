unit UserRightsEditorUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ExtCtrls, UnitDBKernel, Dolphin_DB,
  Language;

type
  TUserRightEditorForm = class(TForm)
    CheckListBox1: TCheckListBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  FUserName : String;
    { Private declarations }
  public
  procedure Execute(UserName : String);
    { Public declarations }
  end;

procedure ChangeAccessToUser(UserName : String);

implementation

{$R *.dfm}

procedure ChangeAccessToUser(UserName : String);
var
  UserRightEditorForm: TUserRightEditorForm;
begin
 Application.CreateForm(TUserRightEditorForm,UserRightEditorForm);
 UserRightEditorForm.Execute(UserName);
 UserRightEditorForm.Release;
 if UseFreeAfterRelease then UserRightEditorForm.Free;
end;

{ TUserRightEditorForm }

procedure TUserRightEditorForm.Execute(UserName: String);
var
  Access : String;
  i, res : integer;
begin
{ FUserName:=UserName;
 res:=DBKernel.GetUserAccess(UserName,Access);
 if res<>LOG_IN_OK then
 begin
  DBKernel.LoginErrorMsg(res);
  exit;
 end;
 for i:=1 to CheckListBox1.Count do
 CheckListBox1.Checked[i-1]:=Access[i]='1';
 Label1.Caption:=Format(TEXT_MES_SELECT_RIGHTS_F,[UserName]);
 ShowModal; }
end;

procedure TUserRightEditorForm.Button1Click(Sender: TObject);
var
  Access : String;
  i, res : integer;
begin
{ Access:='0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
 for i:=1 to CheckListBox1.Count do
 begin
  if CheckListBox1.Checked[i-1] then Access[i]:='1' else Access[i]:='0';
 end;
 res:=DBKernel.SetUserAccess(FUserName,Access);
 if res<>LOG_IN_OK then
 begin
  DBKernel.LoginErrorMsg(res);
  exit;
 end;
 Close;  }
end;

procedure TUserRightEditorForm.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TUserRightEditorForm.FormCreate(Sender: TObject);
begin
 Button2.Caption:=TEXT_MES_CANCEL;
 Button1.Caption:=TEXT_MES_OK;
 Caption:=TEXT_MES_USER_CHANGE_ACCESS;
 CheckListBox1.Clear;
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_DELETE);        //  fUserRights.Delete:=fDBUserAccess[1]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_ADD);           //  fUserRights.Add:=fDBUserAccess[2]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_SET_PRIVATE); //  fUserRights.SetPrivate:=fDBUserAccess[3]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_CHANGE_PASSWORD);  //   fUserRights.ChPass:=fDBUserAccess[4]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_EDIT_IMAGE);     //   fUserRights.EditImage:=fDBUserAccess[5]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_SET_RATING);      //   fUserRights.SetRating:=fDBUserAccess[6]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_SET_INFO); //   fUserRights.SetInfo:=fDBUserAccess[7]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_SHOW_PRIVATE);     //   fUserRights.ShowPrivate:=fDBUserAccess[8]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_SHOW_OPTIONS);   //    fUserRights.ShowOptions:=fDBUserAccess[9]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_ADMIN_TOOLS);   //    fUserRights.ShowAdminTools:=fDBUserAccess[10]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_CHANGE_DB_NAME);     //    fUserRights.ChDbName:=fDBUserAccess[11]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_CRITICAL_FILE_OPERATIONS); // fUserRights.FileOperationsCritical:=fDBUserAccess[12]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_MANAGE_GROUPS);  //  fUserRights.ManageGroups:=fDBUserAccess[13]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_NORMAL_FILE_OPERATIONS);    //  fUserRights.FileOperationsNormal:=fDBUserAccess[14]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_EXECUTE);         //  fUserRights.Execute:=fDBUserAccess[15]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_CRYPT);         // fUserRights.Crypt:=fDBUserAccess[16]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_SHOW_PATH);         // fUserRights.Crypt:=fDBUserAccess[17]='1';
 CheckListBox1.Items.Add(TEXT_MES_RIGHTS_PRINT);         // fUserRights.Crypt:=fDBUserAccess[18]='1';
end;


end.
