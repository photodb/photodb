unit UnitCDExportThread;

interface

uses
  Classes, Forms, UnitCDMappingSupport, Dolphin_DB, Language, uVistaFuncs, DB,
  UnitGroupsWork, UnitDBDeclare, CommonDBSupport, win32crc, SysUtils, uLogger,
  uFileUtils;

type
  TCDExportOptions = record
   ToDirectory : String;
   DeleteFiles : boolean;
   ModifyDB : boolean;     
   CreatePortableDB : boolean;
   OnEnd : TNotifyEvent;
  end;

type
  TCDExportThread = class(TThread)
  private
   Mapping: TCDIndexMapping;
   Options : TCDExportOptions; 
   DBRemapping : TDBFilePathArray;
   DS : TDataSet;
   ExtDS : TDataSet;
   DBUpdated : boolean;
   CRC : Cardinal;
   FRegGroups : TGroups;
   FGroupsFounded : TGroups;
   ImageSettings : TImageDBOptions;
   IntParam, CopiedSize : int64;
   StrParam : string;
   ProgressWindow : TForm;
   IsClosedParam : boolean;
    { Private declarations }
  protected
    procedure Execute; override;  
  public
    constructor Create(CreateSuspennded: Boolean; aMapping : TCDIndexMapping;
     aOptions : TCDExportOptions);
    procedure DoErrorDeletingFiles;
    procedure ShowError;
    procedure DoOnEnd;
    procedure ShowCopyError;
    procedure CreatePortableDB;
    procedure InitializeProgress;
    procedure OnProgress(Sender : TObject; var Info : TProgressCallBackInfo);
    procedure SetProgressAsynch;
    procedure IfBreakOperation;
    procedure DestroyProgress;
    procedure SetProgressOperation;
    procedure SetMaxPosition;         
    procedure SetPosition;
  end;

implementation

uses UnitSaveQueryThread, ProgressActionUnit;

{ TCDExportThread }

constructor TCDExportThread.Create(CreateSuspennded: Boolean;
  aMapping: TCDIndexMapping; aOptions : TCDExportOptions);
begin
 inherited create(true);
 Mapping:=aMapping;
 Options:=aOptions;
 if not CreateSuspennded then Resume;
end;

procedure TCDExportThread.CreatePortableDB;
begin
 CreateMobileDBFilesInDirectory(StrParam,Mapping.CDLabel);
end;

procedure TCDExportThread.DoErrorDeletingFiles;
begin
 MessageBoxDB(Handle,TEXT_MES_UNABLE_TO_DELETE_ORIGINAL_FILES,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TCDExportThread.DoOnEnd;
begin
 Options.OnEnd(Self);
end;

procedure TCDExportThread.InitializeProgress;
begin
 ProgressWindow:=GetProgressWindow(true);
 With ProgressWindow as TProgressActionForm do
 begin
  CanClosedByUser:=True;
  OneOperation:=false;
  OperationCount:=4;
  OperationPosition:=1;
  MaxPosCurrentOperation:=IntParam;
  xPosition:=0;
  Show;
 end;
end;

procedure TCDExportThread.Execute;
var
   i, j : integer;
   Directory : string;
   FS : TFileStream;
   Str : string;

procedure CopyRecordsW(OutTable, InTable: TDataSet; FileName : string; CRC : Cardinal);
var
  S,Folder : String;
begin
 InTable.FieldByName('Name').AsString:=OutTable.FieldByName('Name').AsString;
 InTable.FieldByName('FFileName').AsString:=FileName;
 {$R-}
 InTable.FieldByName('FolderCRC').AsInteger:=Integer(CRC);
 {$R+}
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


begin
 FreeOnTerminate:=true;

 try
 IsClosedParam:=false;
 CopiedSize:=0;
 IntParam:=Mapping.GetCDSize;
 Synchronize(InitializeProgress);
 FormatDir(Options.ToDirectory);
 IntParam:=1;
 Synchronize(SetProgressOperation);

 if not Mapping.CreateStructureToDirectory(Options.ToDirectory,OnProgress) then
 begin
  Synchronize(ShowCopyError); 
  Synchronize(DestroyProgress);
  Synchronize(DoOnEnd);
  exit;
 end;

 Mapping.PlaceMapFile(Options.ToDirectory);

 try
  FS:=TFileStream.Create(Options.ToDirectory+Mapping.CDLabel+'\AutoRun.inf',fmOpenWrite or fmCreate);
  Str:='[autorun]'#13#10;
  FS.Write(Str[1],Length(Str));
  Str:='icon='+Mapping.CDLabel+'.exe,0'#13#10;
  FS.Write(Str[1],Length(Str));
  Str:='open='+Mapping.CDLabel+'.exe'#13#10;
  FS.Write(Str[1],Length(Str));
  
  FS.Free;
 except
  on e : Exception do
  begin
   EventLog(':TCDExportThread::Execute()/ExtDS.Open throw exception: '+e.Message);
   StrParam:=e.Message;
   Synchronize(ShowError);
  end;
 end;
            
 IntParam:=2;
 Synchronize(SetProgressOperation);    
 IntParam:=0;
 Synchronize(SetPosition);

 if not IsClosedParam and Options.DeleteFiles then
 if not Mapping.DeleteOriginalStructure(OnProgress) then
 begin
  Synchronize(DoErrorDeletingFiles);
 end;
           
 IntParam:=3;
 Synchronize(SetProgressOperation);
 if not IsClosedParam and Options.ModifyDB then
 begin
  DBRemapping:=Mapping.GetDBRemappingArray;
  DS:=GetQuery;
  DBUpdated:=true;
  IntParam:=Length(DBRemapping)-1;
  Synchronize(SetMaxPosition);
  for i:=0 to Length(DBRemapping)-1 do
  begin
   IntParam:=i;
   Synchronize(SetPosition);   
   if IsClosedParam then break;

   Directory:=GetDirectory(DBRemapping[i].FileName);
   UnformatDir(Directory);
   CalcStringCRC32(AnsiLowerCase(Directory),crc);

   SetSQL(DS,'Update '+GetDefDBName+' Set FFileName = :FileName, FolderCRC = :FolderCRC Where ID = :ID');
   SetStrParam(DS,0,DBRemapping[i].FileName);
   SetIntParam(DS,1,Integer(Crc));
   SetIntParam(DS,2,DBRemapping[i].ID);
   try
    ExecSQL(DS);
   except
    DBUpdated:=false;
   end;
  end;
  FreeDS(DS);
 end;

 Directory:=GetDirectory(Options.ToDirectory);
 FormatDir(Directory);
 Directory:=Directory+Mapping.CDLabel+'\';
         
 IntParam:=4;
 Synchronize(SetProgressOperation);
 if not IsClosedParam and Options.CreatePortableDB then
 begin
  StrParam:=Directory;
  Synchronize(CreatePortableDB);
  if DBKernel.CreateDBbyName(Directory+Mapping.CDLabel+'.photodb')=0 then
  begin

   ImageSettings:=CommonDBSupport.GetImageSettingsFromTable(DBName);
   CommonDBSupport.UpdateImageSettings(Directory+Mapping.CDLabel+'.photodb',ImageSettings);

   DBRemapping:=Mapping.GetDBRemappingArray;
   ExtDS:=GetTable(Directory+Mapping.CDLabel+'.photodb', DB_TYPE_MDB);

   try
    ExtDS.Open;
   except
    on e : Exception do
    begin
     EventLog(':TCDExportThread::Execute()/ExtDS.Open throw exception: '+e.Message);
     StrParam:=e.Message;
     Synchronize(ShowError);
    end;
   end;
   if ExtDS.Active then
   begin
    DS:=GetQuery;
    DBUpdated:=true;
            
    IntParam:=Length(DBRemapping)-1;
    Synchronize(SetMaxPosition);
    
    for i:=0 to Length(DBRemapping)-1 do
    begin        
     IntParam:=i;
     Synchronize(SetPosition);  
     if IsClosedParam then break;

     Delete(DBRemapping[i].FileName,1,Length(Mapping.CDLabel)+5);

     Directory:=DBRemapping[i].FileName;
     if Pos('\',Directory)>0 then
     Directory:=GetDirectory(Directory) else Directory:='';
     UnformatDir(Directory);

     CalcStringCRC32(AnsiLowerCase(Directory),crc);

     SetSQL(DS,'Select * from '+GetDefDBName+'  Where ID = :ID');
     SetIntParam(DS,0,DBRemapping[i].ID);
     try
      DS.Open;
     except
      break;
     end;
     if DS.RecordCount=1 then
     begin
      ExtDS.Append;
      CopyRecordsW(DS,ExtDS,DBRemapping[i].FileName,CRC);
      ExtDS.Post;
     end;

    end;
    FreeDS(DS);
   end;
   FreeDS(ExtDS);
  end;

  Directory:=GetDirectory(Options.ToDirectory);
  FormatDir(Directory);
  Directory:=Directory+Mapping.CDLabel+'\';

  FRegGroups:=GetRegisterGroupList(True);
  CreateGroupsTableW(GroupsTableFileNameW(Directory+Mapping.CDLabel+'.photodb'));

  IntParam:=Length(FGroupsFounded)-1;
  Synchronize(SetMaxPosition);
  for i:=0 to length(FGroupsFounded)-1 do
  begin
   IntParam:=i;
   Synchronize(SetPosition);  
   if IsClosedParam then break;

   for j:=0 to length(FRegGroups)-1 do
   if FRegGroups[j].GroupCode=FGroupsFounded[i].GroupCode then
   begin
    AddGroupW(FRegGroups[j],GroupsTableFileNameW(Directory+Mapping.CDLabel+'.photodb'));
    Break;
   end;
  end;
 end;

 CommonDBSupport.TryRemoveConnection(Directory+Mapping.CDLabel+'.photodb',true);

 except
  on e : Exception do
  begin
   EventLog(':TCDExportThread::Execute() throw exception: '+e.Message);
   StrParam:=e.Message;
   Synchronize(ShowError);
  end;
 end;
 Synchronize(DestroyProgress);
 Synchronize(DoOnEnd);
end;

procedure TCDExportThread.ShowCopyError;
begin
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_UNABLE_TO_COPY_DISK,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TCDExportThread.ShowError;
begin
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,Format(TEXT_MES_UNKNOWN_ERROR_F,[StrParam]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
end;

procedure TCDExportThread.OnProgress(Sender: TObject;
  var Info: TProgressCallBackInfo);
begin
 CopiedSize:=CopiedSize+Info.Position;
 Synchronize(SetProgressAsynch);   
 Info.Terminate:=IsClosedParam;
end;

procedure TCDExportThread.SetProgressAsynch;
begin
 With ProgressWindow as TProgressActionForm do
 begin
  xPosition:=CopiedSize;
 end;     
 IfBreakOperation;
end;

procedure TCDExportThread.DestroyProgress;
begin
 (ProgressWindow as TProgressActionForm).WindowCanClose:=true;
 ProgressWindow.Release;
 if UseFreeAfterRelease then ProgressWindow.Free;
end;

procedure TCDExportThread.IfBreakOperation;
begin
 IsClosedParam:=(ProgressWindow as TProgressActionForm).Closed;
end;

procedure TCDExportThread.SetProgressOperation;
begin
 (ProgressWindow as TProgressActionForm).OperationPosition:=IntParam;
end;

procedure TCDExportThread.SetMaxPosition;
begin
 (ProgressWindow as TProgressActionForm).MaxPosCurrentOperation:=IntParam;
end;

procedure TCDExportThread.SetPosition;
begin
 (ProgressWindow as TProgressActionForm).xPosition:=IntParam;
end;

end.
