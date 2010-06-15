unit login;

interface

uses
  DBCMenu, UnitDBKernel, crypt, Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms, UnitINI, uVistaFuncs,
  Dialogs, StdCtrls, ExtCtrls, jpeg, DB, DBTables, Menus;

type
  TLoginForm = class(TForm)
    Image1: TImage;
    HelpTimer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CreateLoginDB(filename : string);
    procedure LoadNicks(Sender: TObject);
    procedure NewUser(Sender: TObject);
    procedure ChangeUser(Sender: TObject);
    procedure ChangeUserAccess(Sender: TObject);
    procedure DeleteUser(Sender: TObject);
    procedure LogIn_(Sender : TObject);
    procedure OnKeyPress_(Sender: TObject; var Key: Char);
    procedure OnContextPopup_(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure execute;
    procedure FormDestroy(Sender: TObject);
    procedure canceldefuser(Sender: TObject);
    procedure chclicked(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpTimer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

   procedure wmmousedown(var s : Tmessage); message wm_lbuttondown;

    { Private declarations }
  public

    { Public declarations }
  end;

var         
  LoginForm: TLoginForm;
  arim : array of timage;
  ared : array of tedit;
  arlb : array of tlabel;
  arbt : array of tbutton;
  arcb : array of tcheckbox;
  PopUp : TPopupmenu;
  Menu_ChangePass, Menu_Delete, Menu_Add, Menu_CancelAsDefault, Menu_ChangeAccess : TMenuItem;
  DefaultUserName  :string;

implementation

uses Dolphin_DB, CreateUserUnit, Language, UserRightsEditorUnit, UnitHelp,
     CommonDBSupport, UnitFormLoginModeChooser;

{$R *.dfm}

{ TForm8 }

procedure TLoginForm.wmmousedown(var s: Tmessage);
begin
  perform(wm_nclbuttondown,HTcaption,s.lparam);
end;

procedure TLoginForm.FormCreate(Sender: TObject);
begin
 DBkernel.RecreateThemeToForm(Self);
 SetLength(arim,0);
 SetLength(ared,0);
 SetLength(arlb,0);
 SetLength(arbt,0);
 SetLength(arcb,0);
 Caption := TEXT_MES_LOG_ON_CAPTION;
end;

procedure TLoginForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//close;
end;

procedure TLoginForm.CreateLoginDB(filename : string);
begin
 DBkernel.CreateLoginDB;
end;

procedure TLoginForm.LoadNicks(Sender: TObject);
var
  nn, n, i : integer;
  fbs : TStream;
  J : TJpegImage;
  fQuery : TDataSet;
begin
 fQuery:=GetQuery(DBKernel.GetLoginDataBaseFileName);

 for i:=0 to length(ArIm)-1 do
 begin
  freeandnil(arim[i]);
  freeandnil(ared[i]);
  freeandnil(arlb[i]);
  freeandnil(arbt[i]);
  freeandnil(arcb[i]);
 end;

 if DBKernel.TestLoginDB then
 begin
  fQuery.Active:=false;

  SetSQL(fQuery,'Select * from '+DBKernel.GetLoginDataBaseName);
  try
   fQuery.Active:=true;
   n:=fQuery.RecordCount;
  except   
   on e : Exception do
   begin
    EventLog(':TLoginForm::LoadNicks() throw exception: '+e.Message);
    n:=0;
   end;
  end;
 end else
 begin
  DBTerminating:=True;
  Application.Terminate;
  FreeDS(fQuery);
  Exit;
 end;
 if DBTerminating then
 begin
  FreeDS(fQuery);
  exit;
 end;
 SetLength(arim,n);
 SetLength(ared,n);
 SetLength(arlb,n);
 SetLength(arbt,n);
 SetLength(arcb,n);
 nn:=-1;
 fQuery.First;
 for i:=0 to n-1 do
 begin
  inc(nn);
  arim[nn]:=timage.create(self);
  arim[nn].Parent:=self;
  arim[nn].Name:='IMG'+inttostr(nn);
  arim[nn].Left:=5;
  arim[nn].width:=48;
  arim[nn].height:=48;
  arim[nn].top:=50*nn+5;
  arim[nn].Center:=true;
  arim[nn].OnContextPopup:=OnContextPopup_;
  begin
   arim[nn].Picture:=tpicture.create;
   arim[nn].Picture.Graphic:=tjpegimage.Create;
   J:=TJpegImage.create;
   if TBlobField(fQuery.FieldByName('FIMAGE'))=nil then exit;
   fbs:=GetBlobStream(fQuery.FieldByName('FIMAGE'),bmRead);
   try
    if fbs.Size<>0 then
    J.loadfromStream(fbs) else
   except
   end;
   fbs.Free;
   arim[nn].Picture.Assign(J);
   J.Free;
  end;
  arlb[nn]:=TLabel.create(self);
  arlb[nn].Parent:=self;
  arlb[nn].Left:= arim[nn].Width+15;
  arlb[nn].Top:=50*nn+5;
  arlb[nn].Width:=121;
  arlb[nn].Height:=35;
  arlb[nn].Font.Name:='Comic Sans MS';
  arlb[nn].Font.Size:=12;
  arlb[nn].Font.Color:=0;
  if UpcaseAll(Trim(fQuery.FieldByName('LOGO').AsString))<>UpcaseAll(TEXT_MES_ADMIN) then
  arlb[nn].caption:=Trim(fQuery.FieldByName('LOGO').AsString)
  else arlb[0].caption:=TEXT_MES_ADMIN;
  arlb[nn].ParentColor:=true;
  ared[nn]:=tedit.create(self);
  ared[nn].Parent:=self;
  ared[nn].Name:='ED_'+inttostr(nn);
  ared[nn].Left:= arim[nn].Width+12;
  ared[nn].top:=50*nn+5+arlb[nn].height;
  ared[nn].width:=150;
  ared[nn].height:=26;
  ared[nn].Font.Name:='Comic Sans MS';
  ared[nn].Font.Size:=10;
  ared[nn].Font.Color:=0;
  ared[nn].text:='Password';
  ared[nn].ParentColor:=true;
  ared[nn].PasswordChar:='*';
  ared[nn].OnKeyPress:=OnKeyPress_;
  arbt[nn]:=tbutton.create(self);
  arbt[nn].Parent:=self;
  arbt[nn].Name:='BTN'+inttostr(nn);
  arbt[nn].Left:= arim[nn].Width+15+ared[nn].Width;
  arbt[nn].top:=50*nn+5+arlb[nn].height;
  arbt[nn].width:=50;
  arbt[nn].height:=26;
  arbt[nn].caption:=TEXT_MES_LOG_ON;
  arbt[nn].OnClick:=LogIn_ ;
  arcb[nn]:=tcheckbox.create(self);
  arcb[nn].Parent:=self;
  arcb[nn].caption:=TEXT_MES_AUTO_LOG_ON;
  arcb[nn].width:=80;
  arcb[nn].Left:=arbt[nn].left+arbt[nn].width-arcb[nn].Width;
  arcb[nn].top:=50*nn+5;
  arcb[nn].height:=20;
  arcb[nn].OnClick:=chclicked;
  if (arlb[nn].caption<>'') and (defaultusername=arlb[nn].caption) then arcb[nn].Checked:=true;
  fQuery.Next;
 end;
 fQuery.Close;
 FreeDS(fQuery);
 if (nn<Length(arim)) and (nn>-1) then
 begin
  Clientheight:=arim[nn].Top+arim[nn].Height+5;
  ClientWidth:=arbt[nn].Width+arbt[nn].left+5;
 end;
end;

procedure TLoginForm.NewUser(Sender: TObject);
begin
 if NewSingleUserForm=nil then
 Application.CreateForm(TNewSingleUserForm, NewSingleUserForm);
 NewSingleUserForm.Execute(true,'','',0,nil);
 NewSingleUserForm.Release;
 if UseFreeAfterRelease then NewSingleUserForm.Free;
 NewSingleUserForm:=nil;
 try
  LoadNicks(Sender);
 except 
   on e : Exception do EventLog(':TLoginForm.NewUser()/LoadNicks throw exception: '+e.Message);
 end;
end;

procedure TLoginForm.LogIn_(Sender: TObject);
var
  n, reslongin : integer;
  s : string;
  Reg : TBDRegistry;
begin
 s:=(Sender as tcomponent).Name;
 delete(s,1,3);
 n:=strtoint(s);
 reslongin:=DBKernel.LogIn(arlb[n].Caption,ared[n].Text,arcb[n].Checked);
 case reslongin of
  LOG_IN_OK :
  begin
   Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
   Reg.OpenKey(RegRoot+'HelpSystem',true);
   Reg.WriteString('HelpLogIn','false');
   Reg.Free;
   OnClose:=nil;
   ResultLogin:=true;
   Close;
  end else
  begin
   DBKernel.LoginErrorMsg(reslongin);
   ared[n].SetFocus;
   ared[n].SelectAll;
  end;
 end;
end;

procedure TLoginForm.OnKeyPress_(Sender: TObject; var Key: Char);
var
  n : integer;
  s : string;
begin
 if Key=#13 then
 begin
  Key:=#0;
  s:=(Sender as tcomponent).Name;
  delete(s,1,3);
  n:=strtoint(s);
  LogIn_(arbt[n]);
 end;
end;

procedure TLoginForm.OnContextPopup_(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  n : integer;
  S : string;
begin
  S:=(Sender as tcomponent).Name;
  Delete(s,1,3);
  n:=StrToInt(S);
  if dbkernel.DBUserType<>UtAdmin then
  if Arlb[n].Caption<>DBKernel.DBUserName then exit;
  Popup:=TPopupMenu.Create(self);
  if DBkernel.UserRights.ChPass then
  begin
   Menu_ChangePass := TMenuItem.Create(PopUp);
   Menu_ChangePass.Caption:=TEXT_MES_CH_USER;
   Menu_ChangePass.Tag:=n;
   Menu_ChangePass.OnClick:=ChangeUser;
  end;
  if DBKernel.DBUserType=UtAdmin then
  begin
   Menu_Add := TMenuItem.Create(PopUp);
   Menu_Add.Caption:=TEXT_MES_ADD_NEW_USER;
   Menu_Add.OnClick:=newuser;
   if n<>0 then
   begin
    Menu_Delete := TMenuItem.Create(PopUp);
    Menu_Delete.Caption:=TEXT_MES_DEL_USER;
    Menu_Delete.OnClick:=DeleteUser;
    menu_delete.Tag:=n;
    Menu_ChangeAccess:= TMenuItem.Create(PopUp);
    Menu_ChangeAccess.Caption:=TEXT_MES_USER_CHANGE_ACCESS;
    Menu_ChangeAccess.OnClick:=ChangeUserAccess;
    Menu_ChangeAccess.Tag:=n;
   end;
  end;
  if ArCb[n].Checked and ((DBKernel.DBUserType=UtAdmin) or ((DBKernel.DBUserType<>UtAdmin) and (DefaultUserName=DBKernel.DBUserName))) then
  begin
   Menu_CancelAsDefault := TMenuItem.Create(PopUp);
   Menu_CancelAsDefault.Caption:=TEXT_MES_CANCEL_AS_DEF;
   Menu_CancelAsDefault.OnClick:=CancelDefUser;
   Menu_CancelAsDefault.Tag:=n;
  end;
  if DBkernel.UserRights.ChPass then
  Popup.Items.Add(Menu_ChangePass);
  if arcb[n].Checked and ((Dbkernel.DBUserType=UtAdmin) or ((Dbkernel.DBUserType<>UtAdmin) and (DefaultUserName=DBKernel.DBUserName))) then
  Popup.Items.Add(Menu_CancelAsDefault);
  if dbkernel.DBUserType=UtAdmin then
  begin
   if n<>0 then
   begin
    Popup.Items.Add(Menu_ChangeAccess);
    Popup.Items.Add(Menu_Delete);
   end;
   Popup.Items.Add(Menu_Add);
  end;
  Popup.Popup((Sender as timage).ClientToScreen(MousePos).x,(Sender as timage).ClientToScreen(MousePos).y);
  Popup.FreeOnRelease;
  Popup:=nil;
end;

procedure TLoginForm.Execute;
Var
  S1, S2 : string;
  r : integer;
  Reg : TBDRegistry;
  NoUserMode : boolean;
begin
 DBKernel.TryToLoadDefaultUser(s1,s2);
 DefaultUserName := S1;
 r:=DBKernel.CheckAdmin;
 if r<>LOG_IN_OK then
 begin
  if not DBKernel.TestLoginDB then
  DBKernel.CreateLoginDB;  
  NoUserMode:=DoSelectLoginMode;
  r:=DBKernel.CheckAdmin;
  if r<>LOG_IN_OK then
  begin
   if NewSingleUserForm=nil then
   Application.CreateForm(TNewSingleUserForm, NewSingleUserForm);
   NewSingleUserForm.ExecuteAdmin;
   if NewSingleUserForm<>nil then
   NewSingleUserForm.Release;
   if UseFreeAfterRelease then NewSingleUserForm.Free;
   NewSingleUserForm:=nil;
   ResultLogin:=false;
  end else
  begin
   if NoUserMode then
   begin
    if DBKernel.LogIn(Language.TEXT_MES_ADMIN,'',true)=LOG_IN_OK then
    begin
     ResultLogin:=true;
     exit;
    end;
   end;
  end;
 end;
 LoadNicks(nil);
 Application.Restore;

 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 Reg.OpenKey(RegRoot+'HelpSystem',true);
 if Reg.ReadString('HelpLogIn')<>'false' then
 begin
  HelpTimer1.Enabled:=true;
 end;
 Reg.Free;
 ShowModal;
end;

procedure TLoginForm.DeleteUser(Sender: TObject);
var
  DUserName : string;
begin
 DUserName:=arlb[(Sender as tmenuitem).tag].Caption;
 if ID_OK=MessageBoxDB(Handle,Format(TEXT_MES_DEL_USER_CONFIRM,[dUserName]),TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 DBKernel.DeleteUser(DUserName);
 LoadNicks(Sender);
end;

procedure TLoginForm.FormDestroy(Sender: TObject);
var
  i : integer;
begin
 for i:=0 to length(arim)-1 do
 begin
  freeandnil(arim[i]);
  freeandnil(ared[i]);
  freeandnil(arlb[i]);
  freeandnil(arbt[i]);
  freeandnil(arcb[i]);
 end;
end;

procedure TLoginForm.ChangeUser(Sender: TObject);
begin
 if NewSingleUserForm=nil then
 Application.CreateForm(TNewSingleUserForm, NewSingleUserForm);
 NewSingleUserForm.Execute(false,arlb[(Sender as tmenuitem).tag].Caption,ared[(Sender as tmenuitem).tag].text,(Sender as tmenuitem).tag,arim[(Sender as tmenuitem).tag].picture.graphic as tjpegimage);
 NewSingleUserForm.Release;
 if UseFreeAfterRelease then NewSingleUserForm.Free;
 NewSingleUserForm:=nil;
 try
  LoadNicks(Sender);
 except 
   on e : Exception do EventLog(':TLoginForm.ChangeUser()/LoadNicks throw exception: '+e.Message);
 end;
end;

procedure TLoginForm.CancelDefuser(Sender: TObject);
begin
 DBKernel.CancelUserAsDefault;
 if arcb[(Sender as tmenuitem).tag]<>nil then
 arcb[(Sender as tmenuitem).tag].Checked:=false;
end;

procedure TLoginForm.chclicked(Sender: TObject);
var
  i : integer;
  TNTF : TNotifyEvent;
begin
 for i:=0 to length(arcb)-1 do
 if (arcb[i]<>Sender) and (arcb[i]<>nil) then
 begin
  tntf:=arcb[i].OnClick;
  arcb[i].OnClick:=nil;
  arcb[i].Checked:=false;
  arcb[i].OnClick:=tntf;
 end;
end;

procedure TLoginForm.FormShow(Sender: TObject);
begin
 Application.Restore;
 ShowWindow(Handle,SW_SHOW);
 SetFocus;
end;

procedure TLoginForm.ChangeUserAccess(Sender: TObject);
begin
 ChangeAccessToUser(arlb[(Sender as tmenuitem).tag].Caption);
end;

procedure TLoginForm.HelpTimer1Timer(Sender: TObject);
begin
 if not Active then exit;
 HelpTimer1.Enabled:=false;
 DoHelpHint(TEXT_MES_HELP_HINT,TEXT_MES_HELP_LOGIN,Point(0,0),ared[0]);
end;

procedure TLoginForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

end.

