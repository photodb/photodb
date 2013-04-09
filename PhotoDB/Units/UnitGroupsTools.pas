unit UnitGroupsTools;

interface

uses
  Windows,
  SysUtils,
  Classes,
  DB,
  Forms,

  CommonDBSupport,
  ProgressActionUnit,

  uConstants,
  uMemory,
  uMemoryEx,
  uTranslate,
  uShellIntegration,
  uRuntime,
  uDBContext,
  uDBEntities;

procedure MoveGroup(Context: IDBContext; GroupToMove, IntoGroup: TGroup); overload;
procedure MoveGroup(Context: IDBContext; GroupToMove, IntoGroup: string); overload;

procedure RenameGroup(Context: IDBContext; GroupToRename, NewName: string); overload;
procedure RenameGroup(Context: IDBContext; GroupToRename: TGroup; NewName: string); overload;

procedure DeleteGroup(Context: IDBContext; GroupToDelete: TGroup); overload;
procedure DeleteGroup(Context: IDBContext; GroupToDelete: string); overload;

implementation

procedure DeleteGroup(Context: IDBContext; GroupToDelete: string);
var
  Groups: TGroups;
begin
  Groups := TGroups.CreateFromString(GroupToDelete);
  try
    if Groups.Count > 0 then
      DeleteGroup(Context, Groups[0]);
  finally
    F(Groups);
  end;
end;

procedure DeleteGroup(Context: IDBContext; GroupToDelete: TGroup);
var
  I: Integer;
  Table: TDataSet;
  Error: string;
  Groups: string;
  SGroupToDelete: string;
  ProgressWindow: TProgressActionForm;
begin
  SGroupToDelete := GroupToDelete.ToString;
  Table := GetTable(Context.CollectionFileName, DB_TABLE_IMAGES);
  try
    ProgressWindow := GetProgressWindow;
    try
      ProgressWindow.OneOperation := True;
      ProgressWindow.Show;
      try
        Table.Open;
        Table.First;
        ProgressWindow.MaxPosCurrentOperation := Table.RecordCount;
        for I := 1 to Table.RecordCount do
        begin
          ProgressWindow.XPosition := I;
          Application.ProcessMessages;
          Groups := Table.FieldByName('Groups').AsString;
          if TGroups.GroupWithCodeExistsInString(GroupToDelete.GroupCode, Groups) then
          begin
            TGroups.ReplaceGroups(SGroupToDelete, '', Groups);
            Table.Edit;
            Table.FieldByName('Groups').AsString := Groups;
            Table.Post;
          end;
          Table.Next;
        end;
        Table.Close;
      except
        on E: Exception do
        begin
          Error := E.message;
          MessageBoxDB(0, Format(TA('An error occurred during the delete group %s', 'Groups'), [Error]), TA('Error'),
            TD_BUTTON_OK, TD_ICON_ERROR)
        end;
      end;
      ProgressWindow.Close;
    finally
      R(ProgressWindow);
    end;
  finally
    FreeDS(Table);
  end;
end;

procedure RenameGroup(Context: IDBContext; GroupToRename, NewName: string);
var
  Groups: TGroups;
begin
  Groups := TGroups.CreateFromString(GroupToRename);
  try
    if Groups.Count > 0 then
      RenameGroup(Context, Groups[0], NewName);
  finally
    F(Groups);
  end;
end;

procedure RenameGroup(Context: IDBContext; GroupToRename: TGroup; NewName: string);
var
  I: Integer;
  Table: TDataSet;
  FQuery: TDataSet;
  Error: string;
  Groups: string;
  SGroupToDelete, SGroupToAdd: string;
  ProgressWindow: TProgressActionForm;
begin
  SGroupToDelete := GroupToRename.ToString;
  GroupToRename.GroupName := NewName;
  SGroupToAdd := GroupToRename.ToString;

  Table := Context.CreateQuery;
  try
    SetSQL(Table, 'Select ID, Groups from $DB$');

    ProgressWindow := GetProgressWindow;
    try
      ProgressWindow.OneOperation := True;
      ProgressWindow.Show;
      ProgressWindow.CanClosedByUser := False;
      try
        Table.Open;
        Table.First;
        ProgressWindow.MaxPosCurrentOperation := Table.RecordCount;
        for I := 1 to Table.RecordCount do
        begin
          ProgressWindow.XPosition := I;
          Application.ProcessMessages;
          Groups := Table.FieldByName('Groups').AsString;
          if TGroups.GroupWithCodeExistsInString(GroupToRename.GroupCode, Groups) then
          begin
            TGroups.ReplaceGroups(SGroupToDelete, SGroupToAdd, Groups);
            FQuery := Context.CreateQuery;
            try
              SetSQL(FQuery, 'UPDATE $DB$ SET Groups=:Groups where ID=' + IntToStr(Table.FieldByName('ID').AsInteger));
              SetStrParam(FQuery, 0, Groups);
              ExecSQL(FQuery);
            finally
              FreeDS(FQuery);
            end;
          end;
          Table.Next;
        end;
      except
        on E: Exception do
        begin
          Error := E.message;
          MessageBoxDB(0, Format(TA('An error occurred during the rename group %s', 'Groups'), [Error]), TA('Error'),
            TD_BUTTON_OK, TD_ICON_ERROR);
        end;
      end;
      ProgressWindow.Close;
    finally
      R(ProgressWindow);
    end;
  finally
    FreeDS(Table);
  end;
end;

procedure MoveGroup(Context: IDBContext; GroupToMove, IntoGroup: string);
var
  GroupSource, GroupDestination: TGroups;
begin
  GroupSource := TGroups.CreateFromString(GroupToMove);
  GroupDestination := TGroups.CreateFromString(IntoGroup);
  try
    if (GroupSource.Count > 0) and (GroupDestination.Count > 0) then
      MoveGroup(Context, GroupSource[0], GroupDestination[0]);
  finally
    F(GroupSource);
    F(GroupDestination);
  end;
end;

procedure MoveGroup(Context: IDBContext; GroupToMove, IntoGroup: TGroup);
var
  I: Integer;
  Table: TDataSet;
  FQuery: TDataSet;
  Error: string;
  Groups: string;
  SGroupToMove, SIntoGroup: string;
  ProgressWindow: TProgressActionForm;
begin
  SGroupToMove := GroupToMove.ToString;
  SIntoGroup := IntoGroup.ToString;

  Table := Context.CreateQuery;
  SetSQL(Table, 'Select ID, Groups from $DB$');

  ProgressWindow := GetProgressWindow;
  ProgressWindow.OneOperation := True;
  ProgressWindow.Show;
  try
    Table.Open;
    Table.First;
    ProgressWindow.MaxPosCurrentOperation := Table.RecordCount;
    for I := 1 to Table.RecordCount do
    begin
      ProgressWindow.XPosition := I;
      Application.ProcessMessages;
      Groups := Table.FieldByName('Groups').AsString;
      if TGroups.GroupWithCodeExistsInString(GroupToMove.GroupCode, Groups) then
      begin
        TGroups.ReplaceGroups(SGroupToMove, SIntoGroup, Groups);

        FQuery := Context.CreateQuery;
        try
          SetSQL(FQuery, 'UPDATE $DB$ SET Groups=:Groups where ID=' + IntToStr(Table.FieldByName('ID').AsInteger));
          SetStrParam(FQuery, 0, Groups);
          ExecSQL(FQuery);

          // checking
          SetSQL(FQuery, 'Select Groups from $DB$ where ID=' + IntToStr(Table.FieldByName('ID').AsInteger));
          FQuery.Open;
          if Groups <> FQuery.FieldByName('Groups').AsString then
            MessageBoxDB(0, Format(TA('An error occurred during the move group %s to group %s (%s)', 'Groups'), [GroupToMove.GroupName,
                GroupToMove.GroupCode, IntoGroup.GroupName, IntoGroup.GroupCode]), TA('Error'), TD_BUTTON_OK,
              TD_ICON_ERROR);
        finally
          FreeDS(FQuery);
        end;
      end;
      Table.Next;
    end;
  except
    on E: Exception do
    begin
      if Error = '' then
        Error := E.message;
      MessageBoxDB(0, Format(TA('An error occurred during the move group %s', 'Groups'), [Error]), TA('Error'), TD_BUTTON_OK,
        TD_ICON_ERROR);
    end;
  end;
  ProgressWindow.Close;
  ProgressWindow.Release;
  ProgressWindow.Free;
  FreeDS(Table);
end;

end.
