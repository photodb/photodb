unit uGroupTypes;

interface

uses
  Classes,
  Vcl.Imaging.Jpeg,
  uConstants;

type
  TGroup = record
    GroupID: Integer;
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

//${345d-fgtr-ergd}[#Group name#]
function CreateNewGroupCode: string;
function CreateNewGroupCodeA: string;
function CreateNewGroup(GroupName: string): string;
function EncodeGroups(Groups: string): TGroups;
procedure FreeGroup(var Group: TGroup);
procedure FreeGroups(var Groups: TGroups);
function CodeGroups(Groups: TGroups): string;
function CodeGroup(Group: TGroup): string;
function CopyGroups(Groups: TGroups): TGroups;
function CopyGroup(Group: TGroup): TGroup;
procedure RemoveGroupsFromGroups(var Groups: TGroups; GroupsToRemove: TGroups);
procedure RemoveGroupFromGroups(var Groups: TGroups; Group: TGroup);
procedure AddGroupsToGroups(var Groups: TGroups; GroupsToAdd: TGroups); overload;
procedure AddGroupsToGroups(var Groups: string; GroupsToAdd: string); overload;
procedure AddGroupToGroups(var Groups: TGroups; Group: TGroup);

function GetCommonGroups(GroupsList: TStringList): string; overload;
function GetCommonGroups(ArGroups: TArGroups): TGroups; overload;
function CompareGroups(GroupsA, GroupsB: string): Boolean; overload;
function CompareGroups(GroupsA, GroupsB: TGroups): Boolean; overload;
procedure ReplaceGroups(GroupsToDelete, GroupsToAdd: string; var Groups: string);
function GetNilGroup: TGroup;
function GroupExistsInGroups(Group: TGroup; Groups: TGroups): Boolean;
procedure ReplaceGroupsW(GroupsToDelete, GroupsToAdd: TGroups; var Groups: TGroups);
function GroupWithCodeExistsInString(GroupCode, Groups: string): Boolean;

implementation


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
  begin
    Group.GroupImage.Free;
    Group.GroupImage := nil;
  end;
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
      FreeGroup(Groups[I]);
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
