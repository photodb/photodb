unit UnitGroupsTools;

interface

uses Windows, DB, Forms, Classes, UnitGroupsWork, SysUtils,
     ProgressActionUnit, uVistaFuncs;

procedure MoveGroup(GroupToMove, IntoGroup : TGroup); overload;
procedure MoveGroup(GroupToMove, IntoGroup : String); overload;

procedure RenameGroup(GroupToRename, NewName : String); overload;
procedure RenameGroup(GroupToRename : TGroup; NewName : String); overload;

procedure DeleteGroup(GroupToDelete : TGroup); overload;
procedure DeleteGroup(GroupToDelete : String); overload;

implementation

uses UnitDBKernel, Dolphin_DB, Language, CommonDBSupport;

procedure DeleteGroup(GroupToDelete : String);
begin
 DeleteGroup(EncodeGroups(GroupToDelete)[0]);
end;

procedure DeleteGroup(GroupToDelete : TGroup);
var
  i : integer;
  Table : TDataSet;
  Error : String;
  Groups : String;
  sGroupToDelete : String;
  ProgressWindow : TProgressActionForm;
begin
 sGroupToDelete:=CodeGroup(GroupToDelete);
 Table := GetTable(dbname,DB_TABLE_IMAGES);
 ProgressWindow := GetProgressWindow;
 ProgressWindow.OneOperation:=true;
 ProgressWindow.Show;
 try
  Table.Open;
  Table.First;
  ProgressWindow.MaxPosCurrentOperation:=Table.RecordCount;
  for i:=1 to Table.RecordCount do
  begin
   ProgressWindow.xPosition:=i;
   Application.ProcessMessages;
   Groups:=Table.FieldByName('Groups').AsString;
   if GroupWithCodeExistsInString(GroupToDelete.GroupCode,Groups) then
   begin
    UnitGroupsWork.ReplaceGroups(sGroupToDelete,'',Groups);
    Table.Edit;
    Table.FieldByName('Groups').AsString:=Groups;
    Table.Post;
   end;
   Table.Next;
  end;
  FlushBuffers(Table);
  Table.Close;
 except
  on e : Exception do
  begin
   Error:=E.Message;
   MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_UNABLE_TO_DELETE_GROUP_F,[Error]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR)
  end;
 end;
 ProgressWindow.Close;
 ProgressWindow.Release;
 ProgressWindow.Free;
 FreeDS(Table);
end;

procedure RenameGroup(GroupToRename, NewName : String);
begin
 RenameGroup(EncodeGroups(GroupToRename)[0],NewName);
end;

procedure RenameGroup(GroupToRename : TGroup; NewName : String);
var
  i : integer;
  Table : TDataSet;
  FQuery : TDataSet;
  Error : String;
  Groups : String;
  sGroupToDelete,sGroupToAdd : String;
  ProgressWindow : TProgressActionForm;
begin
 sGroupToDelete:=CodeGroup(GroupToRename);
 GroupToRename.GroupName:=NewName;
 sGroupToAdd:=CodeGroup(GroupToRename);
 if GetDBType=DB_TYPE_BDE then
 Table :=  GetTable(dbname,DB_TABLE_IMAGES);

 if GetDBType=DB_TYPE_MDB then
 begin
  Table:=GetQuery;
  SetSQL(Table,'Select ID, Groups from '+GetDefDBname);
 end;

 ProgressWindow := GetProgressWindow;
 ProgressWindow.OneOperation:=true;
 ProgressWindow.Show;
 ProgressWindow.CanClosedByUser:=false;
 try
  Table.Open;
  Table.First;
  ProgressWindow.MaxPosCurrentOperation:=Table.RecordCount;
  for i:=1 to Table.RecordCount do
  begin
   ProgressWindow.xPosition:=i;
   Application.ProcessMessages;
   Groups:=Table.FieldByName('Groups').AsString;
   if GroupWithCodeExistsInString(GroupToRename.GroupCode,Groups) then
   begin
    UnitGroupsWork.ReplaceGroups(sGroupToDelete,sGroupToAdd,Groups);
    FQuery:=GetQuery;
    SetSQL(FQuery,'UPDATE '+GetDefDBname+' SET Groups=:Groups where ID='+IntToStr(Table.FieldByName('ID').AsInteger));
    SetStrParam(FQuery,0,Groups);
    ExecSQL(FQuery);
    FreeDS(FQuery);
   end;
   Table.Next;
  end;
 except
  on e : Exception do
  begin
   Error:=E.Message;
   MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_UNABLE_TO_RENAME_GROUP_F,[Error]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
 end;
 ProgressWindow.Close;
 ProgressWindow.Release;
 ProgressWindow.Free;
 FreeDS(Table);
end;

procedure MoveGroup(GroupToMove, IntoGroup : String);
begin
 MoveGroup(EncodeGroups(GroupToMove)[0],EncodeGroups(IntoGroup)[0]);
end;

procedure MoveGroup(GroupToMove, IntoGroup : TGroup);
var
  i : integer;
  Table : TDataSet;  
  FQuery : TDataSet;
  Error : String;
  Groups : String;
  sGroupToMove,sIntoGroup : String;
  ProgressWindow : TProgressActionForm;
begin
 sGroupToMove:=CodeGroup(GroupToMove);
 sIntoGroup:=CodeGroup(IntoGroup);

 if GetDBType=DB_TYPE_BDE then
 Table :=  GetTable(dbname,DB_TABLE_IMAGES);

 if GetDBType=DB_TYPE_MDB then
 begin
  Table:=GetQuery;
  SetSQL(Table,'Select ID, Groups from '+GetDefDBname);
 end;

 ProgressWindow := GetProgressWindow;
 ProgressWindow.OneOperation:=true;
 ProgressWindow.Show;
 try
  Table.Open;
  Table.First;
  ProgressWindow.MaxPosCurrentOperation:=Table.RecordCount;
  for i:=1 to Table.RecordCount do
  begin
   ProgressWindow.xPosition:=i;
   Application.ProcessMessages;
   Groups:=Table.FieldByName('Groups').AsString;
   if GroupWithCodeExistsInString(GroupToMove.GroupCode,Groups) then
   begin
    UnitGroupsWork.ReplaceGroups(sGroupToMove,sIntoGroup,Groups);

    if GetDBType=DB_TYPE_MDB then
    begin
     FQuery:=GetQuery;
     SetSQL(FQuery,'UPDATE '+GetDefDBname+' SET Groups=:Groups where ID='+IntToStr(Table.FieldByName('ID').AsInteger));
     SetStrParam(FQuery,0,Groups);
     ExecSQL(FQuery);
    end;
    if GetDBType=DB_TYPE_BDE then
    begin
     FQuery:=GetQuery;
     SetSQL(FQuery,'UPDATE '+GetDefDBname+' SET Groups="'+normalizeDBString(Groups)+'" where ID='+IntToStr(Table.FieldByName('ID').AsInteger));
     ExecSQL(FQuery);
    end;

    //checking
    SetSQL(FQuery,'Select Groups from '+GetDefDBname+' where ID='+IntToStr(Table.FieldByName('ID').AsInteger));
    FQuery.Open;
    if Groups<>FQuery.FieldByName('Groups').AsString then
    MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_ERROR_MOVING_GROUP_F,[GroupToMove.GroupName,GroupToMove.GroupCode,IntoGroup.GroupName,IntoGroup.GroupCode]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
    FreeDS(FQuery);
   end;
   Table.Next;
  end;
 except
  on e : Exception do
  begin
   if Error='' then Error:=E.Message;
   MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_UNABLE_TO_MOVE_GROUP_F,[Error]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
 end;
 ProgressWindow.Close;
 ProgressWindow.Release;
 ProgressWindow.Free;
 FreeDS(Table);
end;

end.
