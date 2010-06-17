unit UnitUpdateDBObject;

interface

uses Windows, Controls, Classes,  Forms, SysUtils, uScript, UnitScripts,
     Dolphin_DB, UnitDBDeclare, UnitDBCommon;

type

   TOwnerFormSetText = procedure(Text : string) of object;  
   TOwnerFormSetMaxValue = procedure(Value : integer) of object; 
   TOwnerFormSetAutoAnswer = procedure(Value : integer) of object;  
   TOwnerFormSetTimeText = procedure(Text : string) of object;
   TOwnerFormSetPosition = procedure(Value : integer) of object;
   TOwnerFormSetFileName = procedure(FileName : string) of object;
   TOwnerFormAddFileSizes = procedure(Value : int64) of object;

type
  TDBFileInfo = record
   FileName : String;
   Comment : String;
   Owner : String;
   KeyWords : String;
   Collection : String;
   Date : TDateTime;
   IsDate : Boolean;
   Groups : String;
   Rating : Integer;
  end;

  TDBFilesInfo = array of TDBFileInfo;

Type
  TUpdaterDB = class(TObject)
  private
    fProcessScript : TScript;
    ScriptProcessString : string;
    FPosition : Integer;
    fShowWindow: Boolean;
    FForm : TForm;
    FmaxSize : Integer;
    FTerminate : Boolean;
    FActive: Boolean;
    FAuto: boolean;
    FAutoAnswer : Integer;
    Fpause : boolean;
    BeginTime : TDateTime;
    FFilesInfo : TDBFilesInfo;
    FUseFileNameScaning: boolean;
    procedure SetAuto(const Value: boolean);
    procedure SetAutoAnswer(Value: Integer);
    procedure SetUseFileNameScaning(const Value: boolean);
    procedure ProcessFile(var FileName : string);
    { Private declarations }
  protected
  public
   OwnerFormSetText : TOwnerFormSetText;
   OwnerFormSetMaxValue : TOwnerFormSetMaxValue;
   OwnerFormSetAutoAnswer : TOwnerFormSetAutoAnswer;
   OwnerFormSetTimeText : TOwnerFormSetTimeText;
   OwnerFormSetPosition : TOwnerFormSetPosition;
   OwnerFormSetFileName : TOwnerFormSetFileName;
   OwnerFormAddFileSizes : TOwnerFormAddFileSizes;
   ShowForm : TNotifyEvent;
   SetDone : TNotifyEvent;
   SetBeginUpdation : TNotifyEvent;  
   DoShowImage : TNotifyEvent;
   OnDirectoryAdded : TNotifyEvent;     
   OnExecuting : TNotifyEvent;
   NoLimit : boolean;
   Constructor Create(AutoCreateForm : boolean = true);
   Destructor Destroy; override;
   Function AddFile(FileName : string; Silent : boolean = false) : Boolean;
   Function AddDirectory(Directory : string; OnFileFounded : TFileFoundedEvent) : Boolean;
   Procedure EndDirectorySize(Sender : TObject);
   Procedure OnAddFileDone(Sender : TObject);   
   Procedure Execute;
   Procedure ShowWindowNow;
   Procedure DoTerminate;
   Procedure DoPause;
   Procedure DoUnPause;
   Procedure SaveWork;   
   Procedure LoadWork;
   function GetFilesCount : integer;
   Property Active : Boolean read FActive;
   Property Auto : boolean read FAuto Write SetAuto Default True;
   Property UseFileNameScaning : boolean read FUseFileNameScaning Write SetUseFileNameScaning Default false;
   Property AutoAnswer : Integer Read FAutoAnswer Write SetAutoAnswer;
   Property Pause : Boolean read FPause;
   function FileExistsInFileList(FileName : String) : Boolean;
   function GetCount : integer;
   Property Form : TForm read FForm;
 end;

implementation

uses Language,UnitUpdateDBThread, DBScriptFunctions,
       FormManegerUnit, UnitUpdateDB, ProgressActionUnit;

{ TUpdaterDB }

function TUpdaterDB.AddDirectory(Directory: string; OnFileFounded : TFileFoundedEvent): Boolean;
var
  Dir : string;
begin
 Dir:=Directory;

 if Length(FFilesInfo)=0 then
 if Assigned(OwnerFormSetText) then
  OwnerFormSetText(TEXT_MES_ADDING_FOLDER);

 if FForm<>nil then
 if (FForm is TUpdateDBForm) then
 begin
  OnFileFounded:=(FForm as TUpdateDBForm).OnDirectorySearch;
  (FForm as TUpdateDBForm).FullSize:=0;
 end;
 DirectorySizeThread.Create(false,Dir,EndDirectorySize,@FTerminate,OnFileFounded,ProcessFile);
 Result:=True;
end;

function TUpdaterDB.FileExistsInFileList(FileName: String): Boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to Length(FFilesInfo)-1 do
 if AnsiLowerCase(FileName)=AnsiLowerCase(FFilesInfo[i].FileName) then
 begin
  Result:=true;
  exit;
 end;
end;

function TUpdaterDB.AddFile(FileName : string; Silent : boolean = false): Boolean;
var
  FileSize : int64;
begin
 ProcessFile(FileName);

 If Silent or (FileExists(FileName) and ExtInMask(SupportedExt,GetExt(FileName))) then
 if not(FileExistsInFileList(FileName)) then
 begin
  FileSize:=GetFileSizeByName(FileName);
  Inc(FmaxSize,FileSize);
  SetLength(FFilesInfo,Length(FFilesInfo)+1);
  FFilesInfo[Length(FFilesInfo)-1].FileName:=FileName;
  if Assigned(OwnerFormSetMaxValue) then
  begin
   OwnerFormSetMaxValue(Length(FFilesInfo));
  end;
  if Assigned(OwnerFormAddFileSizes) then
  OwnerFormAddFileSizes(FileSize);
  If Auto then
  begin
   if not Silent then
   Execute;
   if Assigned(ShowForm) then
   ShowForm(Self);
  end;
 end;
 Result:=True;
end;

constructor TUpdaterDB.Create(AutoCreateForm : boolean = true);
var
  TermInfo : TTemtinatedAction;
begin

 ScriptProcessString:=Include('scripts\Adding_AddFile.dbini');
 fProcessScript := TScript.Create('');
 fProcessScript.Description:='Add File script';

 NoLimit:=false;
 OwnerFormSetText:=nil;
 FUseFileNameScaning:=false;
 if FormManager<>nil then
 begin
  TermInfo.TerminatedPointer:=@Self.FTerminate;
  TermInfo.TerminatedVerify:=@Self.Active;
  TermInfo.Options:=TA_INFORM_AND_NT;
  TermInfo.Discription:=TEXT_MES_UPDATING_DESCTIPTION;
  TermInfo.Owner:=Self;
  FormManager.RegisterActionCanTerminating(TermInfo);
 end;
 SetLength(FFilesInfo,0);
 FPosition := 0;
 Auto:=True;
 FTErminate:=false;
 fShowWindow:= false;
 FActive:=false;
 FmaxSize:=0;
 FPause:=false;
 FAutoAnswer := Result_invalid;
 if AutoCreateForm then
 begin
   Application.CreateForm(TUpdateDBForm,FForm);
   (FForm as TUpdateDBForm).SetAddObject(self);
   //SETTING EVENTS
   OwnerFormSetAutoAnswer:=(FForm as TUpdateDBForm).SetAutoAnswer;
   OwnerFormSetText:=(FForm as TUpdateDBForm).SetText;
   OwnerFormSetMaxValue:=(FForm as TUpdateDBForm).SetMaxValue;
   OwnerFormSetPosition:=(FForm as TUpdateDBForm).SetPosition;
   ShowForm:=(FForm as TUpdateDBForm).ShowForm;
   SetDone:=(FForm as TUpdateDBForm).SetDone;
   OwnerFormSetTimeText:=(FForm as TUpdateDBForm).SetTimeText;  
   OwnerFormSetFileName:=(FForm as TUpdateDBForm).SetFileName;
   SetBeginUpdation:=(FForm as TUpdateDBForm).SetBeginUpdation;
   OwnerFormAddFileSizes:=(FForm as TUpdateDBForm).AddFileSizes;
   SetBeginUpdation:=(FForm as TUpdateDBForm).OnBeginUpdation;
   LoadWork;
  end;
  BeginTime:=-1;
end;

destructor TUpdaterDB.Destroy;
var
  TermInfo : TTemtinatedAction;
begin
 if TFormManager<>nil then
 begin
  TermInfo.TerminatedPointer:=@Self.FTerminate;
  TermInfo.TerminatedVerify:=@Self.Active;
  TermInfo.Options:=TA_INFORM_AND_NT;
  TermInfo.Owner:=Self;
  FormManager.UnRegisterActionCanTerminating(TermInfo);
 end;

 if FForm<>nil then
 begin
  FForm.Release;
  if UseFreeAfterRelease then
  FForm.Free;
 end;

 fProcessScript.Free;
end;

procedure TUpdaterDB.DoPause;
begin
 FPause:=True;
end;

procedure TUpdaterDB.DoTerminate;
begin
 FTerminate:=True;
 SetLength(FFilesInfo,0);
 FPosition:=0;
 fActive:=false;
 BeginTime:=-1;
 if Assigned(SetDone) then SetDone(self);
// FormManager.UnRegisterMainForm(FForm);
end;

procedure TUpdaterDB.DoUnPause;
begin
 FPause:=false;
 Execute;
end;

procedure TUpdaterDB.EndDirectorySize(Sender: TObject);
var
  i : integer;
begin
  if Length(FFilesInfo)=0 then
  if Assigned(OwnerFormSetFileName) then
    OwnerFormSetFileName(TEXT_MES_NO_ANY_FILEA);

  Inc(FmaxSize,(Sender as TValueObject).TIntValue);

  if Assigned(OwnerFormAddFileSizes) then
  OwnerFormAddFileSizes((Sender as TValueObject).TIntValue);

  For i:=1 to (Sender as TValueObject).TStrValue.Count do
  begin
   SetLength(FFilesInfo,Length(FFilesInfo)+1);
   FFilesInfo[Length(FFilesInfo)-1].FileName:=(Sender as TValueObject).TStrValue[i-1];
  end;
  if Assigned(OwnerFormSetMaxValue) then
    OwnerFormSetMaxValue(Length(FFilesInfo));
  If Auto then
  begin
   ShowMessageAboutLimit:=True;
   Execute;
   if Assigned(ShowForm) then ShowForm(Self);
  end;

  if Assigned(OnDirectoryAdded) then OnDirectoryAdded(Self);
end;

procedure TUpdaterDB.Execute;
var
  Info: TAddFileInfoArray;
  Files : TArStrings;
  i : integer;
begin
 if BeginTime<0 then BeginTime:=now;
 If FTerminate then
 begin
  FTerminate:=false;
  fActive:=false;
  BeginTime:=-1;
  Exit;
 end;
// if not Formmanager.IsMainForms(Self.FForm) then FormManager.RegisterMainForm(Self.FForm);
 If fActive then exit;
 fActive:=true;
 If FPosition=0 then
 begin
  if Assigned(SetBeginUpdation) then SetBeginUpdation(self);
//  FormManager.UnRegisterMainForm(Self.FForm);
 end;
 If FPosition>=Length(FFilesInfo) then
 begin
  SetLength(FFilesInfo,0);
  FPosition:=0;
  fActive:=false;
  BeginTime:=-1;
  if Assigned(SetDone) then SetDone(self);
//  FormManager.UnRegisterMainForm(Self.FForm);
  Exit;
 end;
 if Length(FFilesInfo)=0 then
 begin
  fActive:=false;
//  Formmanager.UnRegisterMainForm(Self.FForm);
  if Assigned(SetDone) then SetDone(self);
//  TUpdateDBForm(Self.FForm).HideImage;
  Exit;
 End;
 if (FPosition<>0) then
 begin
  if Assigned(DoShowImage) then DoShowImage(self);
  if (Length(FFilesInfo)-FPosition>1) then
  begin
   if Assigned(OwnerFormSetTimeText) then OwnerFormSetTimeText(TimeTostr(((Now-BeginTime)/FPosition)*(Length(FFilesInfo)-FPosition)));
   //(FForm as TUpdateDBForm).TimeLabel.Caption:=TimeTostr(((Now-BeginTime)/FPosition)*(Length(FFilesInfo)-FPosition))
  end else
  begin
   if Assigned(OwnerFormSetTimeText) then OwnerFormSetTimeText(TEXT_MES_LAST_FILE);
   //(FForm as TUpdateDBForm).TimeLabel.Caption:=TEXT_MES_LAST_FILE;
  end;
 end;
 if Assigned(OwnerFormSetPosition) then
  OwnerFormSetPosition(FPosition+1);

 if Assigned(OwnerFormSetFileName) then
   OwnerFormSetFileName(FFilesInfo[FPosition].FileName);

 If FPause then
 begin
  fActive:=false;
  Exit;
 end;

 SetLength(Info,0);
 SetLength(Files,0);

 for i:=0 to 4 do
 begin
  SetLength(Info,i+1);
  SetLength(Files,i+1);
  Info[i].Rotate:=0;
  Info[i].Comment:=FFilesInfo[FPosition].Comment;
  Info[i].Rating:=FFilesInfo[FPosition].Rating;
  Info[i].KeyWords:=FFilesInfo[FPosition].KeyWords;
  Info[i].Owner:=FFilesInfo[FPosition].Owner;
  Info[i].Collection:=FFilesInfo[FPosition].Collection;
  Files[i]:=FFilesInfo[FPosition].FileName;
  Inc(FPosition);
  if (Length(FFilesInfo)-FPosition=0) then
  begin
   Break;
  end;
 end;
 UpdateDBThread.Create(false,Self,Files,Info,OnAddFileDone,FAutoAnswer,UseFileNameScaning,@FTerminate,@FPause,NoLimit);

end;

procedure TUpdaterDB.OnAddFileDone(Sender: TObject);
begin
 fActive:=false;
 Execute;
end;

procedure TUpdaterDB.SetAuto(const Value: boolean);
begin
  FAuto := Value;
end;

procedure TUpdaterDB.SetAutoAnswer(Value: Integer);
begin
 FAutoAnswer := Value;
 if Assigned(OwnerFormSetAutoAnswer) then
 OwnerFormSetAutoAnswer(Value);
end;

procedure TUpdaterDB.SetUseFileNameScaning(const Value: boolean);
begin
  FUseFileNameScaning := Value;
end;

procedure TUpdaterDB.ShowWindowNow;
begin
 FForm.Show;
end;

function TUpdaterDB.GetFilesCount: integer;
begin
 Result:=Length(FFilesInfo);
end;

procedure TUpdaterDB.ProcessFile(var FileName: string);
var
  c : integer;
begin
 if not GetParamStrDBBool('/Add') then
 begin
  SetNamedValueStr(fProcessScript,'$File',FileName);
  ExecuteScript(nil,fProcessScript,ScriptProcessString,c,nil);
  FileName:=GetNamedValueString(fProcessScript,'$File');
 end;
end;

procedure TUpdaterDB.LoadWork;
var
  i,c : integer;
  ProgressWindow : TProgressActionForm;
begin
 ProgressWindow:= GetProgressWindow;
 c:=DBKernel.ReadInteger('Updater','Counter',0);
 ProgressWindow.OneOperation:=true;
 ProgressWindow.MaxPosCurrentOperation:=c;
 ProgressWindow.xPosition:=0;
 ProgressWindow.SetAlternativeText(TEXT_MES_WAIT_LOADING_WORK);
 if c>10 then
 ProgressWindow.Show;
 for i:=0 to c-1 do
 begin
  if i mod 8=0 then
  begin
   ProgressWindow.xPosition:=i;
   Application.ProcessMessages;
  end;
  AddFile(DBKernel.ReadString('Updater','File'+IntToStr(i)),i<>c-1);
 end;

 ProgressWindow.Release;
 if UseFreeAfterRelease then
 ProgressWindow.Free;
end;

procedure TUpdaterDB.SaveWork;
var
  i : integer;
begin
 DBKernel.WriteInteger('Updater','Counter',Length(FFilesInfo));
 for i:=0 to Length(FFilesInfo)-1 do
 begin
  DBKernel.WriteString('Updater','File'+IntToStr(i),FFilesInfo[i].FileName);
 end;
end;

function TUpdaterDB.GetCount: integer;
begin
 Result:=Length(FFilesInfo);
end;

end.
