unit uExplorerShelfProvider;

interface

uses
  System.SysUtils,
  System.StrUtils,
  Vcl.Graphics,

  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,

  uConstants,
  uMemory,
  uTranslate,
  uPhotoShelf,
  uExplorerPathProvider;

type
  TShelfItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TShelfProvider = class(TExplorerPathProvider)
  public
    function GetTranslateID: string; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  end;

implementation

{ TShelfItem }

constructor TShelfItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FCanHaveChildren := False;
  FDisplayName := TA('Photo shelf', 'PhotoShelf');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TShelfItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TShelfItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TShelfItem.Create;
end;

function TShelfItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TShelfItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'SHELF', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TShelfProvider }

function TShelfProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if StartsText(cShelfPath, AnsiLowerCase(Path)) then
    Result := TShelfItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TShelfProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TShelfItem;
  Result := Result or Supports(Item.Path);
end;

function TShelfProvider.GetTranslateID: string;
begin
  Result := 'PhotoShelf';
end;

function TShelfProvider.InternalFillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize, PacketSize: Integer;
  CallBack: TLoadListCallBack): Boolean;
var
  Cancel: Boolean;
  SI: TShelfItem;
begin
  inherited;
  Result := True;
  Cancel := False;

  if Options and PATH_LOAD_ONLY_FILE_SYSTEM > 0 then
    Exit;

  if Item is THomeItem then
  begin
    if PhotoShelf.Count > 0 then
    begin
      SI := TShelfItem.CreateFromPath(cShelfPath, Options, ImageSize);
      List.Add(SI);
    end;
  end;

  if Item is TShelfItem then
  begin
    //do nothing, all logic is inside ExplorerThread unit
  end;

  if Assigned(CallBack) then
    CallBack(Sender, Item, List, Cancel);
end;

function TShelfProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cShelfPath, AnsiLowerCase(Path));
  Result := Result or (Pos(cImagesSearchPath, AnsiLowerCase(Path)) > 0);
  Result := Result or (Pos(cFilesSearchPath, AnsiLowerCase(Path)) > 0);
end;

end.
