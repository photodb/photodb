unit UnitCleanUpThread;

interface

uses
  UnitDBKernel, windows, Messages, CommCtrl, Dialogs, Classes, DBGrids, DB,
  DBTables, SysUtils,ComCtrls, Graphics, jpeg, UnitINI, Exif, DateUtils,
  CommonDBSupport, win32crc, UnitCDMappingSupport, uLogger, uConstants;

type
  CleanUpThread = class(TThread)
  private
   FTable: TDataSet;
   fQuery : TDataSet;
   fReg : TBDRegistry;
   FText, fDBname : string;
   FPosition : Integer;
   FMaxPosition : integer;
   lastID : integer;
  procedure UpdateProgress;
  procedure UpdateMaxProgress;
  procedure UpdateText;
  procedure InitializeForm;
  procedure FinalizeForm;
  procedure RegisterThread;
  procedure UnRegisterThread;
  function GetDBRecordCount : integer;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure SavePosition;
  end;

  var   Termitating : boolean = false;
        Active : boolean = false;
      Share_Position, Share_MaxPosition : Integer;

implementation

uses Searching, dolphin_db, UnitDBCleaning, Language, FormManegerUnit;

{ CleanUpThread }

procedure CleanUpThread.Execute;
var
  i, int, position : integer;
  s, str_position, _sqlexectext, FromDB : string;
  Exif : TExif;
  crc : cardinal;
  folder : string;
  SetQuery : TDataSet;
  DateToAdd, aTime : TDateTime;
  IsDate, IsTime : boolean;
begin
 if FolderView then exit;
 FreeOnTerminate:=True;
 Synchronize(RegisterThread);
 if not DBKernel.TestDB(DBname) then exit;
 fDBname:=DBname;
 If Active then exit;
 Priority:=tpIdle;
 Termitating:=false;
 Sleep(10*60000); //delay 10 minutes after start
 Active:=true;
 if (GetDBType(fDBname)=DB_TYPE_BDE) then
 begin
  FTable:=GetTable;
  try
   FTable.Active:=true;
  except   
   on e : Exception do
   begin
    EventLog(':CleanUpThread::Execute() throw exception: '+e.Message);
    FTable.Free;
    exit;
   end;
  end;
  FTable.First;
 end;
 if (GetDBType(fDBname)=DB_TYPE_MDB) then
 FTable:=GetQuery; //no TABLEs with access - slow work

 fQuery:=GetQuery;

 fReg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 fReg.OpenKey(RegRoot,true);
 str_position:=fReg.ReadString('CleanPosition');
 if fReg.ValueExists('CleanLastID') then
 lastID:=fReg.ReadInteger('CleanLastID') else lastID:=0;
 position:=StrToIntDef(str_position,1);
 if Position<1 then Position:=1;
 FMaxPosition:=GetDBRecordCount;
 if Position>FMaxPosition then
 begin
  DBKernel.WriteBool('Options','AllowFastCleaning',False);
  Position:=1;
 end;
 fReg.free;

 if (GetDBType(fDBname)=DB_TYPE_BDE) then
 begin
  FTable.MoveBy(Position);
  FTable.RecNo:=Position;
 end;
 
 Share_Position:=0;

 Share_MaxPosition:=FMaxPosition;
 Synchronize(UpdateMaxProgress);
 Synchronize(InitializeForm);
 FPosition:=Position;
 while not {FTable.eof}FMaxPosition<FPosition do
 begin
  if not DBKernel.ReadBool('Options','AllowFastCleaning',False) then
  Sleep(2500);

  if fDBname<>DBname then
  begin
   break;
  end;
  if Termitating then break;
  _sqlexectext:='Select * from '+GetDefDBName+' where ID=(Select MIN(ID) from '+GetDefDBName+' where ID>'+IntToStr(lastID)+')';

  SetSQL(FTable,_sqlexectext);
  FTable.Open;

  FText:=format(TEXT_MES_CLEANING_ITEM,[Trim(FTable.FieldByName('Name').AsString)]);
  lastID:=FTable.FieldByName('ID').AsInteger;
  Synchronize(UpdateText);
  inc(Fposition);
  //Fposition:=FTable.RecNo;

  Share_Position:=FPosition;
  Synchronize(UpdateProgress);
  if fPosition mod 10 = 0 then SavePosition;
  if FTable=nil then break;
  if Termitating then break;

  try

   if (GetDBType(fDBname)=DB_TYPE_MDB) then
   begin
    if not StaticPath(FTable.FieldByName('FFileName').AsString) then
    begin
     Continue;
    end;
    
    folder:=GetDirectory(FTable.FieldByName('FFileName').AsString);

    folder:=AnsiLowerCase(folder);
    UnFormatDir(folder);
    CalcStringCRC32(AnsiLowerCase(folder),crc);
    int:=Integer(crc);
    if int<>FTable.FieldByName('FolderCRC').AsInteger then
    begin
     SetQuery:=GetQuery;
     SetSQL(SetQuery,'Update '+GetDefDBName+' Set FolderCRC=:FolderCRC Where ID='+IntToStr(FTable.FieldByName('ID').AsInteger));
     SetIntParam(SetQuery,0,crc);
     ExecSQL(SetQuery);

     FreeDS(SetQuery);
    end;
   end;


   if DBKernel.ReadBool('Options','DeleteNotValidRecords',True) then
   begin
    if not FileExists( FTable.FieldByName('FFileName').AsString) then
    begin
     if DBKernel.ReadBool('Options','DeleteNotValidRecords',True) then
     begin
      if (FTable.FieldByName('Rating').AsInteger=0) and (FTable.FieldByName('Access').AsInteger<>db_access_private) and (FTable.FieldByName('Comment').AsString='') and (FTable.FieldByName('KeyWords').AsString='') and (FTable.FieldByName('Groups').AsString='') and (FTable.FieldByName('IsDate').AsBoolean=False)  then
      begin
       if (GetDBType(fDBname)=DB_TYPE_MDB) then
       begin
        SetQuery:=GetQuery;
        SetSQL(SetQuery,'Delete from '+GetDefDBName+' Where ID='+IntToStr(FTable.FieldByName('ID').AsInteger));
        ExecSQL(SetQuery);
        FreeDS(SetQuery);
       end else
       begin
        FTable.Edit;
        FTable.Delete;
       end;
       Continue;
      end;
     end;
     fQuery.Active:=false;

     SetSQL(fQuery,'UPDATE '+GetDefDBName+' SET Attr='+inttostr(db_attr_not_exists)+' WHERE ID='+inttostr(FTable.FieldByName('ID').AsInteger));
     ExecSQL(fQuery);
    end else
    begin
     if (FTable.FieldByName('Attr').AsInteger=db_attr_not_exists) then
     SetAttr(FTable.FieldByName('ID').AsInteger,db_attr_norm);
    end;
   end
  except    
   on e : Exception do EventLog(':CleanUpThread::Execute() throw exception: '+e.Message);
  end;

  if Termitating then break;
  
  try
   s:=FTable.FieldByName('FFileName').AsString;
   If s<>AnsiLowerCase(s) then
   begin
    if (GetDBType(fDBname)=DB_TYPE_BDE) then
    begin
     FTable.Edit;
     FTable.FieldByName('FFileName').AsString:=AnsiLowerCase(s);
     FTable.Post;
     FlushBuffers(FTable);
    end else
    begin
     SetQuery:=GetQuery;
     SetSQL(SetQuery,'UPDATE '+GetDefDBName+' Set FFileName=:FFileName Where ID='+IntToStr(FTable.FieldByName('ID').AsInteger));
     SetStrParam(SetQuery,0,AnsiLowerCase(s));
     ExecSQL(SetQuery);
     FreeDS(SetQuery);
    end;
   end;
  except    
   on e : Exception do EventLog(':CleanUpThread::Execute() throw exception: '+e.Message);
  end;

  if Termitating then break;

  if DBKernel.ReadBool('Options','FixDateAndTime',True) then
  begin
   Exif := TExif.Create;
   try
    Exif.ReadFromFile(FTable.FieldByName('FFileName').AsString);
    if YearOf(Exif.Date)>2000 then
    if (FTable.FieldByName('DateToAdd').AsDateTime<>Exif.Date) or (FTable.FieldByName('aTime').AsDateTime<>Exif.Time) then
    begin
     if (GetDBType(fDBname)=DB_TYPE_BDE) then
     begin
      FTable.Edit;
      FTable.FieldByName('DateToAdd').AsDateTime:=Exif.Date;
      FTable.FieldByName('aTime').AsDateTime:=Exif.Time;
      FTable.FieldByName('IsDate').AsBoolean:=True;
      FTable.FieldByName('IsTime').AsBoolean:=True;
      FTable.Post;
      FlushBuffers(FTable);
     end else
     begin

       DateToAdd:=Exif.Date;
       aTime:=Exif.Time;
       IsDate:=True;
       IsTime:=True;
       _sqlexectext:='';
       _sqlexectext:=_sqlexectext+'DateToAdd=:DateToAdd,';
       _sqlexectext:=_sqlexectext+'aTime=:aTime,';
       _sqlexectext:=_sqlexectext+'IsDate=:IsDate,';
       _sqlexectext:=_sqlexectext+'IsTime=:IsTime';
       SetQuery:=GetQuery;
       SetSQL(SetQuery,'Update '+GetDefDBName+' Set '+_sqlexectext+' where ID = '+IntToStr(FTable.FieldByName('ID').AsInteger));
       SetDateParam(SetQuery,0,DateToAdd);
       SetDateParam(SetQuery,1,aTime);
       SetBoolParam(SetQuery,2,IsDate);
       SetBoolParam(SetQuery,3,IsTime);
       ExecSQL(SetQuery);
       FreeDS(SetQuery);
     end;
    end;
   except  
   on e : Exception do EventLog(':CleanUpThread::Execute() throw exception: '+e.Message);
   end;
   Exif.Free;
  end;

  if Termitating then break;
  try
  if DBKernel.ReadBool('Options','VerifyDublicates',False) then
  begin
   fQuery.Active:=false;

   if (GetDBType(dbname)=DB_TYPE_MDB) then
   begin
    FromDB:='(Select * from '+GetDefDBname+' where StrThCrc=:StrThCrc)';
    SetSQL(fQuery,'SELECT * FROM '+FromDB+' WHERE StrTh = :StrTh ORDER BY ID');
    SetIntParam(fQuery,0,StringCRC(FTable.FieldByName('StrTh').AsString));
    SetStrParam(fQuery,1,FTable.FieldByName('StrTh').AsString);
   end else
   begin
    SetSQL(fQuery,'SELECT * FROM '+GetDefDBname+' WHERE StrTh = :StrTh ORDER BY ID');
    SetStrParam(fQuery,0,FTable.FieldByName('StrTh').AsString);
   end;

{   SetSQL(fQuery,'SELECT * FROM '+GetDefDBName+' WHERE (StrTh = :str)');

   SetStrParam(fQuery,0,FTable.FieldByName('StrTh').AsString);
}
   if Termitating then Break;

   fQuery.Active:=true;
   fQuery.First;
   if fQuery.RecordCount>1 then
   begin
    for i:=1 to fQuery.RecordCount do
    begin
     if FTable=nil then break;
     if termitating then break;
     if fQuery.FieldByName('Attr').AsInteger<>db_attr_dublicate then
     SetAttr(fQuery.FieldByName('ID').AsInteger,db_attr_dublicate);
     fQuery.next;
    end;
   end;
   if (fQuery.RecordCount=1) and  fileexists(FTable.FieldByName('FFileName').AsString) and (FTable.FieldByName('Attr').AsInteger=db_attr_dublicate) then
   SetAttr(FTable.FieldByName('ID').AsInteger,db_attr_norm);
  end;
  except     
   on e : Exception do EventLog(':CleanUpThread::Execute() throw exception: '+e.Message);
  end;

  //FTable.next;
 end;
 SavePosition;
 FreeDS(FTable);
 FreeDS(fQuery);
 Synchronize(FinalizeForm);
 Active:=false;
 try
  Synchronize(UnRegisterThread);
 except  
   on e : Exception do EventLog(':CleanUpThread::Execute()/UnRegisterThread throw exception: '+e.Message);
 end;
end;

procedure CleanUpThread.FinalizeForm;
begin
 if DBCleaningForm<>nil then
 begin
  DBCleaningForm.Button3.Enabled:=True;
  DBCleaningForm.Button4.Enabled:=False;
  DBCleaningForm.DmProgress1.MaxValue:=1;
  DBCleaningForm.DmProgress1.Position:=0;
  DBCleaningForm.DmProgress1.Text:=TEXT_MES_CLEANING_STOPED;
 end;
end;

function CleanUpThread.GetDBRecordCount: integer;
var
  DS : TDataSet;
begin
 if (GetDBType(fDBname)=DB_TYPE_BDE) then
 begin
  Result:=FTable.RecordCount;
  exit;
 end;

 Result:=0;
 DS := GetQuery;
 SetSQL(DS,'SELECT count(*) as DB_Count from '+GetDefDBName);
 try
  DS.Open;
  Result:=DS.FieldByName('DB_Count').AsInteger;
 except
  Result:=0;
 end;
 FreeDS(DS);
end;

procedure CleanUpThread.InitializeForm;
begin
 if DBCleaningForm<>nil then
 begin
  DBCleaningForm.Button3.Enabled:=False;
  DBCleaningForm.Button4.Enabled:=True;
  DBCleaningForm.DmProgress1.MaxValue:=Share_MaxPosition;
  DBCleaningForm.DmProgress1.Position:=Share_Position;
 end;
end;

procedure CleanUpThread.RegisterThread;
Var
  TermInfo : TTemtinatedAction;
begin
 TermInfo.TerminatedPointer:=@Termitating;
 TermInfo.TerminatedVerify:=@Active;
 TermInfo.Options:=TA_INFORM_AND_NT;
 TermInfo.Owner:=Self;
 FormManager.RegisterActionCanTerminating(TermInfo);
end;

procedure CleanUpThread.SavePosition;
begin
 fReg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 fReg.OpenKey(RegRoot,true);
 fReg.WriteString('CleanPosition',IntToStr(fposition));
 fReg.WriteInteger('CleanLastID',LastID);
 fReg.free;
end;

procedure CleanUpThread.UnRegisterThread;
Var
  TermInfo : TTemtinatedAction;
begin
 TermInfo.TerminatedPointer:=@Termitating;
 TermInfo.TerminatedVerify:=@Active;
 TermInfo.Options:=TA_INFORM_AND_NT;
 TermInfo.Owner:=Self;
 FormManager.UnRegisterActionCanTerminating(TermInfo); 
end;

procedure CleanUpThread.UpdateMaxProgress;
begin
 if DBCleaningForm<>nil then
 begin
  DBCleaningForm.DmProgress1.MinValue:=0;
  DBCleaningForm.DmProgress1.MaxValue:=FMaxPosition;
 end;
end;

procedure CleanUpThread.UpdateProgress;
begin
 if DBCleaningForm<>nil then
 begin
  DBCleaningForm.DmProgress1.Position:=Fposition;
 end;
end;

procedure CleanUpThread.UpdateText;
begin
 if DBCleaningForm<>nil then
 begin
  DBCleaningForm.DmProgress1.Text:=FText;
 end;
end;

end.
