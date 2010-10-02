unit UnitFormCDMapper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Language, Dolphin_DB, UnitDBKernel,
  ImgList, UnitCDMappingSupport, UnitDBCommonGraphics, Menus, DB, CommonDBSupport,
  uVistaFuncs, uLogger;

type
  TFormCDMapper = class(TForm)
    Image1: TImage;
    LabelInfo: TLabel;
    CDMappingListView: TListView;
    ButtonOK: TButton;
    ButtonAddocation: TButton;
    ButtonRemoveLocation: TButton;
    TimerDestroy: TTimer;
    CDImageList: TImageList;
    PopupMenuCDActions: TPopupMenu;
    Explorer1: TMenuItem;
    N1: TMenuItem;
    Dismount1: TMenuItem;
    N2: TMenuItem;
    RefreshDBFilesOnCD1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerDestroyTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonAddocationClick(Sender: TObject);
    procedure CDMappingListViewDblClick(Sender: TObject);
    procedure CDMappingListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ButtonRemoveLocationClick(Sender: TObject);
    procedure PopupMenuCDActionsPopup(Sender: TObject);
    procedure Explorer1Click(Sender: TObject);
    procedure RefreshDBFilesOnCD1Click(Sender: TObject);
  private
   procedure LoadLanguage;
    { Private declarations }
  public
   procedure Execute;
   procedure RefreshCDList;
    { Public declarations }
  end;
                    
procedure DoManageCDMapping;

implementation

uses UnitFormCDMapInfo, ExplorerUnit, UnitRefreshDBRecordsThread;

{$R *.dfm}

procedure DoManageCDMapping;
var
  FormCDMapper: TFormCDMapper;
begin
  Application.CreateForm(TFormCDMapper, FormCDMapper);
  FormCDMapper.Execute;
end;

procedure TFormCDMapper.Execute;
begin
 ShowModal;
end;

procedure TFormCDMapper.FormCreate(Sender: TObject);
var
  Icon : TIcon;
begin
  PopupMenuCDActions.Images:=DBKernel.ImageList;
  Icon:=TIcon.Create;
  DBkernel.ImageList.GetIcon(DB_IC_CD_IMAGE, Icon);
  CDImageList.AddIcon(Icon);
  Icon.Free;
  DBKernel.RegisterForm(Self);
  DBKernel.RecreateThemeToForm(Self);
  LoadLanguage;
  RefreshCDList;
end;

procedure TFormCDMapper.FormDestroy(Sender: TObject);
begin
 DBKernel.UnRegisterForm(Self);
end;

procedure TFormCDMapper.ButtonOKClick(Sender: TObject);
begin
 Close;
end;

procedure TFormCDMapper.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 TimerDestroy.Enabled:=true;
end;

procedure TFormCDMapper.TimerDestroyTimer(Sender: TObject);
begin
 TimerDestroy.Enabled:=false;
 Release;
end;

procedure TFormCDMapper.LoadLanguage;
begin
 Caption:=TEXT_MES_CD_MAPPING_CAPTION; 
 LabelInfo.Caption:=TEXT_MES_CD_MAPPING_INFO;
 CDMappingListView.Columns[0].Caption:=TEXT_MES_ID;
 CDMappingListView.Columns[1].Caption:=TEXT_MES_NAME;  
 CDMappingListView.Columns[2].Caption:=TEXT_MES_CD_LOCATION;
 CDMappingListView.Columns[3].Caption:=TEXT_MES_CD_MOUNED_PERMANENT;
 ButtonRemoveLocation.Caption:=TEXT_MES_REMOVE_CD_LOCATION;
 ButtonAddocation.Caption:=TEXT_MES_ADD_CD_LOCATION;
 ButtonOK.Caption:=TEXT_MES_OK;

 Explorer1.Caption:=TEXT_MES_EXPLORER_CD_DVD;
 Dismount1.Caption:=TEXT_MES_REMOVE_CD_LOCATION;
 RefreshDBFilesOnCD1.Caption:=TEXT_MES_REFRESH_DB_FILES_ON_CD;
end;

procedure TFormCDMapper.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

procedure TFormCDMapper.ButtonAddocationClick(Sender: TObject);
begin
 AddCDLocation;
 RefreshCDList;
end;

procedure TFormCDMapper.RefreshCDList;
var
  i : integer;
  List : TList;
  Item, CDItem : PCDClass;
  ListItem : TListItem;
begin
 if CDMapper=nil then exit;
 CDMappingListView.Items.BeginUpdate;
 CDMappingListView.Items.Clear;
 List:=CDMapper.GetFindedCDList;
 for i:=0 to List.Count-1 do
 begin
  Item:=List[i];
  ListItem:=CDMappingListView.Items.Add;
  ListItem.ImageIndex:=0;
  ListItem.Caption:=IntToStr(i+1);
  ListItem.SubItems.Add(Item.Name);
  ListItem.Data:=Item;
  CDItem:=CDMapper.GetCDByName(Item.Name);
  if CDItem<>nil then
  begin
   if CDItem.Path<>nil then ListItem.SubItems.Add(CDItem.Path) else ListItem.SubItems.Add('');
  end else ListItem.SubItems.Add('');

 end;
 CDMappingListView.Items.EndUpdate;
end;

procedure TFormCDMapper.CDMappingListViewDblClick(Sender: TObject);
begin
 if CDMappingListView.Selected<>nil then
 begin
  CheckCD(PCDClass(CDMappingListView.Selected.Data).Name);
  RefreshCDList;
 end;
end;

procedure TFormCDMapper.CDMappingListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
 ButtonRemoveLocation.Enabled:=Selected;
end;

procedure TFormCDMapper.ButtonRemoveLocationClick(Sender: TObject);
begin
 if CDMappingListView.Selected<>nil then
 begin
  CDMapper.RemoveCDMapping(PCDClass(CDMappingListView.Selected.Data).Name);
  RefreshCDList;
 end;
end;

procedure TFormCDMapper.PopupMenuCDActionsPopup(Sender: TObject);
begin
 Explorer1.Visible:=false;
 Dismount1.Visible:=false;
 RefreshDBFilesOnCD1.Visible:=false;
 if CDMappingListView.Selected<>nil then
 begin
  RefreshDBFilesOnCD1.Visible:=PCDClass(CDMappingListView.Selected.Data).Path<>nil;
  Dismount1.Visible:=RefreshDBFilesOnCD1.Visible;
  Explorer1.Visible:=Dismount1.Visible;
 end;
end;

procedure TFormCDMapper.Explorer1Click(Sender: TObject);
begin
 if CDMappingListView.Selected<>nil then
 begin
  With ExplorerManager.NewExplorer(False) do
  begin
   SetOldPath(PCDClass(CDMappingListView.Selected.Data).Path);
   SetPath(GetDirectory(PCDClass(CDMappingListView.Selected.Data).Path));
   Show;
  end;
 end;
end;

procedure TFormCDMapper.RefreshDBFilesOnCD1Click(Sender: TObject);
var
  Options : TRefreshIDRecordThreadOptions;
  DS : TDataSet;
  i : integer;
  CD : PCDClass;
begin
 if CDMappingListView.Selected<>nil then   
 if CDMappingListView.Selected.Data<>nil then
 begin
  CD:=CDMapper.GetCDByName(PCDClass(CDMappingListView.Selected.Data).Name);
  if CD<>nil then
  begin
   DS:=GetQuery;
   SetSQL(DS,'Select ID,FFileName from $DB$ where FFileName Like "%::'+AnsiLowerCase(PCDClass(CDMappingListView.Selected.Data).Name)+'::%"');

   try
    DS.Open;
   except
    on e : Exception do
    begin
     MessageBoxDB(Handle,Format(Language.TEXT_MES_ERROR_RUNNING_F,[e.Message]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     EventLog(':TFormCDMapper::RefreshDBFilesOnCD1Click() throw exception '+e.Message);
     exit;
    end;
   end;
   if DS.RecordCount>0 then
   begin
    DS.First;
    SetLength(Options.Files,DS.RecordCount);
    SetLength(Options.IDs,DS.RecordCount);
    SetLength(Options.Selected,DS.RecordCount);
    for i:=1 to DS.RecordCount do
    begin
     Options.Files[i-1]:=DS.FieldByName('FFileName').AsString;
     Options.IDs[i-1]:=DS.FieldByName('ID').AsInteger;
     Options.Selected[i-1]:=true;
     DS.Next;
    end;
    TRefreshDBRecordsThread.Create(false,Options);
   end;
   FreeDS(DS);
  end;
 end;
end;

end.
