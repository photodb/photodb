unit UnitGroupsReplace;

interface

uses
  System.SysUtils,

  uMemory,
  uDBContext,
  uTranslate,
  uGroupTypes,
  uDBEntities,
  uConstants,
  uSettings,
  uShellIntegration;

procedure FilterGroups(DBContext: IDBContext; var Groups: TGroups; var OutRegGroups, InRegGroups: TGroups; var Actions: TGroupsActionsW);

implementation

uses
  UnitGroupReplace;

procedure AddGroupsAction(var Actions: TGroupsActions; Action: TGroupAction);
var
  I: Integer;
  B: Boolean;
begin
  B := False;
  for I := 0 to Length(Actions) - 1 do
    if Actions[I].OutGroup.GroupCode = Action.OutGroup.GroupCode then
    begin
      B := True;
      Break;
    end;
  if not B then
  begin
    SetLength(Actions, Length(Actions) + 1);
    Actions[Length(Actions) - 1] := Action;
  end;
end;

function ExistsActionForGroup(Actions: TGroupsActions; Group: TGroup): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Actions) - 1 do
    if Actions[I].OutGroup.GroupCode = Group.GroupCode then
    begin
      Result := True;
      Break;
    end;
end;

function GetGroupAction(Actions: TGroupsActions; Group: TGroup): TGroupAction;
var
  I: Integer;
begin
  for I := 0 to Length(Actions) - 1 do
    if Actions[I].OutGroup.GroupCode = Group.GroupCode then
    begin
      Result := Actions[I];
      Break;
    end;
end;

procedure FilterGroups(DBContext: IDBContext; var Groups: TGroups; var OutRegGroups, InRegGroups: TGroups; var Actions: TGroupsActionsW);
var
  I: Integer;
  PI: PInteger;
  Action: TGroupAction;
  TempGroups, Temp: TGroups;
  GrNameIn, GrNameOut: string;
  Options: GroupReplaceOptions;
  SortGroupsByName: Boolean;
  GroupsRepository: IGroupsRepository;

  function GroupExistsIn(GroupCode: string): string;
  var
    J: Integer;
  begin
    Result := '';
    for J := 0 to InRegGroups.Count - 1 do
      if InRegGroups[J].GroupCode = GroupCode then
      begin
        Result := InRegGroups[J].GroupName;
        Break;
      end;
  end;

  function GroupByNameIn(GroupName: string): TGroup;
  var
    J: Integer;
  begin
    for J := 0 to InRegGroups.Count - 1 do
      if InRegGroups[J].GroupName = GroupName then
      begin
        Result := InRegGroups[J];
        Break;
      end;
  end;

  function GroupExistsInByNameByCode(GroupCode: string): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to InRegGroups.Count - 1 do
      if InRegGroups[J].GroupCode = GroupCode then
      begin
        Result := True;
        Break;
      end;
  end;

  function GroupExistsOut(GroupCode: string): string;
  var
    J: Integer;
  begin
    Result := '';
    for J := 0 to OutRegGroups.Count - 1 do
      if OutRegGroups[J].GroupCode = GroupCode then
      begin
        Result := OutRegGroups[J].GroupName;
        Break;
      end;
  end;

  function GroupByNameOut(GroupName: string; default: TGroup): TGroup;
  var
    J: Integer;
  begin
    Result := default;
    for J := 0 to OutRegGroups.Count - 1 do
      if OutRegGroups[J].GroupName = GroupName then
      begin
        Result := OutRegGroups[J];
        Exit;
      end;
  end;

  procedure ReplaceGroup(GroupToRemove, GroupToAdd: TGroup; Groups: TGroups);
  var
    GroupsToRemove, GroupsToAdd: TGroups;
  begin
    GroupsToRemove := TGroups.Create;
    GroupsToAdd := TGroups.Create;
    try
      GroupsToRemove.Add(GroupToRemove);
      GroupsToAdd.Add(GroupToAdd);

      ReplaceGroupsW(GroupsToRemove, GroupsToAdd, Groups);
    finally
      GroupsToRemove.Clear;
      GroupsToAdd.Clear;
      F(GroupsToRemove);
      F(GroupsToAdd);
    end;
  end;

begin
  GroupsRepository := DBContext.Groups;
  SortGroupsByName := AppSettings.Readbool('Options', 'SortGroupsByName', True);

  PI := @I;
  for I := 0 to Groups.Count - 1 do
  begin
    if Groups.Count <= I then
      Break;

    if not ExistsActionForGroup(Actions.Actions, Groups[I]) then
    begin
      GrNameIn := GroupExistsIn(Groups[I].GroupCode);
      GrNameOut := GroupExistsOut(Groups[I].GroupCode);
      if ((GrNameIn <> '') or GroupExistsInByNameByCode(Groups[I].GroupName)) then
        Options.AllowAdd := False
      else
      begin
        if GrNameOut <> '' then
          Options.AllowAdd := True
        else
          Options.AllowAdd := False;
      end;
      Options.MaxAuto := Actions.MaxAuto;
      Options.AllowAdd := True;

      if GrNameOut = '' then
        GroupReplaceNotExists(DBContext, Groups[I], Action, Options)
      else
        GroupReplaceExists(DBContext, GroupByNameOut(Groups[I].GroupName, Groups[I]), Action, Options);

      if Action.Action <> GROUP_ACTION_ADD then
        AddGroupsAction(Actions.Actions, Action);

      if Action.Action = GROUP_ACTION_ADD_IN_EXISTS then
        ReplaceGroup(Action.OutGroup, Action.InGroup, Groups);

      if Action.Action = GROUP_ACTION_ADD_IN_NEW then
        ReplaceGroup(Action.OutGroup, Action.InGroup, Groups);

      if Action.Action = GROUP_ACTION_NO_ADD then
      begin
        RemoveGroupFromGroups(Groups, Action.InGroup);
        Pi^ := I - 1;
      end;

      if Action.Action = GROUP_ACTION_ADD then
      begin
        if GroupsRepository.Add(GroupByNameOut(Groups[I].GroupName, Groups[I])) then
        begin
          ReplaceGroup(Action.OutGroup, Action.InGroup, Groups);

          Action.InGroup := GroupsRepository.GetByName(Groups[I].GroupName, False);
          Action.Action := GROUP_ACTION_ADD_IN_EXISTS;
          AddGroupsAction(Actions.Actions, Action);

          F(InRegGroups);
          InRegGroups := GroupsRepository.GetAll(True, SortGroupsByName);
        end else
        begin
          MessageBoxDB(0, Format(TA('An error occurred while adding a group', 'Groups'),
              [Groups[I].GroupName]), TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        end;
      end;
    end else
    begin
      Action := GetGroupAction(Actions.Actions, Groups[I]);
      if Action.Action = GROUP_ACTION_ADD_IN_EXISTS then
        ReplaceGroup(Action.OutGroup, Action.InGroup, Groups);

      if Action.Action = GROUP_ACTION_ADD_IN_NEW then
        ReplaceGroup(Action.OutGroup, Action.InGroup, Groups);

      if Action.Action = GROUP_ACTION_NO_ADD then
      begin
        RemoveGroupFromGroups(Groups, Action.InGroup);
        Pi^ := I - 1;
      end;
    end;
  end;
end;

end.
