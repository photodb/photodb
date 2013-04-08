unit uDBEntities;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SysUtils,
  Vcl.Imaging.Jpeg,
  Data.DB,

  CommonDBSupport,

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

    class function GroupSearchByGroupName(GroupName: string): string;

    constructor Create;
    destructor Destroy; override;

    procedure ReadFromDS(DS: TDataSet); override;
    procedure Assign(Group: TGroup);
    function Clone: TGroup;
  end;
  TGroups = class(TList<TGroup>)
  public
    destructor Destroy; override;
    procedure DeleteGroupAt(Index: Integer);
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

class function TGroup.GroupSearchByGroupName(GroupName: string): string;
begin
  Result := '%#' + GroupName + '#%';
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

{ TGroups }

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

end.
