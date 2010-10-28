unit UnitDBKernel;

interface

uses Win32crc, CheckLst, TabNotBk, WebLink, ShellCtrls, Dialogs, TwButton,
  Rating, ComCtrls, StdCtrls, ExtCtrls, Forms, Windows, Classes,
  Controls, Graphics, DB, SysUtils, JPEG, UnitDBDeclare, IniFiles,
  GraphicSelectEx, ValEdit, GraphicCrypt, ADODB, uVistaFuncs, uLogger,
  EasyListview, ScPanel, UnitDBCommon, DmProgress, UnitDBCommonGraphics,
  uConstants, CommCtrl, uTime, UnitINI, SyncObjs, uMemory, uFileUtils;

type
  TCharObject = class (TObject)
  private
    FChar: Char;
    procedure SetChar(const Value: Char);
  public
    constructor Create;
    destructor Destroy; override;
    property Char_: Char read FChar write SetChar;
  end;

 const

  DB_VER_1_8 = 1;
  DB_VER_1_9 = 2;
  DB_VER_2_0 = 3;
  DB_VER_2_1 = 4;
  DB_VER_2_2 = 5;

DB_IC_SHELL          = 0;
DB_IC_SLIDE_SHOW     = 1;
DB_IC_REFRESH_THUM   = 2;
DB_IC_RATING_STAR    = 3;
DB_IC_DELETE_INFO    = 4;
DB_IC_DELETE_FILE    = 5;
DB_IC_COPY_ITEM      = 6;
DB_IC_PROPERTIES     = 7;
DB_IC_PRIVATE        = 8;
DB_IC_COMMON         = 9;
DB_IC_SEARCH         = 10;
DB_IC_EXIT           = 11;
DB_IC_FAVORITE       = 12;
DB_IC_DESKTOP        = 13;
DB_IC_RELOAD         = 14;
DB_IC_NOTES          = 15;
DB_IC_NOTEPAD        = 16;
DB_IC_RATING_1       = 17;
DB_IC_RATING_2       = 18;
DB_IC_RATING_3       = 19;
DB_IC_RATING_4       = 20;
DB_IC_RATING_5       = 21;
DB_IC_NEXT           = 22;
DB_IC_PREVIOUS       = 23;
DB_IC_NEW            = 24;
DB_IC_ROTETED_0      = 25;
DB_IC_ROTETED_90     = 26;
DB_IC_ROTETED_180    = 27;
DB_IC_ROTETED_270    = 28;
DB_IC_PLAY           = 29;
DB_IC_PAUSE          = 30;
DB_IC_COPY           = 31;
DB_IC_PASTE          = 32;
DB_IC_LOADFROMFILE   = 33;
DB_IC_SAVETOFILE     = 34;
DB_IC_PANEL          = 35;
DB_IC_SELECTALL      = 36;
DB_IC_OPTIONS        = 37;
DB_IC_ADMINTOOLS     = 38;
DB_IC_ADDTODB        = 39;
DB_IC_HELP           = 40;
DB_IC_RENAME         = 41;
DB_IC_EXPLORER       = 42;
DB_IC_SENDTO         = 44; //!!!
DB_IC_SEND           = 43; //!!!
DB_IC_NEW_SHELL      = 45;
DB_IC_NEW_DIRECTORY  = 46;
DB_IC_SHELL_PREVIOUS = 47;
DB_IC_SHELL_NEXT     = 48;
DB_IC_SHELL_UP       = 49;
DB_IC_KEY            = 50;
DB_IC_FOLDER         = 51;
DB_IC_ADD_FOLDER     = 52;
DB_IC_BOX            = 53;
DB_IC_DIRECTORY      = 54;
DB_IC_TH_FOLDER      = 55;
DB_IC_CUT            = 56;
DB_IC_NEWWINDOW      = 57;
DB_IC_ADD_SINGLE_FILE= 58;
DB_IC_MANY_FILES     = 59;
DB_IC_MY_COMPUTER    = 60;
DB_IC_EXPLORER_PANEL = 61;
DB_IC_INFO_PANEL     = 62;
DB_IC_SAVE_AS_TABLE  = 63;
DB_IC_EDIT_DATE      = 64;
DB_IC_GROUPS         = 65;
DB_IC_WALLPAPER      = 66;
DB_IC_NETWORK        = 67;
DB_IC_WORKGROUP      = 68;
DB_IC_COMPUTER       = 69;
DB_IC_SHARE          = 70;
DB_IC_ZOOMIN         = 71;
DB_IC_ZOOMOUT        = 72;
DB_IC_REALSIZE       = 73;
DB_IC_BESTSIZE       = 74;
DB_IC_E_MAIL         = 75;
DB_IC_CRYPTIMAGE     = 76;
DB_IC_DECRYPTIMAGE   = 77;
DB_IC_PASSWORD       = 78;
DB_IC_EXEFILE        = 79;
DB_IC_SIMPLEFILE     = 80;
DB_IC_CONVERT        = 81;
DB_IC_RESIZE         = 82;
DB_IC_REFRESH_ID     = 83;
DB_IC_DUBLICAT       = 84;
DB_IC_DEL_DUBLICAT   = 85;
DB_IC_UPDATING       = 86;
DB_IC_DO_SLIDE_SHOW  = 87;
DB_IC_MY_DOCUMENTS   = 88;
DB_IC_MY_PICTURES    = 89;
DB_IC_DESKTOPLINK    = 90;
DB_IC_IMEDITOR       = 91;
DB_IC_OTHER_TOOLS    = 92;
DB_IC_EXPORT_IMAGES  = 93;
DB_IC_PRINTER        = 94;
DB_IC_EXIF           = 95;
DB_IC_GET_USB        = 96;
DB_IC_USB            = 97;
DB_IC_TEXT_FILE      = 98;
DB_IC_DOWN           = 99;
DB_IC_UP             = 100;
DB_IC_CD_ROM         = 101;
DB_IC_TREE           = 102;
DB_IC_CANCEL_ACTION  = 103;
DB_IC__DB            = 104;
DB_IC__MDB           = 105;
DB_IC_SORT           = 106;
DB_IC_FILTER         = 107;
DB_IC_CLOCK          = 108;
DB_IC_ATYPE          = 109;
DB_IC_MAIN           = 110;
DB_IC_APPLY_ACTION   = 111;
DB_IC_RELOADING      = 112;
DB_IC_STENO          = 113;
DB_IC_DESTENO        = 114;
DB_IC_SPLIT          = 115;
DB_IC_CD_EXPORT      = 116;
DB_IC_CD_MAPPING     = 117;
DB_IC_CD_IMAGE       = 118;

type DBChangesIDEvent = Procedure(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues)  of object;

type DBEventsIDArray = record
 Sender : TObject;
 IDs : integer;
 DBChangeIDArrayesEvents : DBChangesIDEvent;
end;

type
  TUserRights = record
   Delete : boolean;
   Add : boolean;
   ChDbName : boolean;
   SetPrivate : boolean;
   SetRating : boolean;
   SetInfo : boolean;
   ChPass : boolean;
   ShowPrivate : boolean;
   ShowOptions : boolean;
   ShowAdminTools : boolean;
   FileOperationsCritical : Boolean;
   FileOperationsNormal : Boolean;
   ManageGroups : Boolean;
   Execute : Boolean;
   Crypt : Boolean;
   EditImage : boolean;
   ShowPath : boolean;
   Print : Boolean;
  end;

type TDBEventsIDArray = array of DBEventsIDArray;

const
  IconsCount = 119;

type
 TDbKernelArrayIcons = array [1..IconsCount] of THandle;

type TDBKernel = class(TObject)
  private
    { Private declarations }
    FINIPasswods : TStrings;
    FPasswodsInSession : TStrings;
    FEvents : TDBEventsIDArray;
    FImageList: TImageList;
    FForms : TList;
    FApplicationKey : String;
    Chars : array[1..100] of TCharObject;
    Sootv : array [1..16] of integer;
    FDemoMode : Boolean;
    ThreadOpenResultBool : Boolean;
    ThreadOpenResultWork : Boolean;
    FDBs : TPhotoDBFiles;
    fImageOptions : TImageDBOptions;
    FRegistryCache : TDBRegistryCache;
    FSych : TCriticalSection;
    procedure LoadDBs;
    function GetSortGroupsByName: Boolean;
  public
    { Public declarations }
    IconDllInstance : THandle;
    constructor Create;
    destructor Destroy; override;
    property DBs: TPhotoDBFiles read FDBs;
    property ImageList: TImageList read FImageList;
    procedure UnRegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
    procedure UnRegisterChangesIDByID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
    procedure RegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
    procedure UnRegisterChangesIDBySender(Sender: TObject);
    procedure RegisterChangesIDbyID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
    procedure DoIDEvent(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
    function TestDB(DBName_: string; OpenInThread: Boolean = False): Boolean;
    function ReadProperty(Key, name: string): string;
    procedure DeleteKey(Key: string);
    procedure WriteProperty(Key, name, Value: string);
    procedure WriteBool(Key, name: string; Value: Boolean);
    procedure WriteBoolW(Key, name: string; Value: Boolean);
    procedure WriteInteger(Key, name: string; Value: Integer);
    procedure WriteStringW(Key, name, Value: string);
    procedure WriteString(Key, name: string; Value: string);
    procedure WriteDateTime(Key, name: string; Value: TDateTime);
    function ReadKeys(Key: string): TStrings;
    function ReadValues(Key: string): TStrings;
    function ReadBool(Key, name: string; default: Boolean): Boolean;
    function ReadRealBool(Key, name: string; default: Boolean): Boolean;
    function ReadboolW(Key, name: string; default: Boolean): Boolean;
    function ReadInteger(Key, name: string; default: Integer): Integer;
    function ReadString(Key, name: string): string;
    function ReadStringW(Key, name: string): string;
    function ReadDateTime(Key, name: string; default: TdateTime): TDateTime;
    procedure BackUpTable;
    function LogIn(UserName, Password: string; AutoLogin: Boolean): Integer;
    function CreateDBbyName(FileName: string): Integer;
    function GetDataBase: string;
    function GetDataBaseName: string;
    procedure SetDataBase(DBname_: string);
    procedure SetActivateKey(AName, AKey: string);
    function ReadActivateKey: string;
    function GetDemoMode: Boolean;
    function ReadRegName: string;
    procedure RegisterForm(Form: TForm);
    procedure UnRegisterForm(Form: TForm);
    function GetTemporaryFolder: string;
    function ApplicationCode: string;
    procedure SaveApplicationCode(Key: string);
    function GetCodeChar(N: Integer): Char;
    function ProgramInDemoMode: Boolean;
    procedure InitRegModule;
    procedure AddTemporaryPasswordInSession(Pass: string);
    function FindPasswordForCryptImageFile(FileName: string): string;
    procedure ClearTemporaryPasswordsInSession;
    function FindPasswordForCryptBlobStream(DF: TField): string;
    procedure SavePassToINIDirectory(Pass: string);
    procedure LoadINIPasswords;
    procedure SaveINIPasswords;
    procedure ClearINIPasswords;
    procedure ThreadOpenResult(Result: Boolean);
    procedure AddDB(DBName, DBFile, DBIco: string; Force: Boolean = False);
    function RenameDB(OldDBName, NewDBName: string): Boolean;
    function DeleteDB(DBName: string): Boolean;
    procedure DeleteValues(Key: string);
    function TestDBEx(DBName_: string; OpenInThread: Boolean = False): Integer;
    function StringDBVersion(DBVersion: Integer): string;
    procedure MoveDB(OldDBFile, NewDBFile: string);
    function DBExists(DBName: string): Boolean;
    function NewDBName(DBNamePattern: string): string;
    function ValidDBVersion(DBFile: string; DBVersion: Integer): Boolean;
    procedure InitIconDll;
    procedure FreeIconDll;
    procedure ReadDBOptions;
    procedure DoSelectDB;
    procedure GetPasswordsFromParams;
    procedure LoadIcons;
    property ImageOptions: TImageDBOptions read FImageOptions;
    property SortGroupsByName : Boolean read GetSortGroupsByName;
  end;

  var Icons : TDbKernelArrayIcons;

function inttochar(int : Integer):char;
function chartoint(ch : char):Integer;

implementation

uses Dolphin_db, Language, UnitCrypting, CommonDBSupport,
  UnitActiveTableThread, UnitFileCheckerDB, UnitGroupsWork,
  UnitBackUpTableInCMD, UnitCDMappingSupport;

{ TDBKernel }

constructor TDBKernel.Create;
var
  i : integer;
begin
  inherited;
  FDBs := nil;
  FSych := TCriticalSection.Create;
  FForms := TList.Create;
  FRegistryCache := TDBRegistryCache.Create;
  LoadDBs;
  for i := 1 to 100 do
    Chars[i] := nil;
  FPasswodsInSession := TStringList.create;
  FINIPasswods := nil;
  FApplicationKey := '';
end;

function TDBKernel.CreateDBbyName(FileName: string): integer;
var
  f : file;
begin
 result:=0;
 Dolphin_DB.CreateDirA(GetDirectory(FileName));
 try
  if FileExists(FileName) then
  begin
   System.Assign(f,FileName);
   System.Erase(f);
  end;
 except
  on e : Exception do
  begin
   EventLog(':TDBKernel::CreateDBbyName() throw exception: '+e.Message);
   Exit;
  end;
 end;
 if FileExists(FileName) then
 begin
  Result:=1;
  exit;
 end;
 Result:=1;
 if GetDBType(FileName)=DB_TYPE_MDB then
 begin
  if ADOCreateImageTable(FileName) then result:=0;
  ADOCreateSettingsTable(FileName);
 end;
end;

destructor TDBKernel.destroy;
var
  I: Integer;
begin
  FImageList.Free;
  FINIPasswods.Free;
  FPasswodsInSession.Free;
  for I := 1 to 100 do
    if Chars[I] <> nil then
      Chars[I].Free;
  FreeIconDll;
  FRegistryCache.Free;
  FSych.Free;
  F(FForms);
  F(FDBs);
  inherited;
end;

procedure TDBKernel.DoIDEvent(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  i:integer;
  fXevents : TDBEventsIDArray;
begin
  if Sender = nil then
    raise Exception.Create('Sender is null!');

  if GetCurrentThreadId <> MainThreadID then
    raise Exception.Create('DoIDEvent call not from main thread! Sender: ' + Sender.ClassName);

  if not ProgramInDemoMode then
    if not DBInDebug then
      if CharToInt(GetCodeChar(1)) + CharToInt(GetCodeChar(2)) <> 15 then
        Exit;

 if length(fevents)=0 then exit;
 SetLength(fXevents,length(fevents));
 for i:=0 to length(fevents)-1 do
 fXevents[i]:=fevents[i];
 for i:=0 to length(fXevents)-1 do
 begin
  if fXevents[i].ids=-1 then begin if Assigned(fXevents[i].DBChangeIDArrayesEvents) then
  fXevents[i].DBChangeIDArrayesEvents(Sender,ID,Params,Value) end else
  begin
   if fXevents[i].ids=ID then begin if Assigned(fXevents[i].DBChangeIDArrayesEvents) then
   fXevents[i].DBChangeIDArrayesEvents(Sender,ID,Params,Value) end;
  end;
 end;
end;


function TDBKernel.LogIn(UserName, Password: string; AutoLogin : boolean): integer;
begin
  DoSelectDB;
  LoadINIPasswords;
  Result := 0;
end;

function TDBKernel.Readbool(Key, Name: string; default : boolean): boolean;
var
  Reg : TBDRegistry;
  Value : string;
begin
  Result := Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Value := AnsiLowerCase(reg.ReadString(Name));
  if Value = 'true' then Result := True;
  if Value = 'false' then Result := False;
end;

function TDBKernel.ReadRealBool(Key, Name: string; Default : boolean): Boolean;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Result := Reg.ReadBool(Name);
end;

function TDBKernel.ReadboolW(Key, Name: string; Default : boolean): boolean;
var
  Reg : TBDRegistry;
  Value : string;
begin
  Result := Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Value := AnsiLowerCase(Reg.ReadString(Name));
  if Value = 'true' then Result := True;
  if Value = 'false' then Result := False;
end;

function TDBKernel.ReadInteger(Key, Name : string; Default : integer): integer;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Result := StrToIntDef(reg.ReadString(Name), Default);
end;

function TDBKernel.ReadDateTime(Key, Name : string; Default : TDateTime): TDateTime;
var
  Reg : TBDRegistry;
begin
  Result:=Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  if Reg.ValueExists(Name) then
    Result:=Reg.ReadDateTime(Name);
end;

function TDBKernel.ReadProperty(Key, Name: string): string;
var
  Reg : TBDRegistry;
begin
  Result := '';
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Result := Reg.ReadString(Name);
end;

function TDBKernel.ReadString(Key, Name: string): string;
var
  Reg : TBDRegistry;
begin
  Result := '';
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Result:=Reg.ReadString(Name);
end;

function TDBKernel.ReadKeys(Key: string): TStrings;
var
  Reg : TBDRegistry;
begin
  Result:=TStringList.Create;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.GetKeyNames(Result);
end;

function TDBKernel.ReadValues(Key: string): TStrings;
var
  Reg : TBDRegistry;
begin
  Result:=TStringList.Create;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.GetValueNames(Result);
end;

procedure TDBKernel.DeleteValues(Key: string);
var
  Reg : TBDRegistry;
  i : integer;
  Result : TStrings;
begin
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Result:=TStringList.Create;
    Reg.OpenKey(GetRegRootKey+Key,true);
    Reg.GetValueNames(Result);
    for i:=0 to Result.Count-1 do
      Reg.DeleteValue(Result[i]);
  finally
    Reg.Free;
  end;
end;

procedure TDBKernel.DeleteKey(Key: string);
var
  Reg : TBDRegistry;
begin
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.DeleteKey(GetRegRootKey+Key);
  finally;
    Reg.Free;
  end;
end;

function TDBKernel.ReadStringW(Key, Name: string): string;
var
  Reg : TBDRegistry;
begin
  Result := '';
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Result := Reg.ReadString(Name);
end;

procedure TDBKernel.RegisterChangesID(Sender : TObject; Event_ : DBChangesIDEvent);
var
  i : integer;
  is_ : boolean;
begin
 is_:=false;
 for i:=0 to length(fevents)-1 do
 if (@fevents[i].DBChangeIDArrayesEvents=@Event_) and (fevents[i].ids=-1) and (Sender=fevents[i].Sender) then
 begin
  is_:=true;
  break;
 end;
 if not is_ then
 begin
  setlength(fevents,length(fevents)+1);
  fevents[length(fevents)-1].ids:=-1;
  fevents[length(fevents)-1].Sender:=Sender;
  fevents[length(fevents)-1].DBChangeIDArrayesEvents:=Event_;
 end;
end;

procedure TDBKernel.RegisterChangesIDByID(Sender : TObject; Event_ : DBChangesIDEvent;
  id: integer);
var
  i : integer;
  is_ : boolean;
begin
 is_:=false;
 for i:=0 to length(fevents)-1 do
 if (@fevents[i].DBChangeIDArrayesEvents=@Event_) and (fevents[i].ids=id) and (Sender=fevents[i].Sender) then
 begin
  is_:=true;
  break;
 end;
 if not is_ then
 begin
  setlength(fevents,length(fevents)+1);
  fevents[length(fevents)-1].ids:=id;
  fevents[length(fevents)-1].sender:=Sender;
  fevents[length(fevents)-1].DBChangeIDArrayesEvents:=Event_;
 end;
end;

function TDBKernel.TestDB(DBName_: string; OpenInThread : boolean = false): boolean;
begin
 Result:=ValidDBVersion(DBName_,TestDBEx(DBName_,OpenInThread));
end;

function TDBKernel.TestDBEx(DBName_: string; OpenInThread : boolean = false): integer;
var
  FTestTable : TDataSet;
  ActiveOk : boolean;
begin
 //Fast test -> in thread load db query
  result:=0;
  if not FileExists(DBName_) then
  begin
   result:=-1;
   exit;
  end;
  FTestTable:=nil;
  if (GetDBType(DBName_)=DB_TYPE_MDB) and (GetFileSizeByName(DBName_)>500*1025) then
  begin
   FTestTable:= GetQuery(DBName_);
   SetSQL(FTestTable,'Select TOP 1 * From ImageTable Where ID<>0 ');
   try
    FTestTable.Open;
   except
    on e : Exception do
    begin
     EventLog(':TDBKernel::TestDBEx()/Open throw exception: '+e.Message);
     FreeDS(FTestTable);
     result:=-2;
     exit;
    end;
   end;
  end;

  if FTestTable<>nil then
  if FTestTable.Active then
  if FTestTable.RecordCount=0 then
  begin
   FreeDS(FTestTable);
   FTestTable:= GetTable(DBName_,DB_TABLE_IMAGES);
  end;

  if FTestTable=nil then FTestTable:= GetTable(DBName_,DB_TABLE_IMAGES);

  if FTestTable=nil then exit;
  if not (FTestTable.Active) then
  begin
   if OpenInThread then
   begin
    ThreadOpenResultWork:=false;
    TActiveTableThread.Create(FTestTable,true,ThreadOpenResult);
    Repeat
     Application.ProcessMessages;
     Sleep(50);
    until ThreadOpenResultBool;
    ActiveOk:=ThreadOpenResultBool;
   end else
   ActiveOk:=ActiveTable(FTestTable,true);
   if not ActiveOk then
   begin
    FreeDS(FTestTable);
    result:=-3;
    exit;
   end;
  end;

  try
   FTestTable.First;
   FTestTable.FieldByName('ID').AsInteger;
   if FTestTable.FindField('Name')=nil then
   begin
    FreeDS(FTestTable);
    result:=-4;
    exit;
   end;
   FTestTable.FieldByName('Name').AsString;
   if FTestTable.FindField('FFilename')=nil then
   begin
    FreeDS(FTestTable);
    result:=-5;
    exit;
   end;
   FTestTable.FieldByName('FFilename').AsString;
   FTestTable.FieldByName('StrTh').AsString;
   FTestTable.FieldByName('Comment').AsString;
   FTestTable.FieldByName('KeyWords').AsString;
   FTestTable.FieldByName('Rating').AsInteger;
   FTestTable.FieldByName('Attr').AsInteger;
   FTestTable.FieldByName('Access').AsInteger;
   FTestTable.FieldByName('Owner').AsString;
   FTestTable.FieldByName('Collection').AsString;
   FTestTable.FieldByName('FileSize').AsInteger;
   FTestTable.FieldByName('Width').AsInteger;
   FTestTable.FieldByName('Height').AsInteger;
   FTestTable.FieldByName('Rotated').AsInteger;
   Result:=DB_VER_1_8;
   //Added in PhotoDB v1.9
   if FTestTable.FindField('Include')=nil then
   begin
     FreeDS(FTestTable);
     exit;
   end;
   FTestTable.FindField('Include').AsBoolean;
   if FTestTable.FindField('Links')=nil then
   begin
    FreeDS(FTestTable);
    exit;
   end;
   FTestTable.FindField('Links').AsString;
   Result:=DB_VER_1_9;
   if FTestTable.FindField('aTime')=nil then
   begin
    FreeDS(FTestTable);
    exit;
   end;
   FTestTable.FindField('aTime').AsDateTime;
   if FTestTable.FindField('IsTime')=nil then
   begin
    FreeDS(FTestTable);
    exit;
   end;

   Result:=DB_VER_2_0;
   if (GetDBType(DBName_)=DB_TYPE_MDB) then
   if FTestTable.FindField('FolderCRC')=nil then
   begin
    FreeDS(FTestTable);
    exit;
   end;

   if (GetDBType(DBName_)=DB_TYPE_MDB) then
   if FTestTable.FindField('StrThCRC')=nil then
   begin
    FreeDS(FTestTable);
    exit;
   end;

  except
   on e : Exception do
   begin
    EventLog(':TDBKernel::TestDBEx() throw exception: '+e.Message);
    FreeDS(FTestTable);
    result:=-6;
    exit;
   end;
  end;
  if (GetDBType(DBName_)=DB_TYPE_MDB) then
  begin
   Result:=DB_VER_2_1;
   FTestTable:=nil;

   try
    FTestTable:= GetTable(DBName_,DB_TABLE_SETTINGS);
    FTestTable.Open;
   except
    on e : Exception do
    begin
     EventLog(':TDBKernel::TestDBEx()/DB_TABLE_SETTINGS throw exception: '+e.Message);
     if FTestTable<>nil then FreeDS(FTestTable);
     exit;
    end;
   end;
   if FTestTable<>nil then
   begin
    if FTestTable.RecordCount>0 then
    begin
     FTestTable.First;
     if FTestTable.FindField('Version')=nil then
     begin
      FreeDS(FTestTable);
      exit;
     end;
     if FTestTable.FindField('DBJpegCompressionQuality')=nil then
     begin
      FreeDS(FTestTable);
      exit;
     end;
     if FTestTable.FindField('ThSizePanelPreview')=nil then
     begin
      FreeDS(FTestTable);
      exit;
     end;
     if FTestTable.FindField('ThImageSize')=nil then
     begin
      FreeDS(FTestTable);
      exit;
     end;
     if FTestTable.FindField('ThHintSize')=nil then
     begin
      FreeDS(FTestTable);
      exit;
     end;
     try
      FTestTable.FieldByName('Version').AsString;
      FTestTable.FieldByName('DBJpegCompressionQuality').AsString;
      FTestTable.FieldByName('ThSizePanelPreview').AsInteger;
      FTestTable.FieldByName('ThImageSize').AsInteger;
      FTestTable.FieldByName('ThHintSize').AsInteger;
     except
      on e : Exception do
      begin
       EventLog(':TDBKernel::TestDBEx()/DB_TABLE_SETTINGS throw exception: '+e.Message);
       FreeDS(FTestTable);
       exit;
      end;
     end;
     Result:=DB_VER_2_2;
    end;
    FreeDS(FTestTable);
   end;
  end;

  FreeDS(FTestTable);
end;

procedure TDBKernel.UnRegisterChangesID(Sender : TObject; Event_ : DBChangesIDEvent);
var
  i, j : integer;
begin
 if length(fevents)=0 then exit;
 for i:=0 to length(fevents)-1 do
 begin
  if (@fevents[i].DBChangeIDArrayesEvents=@Event_) and (fevents[i].ids=-1) and (Sender=fevents[i].Sender) then
  begin
   for j:=i to length(fevents)-2 do
   fevents[j]:=fevents[j+1];
   SetLength(fevents,Length(fevents)-1);
   break;
  end;
 end;
end;

procedure TDBKernel.UnRegisterChangesIDByID(Sender : TObject; Event_ : DBChangesIDEvent; id: integer);
var
  i, j : integer;
begin
 if length(fevents)=0 then exit;
 for i:=0 to length(fevents)-1 do
 if (@fevents[i].DBChangeIDArrayesEvents=@Event_) and (fevents[i].ids=id) and (Sender=fevents[i].Sender) then
 begin
  for j:=i to length(fevents)-2 do
  fevents[j]:=fevents[j+1];
  SetLength(fevents,Length(fevents)-1);
  break;
 end;
end;

procedure TDBKernel.UnRegisterChangesIDBySender(Sender : TObject);
var
  i, j, k : integer;
begin
 if length(fevents)=0 then exit;
 for k:=0 to length(fevents)-1 do
 for i:=0 to length(fevents)-1 do
 if (Sender=fevents[i].Sender) then
 begin
  for j:=i to length(fevents)-2 do
  fevents[j]:=fevents[j+1];
  SetLength(fevents,Length(fevents)-1);
  break;
 end;
end;

procedure TDBKernel.WriteBool(Key, Name: string; Value: boolean);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  if Value then
    Reg.WriteString(Name,'True')
  else
    Reg.WriteString(Name,'False');
end;

procedure TDBKernel.WriteBoolW(Key, Name: string; value: boolean);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  if Value then
    Reg.WriteString(Name,'True')
  else
    Reg.WriteString(Name,'False');
end;

procedure TDBKernel.WriteInteger(Key, Name: string; Value: integer);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.WriteString(Name, IntToStr(Value));
end;

procedure TDBKernel.WriteProperty(Key, Name, Value: string);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Reg.WriteString(Name, Value);
end;

procedure TDBKernel.WriteString(Key, Name, Value: string);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.WriteString(Name, Value);
end;

procedure TDBKernel.WriteStringW(Key, Name, value: string);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Reg.WriteString(Name, Value);
end;

procedure TDBKernel.WriteDateTime(Key, Name : String; Value: TDateTime);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.WriteDateTime(Name, Value);
end;

function TDBKernel.GetDataBase: string;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot);
  Result:=Reg.ReadString('DBDefaultName');
end;

function TDBKernel.GetDataBaseName: string;
var
  i : integer;
begin
 for i:=0 to FDBs.Count-1 do
 if AnsiLowerCase(FDBs[i].FileName)=AnsiLowerCase(DBName) then
 begin
  Result:=FDBs[i].Name;
 end;

 //? if Result='' then Result:=Dolphin_DB.GetFileNameWithoutExt(DBName);

 if Result='' then Result:=TEXT_MES_UNKNOWN_DB;
end;

procedure TDBKernel.SetDataBase(DBname_: string);
var
  Reg : TBDRegistry;
begin
 if not FileExists(DBname_) then exit;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot,true);
  Reg.WriteString('DBDefaultName',DBname_);
 except
  on e : Exception do EventLog(':TDBKernel::SetDataBase() throw exception: '+e.Message);
 end;
 dbname:=DBname_;
 Reg.Free;
 ReadDBOptions;
end;

procedure TDBKernel.SetActivateKey(aName,aKey: String);
var
  Reg : TBDRegistry;
  Key, Name : String;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CLASSES);
 if PortableWork then
 begin
  Key:='\CLSID';
  Name:='Key';
 end else
 begin
  Key:='\CLSID\'+ActivationID;
  Name:='DefaultHandle';
 end;
 try
  Reg.OpenKey(Key,true);
  Reg.WriteString(Name,aKey);
  Reg.WriteString('UserName',aName);
  Reg.CloseKey;
  except
 end;
 Reg.free;
end;

function TDBKernel.ReadActivateKey: String;
var
  Reg : TBDRegistry;
  Key, Name : String;
begin
 if FApplicationKey<>'' then exit;
 if FolderView then exit;
 Reg:=TBDRegistry.Create(REGISTRY_CLASSES,true);
 if PortableWork then
 begin
  Key:='\CLSID';
  Name:='Key';
 end else
 begin
  Key:='\CLSID\'+ActivationID;
  Name:='DefaultHandle';
 end;
 try
  Reg.OpenKey(Key,true);
  Result:=Reg.ReadString(Name);
  SaveApplicationCode(Result);
  except
 end;
 Reg.CloseKey;
 Reg.Free;
end;

function chartoint(ch : char):Integer;
begin
 Result:=HexToIntDef(ch,0);
end;

function inttochar(int : Integer):char;
begin
 result:=IntToHex(int,1)[1];
end;

function TDBKernel.GetDemoMode: Boolean;
var
  i, Sum : integer;
  Str, ActCode, s: string;
begin
 Result:=false;
 if FolderView then exit;
 S:=ApplicationCode;
 ActCode:=ReadActivateKey;
 if length(ActCode)<16 then ActCode:='0000000000000000';
 for i:=1 to 8 do
 begin
  Str:=inttohex(abs(Round(cos(ord(s[i])+100*i+0.34)*16)),8);
  If ActCode[(i-1)*2+1]<>Str[8] then
  begin
   Result:=True;
   exit;
  end;
 end;
 Sum:=0;
 for i:=1 to 15 do
 Sum:=Sum+chartoint(ActCode[i]);
 if inttochar(Sum mod 15)<>ActCode[16] then
 begin
  Result:=True;
  exit;
 end;
end;

function TDBKernel.ReadRegName: string;
var
  Reg : TBDRegistry;
  Key : String;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CLASSES);
 if PortableWork then
 begin
  Key:='\CLSID';
 end else
 begin
  Key:='\CLSID\'+ActivationID;
 end;
 try
  Reg.OpenKey(Key,true);
  Result:=Reg.ReadString('UserName');
  except
 end;
 Reg.free;
end;

procedure TDBKernel.RegisterForm(Form: TForm);
begin
  if FForms.IndexOf(Form) > -1 then
    Exit;

  FForms.Add(Form);

  if IsWindowsVista then
    SetVistaFonts(Form);
end;

procedure TDBKernel.UnRegisterForm(Form: TForm);
begin
  FForms.Remove(Form);
end;

function TDBKernel.GetTemporaryFolder: String;
begin
 Result:=GetDirectory(Application.ExeName);
end;

function TDBKernel.ApplicationCode: String;
var
  s, Code : String;
  n : Cardinal;
begin
 s:=GetIdeDiskSerialNumber;
 CalcStringCRC32(s,n);
// n:=n xor $FA45B671;  //v1.75
// n:=n xor $8C54AF5B; //v1.8
// n:=n xor $AC68DF35; //v1.9
// n:=n xor $B1534A4F; //v2.0
// n:=n xor $29E0FA13; //v2.1
 n:=n xor $6357A302; //v2.2
 s:=inttohex(n,8);
 CalcStringCRC32(s,n);
 {$IFDEF ENGL}
  n:=n xor $1459EF12;
 {$ENDIF}
 {$IFDEF RUS}
//  n:=n xor $4D69F789; //v1.9
//  n:=n xor $E445CF12; //v2.0
//  n:=n xor $56C987F3; //v2.1
 n:=n xor $762C90CA; //v2.2
 {$ENDIF}
 Code:=s+inttohex(n,8);
 Result:=Code;
end;

procedure TDBKernel.SaveApplicationCode(Key : String);
var
  i, n : integer;
begin
 Randomize;
 If Length(Key)<16 then key:='0000000000000000';
 for i:=1 to 100 do
 if Chars[i]<>nil then
 begin
  Chars[i].free;
  Chars[i]:=nil;
 end;
 for i:=1 to 16 do
 sootv[i]:=0;
 for i:=1 to 16 do
 begin
  Repeat
   n:=Random(100)+1;
   if Chars[n]=nil then
   begin
    Chars[n]:=TCharObject.Create;
    Chars[n].Char_:=Key[i];
    sootv[i]:=n;
    Break;
   end;
  Until False;
 end;
end;

function TDBKernel.GetCodeChar(n: integer): Char;
begin
 Result:=#0;
 if Chars[Sootv[n]]<>nil then
 Result:=Chars[sootv[n]].Char_;
end;

function TDBKernel.ProgramInDemoMode: Boolean;
begin
 Result:=FDemoMode;
end;

procedure TDBKernel.BackUpTable;
var
   Options: TBackUpTableThreadOptions;
begin
  if FolderView then
    Exit;

  if Now - DBkernel.ReadDateTime('Options', 'BackUpDateTime', 0) > DBKernel.ReadInteger('Options', 'BackUpdays', 7) then
  begin
    Options.WriteLineProc := nil;
    Options.WriteLnLineProc := nil;
    Options.OnEnd := nil;
    Options.FileName := DBName;

    BackUpTableInCMD.Create(Options);

    DBkernel.WriteBool('StartUp', 'BackUp', True);
  end;
end;

procedure TDBKernel.InitRegModule;
begin
  ReadActivateKey;
  FDemoMode := GetDemoMode;
end;

procedure TDBKernel.AddTemporaryPasswordInSession(Pass: String);
var
  I : integer;
begin
  FSych.Enter;
  try
    for I := 0 to FPasswodsInSession.Count - 1 do
      if FPasswodsInSession[I] = Pass then
        Exit;
    FPasswodsInSession.Add(Pass);
  finally
    FSych.Leave;
  end;
end;

procedure TDBKernel.ClearTemporaryPasswordsInSession;
begin
  FSych.Enter;
  try
    FPasswodsInSession.Clear;
  finally
    FSych.Leave;
  end;
end;

function TDBKernel.FindPasswordForCryptImageFile(FileName: String): String;
var
  I : Integer;
begin
  Result := '';
  FSych.Enter;
  try
    FileName := ProcessPath(FileName);
    for I := 0 to FPasswodsInSession.Count - 1 do
      if ValidPassInCryptGraphicFile(FileName, FPasswodsInSession[I]) then
      begin
        Result := FPasswodsInSession[I];
        Exit;
      end;
    for I := 0 to FINIPasswods.Count - 1 do
      if ValidPassInCryptGraphicFile(FileName, FINIPasswods[I]) then
      begin
        Result := FINIPasswods[I];
        Exit;
      end;
  finally
    FSych.Leave;
  end;
end;

function TDBKernel.FindPasswordForCryptBlobStream(DF : TField): String;
var
  I : Integer;
begin
  Result := '';
  FSych.Enter;
  try
    for I := 0 to FPasswodsInSession.Count - 1 do
      if ValidPassInCryptBlobStreamJPG(DF, FPasswodsInSession[I]) then
      begin
        Result:=FPasswodsInSession[I];
        Exit;
      end;
    for I := 0 to FINIPasswods.Count - 1 do
      if ValidPassInCryptBlobStreamJPG(DF, FINIPasswods[I]) then
      begin
        Result:=FINIPasswods[I];
        Exit;
      end;
  finally
    FSych.Leave;
  end;
end;

procedure TDBKernel.SavePassToINIDirectory(Pass: String);
var
  I : integer;
begin
  FSych.Enter;
  try
    for I := 0 to FINIPasswods.Count - 1 do
      if FINIPasswods[I] = Pass then
        Exit;

     FINIPasswods.Add(Pass);
     SaveINIPasswords;

   finally
     FSych.Leave;
   end;
end;

procedure TDBKernel.LoadINIPasswords;
var
  Reg : TBDRegistry;
  s : String;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  if FINIPasswods<>nil then FINIPasswods.Free;
  Reg.OpenKey(GetRegRootKey,true);
  s:='';
  if Reg.ValueExists('INI') then
  try
   s:=Reg.ReadString('INI');
  except
  end;
  s:=HexStringToString(s);
  if Length(s)>0 then
  begin                             //TODO:!
   FINIPasswods:=DeCryptTStrings(s, 'dbpass')
  end else
  FINIPasswods:=TStringList.Create;
 except
 end;
 Reg.free;
end;

procedure TDBKernel.SaveINIPasswords;
var
  Reg : TBDRegistry;
  s : String;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(GetRegRootKey,true);//todo!
  s:=CryptTStrings(FINIPasswods, 'dbpass');
  s:=StringToHexString(s);
  Reg.WriteString('INI',s);
 except
 end;
 Reg.free;
end;

procedure TDBKernel.ClearINIPasswords;
begin
 FINIPasswods.Clear;
 SaveINIPasswords;
end;

procedure TDBKernel.ThreadOpenResult(Result: boolean);
begin
 ThreadOpenResultBool := Result;
 ThreadOpenResultWork := false;
end;

procedure TDBKernel.LoadDBs;
var
  Reg : TBDRegistry;
  List : TStrings;
  I, DBType : Integer;
  Icon, FileName : string;
begin
  FDBs := TPhotoDBFiles.Create;

  List:=TStringList.Create;
  try
    Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(RegRoot + 'dbs', True);
      Reg.GetKeyNames(List);
      for I := 0 to List.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(RegRoot + 'dbs\' + List[I], True);
        if Reg.ValueExists('Icon') and Reg.ValueExists('FileName') and Reg.ValueExists('Type') then
        begin
          Icon := Reg.ReadString('Icon');
          FileName := Reg.ReadString('FileName');
          DBType := Reg.ReadInteger('Type');
          FDBs.Add(List[I], Icon, FileName, DBType);
        end;
      end;
    finally
      Reg.Free;
    end;
  finally
    List.Free;
  end;
end;

procedure TDBKernel.MoveDB(OldDBFile, NewDBFile: string);
var
  Reg : TBDRegistry;
  DBS : TStrings;
  i : integer;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot+'dbs',true);
  DBS:=TStringList.Create;
  Reg.GetKeyNames(DBS);
  Reg.CloseKey;
  for i:=0 to DBS.Count-1 do
  begin
   Reg.OpenKey(RegRoot+'dbs\'+DBS[i],true);
   if AnsiLowerCase(Reg.ReadString('FileName'))=AnsiLowerCase(OldDBFile) then
   begin
    Reg.WriteString('FileName',NewDBFile);
    Reg.CloseKey;
    break;
   end;
   Reg.CloseKey;
  end;
 except
  on e : Exception do EventLog(':TDBKernel::MoveDB() throw exception: '+e.Message);
 end;
 Reg.Free;
 LoadDBs;
end;

function TDBKernel.DBExists(DBName : string) : boolean;
var
  Reg : TBDRegistry;
  DBS : TStrings;
  i : integer;
begin
 Result:=false;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot+'dbs',true);
  DBS:=TStringList.Create;
  Reg.GetKeyNames(DBS);
  Reg.CloseKey;
  for i:=0 to DBS.Count-1 do
  begin
   Reg.OpenKey(RegRoot+'dbs\'+DBS[i],true);
   if AnsiLowerCase(Reg.ReadString('FileName'))=AnsiLowerCase(DBName) then
   begin
    Result:=true;
    Reg.CloseKey;
    break;
   end;
   Reg.CloseKey;
  end;
 except
  on e : Exception do EventLog(':TDBKernel::DBExists() throw exception: '+e.Message);
 end;
 Reg.Free;
end;

function TDBKernel.NewDBName(DBNamePattern : string) : string;
var
  Reg : TBDRegistry;
  DBS : TStrings;
  i, j : integer;
  DBNameCurrent : string;
  b : boolean;
begin
 Result:=DBNamePattern;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot+'dbs',true);
  DBS:=TStringList.Create;
  Reg.GetKeyNames(DBS);
  Reg.CloseKey;
  DBNameCurrent:=DBNamePattern;
  for j:=1 to 1000 do
  begin
   b:=false;
   for i:=0 to DBS.Count-1 do
   begin
    if AnsiLowerCase(DBS[i])=AnsiLowerCase(DBNameCurrent) then
    begin
     b:=true;
    end;
   end;
   if b then
   begin
    DBNameCurrent:= DBNamePattern+'_'+IntToStr(j);
   end else
   begin
    Result:=DBNameCurrent;
    exit;
   end;
  end;
 except
  on e : Exception do EventLog(':TDBKernel::NewDBName() throw exception: '+e.Message);
 end;
 Reg.Free;
end;

procedure TDBKernel.AddDB(DBName, DBFile, DBIco: string; Force : boolean = false);
var
  Reg : TBDRegistry;
begin
 if not Force then
 if DBExists(DBFile) then exit;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot+'dbs\'+DBName,true);
  Reg.WriteString('FileName',DBFile);
  Reg.WriteString('icon',DBIco);
  Reg.WriteInteger('type',CommonDBSupport.GetDBType(DBFile));
 except
  on e : Exception do EventLog(':TDBKernel::AddDB() throw exception: '+e.Message);
 end;
 Reg.Free;
 LoadDBs;
end;

function TDBKernel.RenameDB(OldDBName, NewDBName: string): boolean;
var
  Reg : TBDRegistry;
  DB : TPhotoDBFile;
begin
 Result:=false;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot+'dbs\'+OldDBName,true);
  DB :=  TPhotoDBFile.Create;
  DB.Name:=OldDBName;
  DB.Icon:=Reg.ReadString('icon');
  DB.FileName:=Reg.ReadString('FileName');
  DB.FileType:=Reg.ReadInteger('type');
  Reg.CloseKey;
  Reg.OpenKey(RegRoot+'dbs\'+NewDBName,true);
  Reg.WriteString('FileName',DB.FileName);
  Reg.WriteString('icon',DB.Icon);
  Reg.WriteInteger('type',CommonDBSupport.GetDBType(DB.FileName));
  Reg.CloseKey;
 except
  on e : Exception do EventLog(':TDBKernel::RenameDB() throw exception: '+e.Message);
 end;
 Reg.Free;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.DeleteKey(RegRoot+'dbs\'+OldDBName);
 except
  on e : Exception do EventLog(':TDBKernel::RenameDB() throw exception: '+e.Message);
 end;
 Reg.Free;
 LoadDBs;
end;

function TDBKernel.DeleteDB(DBName: string): boolean;
var
  Reg : TBDRegistry;
begin
 Result:=false;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.DeleteKey(RegRoot+'dbs\'+DBName);
 except
  on e : Exception do EventLog(':TDBKernel::DeleteDB() throw exception: '+e.Message);
 end;
 Reg.Free;
 LoadDBs;
end;

function TDBKernel.StringDBVersion(DBVersion: integer): string;
begin
 Result:=TEXT_MES_UNKNOWN_DB_VERSION;
 Case DBVersion of
  DB_VER_1_8 : Result:='Paradox DB v1.8';
  DB_VER_1_9 : Result:='Paradox DB v1.9';
  DB_VER_2_0 : Result:='Paradox DB v2.0';
  DB_VER_2_1 : Result:='Access DB v2.1';
  DB_VER_2_2 : Result:='Access DB v2.2';
 end;
end;

function TDBKernel.ValidDBVersion(DBFile: string;
  DBVersion: integer): boolean;
begin
 if CommonDBSupport.GetDBType(DBFile)=DB_TYPE_MDB then
 Result:=DBVersion>DB_VER_2_1 else Result:=DBVersion>DB_VER_1_9;
end;

procedure TDBKernel.InitIconDll;
begin
  IconDllInstance := LoadLibrary(PWideChar(ProgramDir + 'Icons.dll'));
  if IconDllInstance = 0 then
  begin
   EventLog('icons IS missing -> exit');
//   MessageBoxDB(GetActiveFormHandle, TEXT_MES_ERROR_ICONS_DLL, TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
   Halt;
  end;
end;

procedure TDBKernel.FreeIconDll;
begin
 if IconDllInstance<>0 then
 FreeLibrary(IconDllInstance);
end;

procedure TDBKernel.ReadDBOptions;
begin
 fImageOptions:=CommonDBSupport.GetImageSettingsFromTable(DBName);
 DBJpegCompressionQuality := fImageOptions.DBJpegCompressionQuality;
 ThSize := fImageOptions.ThSize+2;
 ThSizePanelPreview := fImageOptions.ThSizePanelPreview;
 ThImageSize := fImageOptions.ThSize;
 ThHintSize := fImageOptions.ThHintSize;
end;

procedure TDBKernel.DoSelectDB;
var
  ParamDBFile : string;
  i : integer;
begin
 ParamDBFile:=GetParamStrDBValue('/SelectDB');
 if ParamDBFile='' then
 begin
  dbname:=GetDataBase;
 end else
 begin
  for i:=0 to DBs.Count-1 do
  begin
   if DBs[i].Name=ParamDBFile then
   begin
    DBName:=DBs[i].FileName;
    if GetParamStrDBBool('/SelectDBPermanent') then
    DBKernel.SetDataBase(DBName);
    exit;
   end
  end;
  DBName:=SysUtils.AnsiDequotedStr(ParamDBFile,'"');
  if GetParamStrDBBool('/SelectDBPermanent') then
  DBKernel.SetDataBase(DBName);
 end;
end;


function SplitString(str : String; SplitChar : char) : TArStrings;
var
  i,p : integer;
  StrTemp : string;
begin
  p:=1;
  SetLength(Result,0);
  for i:=1 to Length(str) do
  if (str[i]=SplitChar) or (i = Length(str))  then
  begin
   if i = Length(str) then
   StrTemp:=copy(str,p,i-p+1) else
   StrTemp:=copy(str,p,i-p);

   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:= StrTemp;
   p:=i+1;
  end;
end;

procedure TDBKernel.GetPasswordsFromParams;
var
  PassParam : string;
  PassArray : TArStrings;
  i : integer;
begin
 PassParam:=GetParamStrDBValue('/AddPass');
 PassParam:=SysUtils.AnsiDequotedStr(PassParam,'"');
 PassArray:=SplitString(PassParam,'!');
 for i:=0 to Length(PassArray)-1 do
 AddTemporaryPasswordInSession(PassArray[i]);
end;

function TDBKernel.GetSortGroupsByName: Boolean;
begin
  Result := Readbool('Options', 'SortGroupsByName', True);
end;

procedure TDBKernel.LoadIcons;
var
  I : Integer;

  function LoadIcon(Instance : HINST; ResName : string) : HIcon;
  begin
    Result := LoadImage(Instance, PWideChar(ResName), IMAGE_ICON, 16, 16, 0);
  end;

begin
  FImageList := TImageList.Create(nil);
  FImageList.Width := 16;
  FImageList.Height := 16;
  FImageList.BkColor := ClMenu;
  InitIconDll;

  icons[1] := LoadIcon(IconDllInstance,'SHELL');
  icons[2] := LoadIcon(IconDllInstance,'SLIDE_SHOW');
  icons[3] := LoadIcon(IconDllInstance,'REFRESH_THUM');
  icons[4] := LoadIcon(IconDllInstance,'RATING_STAR');
  icons[5] := LoadIcon(IconDllInstance,'DELETE_INFO');
  icons[6] := LoadIcon(IconDllInstance,'DELETE_FILE');
  icons[7] := LoadIcon(IconDllInstance,'COPY_ITEM');
  icons[8] := LoadIcon(IconDllInstance,'PROPERTIES');
  icons[9] := LoadIcon(IconDllInstance,'PRIVATE');
  icons[10] := LoadIcon(IconDllInstance,'COMMON');
  icons[11] := LoadIcon(IconDllInstance,'SEARCH');
  icons[12] := LoadIcon(IconDllInstance,'EXIT');
  icons[13] := LoadIcon(IconDllInstance,'FAVORITE');
  icons[14] := LoadIcon(IconDllInstance,'DESKTOP');
  icons[15] := LoadIcon(IconDllInstance,'RELOAD');
  icons[16] := LoadIcon(IconDllInstance,'NOTES');
  icons[17] := LoadIcon(IconDllInstance,'NOTEPAD');
  icons[18] := LoadIcon(IconDllInstance,'TRATING_1');
  icons[19] := LoadIcon(IconDllInstance,'TRATING_2');
  icons[20] := LoadIcon(IconDllInstance,'TRATING_3');
  icons[21] := LoadIcon(IconDllInstance,'TRATING_4');
  icons[22] := LoadIcon(IconDllInstance,'TRATING_5');
  icons[23] := LoadIcon(IconDllInstance,'NEXT');
  icons[24] := LoadIcon(IconDllInstance,'PREVIOUS');
  icons[25] := LoadIcon(IconDllInstance,'TH_NEW');
  icons[26] := LoadIcon(IconDllInstance,'ROTATE_0');
  icons[27] := LoadIcon(IconDllInstance,'ROTATE_90');
  icons[28] := LoadIcon(IconDllInstance,'ROTATE_180');
  icons[29] := LoadIcon(IconDllInstance,'ROTATE_270');
  icons[30] := LoadIcon(IconDllInstance,'PLAY');
  icons[31] := LoadIcon(IconDllInstance,'PAUSE');
  icons[32] := LoadIcon(IconDllInstance,'COPY');
  icons[33] := LoadIcon(IconDllInstance,'PASTE');
  icons[34] := LoadIcon(IconDllInstance,'LOADFROMFILE');
  icons[35] := LoadIcon(IconDllInstance,'SAVETOFILE');
  icons[36] := LoadIcon(IconDllInstance,'PANEL');
  icons[37] := LoadIcon(IconDllInstance,'SELECTALL');
  icons[38] := LoadIcon(IconDllInstance,'OPTIONS');
  icons[39] := LoadIcon(IconDllInstance,'ADMINTOOLS');
  icons[40] := LoadIcon(IconDllInstance,'ADDTODB');
  icons[41] := LoadIcon(IconDllInstance,'HELP');
  icons[42] := LoadIcon(IconDllInstance,'RENAME');
  icons[43] := LoadIcon(IconDllInstance,'EXPLORER');
  icons[44] := LoadIcon(IconDllInstance,'SEND');
  icons[45] := LoadIcon(IconDllInstance,'SENDTO');
  icons[46] := LoadIcon(IconDllInstance,'NEW');
  icons[47] := LoadIcon(IconDllInstance,'NEWDIRECTORY');
  icons[48] := LoadIcon(IconDllInstance,'SHELLPREVIOUS');
  icons[49] := LoadIcon(IconDllInstance,'SHELLNEXT');
  icons[50] := LoadIcon(IconDllInstance,'SHELLUP');
  icons[51] := LoadIcon(IconDllInstance,'KEY');
  icons[52] := LoadIcon(IconDllInstance,'FOLDER');
  icons[53] := LoadIcon(IconDllInstance,'ADDFOLDER');
  icons[54] := LoadIcon(IconDllInstance,'BOX');
  icons[55] := LoadIcon(IconDllInstance,'DIRECTORY');
  icons[56] := LoadIcon(IconDllInstance,'THFOLDER');
  icons[57] := LoadIcon(IconDllInstance,'CUT');
  icons[58] := LoadIcon(IconDllInstance,'NEWWINDOW');
  icons[59] := LoadIcon(IconDllInstance,'ADDSINGLEFILE');
  icons[60] := LoadIcon(IconDllInstance,'MANYFILES');
  icons[61] := LoadIcon(IconDllInstance,'MYCOMPUTER');
  icons[62] := LoadIcon(IconDllInstance,'EXPLORERPANEL');
  icons[63] := LoadIcon(IconDllInstance,'INFOPANEL');
  icons[64] := LoadIcon(IconDllInstance,'SAVEASTABLE');
  icons[65] := LoadIcon(IconDllInstance,'EDITDATE');
  icons[66] := LoadIcon(IconDllInstance,'GROUPS');
  icons[67] := LoadIcon(IconDllInstance,'WALLPAPER');
  icons[68] := LoadIcon(IconDllInstance,'NETWORK');
  icons[69] := LoadIcon(IconDllInstance,'WORKGROUP');
  icons[70] := LoadIcon(IconDllInstance,'COMPUTER');
  icons[71] := LoadIcon(IconDllInstance,'SHARE');
  icons[72] := LoadIcon(IconDllInstance,'Z_ZOOMIN_NORM');
  icons[73] := LoadIcon(IconDllInstance,'Z_ZOOMOUT_NORM');
  icons[74] := LoadIcon(IconDllInstance,'Z_FULLSIZE_NORM');
  icons[75] := LoadIcon(IconDllInstance,'Z_BESTSIZE_NORM');
  icons[76] := LoadIcon(IconDllInstance,'E_MAIL');
  icons[77] := LoadIcon(IconDllInstance,'CRYPTFILE');
  icons[78] := LoadIcon(IconDllInstance,'DECRYPTFILE');
  icons[79] := LoadIcon(IconDllInstance,'PASSWORD');
  icons[80] := LoadIcon(IconDllInstance,'EXEFILE');
  icons[81] := LoadIcon(IconDllInstance,'SIMPLEFILE');
  icons[82] := LoadIcon(IconDllInstance,'CONVERT');
  icons[83] := LoadIcon(IconDllInstance,'RESIZE');
  icons[84] := LoadIcon(IconDllInstance,'REFRESHID');
  icons[85] := LoadIcon(IconDllInstance,'DUBLICAT');
  icons[86] := LoadIcon(IconDllInstance,'DELDUBLICAT');
  icons[87] := LoadIcon(IconDllInstance,'UPDATING');
  icons[88] := LoadIcon(IconDllInstance,'Z_FULLSCREEN_NORM');
  icons[89] := LoadIcon(IconDllInstance,'MYDOCUMENTS');
  icons[90] := LoadIcon(IconDllInstance,'MYPICTURES');
  icons[91] := LoadIcon(IconDllInstance,'DESKTOPLINK');
  icons[92] := LoadIcon(IconDllInstance,'IMEDITOR');
  icons[93] := LoadIcon(IconDllInstance,'OTHER_TOOLS');
  icons[94] := LoadIcon(IconDllInstance,'EXPORT_IMAGES');
  icons[95] := LoadIcon(IconDllInstance,'PRINTER');
  icons[96] := LoadIcon(IconDllInstance,'EXIF');
  icons[97] := LoadIcon(IconDllInstance,'GET_USB');
  icons[98] := LoadIcon(IconDllInstance,'USB');
  icons[99] := LoadIcon(IconDllInstance,'TXTFILE');
  icons[100] := LoadIcon(IconDllInstance,'DOWN');
  icons[101] := LoadIcon(IconDllInstance,'UP');
  icons[102] := LoadIcon(IconDllInstance,'CDROM');
  icons[103] := LoadIcon(IconDllInstance,'TREE');
  icons[104] := LoadIcon(IconDllInstance,'CANCELACTION');
  icons[105] := LoadIcon(IconDllInstance,'XDB');
  icons[106] := LoadIcon(IconDllInstance,'XMDB');
  icons[107] := LoadIcon(IconDllInstance,'SORT');
  icons[108] := LoadIcon(IconDllInstance,'FILTER');
  icons[109] := LoadIcon(IconDllInstance,'CLOCK');
  icons[110] := LoadIcon(IconDllInstance,'ATYPE');
  icons[111] := LoadIcon(HInstance,'MAINICON');
  icons[112] := LoadIcon(IconDllInstance,'APPLY_ACTION');
  icons[113] := LoadIcon(IconDllInstance,'RELOADING');
  icons[114] := LoadIcon(IconDllInstance,'STENO');
  icons[115] := LoadIcon(IconDllInstance,'DESTENO');
  icons[116] := LoadIcon(IconDllInstance,'SPLIT');
  icons[117] := LoadIcon(IconDllInstance,'CD_EXPORT');
  icons[118] := LoadIcon(IconDllInstance,'CD_MAPPING');
  icons[119] := LoadIcon(IconDllInstance,'CD_IMAGE');

  //disabled items are bad

  for i:=1 to IconsCount do
    ImageList_ReplaceIcon(FImageList.Handle, -1, icons[i]);
end;

{ TCharObject }

constructor TCharObject.Create;
begin
 Inherited;
 FChar:=#0;
end;

destructor TCharObject.Destroy;
begin
 Inherited;
end;

procedure TCharObject.SetChar(const Value: Char);
begin
  FChar := Value;
end;

initialization

finalization

if DBKernel <> nil then
begin
  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(Dbname));
end;

end.
