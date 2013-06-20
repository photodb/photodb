unit UnitDBDeclare;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Imaging.JPEG,
  Data.DB,

  EasyListview,
  GraphicCrypt,

  Dmitry.CRC32,
  Dmitry.Utils.Files,
  Dmitry.PathProviders,

  uMemory,
  uDBBaseTypes,
  uDBGraphicTypes,
  uRuntime,
  uDBAdapter,
  uCDMappingTypes;

const
  BufferSize = 100 * 3 * 4 * 4096;

const
  LINE_INFO_UNDEFINED = 0;
  LINE_INFO_OK        = 1;
  LINE_INFO_ERROR     = 2;
  LINE_INFO_WARNING   = 3;
  LINE_INFO_PLUS      = 4;
  LINE_INFO_PROGRESS  = 5;
  LINE_INFO_DB        = 6;
  LINE_INFO_GREETING  = 7;
  LINE_INFO_INFO      = -1;

type
  PBuffer = ^TBuffer;
  TBuffer = array [1..BufferSize] of Byte;

type
  TPasswordRecord = class
  public
    CRC: Cardinal;
    FileName: string;
    ID: Integer;
  end;

  TWriteLineProcedure = procedure(Sender: TObject; Line: string; aType: Integer) of object;
  TGetFilesWithoutPassProc = function(Sender: TObject): TList of object;
  TAddCryptFileToListProc = procedure(Sender: TObject; Rec: TPasswordRecord) of object;
  TGetAvaliableCryptFileList = function(Sender: TObject): TArInteger of object;

type
  TEventField = (EventID_Param_Name, EventID_Param_ID, EventID_Param_Rotate,
    EventID_Param_Rating, EventID_Param_Access, EventID_Param_Comment,
    EventID_Param_KeyWords, EventID_Param_Attr,
    EventID_Param_Image, EventID_Param_Refresh, EventID_Param_Critical,
    EventID_Param_Delete, EventID_Param_Date,
    EventID_Param_Person,
    EventID_Param_Time, EventID_Param_IsDate , EventID_Param_IsTime,
    EventID_Param_Groups, EventID_Param_Crypt, EventID_Param_Include,
    EventID_Param_GroupsChanged,
    EventID_Param_Add_Crypt_WithoutPass, SetNewIDFileData, EventID_CancelAddingImage,
    EventID_Param_Links,  EventID_Param_DB_Changed, EventID_Param_Refresh_Window,
    EventID_FileProcessed, EventID_Repaint_ImageList, EventID_No_EXIF,
    EventID_PersonAdded, EventID_PersonChanged, EventID_PersonRemoved,
    EventID_GroupAdded, EventID_GroupChanged, EventID_GroupRemoved,
    EventID_ShelfChanged, EventID_ShelfItemRemoved, EventID_ShelfItemAdded,
    EventID_CollectionInfoChanged, EventID_CollectionFoldersChanged);

  TEventFields = set of TEventField;

  TEventValues = record
    ID: Integer;
    FileName: string;
    NewName: string;
    Rotation: Integer;
    Rating: Integer;
    Comment: string;
    KeyWords: string;
    Access: Integer;
    Attr: Integer;
    Date: TDateTime;
    Time: TDateTime;
    IsDate: Boolean;
    IsTime: Boolean;
    Groups: string;
    Links: string;
    JPEGImage: TJpegImage;
    IsEncrypted: Boolean;
    Include: Boolean;
    Data: TObject;
  end;

  TClonableObject = class(TObject)
  public
    function Clone: TClonableObject; virtual; abstract;
  end;

  TSearchDataExtension = class(TClonableObject)
  public
    Bitmap: TBitmap;
    Icon: TIcon;
    CompareResult: TImageCompareResult;
    function Clone: TClonableObject; override;
    constructor Create;
    destructor Destroy; override;
  end;

  TLVDataObject = class(TObject)
  private
  public
    Include: Boolean;
    IsImage: Boolean;
    Data: TObject;
    constructor Create;
    destructor Destroy; override;
  end;

  TCryptImageThreadOptions = record
    Files: TArStrings;
    IDs: TArInteger;
    Selected: TArBoolean;
    Password: string;
    EncryptOptions: Integer;
    Action: Integer;
  end;

  // Структура с информацией об изменении в файловой системе (передается в callback процедуру)
  PInfoCallback = ^TInfoCallback;

  TInfoCallback = record
    FAction: Integer; // тип изменения (константы FILE_ACTION_XXX)
    FOldFileName: string; // имя файла до переименования
    FNewFileName: string; // имя файла после переименования
  end;

  TInfoCallBackDirectoryChangedArray = array of TInfoCallback;

  // callback процедура, вызываемая при изменении в файловой системе
  TWatchFileSystemCallback = procedure(PInfo: TInfoCallBackDirectoryChangedArray) of object;

  TNotifyDirectoryChangeW = procedure(Sender: TObject; SID: string; pInfo: TInfoCallBackDirectoryChangedArray) of object;

  TImportPlace = class(TObject)
  public
    Path: string;
  end;

  TGeoLocation = class
    Latitude: Double;
    Longitude: Double;
    function Copy: TGeoLocation;
    procedure Assign(Item: TGeoLocation);
  end;

  TEncryptImageOptions = record
    Password: string;
    CryptFileName: Boolean;
  end;

  TDataObject = class
  public
    function Clone: TDataObject; virtual; abstract;
    procedure Assign(Source: TDataObject); virtual; abstract;
  end;

  TDatabaseInfo = class(TDataObject)
  private
    FOldTitle: string;
    FTitle: string;
    procedure SetTitle(const Value: string);
  public
    Path: string;
    Icon: string;
    Description: string;
    Order: Integer;
    constructor Create; overload;
    constructor Create(Title, Path, Icon, Description: string; Order: Integer = 0); overload;
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
    property Title: string read FTitle write SetTitle;
    property OldTitle: string read FOldTitle;
  end;

type
  TRemoteCloseFormProc = procedure(Form: TForm; ID: string) of object;
  TFileFoundedEvent = procedure(Owner: TObject; FileName: string; Size: Int64) of object;

type
  TCallBackBigSizeProc = procedure(Sender: TObject; SizeX, SizeY: Integer) of object;

  TWatermarkMode = (WModeImage, WModeText);

  TWatermarkOptions = record
    DrawMode: TWatermarkMode;
    ImageFile: string;
    KeepProportions: Boolean;
    ImageTransparency: Byte;
    StartPoint, EndPoint: TPoint;
    Text: string;
    BlockCountX: Integer;
    BlockCountY: Integer;
    Transparenty: Byte;
    Color: TColor;
    FontName: string;
    IsBold: Boolean;
    IsItalic: Boolean;
  end;

  TPreviewOptions = record
    GeneratePreview: Boolean;
    PreviewWidth: Integer;
    PreviewHeight: Integer;
  end;

  TProcessingParams = record
    Rotation: Integer;
    ResizeToSize: Boolean;
    Width: Integer;
    Height: Integer;
    Resize: Boolean;
    Rotate: Boolean;
    PercentResize: Integer;
    Convert: Boolean;
    GraphicClass: TGraphicClass;
    SaveAspectRation: Boolean;
    Preffix: string;
    WorkDirectory: string;
    AddWatermark: Boolean;
    WatermarkOptions: TWatermarkOptions;
    PreviewOptions: TPreviewOptions;
  end;

implementation

{ TSearchDataExtension }

function TSearchDataExtension.Clone: TClonableObject;
begin
  Result := TSearchDataExtension.Create;
  TSearchDataExtension(Result).CompareResult := CompareResult;
  if Bitmap <> nil then
  begin
    TSearchDataExtension(Result).Bitmap := TBitmap.Create;
    TSearchDataExtension(Result).Bitmap.Assign(Bitmap);
  end;
end;

constructor TSearchDataExtension.Create;
begin
  Bitmap := nil;
  Icon := nil;
end;

destructor TSearchDataExtension.Destroy;
begin
  F(Bitmap);
  F(Icon);
  inherited;
end;

{ TLVDataObject }

constructor TLVDataObject.Create;
begin
  Data := nil;
end;

destructor TLVDataObject.Destroy;
begin
  F(Data);
  inherited;
end;

{ TGeoLocation }

procedure TGeoLocation.Assign(Item: TGeoLocation);
begin
  Self.Latitude := Item.Latitude;
  Self.Longitude := Item.Longitude;
end;

function TGeoLocation.Copy: TGeoLocation;
begin
  Result := TGeoLocation.Create;
  Result.Assign(Self);
end;

{ TDatabaseInfo }

procedure TDatabaseInfo.Assign(Source: TDataObject);
var
  DI: TDatabaseInfo;
begin
  DI := Source as TDatabaseInfo;
  if DI <> nil then
  begin
    Title := DI.Title;
    Path := DI.Path;
    Icon := DI.Icon;
    Description := DI.Description;
    Order := DI.Order;
  end;
end;


function TDatabaseInfo.Clone: TDataObject;
begin
  Result := TDatabaseInfo.Create(Title, Path, Icon, Description, Order);
end;

constructor TDatabaseInfo.Create;
begin
end;

constructor TDatabaseInfo.Create(Title, Path, Icon, Description: string; Order: Integer = 0);
begin
  Self.Title := Title;
  Self.Path := Path;
  Self.Icon := Icon;
  Self.Description := Description;
  Self.Order := Order;
  FOldTitle := Title;
end;

procedure TDatabaseInfo.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

end.
