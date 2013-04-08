unit uGroupsRepository;

interface

uses
  Generics.Defaults,
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,

  Dmitry.Utils.System,
  
  uConstants,
  uMemory,
  uDBEntities,
  uDBContext,
  uDBClasses;

type
  TGroupsRepository = class(TBaseRepository<TGroup>, IGroupsRepository)
  public
    function Add(Group: TGroup): Boolean;
    function Delete(Group: TGroup): Boolean;
    function FindCodeByName(GroupName: string): string;
    function FindNameByCode(GroupCode: string): string;
    function GetByCode(GroupCode: string; LoadImage: Boolean): TGroup;
    function GetByName(GroupName: string; LoadImage: Boolean): TGroup;
    function Update(Group: TGroup): Boolean;
    function GetAll(LoadImages: Boolean; SortByName: Boolean; UseInclude: Boolean = False): TGroups;
    function HasGroupWithCode(GroupCode: string): Boolean;
    function HasGroupWithName(GroupName: string): Boolean;
  end;

implementation

{ TGroupsRepository }

function TGroupsRepository.Add(Group: TGroup): Boolean;
var
  IC: TInsertCommand;
begin
  Result := False;

  if HasGroupWithName(Group.GroupName) or HasGroupWithCode(Group.GroupCode) then
    Exit;  

  IC := Context.CreateInsert(GroupsTableName);
  try
    IC.AddParameter(TStringParameter.Create('GroupCode', Group.GroupCode));   
    IC.AddParameter(TStringParameter.Create('GroupName', Group.GroupName));    
    IC.AddParameter(TStringParameter.Create('GroupComment', Group.GroupComment));  
    IC.AddParameter(TStringParameter.Create('GroupKW', Group.GroupKeyWords));
    IC.AddParameter(TBooleanParameter.Create('GroupAddKW', Group.AutoAddKeyWords));     
    IC.AddParameter(TDateTimeParameter.Create('GroupDate', IIF(Group.GroupDate = 0, Now, Group.GroupDate))); 
    IC.AddParameter(TStringParameter.Create('GroupFaces', Group.GroupFaces));          
    IC.AddParameter(TStringParameter.Create('RelatedGroups', Group.RelatedGroups));   
    IC.AddParameter(TBooleanParameter.Create('IncludeInQuickList', Group.IncludeInQuickList)); 
    IC.AddParameter(TIntegerParameter.Create('GroupAccess', Group.GroupAccess));   
  
    IC.AddParameter(TJpegParameter.Create('GroupImage', Group.GroupImage));
  
    Result := IC.Execute > 0;
  finally
    F(IC);
  end;
end;

function TGroupsRepository.Delete(Group: TGroup): Boolean;
var
  DC: TDeleteCommand;
begin
  DC := Context.CreateDelete(GroupsTableName);
  try
    DC.AddWhereParameter(TStringParameter.Create('GroupCode', Group.GroupCode, paLike));
    DC.Execute;

    Result := True;
  finally
    F(DC);
  end;
end;

function TGroupsRepository.FindNameByCode(GroupCode: string): string;
var
  SC: TSelectCommand;
begin
  Result := '';
  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TStringParameter.Create('GroupName'));
    SC.AddWhereParameter(TStringParameter.Create('GroupCode', GroupCode));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('GroupName').AsString;
  finally
    F(SC);
  end;
end;

function TGroupsRepository.FindCodeByName(GroupName: string): string;
var
  SC: TSelectCommand;
begin
  Result := '';
  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TStringParameter.Create('GroupCode'));
    SC.AddWhereParameter(TStringParameter.Create('GroupName', GroupName, paLike));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('GroupCode').AsString;
  finally
    F(SC);
  end;
end;

function TGroupsRepository.GetAll(LoadImages, SortByName, UseInclude: Boolean): TGroups;
var
  SC: TSelectCommand;
  Group: TGroup;
begin
  Result := TGroups.Create;
  
  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TCustomConditionParameter.Create('1 = 1'));
    if UseInclude then
      SC.AddWhereParameter(TBooleanParameter.Create('IncludeInQuickList', True));
  
    if SC.Execute > 0 then
    begin
      SC.DS.First;
      repeat
        Group := TGroup.Create;
        Group.ReadFromDS(SC.DS);
        Result.Add(Group);
        SC.DS.Next;
      until SC.DS.Eof;
    end;
                  
  finally
    F(SC);
  end;
  
  if SortByName then
    Result.Sort(TComparer<TGroup>.Construct(
             function (const L, R: TGroup): Integer
             begin
               Result := AnsiCompareStr(L.GroupName, R.GroupName);
             end
          ));
end;

function TGroupsRepository.GetByCode(GroupCode: string; LoadImage: Boolean): TGroup;
var
  SC: TSelectCommand;
begin
  Result := nil;

  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TStringParameter.Create('ID'));
    SC.AddParameter(TStringParameter.Create('GroupCode'));
    SC.AddParameter(TStringParameter.Create('GroupName'));
    SC.AddParameter(TDateTimeParameter.Create('GroupDate'));
    SC.AddParameter(TStringParameter.Create('GroupComment'));
    SC.AddParameter(TIntegerParameter.Create('GroupAccess'));
    SC.AddParameter(TStringParameter.Create('GroupFaces'));
    SC.AddParameter(TStringParameter.Create('GroupKW'));
    SC.AddParameter(TBooleanParameter.Create('GroupAddKW', False));
    SC.AddParameter(TStringParameter.Create('RelatedGroups'));
    SC.AddParameter(TBooleanParameter.Create('IncludeInQuickList', False));
    if LoadImage then
      SC.AddParameter(TCustomFieldParameter.Create('[GroupImage]'));

    SC.AddWhereParameter(TStringParameter.Create('GroupCode', GroupCode, paLike));

    if SC.Execute > 0 then
    begin  
      Result := TGroup.Create;
      Result.ReadFromDS(SC.DS);
    end;
  finally
    F(SC);
  end;
end;

function TGroupsRepository.GetByName(GroupName: string; LoadImage: Boolean): TGroup;
var
  SC: TSelectCommand;
begin
  Result := nil;

  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TStringParameter.Create('ID'));
    SC.AddParameter(TStringParameter.Create('GroupCode'));
    SC.AddParameter(TStringParameter.Create('GroupName'));
    SC.AddParameter(TDateTimeParameter.Create('GroupDate'));
    SC.AddParameter(TStringParameter.Create('GroupComment'));
    SC.AddParameter(TIntegerParameter.Create('GroupAccess'));
    SC.AddParameter(TStringParameter.Create('GroupFaces'));
    SC.AddParameter(TStringParameter.Create('GroupKW'));
    SC.AddParameter(TBooleanParameter.Create('GroupAddKW', False));
    SC.AddParameter(TStringParameter.Create('RelatedGroups'));
    SC.AddParameter(TBooleanParameter.Create('IncludeInQuickList', False));
    if LoadImage then
      SC.AddParameter(TCustomFieldParameter.Create('[GroupImage]'));
         
    SC.AddWhereParameter(TStringParameter.Create('GroupName', GroupName, paLike));

    if SC.Execute > 0 then
    begin  
      Result := TGroup.Create;
      Result.ReadFromDS(SC.DS);
    end;
  finally
    F(SC);
  end;
end;

function TGroupsRepository.HasGroupWithCode(GroupCode: string): Boolean;
var
  SC: TSelectCommand;
begin
  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TCustomFieldParameter.Create('1'));
    SC.AddWhereParameter(TStringParameter.Create('GroupCode', GroupCode));

    Result := SC.Execute > 0;
  finally
    F(SC);
  end;
end;

function TGroupsRepository.HasGroupWithName(GroupName: string): Boolean;
var
  SC: TSelectCommand;
begin
  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TCustomFieldParameter.Create('1'));
    SC.AddWhereParameter(TStringParameter.Create('GroupName', GroupName, paLike));

    Result := SC.Execute > 0;
  finally
    F(SC);
  end;
end;

function TGroupsRepository.Update(Group: TGroup): Boolean;
var
  SC: TSelectCommand;
  UC: TUpdateCommand;
  GroupDate: TDateTime;
begin
  Result := False;
  SC := Context.CreateSelect(GroupsTableName);
  try
    SC.AddParameter(TCustomFieldParameter.Create('[ID]'));
    SC.AddWhereParameter(TStringParameter.Create('GroupCode', Group.GroupCode));
    try
      SC.Execute;
    except
      Exit;
    end;
    if SC.RecordCount > 0 then
    begin

      UC := Context.CreateUpdate(GroupsTableName);
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
        UC.AddWhereParameter(TIntegerParameter.Create('ID', SC.DS.FindField('ID').AsInteger));

        UC.Execute;
        Result := True;
      finally
        F(UC);
      end;
    end;
  finally
    F(SC);
  end;
end;

end.
