unit uExplorerGroupsProvider;

interface

uses
  System.SysUtils,
  System.StrUtils,
  Winapi.Windows,
  Vcl.Graphics,

  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,

  UnitDBDeclare,

  uConstants,
  uMemory,
  uExplorerPathProvider,
  uShellIntegration,
  uDBForm,
  uDBContext,
  uDBEntities,
  uDBManager,
  uFormInterfaces,
  uCollectionEvents,
  uTranslate,
  uStringUtils,
  uBitmapUtils,
  uJpegUtils;

type
  TGroupsItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TGroupItem = class(TPathItem)
  private
    FGroupName: string;
    FKeywords: string;
    FComment: string;
    procedure SetGroupName(const Value: string);
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    procedure ReadFromGroup(Group: TGroup; Options, ImageSize: Integer);
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property GroupName: string read FGroupName write SetGroupName;
    property Keywords: string read FKeywords;
    property Comment: string read FComment;
  end;

type
  TGroupProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
    function Delete(Sender: TObject; Items: TPathItemCollection; Options: TPathFeatureOptions): Boolean;
    function ShowProperties(Sender: TObject; Items: TPathItemCollection): Boolean;
    function Rename(Sender: TObject; Items: TPathItemCollection; Options: TPathFeatureEditOptions): Boolean;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function ExecuteFeature(Sender: TObject; Items: TPathItemCollection; Feature: string; Options: TPathFeatureOptions): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

uses
  UnitGroupsTools;

{ TGroupProvider }

function ExtractGroupName(Path: string): string;
var
  P: Integer;
begin
  Result := '';
  P := Pos('\', Path);
  if P > 0 then
    Result := Right(Path, P + 1);;
end;

function TGroupProvider.CreateFromPath(Path: string): TPathItem;
var
  S: string;
begin
  Result := nil;
  if Path = cGroupsPath then
    Result := TGroupsItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
  if StartsText(cGroupsPath + '\', Path) then
  begin
    S := Path;
    System.Delete(S, 1, Length(cGroupsPath) + 1);

    //subitem
    if Pos('\', S) > 0 then
      Exit;

    Result := TGroupItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
  end;
end;

function TGroupProvider.Delete(Sender: TObject; Items: TPathItemCollection; Options: TPathFeatureOptions): Boolean;
var
  EventInfo: TEventValues;
  Group: TGroup;
  GroupItem: TGroupItem;
  Form: TDBForm;
  Context: IDBContext;
  GroupsRepository: IGroupsRepository;
begin
  Result := False;
  Form := TDBForm(Sender);

  if Items.Count = 0 then
    Exit;

  if Items.Count > 1 then
  begin
    MessageBoxDB(Form.Handle, L('Please delete only one group at time!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  GroupItem := Items[0] as TGroupItem;

  if GroupItem = nil then
    Exit;

  Context := DBManager.DBContext;
  GroupsRepository := Context.Groups;

  Group := GroupsRepository.GetByName(GroupItem.GroupName, False);
  try
    EventInfo.Data := GroupItem;
    if ID_OK = MessageBoxDB(Form.Handle, Format(L('Do you really want to delete group "%s"?'), [Group.GroupName]), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      if GroupsRepository.Delete(Group) then
      begin
        if ID_OK = MessageBoxDB(Form.Handle, Format(L('Scan collection and remove all pointers to group "%s"?'), [Group.GroupName]),
          L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        begin
          UnitGroupsTools.DeleteGroup(Context, Group);
          CollectionEvents.DoIDEvent(Form, 0, [EventID_Param_GroupsChanged, EventID_GroupRemoved, EventID_Param_Refresh, EventID_Param_Critical, EventID_Param_Refresh_Window], EventInfo);
          Result := True;
          Exit;
        end;
        CollectionEvents.DoIDEvent(Form, 0, [EventID_Param_GroupsChanged, EventID_GroupRemoved], EventInfo);
      end;
  finally
    F(Group);
  end;
end;

function TGroupProvider.ExecuteFeature(Sender: TObject; Items: TPathItemCollection;
  Feature: string; Options: TPathFeatureOptions): Boolean;
begin
  Result := inherited ExecuteFeature(Sender, Items, Feature, Options);

  if Feature = PATH_FEATURE_DELETE then
    Result := Delete(Sender, Items, Options);

  if Feature = PATH_FEATURE_PROPERTIES then
    Result := ShowProperties(Sender, Items);

  if Feature = PATH_FEATURE_RENAME then
    Result := Rename(Sender, Items, Options as TPathFeatureEditOptions);
end;

function TGroupProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
var
  Group: TGroup;
  Context: IDBContext;
  GroupsRepository: IGroupsRepository;
begin
  Result := False;

  Context := DBManager.DBContext;
  GroupsRepository := Context.Groups;

  Group := GroupsRepository.GetByName(ExtractGroupName(Item.Path), True);

  try
    if (Group = nil) or (Group.GroupImage = nil) then
      Exit;

    Bitmap.Assign(Group.GroupImage);
    KeepProportions(Bitmap, MaxWidth, MaxHeight);
    Result := True;
  finally
    F(Group);
  end;
end;

function TGroupProvider.GetTranslateID: string;
begin
  Result := 'GroupsProvider';
end;

function TGroupProvider.InternalFillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize, PacketSize: Integer;
  CallBack: TLoadListCallBack): Boolean;
var
  I: Integer;
  GI: TGroupsItem;
  G: TGroupItem;
  Cancel: Boolean;
  Groups: TGroups;
  Context: IDBContext;
  GroupsRepository: IGroupsRepository;
begin
  inherited;
  Result := True;
  Cancel := False;

  if Options and PATH_LOAD_ONLY_FILE_SYSTEM > 0 then
    Exit;

  if Item is THomeItem then
  begin
    GI := TGroupsItem.CreateFromPath(cGroupsPath, Options, ImageSize);
    List.Add(GI);
  end;

  if Item is TGroupsItem then
  begin
    Context := DBManager.DBContext;
    GroupsRepository := Context.Groups;

    Groups := GroupsRepository.GetAll(True, True);
    try
      for I := 0 to Groups.Count - 1 do
      begin
        G := TGroupItem.CreateFromPath(cGroupsPath + '\' + Groups[I].GroupName, PATH_LOAD_NO_IMAGE, 0);
        G.ReadFromGroup(Groups[I], Options, ImageSize);
        List.Add(G);

        if List.Count mod PacketSize = 0 then
        begin
          if Assigned(CallBack) then
            CallBack(Sender, Item, List, Cancel);
          if Cancel then
            Break;
        end;
      end;
    finally
      F(Groups);
    end;
  end;

  if Assigned(CallBack) then
    CallBack(Sender, Item, List, Cancel);
end;

function TGroupProvider.Rename(Sender: TObject; Items: TPathItemCollection;
  Options: TPathFeatureEditOptions): Boolean;
var
  Group: TGroup;
  Form: TDBForm;
  EventInfo: TEventValues;
  Item: TGroupItem;
  Context: IDBContext;
  GroupsRepository: IGroupsRepository;
begin
  Result := False;

  if Items.Count = 0 then
    Exit;

  Context := DBManager.DBContext;
  GroupsRepository := Context.Groups;

  Item := Items[0] as TGroupItem;

  Group := GroupsRepository.GetByName(Item.GroupName, False);
  try
    Form := TDBForm(Sender);

    if Group.GroupName <> Options.NewName then
    begin
      if GroupsRepository.HasGroupWithName(Options.NewName) then
      begin
        MessageBoxDB(Form.Handle, L('Group with this name already exists!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
        Exit;
      end;

      if ID_OK <> MessageBoxDB(Form.Handle, L('Do you really want to change name of this group?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        Exit;

      Group.GroupName := Options.NewName;
      if GroupsRepository.Update(Group) then
      begin
        RenameGroup(Context, Group, Options.NewName);

        EventInfo.FileName := Item.GroupName;
        EventInfo.NewName := Options.NewName;

        Item.GroupName := Options.NewName;
        EventInfo.Data := Item;
        CollectionEvents.DoIDEvent(Form, 0, [EventID_Param_GroupsChanged, EventID_GroupChanged, EventID_Param_Refresh, EventID_Param_Critical, EventID_Param_Refresh_Window], EventInfo);

        Result := True;
      end;
    end;
  finally
    F(Group);
  end;
end;

function TGroupProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TGroupsItem;
  Result := Item is TGroupItem or Result;
  Result := Result or Supports(Item.Path);
end;

function TGroupProvider.ShowProperties(Sender: TObject; Items: TPathItemCollection): Boolean;
begin
  Result := False;
  if Items.Count = 0 then
    Exit;

  GroupInfoForm.Execute(nil, TGroupItem(Items[0]).GroupName, False);
  Result := True;
end;

function TGroupProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cGroupsPath, Path);

  if Result then
  begin
    System.Delete(Path, 1, Length(cGroupsPath) + 1);

    //subitem
    if Pos('\', Path) > 0 then
      Result := False;
  end;
end;

function TGroupProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_DELETE;
  Result := Result or (Feature = PATH_FEATURE_PROPERTIES);
  Result := Result or (Feature = PATH_FEATURE_RENAME);
end;

{ TGroupItem }

constructor TGroupsItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
begin
  inherited;
  FPath := cGroupsPath;
  FDisplayName := TA('Groups', 'Path');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TGroupsItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TGroupsItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TGroupsItem.Create;
end;

function TGroupsItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TGroupsItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'GROUPS', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TGroupItem }

procedure TGroupItem.Assign(Item: TPathItem);
begin
  inherited;
  FGroupName := TGroupItem(Item).FGroupName;
  FKeywords := TGroupItem(Item).FKeywords;
  FComment := TGroupItem(Item).FComment;
end;

constructor TGroupItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FGroupName := APath;
  Delete(FGroupName, 1, Length(cGroupsPath) + 1);
  FDisplayName := FGroupName;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TGroupItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TGroupItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TGroupItem.Create;
end;

function TGroupItem.InternalGetParent: TPathItem;
begin
  Result := TGroupsItem.CreateFromPath(cGroupsPath, PATH_LOAD_NORMAL, 0);
end;

function TGroupItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Group: TGroup;
  Context: IDBContext;
  GroupsRepository: IGroupsRepository;
begin
  F(FImage);

  Context := DBManager.DBContext;
  GroupsRepository := Context.Groups;
  Group := GroupsRepository.GetByName(GroupName, True);
  try
    ReadFromGroup(Group, Options, ImageSize);
    Result := True;
  finally
    F(Group);
  end;
end;

procedure TGroupItem.ReadFromGroup(Group: TGroup; Options, ImageSize: Integer);
var
  Bitmap: TBitmap;
begin
  FDisplayName := Group.GroupName;
  FGroupName := Group.GroupName;
  FComment := Group.GroupComment;
  FKeywords := Group.GroupKeyWords;
  FPath := cGroupsPath + '\' + Group.GroupName;
  if (Group.GroupImage <> nil) and (ImageSize > 0) then
  begin
    Bitmap := TBitmap.Create;
    try
      JPEGScale(Group.GroupImage, ImageSize, ImageSize);
      AssignJpeg(Bitmap, Group.GroupImage);
      KeepProportions(Bitmap, ImageSize, ImageSize);
      if Options and PATH_LOAD_FOR_IMAGE_LIST <> 0 then
        CenterBitmap24To32ImageList(Bitmap, ImageSize);

      F(FImage);
      FImage := TPathImage.Create(Bitmap);
      Bitmap := nil;
    finally
      F(Bitmap);
    end;
  end;
end;

procedure TGroupItem.SetGroupName(const Value: string);
begin
  FGroupName := Value;
  FPath := cGroupsPath + '\' + FGroupName;
end;

end.
