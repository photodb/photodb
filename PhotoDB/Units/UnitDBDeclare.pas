unit UnitDBDeclare;

interface

uses DB, Windows, Classes, Menus, Graphics, JPEG, EasyListview,
     GraphicCrypt, uMemory, uFileUtils;

//array types
type
    TArMenuItem   = array of TMenuItem;
    TArInteger    = array of Integer;
    TArStrings    = array of String;
    TArBoolean    = array of Boolean;
    TArDateTime   = array of TDateTime;
    TArTime       = array of TDateTime;
    TArInteger64  = array of int64;
    TArCardinal   = array of Cardinal;

const
  BufferSize = 100*3*4*4096;
Type
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

  TProgressCallBackInfo = record
    MaxValue : int64;
    Position : int64;
    Information : String;
    Terminate : Boolean;
  end;

  TCallBackProgressEvent = procedure(Sender : TObject; var Info : TProgressCallBackInfo) of object;

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
    Version : integer;
    DBJpegCompressionQuality : byte;
    ThSize : integer;
    ThSizePanelPreview : integer;
    ThHintSize : integer;
    Description : string;
    Name : string;
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


  TOnDBKernelEventProcedure = procedure(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues) of object;

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
  TImageCompareResult = record
    ByGistogramm : Byte;
    ByPixels : Byte;
  end;

 TExplorerFileInfo = class(TObject)
  public
    FileName : String;
    SID : TGUID;
    FileType :  Integer;
    ID : Integer;
    Rotate : Integer;
    Access : Integer;
    Rating : Integer;
    FileSize : Int64;
    Comment: string;
    KeyWords: string;
    Date: TDateTime;
    Time: TDateTime;
    ImageIndex: Integer;
    Owner: string;
    Groups: string;
    Collections: string;
    IsDate: Boolean;
    IsTime: Boolean;
    Crypted: Boolean;
    Tag: Integer;
    Loaded: Boolean;
    Include: Boolean;
    Links: string;
    IsBigImage: Boolean;
    function Clone: TExplorerFileInfo;
  end;

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
  TOneRecordInfo = record
    ItemFileName: string;
    ItemCrypted: Boolean;
    ItemId: Integer;
    ItemImTh: string;
    ItemSize: Int64;
    ItemRotate: Integer;
    ItemRating: Integer;
    ItemAccess: Integer;
    ItemComment: string;
    ItemCollections: string;
    ItemGroups: string;
    ItemOwner: string;
    ItemKeyWords: string;
    ItemDate: TDateTime;
    ItemTime: TDateTime;
    ItemIsDate: Boolean;
    ItemIsTime: Boolean;
    ItemHeight: Integer;
    ItemWidth: Integer;
    ItemInclude: Boolean;
    Image: TJpegImage;
    Tag: Integer;
    PassTag: Integer;
    Loaded: Boolean;
    ItemLinks: string;
  end;

  TRecordsInfo = record
    ItemFileNames: TArStrings;
    ItemIds: TArInteger;
    ItemRotates: TArInteger;
    ItemRatings: TArInteger;
    ItemAccesses: TArInteger;
    ItemComments: TArStrings;
    ItemCollections: TArStrings;
    ItemGroups: TArStrings;
    ItemOwners: TArStrings;
    ItemKeyWords: TArStrings;
    ItemDates: TArDateTime;
    ItemTimes: TArTime;
    ItemIsDates: TArBoolean;
    ItemIsTimes: TArBoolean;
    ItemCrypted: TArBoolean;
    ItemInclude: TArBoolean;
    ItemLinks: TArStrings;
    Position: Integer;
    Tag: Integer;
    LoadedImageInfo: TArBoolean;
  end;

type
  TDBPopupMenuInfoRecord = class(TObject)
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
    Links: string; // ??? not for common use yet
    Exists: Integer; // for drawing in lists
    LongImageID: string;
    Data: TClonableObject;
    constructor CreateFromDS(DS: TDataSet);
//    constructor CreateFromContRecord(ContRecord: TImageContRecord);
    constructor CreateFromSlideShowInfo(Info: TRecordsInfo; Position: Integer);
//    constructor CreateFromSearchRecord(Info: TSearchRecord);
    constructor CreateFromExplorerInfo(Info: TExplorerFileInfo);
    constructor CreateFromRecordInfo(RI: TOneRecordInfo);
    destructor Destroy; override;
    function Copy : TDBPopupMenuInfoRecord;
  end;

  function GetSearchRecordFromItemData(ListItem : TEasyItem) : TDBPopupMenuInfoRecord;

implementation

{ TSearchRecordArray }

{procedure TSearchRecordArray.Add(Data: TSearchRecord);
begin
  FList.Add(Data);
end;

function TSearchRecordArray.AddNew: TSearchRecord;
begin
  Result := TSearchRecord.Create;
  FList.Add(Result);
end;

procedure TSearchRecordArray.Clear;
var
  I : Integer;
begin
  for I := 0 to FList.Count - 1 do
    TSearchRecord(FList[I]).Free;
  FList.Clear;
end;

procedure TSearchRecordArray.ClearList;
begin
  FList.Clear;
end;

constructor TSearchRecordArray.Create;
begin
  FList := TList.Create;
end;

procedure TSearchRecordArray.DeleteAt(Index: Integer);
var
  Rec : TSearchRecord;
begin
  Rec := FList[Index];
  Rec.Free;
  FList.Delete(Index);
end;

destructor TSearchRecordArray.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TSearchRecordArray.ExtractAt(Index: Integer): TSearchRecord;
begin
  Result := FList[Index];
  FList.Delete(Index);
end;

function TSearchRecordArray.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSearchRecordArray.GetValueByIndex(Index: Integer): TSearchRecord;
begin
  Result := FList[Index];
end;

procedure TSearchRecordArray.SetValueByIndex(Index: Integer;
  const Value: TSearchRecord);
begin
  FList[Index] := Value;
end;
        }

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

{ TSearchRecord }

{constructor TSearchRecord.Create;
begin
  Bitmap := nil;
end;

destructor TSearchRecord.Destroy;
begin
  if Bitmap <> nil then
    Bitmap.Free;
  inherited;
end;    }


  { TDBPopupMenuInfoRecord }

function TDBPopupMenuInfoRecord.Copy: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord.Create;
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
  if Data <> nil then
    Result.Data := Data.Copy
  else
    Result.Data := nil;
end;

constructor TDBPopupMenuInfoRecord.CreateFromDS(DS: TDataSet);
var
  ThumbField: TField;
begin
  InfoLoaded := True;
  Selected := True;
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
  Data := nil;
end;

constructor TDBPopupMenuInfoRecord.CreateFromExplorerInfo(Info: TExplorerFileInfo);
begin
  ID := Info.ID;
  FileName := Info.FileName;
  Comment := Info.Comment;
  Groups := Info.Groups;
  FileSize := Info.FileSize;
  Rotation := Info.Rotate;
  Rating := Info.Rating;
  Access := Info.Access;
  Date := Info.Date;
  Time := Info.Time;
  IsDate := Info.IsDate;
  IsTime := Info.IsTime;
  Crypted := Info.Crypted;
  KeyWords := Info.KeyWords;
  InfoLoaded := Info.Loaded;
  Include := Info.Include;
  Links := Info.Links;
  Data := nil;
end;

constructor TDBPopupMenuInfoRecord.CreateFromRecordInfo(RI: TOneRecordInfo);
begin
  FileName := RI.ItemFileName;
  Comment := RI.ItemComment;
  Groups := RI.ItemGroups;
  ID := RI.ItemId;
  FileSize := RI.ItemSize;
  Rotation := RI.ItemRotate;
  Rating := RI.ItemRating;
  Access := RI.ItemAccess;
  Date := RI.ItemDate;
  Time := RI.ItemTime;
  IsDate := RI.ItemIsDate;
  IsTime := RI.ItemIsTime;
  Crypted := RI.ItemCrypted;
  KeyWords := RI.ItemKeyWords;
  InfoLoaded := RI.Loaded;
  Include := RI.ItemInclude;
  Links := RI.ItemLinks;
  Data := nil;
end;

constructor TDBPopupMenuInfoRecord.CreateFromSlideShowInfo(Info: TRecordsInfo; Position: Integer);
begin
  FileName := Info.ItemFileNames[Position];
  ID := Info.ItemIds[Position];
  Rotation := Info.ItemRotates[Position];
  Rating := Info.ItemRatings[Position];
  Comment := Info.ItemComments[Position];
  Access := Info.ItemAccesses[Position];
  Date := Info.ItemDates[Position];
  Time := Info.ItemTimes[Position];
  IsDate := Info.ItemIsDates[Position];
  IsTime := Info.ItemIsTimes[Position];
  Groups := Info.ItemGroups[Position];
  Crypted := Info.ItemCrypted[Position];
  KeyWords := Info.ItemKeyWords[Position];
  Links := Info.ItemLinks[Position];
  Selected := True;
  InfoLoaded := True;
  Attr := 0;
  InfoLoaded := Info.LoadedImageInfo[Position];
  FileSize := GetFileSizeByName(Info.ItemFileNames[Position]);
  Include := Info.ItemInclude[Position];
  Data := nil;
end;

destructor TDBPopupMenuInfoRecord.Destroy;
begin
  F(Data);
  inherited;
end;

{ TExplorerFileInfo }

function TExplorerFileInfo.Clone: TExplorerFileInfo;
begin
  Result := TExplorerFileInfo.Create;
  Result.FileName := FileName;
  Result.SID := SID;
  Result.FileType := FileType;
  Result.ID := ID;
  Result.Rotate := Rotate;
  Result.Access := Access;
  Result.Rating := Rating;
  Result.FileSize := FileSize;
  Result.Comment := Comment;
  Result.KeyWords := KeyWords;
  Result.Date := Date;
  Result.Time := Time;
  Result.ImageIndex := ImageIndex;
  Result.Owner := Owner;
  Result.Groups := Groups;
  Result.Collections := Collections;
  Result.IsDate := IsDate;
  Result.IsTime := IsTime;
  Result.Crypted := Crypted;
  Result.Tag := Tag;
  Result.Loaded := Loaded;
  Result.Include := Include;
  Result.Links := Links;
  Result.isBigImage := isBigImage;
end;

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
end;

destructor TSearchDataExtension.Destroy;
begin
  F(Bitmap);
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
