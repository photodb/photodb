unit AddForm;

interface    

uses
  UnitDBKernel, dolphin_db, dm, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, DmProgress, DB, ADODB,
  ExtCtrls,  DragDrop, EnumFmt,FileDrop, ActiveX, Menus, SaveWindowPos, shellapi;

type
  TForm4 = class(TForm)
    ShellTreeView1: TShellTreeView;
    SaveWindowPos1: TSaveWindowPos;
    PopupMenu1: TPopupMenu;
    Shell1: TMenuItem;
    Show1: TMenuItem;
    SearchForIt1: TMenuItem;
    Property1: TMenuItem;
    N1: TMenuItem;
    AddFile1: TMenuItem;
    Private1: TMenuItem;
    Copy1: TMenuItem;
    ShellChangeNotifier1: TShellChangeNotifier;
    Rotate1: TMenuItem;
    Rating1: TMenuItem;
    N01: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    None1: TMenuItem;
    N90CW1: TMenuItem;
    N1801: TMenuItem;
    N90CCW1: TMenuItem;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Label_type: TLabel;
    Label_width: TLabel;
    Label3: TLabel;
    Label_height: TLabel;
    Label4: TLabel;
    Name_label: TLabel;
    Label5: TLabel;
    id_label: TLabel;
    Edit1: TEdit;
    Memo1: TMemo;
    Edit2: TEdit;
    Panel2: TPanel;
    LabelFolder: TLabel;
    LabelFileName: TLabel;
    DmProgress1: TDmProgress;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure recreatetheme(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadImageInfo(filename_ : string);
    procedure EndAdding(Sender: TObject);
    procedure BeginAdding(Sender: TObject);
    procedure DoAdding(Sender: TObject);
    procedure TerminateAdding(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure SearchForIt1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Property1Click(Sender: TObject);
    procedure ChangedDBDataByIDAdd(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure registrID;
    procedure unregistrID;
    procedure Private1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure ShellChangeNotifier1Change;
    procedure N01Click(Sender: TObject);
    procedure None1Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  menu_image_th : Tpopupmenu;
  notcreating : boolean = false;
  CurrentRecord : TOneRecordInfo;

implementation

uses Searching, adddatathreadunit, UnitThCreator, SlideShow,
  PropertyForm;

{$R *.dfm}

procedure TForm4.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
 begin
  LoadImageInfo(ShellTreeView1.Path);
 end;
 LabelFolder.Caption:=ShellTreeView1.Path;
end;

procedure TForm4.recreatetheme(Sender: TObject);
begin
 self.color:=Theme_MainColor;
 self.font.color:=Theme_MainFontColor;
 ShellTreeView1.color:= Theme_ListColor;
 ShellTreeView1.font.color:= Theme_ListfontColor;
 memo1.color:=Theme_memoeditcolor;
 edit1.color:=Theme_memoeditcolor;
 edit2.color:=Theme_memoeditcolor;
 memo1.Font.Color:=Theme_memoeditfontcolor;
 edit1.Font.Color:=Theme_memoeditfontcolor;
 edit2.Font.Color:=Theme_memoeditfontcolor;
end;

procedure TForm4.FormCreate(Sender: TObject);
var {icons : array [1..8] of ticon; }  i:integer;
begin
 PopupMenu1.Images:=DBKernel.imageList;
 Shell1.ImageIndex:=DB_IC_SHELL;
 Show1.ImageIndex:=DB_IC_SLIDE_SHOW;
 Copy1.ImageIndex:=DB_IC_COPY_ITEM;
 Private1.ImageIndex:=DB_IC_PRIVATE;
 SearchForIt1.ImageIndex:=DB_IC_SEARCH;
 Property1.ImageIndex:=DB_IC_PROPERTIES;
 AddFile1.ImageIndex:=DB_IC_NEW;
 Rotate1.ImageIndex:=DB_IC_ROTETED_0;
 Rating1.ImageIndex:=DB_IC_RATING_STAR;

 None1.ImageIndex:=DB_IC_ROTETED_0;
 N90CW1.ImageIndex:=DB_IC_ROTETED_90;
 N1801.ImageIndex:=DB_IC_ROTETED_180;
 N90CCW1.ImageIndex:=DB_IC_ROTETED_270;
 N01.ImageIndex:=DB_IC_DELETE_INFO;
 N11.ImageIndex:=DB_IC_RATING_1;
 N21.ImageIndex:=DB_IC_RATING_2;
 N31.ImageIndex:=DB_IC_RATING_3;
 N41.ImageIndex:=DB_IC_RATING_4;
 N51.ImageIndex:=DB_IC_RATING_5;

 EndAdding(Sender);
 recreatetheme(sender);
 SaveWindowPos1.SetPosition;
 CurrentRecord.ItemId:=0;
 notcreating:=true;
 DBKernel.RegisterChangesID(self,ChangedDBDataByID);
end;

procedure TForm4.LoadImageInfo(filename_: string);
begin
 CurrentRecord.ItemRotate:=0;
 UnitThCreator.fImage:=image1;
 UnitThCreator.work_.Add(filename_);
 ThCreator.create(false);
end;

procedure TForm4.EndAdding(Sender: TObject);
var EventInfo : TEventValues;
begin
 DmProgress1.Text:='Done';
 DmProgress1.MaxValue:=1000;
 DmProgress1.Position:=0;
 Button1.Caption:='Add';
 AddFile1.OnClick:=DoAdding;
 AddFile1.Caption:='Add File';
 Button1.OnClick:=DoAdding;
 ShellTreeView1Change(Sender,nil);
 EventInfo.ID:=CurrentRecord.ItemId;
 DBKernel.DoIDEvent(Sender,CurrentRecord.ItemId,[EventID_Param_Add],EventInfo);
end;

procedure TForm4.BeginAdding(Sender: TObject);
begin
 Button1.Caption:='Stop!';
 AddFile1.OnClick:=TerminateAdding;
 AddFile1.Caption:='Stop!';
 Button1.OnClick:=TerminateAdding;
end;

procedure TForm4.DoAdding(Sender: TObject);
begin
 if AddDataThreadUnit.active then exit;
 AddDataThreadUnit.OnEndThread:=EndAdding;
 beginadding(sender);
 AddDataThreadUnit.Addfile_:=fileexists(ShellTreeView1.Path);
 AddDataThreadUnit.FolderName_:=ShellTreeView1.Path;
 AddDataThreadUnit.FileName_:=ShellTreeView1.Path;
 AddDataThreadUnit.KeyWords_:=memo1.Text;
 AddDataThreadUnit.Collection_:=edit2.text;
 AddDataThreadUnit.Owner_:=edit1.text;
 AddDataThread.Create(false);
end;

procedure TForm4.TerminateAdding(Sender: TObject);
begin
 if AddDataThreadUnit.terminated_ then exit;
 if id_ok=Application.MessageBox('Do you really wont to break this operation?','Confirm',mb_okcancel+mb_iconinformation) then
 AddDataThreadUnit.terminated_:=true;
 repeat
  delay(1);
 until not AddDataThreadUnit.active;
 Button1.Caption:='Add';
 Button1.OnClick:=DoAdding;
 AddFile1.OnClick:=DoAdding;
 AddFile1.Caption:='Add File';
end;

procedure TForm4.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DropSource : TFileDropSource;
  DropData : THDropDataObject;
  rslt : HRESULT;
  dwEffect : integer;
  DropPoint : TPoint;
  files_:Tstrings;  i:integer;
begin
  if (Button = mbLeft) then
  begin
    if not (fileexists(ShellTreeView1.Path) or directoryexists(ShellTreeView1.Path)) then exit;
    DropSource := TFileDropSource.Create;
    DropPoint.x := 0;
    DropPoint.y := 0;
    DropData := THDropDataObject.Create
    (DropPoint, True);
    DropData.Add(ShellTreeView1.Path);
    rslt := DoDragDrop(DropData, DropSource,
    DROPEFFECT_COPY, dwEffect);

    if ((rslt <> DRAGDROP_S_DROP) and
        (rslt <> DRAGDROP_S_CANCEL)) then
    begin
      case rslt of
        E_OUTOFMEMORY : ShowMessage('Out of memory');
        else ShowMessage('Something bad happened');
      end;
    end;

//   DropSource.Free;
//   DropData.Free;
  end;

end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
 SaveWindowPos1.SavePosition;
end;

procedure TForm4.Shell1Click(Sender: TObject);
begin
 ShellExecute(0, Nil,Pchar(ShellTreeView1.Path), Nil, Nil, SW_NORMAL);
end;

procedure TForm4.SearchForIt1Click(Sender: TObject);
begin
 if CurrentRecord.ItemId<>0 then
 form2.Edit1.Text:=inttostr(CurrentRecord.ItemId)+'$';
 form2.DoSearchNow(Sender);
end;

procedure TForm4.Show1Click(Sender: TObject);
var file_ : tstrings; tar, trot : tarinteger;
Info: TRecordsInfo;
begin
 if FileExists(CurrentRecord.ItemFileName) then
 begin
  If CurrentRecord.ItemId<>0 then
  begin
   Info:=GetRecordsFromOne(CurrentRecord);
   Form3.Execute(Sender,Info);
  end else begin
   Form3.ShowFolderA(CurrentRecord.ItemFileName);
  end;
 end;
end;

procedure TForm4.PopupMenu1Popup(Sender: TObject);
begin
 Show1.Visible:=extinmask('|BMP|JPG|JPEG|',getext(CurrentRecord.ItemFileName));
 Property1.Visible:=extinmask('|BMP|JPG|JPEG|',getext(CurrentRecord.ItemFileName));
 Shell1.Visible:=fileexists(CurrentRecord.ItemFileName) or directoryexists(CurrentRecord.ItemFileName);
 Copy1.Visible:=fileexists(CurrentRecord.ItemFileName) or directoryexists(CurrentRecord.ItemFileName);
end;

procedure TForm4.Property1Click(Sender: TObject);
begin
 if Form6=nil then Application.CreateForm(TForm6, Form6);
 if CurrentRecord.ItemId<>0 then
 Form6.execute(CurrentRecord.ItemId) else
 Form6.ExecuteFileNoEx(CurrentRecord.ItemFileName);
end;

procedure TForm4.ChangedDBDataByIDAdd(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
begin
 if visible then ShellTreeView1Change(Sender,nil);
end;

procedure TForm4.registrID;
begin
 DBKernel.RegisterChangesIDbyID(self,ChangedDBDataByIDAdd,CurrentRecord.ItemId);
end;

procedure TForm4.unregistrID;
begin
 DBKernel.UnRegisterChangesIDbyID(self,ChangedDBDataByIDAdd,CurrentRecord.ItemId);
end;

procedure TForm4.Private1Click(Sender: TObject);
var EventInfo : TEventValues;
begin
 if not dbkernel.UserRights.SetPrivate then exit;
 if Private1.ImageIndex<>DB_IC_COMMON then
 begin
  SetPrivate(CurrentRecord.ItemId);
  EventInfo.Access:=db_access_private;
  DBKernel.DoIDEvent(Sender,CurrentRecord.ItemId,[EventID_Param_Private],EventInfo);
 end else begin
  UnSetPrivate(CurrentRecord.ItemId);
  EventInfo.Access:=db_access_none;
  DBKernel.DoIDEvent(Sender,CurrentRecord.ItemId,[EventID_Param_Private],EventInfo);
 end;
end;

procedure TForm4.Copy1Click(Sender: TObject);
begin
 CopyFilesToClipboard(CurrentRecord.ItemFileName);
end;

procedure TForm4.ShellChangeNotifier1Change;
begin
 if notcreating then ShellTreeView1Change(nil,nil);
end;

procedure TForm4.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
begin
 if ID=CurrentRecord.ItemId then
 ShellTreeView1Change(Sender,nil);
end;

procedure TForm4.N01Click(Sender: TObject);
var str:string;
 EventInfo : TEventValues;
begin
 if sender is tmenuitem then
 With sender as tmenuitem do
 begin
  str:=(sender as tmenuitem).caption;
  system.delete(str,1,1);
  SetRating(CurrentRecord.ItemId,strtoint(str));
  EventInfo.Rating:=strtoint(str);
  DBKernel.DoIDEvent(Sender,CurrentRecord.ItemId,[EventID_Param_Rating],EventInfo);
 end;
end;

procedure TForm4.None1Click(Sender: TObject);
var EventInfo : TEventValues;
begin
 setrotate(CurrentRecord.ItemId,(sender as Tmenuitem).tag);
 EventInfo.Rotate:=(sender as Tmenuitem).tag;
 DBKernel.DoIDEvent(Sender,CurrentRecord.ItemId,[EventID_Param_Rotate],EventInfo);
end;

procedure TForm4.FormDblClick(Sender: TObject);
begin
 ShellTreeView1.Refresh(ShellTreeView1.Selected);
end;

end.
