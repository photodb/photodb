unit UnitGroupsWork;

interface


uses Windows, SysUtils, Graphics, Dolphin_DB, UnitDBDeclare, jpeg, DB, Classes,
  uMemory;

type
  TGroup = Record
   GroupName : String;
   GroupCode : String;
   GroupImage : TJpegImage;
   GroupDate : TdateTime;
   GroupComment : String;
   GroupFaces : String;
   GroupAccess : Integer;
   GroupKeyWords : String;
   AutoAddKeyWords : Boolean;
   RelatedGroups : String;
   IncludeInQuickList : Boolean;
  end;

  TGroups = array of TGroup;
  TArGroups = array of TGroups;

  Const

  GROUP_ACCESS_COMMON  = 0;
  GROUP_ACCESS_PRIVATE = 1;

type
  TGroupAction = record
   Action : Integer;
   OutGroup : TGroup;
   InGroup : TGroup;
   ReplaceImageOnNew : Boolean;
   ActionForAll : Boolean;
   ActionForAllKnown : Boolean;
   ActionForAllUnKnown : Boolean;
  end;

  TGroupsActions = array of TGroupAction;

  TGroupsActionsW = record
    Actions : TGroupsActions;
    IsActionForUnKnown : Boolean;
    ActionForUnKnown : TGroupAction;
    IsActionForKnown : Boolean;
    ActionForKnown : TGroupAction;
    MaxAuto : Boolean;
  end;


Function CreateNewGroup(GroupName : String) : String;
Function GroupSearchByGroupName(GroupName : String) : String;
Function EncodeGroups(Groups : String) : TGroups;
//Function GroupsTableFileName : String;
function GroupsTableName : String; overload;
function GroupsTableName(FileName : String) : String; overload;
Function GetRegisterGroupList(LoadImages : Boolean; UseInclude : Boolean = false) : TGroups;
Function IsValidGroupsTable : Boolean;
Function CreateGroupsTable : Boolean;
Function AddGroup(Group : TGroup) : Boolean;
Procedure FreeGroup(var Group : TGroup);
Procedure FreeGroups(var Groups : TGroups);
Function CreateNewGroupCode : String;
Function GroupNameExists(GroupName : String) : Boolean;
function DeleteGroup(Group : TGroup) : Boolean;
Function FindGroupCodeByGroupName(GroupName : String) : String;
Function FindGroupNameByGroupCode(GroupCode : String) : String;
Function CodeGroups(Groups : TGroups) : String;
Function CodeGroup(Group : TGroup) : String;
Function CopyGroups(Groups : TGroups) : TGroups;
Function CreateNewGroupCodeA : String;
Function GetGroupByGroupName(GroupName : String; LoadImage : Boolean) : TGroup; overload;
Function GetGroupByGroupCode(GroupCode : String; LoadImage : Boolean) : TGroup; overload;
Function CopyGroup(Group : TGroup) : TGroup;
function UpdateGroup(Group : TGroup): Boolean;
Procedure RemoveGroupsFromGroups(var Groups : TGroups; GroupsToRemove : TGroups);
Procedure RemoveGroupFromGroups(var Groups : TGroups; Group : TGroup);
Procedure AddGroupsToGroups(var Groups : TGroups; GroupsToAdd : TGroups); overload;
Procedure AddGroupsToGroups(var Groups : String; GroupsToAdd : String); overload;
Procedure AddGroupToGroups(var Groups : TGroups; Group : TGroup);
{$IFNDEF EXT}
Function GetCommonGroups(GroupsList : TStringList) : String; overload;
{$ENDIF}
Function GetCommonGroups(ArGroups : TArGroups) : TGroups; overload;
Function CompareGroups(GroupsA, GroupsB : String) : Boolean; overload;
Function CompareGroups(GroupsA, GroupsB : TGroups) : Boolean; overload;
Procedure ReplaceGroups(GroupsToDelete, GroupsToAdd : String; var Groups : String);
Function GetRegisterGroupListW(FileName : String; LoadImages : Boolean; UseInclude : Boolean = false) : TGroups;
Function GroupExistsInGroups(Group : TGroup; Groups : TGroups) : Boolean;
Procedure ReplaceGroupsW(GroupsToDelete, GroupsToAdd : TGroups; var Groups : TGroups);
Function GroupWithCodeExists(GroupCode : String) : Boolean;
Function GroupWithCodeExistsInString(GroupCode, Groups : String) : Boolean;
Function IsValidGroupsTableW(FileName : String; NoCheck : boolean = false) : Boolean;
Function GetGroupByGroupNameW(GroupName : String; LoadImage : Boolean; FileName : String) : TGroup;
Function AddGroupW(Group : TGroup; FileName : String) : Boolean;
Function GroupNameExistsW(GroupName : String; FileName : String) : Boolean;
Function CreateGroupsTableW(FileName : String) : Boolean;
Function GroupsTableFileNameW(FileName : String) : String;
function GetNilGroup : TGroup;

//${345d-fgtr-ergd}[#Имя группы#]

implementation

uses CommonDBSupport, UnitDBkernel, UnitFileCheckerDB;

function FileExistsW(FileName : String) : boolean;
begin
 if FileName<>'' then if FileName[1]='"' then FileName:=Copy(FileName,2,Length(FileName)-2);
 Result:=FileExists(FileName);
end;

function GetNilGroup : TGroup;
begin
 Result.GroupName:='';
 Result.GroupCode:='';
 Result.GroupImage:=nil;
 //no reason to free other fields
end;

Procedure FreeGroup(var Group : TGroup);
begin
 if Group.GroupImage <> nil then
    Group.GroupImage.Free;
end;

procedure FreeGroups(var Groups : TGroups);
var
  I : Integer;
begin
  for I := 0 to Length(Groups) - 1 do
    FreeGroup(Groups[I]);
  SetLength(Groups, 0);
end;

{$IFDEF EXT}
Function GetExt(Filename : string) : string;
var
  i,j:integer;
  s:string;
begin
 j:=0;
 For i:=length(filename) downto 1 do
 begin
  If filename[i]='.' then
  begin
   j:=i;
   break;
  end;
  If filename[i]='\' then break;
 end;
 s:='';
 If j<>0 then
 begin
  s:=copy(filename,j+1,length(filename)-j);
  For i:=1 to length(s) do
  s[i]:=Upcase(s[i]);
 end;
 result:=s;
end;

function GetFileNameWithoutExt(filename : string) : string;
var
  i, n : integer;
begin
 Result:='';
 If filename='' then exit;
 n:=0;
 for i:=length(filename)-1 downto 1 do
 If filename[i]='\' then
 begin
  n:=i;
  break;
 end;
 delete(filename,1,n);
 If filename<>'' then
 If filename[Length(filename)]='\' then
 Delete(filename,Length(filename),1);
 For i:=Length(filename) Downto 1 do
 begin
  if filename[i]='.' then
  begin
   FileName:=Copy(filename,1,i-1);
   Break;
  end;
 end;
 Result:=FileName;
end;

procedure UnFormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]='\' then Delete(s,length(s),1);
end;

procedure FormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]<>'\' then s:=s+'\';
end;

function GetDirectory(FileName:string):string;
var
  i, n: integer;
begin
 n:=0;
 for i:=Length(FileName) downto 1 do
 If FileName[i]='\' then
 begin
  n:=i;
  Break;
 end;
 Delete(filename,n,length(filename)-n+1);
 Result:=FileName;
 FormatDir(Result);
end;

function NormalizeDBString(S : String) : String;
var
  i : integer;
begin
 result:=s;
 i:=1;
 if length(result)>0 then
 Repeat
  if result[i]='"' then
  begin
   insert('"',result,i);
   inc(i);
  end;
  inc(i);
 until i>length(result);
end;
{$ENDIF}

function CreateNewGroupCode : String;
Const
{$IFNDEF EXT}
  StrTable = pwd_rusup+pwd_rusdown+pwd_englup+pwd_engldown+pwd_cifr;
{$ENDIF}
{$IFDEF EXT}
  StrTable = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
{$ENDIF}
begin
{$IFNDEF EXT}
 Result:=RandomPwd(4,StrTable)+'-'+RandomPwd(4,StrTable)+'-'+RandomPwd(4,StrTable);
{$ENDIF}
{$IFDEF EXT}
 Result:=''
{$ENDIF}
end;

function CreateNewGroupCodeA : String;
Const
{$IFNDEF EXT}
  StrTable = pwd_rusup+pwd_rusdown+pwd_englup+pwd_engldown+pwd_cifr;
{$ENDIF}
{$IFDEF EXT}
  StrTable = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
{$ENDIF}
begin
{$IFNDEF EXT}
 Result:='${'+RandomPwd(4,StrTable)+'-'+RandomPwd(4,StrTable)+'-'+RandomPwd(4,StrTable)+'}';
{$ENDIF}
{$IFDEF EXT}
 Result:=''
{$ENDIF}
end;

function CreateNewGroup(GroupName : String) : String;
begin
 Result:=CreateNewGroupCodeA+'[#'+GroupName+'#]'
end;

function GroupSearchByGroupName(GroupName : String) : String;
begin
 if GetDBType=DB_TYPE_MDB then Result:='%#'+GroupName+'#%';
end;

function EncodeGroups(Groups : String) : TGroups;
var
  i, j, n : integer;
  IsGroupCode, IsGroupName : Boolean;
  s, GroupName, GroupCode : String;
begin
 SetLength(Result,0);
 s:=Groups;
 For i:=1 to Length(Groups)-4 do
 begin
  IsGroupCode:=False;
  IsGroupName:=False;
  If (s[i]='$') and (s[i+1]='{') then
  begin
   n:=i;
   For j:=i+1 to Length(Groups) do
   if s[j]='}' then
   begin
    n:=j;
    GroupCode:=Copy(s,i,j-i);
   end;
   For j:=i+1 to Length(Groups)-1 do
   if s[j]='}' then
   begin
    n:=j;
    IsGroupCode:=True;
    GroupCode:=Copy(s,i+2,j-i-2);
    Break;
   end;
   if s[n+1]='[' then
   For j:=n+1 to Length(Groups) do
   if s[j]=']' then
   begin
    IsGroupName:=True;
    GroupName:=Copy(s,n+2,j-n-2);
    GroupName:=Copy(GroupName,2,Length(GroupName)-2);
    Break;
   end;
   If IsGroupName and IsGroupCode then
   begin
    SetLength(Result,Length(Result)+1);
    Result[Length(Result)-1].GroupName:=GroupName;
    Result[Length(Result)-1].GroupCode:=GroupCode;
    Result[Length(Result)-1].GroupImage:=nil;
   end;
  end;
 end;
end;

Function CopyGroup(Group : TGroup) : TGroup;
begin
 Result:=Group;
 If Group.GroupImage<>nil then
 begin
  Result.GroupImage:=TJpegImage.Create;
  Result.GroupImage.Assign(Group.GroupImage);
 end;
end;

Function CopyGroups(Groups : TGroups) : TGroups;
var
  i : integer;
begin
 SetLength(Result,Length(Groups));
 for i:=0 to length(Groups)-1 do
 begin
  Result[i]:=Groups[i];
  if Groups[i].GroupImage<>nil then
  begin
   Result[i].GroupImage:=TJpegImage.Create;
   Result[i].GroupImage.Assign(Groups[i].GroupImage);
  end else Result[i].GroupImage:=nil;
 end;
end;

Function CodeGroup(Group : TGroup) : String;
begin
 Result:='${'+Group.GroupCode+'}[#'+Group.GroupName+'#]';
end;

Function CodeGroups(Groups : TGroups) : String;
var
  i : integer;
begin
 Result:='';
 For i:=0 to Length(Groups)-1 do
 Result:=Result+CodeGroup(Groups[i])//'${'+Groups[i].GroupCode+'}[#'+Groups[i].GroupName+'#]';
end;

Procedure AddGroupToGroups(var Groups : TGroups; Group : TGroup);
var
  i : Integer;
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

Procedure AddGroupsToGroups(var Groups : TGroups; GroupsToAdd : TGroups);
var
  i : Integer;
begin
  For i:=0 to Length(GroupsToAdd)-1 do
  AddGroupToGroups(Groups,GroupsToAdd[i]);
end;

Procedure AddGroupsToGroups(var Groups : String; GroupsToAdd : String);
var
  GA, GB : TGroups;
begin
 GA:=EnCodeGroups(Groups);
 GB:=EnCodeGroups(GroupsToAdd);
 AddGroupsToGroups(GA,GB);
 Groups:=CodeGroups(GA);
end;

Procedure RemoveGroupFromGroups(var Groups : TGroups; Group : TGroup);
var
  i, j : Integer;
begin
 For i:=0 to Length(Groups)-1 do
 if Groups[i].GroupCode=Group.GroupCode then
 begin
  For j:=i to Length(Groups)-2 do
  Groups[j]:=Groups[j+1];
  SetLength(Groups,Length(Groups)-1);
  Break;
 end;
end;

Procedure RemoveGroupsFromGroups(var Groups : TGroups; GroupsToRemove : TGroups);
var
  i : Integer;
begin
  For i:=0 to Length(GroupsToRemove)-1 do
  RemoveGroupFromGroups(Groups,GroupsToRemove[i]);
end;

Function FindGroupCodeByGroupName(GroupName : String) : String;
var
  Query : TDataSet;
begin
 Result:='';
 If not FileExistsW(GroupsTableFileNameW(dbname)) and (GetDBType<>DB_TYPE_MDB) then exit;
 Query := GetQuery;
 SetSQL(Query,'Select * From '+GroupsTableName+' Where GroupName like "'+GroupName+'"');
 try
 Query.Active:=True;
 except
  FreeDS(Query);
  exit;
 end;
 If Query.RecordCount=0 then
 begin
  FreeDS(Query);
  Exit;
 end;
 Query.First;
 Result:=Query.FieldByName('GroupCode').AsString;
 Query.Close;
 FreeDS(Query);
end;

Function FindGroupNameByGroupCode(GroupCode : String) : String;
var
  Query : TDataSet;
begin
 Result:='';
 If not FileExistsW(GroupsTableFileNameW(dbname)) and (GetDBType<>DB_TYPE_MDB) then exit;
 Query := GetQuery;
 SetSQL(Query,'Select * From '+GroupsTableName+' Where GroupCode="'+GroupCode+'"');
 Query.Active:=True;
 If Query.RecordCount=0 then
 begin
  FreeDS(Query);
  Exit;
 end;
 Query.First;
 Result:=Query.FieldByName('GroupName').AsString;
 Query.Close;
 FreeDS(Query);
end;

Function GroupNameExists(GroupName : String) : Boolean;
begin
 Result:=GroupNameExistsW(GroupName,dbname);
end;

Function GroupNameExistsW(GroupName : String; FileName : String) : Boolean;
var
  Query : TDataSet;
begin
 Result:=False;
 If not FileExists(GroupsTableFileNameW(FileName)) and (GetDBType<>DB_TYPE_MDB) then exit;
 Query := GetQuery(FileName);
 SetSQL(Query,'Select * From '+GroupsTableName(FileName)+' Where GroupName like "'+GroupName+'"');
 try
  Query.Active:=True;
 except
  Query.Active:=False;
  FreeDS(Query);
  Exit;
 end;
 If Query.RecordCount=0 then Result:=False else
 Result:=True;
 Query.Close;
 FreeDS(Query);
end;

Function GroupWithCodeExists(GroupCode : String) : Boolean;
var
  Query : TDataSet;
begin
 Result:=False;
 Query := GetQuery;
 SetSQL(Query,'Select * From '+GroupsTableName+' Where GroupCode like "'+GroupCode+'"');
 try
  Query.Active:=True;
 except
  Query.Active:=False;
  FreeDS(Query);
  Exit;
 end;
 If Query.RecordCount=1 then Result:=True;
 Query.Close;
 FreeDS(Query);
end;

function DeleteGroup(Group : TGroup) : Boolean;
var
  Query : TDataSet;
begin
 Result:=false;
 Query := GetQuery;
 SetSQL(Query,'Delete From '+GroupsTableName+' Where GroupCode like "'+Group.GroupCode+'"');
 try
  ExecSQL(Query);
 except
  FreeDS(Query);
  exit;
 end;
 FreeDS(Query);
 Result:=true;
end;

function UpdateGroup(Group : TGroup): Boolean;
var
  Query : TDataSet;
  ID : integer;
begin
 Result:=false;
 If not FileExists(GroupsTableFileNameW(dbname)) and (GetDBType<>DB_TYPE_MDB) then exit;
 Query := GetQuery;
 SetSQL(Query,'Select * From '+GroupsTableName+' Where GroupCode like "'+Group.GroupCode+'"');
 try
  Query.Active:=True;
 except
  FreeDS(Query);
  Exit;
 end;
 If Query.RecordCount=0 then
 begin
  FreeDS(Query);
  Exit;
 end;
 Query.First;
 ID:=Query.FieldByName('ID').AsInteger;
 Query.Active:=false;
 SetSQL(Query,'Update '+GroupsTableName+' Set GroupName='+NormalizeDBString(Group.GroupName)+', GroupAccess=:GroupAccess, GroupImage=:GroupImage, GroupComment='+NormalizeDBString(Group.GroupComment)+', GroupFaces='+NormalizeDBString(Group.GroupFaces)+', GroupDate = :GroupDate, GroupAddKW=:GroupAddKW, GroupKW='+NormalizeDBString(Group.GroupKeyWords)+', RelatedGroups = '+NormalizeDBString(Group.RelatedGroups)+', IncludeInQuickList = :IncludeInQuickList Where ID='+IntToStr(ID));
 SetIntParam(Query,0,Group.GroupAccess);
 AssignParam(Query,1,Group.GroupImage);
 if Group.GroupDate=0 then
 SetDateParam(Query,'GroupDate',Now) else
 SetDateParam(Query,'GroupDate',Group.GroupDate);
 SetBoolParam(Query,3,Group.AutoAddKeyWords);
 SetBoolParam(Query,4,Group.IncludeInQuickList);
 ExecSQL(Query);
 FreeDS(Query);
 Result:=true;
end;

function AddGroupW(Group : TGroup; FileName : String) : Boolean;
var
  Query : TDataSet;
  Bit : TBitmap;
begin
 Result:=false;
 if not IsValidGroupsTableW(FileName,true) then
 CreateGroupsTableW(FileName);
 if GroupNameExistsW(Group.GroupName,FileName) then exit;
 Query := GetQuery(FileName);
 SetSQL(Query,'Select * From '+GroupsTableName(FileName)+' Where GroupCode like "'+Group.GroupCode+'"');
 try
  Query.Active:=True;
 except
  FreeDS(Query);
  Exit;
 end;
 If Query.RecordCount=0 then
 begin
  Query.Active:=false;
  SetSQL(Query,'Insert Into '+GroupsTableName(FileName)+' (GroupCode, GroupName, GroupImage, GroupComment, GroupDate, Groupfaces, GroupAccess, GroupKW, GroupAddKW, RelatedGroups, IncludeInQuickList) values'+' (:GroupCode, :GroupName, :GroupImage, :GroupComment, :GroupDate, :Groupfaces, :GroupAccess, :GroupKW, :GroupAddKW, :RelatedGroups, :IncludeInQuickList)');

  SetStrParam(Query,0,Group.GroupCode);
  SetStrParam(Query,1,Group.GroupName);
  if Group.GroupImage=nil then
  begin
   Bit:=TBitmap.Create;
   Bit.PixelFormat:=pf24bit;
   Bit.Width:=16;
   Bit.Height:=16;
   DrawIconEx(Bit.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_DELETE_INFO+1],16,16,0,0,DI_NORMAL);
   Group.GroupImage:=TJpegImage.Create;
   Group.GroupImage.Assign(Bit);
   Bit.Free;
   Group.GroupImage.Compress;
  end;

  AssignParam(Query,2,Group.GroupImage);

//  else AssignParam(Query,2,nil);
  SetStrParam(Query,3,Group.GroupComment);
  if Group.GroupDate=0 then
  SetDateParam(Query,'GroupDate',Now) else
  SetDateParam(Query,'GroupDate',Group.GroupDate);
  SetStrParam(Query,5,Group.GroupFaces);
  SetIntParam(Query,6,Group.GroupAccess);
  SetStrParam(Query,7,Group.GroupKeyWords);
  SetBoolParam(Query,8,Group.AutoAddKeyWords);
  SetStrParam(Query,9,Group.RelatedGroups);
  SetBoolParam(Query,10,Group.IncludeInQuickList);
  try
   ExecSQL(Query);
  except
   FreeDS(Query);
   Exit;
  end;
  Result:=True;
  FreeDS(Query);
  Exit;
 end;
end;

Function AddGroup(Group : TGroup) : Boolean;
begin
 Result:=AddGroupW(Group,dbname);
end;

Function GroupsTableFileNameW(FileName : String) : String;
begin
 if GetDBType(FileName)=DB_TYPE_MDB then Result:=FileName;
end;

function GroupsTableName(FileName : String) : String;
begin
 if FileName<>'' then
 if (FileName[1]=FileName[Length(FileName)]) then
 if FileName[1]='"' then FileName:=Copy(FileName,2,Length(FileName)-2);
 if GetDBType(FileName)=DB_TYPE_MDB then Result:='Groups';
end;

function GroupsTableName : String;
begin
 if GetDBType=DB_TYPE_MDB then Result:='Groups';
end;

Function IsValidGroupsTableW(FileName : String; NoCheck : boolean = false) : Boolean;
var
  Table : TDataSet;
  Query : TDataSet;
  CheckResult : integer;
begin
 CheckResult:=FileCheckedDB.CheckFile(GroupsTableFileNameW(FileName));
 if (CheckResult=CHECK_RESULT_OK) and not NoCheck then
 begin
  Result:=true;
  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(FileName));
  exit;
 end;

 Result:=false;
 If (CheckResult=CHECK_RESULT_FILE_NOE_EXISTS) and (GetDBType<>DB_TYPE_MDB) then exit;
 Table := GetTable(FileName,DB_TABLE_GROUPS);
 if Table=nil then Exit;
 try
  Table.Active:=True;
 except
  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(FileName));
  FreeDS(Table);
  Exit;
 end;
 Table.First;
 try
  Table.FieldByName('GroupCode').AsString;
  Table.FieldByName('GroupName').AsString;
  Table.FieldByName('GroupImage').AsString;
  Table.FieldByName('GroupComment').AsString;
  Table.FieldByName('GroupDate').AsDateTime;
  Table.FieldByName('GroupFaces').AsString;
  Table.FieldByName('GroupAccess').AsInteger;

  if Table.FindField('GroupKW')=nil then
  begin
   Table.Active := False;
   Query := GetQuery(FileName);
   SetSQL(Query,'ALTER TABLE '+FileName+' ADD GroupKW BLOB(240,1)');
   ExecSQL(Query);
   FreeDS(Query);
   Table.Active := True;
  end;
  Table.FieldByName('GroupKW').AsString;
  if Table.FindField('GroupAddKW')=nil then
  begin
   Table.Active := False;
   Query := GetQuery(FileName);;
   SetSQL(Query,'ALTER TABLE '+FileName+' ADD GroupAddKW BOOLEAN');
   ExecSQL(Query);
   FreeDS(Query);
   Table.Active := True;
  end;
  Table.FieldByName('GroupAddKW').AsBoolean;
  //Included in PhotoDB v1.9
  if Table.FindField('RelatedGroups')=nil then
  begin
   Table.Active := False;
   Query := GetQuery(FileName);
   SetSQL(Query,'ALTER TABLE '+FileName+' ADD RelatedGroups BLOB(240,1)');
   ExecSQL(Query);
   FreeDS(Query);
   Table.Active := True;
  end;
  Table.FieldByName('RelatedGroups').AsString;
  if Table.FindField('IncludeInQuickList')=nil then
  begin
   Table.Active := False;
   Query := GetQuery(FileName);
   SetSQL(Query,'ALTER TABLE '+FileName+' ADD IncludeInQuickList BOOLEAN');
   ExecSQL(Query);
   FreeDS(Query);
   Query := GetQuery(FileName);
   SetSQL(Query,'UPDATE '+FileName+' SET IncludeInQuickList = TRUE');
   ExecSQL(Query);
   FreeDS(Query);
   Table.Active := True;
  end;
  Table.FieldByName('IncludeInQuickList').AsBoolean;
 except
  FreeDS(Table);
  Exit;
 end;
 FreeDS(Table);
 Result:=True;
end;

Function IsValidGroupsTable : Boolean;
begin
  Result := True; exit; //TODO:!!!
  Result:=IsValidGroupsTableW(dbname);
end;

function CreateGroupsTableW(FileName : String) : Boolean;
begin
  Result:=False;
  if GetDBType(FileName)=DB_TYPE_MDB then Result:=ADOCreateGroupsTable(FileName);
end;

Function CreateGroupsTable : Boolean;
begin
 Result:=CreateGroupsTableW(GroupsTableFileNameW(dbname))
end;

Function GetGroupByGroupCode(GroupCode : String; LoadImage : Boolean) : TGroup;
var
  Query : TDataSet;
  BS : TStream;
begin
  Query := GetQuery;
  try
    if LoadImage then
      SetSQL(Query, 'Select * From ' + GroupsTableName + ' Where GroupCode like "' + GroupCode + '"')
    else
      SetSQL(Query,
        'Select GroupCode,GroupName,GroupDate,GroupComment,GroupAccess,GroupFaces,GroupKW,GroupAddKW,RelatedGroups,IncludeInQuickList From '
          + GroupsTableName + ' Where GroupCode like "' + GroupCode + '"');
    try
      Query.Active := True;
    except
      Result := GetNilGroup;
      Exit;
    end;
    Query.First;
    Result.GroupName := Query.FieldByName('GroupName').AsString;
    Result.GroupCode := Query.FieldByName('GroupCode').AsString;
    Result.GroupImage := nil;
    if LoadImage then
    begin
      if TBlobField(Query.FieldByName('GroupImage')) <> nil then
      begin
        BS := GetBlobStream(Query.FieldByName('GroupImage'), bmRead);
        try
          Result.GroupImage := TJpegImage.Create;
          if Bs.Size <> 0 then
            Result.GroupImage.LoadfromStream(Bs);

        finally
          F(BS);
        end;
      end;
    end;
    Result.GroupComment := Query.FieldByName('GroupComment').AsString;
    Result.GroupDate := Query.FieldByName('GroupDate').AsDateTime;
    Result.GroupFaces := Query.FieldByName('GroupFaces').AsString;
    Result.GroupAccess := Query.FieldByName('GroupAccess').AsInteger;
    Result.GroupKeyWords := Query.FieldByName('GroupKW').AsString;
    Result.AutoAddKeyWords := Query.FieldByName('GroupAddKW').AsBoolean;
    Result.RelatedGroups := Query.FieldByName('RelatedGroups').AsString;
    Result.IncludeInQuickList := Query.FieldByName('IncludeInQuickList').AsBoolean;

    Query.Close;
  finally
    FreeDS(Query);
  end;
end;

function GetGroupByGroupName(GroupName: string; LoadImage: Boolean): TGroup;
begin
  Result := GetGroupByGroupNameW(GroupName, LoadImage, Dbname);
end;

function GetGroupByGroupNameW(GroupName: string; LoadImage: Boolean; FileName: string): TGroup;
var
  Query: TDataSet;
  BS: TStream;
begin
  Query := GetQuery(FileName);
  try
    if LoadImage then
      SetSQL(Query, 'Select * From ' + GroupsTableName(FileName) + ' Where GroupName like "' + GroupName + '"')
    else
      SetSQL(Query,
        'Select GroupCode,GroupName,GroupDate,GroupComment,GroupAccess,GroupFaces,GroupKW,GroupAddKW, RelatedGroups, IncludeInQuickList From ' + GroupsTableName(FileName) + ' Where GroupName like "' + GroupName + '"');
    try
      Query.Active := True;
    except
      Result := GetNilGroup;
      Exit;
    end;
    Query.First;
    Result.GroupName := Query.FieldByName('GroupName').AsString;
    Result.GroupCode := Query.FieldByName('GroupCode').AsString;
    Result.GroupImage := nil;
    if LoadImage then
    begin
      if TBlobField(Query.FieldByName('GroupImage')) <> nil then
      begin
        Bs := GetBlobStream(Query.FieldByName('GroupImage'), bmRead);
        try
          Result.GroupImage := TJpegImage.Create;
          Result.GroupImage.LoadfromStream(BS);

        finally
          BS.Free;
        end;
      end;
    end;
    Result.GroupComment := Query.FieldByName('GroupComment').AsString;
    Result.GroupDate := Query.FieldByName('GroupDate').AsDateTime;
    Result.GroupFaces := Query.FieldByName('GroupFaces').AsString;
    Result.GroupAccess := Query.FieldByName('GroupAccess').AsInteger;

    Result.GroupKeyWords := Query.FieldByName('GroupKW').AsString;
    Result.AutoAddKeyWords := Query.FieldByName('GroupAddKW').AsBoolean;
    Result.RelatedGroups := Query.FieldByName('RelatedGroups').AsString;
    Result.IncludeInQuickList := Query.FieldByName('IncludeInQuickList').AsBoolean;
  finally
    FreeDS(Query);
  end;
end;

function GetRegisterGroupListW(FileName : String; LoadImages : Boolean; UseInclude : Boolean = false) : TGroups;
var
  Table : TDataSet;
  N: Integer;
  BS: TStream;
  I, J: Integer;
  Temp: TGroup;
  B: Boolean;
begin
  Setlength(Result, 0);
  Table := GetTable(FileName, DB_TABLE_GROUPS);
  try
    if Table = nil then
      Exit;
    try
      Table.Active := True;
    except
      Exit;
    end;
    if Table.RecordCount > 0 then
    begin
      Table.First;
      repeat
        if UseInclude then
          if not Table.FieldByName('IncludeInQuickList').AsBoolean then
          begin
            Table.Next;
            Continue;
          end;
        N := Length(Result);
        Setlength(Result, N + 1);
        Result[N].GroupName := Table.FieldByName('GroupName').AsString;
        Result[N].GroupCode := Table.FieldByName('GroupCode').AsString;
        Result[N].GroupImage := nil;
        if LoadImages then
        begin
          if TBlobField(Table.FieldByName('GroupImage')) <> nil then
          begin
            BS := GetBlobStream(Table.FieldByName('GroupImage'), Bmread);
            try
              Result[N].GroupImage := TJpegImage.Create;
              Result[N].GroupImage.LoadfromStream(BS);
            finally
              F(BS);
            end;
          end;
        end;
        Result[N].GroupComment := Table.FieldByName('GroupComment').AsString;
        Result[N].GroupDate := Table.FieldByName('GroupDate').AsDateTime;
        Result[N].GroupFaces := Table.FieldByName('GroupFaces').AsString;
        Result[N].GroupAccess := Table.FieldByName('GroupAccess').AsInteger;
        Result[N].GroupKeyWords := Table.FieldByName('GroupKW').AsString;
        Result[N].AutoAddKeyWords := Table.FieldByName('GroupAddKW').AsBoolean;
        Result[N].RelatedGroups := Table.FieldByName('RelatedGroups').AsString;
        Result[N].IncludeInQuickList := Table.FieldByName('IncludeInQuickList').AsBoolean;
        Table.Next;
      until Table.Eof;
    end;
  finally
    FreeDS(Table);
  end;
  if DBKernel.Readbool('Options', 'SortGroupsByName', True) then
    for I := 1 to Length(Result) do
    begin
      B := True;
      for J := 0 to Length(Result) - 2 do
        if CompareStr(AnsiLowerCase(Result[J].GroupName), AnsiLowerCase(Result[J + 1].GroupName)) > 0 then
        begin
          Temp := Result[J];
          Result[J] := Result[J + 1];
          Result[J + 1] := Temp;
          B := False;
        end;
      if B then
        Break;
    end;
end;

Function GetRegisterGroupList(LoadImages : Boolean; UseInclude : Boolean = false) : TGroups;
begin
 Result:=GetRegisterGroupListW(dbname,LoadImages,UseInclude);
end;

Function GroupExistsInGroups(Group : TGroup; Groups : TGroups) : Boolean;
var
  i : integer;
begin
 Result:=False;
 For i:=0 to Length(Groups)-1 do
 if Groups[i].GroupCode=Group.GroupCode then
 begin
  Result:=True;
  Break;
 end;
end;

{$IFNDEF EXT}
function GetCommonGroups(GroupsList : TStringList) : String;
var
  i : integer;
  FArGroups : TArGroups;
  Res : TGroups;
begin
 Result:='';
 SetLength(Res,0);
 if GroupsList.Count=0 then exit;
 SetLength(FArGroups,GroupsList.Count);
 For i:=0 to GroupsList.Count-1 do
 FArGroups[i]:=EncodeGroups(GroupsList[i]);
 Res:=GetCommonGroups(FArGroups);
 Result:=CodeGroups(Res);
end;
{$ENDIF}

function GetCommonGroups(ArGroups : TArGroups) : TGroups;
var
  i, j : integer;
begin
 if Length(ArGroups)=0 then exit;
 Result:=CopyGroups(ArGroups[0]);
 for i:=1 to length(ArGroups)-1 do
 begin
  if length(ArGroups[i])=0 then
  begin
   SetLength(Result,0);
   Break;
  end;
  For j:=length(Result)-1 downto 0 do
  if not GroupExistsInGroups(Result[j],ArGroups[i]) then
  RemoveGroupFromGroups(Result,Result[j]);
  If Length(Result)=0 then Exit;
 end;
end;

Function CompareGroups(GroupsA, GroupsB : TGroups) : Boolean;
var
  i : integer;
begin
 Result:=True;
 for i:=0 to length(GroupsA)-1 do
 begin
  if not GroupExistsInGroups(GroupsA[i],GroupsB) then
  begin
   Result:=False;
   Break;
  end;
 end;
 for i:=0 to length(GroupsB)-1 do
 begin
  if not GroupExistsInGroups(GroupsB[i],GroupsA) then
  begin
   Result:=False;
   Break;
  end;
 end;
end;

Function CompareGroups(GroupsA, GroupsB : String) : Boolean;
var
  GA, GB : TGroups;
begin
 GA:=EncodeGroups(GroupsA);
 GB:=EncodeGroups(GroupsB);
 Result:=CompareGroups(GA,GB);
end;

Procedure ReplaceGroupsW(GroupsToDelete, GroupsToAdd : TGroups; var Groups : TGroups);
begin
 RemoveGroupsFromGroups(Groups,GroupsToDelete);
 AddGroupsToGroups(Groups,GroupsToAdd);
end;

Procedure ReplaceGroups(GroupsToDelete, GroupsToAdd : String; var Groups : String);
var
  GA, GB, GR : TGroups;
begin
 GA:=EncodeGroups(GroupsToDelete);
 GB:=EncodeGroups(GroupsToAdd);
 GR:=EncodeGroups(Groups);
 RemoveGroupsFromGroups(GR,GA);
 AddGroupsToGroups(GR,GB);
 Groups:=CodeGroups(GR);
end;

Function GroupWithCodeExistsInString(GroupCode, Groups : String) : Boolean;
var
  aGroups : TGroups;
  i : integer;
begin
 Result:=false;
 aGroups:=EncodeGroups(Groups);
 for i:=0 to Length(aGroups)-1 do
 if aGroups[i].GroupCode=GroupCode then
 begin
  Result:=true;
  Break;
 end;
end;

end.
