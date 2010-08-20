unit UnitPasswordForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, FormManegerUnit, GraphicCrypt, Language, DB,
  uVistaFuncs, win32crc, Menus, Clipbrd, UnitDBDeclare;

type
 PasswordType = integer;

Const
 PASS_TYPE_IMAGE_FILE  = 0;
 PASS_TYPE_IMAGE_BLOB  = 1;
 PASS_TYPE_IMAGE_STENO = 2;
 PASS_TYPE_IMAGES_CRC  = 3;

type
  TPassWordForm = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Button3: TButton;
    InfoListBox: TListBox;
    Button4: TButton;
    PopupMenu1: TPopupMenu;
    CopyText1: TMenuItem;
    Label2: TLabel;
    PopupMenu2: TPopupMenu;
    CloseDialog1: TMenuItem;
    Skipthisfiles1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure LoadLanguage;
    procedure Button2Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure CopyText1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CloseDialog1Click(Sender: TObject);
    procedure Skipthisfiles1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure InfoListBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      aRect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
  public
    FFileName : String;
    Password : String;
    DB : TField;
    UseAsk : Boolean;
    fCRC : Cardinal;
    fOpenedList : boolean;
    DialogType : PasswordType;
    Skip : boolean;
    PassIcon : TIcon;
    procedure ReallignControlsEx;
    procedure LoadFileList(FileList : TArStrings);
    { Public declarations }
  end;

function GetImagePasswordFromUser(FileName : String) : String;
function GetImagePasswordFromUserBlob(DF : TField; FileName : String) : String;
function GetImagePasswordFromUserEx(FileName : String; out AskAgain : boolean) : String;
function GetImagePasswordFromUserStenoraphy(FileName : string; CRC : Cardinal) : String;
function GetImagePasswordFromUserForManyFiles(FileList : TArStrings; CRC : Cardinal; var Skip : boolean) : String;

implementation

{$R *.dfm}

function GetImagePasswordFromUserForManyFiles(FileList : TArStrings; CRC : Cardinal; var Skip : boolean) : String;
var
  PassWordForm: TPassWordForm;
begin
 Application.CreateForm(TPassWordForm, PassWordForm);
 PassWordForm.FFileName:='';
 PassWordForm.DB:=nil;
 PassWordForm.Label1.Caption:=TEXT_MES_MANY_FALES_PASSWORD_INFO;
 PassWordForm.fCRC:=CRC;
 PassWordForm.DialogType:=PASS_TYPE_IMAGES_CRC;
 PassWordForm.UseAsk:=false;
 PassWordForm.ReallignControlsEx;  
 PassWordForm.LoadFileList(FileList);
 PassWordForm.Skip:=Skip;
 PassWordForm.ShowModal;
 Skip:=PassWordForm.Skip;
 Result:=PassWordForm.Password;
 PassWordForm.Release;
 if UseFreeAfterRelease then PassWordForm.Free;
end;

function GetImagePasswordFromUser(FileName : String) : String;
var
  PassWordForm: TPassWordForm;
begin
 Application.CreateForm(TPassWordForm, PassWordForm);
 PassWordForm.FFileName:=FileName;
 PassWordForm.DB:=nil;
 PassWordForm.Label1.Caption:=format(TEXT_MES_ENTER_PASS_HERE,[Mince(FileName,30)]);
 PassWordForm.UseAsk:=false;
 PassWordForm.DialogType:=PASS_TYPE_IMAGE_FILE;
 PassWordForm.ReallignControlsEx;
 PassWordForm.ShowModal;
 Result:=PassWordForm.Password;
 PassWordForm.Release;
 if UseFreeAfterRelease then PassWordForm.Free;
end;

function GetImagePasswordFromUserEx(FileName : String; out AskAgain : boolean) : String;
var
  PassWordForm: TPassWordForm;
begin
 Application.CreateForm(TPassWordForm, PassWordForm);
 PassWordForm.FFileName:=FileName;
 PassWordForm.DB:=nil;
 PassWordForm.UseAsk:=true;
 PassWordForm.DialogType:=PASS_TYPE_IMAGE_FILE;
 PassWordForm.ReallignControlsEx;
 PassWordForm.Label1.Caption:=format(TEXT_MES_ENTER_PASS_HERE,[Mince(FileName,30)]);
 PassWordForm.ShowModal;
 AskAgain:=not PassWordForm.CheckBox3.Checked;
 Result:=PassWordForm.Password;
 PassWordForm.Release;
 if UseFreeAfterRelease then PassWordForm.Free;
end;

function GetImagePasswordFromUserBlob(DF : TField; FileName : String) : String;
var
  PassWordForm: TPassWordForm;
begin
 Application.CreateForm(TPassWordForm, PassWordForm);
 PassWordForm.FFileName:='';
 PassWordForm.DB:=DF;
 PassWordForm.UseAsk:=false;
 PassWordForm.DialogType:=PASS_TYPE_IMAGE_BLOB;
 PassWordForm.ReallignControlsEx;
 PassWordForm.Label1.Caption:=format(TEXT_MES_ENTER_PASS_HERE,[Mince(FileName,30)]);
 PassWordForm.ShowModal;
 Result:=PassWordForm.Password;
 PassWordForm.Release;
 PassWordForm.Free;
end;

function GetImagePasswordFromUserStenoraphy(FileName : string; CRC : Cardinal) : String;
var
  PassWordForm: TPassWordForm;
begin
 Application.CreateForm(TPassWordForm, PassWordForm);
 PassWordForm.FFileName:=FileName;
 PassWordForm.DB:=nil;
 PassWordForm.UseAsk:=false;
 PassWordForm.fCRC:=CRC;           
 PassWordForm.DialogType:=PASS_TYPE_IMAGE_STENO;
 PassWordForm.ReallignControlsEx;
 PassWordForm.Label1.Caption:=format(TEXT_MES_ENTER_PASS_HERE,[Mince(FileName,30)]);
 PassWordForm.ShowModal;
 Result:=PassWordForm.Password;
 PassWordForm.Release;
 PassWordForm.Free;
end;

procedure TPassWordForm.FormCreate(Sender: TObject);
begin
 fOpenedList:=false;
 ClientHeight:=Button2.Top+Button2.Height+5;
 DBKernel.RecreateThemeToForm(Self);
 CheckBox1.Checked:=DBKernel.Readbool('Options','AutoSaveSessionPasswords',true);
 CheckBox2.Checked:=DBKernel.Readbool('Options','AutoSaveINIPasswords',false);
 LoadLanguage;
 Password:='';
  PassIcon := TIcon.Create;
  PassIcon.Handle := LoadIcon(DBKernel.IconDllInstance, PWideChar('PASSWORD'));
end;

procedure TPassWordForm.LoadLanguage;
begin
 Caption:=TEXT_MES_PASSWORD_NEEDED;
 Label1.Caption:=TEXT_MES_ENTER_PASS_HERE;
 Button1.Caption:=TEXT_MES_CANCEL;
 Button2.Caption:=TEXT_MES_OK;
 CheckBox1.Caption:=TEXT_MES_SAVE_PASS_SESSION;
 CheckBox2.Caption:=TEXT_MES_SAVE_PASS_IN_INI_DIRECTORY;
 CheckBox3.Caption:=TEXT_MES_ASK_AGAIN;
 Button3.Caption:=TEXT_MES_SHOW_PASSWORD_FILE_LIST;
 Label2.Caption:=TEXT_MES_PASSWORD_FILE_LIST_INFO;
 CloseDialog1.Caption:=TEXT_MES_CLOSE_DIALOG;      
 Skipthisfiles1.Caption:=TEXT_MES_SKIP_THIS_FILES;  
 Button4.Caption:=TEXT_MES_CLOSE_PASSWORD_FILE_LIST;
 CopyText1.Caption:=TEXT_MES_COPY_TEXT;
end;

procedure TPassWordForm.Button2Click(Sender: TObject);

 function TEST : Boolean;
 var
   crc : Cardinal;
 begin
  Result:=false;
  if (DialogType=PASS_TYPE_IMAGE_STENO) or (DialogType=PASS_TYPE_IMAGES_CRC) then
  begin
   CalcStringCRC32(Edit1.Text,crc);
   Result:=crc=fCRC;
   exit;
  end;
  if FFileName<>'' then Result:=ValidPassInCryptGraphicFile(FFileName,Edit1.Text);
  if DB<>nil then Result:=ValidPassInCryptBlobStreamJPG(DB,Edit1.Text);
 end;

begin
 if TEST then
 begin
  Password:=Edit1.Text;
  if CheckBox1.Checked then DBKernel.AddTemporaryPasswordInSession(Password);
  if CheckBox2.Checked then DBKernel.SavePassToINIDirectory(Password);
  Close;
 end else
 begin
  MessageBoxDB(Handle,TEXT_MES_PASSWORD_INVALID,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
end;

procedure TPassWordForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then
 begin
  Key:=#0;
  Button2Click(Sender);
 end;
 if Key=#27 then
 begin
  Password:='';
  Close;
 end;
end;

procedure TPassWordForm.Button1Click(Sender: TObject);
var
  p : TPoint;
begin
 if (DialogType=PASS_TYPE_IMAGES_CRC) then
 begin
  p.x:=Button1.Left;
  p.y:=Button1.Top+Button1.Height;
  p:=ClientToScreen(p);
  PopupMenu2.Popup(p.x,p.y);
 end else
 begin
  Password:='';
  Close;
 end;
end;

procedure TPassWordForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#27 then
 begin
  Password:='';
  Close;
 end;
end;

procedure TPassWordForm.ReallignControlsEx;
begin
 if not UseAsk then
 begin
  CheckBox3.Visible:=false;
  Button1.Top:=CheckBox2.Top+CheckBox2.Height+3;
  Button2.Top:=CheckBox2.Top+CheckBox2.Height+3;
  CheckBox1.Enabled:=CheckBox1.Enabled and not (DialogType=PASS_TYPE_IMAGE_STENO) and not (DialogType=PASS_TYPE_IMAGES_CRC);
  CheckBox2.Enabled:=CheckBox2.Enabled and not (DialogType=PASS_TYPE_IMAGE_STENO);
  CheckBox3.Enabled:=CheckBox3.Enabled and not (DialogType=PASS_TYPE_IMAGE_STENO);

  if (DialogType=PASS_TYPE_IMAGES_CRC) then CheckBox1.Checked:=true;
  if (DialogType=PASS_TYPE_IMAGES_CRC) then
  begin
   Label1.Height:=50;
   Edit1.Top:=Label1.Top+Label1.Height+3;
   CheckBox1.Top:=Edit1.Top+Edit1.Height+5;
   CheckBox2.Top:=CheckBox1.Top+CheckBox1.Height+3;
   CheckBox3.Top:=CheckBox2.Top;//+CheckBox2.Height+3; //invisible
   Button1.Top:=CheckBox3.Top+CheckBox3.Height+3;
   Button2.Top:=CheckBox3.Top+CheckBox3.Height+3;
   Button3.Top:=CheckBox3.Top+CheckBox3.Height+3;
   Label2.Top:=Button3.Top+Button3.Height+3;
   InfoListBox.Top:=Label2.Top+Label2.Height+3;
  end;
  ClientHeight:=Button2.Top+Button2.Height+3;
 end;
end;

procedure TPassWordForm.CopyText1Click(Sender: TObject);
begin
 TextToClipboard(InfoListBox.Items.Text);
end;

procedure TPassWordForm.LoadFileList(FileList: TArStrings);
var
  i : integer;
begin
 for i:=0 to Length(FileList)-1 do
 begin
  InfoListBox.Items.Add(FileList[i]);
 end;
 Button3.Visible:=true;
 InfoListBox.Visible:=true;
 Label2.Visible:=true;
 Button4.Visible:=true;
 CheckBox1.Enabled:=false;
 CheckBox3.Enabled:=true;
end;

procedure TPassWordForm.Button3Click(Sender: TObject);
begin
 if fOpenedList then
 begin
  fOpenedList:=false;
  ClientHeight:=Button3.Top+Button3.Height+3;
  InfoListBox.Visible:=false;
  Button4.Visible:=false;
  Label2.Visible:=false;
 end else
 begin
  fOpenedList:=true;
  ClientHeight:=Button4.Top+Button4.Height+3;
  InfoListBox.Visible:=true;
  Button4.Visible:=true;
  Label2.Visible:=true;
 end;
end;

procedure TPassWordForm.CloseDialog1Click(Sender: TObject);
begin
 Password:='';
 Close;
end;

procedure TPassWordForm.Skipthisfiles1Click(Sender: TObject);
begin 
 Password:='';
 Close;
 Skip:=true;
end;

procedure TPassWordForm.Button4Click(Sender: TObject);
begin
 fOpenedList:=false;
 ClientHeight:=Button3.Top+Button3.Height+3;
 InfoListBox.Visible:=false;
 Button4.Visible:=false;    
 Label2.Visible:=false;
end;

procedure TPassWordForm.InfoListBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
 Height:=InfoListBox.Canvas.TextHeight('Iy')*3+5;
end;

procedure TPassWordForm.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; aRect: TRect; State: TOwnerDrawState);
var
  ListBox : TListBox;
begin
 ListBox:=Control as TListBox;
 if odSelected in State then
 ListBox.Canvas.Brush.Color:=$A0A0A0 else
 ListBox.Canvas.Brush.Color:=ClWhite;
 //clearing rect
 ListBox.Canvas.Pen.Color:=ListBox.Canvas.Brush.Color;
 ListBox.Canvas.Rectangle(aRect);

 ListBox.Canvas.Pen.Color:=ClBlack;
 ListBox.Canvas.Font.Color:=ClBlack;
 Text:=ListBox.Items[index];

 DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,PassIcon.Handle,16,16,0,0,DI_NORMAL);
 aRect.Left:=aRect.Left+20;
 DrawText(ListBox.Canvas.Handle,PWideChar(Text),Length(Text), aRect,DT_NOPREFIX+DT_LEFT+DT_WORDBREAK);

end;

end.
