unit UnitGroupsWork;

interface


uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  JPEG,
  DB,

  CommonDBSupport,

  uMemory,
  uConstants,
  uRuntime,
  uGroupTypes,
  uDBIcons,
  uDBClasses;

function GroupSearchByGroupName(GroupName: string): string;
function GroupsTableName: string; overload;
function GroupsTableName(FileName: string): string; overload;
function GetRegisterGroupList(LoadImages: Boolean; UseInclude: Boolean = False): TGroups;
function AddGroup(Group: TGroup): Boolean;
function GroupNameExists(GroupName: string): Boolean;
function DeleteGroup(Group: TGroup): Boolean;
function FindGroupCodeByGroupName(GroupName: string): string;
function FindGroupNameByGroupCode(GroupCode: string): string;
function GetGroupByGroupName(GroupName: string; LoadImage: Boolean): TGroup; overload;
function GetGroupByGroupCode(GroupCode: string; LoadImage: Boolean): TGroup; overload;
function UpdateGroup(Group: TGroup): Boolean;
function GetRegisterGroupListW(FileName: string; LoadImages: Boolean; SortByName: Boolean; UseInclude: Boolean = False): TGroups;
function GroupWithCodeExists(GroupCode: string): Boolean;
function GetGroupByGroupNameW(GroupName: string; LoadImage: Boolean; FileName: string): TGroup;
function AddGroupW(Group: TGroup; FileName: string): Boolean;
function GroupNameExistsW(GroupName: string; FileName: string): Boolean;
function ReadGroupFromDS(DS: TDataSet; var Group: TGroup): Boolean;

implementation

function ReadGroupFromDS(DS: TDataSet; var Group: TGroup): Boolean;
var
  BS: TStream;
begin
  Group.GroupID := 0;
  if DS.FindField('ID') <> nil then
    Group.GroupID := DS.FieldByName('ID').AsInteger;

  if DS.FindField('GroupName') <> nil then
    Group.GroupName := Trim(DS.FieldByName('GroupName').AsString);

  if DS.FindField('GroupCode') <> nil then
    Group.GroupCode := Trim(DS.FieldByName('GroupCode').AsString);

  Group.GroupImage := nil;
  if DS.FindField('GroupImage') <> nil then
  begin
    BS := GetBlobStream(DS.FieldByName('GroupImage'), bmRead);
    try
      Group.GroupImage := TJpegImage.Create;
      if BS.Size <> 0 then
        Group.GroupImage.LoadfromStream(Bs);

    finally
      F(BS);
    end;
  end;

  if DS.FindField('GroupComment') <> nil then
    Group.GroupComment := DS.FieldByName('GroupComment').AsString;

  if DS.FindField('GroupDate') <> nil then
    Group.GroupDate := DS.FieldByName('GroupDate').AsDateTime;

  if DS.FindField('GroupFaces') <> nil then
    Group.GroupFaces := DS.FieldByName('GroupFaces').AsString;

  if DS.FindField('GroupAccess') <> nil then
    Group.GroupAccess := DS.FieldByName('GroupAccess').AsInteger;

  if DS.FindField('GroupKW') <> nil then
    Group.GroupKeyWords := DS.FieldByName('GroupKW').AsString;

  if DS.FindField('GroupAddKW') <> nil then
    Group.AutoAddKeyWords := DS.FieldByName('GroupAddKW').AsBoolean;

  if DS.FindField('RelatedGroups') <> nil then
    Group.RelatedGroups := DS.FieldByName('RelatedGroups').AsString;

  if DS.FindField('IncludeInQuickList') <> nil then
    Group.IncludeInQuickList := DS.FieldByName('IncludeInQuickList').AsBoolean;

  Result := True;
end;

function GroupSearchByGroupName(GroupName: string): string;
begin
  Result := '%#' + GroupName + '#%';
end;

function FindGroupCodeByGroupName(GroupName: string): string;
var
  Query: TDataSet;
begin
  Result := '';
  Query := GetQuery;
  try
    SetSQL(Query, 'Select * From ' + GroupsTableName + ' Where GroupName like "' + GroupName + '"');
    try
      OpenDS(Query);
    except
      Exit;
    end;
    if Query.RecordCount = 0 then
      Exit;

    Query.First;
    Result := Query.FieldByName('GroupCode').AsString;
    Query.Close;
  finally
    FreeDS(Query);
  end;
end;

function FindGroupNameByGroupCode(GroupCode: string): string;
var
  Query: TDataSet;
begin
  Result := '';
  Query := GetQuery;
  try
    SetSQL(Query, 'Select * From ' + GroupsTableName + ' Where GroupCode="' + GroupCode + '"');
    OpenDS(Query);
    if Query.RecordCount = 0 then
      Exit;

    Query.First;
    Result := Query.FieldByName('GroupName').AsString;
    Query.Close;
  finally
    FreeDS(Query);
  end;
end;

function GroupNameExists(GroupName: string): Boolean;
begin
  Result := GroupNameExistsW(GroupName, Dbname);
end;

function GroupNameExistsW(GroupName : String; FileName : String) : Boolean;
var
  Query : TDataSet;
begin
  Result := False;
  Query := GetQuery(FileName);
  try
    SetSQL(Query, 'Select 1 From ' + GroupsTableName(FileName) + ' Where GroupName like "' + GroupName + '"');
    try
      OpenDS(Query);
    except
      Exit;
    end;
    Result := Query.RecordCount <> 0;
    Query.Close;
  finally
    FreeDS(Query);
  end;
end;

function GroupWithCodeExists(GroupCode: string): Boolean;
var
  Query: TDataSet;
begin
  Result := False;
  Query := GetQuery;
  try
    SetSQL(Query, 'Select * From ' + GroupsTableName + ' Where GroupCode like "' + GroupCode + '"');
    try
      OpenDS(Query);
    except
      Exit;
    end;

    Result := Query.RecordCount = 1;
    Query.Close;
  finally
    FreeDS(Query);
  end;
end;

function DeleteGroup(Group: TGroup): Boolean;
var
  Query: TDataSet;
begin
  Result := False;
  Query := GetQuery;
  try
    SetSQL(Query, 'Delete From ' + GroupsTableName + ' Where GroupCode like "' + Group.GroupCode + '"');
    try
      ExecSQL(Query);
    except
      Exit;
    end;
  finally
    FreeDS(Query);
  end;
  Result := True;
end;

function UpdateGroup(Group: TGroup): Boolean;
var
  SC: TSelectCommand;
  UC: TUpdateCommand;
  G: TGroup;
  GroupDate: TDateTime;
begin
  Result := False;
  SC := TSelectCommand.Create(GroupsTableName);
  try
    SC.AddParameter(TCustomFieldParameter.Create('[ID]'));
    SC.AddWhereParameter(TStringParameter.Create('GroupCode', Group.GroupCode));
    try
      SC.Execute;
    except
      Exit;
    end;
    if SC.RecordCount = 1 then
    begin
      if ReadGroupFromDS(SC.DS, G) then
      begin
        UC := TUpdateCommand.Create(GroupsTableName);
        try
          UC.AddParameter(TStringParameter.Create('GroupName', Group.GroupName));
          UC.AddParameter(TIntegerParameter.Create('GroupAccess', Group.GroupAccess));
          if Group.GroupImage <> nil then
            UC.AddParameter(TJpegParameter.Create('GroupImage', Group.GroupImage));
          UC.AddParameter(TStringParameter.Create('GroupComment', Group.GroupComment));
          UC.AddParameter(TStringParameter.Create('GroupFaces', Group.GroupFaces));

          if Group.GroupDate = 0 then
            GroupDate := Now
          else
            GroupDate := Group.GroupDate;
          UC.AddParameter(TDateTimeParameter.Create('GroupDate', GroupDate));

          UC.AddParameter(TBooleanParameter.Create('GroupAddKW', Group.AutoAddKeyWords));
          UC.AddParameter(TStringParameter.Create('GroupKW', Group.GroupKeyWords));
          UC.AddParameter(TStringParameter.Create('RelatedGroups', Group.RelatedGroups));
          UC.AddParameter(TBooleanParameter.Create('IncludeInQuickList', Group.IncludeInQuickList));
          UC.AddWhereParameter(TIntegerParameter.Create('ID', G.GroupID));

          UC.Execute;
          Result := True;
        finally
          F(UC);
        end;
      end;
    end;
  finally
    F(SC);
  end;
end;

function AddGroupW(Group: TGroup; FileName: string): Boolean;
var
  Query: TDataSet;
  Bit: TBitmap;
begin
  Result := False;

  if GroupNameExistsW(Group.GroupName, FileName) then
    Exit;

  Query := GetQuery(FileName);
  try
    SetSQL(Query, 'Select * From ' + GroupsTableName(FileName) + ' Where GroupCode like "' + Group.GroupCode + '"');
    try
      OpenDS(Query);
    except
      Exit;
    end;
    if Query.RecordCount = 0 then
    begin
      Query.Active := False;
      SetSQL(Query, 'Insert Into ' + GroupsTableName(FileName) +
          ' (GroupCode, GroupName, GroupImage, GroupComment, GroupDate, Groupfaces, GroupAccess, GroupKW, GroupAddKW, RelatedGroups, IncludeInQuickList) values' + ' (:GroupCode, :GroupName, :GroupImage, :GroupComment, :GroupDate, :Groupfaces, :GroupAccess, :GroupKW, :GroupAddKW, :RelatedGroups, :IncludeInQuickList)');

      SetStrParam(Query, 0, Group.GroupCode);
      SetStrParam(Query, 1, Group.GroupName);
      if Group.GroupImage = nil then
      begin
        Bit := TBitmap.Create;
        try
          Bit.PixelFormat := Pf24bit;
          Bit.Width := 16;
          Bit.Height := 16;
          DrawIconEx(Bit.Canvas.Handle, 0, 0, Icons[DB_IC_DELETE_INFO], 16, 16, 0, 0, DI_NORMAL);
          Group.GroupImage := TJpegImage.Create;
          Group.GroupImage.Assign(Bit);
        finally
          F(Bit);
        end;
        Group.GroupImage.Compress;
      end;

      AssignParam(Query, 2, Group.GroupImage);
      SetStrParam(Query, 3, Group.GroupComment);
      if Group.GroupDate = 0 then
        SetDateParam(Query, 'GroupDate', Now)
      else
        SetDateParam(Query, 'GroupDate', Group.GroupDate);
      SetStrParam(Query, 5, Group.GroupFaces);
      SetIntParam(Query, 6, Group.GroupAccess);
      SetStrParam(Query, 7, Group.GroupKeyWords);
      SetBoolParam(Query, 8, Group.AutoAddKeyWords);
      SetStrParam(Query, 9, Group.RelatedGroups);
      SetBoolParam(Query, 10, Group.IncludeInQuickList);
      try
        ExecSQL(Query);
      except
        Exit;
      end;
      Result := True;
    end;
  finally
    FreeDS(Query);
  end;
end;

function AddGroup(Group: TGroup): Boolean;
begin
  Result := AddGroupW(Group, Dbname);
end;

function GroupsTableName(FileName: string): string;
begin
  Result := 'Groups';
end;

function GroupsTableName: string;
begin
  Result := 'Groups';
end;

function GetGroupByGroupCode(GroupCode : String; LoadImage : Boolean) : TGroup;
var
  Query: TDataSet;
begin
  Query := GetQuery;
  try
    if LoadImage then
      SetSQL(Query, 'Select * From ' + GroupsTableName + ' Where GroupCode like "' + GroupCode + '"')
    else
      SetSQL(Query,
        'Select GroupCode,GroupName,GroupDate,GroupComment,GroupAccess,GroupFaces,GroupKW,GroupAddKW,RelatedGroups,IncludeInQuickList From '
          + GroupsTableName + ' Where GroupCode like "' + GroupCode + '"');
    try
      OpenDS(Query);
    except
      Result := GetNilGroup;
      Exit;
    end;
    Query.First;

    ReadGroupFromDS(Query, Result);
  finally
    FreeDS(Query);
  end;
end;

function GetGroupByGroupName(GroupName: string; LoadImage: Boolean): TGroup;
begin
  Result := GetGroupByGroupNameW(GroupName, LoadImage, Dbname);
end;

function GetGroupByGroupNameW(GroupName: string; LoadImage: Boolean; FileName: string): TGroup;
var
  Query: TDataSet;
begin
  Result := GetNilGroup;
  Query := GetQuery(FileName, True);
  try
    if LoadImage then
      SetSQL(Query, 'Select * From ' + GroupsTableName(FileName) + ' Where GroupName like "' + GroupName + '"')
    else
      SetSQL(Query,
        'Select GroupCode,GroupName,GroupDate,GroupComment,GroupAccess,GroupFaces,GroupKW,GroupAddKW, RelatedGroups, IncludeInQuickList From ' + GroupsTableName(FileName) + ' Where GroupName like "' + GroupName + '"');
    try
      OpenDS(Query);
    except
      Exit;
    end;
    if Query.RecordCount > 0 then
    begin
      Query.First;

      ReadGroupFromDS(Query, Result);
    end;
  finally
    FreeDS(Query);
  end;
end;

function GetRegisterGroupListW(FileName: String; LoadImages: Boolean; SortByName: Boolean; UseInclude: Boolean = False): TGroups;
var
  Table: TDataSet;
  N: Integer;
  I, J: Integer;
  Temp: TGroup;
  B: Boolean;
begin
  Setlength(Result, 0);
  Table := GetTable(FileName, DB_TABLE_GROUPS);
  try
    if Table = nil then
      Exit;
    try
      OpenDS(Table);
    except
      Exit;
    end;
    if Table.RecordCount > 0 then
    begin
      Table.First;
      repeat
        if UseInclude then
          if not Table.FieldByName('IncludeInQuickList').AsBoolean then
          begin
            Table.Next;
            Continue;
          end;
        N := Length(Result);
        Setlength(Result, N + 1);

        ReadGroupFromDS(Table, Result[N]);

        Table.Next;
      until Table.Eof;
    end;
  finally
    FreeDS(Table);
  end;
  if SortByName then
    for I := 1 to Length(Result) do
    begin
      B := True;
      for J := 0 to Length(Result) - 2 do
        if CompareStr(AnsiLowerCase(Result[J].GroupName), AnsiLowerCase(Result[J + 1].GroupName)) > 0 then
        begin
          Temp := Result[J];
          Result[J] := Result[J + 1];
          Result[J + 1] := Temp;
          B := False;
        end;
      if B then
        Break;
    end;
end;

function GetRegisterGroupList(LoadImages: Boolean; UseInclude: Boolean = False): TGroups;
begin
  Result := GetRegisterGroupListW(Dbname, LoadImages, True, UseInclude);
end;

end.
