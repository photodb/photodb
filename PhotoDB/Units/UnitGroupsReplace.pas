unit UnitGroupsReplace;

interface

uses UnitGroupsWork, Forms, SysUtils, Dialogs, Windows, UnitDBKernel,
  uTranslate, uVistaFuncs, uShellIntegration, Dolphin_DB, CommonDBSupport;

procedure FilterGroups(var Groups: TGroups; var OutRegGroups, InRegGroups: TGroups; var Actions: TGroupsActionsW);
procedure FilterGroupsW(var Groups: TGroups; var OutRegGroups, InRegGroups: TGroups; var Actions: TGroupsActionsW;
  FileName: string);

implementation

uses UnitGroupReplace;

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

procedure FilterGroups(var Groups: TGroups; var OutRegGroups, InRegGroups: TGroups; var Actions: TGroupsActionsW);
begin
  FilterGroupsW(Groups, OutRegGroups, InRegGroups, Actions, dbname);
end;

procedure FilterGroupsW(var Groups: TGroups; var OutRegGroups, InRegGroups: TGroups; var Actions: TGroupsActionsW;
  FileName: string);
var
  I: Integer;
  Pi: PInteger;
  Action: TGroupAction;
  TempGroups, Temp: TGroups;
  GrNameIn, GrNameOut: string;
  Options: GroupReplaceOptions;

  function GroupExistsIn(GroupCode: string): string;
  var
    J: Integer;
  begin
    Result := '';
    for J := 0 to Length(InRegGroups) - 1 do
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
    for J := 0 to Length(InRegGroups) - 1 do
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
    for J := 0 to Length(InRegGroups) - 1 do
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
    for J := 0 to Length(OutRegGroups) - 1 do
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
    for J := 0 to Length(OutRegGroups) - 1 do
      if OutRegGroups[J].GroupName = GroupName then
      begin
        Result := OutRegGroups[J];
        Exit;
      end;
  end;

begin

  Pi := @I;
  for I := 0 to Length(Groups) - 1 do
  begin
    if Length(Groups) <= I then
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
        GroupReplaceNotExists(Groups[I], Action, Options, FileName)
      else
        GroupReplaceExists(GroupByNameOut(Groups[I].GroupName, Groups[I]), Action, Options, FileName);

      if Action.Action <> GROUP_ACTION_ADD then
        AddGroupsAction(Actions.Actions, Action);

      if Action.Action = GROUP_ACTION_ADD_IN_EXISTS then
      begin
        SetLength(TempGroups, 1);
        TempGroups[0] := Action.InGroup;
        SetLength(Temp, 1);
        Temp[0] := Action.OutGroup;
        ReplaceGroupsW(Temp, TempGroups, Groups);
      end;
      if Action.Action = GROUP_ACTION_ADD_IN_NEW then
      begin
        SetLength(TempGroups, 1);
        TempGroups[0] := Action.InGroup;
        SetLength(Temp, 1);
        Temp[0] := Action.OutGroup;
        ReplaceGroupsW(Temp, TempGroups, Groups);
      end;
      if Action.Action = GROUP_ACTION_NO_ADD then
      begin
        RemoveGroupFromGroups(Groups, Action.InGroup);
        Pi^ := I - 1;
      end;
      if Action.Action = GROUP_ACTION_ADD then
      begin
        if AddGroupW(GroupByNameOut(Groups[I].GroupName, Groups[I]), FileName) then
        begin
          SetLength(TempGroups, 1);
          TempGroups[0] := Action.InGroup;
          SetLength(Temp, 1);
          Temp[0] := Action.OutGroup;
          ReplaceGroupsW(Groups, Temp, TempGroups);
          Action.InGroup := GetGroupByGroupNameW(Groups[I].GroupName, False, FileName);
          Action.Action := GROUP_ACTION_ADD_IN_EXISTS;
          AddGroupsAction(Actions.Actions, Action);
          InRegGroups := GetRegisterGroupListW(FileName, True, DBKernel.SortGroupsByName);
        end else
        begin
          MessageBoxDB(GetActiveFormHandle, Format(TA('An error occurred while adding a group', 'Groups'),
              [Groups[I].GroupName]), TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        end;
      end;
    end else
    begin
      Action := GetGroupAction(Actions.Actions, Groups[I]);
      if Action.Action = GROUP_ACTION_ADD_IN_EXISTS then
      begin
        SetLength(TempGroups, 1);
        TempGroups[0] := Action.InGroup;
        SetLength(Temp, 1);
        Temp[0] := Action.OutGroup;
        ReplaceGroupsW(Temp, TempGroups, Groups);
      end;
      if Action.Action = GROUP_ACTION_ADD_IN_NEW then
      begin
        SetLength(TempGroups, 1);
        TempGroups[0] := Action.InGroup;
        SetLength(Temp, 1);
        Temp[0] := Action.OutGroup;
        ReplaceGroupsW(Temp, TempGroups, Groups);
      end;
      if Action.Action = GROUP_ACTION_NO_ADD then
      begin
        RemoveGroupFromGroups(Groups, Action.InGroup);
        Pi^ := I - 1;
      end;
    end;
  end;
end;

end.
