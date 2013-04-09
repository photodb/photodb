unit uDBEntities;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SysUtils,
  Vcl.Imaging.Jpeg,
  Data.DB,

  CommonDBSupport,

  uConstants,
  uMemory;

type
  TBaseEntity = class
  public
    procedure ReadFromDS(DS: TDataSet); virtual; abstract;
  end;

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

const
  GROUP_ACCESS_COMMON = 0;
  GROUP_ACCESS_PRIVATE = 1;

type
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
  for I := 0 to Count - 1 do
    if Self[I].GroupCode = Group.GroupCode then
      Exit;

  Add(Group.Clone);

  Result := Self;
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

end.
