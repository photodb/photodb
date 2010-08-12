unit UnitUpdateDBThread;

interface

uses
   ReplaceForm, UnitDBKernel, Windows, dolphin_db, Classes, UnitUpdateDB, Forms,
  SysUtils, DB, GraphicCrypt, dialogs, Exif, DateUtils, CommonDBSupport,
  win32crc, Jpeg, UnitUpdateDBObject, uVistaFuncs, uLogger, uFileUtils,
  UnitDBDeclare;

type
  TFileProcessProcedureOfObject = procedure(var FileName : string) of object;

type
  UpdateDBThread = class(TThread)
  private
  FFiles : TArStrings;
  FOnDone : TNotifyEvent;
  fTerminating : PBoolean;
  fPause : PBoolean;
  StringParam : String;
  IntResult, IntIDResult : Integer;
  FCurrentImageDBRecord : TImageDBRecordA;
  fSender : TUpdaterDB;
  ResArray : TImageDBRecordAArray;
  IDParam : integer;
  NameParam : String;
  fInfo : TAddFileInfoArray;
  FUseFileNameScaning : Boolean;
  FileNumber : integer;
  Time, Date: TDateTime;
  IsTime : Boolean;
  FNoLimit : boolean;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    procedure LimitError;
    Procedure DoOnDone;
    procedure ExecuteReplaceDialog;
    procedure AddAutoAnswer;
    procedure DoExit;
    procedure SetImages;
    procedure DoEventReplace(ID : Integer; Name : String);
    procedure DoEventReplaceSynch;
    procedure UpdateCurrent;
    procedure CryptFileWithoutPass;
    function Res : TImageDBRecordA;
    procedure FileProcessed;
    constructor Create(CreateSuspennded: Boolean; Sender : TUpdaterDB;
      FileNames : TArStrings; Info : TAddFileInfoArray; OnDone : TNotifyEvent;
      AutoAnswer : Integer; UseFileNameScaning : Boolean; Terminating,
      Pause: PBoolean; NoLimit : boolean = false);
  end;

type TValueObject = Class(TObject)
  private
    FTIntValue: Integer;
    FSTStrValue : TStrings;
    FTBoolValue: Boolean;
    procedure SetTIntValue(const Value: Integer);
    procedure SetTStrValue(const Value: TStrings);
    procedure SetTBoolValue(const Value: Boolean);
    public
       Constructor Create;
       Destructor Destroy; override;
    published
    Property TIntValue : Integer read FTIntValue Write SetTIntValue;
    Property TStrValue : TStrings read FSTStrValue Write SetTStrValue;
    Property TBoolValue : Boolean read FTBoolValue Write SetTBoolValue;
    end;


type
  DirectorySizeThread = class(TThread)
  private
  FDirectory, StrParam : string;
  FObject : TValueObject;
  FOnDone : TNotifyEvent;
  FTerminating : PBoolean;
  IntParam : integer;
  FOnFileFounded : TFileFoundedEvent;
  FProcessFileEvent : TFileProcessProcedureOfObject;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; Directory : string;
    OnDone : TNotifyEvent; Terminating: PBoolean;
    OnFileFounded : TFileFoundedEvent; ProcessFileEvent : TFileProcessProcedureOfObject = nil);
    procedure DoOnDone;
    procedure DoFileProcessed;  
    procedure DoOnFileFounded;
    function GetDirectory(DirectoryName: string; var Files : TStrings; Terminating : PBoolean):integer;
  end;

  var
    ShowMessageAboutLimit : boolean;
    CryptFileWithoutPassChecked : Boolean;
    fAutoAnswer : integer = -1;

function SQL_AddFileToDB(Path : string; Crypted : boolean; JPEG : TJpegImage; ImTh, KeyWords, Comment, Password : String; OrWidth, OrHeight : integer; var Date, Time : TDateTime; var IsTime : Boolean; Rating : integer = 0; Rotated : integer = DB_IMAGE_ROTATED_0; Links : string = ''; Access : integer = 0; Groups : string = '') : boolean;

implementation

Uses Language;

{ UpdateDBThread }

constructor UpdateDBThread.Create(CreateSuspennded: Boolean; Sender : TUpdaterDB;
  FileNames : TArStrings; Info : TAddFileInfoArray; OnDone: TNotifyEvent;
  AutoAnswer : Integer; UseFileNameScaning : Boolean; Terminating,
  Pause: PBoolean; NoLimit : boolean = false);
var
  i : integer;
begin
  Inherited Create(True);

  SetLength(FFiles,Length(FileNames));
  for i:=0 to Length(FileNames)-1 do
  FFiles[i]:=FileNames[i];
  SetLength(fInfo,Length(Info));
  for i:=0 to Length(Info)-1 do
  begin
   fInfo[i]:=Info[i];
   fInfo[i].KeyWords:='';
  end;
  
  FOnDone := OnDone;
  fTerminating := Terminating;
  fPause := Pause;
  fAutoAnswer := AutoAnswer;
  FSender := Sender;
  FNoLimit := NoLimit;
  FUseFileNameScaning:=UseFileNameScaning;
  if not CreateSuspennded then Resume;
end;

procedure UpdateDBThread.DoOnDone;
begin
  if Assigned(FOnDone) then FOnDone(Self);
end;

function SQL_AddFileToDB(Path : string; Crypted : boolean; JPEG : TJpegImage; ImTh, KeyWords, Comment, Password : String; OrWidth, OrHeight : integer; var Date, Time : TDateTime; var IsTime : Boolean; Rating : integer = 0; Rotated : integer = DB_IMAGE_ROTATED_0; Links : string = ''; Access : integer = 0; Groups : string = '') : boolean;
var
  Exif : TExif;
  sql, mdbfields, mdbvalues : string;
  fQuery : TDataSet;
  M : TMemoryStream;
  folder : string;
  CRC,StrThCrc : Cardinal;
begin
 Result:=false;
 if DBKernel.ReadBool('Options','NoAddSmallImages',true) then
 begin
  if (DBKernel.ReadInteger('Options','NoAddSmallImagesWidth',64)>OrWidth) or
  (DBKernel.ReadInteger('Options','NoAddSmallImagesHeight',64)>OrHeight) then
  begin
   exit;
   //small images - no photos
  end;
 end;
 fQuery := GetQuery;
 if GetDBType=DB_TYPE_MDB then
 begin
  mdbfields:=',FolderCRC,StrThCRC';       //
  mdbvalues:=',:FolderCRC,:StrThCRC';         //
 end;
 sql:='insert into $DB$';
 sql:=sql+' (Name,FFileName,FileSize,DateToAdd,Thum,StrTh,KeyWords,Owner,Collection,Access,Width,Height,Comment,Attr,Rotated,Rating,IsDate,Include,aTime,IsTime,Links,Groups'+mdbfields+') ';
 sql:=sql+' values (:Name,:FFileName,:FileSize,:DateToAdd,:Thum,:StrTh,:KeyWords,:Owner,:Collection,:Access,:Width,:Height,:Comment,:Attr,:Rotated,:Rating,:IsDate,:Include,:aTime,:IsTime,:Links,:Groups'+mdbvalues+') ';
 SetSQL(fQuery,sql);
 SetStrParam(fQuery,0,ExtractFileName(Path));
 SetStrParam(fQuery,1,AnsiLowerCase(Path));
 SetIntParam(fQuery,2,Dolphin_DB.GetFileSize(Path));
  Exif := TExif.Create;
  Date:=0;
  try
   Exif.ReadFromFile(Path);
   Date:=Exif.Date;
   Time:=Exif.Time;
  except
  end;
  Exif.Free;
  SetBoolParam(fQuery,16,true);
  if Date=0 then
  begin
   SetDateParam(fQuery,'DateToAdd',Now);
   SetDateParam(fQuery,'aTime',TimeOf(Now));
   SetBoolParam(fQuery,19,false);
  end else
  begin
   SetDateParam(fQuery,'DateToAdd',Date);
   SetDateParam(fQuery,'aTime',TimeOf(Time));
   SetBoolParam(fQuery,19,true);
  end;
  IsTime:=GetBoolParam(fQuery,19);
  if Crypted then
  begin
   M:=CryptGraphicImage(Jpeg,Password);
   if M<>nil then
   begin
    LoadParamFromStream(fQuery,4,M,ftBlob);
    M.Free;
   end;
  end else
  AssignParam(fQuery,4,Jpeg);
  SetStrParam(fQuery,5,ImTh);
  SetStrParam(fQuery,6,KeyWords);
  SetStrParam(fQuery,7,InstalledUserName);
  SetStrParam(fQuery,8,'PhotoAlbum');
  SetIntparam(fQuery,9,Access);
  SetIntparam(fQuery,10,OrWidth);
  SetIntparam(fQuery,11,OrHeight);

  SetStrParam(fQuery,12,Comment);
  SetIntParam(fQuery,13,db_attr_norm);
  SetIntParam(fQuery,14,Rotated);
  SetIntParam(fQuery,15,Rating);
  SetBoolParam(fQuery,17,true);

  SetStrParam(fQuery,20,Links);  
  SetStrParam(fQuery,21,Groups);

  if GetDBType=DB_TYPE_MDB then
  begin
   folder:=GetDirectory(AnsiLowerCase(Path));
   UnFormatDir(folder);
   CalcStringCRC32(folder,crc);
   {$R-}
   SetIntParam(fQuery,22,crc);
 
   CalcStringCRC32(ImTh,StrThCrc);
   SetIntParam(fQuery,23,StrThCrc);
  end;
  try
   ExecSQL(fQuery);
   if LastInseredID=0 then
   begin
    if GetDBType=DB_TYPE_MDB then
    SetSQL(fQuery,Format('Select ID from (Select * from $DB$ where FolderCRC=%d) where FFileName like :FFileName',[Integer(crc)])) else
    SetSQL(fQuery,Format('Select ID from $DB$ where FFileName like :FFileName',[]));
    SetStrParam(fQuery,0,Delnakl(normalizeDBStringLike(NormalizeDBString(AnsiLowerCase(Path)))));
    try
     fQuery.Open;
     if fQuery.RecordCount>0 then
     LastInseredID:=fQuery.FieldByName('ID').AsInteger;
    except
    end;
   end else inc(LastInseredID);
   except
  end;
  FreeDS(fQuery);
  Result:=true;
 end;

procedure UpdateDBThread.Execute;
var
  DemoTable : TDataSet;
  fQuery : TDataSet;
  Counter : integer;
  AutoAnswerSetted : boolean;
  ModuleAddress : Pointer;
  BooleanFunct : TBooleanFunction;

 Procedure AddFileToDB;
 begin
  if SQL_AddFileToDB(FFiles[FileNumber],Res.Crypt,Res.Jpeg,
  res.ImTh ,FInfo[FileNumber].KeyWords, FInfo[FileNumber].Comment,Res.Password,
  res.OrWidth,res.OrHeight,Date,Time,IsTime) then
  Synchronize(SetImages) else begin ResArray[FileNumber].Jpeg.Free; ResArray[FileNumber].Jpeg:=nil; end;
 end;

 Function GetRecordsCount : integer;
 begin
   DemoTable:=GetQuery(dbname);
   SetSQL(DemoTable,'Select Count(*) as CountOfRecs from $DB$');
   DemoTable.Open;
   Result:=Demotable.FieldByName('CountOfRecs').AsInteger;
   FreeDS(Demotable);
 end;

begin
 FreeOnTerminate:=true;
 FileNumber:=0;
 AutoAnswerSetted:=false;

 if not DBInDebug then     
 if not Emulation then
 if not FNoLimit then
 begin

  if DBKernel.GetDemoMode then
  begin
   if GetRecordsCount>LimitDemoRecords then
   begin
    if ShowMessageAboutLimit then
    begin
     Synchronize(limiterror);
     ShowMessageAboutLimit:=false;
    end;
    EventLog(':Limit of records! --> exit updating DB');
    DoExit;
    Exit;
   end;
  end;    

  ModuleAddress:=GetProcAddress(KernelHandle,'GetWindowsName');
  if ModuleAddress=nil then
  begin     
   EventLog(':UpdateDBThread::Execute()/GetWindowsName not found!');
   DoExit;
   exit;
  end;
  @BooleanFunct:=ModuleAddress;

  try
   if BooleanFunct then
   begin
    if GetRecordsCount>LimitDemoRecords then
    begin
     EventLog(':Limit of records! --> exit updating DB');
     DoExit;
     exit;
    end;
   end;
  except    
   on e : Exception do
   begin
    EventLog(':UpdateDBThread::Execute()/BooleanFunct throw exception: '+e.Message);
    // BooleanFunct Error
    DoExit;
    exit;
   end;
  end;

 end;

 ResArray:=getimageIDWEx(FFiles,FUseFileNameScaning);

 for Counter:=1 to Length(FFiles) do
 begin

 If Res.Jpeg<>nil then
 begin

 If (Res.count=1) and ((Res.Attr[0]=db_attr_not_exists) or (res.FileNames[0]<>FFiles[FileNumber])) and (AnsiLowerCase(res.FileNames[0])=AnsiLowerCase(FFiles[FileNumber])) then
 begin
  Synchronize(FileProcessed);
  UpdateMovedDBRecord(res.ids[0],FFiles[FileNumber]);
  DoEventReplace(Res.Ids[0],FFiles[FileNumber]);
//  DoExit;
//  Exit;
 end;

 IntResult:=Result_invalid;

 If (Res.count>1) then
 begin
  If not ((fAutoAnswer=Result_skip_all) or (fAutoAnswer=Result_add_all)) then
  begin
   FCurrentImageDBRecord:=res;
   StringParam:=res.ImTh;
   Synchronize(ExecuteReplaceDialog);
   Case IntResult of
     Result_invalid:
     Begin
//      DoExit;
//      exit;
     End;
     Result_skip:
     Begin
//      DoExit;
//      exit;
     End;
     Result_Add_All:
     Begin
      FAutoAnswer:=Result_Add_all;
      Synchronize(AddAutoAnswer);
     End;
     Result_skip_all:
     begin
      FAutoAnswer:=Result_skip_all;
      AutoAnswerSetted:=true;
      Synchronize(AddAutoAnswer);
//      DoExit;
//      exit;
     end;
     Result_replace:
     begin
      UpdateMovedDBRecord(IntIDResult,FFiles[FileNumber]);
      DoEventReplace(IntIDResult,FFiles[FileNumber]);
//      DoExit;
//      exit;
     end;
   Result_Add:
    begin
     AddFileToDB;
     fQuery:=GetQuery;
     SetSQL(fQuery,'Update $DB$ Set Attr=:Attr Where StrTh=:s');
     SetIntParam(fQuery,0,db_attr_dublicate);
     SetStrParam(fQuery,1,Res.ImTh);
     try
      ExecSQL(fQuery);
     except    
      on e : Exception do EventLog(':UpdateDBThread::Execute()/Result_Add/ExecSQL throw exception: '+e.Message);
     end;
     FreeDS(fQuery);
//     DoExit;
//     exit;
    end;
  Result_Delete_File:
   begin
    DeleteFile(FFiles[FileNumber]);
//    DoExit;
//    exit;
   end;
   Result_Replace_And_Del_Dublicates:
    begin
      UpdateMovedDBRecord(IntIDResult,FFiles[FileNumber]);
      DoEventReplace(IntIDResult,FFiles[FileNumber]);
      fQuery:=GetQuery;
      SetSQL(fQuery,'DELETE FROM $DB$ WHERE StrTh=:s and ID<>:ID');
      SetStrParam(fQuery,0,Res.ImTh);
      SetIntParam(fQuery,1,IntIDResult);
      try
       ExecSQL(fQuery);
      except    
      on e : Exception do EventLog(':UpdateDBThread::Execute()/Result_Replace_And_Del_Dublicates/ExecSQL throw exception: '+e.Message);
      end;
      FreeDS(fQuery);
//      DoExit;
//      exit;
     end;
    end;
//   DoExit;
//   Exit;
  end else
  begin
  if FAutoAnswer=Result_replace_All then
   begin
    UpdateMovedDBRecord(IntIDResult,FFiles[FileNumber]);
    DoEventReplace(IntIDResult,FFiles[FileNumber]);
//    DoExit;
//    exit;
   end;
   if FAutoAnswer=Result_skip_all then
   begin
//    DoExit;
//    exit;
   end;
  if FAutoAnswer=Result_add_All then
  begin
   AddFileToDB;
   fQuery:=GetQuery;
   SetSQL(fQuery,'Update $DB$ Set Attr = :Attr Where StrTh = :s');
   SetIntParam(fQuery,0,db_attr_dublicate);
   SetStrParam(fQuery,1,Res.ImTh);
   try
    ExecSQL(fQuery);
   except
    on e : Exception do EventLog(':UpdateDBThread::Execute()/Result_add_All/ExecSQL throw exception: '+e.Message);
   end;
   fQuery.Free;
//   DoExit;
//   exit;
  end;
  end;
 end;

 If (Res.count=1) and (AnsiLowerCase(res.FileNames[0])<>AnsiLowerCase(FFiles[FileNumber])) then
 begin

  If not ((fAutoAnswer=Result_skip_all) or (fAutoAnswer=Result_replace_All) or (fAutoAnswer=Result_add_all)) then
  begin
   FCurrentImageDBRecord:=res;
   StringParam:=res.ImTh;
   Synchronize(ExecuteReplaceDialog);


  Case IntResult of
   Result_invalid:
    Begin
//     DoExit;
//     exit;
    End;
   Result_skip:
    Begin
//     DoExit;
//     exit;
    End;
   Result_skip_all:
    begin
     FAutoAnswer:=Result_skip_all;
     Synchronize(AddAutoAnswer);
     AutoAnswerSetted:=true;
//     DoExit;
//     exit;
    end;
   Result_Delete_File:
    begin
     DeleteFile(FFiles[FileNumber]);
//     DoExit;
//     exit;
    end;
   Result_replace_all:
    begin
     FAutoAnswer:=Result_replace_All;
     Synchronize(AddAutoAnswer);
     AutoAnswerSetted:=true;
     UpdateMovedDBRecord(res.ids[0],FFiles[FileNumber]);
     DoEventReplace(res.ids[0],FFiles[FileNumber]);
//     DoExit;
//     exit;
    end;
   Result_replace:
    begin
     UpdateMovedDBRecord(res.ids[0],FFiles[FileNumber]);
     if res.UsedFileNameSearch then
     begin
      if res.ChangedRotate[0] then
      SetRotate(res.ids[0],DB_IMAGE_ROTATED_0);
      Synchronize(UpdateCurrent);
     end;
     DoEventReplace(res.ids[0],FFiles[FileNumber]);
//     DoExit;
//     exit;
    end;
   Result_Add:
    begin
     AddFileToDB;
     fQuery:=GetQuery;
     SetSQL(fQuery,'Update $DB$ Set Attr=:Attr Where StrTh=:s');
     SetIntParam(fQuery,0,db_attr_dublicate);
     SetStrParam(fQuery,1,Res.ImTh);
     try
      ExecSQL(fQuery);
     except
     end;
     FreeDS(fQuery);
//     DoExit;
//     exit;
    end;
   Result_Add_All:
    begin
     FAutoAnswer:=Result_Add_All;
     Synchronize(AddAutoAnswer);
     AutoAnswerSetted:=true;
     AddFileToDB;
     fQuery:=GetQuery;
     SetSQL(fQuery,'Update $DB$ Set Attr=:Attr Where StrTh=:s');
     SetIntParam(fQuery,0,db_attr_dublicate);
     SetStrParam(fQuery,1,Res.ImTh);
     try
      ExecSQL(fQuery);
     except  
      on e : Exception do EventLog(':UpdateDBThread::Execute()/Result_Add_All2/ExecSQL throw exception: '+e.Message);
     end;
     FreeDS(fQuery);
//     DoExit;
//     exit;
    end;

   end;

  end;

  if not AutoAnswerSetted then
  begin
   if FAutoAnswer=Result_replace_All then
   begin
    UpdateMovedDBRecord(res.ids[0],FFiles[FileNumber]);
    DoEventReplace(res.ids[0],FFiles[FileNumber]);
   end;
   if FAutoAnswer=Result_skip_all then
   begin
   end;
   if FAutoAnswer=Result_Add_All then
   begin
    AddFileToDB;
    fQuery:=GetQuery;
    SetSQL(fQuery,'Update $DB$ Set Attr=:Attr Where StrTh=:s');
    SetIntParam(fQuery,0,db_attr_dublicate);
    SetStrParam(fQuery,1,Res.ImTh);
    try
     ExecSQL(fQuery);
    except   
      on e : Exception do EventLog(':UpdateDBThread::Execute()/Result_replace_All3/ExecSQL throw exception: '+e.Message);
    end;
    FreeDS(fQuery);
   end;
  end;
 end;
 AutoAnswerSetted:=false;


 If Res.count=0 then
 begin
  AddFileToDB;
//  DoExit;
//  Exit;
 end;

 end else
 begin
  Synchronize(CryptFileWithoutPass);
 end;
 if Res.Jpeg<>nil then
 Res.Jpeg.free;
 inc(FileNumber);
 end;
// Synchronize(SetImages);


 Synchronize(DoOnDone);

end;

procedure UpdateDBThread.LimitError;
begin
 MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_LIMIT_RECS,[inttostr(LimitDemoRecords)]),TEXT_MES_NEEDS_ACTIVATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
end;

procedure UpdateDBThread.ExecuteReplaceDialog;
begin
 if DBReplaceForm=nil then
 Application.CreateForm(TDBReplaceForm, DBReplaceForm);
 DBReplaceForm.ExecuteToAdd(FFiles[FileNumber],0,StringParam,@IntResult,@IntIDResult,FCurrentImageDBRecord);
end;

procedure UpdateDBThread.AddAutoAnswer;
begin
 Fsender.AutoAnswer:=FAutoAnswer;
end;

procedure UpdateDBThread.DoExit;
begin
 Synchronize(DoOnDone);
end;

procedure UpdateDBThread.DoEventReplace(ID: Integer; Name: String);
begin
 IDParam := ID;
 NameParam := Name;
 Synchronize(DoEventReplaceSynch);
end;

procedure UpdateDBThread.DoEventReplaceSynch;
var
  EventInfo : TEventValues;
begin
 try
  EventInfo.NewName:=NameParam;
  EventInfo.ID:=IDParam;
  DBKernel.DoIDEvent(Self,IDParam,[EventID_Param_Name],EventInfo);
 except  
  on e : Exception do EventLog(':UpdateDBThread::DoEventReplaceSynch() throw exception: '+e.Message);
 end;
end;

procedure UpdateDBThread.UpdateCurrent;
begin
 UpdateImageRecord(FFiles[FileNumber],res.ids[0]);
end;

procedure UpdateDBThread.CryptFileWithoutPass;
var
  EventInfo : TEventValues;
begin
 EventInfo.Name:=FFiles[FileNumber];
 DBKernel.DoIDEvent(Self,-1,[EventID_Param_Add_Crypt_WithoutPass],EventInfo);
 CryptFileWithoutPassChecked:=true;
end;

function UpdateDBThread.Res: TImageDBRecordA;
begin
 Result:=ResArray[FileNumber];
end;

procedure UpdateDBThread.SetImages;
var
  EventInfo : TEventValues;
begin
 EventInfo.Name:=AnsiLowerCase(FFiles[FileNumber]);
 EventInfo.ID:=LastInseredID;
 EventInfo.Rotate:=0;
 EventInfo.Rating:=0;
 EventInfo.Comment:='';
 EventInfo.KeyWords:='';
 EventInfo.Access:=0;
 EventInfo.Attr:=0;
 EventInfo.Date:=Date;
 EventInfo.IsDate:=true;
 EventInfo.IsTime:=IsTime;
 EventInfo.Time:=TimeOf(Time);
 EventInfo.Image:=nil;
 EventInfo.Groups:='';
 EventInfo.JPEGImage:=Res.Jpeg;
 EventInfo.Crypt:=Res.Crypt;
 EventInfo.Include:=true;    
 DBKernel.DoIDEvent(Self,LastInseredID,[SetNewIDFileData],EventInfo);
 Res.Jpeg.Free;
 ResArray[FileNumber].Jpeg:=nil;
end;

procedure UpdateDBThread.FileProcessed;
var
  EventInfo : TEventValues;
begin
 EventInfo.Name:=AnsiLowerCase(FFiles[FileNumber]);
 EventInfo.ID:=LastInseredID;
 EventInfo.Rotate:=0;
 EventInfo.Rating:=0;
 EventInfo.Comment:='';
 EventInfo.KeyWords:='';
 EventInfo.Access:=0;
 EventInfo.Attr:=0;
 EventInfo.Date:=Date;
 EventInfo.IsDate:=true;
 EventInfo.IsTime:=IsTime;
 EventInfo.Time:=TimeOf(Time);
 EventInfo.Image:=nil;
 EventInfo.Groups:='';
 EventInfo.JPEGImage:=Res.Jpeg;
 EventInfo.Crypt:=Res.Crypt;
 EventInfo.Include:=true;     
 DBKernel.DoIDEvent(Self,LastInseredID,[EventID_FileProcessed],EventInfo);
end;

{ DirectorySizeThread }

function DirectorySizeThread.GetDirectory(DirectoryName: string; var Files : TStrings; Terminating : PBoolean):integer;
Var
 Found  : integer;
 SearchRec : TSearchRec;
 FileName : string;
begin
  result:=0;
  if Terminating^ then exit;
  if not DirectoryExists(DirectoryName) then exit;
  If DirectoryName[length(DirectoryName)]<>'\' then DirectoryName:=DirectoryName+'\';
  Found := FindFirst(DirectoryName+'*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if Terminating^ then
   begin
    FindClose(SearchRec);
    exit;
   end;
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
    If FileExists(DirectoryName+SearchRec.Name) and ExtInMask(SupportedExt,GetExt(DirectoryName+SearchRec.Name)) then
    begin
     Result:=Result+SearchRec.Size;
     FileName:=DirectoryName+SearchRec.Name;
     StrParam:=FileName;
     Synchronize(DoFileProcessed);
     FileName:=StrParam;
     Files.Add(FileName);
     IntParam:=SearchRec.Size;
     Synchronize(DoOnFileFounded);
    end else If DirectoryExists(DirectoryName+SearchRec.Name) then Result:=Result+GetDirectory(DirectoryName+SearchRec.Name, Files, Terminating);
   end;
   Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

constructor DirectorySizeThread.Create(CreateSuspennded: Boolean;
  Directory: string; OnDone: TNotifyEvent; Terminating: PBoolean; OnFileFounded : TFileFoundedEvent;
  ProcessFileEvent : TFileProcessProcedureOfObject = nil);
begin
  Inherited Create(true);
  FDirectory := Directory;
  FTerminating := Terminating;
  FOnFileFounded:=OnFileFounded;
  FProcessFileEvent:=ProcessFileEvent;
  FOnDone := OnDone;
  if not CreateSuspennded then Resume;
end;

procedure DirectorySizeThread.DoOnDone;
begin
  If Assigned(FOnDone) then
  FOnDone(FObject);
end;

procedure DirectorySizeThread.Execute;
var
    Size : integer;
    Files : TStrings;
begin
 FreeOnTerminate:=true;
 Files:=TStringList.create;
 Size:=GetDirectory(FDirectory,Files,FTerminating);
 If not FTerminating^ then
 begin
  FObject:=TValueObject.Create;
  FObject.FTIntValue:=Size;
  FObject.FSTStrValue:=Files;
  Synchronize(DoOnDone);
  FObject.free;
 end;
end;

procedure DirectorySizeThread.DoFileProcessed;
begin
 if Assigned(FProcessFileEvent) then
 FProcessFileEvent(StrParam);
end;

procedure DirectorySizeThread.DoOnFileFounded;
begin
 if Assigned(FOnFileFounded) then FOnFileFounded(nil, StrParam,IntParam);
end;

{ TValueObject }

constructor TValueObject.Create;
begin
 FSTStrValue:=TStringList.Create;
end;

destructor TValueObject.Destroy;
begin
 FSTStrValue.Free;
end;

procedure TValueObject.SetTBoolValue(const Value: Boolean);
begin
  FTBoolValue := Value;
end;

procedure TValueObject.SetTIntValue(const Value: Integer);
begin
  FTIntValue := Value;
end;

procedure TValueObject.SetTStrValue(const Value: TStrings);
begin
 FSTStrValue.Assign(Value);
end;

initialization

ShowMessageAboutLimit:=True;
CryptFileWithoutPassChecked:=false;

end.
