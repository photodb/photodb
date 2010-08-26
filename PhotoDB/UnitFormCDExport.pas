unit UnitFormCDExport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, ComboBoxExDB, Menus, ImgList,
  Language, Dolphin_DB, UnitDBKernel, Buttons, DragDrop, DropTarget, uFileUtils,
  DragDropFile, UnitCDMappingSupport, UnitDBFileDialogs, UnitDBCommonGraphics,
  AppEvnts, uVistaFuncs, DB, uAssociatedIcons;

type
  TFormCDExport = class(TForm)
    CDListView: TListView;
    PanelBottom: TPanel;
    PanelTop: TPanel;
    ComboBoxPathList: TComboBoxExDB;
    ButtonAddItems: TButton;
    ButtonRemoveItems: TButton;
    ButtonCreateDirectory: TButton;
    LabelInfo: TLabel;
    Image1: TImage;
    LabelCDLabel: TLabel;
    EditLabel: TEdit;
    LabelPath: TLabel;
    ButtonExport: TButton;
    CheckBoxDeleteFiles: TCheckBox;
    CheckBoxModifyDB: TCheckBox;
    PopupMenuListView: TPopupMenu;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N1: TMenuItem;
    Delete1: TMenuItem;
    N2: TMenuItem;
    Open1: TMenuItem;
    ImageListIcons: TImageList;
    LabelExportDirectory: TLabel;
    LabelExportSize: TLabel;
    EditCDSize: TEdit;
    EditExportDirectory: TEdit;
    ButtonChooseDirectory: TButton;
    DestroyTimer: TTimer;
    DropFileTarget1: TDropFileTarget;
    N3: TMenuItem;
    Rename1: TMenuItem;
    N4: TMenuItem;
    AddItems1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    CheckBoxCreatePortableDB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CDListViewDblClick(Sender: TObject);
    procedure ButtonRemoveItemsClick(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      APoint: TPoint; var Effect: Integer);
    procedure ButtonCreateDirectoryClick(Sender: TObject);
    procedure ButtonChooseDirectoryClick(Sender: TObject);
    procedure ButtonAddItemsClick(Sender: TObject);
    procedure ComboBoxPathListSelect(Sender: TObject);
    procedure ButtonExportClick(Sender: TObject);
    procedure PanelTopResize(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure CDListViewEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure CDListViewEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure PopupMenuListViewPopup(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
   Mapping : TCDIndexMapping;
   procedure LoadLanguage;
    { Private declarations }
  protected
   procedure CreateParams(VAR Params: TCreateParams); override;
  public
   procedure Execute;
   procedure DrawCurrentDirectory(ListView : TListView);
   procedure OnThreadEnd(Sender: TObject);
   procedure EnableControls(Value : boolean);
    { Public declarations }
  end;

procedure DoCDExport;

implementation

uses FormManegerUnit, ExplorerThreadUnit, UnitStringPromtForm,
     UnitCDExportThread;

{$R *.dfm}

procedure DoCDExport;
var
  FormCDExport: TFormCDExport;
begin
  Application.CreateForm(TFormCDExport, FormCDExport);
  FormCDExport.Execute;
end;

{ TFormCDExport }

procedure TFormCDExport.Execute;
begin
 Show;
end;

procedure TFormCDExport.FormCreate(Sender: TObject);
begin
 CDListView.DoubleBuffered:=true;
                   
 ConvertTo32BitImageList(ImageListIcons);
 Mapping := TCDIndexMapping.Create;
 EditCDSize.Text:=SizeInTextA(Mapping.GetCDSize);

 DropFileTarget1.Register(CDListView);
 PopupMenuListView.Images:=DBKernel.ImageList;
 DBKernel.RegisterForm(Self);
 DBKernel.RecreateThemeToForm(Self);
 FormManager.RegisterMainForm(Self);
 ComboBoxPathList.ItemIndex:=0;
 LoadLanguage;
 Open1.ImageIndex:=DB_IC_SHELL;
 Copy1.ImageIndex:=DB_IC_COPY;
 Cut1.ImageIndex:=DB_IC_CUT;
 Paste1.ImageIndex:=DB_IC_PASTE;
 Delete1.ImageIndex:=DB_IC_DELETE_INFO;
 Rename1.ImageIndex:=DB_IC_RENAME;
 AddItems1.ImageIndex:=DB_IC_NEW;

 PanelTopResize(Self);
end;

procedure TFormCDExport.LoadLanguage;
begin
 Caption:=TEXT_MES_CD_EXPORT_CAPTION;
 LabelInfo.Caption:=TEXT_MES_CD_EXPORT_INFO;
 LabelCDLabel.Caption:=TEXT_MES_CREATE_CD_WITH_LABEL+':';
 EditLabel.Text:=TEXT_MES_CD_EXPORT_LABEL_DEFAULT;
 LabelPath.Caption:=TEXT_MES_PATH+':';
 ButtonAddItems.Caption:=TEXT_MES_ADD_CD_ITEMS;
 ButtonRemoveItems.Caption:=TEXT_MES_REMOVE_CD_ITEMS;
 ButtonCreateDirectory.Caption:=TEXT_MES_CREATE_DIRECTORY;
 CDListView.Columns[0].Caption:=TEXT_MES_CD_EXPORT_LIST_VIEW_LOCUMN_FILE_NAME;
 CDListView.Columns[1].Caption:=TEXT_MES_CD_EXPORT_LIST_VIEW_LOCUMN_FILE_SIZE; 
 CDListView.Columns[2].Caption:=TEXT_MES_CD_EXPORT_LIST_VIEW_LOCUMN_DB_ID;

 CheckBoxDeleteFiles.Caption:=TEXT_MES_CD_EXPORT_DELETE_ORIGINAL_FILES;
 CheckBoxModifyDB.Caption:=TEXT_MES_CD_EXPORT_MODIFY_DB;
 ButtonExport.Caption:=TEXT_MES_DO_CD_EXPORT;
 LabelExportDirectory.Caption:=TEXT_MES_CD_EXPORT_DIRECTORY+':';
 ButtonChooseDirectory.Caption:=TEXT_MES_CHOOSE_DIRECTORY;
 Open1.Caption:=TEXT_MES_OPEN;
 Copy1.Caption:=TEXT_MES_COPY;
 Cut1.Caption:=TEXT_MES_CUT;
 Paste1.Caption:=TEXT_MES_PASTE;
 Delete1.Caption:=TEXT_MES_DELETE;
 LabelExportSize.Caption:=TEXT_MES_CD_EXPORT_SIZE+':';
 Rename1.Caption:=TEXT_MES_RENAME;
 AddItems1.Caption:=TEXT_MES_ADD_CD_ITEMS;

 CheckBoxCreatePortableDB.Caption:=TEXT_MES_CREATE_PORTABLE_DB;
end;

procedure TFormCDExport.FormDestroy(Sender: TObject);
begin
 FormManager.UnRegisterMainForm(Self);
 DBKernel.UnRegisterForm(Self);
 Mapping.Free;
end;

procedure TFormCDExport.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
end;

procedure TFormCDExport.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
end;

procedure TFormCDExport.DrawCurrentDirectory(ListView : TListView);
var
  Level : PCDIndexMappingDirectory;
  i, ID : integer;
  Item : TListItem;
  Size : int64;
  PathList : TStrings;
  Icon : TIcon;
begin
 ListView.Items.BeginUpdate;
 ListView.Items.Clear;
 ImageListIcons.Clear;
 Level:=Mapping.CurrentLevel;
 if Level.Parent<>nil then
 begin
  Item:=ListView.Items.Add;
  Item.Caption:='[..]';
  Item.Data:=nil;
  Icon:=TAIcons.Instance.GetIconByExt('',true,16,true);
  Item.ImageIndex:=ImageListIcons.AddIcon(Icon);
 end;
 for i:=0 to Level.Files.Count-1 do
 begin
  Item:=ListView.Items.Add;
  Item.Caption:=PCDIndexMappingDirectory(Level.Files[i]).Name;
  Item.Data:=Level.Files[i];
  Size:=Mapping.GetCDSizeWithDirectory(Level.Files[i]);
  if Size>0 then
  Item.SubItems.Add(SizeInTextA(Size)) else Item.SubItems.Add('');
  ID:=PCDIndexMappingDirectory(Level.Files[i]).DB_ID;
  if ID>0 then
  Item.SubItems.Add(IntToStr(ID)) else
  begin
   if Mapping.DirectoryHasDBFiles(Item.Data) then
   Item.SubItems.Add('+') else Item.SubItems.Add('');
  end;

  if PCDIndexMappingDirectory(Level.Files[i]).IsFile then
  begin
   Icon:=TAIcons.Instance.GetIconByExt(PCDIndexMappingDirectory(Level.Files[i]).RealFileName,false,16,false);
  end else
  begin
   Icon:=TAIcons.Instance.GetIconByExt('',true,16,true);
  end;
  Item.ImageIndex:=ImageListIcons.AddIcon(Icon);
 end;
 ListView.Items.EndUpdate;
 EditCDSize.Text:=SizeInTextA(Mapping.GetCDSize);
 ComboBoxPathList.Items.Clear;
 PathList:= Mapping.GetCurrentUpperDirectories;
 for i:=PathList.Count-1 downto 0 do
 ComboBoxPathList.Items.Add(PathList[i]);
 ComboBoxPathList.ItemIndex:=0;
 PathList.Free;
end;

procedure TFormCDExport.CDListViewDblClick(Sender: TObject);
var
  Item : TListItem;
begin
 Item:=CDListView.Selected;
 if Item=nil then exit;

 if Item.Data=nil then
 begin
  Mapping.GoUp;    
  DrawCurrentDirectory(CDListView);
  exit;
 end;

 if Item.Data<>nil then
 if not PCDIndexMappingDirectory(Item.Data).IsFile then
 begin
  Mapping.SelectDirectory(PCDIndexMappingDirectory(Item.Data).Name);
  DrawCurrentDirectory(CDListView);
 end;
end;

procedure TFormCDExport.ButtonRemoveItemsClick(Sender: TObject);
var
  i : integer;
  Item : PCDIndexMappingDirectory;
begin
 for i:=CDListView.Items.Count-1 downto 0 do
 if CDListView.Items[i].Selected then
 begin
  Item:=CDListView.Items[i].Data;
  if Item<>nil then
  begin
   if Item.IsFile then
   Mapping.DeleteFile(Item.Name) else
   Mapping.DeleteDirectory(Item.Name);
  end;
  Mapping.ClearClipBoard;
 end;
 DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; APoint: TPoint; var Effect: Integer);
var
  FileList : TStrings;
begin
  FileList := TStringList.Create;
  try
    DropFileTarget1.Files.AssignTo(FileList);
    Mapping.AddRealItemsToCurrentDirectory(FileList);
    DrawCurrentDirectory(CDListView);
  finally
    FileList.Free;
  end;
end;

procedure TFormCDExport.ButtonCreateDirectoryClick(Sender: TObject);
var
  DirectoryName : string;
begin
 DirectoryName:=Language.TEXT_MES_NEW_FOLDER;
 if PromtString(TEXT_MES_CREATE_DIRECTORY,TEXT_MES_ENTER_NEW_VIRTUAL_DIRECTORY_NAME,DirectoryName) then
 begin
  Mapping.CreateDirectory(DirectoryName);
  DrawCurrentDirectory(CDListView);
 end;
end;

procedure TFormCDExport.ButtonChooseDirectoryClick(Sender: TObject);
var
  Dir : String;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SELECT_PLACE_TO_CD_EXPORT,Dolphin_DB.UseSimpleSelectFolderDialog);
 If DirectoryExists(Dir) then
 EditExportDirectory.Text:=Dir;
end;

procedure TFormCDExport.ButtonAddItemsClick(Sender: TObject);
var
  Dialog : DBOpenDialog;
begin
 Dialog:=DBOpenDialog.Create;
 Dialog.EnableMultyFileChooseWithDirectory;
 if Dialog.Execute then
 begin
  Mapping.AddRealItemsToCurrentDirectory(Dialog.GetFiles);
  DrawCurrentDirectory(CDListView);
 end;
end;

procedure TFormCDExport.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);
 Params.WndParent := GetDesktopWindow;
 with params do
 ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormCDExport.ComboBoxPathListSelect(Sender: TObject);
begin
 Mapping.SelectPath(ComboBoxPathList.Items[ComboBoxPathList.ItemIndex]);
 DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.EnableControls(Value : boolean);
begin
   EditLabel.Enabled:=Value;
   EditCDSize.Enabled:=Value;
   PanelTop.Enabled:=Value;
   ButtonAddItems.Enabled:=Value;
   ButtonRemoveItems.Enabled:=Value;
   ButtonCreateDirectory.Enabled:=Value;
   CDListView.Enabled:=Value;
   ButtonChooseDirectory.Enabled:=Value;
   CheckBoxDeleteFiles.Enabled:=Value;
   CheckBoxModifyDB.Enabled:=Value;
   ButtonExport.Enabled:=Value;
end;

procedure TFormCDExport.ButtonExportClick(Sender: TObject);
var
  Drive, Directory : string;
  DriveFreeSize : int64;
  Options : TCDExportOptions;
begin
 if (Pos(':',EditLabel.Text)>0) or (Pos('\',EditLabel.Text)>0) or (Pos('?',EditLabel.Text)>0) or (EditLabel.Text='') then
 begin
  MessageBoxDB(Handle,TEXT_MES_ENTER_CD_LABEL_TO_IDENTIFY_DISK,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  EditLabel.SetFocus;
  EditLabel.SelectAll;
  exit;
 end;
 Mapping.CDLabel:=EditLabel.Text;
 DriveFreeSize:=DiskFree(ord(AnsiLowerCase(EditExportDirectory.Text)[1])-ord('a')+1);
 if Mapping.GetCDSize>DriveFreeSize then
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_UNABLE_TO_COPY_DISK_FULL_F,[SizeInTextA(Mapping.GetCDSize),SizeInTextA(DriveFreeSize)]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  exit;
 end;

 if not Mapping.DirectoryHasDBFiles(Mapping.GetRoot) then
 begin
  if ID_YES<>MessageBoxDB(Handle,TEXT_MES_CD_EXPORT_HASNT_ANY_DB_FILE,TEXT_MES_WARNING,TD_BUTTON_YESNO,TD_ICON_WARNING) then exit;
 end;
                
 EnableControls(false);
 //in thread!

 Options.ToDirectory:=EditExportDirectory.Text;
 Options.DeleteFiles:=CheckBoxDeleteFiles.Checked;
 Options.ModifyDB:=CheckBoxModifyDB.Checked;
 Options.CreatePortableDB:=CheckBoxCreatePortableDB.Checked;
 Options.OnEnd:=OnThreadEnd;

 TCDExportThread.Create(false,Mapping,Options);

end;

procedure TFormCDExport.PanelTopResize(Sender: TObject);
begin
 ButtonCreateDirectory.Left:=PanelTop.Width-ButtonCreateDirectory.Width-5;
 ButtonRemoveItems.Left:=ButtonCreateDirectory.Left-ButtonRemoveItems.Width-5;
 ButtonAddItems.Left:=ButtonRemoveItems.Left-ButtonAddItems.Width-5;
 ComboBoxPathList.Width:=ButtonAddItems.Left-ComboBoxPathList.Left-5;
                                                                      
 ButtonExport.Left:=PanelTop.Width-ButtonExport.Width-5;
end;

procedure TFormCDExport.Rename1Click(Sender: TObject);
var
  Item : TListItem;
begin
 Item:=CDListView.Selected;
 if Item<>nil then
 begin
  Item.EditCaption;
 end;
end;

procedure TFormCDExport.CDListViewEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
 if Item<>nil then
 if Item.Data=nil then AllowEdit:=false;
end;

procedure TFormCDExport.CDListViewEdited(Sender: TObject; Item: TListItem;
  var S: String);
var
  Data : PCDIndexMappingDirectory;
begin
 Data:=PCDIndexMappingDirectory(Item.Data);
 if Data.IsFile then
 if Mapping.FileExists(S) then
 begin
  S:=Item.Caption;
  exit;
 end;
 if not Data.IsFile then
 if Mapping.DirectoryExists(S) then
 begin
  S:=Item.Caption;
  exit;
 end;
 Data.Name:=S;
end;

procedure TFormCDExport.PopupMenuListViewPopup(Sender: TObject);
begin
 Open1.Visible:=CDListView.SelCount>0;
 Copy1.Visible:=CDListView.SelCount>0;  
 Cut1.Visible:=CDListView.SelCount>0;
 Paste1.Visible:=CDListView.SelCount=0;  
 Rename1.Visible:=CDListView.SelCount=1;
 Delete1.Visible:=CDListView.SelCount>0;
end;

procedure TFormCDExport.Copy1Click(Sender: TObject);
var
  i : integer;
  Item : PCDIndexMappingDirectory;
  List : TList;
begin
 List:=TList.Create;
 for i:=CDListView.Items.Count-1 downto 0 do
 if CDListView.Items[i].Selected then
 begin
  Item:=CDListView.Items[i].Data;
  List.Add(Item);
 end;
 Mapping.Copy(List);
 List.Free;
 DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.Cut1Click(Sender: TObject);
var
  i : integer;
  Item : PCDIndexMappingDirectory;
  List : TList;
begin
 List:=TList.Create;
 for i:=CDListView.Items.Count-1 downto 0 do
 if CDListView.Items[i].Selected then
 begin
  Item:=CDListView.Items[i].Data;
  List.Add(Item);
 end;
 Mapping.Cut(List);
 List.Free;
 DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.Paste1Click(Sender: TObject);
begin
 Mapping.Paste;
 DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if Msg.hwnd=CDListView.Handle then
 begin
  if Msg.message=256 then
  begin
   //Del  --->  delete selected
   if (Msg.wParam=46) then ButtonRemoveItemsClick(ButtonRemoveItems);
   if (Msg.wParam=13) then CDListViewDblClick(CDListView);
   if (Msg.wParam=113) then
   begin
    Rename1Click(Rename1);
   end;
  end;
 end;
end;

procedure TFormCDExport.OnThreadEnd(Sender: TObject);
var
  Directory : string;
begin
 EnableControls(true);

 Directory:=GetDirectory(EditExportDirectory.Text);
 FormatDir(Directory);
 Directory:=Directory+Mapping.CDLabel+'\';

 MessageBoxDB(Handle,Format(TEXT_MES_CD_EXPORT_OK_F,[Directory]),TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
 Close;
end;

end.
