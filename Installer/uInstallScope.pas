unit uInstallScope;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Classes, uMemory;

type
  //OBJECTS
  TInstallObject = class(TObject)

  end;

  TDiskObject = class(TInstallObject)
  public
    Name : string;
    FinalDestination : string;
    constructor Create(AName, AFinalDestination : string);
  end;

  TFileObject = class(TDiskObject)

  end;

  TDirectoryObject = class(TDiskObject)

  end;

  //COLLESTIONS
  TInstallScope = class

  end;

  TScopeFiles = class(TInstallScope)
  private
    FFiles : TList;
    function GetCount: Integer;
    function GetFileByIndex(Index: Integer): TDiskObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(DiskObject : TDiskObject);
    property Count : Integer read GetCount;
    property Files[Index : Integer] : TDiskObject read GetFileByIndex; default;
  end;

  //COMPLETE INSTALLLATION
  TInstall = class(TObject)
  private
    FFiles : TScopeFiles;
  public
    constructor Create;
    destructor Destroy; override;
    property Files : TScopeFiles read FFiles;
  end;

  TPhotoDBInstall_V23 = class(TInstall)
  public
    constructor Create;
  end;

  var
    CurrentInstall : TInstall = nil;

implementation

{ TDiskObject }

constructor TDiskObject.Create(AName, AFinalDestination: string);
begin
  Name := AName;
  FinalDestination := AFinalDestination;
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
end;

destructor TInstall.Destroy;
begin
  F(FFiles);
  inherited;
end;

{ TPhotoDBInstall_V23 }

constructor TPhotoDBInstall_V23.Create;
begin
  inherited;

  Files.Add(TFileObject.Create('PhotoDB.exe', '%PROGRAM%'));
  Files.Add(TFileObject.Create('Kernel.dll', '%PROGRAM%'));
  Files.Add(TFileObject.Create('Icons.dll', '%PROGRAM%'));
  Files.Add(TFileObject.Create('FreeImage.dll', '%PROGRAM%'));

  {$IFDEF DBDEBUG}
  Files.Add(TFileObject.Create('FastMM_FullDebugMode.dll', '%PROGRAM%'));
  {$ENDIF}

  Files.Add(TDirectoryObject.Create('Languages', '%PROGRAM%'));
  Files.Add(TDirectoryObject.Create('Actions', '%PROGRAM%'));
  Files.Add(TDirectoryObject.Create('Scripts', '%PROGRAM%'));
  Files.Add(TDirectoryObject.Create('Images', '%PROGRAM%'));
end;

initialization

  CurrentInstall := TPhotoDBInstall_V23.Create;

finalization

  F(CurrentInstall);

end.
