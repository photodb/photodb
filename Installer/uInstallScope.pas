unit uInstallScope;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Generics.Collections,
  System.Classes,
  uMemory,
{$IFNDEF EXTERNAL}
  uTranslate,
{$ENDIF}
  uConstants;

type
  //OBJECTS
  TInstallObject = class(TObject)

  end;

  TShortCut = class(TObject)
  public
    Name: string;
    Location: string;
  end;

  TShortCuts = class(TObject)
  private
    FShortCuts: TList;
    function GetCount: Integer;
    function GetItemByIndex(Index: Integer): TShortCut;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Name, Location: string); overload;
    procedure Add(Location: string); overload;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TShortCut read GetItemByIndex; default;
  end;

  TActionScope = (asInstall, asUninstall, asInstallFont, asUninstallFont);

  TFileAction = class(TObject)
  public
    CommandLine: string;
    Scope: TActionScope;
  end;

  TFileActions = class(TObject)
  private
    FActions: TList<TFileAction>;
    function GetCount: Integer;
    function GetItemByIndex(Index: Integer): TFileAction;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(CommandLine: string; Scope: TActionScope); overload;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TFileAction read GetItemByIndex; default;
  end;

  TDiskObject = class(TInstallObject)
  private
    FShortCuts: TShortCuts;
    FActions: TFileActions;
  public
    Name: string;
    FinalDestination: string;
    Description: string;
    constructor Create(AName, AFinalDestination, ADescription: string);
    destructor Destroy; override;
    property ShortCuts: TShortCuts read FShortCuts;
    property Actions: TFileActions read FActions;
  end;

  TFileObject = class(TDiskObject)

  end;

  TDirectoryObject = class(TDiskObject)
  private
    FIsRecursive: Boolean;
  public
    property IsRecursive: Boolean read FIsRecursive write FIsRecursive;
  end;

  //COLLESTIONS
  TInstallScope = class

  end;

  TScopeFiles = class(TInstallScope)
  private
    FFiles: TList;
    function GetCount: Integer;
    function GetFileByIndex(Index: Integer): TDiskObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(DiskObject: TDiskObject);
    property Count: Integer read GetCount;
    property Files[Index: Integer]: TDiskObject read GetFileByIndex; default;
  end;

  TUninstallOptions = class(TObject)
  private
    FDeleteUserSettings: Boolean;
    FDeleteAllCollections: Boolean;
  public
    constructor Create;
    property DeleteUserSettings: Boolean read FDeleteUserSettings write FDeleteUserSettings;
    property DeleteAllCollections: Boolean read FDeleteAllCollections write FDeleteAllCollections;
  end;

  // COMPLETE INSTALLLATION
  TInstall = class(TObject)
  private
    FFiles: TScopeFiles;
    FDestinationPath: string;
    FIsUninstall: Boolean;
    FUninstallOptions: TUninstallOptions;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property DestinationPath: string read FDestinationPath write FDestinationPath;
    property Files: TScopeFiles read FFiles;
    property IsUninstall: Boolean read FIsUninstall write FIsUninstall;
    property UninstallOptions: TUninstallOptions read FUninstallOptions;
  end;

  TPhotoDBInstall_V23 = class(TInstall)
  public
    constructor Create; override;
  end;

function CurrentInstall: TInstall;

implementation

var
  FCurrentInstall: TInstall = nil;

{$IFDEF EXTERNAL}

function TA(StringToTranslate, Scope: string): string;
begin
  Result := StringToTranslate;
end;
{$ENDIF}

function CurrentInstall: TInstall;
begin
  if FCurrentInstall = nil then
    FCurrentInstall := TPhotoDBInstall_V23.Create;

  Result := FCurrentInstall;
end;

{ TShortCuts }

procedure TShortCuts.Add(Name, Location: string);
var
  ShortCut: TShortCut;
begin
  ShortCut := TShortCut.Create;
  ShortCut.Name := Name;
  ShortCut.Location := Location;
  FShortCuts.Add(ShortCut);
end;

procedure TShortCuts.Add(Location: string);
begin
  Add('', Location);
end;

constructor TShortCuts.Create;
begin
  FShortCuts := TList.Create;
end;

destructor TShortCuts.Destroy;
begin
  FreeList(FShortCuts);
  inherited;
end;

function TShortCuts.GetCount: Integer;
begin
  Result := FShortCuts.Count;
end;

function TShortCuts.GetItemByIndex(Index: Integer): TShortCut;
begin
  Result := FShortCuts[Index];
end;

{ TDiskObject }

constructor TDiskObject.Create(AName, AFinalDestination, ADescription: string);
begin
  Name := AName;
  FinalDestination := AFinalDestination;
  Description := ADescription;
  FShortCuts := TShortCuts.Create;
  FActions := TFileActions.Create;
end;

destructor TDiskObject.Destroy;
begin
  F(FShortCuts);
  inherited;
end;

{ TScopeFiles }

procedure TScopeFiles.Add(DiskObject: TDiskObject);
begin
  FFiles.Add(DiskObject);
end;

constructor TScopeFiles.Create;
begin
  FFiles := TList.Create;
end;

destructor TScopeFiles.Destroy;
begin
  FreeList(FFiles);
  inherited;
end;

function TScopeFiles.GetCount: Integer;
begin
  Result := FFiles.Count;
end;

function TScopeFiles.GetFileByIndex(Index: Integer): TDiskObject;
begin
  Result := FFiles[Index];
end;

{ TInstall }

constructor TInstall.Create;
begin
  FFiles := TScopeFiles.Create;
  FUninstallOptions := TUninstallOptions.Create;
  FIsUninstall := False;
end;

destructor TInstall.Destroy;
begin
  F(FFiles);
  F(FUninstallOptions);
  inherited;
end;

{ TPhotoDBInstall_V23 }

constructor TPhotoDBInstall_V23.Create;
var
  PhotoDBFile: TDiskObject;
  PhotoDBBridge: TDiskObject;
  ListFont: TDiskObject;
  {$IFDEF MEDIA_PLAYER}
  DirectoryObj: TDirectoryObject;
  {$ENDIF}
begin
  inherited;

  Files.Add(TDirectoryObject.Create('Languages',   '%PROGRAM%', ''));
  Files.Add(TDirectoryObject.Create('Licenses',    '%PROGRAM%', ''));
  Files.Add(TDirectoryObject.Create('Cascades',    '%PROGRAM%', ''));

  PhotoDBFile := TFileObject.Create(PhotoDBFileName, '%PROGRAM%', TA('Photo Database {V} helps you to find, protect and organize your photos.', 'System'));
  PhotoDBFile.FShortCuts.Add('%DESKTOP%\Photo Database {V}.lnk');
  PhotoDBFile.FShortCuts.Add('%STARTMENU%\' + StartMenuProgramsPath + '\' + ProgramShortCutFile);
  PhotoDBFile.FShortCuts.Add('%STARTMENU%\' + StartMenuProgramsPath + '\' + TA('Home page', 'System') + '.lnk', 'http://photodb.illusdolphin.net/{LNG}');
  Files.Add(PhotoDBFile);

  PhotoDBBridge := TFileObject.Create('PhotoDBBridge.exe',         '%PROGRAM%', '');
  PhotoDBBridge.Actions.Add('/regserver', asInstall);
  PhotoDBBridge.Actions.Add('/unregserver', asUnInstall);
  Files.Add(PhotoDBBridge);
  Files.Add(TFileObject.Create('Kernel.dll',                      '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('FreeImage.dll',                   '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('opencv_core246.dll',              '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('opencv_highgui246.dll',           '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('opencv_imgproc246.dll',           '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('opencv_objdetect246.dll',         '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('UnInstall.exe',                   '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('libeay32.dll',                    '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('ssleay32.dll',                    '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('lcms2.dll',                       '%PROGRAM%', ''));

  ListFont := TFileObject.Create('MyriadPro-Regular.otf',         '%PROGRAM%', '');
  ListFont.Actions.Add('Myriad Pro Regular (TrueType)', asInstallFont);
  ListFont.Actions.Add('Myriad Pro Regular (TrueType)', asUninstallFont);
  Files.Add(ListFont);

  Files.Add(TFileObject.Create('TransparentEncryption.dll',       '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('TransparentEncryption64.dll',     '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('PlayEncryptedMedia.exe',          '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('PlayEncryptedMedia64.exe',        '%PROGRAM%', ''));
  {$IFDEF DBDEBUG}
  Files.Add(TFileObject.Create('FastMM_FullDebugMode.dll', '%PROGRAM%', ''));
  Files.Add(TFileObject.Create('PhotoDB.map',              '%PROGRAM%', ''));
  {$ENDIF}

  Files.Add(TDirectoryObject.Create('Actions',     '%PROGRAM%', ''));
  Files.Add(TDirectoryObject.Create('Scripts',     '%PROGRAM%', ''));
  Files.Add(TDirectoryObject.Create('Images',      '%PROGRAM%', ''));
  Files.Add(TDirectoryObject.Create('PlugInsEx',   '%PROGRAM%', ''));
  Files.Add(TDirectoryObject.Create('Styles',      '%PROGRAM%', ''));

  {$IFDEF MEDIA_PLAYER}
  DirectoryObj := TDirectoryObject.Create('MediaPlayer',    '%PROGRAM%', '');
  DirectoryObj.IsRecursive := True;
  Files.Add(DirectoryObj);
  //russian language
  Files.Add(TFileObject.Create('MediaPlayer\Lang\mpcresources.ru.dll', '%PROGRAM%', ''));
  {$ENDIF}
end;

{ TFileActions }

procedure TFileActions.Add(CommandLine: string; Scope: TActionScope);
var
  FA: TFileAction;
begin
  FA := TFileAction.Create;
  FA.CommandLine := CommandLine;
  FA.Scope := Scope;
  FActions.Add(FA);
end;

constructor TFileActions.Create;
begin
  FActions := TList<TFileAction>.Create;
end;

destructor TFileActions.Destroy;
begin
  FreeList(FActions);
  inherited;
end;

function TFileActions.GetCount: Integer;
begin
  Result := FActions.Count;
end;

function TFileActions.GetItemByIndex(Index: Integer): TFileAction;
begin
  Result := FActions[Index];
end;

{ TUninstallOptions }

constructor TUninstallOptions.Create;
begin
  FDeleteUserSettings := True;
  FDeleteAllCollections := False;
end;

initialization

finalization

  F(FCurrentInstall);

end.
