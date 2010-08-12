unit UnitSaveQueryThread;

interface

uses
  Windows, SysUtils, UnitGroupsWork, UnitExportThread, Classes, DB, Dolphin_DB,
  CommonDBSupport, Forms, win32crc, ActiveX, acWorkRes, Graphics, Dialogs,
  acDlgSelect, uVistaFuncs, UnitDBDeclare, uFileUtils;

type
  TSaveQueryThread = class(TThread)
  private
  FQuery : TDataSet;
  FTable : TDataSet;
  FFileName,DBFolder : String;
  FIntParam : Integer;
  FOwner : TForm;
  FRegGroups : TGroups;
  FGroupsFounded : TGroups;
  FolderSave : boolean;
  FSubFolders : boolean;
  FFileList : TArStrings;
  SaveToDBName : string;
  NewIcon : TIcon;
  OutIconName : string;
  OriginalIconLanguage : integer;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure SetMaxValue(Value : integer);
    procedure SetMaxValueA;
    procedure SetProgress(Value : integer);
    procedure SetProgressA;
    Procedure Done;
    procedure CopyRecordsW(OutTable, InTable: TDataSet);
    procedure LoadCustomDBName;
    procedure ReplaceIconAction;
  public
    constructor Create(CreateSuspennded: Boolean; Query : TDataSet; FileName : String; OwnerForm : TForm; SubFolders : boolean; FileList : TArStrings);
    Destructor Destroy; override;
  end;

  function CreateMobileDBFIlesInDirectory(Directory, SaveToDBName  : string) : boolean;

implementation

uses UnitSavingTableForm, UnitStringPromtForm, Language;

{ TSaveQueryThread }

function c_GetTempPath: String;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetTempPath(Sizeof(Buffer)-1,Buffer));
end;

function c_GetTempPathIco: String;
begin
 Result:=c_GetTempPath+'\$temp$.ico';
end;

function ReplaceIconForFileQuestion(out IcoTempName : string; out Language : integer) : TIcon;
var
  LoadIconDLG : TOpenDialog;
  FN : string;
  index : integer;
  ResIcoNameW, IcoTempNameW : PWideChar;
  update : DWORD;               
  ig     : TPIconGroup;

  function FindIconEx(FileName : string; index : integer) : boolean;
  var
    i : integer;
  begin
   Result:=false;
   try
    update:= BeginUpdateResourceW(StringToPWide(FileName), False, false);
    if update=0 then
    begin
     exit;
    end;
    ResIcoNameW:=GetNameIcon(update,index);
    Language:=-1;
    ig:=nil;
    for i:=0 to $FFFFF do
    begin
    if GetIconGroupResourceW(update, ResIcoNameW, i, ig) then
     begin
      Language:=i;
      break;
     end;
     if ig<>nil then
     begin
      FreeMem(ig); ig:=nil;
     end;
    end;
    if Language<>0 then
    SaveIconGroupResourceW(update,ResIcoNameW,Language,IcoTempNameW) else
    begin
     EndUpdateResourceW(update,true);
     exit;
    end;
    EndUpdateResourceW(update,true);
   except
    exit;
   end;
   Result:=true;
  end;

begin
 Result:=nil;
 if ID_YES=MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_DO_YOU_WANT_REPLACE_ICON_QUESTION,TEXT_MES_QUESTION,TD_BUTTON_YESNO,TD_ICON_QUESTION) then
 begin
  LoadIconDLG := TOpenDialog.Create(nil);
  LoadIconDLG.Filter:=TEXT_MES_ICONS_OPEN_MASK;
  if LoadIconDLG.Execute then
  begin
   FN:=LoadIconDLG.FileName;
   if GetEXT(FN)='ICO' then
   begin
    Result:=TIcon.Create;
    Result.LoadFromFile(FN);
   end;
   if (GetEXT(FN)='EXE') or (GetEXT(FN)='DLL') or (GetEXT(FN)='OCX') or (GetEXT(FN)='SCR') then
   begin
    if ChangeIconDialog(Application.Handle,FN,index) then
    begin
     IcoTempName:=c_GetTempPathIco+IntToStr(random(10000000))+'.ico';
     GetMem(IcoTempNameW,2048);
     IcoTempNameW:=StringToWideChar(IcoTempName,IcoTempNameW,2048);
     FindIconEx(FN,index);
     Result:=TIcon.Create;
     Result.LoadFromFile(IcoTempName);
     try
      DeleteFile(IcoTempName);
     except
     end;
    end;
   end;
  end;
 end;
end;

  function ReplaceIcon(FileName : string; IcoTempNameW : PWideChar; OriginalIconLanguage : integer) : boolean;
  var
    update : DWORD;
    ResIcoNameW : PWideChar;
  begin
   Result:=false;
   try               
    update:= BeginUpdateResourceW(StringToPWide(FileName), False);
    ResIcoNameW:=GetNameIcon(update,0);
    if not LoadIconGroupResourceW(update,ResIcoNameW,OriginalIconLanguage,IcoTempNameW) then
    begin
     EndUpdateResourceW(update,false);
     exit;
    end;
    EndUpdateResourceW(update,false);
   except
    exit;
   end;
   Result:=true;
  end;

function CreateMobileDBFilesInDirectory(Directory, SaveToDBName  : string) : boolean;
var
  NewIcon : TIcon;   
  IcoTempName : string;
  Language : integer;
begin
 FormatDir(Directory);
 CopyFile(PChar(Application.Exename),PChar(Directory+SaveToDBName+'.exe'),false);
 CopyFile(PChar(GetDirectory(Application.Exename)+'icons.dll'),PChar(Directory+'icons.dll'),false);

 NewIcon:=nil;
 try
  NewIcon := ReplaceIconForFileQuestion(IcoTempName,Language);
  if NewIcon<>nil then
  begin
   NewIcon.SaveToFile(IcoTempName);
   NewIcon.Free;

   ReplaceIcon(Directory+SaveToDBName+'.exe',StringToPWide(IcoTempName),Language);

   try
    if FileExists(IcoTempName) then
    DeleteFile(IcoTempName);
   except
   end;

  end;
  except
   try
    if NewIcon<>nil then NewIcon.Free;
   except
   end;
  exit;
 end;
end;

Constructor TSaveQueryThread.Create(CreateSuspennded: Boolean;  Query : TDataSet; FileName : String; OwnerForm : TForm; SubFolders : boolean; FileList : TArStrings);
begin
 inherited Create(True);
 FSubFolders:=SubFolders;
 FolderSave:=false;
 FFileName:=FileName;
 Fowner := OwnerForm;
 FFileList := FileList;
 if Query<>nil then
 FQuery := GetQuery else FQuery:=nil;
 FTable := nil;
 if Query<>nil then
 AssingQuery(Query, FQuery) else FolderSave:=true;
 If not CreateSuspennded then Resume;
end;

destructor TSaveQueryThread.Destroy;
begin

 inherited;
end;

procedure TSaveQueryThread.Done;
begin
 FOwner.OnCloseQuery:=nil;
 FOwner.Close;
end;


procedure TSaveQueryThread.Execute;
var
  i, j : integer;
  AndWhere, FromSQL : string;
  crc : Cardinal;
  ImageSettings : TImageDBOptions;

 Procedure DoExit;
 begin
  CoUninitialize;
  try
   FreeDS(FQuery);
   if FTable<>nil then
   FreeDS(FTable);
  except
  end;
  Synchronize(Done);
 end;

 procedure LoadLocation(Location : string);
 var
   LocationFolder : string;
 begin
  if FileExists(Location) then
  LocationFolder:=GetDirectory(Location) else LocationFolder:=Location;
  UnFormatDir(LocationFolder);
  FQuery:=GetQuery;
  if not FSubFolders then
  begin
   AndWhere:=' and not (FFileName like :FolderB) ';
   CalcStringCRC32(AnsiLowerCase(LocationFolder),crc);
   FromSQL:='(Select * from $DB$ where FolderCRC='+inttostr(Integer(crc))+')';
  end else
  begin
   FromSQL:='$DB$';
   AndWhere:='';
  end;
  if GetDBType=DB_TYPE_MDB then SetSQL(FQuery,'Select * From '+FromSQL+' where (FFileName Like :FolderA)'+AndWhere);
  FormatDir(LocationFolder);
  if FileExists(Location) then
  SetStrParam(FQuery,0,'%'+AnsiLowerCase(Location)+'%') else
  SetStrParam(FQuery,0,'%'+LocationFolder+'%');
  if not FSubFolders then
  SetStrParam(FQuery,1,'%'+LocationFolder+'%\%');
 end;

 procedure SaveLocation;
 begin
  try
   FQuery.Active:=True;
  except
   DoExit;
   Exit;
  end;
  SetMaxValue(FQuery.RecordCount);
  FQuery.First;
  Repeat
   if (FOwner as TSavingTableForm).FTerminating then Break;
   FTable.Append;
   CopyRecordsW(FQuery,FTable);
   FTable.Post;
   SetProgress(FQuery.RecNo);
   FQuery.Next;
  Until FQuery.Eof;
 end;


begin
 FreeOnTerminate:=True;

 RandomIze;
 CoInitialize(nil);
 SaveToDBName:=GetFileNameWithoutExt(FFileName);
 if SaveToDBName<>'' then
 if Length(SaveToDBName)>1 then
 if SaveToDBName[2]=':' then SaveToDBName:=SaveToDBName[1]+'_drive';
 Synchronize(LoadCustomDBName);
 if FQuery=nil then FormatDir(FFileName);
 if FQuery=nil then
 if DBKernel.CreateDBbyName(FFileName+SaveToDBName+'.photodb')<>0 then
  begin DoExit; Exit; end;

 ImageSettings:=CommonDBSupport.GetImageSettingsFromTable(DBName);
 CommonDBSupport.UpdateImageSettings(FFileName+SaveToDBName+'.photodb',ImageSettings);

 if FQuery<>nil then
 if DBKernel.CreateDBbyName(FFileName)<>0 then
  begin DoExit; Exit; end;

 if FQuery<>nil then
 FTable:=GetTable(FFileName,DB_TABLE_IMAGES) else
 FTable:=GetTable(GetDirectory(FFileName)+SaveToDBName+'.photodb',DB_TABLE_IMAGES);

 try
  FTable.Active:=True;
 except
  DoExit;
  Exit;
 end;

 if FileExists(FFileName) then DBFolder:=GetDirectory(FFileName) else DBFolder:=FFileName;

 Setlength(FGroupsFounded,0);

 if FQuery=nil then
 begin
  for i:=0 to Length(FFileList)-1 do
  begin
   LoadLocation(FFileList[i]);
   SaveLocation;
  end;
 end else
 begin
  SaveLocation;
 end;

 SetMaxValue(length(FGroupsFounded));
 FRegGroups:=GetRegisterGroupList(True);
 CreateGroupsTableW(GroupsTableFileNameW(GetDirectory(FFileName)+SaveToDBName+'.photodb'));

 For i:=0 to length(FGroupsFounded)-1 do
 begin             
  if (FOwner as TSavingTableForm).FTerminating then Break;
  SetProgress(i);
  for j:=0 to length(FRegGroups)-1 do
  if FRegGroups[j].GroupCode=FGroupsFounded[i].GroupCode then
  begin
   AddGroupW(FRegGroups[j],GroupsTableFileNameW(GetDirectory(FFileName)+SaveToDBName+'.photodb'));
   Break;
  end;
 end;
 
 if FolderSave then
 begin
  FormatDir(FFileName);
  CopyFile(PChar(Application.Exename),PChar(GetDirectory(FFileName)+SaveToDBName+'.exe'),false);
  CopyFile(PChar(GetDirectory(Application.Exename)+'icons.dll'),PChar(GetDirectory(FFileName)+'icons.dll'),false);
  try
   Synchronize(ReplaceIconAction);
   if NewIcon<>nil then
   begin

    NewIcon.SaveToFile(OutIconName);
    NewIcon.Free;

    ReplaceIcon(GetDirectory(FFileName)+SaveToDBName+'.exe',StringToPWide(OutIconName),OriginalIconLanguage);
    try
     if FileExists(OutIconName) then
     DeleteFile(OutIconName);
    except
    end;
   end;
   except
    DoExit;
    try
     if NewIcon<>nil then NewIcon.Free;
    except
    end;
   exit;
  end;
 end;
 
 DoExit;
end;

procedure TSaveQueryThread.SetMaxValue(Value: integer);
begin
 FIntParam:=Value;
 Synchronize(SetMaxValueA);
end;

procedure TSaveQueryThread.SetMaxValueA;
begin
 (FOwner as TSavingTableForm).DmProgress1.MaxValue:=FIntParam;
end;

procedure TSaveQueryThread.SetProgress(Value: integer);
begin
 FIntParam:=Value;
 Synchronize(SetProgressA);
end;

procedure TSaveQueryThread.SetProgressA;
begin
 (FOwner as TSavingTableForm).DmProgress1.Position:=FIntParam;
end;

procedure TSaveQueryThread.CopyRecordsW(OutTable, InTable: TDataSet);
var
  S,Folder : String;
  crc : Cardinal;
begin
 InTable.FieldByName('Name').AsString:=OutTable.FieldByName('Name').AsString;
 if FolderSave then
 begin
  //subfolder crc neened
  s:=OutTable.FieldByName('FFileName').AsString;
  Delete(s,1,Length(DBFolder));
  InTable.FieldByName('FFileName').AsString:=s;
   
  if Pos('\',s)>0 then
  Folder:=GetDirectory(s) else Folder:='';
  UnformatDir(Folder);
  CalcStringCRC32(Folder,crc);
 {$R-}
 InTable.FieldByName('FolderCRC').AsInteger:=crc;
 {$R+}

 end else
 begin
  InTable.FieldByName('FFileName').AsString:=OutTable.FieldByName('FFileName').AsString;
  if GetDBType=DB_TYPE_MDB then
  InTable.FieldByName('FolderCRC').AsInteger:=OutTable.FieldByName('FolderCRC').AsInteger;
 end;
 InTable.FieldByName('Comment').AsString:=OutTable.FieldByName('Comment').AsString;
 InTable.FieldByName('DateToAdd').AsDateTime:=OutTable.FieldByName('DateToAdd').AsDateTime;
 InTable.FieldByName('Owner').AsString:=OutTable.FieldByName('Owner').AsString;
 InTable.FieldByName('Rating').AsInteger:=OutTable.FieldByName('Rating').AsInteger;
 InTable.FieldByName('Thum').AsVariant:=OutTable.FieldByName('Thum').AsVariant;
 InTable.FieldByName('FileSize').AsInteger:=OutTable.FieldByName('FileSize').AsInteger;
 InTable.FieldByName('KeyWords').AsString:=OutTable.FieldByName('KeyWords').AsString;
 InTable.FieldByName('StrTh').AsString:=OutTable.FieldByName('StrTh').AsString;
 If fileexists(InTable.FieldByName('FFileName').AsString) then
 InTable.FieldByName('Attr').AsInteger:=db_attr_norm else
 InTable.FieldByName('Attr').AsInteger:=db_attr_not_exists;
 InTable.FieldByName('Attr').AsInteger:=OutTable.FieldByName('Attr').AsInteger;
 InTable.FieldByName('Collection').AsString:=OutTable.FieldByName('Collection').AsString;
 if OutTable.FindField('Groups')<>nil then
 begin
  S:=OutTable.FieldByName('Groups').AsString;
  AddGroupsToGroups(FGroupsFounded,EnCodeGroups(S));
  InTable.FieldByName('Groups').AsString:=S;
 end;
 InTable.FieldByName('Groups').AsString:=OutTable.FieldByName('Groups').AsString;
 InTable.FieldByName('Access').AsInteger:=OutTable.FieldByName('Access').AsInteger;
 InTable.FieldByName('Width').AsInteger:=OutTable.FieldByName('Width').AsInteger;
 InTable.FieldByName('Height').AsInteger:=OutTable.FieldByName('Height').AsInteger;
 InTable.FieldByName('Colors').AsInteger:=OutTable.FieldByName('Colors').AsInteger;
 InTable.FieldByName('Rotated').AsInteger:=OutTable.FieldByName('Rotated').AsInteger;
 InTable.FieldByName('IsDate').AsBoolean:=OutTable.FieldByName('IsDate').AsBoolean;
 if OutTable.FindField('Include')<>nil then
 InTable.FieldByName('Include').AsBoolean:=OutTable.FieldByName('Include').AsBoolean;
 if OutTable.FindField('aTime')<>nil then
 InTable.FieldByName('aTime').AsDateTime:=OutTable.FieldByName('aTime').AsDateTime;
 if OutTable.FindField('IsTime')<>nil then
 InTable.FieldByName('IsTime').AsBoolean:=OutTable.FieldByName('IsTime').AsBoolean;
 if OutTable.FindField('Links')<>nil then
 InTable.FieldByName('Links').AsString:=OutTable.FieldByName('Links').AsString;

end;

procedure TSaveQueryThread.LoadCustomDBName;
var
  s : string;
begin
 s:=SaveToDBName;
 if PromtString(TEXT_MES_DB_NAME,TEXT_MES_ENTER_CUSTOM_DB_NAME,s) then
 if s<>'' then
 if ValidDBPath('x:\'+s+'.photodb') then
 SaveToDBName:=s;
end;

procedure TSaveQueryThread.ReplaceIconAction;
begin
 NewIcon:=ReplaceIconForFileQuestion(OutIconName,OriginalIconLanguage);
end;

end.
