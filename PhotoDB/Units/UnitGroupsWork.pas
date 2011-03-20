unit UnitGroupsWork;

interface


uses
  Windows, SysUtils, Graphics, UnitDBDeclare, JPEG, DB, Classes,
  uMemory, uConstants, uFileUtils;

type
  TGroup = record
    GroupName: string;
    GroupCode: string;
    GroupImage: TJpegImage;
    GroupDate: TdateTime;
    GroupComment: string;
    GroupFaces: string;
    GroupAccess: Integer;
    GroupKeyWords: string;
    AutoAddKeyWords: Boolean;
    RelatedGroups: string;
    IncludeInQuickList: Boolean;
  end;

  TGroups = array of TGroup;
  TArGroups = array of TGroups;

const
  GROUP_ACCESS_COMMON = 0;
  GROUP_ACCESS_PRIVATE = 1;

type
  TGroupAction = record
    Action: Integer;
    OutGroup: TGroup;
    InGroup: TGroup;
    ReplaceImageOnNew: Boolean;
    ActionForAll: Boolean;
    ActionForAllKnown: Boolean;
    ActionForAllUnKnown: Boolean;
  end;

  TGroupsActions = array of TGroupAction;

  TGroupsActionsW = record
    Actions: TGroupsActions;
    IsActionForUnKnown: Boolean;
    ActionForUnKnown: TGroupAction;
    IsActionForKnown: Boolean;
    ActionForKnown: TGroupAction;
    MaxAuto: Boolean;
  end;

function CreateNewGroup(GroupName: string): string;
function GroupSearchByGroupName(GroupName: string): string;
function EncodeGroups(Groups: string): TGroups;
function GroupsTableName: string; overload;
function GroupsTableName(FileName: string): string; overload;
function GetRegisterGroupList(LoadImages: Boolean; UseInclude: Boolean = False): TGroups;
function IsValidGroupsTable: Boolean;
function CreateGroupsTable: Boolean;
function AddGroup(Group: TGroup): Boolean;
procedure FreeGroup(var Group: TGroup);
procedure FreeGroups(var Groups: TGroups);
function CreateNewGroupCode: string;
function GroupNameExists(GroupName: string): Boolean;
function DeleteGroup(Group: TGroup): Boolean;
function FindGroupCodeByGroupName(GroupName: string): string;
function FindGroupNameByGroupCode(GroupCode: string): string;
function CodeGroups(Groups: TGroups): string;
function CodeGroup(Group: TGroup): string;
function CopyGroups(Groups: TGroups): TGroups;
function CreateNewGroupCodeA: string;
function GetGroupByGroupName(GroupName: string; LoadImage: Boolean): TGroup; overload;
function GetGroupByGroupCode(GroupCode: string; LoadImage: Boolean): TGroup; overload;
function CopyGroup(Group: TGroup): TGroup;
function UpdateGroup(Group: TGroup): Boolean;
procedure RemoveGroupsFromGroups(var Groups: TGroups; GroupsToRemove: TGroups);
procedure RemoveGroupFromGroups(var Groups: TGroups; Group: TGroup);
procedure AddGroupsToGroups(var Groups: TGroups; GroupsToAdd: TGroups); overload;
procedure AddGroupsToGroups(var Groups: string; GroupsToAdd: string); overload;
procedure AddGroupToGroups(var Groups: TGroups; Group: TGroup);
{$IFNDEF EXT}
function GetCommonGroups(GroupsList: TStringList): string; overload;
{$ENDIF}
function GetCommonGroups(ArGroups: TArGroups): TGroups; overload;
function CompareGroups(GroupsA, GroupsB: string): Boolean; overload;
function CompareGroups(GroupsA, GroupsB: TGroups): Boolean; overload;
procedure ReplaceGroups(GroupsToDelete, GroupsToAdd: string; var Groups: string);
function GetRegisterGroupListW(FileName: string; LoadImages: Boolean; SortByName: Boolean;
  UseInclude: Boolean = False): TGroups;
function GroupExistsInGroups(Group: TGroup; Groups: TGroups): Boolean;
procedure ReplaceGroupsW(GroupsToDelete, GroupsToAdd: TGroups; var Groups: TGroups);
function GroupWithCodeExists(GroupCode: string): Boolean;
function GroupWithCodeExistsInString(GroupCode, Groups: string): Boolean;
function IsValidGroupsTableW(FileName: string; NoCheck: Boolean = False): Boolean;
function GetGroupByGroupNameW(GroupName: string; LoadImage: Boolean; FileName: string): TGroup;
function AddGroupW(Group: TGroup; FileName: string): Boolean;
function GroupNameExistsW(GroupName: string; FileName: string): Boolean;
function CreateGroupsTableW(FileName: string): Boolean;
function GroupsTableFileNameW(FileName: string): string;
function GetNilGroup: TGroup;

//${345d-fgtr-ergd}[#Имя группы#]

implementation

uses
  CommonDBSupport, UnitDBkernel, UnitFileCheckerDB;

function FileExistsW(FileName: string): Boolean;
begin
  if FileName <> '' then
    if FileName[1] = '"' then
      FileName := Copy(FileName, 2, Length(FileName) - 2);
  Result := FileExistsSafe(FileName);
end;

function GetNilGroup: TGroup;
begin
  Result.GroupName := '';
  Result.GroupCode := '';
  Result.GroupImage := nil;
  // no reason to free other fields
end;

procedure FreeGroup(var Group: TGroup);
begin
  if Group.GroupImage <> nil then
    Group.GroupImage.Free;
end;

procedure FreeGroups(var Groups : TGroups);
var
  I : Integer;
begin
  for I := 0 to Length(Groups) - 1 do
    FreeGroup(Groups[I]);
  SetLength(Groups, 0);
end;

function RandomPwd(PWLen: Integer; StrTable: string): string;
var
  Y, I: Integer;
begin
  Randomize;
  SetLength(Result, PWLen);
  Y := Length(StrTable);
  for I := 1 to PWLen do
  begin
    Result[I] := StrTable[Random(Y) + 1];
  end;
end;

function CreateNewGroupCode: string;
const
  StrTable = Pwd_rusup + Pwd_rusdown + Pwd_englup + Pwd_engldown + Pwd_cifr;
begin
  Result := RandomPwd(4, StrTable) + '-' + RandomPwd(4, StrTable) + '-' + RandomPwd(4, StrTable);
end;

function CreateNewGroupCodeA: string;
const
  StrTable = Pwd_rusup + Pwd_rusdown + Pwd_englup + Pwd_engldown + Pwd_cifr;
begin
  Result := '${' + RandomPwd(4, StrTable) + '-' + RandomPwd(4, StrTable) + '-' + RandomPwd(4, StrTable) + '}';
end;

function CreateNewGroup(GroupName: string): string;
begin
  Result := CreateNewGroupCodeA + '[#' + GroupName + '#]'
end;

function GroupSearchByGroupName(GroupName: string): string;
begin
  if GetDBType = DB_TYPE_MDB then
    Result := '%#' + GroupName + '#%';
end;

function EncodeGroups(Groups: string): TGroups;
var
  I, J, N: Integer;
  IsGroupCode, IsGroupName: Boolean;
  S, GroupName, GroupCode: string;
begin
  SetLength(Result, 0);
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
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1].GroupName := GroupName;
        Result[Length(Result) - 1].GroupCode := GroupCode;
        Result[Length(Result) - 1].GroupImage := nil;
      end;
    end;
  end;
end;

Function CopyGroup(Group: TGroup): TGroup;
begin
  Result := Group;
  if Group.GroupImage <> nil then
  begin
    Result.GroupImage := TJpegImage.Create;
    Result.GroupImage.Assign(Group.GroupImage);
  end;
end;

Function CopyGroups(Groups: TGroups): TGroups;
var
  I: Integer;
begin
  SetLength(Result, Length(Groups));
  for I := 0 to Length(Groups) - 1 do
  begin
    Result[I] := Groups[I];
    if Groups[I].GroupImage <> nil then
    begin
      Result[I].GroupImage := TJpegImage.Create;
      Result[I].GroupImage.Assign(Groups[I].GroupImage);
    end
    else
      Result[I].GroupImage := nil;
  end;
end;

function CodeGroup(Group: TGroup): string;
begin
  Result := '${' + Group.GroupCode + '}[#' + Group.GroupName + '#]';
end;

function CodeGroups(Groups: TGroups): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(Groups) - 1 do
    Result := Result + CodeGroup(Groups[I]) // '${'+Groups[i].GroupCode+'}[#'+Groups[i].GroupName+'#]';
end;

procedure AddGroupToGroups(var Groups: TGroups; Group: TGroup);
var
  I: Integer;
  B: Boolean;
begin
  B := False;
  for I := 0 to Length(Groups) - 1 do
  begin
    if Groups[I].GroupCode = Group.GroupCode then
    begin
      B := True;
      Break;
    end;
  end;
  if not B then
  begin
    SetLength(Groups, Length(Groups) + 1);
    Groups[Length(Groups) - 1] := Group;
    if Group.GroupImage <> nil then
    begin
      Groups[Length(Groups) - 1].GroupImage := TJpegImage.Create;
      Groups[Length(Groups) - 1].GroupImage.Assign(Group.GroupImage);
    end;
  end;
end;

procedure AddGroupsToGroups(var Groups: TGroups; GroupsToAdd: TGroups);
var
  I: Integer;
begin
  for I := 0 to Length(GroupsToAdd) - 1 do
    AddGroupToGroups(Groups, GroupsToAdd[I]);
end;

procedure AddGroupsToGroups(var Groups: string; GroupsToAdd: string);
var
  GA, GB: TGroups;
begin
  GA := EnCodeGroups(Groups);
  GB := EnCodeGroups(GroupsToAdd);
  AddGroupsToGroups(GA, GB);
  Groups := CodeGroups(GA);
end;

procedure RemoveGroupFromGroups(var Groups: TGroups; Group: TGroup);
var
  I, J: Integer;
begin
  for I := 0 to Length(Groups) - 1 do
    if Groups[I].GroupCode = Group.GroupCode then
    begin
      for J := I to Length(Groups) - 2 do
        Groups[J] := Groups[J + 1];
      SetLength(Groups, Length(Groups) - 1);
      Break;
    end;
end;

procedure RemoveGroupsFromGroups(var Groups: TGroups; GroupsToRemove: TGroups);
var
  I: Integer;
begin
  for I := 0 to Length(GroupsToRemove) - 1 do
    RemoveGroupFromGroups(Groups, GroupsToRemove[I]);
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
      Query.Active := True;
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
    Query.Active := True;
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
      Query.Active := True;
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
      Query.Active := True;
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
  Query: TDataSet;
  ID: Integer;
begin
  Result := False;
  Query := GetQuery;
  try
    SetSQL(Query, 'Select * From ' + GroupsTableName + ' Where GroupCode like "' + Group.GroupCode + '"');
    try
      Query.Active := True;
    except
      Exit;
    end;
    if Query.RecordCount = 0 then
      Exit;

    Query.First;
    ID := Query.FieldByName('ID').AsInteger;
    Query.Active := False;
    SetSQL(Query, 'Update ' + GroupsTableName + ' Set GroupName=' + NormalizeDBString(Group.GroupName) +
        ', GroupAccess=:GroupAccess, GroupImage=:GroupImage, GroupComment=' + NormalizeDBString(Group.GroupComment)
        + ', GroupFaces=' + NormalizeDBString(Group.GroupFaces) +
        ', GroupDate = :GroupDate, GroupAddKW=:GroupAddKW, GroupKW=' + NormalizeDBString(Group.GroupKeyWords)
        + ', RelatedGroups = ' + NormalizeDBString(Group.RelatedGroups) +
        ', IncludeInQuickList = :IncludeInQuickList Where ID=' + IntToStr(ID));
    SetIntParam(Query, 0, Group.GroupAccess);
    AssignParam(Query, 1, Group.GroupImage);
    if Group.GroupDate = 0 then
      SetDateParam(Query, 'GroupDate', Now)
    else
      SetDateParam(Query, 'GroupDate', Group.GroupDate);
    SetBoolParam(Query, 3, Group.AutoAddKeyWords);
    SetBoolParam(Query, 4, Group.IncludeInQuickList);
    ExecSQL(Query);
  finally
    FreeDS(Query);
  end;
  Result := True;
end;

function AddGroupW(Group: TGroup; FileName: string): Boolean;
var
  Query: TDataSet;
  Bit: TBitmap;
begin
  Result := False;
  if not IsValidGroupsTableW(FileName, True) then
    CreateGroupsTableW(FileName);
  if GroupNameExistsW(Group.GroupName, FileName) then
    Exit;

  Query := GetQuery(FileName);
  try
    SetSQL(Query, 'Select * From ' + GroupsTableName(FileName) + ' Where GroupCode like "' + Group.GroupCode + '"');
    try
      Query.Active := True;
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
          DrawIconEx(Bit.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 16, 16, 0, 0, DI_NORMAL);
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

function GroupsTableFileNameW(FileName: string): string;
begin
  if GetDBType(FileName) = DB_TYPE_MDB then
    Result := FileName;
end;

function GroupsTableName(FileName: string): string;
begin
  if FileName <> '' then
    if (FileName[1] = FileName[Length(FileName)]) then
      if FileName[1] = '"' then
        FileName := Copy(FileName, 2, Length(FileName) - 2);
  if GetDBType(FileName) = DB_TYPE_MDB then
    Result := 'Groups';
end;

function GroupsTableName: string;
begin
  if GetDBType = DB_TYPE_MDB then
    Result := 'Groups';
end;

function IsValidGroupsTableW(FileName: string; NoCheck: Boolean = False): Boolean;
var
  Table: TDataSet;
  Query: TDataSet;
  CheckResult: Integer;
begin
  CheckResult := FileCheckedDB.CheckFile(GroupsTableFileNameW(FileName));
  if (CheckResult = CHECK_RESULT_OK) and not NoCheck then
  begin
    Result := True;
    FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(FileName));
    Exit;
  end;

  Result:= False;
  if (CheckResult = CHECK_RESULT_FILE_NOE_EXISTS) and (GetDBType <> DB_TYPE_MDB) then
    Exit;
  Table := GetTable(FileName, DB_TABLE_GROUPS);
  if Table = nil then
    Exit;

  try
    try
      Table.Active := True;
    except
      FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(FileName));
      Exit;
    end;
    Table.First;
    try
      Table.FieldByName('GroupCode').AsString;
      Table.FieldByName('GroupName').AsString;
      Table.FieldByName('GroupImage').AsString;
      Table.FieldByName('GroupComment').AsString;
      Table.FieldByName('GroupDate').AsDateTime;
      Table.FieldByName('GroupFaces').AsString;
      Table.FieldByName('GroupAccess').AsInteger;

      if Table.FindField('GroupKW') = nil then
      begin
        Table.Active := False;
        Query := GetQuery(FileName);
        try
          SetSQL(Query, 'ALTER TABLE ' + FileName + ' ADD GroupKW BLOB(240,1)');
          ExecSQL(Query);
        finally
          FreeDS(Query);
        end;
        Table.Active := True;
      end;
      Table.FieldByName('GroupKW').AsString;
      if Table.FindField('GroupAddKW') = nil then
      begin
        Table.Active := False;
        Query := GetQuery(FileName);
        try
          SetSQL(Query, 'ALTER TABLE ' + FileName + ' ADD GroupAddKW BOOLEAN');
          ExecSQL(Query);
        finally
          FreeDS(Query);
        end;
        Table.Active := True;
      end;
      Table.FieldByName('GroupAddKW').AsBoolean;
      // Included in PhotoDB v1.9
      if Table.FindField('RelatedGroups') = nil then
      begin
        Table.Active := False;
        Query := GetQuery(FileName);
        try
          SetSQL(Query, 'ALTER TABLE ' + FileName + ' ADD RelatedGroups BLOB(240,1)');
          ExecSQL(Query);
        finally
          FreeDS(Query);
        end;
        Table.Active := True;
      end;
      Table.FieldByName('RelatedGroups').AsString;
      if Table.FindField('IncludeInQuickList') = nil then
      begin
        Table.Active := False;
        Query := GetQuery(FileName);
        try
          SetSQL(Query, 'ALTER TABLE ' + FileName + ' ADD IncludeInQuickList BOOLEAN');
          ExecSQL(Query);
        finally
          FreeDS(Query);
        end;
        Query := GetQuery(FileName);
        try
          SetSQL(Query, 'UPDATE ' + FileName + ' SET IncludeInQuickList = TRUE');
          ExecSQL(Query);
        finally
          FreeDS(Query);
        end;
        Table.Active := True;
      end;
      Table.FieldByName('IncludeInQuickList').AsBoolean;
    except
      Exit;
    end;
  finally
    FreeDS(Table);
  end;
  Result := True;
end;

function IsValidGroupsTable: Boolean;
begin
  Result := True;
  Exit; // TODO:!!!
  Result := IsValidGroupsTableW(Dbname);
end;

function CreateGroupsTableW(FileName: string): Boolean;
begin
  Result := False;
  if GetDBType(FileName) = DB_TYPE_MDB then
    Result := ADOCreateGroupsTable(FileName);
end;

function CreateGroupsTable: Boolean;
begin
  Result := CreateGroupsTableW(GroupsTableFileNameW(Dbname))
end;

Function GetGroupByGroupCode(GroupCode : String; LoadImage : Boolean) : TGroup;
var
  Query : TDataSet;
  BS : TStream;
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
      Query.Active := True;
    except
      Result := GetNilGroup;
      Exit;
    end;
    Query.First;
    Result.GroupName := Query.FieldByName('GroupName').AsString;
    Result.GroupCode := Query.FieldByName('GroupCode').AsString;
    Result.GroupImage := nil;
    if LoadImage then
    begin
      if TBlobField(Query.FieldByName('GroupImage')) <> nil then
      begin
        BS := GetBlobStream(Query.FieldByName('GroupImage'), bmRead);
        try
          Result.GroupImage := TJpegImage.Create;
          if Bs.Size <> 0 then
            Result.GroupImage.LoadfromStream(Bs);

        finally
          F(BS);
        end;
      end;
    end;
    Result.GroupComment := Query.FieldByName('GroupComment').AsString;
    Result.GroupDate := Query.FieldByName('GroupDate').AsDateTime;
    Result.GroupFaces := Query.FieldByName('GroupFaces').AsString;
    Result.GroupAccess := Query.FieldByName('GroupAccess').AsInteger;
    Result.GroupKeyWords := Query.FieldByName('GroupKW').AsString;
    Result.AutoAddKeyWords := Query.FieldByName('GroupAddKW').AsBoolean;
    Result.RelatedGroups := Query.FieldByName('RelatedGroups').AsString;
    Result.IncludeInQuickList := Query.FieldByName('IncludeInQuickList').AsBoolean;

    Query.Close;
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
  BS: TStream;
begin
  Query := GetQuery(FileName);
  try
    if LoadImage then
      SetSQL(Query, 'Select * From ' + GroupsTableName(FileName) + ' Where GroupName like "' + GroupName + '"')
    else
      SetSQL(Query,
        'Select GroupCode,GroupName,GroupDate,GroupComment,GroupAccess,GroupFaces,GroupKW,GroupAddKW, RelatedGroups, IncludeInQuickList From ' + GroupsTableName(FileName) + ' Where GroupName like "' + GroupName + '"');
    try
      Query.Active := True;
    except
      Result := GetNilGroup;
      Exit;
    end;
    Query.First;
    Result.GroupName := Query.FieldByName('GroupName').AsString;
    Result.GroupCode := Query.FieldByName('GroupCode').AsString;
    Result.GroupImage := nil;
    if LoadImage then
    begin
      if TBlobField(Query.FieldByName('GroupImage')) <> nil then
      begin
        Bs := GetBlobStream(Query.FieldByName('GroupImage'), bmRead);
        try
          Result.GroupImage := TJpegImage.Create;
          Result.GroupImage.LoadfromStream(BS);
        finally
          F(BS);
        end;
      end;
    end;
    Result.GroupComment := Query.FieldByName('GroupComment').AsString;
    Result.GroupDate := Query.FieldByName('GroupDate').AsDateTime;
    Result.GroupFaces := Query.FieldByName('GroupFaces').AsString;
    Result.GroupAccess := Query.FieldByName('GroupAccess').AsInteger;
    Result.GroupKeyWords := Query.FieldByName('GroupKW').AsString;
    Result.AutoAddKeyWords := Query.FieldByName('GroupAddKW').AsBoolean;
    Result.RelatedGroups := Query.FieldByName('RelatedGroups').AsString;
    Result.IncludeInQuickList := Query.FieldByName('IncludeInQuickList').AsBoolean;
  finally
    FreeDS(Query);
  end;
end;

function GetRegisterGroupListW(FileName : String; LoadImages : Boolean; SortByName : Boolean; UseInclude : Boolean = false) : TGroups;
var
  Table : TDataSet;
  N: Integer;
  BS: TStream;
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
      Table.Active := True;
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
        Result[N].GroupName := Table.FieldByName('GroupName').AsString;
        Result[N].GroupCode := Table.FieldByName('GroupCode').AsString;
        Result[N].GroupImage := nil;
        if LoadImages then
        begin
          if TBlobField(Table.FieldByName('GroupImage')) <> nil then
          begin
            BS := GetBlobStream(Table.FieldByName('GroupImage'), Bmread);
            try
              Result[N].GroupImage := TJpegImage.Create;
              Result[N].GroupImage.LoadfromStream(BS);
            finally
              F(BS);
            end;
          end;
        end;
        Result[N].GroupComment := Table.FieldByName('GroupComment').AsString;
        Result[N].GroupDate := Table.FieldByName('GroupDate').AsDateTime;
        Result[N].GroupFaces := Table.FieldByName('GroupFaces').AsString;
        Result[N].GroupAccess := Table.FieldByName('GroupAccess').AsInteger;
        Result[N].GroupKeyWords := Table.FieldByName('GroupKW').AsString;
        Result[N].AutoAddKeyWords := Table.FieldByName('GroupAddKW').AsBoolean;
        Result[N].RelatedGroups := Table.FieldByName('RelatedGroups').AsString;
        Result[N].IncludeInQuickList := Table.FieldByName('IncludeInQuickList').AsBoolean;
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

function GroupExistsInGroups(Group: TGroup; Groups: TGroups): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Groups) - 1 do
    if Groups[I].GroupCode = Group.GroupCode then
    begin
      Result := True;
      Break;
    end;
end;

{$IFNDEF EXT}

function GetCommonGroups(GroupsList: TStringList): string;
var
  I: Integer;
  FArGroups: TArGroups;
  Res: TGroups;
begin
  Result := '';
  SetLength(Res, 0);
  if GroupsList.Count = 0 then
    Exit;
  SetLength(FArGroups, GroupsList.Count);
  for I := 0 to GroupsList.Count - 1 do
    FArGroups[I] := EncodeGroups(GroupsList[I]);
  Res := GetCommonGroups(FArGroups);
  Result := CodeGroups(Res);
end;
{$ENDIF}

function GetCommonGroups(ArGroups: TArGroups): TGroups;
var
  I, J: Integer;
begin
  if Length(ArGroups) = 0 then
    Exit;
  Result := CopyGroups(ArGroups[0]);
  for I := 1 to Length(ArGroups) - 1 do
  begin
    if Length(ArGroups[I]) = 0 then
    begin
      SetLength(Result, 0);
      Break;
    end;
    for J := Length(Result) - 1 downto 0 do
      if not GroupExistsInGroups(Result[J], ArGroups[I]) then
        RemoveGroupFromGroups(Result, Result[J]);
    if Length(Result) = 0 then
      Exit;
  end;
end;

function CompareGroups(GroupsA, GroupsB: TGroups): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Length(GroupsA) - 1 do
  begin
    if not GroupExistsInGroups(GroupsA[I], GroupsB) then
    begin
      Result := False;
      Break;
    end;
  end;
  for I := 0 to Length(GroupsB) - 1 do
  begin
    if not GroupExistsInGroups(GroupsB[I], GroupsA) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function CompareGroups(GroupsA, GroupsB: string): Boolean;
var
  GA, GB: TGroups;
begin
  GA := EncodeGroups(GroupsA);
  GB := EncodeGroups(GroupsB);
  Result := CompareGroups(GA, GB);
end;

procedure ReplaceGroupsW(GroupsToDelete, GroupsToAdd: TGroups; var Groups: TGroups);
begin
  RemoveGroupsFromGroups(Groups, GroupsToDelete);
  AddGroupsToGroups(Groups, GroupsToAdd);
end;

procedure ReplaceGroups(GroupsToDelete, GroupsToAdd: string; var Groups: string);
var
  GA, GB, GR: TGroups;
begin
  GA := EncodeGroups(GroupsToDelete);
  GB := EncodeGroups(GroupsToAdd);
  GR := EncodeGroups(Groups);
  RemoveGroupsFromGroups(GR, GA);
  AddGroupsToGroups(GR, GB);
  Groups := CodeGroups(GR);
end;

function GroupWithCodeExistsInString(GroupCode, Groups: string): Boolean;
var
  AGroups: TGroups;
  I: Integer;
begin
  Result := False;
  AGroups := EncodeGroups(Groups);
  for I := 0 to Length(AGroups) - 1 do
    if AGroups[I].GroupCode = GroupCode then
    begin
      Result := True;
      Break;
    end;
end;

end.
