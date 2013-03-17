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
  TDBPopupMenuInfoRecord = class;

  TEventField = (EventID_Param_Name, EventID_Param_ID, EventID_Param_Rotate,
    EventID_Param_Rating, EventID_Param_Private, EventID_Param_Comment,
    EventID_Param_KeyWords, EventID_Param_Attr,
    EventID_Param_Image, EventID_Param_Refresh, EventID_Param_Critical,
    EventID_Param_Delete, EventID_Param_Date,
    EventID_Param_Time, EventID_Param_IsDate , EventID_Param_IsTime,
    EventID_Param_Groups, EventID_Param_Crypt, EventID_Param_Include,
    EventID_Param_GroupsChanged,
    EventID_Param_Add_Crypt_WithoutPass, SetNewIDFileData, EventID_CancelAddingImage,
    EventID_Param_Links,  EventID_Param_DB_Changed, EventID_Param_Refresh_Window,
    EventID_FileProcessed, EventID_Repaint_ImageList, EventID_No_EXIF,
    EventID_PersonAdded, EventID_PersonChanged, EventID_PersonRemoved,
    EventID_GroupAdded, EventID_GroupChanged, EventID_GroupRemoved,
    EventID_ShelfChanged, EventID_ShelfItemRemoved, EventID_ShelfItemAdded);

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
    procedure ReadFromInfo(Info: TDBPopupMenuInfoRecord);
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

  TDBPopupMenuInfoRecord = class(TPathItem)
  private
    FOriginalFileName: string;
    FFileNameCRC32: Cardinal;
    FGeoLocation: TGeoLocation;
    function GetInnerImage: Boolean;
    function GetExistedFileName: string;
    function GetFileNameCRC: Cardinal;
    function GetHasImage: Boolean;
  protected
    function InitNewInstance: TDBPopupMenuInfoRecord; virtual;
  public
    Name: string;
    FileName: string;
    Comment: string;
    FileSize: Int64;
    Rotation: Integer;
    Rating: Integer;
    ID: Integer;
    IsCurrent: Boolean;
    Selected: Boolean;
    Access: Integer;
    Date: TDateTime;
    Time: TTime;
    IsDate: Boolean;
    IsTime: Boolean;
    Groups: string;
    KeyWords: string;
    Encrypted: Boolean;
    Attr: Integer;
    InfoLoaded: Boolean;
    Include: Boolean;
    Width, Height: Integer;
    Links: string;
    Exists: Integer; // for drawing in lists
    LongImageID: string;
    Data: TClonableObject;
    Image: TJpegImage;
    Tag: Integer;
    IsImageEncrypted: Boolean;
    HasExifHeader: Boolean;
    constructor Create; override;
    constructor CreateFromDS(DS: TDataSet);
    constructor CreateFromFile(FileName: string);
    procedure ReadExists;
    destructor Destroy; override;
    procedure ReadFromDS(DS: TDataSet);
    procedure WriteToDS(DS: TDataSet);
    function Copy: TDBPopupMenuInfoRecord; reintroduce; virtual;
    function FileExists: Boolean;
    procedure LoadGeoInfo(Latitude, Longitude: Double);
    procedure Assign(Item: TDBPopupMenuInfoRecord; MoveImage: Boolean = False); reintroduce;
    property InnerImage: Boolean read GetInnerImage;
    property ExistedFileName: string read GetExistedFileName;
    //lower case
    property FileNameCRC: Cardinal read GetFileNameCRC;
    property GeoLocation: TGeoLocation read FGeoLocation;
    property HasImage: Boolean read GetHasImage;
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
  public
    Title: string;
    Path: string;
    Icon: string;
    Description: string;
    Order: Integer;
    constructor Create; overload;
    constructor Create(Title, Path, Icon, Description: string; Order: Integer = 0); overload;
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
  end;


type
  THintCheckFunction = function(Info: TDBPopupMenuInfoRecord): Boolean of object;
  TRemoteCloseFormProc = procedure(Form: TForm; ID: string) of object;
  TFileFoundedEvent = procedure(Owner: TObject; FileName: string; Size: Int64) of object;

type
  TCallBackBigSizeProc = procedure(Sender: TObject; SizeX, SizeY: Integer) of object;

  TWatermarkOptions = record
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

  function GetSearchRecordFromItemData(ListItem : TEasyItem) : TDBPopupMenuInfoRecord;

implementation

{ TDBPopupMenuInfoRecord }

procedure TDBPopupMenuInfoRecord.Assign(Item: TDBPopupMenuInfoRecord; MoveImage: Boolean = False);
begin
  FPath := Item.Path;
  ID := Item.ID;
  Name := Item.Name;
  FileName := Item.FileName;
  FOriginalFileName := Item.FOriginalFileName;
  Comment := Item.Comment;
  Groups := Item.Groups;
  FileSize := Item.FileSize;
  Rotation := Item.Rotation;
  Rating := Item.Rating;
  Access := Item.Access;
  Date := Item.Date;
  Time := Item.Time;
  IsDate := Item.IsDate;
  IsTime := Item.IsTime;
  Encrypted := Item.Encrypted;
  KeyWords := Item.KeyWords;
  InfoLoaded := Item.InfoLoaded;
  Include := Item.Include;
  Links := Item.Links;
  Selected := Item.Selected;
  Tag := Item.Tag;
  IsImageEncrypted := Item.IsImageEncrypted;
  Width := Item.Width;
  Height := Item.Height;
  Exists := Item.Exists;
  HasExifHeader := Item.HasExifHeader;
  if MoveImage then
  begin
    F(Image);
    Image := Item.Image;
    Item.Image := nil;
  end;
  F(FGeoLocation);
  if Item.GeoLocation <> nil then
    LoadGeoInfo(Item.GeoLocation.Latitude, Item.GeoLocation.Longitude);
end;

function TDBPopupMenuInfoRecord.Copy: TDBPopupMenuInfoRecord;
begin
  Result := InitNewInstance;
  Result.Assign(Self, False);
  if Data <> nil then
    Result.Data := Data.Clone
  else
    Result.Data := nil;
end;

constructor TDBPopupMenuInfoRecord.Create;
begin
  inherited;
  FFileNameCRC32 := 0;
  IsImageEncrypted := False;
  Tag := 0;
  ID := 0;
  FOriginalFileName := '';
  FileName := '';
  Comment := '';
  Groups := '';
  FileSize := 0;
  Rotation := 0;
  Rating := 0;
  Access := 0;
  Date := 0;
  Time := 0;
  IsDate := False;
  IsTime := False;
  Encrypted := False;
  KeyWords := '';
  InfoLoaded := False;
  Include := False;
  Links := '';
  Selected := False;
  Data := nil;
  Image := nil;
  FGeoLocation := nil;
  HasExifHeader := False;
end;

constructor TDBPopupMenuInfoRecord.CreateFromDS(DS: TDataSet);
begin
  InfoLoaded := True;
  Selected := True;
  ReadFromDS(DS);
  Data := nil;
  Image := nil;
  FGeoLocation := nil;
end;

constructor TDBPopupMenuInfoRecord.CreateFromFile(FileName: string);
begin
  Create;
  Self.FOriginalFileName := FileName;
  Self.FileName := FileName;
  Self.FPath := FileName;
  Self.Name := ExtractFileName(FileName);
end;

destructor TDBPopupMenuInfoRecord.Destroy;
begin
  F(Data);
  F(Image);
  F(FGeoLocation);
  inherited;
end;

function TDBPopupMenuInfoRecord.FileExists: Boolean;
begin
  Result := InnerImage or FileExistsSafe(FileName);
end;

function TDBPopupMenuInfoRecord.GetExistedFileName: string;
begin
  if FolderView then
    Result := FileName
  else
    Result := FOriginalFileName;
end;

function TDBPopupMenuInfoRecord.GetFileNameCRC: Cardinal;
begin
  if FFileNameCRC32 = 0 then
    FFileNameCRC32 := StringCRC(AnsiLowerCase(FileName));
  Result := FFileNameCRC32;
end;

function TDBPopupMenuInfoRecord.GetHasImage: Boolean;
begin
  Result := (Image <> nil) and not Image.Empty;
end;

function TDBPopupMenuInfoRecord.GetInnerImage: Boolean;
begin
  Result := FileName = '?.JPEG';
end;

function TDBPopupMenuInfoRecord.InitNewInstance: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord.Create;
end;

procedure TDBPopupMenuInfoRecord.LoadGeoInfo(Latitude, Longitude: Double);
begin
  F(FGeoLocation);
  FGeoLocation := TGeoLocation.Create;
  FGeoLocation.Latitude := Latitude;
  FGeoLocation.Longitude := Longitude;
end;

procedure TDBPopupMenuInfoRecord.ReadExists;
begin
  if FileExistsSafe(FileName) then
    Exists := 1
  else
    Exists := -1;
end;

procedure TDBPopupMenuInfoRecord.ReadFromDS(DS: TDataSet);
var
  ThumbField: TField;
  DA: TDBAdapter;
begin
  F(Image);
  DA := TDBAdapter.Create(DS);
  try
    ID := DA.ID;
    Name := DA.Name;
    FOriginalFileName := DA.FileName;
    if FolderView then
      FileName := ExtractFilePath(ParamStr(0)) + FOriginalFileName
    else
      FileName := ProcessPath(FOriginalFileName, False);
    KeyWords := DA.KeyWords;
    FileSize := DA.FileSize;
    Rotation := DA.Rotation;
    Rating := DA.Rating;
    Access := DA.Access;
    Attr := DA.Attributes;
    Comment := DA.Comment;
    Date := DA.Date;
    Time := DA.Time;
    IsDate := DA.IsDate;
    IsTime := DA.IsTime;
    Groups := DA.Groups;
    LongImageID := DA.LongImageID;
    Width := DA.Width;
    Height := DA.Height;

    ThumbField := DA.Thumb;
    Encrypted := (ThumbField <> nil) and ValidCryptBlobStreamJPG(ThumbField);
    Include := DA.Include;
    Links := DA.Links;

  finally
    F(DA);
  end;
  InfoLoaded := True;
end;

procedure TDBPopupMenuInfoRecord.WriteToDS(DS: TDataSet);
var
  DA: TDBAdapter;
begin
  DA := TDBAdapter.Create(DS);
  try
    DA.Name := Name;
    DA.FileName := FOriginalFileName;
    DA.KeyWords := KeyWords;
    DA.FileSize := FileSize;
    DA.Rotation := Rotation;
    DA.Rating := Rating;
    DA.Access := Access;
    DA.Attributes := Attr;
    DA.Comment := Comment;
    DA.Date := DateOf(Date);
    DA.Time := TimeOf(Time);
    DA.IsDate := IsDate;
    DA.IsTime := IsTime;
    DA.Groups := Groups;
    DA.LongImageID := LongImageID;
    DA.Width := Width;
    DA.Height := Height;
    DA.Include := Include;
    DA.Links := Links;
  finally
    F(DA);
  end;
end;

{ TExplorerFileInfo }

function GetSearchRecordFromItemData(ListItem: TEasyItem) : TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord(TLVDataObject(ListItem.Data).Data);
end;

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
end;

{ TEventValues }

procedure TEventValues.ReadFromInfo(Info: TDBPopupMenuInfoRecord);
begin
  Self.FileName := AnsiLowerCase(Info.FileName);
  Self.ID := LastInseredID;
  Self.Rotation := Info.Rotation;
  Self.Rating := Info.Rating;
  Self.Comment := Info.Comment;
  Self.KeyWords := Info.KeyWords;
  Self.Access := Info.Access;
  Self.Attr := Info.Attr;
  Self.Date := Info.Date;
  Self.IsDate := Info.IsDate;
  Self.IsTime := Info.IsTime;
  Self.Time := TimeOf(Info.Time);
  Self.Groups := Info.Groups;
  Self.IsEncrypted := Info.Encrypted;
  Self.Include := Info.Include;
end;

end.
