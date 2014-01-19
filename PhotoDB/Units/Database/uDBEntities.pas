unit uDBEntities;

interface

uses
  Winapi.Windows,
  Generics.Collections,
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  CmpUnit,
  EasyListView,
  UnitDBDeclare,
  GraphicCrypt,
  UnitLinksSupport,

  uConstants,
  uMemory,
  uRuntime,
  uList64,
  uDBConnection,
  uDBAdapter,
  uBitmapUtils,
  uCDMappingTypes,
  uDBGraphicTypes,
  uFaceDetection;

type
  TBaseEntity = class
  public
    procedure ReadFromDS(DS: TDataSet); virtual; abstract;
  end;

type
  TMediaItem = class(TBaseEntity)
  private
    FOriginalFileName: string;
    FFileNameCRC32: Cardinal;
    FGeoLocation: TGeoLocation;
    function GetInnerImage: Boolean;
    function GetExistedFileName: string;
    function GetFileNameCRC: Cardinal;
    function GetHasImage: Boolean;
  protected
    function InitNewInstance: TMediaItem; virtual;
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
    Colors: string;
    ViewCount: Integer;
    UpdateDate: TDateTime;
    Histogram: THistogrammData;
    constructor Create;
    constructor CreateFromDS(DS: TDataSet);
    constructor CreateFromFile(FileName: string);
    procedure ReadExists;
    destructor Destroy; override;
    procedure ReadFromDS(DS: TDataSet); override;
    procedure WriteToDS(DS: TDataSet);
    procedure LoadImageFromDS(DS: TDataSet);
    function Copy: TMediaItem; virtual;
    function FileExists: Boolean;
    procedure SaveToEvent(var EventValues: TEventValues);
    procedure LoadGeoInfo(Latitude, Longitude: Double);
    procedure Assign(Item: TMediaItem; MoveImage: Boolean = False); reintroduce;
    property InnerImage: Boolean read GetInnerImage;
    property ExistedFileName: string read GetExistedFileName;
    //lower case
    property FileNameCRC: Cardinal read GetFileNameCRC;
    property GeoLocation: TGeoLocation read FGeoLocation;
    property HasImage: Boolean read GetHasImage;
  end;

  TMediaItemCollection = class(TObject)
  private
    FIsPlusMenu: Boolean;
    FIsListItem: Boolean;
    FListItem: TEasyItem;
    function GetValueByIndex(Index: Integer): TMediaItem;
    function GetCount: Integer;
    function GetIsVariousInclude: Boolean;
    function GetStatRating: Integer;
    function GetStatDate: TDateTime;
    function GetStatTime: TDateTime;
    function GetStatIsDate: Boolean;
    function GetStatIsTime: Boolean;
    function GetIsVariousDate: Boolean;
    function GetIsVariousTime: Boolean;
    function GetCommonKeyWords: string;
    function GetIsVariousComments: Boolean;
    function GetCommonGroups: string;
    function GetCommonLinks: TLinksInfo;
    function GetPosition: Integer;
    procedure SetPosition(const Value: Integer);
    function GetStatInclude: Boolean;
    function GetCommonComments: string;
    procedure SetValueByIndex(Index: Integer; const Value: TMediaItem);
    function GetSelectionCount: Integer;
    function GetIsVariousHeight: Boolean;
    function GetIsVariousWidth: Boolean;
    function GetOnlyDBInfo: Boolean;
    function GetFilesSize: Int64;
    function GetIsVariousLocation: Boolean;
    function GetHasNonDBInfo: Boolean;
    function GetCommonSelectedGroups: string;
    function GetTotalViews: Integer;
  protected
    FData: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TMediaItemCollection);
    procedure Insert(Index: Integer; MenuRecord: TMediaItem);
    procedure Add(MenuRecord: TMediaItem); overload;
    function Add(FileName: string): TMediaItem; overload;
    procedure Clear;
    procedure ClearList;
    procedure Exchange(Index1, Index2: Integer);
    procedure Delete(Index: Integer);
    procedure NextSelected;
    procedure PrevSelected;
    function Extract(Index: Integer): TMediaItem;
    property Items[index: Integer]: TMediaItem read GetValueByIndex write SetValueByIndex; default;
    property IsListItem: Boolean read FIsListItem write FIsListItem;
    property Count: Integer read GetCount;
    property IsVariousInclude: Boolean read GetIsVariousInclude;
    property IsVariousDate: Boolean read GetIsVariousDate;
    property IsVariousTime: Boolean read GetIsVariousTime;
    property IsVariousComments: Boolean read GetIsVariousComments;
    property IsVariousWidth: Boolean read GetIsVariousWidth;
    property IsVariousHeight: Boolean read GetIsVariousHeight;
    property IsVariousLocation: Boolean read GetIsVariousLocation;
    property StatRating: Integer read GetStatRating;
    property StatDate: TDateTime read GetStatDate;
    property StatTime: TDateTime read GetStatTime;
    property StatIsDate: Boolean read GetStatIsDate;
    property StatIsTime: Boolean read GetStatIsTime;
    property StatInclude: Boolean read GetStatInclude;
    property IsPlusMenu: Boolean read FIsPlusMenu write FIsPlusMenu;
    property CommonKeyWords: string read GetCommonKeyWords;
    property CommonGroups: string read GetCommonGroups;
    property CommonSelectedGroups: string read GetCommonSelectedGroups;
    property CommonLinks: TLinksInfo read GetCommonLinks;
    property CommonComments: string read GetCommonComments;
    property Position: Integer read GetPosition write SetPosition;
    property ListItem: TEasyItem read FListItem write FListItem;
    property SelectionCount: Integer read GetSelectionCount;
    property OnlyDBInfo: Boolean read GetOnlyDBInfo;
    property FilesSize: Int64 read GetFilesSize;
    property HasNonDBInfo: Boolean read GetHasNonDBInfo;
    property TotalViews: Integer read GetTotalViews;
  end;

const
  GROUP_ACCESS_COMMON = 0;
  GROUP_ACCESS_PRIVATE = 1;

type
  TGroup = class(TBaseEntity)
  public
    GroupID: Integer;
    GroupName: string;
    GroupCode: string;
    GroupImage: TJpegImage;
    GroupDate: TDateTime;
    GroupComment: string;
    GroupFaces: string;
    GroupAccess: Integer;
    GroupKeyWords: string;
    AutoAddKeyWords: Boolean;
    RelatedGroups: string;
    IncludeInQuickList: Boolean;

    class function CreateNewGroupCode: string;
    class function GroupSearchByGroupName(GroupName: string): string;

    constructor Create;
    destructor Destroy; override;

    procedure ReadFromDS(DS: TDataSet); override;
    procedure Assign(Group: TGroup);
    function Clone: TGroup;
    function ToString: string; override;
  end;

  TGroups = class(TList<TGroup>)
  public
    class procedure AddGroupsToGroups(var Groups: string; GroupsToAdd: string); overload;
    class function CompareGroups(GroupsA, GroupsB: string): Boolean; overload;
    class procedure ReplaceGroups(GroupsToDelete, GroupsToAdd: string; var Groups: string);
    class function GroupWithCodeExistsInString(GroupCode, Groups: string): Boolean;

    constructor CreateFromString(Groups: string);
    destructor Destroy; override;
    procedure DeleteGroupAt(Index: Integer);
    procedure RemoveGroup(Group: TGroup);
    function RemoveGroups(Groups: TGroups): TGroups;
    function ToString: string; override;
    function AddGroup(Group: TGroup): TGroups;
    function AddGroups(Groups: TGroups): TGroups;
    function HasGroup(Group: TGroup): Boolean;
    function CompareTo(Groups: TGroups): Boolean;
    function Clone: TGroups;
  end;

  TPerson = class(TBaseEntity)
  private
    FEmpty: Boolean;
    FID: Integer;
    FName: string;
    FImage: TJpegImage;
    FGroups: string;
    FBirthDay: TDateTime;
    FComment: string;
    FPhone: string;
    FAddress: string;
    FCompany: string;
    FJobTitle: string;
    FIMNumber: string;
    FEmail: string;
    FSex: Integer;
    FCreateDate: TDateTime;
    FUniqID: string;
    FPreview: TBitmap;
    FPreviewSize: TSize;
    FCount: Integer;
    FTag: Integer;
    procedure SetImage(const Value: TJpegImage);
    procedure SetID(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function CreatePreview(Width, Height: Integer): TBitmap;
    procedure ReadFromDS(DS: TDataSet); override;
    procedure SaveToDS(DS: TDataSet);
    procedure Assign(Source: TPerson);
    function Clone: TPerson;
    property ID: Integer read FID write SetID;
    property Name: string read FName write FName;
    property BirthDay: TDateTime read FBirthDay write FBirthDay;
    property Image: TJpegImage read FImage write SetImage;
    property Groups: string read FGroups write FGroups;
    property Comment: string read FComment write FComment;
    property Phone: string read FPhone write FPhone;
    property Address: string read FAddress write FAddress;
    property Company: string read FCompany write FCompany;
    property JobTitle: string read FJobTitle write FJobTitle;
    property IMNumber: string read FIMNumber write FIMNumber;
    property Email: string read FEmail write FEmail;
    property Sex: Integer read FSex write FSex;
    property CreateDate: TDateTime read FCreateDate;
    property UniqID: string read FUniqID write FUniqID;
    property Empty: Boolean read FEmpty;
    property Count: Integer read FCount;
    property Tag: Integer read FTag write FTag;
  end;

  TPersonCollection = class(TBaseEntity)
  private
    FList: TList<TPerson>;
    FFreeCollectionItems: Boolean;
    function GetCount: Integer;
    function GetPersonByIndex(Index: Integer): TPerson;
  public
    function GetPersonByName(PersonName: string): TPerson;
    function GetPersonByID(ID: Integer): TPerson;
    function IndexOf(Person: TPerson): Integer;
    constructor Create(FreeCollectionItems: Boolean = True);
    destructor Destroy; override;
    procedure Clear;
    procedure FreeItems;
    procedure Add(Person: TPerson);
    procedure ReadFromDS(DS: TDataSet); override;
    procedure DeleteAt(I: Integer);
    procedure MovePersonTo(FromIndex, ToIndex: Integer);
    procedure RemoveByID(PersonID: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPerson read GetPersonByIndex; default;
  end;

  TPersonArea = class(TClonableObject)
  private
    FID: Integer;
    FX: Integer;
    FY: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FFullWidth: Integer;
    FFullHeight: Integer;
    FImageID: Integer;
    FPersonID: Integer;
    FPage: Integer;
    FPersonUniqId: string;
    FPersonName: string;
  public
    constructor Create; overload;
    constructor Create(ImageID, PersonID: Integer; Area: TFaceDetectionResultItem); overload;
    procedure ReadFromDS(DS: TDataSet);
    procedure RotateLeft;
    procedure RotateRight;
    function Clone: TClonableObject; override;
    property ID: Integer read FID write FID;
    property X: Integer read FX write FX;
    property Y: Integer read FY write FY;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property FullWidth: Integer read FFullWidth write FFullWidth;
    property FullHeight: Integer read FFullHeight write FFullHeight;
    property ImageID: Integer read FImageID write FImageID;
    property PersonID: Integer read FPersonID write FPersonID;
    property Page: Integer read FPage write FPage;
    property PersonName: string read FPersonName write FPersonName;
    property PersonUniqId: string read FPersonUniqId write FPersonUniqId;
  end;

  TPersonAreaCollection = class(TObject)
  private
    FList: TList;
    function GetAreaByIndex(Index: Integer): TPersonArea;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ReadFromDS(DS: TDataSet);
    function Extract(Index: Integer): TPersonArea;
    procedure RotateLeft;
    procedure RotateRight;
    procedure Add(Item: TPersonArea);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPersonArea read GetAreaByIndex; default;
  end;

  TSettings = class(TBaseEntity)
  public
    Version: Integer;
    Name: string;
    Description: string;

    DBJpegCompressionQuality: Byte;
    ThSize: Integer;

    constructor Create;
    function Copy: TSettings;
    procedure ReadFromDS(DS: TDataSet); override;
  end;

implementation

uses
  uSessionPasswords;

{$REGION 'Media'}

{ TMediaItem }

procedure TMediaItem.Assign(Item: TMediaItem; MoveImage: Boolean = False);
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
  Encrypted := Item.Encrypted;
  KeyWords := Item.KeyWords;
  InfoLoaded := Item.InfoLoaded;
  Include := Item.Include;
  Links := Item.Links;
  Selected := Item.Selected;
  LongImageID := Item.LongImageID;
  Tag := Item.Tag;
  IsImageEncrypted := Item.IsImageEncrypted;
  Width := Item.Width;
  Height := Item.Height;
  Exists := Item.Exists;
  Colors := Item.Colors;
  ViewCount := Item.ViewCount;
  UpdateDate := Item.UpdateDate;
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

function TMediaItem.Copy: TMediaItem;
begin
  Result := InitNewInstance;
  Result.Assign(Self, False);
  if Data <> nil then
    Result.Data := Data.Clone
  else
    Result.Data := nil;
end;

constructor TMediaItem.Create;
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
  Colors := '';
  ViewCount := 0;
  UpdateDate := 0;
end;

constructor TMediaItem.CreateFromDS(DS: TDataSet);
begin
  InfoLoaded := True;
  Selected := True;
  ReadFromDS(DS);
  Data := nil;
  Image := nil;
  FGeoLocation := nil;
end;

constructor TMediaItem.CreateFromFile(FileName: string);
begin
  Create;
  Self.FOriginalFileName := FileName;
  Self.FileName := FileName;
  Self.Name := ExtractFileName(FileName);
end;

destructor TMediaItem.Destroy;
begin
  F(Data);
  F(Image);
  F(FGeoLocation);
  inherited;
end;

function TMediaItem.FileExists: Boolean;
begin
  Result := InnerImage or FileExistsSafe(FileName);
end;

function TMediaItem.GetExistedFileName: string;
begin
  if FolderView then
    Result := FileName
  else
    Result := FOriginalFileName;
end;

function TMediaItem.GetFileNameCRC: Cardinal;
begin
  if FFileNameCRC32 = 0 then
    FFileNameCRC32 := StringCRC(AnsiLowerCase(FileName));
  Result := FFileNameCRC32;
end;

function TMediaItem.GetHasImage: Boolean;
begin
  Result := (Image <> nil) and not Image.Empty;
end;

function TMediaItem.GetInnerImage: Boolean;
begin
  Result := FileName = '?.JPEG';
end;

function TMediaItem.InitNewInstance: TMediaItem;
begin
  Result := TMediaItem.Create;
end;

procedure TMediaItem.LoadGeoInfo(Latitude, Longitude: Double);
begin
  F(FGeoLocation);
  FGeoLocation := TGeoLocation.Create;
  FGeoLocation.Latitude := Latitude;
  FGeoLocation.Longitude := Longitude;
end;

procedure TMediaItem.LoadImageFromDS(DS: TDataSet);
var
  FBS: TStream;
begin
  if Encrypted then
  begin
    Image := TJpegImage.Create;
    DeCryptBlobStreamJPG(DS.FieldByName('thum'), SessionPasswords.FindForBlobStream(DS.FieldByName('thum')), Image);
    IsImageEncrypted := not Image.Empty;
  end else
  begin
    Image := TJpegImage.Create;
    FBS := GetBlobStream(DS.FieldByName('thum'), bmRead);
    try
      Image.LoadFromStream(FBS);
    finally
      F(FBS);
    end;
  end;
end;

procedure TMediaItem.ReadExists;
begin
  if FileExistsSafe(FileName) then
    Exists := 1
  else
    Exists := -1;
end;

procedure TMediaItem.ReadFromDS(DS: TDataSet);
var
  ThumbField: TField;
  DA: TImageTableAdapter;
begin
  F(Image);
  DA := TImageTableAdapter.Create(DS);
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
    Colors := DA.Colors;
    ViewCount := DA.ViewCount;
    UpdateDate := DA.UpdateDate;

    DA.ReadHistogram(Histogram);
  finally
    F(DA);
  end;
  InfoLoaded := True;
end;

procedure TMediaItem.SaveToEvent(var EventValues: TEventValues);
begin
  EventValues.FileName := AnsiLowerCase(Self.FileName);
  EventValues.ID := Self.ID;
  EventValues.Rotation := Self.Rotation;
  EventValues.Rating := Self.Rating;
  EventValues.Comment := Self.Comment;
  EventValues.KeyWords := Self.KeyWords;
  EventValues.Access := Self.Access;
  EventValues.Attr := Self.Attr;
  EventValues.Date := Self.Date;
  EventValues.IsDate := Self.IsDate;
  EventValues.IsTime := Self.IsTime;
  EventValues.Time := TimeOf(Self.Time);
  EventValues.Groups := Self.Groups;
  EventValues.IsEncrypted := Self.Encrypted;
  EventValues.Include := Self.Include;
end;

procedure TMediaItem.WriteToDS(DS: TDataSet);
var
  DA: TImageTableAdapter;
begin
  DA := TImageTableAdapter.Create(DS);
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
    DA.Colors := Colors;
    DA.ViewCount := ViewCount;
    DA.UpdateDate := UpdateDate;
  finally
    F(DA);
  end;
end;

function GetCommonGroupsForStringList(GroupsList: TStringList): string;
var
  I: Integer;
  FArGroups: TList<TGroups>;
  Res: TGroups;

  function GetCommonGroupsForList(ArGroups: TList<TGroups>): TGroups;
  var
    I, J: Integer;
  begin
    if ArGroups.Count = 0 then
      Exit;

    Result := ArGroups[0].Clone;
    for I := 1 to ArGroups.Count - 1 do
    begin
      if ArGroups[I].Count = 0 then
      begin
        FreeList(Result, False);
        Break;
      end;

      for J := Result.Count - 1 downto 0 do
        if not ArGroups[I].HasGroup(Result[J]) then
          Result.RemoveGroup(Result[J]);

      if Result.Count = 0 then
        Exit;
    end;
  end;

begin
  Result := '';

  if GroupsList.Count = 0 then
    Exit;

  FArGroups := TList<TGroups>.Create;
  try
    for I := 0 to GroupsList.Count - 1 do
      FArGroups.Add(TGroups.CreateFromString(GroupsList[I]));

    Res := GetCommonGroupsForList(FArGroups);
    try
      Result := Res.ToString;
    finally
      F(Res);
    end;
  finally
    FreeList(FArGroups);
  end;
end;

{ TDBPopupMenuInfo }

procedure TMediaItemCollection.Add(MenuRecord: TMediaItem);
begin
  if MenuRecord = nil then
    Exit;

  FData.Add(MenuRecord);
end;

procedure TMediaItemCollection.Insert(Index: Integer;
  MenuRecord: TMediaItem);
begin
  if MenuRecord = nil then
    Exit;

  FData.Insert(Index, MenuRecord);
end;

function TMediaItemCollection.Add(FileName: string): TMediaItem;
begin
  Result := TMediaItem.Create;
  Result.FileName := FileName;
  Result.Include := True;
  Result.FileSize := GetFileSize(FileName);
  Add(Result);
end;

procedure TMediaItemCollection.Assign(Source: TMediaItemCollection);
var
  I: Integer;
begin
  if Pointer(Source) = Pointer(Self) then
     Exit;
  Clear;
  for I := 0 to Source.Count - 1 do
    FData.Add(Source[I].Copy);

  if Source.Position >= 0 then
    Position := Source.Position;

  ListItem := Source.ListItem;
end;

procedure TMediaItemCollection.Clear;
var
  I: Integer;
begin
  for I := 0 to FData.Count - 1 do
    TMediaItem(FData[I]).Free;
  FData.Clear;
end;

procedure TMediaItemCollection.ClearList;
begin
  FData.Clear;
end;

constructor TMediaItemCollection.Create;
begin
  FData := TList.Create;
  ListItem := nil;
  IsListItem := False;
  IsPlusMenu := False;
end;

procedure TMediaItemCollection.Delete(Index: Integer);
begin
  TObject(FData[Index]).Free;
  FData.Delete(Index);
end;

destructor TMediaItemCollection.Destroy;
begin
  Clear;
  F(FData);
  inherited;
end;

procedure TMediaItemCollection.Exchange(Index1, Index2: Integer);
begin
  FData.Exchange(Index1, Index2);
end;

function TMediaItemCollection.Extract(Index: Integer): TMediaItem;
begin
  Result := FData[Index];
  FData.Delete(Index);
end;

function TMediaItemCollection.GetCommonComments: string;
begin
  Result := '';
  if (Count > 0) and not IsVariousComments then
    Result := Self[0].Comment;
end;

function TMediaItemCollection.GetCommonGroups: string;
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      SL.Add(Self[I].Groups);
    Result := GetCommonGroupsForStringList(SL);
  finally
    F(SL);
  end;
end;

function TMediaItemCollection.GetCommonSelectedGroups: string;
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      if Self[I].Selected then
        SL.Add(Self[I].Groups);
    Result := GetCommonGroupsForStringList(SL);
  finally
    F(SL);
  end;
end;

function TMediaItemCollection.GetCommonKeyWords: string;
var
  KL: TStringList;
  I: Integer;
begin
  KL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      KL.Add(Self[I].KeyWords);
    Result := GetCommonWordsA(KL);
  finally
    F(KL);
  end;
end;

function TMediaItemCollection.GetCommonLinks: TLinksInfo;
var
  LL: TStringList;
  I: Integer;
begin
  LL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      LL.Add(Self[I].Links);
    Result := UnitLinksSupport.GetCommonLinks(LL);
  finally
    F(LL);
  end;
end;

function TMediaItemCollection.GetCount: Integer;
begin
  Result := FData.Count;
end;

function TMediaItemCollection.GetFilesSize: Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    Inc(Result, Self[I].FileSize);
end;

function TMediaItemCollection.GetHasNonDBInfo: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Self[I].ID = 0 then
      Exit(True);
end;

function TMediaItemCollection.GetIsVariousComments: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Comment <> Self[I].Comment then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousDate: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Date <> Self[I].Date then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousHeight: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Height <> Self[I].Height then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousInclude: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Include <> Self[I].Include then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousLocation: Boolean;
var
  I: Integer;
  FirstDir: string;
begin
  Result := False;
  if Count > 1 then
  begin
    FirstDir := ExtractFileDir(Self[0].FileName);
    for I := 1 to Count - 1 do
      if FirstDir <> ExtractFileDir(Self[I].FileName) then
        Result := True;
  end;
end;

function TMediaItemCollection.GetIsVariousTime: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Time <> Self[I].Time then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousWidth: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Width <> Self[I].Width then
        Result := True;
end;

function TMediaItemCollection.GetOnlyDBInfo: Boolean;
var
  I: Integer;
begin
  Result := True;

  for I := 0 to Count - 1 do
    if Self[I].ID = 0 then
      Exit(False);
end;

function TMediaItemCollection.GetPosition: Integer;
var
  I: Integer;
begin
  Result := -1;
  if Count > 0 then
    Result := 0;
  for I := 1 to Count - 1 do
    if Self[I].IsCurrent then
      Result := I;
end;

function TMediaItemCollection.GetSelectionCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Self[I].Selected then
      Inc(Result);
end;

function TMediaItemCollection.GetStatDate: TDateTime;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Date);
    Result := List.MaxStatDateTime;
  finally
    F(List);
  end;
end;

function TMediaItemCollection.GetStatInclude: Boolean;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Include);
    Result := List.MaxStatBoolean;
  finally
    F(List);
  end;
end;

function TMediaItemCollection.GetStatIsDate: Boolean;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].IsDate);
    Result := List.MaxStatBoolean;
  finally
    F(List);
  end;
end;

function TMediaItemCollection.GetStatIsTime: Boolean;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].IsTime);
    Result := List.MaxStatBoolean;
  finally
    F(List);
  end;
end;

function TMediaItemCollection.GetStatRating: Integer;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Rating);
    Result := List.MaxStatInteger;
  finally
    F(List);
  end;
end;

function TMediaItemCollection.GetStatTime: TDateTime;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Time);
    Result := List.MaxStatDateTime;
  finally
    F(List);
  end;
end;

function TMediaItemCollection.GetTotalViews: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Count - 1 do
    Result := Result + Self[I].ViewCount;
end;

function TMediaItemCollection.GetValueByIndex(Index: Integer): TMediaItem;
begin
  if Index < 0 then
    raise EInvalidOperation.Create('Index is out of range - index should be 0 or grater!');

  if Index > Count - 1 then
    raise EInvalidOperation.Create('Index is out of range!');

  Result := FData[Index];
end;

procedure TMediaItemCollection.SetPosition(const Value: Integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].IsCurrent := False;
  Self[Value].IsCurrent := True;
end;

procedure TMediaItemCollection.NextSelected;
var
  I: Integer;
begin
  for I := Position + 1 to Count - 1 do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;

  for I := 0 to Position do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;
end;

procedure TMediaItemCollection.PrevSelected;
var
  I: Integer;
begin
  for I := Position - 1 downto 0 do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;

  for I := Count - 1 downto Position do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;
end;

procedure TMediaItemCollection.SetValueByIndex(index: Integer;
  const Value: TMediaItem);
begin
  if FData[Index] <> nil then
    TMediaItem(FData[index]).Free;
  FData[Index] := Value;
end;

{$ENDREGION}

{$REGION 'Settings'}

{ TSettings }

function TSettings.Copy: TSettings;
begin
  Result := TSettings.Create;
  Result.Version := Version;

  Result.Name := Name;
  Result.Description := Description;

  Result.DBJpegCompressionQuality := DBJpegCompressionQuality;
  Result.ThSize := ThSize;
end;

constructor TSettings.Create;
begin
  Version := 0;
  DBJpegCompressionQuality := 75;
  ThSize := 200;
end;

procedure TSettings.ReadFromDS(DS: TDataSet);
begin
  Version := DS.FieldByName('Version').AsInteger;

  Name := Trim(DS.FieldByName('DBName').AsString);
  Description := Trim(DS.FieldByName('DBDescription').AsString);

  DBJpegCompressionQuality := DS.FieldByName('DBJpegCompressionQuality').AsInteger;
  ThSize := DS.FieldByName('ThImageSize').AsInteger;
end;

{$ENDREGION}

{$REGION 'Groups'}

{ TGroup }

//${345d-fgtr-ergd}[#Group name#]
class function TGroup.CreateNewGroupCode: string;
const
  StrTable = Pwd_rusup + Pwd_rusdown + Pwd_englup + Pwd_engldown + Pwd_cifr;

function RandomPwd(PWLen: Integer; StrTable: string): string;
var
  Y, I: Integer;
begin
  Randomize;
  SetLength(Result, PWLen);
  Y := Length(StrTable);
  for I := 1 to PWLen do
    Result[I] := StrTable[Random(Y) + 1];
end;

begin
  Result := RandomPwd(4, StrTable) + '-' + RandomPwd(4, StrTable) + '-' + RandomPwd(4, StrTable);
end;

class function TGroup.GroupSearchByGroupName(GroupName: string): string;
begin
  Result := '%#' + GroupName + '#%';
end;

procedure TGroup.Assign(Group: TGroup);
begin
  GroupID := Group.GroupID;
  GroupName := Group.GroupName;
  GroupCode := Group.GroupCode;
  F(GroupImage);
  if Group.GroupImage <> nil then
  begin
    GroupImage := TJpegImage.Create;
    GroupImage.Assign(Group.GroupImage);
  end;
  GroupComment := Group.GroupComment;
  GroupDate := Group.GroupDate;
  GroupFaces := Group.GroupFaces;
  GroupAccess := Group.GroupAccess;
  GroupKeyWords := Group.GroupKeyWords;
  AutoAddKeyWords := Group.AutoAddKeyWords;
  RelatedGroups := Group.RelatedGroups;
  IncludeInQuickList := Group.IncludeInQuickList;
end;

function TGroup.Clone: TGroup;
begin
  Result := TGroup.Create;
  Result.Assign(Self);
end;

constructor TGroup.Create;
begin
  GroupName := '';
  GroupCode := '';
  GroupImage := nil;
  GroupDate := 0;
  IncludeInQuickList := True;
end;

destructor TGroup.Destroy;
begin
  F(GroupImage);
  inherited;
end;

procedure TGroup.ReadFromDS(DS: TDataSet);
var
  BS: TStream;
begin
  GroupID := DS.FieldByName('ID').AsInteger;
  GroupName := Trim(DS.FieldByName('GroupName').AsString);
  GroupCode := Trim(DS.FieldByName('GroupCode').AsString);
  F(GroupImage);
  if DS.FindField('GroupImage') <> nil then
  begin
    BS := GetBlobStream(DS.FieldByName('GroupImage'), bmRead);
    try
      GroupImage := TJpegImage.Create;
      if BS.Size <> 0 then
        GroupImage.LoadfromStream(Bs);

    finally
      F(BS);
    end;
  end;

  GroupComment := DS.FieldByName('GroupComment').AsString;
  GroupDate := DS.FieldByName('GroupDate').AsDateTime;
  GroupFaces := DS.FieldByName('GroupFaces').AsString;
  GroupAccess := DS.FieldByName('GroupAccess').AsInteger;
  GroupKeyWords := DS.FieldByName('GroupKW').AsString;
  AutoAddKeyWords := DS.FieldByName('GroupAddKW').AsBoolean;
  RelatedGroups := DS.FieldByName('RelatedGroups').AsString;
  IncludeInQuickList := DS.FieldByName('IncludeInQuickList').AsBoolean;
end;

function TGroup.ToString: string;
begin
  Result := '${' + GroupCode + '}[#' + GroupName + '#]';
end;

{ TGroups }

class procedure TGroups.AddGroupsToGroups(var Groups: string; GroupsToAdd: string);
var
  GA, GB: TGroups;
begin
  GA := TGroups.CreateFromString(Groups);
  GB := TGroups.CreateFromString(GroupsToAdd);
  try
    GA.AddGroups(GB);
    Groups := GA.ToString;
  finally
    F(GA);
    F(GB);
  end;
end;

class function TGroups.CompareGroups(GroupsA, GroupsB: string): Boolean;
var
  GA, GB: TGroups;
begin
  GA := TGroups.CreateFromString(GroupsA);
  GB := TGroups.CreateFromString(GroupsB);
  try
    Result := GA.CompareTo(GB);
  finally
    F(GA);
    F(GB);
  end;
end;

class function TGroups.GroupWithCodeExistsInString(GroupCode, Groups: string): Boolean;
var
  AGroups: TGroups;
  I: Integer;
begin
  Result := False;
  AGroups := TGroups.CreateFromString(Groups);
  try
    for I := 0 to AGroups.Count - 1 do
      if AGroups[I].GroupCode = GroupCode then
      begin
        Result := True;
        Break;
      end;
  finally
    F(AGroups);
  end;
end;

class procedure TGroups.ReplaceGroups(GroupsToDelete, GroupsToAdd: string; var Groups: string);
var
  GA, GB, GR: TGroups;
begin
  GA := TGroups.CreateFromString(GroupsToDelete);
  GB := TGroups.CreateFromString(GroupsToAdd);
  GR := TGroups.CreateFromString(Groups);
  try
    GR.RemoveGroups(GA).AddGroups(GB);
    Groups := GR.ToString;
  finally
    F(GA);
    F(GB);
    F(GR);
  end;
end;

function TGroups.AddGroup(Group: TGroup): TGroups;
var
  I: Integer;
begin
  Result := Self;

  for I := 0 to Count - 1 do
    if Self[I].GroupCode = Group.GroupCode then
      Exit;

  Add(Group.Clone);
end;

function TGroups.AddGroups(Groups: TGroups): TGroups;
var
  I: Integer;
begin
  for I := 0 to Groups.Count - 1 do
    AddGroup(Groups[I]);

  Result := Self;
end;

function TGroups.Clone: TGroups;
var
  Group: TGroup;
begin
  Result := TGroups.Create;
  for Group in Self do
    Result.Add(Group.Clone);
end;

function TGroups.CompareTo(Groups: TGroups): Boolean;
var
  I: Integer;
begin
  Result := Count = Groups.Count;
  if Result then
    for I := 0 to Count - 1 do
      if not Groups.HasGroup(Self[I]) then
        Exit(False);
end;

constructor TGroups.CreateFromString(Groups: string);
var
  I, J, N: Integer;
  IsGroupCode, IsGroupName: Boolean;
  S, GroupName, GroupCode: string;
  Group: TGroup;
begin
  inherited Create;
  S := Groups;
  for I := 1 to Length(Groups) - 4 do
  begin
    IsGroupCode := False;
    IsGroupName := False;
    if (S[I] = '$') and (S[I + 1] = '{') then
    begin
      N := I;
      for J := I + 1 to Length(Groups) do
        if S[J] = '}' then
        begin
          N := J;
          GroupCode := Copy(S, I, J - I);
        end;
      for J := I + 1 to Length(Groups) - 1 do
        if S[J] = '}' then
        begin
          N := J;
          IsGroupCode := True;
          GroupCode := Copy(S, I + 2, J - I - 2);
          Break;
        end;
      if S[N + 1] = '[' then
        for J := N + 1 to Length(Groups) do
          if S[J] = ']' then
          begin
            IsGroupName := True;
            GroupName := Copy(S, N + 2, J - N - 2);
            GroupName := Copy(GroupName, 2, Length(GroupName) - 2);
            Break;
          end;
      if IsGroupName and IsGroupCode and (GroupName <> '') then
      begin
        Group := TGroup.Create;
        Group.GroupName := GroupName;
        Group.GroupCode := GroupCode;
        Add(Group);
      end;
    end;
  end;
end;

procedure TGroups.DeleteGroupAt(Index: Integer);
var
  Group: TGroup;
begin
  Group := Self[Index];
  Delete(Index);
  F(Group);
end;

destructor TGroups.Destroy;
begin
  FreeList(Self, False);
  inherited;
end;

function TGroups.HasGroup(Group: TGroup): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Self[I].GroupCode = Group.GroupCode then
      Exit(True);
end;

procedure TGroups.RemoveGroup(Group: TGroup);
var
  I: Integer;
begin
  if Group = nil then
    Exit;

  for I := Count - 1 downto 0 do
    if Self[I].GroupCode = Group.GroupCode then
    begin
      DeleteGroupAt(I);
      Exit;
    end;
end;

function TGroups.RemoveGroups(Groups: TGroups): TGroups;
var
  I: Integer;
begin
  for I := Groups.Count - 1 downto 0 do
    RemoveGroup(Groups[I]);

  Result := Self;
end;

function TGroups.ToString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    Result := Result + Self[I].ToString // '${'+Groups[i].GroupCode+'}[#'+Groups[i].GroupName+'#]';
end;

{$ENDREGION}

{$REGION 'Persons'}

{ TPerson }

procedure TPerson.Assign(Source: TPerson);
begin
  FID := Source.ID;
  FName := Source.Name;
  Image := Source.Image;
  FGroups := Source.Groups;
  FBirthDay := Source.BirthDay;
  FComment := Source.Comment;
  FPhone := Source.Phone;
  FAddress := Source.Address;
  FCompany := Source.Company;
  FJobTitle := Source.JobTitle;
  FIMNumber := Source.IMNumber;
  FEmail := Source.Email;
  FSex := Source.Sex;
  FCreateDate := Source.CreateDate;
  FEmpty := Source.Empty;
end;

function TPerson.Clone: TPerson;
var
  P: TPerson;
begin
  P := TPerson.Create;
  P.Assign(Self);
  Result := P;
end;

constructor TPerson.Create;
begin
  FEmpty := True;
  FID := 0;
  FName := '';
  FImage := nil;
  FGroups := '';
  FPreview := nil;
  FPreviewSize.cx := 0;
  FPreviewSize.cy := 0;
  FCount := 0;
end;

function TPerson.CreatePreview(Width, Height: Integer): TBitmap;
begin
  if (FPreview = nil) or (FPreviewSize.cx <> Width) or (FPreviewSize.cy <> Height) then
  begin
    F(FPreview);
    FPreview := TBitmap.Create;
    try
      FPreview.Assign(FImage);
      CenterBitmap24To32ImageList(FPreview, Width);
    except
      F(FPreview);
      raise;
    end;
  end;
  Result := FPreview;
end;

destructor TPerson.Destroy;
begin
  F(FImage);
  F(FPreview);
  inherited;
end;

procedure TPerson.ReadFromDS(DS: TDataSet);
var
  ImageField: TField;
begin
  FID := DS.FieldByName('ObjectID').AsInteger;
  FName := Trim(DS.FieldByName('ObjectName').AsString);
  FGroups := DS.FieldByName('RelatedGroups').AsString;
  FBirthDay := DS.FieldByName('BirthDate').AsDateTime;
  FPhone := Trim(DS.FieldByName('Phone').AsString);
  FAddress := Trim(DS.FieldByName('Address').AsString);
  FCompany := Trim(DS.FieldByName('Company').AsString);
  FJobTitle := Trim(DS.FieldByName('JobTitle').AsString);
  FIMNumber := Trim(DS.FieldByName('IMNumber').AsString);
  FEmail := Trim(DS.FieldByName('Email').AsString);
  FSex := DS.FieldByName('Sex').AsInteger;
  FComment := DS.FieldByName('ObjectComment').AsString;
  FCreateDate := DS.FieldByName('CreateDate').AsDateTime;
  FUniqID := Trim(DS.FieldByName('ObjectUniqID').AsString);
  if DS.Fields.FindField('ObjectsCount') <> nil then
    FCount := DS.FieldByName('ObjectsCount').AsInteger;

  F(FImage);

  ImageField := DS.FindField('Image');
  if ImageField <> nil then
  begin
    FImage := TJpegImage.Create;
    FImage.Assign(DS.FieldByName('Image'));
  end;
  FEmpty := False;
end;

procedure TPerson.SaveToDS(DS: TDataSet);
begin
  raise Exception.Create('Not implemented');
end;

procedure TPerson.SetID(const Value: Integer);
begin
  FID := Value;
  FEmpty := False;
end;

procedure TPerson.SetImage(const Value: TJpegImage);
begin
  F(FImage);
  if Value <> nil then
  begin
    FImage := TJpegImage.Create;
    FImage.Assign(Value);
  end;
end;

{ TPersonCollection }

procedure TPersonCollection.Add(Person: TPerson);
begin
  if FFreeCollectionItems then
    FList.Add(TPerson(Person.Clone))
  else
    FList.Add(Person);
end;

procedure TPersonCollection.Clear;
begin
  if FFreeCollectionItems then
    FreeList(FList, False)
  else
    FList.Clear;
end;

constructor TPersonCollection.Create(FreeCollectionItems: Boolean = True);
begin
  FFreeCollectionItems := FreeCollectionItems;
  FList := TList<TPerson>.Create;
end;

procedure TPersonCollection.DeleteAt(I: Integer);
begin
  if FFreeCollectionItems then
    FList[I].Free;

  FList.Delete(I);
end;

destructor TPersonCollection.Destroy;
begin
  if FFreeCollectionItems then
    FreeList(FList)
  else
    F(FList);
  inherited;
end;

procedure TPersonCollection.MovePersonTo(FromIndex, ToIndex: Integer);
var
  P: TPerson;
begin
  P := FList[FromIndex];
  FList.Delete(FromIndex);
  FList.Insert(ToIndex, P);
end;

procedure TPersonCollection.FreeItems;
begin
  FreeList(FList, False);
end;

function TPersonCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPersonCollection.GetPersonByIndex(Index: Integer): TPerson;
begin
  Result := FList[Index];
end;

function TPersonCollection.GetPersonByName(PersonName: string): TPerson;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].Name = PersonName then
    begin
      Result := Items[I];
      Exit;
    end;
end;

function TPersonCollection.IndexOf(Person: TPerson): Integer;
begin
  Result := FList.IndexOf(Person);
end;

function TPersonCollection.GetPersonByID(ID: Integer): TPerson;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].ID = ID then
    begin
      Result := Items[I];
      Exit;
    end;
end;

procedure TPersonCollection.ReadFromDS(DS: TDataSet);
var
  I: Integer;
  P: TPerson;
begin
  Clear;

  for I := 0 to DS.RecordCount - 1 do
  begin
    if I = 0 then
      DS.First;
    P := TPerson.Create;
    FList.Add(P);
    P.ReadFromDS(DS);
    DS.Next;
  end;
end;

procedure TPersonCollection.RemoveByID(PersonID: Integer);
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    if Items[I].ID = PersonID then
    begin
      DeleteAt(I);
      Exit;
    end;
end;

{ TPersonAreaCollection }

procedure TPersonAreaCollection.Add(Item: TPersonArea);
begin
  FList.Add(Item);
end;

procedure TPersonAreaCollection.Clear;
begin
  FreeList(FList, False);
end;

constructor TPersonAreaCollection.Create;
begin
  FList := TList.Create;
end;

destructor TPersonAreaCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TPersonAreaCollection.Extract(Index: Integer): TPersonArea;
begin
  Result := FList[Index];
  FList.Delete(Index);
end;

function TPersonAreaCollection.GetAreaByIndex(Index: Integer): TPersonArea;
begin
  Result := FList[Index];
end;

function TPersonAreaCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TPersonAreaCollection.ReadFromDS(DS: TDataSet);
var
  I: Integer;
  PA: TPersonArea;
begin
  Clear;
  if DS.RecordCount > 0 then
    DS.First;
  for I := 0 to DS.RecordCount - 1 do
  begin
    PA := TPersonArea.Create;
    FList.Add(PA);
    PA.ReadFromDS(DS);
    DS.Next;
  end;
end;

procedure TPersonAreaCollection.RotateLeft;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].RotateLeft;
end;

procedure TPersonAreaCollection.RotateRight;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].RotateRight;
end;

{ TPersonArea }

function TPersonArea.Clone: TClonableObject;
var
  P: TPersonArea;
begin
  P := TPersonArea.Create;
  P.ID := ID;
  P.FX := X;
  P.FY := Y;
  P.FWidth := Width;
  P.FHeight := Height;
  P.FFullWidth := FullWidth;
  P.FFullHeight := FullHeight;
  P.FImageID := ImageID;
  P.FPersonID := PersonID;
  P.FPage := Page;

  Result := P;
end;

constructor TPersonArea.Create(ImageID, PersonID: Integer;
  Area: TFaceDetectionResultItem);
begin
  Create;
  FID := 0;

  if Area <> nil then
  begin
    FX := Area.X;
    FY := Area.Y;
    FWidth := Area.Width;
    FHeight := Area.Height;
    FFullWidth := Area.ImageWidth;
    FFullHeight := Area.ImageHeight;
    FPage := Area.Page;
  end;

  FImageID := ImageID;
  FPersonID := PersonID;
end;

constructor TPersonArea.Create;
begin
end;

procedure TPersonArea.ReadFromDS(DS: TDataSet);
begin
  FID := DS.FieldByName('ObjectMappingID').AsInteger;
  FX := DS.FieldByName('Left').AsInteger;
  FY := DS.FieldByName('Top').AsInteger;
  FWidth := DS.FieldByName('Right').AsInteger - FX;
  FHeight := DS.FieldByName('Bottom').AsInteger - FY;
  FFullWidth := DS.FieldByName('ImageWidth').AsInteger;
  FFullHeight := DS.FieldByName('ImageHeight').AsInteger;
  FImageID := DS.FieldByName('ImageID').AsInteger;
  FPersonID := DS.FieldByName('ObjectID').AsInteger;
  FPage := DS.FieldByName('PageNumber').AsInteger;
end;

procedure TPersonArea.RotateLeft;
var
  NW, NH, NImageW, NImageH, NX, NY: Integer;
begin
  NImageH := FFullWidth;
  NImageW := FFullHeight;

  NW := FHeight;
  NH := FWidth;

  NX := FY;
  NY := FFullWidth - FX - Width;

  FFullWidth := NImageW;
  FFullHeight := NImageH;

  FWidth := NW;
  FHeight := NH;

  FX := NX;
  FY := NY;
end;

procedure TPersonArea.RotateRight;
var
  NW, NH, NImageW, NImageH, NX, NY: Integer;
begin
  NImageH := FFullWidth;
  NImageW := FFullHeight;

  NW := FHeight;
  NH := FWidth;

  NX := FFullHeight - FY - Height;
  NY := FX;

  FFullWidth := NImageW;
  FFullHeight := NImageH;

  FWidth := NW;
  FHeight := NH;

  FX := NX;
  FY := NY;
end;

{$ENDREGION}

end.
