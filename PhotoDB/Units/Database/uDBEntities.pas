unit uDBEntities;

interface

uses
  Winapi.Windows,
  Generics.Collections,
  System.Classes,
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,
  Data.DB,

  CommonDBSupport,
  UnitDBDeclare,

  uConstants,
  uMemory,
  uBitmapUtils,
  uFaceDetection;

type
  TBaseEntity = class
  public
    procedure ReadFromDS(DS: TDataSet); virtual; abstract;
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
    procedure ReadFromDS(DS: TDataSet);
    procedure DeleteAt(I: Integer);
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
  public
    constructor Create; overload;
    constructor Create(ImageID, PersonID: Integer; Area: TFaceDetectionResultItem); overload;
    procedure ReadFromDS(DS: TDataSet);
    procedure RotateLeft;
    procedure RotateRight;
    function Clone: TClonableObject; override;
    property ID: Integer read FID write FID;
    property X: Integer read FX;
    property Y: Integer read FY;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property FullWidth: Integer read FFullWidth;
    property FullHeight: Integer read FFullHeight;
    property ImageID: Integer read FImageID;
    property PersonID: Integer read FPersonID write FPersonID;
    property Page: Integer read FPage;
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
    ThHintSize: Integer;

    constructor Create;
    function Copy: TSettings;
    procedure ReadFromDS(DS: TDataSet); override;
  end;

implementation

{ TSettings }

function TSettings.Copy: TSettings;
begin
  Result := TSettings.Create;
  Result.Version := Version;

  Result.Name := Name;
  Result.Description := Description;

  Result.DBJpegCompressionQuality := DBJpegCompressionQuality;
  Result.ThSize := ThSize;
  Result.ThHintSize := ThHintSize;
end;

constructor TSettings.Create;
begin
  Version := 0;
  DBJpegCompressionQuality := 75;
  ThSize := 200;
  ThHintSize := 400;
end;

procedure TSettings.ReadFromDS(DS: TDataSet);
begin
  Version := DS.FieldByName('Version').AsInteger;

  Name := DS.FieldByName('DBName').AsString;
  Description := DS.FieldByName('DBDescription').AsString;

  DBJpegCompressionQuality := DS.FieldByName('DBJpegCompressionQuality').AsInteger;
  ThSize := DS.FieldByName('ThImageSize').AsInteger;
  ThHintSize := DS.FieldByName('ThHintSize').AsInteger;
end;

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
      if IsGroupName and IsGroupCode then
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
  for I := Count - 1 downto 0 do
    if Self[I].GroupCode = Group.GroupCode then
      DeleteGroupAt(I);
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
var
  B: TBitmap;
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
  FImage := TJpegImage.Create;
  FImage.Assign(DS.FieldByName('Image'));
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

end.
