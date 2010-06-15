unit Options;

interface

uses
  Registry, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TabNotBk, DmProgress, ExtCtrls, CheckLst,
  Menus, ShellCtrls, Dolphin_DB, ImgList, Math, GDIPlusRotate, Mask,
  acDlgSelect, UnitDBKernel, SaveWindowPos, UnitINI, uVistaFuncs, UnitDBDeclare,
  UnitDBFileDialogs, WindowsIconCacheTools;

type
  TOptionsForm = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    RadioGroup1: TRadioGroup;
    Button6: TButton;
    ColorDialog1: TColorDialog;
    FontDialog1: TFontDialog;
    CancelButton: TButton;
    OkButton: TButton;
    PopupMenu1: TPopupMenu;
    Usethisprogramasdefault1: TMenuItem;
    Usemenuitem1: TMenuItem;
    Dontusethisextension1: TMenuItem;
    Panel1: TPanel;
    Shape6: TShape;
    Label8: TLabel;
    Shape7: TShape;
    Label9: TLabel;
    Shape2: TShape;
    Label4: TLabel;
    Shape1: TShape;
    Label1: TLabel;
    Label6: TLabel;
    Shape4: TShape;
    Shape3: TShape;
    Label7: TLabel;
    Shape5: TShape;
    Button9: TButton;
    Button8: TButton;
    Button10: TButton;
    Button11: TButton;
    StaticText1: TStaticText;
    Label5: TLabel;
    CheckBox1: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    Button12: TButton;
    CheckListBox1: TCheckListBox;
    ListBox1: TListBox;
    Button1: TButton;
    Label10: TStaticText;
    ShellChangeNotifier1: TShellChangeNotifier;
    Label13: TStaticText;
    Label12: TStaticText;
    Label14: TStaticText;
    ListView1: TListView;
    PopupMenu2: TPopupMenu;
    Addnewcommand1: TMenuItem;
    Remore1: TMenuItem;
    Button13: TButton;
    Button14: TButton;
    ImageList1: TImageList;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    GroupBox3: TGroupBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    Panel2: TPanel;
    Label24: TLabel;
    Image2: TImage;
    Label21: TLabel;
    Edit7: TEdit;
    Label23: TLabel;
    Edit8: TEdit;
    Button15: TButton;
    Button19: TButton;
    Button20: TButton;
    CheckBox2: TCheckBox;
    CheckBox13: TCheckBox;
    Edit1: TEdit;
    Button2: TButton;
    Panel3: TPanel;
    Label16: TLabel;
    Label26: TLabel;
    TrackBar4: TTrackBar;
    TrackBar3: TTrackBar;
    Panel4: TPanel;
    CheckBox16: TCheckBox;
    Button7: TButton;
    Edit5: TEdit;
    Edit9: TEdit;
    Label25: TLabel;
    Edit4: TEdit;
    Button5: TButton;
    Label18: TLabel;
    Edit6: TEdit;
    Label20: TLabel;
    Label19: TLabel;
    DestroyTimer: TTimer;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    CheckBox22: TCheckBox;
    CheckBox23: TCheckBox;
    CheckBox24: TCheckBox;
    Button21: TButton;
    CheckBox25: TCheckBox;
    TrackBar2: TTrackBar;
    Label22: TLabel;
    TrackBar1: TTrackBar;
    Label15: TLabel;
    Button22: TButton;
    CheckBox26: TCheckBox;
    CheckBox27: TCheckBox;
    Button23: TButton;
    Button24: TButton;
    CheckListBox2: TCheckListBox;
    Label11: TLabel;
    Label27: TLabel;
    PopupMenu3: TPopupMenu;
    Additem1: TMenuItem;
    DeleteItem1: TMenuItem;
    N1: TMenuItem;
    Up1: TMenuItem;
    Down1: TMenuItem;
    PlacesImageList: TImageList;
    PlacesListView: TListView;
    CheckBox28: TCheckBox;
    Bevel1: TBevel;
    Rename1: TMenuItem;
    N2: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    CheckBox29: TCheckBox;
    CheckBox30: TCheckBox;
    Shape8: TShape;
    Label28: TLabel;
    CheckBox31: TCheckBox;
    N3: TMenuItem;
    Default1: TMenuItem;
    CheckBox32: TCheckBox;
    Edit11: TEdit;
    CheckBox33: TCheckBox;
    Button25: TButton;
    CheckBox34: TCheckBox;
    Edit12: TEdit;
    Label31: TLabel;
    Edit13: TEdit;
    Label32: TLabel;
    GroupBox2: TGroupBox;
    Edit10: TEdit;
    Label30: TLabel;
    Label29: TLabel;
    CheckBox35: TCheckBox;
    GroupBox4: TGroupBox;
    Label17: TLabel;
    Image1: TImage;
    Button4: TButton;
    Button3: TButton;
    CheckBox15: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox36: TCheckBox;
    Shape9: TShape;
    Shape10: TShape;
    Shape11: TShape;
    Label2: TLabel;
    Label3: TLabel;
    Label33: TLabel;
    CheckBox5: TCheckBox;
    Edit2: TEdit;
    Label35: TLabel;
    Label34: TLabel;
    CheckBox37: TCheckBox;
    CheckBox38: TCheckBox;
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure Button6Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button9Click(Sender: TObject);
    procedure LoadCOlorsToWindow;
    procedure FormCreate(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure LoadColorsFromWindow;
    procedure Button11Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure CheckListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Usethisprogramasdefault1Click(Sender: TObject);
    procedure Usemenuitem1Click(Sender: TObject);
    procedure Dontusethisextension1Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure ShellChangeNotifier1Change;
    procedure Button1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure CheckBox13Click(Sender: TObject);
    procedure LoadExts;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Addnewcommand1Click(Sender: TObject);
    procedure Remore1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Button13Click(Sender: TObject);
    procedure Edit6KeyPress(Sender: TObject; var Key: Char);
    procedure Button16Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure PlacesListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button24Click(Sender: TObject);
    procedure ReadPlaces;
    procedure WritePlaces;
    procedure PlacesListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure CheckListBox2ClickCheck(Sender: TObject);
    procedure Button23Click(Sender: TObject);
    procedure DeleteItem1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure PlacesListViewEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure Default1Click(Sender: TObject);
    procedure CheckBox32Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure CheckBox33Click(Sender: TObject);
    procedure CheckBox34Click(Sender: TObject);
    procedure CheckBox36Click(Sender: TObject);
  private
  FThemeList : TStringList;
  FUserMenu : TUserMenuItemArray;
  FLoadedPages : array[0..5] of boolean;
  FPlaces : TPlaceFolderArray;
  ReloadData : boolean;
  protected
    procedure CreateParams(VAR Params: TCreateParams); override;
    { Private declarations }
  public
    procedure LoadLanguage;
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;

implementation

uses Language, CleaningForm, dbselectunit, login, SlideShow, ExplorerThreadUnit,
      ExplorerUnit, UnitJPEGOptions;

{$R *.dfm}

Procedure RelodThemesNamesW(var List : TStringList);
var
  Found  : integer;
  SearchRec : TSearchRec;
  Directory : string;
begin    
 List:= TStringList.Create;
 List.Clear;
 Directory:=ProgramDir;
 FormatDir(Directory);
 Directory:=Directory+ThemesDirectory;
 Found := FindFirst(Directory+'*.dbc', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If fileexists(Directory+SearchRec.Name) then
   List.Add(Directory+SearchRec.Name);
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 SysUtils.FindClose(SearchRec);
end;

procedure TOptionsForm.TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
var
  i, j : integer;
  Reg : TBDRegistry;
  S : TStrings;
  fCaption,EXEFile,Params,Icon : String;
  UseSubMenu : boolean;
  Ico : Ticon;
  RegIni: TRegIniFile;
begin
 if FLoadedPages[NewTab] then exit;
 FLoadedPages[NewTab]:=true;


 if NewTab=0 then
 begin
  Button6.Enabled:=not FolderView;
  CheckBox3.Checked:=DBKernel.Readbool('Options','ShowAnimateToHintWindow',false);
  CheckBox4.Checked:=DBKernel.Readbool('Options','AllowPreview',True);
  RadioGroup1.ItemIndex:=DBKernel.readinteger('Options','PreviewSwohOptions',0);

  CheckBox36.Checked:=DBKernel.Readbool('Options','UseWindowsTheme',True);
  ListBox1.Enabled:=not DBKernel.Readbool('Options','UseWindowsTheme',True);
 end;
 if NewTab=1 then
 begin
  CheckBox1.Checked:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
  CheckBox6.Checked:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
  CheckBox7.Checked:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
  CheckBox8.Checked:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False);
  CheckBox9.Checked:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
  CheckBox10.Checked:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
  CheckBox11.Checked:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
  CheckBox12.Checked:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
  CheckBox20.Checked:=DBKernel.ReadBool('Options','ShowEXIFMarker',false);
  CheckBox21.Checked:=DBKernel.ReadBool('Options','ShowOtherPlaces',true);
  CheckListBox1.Items.Clear;
  For i:=1 to Length(SupportedExt) do
  begin
   if SupportedExt[i]='|' then
   for j:=i to length(SupportedExt) do
   begin
    If SupportedExt[j]='|' then
    If (j-i-1>0) and (i+1<length(SupportedExt)) then
    if (copy(SupportedExt,i+1,j-i-1))<>'' then
    begin
     CheckListBox1.Items.Add(AnsiUppercase(copy(SupportedExt,i+1,j-i-1)));
     Break;
    end;
   end;
  end;
  LoadExts;
  ReadPlaces;
 end;
 if NewTab=2 then
 begin
  CheckBox37.Checked:=DBKernel.ReadBool('SlideShow','UseFastSlideShowImageLiading',true);

  CheckBox22.Checked:=DBKernel.Readbool('Options','NextOnClick',false);
  CheckBox24.Checked:=DBKernel.Readbool('Options','RotateWithoutPromt',true);
  CheckBox25.Checked:=DBKernel.Readbool('Options','RotateEvenIfFileInDB',true);

  TrackBar1.Position:=Min(Max(DBKernel.ReadInteger('Options','SlideShow_SlideSteps',25),1),100);
  TrackBar2.Position:=Min(Max(DBKernel.ReadInteger('Options','SlideShow_SlideDelay',40),1),100);
  TrackBar3.Position:=Min(Max(DBKernel.ReadInteger('Options','SlideShow_GrayScale',20),1),100);
  TrackBar4.Position:=Min(Max(DBKernel.ReadInteger('Options','FullScreen_SlideDelay',40),1),100);
  CheckBox2.Checked:=DBKernel.ReadboolW('Options','SlideShow_UseCoolStretch',True);
  CheckBox13.Checked:=DBKernel.ReadboolW('Options','SlideShow_UseExternelViewer',False);
  CheckBox13Click(Sender);
  TrackBar1Change(Sender);
  TrackBar2Change(Sender);
  TrackBar3Change(Sender);
  TrackBar4Change(Sender);
  Edit1.Text:=DBKernel.ReadStringW('Options','SlideShow_ExternelViewer');
 end;
 if NewTab=4 then
 begin
  CheckBox14.Checked:=DBKernel.Readbool('Options','AutoSaveSessionPasswords',true);
  CheckBox15.Checked:=DBKernel.Readbool('Options','AutoSaveINIPasswords',false); 
  Edit10.Text:=IntToStr(DBKernel.ReadInteger('Options','BackUpdays',7));
 end;

 if NewTab=5 then
 begin

  CheckBox38.Checked:=DBKernel.Readbool('Options','UseSmallToolBarButtons',false);
  CheckBox5.Checked:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
  Edit2.Text:=IntToStr(DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3));

  CheckBox26.Checked:=DBKernel.Readbool('Options','SortGroupsByName',true);
  CheckBox23.Checked:=DBKernel.Readbool('Options','UseHotSelect',true);
  CheckBox27.Checked:=DBKernel.Readbool('Options','UseGDIPlus',GDIPlusPresent);
  CheckBox28.Checked:=DBKernel.Readbool('Options','AllowManyInstancesOfProperty',true);
  CheckBox29.Checked:=DBKernel.Readbool('Options','UseMainMenuInSearchForm',true);
  CheckBox30.Checked:=DBKernel.ReadBool('Editor','VirtualCursor',false);
  CheckBox31.Checked:=DBKernel.ReadBool('Options','CheckUpdateLinks',false);

  CheckBox32.Checked:=DBKernel.ReadBool('Options','RunExplorerAtStartUp',false);
  CheckBox33.Checked:=DBKernel.ReadBool('Options','UseSpecialStartUpFolder',false);
  Edit11.text:=DBKernel.ReadString('Options','SpecialStartUpFolder');

  CheckBox35.Checked:=DBKernel.Readbool('Options','UseGroupsInSearch',true);
  if not DirectoryExists(Edit11.text) then
  begin
   RegIni := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
   Edit11.text:=RegIni.ReadString('Shell Folders', 'My Pictures', '');
   RegIni.Free;
  end;
  CheckBox33.Enabled:=CheckBox32.Checked;
  Edit11.Enabled:=CheckBox33.Checked and CheckBox33.Enabled;

  CheckBox34.Checked:=DBKernel.ReadBool('Options','NoAddSmallImages',true);
  Edit12.text:=IntToStr(DBKernel.ReadInteger('Options','NoAddSmallImagesWidth',64));
  Edit13.text:=IntToStr(DBKernel.ReadInteger('Options','NoAddSmallImagesHeight',64));
  Edit12.Enabled:=CheckBox34.Checked;
  Edit13.Enabled:=CheckBox34.Checked;
 end;

 if NewTab=3 then
 begin
  ImageList1.Clear;
  ImageList1.Width:=16;
  ImageList1.Height:=16;
  ImageList1.BkColor:=clmenu;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  Reg.OpenKey(GetRegRootKey+'\Menu',true);
  S := TStringList.create;
  Reg.GetKeyNames(S);
  SetLength(FUserMenu,0);
  ListView1.Clear;
  for i:=0 to S.Count-1 do
  begin
   Reg.CloseKey;
   Reg.OpenKey(GetRegRootKey+'\Menu'+s[i],true);
   UseSubMenu:=true;
   try
    if Reg.ValueExists('Caption') then
    fCaption:=Reg.ReadString('Caption');
    if Reg.ValueExists('EXEFile') then
    EXEFile:=Reg.ReadString('EXEFile');
    if Reg.ValueExists('Params') then
    Params:=Reg.ReadString('Params');
    if Reg.ValueExists('Icon') then
    Icon:=Reg.ReadString('Icon');
    if Reg.ValueExists('UseSubMenu') then
    UseSubMenu:=Reg.ReadBool('UseSubMenu');
   except
   end;
   if (fCaption<>'') and (EXEFile<>'') then
   begin
    SetLength(FUserMenu,Length(FUserMenu)+1);
    FUserMenu[Length(FUserMenu)-1].Caption:=fCaption;
    FUserMenu[Length(FUserMenu)-1].EXEFile:=EXEFile;
    FUserMenu[Length(FUserMenu)-1].Params:=Params;
    FUserMenu[Length(FUserMenu)-1].Icon:=Icon;
    FUserMenu[Length(FUserMenu)-1].UseSubMenu:=UseSubMenu;
    Ico:=GetSmallIconByPath(Icon);
    ImageList1.AddIcon(Ico);
    Ico.free;
    with ListView1.Items.Add do
    begin
     ImageIndex:=ImageList1.Count-1;
     Caption:=fCaption;
    end;
   end;
  end;
  S.free;
  Reg.free;
  CheckBox17.Checked:=DBKernel.ReadBool('Options','UseUserMenuForIDmenu',true);
  CheckBox19.Checked:=DBKernel.ReadBool('Options','UseUserMenuForViewer',true);
  CheckBox18.Checked:=DBKernel.ReadBool('Options','UseUserMenuForExplorer',true);
  Edit7.Text:=DBKernel.ReadString('','UserMenuName');
  if Edit7.Text='' then
  Edit7.Text:=TEXT_MES_USER_SUBMENU;
  Edit8.Text:=DBKernel.ReadString('','UserMenuIcon');
  if Edit8.Text='' then
  Edit8.Text:='%SystemRoot%\system32\shell32.dll,126';
  Image2.Picture.Icon:=GetSmallIconByPath(Edit8.Text);
 end;

end;

procedure TOptionsForm.Button6Click(Sender: TObject);
begin
  if LoginForm=nil then
   Application.CreateForm(TLoginForm, LoginForm);
   LoginForm.Execute;
   LoginForm.Release;
   LoginForm.Free;
   LoginForm:=nil;
end;

procedure TOptionsForm.FormShow(Sender: TObject);
var
  b : boolean;
begin
 TabbedNotebook1Change(sender,0,b);
end;

procedure TOptionsForm.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 ColorDialog1.Color:= (Sender as TShape).brush.color;
 if ColorDialog1.Execute then
 (Sender as TShape).brush.color:=ColorDialog1.Color;
end;

procedure TOptionsForm.Button9Click(Sender: TObject);
var
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
 SaveDialog:=DBSaveDialog.Create;
 SaveDialog.Filter:='Color Themes (*.dbc)|*.dbc';
 SaveDialog.FilterIndex:=1;
 if SaveDialog.Execute then
 begin
  FileName:=SaveDialog.FileName;
  if GetExt(FileName)<>'DBC' then
  FileName:=FileName+'.dbc';
  If FileExists(FileName) then
  if ID_OK<>MessageBoxDB(Handle, Format(TEXT_MES_FILE_EXISTS_1,[FileName]),TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
  DBKernel.SaveThemeToFile(FileName);
 end;
 SaveDialog.Free;
end;

procedure TOptionsForm.LoadColorsToWindow;
begin
  Shape1.Brush.Color:=Theme_MainColor;
  Shape2.Brush.Color:=Theme_ListColor;
  Shape3.Brush.Color:=Theme_ListFontColor;
  Shape4.Brush.Color:=Theme_MainFontColor;
  Shape7.Brush.Color:=Theme_memoeditcolor;
  Shape5.Brush.Color:=Theme_memoeditfontcolor;
  Shape6.Brush.Color:=Theme_Labelfontcolor;   
  Shape8.Brush.Color:=Theme_ListSelectColor;
  Shape9.Brush.Color:=Theme_ProgressBackColor;
  Shape10.Brush.Color:=Theme_ProgressFontColor;  
  Shape11.Brush.Color:=Theme_ProgressFillColor;
end;

procedure TOptionsForm.FormCreate(Sender: TObject);
var
  i : integer;
begin
 ReloadData:=false;
 ClientHeight:=OkButton.Top+OkButton.Height+3;

 SaveWindowPos1.Key:=GetRegRootKey+'Options';
 SaveWindowPos1.SetPosition;
 for i:=0 to 5 do
 FLoadedPages[i]:=false;
 LoadColorsToWindow;
 LoadLanguage;
 FThemeList:=nil;
 ShellChangeNotifier1.Root:=ProgramDir+ThemesDirectory;
 ShellChangeNotifier1Change;
 CheckBox27.Enabled:=GDIPlusPresent;
 if not GDIPlusPresent then
 CheckBox27.Caption:=TEXT_MES_GDI_PLUS_DISABLED_INFO;
 PopupMenu3.Images:=DBkernel.ImageList;
 PopupMenu2.Images:=DBkernel.ImageList;
 Up1.ImageIndex:=DB_IC_UP;
 Down1.ImageIndex:=DB_IC_DOWN;
 DeleteItem1.ImageIndex:=DB_IC_DELETE_INFO;
 Additem1.ImageIndex:=DB_IC_EXPLORER;
 Rename1.ImageIndex:=DB_IC_RENAME;
 Addnewcommand1.ImageIndex:=DB_IC_EXPLORER;
 Remore1.ImageIndex:=DB_IC_DELETE_INFO;
 CheckBox31.Enabled:=not FolderView;
 ClientHeight:=484;
end;

procedure TOptionsForm.Button8Click(Sender: TObject);
var
  OpenDialog : DBOpenDialog;
begin
 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='Color Themes (*.dbc)|*.dbc';
 OpenDialog.FilterIndex:=1;
 If OpenDialog.Execute then
 begin
  DBkernel.LoadThemeFromFile(OpenDialog.FileName);
  DBkernel.ReloadGlobalTheme;
  LoadColorsToWindow;
 end;
 OpenDialog.Free;
end;

procedure TOptionsForm.LoadColorsFromWindow;
begin
  Theme_MainColor:=Shape1.Brush.Color;
  Theme_ListColor:=Shape2.Brush.Color;
  Theme_ListFontColor:=Shape3.Brush.Color;
  Theme_MainFontColor:=Shape4.Brush.Color;
  Theme_memoeditcolor:=Shape7.Brush.Color;
  Theme_memoeditfontcolor:=Shape5.Brush.Color;
  Theme_Labelfontcolor:=Shape6.Brush.Color;
  Theme_ListSelectColor:=Shape8.Brush.Color;

  Theme_ProgressBackColor:=Shape9.Brush.Color;
  Theme_ProgressFontColor:=Shape10.Brush.Color;
  Theme_ProgressFillColor:=Shape11.Brush.Color;

  DBkernel.ReloadGlobalTheme;
end;

procedure TOptionsForm.Button11Click(Sender: TObject);
begin
 LoadColorsFromWindow;
end;

procedure TOptionsForm.Button10Click(Sender: TObject);
begin
 LoadColorsToWindow;
end;

procedure TOptionsForm.OkButtonClick(Sender: TObject);
var
  Exts : TInstallExts;
  i : integer;
  reg : TBDRegistry;
  S : TStrings;   
  EventInfo : TEventValues;
begin
  if ReloadData then
  begin
   if MessageBoxDB(Handle,TEXT_MES_RELOAD_DATA,TEXT_MES_INFORMATION,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION)=ID_OK then
   begin
    DBKernel.DoIDEvent(nil,0,[EventID_Param_Refresh_Window],EventInfo);
   end;
  end;
// Case TabbedNotebook1.PageIndex of
// 0:
  if FLoadedPages[0] then
  begin
   DBKernel.WriteBool('Options','ShowAnimateToHintWindow',CheckBox3.Checked);
   DBKernel.WriteBool('Options','AllowPreview',CheckBox4.Checked);
   DBKernel.WriteInteger('Options','PreviewSwohOptions',RadioGroup1.ItemIndex);
   DBKernel.WriteBool('Options','UseWindowsTheme',CheckBox36.Checked);
   if CheckBox36.Checked then
   begin
    DBkernel.LoadColorTheme;
    try
     DBkernel.ReloadGlobalTheme;
    except
      on e : Exception do EventLog(':TOptionsForm::OkButtonClick()\ReloadGlobalTheme throw exception: '+e.Message);
    end;
   end;
  end;
// 1:
  if FLoadedPages[1] then
  begin
   DBKernel.WriteBool('Options','Explorer_ShowFolders',CheckBox1.Checked);
   DBKernel.WriteBool('Options','Explorer_ShowSimpleFiles',CheckBox6.Checked);
   DBKernel.WriteBool('Options','Explorer_ShowImageFiles',CheckBox7.Checked);
   DBKernel.WriteBool('Options','Explorer_ShowHiddenFiles',CheckBox8.Checked);
   DBKernel.WriteBool('Options','Explorer_ShowAttributes',CheckBox9.Checked);
   DBKernel.WriteBool('Options','Explorer_ShowThumbnailsForFolders',CheckBox10.Checked);
   DBKernel.WriteBool('Options','Explorer_SaveThumbnailsForFolders',CheckBox11.Checked);
   DBKernel.WriteBool('Options','Explorer_ShowThumbnailsForImages',CheckBox12.Checked);
   DBKernel.WriteBool('Options','ShowEXIFMarker',CheckBox20.Checked);
   DBKernel.WriteBool('Options','ShowOtherPlaces',CheckBox21.Checked);
   
   ExplorerManager.ShowEXIF:=CheckBox20.Checked;
   ExplorerManager.ShowQuickLinks:=CheckBox21.Checked;
   SetLength(Exts,CheckListBox1.Items.Count);
   For i:=1 to CheckListBox1.Items.Count do
   begin
    Exts[i-1].Ext:=CheckListBox1.Items[i-1];
    Case CheckListBox1.State[i-1] of
     cbUnchecked:  Exts[i-1].InstallType:=InstallType_UnChecked;
     cbChecked:  Exts[i-1].InstallType:=InstallType_Checked;
     cbGrayed:  Exts[i-1].InstallType:=InstallType_Grayed;
    end;
   end;
   ExtInstallApplicationW(Exts,InstalledFileName);
   WritePlaces;
  end;
//  3 :
  if FLoadedPages[3] then
  begin
   Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
   Reg.OpenKey(GetRegRootKey+'\Menu',true);
   S := TStringList.create;
   Reg.GetKeyNames(S);
   Reg.CloseKey;
   for i:=1 to S.Count do
   begin
    Reg.DeleteKey(GetRegRootKey+'\Menu\.'+IntToStr(i));
   end;
   s.free;
   for i:=0 to Length(FUserMenu)-1 do
   begin
    Reg.OpenKey(GetRegRootKey+'\Menu\.'+IntToStr(i),true);
    Reg.WriteString('Caption',FUserMenu[i].Caption);
    Reg.WriteString('EXEFile',FUserMenu[i].EXEFile);
    Reg.WriteString('Params',FUserMenu[i].Params);
    Reg.WriteString('Icon',FUserMenu[i].Icon);
    Reg.WriteBool('UseSubMenu',FUserMenu[i].UseSubMenu);
    Reg.CloseKey;
   end;
   Reg.free;
   DBKernel.WriteBool('Options','UseUserMenuForIDmenu',CheckBox17.Checked);
   DBKernel.WriteBool('Options','UseUserMenuForViewer',CheckBox19.Checked);
   DBKernel.WriteBool('Options','UseUserMenuForExplorer',CheckBox18.Checked);
  end;
//  4 :
  if FLoadedPages[4] then
  begin
   DBKernel.WriteBool('Options','AutoSaveSessionPasswords',CheckBox14.Checked);
   DBKernel.WriteBool('Options','AutoSaveINIPasswords',CheckBox15.Checked);  
   DBKernel.WriteInteger('Options','BackUpdays',StrToIntDef(Edit10.Text,7));
  end;
//  5 :
  if FLoadedPages[5] then
  begin
   DBKernel.WriteBool('Options','UseSmallToolBarButtons',CheckBox38.Checked);
   DBKernel.WriteBool('Options','UseListViewFullRectSelect',CheckBox5.Checked);
   DBKernel.WriteInteger('Options','UseListViewRoundRectSize',StrToIntDef(Edit2.Text,0));

   DBKernel.WriteBool('Options','UseGroupsInSearch',CheckBox35.Checked);
   DBKernel.WriteBool('Options','SortGroupsByName',CheckBox26.Checked);
   DBKernel.WriteBool('Options','UseHotSelect',CheckBox23.Checked);
   DBKernel.WriteBool('Options','UseGDIPlus',CheckBox27.Checked);
   DBKernel.WriteBool('Options','AllowManyInstancesOfProperty',CheckBox28.Checked);
   DBKernel.WriteBool('Options','UseMainMenuInSearchForm',CheckBox29.Checked);
   DBKernel.WriteBool('Editor','VirtualCursor',CheckBox30.Checked);
   DBKernel.WriteBool('Options','CheckUpdateLinks',CheckBox31.Checked);

   DBKernel.WriteBool('Options','RunExplorerAtStartUp',CheckBox32.Checked);
   DBKernel.WriteBool('Options','UseSpecialStartUpFolder',CheckBox33.Checked);
   DBKernel.WriteString('Options','SpecialStartUpFolder',Edit11.text);

   DBKernel.WriteBool('Options','NoAddSmallImages',CheckBox34.Checked);
   DBKernel.WriteString('Options','NoAddSmallImagesWidth',Edit12.text);
   DBKernel.WriteString('Options','NoAddSmallImagesHeight',Edit13.text);

  end;
//  2 :
  if FLoadedPages[2] then
  begin
   DBKernel.WriteBool('SlideShow','UseFastSlideShowImageLiading',CheckBox37.Checked);

   SlideShow.IncGrayScale:=TrackBar3.Position;
   DBKernel.WriteBool('Options','RotateWithoutPromt',CheckBox24.Checked);
   DBKernel.WriteBool('Options','RotateEvenIfFileInDB',CheckBox25.Checked);

   DBKernel.WriteBool('Options','NextOnClick',CheckBox22.Checked);
   DBKernel.WriteBoolW('Options','SlideShow_UseCoolStretch',CheckBox2.Checked);
   DBKernel.WriteInteger('Options','SlideShow_SlideSteps',TrackBar1.Position);
   DBKernel.WriteInteger('Options','SlideShow_SlideDelay',TrackBar2.Position);
   DBKernel.WriteInteger('Options','SlideShow_GrayScale',TrackBar3.Position);
   DBKernel.WriteInteger('Options','FullScreen_SlideDelay',TrackBar4.Position);
   DBKernel.WriteString('Options','SlideShow_ExternelViewer',Edit1.Text);
   DBKernel.WriteBoolW('Options','SlideShow_UseExternelViewer',CheckBox13.Checked);
  end;
// end;
 Close;
 DestroyTimer.Enabled:=true;
end;

procedure TOptionsForm.CancelButtonClick(Sender: TObject);
begin
 Close;
 DestroyTimer.Enabled:=true;
end;

procedure TOptionsForm.CheckListBox1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  item : Integer;
begin
 item:=CheckListBox1.ItemAtPos(MousePos,True);
 if item<>-1 then
 begin
  PopupMenu1.Tag:=item;
  Usethisprogramasdefault1.Checked:=false;
  Usemenuitem1.Checked:=false;
  Dontusethisextension1.Checked:=false;
  Case CheckListBox1.State[item] of
   cbUnchecked: Dontusethisextension1.Checked:=True;
   cbChecked  : Usethisprogramasdefault1.Checked:=True;
   cbGrayed   : Usemenuitem1.Checked:=True;
  end;
 end;
 PopupMenu1.PopUp(CheckListBox1.CLientToScreen(MousePos).X,CheckListBox1.CLientToScreen(MousePos).Y);
end;

procedure TOptionsForm.Usethisprogramasdefault1Click(Sender: TObject);
begin
 CheckListBox1.State[PopupMenu1.Tag]:=cbChecked;
end;

procedure TOptionsForm.Usemenuitem1Click(Sender: TObject);
begin
 CheckListBox1.State[PopupMenu1.Tag]:=cbGrayed;
end;

procedure TOptionsForm.Dontusethisextension1Click(Sender: TObject);
begin
 CheckListBox1.State[PopupMenu1.Tag]:=cbUnchecked;
end;

procedure TOptionsForm.Button12Click(Sender: TObject);
Var
  i : Integer;
  Exts : TInstallExts;
begin
 SetLength(Exts,CheckListBox1.Items.Count);
 For i:=1 to CheckListBox1.Items.Count do
 begin
  Exts[i-1].Ext:=CheckListBox1.Items[i-1];
  Case CheckListBox1.State[i-1] of
   cbUnchecked:  Exts[i-1].InstallType:=InstallType_UnChecked;
   cbChecked:  Exts[i-1].InstallType:=InstallType_Checked;
   cbGrayed:  Exts[i-1].InstallType:=InstallType_Grayed;
  end;
 end;
 ExtUnInstallApplicationW;
 ExtInstallApplicationW(Exts,Application.ExeName);
 LoadExts;
 try
  RebuildIconCacheAndNotifyChanges;
 except
 end;
end;

procedure TOptionsForm.LoadLanguage;
begin
 Caption := TEXT_MES_OPTIONS;
 TabbedNotebook1.Pages[0]:=TEXT_MES_GENERAL;
 TabbedNotebook1.Pages[1]:=TEXT_MES_EXPLORER;
 TabbedNotebook1.Pages[2]:=TEXT_MES_SLIDE_SHOW;
 TabbedNotebook1.Pages[3]:=TEXT_MES_USER_MENU;
 TabbedNotebook1.Pages[4]:=TEXT_MES_SECURITY;
 TabbedNotebook1.Pages[5]:=TEXT_MES_GLOBAL;
 GroupBox2.Caption:=TEXT_MES_BACKUPING_GROUP;
 StaticText1.Caption:=TEXT_MES_COLOR_THEME;
 Label1.Caption:= TEXT_MES_MAIN_COLOR;
 Label6.Caption:= TEXT_MES_MAIN_F_COLOR;
 Label4.Caption:= TEXT_MES_LIST_COLOR;
 Label5.Caption:= TEXT_MES_LIST_F_COLOR;
 Label9.Caption:= TEXT_MES_EDIT_COLOR;
 Label7.Caption:= TEXT_MES_EDIT_F_COLOR;
 Label8.Caption:= TEXT_MES_LABEL_COLOR;
 Dontusethisextension1.Caption:=TEXT_MES_DONT_USE_EXT;
 Usethisprogramasdefault1.Caption:=TEXT_MES_USE_THIS_PROGRAM;
 Usemenuitem1.Caption:=TEXT_MES_USE_ITEM;
 Button11.Caption:= TEXT_MES_LOAD_THEME;
 Button10.Caption:= TEXT_MES_RESET;
 Button8.Caption:= TEXT_MES_LOAD_FROM_FILE;
 Button9.Caption:= TEXT_MES_SAVE_THEME_TO_FILE;
 CheckBox4.Caption:=TEXT_MES_SHOW_PREVIEW;
 RadioGroup1.Caption:=TEXT_MES_HINTS;
 RadioGroup1.Items[0]:=TEXT_MES_ANIMATE_SHOW;
 RadioGroup1.Items[1]:=TEXT_MES_SHOW_SHADOW;
 Button6.Caption:=TEXT_MES_USERS;
 Label12.Caption:= TEXT_MES_SHOW_CURRENT_OBJ;
 CheckBox1.Caption:= TEXT_MES_FOLDERS;
 CheckBox6.Caption:= TEXT_MES_SIMPLE_FILES;
 CheckBox7.Caption:= TEXT_MES_IMAGE_FILES;
 CheckBox8.Caption:= TEXT_MES_HIDDEN_FILES;
 Label13.Caption:= TEXT_MES_TH_OPTIONS;
 CheckBox9.Caption:= TEXT_MES_SHOW_ATTR;
 CheckBox10.Caption:= TEXT_MES_SHOW_TH_FOLDRS;
 CheckBox11.Caption:= TEXT_MES_SAVE_TH_FOLDRS;
 CheckBox12.Caption:= TEXT_MES_SHOW_TH_IMAGE;
 Button12.Caption:= TEXT_MES_SET;
 OkButton.Caption:=TEXT_MES_OK;
 Cancelbutton.Caption:=TEXT_MES_CANCEL;
 Label10.Caption:=TEXT_MES_AVALIABLE_THEMES;
 Button1.Caption:=TEXT_MES_LOAD_THEME;
 CheckBox2.Caption:=TEXT_MES_USE_COOL_STRETCH;
// GroupBox2.Caption:=TEXT_MES_DO_SLIDE_SHOW;
 CheckBox13.Caption:=TEXT_MES_USE_EXTERNAL_VIEWER;
 Label14.Caption:=TEXT_MES_EXT_IN_USE;
 TrackBar4Change(nil);
 TrackBar3Change(nil);
 TrackBar2Change(nil);
 TrackBar1Change(nil);
 Label17.Caption:=TEXT_MES_SECURITY_INFO;
 CheckBox14.Caption:=TEXT_MES_SECURITY_USE_SAVE_IN_SESSION;
 CheckBox15.Caption:=TEXT_MES_SECURITY_USE_SAVE_IN_INI;
 Button3.Caption:=TEXT_MES_SECURITY_CLEAR_SESSION;
 Button4.Caption:=TEXT_MES_SECURITY_CLEAR_INI;
 ListView1.Columns[0].Caption:=TEXT_MES_USER_MENU_ITEM;
 Label20.Caption:=TEXT_MES_CAPTION;
 Label18.Caption:=TEXT_MES_EXECUTABLE_FILE;
 Label25.Caption:=TEXT_MES_EXECUTABLE_FILE_PARAMS;
 Label19.Caption:=TEXT_MES_ICON;
 CheckBox16.Caption:=TEXT_MES_USE_SUBMENU;
 Button14.Caption:=TEXT_MES_ADD;
 Button13.Caption:=TEXT_MES_SAVE;
 Button16.Caption:=TEXT_MES_SAVE;
 Label24.Caption:=TEXT_MES_IMAGE_PRIVIEW;
 Label21.Caption:=TEXT_MES_USER_SUBMENU_CAPTION;
 Label23.Caption:=TEXT_MES_USER_SUBMENU_ICON;
 Addnewcommand1.Caption:=TEXT_MES_ADD_NEW_USER_MENU_ITEM;
 Remore1.Caption:=TEXT_MES_REMOVE_USER_MENU_ITEM;
 Button17.Caption:=TEXT_MES_ITEM_UP;
 Button18.Caption:=TEXT_MES_ITEM_DOWN;
 GroupBox3.Caption:=TEXT_MES_USE_USER_MENU_FOR;
 CheckBox17.Caption:=TEXT_MES_USE_USER_MENU_FOR_ID_MENU;
 CheckBox19.Caption:=TEXT_MES_USE_USER_MENU_FOR_VIEWER;
 CheckBox18.Caption:=TEXT_MES_USE_USER_MENU_FOR_EXPLORER;
 Button19.Caption:=TEXT_MES_CLEAR_FOLDER_IMAGES_CASH;
 Button20.Caption:=TEXT_MES_CLEAR_ICON_CASH;
 CheckBox20.Caption:=TEXT_MES_SHOW_EXIF_MARKER;
 CheckBox21.Caption:=TEXT_MES_SHOW_OTHER_PLACES;
 CheckBox22.Caption:=TEXT_MES_NEXT_ON_CLICK;
 CheckBox23.Caption:=TEXT_MES_USE_HOT_SELECT_IN_LISTVIEWS;
 CheckBox24.Caption:=TEXT_MES_ROTATE_WITHOUT_PROMT;
 CheckBox25.Caption:=TEXT_MES_ROTATE_EVEN_IF_FILE_IN_DB;
 Button21.Caption:=TEXT_MES_JPEG_OPTIONS;
 Button22.Caption:=TEXT_MES_JPEG_OPTIONS;
 CheckBox26.Caption:=TEXT_MES_SORT_GROUPS;
 CheckBox27.Caption:=TEXT_MES_USE_GDI_PLUS;
 Label29.Caption:=TEXT_MES_CREATE_BACK_UP_EVERY;
 Label30.Caption:=TEXT_MES_DAYS;
 CheckBox28.Caption:=TEXT_MES_MANY_INSTANCES_OF_PROEPRTY;
 CheckListBox2.Clear;
 CheckListBox2.Items.Add(TEXT_MES_MY_COMPUTER);
 CheckListBox2.Items.Add(TEXT_MES_MY_DOCUMENTS);
 CheckListBox2.Items.Add(TEXT_MES_MY_PICTURES);
 CheckListBox2.Items.Add(TEXT_MES_OTHER_PLACES);
 Button24.Caption:=TEXT_MES_NEW_PLACE;
 Label27.Caption:=TEXT_MES_SHOW_PLACE_IN;
 Label11.Caption:=TEXT_MES_USER_DEFINED_PLACES;
 PlacesListView.Columns[0].Caption:=TEXT_MES_PLACES;

 Additem1.Caption:=TEXT_MES_NEW_PLACE;
 DeleteItem1.Caption:=TEXT_MES_DELETE_ITEM;
 Up1.Caption:=TEXT_MES_ITEM_UP;
 Down1.Caption:=TEXT_MES_ITEM_DOWN;
 Button23.Caption:=TEXT_MES_ICON;
 Rename1.Caption:=TEXT_MES_RENAME;
 CheckBox29.Caption:=TEXT_MES_USE_MAIN_MENU_IN_SEARCH_FORM;
 CheckBox30.Caption:=TEXT_MES_ALLOW_VIRTUAL_CURSOR_IN_EDITOR;

 Label28.Caption:=TEXT_MES_SELECTED_COLOR;
 Default1.Caption:=TEXT_MES_DEFAULT;
 CheckBox31.Caption:=TEXT_MES_DO_UPDATE_IMAGES_ON_IMAGE_CHANGES;
 CheckBox32.Caption:=TEXT_MES_RUN_EXPLORER_AT_ATARTUP;
 CheckBox33.Caption:=TEXT_MES_USE_SPECIAL_FOLDER;

 CheckBox34.Caption:=TEXT_MES_NO_ADD_SMALL_FILES_WITH_WH;
 Label31.Caption:=TEXT_MES_WIDTH;
 Label32.Caption:=TEXT_MES_HEIGHT;
 CheckBox35.Caption:=TEXT_MES_SHOW_GROUPS_IN_SEARCH;
 GroupBox4.Caption:=TEXT_MES_PASSWORDS;

 CheckBox36.Caption:=TEXT_MES_USE_WINDOWS_THEME;

 Label2.Caption:=TEXT_MES_PROGRESS_BACK_COLOR;
 Label3.Caption:=TEXT_MES_PROGRESS_FONT_COLOR;
 Label33.Caption:=TEXT_MES_PROGRESS_FILL_COLOR;

 CheckBox5.Caption:=TEXT_MES_USE_FULL_RECT_SELECT;
 Label34.Caption:=TEXT_MES_LIST_VIEW_ROUND_RECT_SIZE;

 CheckBox37.Caption:=TEXT_MES_USE_SLIDE_SHOW_FAST_LOADING;
 CheckBox38.Caption:=TEXT_MES_USE_SMALL_TOOLBAR_ICONS;
end;

procedure TOptionsForm.ShellChangeNotifier1Change;
var
  i : integer;
begin
 if FThemeList=nil then FThemeList:=TStringList.Create;
 FThemeList.Clear;
 RelodThemesNamesW(FThemeList);
 ListBox1.Items.Clear;
 for i:=0 to FThemeList.Count-1 do
 ListBox1.Items.Add(GetFileName(FThemeList[i]));
end;

procedure TOptionsForm.Button1Click(Sender: TObject);
var
  i : integer;
begin
 For i:=0 to ListBox1.Items.Count-1 do
 begin
  if ListBox1.Selected[i] then
  begin
   DBkernel.LoadThemeFromFile(FThemeList[i]);
   DBkernel.ReloadGlobalTheme;
   LoadColorsToWindow;
   Break;
  end;
 end;
end;

procedure TOptionsForm.ListBox1DblClick(Sender: TObject);
var
  i : integer;
begin
 For i:=0 to ListBox1.Items.Count-1 do
 begin
  if ListBox1.Selected[i] then
  begin
   DBkernel.LoadThemeFromFile(FThemeList[i]);
   try
    DBkernel.ReloadGlobalTheme;
   except    
    on e : Exception do EventLog(':TOptionsForm::ListBox1DblClick()\ReloadGlobalTheme throw exception: '+e.Message);
   end;
   LoadColorsToWindow;
   ReloadData:=true;
   Break;
  end;
 end;
end;

procedure TOptionsForm.TrackBar1Change(Sender: TObject);
begin
 Label15.Caption:=Format(TEXT_MES_SLIDE_SHOW_STEPS_OPTIONS,[IntToStr(TrackBar1.Position)]);
end;

procedure TOptionsForm.TrackBar2Change(Sender: TObject);
begin
// Label15.Caption:=Format(TEXT_MES_SLIDE_SHOW_GRAYSCALE_OPTIONS,[IntToStr(TrackBar2.Position)]);
 Label22.Caption:=Format(TEXT_MES_SLIDE_SHOW_SPEED,[IntToStr(TrackBar2.Position*50)]);
end;

procedure TOptionsForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#8 then
 begin
  Edit1.Text:=TEXT_MES_NO_FILE;
 end;
end;

procedure TOptionsForm.Button2Click(Sender: TObject);
var
  OpenDialog : DBOpenDialog;
begin

 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='Programs (*.exe)|*.exe';
 OpenDialog.FilterIndex:=1;

 if OpenDialog.Execute then
 begin
  If GetExt(OpenDialog.FileName)='EXE' then
  Edit1.text:='"'+OpenDialog.FileName+'" %s';
 end;
 OpenDialog.Free;
end;

procedure TOptionsForm.TrackBar3Change(Sender: TObject);
begin
 Label16.Caption:=Format(TEXT_MES_SLIDE_SHOW_GRAYSCALE_OPTIONS,[IntToStr(TrackBar3.Position)]);
end;

procedure TOptionsForm.CheckBox13Click(Sender: TObject);
begin
 if (not CheckBox13.Checked) then
 begin
  Edit1.Enabled:=false;
  Button2.Enabled:=false;
 end else
 begin
  Edit1.Enabled:=true;
  Button2.Enabled:=true;
 end;
end;

procedure TOptionsForm.LoadExts;
var
  i : integer;
  reg : TRegistry;
  s : string;
begin
 Reg:=TRegistry.Create;
 Reg.RootKey:=Windows.HKEY_CLASSES_ROOT;
 For i:=1 to CheckListBox1.Items.Count do
 begin
  CheckListBox1.State[i-1]:=cbUnchecked;
  Reg.OpenKey('\.'+CheckListBox1.Items[i-1],false);
  S:=Reg.ReadString('');
  Reg.CloseKey;
  Reg.OpenKey('\'+S+'\shell\open\command',false);
  If reg.ReadString('')='' then
  CheckListBox1.State[i-1]:=cbUnchecked else
  begin
   if FileRegisteredOnInstalledApplication(reg.ReadString('')) then
   CheckListBox1.State[i-1]:=cbChecked else
   begin
    Reg.CloseKey;
    Reg.OpenKey('\'+S+'\Shell\PhotoDBView\command',false);
    if FileRegisteredOnInstalledApplication(reg.ReadString('')) then
    CheckListBox1.State[i-1]:=cbGrayed else
    CheckListBox1.State[i-1]:=cbUnchecked;
   end;
  end;
  Reg.CloseKey;
 end;
 Reg.Free;
end;

procedure TOptionsForm.Button3Click(Sender: TObject);
begin
 DBkernel.ClearTemporaryPasswordsInSession;
end;

procedure TOptionsForm.Button4Click(Sender: TObject);
begin
 DBkernel.ClearINIPasswords;
end;

procedure TOptionsForm.Button7Click(Sender: TObject);
var
  FileName : String;
  IconIndex : integer;

  s, Icon : String;
  i : Integer;
begin
 s:=Edit5.Text;
 i:=Pos(',',s);
 FileName:=Copy(s,1,i-1);
 Icon:=Copy(s,i+1,Length(s)-i);
 IconIndex:=StrToIntDef(Icon,0);
 ChangeIconDialog(handle,FileName,IconIndex);
 if FileName<>'' then
 Edit5.Text:=FileName+','+IntToStr(IconIndex);
end;

procedure TOptionsForm.Button5Click(Sender: TObject);
var
  OpenDialog : DBOpenDialog;
begin

 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='Programs (*.exe)|*.exe|All Files (*.*)|*.*';
 OpenDialog.FilterIndex:=1;

 if OpenDialog.Execute then
 begin
  Edit4.Text:=OpenDialog.FileName;
 end;
 OpenDialog.Free;
end;

procedure TOptionsForm.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  item : TListItem;
begin
 item:=ListView1.GetItemAt(MousePos.X,MousePos.Y);
 if item=nil then
 begin
  Addnewcommand1.Visible:=true;
  Remore1.Visible:=false;
  PopupMenu2.Tag:=-1;
 end else
 begin
  Addnewcommand1.Visible:=false;
  Remore1.Visible:=true;
  PopupMenu2.Tag:=item.Index;
 end;
 PopupMenu2.Popup(ListView1.ClientToScreen(MousePos).x,ListView1.ClientToScreen(MousePos).y);
end;

procedure TOptionsForm.Addnewcommand1Click(Sender: TObject);
var
  Ico : TIcon;
  OpenDialog : DBOpenDialog;
const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,0';
begin

 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='Programs (*.exe)|*.exe|All Files (*.*)|*.*';
 OpenDialog.FilterIndex:=1;
 if OpenDialog.Execute then
 begin
  SetLength(FUserMenu,Length(FUserMenu)+1);
  FUserMenu[Length(FUserMenu)-1].Caption:=GetFileNameWithoutExt(OpenDialog.FileName);
  FUserMenu[Length(FUserMenu)-1].EXEFile:=OpenDialog.FileName;
  FUserMenu[Length(FUserMenu)-1].Params:='%1';
  if AnsiLowerCase(ExtractFileExt(OpenDialog.FileName))='.exe' then
  FUserMenu[Length(FUserMenu)-1].Icon:=OpenDialog.FileName+',0' else
  FUserMenu[Length(FUserMenu)-1].Icon:=DefaultIcon;
  FUserMenu[Length(FUserMenu)-1].UseSubMenu:=true;
  Ico:=GetSmallIconByPath(FUserMenu[Length(FUserMenu)-1].Icon);
  ImageList1.AddIcon(Ico);
  Ico.free;
  with ListView1.Items.Add do
  begin
   ImageIndex:=ImageList1.Count-1;
   Caption:=GetFileNameWithoutExt(OpenDialog.FileName);
  end;
 end;
 OpenDialog.Free;
end;

procedure TOptionsForm.Remore1Click(Sender: TObject);
var
  i : integer;
begin
 if PopupMenu2.Tag<>-1 then
 begin
  for i:=PopupMenu2.Tag to Length(FUserMenu)-2 do
  FUserMenu[i]:=FUserMenu[i+1];
  SetLength(FUserMenu,Length(FUserMenu)-1);
  ListView1.Items.Delete(PopupMenu2.tag);
  ImageList1.Delete(PopupMenu2.Tag);
  for i:=PopupMenu2.tag to Length(FUserMenu)-1 do
  ListView1.Items[i].ImageIndex:=ListView1.Items[i].ImageIndex-1;
 end;
end;

procedure TOptionsForm.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
 if (Item=nil) or (Selected=false) then
 begin
  Button17.Enabled:=false;
  Button18.Enabled:=false;
  Edit6.Enabled:=false;
  Edit5.Enabled:=false;
  Edit4.Enabled:=false;
  Edit9.Enabled:=false;
  Button5.Enabled:=false;
  Button7.Enabled:=false;
  Button13.Enabled:=false;
  CheckBox16.Checked:=false;
  CheckBox16.Enabled:=false;
  Edit6.Text:='';
  Edit5.Text:='';
  Edit4.Text:='';
  Edit9.Text:='';
 end else
 begin
  Button17.Enabled:=Item.Index<>0;
  Button18.Enabled:=Item.Index<>ListView1.Items.Count-1;
  Edit6.Text:=FUserMenu[Item.index].Caption;
  Edit5.Text:=FUserMenu[Item.index].Icon;
  Edit4.Text:=FUserMenu[Item.index].EXEFile;
  Edit9.Text:=FUserMenu[Item.index].Params;
  CheckBox16.Checked:=FUserMenu[Item.index].UseSubMenu;
  CheckBox16.Enabled:=true;
  Edit6.Enabled:=true;
  Edit5.Enabled:=true;
  Edit4.Enabled:=true;
  Edit9.Enabled:=true;
  Button5.Enabled:=true;
  Button7.Enabled:=true;
  Button13.Enabled:=true;
 end;
end;

procedure TOptionsForm.Button13Click(Sender: TObject);
var
  ico : TIcon;
begin
 if ListView1.Selected=nil then exit;
 FUserMenu[ListView1.Selected.index].Caption:=Edit6.Text;
 FUserMenu[ListView1.Selected.index].Icon:=Edit5.Text;
 FUserMenu[ListView1.Selected.index].EXEFile:=Edit4.Text;
 FUserMenu[ListView1.Selected.index].Params:=Edit9.Text;
 FUserMenu[ListView1.Selected.index].UseSubMenu:=CheckBox16.Checked;
 ListView1.Selected.Caption:=Edit6.Text;
 Ico:=GetSmallIconByPath(Edit5.Text);
 ImageList1.ReplaceIcon(ListView1.Selected.Index,ico);
 Ico.free;
end;

procedure TOptionsForm.Edit6KeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then Button13Click(Sender);
end;

procedure TOptionsForm.Button16Click(Sender: TObject);
begin
 DBKernel.WriteString('','UserMenuName',Edit7.Text);
 DBKernel.WriteString('','UserMenuIcon',Edit8.Text);
end;

procedure TOptionsForm.Button15Click(Sender: TObject);
var
  FileName : String;
  IconIndex : integer;
  s,  Icon : String;
  i : Integer;
begin
 s:=Edit8.text;
 i:=Pos(',',s);
 FileName:=Copy(s,1,i-1);
 Icon:=Copy(s,i+1,Length(s)-i);
 IconIndex:=StrToIntDef(Icon,0);
 ChangeIconDialog(handle,FileName,IconIndex);
 if FileName<>'' then
 Edit8.text:=FileName+','+IntToStr(IconIndex);
 if Image2.Picture.Icon<>nil then
 Image2.Picture.Icon:=GetSmallIconByPath(Edit8.text);
end;

procedure TOptionsForm.Button17Click(Sender: TObject);
var
  info : TUserMenuItem;
  Icon1,Icon2 : TIcon;
begin
 info:=FUserMenu[ListView1.Selected.index];
 FUserMenu[ListView1.Selected.index]:=FUserMenu[ListView1.Selected.index-1];
 FUserMenu[ListView1.Selected.index-1]:=info;
 Icon1:=TIcon.Create;
 Icon2:=TIcon.Create;
 ImageList1.GetIcon(ListView1.Selected.index,Icon1);
 ImageList1.GetIcon(ListView1.Selected.index-1,Icon2);
 ImageList1.ReplaceIcon(ListView1.Selected.index,Icon2);
 ImageList1.ReplaceIcon(ListView1.Selected.index-1,Icon1);
 ListView1.Items[ListView1.Selected.index].Caption:=FUserMenu[ListView1.Selected.index].Caption;
 ListView1.Items[ListView1.Selected.index-1].Caption:=FUserMenu[ListView1.Selected.index-1].Caption;
 ListView1.Selected:=ListView1.Items[ListView1.Selected.index-1];
 ListView1.SetFocus;
 Icon1.free;
 Icon2.free;
end;

procedure TOptionsForm.Button18Click(Sender: TObject);
var
  info : TUserMenuItem;
  Icon1,Icon2 : TIcon;
begin
 info:=FUserMenu[ListView1.Selected.index];
 FUserMenu[ListView1.Selected.index]:=FUserMenu[ListView1.Selected.index+1];
 FUserMenu[ListView1.Selected.index+1]:=info;
 Icon1:=TIcon.Create;
 Icon2:=TIcon.Create;
 ImageList1.GetIcon(ListView1.Selected.index,Icon1);
 ImageList1.GetIcon(ListView1.Selected.index+1,Icon2);
 ImageList1.ReplaceIcon(ListView1.Selected.index,Icon2);
 ImageList1.ReplaceIcon(ListView1.Selected.index+1,Icon1);
 ListView1.Items[ListView1.Selected.index].Caption:=FUserMenu[ListView1.Selected.index].Caption;
 ListView1.Items[ListView1.Selected.index+1].Caption:=FUserMenu[ListView1.Selected.index+1].Caption;
 ListView1.Selected:=ListView1.Items[ListView1.Selected.index+1];
 ListView1.SetFocus;
 Icon1.free;
 Icon2.free;
end;

procedure TOptionsForm.Button20Click(Sender: TObject);
begin
 AIcons.Clear;
end;

procedure TOptionsForm.Button19Click(Sender: TObject);
begin
 AExplorerFolders.Clear;
end;

procedure TOptionsForm.TrackBar4Change(Sender: TObject);
begin
 Label26.Caption:=Format(TEXT_MES_FULL_SCREEN_SLIDE_SPEED,[IntToStr(TrackBar4.Position*100)]);
end;

procedure TOptionsForm.DestroyTimerTimer(Sender: TObject);
begin
 SaveWindowPos1.SavePosition;
 DestroyTimer.Enabled:=false;
 Release;
 if UseFreeAfterRelease then Free;
 OptionsForm:=nil;
end;

procedure TOptionsForm.Button21Click(Sender: TObject);
begin
 SetJPEGOptions('Viewer');
end;

procedure TOptionsForm.Button22Click(Sender: TObject);
begin
 SetJPEGOptions;
end;

procedure TOptionsForm.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);  
 Params.WndParent := GetDesktopWindow;
 with params do
 ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TOptionsForm.PlacesListViewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  item : TListItem;
begin
 item:=PlacesListView.GetItemAt(MousePos.X,MousePos.Y);
 if item=nil then
 begin
  Up1.Visible:=false;
  Down1.Visible:=false;  
  DeleteItem1.Visible:=false;
  Rename1.Visible:=false;
 end else
 begin
  Up1.Visible:=Item.Index<>0;
  Down1.Visible:=Item.Index<>PlacesListView.Items.Count-1;
  PopupMenu3.Tag:=item.Index;
  Rename1.Visible:=true;
  DeleteItem1.Visible:=true;
 end;
 PopupMenu3.Popup(PlacesListView.ClientToScreen(MousePos).x,PlacesListView.ClientToScreen(MousePos).y);
end;

procedure TOptionsForm.Button24Click(Sender: TObject);
var
  NewPlace : String;
  Ico : TIcon;
const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,3';
begin
 if PlacesListView.Selected=nil then
 begin
  NewPlace:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_NEW_PLACE,Dolphin_DB.UseSimpleSelectFolderDialog);
  if DirectoryExists(NewPlace) then
  begin
   SetLength(FPlaces,Length(FPlaces)+1);
   FPlaces[Length(FPlaces)-1].Name:=GetFileNameWithoutExt(NewPlace);
   FPlaces[Length(FPlaces)-1].FolderName:=NewPlace;
   FPlaces[Length(FPlaces)-1].Icon:=DefaultIcon;
   FPlaces[Length(FPlaces)-1].MyComputer:=true;
   FPlaces[Length(FPlaces)-1].MyDocuments:=true;
   FPlaces[Length(FPlaces)-1].MyPictures:=true;
   FPlaces[Length(FPlaces)-1].OtherFolder:=true;
   Ico:=GetSmallIconByPath(DefaultIcon);
   PlacesImageList.AddIcon(Ico);
   Ico.free;
   with PlacesListView.Items.AddItem(nil) do
   begin
    ImageIndex:=PlacesImageList.Count-1;
    Caption:=GetFileNameWithoutExt(NewPlace);
   end;
  end;
 end else
 begin
  NewPlace:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_NEW_PLACE,FPlaces[PlacesListView.Selected.Index].FolderName,Dolphin_DB.UseSimpleSelectFolderDialog);
  if DirectoryExists(NewPlace) then
  FPlaces[PlacesListView.Selected.Index].FolderName:=NewPlace;
  FPlaces[PlacesListView.Selected.Index].Name:=GetFileNameWithoutExt(NewPlace);
  PlacesListView.Selected.Caption:=GetFileNameWithoutExt(NewPlace);
 end;
end;

procedure TOptionsForm.ReadPlaces;
var
  Reg : TBDRegistry;
  S : TStrings;
  fName, fFolderName, fIcon : string;
  fMyComputer, fMyDocuments, fMyPictures, fOtherFolder : boolean;
  i : integer;
  Ico : TIcon;
begin
 PlacesImageList.Clear;
 PlacesImageList.Width:=16;
 PlacesImageList.Height:=16;
 PlacesImageList.BkColor:=clMenu;
 Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);

 Reg.OpenKey(GetRegRootKey+'\Places',true);
 S := TStringList.create;
 Reg.GetKeyNames(S);
 SetLength(FPlaces,0);
 PlacesListView.Clear;
 for i:=0 to S.Count-1 do
 begin
  Reg.CloseKey;
  Reg.OpenKey(GetRegRootKey+'\Places\'+s[i],true);
  fMyComputer:=false;
  fMyDocuments:=false;
  fMyPictures:=false;
  fOtherFolder:=false;
  try
   if Reg.ValueExists('Name') then
   fName:=Reg.ReadString('Name');
   if Reg.ValueExists('FolderName') then
   fFolderName:=Reg.ReadString('FolderName');
   if Reg.ValueExists('Icon') then
   fIcon:=Reg.ReadString('Icon');
   if Reg.ValueExists('MyComputer') then
   fMyComputer:=Reg.ReadBool('MyComputer');
   if Reg.ValueExists('MyDocuments') then
   fMyDocuments:=Reg.ReadBool('MyDocuments');
   if Reg.ValueExists('MyPictures') then
   fMyPictures:=Reg.ReadBool('MyPictures');
   if Reg.ValueExists('OtherFolder') then
   fOtherFolder:=Reg.ReadBool('OtherFolder');
  except
  end;
   if (fName<>'') and (fFolderName<>'') then
   begin
    SetLength(FPlaces,Length(FPlaces)+1);
    FPlaces[Length(FPlaces)-1].Name:=fName;
    FPlaces[Length(FPlaces)-1].FolderName:=fFolderName;
    FPlaces[Length(FPlaces)-1].Icon:=fIcon;
    FPlaces[Length(FPlaces)-1].MyComputer:=fMyComputer;
    FPlaces[Length(FPlaces)-1].MyDocuments:=fMyDocuments;
    FPlaces[Length(FPlaces)-1].MyPictures:=fMyPictures;
    FPlaces[Length(FPlaces)-1].OtherFolder:=fOtherFolder;
    Ico:=GetSmallIconByPath(fIcon);
    PlacesImageList.AddIcon(Ico);
    Ico.free;
    with PlacesListView.Items.Add do
    begin
     ImageIndex:=PlacesImageList.Count-1;
     Caption:=fName;
    end;
   end;
  end;
  S.free;
  Reg.free;
end;

procedure TOptionsForm.WritePlaces;
var
  i : integer;
  Reg : TBDRegistry;
  S : TStrings;
begin
 Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);

 Reg.OpenKey(GetRegRootKey+'\Places',true);
 S := TStringList.create;
 Reg.GetKeyNames(S);
 Reg.CloseKey;
 for i:=1 to S.Count do
 begin
  Reg.DeleteKey(GetRegRootKey+'\Places\.'+IntToStr(i));
 end;
 s.free;
 for i:=0 to Length(FPlaces)-1 do
 begin
  Reg.OpenKey(GetRegRootKey+'\Places\.'+IntToStr(i),true);
  Reg.WriteString('Name',FPlaces[i].Name);
  Reg.WriteString('FolderName',FPlaces[i].FolderName);
  Reg.WriteString('Icon',FPlaces[i].Icon);
  Reg.WriteBool('MyComputer',FPlaces[i].MyComputer);
  Reg.WriteBool('MyDocuments',FPlaces[i].MyDocuments);
  Reg.WriteBool('MyPictures',FPlaces[i].MyPictures);
  Reg.WriteBool('OtherFolder',FPlaces[i].OtherFolder);
  Reg.CloseKey;
 end;
 Reg.free;
end;

procedure TOptionsForm.PlacesListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  i : integer;
begin
 if not Selected then
 begin
  for i:=0 to 3 do
  CheckListBox2.Checked[i]:=false;
  CheckListBox2.Enabled:=false;
  Button23.Enabled:=false;
 end else
 begin
  CheckListBox2.Checked[0]:=FPlaces[Item.Index].MyComputer;
  CheckListBox2.Checked[1]:=FPlaces[Item.Index].MyDocuments;
  CheckListBox2.Checked[2]:=FPlaces[Item.Index].MyPictures;
  CheckListBox2.Checked[3]:=FPlaces[Item.Index].OtherFolder;
  CheckListBox2.Enabled:=true;
  Button23.Enabled:=true;
 end;
end;

procedure TOptionsForm.CheckListBox2ClickCheck(Sender: TObject);
var
  i : integer;
begin
 if PlacesListView.Selected<>nil then
 begin
  i:=PlacesListView.Selected.Index;
  FPlaces[i].MyComputer:=CheckListBox2.Checked[0];
  FPlaces[i].MyDocuments:=CheckListBox2.Checked[1];
  FPlaces[i].MyPictures:=CheckListBox2.Checked[2];
  FPlaces[i].OtherFolder:=CheckListBox2.Checked[3];
 end;
end;

procedure TOptionsForm.Button23Click(Sender: TObject);
var
  FileName : String;
  IconIndex : integer;
  s,  Icon : String;
  i, index : Integer;
  ico : TIcon;
begin
 if PlacesListView.Selected=nil then exit;
 index:=PlacesListView.Selected.Index;
 s:=FPlaces[index].Icon;
 i:=Pos(',',s);
 FileName:=Copy(s,1,i-1);
 Icon:=Copy(s,i+1,Length(s)-i);
 IconIndex:=StrToIntDef(Icon,0);
 ChangeIconDialog(handle,FileName,IconIndex);
 if FileName<>'' then
 FPlaces[index].Icon:=FileName+','+IntToStr(IconIndex);
 ico:=GetSmallIconByPath(FPlaces[index].Icon);
 PlacesImageList.ReplaceIcon(index,ico);
 ico.free;
end;

procedure TOptionsForm.DeleteItem1Click(Sender: TObject);
var
  i : integer;
begin
 if PopupMenu3.Tag<>-1 then
 begin
  for i:=PopupMenu3.Tag to Length(FPlaces)-2 do
  FPlaces[i]:=FPlaces[i+1];
  SetLength(FPlaces,Length(FPlaces)-1);
  PlacesListView.Items.Delete(PopupMenu3.tag);
  PlacesImageList.Delete(PopupMenu3.Tag);
  for i:=PopupMenu3.tag to Length(FPlaces)-1 do
  PlacesListView.Items[i].ImageIndex:=PlacesListView.Items[i].ImageIndex-1;
 end;
end;

procedure TOptionsForm.Up1Click(Sender: TObject);
var
  info : TPlaceFolder;
  Icon1,Icon2 : TIcon;
begin
 if PlacesListView.Selected=nil then exit;
 info:=FPlaces[PlacesListView.Selected.index];
 FPlaces[PlacesListView.Selected.index]:=FPlaces[PlacesListView.Selected.index-1];
 FPlaces[PlacesListView.Selected.index-1]:=info;
 Icon1:=TIcon.Create;
 Icon2:=TIcon.Create;
 PlacesImageList.GetIcon(PlacesListView.Selected.index,Icon1);
 PlacesImageList.GetIcon(PlacesListView.Selected.index-1,Icon2);
 PlacesImageList.ReplaceIcon(PlacesListView.Selected.index,Icon2);
 PlacesImageList.ReplaceIcon(PlacesListView.Selected.index-1,Icon1);
 PlacesListView.Items[PlacesListView.Selected.index].Caption:=FPlaces[PlacesListView.Selected.index].Name;
 PlacesListView.Items[PlacesListView.Selected.index-1].Caption:=FPlaces[PlacesListView.Selected.index-1].Name;
 PlacesListView.Selected:=PlacesListView.Items[PlacesListView.Selected.index-1];
 PlacesListView.SetFocus;
 Icon1.free;
 Icon2.free;
end;

procedure TOptionsForm.Down1Click(Sender: TObject);
var
  info : TPlaceFolder;
  Icon1,Icon2 : TIcon;
begin
 if PlacesListView.Selected=nil then exit;
 info:=FPlaces[PlacesListView.Selected.index];
 FPlaces[PlacesListView.Selected.index]:=FPlaces[PlacesListView.Selected.index+1];
 FPlaces[PlacesListView.Selected.index+1]:=info;
 Icon1:=TIcon.Create;
 Icon2:=TIcon.Create;
 PlacesImageList.GetIcon(PlacesListView.Selected.index,Icon1);
 PlacesImageList.GetIcon(PlacesListView.Selected.index+1,Icon2);
 PlacesImageList.ReplaceIcon(PlacesListView.Selected.index,Icon2);
 PlacesImageList.ReplaceIcon(PlacesListView.Selected.index+1,Icon1);
 PlacesListView.Items[PlacesListView.Selected.index].Caption:=FPlaces[PlacesListView.Selected.index].Name;
 PlacesListView.Items[PlacesListView.Selected.index+1].Caption:=FPlaces[PlacesListView.Selected.index+1].Name;
 PlacesListView.Selected:=PlacesListView.Items[PlacesListView.Selected.index+1];
 PlacesListView.SetFocus;
 Icon1.free;
 Icon2.free;
end;

procedure TOptionsForm.Rename1Click(Sender: TObject);
begin
 if PlacesListView.Selected=nil then exit;
 PlacesListView.Selected.EditCaption;
end;

procedure TOptionsForm.PlacesListViewEdited(Sender: TObject;
  Item: TListItem; var S: String);
begin
 FPlaces[Item.Index].Name:=S;
end;

procedure TOptionsForm.Default1Click(Sender: TObject);
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

procedure TOptionsForm.CheckBox32Click(Sender: TObject);
begin
 CheckBox33.Enabled:=CheckBox32.Checked;
 Edit11.Enabled:=CheckBox33.Checked;
end;

procedure TOptionsForm.Button25Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SELECT_FOLDER,Dolphin_DB.UseSimpleSelectFolderDialog);
 If DirectoryExists(dir) then
 begin
  FormatDir(Dir);
  Edit11.Text:=Dir;
 end;
end;

procedure TOptionsForm.CheckBox33Click(Sender: TObject);
begin
 Edit11.Enabled:=CheckBox33.Checked;
end;

procedure TOptionsForm.CheckBox34Click(Sender: TObject);
begin
 Edit12.Enabled:=CheckBox34.Checked;
 Edit13.Enabled:=CheckBox34.Checked;
end;

procedure TOptionsForm.CheckBox36Click(Sender: TObject);
begin
 ListBox1.Enabled:=not CheckBox36.Checked;
 if CheckBox36.Checked then
 begin
  DBkernel.LoadColorTheme;
  LoadColorsToWindow;
 end;
end;

end.
