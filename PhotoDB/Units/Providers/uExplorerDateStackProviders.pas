unit uExplorerDateStackProviders;

interface

uses
  uConstants,
  uMemory,
  uTranslate,
  uExplorerPathProvider,
  uExplorerMyComputerProvider,
  uPathProviders;

type
  TDateStackItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TExplorerDateStackProvider = class(TExplorerPathProvider)
  public
    function GetTranslateID: string; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  end;

implementation

{ TExplorerDateStackProvider }

function TExplorerDateStackProvider.CreateFromPath(Path: string): TPathItem;
begin

end;

function TExplorerDateStackProvider.GetTranslateID: string;
begin
  Result := 'ExplorerDateProvider';
end;

function TExplorerDateStackProvider.InternalFillChildList(Sender: TObject;
  Item: TPathItem; List: TPathItemCollection; Options, ImageSize,
  PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
begin

end;

function TExplorerDateStackProvider.Supports(Item: TPathItem): Boolean;
begin

end;

function TExplorerDateStackProvider.Supports(Path: string): Boolean;
begin

end;

{ TDateStackItem }

constructor TDateStackItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;

end;

function TDateStackItem.GetIsDirectory: Boolean;
begin

end;

function TDateStackItem.InternalCreateNewInstance: TPathItem;
begin

end;

function TDateStackItem.InternalGetParent: TPathItem;
begin

end;

function TDateStackItem.LoadImage(Options, ImageSize: Integer): Boolean;
begin
  FDisplayName := TA('Photo shelf', 'PhotoShelf');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

initialization
  PathProviderManager.RegisterProvider(TExplorerDateStackProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TExplorerDateStackProvider);

end.
