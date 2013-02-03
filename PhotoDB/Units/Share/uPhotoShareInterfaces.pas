unit uPhotoShareInterfaces;

interface

uses
  uMemory,
  Generics.Collections,
  Classes,
  SyncObjs,
  SysUtils,
  Graphics,
  uInternetUtils;

const
  PHOTO_PROVIDER_FEATURE_ALBUMS        = '{06213CD9-35C9-4FA8-B21D-4D7628347DEC}';
  PHOTO_PROVIDER_FEATURE_PRIVATE_ITEMS = '{0D4C568C-C3E7-45DD-9E61-47D529480D0E}';
  PHOTO_PROVIDER_FEATURE_DELETE        = '{7258EB96-A9FE-4E63-8035-2F94680EC320}';

  PHOTO_PROVIDER_ALBUM_PUBLIC = 1;
  PHOTO_PROVIDER_ALBUM_PROTECTED = 2;
  PHOTO_PROVIDER_ALBUM_PRIVATE = 3;

type
  IPhotoServiceUserInfo = interface
    function GetUserAvatar(Bitmap: TBitmap): Boolean;
    function GetUserDisplayName: string;
    function GetHomeUrl: string;
    function GetAvailableSpace: Int64;
    property UserDisplayName: string read GetUserDisplayName;
    property HomeUrl: string read GetHomeUrl;
    property AvailableSpace: Int64 read GetAvailableSpace;
  end;

  IPhotoServiceItem = interface
    function GetName: string;
    function GetDescription: string;
    function GetDate: TDateTime;
    function GetUrl: string;
    function GetSize: Int64;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function ExtractPreview(Image: TBitmap): Boolean;
    function Delete: Boolean;
    property Name: string read GetName;
    property Description: string read GetDescription;
    property Date: TDateTime read GetDate;
    property Url: string read GetUrl;
    property Size: Int64 read GetSize;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
  end;

  IPhotoShareProvider = interface;

  IUploadProgress = interface
    procedure OnProgress(Sender: IPhotoShareProvider; Max, Position: Int64);
  end;

  IPhotoServiceAlbum = interface
    function UploadItem(FileName, Name, Description: string; Date: TDateTime; ContentType: string;
      Stream: TStream; Progress: IUploadProgress; out Item: IPhotoServiceItem): Boolean;
    function GetAlbumID: string;
    function GetName: string;
    function GetDescription: string;
    function GetDate: TDateTime;
    function GetUrl: string;
    function GetAccess: Integer;
    function GetPreview(Bitmap: TBitmap; HttpContainer: THTTPRequestContainer = nil): Boolean;
    property AlbumID: string read GetAlbumID;
    property Name: string read GetName;
    property Description: string read GetDescription;
    property Date: TDateTime read GetDate;
    property Url: string read GetUrl;
    property Access: Integer read GetAccess;
  end;

  IPhotoShareProvider = interface
    function InitializeService: Boolean;
    function GetProviderName: string;
    function GetUserInfo(out Info: IPhotoServiceUserInfo): Boolean;
    function GetAlbumList(Albums: TList<IPhotoServiceAlbum>): Boolean;
    function CreateAlbum(Name, Description: string; Date: TDateTime; Access: Integer; out Album: IPhotoServiceAlbum): Boolean;
    function UploadPhoto(AlbumID, FileName, Name, Description: string; Date: TDateTime; ContentType: string;
      Stream: TStream; Progress: IUploadProgress; out Photo: IPhotoServiceItem): Boolean;
    function IsFeatureSupported(Feature: string): Boolean;
    function GetProviderImage(Bitmap: TBitmap): Boolean;
    function ChangeUser: Boolean;
  end;

  TPhotoShareManager = class(TObject)
  private
    FProviders: TList<IPhotoShareProvider>;
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProvider(Provider: IPhotoShareProvider);
    procedure FillProviders(Items: TList<IPhotoShareProvider>);
  end;

function PhotoShareManager: TPhotoShareManager;
function GetFileMIMEType(FileName: string): string;

implementation

var
  FPhotoShareManager: TPhotoShareManager = nil;

function PhotoShareManager: TPhotoShareManager;
begin
  if FPhotoShareManager = nil then
    FPhotoShareManager := TPhotoShareManager.Create;

  Result := FPhotoShareManager;
end;

{ 
----------------------
    * video/3gpp
    * video/avi
    * video/quicktime
    * video/mp4
    * video/mpeg
    * video/mpeg4
    * video/msvideo
    * video/x-ms-asf
    * video/x-ms-wmv
    * video/x-msvideo
}

function GetFileMIMEType(FileName: string): string;
var
  Ext: string;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));

  Result := 'video/' + StringReplace(Ext, '.', '', []);

  if (Ext = '.3gp2') or (Ext = '.3gpp') or (Ext = '.3gp') or (Ext = '.3g2') then
    Result := 'video/3gpp'
  else if (Ext = '.avi') then
    Result := 'video/avi'
  else if (Ext = '.mov') then
    Result := 'video/quicktime'
  else if (Ext = '.mp4') then
    Result := 'video/mp4'
  else if (Ext = '.mpeg') then
    Result := 'video/mpeg'
  else if (Ext = '.mpeg4') then
    Result := 'video/mpeg4'
  else if (Ext = '.asf') then
    Result := 'video/x-ms-asf'
  else if (Ext = '.wmv') then
    Result := 'video/x-ms-wmv';
end;

{ TPhotoShareManager }

constructor TPhotoShareManager.Create;
begin
  FProviders := TList<IPhotoShareProvider>.Create;
  FSync := TCriticalSection.Create;
end;

destructor TPhotoShareManager.Destroy;
begin
  F(FProviders);
  F(FSync);
  inherited;
end;

procedure TPhotoShareManager.FillProviders(Items: TList<IPhotoShareProvider>);
begin
  FSync.Enter;
  try
    Items.AddRange(FProviders);
  finally
    FSync.Leave;
  end;
end;

procedure TPhotoShareManager.RegisterProvider(Provider: IPhotoShareProvider);
begin
  FSync.Enter;
  try
    FProviders.Add(Provider);
  finally
    FSync.Leave;
  end;
end;

initialization

finalization
  F(FPhotoShareManager);

end.
