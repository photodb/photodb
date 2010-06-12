unit UnitEditLinkForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, UnitLinksSupport, Language, ExtDlgs, GraphicEx,
  acDlgSelect, DropSource, DropTarget, Dolphin_DB, ComCtrls, ImgList,
  UnitDBKernel, DragDrop, DragDropFile, uVistaFuncs, ComboBoxExDB,
  UnitDBFileDialogs;

type
  TFormEditLink = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label4: TLabel;
    DropFileTarget1: TDropFileTarget;
    DestroyTimer: TTimer;
    Edit2: TMemo;
    LinkImageList: TImageList;
    ComboBox1: TComboBoxExDB;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit1Change(Sender: TObject);
    procedure ComboBox1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  FProc : TSetLinkProcedure;
  FOnClose : TRemoteCloseFormProc;
  FInfo : TLinksInfo;
  FN : integer;
  FAdd : Boolean;
    { Private declarations }
  public
  Procedure Execute(Add : Boolean; var info : TLinksInfo; Proc : TSetLinkProcedure; OnClose : TRemoteCloseFormProc);
  Procedure LoadLanguage;
    { Public declarations }
  end;

function AddNewLink(Add : Boolean; var info : TLinksInfo; Proc : TSetLinkProcedure; OnClose : TRemoteCloseFormProc) : TForm;

implementation

{$R *.dfm}

function AddNewLink(Add : Boolean; var info : TLinksInfo; Proc : TSetLinkProcedure; OnClose : TRemoteCloseFormProc) : TForm;
var
  FormEditLink: TFormEditLink;
begin
 Application.CreateForm(TFormEditLink, FormEditLink);
 FormEditLink.Execute(Add,info,Proc,OnClose);
 Result:=FormEditLink;
end;

{ TFormEditLink }

procedure TFormEditLink.Execute(Add: Boolean; var info: TLinksInfo; Proc : TSetLinkProcedure; OnClose : TRemoteCloseFormProc);
var
  i : integer;
begin
 FOnClose:=OnClose;
 FProc:=Proc;
 FAdd:=Add;
 FInfo:=CopyLinksInfo(info);
 if Add then
 begin
  Caption:=TEXT_MES_ADD_LINK;
 end else
 begin
  FN:=0;
  for i:=0 to Length(FInfo)-1 do
  if (FInfo[i].Tag and LINK_TAG_SELECTED)<>0 then
  begin
   FN:=i;
   Break;
  end;
  ComboBox1.ItemIndex:=FInfo[FN].LinkType;
  Edit1.Text:=FInfo[FN].LinkName;
  if FInfo[FN].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT=0 then
  Edit2.Text:=FInfo[FN].LinkValue else
  Edit2.Text:=TEXT_MES_VAR_VALUES;
  Caption:=TEXT_MES_EDIT_LINK;
 end;
 Show;
end;

procedure TFormEditLink.FormCreate(Sender: TObject);
var
  SmallB : TBitmap;
  icon : TIcon;
  i : integer;
begin
 LoadLanguage;
 DropFileTarget1.Register(self);
 LinkImageList.Clear;
 for i:=LINK_TYPE_ID to LINK_TYPE_TXT do
 begin
  SmallB := TBitmap.Create;
  SmallB.PixelFormat:=pf24bit;
  SmallB.Width:=16;
  SmallB.Height:=16;
  SmallB.Canvas.Pen.Color:=ClWindow;//Theme_MainColor;
  SmallB.Canvas.Brush.Color:=ClWindow;//Theme_MainColor;
  SmallB.Canvas.Rectangle(0,0,16,16);
  case i of
  LINK_TYPE_ID : Icon:=UnitDBKernel.Icons[DB_IC_SLIDE_SHOW+1];
  LINK_TYPE_ID_EXT : Icon:=UnitDBKernel.Icons[DB_IC_NOTES+1];
  LINK_TYPE_IMAGE : Icon:=UnitDBKernel.Icons[DB_IC_DESKTOP+1];
  LINK_TYPE_FILE : Icon:=UnitDBKernel.Icons[DB_IC_SHELL+1];
  LINK_TYPE_FOLDER : Icon:=UnitDBKernel.Icons[DB_IC_DIRECTORY+1];
  LINK_TYPE_TXT : Icon:=UnitDBKernel.Icons[DB_IC_TEXT_FILE+1];
   else Icon:=nil;
  end;
  if Icon<>nil then
  DrawIconEx(SmallB.Canvas.Handle,0,0,Icon.Handle,16,16,0,0,DI_NORMAL);
  LinkImageList.Add(SmallB,nil);
  SmallB.Free;
 end;

 ComboBox1.Items.Add(LINK_TEXT_TYPE_ID);
 ComboBox1.Items.Add(LINK_TEXT_TYPE_ID_EXT);
 ComboBox1.Items.Add(LINK_TEXT_TYPE_IMAGE);
 ComboBox1.Items.Add(LINK_TEXT_TYPE_FILE);
 ComboBox1.Items.Add(LINK_TEXT_TYPE_FOLDER);
 ComboBox1.Items.Add(LINK_TEXT_TYPE_TXT);
 for i:=LINK_TYPE_ID to LINK_TYPE_TXT do
 ComboBox1.ItemsEx[i].ImageIndex:=i;
 ComboBox1.ItemIndex:=0;
 DBkernel.RecreateThemeToForm(self);
 //no HTML support
 //ComboBox1.Items.Add(LINK_TEXT_TYPE_HTML);
end;

procedure TFormEditLink.Button3Click(Sender: TObject);
begin
 Close;
end;

procedure TFormEditLink.LoadLanguage;
begin
 Label4.Caption:=TEXT_MES_LINK_FORM_CAPTION;
 Label1.Caption:=TEXT_MES_LINK_TYPE;
 Label2.Caption:=TEXT_MES_LINK_NAME;
 Label3.Caption:=TEXT_MES_LINK_VALUE;
 Button3.Caption:=TEXT_MES_CANCEL;
 Button2.Caption:=TEXT_MES_OK;

//
end;

procedure TFormEditLink.Button1Click(Sender: TObject);
var
  S : String;
  OpenDialog : DBOpenDialog;
  OpenPictureDialog : DBOpenPictureDialog;
begin
 
 Case ComboBox1.ItemIndex of
  LINK_TYPE_ID:
  begin               
   OpenPictureDialog:=DBOpenPictureDialog.Create;
   OpenPictureDialog.Filter:=Dolphin_DB.GetGraphicFilter;
   if OpenPictureDialog.Execute then
   begin
    Edit2.Text:=IntToStr(GetIdByFileName(OpenPictureDialog.FileName));
   end;   
   OpenPictureDialog.Free;
  end;
  LINK_TYPE_IMAGE:
  begin
   OpenPictureDialog:=DBOpenPictureDialog.Create;
   OpenPictureDialog.Filter:=Dolphin_DB.GetGraphicFilter;
   if OpenPictureDialog.Execute then Edit2.Text:=OpenPictureDialog.FileName;
   OpenPictureDialog.Free;
  end;
  LINK_TYPE_FILE:
  begin
   OpenDialog:=DBOpenDialog.Create;
   if OpenDialog.Execute then Edit2.Text:=OpenDialog.FileName;
   OpenDialog.Free;
  end;
  LINK_TYPE_FOLDER:
  begin
   S:=SelectDir(Application.Handle,TEXT_MES_SELECT_DIRECTORY);
   if S<>'' then Edit2.Text:=S;
  end;
  LINK_TYPE_ID_EXT:
  begin              
   OpenPictureDialog:=DBOpenPictureDialog.Create;
   OpenPictureDialog.Filter:=Dolphin_DB.GetGraphicFilter;
   if OpenPictureDialog.Execute then
   begin
    Edit2.Text:=CodeExtID(GetImageIDW(OpenPictureDialog.FileName,false).ImTh);  
    OpenPictureDialog.Free;
   end;
  end;
 end;
end;

procedure TFormEditLink.Button2Click(Sender: TObject);
var
  i : integer;
  Link : TLinkInfo;
begin
 if FAdd then
 begin
  for i:=0 to Length(FInfo)-1 do
  if (AnsiLowerCase(FInfo[i].LinkName)=AnsiLowerCase(Edit1.Text)) and (FInfo[i].LinkType=ComboBox1.ItemIndex) then
  begin
   MessageBoxDB(Handle,TEXT_MES_CANT_ADD_LINK_ALREADY_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   Exit;
  end;
  Link.LinkType:=ComboBox1.ItemIndex;
  Link.LinkName:=Edit1.Text;
  Link.LinkValue:=Edit2.Text;
  FProc(self,'',Link,0,LINK_PROC_ACTION_ADD);
 end else
 begin
  for i:=0 to Length(FInfo)-1 do
  if i<>FN then
  if (AnsiLowerCase(FInfo[i].LinkName)=AnsiLowerCase(Edit1.Text)) and (FInfo[i].LinkType=ComboBox1.ItemIndex) then
  begin
   MessageBoxDB(Handle,TEXT_MES_CANT_ADD_LINK_ALREADY_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   Exit;
  end;
  Link.LinkType:=ComboBox1.ItemIndex;
  Link.LinkName:=Edit1.Text;
  Link.LinkValue:=Edit2.Text;
  FProc(self,'',Link,FN,LINK_PROC_ACTION_MODIFY);
 end;
 Close;
end;

procedure TFormEditLink.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  S : String;
begin
 Case ComboBox1.ItemIndex of
  LINK_TYPE_ID:
  begin
   Edit2.Text:=IntToStr(GetIdByFileName(DropFileTarget1.Files[0]));
  end;
  LINK_TYPE_IMAGE:
  begin
   Edit2.Text:=DropFileTarget1.Files[0];
  end;
  LINK_TYPE_FILE:
  begin
   Edit2.Text:=DropFileTarget1.Files[0];
  end;
  LINK_TYPE_FOLDER:
  begin
   If DirectoryExists(DropFileTarget1.Files[0]) then S:=DropFileTarget1.Files[0] else
   S:=GetDirectory(DropFileTarget1.Files[0]);
   if S<>'' then Edit2.Text:=S;
  end;
  LINK_TYPE_ID_EXT:
  begin
   Edit2.Text:=CodeExtID(GetImageIDW(DropFileTarget1.Files[0],false).ImTh);
  end;
 end;
end;

procedure TFormEditLink.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
end;

procedure TFormEditLink.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 FOnClose(self,'');
 DestroyTimer.Enabled:=true;
end;

procedure TFormEditLink.Edit1Change(Sender: TObject);
var
  i : integer;
  S,SOld : String;
begin
 SOld:='';
 if Sender is TEdit then SOld:=TEdit(Sender).Text;
 if Sender is TMemo then SOld:=TMemo(Sender).Text;
 if SOld='' then Exit;
 S:=SOld;
 if Sender is TEdit then
 for i:=Length(s) downto 1 do
 if (s[i]='[') or (s[i]=']') or (s[i]='{') or (s[i]='}') then
 s[i]:='_';

 if Sender is TMemo then
 for i:=Length(s) downto 1 do
 if (s[i]=';') then
 s[i]:='_';

 if s<>sOld then
 begin
  if Sender is TEdit then TEdit(Sender).Text:=s;
  if Sender is TMemo then TMemo(Sender).Text:=s;
 end;
end;

procedure TFormEditLink.ComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
 if (Key='[') or (Key=']') or (Key='{') or (Key='}') then
 Key:='_';
end;

procedure TFormEditLink.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
 if (Key=';') then
 Key:='_';
end;

procedure TFormEditLink.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

end.
