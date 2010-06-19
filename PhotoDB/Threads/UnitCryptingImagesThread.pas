unit UnitCryptingImagesThread;

interface

uses
  Classes, Dolphin_DB, UnitDBKernel, Forms, UnitPropeccedFilesSupport,
  UnitCrypting, GraphicCrypt, SysUtils, CommonDBSupport, DB, UnitRotatingImagesThread,
  UnitDBDeclare;

type
  TCryptImageThreadOptions = record
   Files : TArStrings;
   IDs : TArInteger;   
   Selected : TArBoolean;
   Password : String;
   CryptOptions : integer;
   Action : integer;
  end;

const
  ACTION_CRYPT_IMAGES   = 1;
  ACTION_DECRYPT_IMAGES = 2;

type
  TCryptingImagesThread = class(TThread)
  private    
    fOptions: TCryptImageThreadOptions;
    BoolParam : boolean;
    IntParam : integer;
    StrParam : string;   
    Count : integer;
    ProgressWindow : TForm; 
    Result : integer;
    Table : TDataSet;
    fPassword : String;
    fField : TField;
    FE : Boolean;
    { Private declarations }
  public 
    constructor Create(CreateSuspennded: Boolean; Options: TCryptImageThreadOptions);
  protected
    procedure Execute; override;
    procedure InitializeProgress;    
    procedure DestroyProgress;   
    procedure IfBreakOperation;
    procedure SetProgressPosition(Position : integer);
    procedure SetProgressPositionSynch;
    procedure DoDBkernelEvent;
    procedure DoDBkernelEventRefreshList;
    procedure RemoveFileFromUpdatingList;
    procedure GetPassword;
    procedure FindPasswordToFile;
    procedure FindPasswordToBlob;

    procedure GetPasswordFromUserFile;
    procedure GetPasswordFromUserBlob;
  end;

implementation

uses ProgressActionUnit, UnitPasswordForm;

{ TCryptingImagesThread }

constructor TCryptingImagesThread.Create(CreateSuspennded: Boolean;
  Options: TCryptImageThreadOptions);
var
  i : integer;
begin
 inherited create(true);
 Table:=nil;
 fOptions:=Options;
 for i:=0 to Length(Options.Files)-1 do   
 if Options.Selected[i] then
 ProcessedFilesCollection.AddFile(Options.Files[i]);
 DoDBkernelEventRefreshList;
 if not CreateSuspennded then Resume;
end;

procedure TCryptingImagesThread.DestroyProgress;
begin
 (ProgressWindow as TProgressActionForm).WindowCanClose:=true;
 ProgressWindow.Release;
 if UseFreeAfterRelease then ProgressWindow.Free;
end;

procedure TCryptingImagesThread.DoDBkernelEvent;
var
  EventInfo : TEventValues;
begin
 if fOptions.Action = ACTION_CRYPT_IMAGES then
 begin
  if Result<>CRYPT_RESULT_OK then EventInfo.Crypt:=false else EventInfo.Crypt:=true;
 end else
 begin
  if Result=CRYPT_RESULT_OK then EventInfo.Crypt:=false else EventInfo.Crypt:=true;
 end;
 if IntParam<>0 then
 begin
  DBKernel.DoIDEvent(nil,IntParam,[EventID_Param_Crypt],EventInfo)
 end else
 begin
  EventInfo.NewName:=StrParam;
  DBKernel.DoIDEvent(nil,IntParam,[EventID_Param_Name],EventInfo)
 end;
end;

procedure TCryptingImagesThread.DoDBkernelEventRefreshList;
var
  EventInfo : TEventValues;
begin
 DBKernel.DoIDEvent(nil,IntParam,[EventID_Repaint_ImageList],EventInfo);
end;

procedure TCryptingImagesThread.Execute;
var
  i,j : integer;
  c : integer;
begin
 FreeOnTerminate:=true;
 Count:=0;
 for i:=0 to Length(fOptions.IDs)-1 do
 if fOptions.Selected[i] then
 inc(Count);
 Synchronize(InitializeProgress);
 c:=0;
 for i:=0 to Length(fOptions.IDs)-1 do
 begin
  if fOptions.Selected[i] then
  begin   
   Synchronize(IfBreakOperation);
   if BoolParam then
   begin
    for j:=i to Length(fOptions.IDs)-1 do
    begin
     StrParam:=fOptions.Files[j];
     Synchronize(RemoveFileFromUpdatingList);
    end;
    Synchronize(DoDBkernelEventRefreshList);
    continue;
   end;
   Inc(c);
   SetProgressPosition(c);
   if fOptions.Action=ACTION_CRYPT_IMAGES then
   begin
    //Crypting images
    try
     Result:=CryptImageByFileName(fOptions.Files[i],fOptions.IDs[i],fOptions.Password,fOptions.CryptOptions,false);
    except
    end;
   end else
   begin
    //DEcrypting images
    FE:=FileExists(fOptions.Files[i]);
    //GetPassword
    StrParam:=fOptions.Files[i];
    IntParam:=fOptions.IDs[i];
    GetPassword;
    //DEcrypting images
    try
     ResetPasswordImageByFileName(fOptions.Files[i],fOptions.IDs[i],fPassword);
    except
    end;
   end;
   StrParam:=fOptions.Files[i];
   IntParam:=fOptions.IDs[i];
   Synchronize(RemoveFileFromUpdatingList);    
   Synchronize(DoDBkernelEventRefreshList);
   Synchronize(DoDBkernelEvent);
  end;
 end;
 if Table<>nil then Table.free;
 Synchronize(DestroyProgress);
end;


procedure TCryptingImagesThread.GetPasswordFromUserFile;
begin
 fPassword:=GetImagePasswordFromUser(StrParam);
end;

procedure TCryptingImagesThread.GetPasswordFromUserBlob;
begin
 fPassword:=GetImagePasswordFromUserBlob(fField,StrParam);
end;

procedure TCryptingImagesThread.FindPasswordToFile;
begin
 fPassword:=DBkernel.FindPasswordForCryptImageFile(StrParam)
end;

procedure TCryptingImagesThread.FindPasswordToBlob;
begin
 fPassword:=DBkernel.FindPasswordForCryptBlobStream(fField);
end;

procedure TCryptingImagesThread.GetPassword;
begin
 if FE then
 Synchronize(FindPasswordToFile)
 else
 begin
  if Table=nil then
  begin
   Table := GetTable;
   Table.Open;
  end;
  Table.Locate('ID',IntParam,[loPartialKey]);
  fField:=Table.FieldByName('thum');
  Synchronize(FindPasswordToBlob);
 end;
 if fPassword='' then
 begin
  begin
   if not FE then
   begin
    if IntParam=0 then
    begin
     exit;
    end;
    Table.Locate('ID',IntParam,[loPartialKey]);
    Table.Edit;
    fField:=Table.FieldByName('thum');
    Synchronize(FindPasswordToBlob);
    Table.Post;
    end else
   begin
    Synchronize(GetPasswordFromUserFile);
   end;
  end;
 end;
end;

procedure TCryptingImagesThread.IfBreakOperation;
begin
 BoolParam:=(ProgressWindow as TProgressActionForm).Closed;
end;

procedure TCryptingImagesThread.InitializeProgress;
begin
 ProgressWindow:=GetProgressWindow(true);
 With ProgressWindow as TProgressActionForm do
 begin
  CanClosedByUser:=True;
  OneOperation:=false;
  OperationCount:=1;
  OperationPosition:=1;
  MaxPosCurrentOperation:=Count;
  xPosition:=0;
  Show;
 end;
end;

procedure TCryptingImagesThread.RemoveFileFromUpdatingList;
begin
 ProcessedFilesCollection.RemoveFile(StrParam);
end;

procedure TCryptingImagesThread.SetProgressPosition(Position: integer);
begin
 IntParam:=Position;
 Synchronize(SetProgressPositionSynch);
end;

procedure TCryptingImagesThread.SetProgressPositionSynch;
begin
 (ProgressWindow as TProgressActionForm).xPosition:=IntParam;
end;

end.
