unit AddDataThreadUnit;

interface

uses
 UnitDBKernel, forms,dm, windows, Messages, CommCtrl, Dialogs, Classes, DBGrids, DB,
 DBTables, SysUtils,ComCtrls, Graphics, jpeg, StdCtrls, dolphin_db;

type
  AddDataThread = class(TThread)
  private
  fQuery: TQuery;
  fSizeToUpdating_:integer;
  FFolderSize : integer;
  fBytesReadDone_:integer;
  fcalc : boolean;
  f10percent : integer;
  fProgressText : string;
  FCurrentFileName : string;
  FCurrentImageDBRecord : TImageDBRecordA;
  FresultDialog : Pinteger;
  FIntResultDialog : integer;
  CurrentImTh : string;
  FskipAll : boolean;
  FReplaceAll : boolean;
    { Private declarations }
  protected
    procedure savefiletoDB(filename:string);
    procedure limiterror;
    procedure Execute; override;
    procedure SetProgressText;
    procedure SetProgressPercent;
    procedure label_file_up;
    function GetUpdatingSize_(Sender: TObject; DirectoryName,
  mask: string):integer;
    procedure AddDirectory_(Sender: TObject; DirectoryName: string; mask : string);
    procedure fileexistsinDB;
  end;

  var FolderName_, FileName_ : string;
  Addfile_ : boolean;
  KeyWords_ : string;
  Collection_, owner_ : string;
  flabel_file : string;
  active:boolean;
  OnEndThread : TNotifyEvent;
  terminated_:boolean;
  info_label : tlabel;
  Comment_:string;

implementation

uses Searching, AddForm, UnitCleanUpThread, replaceform;

{ AddDataThread }

function AddDataThread.GetUpdatingSize_(Sender: TObject; DirectoryName,
  mask: string):integer;
Var
 Found  : integer;
 SearchRec : TSearchRec;
 f:file;
 attr : integer;
begin
  result:=0;
  if terminated_ then exit;
  if length(DirectoryName)=0 then exit;
  if not directoryexists(DirectoryName) then exit;
  If DirectoryName[length(DirectoryName)]<>'\' then DirectoryName:=DirectoryName+'\';
  Found := FindFirst(DirectoryName+'*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
  If fileexists(DirectoryName+SearchRec.Name) and extinmask(mask,getext(DirectoryName+SearchRec.Name)) then begin

   result:=result+ dm.GetFileSize(DirectoryName+SearchRec.Name);
   fSizeToUpdating_:=fSizeToUpdating_+ dm.GetFileSize(DirectoryName+SearchRec.Name);

   fprogresstext:='Calculating... '+inttostr(fSizeToUpdating_)+' bytes done';
   synchronize(setprogresstext);
 end else If directoryexists(DirectoryName+SearchRec.Name) then result:=result+GetUpdatingSize_(Sender,DirectoryName+SearchRec.Name, mask);
   end;
    Found := sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

function delnakl(s:string):string;
var j:integer;
begin
result:=s;
for j:=1 to length(result) do
if result[j]='\' then result[j]:='_';
end;

procedure AddDataThread.savefiletoDB(filename:string);
var thstr, name_:string;  pic:Tpicture;  bs: TBlobStream;  Jpg: TJPegImage;
thw,thh:integer;   thbmp, bmp:Tbitmap;
F:file;  filesize_:integer;   _sqlexectext:string;
params_ : TParams;    blob :tparam; tstr:tstream;
res : TImageDBRecordA;
fftable : Ttable; f_:TBooleanFunction;  Fh:pointer;
EventInfo : TEventValues;
begin
 flabel_file:=filename;
 synchronize(label_file_up);
 name_:=getfilename(filename);
 if not extinmask(SupportedExt,getext(name_)) then
 exit;
 res:=getimageIDW(filename);
 if (res.Count<>0) and (UpcaseAll(res.FileNames[0])<>UpcaseAll(filename)) then
 begin
  try
   CurrentImTh := res.ImTh;
   FCurrentImageDBRecord:=res;
   FCurrentFileName:=filename;
   if (not FskipAll) and (not FreplaceAll) then
   synchronize(fileexistsinDB);
   case FIntResultDialog of
    Result_invalid: exit;
    Result_skip: exit;
    Result_skip_all: begin FskipAll:=true; exit; end;
    Result_replace_all:
     begin
      FreplaceAll:=true;
      UpdateMovedDBRecord(res.ids[0],filename);
      EventInfo.Name:=filename;
      DBKernel.DoIDEvent(nil,res.ids[0],[EventID_Param_Name],EventInfo);
      exit;
     end;
    Result_replace:
     begin
      UpdateMovedDBRecord(res.ids[0],filename);
      EventInfo.Name:=filename;
      DBKernel.DoIDEvent(nil,res.ids[0],[EventID_Param_Name],EventInfo);
      exit;
     end;
    end;
    if FreplaceAll then UpdateMovedDBRecord(res.ids[0],filename);
    if FskipAll then exit;
   except
  end;
 end else begin
  filesize_:=dm.GetFileSize(filename);
  fQuery.SQL.Clear;                                                                                       {}
  fQuery.SQL.Add('insert into "'+dbname+'"');
  fQuery.SQL.Add(' (Name,FFileName,Owner,FileSize,DateToAdd,Thum,StrTh,KeyWords,Owner,Collection,Access,Width,Height,Comment,KeyWords,Attr,Rotated,Rating) ');
  fQuery.SQL.Add(' values (:Name,:FFileName,:Owner,:FileSize,:DateToAdd,:Thum,:StrTh,:KeyWords,:Owner,:Collection,:Access,:Width,:Height,:Comment,:KeyWords,:Attr,:Rotated,:Rating) ');
  fQuery.Params[0].AsString:=name_;
  fQuery.Params[1].AsString:=filename;
  fQuery.Params[2].AsString:='Dolphin';
  fQuery.Params[3].AsInteger:=filesize_;
  fQuery.Params[4].AsDateTime:=now;
  fQuery.Params[5].Assign(res.Jpeg);
  fQuery.Params[6].AsString:=res.ImTh;
  fQuery.Params[7].AsString:=KeyWords_;
  fQuery.Params[8].AsString:=owner_;
  fQuery.Params[9].AsString:=Collection_;
  fQuery.Params[10].AsInteger:=0;
  fQuery.Params[11].AsInteger:=res.OrWidth;
  fQuery.Params[12].AsInteger:=res.OrHeight;
  fQuery.Params[13].AsString:=Comment_;
  fQuery.Params[14].AsString:=KeyWords_;
  fQuery.Params[15].AsInteger:=db_attr_norm;
  fQuery.Params[16].AsInteger:=DB_IMAGE_ROTETED_0;
  fQuery.Params[17].AsInteger:=0;
  res.Jpeg.Free;
  try
   fQuery.ExecSQL;
   except
  end;
 end;
end;



procedure AddDataThread.AddDirectory_(Sender: TObject; DirectoryName: string; mask : string);
Var
 Found  : integer;
 SearchRec : TSearchRec;
 f:file;   i:integer;
 r:real;
begin
  if terminated_ then exit;
  If DirectoryName[length(DirectoryName)]<>'\' then DirectoryName:=DirectoryName+'\';
  Found := FindFirst(DirectoryName+'*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
  If fileexists(DirectoryName+SearchRec.Name) and extinmask(mask,getext(DirectoryName+SearchRec.Name)) then begin
   savefiletoDB(DirectoryName+SearchRec.Name);
  fBytesReadDone_:=fBytesReadDone_+dm.GetFileSize(DirectoryName+SearchRec.Name);
   if FFolderSize<>0 then
  r:=fBytesReadDone_/FFolderSize else r:=0;
  r:=1000*r; 
  f10percent:=round(r);
  synchronize(SetProgressPercent);
  if terminated_ then exit;
  end else If directoryexists(DirectoryName+SearchRec.Name) then AddDirectory_(Sender,DirectoryName+SearchRec.Name, mask);
   end;
    Found := sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

procedure AddDataThread.Execute;
begin
  terminated_:=false;
  Active:=true;
  Application.Initialize;
  inc(Foperations);
  fQuery:=TQuery.Create(nil);
  fQuery.DatabaseName:='DolphinAlias';
  fBytesReadDone_:=0;
  fcalc:=true;
  FskipAll := false;
  FReplaceAll := false;
  if not Addfile_ then
  begin
   try
   FFolderSize:=GetUpdatingSize_(self,FolderName_,SupportedExt);
   except
   end;
   Form4.DmProgress1.MaxValue:=1000;
   fProgressText:='Progress... (&%%)';
   synchronize(SetProgressText);
   try
   AddDirectory_(self,FolderName_,SupportedExt);
   except
   end;
   fProgressText:='Done. ';
   f10percent:=0;
   synchronize(SetProgressText);
   synchronize(SetProgressPercent);
  end else
  begin
   f10percent:=0;
   synchronize(SetProgressPercent);
   fProgressText:='Adding file... ';
   synchronize(SetProgressText);
   try
   savefiletoDB(FileName_);
   except
   end;
   fProgressText:='Done.';
   synchronize(SetProgressText);
  end;
  fQuery.free;
  dec(Foperations);
  Active:=false;
  terminated_:=false;
  if assigned(OnEndThread) then OnEndThread(self);
end;

procedure AddDataThread.SetProgressText;
begin
Form4.DmProgress1.Text:=fProgressText;
end;

procedure AddDataThread.SetProgressPercent;
begin

Form4.DmProgress1.position:=f10percent;
end;

procedure AddDataThread.label_file_up;
begin
Form4.LabelFileName.caption:=flabel_file;
end;

procedure AddDataThread.fileexistsinDB;
begin
 if DBReplaceForm=nil then
 Application.CreateForm(TDBReplaceForm, DBReplaceForm);
 DBReplaceForm.ExecuteToAdd(FCurrentFileName,0,CurrentImTh,@FIntResultDialog,FCurrentImageDBRecord);
end;

procedure AddDataThread.limiterror;
begin
 Application.MessageBox(Pchar('You are work with not activated DataBase!'+#13+'You can add only '+inttostr(LimitDemoRecords)+' records!'+#13+'Press "help key in main wondow to view help."'),'Needs activation',mb_ok+mb_iconinformation);
end;

end.
