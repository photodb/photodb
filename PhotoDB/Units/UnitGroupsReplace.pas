unit UnitGroupsReplace;

interface

uses UnitGroupsWork, Forms, SysUtils, Dialogs, Windows, Dolphin_DB,
      uVistaFuncs;

Procedure FilterGroups(var Groups : TGroups; var OutRegGroups, InRegGroups : TGroups; var Actions : TGroupsActionsW);
Procedure FilterGroupsW(var Groups : TGroups; var OutRegGroups, InRegGroups : TGroups; var Actions : TGroupsActionsW; FileName : String);

implementation

uses UnitGroupReplace, Language;

Procedure AddGroupsAction(var Actions : TGroupsActions; Action : TGroupAction);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(Actions)-1 do
 if Actions[i].OutGroup.GroupCode=Action.OutGroup.GroupCode then
 begin
  b:=True;
  break;
 end;
 if not b then
 begin
  SetLength(Actions,length(Actions)+1);
  Actions[length(Actions)-1]:=Action;
 end;
end;

Function ExistsActionForGroup(Actions : TGroupsActions; Group : TGroup) : boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to length(Actions)-1 do
 if Actions[i].OutGroup.GroupCode=Group.GroupCode then
 begin
  Result:=True;
  Break;
 end;
end;

Function GetGroupAction(Actions : TGroupsActions; Group : TGroup) : TGroupAction;
var
  i : integer;
begin
 for i:=0 to length(Actions)-1 do
 if Actions[i].OutGroup.GroupCode=Group.GroupCode then
 begin
  Result:=Actions[i];
  Break;
 end;
end;

Procedure FilterGroups(var Groups : TGroups; var OutRegGroups, InRegGroups : TGroups; var Actions : TGroupsActionsW);
begin
 FilterGroupsW(Groups, OutRegGroups, InRegGroups, Actions, dbname);
end;

Procedure FilterGroupsW(var Groups : TGroups; var OutRegGroups, InRegGroups : TGroups; var Actions : TGroupsActionsW; FileName : String);
var
  i : integer;
  pi : PInteger;
  Action : TGroupAction;
  TempGroups, Temp : TGroups;
  GrNameIn, GrNameOut : String;
  Options : GroupReplaceOptions;
  
  function GroupExistsIn(GroupCode : String) : String;
  var
    j : integer;
  begin
   Result:='';
   for j:=0 to length(InRegGroups)-1 do
   if InRegGroups[j].GroupCode=GroupCode then
   begin
    Result:=InRegGroups[j].GroupName;
    Break;
   end;
  end;

  function GroupByNameIn(GroupName : String) :TGroup;
  var
    j : integer;
  begin
   for j:=0 to length(InRegGroups)-1 do
   if InRegGroups[j].GroupName=GroupName then
   begin
    Result:=InRegGroups[j];
    Break;
   end;
  end;

  function GroupExistsInByNameByCode(GroupCode : String) : boolean;
  var
    j : integer;
  begin
   Result:=False;
   for j:=0 to length(InRegGroups)-1 do
   if InRegGroups[j].GroupCode=GroupCode then
   begin
    Result:=True;
    Break;
   end;
  end;

  function GroupExistsOut(GroupCode : String) : String;
  var
    j : integer;
  begin
   Result:='';
   for j:=0 to length(OutRegGroups)-1 do
   if OutRegGroups[j].GroupCode=GroupCode then
   begin
    Result:=OutRegGroups[j].GroupName;
    Break;
   end;
  end;

  function GroupByNameOut(GroupName : String; Default :TGroup) :TGroup;
  var
    j : integer;
  begin
   Result:=Default;
   for j:=0 to length(OutRegGroups)-1 do
   if OutRegGroups[j].GroupName=GroupName then
   begin
    Result:=OutRegGroups[j];
    exit;
   end;
  end;

begin

 pi:=@i;
 for i:=0 to length(Groups)-1 do
 begin
  if length(Groups)<=i then Break;
  if not ExistsActionForGroup(Actions.Actions,Groups[i]) then
  begin
   GrNameIn:=GroupExistsIn(Groups[i].GroupCode);
   GrNameOut:=GroupExistsOut(Groups[i].GroupCode);
   if ((GrNameIn<>'') or GroupExistsInByNameByCode(Groups[i].GroupName)) then
   Options.AllowAdd:=false else
   begin
    if GrNameOut<>'' then
    Options.AllowAdd:=true else Options.AllowAdd:=false;
   end;
   Options.MaxAuto:=Actions.MaxAuto;
   Options.AllowAdd:=true;
   If GrNameOut='' then
   begin
    GroupReplaceNotExists(Groups[i],Action,Options,FileName);
   end else
   begin
    GroupReplaceExists(GroupByNameOut(Groups[i].GroupName,Groups[i]),Action,Options,FileName);
   end;
   If Action.Action<>GROUP_ACTION_ADD then
   AddGroupsAction(Actions.Actions,Action);

    If Action.Action=GROUP_ACTION_ADD_IN_EXISTS then
    begin
     SetLength(TempGroups,1);
     TempGroups[0]:=Action.InGroup;
     SetLength(Temp,1);
     Temp[0]:=Action.OutGroup;
     ReplaceGroupsW(Temp,TempGroups,Groups);
    end;
    If Action.Action=GROUP_ACTION_ADD_IN_NEW then
    begin
     SetLength(TempGroups,1);
     TempGroups[0]:=Action.InGroup;
     SetLength(Temp,1);
     Temp[0]:=Action.OutGroup;
     ReplaceGroupsW(Temp,TempGroups,Groups);
    end;             
    If Action.Action=GROUP_ACTION_NO_ADD then
    begin
     RemoveGroupFromGroups(Groups,Action.InGroup);
     pi^:=i-1;
    end;
    If Action.Action=GROUP_ACTION_ADD then
    begin
     //if AddGroupW(Groups[i],FileName) then
     if AddGroupW(GroupByNameOut(Groups[i].GroupName,Groups[i]),FileName) then
     begin
      SetLength(TempGroups,1);
      TempGroups[0]:=Action.InGroup;
      SetLength(Temp,1);
      Temp[0]:=Action.OutGroup;
      ReplaceGroupsW(Groups,Temp,TempGroups);
      Action.InGroup:=GetGroupByGroupNameW(Groups[i].GroupName,false,FileName);
      Action.Action:=GROUP_ACTION_ADD_IN_EXISTS;
      AddGroupsAction(Actions.Actions,Action);
      InRegGroups:=GetRegisterGroupListW(FileName,True);
     end else
     begin
      MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_ERROR_ADDING_GROUP,[Groups[i].GroupName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     end;
    end;

  end else
  begin
   Action:=GetGroupAction(Actions.Actions,Groups[i]);
   If Action.Action=GROUP_ACTION_ADD_IN_EXISTS then
   begin
    SetLength(TempGroups,1);
    TempGroups[0]:=Action.InGroup;
    SetLength(Temp,1);
    Temp[0]:=Action.OutGroup;
    ReplaceGroupsW(Temp,TempGroups,Groups);
   end;
   If Action.Action=GROUP_ACTION_ADD_IN_NEW then
   begin
    SetLength(TempGroups,1);
    TempGroups[0]:=Action.InGroup;
    SetLength(Temp,1);
    Temp[0]:=Action.OutGroup;
    ReplaceGroupsW(Temp,TempGroups,Groups);
   end;
   If Action.Action=GROUP_ACTION_NO_ADD then
   begin
    RemoveGroupFromGroups(Groups,Action.InGroup);
    pi^:=i-1;
   end;
  end;
 end;
end;

end.
