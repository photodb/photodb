unit uGroupTypes;

interface

uses
  Generics.Collections,
  System.Classes,
  Vcl.Imaging.Jpeg,

  uMemory,
  uDBEntities,
  uConstants;

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

//${345d-fgtr-ergd}[#Group name#]
function CreateNewGroupCode: string;
function CreateNewGroupCodeA: string;
function CreateNewGroup(GroupName: string): string;
function EncodeGroups(Groups: string): TGroups;

function CodeGroups(Groups: TGroups): string;
function CodeGroup(Group: TGroup): string;

function CopyGroups(Groups: TGroups): TGroups;

procedure RemoveGroupsFromGroups(var Groups: TGroups; GroupsToRemove: TGroups);
procedure RemoveGroupFromGroups(var Groups: TGroups; Group: TGroup);
procedure AddGroupsToGroups(var Groups: TGroups; GroupsToAdd: TGroups); overload;
procedure AddGroupsToGroups(var Groups: string; GroupsToAdd: string); overload;
procedure AddGroupToGroups(Groups: TGroups; Group: TGroup);

function GetCommonGroups(GroupsList: TStringList): string; overload;
function GetCommonGroups(ArGroups: TList<TGroups>): TGroups; overload;
function CompareGroups(GroupsA, GroupsB: string): Boolean; overload;
function CompareGroups(GroupsA, GroupsB: TGroups): Boolean; overload;
procedure ReplaceGroups(GroupsToDelete, GroupsToAdd: string; var Groups: string);
function GroupExistsInGroups(Group: TGroup; Groups: TGroups): Boolean;
procedure ReplaceGroupsW(GroupsToDelete, GroupsToAdd: TGroups; var Groups: TGroups);
function GroupWithCodeExistsInString(GroupCode, Groups: string): Boolean;

implementation

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

function GroupExistsInGroups(Group: TGroup; Groups: TGroups): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Groups.Count - 1 do
    if Groups[I].GroupCode = Group.GroupCode then
    begin
      Result := True;
      Break;
    end;
end;

function EncodeGroups(Groups: string): TGroups;
var
  I, J, N: Integer;
  IsGroupCode, IsGroupName: Boolean;
  S, GroupName, GroupCode: string;
  Group: TGroup;
begin
  Result := TGroups.Create;
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
        Result.Add(Group);
      end;
    end;
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
  for I := 0 to Groups.Count - 1 do
    Result := Result + CodeGroup(Groups[I]) // '${'+Groups[i].GroupCode+'}[#'+Groups[i].GroupName+'#]';
end;

procedure AddGroupToGroups(Groups: TGroups; Group: TGroup);
var
  I: Integer;
begin
  for I := 0 to Groups.Count - 1 do
    if Groups[I].GroupCode = Group.GroupCode then
      Exit;

  Groups.Add(Group.Clone);
end;

procedure AddGroupsToGroups(var Groups: TGroups; GroupsToAdd: TGroups);
var
  I: Integer;
begin
  for I := 0 to GroupsToAdd.Count - 1 do
    AddGroupToGroups(Groups, GroupsToAdd[I]);
end;

procedure AddGroupsToGroups(var Groups: string; GroupsToAdd: string);
var
  GA, GB: TGroups;
begin
  GA := EnCodeGroups(Groups);
  GB := EnCodeGroups(GroupsToAdd);
  try
    AddGroupsToGroups(GA, GB);
    Groups := CodeGroups(GA);
  finally
    F(GA);
    F(GB);
  end;
end;

procedure RemoveGroupFromGroups(var Groups: TGroups; Group: TGroup);
var
  I: Integer;
begin
  for I := Groups.Count - 1 downto 0  do
    if Groups[I].GroupCode = Group.GroupCode then
      Groups.DeleteGroupAt(I);
end;

procedure RemoveGroupsFromGroups(var Groups: TGroups; GroupsToRemove: TGroups);
var
  I: Integer;
begin
  for I := GroupsToRemove.Count - 1 downto 0 do
    RemoveGroupFromGroups(Groups, GroupsToRemove[I]);
end;

function GetCommonGroups(GroupsList: TStringList): string;
var
  I: Integer;
  FArGroups: TList<TGroups>;
  Res: TGroups;
begin
  Result := '';

  if GroupsList.Count = 0 then
    Exit;

  FArGroups := TList<TGroups>.Create;
  try
    for I := 0 to GroupsList.Count - 1 do
      FArGroups.Add(EncodeGroups(GroupsList[I]));

    Res := GetCommonGroups(FArGroups);
    try
      Result := CodeGroups(Res);
    finally
      F(Res);
    end;
  finally
    FreeList(FArGroups);
  end;
end;

function CopyGroups(Groups: TGroups): TGroups;
var
  Group: TGroup;
begin
  Result := TGroups.Create;
  for Group in Groups do
    Result.Add(Group.Clone);
end;

function GetCommonGroups(ArGroups: TList<TGroups>): TGroups;
var
  I, J: Integer;
begin
  if ArGroups.Count = 0 then
    Exit;

  Result := CopyGroups(ArGroups[0]);
  for I := 1 to ArGroups.Count - 1 do
  begin
    if ArGroups[I].Count = 0 then
    begin
      FreeList(Result, False);
      Break;
    end;

    for J := Result.Count - 1 downto 0 do
      if not GroupExistsInGroups(Result[J], ArGroups[I]) then
        RemoveGroupFromGroups(Result, Result[J]);

    if Result.Count = 0 then
      Exit;
  end;
end;

function CompareGroups(GroupsA, GroupsB: TGroups): Boolean;
var
  I: Integer;
begin
  Result := GroupsA.Count = GroupsB.Count;
  if Result then
    for I := 0 to GroupsA.Count - 1 do
      if not GroupExistsInGroups(GroupsA[I], GroupsB) then
        Exit(False);
end;

function CompareGroups(GroupsA, GroupsB: string): Boolean;
var
  GA, GB: TGroups;
begin
  GA := EncodeGroups(GroupsA);
  GB := EncodeGroups(GroupsB);
  try
    Result := CompareGroups(GA, GB);
  finally
    F(GA);
    F(GB);
  end;
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
  try
    RemoveGroupsFromGroups(GR, GA);
    AddGroupsToGroups(GR, GB);
    Groups := CodeGroups(GR);
  finally
    F(GA);
    F(GB);
    F(GR);
  end;
end;

function GroupWithCodeExistsInString(GroupCode, Groups: string): Boolean;
var
  AGroups: TGroups;
  I: Integer;
begin
  Result := False;
  AGroups := EncodeGroups(Groups);
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

end.
