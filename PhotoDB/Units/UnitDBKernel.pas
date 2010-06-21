unit UnitDBKernel;

interface

//{$DEFINE ENGL}
{$DEFINE RUS}

uses  win32crc, CheckLst, TabNotBk, WebLink, ShellCtrls, Dialogs, TwButton,
 Rating, ComCtrls, StdCtrls, ExtCtrls, Forms,  Windows, Classes,
 Controls, Graphics, DB, SysUtils, JPEG, UnitDBDeclare, IniFiles,
 GraphicSelectEx, ValEdit, GraphicCrypt, ADODB, uVistaFuncs, uLogger,
   EasyListview, ScPanel, UnitDBCommon, DmProgress, UnitDBCommonGraphics,
   uConstants, CommCtrl, uTime;

type
  TCharObject = class (TObject)
  private
   FChar : Char;
    procedure SetChar(const Value: Char);
  public
  constructor Create; 
  Destructor Destroy; override;
  published
  Property Char_ : Char Read FChar Write SetChar;
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

TUserType = (UtUser, UtAdmin, UtGuest, UtNone);

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

type
  TDBTheme = record
   MainColor : TColor;
   MainFont : TFont;
   EditColor : TColor;
   EditFont : TFont;
   MemoColor : TColor;
   MemoFont : TFont;
   LabelFont : TColor;
   LabelGroupFont : TFont;
   HintColor : TColor;
   ProgressBackColor : TColor;
   ProgressFontColor : TColor;
   ProgressFillColor : TColor;
  end;

type TDBEventsIDArray = array of DBEventsIDArray;

Const IconsCount = 119;

type
 TDbKernelArrayIcons = array [1..IconsCount] of THandle;

type TDBKernel = class(TObject)
  private
    FINIPasswods : TStrings;
    FPasswodsInSession : TStrings;
    FEvents : TDBEventsIDArray;
    FImageList: TImageList;
    fDBUserName: string;
    fDBUserPassword: string;
    fDBUserType: TUserType;
    fDBUserHash: integer;
    FTheme: TDbTheme;
    flock: boolean;
    FForms : array of TForm;
    FThemeNotifys : array of TNotifyEvent; 
    FThemeNotifysForms : array of TForm;
    FApplicationKey : String;
    Chars : array[1..100] of TCharObject;
    Sootv : array [1..16] of integer;
    FDemoMode : Boolean;
    ThreadOpenResultBool : Boolean;
    ThreadOpenResultWork : Boolean;
    FDBs : TPhotoDBFiles;
    fImageOptions : TImageDBOptions;
    procedure LoadDBs;
    procedure SetImageList(const Value: TImageList);
    procedure SetTheme(const Value: TDbTheme);
    procedure setlock(const Value: boolean);
    { Private declarations }
  public              
  IconDllInstance : THandle;
  constructor create;
  destructor destroy; override;
  published
  property DBs : TPhotoDBFiles read FDBs;
  Property ImageList : TImageList read FImageList Write SetImageList;
  procedure UnRegisterChangesID(Sender : TObject; Event_ : DBChangesIDEvent);
  procedure UnRegisterChangesIDByID(Sender : TObject; Event_ : DBChangesIDEvent; id : integer);
  procedure RegisterChangesID(Sender : TObject; Event_ : DBChangesIDEvent);
  procedure UnRegisterChangesIDBySender(Sender : TObject);
  procedure RegisterChangesIDbyID(Sender : TObject; Event_ : DBChangesIDEvent; id : integer);
  procedure DoIDEvent(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
  function TestDB(DBName_ : string; OpenInThread : boolean = false) : boolean;
  function ReadProperty(Key, Name : string) : string;
  procedure DeleteKey(Key: string);
  procedure WriteProperty(Key, Name, value : string);
  procedure WriteBool(Key, Name : string; value : boolean);
  procedure WriteBoolW(Key, Name : string; value : boolean);
  procedure WriteInteger(Key, Name: string; value: integer);
  procedure WriteStringW(Key, Name, value: string);
  procedure WriteString(Key, Name: string; value: string);
  procedure WriteDateTime(Key, Name : String; Value: TDateTime);
  function ReadKeys(Key: string): TStrings;
  function ReadValues(Key: string): TStrings;
  function ReadBool(Key, Name : string; default : boolean): boolean;
  function ReadRealBool(Key, Name: string; default : boolean): boolean;
  function ReadboolW(Key, Name: string; default : boolean): boolean;
  function ReadInteger(Key, Name : string; default : integer): integer;
  function ReadString(Key, Name : string): string;
  function ReadStringW(Key, Name: string): string;
  function ReadDateTime(Key, Name : string; default : TdateTime): TDateTime;
  procedure BackUpTable;
  procedure LoadColorTheme;
  Procedure SaveCurrentColorTheme;
  Function LogIn(UserName, Password : string; AutoLogin : boolean) : integer;
  Function CreateDBbyName(FileName : string) : integer;
  Function GetDataBase : string;
  function GetDataBaseName: string;
  procedure SetDataBase(DBname_ : string);
  Property Theme : TDbTheme Read FTheme Write SetTheme;
  Procedure SetActivateKey(aName, aKey : String);
  Function ReadActivateKey : String;
  Function GetDemoMode : Boolean;
  Function ReadRegName : string;
  Procedure RecreateThemeToForm(Form : TForm);
  Property Lock : boolean read flock write setlock default false;
  Procedure SaveThemeToFile(FileName : string);
  Procedure LoadThemeFromFile(FileName : string);
  Procedure RegisterForm(Form : TForm);
  Procedure UnRegisterForm(Form : TForm);
  Procedure ReloadGlobalTheme;
  Procedure RegisterProcUpdateTheme(Proc : TNotifyEvent; Form : TForm);
  Procedure UnRegisterProcUpdateTheme(Proc : TNotifyEvent; Form : TForm);
  Procedure DoProcGlobalTheme;
  Function GetTemporaryFolder : String;
  Function ApplicationCode : String;
  Procedure SaveApplicationCode(Key : String);
  Function GetCodeChar(n : integer) : char;
  Function ProgramInDemoMode : Boolean;
  Procedure InitRegModule;
  procedure AddTemporaryPasswordInSession(Pass : String);
  function FindPasswordForCryptImageFile(FileName : String) : String;
  procedure ClearTemporaryPasswordsInSession;
  function FindPasswordForCryptBlobStream(DF : TField): String;
  procedure SavePassToINIDirectory(Pass : String);
  procedure LoadINIPasswords;
  procedure SaveINIPasswords;
  procedure ClearINIPasswords;
  procedure ThreadOpenResult(Result: boolean);
  procedure AddDB(DBName, DBFile, DBIco : string; Force : boolean = false);
  function RenameDB(OldDBName, NewDBName : string) : boolean;
  function DeleteDB(DBName : string) : boolean;
  procedure DeleteValues(Key: string);
  function TestDBEx(DBName_: string; OpenInThread : boolean = false): integer;
  function StringDBVersion(DBVersion : integer) : string;
  procedure MoveDB(OldDBFile, NewDBFile : string);
  function DBExists(DBName : string) : boolean;
  function NewDBName(DBNamePattern : string) : string;
  function ValidDBVersion(DBFile: string; DBVersion : integer) : boolean;
  procedure ActivateDBControls(Form: TForm);
  procedure InitIconDll;
  procedure FreeIconDll;
  procedure ReadDBOptions;
  procedure DoSelectDB;
  procedure GetPasswordsFromParams;
  procedure LoadIcons;
      { Public declarations }
  published
    property ImageOptions : TImageDBOptions read fImageOptions;
  end;

  var Icons : TDbKernelArrayIcons;

function inttochar(int : Integer):char;
function chartoint(ch : char):Integer;

implementation

uses dolphin_db, UnitBackUpTableThread, Language, UnitCrypting, CommonDBSupport,
UnitActiveTableThread, UnitINI, UnitFileCheckerDB, UnitGroupsWork,
UnitCDMappingSupport;

{ TDBKernel }

constructor TDBKernel.Create;
var
  i : integer;
begin
  inherited;
  LoadDBs;
  for i:=1 to 100 do
  Chars[i]:=nil;
  FPasswodsInSession := TStringList.create;
  FINIPasswods := nil;
  FApplicationKey:='';
  fDBUserType:=UtNone;
  //LoadIcons;
  TW.I.Start('TDBKernel -> InitRegModule');
  InitRegModule;
  TW.I.Stop;
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
  i : integer;
begin
  FImageList.Free;
  FINIPasswods.Free;
  FPasswodsInSession.Free;
  for i:=1 to 100 do
  if Chars[i]<>nil then Chars[i].free;
  FreeIconDll;
  inherited;
end;

procedure TDBKernel.DoIDEvent(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  i:integer;
  fXevents : TDBEventsIDArray;
begin
 If not ProgramInDemoMode then
 if not DBInDebug then
 begin
  if CharToInt(GetCodeChar(1))+CharToInt(GetCodeChar(2))<>15 then exit;
 end;            
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

procedure TDBKernel.LoadColorTheme;
var
  Reg : TBDRegistry;
begin
 if DBKernel.Readbool('Options','UseWindowsTheme',True) then
 begin
  Theme_ListColor:=ColorToRGB(clWindow);
  Theme_ListFontColor:=ColorToRGB(clWindowText);
  Theme_MainColor:=ColorToRGB(ClBtnFace);
  Theme_MainFontColor:=ColorToRGB(clWindowText);
  Theme_memoeditcolor:=ColorToRGB(clWindow);
  Theme_memoeditfontcolor:=ColorToRGB(clWindowText);
  Theme_Labelfontcolor:=ColorToRGB(clWindowText);
  Theme_ListSelectColor:=ColorToRGB(clHighlight);
  Theme_ProgressBackColor:=clBlack;
  Theme_ProgressFontColor:=clWhite;
  Theme_ProgressFillColor:=$00009600;
 end else
 begin
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  Reg.OpenKey(GetRegRootKey+'CurrentTheme',true);

  Theme_ListColor:=HexToIntDef(Reg.ReadString('Theme_ListColor'),ColorToRGB(clWindow));
  Theme_ListFontColor:=HexToIntDef(Reg.ReadString('Theme_ListFontColor'),ColorToRGB(clWindowText));
  Theme_MainColor:=HexToIntDef(Reg.ReadString('Theme_MainColor'),ColorToRGB(ClBtnFace));
  Theme_MainFontColor:=HexToIntDef(Reg.ReadString('Theme_MainFontColor'),ColorToRGB(clWindowText));
  Theme_memoeditcolor:=HexToIntDef(Reg.ReadString('Theme_memoeditcolor'),ColorToRGB(clWindow));
  Theme_memoeditfontcolor:=HexToIntDef(Reg.ReadString('Theme_memoeditfontcolor'),ColorToRGB(clWindowText));
  Theme_Labelfontcolor:=HexToIntDef(Reg.ReadString('Theme_Labelfontcolor'),ColorToRGB(clWindowText));
  Theme_ListSelectColor:=HexToIntDef(Reg.ReadString('Theme_ListSelectColor'),ColorToRGB(clHighlight));
  Theme_ProgressBackColor:=HexToIntDef(Reg.ReadString('Theme_ProgressBackColor'),clBlack);
  Theme_ProgressFontColor:=HexToIntDef(Reg.ReadString('Theme_ProgressFontColor'),clWhite);
  Theme_ProgressFillColor:=HexToIntDef(Reg.ReadString('Theme_ProgressFillColor'),$00009600);
  Reg.CloseKey;
  Reg.free;
 end;
end;

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//     fUserRights.Add:=false;
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

function TDBKernel.LogIn(UserName, Password: string; AutoLogin : boolean): integer;
var
  fQuery : TDataSet;
  s1, s2 : string;
begin
  DoSelectDB;
  LoadINIPasswords;
end;

function TDBKernel.Readbool(Key, Name: string; default : boolean): boolean;
var
  Reg : TBDRegistry;
begin         
  Result:=default;
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey+Key,true);
    if AnsiLowerCase(reg.ReadString(Name)) = 'true' then Result := True;
    if AnsiLowerCase(reg.ReadString(Name)) = 'false' then Result := False;
  finally  
    Reg.Free;
  end;
end;

function TDBKernel.ReadRealBool(Key, Name: string; Default : boolean): boolean;
var
  Reg : TBDRegistry;
begin         
  Result := Default;
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + Key, True);
    Result := Reg.ReadBool(Name);
  finally
    Reg.Free;
  end;
end;

function TDBKernel.ReadboolW(Key, Name: string; Default : boolean): boolean;
var
  Reg : TBDRegistry;
begin     
  Result := Default;
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot + Key, True);
    if AnsiLowerCase(Reg.ReadString(Name)) = 'true' then Result := True;
    if AnsiLowerCase(Reg.ReadString(Name)) = 'false' then Result := False;
  finally
    Reg.Free;
  end;
end;

function TDBKernel.ReadInteger(Key, Name : string; Default : integer): integer;
var
  Reg : TBDRegistry;
begin               
  Result:=Default;
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    reg.OpenKey(GetRegRootKey+Key,true);
    Result := strtointdef(reg.ReadString(Name), default);
  finally
    reg.Free;
  end;
end;

function TDBKernel.ReadDateTime(Key, Name : string; Default : TDateTime): TDateTime;
var
  Reg : TBDRegistry;
begin
  Result:=Default;
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey+Key, true);
    if Reg.ValueExists(Name) then
      Result:=Reg.ReadDateTime(Name);
  finally
    reg.Free;
  end;
end;

function TDBKernel.ReadProperty(Key, Name: string): string;
var
  Reg : TBDRegistry;
begin
  Result := '';
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot+Key,true);
    Result:=Reg.ReadString(Name);
  finally
    Reg.Free;
  end;
end;

function TDBKernel.ReadString(Key, Name: string): string;
var
  Reg : TBDRegistry;
begin        
  Result := '';
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey+Key,true);
    Result:=Reg.ReadString(Name);
  finally
    Reg.Free;
  end;
end;

function TDBKernel.ReadKeys(Key: string): TStrings;
var
  Reg : TBDRegistry;
begin     
  Result:=TStringList.Create;
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey+Key,true);
    Reg.GetKeyNames(Result);
  finally
    Reg.Free;
  end;
end;

function TDBKernel.ReadValues(Key: string): TStrings;
var
  Reg : TBDRegistry;
begin           
  Result:=TStringList.Create;
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey+Key,true);
    Reg.GetValueNames(Result);
  finally
    Reg.Free;
  end;
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
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot+Key,true);
    Result:=Reg.ReadString(Name);
  finally
    Reg.Free;
  end;
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

procedure TDBKernel.SetImageList(const Value: TImageList);
begin
  FImageList.assign(Value);
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
    TActiveTableThread.Create(false,FTestTable,true,ThreadOpenResult);
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

procedure TDBKernel.WriteBool(Key, Name: string; value: boolean);
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(GetRegRootKey+Key,true);
  if value then
  Reg.writeString(Name,'True') else
  Reg.writeString(Name,'False');
 except
 end;
 Reg.free;
end;

procedure TDBKernel.WriteBoolW(Key, Name: string; value: boolean);
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try   
  Reg.OpenKey(RegRoot+Key,true);
  if value then
  Reg.writeString(Name,'True') else
  Reg.writeString(Name,'False');
 except
 end;
 Reg.free;
end;

procedure TDBKernel.WriteInteger(Key, Name: string; value: integer);
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(GetRegRootKey+Key,true);
  Reg.WriteString(Name,inttostr(value));
 except
 end;
 Reg.free;
end;

procedure TDBKernel.WriteProperty(Key, Name, value: string);
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot+Key,true);
  Reg.WriteString(Name,value);
 except
 end;
 Reg.Free;
end;

procedure TDBKernel.WriteString(Key, Name, value: string);
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(GetRegRootKey+Key,true);
  Reg.writeString(Name,value);
 except
 end;
 Reg.free;
end;

procedure TDBKernel.WriteStringW(Key, Name, value: string);
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot+Key,true);
  Reg.writeString(Name,value);
 except
 end;
 Reg.free;
end;

procedure TDBKernel.WriteDateTime(Key, Name : String; Value: TDateTime);
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(GetRegRootKey+Key,true);
  Reg.WriteDateTime(Name,Value);
 except
 end;
 Reg.free;
end;

function TDBKernel.GetDataBase: string;
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot,true);
  Result:=Reg.ReadString('DBDefaultName');
 except
 end;
 Reg.Free;
end;

function TDBKernel.GetDataBaseName: string;
var
  i : integer;
begin
 for i:=0 to length(FDBs)-1 do
 if AnsiLowerCase(FDBs[i].FileName)=AnsiLowerCase(DBName) then
 begin
  Result:=FDBs[i]._Name;
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

procedure TDBKernel.SetTheme(const Value: TDbTheme);
begin
  FTheme := Value;
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

procedure TDBKernel.RecreateThemeToForm(Form: TForm);
var
  i, n : integer;
  aTag : integer;
begin
 If Form=nil then exit;
 SetVistaFonts(Form);
 for i:=1 to Form.ComponentCount do
 begin
  if Form.Components[i-1] is TEdit then
  with (Form.Components[i-1] as TEdit) do
  begin
   if Tag>10 then
   begin
    aTag := Tag-10;
    SetVistaContentFonts(Font,1);
   end else
   begin
    aTag := Tag;
    SetVistaContentFonts(Font);
   end;
   SetVistaContentFonts(Font);
   if aTag=0 then
   begin
    Color:=Theme_MemoEditColor;
    Font.Color:=Theme_MemoEditFontColor;
   end else begin
    Color:=Theme_MainColor;
    Font.Color:=Theme_MainFontColor;
   end;
  end;
  if Form.Components[i-1] is TComboBox then
  with (Form.Components[i-1] as TComboBox) do
  begin
   if tag=0 then
   begin
    color:=Theme_MemoEditColor;
    font.color:=Theme_MemoEditFontColor;
   end else begin
    color:=Theme_MainColor;
    font.color:=Theme_MainFontColor;
   end;
  end;
  if Form.Components[i-1] is TComboBoxEx then
  with (Form.Components[i-1] as TComboBoxEx) do
  begin
   if Tag=0 then
   begin
    Color:=Theme_MemoEditColor;
    Font.Color:=Theme_MemoEditFontColor;
   end else begin
    Color:=Theme_MainColor;
    Font.Color:=Theme_MainFontColor;
   end;
  end;

  if Form.Components[i-1] is TListView then
  with (Form.Components[i-1] as TListView) do
  begin
   SetVistaContentFonts(Font);
   Color:=Theme_ListColor;
   Font.Color:=Theme_ListFontColor;
  end;

  if Form.Components[i-1] is TEasyListView then
  with (Form.Components[i-1] as TEasyListView) do
  begin
   Color:=Theme_ListColor;
   Font.Color:=Theme_ListFontColor;
   SetVistaContentFonts(Font);
   Selection.BlendColorSelRect:=Theme_ListSelectColor;
   Selection.BorderColor:=Theme_ListSelectColor;
   Selection.BorderColorSelRect:=Theme_ListSelectColor;
   Selection.Color:=Theme_ListSelectColor;
   PaintInfoItem.BorderColor:=Theme_ListSelectColor;
  end;

  if Form.Components[i-1] is TShellTreeView then
  with (Form.Components[i-1] as TShellTreeView) do
  begin
   Color:=Theme_ListColor;
   Font.Color:=Theme_ListFontColor;
  end;
  if Form.Components[i-1] is TListBox then
  with (Form.Components[i-1] as TListBox) do
  begin
   Color:=Theme_ListColor;
   Font.Color:=Theme_ListFontColor;
  end;

  if Form.Components[i-1] is TCheckListBox then
  with (Form.Components[i-1] as TCheckListBox) do
  begin
   If Tag=0 then
   begin
    Color:=Theme_ListColor;
    Font.Color:=Theme_ListFontColor;
   end;
   If tag=1 then
   begin
    Color:=Theme_MainColor;
    Font.color:=Theme_MainFontColor;
   end;
  end;
  if Form.Components[i-1] is TDateTimePicker then
  with (Form.Components[i-1] as TDateTimePicker) do
  begin
   //SetVistaContentFonts(Font);
   if Tag=0 then
   begin
    Color:=Theme_memoeditcolor;
    Font.color:=Theme_memoeditfontcolor;
   end else begin
    Color:=Theme_MainColor;
    Font.color:=Theme_MainFontColor;
   end;
  end;
  if Form.Components[i-1] is TRating then
  with (Form.Components[i-1] as TRating) do
  begin
   BkColor:=Theme_MainColor;
  end;
  if Form.Components[i-1] is TTwButton then
  with (Form.Components[i-1] as TTwButton) do
  begin
   Color:=Theme_MainColor;
  end;

  if Form.Components[i-1] is TComboBox then
  with (Form.Components[i-1] as TComboBox) do
  begin
   if Tag=0 then
   begin
    Color:=Theme_MainColor;
    Font.Color:=Theme_MainFontColor;
   end;
   if Tag=1 then
   begin
    Color:=Theme_ListColor;
    Font.Color:=Theme_ListFontColor;
   end;
  end;
  if Form.Components[i-1] is TRadioButton then
  with (Form.Components[i-1] as TRadioButton) do
  begin
   if Tag=0 then
   begin
    Font.Color:=Theme_LabelFontColor;
   end;
   if Tag=1 then
   begin
    Font.Color:=Theme_MainFontColor;
   end;
  end;
  if Form.Components[i-1] is TValueListEditor then
  with (Form.Components[i-1] as TValueListEditor) do
  begin
   if Tag=0 then
   begin
    FixedColor:=Theme_MainColor;
    Color:=Theme_memoeditcolor;
    Font.Color:=Theme_memoeditfontcolor;
   end;
   if Tag=1 then
   begin
    FixedColor:=Theme_MainColor;
    Color:=Theme_MainColor;
    Font.Color:=Theme_MainFontColor;
   end;
  end;
  if Form.Components[i-1] is TCheckBox then
  with (Form.Components[i-1] as TCheckBox) do
  begin
   if Tag=0 then
   begin
    Font.Color:=Theme_LabelFontColor;
   end;
   if Tag=1 then
   begin
    Font.Color:=Theme_MainFontColor;
   end;
  end;
  if Form.Components[i-1] is TPanel then
  with (Form.Components[i-1] as TPanel) do
  begin
   if Tag=0 then
   begin
    Color:=Theme_MainColor;
    Font.Color:=Theme_MainFontColor;
   end;
   if Tag=1 then
   begin
    Color:=Theme_ListColor;
    Font.Color:=Theme_ListFontColor;
   end;
  end;

  if Form.Components[i-1] is TScrollPanel then
  with (Form.Components[i-1] as TScrollPanel) do
  begin
   if Tag=0 then
   begin
    Color:=Theme_MainColor;
    Font.Color:=Theme_MainFontColor;
   end;
   if Tag=1 then
   begin
    Color:=Theme_ListColor;
    Font.Color:=Theme_ListFontColor;
   end;
  end;

  if Form.Components[i-1] is TWebLink then
  with (Form.Components[i-1] as TWebLink) do
  begin    
   SetVistaContentFonts(Font,1);
   if Tag>-1 then
   begin
    bkcolor:=Theme_MainColor;
    font.color:=Theme_MainFontColor;
    If Tag=1 then Font.Style:=[fsBold];
    If Tag=2 then Font.Style:=[fsUnderline];
   end;
  end;
  if Form.Components[i-1] is TLabel then
  with (Form.Components[i-1] as TLabel) do
  begin
   //n:=Tag;
   aTag:=Tag mod 10000;
   ParentColor:=true;
   ParentFont:=true;
   If aTag=1 then Font.Style:=[fsBold];
   If aTag=2 then Font.Style:=[fsUnderline];
   If aTag>100 then
   begin
    If (Tag>100) and (Tag<200) then Font.Style:=[fsBold];
    If (Tag>200) and (Tag<300) then Font.Style:=[fsUnderline];
    Font.Size:=(Tag mod 100);
   end;
   If aTag>1000 then
   begin
    If (aTag>1000) and (aTag<2000) then Font.Style:=[fsBold];
    If (aTag>2000) and (aTag<3000) then Font.Style:=[fsUnderline];
    if (aTag mod 1000)<100 then
   end;
   Font.Color:=Theme_memoeditFontcolor;
   if Tag div 10000>0 then Font.Name:='Times New Roman';  
   SetVistaContentFonts(Font,1);
   //tag:=n;
  end;
  if Form.Components[i-1] is TButton then
  with (Form.Components[i-1] as TButton) do
  begin
   Font.Color:=Theme_MainFontColor;
  end;
  if Form.Components[i-1] is TTabbedNotebook then
  with (Form.Components[i-1] as TTabbedNotebook) do
  begin
   //Color:=Theme_MainColor;
  end;
  if Form.Components[i-1] is TShape then
  with (Form.Components[i-1] as TShape) do
  begin
   if Tag=1 then
   begin
    Brush.Color:=Theme_MainColor;
    Pen.Color:=Theme_MainColor;
   end;
  end;
  if Form.Components[i-1] is TGraphicSelectEx then
  with (Form.Components[i-1] as TGraphicSelectEx) do
  begin
   Color:=Theme_MainColor;
   SelColor:=Theme_MainFontColor;
  end;
  if Form.Components[i-1] is TMemo then
  with (Form.Components[i-1] as TMemo) do
  begin
   if Tag>10 then
   begin
    aTag := Tag-10;
    SetVistaContentFonts(Font,1);
   end else
   begin
    aTag := Tag;
    SetVistaContentFonts(Font);
   end;
   if Tag=0 then
   begin
    Color:=Theme_memoeditcolor;
    Font.Color:=Theme_memoeditfontcolor;
   end else if Tag=-1 then
   begin

   end else
   begin
    Color:=Theme_MainColor;
    Font.color:=Theme_MainFontColor;
   end;
   if aTag=10 then
   begin
    color:=Theme_MainColor;
    ParentColor:=true;
   end;
  end;
  if Form.Components[i-1] is TRichEdit then
  with (Form.Components[i-1] as TRichEdit) do
  begin
   SetVistaContentFonts(Font);
   if Tag=0 then
   begin
    Color:=Theme_memoeditcolor;
    Font.color:=Theme_memoeditfontcolor;
   end else begin
    Color:=Theme_MainColor;
    Font.color:=Theme_MainFontColor;
   end;
  end;

  if Form.Components[i-1] is TDmProgress then
  with (Form.Components[i-1] as TDmProgress) do
  begin
   SetVistaContentFonts(Font,1);
   Color:=Theme_ProgressBackColor;
   BorderColor:=Theme_ProgressFillColor;
   CoolColor:=Theme_ProgressFillColor;
   Font.Color:=Theme_ProgressFontColor;
   Position:=Position; //to remake image
  end;

 end;
 if Form.Tag<>1 then //UpdaterForm
 Form.Color:=Theme_MainColor;
 Form.font.Color:=Theme_MainFontColor;
end;

procedure TDBKernel.setlock(const Value: boolean);
begin
 flock := Value;
end;

procedure TDBKernel.SaveCurrentColorTheme;
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 if not Reg.OpenKey(GetRegRootKey+'CurrentTheme', true) then
 begin
  exit;
 end;
 Reg.WriteString('Theme_ListColor','$'+IntToHex(Theme_ListColor,8));
 Reg.WriteString('Theme_ListFontColor','$'+IntToHex(Theme_ListFontColor,8));
 Reg.WriteString('Theme_MainColor','$'+IntToHex(Theme_MainColor,8));
 Reg.WriteString('Theme_MainFontColor','$'+IntToHex(Theme_MainFontColor,8));
 Reg.WriteString('Theme_memoeditcolor','$'+IntToHex(Theme_memoeditcolor,8));
 Reg.WriteString('Theme_memoeditfontcolor','$'+IntToHex(Theme_memoeditfontcolor,8));
 Reg.WriteString('Theme_Labelfontcolor','$'+IntToHex(Theme_Labelfontcolor,8));
 Reg.WriteString('Theme_ListSelectColor','$'+IntToHex(Theme_ListSelectColor,8));

 Reg.WriteString('Theme_ProgressBackColor','$'+IntToHex(Theme_ProgressBackColor,8));
 Reg.WriteString('Theme_ProgressFontColor','$'+IntToHex(Theme_ProgressFontColor,8));
 Reg.WriteString('Theme_ProgressFillColor','$'+IntToHex(Theme_ProgressFillColor,8));
end;

procedure TDBKernel.SaveThemeToFile(FileName: string);
var
  IniFile : TIniFile;
begin
 IniFile:=TIniFile.Create(FileName);
 try
 IniFile.WriteString('THEME','Theme_ListColor','$'+IntToHex(Theme_ListColor,8));
 IniFile.WriteString('THEME','Theme_ListFontColor','$'+IntToHex(Theme_ListFontColor,8));
 IniFile.WriteString('THEME','Theme_MainColor','$'+IntToHex(Theme_MainColor,8));
 IniFile.WriteString('THEME','Theme_MainFontColor','$'+IntToHex(Theme_MainFontColor,8));
 IniFile.WriteString('THEME','Theme_memoeditcolor','$'+IntToHex(Theme_memoeditcolor,8));
 IniFile.WriteString('THEME','Theme_memoeditfontcolor','$'+IntToHex(Theme_memoeditfontcolor,8));
 IniFile.WriteString('THEME','Theme_Labelfontcolor','$'+IntToHex(Theme_Labelfontcolor,8));
 IniFile.WriteString('THEME','Theme_ListSelectColor','$'+IntToHex(Theme_ListSelectColor,8));

 IniFile.WriteString('THEME','Theme_ProgressBackColor','$'+IntToHex(Theme_ProgressBackColor,8));
 IniFile.WriteString('THEME','Theme_ProgressFontColor','$'+IntToHex(Theme_ProgressFontColor,8));
 IniFile.WriteString('THEME','Theme_ProgressFillColor','$'+IntToHex(Theme_ProgressFillColor,8));
 except
  MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_ERROR_WRITING_THEME,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
 IniFile.Free;
end;

procedure TDBKernel.LoadThemeFromFile(FileName: string);
var
  IniFile : TIniFile;
begin
 IniFile:=TIniFile.Create(FileName);

 Theme_ListColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_ListColor',''),ColorToRGB(clWindow));
 Theme_ListFontColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_ListFontColor',''),ColorToRGB(clWindowText));
 Theme_MainColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_MainColor',''),ColorToRGB(ClBtnFace));
 Theme_MainFontColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_MainFontColor',''),ColorToRGB(clWindowText));
 Theme_memoeditcolor:=HexToIntDef(IniFile.ReadString('THEME','Theme_memoeditcolor',''),ColorToRGB(clWindow));
 Theme_memoeditfontcolor:=HexToIntDef(IniFile.ReadString('THEME','Theme_memoeditfontcolor',''),ColorToRGB(clWindowText));
 Theme_Labelfontcolor:=HexToIntDef(IniFile.ReadString('THEME','Theme_Labelfontcolor',''),ColorToRGB(clWindowText));
 Theme_ListSelectColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_ListSelectColor',''),ColorToRGB(clHighlight));

 Theme_ProgressBackColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_ProgressBackColor',''),clBlack);
 Theme_ProgressFontColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_ProgressFontColor',''),clWhite);
 Theme_ProgressFillColor:=HexToIntDef(IniFile.ReadString('THEME','Theme_ProgressFillColor',''),$00009600);

 IniFile.Free;
end;

procedure TDBKernel.ActivateDBControls(Form: TForm);
var
  i : integer;
begin

 for i:=0 to Form.ComponentCount-1 do
 begin
  if Form.Components[i] is TWebLink then
  (Form.Components[i] as TWebLink).ImageCanRegenerate:=true;
  if Form.Components[i] is TTwButton then
  (Form.Components[i] as TTwButton).ImageCanRegenerate:=true;
  if Form.Components[i] is TRating then
  (Form.Components[i] as TRating).ImageCanRegenerate:=true;
 end;
end;
procedure TDBKernel.RegisterForm(Form: TForm);
var
  i : integer;
  isform : boolean;
begin
 isform:=false;
 ActivateDBControls(Form);
 For i:=0 to length(FForms)-1 do
 begin
  if FForms[i]=form then
  begin
   isform:=true;
   break;
  end;
 end;
 If not isform then
 begin
  SetLength(FForms,length(FForms)+1);
  FForms[length(FForms)-1]:=Form;
  
  if IsWindowsVista then
  SetVistaFonts(Form);
 end;
end;

procedure TDBKernel.UnRegisterForm(Form: TForm);
var
  i, j : integer;
begin
 For i:=0 to length(FForms)-1 do
 begin
  If FForms[i]=Form then
  begin
   For j:=i to length(FForms)-2 do
   FForms[j]:=FForms[j+1];
   SetLength(FForms,length(FForms)-1);
   Exit;
  end
 end;
end;

procedure TDBKernel.ReloadGlobalTheme;
var
  i : integer;
begin
 For i:=0 to length(FForms)-1 do
 begin
  RecreateThemeToForm(FForms[i]);
 end;
 DoProcGlobalTheme;
end;

procedure TDBKernel.RegisterProcUpdateTheme(Proc: TNotifyEvent; Form : TForm);
var
  i : integer;
  isproc : boolean;
  TNE : TNotifyEvent;
begin
 isproc:=false;
 For i:=0 to length(FThemeNotifys)-1 do
 begin
  TNE:=FThemeNotifys[i];
  if (@TNE=@Proc) and (FThemeNotifysForms[i]=Form) then
  begin
   isproc:=true;
   break;
  end;
 end;
 If not isproc then
 begin
  TNE:=Proc;
  SetLength(FThemeNotifys,length(FThemeNotifys)+1);
  FThemeNotifys[length(FThemeNotifys)-1]:=TNE;

  SetLength(FThemeNotifysForms,length(FThemeNotifysForms)+1);
  FThemeNotifysForms[length(FThemeNotifysForms)-1]:=Form;
 end;
end;

procedure TDBKernel.UnRegisterProcUpdateTheme(Proc: TNotifyEvent; Form : TForm);
var
  i, j : integer;
  TNE : TNotifyEvent;
begin
 For i:=0 to length(FThemeNotifys)-1 do
 begin
  TNE:=FThemeNotifys[i];
  if (@TNE=@Proc) and (FThemeNotifysForms[i]=Form) then
  begin
   For j:=i to length(FThemeNotifys)-2 do
   FThemeNotifys[j]:=FThemeNotifys[j+1];
   SetLength(FThemeNotifys,length(FThemeNotifys)-1);

   For j:=i to length(FThemeNotifysForms)-2 do
   FThemeNotifysForms[j]:=FThemeNotifysForms[j+1];
   SetLength(FThemeNotifysForms,length(FThemeNotifysForms)-1);

   Exit;
  end
 end;
end;

procedure TDBKernel.DoProcGlobalTheme;
var
  i : integer;
begin
 For i:=0 to length(FThemeNotifys)-1 do
 begin
  if Assigned(FThemeNotifys[i]) then
  FThemeNotifys[i](Self);
 end;
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
begin
 if FolderView then exit;
 if Now-DBkernel.ReadDateTime('Options','BackUpDateTime',0)>DBKernel.ReadInteger('Options','BackUpdays',7) then
 begin
  if GetDBType=DB_TYPE_MDB then
  begin
   DBkernel.WriteBool('StartUp','BackUp',True);
  end;
 end;
end;

procedure TDBKernel.InitRegModule;
begin
 ReadActivateKey;
 FDemoMode:=GetDemoMode;
end;

procedure TDBKernel.AddTemporaryPasswordInSession(Pass: String);
var
  i : integer;
begin
 for i:=1 to FPasswodsInSession.Count do
 if FPasswodsInSession[i-1]=Pass then exit;
 FPasswodsInSession.Add(Pass);
end;

procedure TDBKernel.ClearTemporaryPasswordsInSession;
begin
 FPasswodsInSession.Clear;
end;

function TDBKernel.FindPasswordForCryptImageFile(FileName: String): String;
var
  i : integer;
begin
 Result:='';
 FileName:=ProcessPath(FileName);
 for i:=1 to FPasswodsInSession.Count do
 if ValidPassInCryptGraphicFile(FileName,FPasswodsInSession[i-1]) then
 begin
  Result:=FPasswodsInSession[i-1];
  Break;
 end;
 for i:=1 to FINIPasswods.Count do
 if ValidPassInCryptGraphicFile(FileName,FINIPasswods[i-1]) then
 begin
  Result:=FINIPasswods[i-1];
  Break;
 end;
end;

function TDBKernel.FindPasswordForCryptBlobStream(DF : TField): String;
var
  i : integer;
begin
 Result:='';
 for i:=1 to FPasswodsInSession.Count do
 if ValidPassInCryptBlobStreamJPG(DF,FPasswodsInSession[i-1]) then
 begin
  Result:=FPasswodsInSession[i-1];
  Break;
 end;
 for i:=1 to FINIPasswods.Count do
 if ValidPassInCryptBlobStreamJPG(DF,FINIPasswods[i-1]) then
 begin
  Result:=FINIPasswods[i-1];
  Break;
 end;
end;

procedure TDBKernel.SavePassToINIDirectory(Pass: String);
var
  i : integer;
begin
 for i:=1 to FINIPasswods.Count do
 if FINIPasswods[i-1]=Pass then exit;
 FINIPasswods.Add(Pass);
 SaveINIPasswords;
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
  begin
   FINIPasswods:=DeCryptTStrings(s,fDBUserPassword)
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
  Reg.OpenKey(GetRegRootKey,true);
  s:=CryptTStrings(FINIPasswods,fDBUserPassword);
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
  i : integer;
begin
 SetLength(FDBs,0);
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 Reg.OpenKey(RegRoot+'dbs',true);
 List:=TStringList.Create;
 Reg.GetKeyNames(List);
 SetLength(FDBs,List.Count);
 for i:=0 to List.Count-1 do
 begin
  Reg.CloseKey;
  Reg.OpenKey(RegRoot+'dbs\'+List[i],true);
  FDBs[i]._Name:=List[i];
  FDBs[i].Icon:=Reg.ReadString('icon');
  FDBs[i].FileName:=Reg.ReadString('FileName');
  FDBs[i].aType:=Reg.ReadInteger('type');
 end;
 Reg.Free;
 List.Free;
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
  DB._Name:=OldDBName;
  DB.Icon:=Reg.ReadString('icon');
  DB.FileName:=Reg.ReadString('FileName');
  DB.aType:=Reg.ReadInteger('type');
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
  IconDllInstance := LoadLibrary(PChar(ProgramDir + 'icons.dll'));
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
  for i:=0 to Length(DBs)-1 do
  begin
   if DBs[i]._Name=ParamDBFile then
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

procedure TDBKernel.LoadIcons;
var
  I : Integer;
begin
  FImageList:=TImageList.Create(nil);
  FImageList.Width:=16;
  FImageList.Height:=16;
  FImageList.BkColor:=clMenu;
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
  //ConvertTo32BitImageList(FImageList);
  
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

 if DBKernel<>nil then
 begin
  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(dbname));
 end;
 
end.
