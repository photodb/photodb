unit uExplorerMyComputerProvider;

interface

uses
  uPathProviders, Windows, uFileUtils, uSysUtils, ShellApi, uMemory,
  uShellIcons;

type
  THomeItem = class(TPathItem)
  protected
    function GetParent: TPathItem; override;
  end;

  TDriveItem = class(TPathItem)
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
  TMyComputerProvider = class(TPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection;
      Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  public
    function Supports(Item: TPathItem): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
  end;

implementation

{ TMyComputerProvider }

function TMyComputerProvider.InternalFillChildList(Sender: TObject;
  Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
const
  DRIVE_REMOVABLE = 2;
  DRIVE_FIXED     = 3;
  DRIVE_REMOTE    = 4;
  DRIVE_CDROM     = 5;
var
  I: Integer;
  DI: TDriveItem;
  Drive: string;
  DriveType : UINT;
  OldMode: Cardinal;
  Cancel: Boolean;
begin
  Cancel := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    for I := Ord('C') to Ord('Z') do
    begin
      DriveType := GetDriveType(PChar(Chr(I) + ':\'));
      if (DriveType = DRIVE_REMOVABLE) or (DriveType = DRIVE_FIXED) or
        (DriveType = DRIVE_REMOTE) or (DriveType = DRIVE_CDROM) or (DriveType = DRIVE_RAMDISK) then
      begin
        Drive := Chr(I) + ':\';
        DI := TDriveItem.CreateFromPath(Drive, Options, ImageSize);
        List.Add(DI);

        if List.Count mod PacketSize = 0 then
        begin
          if Assigned(CallBack) then
            CallBack(Sender, Item, List, Cancel);
          if Cancel then
            Break;
        end;
      end;
    end;

    if Assigned(CallBack) then
      CallBack(Sender, Item, List, Cancel);
  finally
    SetErrorMode(OldMode);
  end;
  Result := True;
end;

function TMyComputerProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item.Path = '';
end;

function TMyComputerProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_CHILD_LIST;
end;

{ TDriveItem }

constructor TDriveItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
var
  DS: TDriveState;
  Icon: HIcon;
begin
  inherited;
  FImage := nil;
  FParent := nil;
  FDisplayName := 'unknown drive';
  if Length(APath) > 0 then
  begin
    DS := DriveState(AnsiString(APath)[1]);
    if (DS = DS_DISK_WITH_FILES) or (DS = DS_EMPTY_DISK) then
      FDisplayName := GetCDVolumeLabelEx(APath[1]) + ' (' + APath[1] + ':)'
    else
      FDisplayName := MrsGetFileType(APath[1] + ':\') + ' (' + APath[1] + ':)';

    if Options and PATH_DONT_LOAD_IMAGE = 0 then
    begin
      Icon := ExtractShellIcon(APath, ImageSize);
      FImage := TPathImage.Create(Icon);
    end;
  end;
end;

destructor TDriveItem.Destroy;
begin
  F(FParent);
  F(FImage);
  inherited;
end;

function TDriveItem.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TDriveItem.GetParent: TPathItem;
begin
  if FParent = nil then
    FParent := THomeItem.Create;

  Result := FParent;
end;

function TDriveItem.GetPathImage: TPathImage;
begin
  Result := FImage;
end;

{ THomeItem }

function THomeItem.GetParent: TPathItem;
begin
  Result := Self;
end;

initialization
  PathProviderManager.RegisterProvider(TMyComputerProvider.Create);

end.
