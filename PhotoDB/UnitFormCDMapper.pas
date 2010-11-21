unit UnitFormCDMapper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Dolphin_DB, UnitDBKernel,
  ImgList, UnitCDMappingSupport, UnitDBCommonGraphics, Menus, DB, CommonDBSupport,
  uVistaFuncs, uLogger, uDBForm, uMemory, UnitDBDeclare, uDBPopupMenuInfo;

type
  TFormCDMapper = class(TDBForm)
    Image1: TImage;
    LabelInfo: TLabel;
    CDMappingListView: TListView;
    ButtonOK: TButton;
    ButtonAddocation: TButton;
    ButtonRemoveLocation: TButton;
    CDImageList: TImageList;
    PopupMenuCDActions: TPopupMenu;
    Explorer1: TMenuItem;
    N1: TMenuItem;
    Dismount1: TMenuItem;
    N2: TMenuItem;
    RefreshDBFilesOnCD1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
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
    { Private declarations }
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute;
    procedure RefreshCDList;
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
  try
    DBkernel.ImageList.GetIcon(DB_IC_CD_IMAGE, Icon);
    CDImageList.AddIcon(Icon);
  finally
    Icon.Free;
  end;
  LoadLanguage;
  RefreshCDList;
end;

procedure TFormCDMapper.ButtonOKClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCDMapper.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
end;

procedure TFormCDMapper.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('CD mapping');
    LabelInfo.Caption := Format(L('In this window you can manage remvable drives with photos. To mount drive - select this disk or select file "%s" in file system'), [C_CD_MAP_FILE]);
    CDMappingListView.Columns[0].Caption := L('ID');
    CDMappingListView.Columns[1].Caption := L('Name');
    CDMappingListView.Columns[2].Caption := L('CD location');
    CDMappingListView.Columns[3].Caption := L('Mounted');
    ButtonRemoveLocation.Caption := L('Unmount drive');
    ButtonAddocation.Caption := L('Mount drive');
    ButtonOK.Caption := L('Ok');
    Explorer1.Caption := L('Explore removable drive');
    Dismount1.Caption := L('Unmount drive');
    RefreshDBFilesOnCD1.Caption := L('Refresh files in DB for this CD');
  finally
    EndTranslate;
  end;
end;

procedure TFormCDMapper.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
   Close;
end;

function TFormCDMapper.GetFormID: string;
begin
  Result := 'CDMapper';
end;

procedure TFormCDMapper.ButtonAddocationClick(Sender: TObject);
begin
  AddCDLocation;
  RefreshCDList;
end;

procedure TFormCDMapper.RefreshCDList;
var
  I: Integer;
  List: TList;
  Item, CDItem: PCDClass;
  ListItem: TListItem;
begin
  if CDMapper = nil then
    Exit;
  CDMappingListView.Items.BeginUpdate;
  try
    CDMappingListView.Items.Clear;
    List := CDMapper.GetFindedCDList;
    for I := 0 to List.Count - 1 do
    begin
      Item := List[I];
      ListItem := CDMappingListView.Items.Add;
      ListItem.ImageIndex := 0;
      ListItem.Caption := IntToStr(I + 1);
      ListItem.SubItems.Add(Item.name);
      ListItem.Data := Item;
      CDItem := CDMapper.GetCDByName(Item.name);
      if CDItem <> nil then
      begin
        if CDItem.Path <> nil then
          ListItem.SubItems.Add(CDItem.Path)
        else
          ListItem.SubItems.Add('');
      end
      else
        ListItem.SubItems.Add('');

    end;
  finally
    CDMappingListView.Items.EndUpdate;
  end;
end;

procedure TFormCDMapper.CDMappingListViewDblClick(Sender: TObject);
begin
  if CDMappingListView.Selected <> nil then
  begin
    CheckCD(PCDClass(CDMappingListView.Selected.Data).name);
    RefreshCDList;
  end;
end;

procedure TFormCDMapper.CDMappingListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  ButtonRemoveLocation.Enabled := Selected;
end;

procedure TFormCDMapper.ButtonRemoveLocationClick(Sender: TObject);
begin
  if CDMappingListView.Selected <> nil then
  begin
    CDMapper.RemoveCDMapping(PCDClass(CDMappingListView.Selected.Data).Name);
    RefreshCDList;
  end;
end;

procedure TFormCDMapper.PopupMenuCDActionsPopup(Sender: TObject);
begin
  Explorer1.Visible := False;
  Dismount1.Visible := False;
  RefreshDBFilesOnCD1.Visible := False;
  if CDMappingListView.Selected <> nil then
  begin
    RefreshDBFilesOnCD1.Visible := PCDClass(CDMappingListView.Selected.Data).Path <> nil;
    Dismount1.Visible := RefreshDBFilesOnCD1.Visible;
    Explorer1.Visible := Dismount1.Visible;
  end;
end;

procedure TFormCDMapper.Explorer1Click(Sender: TObject);
begin
  if CDMappingListView.Selected <> nil then
  begin
    with ExplorerManager.NewExplorer(False) do
    begin
      SetOldPath(PCDClass(CDMappingListView.Selected.Data).Path);
      SetPath(GetDirectory(PCDClass(CDMappingListView.Selected.Data).Path));
      Show;
    end;
  end;
end;

procedure TFormCDMapper.RefreshDBFilesOnCD1Click(Sender: TObject);
var
  Options: TRefreshIDRecordThreadOptions;
  DS: TDataSet;
  I: Integer;
  CD: PCDClass;
  Info: TDBPopupMenuInfo;
  InfoRecord: TDBPopupMenuInfoRecord;
begin
  if CDMappingListView.Selected <> nil then
    if CDMappingListView.Selected.Data <> nil then
    begin
      CD := CDMapper.GetCDByName(PCDClass(CDMappingListView.Selected.Data).name);
      if CD <> nil then
      begin
        DS := GetQuery;
        SetSQL(DS,
          'Select ID,FFileName from $DB$ where FFileName Like "%::' + AnsiLowerCase
            (PCDClass(CDMappingListView.Selected.Data).name) + '::%"');

        try
          DS.Open;
        except
          on E: Exception do
          begin
            MessageBoxDB(Handle, Format(L('Unexpected error: %s'), [E.message]), L('Error'), TD_BUTTON_OK,
              TD_ICON_ERROR);
            EventLog(':TFormCDMapper::RefreshDBFilesOnCD1Click() throw exception ' + E.message);
            Exit;
          end;
        end;
        if DS.RecordCount > 0 then
        begin
          Info := TDBPopupMenuInfo.Create;
          try
            DS.First;
            for I := 1 to DS.RecordCount do
            begin
              InfoRecord := TDBPopupMenuInfoRecord.Create;
              InfoRecord.FileName := DS.FieldByName('FFileName').AsString;
              InfoRecord.ID := DS.FieldByName('ID').AsInteger;
              InfoRecord.Selected := True;
              info.Add(InfoRecord);
              DS.Next;
            end;
            TRefreshDBRecordsThread.Create(Options);
          finally
            F(Info);
          end;
        end;
        FreeDS(DS);
      end;
    end;
end;

end.
