unit Dmitry.PathProviders.MyComputer;

interface

uses
  System.StrUtils,
  System.SysUtils,
  Winapi.Windows,
  Winapi.ShellApi,
  Vcl.Graphics,
  Dmitry.Memory,
  Dmitry.Utils.Files,
  Dmitry.Utils.System,
  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders;

const
  cNetworkPath = 'Network';

type
  THomeItem = class(TPathItem)
  protected
    function GetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    constructor Create; override;
  end;

  TDriveItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TMyComputerProvider = class(TPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection;
      Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  public
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

function ExtractPathExPath(Path: string): string;
function IsPathEx(Path: string): Boolean;

implementation

function IsPathEx(Path: string): Boolean;
var
  P1, P2: Integer;
begin
  P1 := Pos('::', Path);
  P2 := Pos('://', Path);
  Result := (P1 > 0) and (P2 > 0) and (P2 > P1);
end;

function ExtractPathExPath(Path: string): string;
begin
  if IsPathEx(Path) then
    Result := Copy(Path, 1, Pos('::', Path) - 1)
  else
    Result := Path;
end;

{ TMyComputerProvider }

function TMyComputerProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if Path = '' then
    Result := THomeItem.Create;
end;

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
  Result := Item is THomeItem;
  Result := Result or Supports(Item.Path);
end;

function TMyComputerProvider.Supports(Path: string): Boolean;
begin
  Result := Path = '';
end;

function TMyComputerProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_CHILD_LIST;
end;

{ TDriveItem }

constructor TDriveItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
var
  DS: TDriveState;
begin
  inherited;
  FImage := nil;
  FParent := nil;
  FDisplayName := 'unknown drive';
  if Length(APath) > 0 then
  begin
    DS := DriveState(AnsiString(APath)[1]);

    if Options and PATH_LOAD_FAST > 0 then
      FDisplayName := UpCase(APath[1]) + ':\'
    else
    begin
      if (DS = DS_DISK_WITH_FILES) or (DS = DS_EMPTY_DISK) then
        FDisplayName := GetCDVolumeLabelEx(UpCase(APath[1])) + ' (' + APath[1] + ':)'
      else
        FDisplayName := MrsGetFileType(UpCase(APath[1]) + ':\') + ' (' + APath[1] + ':)';
    end;

    if Options and PATH_LOAD_NO_IMAGE = 0 then
      LoadImage(Options, ImageSize);
  end;

  if Options and PATH_LOAD_CHECK_CHILDREN > 0 then
    FCanHaveChildren := IsDirectoryHasDirectories(Path);
end;

function TDriveItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: HIcon;
begin
  Result := False;
  F(FImage);
  Icon := ExtractShellIcon(FPath, ImageSize);
  if Icon <> 0 then
  begin
    FImage := TPathImage.Create(Icon);
    Result := True;
  end;
end;

function TDriveItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TDriveItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDriveItem.Create;
end;

function TDriveItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

{ THomeItem }

constructor THomeItem.Create;
begin
  inherited;
  FDisplayName := 'My Computer';
  UpdateText;
end;

constructor THomeItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := 'My Computer';
  UpdateText;
  if (ImageSize > 0) and (Options and PATH_LOAD_NO_IMAGE = 0) then
    LoadImage(Options, ImageSize);
end;

function THomeItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function THomeItem.GetParent: TPathItem;
begin
  Result := nil;
end;

function THomeItem.InternalCreateNewInstance: TPathItem;
begin
  Result := THomeItem.Create;
end;

function THomeItem.LoadImage(Options, ImageSize: Integer): Boolean;
begin
  F(FImage);
  UpdateImage(ImageSize);
  Result := True;
end;

initialization
  PathProviderManager.RegisterProvider(TMyComputerProvider.Create);

end.
