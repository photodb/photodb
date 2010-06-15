unit UnitDBKernel;

interface

//{$DEFINE ENGL}
{$DEFINE RUS}

uses  win32crc, CheckLst, TabNotBk, WebLink, ShellCtrls, Dialogs, TwButton,
 Rating, ComCtrls, StdCtrls, ExtCtrls, Forms,  Windows, Classes,
 Controls, Graphics, DB, DBTables, SysUtils, JPEG, UnitDBDeclare, IniFiles,
 GraphicSelectEx, ValEdit, GraphicCrypt, ADODB, uVistaFuncs,
   EasyListview, ScPanel, UnitDBCommon, DmProgress, UnitDBCommonGraphics;

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


LOG_IN_OK                   = 0;
LOG_IN_ERROR                = 1;
LOG_IN_USER_NOT_FOUND       = 2;
LOG_IN_TABLE_NOT_FOUND      = 3;
LOG_IN_PASSWORD_WRONG       = 4;
LOG_IN_USER_ALREADY_EXISTS  = 5;

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
 TDbKernelArrayIcons = array [1..IconsCount] of TIcon;

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
    procedure SetDBUserName(const Value: string);
    procedure SetDBUserPassword(const Value: string);
    procedure SetDBUserType(const Value: TUserType);
    procedure SetDBUserHash(const Value: integer);
    procedure SetTheme(const Value: TDbTheme);
    procedure setlock(const Value: boolean);
    { Private declarations }
  public              
  IconDllInstance : THandle;
  constructor create;
  destructor destroy; override;
  published
  property DBs : TPhotoDBFiles read FDBs;
  function CheckAdmin : integer;
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
  Property DBUserName : string read fDBUserName write SetDBUserName;
  Property DBUserPassword : string read fDBUserPassword write SetDBUserPassword;
  Property DBUserType : TUserType read fDBUserType write SetDBUserType;
  Property DBUserHash : integer read fDBUserHash write SetDBUserHash;
  procedure LoadColorTheme;
  Procedure SaveCurrentColorTheme;
  Function LogIn(UserName, Password : string; AutoLogin : boolean) : integer;
  Function CreateDBbyName(FileName : string) : integer;
  Procedure SaveCurrentUserAsDefault;
  Procedure TryToLoadDefaultUser(var DBUserName_, DBUserPassword_ : string);
  Function UpdateUserInfo(Login : string; OldPass, NewPass : string; Image : TJpegImage; UpdateImage : boolean) : integer;
  Function CreateNewUser(Login, Password : string; image : TJpegImage) : integer;
  Function TestLoginDB : boolean;
  Function DeleteUser(Login : string) : integer;
  Function LoadUserImage(Login : String; var image : TJpegImage) : integer;
  procedure LoginErrorMsg(Error : integer);
  Function CreateLoginDB : integer;
  Function CancelUserAsDefault : integer;
  Function GetLoginDataBaseName : string;
  class function GetLoginDataBaseFileName : string;
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
  procedure FixLoginDB;
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
  function GetUserAccess(Login : String; var Access : string): Integer;
  function SetUserAccess(Login : String; Access : string): Integer;
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
      { Public declarations }
  published
    property ImageOptions : TImageDBOptions read fImageOptions;
  end;

  var icons : TDbKernelArrayIcons;

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

  FImageList:=TImageList.Create(nil);
  FImageList.Width:=16;
  FImageList.Height:=16;
  FImageList.BkColor:=clMenu;
  for i:=1 to IconsCount do
  icons[i]:=Ticon.Create;
  InitIconDll;
  //TODO : load icon at first access???
  icons[1].handle:=loadicon(IconDllInstance,'SHELL');
  icons[2].handle:=loadicon(IconDllInstance,'SLIDE_SHOW');
  icons[3].handle:=loadicon(IconDllInstance,'REFRESH_THUM');
  icons[4].handle:=loadicon(IconDllInstance,'RATING_STAR');
  icons[5].handle:=loadicon(IconDllInstance,'DELETE_INFO');
  icons[6].handle:=loadicon(IconDllInstance,'DELETE_FILE');
  icons[7].handle:=loadicon(IconDllInstance,'COPY_ITEM');
  icons[8].handle:=loadicon(IconDllInstance,'PROPERTIES');
  icons[9].handle:=loadicon(IconDllInstance,'PRIVATE');
  icons[10].handle:=loadicon(IconDllInstance,'COMMON');
  icons[11].handle:=loadicon(IconDllInstance,'SEARCH');
  icons[12].handle:=loadicon(IconDllInstance,'EXIT');
  icons[13].handle:=loadicon(IconDllInstance,'FAVORITE');
  icons[14].handle:=loadicon(IconDllInstance,'DESKTOP');
  icons[15].handle:=loadicon(IconDllInstance,'RELOAD');
  icons[16].handle:=loadicon(IconDllInstance,'NOTES');
  icons[17].handle:=loadicon(IconDllInstance,'NOTEPAD');
  icons[18].handle:=loadicon(IconDllInstance,'TRATING_1');
  icons[19].handle:=loadicon(IconDllInstance,'TRATING_2');
  icons[20].handle:=loadicon(IconDllInstance,'TRATING_3');
  icons[21].handle:=loadicon(IconDllInstance,'TRATING_4');
  icons[22].handle:=loadicon(IconDllInstance,'TRATING_5');
  icons[23].handle:=loadicon(IconDllInstance,'NEXT');
  icons[24].handle:=loadicon(IconDllInstance,'PREVIOUS');
  icons[25].handle:=loadicon(IconDllInstance,'TH_NEW');
  icons[26].handle:=loadicon(IconDllInstance,'ROTATE_0');
  icons[27].handle:=loadicon(IconDllInstance,'ROTATE_90');
  icons[28].handle:=loadicon(IconDllInstance,'ROTATE_180');
  icons[29].handle:=loadicon(IconDllInstance,'ROTATE_270');
  icons[30].handle:=loadicon(IconDllInstance,'PLAY');
  icons[31].handle:=loadicon(IconDllInstance,'PAUSE');
  icons[32].handle:=loadicon(IconDllInstance,'COPY');
  icons[33].handle:=loadicon(IconDllInstance,'PASTE');
  icons[34].handle:=loadicon(IconDllInstance,'LOADFROMFILE');
  icons[35].handle:=loadicon(IconDllInstance,'SAVETOFILE');
  icons[36].handle:=loadicon(IconDllInstance,'PANEL');
  icons[37].handle:=loadicon(IconDllInstance,'SELECTALL');
  icons[38].handle:=loadicon(IconDllInstance,'OPTIONS');
  icons[39].handle:=loadicon(IconDllInstance,'ADMINTOOLS');
  icons[40].handle:=loadicon(IconDllInstance,'ADDTODB');
  icons[41].handle:=loadicon(IconDllInstance,'HELP');
  icons[42].handle:=loadicon(IconDllInstance,'RENAME');
  icons[43].handle:=loadicon(IconDllInstance,'EXPLORER');
  icons[44].handle:=loadicon(IconDllInstance,'SEND');
  icons[45].handle:=loadicon(IconDllInstance,'SENDTO');
  icons[46].handle:=loadicon(IconDllInstance,'NEW');
  icons[47].handle:=loadicon(IconDllInstance,'NEWDIRECTORY');
  icons[48].handle:=loadicon(IconDllInstance,'SHELLPREVIOUS');
  icons[49].handle:=loadicon(IconDllInstance,'SHELLNEXT');
  icons[50].handle:=loadicon(IconDllInstance,'SHELLUP');
  icons[51].handle:=loadicon(IconDllInstance,'KEY');
  icons[52].handle:=loadicon(IconDllInstance,'FOLDER');
  icons[53].handle:=loadicon(IconDllInstance,'ADDFOLDER');
  icons[54].handle:=loadicon(IconDllInstance,'BOX');
  icons[55].handle:=loadicon(IconDllInstance,'DIRECTORY');
  icons[56].handle:=loadicon(IconDllInstance,'THFOLDER');
  icons[57].handle:=loadicon(IconDllInstance,'CUT');
  icons[58].handle:=loadicon(IconDllInstance,'NEWWINDOW');
  icons[59].handle:=loadicon(IconDllInstance,'ADDSINGLEFILE');
  icons[60].handle:=loadicon(IconDllInstance,'MANYFILES');
  icons[61].handle:=loadicon(IconDllInstance,'MYCOMPUTER');
  icons[62].handle:=loadicon(IconDllInstance,'EXPLORERPANEL');
  icons[63].handle:=loadicon(IconDllInstance,'INFOPANEL');
  icons[64].handle:=loadicon(IconDllInstance,'SAVEASTABLE');
  icons[65].handle:=loadicon(IconDllInstance,'EDITDATE');
  icons[66].handle:=loadicon(IconDllInstance,'GROUPS');
  icons[67].handle:=loadicon(IconDllInstance,'WALLPAPER');
  icons[68].handle:=loadicon(IconDllInstance,'NETWORK');
  icons[69].handle:=loadicon(IconDllInstance,'WORKGROUP');
  icons[70].handle:=loadicon(IconDllInstance,'COMPUTER');
  icons[71].handle:=loadicon(IconDllInstance,'SHARE');
  icons[72].handle:=loadicon(IconDllInstance,'Z_ZOOMIN_NORM');
  icons[73].handle:=loadicon(IconDllInstance,'Z_ZOOMOUT_NORM');
  icons[74].handle:=loadicon(IconDllInstance,'Z_FULLSIZE_NORM');
  icons[75].handle:=loadicon(IconDllInstance,'Z_BESTSIZE_NORM');
  icons[76].handle:=loadicon(IconDllInstance,'E_MAIL');
  icons[77].handle:=loadicon(IconDllInstance,'CRYPTFILE');
  icons[78].handle:=loadicon(IconDllInstance,'DECRYPTFILE');
  icons[79].handle:=loadicon(IconDllInstance,'PASSWORD');
  icons[80].handle:=loadicon(IconDllInstance,'EXEFILE');
  icons[81].handle:=loadicon(IconDllInstance,'SIMPLEFILE');
  icons[82].handle:=loadicon(IconDllInstance,'CONVERT');
  icons[83].handle:=loadicon(IconDllInstance,'RESIZE');
  icons[84].handle:=loadicon(IconDllInstance,'REFRESHID');
  icons[85].handle:=loadicon(IconDllInstance,'DUBLICAT');
  icons[86].handle:=loadicon(IconDllInstance,'DELDUBLICAT');
  icons[87].handle:=loadicon(IconDllInstance,'UPDATING');
  icons[88].handle:=loadicon(IconDllInstance,'Z_FULLSCREEN_NORM');
  icons[89].handle:=loadicon(IconDllInstance,'MYDOCUMENTS');
  icons[90].handle:=loadicon(IconDllInstance,'MYPICTURES');
  icons[91].handle:=loadicon(IconDllInstance,'DESKTOPLINK');
  icons[92].handle:=loadicon(IconDllInstance,'IMEDITOR');
  icons[93].handle:=loadicon(IconDllInstance,'OTHER_TOOLS');
  icons[94].handle:=loadicon(IconDllInstance,'EXPORT_IMAGES');
  icons[95].handle:=loadicon(IconDllInstance,'PRINTER');
  icons[96].handle:=loadicon(IconDllInstance,'EXIF');
  icons[97].handle:=loadicon(IconDllInstance,'GET_USB');
  icons[98].handle:=loadicon(IconDllInstance,'USB');
  icons[99].handle:=loadicon(IconDllInstance,'TXTFILE');
  icons[100].handle:=loadicon(IconDllInstance,'DOWN');
  icons[101].handle:=loadicon(IconDllInstance,'UP');
  icons[102].handle:=loadicon(IconDllInstance,'CDROM');
  icons[103].handle:=loadicon(IconDllInstance,'TREE');
  icons[104].handle:=loadicon(IconDllInstance,'CANCELACTION');
  icons[105].handle:=loadicon(IconDllInstance,'XDB');
  icons[106].handle:=loadicon(IconDllInstance,'XMDB');
  icons[107].handle:=loadicon(IconDllInstance,'SORT');
  icons[108].handle:=loadicon(IconDllInstance,'FILTER');  
  icons[109].handle:=loadicon(IconDllInstance,'CLOCK');
  icons[110].handle:=loadicon(IconDllInstance,'ATYPE');
  icons[111].handle:=loadicon(HInstance,'MAINICON');
  icons[112].handle:=loadicon(IconDllInstance,'APPLY_ACTION');
  icons[113].handle:=loadicon(IconDllInstance,'RELOADING');      
  icons[114].handle:=loadicon(IconDllInstance,'STENO');
  icons[115].handle:=loadicon(IconDllInstance,'DESTENO');     
  icons[116].handle:=loadicon(IconDllInstance,'SPLIT');        
  icons[117].handle:=loadicon(IconDllInstance,'CD_EXPORT');
  icons[118].handle:=loadicon(IconDllInstance,'CD_MAPPING');
  icons[119].handle:=loadicon(IconDllInstance,'CD_IMAGE');

//disabled items are bad
//  ConvertTo32BitImageList(FImageList);
  for i:=1 to IconsCount do
  FImageList.AddIcon(icons[i]);
  InitRegModule;
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
 if GetDBType(FileName)=DB_TYPE_BDE then if BDECreateImageTable(FileName) then result:=0;
 if GetDBType(FileName)=DB_TYPE_MDB then
 begin
  if ADOCreateImageTable(FileName) then result:=0;
  ADOCreateSettingsTable(FileName);
 end;
end;

function TDBKernel.CreateNewUser(Login, Password: string;
  image: tjpegimage): integer;
var
  fQuery : TDataSet;
  Buf: PChar;
  WinDir : String;
  FUserMenu : TUserMenuItemArray;
  S : TStrings;
  i, c : integer;
  Reg : TBDRegistry;
  SQL : string;
begin
 result:=LOG_IN_ERROR;

 if not TestLoginDB then
 begin
  result:=LOG_IN_TABLE_NOT_FOUND;
  exit;
 end;
 fQuery:=GetQuery(GetLoginDataBaseFileName);
 fQuery.Active:=false;
 SetSQL(fQuery,'Select * from '+GetLoginDataBaseName+' Where Logo = "'+Login+'"');
 try
  fQuery.Active:=true;
 except       
  on e : Exception do
  begin
   EventLog(':TDBKernel::CreateNewUser() throw exception: '+e.Message);
   result:=LOG_IN_TABLE_NOT_FOUND;
   FreeDS(fQuery);
   exit;
  end;
 end;
 if fQuery.RecordCount<>0 then
 begin
  result:=LOG_IN_USER_ALREADY_EXISTS;
  FreeDS(fQuery);
  exit;
 end;
 fQuery.Active:=false;
 SQL:='';
 SQL:=SQL+'insert into '+GetLoginDataBaseName;
 SQL:=SQL+'(FIMAGE,LOGO,PASSHESH)';
 SQL:=SQL+'values (:FIMAGE0,:LOGO,:PASSHESH)';
 SetSQL(fQuery,SQL);
  try
   AssignParam(fQuery,0,image);
  except
  on e : Exception do
   begin
    EventLog(':TDBKernel::CreateNewUser() throw exception: '+e.Message);
    result:=LOG_IN_ERROR;
    FreeDS(fQuery);
    exit;
   end;
  end;
  SetStrParam(fQuery,1,Login);
  SetStrParam(fQuery,2,IntToHex(Hash_Cos_C(Password),8));
  try
   ExecSQL(fQuery);
  except
  on e : Exception do
   begin
    EventLog(':TDBKernel::CreateNewUser() throw exception: '+e.Message);
    result:=LOG_IN_ERROR;
    FreeDS(fQuery);
    exit;
   end;
  end;
  try
   GetMem(Buf, MAX_PATH);
   GetWindowsDirectory(Buf, MAX_PATH);
   WinDir:=Buf;
   FreeMem(Buf);
   UnFormatDir(WinDir);
   Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
   Reg.OpenKey(RegRoot+Login+'\Menu',true);
   S := TStringList.create;
   Reg.GetKeyNames(S);
   Reg.CloseKey;
   c:=0;
   for i:=1 to S.Count do
   begin
    Reg.DeleteKey(RegRoot+Login+'Menu\.'+IntToStr(i));
    c:=c+1;
   end;
   s.free;
   SetLength(FUserMenu,2);
   FUserMenu[0].Caption:=TEXT_MES_EDIT;
   FUserMenu[0].EXEFile:=WinDir+'\system32\mspaint.exe';
   FUserMenu[0].Params:='%1';
   FUserMenu[0].Icon:=WinDir+'\system32\mspaint.exe,0';
   FUserMenu[0].UseSubMenu:=True;
   FUserMenu[1].Caption:=TEXT_MES_FIND;
   FUserMenu[1].EXEFile:=WinDir+'\explorer.exe';
   FUserMenu[1].Params:='/select, %1';
   FUserMenu[1].Icon:=WinDir+'\explorer.exe,0';
   FUserMenu[1].UseSubMenu:=True;
   if c=0 then
   for i:=0 to Length(FUserMenu)-1 do
   begin
    Reg.OpenKey(RegRoot+Login+'\Menu\.'+IntToStr(i),true);
    Reg.WriteString('Caption',FUserMenu[i].Caption);
    Reg.WriteString('EXEFile',FUserMenu[i].EXEFile);
    Reg.WriteString('Params',FUserMenu[i].Params);
    Reg.WriteString('Icon',FUserMenu[i].Icon);
    Reg.WriteBool('UseSubMenu',FUserMenu[i].UseSubMenu);
    Reg.CloseKey;
   end;
   Reg.Free;
   DBKernel.WriteboolW('Options','SlideShow_UseCoolStretch', true);
  except
   on e : Exception do EventLog(':TDBKernel::CreateNewUser() throw exception: '+e.Message);
  end;
  result:=LOG_IN_OK;
  FreeDS(fQuery);
end;

function TDBKernel.DeleteUser(Login: string): integer;
var
  fQuery : TDataSet;
begin
 Result:=LOG_IN_ERROR;
 if not FileExists(GetLoginDataBaseFileName) then
 begin
  result:=LOG_IN_TABLE_NOT_FOUND;
  exit;
 end;
 if fDBUserType<>UtAdmin then exit;
 fQuery := GetQuery(GetLoginDataBaseFileName);
 fQuery.Active:=false;
 SetSQL(fQuery,'Delete from '+GetLoginDataBaseName+' Where LOGO = "'+Login+'"');
 try
  ExecSQL(fQuery);
 except
  on e : Exception do
  begin
   EventLog(':TDBKernel::CreateNewUser() throw exception: '+e.Message);
   FreeDS(fQuery);
   exit;
  end;
 end;
 FreeDS(fQuery);
 result:=LOG_IN_OK;
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

 if UserName<>TEXT_MES_ADMIN then
 begin
  if not FileExists(GetLoginDataBaseFileName) then
  begin
   Result:=LOG_IN_TABLE_NOT_FOUND;
   Exit;
  end;
  fQuery:=GetQuery(GetLoginDataBaseFileName);
  try
   fQuery.Active:=false;
   SetSQL(fQuery,'Select * from '+GetLoginDataBaseName+' where LOGO="'+UserName+'"');
   fQuery.Active:=true;
  except
   on e : Exception do
   begin
    EventLog(':TDBKernel::CreateNewUser() throw exception: '+e.Message);
    result:=LOG_IN_ERROR;
    FreeDS(fQuery);
    exit;
   end;
  end;
  if fQuery.RecordCount=0 then
  begin
   result:=LOG_IN_USER_NOT_FOUND;
   FreeDS(fQuery);
   exit;
  end;
  if fquery.RecordCount>1 then
  begin
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
  fquery.First;
  self.fDBUserName:=UserName;
  if Hash_Cos_C(Password)<> HexToIntDef(Trim(fquery.FieldByName('PASSHESH').AsString),0) then
  begin
   result:=LOG_IN_PASSWORD_WRONG;
   FreeDS(fQuery);
   exit;
  end;
  self.fDBUserPassword:=Password;
 end else
 begin
  if not FileExists(GetLoginDataBaseFileName) then
  begin
   result:=LOG_IN_TABLE_NOT_FOUND;
   exit;
  end;
  fQuery:=GetQuery(GetLoginDataBaseFileName);
  try
   fQuery.Active:=false;
   SetSQL(fQuery,'Select * from '+GetLoginDataBaseName+' where LOGO="'+UserName+'"');
   fQuery.Active:=true;
  except
   on e : Exception do
   begin
    EventLog(':TDBKernel::CreateNewUser() throw exception: '+e.Message);
    result:=LOG_IN_ERROR;
    FreeDS(fQuery);
    exit;
   end;
  end;
  if fquery.RecordCount>1 then
  begin
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;   
  if fquery.RecordCount=0 then
  begin
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
  if fquery.RecordCount=1 then
  begin
   fquery.First;
   self.fDBUserName:=UserName;
   if Hash_Cos_C(Password)<> HexToIntDef(Trim(fquery.FieldByName('PASSHESH').AsString),0) then
   begin
    result:=LOG_IN_PASSWORD_WRONG;
    FreeDS(fQuery);
    exit;
   end else
   self.fDBUserPassword:=Password;
  end;
 end;
 {fDBUserAccess:=fquery.FieldByName('Access').AsString;
 if (fDBUserAccess='') or (Length(fDBUserAccess)<50) then
 begin
  if UserName<>TEXT_MES_ADMIN then
  fDBUserAccess:='0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000' else
  fDBUserAccess:='1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
 end;   }
 FreeDS(fQuery);
 if UserName=TEXT_MES_ADMIN then
 self.fDBUserType:=UtAdmin else
 self.fDBUserType:=UtUser;

 //TODO: select DB!

 DoSelectDB;

  if AutoLogin then SaveCurrentUserAsDefault else
  begin
  TryToLoadDefaultUser(s1,s2);
  if (s2=self.fDBUserPassword) and (s2=self.fDBUserName) then
  CancelUserAsDefault;                                             
  end;
{  Case self.fDBUserType of
  UtNone :
  begin
    fUserRights.Delete:=false;
    fUserRights.Add:=false;
    fUserRights.SetPrivate:=false;
    fUserRights.ChPass:=false;
    fUserRights.EditImage:=false;
    fUserRights.SetRating:=false;
    fUserRights.SetInfo:=false;
    fUserRights.ShowPrivate:=false;
    fUserRights.ShowOptions:=false;
    fUserRights.ShowAdminTools:=false;
    fUserRights.ChDbName:=false;
    fUserRights.FileOperationsCritical:=false;
    fUserRights.ManageGroups:=false;
    fUserRights.FileOperationsNormal:=false;
    fUserRights.Execute:=false;
    fUserRights.Crypt:=false;
    fUserRights.ShowPath:=false;
    fUserRights.Print:=false;
  end;
  UtUser :
  begin
    fUserRights.Delete:=fDBUserAccess[1]='1';
    fUserRights.Add:=fDBUserAccess[2]='1';
    fUserRights.SetPrivate:=fDBUserAccess[3]='1';
    fUserRights.ChPass:=fDBUserAccess[4]='1';
    fUserRights.EditImage:=fDBUserAccess[5]='1';
    fUserRights.SetRating:=fDBUserAccess[6]='1';
    fUserRights.SetInfo:=fDBUserAccess[7]='1';
    fUserRights.ShowPrivate:=fDBUserAccess[8]='1';
    fUserRights.ShowOptions:=fDBUserAccess[9]='1';
    fUserRights.ShowAdminTools:=fDBUserAccess[10]='1';
    fUserRights.ChDbName:=fDBUserAccess[11]='1';
    fUserRights.FileOperationsCritical:=fDBUserAccess[12]='1';
    fUserRights.ManageGroups:=fDBUserAccess[13]='1';
    fUserRights.FileOperationsNormal:=fDBUserAccess[14]='1';
    fUserRights.Execute:=fDBUserAccess[15]='1';
    fUserRights.Crypt:=fDBUserAccess[16]='1';
    fUserRights.ShowPath:=fDBUserAccess[17]='1';
    fUserRights.Print:=fDBUserAccess[18]='1';
  end;
  UtGuest :
  begin
    fUserRights.Delete:=fDBUserAccess[1]='1';
    fUserRights.Add:=fDBUserAccess[2]='1';
    fUserRights.SetPrivate:=fDBUserAccess[3]='1';
    fUserRights.ChPass:=fDBUserAccess[4]='1';
    fUserRights.EditImage:=fDBUserAccess[5]='1';
    fUserRights.SetRating:=fDBUserAccess[6]='1';
    fUserRights.SetInfo:=fDBUserAccess[7]='1';
    fUserRights.ShowPrivate:=fDBUserAccess[8]='1';
    fUserRights.ShowOptions:=fDBUserAccess[9]='1';
    fUserRights.ShowAdminTools:=fDBUserAccess[10]='1';
    fUserRights.ChDbName:=fDBUserAccess[11]='1';
    fUserRights.FileOperationsCritical:=fDBUserAccess[12]='1';
    fUserRights.ManageGroups:=fDBUserAccess[13]='1';
    fUserRights.FileOperationsNormal:=fDBUserAccess[14]='1';
    fUserRights.Execute:=fDBUserAccess[15]='1';
    fUserRights.Crypt:=fDBUserAccess[16]='1';
    fUserRights.ShowPath:=fDBUserAccess[17]='1';
    fUserRights.Print:=fDBUserAccess[18]='1';
  end;
  UtAdmin :
  begin
    fUserRights.Delete:=true;
    fUserRights.Add:=true;
    fUserRights.SetPrivate:=true;
    fUserRights.ChPass:=true;
    fUserRights.EditImage:=true;
    fUserRights.SetRating:=true;
    fUserRights.SetInfo:=true;
    fUserRights.ShowPrivate:=true;
    fUserRights.ShowOptions:=true;
    fUserRights.ShowAdminTools:=true;
    fUserRights.ChDbName:=true;
    fUserRights.FileOperationsCritical:=true;
    fUserRights.ManageGroups:=true;
    fUserRights.FileOperationsNormal:=true;
    fUserRights.Execute:=true;
    fUserRights.Crypt:=true;
    fUserRights.ShowPath:=true;
    fUserRights.Print:=true;
   end;
  end;   }
  LoadINIPasswords;
  result:=LOG_IN_OK;
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

procedure TDBKernel.SaveCurrentUserAsDefault;
var
  hID, rand, path_ : string;
  i : integer;
  s1, s2, s3, sid : string;
  f : file;
  buffer : Pbuffer;
  passw, usernamew : string;
  fReg : TBDRegistry;
begin
 passw:=fDBUserPassword;
 if length(passw)>255 then passw:=copy(passw,1,255);
 hID := gethardwarestring;
 for i:=1 to 255-length(passw) do
 passw:=passw+' ';
 passw:=xorstrings(passw,hID);
 sid:=setstringtolengthwithnodata(sidtostr(GetUserSID),255);
 passw:=xorstrings(passw,SID);
 path_:=AnsiLowerCase(LongFileName(Application.ExeName));
 path_:=setstringtolengthwithnodata(path_,255);
 passw:=xorstrings(passw,path_);
 rand:='';
 randomize;
 for i:=1 to 255 do
 rand:=rand+pwd_all[random(length(pwd_all)-1)+1];
 s1:=xorstrings(passw,rand);
 s2:=rand;
 s3:=inttohex(Hash_Cos_C(fDBUserPassword),8);
 fReg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 fReg.OpenKey(RegRoot,true);
 fReg.WriteString('dbbootpass',StringToHexString(s2));
 fReg.free;
 new(buffer);
 Assignfile(f,GetAppDataDirectory+'\dbboot.dat');
 {$i-}
 System.Rewrite(f, 1);
 {$i+}
 if ioresult<>0 then
 begin
  exit;
 end;
 for i:=1 to 255 do
 buffer[i]:=ord(s1[i]);
 blockwrite(f,buffer^,255);
 for i:=1 to 8 do
 buffer[i]:=ord(s3[i]);
 blockwrite(f,buffer^,8);
 usernamew:=self.fDBUserName;
 if length(usernamew)>255 then usernamew:=copy(usernamew,1,255);
 hID := gethardwarestring;
 for i:=1 to 255-length(usernamew) do
 usernamew:=usernamew+' ';
 usernamew:=xorstrings(usernamew,hID);
 sid:=setstringtolengthwithnodata(sidtostr(GetUserSID),255);
 usernamew:=xorstrings(usernamew,SID);
 path_:=AnsiLowerCase(LongFileName(Application.ExeName));
 path_:=setstringtolengthwithnodata(path_,255);
 usernamew:=xorstrings(usernamew,path_);
 rand:='';
 randomize;
 for i:=1 to 255 do
 rand:=rand+pwd_all[random(length(pwd_all)-1)+1];
 s1:=xorstrings(usernamew,rand);
 s2:=rand;
 s3:=inttohex(Hash_Cos_C(self.fDBUserName),8);
 fReg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 fReg.openkey(RegRoot,true);
 fReg.WriteString('dbbootuser',StringToHexString(s2));
 fReg.free;
 for i:=1 to 255 do
 buffer[i]:=ord(s1[i]);
 blockwrite(f,buffer^,255);
 for i:=1 to 8 do
 buffer[i]:=ord(s3[i]);
 blockwrite(f,buffer^,8);
 System.Close(f);
 freemem(buffer);
end;

procedure TDBKernel.SetDBUserHash(const Value: integer);
begin
  fDBUserHash := Value;
end;

procedure TDBKernel.SetDBUserName(const Value: string);
begin
  fDBUserName := Value;
end;

procedure TDBKernel.SetDBUserPassword(const Value: string);
begin
  fDBUserPassword := Value;
end;

procedure TDBKernel.SetDBUserType(const Value: TUserType);
begin
  fDBUserType := Value;
end;

procedure TDBKernel.SetImageList(const Value: TImageList);
begin
  FImageList.assign(Value);
end;

function TDBKernel.UpdateUserInfo(Login, OldPass, NewPass: string; Image : TJpegImage; UpdateImage : boolean):integer;
var
  fquery : TDataSet;
  _sqlexectext : string;
begin
 result:=LOG_IN_ERROR;
 If not ((self.fDBUserType=UtAdmin) or (Login=self.fDBUserName)) then exit;
// if AnsiLowerCase(Login)<>AnsiLowerCase('Administrator') then
 begin
  if not FileExists(GetLoginDataBaseFileName) and (GetDBType(GetLoginDataBaseFileName)=DB_TYPE_BDE) then
  begin
   result:=LOG_IN_TABLE_NOT_FOUND;
   exit;
  end;
  fQuery:=GetQuery(GetLoginDataBaseFileName);
  try
   fQuery.Active:=false;
   SetSQl(fQuery,'Select * from '+GetLoginDataBaseName+' where LOGO="'+Login+'"');
   fQuery.Active:=true;
  except;
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
  if fquery.RecordCount=0 then
  begin
   result:=LOG_IN_USER_NOT_FOUND;
   FreeDS(fQuery);
   exit;
  end;
  if fquery.RecordCount>1 then
  begin
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
  fquery.First;
  if (Hash_Cos_C(oldpass)<> HexToIntDef(fQuery.FieldByName('PASSHESH').AsString,0)) then
  begin
   if fquery.FieldByName('LOGO').AsString='Administrator' then
   begin
    result:=LOG_IN_PASSWORD_WRONG;
    FreeDS(fQuery);
    exit;
   end;
  end;
  try
   _sqlexectext:='Update '+GetLoginDataBaseName;
   _sqlexectext:=_sqlexectext+ ' Set PASSHESH = "'+IntToHex(Hash_Cos_C(newpass),8)+'"';
   if UpdateImage then _sqlexectext:=_sqlexectext+ ', FIMAGE = :image';
   _sqlexectext:=_sqlexectext+ ' Where LOGO = "'+login+'"';
   fQuery.active:=false;
   SetSQl(fQuery,_sqlexectext);
   if UpdateImage then AssignParam(fQuery,0,image);
   ExecSQL(fQuery);
  except
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
  FreeDS(fQuery);
  result:=LOG_IN_OK;
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

function TDBKernel.TestLoginDB: boolean;
var
  LoginDBName, fn : string;
  FTestTable : TDataSet;
  Query : TQuery;
  CheckResult : integer;
begin
  LoginDBName:=GetLoginDataBaseFileName;
  CheckResult:=FileCheckedDB.CheckFile(LoginDBName);
  if CheckResult=CHECK_RESULT_OK then
  begin
   Result:=true;
   FileCheckedDB.SaveCheckFile(LoginDBName);
   exit;
  end;
  FileCheckedDB.SaveCheckFile(LoginDBName);
  if CheckResult = CHECK_RESULT_FILE_NOE_EXISTS then
  begin
   result:=false;
   exit;
  end;
  FTestTable:= GetTable(LoginDBName,DB_TABLE_LOGIN);
  if FTestTable=nil then
  begin
   Result:=false;
   Exit;
  end;
  try
   FTestTable.Active:=true;
  except   
   on e : Exception do
   begin
    EventLog(':TDBKernel::TestLoginDB() throw exception: '+e.Message);
    Result:=false;
    FreeDS(FTestTable);
    Exit;
   end;
  end;
  try
   FTestTable.First;
   FTestTable.FieldByName('ID').AsInteger;
   FTestTable.FieldByName('FIMAGE').AsVariant;
   FTestTable.FieldByName('LOGO').AsString;
   FTestTable.FieldByName('PWD').AsString;
   FTestTable.FieldByName('DefaultDB').AsString;
   FTestTable.FieldByName('PASSHESH').AsString;
   //Added in PhotoDB v1.8
   if FTestTable.FindField('Access')=nil then
   begin
    FTestTable.Active := False;
    fn:=LoginDBName;
    fn:=GetDirectory(fn)+GetFileNameWithoutExt(fn);
    if FileExists(fn+'.db') then DeleteFile(fn+'.db');
    RenameFile(LoginDBName,fn+'.db');
    Query := TQuery.Create(nil);
    Query.SQL.Text:='ALTER TABLE "'+fn+'.db'+'" ADD Access CHAR(100) ';
    Query.ExecSQL;
    Query.Free;
    RenameFile(fn+'.db',LoginDBName);
    FTestTable.Active := True;
   end;
   FTestTable.FindField('Access').AsString;
  except
   on e : Exception do
   begin
    EventLog(':TDBKernel::TestLoginDB() throw exception: '+e.Message);
    Result:=false;
    FreeDS(FTestTable);
    Exit;
   end;
  end;
  Result:=true;
  FreeDS(FTestTable);
end;

procedure TDBKernel.TryToLoadDefaultUser(var dbusername_, dbuserPassword_ : string);
var
  f : file;
  Buffer : Pbuffer;
  Pass, username, s1, s2, s3, HardwareString, SID, Path_ : string;
  i : integer;
  fReg : TBDRegistry;
begin
 New(Buffer);
 AssignFile(f,GetAppDataDirectory+'\dbboot.dat');
 {$i-}
 System.Reset(f, 1);
 {$i+}
 if IOResult<>0 then
 begin
  DBUserName_:='';
  DBUserPassword_:='';
  FreeMem(Buffer);
  Exit;
 end;
 Seek(f,0);
 try
  BlockRead(f,buffer^,255);
 except
 end;
 s1:='';
 s3:='';
 for i:=1 to 255 do
 s1:=s1+chr(Buffer[i]);
 try
  BlockRead(f,Buffer^,8);
 except
 end;
 for i:=1 to 8 do
 s3:=s3+chr(Buffer[i]);
 fReg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 fReg.OpenKey(RegRoot,true);
 s2:=HexStringToString(fReg.ReadString('dbbootpass'));
 hardwarestring:=gethardwarestring;
 pass:='';
 for i:=1 to 255 do
 pass:=pass+' ';
 path_:=AnsiLowerCase(LongFileName(Application.ExeName));
 path_:=setstringtolengthwithnodata(path_,255);
 pass:=xorstrings(s2,s1);
 pass:=xorstrings(pass,path_);
 sid:=setstringtolengthwithnodata(sidtostr(GetUserSID),255);
 pass:=xorstrings(pass,SID);
 pass:=xorstrings(pass,hardwarestring);
 for i:=length(pass) downto 1 do
 if pass[i]=' ' then Delete(pass,i,1) else
 break;
 if Hash_Cos_C(pass)=HexToIntDef(s3,0) then
 DBUserPassword_:=pass else
 DBUserPassword_:='';
 freg.free;
 try
  BlockRead(f,Buffer^,255);
 except
 end;
 s1:='';
 s3:='';
 for i:=1 to 255 do
 s1:=s1+chr(Buffer[i]);
 try
  BlockRead(f,Buffer^,8);
 except
 end;
 System.Close(f);
 for i:=1 to 8 do
 s3:=s3+chr(Buffer[i]);
 fReg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 fReg.openkey(RegRoot,true);
 s2:=HexStringToString(fReg.ReadString('dbbootuser'));
 hardwarestring:=gethardwarestring;
 username:='';
 for i:=1 to 255 do
 username:=username+' ';
 path_:=AnsiLowerCase(LongFileName(Application.ExeName));
 path_:=setstringtolengthwithnodata(path_,255);
 username:=xorstrings(s2,s1);
 username:=xorstrings(username,path_);
 sid:=setstringtolengthwithnodata(sidtostr(GetUserSID),255);
 username:=xorstrings(username,SID);
 username:=xorstrings(username,hardwarestring);
 for i:=length(username) downto 1 do
 if username[i]=' ' then delete(username,i,1) else
 break;
 if Hash_Cos_C(username)=hextointdef(s3,0) then
 dbusername_:=username else
 dbusername_:='';
 freemem(buffer);
 fReg.free;
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

function TDBKernel.LoadUserImage(Login: String;
  var image: TJpegImage): integer;
var
  fQuery : TDataSet;
  fbs : TStream;
begin
 result:=LOG_IN_ERROR;
  if not FileExists(GetLoginDataBaseFileName) then
  begin
   Result:=LOG_IN_TABLE_NOT_FOUND;
   exit;
  end;
  fQuery:=GetQuery(GetLoginDataBaseFileName);
  try
   fQuery.Active:=false;
   SetSQL(fQuery,'Select * from '+GetLoginDataBaseName+' where LOGO="'+Login+'"');
   fQuery.Active:=true;
  except;
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
  if fQuery.RecordCount=0 then
  begin
   result:=LOG_IN_USER_NOT_FOUND;
   FreeDS(fQuery);
   exit;
  end;
  if fquery.RecordCount>1 then
  begin
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
  fquery.First;
  if image=nil then
  image:=TJPEGImage.Create;
  if TBlobField(fQuery.FieldByName('FIMAGE'))=nil then exit;
  fbs:=GetBlobStream(fQuery.FieldByName('FIMAGE'),bmRead);
  try
   if fbs.Size<>0 then
   image.loadfromStream(fbs) else
   except
  end;
  fbs.Free;
  fQuery.Close;
  FreeDS(fQuery);
  result:=LOG_IN_OK;
end;

procedure TDBKernel.LoginErrorMsg(Error: integer);
begin
  case Error of
   LOG_IN_ERROR :  MessageBoxDB(GetActiveFormHandle,TEXT_MES_ERROR_LOGON,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
   LOG_IN_USER_NOT_FOUND :  MessageBoxDB(GetActiveFormHandle,TEXT_MES_ERROR_USER_NOT_FOUND,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
   LOG_IN_TABLE_NOT_FOUND :  MessageBoxDB(GetActiveFormHandle,TEXT_MES_ERROR_TABLE_NOT_FOUND,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
   LOG_IN_USER_ALREADY_EXISTS : MessageBoxDB(GetActiveFormHandle,TEXT_MES_ERROR_USER_ALREADY_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
   LOG_IN_PASSWORD_WRONG : MessageBoxDB(GetActiveFormHandle,TEXT_MES_ERROR_PASSWORD_WRONG,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
end;

function TDBKernel.CreateLoginDB: integer;
var
  sql : string;
  f : file;
  fQuery : TDataSet;
begin
 EventLog('-> :TDBKernel.CreateLoginDB()');
 result:=LOG_IN_ERROR;
 if FileExists(GetLoginDataBaseFileName) then
 begin           
  EventLog('-> :TDBKernel.CreateLoginDB() LoginDataBaseFileName = '+GetLoginDataBaseFileName);
  EventLog('-> :TDBKernel.CreateLoginDB() -> TryRemoveConnection()');
  TryRemoveConnection(GetLoginDataBaseFileName);
  System.Assign(f,GetLoginDataBaseFileName);
  try
   System.Erase(f);
  except
   on e : Exception do
   begin
    EventLog(':TDBKernel::CreateLoginDB() throw exception: '+e.Message);
    exit;
   end;
  end;
 end;
 EventLog('-> :TDBKernel.CreateLoginDB() -> CreateMSAccessDatabase()');
 try
  CreateMSAccessDatabase(GetLoginDataBaseFileName);
 except
  on e : Exception do
  begin
   EventLog(':TDBKernel::CreateLoginDB() throw exception: '+e.Message);
   result:=LOG_IN_ERROR;
   exit;
  end;
 end;
 EventLog('-> :TDBKernel.CreateLoginDB() -> GetQuery()');
 fQuery := GetQuery(GetLoginDataBaseFileName);
 sql := 'CREATE TABLE '+GetLoginDataBaseName+' ( '+
        'ID  Autoincrement, '+
        'FIMAGE  LONGBINARY , '+
        'LOGO Character(255) , '+
        'ACCESS Character(255) , '+
        'PWD Character(255) , '+
        'DefaultDB Memo , '+
        'PASSHESH Character(255))';
 SetSQL(fQuery,sql);
 EventLog('-> :TDBKernel.CreateLoginDB() -> ExecSQL()');
 try
  ExecSQL(fQuery);
  result:=LOG_IN_ERROR;
  exit;
 except
  on e : Exception do EventLog(':TDBKernel::CreateLoginDB() throw exception: '+e.Message);
 end;
 FreeDS(fQuery);
end;

function TDBKernel.CancelUserAsDefault: integer;
var
  f : file;
  S1, S2 : string;
begin
 Result:=LOG_IN_ERROR;
 if not FileExists(GetAppDataDirectory+'\dbboot.dat') then
 begin
  result:=LOG_IN_ERROR;
  exit;
 end;
 try
  Assignfile(f,GetAppDataDirectory+'\dbboot.dat');
 try
  Erase(f);
 except
  result:=LOG_IN_TABLE_NOT_FOUND;
  exit;
 end;
 DBKernel.TryToLoadDefaultUser(s1,s2);
 if (s1='') and (s2='')
 then
  result:=LOG_IN_OK
 except
  result:=LOG_IN_ERROR;
 end;
end;

class function TDBKernel.GetLoginDataBaseFileName: string;
var
  Buf: PChar;
begin
 EventLog(':GetLoginDataBaseFileName()');
 if (IsWindowsVista or PortableWork) then
 begin
  Result:=GetAppDataDirectory;//GetDirectory(Application.ExeName);
 end else
 begin
  GetMem(Buf, MAX_PATH);
  GetWindowsDirectory(Buf, MAX_PATH);
  Result:=Buf+'\system32';
  FreeMem(Buf);
 end;  
 EventLog(':GetLoginDataBaseFileName() directory is: '+Result);

 UnFormatDir(result);
 if FileExists(result+'\dbmsftr.dll') then
 begin
  if BDEIsInstalled then
  result:=result+'\dbmsftr.dll' else
  result:=result+'\dbmsftr.ocx';
 end else
 begin
  result:=result+'\dbmsftr.ocx';
 end;
end;

function TDBKernel.GetLoginDataBaseName: string;
var
  Buf: PChar;  
begin
 if (IsWindowsVista or PortableWork) then
 begin
  Result:=GetDirectory(Application.ExeName);
 end else
 begin
  GetMem(Buf, MAX_PATH);
  GetWindowsDirectory(Buf, MAX_PATH);
  Result:=Buf+'\system32';
  FreeMem(Buf);
 end;
 UnFormatDir(Result);
 if FileExists(result+'\dbmsftr.dll') then
 begin
  if BDEIsInstalled then
  result:='"'+result+'\dbmsftr.dll"' else
  result:='Login';
 end else
 begin
  result:='Login';
 end;
end;

function TDBKernel.CheckAdmin: integer;
var
  fQuery : TDataSet;
begin
 result:=LOG_IN_ERROR;
 EventLog('-> :CheckAdmin()');
 begin
  if not FileExists(GetLoginDataBaseFileName) then
  begin
   result:=LOG_IN_TABLE_NOT_FOUND;
   exit;
  end;   
  EventLog('-> :CheckAdmin() -> GetQuery');
  fQuery:=GetQuery(GetLoginDataBaseFileName);
  try
   fQuery.Active:=false;
   SetSQL(fQuery,'Select * from '+GetLoginDataBaseName+' where LOGO="'+'Administrator'+'"');
   fQuery.Active:=true;
  except;
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;           
  EventLog('-> :CheckAdmin() -> RecordCount = ' +IntToStr(fQuery.RecordCount));
  if fQuery.RecordCount=0 then
  begin
   result:=LOG_IN_USER_NOT_FOUND;
   FreeDS(fQuery);
   exit;
  end;
  if fQuery.RecordCount>1 then
  begin
   result:=LOG_IN_ERROR;
   FreeDS(fQuery);
   exit;
  end;
 end;
 result:=LOG_IN_OK;
 FreeDS(fQuery);
 EventLog('-> :CheckAdmin() -> Result = ' +IntToStr(LOG_IN_OK));
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
 if fDBUserName='' then exit;
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
  if GetDBType=DB_TYPE_BDE then
  begin
   BackUpTableThread.Create(false);
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

function TDBKernel.GetUserAccess(Login: String; var Access : string): Integer;
var
  fQuery : TDataSet;
begin
 Access:='';
 result:=LOG_IN_ERROR;
 if not TestLoginDB then
 begin
  result:=LOG_IN_TABLE_NOT_FOUND;
  exit;
 end;
 if fDBUserType<>UtAdmin then
 begin
  result:=LOG_IN_TABLE_NOT_FOUND;
  exit;
 end;
 fQuery:=GetQuery(GetLoginDataBaseFileName);
 fQuery.Active:=false;
 SetSQL(fQuery,'Select Access from '+GetLoginDataBaseName+' Where Logo = "'+Login+'"');
 try
 fQuery.Active:=true;
 except
  result:=LOG_IN_TABLE_NOT_FOUND;
  FreeDS(fQuery);
  exit;
 end;
 if fQuery.RecordCount=0 then
 begin
  result:=LOG_IN_USER_NOT_FOUND;
  FreeDS(fQuery);
  exit;
 end;
 Access:=fQuery.FieldByName('Access').AsString;
 if (Access='') or (Length(Access)<50) then Access:='0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
 result:=LOG_IN_OK;
 FreeDS(fQuery);
end;

function TDBKernel.SetUserAccess(Login, Access: string): Integer;
var
  fQuery : TDataSet;
begin
 result:=LOG_IN_ERROR;
 if not TestLoginDB then
 begin
  result:=LOG_IN_TABLE_NOT_FOUND;
  exit;
 end;
 if fDBUserType<>UtAdmin then
 begin
  result:=LOG_IN_TABLE_NOT_FOUND;
  exit;
 end;
 fQuery:=GetQuery(GetLoginDataBaseFileName);
 fQuery.Active:=false;
 SetSQL(fQuery,'UPDATE '+GetLoginDataBaseName+' SET Access = "'+Access+'" Where Logo = "'+Login+'"');
 try
 ExecSQL(fQuery);
 except
  result:=LOG_IN_TABLE_NOT_FOUND;
  FreeDS(fQuery);
  exit;
 end;
 result:=LOG_IN_OK;
 FreeDS(fQuery);
end;

procedure TDBKernel.FixLoginDB;
var
  Connection : TADOConnection;
  LoginDB : string;
  List : TStrings;
  c : boolean;
  i, CheckResult : integer;
begin
 EventLog('-> :FixLoginDB()');
 LoginDB := GetLoginDataBaseFileName;

 CheckResult:=FileCheckedDB.CheckFile(LoginDB);
 if CheckResult=CHECK_RESULT_OK then
 begin    
  EventLog('-> :FixLoginDB().CheckFile OK');
  exit;
 end;

 if GetDBType(LoginDB)=DB_TYPE_MDB then
 begin
  List:=TStringList.Create;   
  EventLog('-> :FixLoginDB() -> ADOInitialize()');
  Connection:=ADOInitialize(LoginDB);
  try
   Connection.GetTableNames(List);
  except
   on e : Exception do EventLog(':TDBKernel::FixLoginDB() throw exception: '+e.Message);
  end;
  c:=false;
  for i:=0 to List.Count-1 do
  if List[i]='Login' then
  begin
   c:=true;
   break;
  end;       
  EventLog('-> :FixLoginDB() -> RemoveADORef()');
  RemoveADORef(Connection);
  if not c then
  begin      
   EventLog('-> :FixLoginDB() -> DBKernel.CreateLoginDB()');
   DBKernel.CreateLoginDB;
  end;
 end;  
 EventLog('-> :FixLoginDB() return');
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
 IconDllInstance:=LoadLibrary(PChar(ProgramDir+'icons.dll'));
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
  FileCheckedDB.SaveCheckFile(TDBKernel.GetLoginDataBaseFileName);
  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(dbname));
 end;
 
end.
