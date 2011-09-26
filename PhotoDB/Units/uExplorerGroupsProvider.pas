unit uExplorerGroupsProvider;

interface

uses
  Windows, Graphics, uExplorerPathProvider, uPathProviders, UnitGroupsWork,
  uBitmapUtils, UnitDBDeclare, uConstants, UnitDBKernel,
  uShellIntegration, SysUtils, uDBForm, uExplorerMyComputerProvider,
  uMemory, uTranslate, uShellIcons;

type
  TGroupsItem = class(TPathItem)
  private
    FImage: TPathImage;
    FDisplayName: string;
    FParent: TPathItem;
  protected
    function GetPathImage: TPathImage; override;
    function GetDisplayName: string; override;
    function GetParent: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    destructor Destroy; override;
  end;

type
  TGroupProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
    function Delete(Sender: TObject; Item: TDBPopupMenuInfoRecord; Options: Integer): Boolean;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function ExecuteFeature(Sender: TObject; Item: TPathItem; Feature: string; Options: Integer): Boolean; override;
  end;

implementation

uses
  UnitGroupsTools;

{ TGroupProvider }

function TGroupProvider.Delete(Sender: TObject; Item: TDBPopupMenuInfoRecord; Options: Integer): Boolean;
var
  EventInfo: TEventValues;
  Group: TGroup;
  Form: TDBForm;
begin
  Result := False;
  Form := TDBForm(Sender);
  Group := GetGroupByGroupName(Item.Name, False);
  try
    if ID_OK = MessageBoxDB(Form.Handle, Format(L('Do you really want to delete group "%s"?'), [Group.GroupName]), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      if UnitGroupsWork.DeleteGroup(Group) then
      begin
        if ID_OK = MessageBoxDB(Form.Handle, Format(L('Scan collection and remove all pointers to group "%s"?'), [Group.GroupName]),
          L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        begin
          UnitGroupsTools.DeleteGroup(Group);
          MessageBoxDB(Form.Handle, L('Update the data in the windows to apply changes!'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING);
          DBKernel.DoIDEvent(Form, 0, [EventID_Param_GroupsChanged], EventInfo);
          Result := True;
          Exit;
        end;
        DBKernel.DoIDEvent(Form, 0, [EventID_Param_GroupsChanged], EventInfo);
      end;
  finally
    FreeGroup(Group);
  end;
end;

function TGroupProvider.ExecuteFeature(Sender: TObject; Item: TPathItem;
  Feature: string; Options: Integer): Boolean;
begin
  Result := inherited ExecuteFeature(Sender, Item, Feature, Options);

  if Feature = PATH_FEATURE_DELETE then
    Result := Delete(Sender, TDBPopupMenuInfoRecord(Item), Options);
end;

function TGroupProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
var
  Group: TGroup;
  Info: TDBPopupMenuInfoRecord;
begin
  Result := False;
  Info := TDBPopupMenuInfoRecord(Item);
  Group := GetGroupByGroupName(Info.FileName, True);

  if Group.GroupImage = nil then
    Exit;

  try
    Bitmap.Assign(Group.GroupImage);
    KeepProportions(Bitmap, MaxWidth, MaxHeight);
    Result := True;
  finally
    FreeGroup(Group);
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
  GI: TGroupsItem;
  Cancel: Boolean;
begin
  inherited;
  Result := True;
  Cancel := False;
  if Item is THomeItem then
  begin
    GI := TGroupsItem.CreateFromPath(cGroupsPath, Options, ImageSize);
    List.Add(GI);

    CallBack(Sender, Item, List, Cancel);
  end;
end;

function TGroupProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item.Parent.Path = cGroupsPath;
end;

function TGroupProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_DELETE;
end;

{ TGroupItem }

constructor TGroupsItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
var
  Icon: TIcon;
begin
  inherited;
  FParent := nil;
  FPath := cGroupsPath;
  FDisplayName := TA('Groups', 'Path');
  FindIcon(HInstance, 'GROUPS', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
end;

destructor TGroupsItem.Destroy;
begin
  F(FParent);
  F(FImage);
  inherited;
end;

function TGroupsItem.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TGroupsItem.GetParent: TPathItem;
begin
  if FParent = nil then
    FParent := THomeItem.Create;

  Result := FParent;
end;

function TGroupsItem.GetPathImage: TPathImage;
begin
  Result := FImage;
end;

initialization
  PathProviderManager.RegisterProvider(TGroupProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TGroupProvider);

end.
