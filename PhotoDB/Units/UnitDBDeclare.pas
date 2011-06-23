unit UnitDBDeclare;

interface

uses DB, Windows, Classes, Menus, Graphics, JPEG, EasyListview,
     GraphicCrypt, uMemory, uFileUtils, uDBBaseTypes, uDBGraphicTypes,
     uDBForm, DateUtils, SysUtils, uRuntime, uDBAdapter,
     uCDMappingTypes;

const
  BufferSize = 100*3*4*4096;

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

  TWriteLineProcedure = procedure(Sender : TObject; Line : string; aType : integer) of object;
  TGetFilesWithoutPassProc = function(Sender : TObject) : TList of object;
  TAddCryptFileToListProc = procedure(Sender : TObject; Rec : TPasswordRecord)  of object;
  TGetAvaliableCryptFileList = function(Sender : TObject) : TArInteger  of object;

  TRecreatingThInTableOptions = record
    OwnerForm: TDBForm;
    WriteLineProc: TWriteLineProcedure;
    WriteLnLineProc: TWriteLineProcedure;
    OnEndProcedure: TNotifyEvent;
    FileName: string;
    GetFilesWithoutPassProc: TGetFilesWithoutPassProc;
    AddCryptFileToListProc: TAddCryptFileToListProc;
    GetAvaliableCryptFileList: TGetAvaliableCryptFileList;
    OnProgress: TCallBackProgressEvent;
  end;

  TImageDBOptions = class
  public
    Version: Integer;
    DBJpegCompressionQuality: Byte;
    ThSize: Integer;
    ThSizePanelPreview: Integer;
    ThHintSize: Integer;
    Description: string;
    Name: string;
    constructor Create;
    function Copy: TImageDBOptions;
  end;

  TPackingTableThreadOptions = record
    OwnerForm: TDBForm;
    FileName: string;
    OnEnd: TNotifyEvent;
    WriteLineProc: TWriteLineProcedure;
  end;

  TRestoreThreadOptions = record
    OwnerForm: TDBForm;
    FileName: string;
    OnEnd: TNotifyEvent;
    WriteLineProc: TWriteLineProcedure;
  end;

  TShowBadLinksThreadOptions = record
    OwnerForm: TDBForm;
    FileName: string;
    OnEnd: TNotifyEvent;
    WriteLineProc: TWriteLineProcedure;
    WriteLnLineProc: TWriteLineProcedure;
    OnProgress: TCallBackProgressEvent;
  end;

  TBackUpTableThreadOptions = record
    OwnerForm: TDBForm;
    FileName: string;
    OnEnd: TNotifyEvent;
    WriteLineProc: TWriteLineProcedure;
    WriteLnLineProc: TWriteLineProcedure;
  end;

  TOptimizeDublicatesThreadOptions = record
    OwnerForm: TDBForm;
    FileName: string;
    OnEnd: TNotifyEvent;
    WriteLineProc: TWriteLineProcedure;
    WriteLnLineProc: TWriteLineProcedure;
    OnProgress: TCallBackProgressEvent;
  end;

type
  TEventField = (EventID_Param_Name, EventID_Param_ID, EventID_Param_Rotate,
    EventID_Param_Rating, EventID_Param_Private, EventID_Param_Comment,
    EventID_Param_KeyWords, EventID_Param_Access, EventID_Param_Attr,
    EventID_Param_Image, EventID_Param_Owner, EventID_Param_Collection,
    EventID_Param_Refresh, EventID_Param_ThemeCH, EventID_Param_Critical,
    EventID_Param_Add, EventID_Param_Delete, EventID_Param_Date,
    EventID_Param_Time, EventID_Param_IsDate , EventID_Param_IsTime,
    EventID_Param_Groups, EventID_Param_Crypt, EventID_Param_Include,
    EventID_Param_GroupsChanged, EventID_Param_CopyPaste,
    EventID_Param_Add_Crypt_WithoutPass, SetNewIDFileData,
    EventID_Param_Links,  EventID_Param_DB_Changed, EventID_Param_Refresh_Window,
    EventID_FileProcessed, EventID_Repaint_ImageList);

  TEventFields = set of TEventField;

  TEventValues = record
    Name: string;
    NewName: string;
    ID: Integer;
    Rotate: Integer;
    Rating: Integer;
    Comment: string;
    KeyWords: string;
    Access: Integer;
    Attr: Integer;
    Image: TBitmap;
    Date: TDateTime;
    IsDate: Boolean;
    IsTime: Boolean;
    Time: TDateTime;
    Groups: string;
    JPEGImage: TJpegImage;
    Collection: string;
    Owner: string;
    Crypt: Boolean;
    Include: Boolean;
    Links: string;
  end;

  TOnDBKernelEventProcedure = procedure(Sender : TDBForm; ID : integer; params : TEventFields; Value : TEventValues) of object;

  ///////////////CONSTANT SECTION//////////////////////

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
  TPhotoDBFile = class
  public
    Name : string;
    Icon : string;
    FileName : string;
    FileType : integer;
  end;

  TPhotoDBFiles = class
  private
    FList : TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TPhotoDBFile;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Name, Icon, FileName : string; FileType : Integer) : TPhotoDBFile;
    property Items[Index: Integer]: TPhotoDBFile read GetValueByIndex; default;
    property Count : Integer read GetCount;
  end;

  TClonableObject = class(TObject)
  public
    function Copy : TClonableObject; virtual; abstract;
  end;

  TSearchDataExtension = class(TClonableObject)
  public
    Bitmap : TBitmap;
    Icon : TIcon;
    CompareResult : TImageCompareResult;
    function Copy : TClonableObject; override;
    constructor Create;
    destructor Destroy; override;
  end;

  TDataObject = class(TObject)
  private
  public
    Include : Boolean;
    IsImage : Boolean;
    Data : TObject;
    constructor Create;
    destructor Destroy; override;
  end;

  TSearchQuery = class(TObject)
  public
    Query : string;
    GroupName : string;
    RatingFrom : Integer;
    RatingTo : Integer;
    ShowPrivate : Boolean;
    DateFrom : TDateTime;
    DateTo : TDateTime;
    SortMethod : Integer;
    SortDecrement : Boolean;
    IsEstimate : Boolean;
    ShowAllImages : Boolean;
    function EqualsTo(AQuery : TSearchQuery) : Boolean;
  end;

type
  TCryptImageThreadOptions = record
    Files: TArStrings;
    IDs: TArInteger;
    Selected: TArBoolean;
    Password: string;
    CryptOptions: Integer;
    Action: Integer;
  end;

type
  TImportPlace = class(TObject)
  public
    Path: string;
  end;

type
  TDBPopupMenuInfoRecord = class(TObject)
  private
    FOriginalFileName: string;
    function GetInnerImage: Boolean;
    function GetExistedFileName: string;
  protected
    function InitNewInstance : TDBPopupMenuInfoRecord; virtual;
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
    Crypted: Boolean;
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
    PassTag: Integer;
    constructor Create;
    constructor CreateFromDS(DS: TDataSet);
    constructor CreateFromFile(FileName: string);
    procedure ReadExists;
    destructor Destroy; override;
    procedure ReadFromDS(DS: TDataSet);
    procedure WriteToDS(DS: TDataSet);
    function Copy: TDBPopupMenuInfoRecord; virtual;
    function FileExists: Boolean;
    procedure Assign(Item: TDBPopupMenuInfoRecord; MoveImage : Boolean = False);
    property InnerImage: Boolean read GetInnerImage;
    property ExistedFileName: string read GetExistedFileName;
  end;

  function GetSearchRecordFromItemData(ListItem : TEasyItem) : TDBPopupMenuInfoRecord;

implementation

{ TPhotoDBFiles }

function TPhotoDBFiles.Add(Name, Icon, FileName: string;
  FileType: Integer): TPhotoDBFile;
begin
  Result := TPhotoDBFile.Create;
  Result.Name := Name;
  Result.Icon := Icon;
  Result.FileName := FileName;
  Result.FileType := FileType;
  FList.Add(Result);
end;

constructor TPhotoDBFiles.Create;
begin
  FList := TList.Create;
end;

destructor TPhotoDBFiles.Destroy;
var
  I : Integer;
begin
  for I := 0 to FList.Count - 1 do
    TPhotoDBFile(FList[I]).Free;
  FList.Free;
  inherited;
end;

function TPhotoDBFiles.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPhotoDBFiles.GetValueByIndex(Index: Integer): TPhotoDBFile;
begin
  Result := FList[Index];
end;

{ TSearchQuery }

function TSearchQuery.EqualsTo(AQuery: TSearchQuery): Boolean;
begin
  Result := (AQuery.RatingFrom = RatingFrom) and (AQuery.RatingTo = RatingTo)
       and (AQuery.DateFrom = DateFrom) and (AQuery.DateTo = DateTo)
       and (AQuery.GroupName = GroupName) and (AQuery.Query = Query)
       and (AQuery.SortMethod = SortMethod) and (AQuery.SortDecrement = SortDecrement);
end;

{ TDBPopupMenuInfoRecord }

procedure TDBPopupMenuInfoRecord.Assign(Item: TDBPopupMenuInfoRecord; MoveImage : Boolean = False);
begin
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
  Crypted := Item.Crypted;
  KeyWords := Item.KeyWords;
  InfoLoaded := Item.InfoLoaded;
  Include := Item.Include;
  Links := Item.Links;
  Selected := Item.Selected;
  Tag := Item.Tag;
  PassTag := Item.PassTag;
  Width := Item.Width;
  Height := Item.Height;
  IsCurrent := False;
  Exists := Item.Exists;
  if MoveImage then
  begin
    F(Image);
    Image := Item.Image;
    Item.Image := nil;
  end;
end;

function TDBPopupMenuInfoRecord.Copy: TDBPopupMenuInfoRecord;
begin
  Result := InitNewInstance;
  Result.Assign(Self, False);
  if Data <> nil then
    Result.Data := Data.Copy
  else
    Result.Data := nil;
end;

constructor TDBPopupMenuInfoRecord.Create;
begin
  PassTag := 0;
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
  Crypted := False;
  KeyWords := '';
  InfoLoaded := False;
  Include := False;
  Links := '';
  Selected := False;
  Data := nil;
  Image := nil;
end;

constructor TDBPopupMenuInfoRecord.CreateFromDS(DS: TDataSet);
begin
  InfoLoaded := True;
  Selected := True;
  ReadFromDS(DS);
  Data := nil;
  Image := nil;
end;

constructor TDBPopupMenuInfoRecord.CreateFromFile(FileName: string);
begin
  Create;
  Self.FOriginalFileName := FileName;
  Self.FileName := FileName;
  Self.Name := ExtractFileName(FileName);
end;

destructor TDBPopupMenuInfoRecord.Destroy;
begin
  F(Data);
  F(Image);
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

function TDBPopupMenuInfoRecord.GetInnerImage: Boolean;
begin
  Result := FileName = '?.JPEG';
end;

function TDBPopupMenuInfoRecord.InitNewInstance: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord.Create;
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
    if ThumbField <> nil then
      Crypted := ValidCryptBlobStreamJPG(ThumbField)
    else
      Crypted := False;

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

function GetSearchRecordFromItemData(ListItem : TEasyItem) : TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord(TDataObject(ListItem.Data).Data);
end;

{ TSearchDataExtension }

function TSearchDataExtension.Copy: TClonableObject;
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

{ TDataObject }

constructor TDataObject.Create;
begin
  Data := nil;
end;

destructor TDataObject.Destroy;
begin
  F(Data);
  inherited;
end;

{ TImageDBOptions }

function TImageDBOptions.Copy: TImageDBOptions;
begin
  Result := TImageDBOptions.Create;
  Result.Version := Version;
  Result.DBJpegCompressionQuality := DBJpegCompressionQuality;
  Result.ThSize := ThSize;
  Result.ThSizePanelPreview := ThSizePanelPreview;
  Result.ThHintSize := ThHintSize;
  Result.Description := Description;
  Result.Name := Name;
end;

constructor TImageDBOptions.Create;
begin
  Version := 0;
end;

end.
