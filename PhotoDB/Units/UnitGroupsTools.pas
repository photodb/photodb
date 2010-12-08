unit UnitGroupsTools;

interface

uses Windows, DB, Forms, Classes, UnitGroupsWork, SysUtils,
  ProgressActionUnit, uVistaFuncs, uMemory, uTranslate;

procedure MoveGroup(GroupToMove, IntoGroup: TGroup); overload;
procedure MoveGroup(GroupToMove, IntoGroup: string); overload;

procedure RenameGroup(GroupToRename, NewName: string); overload;
procedure RenameGroup(GroupToRename: TGroup; NewName: string); overload;

procedure DeleteGroup(GroupToDelete: TGroup); overload;
procedure DeleteGroup(GroupToDelete: string); overload;

implementation

uses
  UnitDBKernel, Dolphin_DB, CommonDBSupport;

procedure DeleteGroup(GroupToDelete: string);
begin
  DeleteGroup(EncodeGroups(GroupToDelete)[0]);
end;

procedure DeleteGroup(GroupToDelete: TGroup);
var
  I: Integer;
  Table: TDataSet;
  Error: string;
  Groups: string;
  SGroupToDelete: string;
  ProgressWindow: TProgressActionForm;
begin
  SGroupToDelete := CodeGroup(GroupToDelete);
  Table := GetTable(Dbname, DB_TABLE_IMAGES);
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
          if GroupWithCodeExistsInString(GroupToDelete.GroupCode, Groups) then
          begin
            UnitGroupsWork.ReplaceGroups(SGroupToDelete, '', Groups);
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
          MessageBoxDB(GetActiveFormHandle, Format(TA('An error occurred during the delete group %s', 'Groups'), [Error]), TA('Error'),
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

procedure RenameGroup(GroupToRename, NewName: string);
begin
  RenameGroup(EncodeGroups(GroupToRename)[0], NewName);
end;

procedure RenameGroup(GroupToRename: TGroup; NewName: string);
var
  I: Integer;
  Table: TDataSet;
  FQuery: TDataSet;
  Error: string;
  Groups: string;
  SGroupToDelete, SGroupToAdd: string;
  ProgressWindow: TProgressActionForm;
begin
  SGroupToDelete := CodeGroup(GroupToRename);
  GroupToRename.GroupName := NewName;
  SGroupToAdd := CodeGroup(GroupToRename);

  Table := GetQuery;
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
          if GroupWithCodeExistsInString(GroupToRename.GroupCode, Groups) then
          begin
            UnitGroupsWork.ReplaceGroups(SGroupToDelete, SGroupToAdd, Groups);
            FQuery := GetQuery;
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
          MessageBoxDB(GetActiveFormHandle, Format(TA('An error occurred during the rename group %s', 'Groups'), [Error]), TA('Error'),
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

procedure MoveGroup(GroupToMove, IntoGroup: string);
begin
  MoveGroup(EncodeGroups(GroupToMove)[0], EncodeGroups(IntoGroup)[0]);
end;

procedure MoveGroup(GroupToMove, IntoGroup: TGroup);
var
  I: Integer;
  Table: TDataSet;
  FQuery: TDataSet;
  Error: string;
  Groups: string;
  SGroupToMove, SIntoGroup: string;
  ProgressWindow: TProgressActionForm;
begin
  SGroupToMove := CodeGroup(GroupToMove);
  SIntoGroup := CodeGroup(IntoGroup);

  if GetDBType = DB_TYPE_MDB then
  begin
    Table := GetQuery;
    SetSQL(Table, 'Select ID, Groups from $DB$');
  end;

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
      if GroupWithCodeExistsInString(GroupToMove.GroupCode, Groups) then
      begin
        UnitGroupsWork.ReplaceGroups(SGroupToMove, SIntoGroup, Groups);

        FQuery := GetQuery;
        try
          SetSQL(FQuery, 'UPDATE $DB$ SET Groups=:Groups where ID=' + IntToStr(Table.FieldByName('ID').AsInteger));
          SetStrParam(FQuery, 0, Groups);
          ExecSQL(FQuery);

          // checking
          SetSQL(FQuery, 'Select Groups from $DB$ where ID=' + IntToStr(Table.FieldByName('ID').AsInteger));
          FQuery.Open;
          if Groups <> FQuery.FieldByName('Groups').AsString then
            MessageBoxDB(GetActiveFormHandle, Format(TA('An error occurred during the move group %s to group %s (%s)', 'Groups'), [GroupToMove.GroupName,
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
      MessageBoxDB(GetActiveFormHandle, Format(TA('An error occurred during the move group %s', 'Groups'), [Error]), TA('Error'), TD_BUTTON_OK,
        TD_ICON_ERROR);
    end;
  end;
  ProgressWindow.Close;
  ProgressWindow.Release;
  ProgressWindow.Free;
  FreeDS(Table);
end;

end.
