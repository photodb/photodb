unit createuserunit;

interface

uses
  Windows, UnitDBKernel, Math, DB, DBTables, Menus, Dialogs, ExtDlgs,
  StdCtrls, Controls, ExtCtrls, jpeg, Classes, Messages, SysUtils, Variants, Graphics,
  Forms, Registry, GraphicSelectEx, UnitDBCommon, UnitDBCommonGraphics, uFileUtils,
  uConstants;

type
  TNewSingleUserForm = class(TForm)
    Image1: TImage;
    Edit1: TEdit;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    PopupMenu1: TPopupMenu;
    LoadFromFile1: TMenuItem;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Edit2: TEdit;
    Label2: TLabel;
    Edit3: TEdit;
    Label1: TLabel;
    Panel2: TPanel;
    Edit5: TEdit;
    Label3: TLabel;
    HelpTimer1: TTimer;
    GraphicSelect1: TGraphicSelectEx;
    procedure Button2Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Execute(add : boolean; name : string; pass:string; ID : integer; image : tjpegimage);
    procedure ExecuteAdmin;
    procedure Button1Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit5KeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure GraphicSelect1ImageSelect(Sender: TObject; Bitmap: TBitmap);
    procedure FormCreate(Sender: TObject);
    procedure RelodDllNames;
    procedure HelpTimer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

//var
//  NewSingleUserForm: TNewSingleUserForm;
//  AddUser_ : boolean;
//  ExAdmin_ : boolean;

implementation

uses Dolphin_DB, Language, UnitHelp;

{$R *.dfm}

procedure TNewSingleUserForm.Button2Click(Sender: TObject);
begin
{ if ExAdmin_ then
 begin
  DBTerminating:=True;
  Application.Terminate;
 end else
 close; }
end;

procedure TNewSingleUserForm.Image1Click(Sender: TObject);
var
  p : Tpoint;
begin
{  GetCursorPos(p);
  GraphicSelect1.RequestPicture(p.X,p.y);    }
end;

procedure TNewSingleUserForm.Execute(Add : boolean; Name : string; Pass : string; ID : integer; Image : TJpegImage);
var
  jpg : tjpegimage;
begin
{ AddUser_:=add;
 ExAdmin_:=false;
 Edit2.Text:='';
 Edit3.Text:='';
 RadioButton1.Checked:=false;
 if add then
 begin
  Caption:=TEXT_MES_ADD_USER_CAPTION;
  panel2.Visible:=false;
  panel1.Top:=panel2.Top;
  Label1.Caption:=TEXT_MES_PASSWORD;
  Edit1.ReadOnly:=false;
  Height:=249-panel2.height;
  ShowModal;
 end else
 begin
  Caption:=TEXT_MES_CH_USER_CAPTION;
  panel2.Visible:=true;
  panel1.Top:=112;
  Label1.Caption:=TEXT_MES_NEW_PASSWORD;
  Edit1.Text:=name;
  Edit1.ReadOnly:=true;
  self.Height:=249;
  jpg:=nil;
  DBKernel.LoadUserImage(name,jpg);
  if jpg<>nil then
  begin
   Image1.Picture.Graphic.Assign(jpg);
   jpg.free;
  end else Image1.Picture.Graphic.Assign(image);
  ShowModal;
 end;    }
end;

procedure TNewSingleUserForm.Button1Click(Sender: TObject);
var
  Result_ : integer;
begin
{ if ExAdmin_ then
 begin
  Result_:=DBKernel.CreateNewUser(TEXT_MES_ADMIN,Edit2.text,image1.Picture.Graphic as TJpegImage);
  case result_ of
   LOG_IN_OK:
    begin
     ResultLogin:=true;
     OnClose:=nil;
     Close;
    end;
   else DBKernel.LoginErrorMsg(result_);
  end;
  Exit;
 end;
 if AddUser_ then
 begin
  Result_:=DBKernel.CreateNewUser(Edit1.text,Edit2.text,image1.Picture.Graphic as tjpegimage);
  case Result_ of
   LOG_IN_OK:
   begin
    OnClose:=nil;
    close;
   end;
   else DBKernel.LoginErrorMsg(result_);
  end;
 end else
 begin
  result_:=DBKernel.UpdateUserInfo(Edit1.text,Edit5.text,Edit2.text,image1.Picture.Graphic as tjpegimage,true);
  case result_ of
   LOG_IN_OK:
   begin
    OnClose:=nil;
    Close;
   end;
   else DBKernel.LoginErrorMsg(result_);
  end;
 end;  }
end;

procedure TNewSingleUserForm.Edit2Change(Sender: TObject);
begin
 //Password can be empty => no login mode
 if {(edit1.text<>'') and (edit2.text<>'') and} (edit2.text=edit3.text) then
 Button1.Enabled:=true else  Button1.Enabled:=false;
end;

procedure TNewSingleUserForm.ExecuteAdmin;
begin
{ ExAdmin_:=true;
 Edit2.Text:='';
 Edit3.Text:='';
 Caption:=TEXT_MES_CREATE_ADMIN_CAPTION;
 Edit1.Text:=TEXT_MES_ADMIN;
 Panel2.Visible:=false;
 Panel1.Top:=RadioButton2.Top+RadioButton2.Height+7;
 Edit2.Top:=Label1.Top+Label1.Height+5;
 Label2.Top:=Edit2.Top+Edit2.Height+8;
 Edit3.Top:=Label2.Top+Label2.Height+5;
 Panel1.Height:=Edit3.Top+Edit3.Height+5;
 ClientHeight:=Panel1.Top+Panel1.Height+3;
 Button1.Top:=Panel1.Height-Button1.Height-5;
 Button2.Top:=Button1.Top-Button2.Height-5;
 Label1.Caption:=TEXT_MES_PASSWORD;
 Edit1.ReadOnly:=true;
 Radiobutton1.Checked:=true;
 HelpTimer1.Enabled:=true;
 ShowModal;
 ExAdmin_:=false;  }
end;

procedure TNewSingleUserForm.Edit5KeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then Button1Click(Sender);
end;

procedure TNewSingleUserForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
{ if ExAdmin_ then
 begin
  DBTerminating:=True;
  Application.Terminate;
 end;   }
end;

procedure TNewSingleUserForm.LoadFromFile1Click(Sender: TObject);
begin
 LoadNickJpegImage(Image1);
end;

procedure TNewSingleUserForm.GraphicSelect1ImageSelect(Sender: TObject;
  Bitmap: TBitmap);
var
  b : TBitmap;
  h, w : integer;
begin
 b:=TBitmap.Create;
 b.PixelFormat:=pf24bit;
 w:=Bitmap.Width;
 h:=Bitmap.Height;
 If Max(w,h)<48 then B.Assign(Bitmap) else
 begin
  ProportionalSize(48,48,w,h);
  DoResize(w,h,Bitmap,b);
 end;
 Image1.Picture.Graphic.Assign(b);
 b.free;
 Image1.Refresh;
end;

procedure TNewSingleUserForm.RelodDllNames;
var
  Found  : integer;
  SearchRec : TSearchRec;
  Directory : string;
  TS : tstrings;
begin
 Ts:= TStringList.Create;
 Ts.Clear;
 Directory:=ProgramDir;
 FormatDir(Directory);
 Directory:=Directory+PlugInImagesFolder;
 Found := FindFirst(Directory+'*.jpgc', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If FileExists(Directory+SearchRec.Name) then
   try
    if ValidJPEGContainer(Directory+SearchRec.Name) then
    TS.Add(Directory+SearchRec.Name);
   except
   end;
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 FindClose(SearchRec);
 GraphicSelect1.Galeries:=Ts;
 GraphicSelect1.Showgaleries:=true;
end;

procedure TNewSingleUserForm.FormCreate(Sender: TObject);
begin
 RelodDllNames;
 DBKernel.RecreateThemeToForm(Self);
 LoadLanguage;
end;

procedure TNewSingleUserForm.LoadLanguage;
begin
 LoadFromFile1.Caption:=TEXT_MES_LOAD_FROM_FILE;
 Button1.Caption:=TEXT_MES_OK;
 Button2.Caption:=TEXT_MES_CANCEL;
 Label1.Caption:=TEXT_MES_PASSWORD;
 Label3.Caption:=TEXT_MES_OLD_PASSWORD;
 Label2.Caption:=TEXT_MES_CONFIRM;
end;

procedure TNewSingleUserForm.HelpTimer1Timer(Sender: TObject);
begin
 if not Active then exit;
 HelpTimer1.Enabled:=false;
 DoHelpHint(TEXT_MES_HELP_HINT,TEXT_MES_HELP_CREATE_ADMIN,Point(0,0),Edit2);
end;

end.
