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

  uGroupTypes,
  uConstants,
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
begin
  DeleteGroup(Context, EncodeGroups(GroupToDelete)[0]);
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
  SGroupToDelete := CodeGroup(GroupToDelete);
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
          if GroupWithCodeExistsInString(GroupToDelete.GroupCode, Groups) then
          begin
            uGroupTypes.ReplaceGroups(SGroupToDelete, '', Groups);
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
  Groups := EncodeGroups(GroupToRename);
  if Groups.Count > 0 then
    RenameGroup(Context, Groups[0], NewName);
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
  SGroupToDelete := CodeGroup(GroupToRename);
  GroupToRename.GroupName := NewName;
  SGroupToAdd := CodeGroup(GroupToRename);

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
          if GroupWithCodeExistsInString(GroupToRename.GroupCode, Groups) then
          begin
            uGroupTypes.ReplaceGroups(SGroupToDelete, SGroupToAdd, Groups);
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
begin
  MoveGroup(Context, EncodeGroups(GroupToMove)[0], EncodeGroups(IntoGroup)[0]);
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
  SGroupToMove := CodeGroup(GroupToMove);
  SIntoGroup := CodeGroup(IntoGroup);

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
      if GroupWithCodeExistsInString(GroupToMove.GroupCode, Groups) then
      begin
        uGroupTypes.ReplaceGroups(SGroupToMove, SIntoGroup, Groups);

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
