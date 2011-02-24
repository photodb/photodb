unit UnitDBDeclare;

interface

uses DB, Windows, Classes, Menus, Graphics, JPEG, EasyListview,
     GraphicCrypt, uMemory, uFileUtils, uDBBaseTypes, uDBGraphicTypes,
     uDBForm;

const
  BufferSize = 100*3*4*4096;

type
  PBuffer = ^TBuffer;
  TBuffer = array [1..BufferSize] of Byte;

type
  TPasswordRecord = class
  public
   CRC : Cardinal;
   FileName : String;
   ID : integer;
  end;

  TWriteLineProcedure = procedure(Sender : TObject; Line : string; aType : integer) of object;
  TGetFilesWithoutPassProc = function(Sender : TObject) : TList of object;
  TAddCryptFileToListProc = procedure(Sender : TObject; Rec : TPasswordRecord)  of object;
  TGetAvaliableCryptFileList = function(Sender : TObject) : TArInteger  of object;

  TRecreatingThInTableOptions = record
    WriteLineProc : TWriteLineProcedure;
    WriteLnLineProc : TWriteLineProcedure;
    OnEndProcedure : TNotifyEvent;
    FileName : string;
    GetFilesWithoutPassProc : TGetFilesWithoutPassProc;
    AddCryptFileToListProc : TAddCryptFileToListProc;
    GetAvaliableCryptFileList : TGetAvaliableCryptFileList;
    OnProgress : TCallBackProgressEvent;
  end;

  TImageDBOptions = record
    Version: Integer;
    DBJpegCompressionQuality: Byte;
    ThSize: Integer;
    ThSizePanelPreview: Integer;
    ThHintSize: Integer;
    Description: string;
    name: string;
  end;

  TPackingTableThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
  end;

  TRestoreThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
  end;

  TShowBadLinksThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
   WriteLnLineProc :  TWriteLineProcedure;
   OnProgress : TCallBackProgressEvent;
  end;

  TBackUpTableThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
   WriteLnLineProc :  TWriteLineProcedure;
  end;

  TOptimizeDublicatesThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
   WriteLnLineProc :  TWriteLineProcedure;
   OnProgress : TCallBackProgressEvent;
  end;

Type TEventField=(EventID_Param_Name, EventID_Param_ID, EventID_Param_Rotate,
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
      Name : String;
      NewName : String;
      ID : integer;
      Rotate : integer;
      Rating : integer;
      Comment : String;
      KeyWords : string;
      Access : integer;
      Attr : integer;
      Image : TBitmap;
      Date : TDateTime;
      IsDate : Boolean;
      IsTime : Boolean;
      Time : TDateTime;
      Groups : String;
      JPEGImage : TJpegImage;
      Collection : string;
      Owner : string;
      Crypt : Boolean;
      Include : Boolean;
      Links : string;
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
  TDBPopupMenuInfoRecord = class(TObject)
  protected
    function InitNewInstance : TDBPopupMenuInfoRecord; virtual;
  public
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
    Time: TDateTime;
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
    destructor Destroy; override;
    procedure ReadFromDS(DS: TDataSet);
    function Copy : TDBPopupMenuInfoRecord; virtual;
    procedure Assign(Item: TDBPopupMenuInfoRecord; MoveImage : Boolean = False);
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
  FileName := Item.FileName;
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
  Result.ID := ID;
  Result.FileName := FileName;
  Result.Comment := Comment;
  Result.Groups := Groups;
  Result.FileSize := FileSize;
  Result.Rotation := Rotation;
  Result.Rating := Rating;
  Result.Access := Access;
  Result.Date := Date;
  Result.Time := Time;
  Result.IsDate := IsDate;
  Result.IsTime := IsTime;
  Result.Crypted := Crypted;
  Result.KeyWords := KeyWords;
  Result.InfoLoaded := InfoLoaded;
  Result.Include := Include;
  Result.Links := Links;
  Result.Selected := Selected;
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
  Self.FileName := FileName;
end;

destructor TDBPopupMenuInfoRecord.Destroy;
begin
  F(Data);
  F(Image);
  inherited;
end;

function TDBPopupMenuInfoRecord.InitNewInstance: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord.Create;
end;

procedure TDBPopupMenuInfoRecord.ReadFromDS(DS: TDataSet);
var
  ThumbField: TField;
begin
  F(Image);
  ID := DS.FieldByName('ID').AsInteger;
  KeyWords := DS.FieldByName('KeyWords').AsString;
  FileName := DS.FieldByName('FFileName').AsString;
  FileSize := DS.FieldByName('FileSize').AsInteger;
  Rotation := DS.FieldByName('Rotated').AsInteger;
  Rating := DS.FieldByName('Rating').AsInteger;
  Access := DS.FieldByName('Access').AsInteger;
  Attr := DS.FieldByName('Attr').AsInteger;
  Comment := DS.FieldByName('Comment').AsString;
  Date := DS.FieldByName('DateToAdd').AsDateTime;
  Time := DS.FieldByName('aTime').AsDateTime;
  IsDate := DS.FieldByName('IsDate').AsBoolean;
  IsTime := DS.FieldByName('IsTime').AsBoolean;
  Groups := DS.FieldByName('Groups').AsString;
  LongImageID := DS.FieldByName('StrTh').AsString;
  Width := DS.FieldByName('Width').AsInteger;
  Height := DS.FieldByName('Height').AsInteger;

  ThumbField := DS.FindField('thum');
  if ThumbField <> nil then
    Crypted := ValidCryptBlobStreamJPG(ThumbField)
  else
    Crypted := False;

  Include := DS.FieldByName('Include').AsBoolean;
  Links := DS.FieldByName('Links').AsString;

  InfoLoaded := True;
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

end.
