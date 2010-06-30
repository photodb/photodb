unit dolphin_db;

interface

uses  Language, Tlhelp32, Registry, UnitDBKernel, ShellApi, Windows,
      Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, DB, Grids, DBGrids, Menus, ExtCtrls, StdCtrls,
      ImgList, ComCtrls, DBCtrls, JPEG, DmProgress, ClipBrd, win32crc,
      SaveWindowPos, ExtDlgs, ToolWin, DbiProcs, DbiErrs, Exif, UnitDBDeclare,
      acDlgSelect, GraphicCrypt, ShlObj, ActiveX, ShellCtrls, ComObj,
      MAPI, DDraw, Math, Effects, DateUtils, psAPI, DBCommon, GraphicsCool,
      uVistaFuncs, GIFImage, GraphicEx, GraphicsBaseTypes, uLogger,
      UnitDBFileDialogs, RAWImage, UnitDBCommon, uConstants;

Const
    DBInDebug = True;
    Emulation = False;
    EmulationInstall = False;

var
    LOGGING_ENABLED : boolean = true;
    LOGGING_MESSAGE : boolean = false;

const
    WM_COPYDATA = $004A;
    FIXIDEX = true;
var
    UseFreeAfterRelease : boolean = true;
    ApplicationRuned : boolean = false;  
    StartProcessorMask : Cardinal;

const
 pwd_rusup='ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
 pwd_rusdown='ёйцукенгшщзхъфывапролджэячсмитьбю';
 pwd_englup='QWERTYUIOPASDFGHJKLZXCVBNM';
 pwd_engldown='qwertyuiopasdfghjklzxcvbnm';
 pwd_cifr='0123456789';
 pwd_spec='!#$%&()=?@<>|{[]}/\*~+#;:.-_';
 abs_engl : set of char = ['a'..'z','A'..'Z'];
 abs_rus : set of char = ['а'..'Я','а'..'Я'];
 abs_cifr : set of char = ['0'..'9'];
 abs_hex : set of char = ['a'..'e','A'..'E','0'..'9'];
 abs_englUp : set of char = ['A'..'Z'];
 abs_rusUp : set of char = ['А'..'Я'];
 abs_englDown : set of char = ['a'..'z'];
 abs_rusDown : set of char = ['а'..'я'];

  SHELL_FOLDERS_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\Explorer';
  QUICK_LAUNCH_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\GrpConv';

 cifri : set of char = ['0'..'9'];

 unusedchar : set of char = ['''','/','|','\','<','>','"','?','*',':'];
 unusedchar_folders : set of char = ['''','/','|','<','>','"','?','*',':'];
 abs_alldb=['0'..'9','а'..'я','А'..'Я','ё','Ё','a'..'z','A'..'Z','/','|','\','<','>','''','?','*',':'];

 validchars : set of char = ['a'..'z','A'..'Z','[',']','-','_','!',':',';','\','/','.',',',' ','0'..'9'];
 validcharsmdb : set of char = ['a'..'z','A'..'Z','[',']','-','_','!',':',';','\','/','.',',',' ','0'..'9',' ','а'..'я','А'..'Я'];

const db_access_private = 1;
      db_access_none = 0;
      db_attr_norm = 0;
      db_attr_not_exists = 1;
      db_attr_dublicate = 2;

const

  DB_IMAGE_ROTATED_0   = 0;
  DB_IMAGE_ROTATED_90  = 1;
  DB_IMAGE_ROTATED_180 = 2;
  DB_IMAGE_ROTATED_270 = 3;

  Result_Invalid                    = -1;
  Result_Add                        =  0;
  Result_Add_All                    =  1;
  Result_Skip                       =  2;
  Result_Skip_All                   =  3;
  Result_Replace                    =  4;
  Result_Replace_All                =  5;
  Result_Replace_And_Del_Dublicates =  6;
  Result_Delete_File                =  7;

  DemoDays = 30;
  LimitDemoRecords = 1000;


type TDBPopupMenuInfo = record
  ItemFileNames_, ItemComments_  : TArstrings;   //0
  ItemFileSizes_  : TArInteger64;                //1
  ItemRotations_ : TArInteger;                   //2
  ItemRatings_ : TArInteger;                     //3
  ItemIDs_ : TArInteger;                         //4
  Position : integer;                            //5
  ItemSelected_ : TArBoolean;                    //6
  ItemAccess_ : TArInteger;                      //7
  ItemDates_ : TArDateTime;                      //8
  ItemTimes_ : TArTime;                          //9
  IsPlusMenu : Boolean;                          //10
  PlusMenu : TArMenuitem;                        //11
  IsListItem : boolean;                          //12
  ListItem : TObject;                            //13
  IsDateGroup : Boolean;                         //14
  ItemIsDates_ : TArBoolean;                     //15
  ItemIsTimes_ : TArBoolean;                     //16
  ItemGroups_ : TArstrings;                      //17
  ItemKeyWords_ : TArstrings;                    //18
  ItemCrypted_ : TArBoolean;                     //19
  IsAttrExists : boolean;                        //20
  ItemAttr_ : TArInteger;                        //21
  ItemLoaded_ : TArBoolean;                      //22
  ItemInclude_ : TArBoolean;                     //23
  ItemLinks_ : TArstrings;  //not for common use yet
end;

 type TBuffer = array of Char;

  type
    PCopyDataStruct = ^TCopyDataStruct;
    TCopyDataStruct = record
    dwData: LongInt;
    cbData: LongInt;
    lpData: Pointer;
  end;

  PRecToPass = ^TRecToPass;
  TRecToPass = packed record
    s : string[255];
    i : integer;
  end;

type
  ShortcutType = (_DESKTOP, _QUICKLAUNCH, _SENDTO, _STARTMENU, _OTHERFOLDER, _PROGRAMS);

  THintRealFucntion = function(item: TObject): boolean of object;
  TPCharFunctionA = function(s : pchar) : PChar;
  TRemoteCloseFormProc = procedure(Form : TForm; ID : String) of object;
  TFileFoundedEvent = procedure(Owner : TObject; FileName : string; Size : int64) of object;

  TRecordsInfo = record
    ItemFileNames : TArStrings;
    ItemIds : TArInteger;
    ItemRotates : TArInteger;
    ItemRatings : TArInteger;
    ItemAccesses : TArInteger;
    ItemComments : TArStrings;
    ItemCollections : TArStrings;
    ItemGroups : TArStrings;
    ItemOwners : TArStrings;
    ItemKeyWords : TArStrings;
    ItemDates : TArDateTime;
    ItemTimes : TArTime;
    ItemIsDates : TArBoolean;
    ItemIsTimes : TArBoolean;
    ItemCrypted : TArBoolean;
    ItemInclude : TArBoolean;   
    ItemLinks : TArStrings;
    Position : Integer;
    Tag : Integer;
    LoadedImageInfo : TArBoolean;
  end;

  TOneRecordInfo = record
    ItemFileName : String;
    ItemCrypted : boolean;
    ItemId : Integer;
    ItemImTh : String;
    ItemSize : int64;
    ItemRotate : Integer;
    ItemRating : Integer;
    ItemAccess : Integer;
    ItemComment : String;
    ItemCollections : String;
    ItemGroups : String;
    ItemOwner : String;
    ItemKeyWords : String;
    ItemDate : TDateTime;
    ItemTime : TDateTime;
    ItemIsDate : Boolean;
    ItemIsTime : Boolean;
    ItemHeight : Integer;
    ItemWidth : Integer;
    ItemInclude : Boolean;
    Image : TJpegImage;
    Tag : Integer;
    PassTag : Integer;
    Loaded : boolean;
    ItemLinks : String;
  end;

  TSelectedInfo = record
     FileName : String;
     FileType : Integer;
     FileTypeW : String;
     KeyWords : String;
     CommonKeyWords : String;
     Rating : Integer;
     CommonRating : Integer;
     Comment : String;
     Groups : String;
     CommonComment : String;
     IsVariousComments : Boolean;
     IsVariousDates : Boolean;
     IsVariousTimes : Boolean;
     Size : int64;
     Date : TDateTime;
     IsDate : boolean;
     IsTime : boolean;
     Time : TDateTime;
     Access : Integer;
     Id : Integer;
     Ids : TArInteger;
     One : Boolean;
     Width : Integer;
     Height : Integer;
     Nil_ : Boolean;
     _GUID : TGUID;
     SelCount : Integer;
     Selected : TListItem;
     Links : String;
     IsVaruousInclude : Boolean;
     Include : Boolean;
   end;

  TDBaccess = set of (db_read_shared, db_read_all, db_write);

  TImageDBRecordA = record
    IDs : array of integer;
    FileNames : array of string;
    ImTh : string[210];
    count : integer;
    Attr : array of integer;
    Jpeg : TJpegImage;
    OrWidth, OrHeight : integer;
    Crypt : Boolean;
    Password : String;
    Size : Integer;
    UsedFileNameSearch : boolean;
    ChangedRotate : array of Boolean;
    IsError : boolean;                  
    ErrorText : String;
  end;

  TImageDBRecordAArray = array of TImageDBRecordA;

  TStringFunction = function : string;
  TIntegerFunction = function : integer;
  TBooleanFunction = function : Boolean;
  TPcharFunction = function : Pchar;

  TDbFileInfoA = record
   ID : Integer;
   Rotated : Integer;
   Access : integer;
   FileName : string;
   Comment : String;
  end;

  TAddFileInfo = record
    Rotate : Integer;
    Rating : integer;
    Access : Integer;
    Comment : String;
    Owner : String;
    Collection : String;
    KeyWords : String;
  end;

  TAddFileInfoArray = array of TAddFileInfo;

  type
  TDriveState =(DS_NO_DISK, DS_UNFORMATTED_DISK, DS_EMPTY_DISK,
    DS_DISK_WITH_FILES);

  TDllRegisterServer = function : HResult; stdcall;


  Const
  InstallType_Checked   = 0;
  InstallType_UnChecked = 1;
  InstallType_Grayed    = 2;

  type TInstallExt = Record
   Ext : String;
   InstallType : Integer;
  End;

  TInstallExts = array of TInstallExt;

  const
   TA_UNKNOWN           = 0;
   TA_NEEDS_TERMINATING = 1;
   TA_INFORM            = 2;
   TA_INFORM_AND_NT     = 3;

  type
    TProcTerminating = Record
     Proc : TNotifyEvent;
     Owner : TObject;
    end;

    TTemtinatedAction = record
     TerminatedPointer : PBoolean;
     TerminatedVerify : PBoolean;
     Options : Integer;
     Discription : String;
     Owner : TObject;
    end;

    TTemtinatedActions = array of TTemtinatedAction;

type TCallbackInfo = record
 Action : Byte;
 ForwardThread : boolean;
 Direction : Boolean;
end;

type TDirectXSlideShowCreatorCallBackResult = record
 Action : Byte;
 FileName : String;
 Result : Integer;
end;

type TDirectXSlideShowCreatorCallBack = function(CallbackInfo : TCallbackInfo) : TDirectXSlideShowCreatorCallBackResult of object;

type TByteArr = array[0..0] of byte;
     PByteArr = ^TByteArr;

type
  TDirectXSlideShowCreatorInfo = record
   FileName : String;
   Rotate : Integer;
   CallBack : TDirectXSlideShowCreatorCallBack;
   FDirectXSlideShowReady : PBoolean;
   FDirectXSlideShowTerminate : PBoolean;
   DirectDraw4: IDirectDraw4;
   PrimarySurface: IDirectDrawSurface4;
   Offscreen: IDirectDrawSurface4;
   Buffer : IDirectDrawSurface4;
   Clpr: IDirectDrawClipper;
   BPP, RBM, GBM, BBM : Integer;
   TransSrc1, TransSrc2, TempSrc: PByteArr;
   SID : TGUID;
   Manager : TObject;
   Form : TForm;
  end;

  type
  TUserMenuItem = record
    Caption : string;
    EXEFile : string;
    Params : string;
    Icon : string;
    UseSubMenu : Boolean;
    end;
    
  TUserMenuItemArray = array of TUserMenuItem;


 //Added in v2.0
  type
   TPlaceFolder = record
   Name : string;
   FolderName : string;
   Icon : string;
   MyComputer : boolean;
   MyDocuments : boolean;
   MyPictures : boolean;
   OtherFolder : boolean;
  end;

  TPlaceFolderArray = array of TPlaceFolder;

type
  TCorrectPathProc = procedure(Src : array of string; Dest : string) of object;

  // Added in 2.2 version

  TCallBackBigSizeProc = procedure(Sender : TObject; SizeX, SizeY : integer) of object;

  TGistogrammData = record
   Gray : T255IntArray;
   Red : T255IntArray;
   Green : T255IntArray;
   Blue : T255IntArray;
   Loaded : boolean;
   Max : byte;
   LeftEffective : byte;
   RightEffective : byte;
  end;

const CSIDL_COMMON_APPDATA = $0023; 
      CSIDL_MYMUSIC = $0013;
      CSIDL_MYPICTURES = $0014;  //FONTS
      CSIDL_LOCAL = $0022;
      CSIDL_SYSTEM = $0025;
      CSIDL_WINDOWS = $0024;
      CSIDL_PROGRAM_FILES = $0026;
      CSIDL_LOCAL_APPDATA  = $001C;

type
 // Структура с информацией об изменении в файловой системе (передается в callback процедуру)

  PInfoCallback = ^TInfoCallback;
  TInfoCallback = record
    FAction      : Integer; // тип изменения (константы FILE_ACTION_XXX)
//    FDrive       : string;  // диск, на котором было изменение
    FOldFileName : string;  // имя файла до переименования
    FNewFileName : string;  // имя файла после переименования
  end;
  TInfoCallBackDirectoryChangedArray = array of TInfoCallback;

  // callback процедура, вызываемая при изменении в файловой системе
  TWatchFileSystemCallback = procedure (pInfo: TInfoCallBackDirectoryChangedArray) of object;

  TNotifyDirectoryChangeW = Procedure(Sender : TObject; SID : string; pInfo: TInfoCallBackDirectoryChangedArray) of Object;

  //[BEGIN] Short install section oldest version
  const
  //1.75
        ProductName_1_75 = 'Photo DataBase 1.75';
        StartMenuProgramsPath_1_75 = 'Photo DB v1.75';
        ProductVersion_1_75 = '1.75';
        ProgramShortCutFile_1_75 = ProductName_1_75+'.lnk';
        HelpShortCutFile_1_75 = TEXT_MES_HELP+'.lnk';
  //1.8
        ProductName_1_8 = 'Photo DataBase 1.8';
        StartMenuProgramsPath_1_8 = 'Photo DB v1.8';
        ProductVersion_1_8 = '1.8';
        ProgramShortCutFile_1_8 = ProductName_1_8+'.lnk';
        HelpShortCutFile_1_8 = TEXT_MES_HELP+'.lnk';
  //1.9
        ProductName_1_9 = 'Photo DataBase 1.9';
        StartMenuProgramsPath_1_9 = 'Photo DB v1.9';
        ProductVersion_1_9 = '1.9';
        ProgramShortCutFile_1_9 = ProductName_1_9+'.lnk';
        HelpShortCutFile_1_9 = TEXT_MES_HELP+'.lnk';

  //2.0
        ProductName_2_0 = 'Photo DataBase 2.0';
        StartMenuProgramsPath_2_0 = 'Photo DB v2.0';
        ProductVersion_2_0 = '2.0';
        ProgramShortCutFile_2_0 = ProductName_2_0+'.lnk';
        HelpShortCutFile_2_0 = TEXT_MES_HELP+'.lnk';
                                                      
  //2.1
        ProductName_2_1 = 'Photo DataBase 2.1';
        StartMenuProgramsPath_2_1 = 'Photo DB v2.1';
        ProductVersion_2_1 = '2.1';
        ProgramShortCutFile_2_1 = ProductName_2_1+'.lnk';
        HelpShortCutFile_2_1 = TEXT_MES_HELP+'.lnk';
  //[END]


  var
        RAWImages : String = 'CR2|';
        TempRAWMask : String = '|THUMB|JPG|TIFF|PBB|';
        SupportedExt : String = '|BMP|JFIF|JPG|JPE|JPEG|RLE|DIB|WIN|VST|VDA|TGA|ICB|TIFF|TIF|FAX|EPS|PCC|PCX|RPF|RLA|SGI|RGBA|RGB|BW|PSD|PDD|PPM|PGM|PBM|CEL|PIC|PCD|GIF|CUT|PSP|PNG|THM|';


  const DBID = '{E1446065-CB87-440D-9315-6FA356F921B5}';
        DBBeginInstallID = '{A8C9FD9D-C2F6-4B1C-9164-11E6075FD527}';
        DBEndInstallID = '{C5348907-0AD6-4D02-8E0D-4063057B652F}';
        ReleaseNumber = 11;
        DemoSecondsToOpen = 5;
        MultimediaBaseFiles = '|MOV|MP3|AVI|MPEG|MPG|WAV|';
        FilesCount = 11;
        FileList : array[0..FilesCount-1] of string = ('Kernel.dll','Licence.txt','Scripts','DBShell.exe','Tools.exe','Help','lpng-px.dll','MSdcRAW.dll','icons.dll','Actions','Images');
        FileOptions : array[0..FilesCount-1] of boolean = (true,true,true,true,true,true,true,true,true,true,true);
        InstallFileNeeds : array[0..FilesCount-1] of boolean = (true,false,true,true,false,false,false,true,true,false,false);
        DBFilesExt : array [0..6] of string = ('DB','MB','FAM','VAL','TV','MDB','LDB');
        RetryTryCountOnWrite = 10;
        RetryTryDelayOnWrite = 500;
        CurrentDBSettingVersion = 1;
        UseSimpleSelectFolderDialog = false;

var
        // Image sizes
        // In FormManager this sizes loaded from DB
        DBJpegCompressionQuality : integer = 75;
        ThSize : integer = 152;
        ThSizeExplorerPreview : integer = 100;
        ThSizePropertyPreview : integer = 100;
        ThSizePanelPreview : integer = 75;
        ThImageSize : integer = 150;
        ThHintSize : integer = 300;
        ProcessorCount : Integer = 0;

resourcestring
    SNotSupported = 'This function is not supported by your version of Windows';


var 
    DBName : string;
    ProgramDir : string;
    Theme_ListSelectColor, Theme_MainColor, Theme_MainFontColor, Theme_ListColor,
    Theme_ListFontColor, Theme_MemoEditColor, Theme_MemoEditFontColor, Theme_LabelFontColor,
    Theme_ProgressBackColor, Theme_ProgressFontColor, Theme_ProgressFillColor : TColor;

    DBKernel : TDBKernel;
    ResultLogin : boolean;
    KernelHandle : THandle;
    DBTerminating : Boolean;
    HelpNO : integer = 0;
    HelpActivationNO : integer = 0;
    FExtImagesInImageList : Integer;
    LastInseredID : integer;
    ProcessMemorySize : integer;
    UseScripts : boolean = true;
    CopyFilesSynchCount : integer = 0;
    FolderView : boolean = false;
    DBLoadInitialized : boolean = false;
    fThisFileInstalled : integer = -1;
    GraphicFilterString : string;

function ActivationID : string;
function GetImageIDW(image: string; UseFileNameScanning : Boolean; OnlyImTh : boolean = false; aThImageSize : integer = 0; aDBJpegCompressionQuality : byte = 0): TImageDBRecordA;
function GetImageIDWEx(images: TArStrings; UseFileNameScanning : Boolean; OnlyImTh : boolean = false): TImageDBRecordAArray;

function GetImageIDTh(ImageTh: string): TImageDBRecordA;
procedure SetPrivate(ID: integer);
procedure UnSetPrivate(ID: integer);
procedure CopyFilesToClipboard(FileList: string);

function SizeInTextA(Size : int64) : String;
procedure UpdateDeletedDBRecord(ID : integer; FileName : string);
procedure UpdateMovedDBRecord(ID : integer; FileName : string);

procedure SetRotate(ID, Rotate: integer);
procedure SetRating(ID, Rating: integer);
procedure SetAttr(ID, Attr: integer);
function GetHardwareString: string;
function XorStrings(s1,s2:string):string;
function SetStringToLengthWithNoData(s:string;n:integer):string;
function BitmapToString(bit : tbitmap):string;
function Delnakl(s:string):string;
function GetIdByFileName(FileName : string) : integer;
function GetFileNameById(ID : integer) : string;
function saveIDsTofile(FileName : string; IDs : TArInteger) : boolean;
function LoadIDsFromfile(FileName : string) : string;
function LoadIDsFromfileA(FileName : string) : TArInteger;

function LoadImThsFromfileA(FileName : string) : TArStrings;
function SaveImThsTofile(FileName : string; ImThs : TArstrings) : boolean;

function NormalizeDBString(S:String):String;
function HardwareStringToCode(hs : string):string;
function CodeToActivateCode(s : string):string;
function GetuserString : string;
function RenameFileWithDB(OldFileName, NewFileName :string; ID : integer; OnlyBD : Boolean) : boolean;
function GetGUID : TGUID;
procedure GetFileListByMask(BeginFile, Mask : string;{ var list : tstrings; }out Info : TRecordsInfo; var n :integer; ShowPrivate : Boolean );
function AltKeyDown : boolean;
function CtrlKeyDown : boolean;
function ShiftKeyDown : boolean;
procedure JPEGScale(Graphic : TGraphic; Width, Height: Integer);

{DB Types}
function RecordInfoOne(Name : string; ID, Rotate,Rating,Access : integer; Size : int64; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; Isdate, IsTime: Boolean; Time : TTime; Crypt, Include, Loaded : Boolean; Links : string) : TOneRecordInfo;
function RecordsInfoFromArrays(Names : TArstrings; IDs, Rotates,Ratings,Accesss : TArInteger; Comments, KeyWords, Groups : TArstrings; Dates : TArDateTime; IsDates, IsTimes : TArBoolean; Times : TArTime; Crypt, Loaded, Include : TArBoolean; Links : TArStrings) : TRecordsInfo;
Function RecordInfoOneA(Name : string; ID, Rotate,Rating,Access, Size : integer; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; IsDate, IsTime: boolean; Time : TTime; Crypt : Boolean; Tag : Integer; Include : boolean; Links : string) : TOneRecordInfo;
procedure AddRecordsInfoOne(Var D : TRecordsInfo; Name : string; ID, Rotate,Rating,Access : integer; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; IsDate, IsTime : Boolean; Time : TTime; Crypt, Loaded, Include : Boolean; Links : string);
procedure SetRecordsInfoOne(Var D : TRecordsInfo; n : integer; Name : string; ID, Rotate,Rating,Access : integer; Comment, Groups : string; Date : TDateTime; IsDate, IsTime: Boolean; Time : TDateTime; Crypt, Include : Boolean; Links : string);
function RecordsInfoOne(Name : string; ID, Rotate,Rating,Access : integer; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; Isdate, IsTime: Boolean; Time : TDateTime; Crypt, Loaded, Include : Boolean; Links : string) : TRecordsInfo;
function DBPopupMenuInfoOne(Filename, Comment, Groups : string; ID,Size,Rotate,Rating,Access : integer; Date : TDateTime; IsDate, IsTime : Boolean; Time : TTime; Crypt : Boolean; KeyWords : String; Loaded, Include : Boolean; Links : string) : TDBPopupMenuInfo;
function GetRecordsFromOne(Info : TOneRecordInfo) : TRecordsInfo;
function GetRecordFromRecords(Info : TRecordsInfo; N : Integer) : TOneRecordInfo;
procedure SetRecordToRecords(Info : TRecordsInfo; N : Integer; Rec : TOneRecordInfo);
procedure CopyRecordsInfo(var S,D : TRecordsInfo);
function RecordsInfoNil : TRecordsInfo;
procedure AddToRecordsInfoOneInfo(var Infos : TRecordsInfo; Info : TOneRecordInfo);
procedure DBPopupMenuInfoToRecordsInfo(var DBP : TDBPopupMenuInfo;var RI : TRecordsInfo);
procedure AddDBPopupMenuInfoOne(var Info : TDBPopupMenuInfo; Filename, Comment, Groups : string; ID,Size,Rotate,Rating,Access : integer; Date : TDateTime; IsDate, IsTime : Boolean; Time : TDateTime; Crypted : Boolean; KeyWords : String; Loaded, Include : Boolean; Links : string);
function DBPopupMenuInfoNil : TDBPopupMenuInfo;
procedure RecordInfoOneToDBPopupMenuInfo(var RI : TOneRecordInfo; var DBP : TDBPopupMenuInfo);
function GetInfoByFileNameA(FileName : string; LoadThum : boolean) : TOneRecordInfo;
function GetMenuInfoByID(ID : Integer) : TDBPopupMenuInfo;
function GetMenuInfoByStrTh(StrTh : string) : TDBPopupMenuInfo;
{END DB Types}
function normalizeDBStringLike(S:String):String;
procedure ShowPropertiesDialog(FName: string);
function MrsGetFileType(strFilename: string): string;
Procedure CopyFiles( Handle : Hwnd; Src : array of string;
  Dest : string; Move : Boolean; AutoRename : Boolean; CallBack : TCorrectPathProc = nil; ExplorerForm : TForm = nil);
function DeleteFiles( Handle : HWnd; Names : array of string; ToRecycle : Boolean ) : Integer;
Function GetCDVolumeLabel(CDName : Char) : String;
function DriveState(driveletter: Char): TDriveState;
Procedure ShowMyComputerProperties(Hwnd : THandle);
function KillTask(ExeFileName: string): integer;
Procedure LoadNickJpegImage(Image : TImage);
function GetFileDateTime(FileName: string): TDateTime;
Procedure DoHelp;
Procedure DoGetCode(S : String);
function SilentDeleteFiles( Handle : HWnd; Names : array of string; ToRecycle : Boolean; HideErrors : boolean = false ) : Integer;

{Setup section}
Function InstalledUserName : string;
Function IsInstalledApplication : Boolean;
Function RegInstallApplication(filename, DBName, UserName : string) : boolean;
Function ExtInstallApplication(filename : string) : Boolean;
Function ExtInstallApplicationW(Exts : TInstallExts; filename : string) : Boolean;
Function ExtUnInstallApplicationW : Boolean;
Function IsNewVersion : boolean;
Function ThisFileInstalled : boolean;
Function DeleteRegistryEntries : boolean;
procedure DoBeginInstall;
procedure DoEndInstall;
Function IsInstalling : boolean;
Function InstalledDirectory : string;
Function InstalledFileName : string;
Function FileRegisteredOnInstalledApplication(Value : String) : Boolean;
procedure GetValidMDBFilesInFolder(dir : String; init : Boolean; Res: TStrings);
function GetDefaultDBName : String;

function GetDirectorySize(folder : string) : int64;

function ExtractAssociatedIcon_(FileName :String) :HICON;
function ExtractAssociatedIcon_W(FileName :String; IconIndex : Word) :HICON;

procedure DoHomeContactWithAuthor;
Procedure DoHomePage;
procedure UpdateImageRecord(FileName: String; ID : Integer);
Procedure UpdateImageRecordEx(FileName: String; ID : Integer; OnDBKernelEvent : TOnDBKernelEventProcedure);
procedure SetDesktopWallpaper(FileName : String; WOptions : Byte);

procedure RotateDBImage270(ID : integer; OldRotation : Integer);
procedure RotateDBImage90(ID : integer; OldRotation : Integer);
procedure RotateDBImage180(ID : integer; OldRotation : Integer);

Procedure DBError(ErrorValue, Error : String);
function GetSmallIconByPath(IconPath : String; Big : boolean = false) : TIcon;

procedure UnFormatDir(var s:string);
procedure FormatDir(var s:string);
function GetExt(Filename : string) : string;
function GetFileSizeByName(FileName: String): int64;
function LongFileName(ShortName: String): String;
function LongFileNameW(ShortName: String): String;
function GetUserSID: PSID;
function SidToStr(Sid : PSID):WideString;
function GetDirectory(FileName:string):string;
function ExtinMask(mask : string; ext : string):boolean;

function GetFileNameWithoutExt(filename : string) : string;
function GetFileSize(FileName: String): int64;
//function GetCPUSpeed(interval:integer):real;

function CompareImages(Image1, Image2 : TGraphic; var Rotate : Integer; fSpsearch_ScanFileRotate : boolean = true; Quick : boolean = false; Raz : integer = 60) : TImageCompareResult;
function GetIdeDiskSerialNumber : String;
procedure Delay(msecs : Longint);
function ColorDiv2(Color1, COlor2 : TColor) : TColor;
function ColorDarken(Color : TColor) : TColor;

function CreateDirA(dir : string) : boolean;
function ValidDBPath(DBPath : String) : boolean;
function CopyFilesSynch(Handle : Hwnd; Src : array of string;
  Dest : string; Move : Boolean; AutoRename : Boolean ) : Integer;
function CreateProgressBar(StatusBar:TStatusBar; index:integer):TProgressBar;
  var findleft:integer;
      i:integer;
procedure LoadDblFromfile(FileName : string; var IDs : TArInteger; var Files : TArStrings);
function SaveListTofile(FileName : string; IDs : TArInteger; Files : TArStrings) : boolean;
function IsWallpaper(FileName : String) : boolean;
procedure LoadFIlesFromClipBoard(var Effects : Integer; files : TStrings);
procedure Copy_Move(FCM:Boolean;File_List:TStrings);
function GetProgramFilesDir: string;
procedure deldir(dir : String; mask : string);
function Mince(PathToMince: String; InSpace: Integer): String;
function WindowsCopyFile(FromFile, ToDir : string) : boolean;
function WindowsCopyFileSilent(FromFile, ToDir : string) : boolean;
function CreateShortcutW(SourceFileName, ShortcutName: string;  // the file the shortcut points to
                        Location: ShortcutType; // shortcut location
                        SubFolder,  // subfolder of location
                        WorkingDir, // working directory property of the shortcut
                        Parameters,
                        Description: string): //  description property of the shortcut
                        string;
procedure HideFromTaskBar(handle : Thandle);
function RandomPwd(PWLen: integer; StrTable : string): string;
procedure Del_Close_btn(Handle : Thandle);
Procedure DoUpdateHelp;
function GetProcessMemory : integer;
function ChangeIconDialog(hOwner :tHandle; var FileName: string; var IconIndex: Integer): Boolean;
function GetProgramPath : string;
Procedure SelectDB(DB : string);
Procedure CopyFullRecordInfo(ID : integer);

function LoadActionsFromfileA(FileName : string) : TArStrings;

function SaveActionsTofile(FileName : string; Actions : TArstrings) : boolean;
procedure RenameFolderWithDB(OldFileName, NewFileName :string; ask : boolean = true);
function GetDBViewMode : boolean;
function GetDBFileName(FileName, DBName : string) : string;
//procedure CompareStrThs(Th1, Th2 : string);
function DBReadOnly : boolean;
function StringCRC(str : string) : Cardinal;
function AnsiCompareTextWithNum(Text1,Text2 : string) : integer;
function DateModify(FileName : string) : TDateTime;

function GettingProcNum: integer;  //Win95 or later and NT3.1 or later
function GetWindowsUserName: string;
Procedure GetPhotosNamesFromDrive(Dir, Mask: String; var Files : TStrings; var MaxFilesCount : integer; MaxFilesSearch : Integer; CallBack : TCallBackProgressEvent = nil);  
function EXIFDateToDate(DateTime : String) : TDateTime;
function EXIFDateToTime(DateTime : String) : TDateTime;
function RemoveBlackColor(im : TBitmap) : TBitmap;

function MessageBoxDB(Handle: THandle; AContent, Title, ADescription: string; Buttons,Icon: integer): integer; overload;
function MessageBoxDB(Handle: THandle; AContent, Title: string; Buttons, Icon: integer): integer; overload;

procedure TextToClipboard(const S : string);
function GetActiveFormHandle : integer;
function GetGraphicFilter : string;
function GetNeededRotation(OldRotation, NewRotation : integer) : Integer;
procedure ExecuteQuery(SQL : string);
function ReadTextFileInString(FileName : string) : string;
function CompareImagesByGistogramm(Image1, Image2 : TBitmap) : Byte;  
procedure ApplyRotate(Bitmap : TBitmap; RotateValue : Integer);
function CenterPos(W1, W2 : Integer) : Integer;    

var
  GetAnyValidDBFileInProgramFolderCounter : Integer;

implementation

uses ExplorerTypes, UnitPasswordForm, UnitWindowsCopyFilesThread, UnitLinksSupport,
CommonDBSupport, Activation, UnitInternetUpdate, UnitManageGroups, About,
UnitUpdateDB, Searching, ManagerDBUnit, ProgressActionUnit, UnitINI,
UnitDBCommonGraphics, UnitCDMappingSupport;

function CenterPos(W1, W2 : Integer) : Integer;
begin
  Result := W1 div 2 - W2 div 2;
end;

function GetDBFileName(FileName, DBName : string) : string;
begin
 Result:=FileName;
 if Length(FileName)>2 then
 if FileName[2]<>':' then
 Result:=GetDirectory(DBName)+FileName;
end;

function DBReadOnly : boolean;
var
  Attr : Integer;
begin
 Result:=false;
 if FileExists(GetDirectory(paramStr(0))+'FolderDB.photodb') then
 begin
  Attr:=Windows.GetFileAttributes(PChar(GetDirectory(paramStr(0))+'FolderDB.photodb'));
  if Attr and FILE_ATTRIBUTE_READONLY<>0 then Result:=true;
 end;

 if FileExists(GetDirectory(paramStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb') then
 begin
  Attr:=Windows.GetFileAttributes(PChar(GetDirectory(paramStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb'));
  if Attr and FILE_ATTRIBUTE_READONLY<>0 then Result:=true;
 end;
end;

function GetDBViewMode : boolean;
begin
 Result:=false;
 if not DBInDebug then
 if not ThisFileInstalled then
 if FileExists(GetDirectory(paramStr(0))+'FolderDB.photodb') or FileExists(GetDirectory(paramStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb') or FileExists(GetDirectory(paramStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.mdb') then
 Result:=true;
end;

function FilePathCRC(FileName : string) : Cardinal;
var
  Folder : string;
begin
  Folder := GetDirectory(FileName);
  UnFormatDir(folder);
  CalcStringCRC32(AnsiLowerCase(folder), Result);
end;

function StringCRC(str : string) : Cardinal;
begin
 Result:=0;
 CalcStringCRC32(str,Result);
end;

function GetProcessMemory : integer;
var
  pmc: PPROCESS_MEMORY_COUNTERS;
  cb: Integer;
begin
  cb := SizeOf(_PROCESS_MEMORY_COUNTERS);
  GetMem(pmc, cb);
  pmc^.cb := cb;
  if GetProcessMemoryInfo(GetCurrentProcess(), pmc, cb) then
    Result := pmc^.WorkingSetSize
  else
    Result:=0;
  FreeMem(pmc);
end;

function GetFileSize(FileName: String): int64;
var
  FS: TFileStream;
begin
 try
  {$I-}
  FS := TFileStream.Create(Filename, fmOpenRead or fmShareDenyNone);
  {$I+}
 except
  Result := -1;
  exit;
 end;
 Result := FS.Size;
 FS.Free;
end;

function GetFileSizeByName(FileName: String): int64;
var
  FindData: TWin32FindData;
  hFind: THandle;
begin
  Result := 0;
  hFind := FindFirstFile(PChar(FileName), FindData);
  if hFind <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(hFind);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := FindData.nFileSizeHigh*2*MaxInt+FindData.nFileSizeLow;
  end;
end;

Function LongFileName(ShortName: String): String;
Var
  SR: TSearchRec; 
Begin
  Result := '';
  If (pos ('\\', ShortName) + pos ('*', ShortName) +
      pos ('?', ShortName) <> 0) Or (Not FileExists(ShortName) and Not DirectoryExists(ShortName)) or (Length(ShortName)<4) Then
  Begin
    Result:=ShortName;
    Exit;
  End;
  if pos ('~1', ShortName)=0 then
  Begin
    Result:=ShortName;
    Exit;
  End;
  While FindFirst(ShortName, faAnyFile, SR) = 0 Do
  Begin
    { next part as prefix }
    Result := '\' + SR.Name + Result;
    SysUtils.FindClose(SR);  { the SysUtils, not the WinProcs procedure! }
    { directory up (cut before '\') }
    ShortName := ExtractFileDir (ShortName);
    If length (ShortName) <= 2 Then 
    Begin
      Break;  { ShortName contains drive letter followed by ':' }
    End; 
  End;
  Result := AnsiUpperCase(ExtractFileDrive (ShortName)) + Result;
end;

function LongFileNameW(ShortName: String): String;
Var
  SR: TSearchRec; 
Begin
  Result := '';
  If (pos ('\\', ShortName) + pos ('*', ShortName) +
      pos ('?', ShortName) <> 0) Or (Not FileExists(ShortName) and Not DirectoryExists(ShortName)) or (Length(ShortName)<4) Then
  Begin
    Result:=ShortName;
    Exit;
  End;
  While FindFirst(ShortName, faAnyFile, SR) = 0 Do
  Begin
    { next part as prefix }
    Result := '\' + SR.Name + Result;
    SysUtils.FindClose(SR);  { the SysUtils, not the WinProcs procedure! }
    { directory up (cut before '\') }
    ShortName := ExtractFileDir (ShortName);
    If length (ShortName) <= 2 Then 
    Begin
      Break;  { ShortName contains drive letter followed by ':' }
    End; 
  End;
  Result := AnsiUpperCase(ExtractFileDrive (ShortName)) + Result;
end;

function GetUserSID: PSID;
type
 PTOKEN_USER = ^TOKEN_USER;
 _TOKEN_USER = record
   User : TSidAndAttributes;
 end;
 TOKEN_USER = _TOKEN_USER;
var
 hToken : THandle;
 cbBuf  : Cardinal;
 ptiUser : PTOKEN_USER;
begin
 Result:=nil;
if not OpenThreadToken(GetCurrentThread(),TOKEN_QUERY,true,hToken)
  then begin
   if GetLastError()<> ERROR_NO_TOKEN then exit;
   // В случее ошибки - получаем маркер доступа нашего процесса.
   if not OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY,hToken)
    then exit;
  end;
 // Вывываем GetTokenInformation для получения размера буфера 
 if not GetTokenInformation(hToken, TokenUser, nil, 0, cbBuf)
  then if GetLastError()<> ERROR_INSUFFICIENT_BUFFER
   then begin
    CloseHandle(hToken);
    exit;
   end;
 if cbBuf = 0 then exit;
  // Выделяем память под буфер
 GetMem(ptiUser,cbBuf);
 // В случае удачного вызова получим указатель на TOKEN_USER
 if GetTokenInformation(hToken,TokenUser,ptiUser,cbBuf,cbBuf)
  then result:=ptiUser.User.Sid;
end;

function SidToStr(Sid : PSID):WideString;
var
 SIA : PSidIdentifierAuthority;
 dwCount : Cardinal;
 I : Integer;
begin
 // S-R-I-S-S...
 Result:='';
 // Проверяем SID
 if not isValidSid(Sid) then Exit;
 Result:='S-'; // Префикс
 // Получаем номер версии SID
 // Хотя работать на прямую с SID, как я уже говорил, не рекомендуется
 Result:=Result+IntToStr(Byte(Sid^))+'-';
 // Получаем орган, выдавший SID
 // Пока все находится в последнем байте
 sia:=GetSidIdentifierAuthority(Sid);
 Result:=Result+IntToStr(sia.Value[5]); //S-R-I-
 // кол-во RID
 dwCount:= GetSidSubAuthorityCount(Sid)^;
 // и теперь перебираем их
 for i:=0 to dwCount-1 do
  Result:=Result+'-'+IntToStr(GetSidSubAuthority(Sid,i)^);
end;

procedure UnFormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]='\' then Delete(s,length(s),1);
end;

procedure FormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]<>'\' then s:=s+'\';
end;

Function GetExt(Filename : string) : string;
var
  i,j:integer;
  s:string;
begin
 j:=0;
 For i:=length(filename) downto 1 do
 begin
  If filename[i]='.' then
  begin
   j:=i;
   break;
  end;
  If filename[i]='\' then break;
 end;
 s:='';
 If j<>0 then
 begin
  s:=copy(filename,j+1,length(filename)-j);
  For i:=1 to length(s) do
  s[i]:=Upcase(s[i]);
 end;
 result:=s;
end;

function GetDirectory(FileName:string):string;
var
  i, n: integer;
begin
 n:=0;
 for i:=Length(FileName) downto 1 do
 If FileName[i]='\' then
 begin
  n:=i;
  Break;
 end;
 Delete(filename,n,length(filename)-n+1);
 Result:=FileName;
 FormatDir(Result);
end;

function ExtinMask(mask : string; ext : string):boolean;
var
  i,j:integer;
begin
 result:=false;
 If mask='||' then
 begin
  result:=true;
  exit;
 end;
 for i:=1 to length(mask) do
 begin
  if mask[i]='|' then
  for j:=i to length(mask) do
  begin
   If mask[j]='|' then
   If (j-i-1>0) and (i+1<length(mask)) then
   if (AnsiUpperCase(copy(mask,i+1,j-i-1))<>'') and (AnsiUpperCase(copy(mask,i+1,j-i-1))=AnsiUpperCase(ext)) then
   begin
    result:=true;
    Break;
   end;
  end;
  If Result then Break;
 end;
end;

function GetFileNameWithoutExt(filename : string) : string;
var
  i, n : integer;
begin
 Result:='';
 If filename='' then exit;
 n:=0;
 for i:=length(filename)-1 downto 1 do
 If filename[i]='\' then
 begin
  n:=i;
  break;
 end;
 delete(filename,1,n);
 If filename<>'' then
 If filename[Length(filename)]='\' then
 Delete(filename,Length(filename),1);
 For i:=Length(filename) Downto 1 do
 begin
  if filename[i]='.' then
  begin
   FileName:=Copy(filename,1,i-1);
   Break;
  end;
 end;
 Result:=FileName;
end;

procedure GetValidMDBFilesInFolder(dir : String; init : Boolean; Res: TStrings);
var
 Found  : integer;
 SearchRec : TSearchRec;
begin
 if init then GetAnyValidDBFileInProgramFolderCounter:=0;
 FormatDir(dir);
 Found := FindFirst(dir+'*.photodb', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
  If fileexists(dir+SearchRec.Name) then
  begin
   inc(GetAnyValidDBFileInProgramFolderCounter);
   if GetAnyValidDBFileInProgramFolderCounter>1000 then break;
   if DBKernel.TestDB(dir+SearchRec.Name) then
   begin
    Res.Add(dir+SearchRec.Name)
   end;
  end else If directoryexists(dir+SearchRec.Name) then
  begin
   GetValidMDBFilesInFolder(dir+SearchRec.Name,false,Res);
  end;
   end;
    Found := sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

Function InstalledFileName : string;
var
  fReg : TBDRegistry;
begin
 Result:='';
 fReg:=TBDRegistry.Create(REGISTRY_ALL_USERS,true);
 try
  fReg.OpenKey(RegRoot,true);
  Result:=fReg.ReadString('DataBase');
  if PortableWork then
  if Result<>'' then
  Result[1]:=Application.Exename[1];
  except
 end;
 fReg.free;
end;

function InstalledUserName : string;
var
  Reg : TBDRegistry;
begin
  Reg:=TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    Reg.OpenKey(RegRoot,true);
    Result := Reg.ReadString('DBUserName');
  finally
    Reg.free;
  end;
end;

function InstalledDirectory : string;
begin
 Result := ExtractFileDir(InstalledFileName);
end;

function IsInstalling : boolean;
var
  hSemaphore : THandle;
begin
  Result:=false;
  hSemaphore := CreateSemaphore( nil, 0, 1, pchar(DBBeginInstallID) );
  if ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    Result:=true;
    hSemaphore := CreateSemaphore( nil, 0, 1, pchar(DBEndInstallID));
    if ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
    begin
      Result:=false;
    end;
    CloseHandle(hSemaphore);
  end;
  CloseHandle(hSemaphore);
end;

procedure DoBeginInstall;
begin
  CreateSemaphore( nil, 0, 1, PChar(DBBeginInstallID) );
end;

procedure DoEndInstall;
begin
  CreateSemaphore( nil, 0, 1, PChar(DBEndInstallID) );
end;

Function IsNewVersion : boolean;
var
  fReg : TBDRegistry;
  f : TIntegerFunction;
  h: Thandle; ProcH : pointer;
  FileName : string;
begin
 Result:=false;
 freg:=TBDRegistry.Create(REGISTRY_ALL_USERS,true);
  try
  fReg.OpenKey(RegRoot,true);
  FileName:=fReg.ReadString('DataBase');
  if PortableWork then
  if FileName<>'' then
  FileName[1]:=Application.Exename[1];
  If FileExists(FileName) then
  begin
   h:=LoadLibrary(Pchar(FileName));
   If h<>0 then
   begin
    ProcH:=GetProcAddress(h,'FileVersion');
    If ProcH<>nil then
    begin
     @f:=ProcH;
     If f>ReleaseNumber then
     result:=true;
    end;
    FreeLibrary(h);
   end;
  end;
  except
 end;
 fReg.free;
end;

Function ThisFileInstalled : boolean;
var
  fReg : TBDRegistry;
  FileName : String;
begin
 EventLog(':ThisFileInstalled()');
 if not DBLoadInitialized then
 begin
  InitializeDBLoadScript();
 end;

 if fThisFileInstalled>-1 then
 begin
  Result:=fThisFileInstalled = 1;
  EventLog(':ThisFileInstalled() return* '+BoolToStr(Result,true));
  exit;
 end;

 Result:=false;
 fReg:=TBDRegistry.Create(REGISTRY_ALL_USERS,true);
 try
  fReg.OpenKey(RegRoot,true); 
  FileName:=fReg.ReadString('DataBase');
  EventLog(':ThisFileInstalled() found program at "'+FileName+'"');
  if PortableWork then
  if FileName<>'' then FileName[1]:=Application.ExeName[1];
  If FileExists(FileName) then
  begin
   EventLog('This program at "'+Application.ExeName+'"');
   if AnsiLowerCase(FileName)=AnsiLowerCase(Application.ExeName) then
   Result:=true;
  end else EventLog('File at "'+FileName+'" not found!');
 except
  on e : Exception do EventLog(':ThisFileInstalled() throw exception: '+e.Message);
 end;
 fReg.free;
 if Result then
 fThisFileInstalled := 1 else fThisFileInstalled := 0;
 EventLog(':ThisFileInstalled() return '+BoolToStr(Result,true));
end;

Function IsInstalledApplication : Boolean;
var
  fReg : TBDRegistry;
  f : TBooleanFunction;
  h: Thandle;
  ProcH : pointer;   
  FileName : String;
begin
 Result:=false;
 fReg:=TBDRegistry.Create(REGISTRY_ALL_USERS,true);
 try
  fReg.OpenKey(RegRoot,true);  
  FileName:=AnsiLowerCase(freg.ReadString('DataBase'));
  if PortableWork then
  if FileName<>'' then FileName[1]:=Application.ExeName[1];
  If FileExists(FileName) then
  begin
   h:=loadlibrary(Pchar(FileName));
   If h<>0 then
   begin
    ProcH:=GetProcAddress(h,'IsFalidDBFile');
    If ProcH<>nil then
    begin
     @f:=ProcH;
     If f then
     if FileExists(GetDirectory(FileName)+'\Kernel.dll') then
     result:=true;
    end;
   FreeLibrary(h);
   end;
  end;
  except
   on e : Exception do EventLog(':IsInstalledApplication() throw exception: '+e.Message);
 end;
 fReg.free;
end;

Function DeleteRegistryEntries : boolean;
var
  freg : TRegistry;
begin
 Result:=false;
 freg:=Tregistry.Create;
 try
  freg.RootKey:=windows.HKEY_CLASSES_ROOT;
  freg.DeleteKey('\.photodb');
  freg.DeleteKey('\PhotoDB.PhotodbFile\');
  freg.DeleteKey('\.ids');
  freg.DeleteKey('\PhotoDB.IdsFile\');
  freg.DeleteKey('\.dbl');
  freg.DeleteKey('\PhotoDB.DblFile\');
  freg.DeleteKey('\.ith');
  freg.DeleteKey('\PhotoDB.IthFile\');
  freg.DeleteKey('\Directory\Shell\PhDBBrowse\');
  freg.DeleteKey('\Drive\Shell\PhDBBrowse\');
  except    
   on e : Exception do
   begin
    EventLog(':DeleteRegistryEntries() throw exception: '+e.Message);
    freg.free;
   end;
 end;
 fReg.free;
 fReg:=Tregistry.Create;
 try
  fReg.RootKey:=HKEY_INSTALL;
  fReg.DeleteKey(RegRoot);
 except
  on e : Exception do
  begin
   EventLog(':DeleteRegistryEntries()/HKEY_INSTALL throw exception: '+e.Message);
   fReg.free;
  end;
 end;
 fReg.free;
 fReg:=TRegistry.Create;
 try
  fReg.RootKey:=HKEY_USER_WORK;
  fReg.DeleteKey(RegRoot);
 except
  on e : Exception do
  begin
   EventLog(':DeleteRegistryEntries()/HKEY_USER_WORK throw exception: '+e.Message);
   fReg.free;
  end;
 end;
 fReg.free;
 fReg:=Tregistry.Create;
 try
  fReg.RootKey:=windows.HKEY_LOCAL_MACHINE;
  fReg.DeleteKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase');
  Result:=true;
 except
  on e : Exception do EventLog(':DeleteRegistryEntries() throw exception: '+e.Message);
 end;
 FReg.free;
 FReg:=TRegistry.Create;
 try
  FReg.RootKey:=Windows.HKEY_LOCAL_MACHINE;
  FReg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler');
  FReg.DeleteKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler');
  FReg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival',True);
  FReg.DeleteValue('PhotoDBgetPhotosHandler');
  Result:=true;
 except     
  on e : Exception do EventLog(':DeleteRegistryEntries() throw exception: '+e.Message);
 end;
 FReg.free;
end;

function GetDefaultDBName : String;
var
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 try
  Reg.OpenKey(RegRoot,true);
  Result:=Reg.ReadString('DBDefaultName');
 except
 end;
 Reg.free;
end;

Function RegInstallApplication(FileName, DBName, UserName : string) : boolean;
var
  freg : TBDRegistry;
begin
 Result:=false;
 freg:=TBDRegistry.Create(REGISTRY_ALL_USERS);
 try
  freg.OpenKey(RegRoot,true);
  freg.WriteString('ReleaseNumber',IntToStr(ReleaseNumber));
  freg.WriteString('DataBase',filename);
  freg.WriteString('Folder',GetDirectory(filename));
  freg.WriteString('DBDefaultName',DBName);
  freg.WriteString('DBUserName',UserName);
 except   
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   freg.free;
   exit;
  end;
 end;
 freg.free;
           
 if PortableWork then exit;

 freg:=TBDRegistry.Create(REGISTRY_ALL_USERS);
 try
  freg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase',true);
  freg.WriteString('UninstallString','"'+filename+'"'+' /uninstall');
  freg.WriteString('DisplayName','Photo DataBase');
  freg.WriteString('DisplayVersion',ProductVersion);
  freg.WriteString('HelpLink',HomeURL);
  freg.WriteString('Publisher',CopyRightString);
  freg.WriteString('URLInfoAbout','MailTo:'+ProgramMail);
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   freg.free;
   exit;
  end;
 end;
 freg.free;
            
 freg:=TBDRegistry.Create(REGISTRY_CLASSES);
 try
  freg.OpenKey('\.photodb',true);
  freg.WriteString('','PhotoDB.PhotodbFile');
  freg.CloseKey;
  freg.OpenKey('\PhotoDB.PhotodbFile',true);
  freg.OpenKey('\PhotoDB.PhotodbFile\DefaultIcon',true);
  freg.WriteString('',FileName+',0');
  Result:=true;
  freg.CloseKey;
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 freg.free;

 freg:=TBDRegistry.Create(REGISTRY_CLASSES);
 try
  freg.OpenKey('\.ids',true);
  freg.WriteString('','PhotoDB.IdsFile');
  freg.CloseKey;
  freg.OpenKey('\PhotoDB.IdsFile',true);
  freg.OpenKey('\PhotoDB.IdsFile\DefaultIcon',true);
  freg.WriteString('',FileName+',0');
  freg.OpenKey('\PhotoDB.IdsFile\Shell\Open\Command',true);
  freg.WriteString('','"'+GetDirectory(FileName)+'DBShell.exe" "%1"');
  Result:=true;
  freg.CloseKey;
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 freg.free;

 freg:=TBDRegistry.Create(REGISTRY_CLASSES);
 try
  freg.CloseKey;
  freg.OpenKey('\.dbl',true);
  freg.WriteString('','PhotoDB.dblFile');
  freg.CloseKey;
  freg.OpenKey('\PhotoDB.dblFile',true);
  freg.OpenKey('\PhotoDB.dblFile\DefaultIcon',true);
  freg.WriteString('',FileName+',0');
  freg.OpenKey('\PhotoDB.dblFile\Shell\Open\Command',true);
  freg.WriteString('','"'+GetDirectory(FileName)+'DBShell.exe" "%1"');
  Result:=true;
  freg.CloseKey;
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 freg.free;

 freg:=TBDRegistry.Create(REGISTRY_CLASSES);
 try
  freg.CloseKey;
  freg.OpenKey('\.ith',true);
  freg.writestring('','PhotoDB.IthFile');
  freg.CloseKey;
  freg.OpenKey('\PhotoDB.IthFile',true);
  freg.OpenKey('\PhotoDB.IthFile\DefaultIcon',true);
  freg.writestring('',FileName+',0');
  freg.OpenKey('\PhotoDB.IthFile\Shell\Open\Command',true);
  freg.writestring('','"'+getdirectory(FileName)+'DBShell.exe" "%1"');
  Result:=true;
  freg.CloseKey;
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;

 freg.free;
// Adding Handler for removable drives
 freg:=TBDRegistry.Create(REGISTRY_ALL_USERS);
 try
  freg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler',True);
  freg.WriteString('Action',TEXT_MES_GET_PHOTOS);
  freg.WriteString('DefaultIcon',FileName+',0');
  freg.WriteString('InvokeProgID','PhotoDB.AutoPlayHandler');
  freg.WriteString('InvokeVerb','Open');
  freg.WriteString('Provider','Photo DataBase '+ProductVersion);
  freg.CloseKey;
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 freg.free;

 freg:=TBDRegistry.Create(REGISTRY_ALL_USERS);
 try
  freg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival',True);
  freg.WriteString('PhotoDBGetPhotosHandler','');
  freg.CloseKey;
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 freg.free;

 freg:=TBDRegistry.Create(REGISTRY_ALL_USERS);
 try
  freg.OpenKey('\SOFTWARE\Classes',True);
  freg.CloseKey;
  freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler',True);
  freg.CloseKey;
  freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell',True);
  freg.CloseKey;
  freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open',True);
  freg.CloseKey;
  freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open\Command',True);
  freg.WriteString('','"'+GetDirectory(filename)+'DBShell.exe" "/GETPHOTOS" "%1"');
  freg.CloseKey;
 except
  on e : Exception do
  begin
   EventLog(':RegInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 freg.free;
end;

Function FileRegisteredOnInstalledApplication(Value : String) : Boolean;
var
  i:integer;
begin
 Result:=False;
 For i:=Length(Value) DownTo 2 do
 if (Value[i-1]='%') and (Value[i]='1') then
 begin
  Delete(Value,i-1,2);
 end;
 For i:=Length(Value) DownTo 1 do
 if Value[i]='"' then delete(Value,i,1);
 For i:=Length(Value) DownTo 1 do
 if Value[i]=' ' then delete(Value,i,1) else
 break;
 If AnsiLowerCase(Value)=AnsiLowerCase(GetDirectory(InstalledFileName)+'DBShell.exe') then
 Result:=True;
end;

Function ExtInstallApplicationW(Exts : TInstallExts; filename : string) : Boolean;
Var
  Reg : TRegistry;
  i : Integer;
  S : String;
  B,C : Boolean;

  procedure DeleteExtInfo(Ext : string);
  var
    fReg : TRegistry;
  begin
   fReg := TRegistry.Create;
   try
    fReg.RootKey:=Windows.HKEY_CURRENT_USER;
    fReg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.'+Ext);
   finally
    fReg.Free;
   end;
  end;
begin
 Result:=False;
 Reg:=TRegistry.Create;
 Reg.RootKey:=Windows.HKEY_CLASSES_ROOT;
 For i:=0 to Length(Exts)-1 do
 begin
  Case Exts[i].InstallType of
   InstallType_Checked :
    begin
     Reg.OpenKey('\.'+Exts[i].Ext,True);
     S := Reg.ReadString('');
     Reg.CloseKey;
     B := False;
     If s='' then B:=True;
     If not b then
     begin
      Reg.OpenKey('\'+S+'\Shell\Open\Command',false);
      If Reg.ReadString('')<>'' then b:=false else b:=true;
      Reg.CloseKey;
     end;
     if B then
     begin
      Reg.OpenKey('\.'+Exts[i].Ext,True);
      Reg.WriteString('','PhotoDB.'+Exts[i].Ext);
      Reg.CloseKey;
      Reg.OpenKey('\PhotoDB.'+Exts[i].Ext+'\Shell\Open\Command',True);
      Reg.WriteString('','"'+GetDirectory(FileName)+'DBShell.exe" "%1"');
      Reg.CloseKey;          
      Reg.OpenKey('\PhotoDB.'+Exts[i].Ext+'\DefaultIcon',True);
      Reg.WriteString('',''+GetDirectory(filename)+'DBShell.exe,0');
      Reg.CloseKey;
      DeleteExtInfo(Exts[i].Ext);
     end else
     begin
      Reg.OpenKey('\.'+Exts[i].Ext,True);
      S:=Reg.ReadString('');
      Reg.WriteString('PhotoDB_PreviousAssociation',S);
      Reg.WriteString('','PhotoDB.'+Exts[i].Ext);
      Reg.CloseKey;
      Reg.OpenKey('\PhotoDB.'+Exts[i].Ext+'\Shell\Open\Command',True);
      Reg.WriteString('','"'+GetDirectory(filename)+'DBShell.exe" "%1"');
      Reg.CloseKey;    
      Reg.OpenKey('\PhotoDB.'+Exts[i].Ext+'\DefaultIcon',True);
      Reg.WriteString('',''+GetDirectory(filename)+'DBShell.exe,0');  
      Reg.CloseKey;   
      DeleteExtInfo(Exts[i].Ext);
     end;
    end;
   InstallType_Grayed  :
    begin
     Reg.OpenKey('\.'+Exts[i].Ext,True);
     S := Reg.ReadString('');
     Reg.CloseKey;
     C := False;
     B := True;
     If s='' then C:=True;
     If not C then
     begin
      Reg.OpenKey('\'+S+'\Shell\Open\Command',false);
      If Reg.ReadString('')<>'' then b:=false else b:=true;
      Reg.CloseKey;
     end;
     If B then
     begin
      Reg.OpenKey('\.'+Exts[i].Ext,True);
      Reg.WriteString('','PhotoDB.'+Exts[i].Ext);
      Reg.CloseKey;
     end;
     If b then
     Reg.OpenKey('\PhotoDB.'+Exts[i].Ext+'\Shell\PhotoDBView',True) else
     Reg.OpenKey('\'+S+'\Shell\PhotoDBView',True);
     Reg.WriteString('',TEXT_MES_VIEW_WITH_DB);
     Reg.CloseKey;
     If b then
     Reg.OpenKey('\PhotoDB.'+Exts[i].Ext+'\Shell\PhotoDBView\Command',True) else
     Reg.OpenKey('\'+S+'\Shell\PhotoDBView\Command',True);
     Reg.WriteString('','"'+GetDirectory(filename)+'DBShell.exe" "%1"');
     if b then
     begin
      Reg.OpenKey('\PhotoDB.'+Exts[i].Ext+'\DefaultIcon',True);
      Reg.WriteString('',''+GetDirectory(filename)+'DBShell.exe,0');
     end;
     Reg.CloseKey;
    end;
  end;
 end;
 Reg.free;
 Result:=True;
end;

function ExtUnInstallApplicationW : Boolean;
var
  i, j : integer;
  Reg : TRegistry;
  S : String;
  PrExt : Boolean;
begin
 Result:=False;
 Reg:=TRegistry.Create;
 Reg.RootKey:=Windows.HKEY_CLASSES_ROOT;
 For i:=1 to Length(SupportedExt) do
 begin
  if SupportedExt[i]='|' then
  for j:=i to length(SupportedExt) do
  begin
   If SupportedExt[j]='|' then
   If (j-i-1>0) and (i+1<length(SupportedExt)) then
   if (AnsiLowerCase(copy(SupportedExt,i+1,j-i-1))<>'') then
   begin
    Reg.OpenKey('\.'+copy(SupportedExt,i+1,j-i-1),true);
    S:=Reg.ReadString('');
    Reg.CloseKey;
    If AnsiLowerCase(S)=AnsiLowerCase('PhotoDB.'+copy(SupportedExt,i+1,j-i-1)) then
    PrExt:=True else PrExt:=false;
    If PrExt then Reg.DeleteKey('\'+s);
    Reg.DeleteKey('\'+S+'\Shell\PhotoDBView\Command');
    Reg.DeleteKey('\'+S+'\Shell\PhotoDBView');
    Reg.OpenKey('\.'+copy(SupportedExt,i+1,j-i-1),true);
    S:=Reg.ReadString('PhotoDB_PreviousAssociation');
    Reg.CloseKey;
    If S<>'' then
    Begin
     Reg.OpenKey('\.'+copy(SupportedExt,i+1,j-i-1),true);
     Reg.DeleteValue('PhotoDB_PreviousAssociation');
     Reg.WriteString('',S);
     Reg.CloseKey;
    end else
    begin
     If PrExt then
     Reg.DeleteKey('\.'+copy(SupportedExt,i+1,j-i-1));
    end;
    Break;
   end;
  end;
 end;
 Reg.free;
 Result:=True;
end;

function ExtInstallApplication(filename : string) : Boolean;
var
  Reg : TRegistry;
begin
 Result:=true;
 Reg:=Tregistry.create;
 try
  Reg.Rootkey:=Windows.HKEY_CLASSES_ROOT;
  Reg.OpenKey('\Directory\Shell\PhDBBrowse',true);
  Reg.Writestring('',TEXT_MES_BROWSE_WITH_DB);
  Reg.CloseKey;
  Reg.OpenKey('\Directory\Shell\PhDBBrowse\Command',true);
  Reg.Writestring('','"'+GetDirectory(filename)+'DBShell.exe" "/EXPLORER" "%1"');
  Result:=true;
 except
  on e : Exception do
  begin
   EventLog(':ExtInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 Reg.free;
 Reg:=Tregistry.create;
 try
  Reg.Rootkey:=Windows.HKEY_CLASSES_ROOT;
  Reg.OpenKey('\Drive\Shell\PhDBBrowse',true);
  Reg.Writestring('',TEXT_MES_BROWSE_WITH_DB);
  Reg.CloseKey;
  Reg.OpenKey('\Drive\Shell\PhDBBrowse\Command',true);
  Reg.Writestring('','"'+GetDirectory(filename)+'DBShell.exe" "/EXPLORER" "%1"');
  Result:=true;
 except
  on e : Exception do
  begin
   EventLog(':ExtInstallApplication() throw exception: '+e.Message);
   Result:=false;
  end;
 end;
 Reg.free;
end;

Function GetInfoByFileNameA(FileName : string; LoadThum : boolean) : TOneRecordInfo;
var
  fQuery : TDataSet;
  fbs : TStream;
  i : integer;
  b : boolean;
  Folder, DBStr, s : string;
  crc : Cardinal;
begin
 fQuery:=GetQuery;
 fQuery.Active:=false;
 UnProcessPath(FileName);

  UnFormatDir(Folder);
  if FolderView then
  begin
   Folder:=GetDirectory(FileName);
   Delete(Folder,1,Length(ProgramDir));
   UnFormatDir(Folder);
   s:=FileName;
   Delete(s,1,Length(ProgramDir));
  end else
  begin
   Folder:=GetDirectory(FileName);
   UnFormatDir(Folder);
   s:=FileName;
  end;
  CalcStringCRC32(Folder,crc);
  DBStr:='(Select * from '+GetDefDBName+' where FolderCRC='+inttostr(Integer(crc))+')';
  CalcStringCRC32(AnsiLowerCase(s),crc);
  SetSQL(fQuery,'SELECT * FROM '+DBStr+' WHERE FFileName = :ffilename');

 SetStrParam(fQuery,0,AnsiLowerCase(s));
 For i:=1 to 20 do
 begin
  b:=true;
  try
   fQuery.active:=true;
  except
   if not fQuery.active then b:=false;
  end;
  if b then break;
  sleep(DelayExecuteSQLOperation);
 end;
 if not b then
 begin
  FreeDS(fQuery);
  Result:=RecordInfoOne(FileName,0,0,0,0,0,'','','','','',0,false,false,0,ValidCryptGraphicFile(ProcessPath(FileName)),true,false,'');
  Result.ItemLinks:='';
  Result.ItemImTh:='';
  Result.Image:=nil;
  Exit;
 end;
 if fQuery.RecordCount=0 then
 begin
  Result:=RecordInfoOne(FileName,0,0,0,0,0,'','','','','',0,false,false,0,ValidCryptGraphicFile(ProcessPath(FileName)),true,true,'');
  Result.ItemLinks:=fQuery.FieldByName('Links').AsString;
  Result.ItemImTh:=fQuery.FieldByName('StrTh').AsString;
  Result.Image:=nil;
 end else
 begin
  Result:=RecordInfoOne(fQuery.FieldByName('FFileName').AsString,fQuery.FieldByName('ID').AsInteger,fQuery.FieldByName('Rotated').AsInteger,fQuery.FieldByName('Rating').AsInteger, fQuery.FieldByName('Access').AsInteger, fQuery.FieldByName('FileSize').AsInteger,fQuery.FieldByName('Comment').AsString,fQuery.FieldByName('KeyWords').AsString, fQuery.FieldByName('Owner').AsString, fQuery.FieldByName('Collection').AsString, fQuery.FieldByName('Groups').AsString, fQuery.FieldByName('DateToAdd').AsDateTime, fQuery.FieldByName('IsDate').AsBoolean , fQuery.FieldByName('IsTime').AsBoolean, fQuery.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')), fQuery.FieldByName('Include').AsBoolean,true,fQuery.FieldByName('Links').AsString);
  Result.ItemHeight:=fQuery.FieldByName('Height').AsInteger;
  Result.ItemWidth:=fQuery.FieldByName('Width').AsInteger;
  Result.ItemLinks:=fQuery.FieldByName('Links').AsString;
  Result.ItemImTh:=fQuery.FieldByName('StrTh').AsString;
  Result.Tag:=EXPLORER_ITEM_IMAGE;
  If LoadThum then
  begin
   Result.Image:=TJpegImage.Create;
   if ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')) then
   begin
    try
     Result.Image:=DeCryptBlobStreamJPG(fQuery.FieldByName('thum'),DBkernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum'))) as TJpegImage;
     Result.ItemCrypted:=true;
     if Result.Image<>nil then Result.tag:=1;
    except
    end;
   end else
   begin
    if TBlobField(fQuery.FieldByName('thum'))=nil then begin FreeDS(fQuery); exit; end;
    fbs:=GetBlobStream(fQuery.FieldByName('thum'),bmRead);
    try
     if fbs.Size<>0 then
     Result.Image.loadfromStream(fbs) else
    except
    end;
    fbs.Free;
   end;
  end;
 end;
 FreeDS(fQuery);
end;

Function RecordsInfoNil : TRecordsInfo;
begin
 Result.Position:=0;
 Result.Tag:=0;
 SetLength(Result.ItemFileNames,0);
 SetLength(Result.ItemIds,0);
 SetLength(Result.ItemRotates,0);
 SetLength(Result.ItemRatings,0);
 SetLength(Result.ItemAccesses,0);
 SetLength(Result.ItemComments,0);
 SetLength(Result.ItemOwners,0);
 SetLength(Result.ItemKeyWords,0);
 SetLength(Result.ItemCollections,0);
 SetLength(Result.ItemDates,0);
 SetLength(Result.ItemIsDates,0);
 SetLength(Result.ItemIsTimes,0);
 SetLength(Result.ItemTimes,0);
 SetLength(Result.ItemGroups,0);
 SetLength(Result.ItemCrypted,0);
 SetLength(Result.LoadedImageInfo,0);
 SetLength(Result.ItemInclude,0);
 SetLength(Result.ItemLinks,0);
end;

Function RecordsInfoOne(Name : string; ID, Rotate,Rating,Access : integer; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; IsDate, IsTime: Boolean; Time : TDateTime; Crypt, Loaded, Include : Boolean; Links : string) : TRecordsInfo;
begin
 Result.Position:=0;
 Result.Tag:=0;
 SetLength(Result.ItemFileNames,1);
 SetLength(Result.ItemIds,1);
 SetLength(Result.ItemRotates,1);
 SetLength(Result.ItemRatings,1);
 SetLength(Result.ItemAccesses,1);
 SetLength(Result.ItemComments,1);
 SetLength(Result.ItemOwners,1);
 SetLength(Result.ItemKeyWords,1);
 SetLength(Result.ItemCollections,1);
 SetLength(Result.ItemDates,1);
 SetLength(Result.ItemIsDates,1);
 SetLength(Result.ItemIsTimes,1);
 SetLength(Result.ItemTimes,1);
 SetLength(Result.ItemGroups,1);
 SetLength(Result.ItemCrypted,1);
 SetLength(Result.LoadedImageInfo,1);
 SetLength(Result.ItemInclude,1);
 SetLength(Result.ItemLinks,1);
 Result.ItemFileNames[0]:=Name;
 Result.ItemIds[0]:=ID;
 Result.ItemRotates[0]:=Rotate;
 Result.ItemRatings[0]:=Rating;
 Result.ItemAccesses[0]:=Access;
 Result.ItemComments[0]:=Comment;
 Result.ItemOwners[0]:=Owner_;
 Result.ItemKeyWords[0]:=Comment;
 Result.ItemCollections[0]:=Collection;
 Result.ItemDates[0]:=Date;
 Result.ItemIsDates[0]:=IsDate;
 Result.ItemIsTimes[0]:=IsTime;
 Result.ItemTimes[0]:=Time;
 Result.ItemGroups[0]:=Groups;
 Result.ItemCrypted[0]:=Crypt;
 Result.LoadedImageInfo[0]:=Loaded;
 Result.ItemInclude[0]:=Include;
 Result.ItemLinks[0]:=Links;
end;

Procedure AddToRecordsInfoOneInfo(var Infos : TRecordsInfo; Info : TOneRecordInfo);
var
  l : integer;
begin
 l:=length(Infos.ItemFileNames)+1;
 SetLength(Infos.ItemFileNames,l);
 SetLength(Infos.ItemIds,l);
 SetLength(Infos.ItemRotates,l);
 SetLength(Infos.ItemRatings,l);
 SetLength(Infos.ItemAccesses,l);
 SetLength(Infos.ItemComments,l);
 SetLength(Infos.ItemOwners,l);
 SetLength(Infos.ItemKeyWords,l);
 SetLength(Infos.ItemCollections,l);
 SetLength(Infos.ItemDates,l);
 SetLength(Infos.ItemIsDates,l);
 SetLength(Infos.ItemIsTimes,l);
 SetLength(Infos.ItemTimes,l);
 SetLength(Infos.ItemGroups,l);
 SetLength(Infos.ItemCrypted,l);
 SetLength(Infos.ItemInclude,l);
 SetLength(Infos.ItemLinks,l);
 Infos.ItemFileNames[l-1]:=Info.ItemFileName;
 Infos.ItemIds[l-1]:=Info.ItemId;
 Infos.ItemRotates[l-1]:=Info.ItemRotate;
 Infos.ItemRatings[l-1]:=Info.ItemRating;
 Infos.ItemAccesses[l-1]:=Info.ItemAccess;
 Infos.ItemComments[l-1]:=Info.ItemComment;
 Infos.ItemOwners[l-1]:=Info.ItemOwner;
 Infos.ItemKeyWords[l-1]:=Info.ItemKeyWords;
 Infos.ItemCollections[l-1]:=Info.ItemCollections;
 Infos.ItemDates[l-1]:=Info.ItemDate;
 Infos.ItemIsDates[l-1]:=Info.ItemIsDate;
 Infos.ItemIsTimes[l-1]:=Info.ItemIsTime;
 Infos.ItemTimes[l-1]:=Info.ItemTime;
 Infos.ItemGroups[l-1]:=Info.ItemGroups;
 Infos.ItemCrypted[l-1]:=Info.ItemCrypted;
 Infos.ItemInclude[l-1]:=Info.ItemInclude;
 Infos.ItemLinks[l-1]:=Info.ItemLinks;
end;

function RecordInfoOneA(Name : string; ID, Rotate,Rating,Access, Size : integer; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; IsDate, IsTime: boolean; Time : TTime; Crypt : Boolean; Tag : Integer; Include : boolean; Links : string) : TOneRecordInfo;
begin
  Result.ItemFileName:=Name;
  Result.ItemCrypted:=false;
  Result.ItemId:=ID;
  Result.ItemSize:=Size;
  Result.ItemRotate:=Rotate;
  Result.ItemRating:=Rating;
  Result.ItemAccess:=Access;
  Result.ItemComment:=Comment;
  Result.ItemCollections:=Collection;
  Result.ItemOwner:=Owner_;
  Result.ItemKeyWords:=KeyWords;
  Result.Image := Nil;
  Result.ItemDate:=Date;
  Result.ItemTime:=Time;
  Result.ItemIsDate:=IsDate;
  Result.ItemIsTime:=IsDate;
  Result.ItemGroups:=Groups;
  Result.ItemCrypted:=Crypt;
  Result.ItemInclude:=Include;
  Result.ItemLinks:=Links;
  Result.tag:=Tag;
end;

Function GetRecordsFromOne(Info : TOneRecordInfo) : TRecordsInfo;
begin
 Result.Position:=0;
 Result.Tag:=0;
 SetLength(Result.ItemFileNames,1);
 SetLength(Result.ItemIds,1);
 SetLength(Result.ItemRotates,1);
 SetLength(Result.ItemRatings,1);
 SetLength(Result.ItemAccesses,1);
 SetLength(Result.ItemComments,1);
 SetLength(Result.ItemComments,1);
 SetLength(Result.ItemKeyWords,1);
 SetLength(Result.ItemOwners,1);
 SetLength(Result.ItemGroups,1);
 SetLength(Result.ItemDates,1);
 SetLength(Result.ItemTimes,1);
 SetLength(Result.ItemIsDates,1);
 SetLength(Result.ItemIsTimes,1);
 SetLength(Result.ItemCollections,1);
 SetLength(Result.ItemCrypted,1);
 SetLength(Result.LoadedImageInfo,1);
 SetLength(Result.ItemInclude,1);
 SetLength(Result.ItemLinks,1);
 Result.ItemFileNames[0]:=Info.ItemFileName;
 Result.ItemIds[0]:=Info.ItemId;
 Result.ItemRotates[0]:=Info.ItemRotate;
 Result.ItemRatings[0]:=Info.ItemRating;
 Result.ItemAccesses[0]:=Info.ItemAccess;
 Result.ItemComments[0]:=Info.ItemComment;
 Result.ItemKeyWords[0]:=Info.ItemKeyWords;
 Result.ItemOwners[0]:=Info.ItemOwner;
 Result.ItemCollections[0]:=Info.ItemCollections;
 Result.ItemDates[0]:=Info.ItemDate;
 Result.ItemTimes[0]:=Info.ItemTime;
 Result.ItemIsDates[0]:=Info.ItemIsDate;
 Result.ItemIsTimes[0]:=Info.ItemIsTime;
 Result.ItemGroups[0]:=Info.ItemGroups;
 Result.ItemCrypted[0]:=Info.ItemCrypted;
 Result.LoadedImageInfo[0]:=Info.Loaded;
 Result.ItemInclude[0]:=Info.ItemInclude;
 Result.ItemLinks[0]:=Info.ItemLinks;
end;

function GetRecordFromRecords(Info : TRecordsInfo; N : Integer) : TOneRecordInfo;
begin
 Result.ItemFileName:= Info.ItemFileNames[N];
 Result.ItemId:= Info.ItemIds[N];
 Result.ItemRotate:= Info.ItemRotates[N];
 Result.ItemRating:= Info.ItemRatings[N];
 Result.ItemAccess:= Info.ItemAccesses[N];
 Result.ItemComment:= Info.ItemComments[N];
 Result.ItemKeyWords:= Info.ItemKeyWords[N];
 Result.ItemOwner:= Info.ItemOwners[N];
 Result.ItemCollections:= Info.ItemCollections[N];
 Result.ItemDate:= Info.ItemDates[N];
 Result.ItemTime:= Info.ItemTimes[N];
 Result.ItemIsDate:= Info.ItemIsDates[N];
 Result.ItemIsTime:= Info.ItemIsTimes[N];
 Result.ItemGroups:= Info.ItemGroups[N];
 Result.ItemCrypted:=  Info.ItemCrypted[N];
 Result.ItemInclude:=  Info.ItemInclude[N];
 Result.Loaded:= Info.LoadedImageInfo[N];
 Result.ItemLinks:= Info.ItemLinks[N];
end;

procedure SetRecordToRecords(Info : TRecordsInfo; N : Integer; Rec : TOneRecordInfo);
begin
 Info.ItemFileNames[N]:=Rec.ItemFileName;
 Info.ItemIds[N]:=Rec.ItemId;
 Info.ItemRotates[N]:=Rec.ItemRotate;
 Info.ItemRatings[N]:=Rec.ItemRating;
 Info.ItemAccesses[N]:=Rec.ItemAccess;
 Info.ItemComments[N]:=Rec.ItemComment;
 Info.ItemKeyWords[N]:=Rec.ItemKeyWords;
 Info.ItemOwners[N]:=Rec.ItemOwner;
 Info.ItemCollections[N]:=Rec.ItemCollections;
 Info.ItemDates[N]:=Rec.ItemDate;
 Info.ItemTimes[N]:=Rec.ItemTime;
 Info.ItemIsDates[N]:=Rec.ItemIsDate;
 Info.ItemIsTimes[N]:=Rec.ItemIsTime;
 Info.ItemGroups[N]:=Rec.ItemGroups;
 Info.ItemCrypted[N]:=Rec.ItemCrypted;
 Info.ItemInclude[N]:=Rec.ItemInclude;
 Info.LoadedImageInfo[N]:=Rec.Loaded;
 Info.ItemLinks[N]:=Rec.ItemLinks;
end;

function LoadInfoFromDataSet(TDS : TDataSet) : TOneRecordInfo;
begin
 Result.ItemFileName:=TDS.FieldByName('FFileName').AsString;
 Result.ItemCrypted:=ValidCryptBlobStreamJPG(TDS.FieldByName('Thum'));
 Result.ItemId:=TDS.FieldByName('ID').AsInteger;
 Result.ItemImTh:=TDS.FieldByName('StrTh').AsString;
 Result.ItemSize:=TDS.FieldByName('FileSize').AsInteger;
 Result.ItemRotate:=TDS.FieldByName('Rotated').AsInteger;
 Result.ItemRating:=TDS.FieldByName('Rating').AsInteger;
 Result.ItemAccess:=TDS.FieldByName('Access').AsInteger;
 Result.ItemComment:=TDS.FieldByName('Comment').AsString;
 Result.ItemGroups:=TDS.FieldByName('Groups').AsString;
 Result.ItemKeyWords:=TDS.FieldByName('KeyWords').AsString;
 Result.ItemDate:=TDS.FieldByName('DateToAdd').AsDateTime;
 Result.ItemIsDate:=TDS.FieldByName('IsDate').AsBoolean;
 Result.ItemIsTime:=TDS.FieldByName('IsTime').AsBoolean;
 Result.ItemInclude:=TDS.FieldByName('Include').AsBoolean;
 Result.ItemLinks:=TDS.FieldByName('Links').AsString;
 Result.Loaded:=true;
end;

Procedure SetRecordsInfoOne(Var D : TRecordsInfo; n : integer; Name : string; ID, Rotate,Rating,Access : integer; Comment, Groups : string; Date : TDateTime; IsDate, IsTime: Boolean; Time : TDateTime; Crypt, Include : Boolean; Links : string);
begin
 D.ItemFileNames[n]:=Name;
 D.ItemIds[n]:=ID;
 D.ItemRotates[n]:=Rotate;
 D.ItemRatings[n]:=Rating;
 D.ItemAccesses[n]:=Access;
 D.ItemComments[n]:=Comment;
 D.ItemGroups[n]:=Groups;
 D.ItemDates[n]:=Date;
 D.ItemTimes[n]:=Time;
 D.ItemIsDates[n]:=IsDate;
 D.ItemIsTimes[n]:=IsTime;
 D.ItemCrypted[n]:=Crypt;
 D.ItemInclude[n]:=Include;
 D.ItemLinks[n]:=Links;
end;

procedure AddRecordsInfoOne(Var D : TRecordsInfo; Name : string; ID, Rotate,Rating,Access : integer; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; IsDate, IsTime : Boolean; Time : TTime; Crypt, Loaded, Include : Boolean; Links : string);
var
  l : integer;
begin
 l:=Length(D.ItemFileNames);
 SetLength(D.ItemFileNames,l+1);
 SetLength(D.ItemIds,l+1);
 SetLength(D.ItemRotates,l+1);
 SetLength(D.ItemRatings,l+1);
 SetLength(D.ItemAccesses,l+1);
 SetLength(D.ItemComments,l+1);
 SetLength(D.ItemOwners,l+1);
 SetLength(D.ItemCollections,l+1);
 SetLength(D.ItemKeyWords,l+1);
 SetLength(D.ItemDates,l+1);
 SetLength(D.ItemTimes,l+1);
 SetLength(D.ItemIsDates,l+1);
 SetLength(D.ItemIsTimes,l+1);
 SetLength(D.ItemGroups,l+1);
 SetLength(D.ItemCrypted,l+1);
 SetLength(D.LoadedImageInfo,l+1);
 SetLength(D.ItemInclude,l+1);
 SetLength(D.ItemLinks,l+1);
 D.ItemFileNames[l]:=Name;
 D.ItemIds[l]:=ID;
 D.ItemRotates[l]:=Rotate;
 D.ItemRatings[l]:=Rating;
 D.ItemAccesses[l]:=Access;
 D.ItemComments[l]:=Comment;
 D.ItemOwners[l]:=Owner_;
 D.ItemCollections[l]:=Collection;
 D.ItemKeyWords[l]:=KeyWords;
 D.ItemDates[l]:=Date;
 D.ItemTimes[l]:=Time;
 D.ItemIsDates[l]:=IsDate;
 D.ItemIsTimes[l]:=IsTime;
 D.ItemGroups[l]:=Groups;
 D.ItemCrypted[l]:=Crypt;
 D.LoadedImageInfo[l]:=Loaded;
 D.ItemInclude[l]:=Include;
 D.ItemLinks[l]:=Links;
end;

Procedure CopyArrayInt(var S,D : TArInteger);
var
  i : integer;
begin
 SetLength(D,Length(S));
 For i:=0 to Length(D)-1 do
 D[i]:=S[i];
end;

Procedure CopyArrayStr(var S,D : TArStrings);
var
  i : integer;
begin
 SetLength(D,Length(S));
 For i:=0 to Length(D)-1 do
 D[i]:=S[i];
end;

Procedure CopyArrayDate(var S,D : TArDateTime);
var
  i : integer;
begin
 SetLength(D,Length(S));
 For i:=0 to Length(D)-1 do
 D[i]:=S[i];
end;

Procedure CopyArrayTime(var S,D : TArTime);
var
  i : integer;
begin
 SetLength(D,Length(S));
 For i:=0 to Length(D)-1 do
 D[i]:=S[i];
end;

Procedure CopyArrayBool(var S,D : TArBoolean);
var
  i : integer;
begin
 SetLength(D,Length(S));
 For i:=0 to Length(D)-1 do
 D[i]:=S[i];
end;

Procedure CopyRecordsInfo(var S,D : TRecordsInfo);
begin
 D.Position:=S.Position;
 CopyArrayStr(S.ItemFileNames,D.ItemFileNames);
 CopyArrayInt(S.ItemIds,D.ItemIds);
 CopyArrayInt(S.ItemRatings,D.ItemRatings);
 CopyArrayInt(S.ItemRotates,D.ItemRotates);
 CopyArrayInt(S.ItemAccesses,D.ItemAccesses);
 CopyArrayStr(S.ItemComments,D.ItemComments);
 CopyArrayDate(S.ItemDates,D.ItemDates);
 CopyArrayTime(S.ItemTimes,D.ItemTimes);
 CopyArrayBool(S.ItemIsDates,D.ItemIsDates);
 CopyArrayBool(S.ItemIsTimes,D.ItemIsTimes);
 CopyArrayStr(S.ItemGroups,D.ItemGroups);
 CopyArrayBool(S.ItemInclude ,D.ItemInclude);
end;

function RecordsInfoFromArrays(Names : TArstrings; IDs, Rotates,Ratings,Accesss : TArInteger; Comments, KeyWords, Groups : TArstrings; Dates : TArDateTime; IsDates, IsTimes : TArBoolean; Times : TArTime; Crypt, Loaded, Include : TArBoolean; Links : TArStrings) : TRecordsInfo;
begin
 CopyArrayStr(Names,Result.ItemFileNames);
 CopyArrayInt(IDs,Result.ItemIds);
 CopyArrayInt(Rotates,Result.ItemRotates);
 CopyArrayInt(Ratings,Result.ItemRatings);
 CopyArrayInt(Accesss,Result.ItemAccesses);
 CopyArrayStr(Comments,Result.ItemComments);
 CopyArrayStr(KeyWords,Result.ItemKeyWords);
 CopyArrayDate(Dates,Result.ItemDates);
 CopyArrayTime(Times,Result.ItemTimes);
 CopyArrayBool(IsDates,Result.ItemIsDates);
 CopyArrayBool(IsTimes,Result.ItemIsTimes);
 CopyArrayStr(Groups,Result.ItemGroups);
 CopyArrayBool(Crypt,Result.ItemCrypted);
 CopyArrayBool(Loaded,Result.LoadedImageInfo);
 CopyArrayBool(Include,Result.ItemInclude);
 CopyArrayStr(Links,Result.ItemLinks);
end;

Procedure DBPopupMenuInfoToRecordsInfo(var DBP : TDBPopupMenuInfo; var RI : TRecordsInfo);
var
  i, FilesSelected:integer;
begin
 FilesSelected:=0;
 For i:=0 to  length(DBP.ItemFileNames_)-1 do
 if DBP.ItemSelected_[i] then
 inc(FilesSelected);
 If FilesSelected<2 then
 begin
  RI:=RecordsInfoFromArrays(DBP.ItemFileNames_,DBP.ItemIDs_,DBP.ItemRotations_,DBP.ItemRatings_, DBP.ItemAccess_,DBP.ItemComments_,DBP.ItemKeyWords_,DBP.ItemGroups_,DBP.ItemDates_,DBP.ItemIsDates_,DBP.ItemIsTimes_,DBP.ItemTimes_,DBP.ItemCrypted_,DBP.ItemLoaded_,DBP.ItemInclude_,DBP.ItemLinks_);
  if FilesSelected=1 then
  RI.Position:=DBP.Position else
  RI.Position:=0;
 end;
 If FilesSelected>1 then
 begin
  RI:=RecordsInfoNil;
  for i:=0 to Length(DBP.ItemFileNames_)-1 do
  if DBP.ItemSelected_[i] then
  begin
    AddRecordsInfoOne(RI,DBP.ItemFileNames_[i],DBP.ItemIDs_[i],DBP.ItemRotations_[i], DBP.ItemRatings_[i], DBP.ItemAccess_[i], DBP.ItemComments_[i],'','','',DBP.ItemGroups_[i],DBP.ItemDates_[i],DBP.ItemIsDates_[i],DBP.ItemIsTimes_[i],DBP.ItemDates_[i],DBP.ItemCrypted_[i],DBP.ItemLoaded_[i],DBP.ItemInclude_[i],DBP.ItemLinks_[i]);
  end;
 end;
end;

function DBPopupMenuInfoOne(Filename, Comment, Groups : string; ID,Size,Rotate,Rating,Access : integer; Date : TDateTime; IsDate, IsTime : Boolean; Time : TTime; Crypt : Boolean; KeyWords : String; Loaded, Include : Boolean; Links : string) : TDBPopupMenuInfo;
begin
 SetLength(Result.ItemFileNames_,1);
 SetLength(Result.ItemComments_,1);
 SetLength(Result.ItemFileSizes_,1);
 SetLength(Result.ItemRotations_,1);
 SetLength(Result.ItemRatings_,1);
 SetLength(Result.ItemIDs_,1);
 SetLength(Result.ItemSelected_,1);
 SetLength(Result.ItemAccess_,1);
 SetLength(Result.ItemDates_,1);
 SetLength(Result.ItemTimes_,1);
 SetLength(Result.ItemIsDates_,1);
 SetLength(Result.ItemIsTimes_,1);
 SetLength(Result.ItemGroups_,1);
 SetLength(Result.ItemCrypted_,1);
 SetLength(Result.ItemKeyWords_,1);
 SetLength(Result.ItemLoaded_,1);
 SetLength(Result.ItemAttr_,1);
 SetLength(Result.ItemInclude_,1);
 SetLength(Result.ItemLinks_,1);
 Result.ItemFileNames_[0]:=Filename;
 Result.ItemComments_[0]:=Comment;
 Result.ItemFileSizes_[0]:=Size;
 Result.ItemRotations_[0]:=Rotate;
 Result.ItemRatings_[0]:=Rating;
 Result.ItemIDs_[0]:=ID;
 Result.ItemSelected_[0]:=true;
 Result.ItemAccess_[0]:=Access;
 Result.ItemDates_[0]:=Date;
 Result.ItemTimes_[0]:=Time;
 Result.ItemIsDates_[0]:=IsDate;
 Result.ItemIsTimes_[0]:=IsDate;
 Result.ItemGroups_[0]:=Groups;
 Result.ItemCrypted_[0]:=Crypt;
 Result.ItemKeyWords_[0]:=KeyWords;
 Result.ItemLoaded_[0]:=Loaded;
 Result.ItemAttr_[0]:=0;
 Result.ItemInclude_[0]:=Include;
 Result.ItemLinks_[0]:=Links;
 Result.IsAttrExists:=false;
 Result.Position:=0;
end;

procedure AddDBPopupMenuInfoOne(var Info : TDBPopupMenuInfo; Filename, Comment, Groups : string; ID,Size,Rotate,Rating,Access : integer; Date : TDateTime; IsDate, IsTime : Boolean; Time : TDateTime; Crypted : Boolean; KeyWords : String; Loaded, Include : Boolean; Links : string);
Var
  Count : integer;
begin
 Count:=Length(Info.ItemFileNames_)+1;
 SetLength(Info.ItemFileNames_,Count);
 SetLength(Info.ItemComments_,Count);
 SetLength(Info.ItemFileSizes_,Count);
 SetLength(Info.ItemRotations_,Count);
 SetLength(Info.ItemRatings_,Count);
 SetLength(Info.ItemIDs_,Count);
 SetLength(Info.ItemSelected_,Count);
 SetLength(Info.ItemAccess_,Count);
 SetLength(Info.ItemDates_,Count);
 SetLength(Info.ItemTimes_,Count);
 SetLength(Info.ItemIsDates_,Count);
 SetLength(Info.ItemIsTimes_,Count);
 SetLength(Info.ItemGroups_,Count);
 SetLength(Info.ItemCrypted_,Count);
 SetLength(Info.ItemKeyWords_,Count);
 SetLength(Info.ItemLoaded_,Count);
 SetLength(Info.ItemAttr_,Count);
 SetLength(Info.ItemInclude_,Count);
 SetLength(Info.ItemLinks_,Count);
 Info.ItemFileNames_[Count-1]:=Filename;
 Info.ItemComments_[Count-1]:=Comment;
 Info.ItemFileSizes_[Count-1]:=Size;
 Info.ItemRotations_[Count-1]:=Rotate;
 Info.ItemRatings_[Count-1]:=Rating;
 Info.ItemIDs_[Count-1]:=ID;
 Info.ItemSelected_[Count-1]:=true;
 Info.ItemAccess_[Count-1]:=Access;
 Info.ItemDates_[Count-1]:=Date;
 Info.ItemTimes_[Count-1]:=Time;
 Info.ItemIsDates_[Count-1]:=IsDate;
 Info.ItemIsTimes_[Count-1]:=IsTime;
 Info.ItemGroups_[Count-1]:=Groups;
 Info.ItemCrypted_[Count-1]:=Crypted;
 Info.ItemKeyWords_[Count-1]:=KeyWords;
 Info.ItemLoaded_[Count-1]:=Loaded;
 Info.ItemAttr_[Count-1]:=0;
 Info.ItemInclude_[Count-1]:=Include;
 Info.ItemLinks_[Count-1]:=Links;
end;

Function DBPopupMenuInfoNil : TDBPopupMenuInfo;
begin
 SetLength(Result.ItemFileNames_,0);
 SetLength(Result.ItemComments_,0);
 SetLength(Result.ItemFileSizes_,0);
 SetLength(Result.ItemRotations_,0);
 SetLength(Result.ItemRatings_,0);
 SetLength(Result.ItemIDs_,0);
 SetLength(Result.ItemSelected_,0);
 SetLength(Result.ItemAccess_,0);
 SetLength(Result.ItemKeyWords_,0);
 SetLength(Result.ItemDates_,0);
 SetLength(Result.ItemTimes_,0);
 SetLength(Result.ItemIsDates_,0);
 SetLength(Result.ItemIsTimes_,0);
 SetLength(Result.ItemGroups_,0);
 SetLength(Result.ItemLoaded_,0);
 SetLength(Result.ItemAttr_,0);
 SetLength(Result.ItemCrypted_,0);
 SetLength(Result.ItemInclude_,0);
 SetLength(Result.ItemLinks_,0);
 Result.ListItem:=nil;
 Result.IsAttrExists:=false;
 Result.IsListItem:=False;
 Result.IsDateGroup:=False;
 Result.IsPlusMenu:=False;
 Result.Position:=0;
end;

function GetMenuInfoByID(ID : Integer) : TDBPopupMenuInfo;
var
  FQuery : TDataSet;
begin
 FQuery := GetQuery;
 SetSQL(FQuery,'SELECT * FROM '+GetDefDBname+' WHERE ID = :ID');
 SetIntParam(FQuery,0,ID);
 FQuery.Open;
 if FQuery.RecordCount<>1 then
 begin
  FreeDS(FQuery);
  Result:=DBPopupMenuInfoNil;
  exit;
 end;
 SetLength(Result.ItemFileNames_,1);
 SetLength(Result.ItemComments_,1);
 SetLength(Result.ItemFileSizes_,1);
 SetLength(Result.ItemRotations_,1);
 SetLength(Result.ItemRatings_,1);
 SetLength(Result.ItemKeyWords_,1);
 SetLength(Result.ItemIDs_,1);
 SetLength(Result.ItemSelected_,1);
 SetLength(Result.ItemAccess_,1);
 SetLength(Result.ItemDates_,1);
 SetLength(Result.ItemTimes_,1);
 SetLength(Result.ItemIsDates_,1);
 SetLength(Result.ItemIsTimes_,1);
 SetLength(Result.ItemGroups_,1);
 SetLength(Result.ItemLoaded_,1);
 SetLength(Result.ItemAttr_,1);
 SetLength(Result.ItemCrypted_,1);
 SetLength(Result.ItemInclude_,1);
 SetLength(Result.ItemLinks_,1);
 Result.ItemFileNames_[0]:=FQuery.FieldByName('FFileName').AsString;
 Result.ItemComments_[0]:=FQuery.FieldByName('Comment').AsString;
 Result.ItemFileSizes_[0]:=FQuery.FieldByName('FileSize').AsInteger;
 Result.ItemRotations_[0]:=FQuery.FieldByName('Rotated').AsInteger;
 Result.ItemRatings_[0]:=FQuery.FieldByName('Rating').AsInteger;
 Result.ItemIDs_[0]:=FQuery.FieldByName('ID').AsInteger;
 Result.ItemSelected_[0]:=true;
 Result.ItemAccess_[0]:=FQuery.FieldByName('Access').AsInteger;
 Result.ItemKeyWords_[0]:=FQuery.FieldByName('KeyWords').AsString;
 Result.ItemDates_[0]:=FQuery.FieldByName('DateToAdd').AsDateTime;
 Result.ItemIsDates_[0]:=FQuery.FieldByName('IsDate').AsBoolean;
 Result.ItemIsTimes_[0]:=FQuery.FieldByName('IsTime').AsBoolean;
 Result.ItemTimes_[0]:=FQuery.FieldByName('aTime').AsDateTime;
 Result.ItemGroups_[0]:=FQuery.FieldByName('Groups').AsString;
 Result.ItemLoaded_[0]:=true;
 Result.ItemAttr_[0]:=FQuery.FieldByName('Attr').AsInteger;
 Result.ItemCrypted_[0]:=ValidCryptBlobStreamJPG(FQuery.FieldByName('thum'));
 Result.ItemInclude_[0]:=FQuery.FieldByName('Include').AsBoolean;
 Result.ItemLinks_[0]:=FQuery.FieldByName('Links').AsString;
 Result.ListItem:=nil;
 Result.IsAttrExists:=false;
 Result.IsListItem:=False;
 Result.IsDateGroup:=False;
 Result.IsPlusMenu:=False;
 Result.Position:=0;
 FQuery.Close;
 FreeDS(FQuery);
end;

function GetMenuInfoByStrTh(StrTh : string) : TDBPopupMenuInfo;
var
  FQuery : TDataSet;
  FromDB : string;
begin
 FQuery := GetQuery;
 if GetDBType=DB_TYPE_MDB then
 FromDB:='(Select * from '+GetDefDBname+' where StrThCrc = '+IntToStr(Integer(StringCRC(StrTh)))+')';
 SetSQL(FQuery,'SELECT * FROM '+GetDefDBname+' WHERE StrTh = :StrTh');
 SetStrParam(FQuery,0,StrTh);
 FQuery.Open;
 if FQuery.RecordCount<>1 then
 begin
  FreeDS(FQuery);
  Result:=DBPopupMenuInfoNil;
  exit;
 end;
 SetLength(Result.ItemFileNames_,1);
 SetLength(Result.ItemComments_,1);
 SetLength(Result.ItemFileSizes_,1);
 SetLength(Result.ItemRotations_,1);
 SetLength(Result.ItemRatings_,1);
 SetLength(Result.ItemKeyWords_,1);
 SetLength(Result.ItemIDs_,1);
 SetLength(Result.ItemSelected_,1);
 SetLength(Result.ItemAccess_,1);
 SetLength(Result.ItemDates_,1);
 SetLength(Result.ItemTimes_,1);
 SetLength(Result.ItemIsDates_,1);
 SetLength(Result.ItemIsTimes_,1);
 SetLength(Result.ItemGroups_,1);
 SetLength(Result.ItemLoaded_,1);
 SetLength(Result.ItemAttr_,1);
 SetLength(Result.ItemCrypted_,1);
 SetLength(Result.ItemInclude_,1);
 SetLength(Result.ItemLinks_,1);
 Result.ItemFileNames_[0]:=FQuery.FieldByName('FFileName').AsString;
 Result.ItemComments_[0]:=FQuery.FieldByName('Comment').AsString;
 Result.ItemFileSizes_[0]:=FQuery.FieldByName('FileSize').AsInteger;
 Result.ItemRotations_[0]:=FQuery.FieldByName('Rotated').AsInteger;
 Result.ItemRatings_[0]:=FQuery.FieldByName('Rating').AsInteger;
 Result.ItemIDs_[0]:=FQuery.FieldByName('ID').AsInteger;
 Result.ItemSelected_[0]:=true;
 Result.ItemAccess_[0]:=FQuery.FieldByName('Access').AsInteger;
 Result.ItemKeyWords_[0]:=FQuery.FieldByName('KeyWords').AsString;
 Result.ItemDates_[0]:=FQuery.FieldByName('DateToAdd').AsDateTime;
 Result.ItemIsDates_[0]:=FQuery.FieldByName('IsDate').AsBoolean;
 Result.ItemIsTimes_[0]:=FQuery.FieldByName('IsTime').AsBoolean;
 Result.ItemTimes_[0]:=FQuery.FieldByName('aTime').AsDateTime;
 Result.ItemGroups_[0]:=FQuery.FieldByName('Groups').AsString;
 Result.ItemLoaded_[0]:=true;
 Result.ItemAttr_[0]:=FQuery.FieldByName('Attr').AsInteger;
 Result.ItemCrypted_[0]:=ValidCryptBlobStreamJPG(FQuery.FieldByName('thum'));
 Result.ItemInclude_[0]:=FQuery.FieldByName('Include').AsBoolean;
 Result.ItemLinks_[0]:=FQuery.FieldByName('Links').AsString;
 Result.ListItem:=nil;
 Result.IsAttrExists:=false;
 Result.IsListItem:=False;
 Result.IsDateGroup:=False;
 Result.IsPlusMenu:=False;
 Result.Position:=0;
 FQuery.Close;
 FreeDS(FQuery);
end;

procedure RecordInfoOneToDBPopupMenuInfo(var RI : TOneRecordInfo; var DBP : TDBPopupMenuInfo);
begin
 DBP:=DBPopupMenuInfoOne(RI.ItemFileName,RI.ItemComment,RI.ItemGroups,RI.ItemId,RI.ItemSize,RI.ItemRotate,RI.ItemRating,RI.ItemAccess,RI.ItemDate,RI.ItemIsDate,RI.ItemIsTime,RI.ItemTime,RI.ItemCrypted,RI.ItemKeyWords,RI.Loaded,RI.ItemInclude,RI.ItemLinks);
end;

function RecordInfoOne(Name : string; ID, Rotate,Rating,Access : integer; Size : int64; Comment, KeyWords, Owner_, Collection, Groups : string; Date : TDateTime; IsDate, IsTime: Boolean; Time : TTime; Crypt, Include, Loaded : Boolean; Links : string) : TOneRecordInfo;
begin
  Result.ItemFileName:=Name;
  Result.ItemCrypted:=Crypt;
  Result.ItemId:=ID;
  Result.ItemSize:=Size;
  Result.ItemRotate:=Rotate;
  Result.ItemRating:=Rating;
  Result.ItemAccess:=Access;
  Result.ItemComment:=Comment;
  Result.ItemCollections:=Collection;
  Result.ItemOwner:=Owner_;
  Result.ItemKeyWords:=KeyWords;
  Result.ItemDate:=Date;
  Result.ItemTime:=Time;
  Result.ItemIsDate:=IsDate;
  Result.ItemIsTime:=IsTime;
  Result.ItemGroups:=Groups;
  Result.ItemInclude:=Include;
  Result.ItemLinks:=Links;
  Result.Image := Nil;
  Result.PassTag:=0;
  Result.Loaded:=Loaded;
end;

procedure GetFileListByMask(BeginFile, Mask : string; out Info : TRecordsInfo; var n :integer; ShowPrivate : Boolean );
Var
 Found,i,j  : integer;
 SearchRec : TSearchRec;
 Folder, DBFolder, s, AddFolder : string;
 C : integer;
 FQuery : TDataSet;
 FBlockedFiles : TArStrings;
 List : TStrings;
 crc : Cardinal;
 FE, EM : boolean;
 p : PChar;
 PSupportedExt : PChar;   

 function IsFileBlocked(FileName : String) : Boolean;
 var
   i : Integer;
 begin
  Result:=false;
  For i:=0 to Length(FBlockedFiles)-1 do
  if AnsiLowerCase(FBlockedFiles[i])=AnsiLowerCase(FileName) then
  begin
   Result:=true;
   break;
  end;
 end;
 
begin

  If FileExists(BeginFile) then
  Folder:=GetDirectory(BeginFile);
  If DirectoryExists(BeginFile) then
  Folder:=BeginFile;
  if Folder='' then Exit;
  List:=TStringlist.Create;
  c:=0;
  n:=0;
  SetLength(FBlockedFiles,0);
  FQuery:=GetQuery(True);
  FQuery.Active:=false;
  Folder:=AnsiLowerCase(Folder);
  formatdir(Folder);
  Folder:=AnsiLowercase(Folder);
  DBFolder:=NormalizeDBStringLike(NormalizeDBString(Folder));

  if FolderView then AddFolder:=AnsiLowerCase(ProgramDir) else
  AddFolder:='';

  UnFormatDir(DBFolder);
  CalcStringCRC32(AnsiLowerCase(DBFolder),crc);

  if (GetDBType=DB_TYPE_MDB) and not FolderView then SetSQL(FQuery,'Select * From (Select * from '+GetDefDBname+' where FolderCRC='+inttostr(Integer(crc))+') where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
  if FolderView then
  begin
   SetSQL(FQuery,'Select * From '+GetDefDBname+' where FolderCRC = :crc');
   s:=DBFolder;
   Delete(s,1,Length(ProgramDir));
   UnformatDir(s);
   CalcStringCRC32(AnsiLowerCase(s),crc);
   SetIntParam(FQuery,0,Integer(crc));
  end else
  begin
   UnFormatDir(DBFolder);
   CalcStringCRC32(AnsiLowerCase(DBFolder),crc);
   FormatDir(DBFolder);
   SetStrParam(FQuery,0,'%'+DBFolder+'%');
   SetStrParam(FQuery,1,'%'+DBFolder+'%\%');
  end;

  FQuery.Active:=True;
  FQuery.First;
  SetLength(FBlockedFiles,0);
  for i:=1 to FQuery.RecordCount do
  begin
   if FQuery.FieldByName('Access').AsInteger=db_access_private then
   begin
    SetLength(FBlockedFiles,length(FBlockedFiles)+1);
    FBlockedFiles[length(FBlockedFiles)-1]:=FQuery.FieldByName('FFileName').AsString;
   end;
   FQuery.Next;
  end;
  try
   BeginFile:=AnsiLowerCase(BeginFile);
   PSupportedExt:=PChar(Mask); //!!!!
   Found := FindFirst(Folder+'*.*', faAnyFile, SearchRec);
   while Found = 0 do
    begin
    //if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
    begin
     FE:=(SearchRec.Attr and faDirectory=0);
     s:=ExtractFileExt(SearchRec.Name);
     Delete(s,1,1);
     s:='|'+AnsiUpperCase(s)+'|';
     if PSupportedExt='*.*' then EM:=true else
     begin
      p:=StrPos(PSupportedExt,PChar(s));
      EM:=p<>nil;
     end;
     If FE and EM and not IsFileBlocked(Folder+SearchRec.Name) then
     begin
      inc(c);
      If AnsiLowerCase(Folder+SearchRec.Name)=BeginFile then
      n:=c-1;
      list.Add(AnsiLowerCase(Folder+SearchRec.Name));
     end;
    end;
    Found := SysUtils.FindNext(SearchRec);
   end;
   FindClose(SearchRec);
  except
  end;
  Info:=RecordsInfoNil;
  FQuery.First;
  for i:=0 to list.Count-1 do
  begin
   AddRecordsInfoOne(Info,List[i],0,0,0,0,'','','','','',0,false,false,0,false,false,true,'');
  end;
  for i:=0 to FQuery.RecordCount-1 do
  begin
   for j:=0 to Length(Info.ItemFileNames)-1 do
   begin
    if (AddFolder+FQuery.FieldByName('FFileName').AsString)=Info.ItemFileNames[j] then
    begin
     SetRecordToRecords(info,j,LoadInfoFromDataSet(FQuery));
     break;
    end;
   end;
   FQuery.Next;
  end;
  for i:=0 to Length(Info.ItemFileNames)-1 do
  begin
   if AnsiLowerCase(Info.ItemFileNames[i])=AnsiLowerCase(BeginFile) then
   Info.position:=i;
   if not Info.LoadedImageInfo[i] then
   begin
    Info.ItemCrypted[i]:=false;//? !!! ValidCryptGraphicFile(Info.ItemFileNames[i]);
    Info.LoadedImageInfo[i]:=true;
   end;
  end;
  FQuery.Close;
  FreeDS(FQuery);
end;

function GetGUID : TGUID;
begin
  CoCreateGuid(Result);
end;

function GetDirectoresOfPath(dir : string) : TArStrings;
var
 Found  : integer;
 SearchRec : TSearchRec;
begin
  SetLength(Result,0);
  If length(dir)<4 then exit;
  If dir[length(dir)]<>'\' then dir:=dir+'\';
  Found := FindFirst(dir+'*.*', faDirectory, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   if (SearchRec.Attr and faDirectory<>0) then
   begin
    SetLength(Result,Length(Result)+1);
    Result[Length(Result)-1]:=SearchRec.Name;
   end;
   Found := sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

procedure RenameFolderWithDB(OldFileName, NewFileName :string; ask : boolean = true);
var
  ProgressWindow : TProgressActionForm;
  fQuery, SetQuery : TDataSet;        
  EventInfo : TEventValues;
  crc : Cardinal;
  i, int : integer;
  FFolder, DBFolder, NewPath, OldPath, sql, dir, s : string;
  dirs : TArStrings;
begin
 if DirectoryExists(NewFileName) or DirectoryExists(OldFileName) then
 begin
  UnFormatDir(OldFileName);
  UnFormatDir(NewFileName);

  fQuery:=GetQuery;
  FFolder:=OldFileName;

  FormatDir(FFolder);

  DBFolder:=AnsiLowerCase(FFolder);
  DBFolder:=NormalizeDBStringLike(NormalizeDBString(DBFolder));
  if FolderView then
  begin
   Delete(DBFolder,1,Length(ProgramDir));
  end;
  SetSQL(FQuery,'Select ID, FFileName From '+GetDefDBname+' where (FFileName Like :FolderA)');
  SetStrParam(FQuery,0,'%'+DBFolder+'%');

  fQuery.Active:=true;
  fQuery.First;
  if fQuery.RecordCount>0 then
  if ask or (ID_OK = MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_RENAME_FOLDER_WITH_DB_F,[OldFileName,IntToStr(fQuery.RecordCount)]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING)) then
  begin
   ProgressWindow := GetProgressWindow;
   ProgressWindow.OneOperation:=true;
   ProgressWindow.MaxPosCurrentOperation:=fQuery.RecordCount;
   SetQuery:=GetQuery;

   if fQuery.RecordCount>5 then
   begin
    ProgressWindow.Show;
    ProgressWindow.Repaint;
    ProgressWindow.DoubleBuffered:=true;
   end;
   try
    for i:=1 to fQuery.RecordCount do
    begin

     NewPath:=FQuery.FieldByName('FFileName').AsString;
     Delete(NewPath,1,Length(OldFileName));
     NewPath:=NewFileName+NewPath;
     OldPath:=FQuery.FieldByName('FFileName').AsString;

     if GetDBType=DB_TYPE_MDB then
     begin
      if not FolderView then
      begin
       CalcStringCRC32(AnsiLowerCase(NewFileName),crc);
      end else
      begin
       s:=NewFileName;
       Delete(s,1,Length(ProgramDir));
       UnFormatDir(s);
       CalcStringCRC32(AnsiLowerCase(s),crc);
       FormatDir(s);
       NewPath:=AnsiLowerCase(s+ExtractFileName(FQuery.FieldByName('FFileName').AsString));
      end;
      int:=integer(crc);                                                                                                                         
      sql:='UPDATE '+GetDefDBname+' SET FFileName="'+AnsiLowerCase(NormalizeDBString(NewPath))+'" , FolderCRC = '+IntToStr(int)+' where ID = '+inttostr(fQuery.FieldByName('ID').AsInteger);
      SetSQL(SetQuery,sql);
     end;
     ExecSQL(SetQuery);
     EventInfo.Name:=OldPath;
     EventInfo.NewName:=NewPath;
     DBKernel.DoIDEvent(Nil,0,[EventID_Param_Name],EventInfo);
     try

      if i<10 then
      begin
       ProgressWindow.xPosition:=i;
       ProgressWindow.Repaint;
      end else
      begin
       if i mod 10 = 0 then
       begin
        ProgressWindow.xPosition:=i;
        ProgressWindow.Repaint;
       end;
      end;
     except
     end;
     fQuery.Next;
    end;
   except
   end;
   FreeDS(SetQuery);
   ProgressWindow.Release;
   if UseFreeAfterRelease then ProgressWindow.Free;

  end;
  FreeDS(fQuery);
 end;
 dir:='';
 UnformatDir(OldFileName);
 UnformatDir(NewFileName);
 SetLength(dirs,0);
 if DirectoryExists(OldFileName) then
 begin
  dirs:=GetDirectoresOfPath(OldFileName);
  if Length(dirs)>0 then
  begin
   for i:=0 to Length(dirs)-1 do
   RenameFolderWithDB(OldFileName+'\'+dirs[i],NewFileName+'\'+dirs[i]);
  end;
 end;
 if DirectoryExists(NewFileName) then
 begin
  dirs:=GetDirectoresOfPath(NewFileName);
  if Length(dirs)>0 then
  begin
   for i:=0 to Length(dirs)-1 do
   RenameFolderWithDB(OldFileName+'\'+dirs[i],NewFileName+'\'+dirs[i]);
  end;
 end;
end;

function RenameFileWithDB(OldFileName, NewFileName :string; ID : integer; OnlyBD : Boolean) : boolean;
var
  fQuery : TDataSet;
  EventInfo : TEventValues;
  acrc, folder : string;
  crc : Cardinal;
begin
 Result:=true;
 if not OnlyBD then
 If FileExists(OldFileName) or DirectoryExists(OldFileName) then
 begin
  try
   Result:=RenameFile(OldFileName,NewFileName);
   if not Result then exit;
  except
   Result:=false;
   exit;
  end;
 end;

 If ID<>0 then
 begin
  fQuery:=GetQuery;
  try
   if GetDBType=DB_TYPE_MDB then
   begin
    acrc:=' ,FolderCRC = :FolderCRC';

    UnProcessPath(NewFileName);
    if not FolderView then
    begin
     folder:=GetDirectory(NewFileName);
     folder:=AnsiLowerCase(folder);
     UnFormatDir(folder);
     CalcStringCRC32(folder,crc);
    end else
    begin
     folder:=GetDirectory(NewFileName);
     Delete(folder,1,Length(ProgramDir));
     UnformatDir(folder);
     CalcStringCRC32(AnsiLowerCase(folder),crc);
     FormatDir(folder);

     Delete(NewFileName,1,Length(ProgramDir));

    end;


   end else
   begin
    acrc:='';
   end;
   fQuery.Active:=false;
   SetSQL(fQuery,'UPDATE '+GetDefDBname+' SET FFileName="'+AnsiLowerCase(NewFileName)+'", Name="'+ExtractFileName(NewFileName)+'" '+acrc+' WHERE (ID='+inttostr(ID)+')');
   if GetDBType=DB_TYPE_MDB then
   SetIntParam(fQuery,0,Integer(crc));
   ExecSQL(fQuery);
   except
  end;
  FreeDS(fQuery);
 end;
 RenameFolderWithDB(OldFileName,NewFileName);

 if OnlyBD then
 begin
  DBKernel.DoIDEvent(Nil,ID,[EventID_Param_Name],EventInfo);
  exit;
 end;

 EventInfo.Name:=OldFileName;
 EventInfo.NewName:=NewFileName;
 DBKernel.DoIDEvent(Nil,ID,[EventID_Param_Name],EventInfo);
end;

function ActivationID : string;
var
  f : TPCharFunction;
  Fh : pointer;
  Activation : PChar;
begin
  Fh:=GetProcAddress(KernelHandle,'GetCIDA');
  if fh=nil then
  begin
    Showmessage(TEXT_MES_ERROR_KERNEL_DLL);
    halt;
    exit;
  end;
  @f := Fh;
  Activation := f();
  result := Copy(Activation, 1, Length(Activation));
end;

function NormalizeDBString(S : String) : String;
begin
  Result := AnsiQuotedStr(S, '"')
end;

function normalizeDBStringLike(S:String):String;
var
  i : integer;
begin
 for i:=1 to Length(s) do
 if (s[i]='[') or (s[i]=']') then s[i]:='_';
 result:=s;
end;

function GetIdByFileName(FileName : string) : integer;
var
  fQuery : TDataSet;
begin
  fQuery:=GetQuery;
  fQuery.Active:=false;
  SetSQL(fQuery,'SELECT * FROM ' + GetDefDBName + ' WHERE FolderCRC = '+IntToStr(GetPathCRC(FileName))+' AND FFileName LIKE :FFileName');
  if FolderView then
  Delete(FileName,1,Length(ProgramDir));
  SetStrParam(fQuery,0,Delnakl(NormalizeDBStringLike(AnsiLowerCase(FileName))));
  try
   fQuery.active:=true;
  except
   result:=0;
   FreeDS(fQuery);
   exit;
  end;
  if fQuery.RecordCount=0 then
  result:=0 else
  Result:=fQuery.fieldByName('ID').AsInteger;
  FreeDS(fQuery);
end;

function GetFileNameById(ID : integer) : string;
var
  fQuery : TDataSet;
begin
  fQuery:=GetQuery;
  fQuery.Active:=false;
  SetSQL(fQuery,'SELECT FFileName FROM '+GetDefDBname+' WHERE ID = :ID');
  SetIntParam(fQuery,0,ID);
  try
   fQuery.active:=true;
  except
   result:='';
   FreeDS(fQuery);
   Exit;
  end;
  if fQuery.RecordCount=0 then
  result:='' else
  Result:=fQuery.fieldByName('FFileName').AsString;
  FreeDS(fQuery);
end;

function Delnakl(s:string):string;
var
  j : integer;
begin
 result:=s;
 for j:=1 to length(result) do
 if result[j]='\' then result[j]:='_';
end;

function BitmapToString(bit : tbitmap):string;
var
  i, j : integer;
  rr1, bb1, gg1 : byte;
  b1, b2 : byte;
  b : tbitmap;
  p : PARGB;
begin
 Result:='';
 b:=tbitmap.create;
 b.PixelFormat:=pf24bit;
 QuickReduceWide(10,10,bit,b);
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
 for i:=0 to 9 do
 begin
  p:=b.ScanLine[i];
  for j:=0 to 9 do
  begin
   rr1:=p[j].r div 8;
   gg1:=p[j].g div 8;
   bb1:=p[j].b div 8;
   b1:=rr1 shl 3;
   b1:=b1+gg1 shr 2;
   b2:=gg1 shl 6;
   b2:=b2+bb1 shl 1;
   if (b1=0) and (b2<>0) then begin b2:=b2+1; b1:=b1 or 135; end;
   if (b1<>0) and (b2=0) then begin b2:=b2+1; b2:=b2 or 225; end;
   if (b1=0) and (b2=0) then begin b1:=255; b2:=255; end;
   if FIXIDEX then if (i=9) and (j=9) and (b2=32) then b2:=255;
   result:=result+chr(b1)+chr(b2);
  end;
 end;
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
 b.Free;
end;

function PixelsToText(Pixels : integer): String;
begin
 If not DBkernel.ProgramInDemoMode then
 begin
  if CharToInt(DBkernel.GetCodeChar(8))<> (CharToInt(DBkernel.GetCodeChar(4))+ CharToInt(DBkernel.GetCodeChar(6)))*17 mod 15 then
  begin
   Result:='Fuck you!';
   exit;
  end;
 end;
 Result:=Format(TEXT_MES_PIXEL_FORMAT,[IntToStr(Pixels)]);
end;

procedure SetRotate(ID, Rotate: integer);
begin
  ExecuteQuery(Format('Update %s Set Rotated=%d Where ID=%d', [GetDefDBname, Rotate, ID]));
end;

procedure SetAttr(ID, Attr: integer);
begin
  ExecuteQuery(Format('Update %s Set Attr=%d Where ID=%d', [GetDefDBname, Attr, ID]));
end;

procedure SetRating(ID, Rating: integer);
begin
  ExecuteQuery(Format('Update %s Set Rating=%d Where ID=%d', [GetDefDBname, Rating, ID]));
end;

procedure UpdateMovedDBRecord(ID : integer; FileName : string);
var
  MDBstr : string;
begin
  MDBstr:=', FolderCRC = '+IntToStr(Integer(FilePathCRC(FileName)));

  ExecuteQuery('UPDATE '+GetDefDBname+' SET FFileName="'+AnsiLowerCase(FileName)+'", Name ="'+ExtractFileName(FileName)+'", Attr='+inttostr(db_access_none)+MDBstr+' WHERE (ID='+inttostr(ID)+')');
end;

procedure UpdateDeletedDBRecord(ID : integer; filename : string);
var
  fQuery : TDataSet; 
  crc : cardinal;
  int : integer;
  MDBstr : string;
begin
 fQuery:=GetQuery;
 try
  fQuery.Active:=false;
  if GetDBType(dbname)=DB_TYPE_MDB then
  begin
   crc:=FilePathCRC(FileName);
   int:=Integer(crc);
   MDBstr:=', FolderCRC = '+IntToStr(int);
  end;
  SetSQL(fQuery,'UPDATE '+GetDefDBname+' SET FFileName="'+AnsiLowerCase(filename)+'", Attr='+inttostr(db_access_none)+MDBstr+' WHERE (ID='+inttostr(ID)+') AND (Attr='+inttostr(db_attr_not_exists)+')');
  ExecSQL(fQuery);
 except
 end;
 FreeDS(fQuery);
end;

function FloatToStrA(Value: Extended; round : integer): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended, ffGeneral, round, 0));
end;

function SizeInTextA(Size : int64) : String;
begin
 if size<=1024 then result:=inttostr(size)+' '+TEXT_MES_BYTES;
 if (size>1024) and (size<=1024*999) then result:=FloatToStrA(size/1024,3)+' '+TEXT_MES_KB;
 if (size>1024*999) and (size<=1024*1024*999) then result:=FloatToStrA(size/(1024*1024),3)+' '+TEXT_MES_MB;
 if (size>1024*1024*999) then result:=FloatToStrA(size/(1024*1024*1024),3)+' '+TEXT_MES_GB;
end;

function getimageIDTh(ImageTh: string): TImageDBRecordA;
var
  fQuery : TDataSet;
  i : Integer;
  FromDB : string;
begin
 fQuery:=GetQuery;
 if GetDBType=DB_TYPE_MDB then
 FromDB:='(Select ID, FFileName, Attr from '+GetDefDBname+' where StrThCrc = '+IntToStr(Integer(StringCRC(ImageTh)))+')' else
 FromDB:='SELECT ID, FFileName, Attr FROM '+GetDefDBname+' WHERE StrTh = :str ';

 SetSQL(fQuery,FromDB);
 if GetDBType<>DB_TYPE_MDB then
 SetStrParam(fquery,0,ImageTh);
 try
  fQuery.active:=true;
 except
  FreeDS(fQuery);
  setlength(result.ids,0);
  setlength(result.FileNames,0);
  setlength(result.Attr,0);
  result.count:=0;
  result.ImTh:='';
  exit;
 end;
 setlength(result.ids,fQuery.RecordCount);
 setlength(result.FileNames,fQuery.RecordCount);
 setlength(result.Attr,fQuery.RecordCount);
 fQuery.First;
 for i:=1 to fQuery.RecordCount do
 begin
  result.ids[i-1]:=fQuery.FieldByName('ID').AsInteger;
  result.FileNames[i-1]:=fQuery.FieldByName('FFileName').AsString;
  result.Attr[i-1]:=fQuery.FieldByName('Attr').AsInteger;
  fQuery.Next;
 end;
 result.count:=fQuery.RecordCount;
 result.ImTh:=ImageTh;
 FreeDS(fQuery);
end;

function GetImageIDFileName(FileName: string): TImageDBRecordA;
var
  fQuery : TDataSet;
  i, count, rot:integer;
  res : TImageCompareResult;
  val : array of boolean;
  xrot : array of integer;
  FJPEG  :TJPEGImage;
  //pic : TPicture;
  G : TGraphic;
  Pass : string;
  s : string;
begin
 fQuery:=GetQuery;
 fQuery.Active:=false;

 SetSQL(fQuery,'SELECT ID, FFileName, Attr, StrTh, Thum FROM '+GetDefDBname+' WHERE FFileName like :str ');
 s:=FileName;
 if FolderView then
 Delete(s,1,Length(ProgramDir));
 SetStrParam(fQuery,0,'%'+Delnakl(NormalizeDBStringLike(AnsiLowerCase(ExtractFileName(s))))+'%');

 try
  fQuery.active:=true;
 except
  FreeDS(fQuery);
  setlength(result.ids,0);
  setlength(result.FileNames,0);
  setlength(result.Attr,0);
  result.count:=0;
  result.ImTh:='';
  exit;
 end;
 fQuery.First;
 //pic := TPicture.Create;
 G := nil;
 if fQuery.RecordCount<>0 then
 begin
  if GraphicCrypt.ValidCryptGraphicFile(FileName) then
  begin
   pass := DBKernel.FindPasswordForCryptImageFile(FileName);
   if pass='' then
   begin
    fQuery.Free;
    setlength(result.ids,0);
    setlength(result.FileNames,0);
    setlength(result.Attr,0);
    result.count:=0;
    result.ImTh:='';
    exit;
   end else
   begin
    G:=GraphicCrypt.DeCryptGraphicFile(FileName,pass);
   end;
  end else
  begin
   G:=GetGraphicClass(GetExt(FileName),false).Create;
   G.LoadFromFile(FileName);
  end;
 end;
 JPEGScale(G,100,100);
 SetLength(val,fQuery.RecordCount);
 SetLength(xrot,fQuery.RecordCount);
 count:=0;
 FJPEG:=nil;
 for i:=1 to fQuery.RecordCount do
 begin
  if ValidCryptBlobStreamJPG(fQuery.FieldByName('Thum')) then
  begin
   Pass:='';
   Pass:=DBkernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('Thum'));
   if Pass='' then
   begin
    FJPEG  := TJPEGImage.Create;
   end else
   begin
    FJPEG:=DeCryptBlobStreamJPG(fQuery.FieldByName('Thum'),Pass) as TJPEGImage;
   end;
  end else
  begin
   FJPEG  := TJPEGImage.Create;
   FJPEG.Assign(fQuery.FieldByName('Thum'));
  end;
  res:=CompareImages(FJPEG,G,rot);
  xrot[i-1]:=rot;
  val[i-1]:=(res.ByGistogramm>1) or (res.ByPixels>1);
  if val[i-1] then inc(count);
  fQuery.Next;
 end;
 if FJPEG<>nil then FJPEG.Free;
 if G<>nil then
 G.Free;
 setlength(result.ids,count);
 setlength(result.FileNames,count);
 setlength(result.Attr,count);
 setlength(result.ChangedRotate,count);
 result.count:=count;
 fQuery.First;
 count:=-1;
 for i:=1 to fQuery.RecordCount do
 if val[i-1] then
 begin
  inc(count);
  result.ChangedRotate[count]:=xrot[count]<>0;
  result.ids[count]:=fQuery.FieldByName('ID').AsInteger;
  result.FileNames[count]:=fQuery.FieldByName('FFileName').AsString;
  result.Attr[count]:=fQuery.FieldByName('Attr').AsInteger;
  result.ImTh:=fQuery.FieldByName('StrTh').AsString;
  fQuery.Next;
 end;
 FreeDS(fQuery);
end;

function getimageIDWEx(images: TArStrings; UseFileNameScanning : Boolean; OnlyImTh : boolean = false): TImageDBRecordAArray;
var
  k, i, l, len : integer;
  fQuery : TDataSet;
  sql, temp, FromDB : string;
  ThImS: TImageDBRecordAArray;
begin
 l := Length(images);
 SetLength(ThImS,l);
 SetLength(Result,l);
 for i:=0 to l-1 do
 ThImS[i]:=GetImageIDW(images[i],UseFileNameScanning,true);
 fQuery:=GetQuery;
 fQuery.Active:=false;
 sql:='';
 if GetDBType=DB_TYPE_MDB then
 begin
  FromDB:='(SELECT ID, FFileName, Attr, StrTh FROM '+GetDefDBname+' WHERE ';
  for i:=1 to l do
  begin
   if i=1 then
   sql:=sql+Format(' (StrThCrc = :strcrc%d) ',[i]) else
   sql:=sql+Format(' or (StrThCrc = :strcrc%d) ',[i]);
  end;
  FromDB:=FromDB+sql+')';
 end else FromDB:=GetDefDBname;

 sql:='SELECT ID, FFileName, Attr, StrTh FROM '+FromDB+' WHERE ';

 for i:=1 to l do
 begin
  if i=1 then
  sql:=sql+Format(' (StrTh = :str%d) ',[i]) else
  sql:=sql+Format(' or (StrTh = :str%d) ',[i]);
 end;
 SetSQL(fQuery,sql);
 if GetDBType=DB_TYPE_MDB then
 begin
  for i:=0 to l-1 do
  begin
   result[i]:=ThImS[i];
   SetIntParam(fQuery,i,Integer(StringCRC(ThImS[i].ImTh)));
  end;
  for i:=l to 2*l-1 do
  begin
   SetStrParam(fQuery,i,ThImS[i-l].ImTh);
  end;
 end else
 begin
  for i:=0 to l-1 do
  begin
   result[i]:=ThImS[i];
   SetStrParam(fQuery,i,ThImS[i].ImTh);
  end;
 end;

 try
  fQuery.active:=true;
 except
  FreeDS(fQuery);
  for i:=0 to l-1 do
  begin
   setlength(result[i].ids,0);
   setlength(result[i].FileNames,0);
   setlength(result[i].Attr,0);
   result[i].count:=0;
   result[i].ImTh:='';
   if result[i].Jpeg<>nil then
   result[i].Jpeg.Free;
   result[i].Jpeg:=nil;
  end;
  exit;
 end;

 for k:=0 to l-1 do
 begin
  setlength(result[k].ids,0);
  setlength(result[k].FileNames,0);
  setlength(result[k].Attr,0);
  len:=0;
  fQuery.First;
  for i:=1 to fQuery.RecordCount do
  begin

   temp := fQuery.FieldByName('StrTh').AsVariant;
   if temp=ThImS[k].ImTh then
   begin
    inc(len);
    setlength(result[k].ids,len);
    setlength(result[k].FileNames,len);
    setlength(result[k].Attr,len);
    result[k].ids[len-1]:=fQuery.FieldByName('ID').AsInteger;
    result[k].FileNames[len-1]:=fQuery.FieldByName('FFileName').AsString;
    result[k].Attr[len-1]:=fQuery.FieldByName('Attr').AsInteger;
   end;
   fQuery.Next;
  end;
  result[k].count:=len;
  result[k].ImTh:=ThImS[k].ImTh;
 end;
 FreeDS(fQuery);
end;

function GetImageIDW(image: string; UseFileNameScanning : Boolean; OnlyImTh : boolean = false; aThImageSize : integer = 0; aDBJpegCompressionQuality : byte = 0): TImageDBRecordA;
var
  bmp, thbmp : TBitmap;
  FileName, imth, PassWord : string;
  G : TGraphic;
begin
 DoProcessPath(image);
 if aThImageSize = 0 then aThImageSize:=ThImageSize;
 if aDBJpegCompressionQuality = 0 then aDBJpegCompressionQuality:=DBJpegCompressionQuality;
 Result.Crypt:=false;
 Result.Password:='';
 Result.UsedFileNameSearch:=false;
 result.IsError:=false;
 G:=nil;
 FileName:=image;
 Result.Jpeg:=nil;
 try
  if ValidCryptGraphicFile(FileName) then
  begin
   Result.Crypt:=true;
   Password:=DBKernel.FindPasswordForCryptImageFile(FileName);
   Result.Password:=Password;
   if PassWord='' then
   begin
    if G<>nil then G.Free;
    Result.count:=0;
    Result.ImTh:='';
    exit;
   end;
   try
    G:=DeCryptGraphicFile(FileName,PassWord);
   except
    if G<>nil then G.Free;
    Result.count:=0;
    Exit;
   end;
  end else
  begin
   Result.Crypt:=false;
   G:=GetGraphicClass(GetExt(FileName),false).Create;
   G.LoadFromFile(FileName);
  end;
 except
  on e : Exception do
  begin
   Result.IsError:=true;
   Result.ErrorText:=e.Message;
   if G<>nil then G.Free;
   Result.count:=0;
   exit;
  end;
 end;
 result.OrWidth:=G.Width;
 result.OrHeight:=G.Height;
 try
  JpegScale(G,aThImageSize,aThImageSize);
  result.Jpeg:=TJpegImage.Create;
  result.Jpeg.CompressionQuality:=aDBJpegCompressionQuality;
  bmp:= Tbitmap.Create;
  bmp.PixelFormat:=pf24bit;
  thbmp:= Tbitmap.Create;
  thbmp.PixelFormat:=pf24bit;
  If Max(G.Width,G.Height)>aThImageSize then
  begin
   if G.Width>G.Height then
   begin
    thbmp.Width:=aThImageSize;
    thbmp.Height:=Round(aThImageSize*(G.Height/G.Width));
   end else
   begin
    thbmp.Width:=Round(aThImageSize*(G.Width/G.Height));
    thbmp.Height:=aThImageSize;
   end;
  end else begin
   thbmp.Width:=G.Width;
   thbmp.Height:=G.Height;
  end;
  try
   LoadImageX(G,bmp,$FFFFFF);
//   bmp.assign(G); //+1
  except
   on e : Exception do
   begin
    EventLog(':GetImageIDW() throw exception: '+e.Message);
    Result.IsError:=true;
    Result.ErrorText:=e.Message;

    bmp.PixelFormat:=pf24bit;
    bmp.Width:=aThImageSize;
    bmp.Height:=aThImageSize;
    FillRectNoCanvas(bmp,$FFFFFF);
    DrawIconEx(bmp.Canvas.Handle,70,70,UnitDBKernel.icons[DB_IC_DELETE_INFO+1],16,16,0,0,DI_NORMAL);
    thbmp.Height:=100;
    thbmp.Width:=100;
   end;
  end;
  if G<>nil then G.Free;
  DoResize(thbmp.Width,thbmp.Height,bmp,thbmp);
  bmp.free;
  result.Jpeg.Assign(thbmp);  //+s
  try
   result.Jpeg.JPEGNeeded;
  except
   on e : Exception do
   begin
    Result.IsError:=true;
    Result.ErrorText:=e.Message;
   end;
  end;

  try
   thbmp.assign(result.Jpeg);
  except
   on e : Exception do
   begin     
    EventLog(':GetImageIDW() throw exception: '+e.Message);
    Result.IsError:=true;
    Result.ErrorText:=e.Message;  
    thbmp.Width:=Result.Jpeg.Width;
    thbmp.Height:=Result.Jpeg.Height;
    FillRectNoCanvas(thbmp,$0);
   end;
  end;
  imth:=BitmapToString(thbmp);
  thbmp.free;
  if OnlyImTh and not UseFileNameScanning then
  begin
   result.ImTh:=imth;
  end else
  begin
   result:=GetImageIDTh(imth);
   if (Result.count=0) and UseFileNameScanning then
   begin
    result:=GetImageIDFileName(FileName);
    Result.UsedFileNameSearch:=true;
   end;
  end;
 except
  on e : Exception do
  begin
   Result.IsError:=true;
   Result.ErrorText:=e.Message;
  end;
 end;
end;

procedure SetPrivate(ID: integer);
begin             
  ExecuteQuery(Format('Update %s Set Access=%d WHERE ID=%d', [GetDefDBname, db_access_private, ID]));
end;

procedure UnSetPrivate(ID: integer);
begin
  ExecuteQuery(Format('Update %s Set Access=%d WHERE ID=%d', [GetDefDBname, db_access_none, ID]));
end;

procedure CopyFilesToClipboard(FileList: string);
var
  DropFiles: PDropFiles;
  hGlobal: THandle;  
  iLen: Integer;  
begin  
  iLen := Length(FileList) + 2;  
  FileList := FileList + #0#0;
  hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,  
    SizeOf(TDropFiles) + iLen);  
  if (hGlobal = 0) then raise Exception.Create('Could not allocate memory.');
  begin  
    DropFiles := GlobalLock(hGlobal);  
    DropFiles^.pFiles := SizeOf(TDropFiles);  
    Move(FileList[1], (PChar(DropFiles) + SizeOf(TDropFiles))^, iLen);
    GlobalUnlock(hGlobal);
    Clipboard.SetAsHandle(CF_HDROP, hGlobal);
  end;
end;

function xorstrings(s1,s2:string):string;
var
  i : integer;
begin
 result:='';
 for i:=1 to 255 do
 result:=result+' ';
 for i:=1 to min(min(length(s1),length(s2)),255) do
 begin
  result[i]:=chr(ord(s1[i]) xor ord(s2[i]));
 end;
end;

function setstringtolengthwithnodata(s:string;n:integer):string;
var
  cs, i : integer;
begin
 cs:=0;
 for i:=1 to Min(Length(s),n) do
 cs:=cs+Ord(s[i]);
 Result:='';
 for i:=1 to n do
 result:=result+' ';
 for i:=1 to n do
 if i<=length(s) then
 result[i]:=chr((ord(s[i]) xor i) xor cs) else
 result[i]:=chr((i+cs) xor cs);
end;

function GetHardwareString: string;
var
  i:integer;
  lpDisplayDevice: TDisplayDevice;
  cc, dwFlags: DWORD;
  EBXstr,ECXstr,EDXstr: string[5];
  hardwarestring,s1 : string;

 function GlobalMemoryStatus(Index: Integer): Integer;
 var
   MemoryStatus: TMemoryStatus;
 begin
   with MemoryStatus do
   begin
     dwLength := SizeOf(TMemoryStatus);
     Windows.GlobalMemoryStatus(MemoryStatus);
     case Index of
       1: Result := dwMemoryLoad;
       2: Result := dwTotalPhys div 1024;
       3: Result := dwAvailPhys div 1024;
       4: Result := dwTotalPageFile div 1024;
       5: Result := dwAvailPageFile div 1024;
       6: Result := dwTotalVirtual div 1024;
       7: Result := dwAvailVirtual div 1024;
     else
      Result := 0;
     end;
   end;
 end;

 function GettingKeybType: string;  //Win95 or later and NT3.1 or later
 var
   Flag:   integer;
 begin
   Flag:=0;
   Case GetKeyboardType(Flag) of
     1:  Result:='IBM PC/XT or compatible (83-key) keyboard';
     2:  Result:='Olivetti "ICO" (102-key) keyboard';
     3:  Result:='IBM PC/AT (84-key) or similar keyboard';
     4:  Result:='IBM enhanced (101- or 102-key) keyboard';
     5:  Result:='Nokia 1050 and similar keyboards';
     6:  Result:='Nokia 9140 and similar keyboards';
     7:  Result:='Japanese keyboard';
   end;
 end;

begin
 for i:=1 to 255 do
  hardwarestring:=hardwarestring+' ';
 s1:=setstringtolengthwithnodata(inttostr(GlobalMemoryStatus(2)),255);
 hardwarestring:=xorstrings(hardwarestring,s1);
 s1:='';
 lpDisplayDevice.cb := sizeof(lpDisplayDevice);
 dwFlags := 0;
 cc:= 0;
 while EnumDisplayDevices(nil, cc, lpDisplayDevice , dwFlags) do
 begin
  Inc(cc);
  s1:=s1+lpDisplayDevice.DeviceString;
 end;
 s1:=setstringtolengthwithnodata(s1,255);
 hardwarestring:=xorstrings(hardwarestring,s1);
 asm
  mov eax,0
  cpuid
  mov dword ptr EBXstr+1,EBX
  mov byte ptr EBXstr,4
  mov dword ptr ECXstr+1,ECX
  mov byte ptr ECXstr,4
  mov dword ptr EDXstr+1,EDX
  mov byte ptr EDXstr,4
 end;
 s1:=EBXstr+'  '+ECXstr+'  '+EDXstr;
 s1:=setstringtolengthwithnodata(s1,255);
 hardwarestring:=xorstrings(hardwarestring,s1);
 s1:=setstringtolengthwithnodata(GettingKeybType,255);
 hardwarestring:=xorstrings(hardwarestring,s1);
 result:=hardwarestring;
end;

function SaveIDsTofile(FileName : string; IDs : TArInteger) : boolean;
var
  i : integer;
  x : array of byte;
  FS : Tfilestream;
begin
 Result:=false;
 if length(IDs)=0 then exit;
 try
  FS:=TFileStream.Create(filename,fmOpenWrite or fmCreate);
 except
  exit;
 end;
 try
  SetLength(x,14);
  x[0]:=ord(' ');
  x[1]:=ord('F');
  x[2]:=ord('I');
  x[3]:=ord('L');
  x[4]:=ord('E');
  x[5]:=ord('-');
  x[6]:=ord('D');
  x[7]:=ord('B');
  x[8]:=ord('I');
  x[9]:=ord('D');
  x[10]:=ord('S');
  x[11]:=ord('-');
  x[12]:=ord('V');
  x[13]:=ord('1');
  fs.Write(Pointer(x)^,14);
  for i:=0 to length(IDs)-1 do
  fs.Write(IDs[i],sizeof(IDs[i]));
 except
  fs.free;
  exit;
 end;
 fs.free;
 Result:=true;
end;

function LoadIDsFromfile(FileName : string) : string;
var
  i : integer;
  x : array of Byte;
  fs : TFileStream;
  int : integer;
  v1 : boolean;
begin
 SetLength(Result,0);
 if not FileExists(FileName) then exit;
 try
  fs:=TFileStream.Create(filename,fmOpenRead);
 except
  exit;
 end;
 SetLength(x,14);
 fs.Read(Pointer(x)^,14);
 if (x[1]=ord('F')) and (x[2]=ord('I')) and (x[3]=ord('L')) and (x[4]=ord('E')) and (x[5]=ord('-')) and (x[6]=ord('D')) and (x[7]=ord('B')) and (x[8]=ord('I')) and (x[9]=ord('D')) and (x[10]=ord('S')) and (x[11]=ord('-')) and  (x[12]=ord('V')) and (x[13]=ord('1')) then
 v1:=true;
 for i:=1 to (fs.Size-14) div sizeof(integer) do
 begin
  fs.Read(int,sizeof(integer));
  result:=result+inttostr(int)+'$';
 end;
 fs.free;
end;

function LoadIDsFromfileA(FileName : string) : TArInteger;
var
  int, i : integer;
  x : array of byte;
  fs : Tfilestream;
  v1 : boolean;
begin
 SetLength(Result,0);
 if not FileExists(FileName) then exit;
 try
  fs:=TFileStream.Create(filename,fmOpenRead);
 except
  exit;
 end;
 SetLength(x,14);
 fs.Read(Pointer(x)^,14);
 if (x[1]=ord('F')) and (x[2]=ord('I')) and (x[3]=ord('L')) and (x[4]=ord('E')) and (x[5]=ord('-')) and (x[6]=ord('D')) and (x[7]=ord('B')) and (x[8]=ord('I')) and (x[9]=ord('D')) and (x[10]=ord('S')) and (x[11]=ord('-')) and  (x[12]=ord('V')) and (x[13]=ord('1')) then
 v1:=true else exit;
 for i:=1 to (fs.Size-14) div SizeOf(integer) do
 begin
  fs.Read(int,sizeof(integer));
  SetLength(result,length(result)+1);
  result[length(result)-1]:=int;
 end;
 fs.free;
end;

function SaveImThsTofile(FileName : string; ImThs : TArstrings) : boolean;
var
  i : integer;
  x : array of byte;
  fs : Tfilestream;
begin
 Result:=false;
 if length(ImThs)=0 then exit;
 try
  fs:=TFileStream.Create(filename,fmOpenWrite or fmCreate);
 except
  exit;
 end;
 try
  SetLength(x,14);
  x[0]:=ord(' ');
  x[1]:=ord('F');
  x[2]:=ord('I');
  x[3]:=ord('L');
  x[4]:=ord('E');
  x[5]:=ord('-');
  x[6]:=ord('I');
  x[7]:=ord('M');
  x[8]:=ord('T');
  x[9]:=ord('H');
  x[10]:=ord('S');
  x[11]:=ord('-');
  x[12]:=ord('V');
  x[13]:=ord('1');
  fs.Write(Pointer(x)^,14);
  for i:=0 to length(ImThs)-1 do
  fs.Write(ImThs[i,1],length(ImThs[i]));
 except
  fs.Free;
  Exit;
 end;
 fs.Free;
 Result:=true;
end;

function LoadImThsFromfileA(FileName : string) : TArStrings;
var
  i : integer;
  s : string;
  x : array of byte;
  fs : Tfilestream;
  v1 : boolean;
begin
 SetLength(Result,0);
 if not FileExists(FileName) then exit;
 try
  fs:=TFileStream.Create(filename,fmOpenRead);
 except
  exit;
 end;
 SetLength(x,14);
 fs.Read(Pointer(x)^,14);
 if (x[1]=ord('F')) and (x[2]=ord('I')) and (x[3]=ord('L')) and (x[4]=ord('E')) and (x[5]=ord('-')) and (x[6]=ord('I')) and (x[7]=ord('M')) and (x[8]=ord('T')) and (x[9]=ord('H')) and (x[10]=ord('S')) and (x[11]=ord('-')) and  (x[12]=ord('V')) and (x[13]=ord('1')) then
 v1:=true else
 begin   
  fs.free;
  exit;
 end;
 for i:=1 to (fs.Size-14) div 200 do
 begin
  SetLength(s,200);
  fs.Read(s[1],200);
  SetLength(Result,length(result)+1);
  result[length(result)-1]:=s;
 end;
 fs.free;
end;

function HardwareStringToCode(hs : string):string;
var
  i, j : integer;
  s : byte;
begin
 hs:=GetUserString;
 Result:='';
 for i:=1 to 8 do
 begin
  s:=0;
  for j:=1 to 32 do
  s:=s+ord(hs[32*(i-1)+j-1]);
  Result:=Result+inttohex(s,2);
 end;
end;

function CodeToActivateCode(s : string):string;
var
  c, intr, sum, i : integer;
  hs : string;
begin
 sum:=0;
 for i:=1 to length(s) do
 sum:=sum+ord(s[i]);
 result:='';
 for i:=1 to length(s) div 2 do
 begin
  c:=hextointdef(s[2*(i-1)+1]+s[2*(i-1)+2],0);
  intr:=round(abs($ff*cos($ff*c+sum+sin(i))));
  hs:=inttohex(intr,2);
  Result:=Result+hs;
 end;
end;

function GetUserString : string;
var
  s1, hardwarestring : string;
begin
 hardwarestring:=gethardwarestring;
 s1:=SidToStr(GetUserSID);
 s1:=setstringtolengthwithnodata(s1,255);
 hardwarestring:=xorstrings(hardwarestring,s1);
 result:=hardwarestring;
end;

function AltKeyDown : boolean;
begin
 result:=(Word(GetKeyState(VK_MENU)) and $8000)<>0;
end;

function CtrlKeyDown : boolean;
begin
 result:=(Word(GetKeyState(VK_CONTROL)) and $8000)<>0;
end;

function ShiftKeyDown : boolean;
begin
 result:=(Word(GetKeyState(VK_SHIFT)) and $8000)<>0;
end;

procedure JPEGScale(Graphic : TGraphic; Width, Height: Integer);
Var
  ScaleX, ScaleY, Scale :Extended;
begin
 try
 If (Graphic Is TJpegImage) Then
 begin
  ScaleX:=Graphic.Width/Width;
  ScaleY:=Graphic.Height/Height;
  Scale:=Max(ScaleX,ScaleY);
  If Scale<2 then
  (Graphic As TJpegImage).Scale:=jsFullSize;
  If (Scale>=2) and (Scale<4) then
  (Graphic As TJpegImage).Scale:=jsHalf;
  If (Scale>=4) and (Scale<8) then
  (Graphic As TJpegImage).Scale:=jsQuarter;
  If Scale>=8 then
  (Graphic As TJpegImage).Scale:=jsEighth;
 end;
 except
 end;
end;

procedure ShowPropertiesDialog(FName: string);
var
  SExInfo: TSHELLEXECUTEINFO;
begin
  ZeroMemory(Addr(SExInfo),SizeOf(SExInfo));
  SExInfo.cbSize := SizeOf(SExInfo);
  SExInfo.lpFile := PChar(FName);
  SExInfo.lpVerb := 'Properties';
  SExInfo.fMask  := SEE_MASK_INVOKEIDLIST;
  ShellExecuteEx(Addr(SExInfo));
end;

function MrsGetFileType(strFilename: string): string;
var 
  FileInfo: TSHFileInfo;
begin
  FillChar(FileInfo, SizeOf(FileInfo), #0); 
  SHGetFileInfo(PChar(strFilename), 0, FileInfo, SizeOf(FileInfo), SHGFI_TYPENAME); 
  Result := FileInfo.szTypeName;
end;

procedure CreateBuffer( Names : array of string; var P : TBuffer );
var
  I : Integer;
  S : string;
begin
 For i:=0 to Length(Names)-1 do
 begin
  If s='' then
  begin
   s:=Names[i];
  end else
  begin
   s:=s+#0+Names[i];
  end;
 end;
 s:=s+#0#0;
 SetLength(P,Length(s));
 For i:=1 to Length(s) do
 P[i-1]:=S[i];
end;

function CopyFilesSynch(Handle : Hwnd; Src : array of string;
  Dest : string; Move : Boolean; AutoRename : Boolean ) : Integer;
var
  SHFileOpStruct : TSHFileOpStruct;
  SrcBuf : TBuffer;
begin
 Result:=-1;
 inc(CopyFilesSynchCount);
 try
  CreateBuffer( Src, SrcBuf );
  with SHFileOpStruct do
  begin
    Wnd := Handle;
    wFunc := FO_COPY;
    if Move then wFunc := FO_MOVE;
    pFrom := Pointer( SrcBuf );
    pTo := PChar( Dest );
    fFlags := 0;
    if AutoRename then
      fFlags := FOF_RENAMEONCOLLISION;
    fAnyOperationsAborted := False;
    hNameMappings := nil;
    lpszProgressTitle := nil;
  end;
  Result := SHFileOperation( SHFileOpStruct );
  SrcBuf := nil;
 except
 end;
 dec(CopyFilesSynchCount);
end;

procedure CopyFiles( Handle : Hwnd; Src : array of string;
  Dest : string; Move : Boolean; AutoRename : Boolean; CallBack : TCorrectPathProc= nil; ExplorerForm : TForm = nil);
begin
 TWindowsCopyFilesThread.Create(false, Handle, Src, Dest, Move, AutoRename, CallBack, ExplorerForm);
end;

function DeleteFiles( Handle : HWnd; Names : array of string; ToRecycle : Boolean ) : Integer;
var
  SHFileOpStruct : TSHFileOpStruct; 
  Src : TBuffer; 
begin 
  CreateBuffer( Names, Src ); 
  with SHFileOpStruct do 
    begin 
      Wnd := Handle; 
      wFunc := FO_DELETE; 
      pFrom := Pointer( Src ); 
      pTo := nil; 
      fFlags := 0; 
      if ToRecycle then fFlags := FOF_ALLOWUNDO; 
      fAnyOperationsAborted := False; 
      hNameMappings := nil; 
      lpszProgressTitle := nil; 
    end; 
  Result := SHFileOperation( SHFileOpStruct ); 
  Src := nil; 
end;

function SilentDeleteFiles( Handle : HWnd; Names : array of string; ToRecycle : Boolean; HideErrors : boolean = false ) : Integer;
var
  SHFileOpStruct : TSHFileOpStruct; 
  Src : TBuffer; 
begin 
  CreateBuffer( Names, Src ); 
  with SHFileOpStruct do 
    begin 
      Wnd := Handle; 
      wFunc := FO_DELETE;
      pFrom := Pointer( Src ); 
      pTo := nil; 
      fFlags := FOF_NOCONFIRMATION;
      if HideErrors then fFlags:=fFlags or FOF_SILENT or FOF_NOERRORUI;
      if ToRecycle then fFlags := fFlags or FOF_ALLOWUNDO;
      fAnyOperationsAborted := False;
      hNameMappings := nil; 
      lpszProgressTitle := nil; 
    end; 
  Result := SHFileOperation( SHFileOpStruct ); 
  Src := nil; 
end;

Function GetCDVolumeLabel(CDName : Char) : String;
var
  VolumeName,
  FileSystemName : array [0..MAX_PATH-1] of Char;
  VolumeSerialNo : DWord;
  MaxComponentLength,FileSystemFlags: Cardinal;
begin
  GetVolumeInformation(Pchar(CDName+':\'),VolumeName,MAX_PATH,@VolumeSerialNo,
  MaxComponentLength,FileSystemFlags, FileSystemName,MAX_PATH);
  Result:=VolumeName;
end;

function DriveState(driveletter: Char): TDriveState;
var
  mask: string[6];
  sRec: TSearchRec;
  oldMode: Cardinal;
  retcode: Integer;
begin
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  mask := '?:\*.*';
  mask[1] := driveletter;
{$I-} { не возбуждаем исключение при неудаче }
  retcode := FindFirst(mask, faAnyfile, SRec);
  FindClose(SRec);
{$I+}
  case retcode of
    0: Result := DS_DISK_WITH_FILES; { обнаружен по крайней мере один файл }
    -18: Result := DS_EMPTY_DISK; { никаких файлов не обнаружено, но ok }
    -21: Result := DS_NO_DISK; { DOS ERROR_NOT_READY }
  else
    Result := DS_UNFORMATTED_DISK; { в моей системе значение равно -1785!}
  end;
  SetErrorMode(oldMode);
end;

Procedure ShowMyComputerProperties(Hwnd : THandle);
var
  pMalloc: IMalloc;
  desktop: IShellFolder;
  mnu: IContextMenu;
  hr: HRESULT;
  pidlDrives: PItemIDList;
  cmd: TCMInvokeCommandInfo;
begin
  hr := SHGetMalloc( pMalloc );
  if SUCCEEDED( hr ) then
  try
   hr := SHGetDesktopFolder( desktop );
   if SUCCEEDED( hr ) then
   try
    hr := SHGetSpecialFolderLocation( Hwnd, CSIDL_DRIVES, pidlDrives );
    if SUCCEEDED( hr ) then
    try
     hr := desktop.GetUIObjectOf( Hwnd, 1, pidlDrives, IContextMenu, nil, Pointer(mnu) );
     if SUCCEEDED( hr ) then
     try
      FillMemory( @cmd, sizeof(cmd), 0 );
      with cmd do
      begin
       cbSize := sizeof( cmd );
       fMask := 0;
       hwnd := 0;
       lpVerb := PChar( 'Properties' );
       nShow := SW_SHOWNORMAL;
      end;
      hr := mnu.InvokeCommand( cmd );
     finally
      mnu := nil;
     end;
    finally
     pMalloc.Free( pidlDrives );
    end;
   finally
    desktop := nil;
   end;
  finally
   pMalloc := nil;
  end;
end;

function KillTask(ExeFileName: string): integer;
const  
  PROCESS_TERMINATE=$0001;
var  
  ContinueLoop: BOOL;  
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;  
begin  
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
  begin  
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
     or (UpperCase(FProcessEntry32.szExeFile) =UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle,  FProcessEntry32);  
  end;  
  CloseHandle(FSnapshotHandle);  
end;

Procedure LoadNickJpegImage(Image : TImage);
var
  Pic : tpicture;
  Bmp, Bitmap : tbitmap;
  fJPG  : TJpegImage;
  OpenPictureDialog : DBOpenPictureDialog;
begin
 OpenPictureDialog := DBOpenPictureDialog.Create();
 OpenPictureDialog.Filter:=GetGraphicFilter;
 if OpenPictureDialog.Execute then
 begin
  Pic:=TPicture.create;
  try
   Pic.LoadFromFile(OpenPictureDialog.FileName);
  except
   Pic.free;
   OpenPictureDialog.Free;
   Exit;
  end;
  JpegScale(Pic.Graphic,48,48);
  Bitmap:=TBitmap.Create;
  Bitmap.PixelFormat:=Pf24Bit;
  Bitmap.Assign(Pic.Graphic);
  Pic.Free;
  Bmp:=tbitmap.Create;
  Bmp.PixelFormat:=pf24bit;
  if Bitmap.Width>Bitmap.Height then
  begin
   if Bitmap.Width>48 then
   bmp.Width:=48 else
   bmp.Width:=Bitmap.Width;
   bmp.Height:=round(bmp.Width*(Bitmap.Height/Bitmap.Width));
  end else
  begin
   if Bitmap.Height>48 then
   bmp.Height:=48 else
   bmp.Height:=Bitmap.Height;
   bmp.Width:=round(bmp.Height*(Bitmap.Width/Bitmap.Height));
  end;
  DoResize(bmp.Width,bmp.Height,Bitmap,Bmp);
  Bitmap.Free;
  fjpg:=TJPegImage.Create;
  fjpg.CompressionQuality:=DBJpegCompressionQuality;
  fjpg.Assign(bmp);
  fjpg.JPEGNeeded;
  if image.Picture.Graphic=nil then image.Picture.Graphic:=TJpegImage.Create;
  Image.Picture.Graphic.Assign(fjpg);
  Image.refresh;
  fjpg.free;
  bmp.free;
  OpenPictureDialog.Free;
 end;
end;

function ExtractAssociatedIcon_(FileName :String) :HICON;
var
  i : Word;
  b : array[0..2048] of char;
begin
 i := 1;
 Result := ExtractAssociatedIcon(Application.Handle, StrLCopy(b,PChar(FileName),SizeOf(b)-1),i);
end;

function ExtractAssociatedIcon_W(FileName :String; IconIndex : Word) :HICON;
var
  b : array[0..2048] of char;
begin
 Result := ExtractAssociatedIcon(Application.Handle, StrLCopy(b,PChar(FileName),SizeOf(b)-1),IconIndex);
end;

function GetFileDateTime(FileName: string): TDateTime;
var
 intFileAge: LongInt;
begin
 intFileAge := FileAge(FileName);
 if intFileAge = -1 then
  Result := 0
 else
  Result := FileDateToDateTime(intFileAge)
end;

Procedure DoHelp;
begin
  ShellExecute(0, Nil, 'http://photodb.illusdolphin.net', Nil, Nil, SW_NORMAL);
end;

Procedure DoUpdateHelp;
begin
 if FileExists(ProgramDir+'Help\photodb_updating.htm') then
 ShellExecute(0, Nil,PChar(ProgramDir+'Help\photodb_updating.htm'), Nil, Nil, SW_NORMAL);
end;

Procedure DoHomePage;
begin
 ShellExecute(0, Nil,Pchar(HomeURL), Nil, Nil, SW_NORMAL);
end;

Procedure DoHomeContactWithAuthor;
begin
 ShellExecute(0, Nil,Pchar('mailto:'+ProgramMail+'?subject='''''+ProductName+''''''), Nil, Nil, SW_NORMAL);
end;

Procedure DoGetCode(S : String);
begin
 ShellExecute(0, Nil,Pchar('mailto:'+ProgramMail+'?subject='''''+ProductName+''''' REGISTRATION CODE = '''''+s+''''''), Nil, Nil, SW_NORMAL);
end;

procedure UpdateImageThInLinks(OldImageTh, NewImageTh : String);
var
  FQuery : TDataSet;
  IDs : TArInteger;
  Links : TArStrings;
  i, j : integer;
  info : TArLinksInfo;
  Link, OldImageThCode : String;
  Table : TDataSet;
begin
 if OldImageTh=NewImageTh then exit;
 if not DBKernel.ReadBool('Options','CheckUpdateLinks',false) then exit;
 FQuery := GetQuery;
 OldImageThCode:=CodeExtID(OldImageTh);
 SetSQL(FQuery,'Select ID, Links from '+GetDefDBName+' where Links like "%'+OldImageThCode+'%"');
 try
  FQuery.Active:=true;
 except
  FreeDS(FQuery);
  exit;
 end;
 if FQuery.RecordCount=0 then
 begin
  FreeDS(FQuery);
  exit;
 end;
 FQuery.First;
 SetLength(IDs,0);
 SetLength(Links,0);
 for i:=1 to FQuery.RecordCount do
 begin
  SetLength(IDs,Length(IDs)+1);
  IDs[Length(IDs)-1]:=FQuery.FieldByName('ID').AsInteger;
  SetLength(Links,Length(Links)+1);
  Links[Length(Links)-1]:=FQuery.FieldByName('Links').AsString;
  FQuery.Next;
 end;
 FQuery.Close;
 FreeDS(FQuery);
 SetLength(info,Length(Links));
 for i:=0 to Length(IDs)-1 do
 begin
  info[i]:=ParseLinksInfo(Links[i]);
  for j:=0 to Length(info[i])-1 do
  begin
   if info[i,j].LinkType=LINK_TYPE_ID_EXT then
   if info[i,j].LinkValue=OldImageThCode then
   begin
    info[i,j].LinkValue:=CodeExtID(NewImageTh);
   end;
  end;
 end;
 //correction
  //Access
  Table:=GetQuery;
  for i:=0 to Length(IDs)-1 do
  begin
   Link:=CodeLinksInfo(info[i]);
   SetSQL(Table,'Update '+GetDefDBName+' set Links="'+Link+'" where ID = '+IntToStr(IDs[i]));
   ExecSQL(Table);
  end;
end;
                                                                                                            
Procedure UpdateImageRecord(FileName: String; ID : Integer);
begin
 UpdateImageRecordEx(FileName, ID, nil);
end;

Procedure UpdateImageRecordEx(FileName: String; ID : Integer; OnDBKernelEvent : TOnDBKernelEventProcedure);
var
  Table : TDataSet;
  Res : TImageDBRecordA;
  Dublicat, IsDate, IsTime, UpdateDateTime : Boolean;
  i, Attr, counter : integer;
  EventInfo : TEventValues;
  Exif : TEXIF;
  EF : TEventFields;
  Path, OldImTh, folder, _SetSql : string;
  crc : Cardinal;
  DateToAdd, aTime : TDateTime;
  ms : TMemoryStream;

  function next : integer;
  begin
   Result:=counter;
   inc(counter);
  end;

  procedure DoDBkernelEvent(Sender: TObject;  ID: integer; Params: TEventFields; Value: TEventValues);
  begin
   if Assigned(OnDBKernelEvent) then
   begin
    OnDBKernelEvent(Sender, ID, params, Value);
   end else
   begin
    DBKernel.DoIDEvent(Sender, ID, params, Value);
   end;
  end;

begin
 if ID=0 then exit;
 if FolderView then if not FileExists(FileName) then  FileName:=ProgramDir+FileName;


 FileName:=LongFileNameW(FileName);
 for i:=Length(FileName)-1 downto 1 do
 begin
  if (FileName[i]='\') and (FileName[i+1]='\') then
  Delete(FileName,i,1);
 end;
 Res:=getimageIDW(FileName,false);
 if Res.Jpeg=nil then exit;

 IsDate:=false;
 IsTime:=false;
 DateToAdd:=0;
 aTime:=0;
 //----
 if GetDBType=DB_TYPE_MDB then
 begin
   Table:=GetQuery;
   SetSQL(Table,'Select StrTh,Attr from '+GetDefDBName+' where ID = '+IntToStr(ID));
   try
    Table.Open;
    OldImTh:=Table.FieldByName('StrTh').AsString;
    Attr:=Table.FieldByName('Attr').AsInteger;
    Table.Close;
    _SetSql:='FFileName=:FFileName,';
    _SetSql:=_SetSql+'Name=:Name,';
    _SetSql:=_SetSql+'StrTh=:StrTh,'; 
    _SetSql:=_SetSql+'StrThCrc=:StrThCrc,';
    _SetSql:=_SetSql+'thum=:thum,';

    _SetSql:=_SetSql+Format('Width=%d,',[Res.OrWidth]);
    _SetSql:=_SetSql+Format('Height=%d,',[Res.OrHeight]);
    _SetSql:=_SetSql+Format('FileSize=%d,',[GetFileSizeByName(ProcessPath(FileName))]);

    if not FolderView then
    begin
     folder:=GetDirectory(FileName);  
     UnProcessPath(folder);
     UnFormatDir(folder);
     CalcStringCRC32(AnsiLowerCase(folder),crc);
    end else
    begin
     folder:=GetDirectory(FileName);
     UnProcessPath(folder);
     Delete(folder,1,Length(ProgramDir));
     UnformatDir(folder);
     CalcStringCRC32(AnsiLowerCase(folder),crc);
     FormatDir(folder);
    end;
    _SetSql:=_SetSql+Format('FolderCRC=%d,',[crc]);

    UpdateDateTime:=false;
    if DBKernel.ReadBool('Options','FixDateAndTime',True) then
    begin
     Exif := TExif.Create;
     try
      Exif.ReadFromFile(FileName);
      if YearOf(Exif.Date)>2000 then
      begin
       UpdateDateTime:=true;
       DateToAdd:=Exif.Date;
       aTime:=Exif.Time;
       IsDate:=True;
       IsTime:=True;
       EventInfo.Date:=Exif.Date;
       EventInfo.Time:=Exif.Time;
       EventInfo.IsDate:=True;
       EventInfo.IsTime:=True;
       EF:=[EventID_Param_Date,EventID_Param_Time, EventID_Param_IsDate ,
       EventID_Param_IsTime];
       DoDBkernelEvent(nil,ID,EF,EventInfo);    
       _SetSql:=_SetSql+'DateToAdd=:DateToAdd,';
       _SetSql:=_SetSql+'aTime=:aTime,';
       _SetSql:=_SetSql+'IsDate=:IsDate,';
       _SetSql:=_SetSql+'IsTime=:IsTime,';
      end;
     except      
      on e : Exception do EventLog(':UpdateImageRecordEx()/FixDateAndTime throw exception: '+e.Message);
     end;
     Exif.Free;
    end;

   if Attr=db_attr_dublicate then
   begin
    Dublicat:=false;
    for i:=0 to Res.count-1 do
    if Res.IDs[i]<>ID then
    if Res.Attr[i]<>db_attr_not_exists then
    begin
     Dublicat:=true;
     break;
    end;
    if not Dublicat then
    begin
     _SetSql:=_SetSql+Format('Attr=%d,',[db_attr_norm]);
     EventInfo.Attr:=db_attr_norm;
     DoDBkernelEvent(nil,ID,[EventID_Param_Attr],EventInfo);
    end;
   end;

   if Attr=db_attr_not_exists then
   begin
    _SetSql:=_SetSql+Format('Attr=%d,',[db_attr_norm]);
    EventInfo.Attr:=db_attr_norm;
    DoDBkernelEvent(nil,ID,[EventID_Param_Attr],EventInfo);
   end;

   if _SetSql[Length(_SetSql)]=',' then _SetSql:=Copy(_SetSql,1,Length(_SetSql)-1);
    SetSQL(Table,'Update '+GetDefDBName+' Set '+_SetSql+' where ID = '+IntToStr(ID));
    if FolderView then
    Path:=folder+ExtractFilename(AnsiLowerCase(FileName)) else
    Path:=AnsiLowerCase(FileName);
    UnProcessPath(Path);

    SetStrParam(Table,next,Path);

    SetStrParam(Table,next,ExtractFileName(FileName));
    SetStrParam(Table,next,Res.ImTh);                    
    SetIntParam(Table,next,Integer(StringCRC(Res.ImTh)));
    //if crypted file not password entered
    if Res.Crypt or (Res.Password<>'') then
    begin
     ms:=CryptGraphicImage(Res.Jpeg,Res.Password);
     LoadParamFromStream(Table,next,ms,ftBlob);
     ms.free;
    end else
    AssignParam(Table,next,Res.Jpeg);
    if UpdateDateTime then
    begin
     SetDateParam(Table,next,DateToAdd);
     SetDateParam(Table,next,aTime);
     SetBoolParam(Table,next,IsDate);
     SetBoolParam(Table,next,IsTime);
    end;
    ExecSQL(Table);
   except  
    on e : Exception do EventLog(':UpdateImageRecordEx()/ExecSQL throw exception: '+e.Message);
   end;
   Res.Jpeg.Free;
   FreeDS(Table);
   UpdateImageThInLinks(OldImTh, Res.ImTh);
   exit;
 end;
 
 //----
 Table := GetTable;
 Table.Active:=true;
 EF:=[];
 try
  if Table.Locate('ID',ID,[loPartialKey]) then
  begin
   OldImTh:=Table.FieldByName('StrTh').AsString;
   Table.Edit;
   Table.FieldByName('FFileName').AsString:=AnsiLowerCase(FileName);
   Table.FieldByName('Name').AsString:=ExtractFilename(FileName);
   Table.FieldByName('StrTh').AsString:=Res.ImTh;
   Table.FieldByName('thum').Assign(Res.Jpeg);
   Table.FieldByName('Width').AsInteger:=Res.OrWidth;
   Table.FieldByName('Height').AsInteger:=Res.OrHeight;
   Table.FieldByName('FileSize').AsInteger:=GetFileSizeByName(FileName);

   if DBKernel.ReadBool('Options','FixDateAndTime',True) then
   begin
    Exif := TExif.Create;
    try
     Exif.ReadFromFile(FileName);
     if YearOf(Exif.Date)>2000 then
     begin
      Table.FieldByName('DateToAdd').AsDateTime:=Exif.Date;
      Table.FieldByName('aTime').AsDateTime:=Exif.Time;
      Table.FieldByName('IsDate').AsBoolean:=True;
      Table.FieldByName('IsTime').AsBoolean:=True;
      EventInfo.Date:=Exif.Date;
      EventInfo.Time:=Exif.Time;
      EventInfo.IsDate:=True;
      EventInfo.IsTime:=True;
      EF:=[EventID_Param_Date,EventID_Param_Time, EventID_Param_IsDate ,
      EventID_Param_IsTime];
      DoDBkernelEvent(nil,ID,EF,EventInfo);
     end;
    except 
     on e : Exception do EventLog(':UpdateImageRecordEx()/FixDateAndTime throw exception: '+e.Message);
    end;
    Exif.Free;
   end;
   
   if Res.Crypt then
   CryptBlobStream(Table.FieldByName('thum'),Res.Password);


   if Table.FieldByName('Attr').AsInteger=db_attr_dublicate then
   begin
    Dublicat:=false;
    for i:=0 to Res.count-1 do
    if Res.IDs[i]<>ID then
    if Res.Attr[i]<>db_attr_not_exists then
    begin
     Dublicat:=true;
     break;
    end;
    if not Dublicat then
    begin
     Table.FieldByName('Attr').AsInteger:=db_attr_norm;
     EventInfo.Attr:=db_attr_norm;
     DoDBkernelEvent(nil,ID,[EventID_Param_Attr],EventInfo);
    end;
   end;

   if  Table.FieldByName('Attr').AsInteger=db_attr_not_exists then
   begin
    Table.FieldByName('Attr').AsInteger:=db_attr_norm;
    EventInfo.Attr:=db_attr_norm;
    DoDBkernelEvent(nil,ID,[EventID_Param_Attr],EventInfo);
   end;

  end;
 finally
  Res.Jpeg.Free;
  FreeDS(Table);
 end;
 try
  UpdateImageThInLinks(OldImTh, Res.ImTh);
 except
  on e : Exception do EventLog(':UpdateImageRecordEx()/UpdateImageThInLinks throw exception: '+e.Message);
 end;
end;

procedure SetDesktopWallpaper(FileName : String; WOptions : Byte);
const
  CLSID_ActiveDesktop: TGUID = '{75048700-EF1F-11D0-9888-006097DEACF9}';
var
  ActiveDesktop: IActiveDesktop;
  P : PWideChar;
  s : String;
  Options : TWallPaperOpt;
begin
  ActiveDesktop := CreateComObject(CLSID_ActiveDesktop) as IActiveDesktop;
  s:=FileName;
  GetMem(P,Length(s)*2+1);
  ActiveDesktop.SetWallpaper(StringToWideChar(s,P,Length(S)*2+1), 0);
  FreeMem(P);
  Options.dwSize:=SizeOf(_tagWALLPAPEROPT);
  Options.dwStyle:=WOptions;
  ActiveDesktop.SetWallpaperOptions(Options,0);
  ActiveDesktop.ApplyChanges(AD_APPLY_ALL or AD_APPLY_FORCE);
end;

procedure RotateDBImage270(ID : integer; OldRotation : Integer);
var
  EventInfo : TEventValues;
begin
 if ID<>0 then
 begin
  Case OldRotation of
   DB_IMAGE_ROTATED_0   :  EventInfo.Rotate:=DB_IMAGE_ROTATED_270;
   DB_IMAGE_ROTATED_90  :  EventInfo.Rotate:=DB_IMAGE_ROTATED_0;
   DB_IMAGE_ROTATED_180 :  EventInfo.Rotate:=DB_IMAGE_ROTATED_90;
   DB_IMAGE_ROTATED_270 :  EventInfo.Rotate:=DB_IMAGE_ROTATED_180;
  end;
  SetRotate(ID,EventInfo.Rotate);
  DBKernel.DoIDEvent(nil,ID,[EventID_Param_Rotate],EventInfo);
 end;
end;

procedure RotateDBImage90(ID : integer; OldRotation : Integer);
var
  EventInfo : TEventValues;
begin
 if ID<>0 then
 begin
  Case OldRotation of
   DB_IMAGE_ROTATED_0   :  EventInfo.Rotate:=DB_IMAGE_ROTATED_90;
   DB_IMAGE_ROTATED_90  :  EventInfo.Rotate:=DB_IMAGE_ROTATED_180;
   DB_IMAGE_ROTATED_180 :  EventInfo.Rotate:=DB_IMAGE_ROTATED_270;
   DB_IMAGE_ROTATED_270 :  EventInfo.Rotate:=DB_IMAGE_ROTATED_0;
  end;
  SetRotate(ID,EventInfo.Rotate);
  DBKernel.DoIDEvent(nil,ID,[EventID_Param_Rotate],EventInfo);
 end;
end;

procedure RotateDBImage180(ID : integer; OldRotation : Integer);
var
  EventInfo : TEventValues;
begin
 if ID<>0 then
 begin
  Case OldRotation of
   DB_IMAGE_ROTATED_0   :  EventInfo.Rotate:=DB_IMAGE_ROTATED_180;
   DB_IMAGE_ROTATED_90  :  EventInfo.Rotate:=DB_IMAGE_ROTATED_270;
   DB_IMAGE_ROTATED_180 :  EventInfo.Rotate:=DB_IMAGE_ROTATED_0;
   DB_IMAGE_ROTATED_270 :  EventInfo.Rotate:=DB_IMAGE_ROTATED_90;
  end;
  SetRotate(ID, EventInfo.Rotate);
  DBKernel.DoIDEvent(nil,ID,[EventID_Param_Rotate],EventInfo);
 end;
end;

function SendMail(const From, Dest, Subject, Text, FileName: PChar;
Outlook: boolean):Integer;
var
  Message: TMapiMessage;
  Recipient, Sender: TMapiRecipDesc;
  File_Attachment: TMapiFileDesc;

  function MakeMessage: TMapiMessage;
  begin
    FillChar(Sender, SizeOf(Sender), 0);
    Sender.ulRecipClass := MAPI_ORIG;
    Sender.lpszAddress := From;
                                               
    FillChar(Recipient, SizeOf(Recipient), 0);
    Recipient.ulRecipClass := MAPI_TO;
    Recipient.lpszAddress := Dest;

    FillChar(File_Attachment, SizeOf(File_Attachment), 0);
    File_Attachment.nPosition := Cardinal(-1);
    File_Attachment.lpszPathName := FileName;

    FillChar(Result, SizeOf(Result), 0);
    with Message do begin
      lpszSubject := Subject;
      lpszNoteText := Text;
      lpOriginator := @Sender;
      nRecipCount := 1;
      lpRecips := @Recipient;
      nFileCount := 1;
      lpFiles := @File_Attachment;
    end;
  end;

var
  SM: TFNMapiSendMail;
  MAPIModule: HModule;
  MAPI_FLAG: Cardinal;
begin
  if Outlook then
   MAPI_FLAG:=MAPI_DIALOG
  else
   MAPI_FLAG:=0;
  MAPIModule := LoadLibrary(PChar(MAPIDLL));
  if MAPIModule = 0 then
    Result := -1
  else
    try
      @SM := GetProcAddress(MAPIModule, 'MAPISendMail');
      if @SM <> nil then begin
        MakeMessage;
        Result := SM(0, Application.Handle, Message, MAPI_FLAG, 0);
      end else Result := 1;
    finally
      FreeLibrary(MAPIModule);
    end;
end;

Procedure DBError(ErrorValue, Error : String);
var
  body : TStrings;
begin
 body:=TStringList.Create;
 body.add('Error body:');
 body.add(ErrorValue);
 SendMail('',ProgramMail,Pchar('Error in program ['+Error+']'),Pchar(body.text),'',true);
 body.free;
end;

function GetSmallIconByPath(IconPath : String; Big : boolean = false) : TIcon;
var
  Path, Icon : String;
  IconIndex, i : Integer;
  ico1,ico2 : HIcon;
begin
 i:=Pos(',',IconPath);
 Path:=Copy(IconPath,1,i-1);
 Icon:=Copy(IconPath,i+1,Length(IconPath)-i);
 IconIndex:=StrToIntDef(Icon,0);
 ico1:=0;
 Result := TIcon.create;
 try
  ExtractIconEx(Pchar(Path),IconIndex,ico1,ico2,1);
 except
 end;
 if Big then
 begin
  Result.Handle:=ico1;
  if ico2<>0 then
  DestroyIcon(ico2);
 end else
 begin
  Result.Handle:=ico2;
  if ico1<>0 then
  DestroyIcon(ico1);
 end;
end;

procedure StretchA(Width, Height : Integer; var S, D : TBitmap);
var
  i,j:integer;
  p1: pargb;
  Sh, Sw : Extended;
  Xp : array of PARGB;
begin
 d.Width:=100;
 d.Height:=100;
 Sw:=S.Width/width;
 Sh:=S.Height/height;
 SetLength(Xp,S.height);
 for i:=0 to S.height-1 do
 Xp[i]:=s.ScanLine[i];
 try
  for i:=0 to height-1 do
  begin
   p1:=d.ScanLine[i];
   for j:=0 to width-1 do
   begin
    p1[j].r:=Xp[Round(Sh*(i)),Round(Sw*j)].r;
    p1[j].g:=Xp[Round(Sh*(i)),Round(Sw*j)].g;
    p1[j].b:=Xp[Round(Sh*(i)),Round(Sw*j)].b;
   end;
  end;
 except
 end;
end;

function Gistogramma(w,h : integer; S : PARGBArray) : TGistogrammData;
var
  i,j, max : integer;
  ps : PARGB;
  LGray, LR, LG, LB : byte;
begin
 
 /// сканирование изображение и подведение статистики
 for i:=0 to 255 do
 begin
  Result.Red[i]:=0;
  Result.Green[i]:=0;
  Result.Blue[i]:=0;
  Result.Gray[i]:=0;
 end;
 for i:=0 to h-1 do
 begin
  ps:=S[i];
  for j:=0 to w-1 do
  begin
   LR:=ps[j].r;
   LG:=ps[j].g;
   LB:=ps[j].b;
   LGray:=Round(0.3*LR+0.59*LG+0.11*LB);
   inc(Result.Gray[LGray]);
   inc(Result.Red[LR]);
   inc(Result.Green[LG]); 
   inc(Result.Blue[LB]);
  end;
 end;

 /// поиск максимума
 max:=1;
 Result.Max:=0;
 for i:=5 to 250 do
 begin
  if max<Result.Red[i] then
  begin
   max:=Result.Red[i];
   Result.Max:=i;
  end;
 end;
 for i:=5 to 250 do
 begin
  if max<Result.Green[i]  then
  begin
   max:=Result.Green[i];
   Result.Max:=i;
  end;
 end;
 for i:=5 to 250 do
 begin
  if max<Result.Blue[i] then
  begin
   max:=Result.Blue[i];    
   Result.Max:=i;
  end;
 end;
                   
 /// в основном диапозоне 0..100
 for i:=0 to 255 do
 begin
  Result.Red[i]:=Round(100*Result.Red[i]/max);
 end;

// max:=1;
 for i:=0 to 255 do
 begin
  Result.Green[i]:=Round(100*Result.Green[i]/max);
 end;

// max:=1;
 for i:=0 to 255 do
 begin
  Result.Blue[i]:=Round(100*Result.Blue[i]/max);
 end;

// max:=1;
 for i:=0 to 255 do
 begin
  Result.Gray[i]:=Round(100*Result.Gray[i]/max);
 end;

 /// ограничение на значение - изза нахождения максимума не во всём диапозоне
 for i:=0 to 255 do
 begin
  if Result.Red[i]>255 then Result.Red[i]:=255;
 end;

 for i:=0 to 255 do
 begin
  if Result.Green[i]>255 then Result.Green[i]:=255;
 end;

 for i:=0 to 255 do
 begin
  if Result.Blue[i]>255 then Result.Blue[i]:=255;
 end;

 for i:=0 to 255 do
 begin
  if Result.Gray[i]>255 then Result.Gray[i]:=255;
 end;

 //получаем границы диапозона
 Result.LeftEffective:=0;
 Result.RightEffective:=255;
 for i:=0 to 254 do
 begin
  if (Result.Gray[i]>10) and (Result.Gray[i+1]>10) then
  begin
   Result.LeftEffective:=i;
   break;
  end;
 end;
 for i:=255 downto 1 do
 begin
  if (Result.Gray[i]>10) and (Result.Gray[i-1]>10) then
  begin
   Result.RightEffective:=i;
   break;
  end;
 end;
 
end;

function CompareImagesByGistogramm(Image1, Image2 : TBitmap) : Byte;
var
  PRGBArr : PARGBArray;
  i, a : integer;
  Diff : byte;
  Data1, Data2, Data : TGistogrammData;
  mx_r,mx_b,mx_g : integer;
  ResultExt : Extended;
  
  function AbsByte(b1,b2 : integer) : integer;
  begin
   //if b1<b2 then Result:=b2-b1 else Result:=b1-b2;
   Result:=b2-b1;
  end;

  procedure RemovePicks;
  const
    InterpolateWidth = 10;
  var
    i,j,r,g,b : integer;
    ar, ag, ab : array[0..InterpolateWidth-1] of integer;
  begin
   mx_r:=0;
   mx_g:=0;
   mx_b:=0;
   /// выкидываем пики резкие и сглаживаем гистограмму
   for j:=0 to InterpolateWidth-1 do
   begin
    ar[j]:=0;  
    ag[j]:=0;
    ab[j]:=0;
   end;

   for i:=1 to 254 do
   begin
    ar[i mod InterpolateWidth]:=Data.Red[i];
    ag[i mod InterpolateWidth]:=Data.Green[i];
    ab[i mod InterpolateWidth]:=Data.Blue[i];

    r:=0;
    g:=0;
    b:=0;
    for j:=0 to InterpolateWidth-1 do
    begin
     r:=ar[j]+r;
     g:=ag[j]+g;
     b:=ab[j]+b;
    end;
    Data.Red[i]:=r div InterpolateWidth;
    Data.Green[i]:=g div InterpolateWidth;
    Data.Blue[i]:=b div InterpolateWidth;

    mx_r:=mx_r+Data.Red[i];
    mx_g:=mx_g+Data.Green[i];
    mx_b:=mx_b+Data.Blue[i];
   end;


   mx_r:=mx_r div 254;
   mx_g:=mx_g div 254;
   mx_b:=mx_b div 254;
  end;

begin
 mx_r:=0;
 mx_g:=0;
 mx_b:=0;
 SetLength(PRGBArr,Image1.Height);
 for i:=0 to Image1.Height-1 do
 PRGBArr[i]:=Image1.ScanLine[i];
 Data1:=Gistogramma(Image1.Width,Image1.Height,PRGBArr);

 GetGistogrammBitmapX(150,0,Data1.Red,a,a).SaveToFile('c:\w1.bmp');
                   
 SetLength(PRGBArr,Image2.Height);
 for i:=0 to Image2.Height-1 do
 PRGBArr[i]:=Image2.ScanLine[i];
 Data2:=Gistogramma(Image2.Width,Image2.Height,PRGBArr);

 GetGistogrammBitmapX(150,0,Data2.Red,a,a).SaveToFile('c:\w2.bmp');

 for i:=0 to 255 do
 begin
  Data.Green[i]:=AbsByte(Data1.Green[i],Data2.Green[i]);
  Data.Blue[i]:=AbsByte(Data1.Blue[i],Data2.Blue[i]);
  Data.Red[i]:=AbsByte(Data1.Red[i],Data2.Red[i]);
 end;
          
 GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w.bmp');

 RemovePicks;

 GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w_pick.bmp');

 for i:=0 to 255 do
 begin
  Data.Green[i]:=Abs(Data.Green[i]-mx_g);
  Data.Blue[i]:=Abs(Data.Blue[i]-mx_b);
  Data.Red[i]:=Abs(Data.Red[i]-mx_r);
 end;

 GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w_mx.bmp');

 ResultExt:=10000;
 if Abs(Data2.Max-Data2.Max)>20 then
 ResultExt:=ResultExt/(Abs(Data2.Max-Data1.Max)/20);

 if (Data2.LeftEffective>Data1.RightEffective) or (Data1.LeftEffective>Data2.RightEffective) then
 begin
  ResultExt:=ResultExt/10;
 end;
 if Abs(Data2.LeftEffective-Data1.LeftEffective)>5 then
 ResultExt:=ResultExt/(Abs(Data2.LeftEffective-Data1.LeftEffective)/20);
 if Abs(Data2.RightEffective-Data1.RightEffective)>5 then
 ResultExt:=ResultExt/(Abs(Data2.RightEffective-Data1.RightEffective)/20);

 for i:=0 to 255 do
 begin
  Diff:=Round(sqrt(sqr(0.3*Data.Red[i])+sqr(0.58*Data.Green[i])+sqr(0.11*Data.Blue[i])));
  if (Diff>5) and (Diff<10) then ResultExt:=ResultExt*(1-diff/1024);
  if (Diff>=10) and (Diff<20) then ResultExt:=ResultExt*(1-diff/512);
  if (Diff>=20) and (Diff<100) then ResultExt:=ResultExt*(1-diff/255);
  if Diff>=100 then ResultExt:=ResultExt*sqr(1-diff/255);
  if diff=0 then ResultExt:=ResultExt*1.02;
  if diff=1 then ResultExt:=ResultExt*1.01;
  if diff=2 then ResultExt:=ResultExt*1.001;
 end;                             
 //Result in 0..10000
 if ResultExt>10000 then ResultExt:=10000;
 Result:=Round(Power(101,ResultExt/10000)-1); //Result in 0..100
end;

function CompareImages(Image1, Image2 : TGraphic; var Rotate : Integer; fSpsearch_ScanFileRotate : boolean = true; Quick : boolean = false; Raz : integer = 60) : TImageCompareResult;
type
 TCompareArray = array[0..99,0..99,0..2] of integer;
var
  b1, b2, b1_, b2_0: TBitmap;
  x1, x2_0, x2_90, x2_180, x2_270 : TCompareArray;
  i : integer;
  Res : array[0..3] of TImageCompareResult;

  procedure FillArray(image : TBitmap; var aArray : TCompareArray);
  var
    i,j : integer;
    P : pargb;
  begin
   for i:=0 to 99 do
   begin
    p:=image.ScanLine[i];
    for j:=0 to 99 do
    begin
     aArray[i,j,0]:=p[j].r;
     aArray[i,j,1]:=p[j].g;
     aArray[i,j,2]:=p[j].b;
    end;
   end;
  end;

  function CmpImages(Image1, Image2 : TCompareArray) : Byte;
  var
    X : TCompareArray;
    i, j, k : integer;
    diff, ResultExt : Extended;
  begin
   ResultExt:=10000;
   for i:=0 to 99 do
   for j:=0 to 99 do
   for k:=0 to 2 do
   begin
    X[i,j,k]:=Abs(Image1[i,j,k]-Image2[i,j,k]);
   end;
   
   for i:=0 to 99 do
   for j:=0 to 99 do
   begin
    Diff:=Round(sqrt(sqr(0.3*X[i,j,0])+sqr(0.58*X[i,j,1])+sqr(0.11*X[i,j,2])));
    if Diff>Raz then ResultExt:=ResultExt*(1-diff/1024);
    if diff=0 then ResultExt:=ResultExt*1.05;
    if diff=1 then ResultExt:=ResultExt*1.01;
    if diff<10 then ResultExt:=ResultExt*1.001;
   end;
   if ResultExt>10000 then ResultExt:=10000;
   Result:=Round(Power(101,ResultExt/10000)-1); //Result in 0..100
  end;

begin
 if Image1.Empty or Image2.Empty then
 begin
  Result.ByGistogramm:=0;     
  Result.ByPixels:=0;
  exit;
 end;
 b1:=TBitmap.Create;
 b2:=TBitmap.Create;
 b1.PixelFormat:=pf24bit;
 b2.PixelFormat:=pf24bit;
 b1.Assign(Image1);
 b2.Assign(Image2);

 b1_:=TBitmap.Create;
 b2_0:=TBitmap.Create;
 b1_.PixelFormat:=pf24bit;
 b2_0.PixelFormat:=pf24bit;
 if Quick then
 begin
  if (b1.Width=100) and (b1.Height=100) then
  begin
   b1_.Assign(b1);
  end else
  StretchA(100,100,b1,b1_);
  b1.free;
  FillArray(b1_,x1);
  if (b2.Width=100) and (b2.Height=100) then
  begin
   b2_0.Assign(b2);
  end else
  StretchA(100,100,b2,b2_0);
  b2.free;
  FillArray(b2_0,x2_0);
 end else
 begin
  if (b1.Width>=100) and (b1.Height>=100) then
  StretchCool(100,100,b1,b1_) else
  Interpolate(0,0,100,100,Rect(0,0,b1.Width,b1.Height),b1,b1_);
  b1.free;
  FillArray(b1_,x1);
  if (b2.Width>=100) and (b2.Height>=100) then
  StretchCool(100,100,b2,b2_0) else
  Interpolate(0,0,100,100,Rect(0,0,b2.Width,b2.Height),b2,b2_0);
  b2.free;
  FillArray(b2_0,x2_0);
 end;      
 if not Quick then
 Result.ByGistogramm:=CompareImagesByGistogramm(b1_,b2_0);
 b1_.free;
 if fSpsearch_ScanFileRotate then
 begin
  Rotate90A(b2_0);
  FillArray(b2_0,x2_90);
  Rotate90A(b2_0);
  FillArray(b2_0,x2_180);
  Rotate90A(b2_0);
  FillArray(b2_0,x2_270);
 end;
 b2_0.free;
 res[0].ByPixels:=CmpImages(x1,x2_0);
 if fSpsearch_ScanFileRotate then
 begin
  res[3].ByPixels:=CmpImages(x1,x2_90);
  res[2].ByPixels:=CmpImages(x1,x2_180);
  res[1].ByPixels:=CmpImages(x1,x2_270);
 end;
 Rotate:=0;
 Result.ByPixels:=res[0].ByPixels;
 if fSpsearch_ScanFileRotate then
 for i:=0 to 3 do
 begin
  if res[i].ByPixels>Result.ByPixels then
  begin
   Result.ByPixels:=res[i].ByPixels;
   Rotate:=i;
  end;
 end;
end;

function GetIdeDiskSerialNumberW : String;
var
  VolumeName,
    FileSystemName: array[0..MAX_PATH - 1] of Char;
  VolumeSerialNo: DWord;
  MaxComponentLength,
    FileSystemFlags: Cardinal;
begin
  GetVolumeInformation( PChar(Copy(Application.ExeName,1,3)),
  VolumeName, MAX_PATH, @VolumeSerialNo,
    MaxComponentLength, FileSystemFlags,
    FileSystemName, MAX_PATH);
  Result:= IntToHex(VolumeSerialNo, 8);
end;

function GetIdeDiskSerialNumber : String;
type
  TSrbIoControl = packed record 
    HeaderLength : ULONG;
    Signature : Array[0..7] of Char; 
    Timeout : ULONG; 
    ControlCode : ULONG; 
    ReturnCode : ULONG; 
    Length : ULONG; 
  end; 
  SRB_IO_CONTROL = TSrbIoControl; 
  PSrbIoControl = ^TSrbIoControl; 

  TIDERegs = packed record 
    bFeaturesReg : Byte; // Used for specifying SMART "commands". 
    bSectorCountReg : Byte; // IDE sector count register 
    bSectorNumberReg : Byte; // IDE sector number register 
    bCylLowReg : Byte; // IDE low order cylinder value 
    bCylHighReg : Byte; // IDE high order cylinder value 
    bDriveHeadReg : Byte; // IDE drive/head register 
    bCommandReg : Byte; // Actual IDE command. 
    bReserved : Byte; // reserved for future use. Must be zero. 
  end; 
  IDEREGS = TIDERegs; 
  PIDERegs = ^TIDERegs; 

  TSendCmdInParams = packed record 
    cBufferSize : DWORD; // Buffer size in bytes 
    irDriveRegs : TIDERegs; // Structure with drive register values. 
    bDriveNumber : Byte; // Physical drive number to send command to (0,1,2,3). 
    bReserved : Array[0..2] of Byte; // Reserved for future expansion. 
    dwReserved : Array[0..3] of DWORD; // For future use. 
    bBuffer : Array[0..0] of Byte; // Input buffer. 
  end; 
  SENDCMDINPARAMS = TSendCmdInParams; 
  PSendCmdInParams = ^TSendCmdInParams; 

  TIdSector = packed record 
    wGenConfig : Word; 
    wNumCyls : Word; 
    wReserved : Word; 
    wNumHeads : Word; 
    wBytesPerTrack : Word; 
    wBytesPerSector : Word; 
    wSectorsPerTrack : Word; 
    wVendorUnique : Array[0..2] of Word; 
    sSerialNumber : Array[0..19] of Char; 
    wBufferType : Word; 
    wBufferSize : Word; 
    wECCSize : Word; 
    sFirmwareRev : Array[0..7] of Char; 
    sModelNumber : Array[0..39] of Char; 
    wMoreVendorUnique : Word; 
    wDoubleWordIO : Word; 
    wCapabilities : Word; 
    wReserved1 : Word; 
    wPIOTiming : Word; 
    wDMATiming : Word; 
    wBS : Word; 
    wNumCurrentCyls : Word; 
    wNumCurrentHeads : Word; 
    wNumCurrentSectorsPerTrack : Word; 
    ulCurrentSectorCapacity : ULONG; 
    wMultSectorStuff : Word; 
    ulTotalAddressableSectors : ULONG; 
    wSingleWordDMA : Word; 
    wMultiWordDMA : Word; 
    bReserved : Array[0..127] of Byte; 
  end; 
  PIdSector = ^TIdSector; 

const 
  IDE_ID_FUNCTION = $EC; 
  IDENTIFY_BUFFER_SIZE = 512; 
  DFP_RECEIVE_DRIVE_DATA = $0007c088; 
  IOCTL_SCSI_MINIPORT = $0004d008; 
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001b0501;
  DataSize = sizeof(TSendCmdInParams)-1+IDENTIFY_BUFFER_SIZE; 
  BufferSize = SizeOf(SRB_IO_CONTROL)+DataSize; 
  W9xBufferSize = IDENTIFY_BUFFER_SIZE+16; 
var
  hDevice : THandle; 
  cbBytesReturned : DWORD; 
  pInData : PSendCmdInParams; 
  pOutData : Pointer; // PSendCmdInParams; 
  Buffer : Array[0..BufferSize-1] of Byte; 
  srbControl : TSrbIoControl absolute Buffer; 

  procedure ChangeByteOrder( var Data; Size : Integer ); 
  var ptr : PChar; 
      i : Integer; 
      c : Char; 
  begin 
    ptr := @Data; 
    for i := 0 to (Size shr 1)-1 do 
    begin 
      c := ptr^; 
      ptr^ := (ptr+1)^; 
      (ptr+1)^ := c; 
      Inc(ptr,2); 
    end; 
  end; 

begin
 if PortableWork then
 begin
  Result:=GetIdeDiskSerialNumberW;
  exit;
 end;
  Result := ''; 
  FillChar(Buffer,BufferSize,#0); 
  if Win32Platform=VER_PLATFORM_WIN32_NT then 
    begin // Windows NT, Windows 2000 
      // Get SCSI port handle 
      hDevice := CreateFile( '\\.\Scsi0:', GENERIC_READ or GENERIC_WRITE, 
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 ); 
      if hDevice=INVALID_HANDLE_VALUE then Exit; 
      try 
        srbControl.HeaderLength := SizeOf(SRB_IO_CONTROL); 
        System.Move('SCSIDISK',srbControl.Signature,8); 
        srbControl.Timeout := 2; 
        srbControl.Length := DataSize; 
        srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY; 
        pInData := PSendCmdInParams(PChar(@Buffer)+SizeOf(SRB_IO_CONTROL)); 
        pOutData := pInData; 
        with pInData^ do 
        begin 
          cBufferSize := IDENTIFY_BUFFER_SIZE; 
          bDriveNumber := 0; 
          with irDriveRegs do 
          begin 
            bFeaturesReg := 0; 
            bSectorCountReg := 1; 
            bSectorNumberReg := 1; 
            bCylLowReg := 0; 
            bCylHighReg := 0; 
            bDriveHeadReg := $A0; 
            bCommandReg := IDE_ID_FUNCTION; 
          end; 
        end; 
        if not DeviceIoControl( hDevice, IOCTL_SCSI_MINIPORT, @Buffer, 
          BufferSize, @Buffer, BufferSize, cbBytesReturned, nil ) then Exit; 
      finally 
        CloseHandle(hDevice); 
      end; 
    end 
  else
    begin // Windows 95 OSR2, Windows 98
      hDevice := CreateFile( '\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0 );
      if hDevice=INVALID_HANDLE_VALUE then Exit; 
      try 
        pInData := PSendCmdInParams(@Buffer); 
        pOutData := PChar(@pInData^.bBuffer); 
        with pInData^ do 
        begin 
          cBufferSize := IDENTIFY_BUFFER_SIZE; 
          bDriveNumber := 0; 
          with irDriveRegs do 
          begin 
            bFeaturesReg := 0; 
            bSectorCountReg := 1; 
            bSectorNumberReg := 1; 
            bCylLowReg := 0; 
            bCylHighReg := 0; 
            bDriveHeadReg := $A0; 
            bCommandReg := IDE_ID_FUNCTION; 
          end; 
        end; 
        if not DeviceIoControl( hDevice, DFP_RECEIVE_DRIVE_DATA, pInData,  
           SizeOf(TSendCmdInParams)-1, pOutData, W9xBufferSize, 
           cbBytesReturned, nil ) then Exit; 
      finally 
        CloseHandle(hDevice); 
      end; 
    end; 
    with PIdSector(PChar(pOutData)+16)^ do 
    begin 
      ChangeByteOrder(sSerialNumber,SizeOf(sSerialNumber)); 
      SetString(Result,sSerialNumber,SizeOf(sSerialNumber)); 
    end; 
end;

procedure Delay(msecs : Longint);
var
  FirstTick : longint;
begin
  FirstTick:=GetTickCount;
  repeat
    Application.ProcessMessages; {для того чтобы не "завесить" Windows}
  until (GetTickCount-FirstTick) >= msecs;
end;

function ColorDiv2(Color1, COlor2 : TColor) : TColor;
begin
 Result:=RGB((GetRValue(Color1)+GetRValue(Color2)) div 2,
 (GetGValue(Color1)+GetGValue(Color2)) div 2,
 (GetBValue(Color1)+GetBValue(Color2)) div 2);
end;

function ColorDarken(Color : TColor) : TColor;
begin
 Result:=RGB(Round(GetRValue(Color)/1.2),
 (Round(GetGValue(Color)/1.2)),
 (Round(GetBValue(Color)/1.2)));
end;

function CreateDirA(dir : string) : boolean;
var
  i : integer;
begin
 Result:=true;
 if dir[length(dir)]<>'\' then dir:=dir+'\';
 if length(dir)<3 then exit;
 for i:=1 to length(dir) do
 try
  if (dir[i]='\') or (i=length(dir)) then
  if not CreateDir(Copy(Dir,1,i)) then
  begin
   Result:=false;
   exit;
  end;
 except
  Result:=false;
  exit;
 end;
end;

function ValidDBPath(DBPath : String) : boolean;
var
  i : integer;
  x : set of char;
begin
 Result:=true;
 x:=[];
 if GetDBType(DBPath)=DB_TYPE_MDB then x:=validcharsmdb;
 for i:=1 to Length(DBPath) do
 if not (DBPath[i] in validchars) then
 begin
  DBPath[i]:='?';
  Result:=false;
  Exit;
 end;
end;

function CreateProgressBar(StatusBar:TStatusBar; index:integer):TProgressBar;
  var findleft:integer;
      i:integer;
begin
 Result:=TProgressBar.Create(Statusbar);
 Result.parent:=Statusbar;
 Result.visible:=true;
 Result.top:=2;
 FindLeft:=0;
 for i:=0 to index-1 do
 FindLeft:=FindLeft+Statusbar.Panels[i].width+1;
 Result.left:=findleft;
 Result.width:=Statusbar.Panels[index].width-4;
 Result.height:=Statusbar.height-2;
end;

function SaveListTofile(FileName : string; IDs : TArInteger; Files : TArStrings) : boolean;
var
  i : integer;
  x : array of byte;
  fs : TFileStream;
  LenIDS, LenFiles, L : integer;
begin
 Result:=false;
 if length(IDs)+length(Files)=0 then exit;
 try
  fs:=TFileStream.Create(filename,fmOpenWrite or fmCreate);
  except
  exit;
 end;
 try
  SetLength(x,14);
  x[0]:=ord(' ');
  x[1]:=ord('F');
  x[2]:=ord('I');
  x[3]:=ord('L');
  x[4]:=ord('E');
  x[5]:=ord('-');
  x[6]:=ord('D');
  x[7]:=ord('B');
  x[8]:=ord('L');
  x[9]:=ord('S');
  x[10]:=ord('T');
  x[11]:=ord('-');
  x[12]:=ord('V');
  x[13]:=ord('1');
  fs.Write(Pointer(x)^,14);
  LenIDS:=Length(IDs);
  fs.Write(LenIDS,sizeof(LenIDS));
  LenFiles:=Length(Files);
  fs.Write(LenFiles,sizeof(LenFiles));
  for i:=0 to LenIDS-1 do
  fs.Write(IDs[i],sizeof(IDs[i]));
  for i:=0 to LenFiles-1 do
  begin
   L:=Length(Files[i]);
   fs.Write(L,sizeof(L));
   fs.Write(Files[i][1],L+1);
  end;
 except
  fs.free;
  exit;
 end;
 fs.free;
 Result:=true;
end;

procedure LoadDblFromfile(FileName : string; var IDs : TArInteger; var Files : TArStrings);
var
  int, i : integer;
  x : array of byte;
  fs : Tfilestream;
  v1 : boolean;
  LenIDS, LenFiles, L : integer;
  Str : String;
begin
 SetLength(IDs,0);
 SetLength(Files,0);
 if not FileExists(FileName) then exit;
 try
  FS:=TFileStream.Create(FileName,fmOpenRead);
 except
  exit;
 end;
 SetLength(x,14);
 fs.Read(Pointer(x)^,14);
 if (x[1]=ord('F')) and (x[2]=ord('I')) and (x[3]=ord('L')) and (x[4]=ord('E')) and (x[5]=ord('-')) and (x[6]=ord('D')) and (x[7]=ord('B')) and (x[8]=ord('L')) and (x[9]=ord('S')) and (x[10]=ord('T')) and (x[11]=ord('-')) and  (x[12]=ord('V')) and (x[13]=ord('1')) then
 v1:=true else
 begin
  FS.free;
  exit;
 end;
 fs.Read(LenIDS,SizeOf(LenIDS));
 fs.Read(LenFiles,SizeOf(LenFiles));
 SetLength(IDs,LenIDS);
 SetLength(Files,LenFiles);
 for i:=1 to LenIDS do
 begin
  fs.Read(int,sizeof(integer));
  IDs[i-1]:=int;
 end;
 for i:=1 to LenFiles do
 begin
  fs.Read(L,sizeof(L));
  SetLength(str,L);
  fs.Read(str[1],L+1);
  Files[i-1]:=str;
 end;
 fs.free;
end;

function IsWallpaper(FileName : String) : boolean;
var
  str : string;
begin
 str:=GetExt(FileName);
 Result:=(str='HTML') or (str='HTM') or (str='GIF') or (str='JPG') or (str='JPEG') or (str='JPE') or (str='BMP');
 Result:=Result and StaticPath(FileName);
end;

procedure LoadFIlesFromClipBoard(var Effects : Integer; files : TStrings);
var
  Hand : THandle;
  Count : integer;
  pfname : array[0..10023] of char;
  CD : Cardinal;
  s : string;
  dwEffect : ^Word;
begin
 Effects:=0;
 Files.Clear;
 if IsClipboardFormatAvailable(CF_HDROP) then
 begin
  if OpenClipboard(Application.Handle)=false then exit;
  CD:=0;
  repeat
   CD:=EnumClipboardFormats(CD);
   if (CD<>0)and(GetClipboardFormatName(CD,pfname,1024)<>0) then
    begin
     s:=UpperCase(string(pfname));
     if Pos('DROPEFFECT',s)<>0 then
      begin
       Hand:=GetClipboardData(CD);
       if (Hand<>NULL) then
        begin
         dwEffect:=GlobalLock(Hand);
         Effects:=dwEffect^;
         GlobalUnlock(Hand);
        end;
       CD:=0;
      end;
    end;
  until (CD=0);
  Hand:=GetClipboardData(CF_HDROP);
  if (Hand<>NULL) then
   begin
    Count:=DragQueryFile(Hand,$FFFFFFFF,nil,0);
    if Count>0 then
     repeat
      dec(Count);
      DragQueryFile(Hand,Count,pfname,1024);
      files.Add(string(pfname));
     until (Count=0);
   end;
  CloseClipboard();
 end;
end;

procedure Copy_Move(FCM:Boolean;File_List:TStrings);
var hGlobal,shGlobal:THandle;
   DropFiles:PDropFiles;
   REff:Cardinal;
   dwEffect:^Word;
   rSize,i:Integer;
   c:PChar;
begin
i:=File_List.Count;
if (i=0)or(OpenClipboard(Application.Handle)=false) then exit;
try
 EmptyClipboard();
 rSize:=sizeof(TDropFiles);
 repeat
  dec(i);
  rSize:=rSize+Length(trim(File_List.Strings[i]))+1;
 until (i=0);
 inc(rSize);
 hGlobal:=GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,rSize);
 if hGlobal<>0 then
  begin
   DropFiles:=GlobalLock(hGlobal);
   DropFiles.pFiles:=sizeof(TDropFiles);
   DropFiles.fNC:=false;
   DropFiles.fWide:=False;
   i:=File_List.Count;
   c:=PChar(DropFiles);
   c:=c+DropFiles.pFiles;
   repeat
    dec(i);
    StrCopy(c,PChar(trim(File_List.Strings[i])));
    c:=c+Length(trim(File_List.Strings[i]))+1;
   until (i=0);
   GlobalUnlock(hGlobal);
   shGlobal:=SetClipboardData(CF_HDROP,hGlobal);
   if (shGlobal<>0) then
    begin
     hGlobal:=GlobalAlloc(GMEM_MOVEABLE,sizeof(dwEffect));
     if hGlobal<>0 then
      begin
       dwEffect:=GlobalLock(hGlobal);
       If FCM then dwEffect^:=DROPEFFECT_COPY else
       dwEffect^:=DROPEFFECT_MOVE;
       GlobalUnlock(hGlobal);
       REff:=RegisterClipboardFormat(PChar('Preferred DropEffect'));//'CFSTR_PREFERREDDROPEFFECT'));
       SetClipboardData(REff,hGlobal)
      end;
    end;
  end;
finally
 CloseClipboard();
end;
end;

function GetProgramFilesDirByKeyStr(KeyStr: string): string;
var
  dwKeySize: DWORD;
  Key: HKEY;
  dwType: DWORD;
begin
  if
    RegOpenKeyEx( Windows.HKEY_LOCAL_MACHINE, PChar(KeyStr), 0, KEY_READ, Key ) = ERROR_SUCCESS
  then
  try
    RegQueryValueEx( Key, 'ProgramFilesDir', nil, @dwType, nil, @dwKeySize );
    if (dwType in [REG_SZ, REG_EXPAND_SZ]) and (dwKeySize > 0) then
    begin
      SetLength( Result, dwKeySize );
      RegQueryValueEx( Key, 'ProgramFilesDir', nil, @dwType, PByte(PChar(Result)),
        @dwKeySize );
    end
    else
    begin
      RegQueryValueEx( Key, 'ProgramFilesPath', nil, @dwType, nil, @dwKeySize );
      if (dwType in [REG_SZ, REG_EXPAND_SZ]) and (dwKeySize > 0) then
      begin
        SetLength( Result, dwKeySize );
        RegQueryValueEx( Key, 'ProgramFilesPath', nil, @dwType, PByte(PChar(Result)),
          @dwKeySize );
      end;
    end;
  finally
    RegCloseKey( Key );
  end;
end;

function GetProgramFilesDir: string;
const
  DefaultProgramFilesDir = '%SystemDrive%\Program Files';
var
  FolderName: string;
  dwStrSize: DWORD;
  i:integer;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    FolderName :=
      GetProgramFilesDirByKeyStr('Software\Microsoft\Windows NT\CurrentVersion');
  end;
  if Length(FolderName) = 0 then
  begin
    FolderName :=
      GetProgramFilesDirByKeyStr('Software\Microsoft\Windows\CurrentVersion');
  end;
  if Length(FolderName) = 0 then FolderName := DefaultProgramFilesDir;
  dwStrSize := ExpandEnvironmentStrings( PChar(FolderName), nil, 0 );
  SetLength( Result, dwStrSize );
  ExpandEnvironmentStrings( PChar(FolderName), PChar(Result), dwStrSize );
  For i:=1 to length(Result) do
  if Result[i]=#0 then
  begin
   result:=copy(Result,1,i-1);
   break;
  end;
end;

procedure DelDir(dir : String; mask : string);
var
 Found  : integer;
 SearchRec : TSearchRec;
 f:textfile;
begin
  If length(dir)<4 then exit;
  If dir[length(dir)]<>'\' then dir:=dir+'\';
  Found := FindFirst(dir+'*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
  If fileexists(dir+SearchRec.Name) and extinmask(mask,getext(dir+SearchRec.Name)) then begin
  try
  Filesetattr(dir+SearchRec.Name,0);
  Assignfile(f,dir+SearchRec.Name);
  {$I-}
  erase(f);
  {$I+}
  except;
  end;
  end else If directoryexists(dir+SearchRec.Name) then deldir(dir+SearchRec.Name, mask);
   end;
    Found := sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  try
   Removedir(dir);
  except
  end;
end;

function Mince(PathToMince: String; InSpace: Integer): String;
{=========================================================}
// "C:\Program Files\Delphi\DDrop\TargetDemo\main.pas"
// "C:\Program Files\..\main.pas"
var
  sl: TStringList;
  sHelp, sFile: String;
  iPos: Integer;

begin
  sHelp := PathToMince;
  iPos := Pos('\', sHelp);
  if iPos = 0 Then
  begin
    Result := PathToMince;
  end
  else
  begin
    sl := TStringList.Create;
    // Decode string 
    while iPos <> 0 Do
    begin
      sl.Add(Copy(sHelp, 1, (iPos - 1)));
      sHelp := Copy(sHelp, (iPos + 1), Length(sHelp));
      iPos := Pos('\', sHelp);
    end;
    if sHelp <> '' Then
    begin
      sl.Add(sHelp); 
    End;
    // Encode string
    sFile := sl[sl.Count - 1];
    sl.Delete(sl.Count - 1);
    Result := '';
    while (Length(Result + sFile) < InSpace) And (sl.Count <> 0) Do
    begin
      Result := Result + sl[0] + '\';
      sl.Delete(0);
    end;
    If sl.Count = 0 Then
    begin
      Result := Result + sFile;
    end
    else
    begin
      Result := Result + '..\' + sFile;
    end;
    sl.Free;
  end;
end;

function WindowsCopyFile(FromFile, ToDir : string) : boolean;
var
  F: TShFileOpStruct;
begin
  F.Wnd := 0; F.wFunc := FO_COPY;
  FromFile:=FromFile+#0; F.pFrom:=pchar(FromFile);
  ToDir:=ToDir+#0; F.pTo:=pchar(ToDir);
  F.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  result:=ShFileOperation(F) = 0;
end;

function WindowsCopyFileSilent(FromFile, ToDir : string) : boolean;
var
  F: TShFileOpStruct;
begin
  F.Wnd := 0; F.wFunc := FO_COPY;
  FromFile:=FromFile+#0; F.pFrom:=pchar(FromFile);
  ToDir:=ToDir+#0; F.pTo:=pchar(ToDir);
  F.fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
  result:=ShFileOperation(F) = 0;
end;

{:Converts Ansi string to Unicode string using specified code page.
  @param   s        Ansi string.
  @param   codePage Code page to be used in conversion.
  @returns Converted wide string.
}
function StringToWideString(const s: AnsiString; codePage: Word): WideString;
var
  l: integer;
begin
  if s = '' then
    Result := ''
  else
  begin
    l := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), - 1, nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@s[1]),
        - 1, PWideChar(@Result[1]), l - 1);
  end;
end; { StringToWideString }

function CreateShortcutW(SourceFileName, ShortcutName: string;  // the file the shortcut points to
                        Location: ShortcutType; // shortcut location
                        SubFolder,  // subfolder of location
                        WorkingDir, // working directory property of the shortcut
                        Parameters,
                        Description: string): //  description property of the shortcut
                        string;
var
  MyObject: IUnknown;
  MySLink: IShellLink;
  MyPFile: IPersistFile; 
  Directory, LinkName: string;
  WFileName: String;
  Reg: TRegIniFile;
  WideFileName : WideString;
  FS : TFileStream;
begin

  MyObject := CreateComObject(CLSID_ShellLink);
  MySLink := MyObject as IShellLink; 
  MyPFile := MyObject as IPersistFile; 

  MySLink.SetPath(PChar(SourceFileName));
  MySLink.SetArguments(PChar(Parameters)); 
  MySLink.SetDescription(PChar(Description)); 

  LinkName := ChangeFileExt(ShortcutName, '.lnk'); 
  LinkName := ExtractFileName(LinkName);

  // Quicklauch 
  if Location = _QUICKLAUNCH then 
  begin 
    Reg := TRegIniFile.Create(QUICK_LAUNCH_ROOT);
    try 
      Directory := Reg.ReadString('MapGroups', 'Quick Launch', ''); 
    finally 
      Reg.Free; 
    end;
  end 
  else 
  // Other locations 
  begin 
    Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
    try 
    case Location of 
      _OTHERFOLDER : Directory := SubFolder; 
      _DESKTOP     : Directory := Reg.ReadString('Shell Folders', 'Desktop', '');
      _STARTMENU   : Directory := Reg.ReadString('Shell Folders', 'Start Menu', '');
      _SENDTO      : Directory := Reg.ReadString('Shell Folders', 'SendTo', '');
      _PROGRAMS    : Directory := Reg.ReadString('Shell Folders', 'Programs', '');
    end;
    finally
      Reg.Free;
    end; 
  end;

  if Directory <> '' then
  begin
    if (SubFolder <> '') and (Location <> _OTHERFOLDER) then
    begin
      if not DirectoryExists(Directory + '\' + SubFolder) then
      CreateDir(Directory + '\' + SubFolder);
      WFileName := Directory + '\' + SubFolder + '\' + LinkName;
      end
    else 
      WFileName := Directory + '\' + LinkName;
    if WorkingDir = '' then
      MySLink.SetWorkingDirectory(PChar(ExtractFilePath(SourceFileName)))
    else
      MySLink.SetWorkingDirectory(PChar(WorkingDir));

    try

     WideFileName:= StringToWideString(WFileName,CP_ACP);

     FS:=nil;
     try
      FS:=TFileStream.Create(SourceFileName,fmShareExclusive);
     except
     end;
     MyPFile.Save(PWideChar(WideFileName), False);
     if FS<> nil then FS.Free;

    except
    end;
    Result := WFileName;
  end; 
end;

procedure HideFromTaskBar(handle : Thandle);
var
 ExtendedStyle : integer;
begin
  ExtendedStyle:=GetWindowLong(application.Handle, GWL_EXSTYLE);
  SetWindowLong(Application.Handle, SW_SHOWMINNOACTIVE,
  WS_EX_TOOLWINDOW+ws_ex_topmost+ws_ex_ltrreading+ws_ex_left or ExtendedStyle);
end;

function RandomPwd(PWLen: integer; StrTable : string): string;
var
   Y,i: integer;
begin
  Randomize;
  SetLength(Result, PWLen);
  Y := Length(StrTable);
  for i:=1 to PWLen do
  begin
    result[i]:=StrTable[random(y)+1];
  end;
end;

procedure Del_Close_btn(Handle : Thandle);
var
  hMenuHandle : HMENU;
begin
 if (Handle <> 0) then
 begin
  hMenuHandle := GetSystemMenu(Handle, FALSE);
  if (hMenuHandle <> 0) then
  DeleteMenu(hMenuHandle, SC_CLOSE, MF_BYCOMMAND);
 end;
end;

function ChangeIconDialog(hOwner :tHandle; var FileName: string; var IconIndex: Integer): Boolean;
type
  SHChangeIconProc = function(Wnd: HWND; szFileName: PChar; Reserved: Integer;
  var lpIconIndex: Integer): DWORD; stdcall;
  SHChangeIconProcW = function(Wnd: HWND; szFileName: PWideChar;
  Reserved: Integer; var lpIconIndex: Integer): DWORD; stdcall;

const
  Shell32 = 'shell32.dll';

var
  ShellHandle: THandle;
  SHChangeIcon: SHChangeIconProc;
  SHChangeIconW: SHChangeIconProcW;
  Buf: array [0..MAX_PATH] of Char;
  BufW: array [0..MAX_PATH] of WideChar;
begin
 Result:= False;
 SHChangeIcon:= nil;
 SHChangeIconW:= nil;
 ShellHandle:= Windows.LoadLibrary(PChar(Shell32));
 try
 if ShellHandle <> 0 then
 begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  SHChangeIconW:= GetProcAddress(ShellHandle, PChar(62))
  else
  SHChangeIcon:= GetProcAddress(ShellHandle, PChar(62));
 end;
 if Assigned(SHChangeIconW) then
 begin
  StringToWideChar(FileName, BufW, SizeOf(BufW));
  Result:= SHChangeIconW(hOwner, BufW, SizeOf(BufW), IconIndex) = 1;
  if Result then
  FileName:= BufW;
 end
 else if Assigned(SHChangeIcon) then
 begin
  StrPCopy(Buf, FileName);
  Result:= SHChangeIcon(hOwner, Buf, SizeOf(Buf), IconIndex) = 1;
  if Result then FileName:= Buf;
 end
 else
 raise Exception.Create(SNotSupported);
 finally
  if ShellHandle <> 0 then FreeLibrary(ShellHandle);
 end;
end;

function GetProgramPath : string;
begin
 Result:=Application.ExeName;
end;

Procedure SelectDB(DB : string);
var
  EventInfo : TEventValues;
  DBVersion : integer;

  procedure DoErrorMsg;
  begin
   if Screen.ActiveForm<>nil then
   begin
    MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_ERROR_DB_FILE_F,[DB]),TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
   end;
  end;
begin
 if FileExists(DB) then
 begin
  DBVersion:=DBKernel.TestDBEx(DB);
  if DBkernel.ValidDBVersion(DB,DBVersion) then
  begin
   dbname:=DB;
   DBKernel.SetDataBase(DB);
   EventInfo.Name:=dbname;
   LastInseredID:=0;
   DBKernel.DoIDEvent(nil,0,[EventID_Param_DB_Changed],EventInfo);
  end else
  begin
   DoErrorMsg;
  end;
 end else
 begin
  DoErrorMsg;
 end;
end;

function SaveActionsTofile(FileName : string; Actions : TArstrings) : boolean;
var
  i, length : integer;
  x : array of byte;
  fs : TFileStream;
begin
 Result:=false;
 if System.Length(Actions)=0 then exit;
 try
  fs:=TFileStream.Create(FileName,fmOpenWrite or fmCreate);
 except
  Exit;
 end;
 try
  SetLength(x,14);
  x[0]:=ord(' ');
  x[1]:=ord('D');
  x[2]:=ord('B');
  x[3]:=ord('A');
  x[4]:=ord('C');
  x[5]:=ord('T');
  x[6]:=ord('I');
  x[7]:=ord('O');
  x[8]:=ord('N');
  x[9]:=ord('S');
  x[10]:=ord('-');
  x[11]:=ord('-');
  x[12]:=ord('V');
  x[13]:=ord('1');
  fs.Write(Pointer(x)^,14);
  length:=System.Length(Actions);
  fs.Write(length,SizeOf(length));
  for i:=0 to System.length(Actions)-1 do
  begin
   length:=System.Length(Actions[i]);
   fs.Write(length,SizeOf(length));
   fs.Write(Actions[i,1],System.length(Actions[i]));
  end;
 except
  fs.Free;
  Exit;
 end;
 fs.Free;
 Result:=true;
end;

function LoadActionsFromfileA(FileName : string) : TArStrings;
var
  i, length : integer;
  s : string;
  x : array of byte;
  fs : Tfilestream;
  v1 : boolean;
begin
 SetLength(Result,0);
 if not FileExists(FileName) then exit;
 try
  fs:=Tfilestream.Create(filename,fmOpenRead);
 except
  exit;
 end;
 SetLength(x,14);
 fs.Read(Pointer(x)^,14);
 if (x[1]=ord('D')) and (x[2]=ord('B')) and (x[3]=ord('A')) and (x[4]=ord('C')) and (x[5]=ord('T')) and (x[6]=ord('I')) and (x[7]=ord('O')) and (x[8]=ord('N')) and (x[9]=ord('S')) and (x[10]=ord('-')) and (x[11]=ord('-')) and  (x[12]=ord('V')) and (x[13]=ord('1')) then
 v1:=true else
 begin
  fs.free;
  exit;
 end;

 fs.Read(length,SizeOf(length));
 for i:=1 to length do
 begin
  fs.Read(length,SizeOf(length));
  SetLength(s,length);
  fs.Read(s[1],length);
  SetLength(Result,System.length(result)+1);
  result[System.length(result)-1]:=s;
 end;
 fs.free;
end;

function GetDirectorySize(folder : string) : int64;
Var
 Found  : integer;
 SearchRec : TSearchRec;
begin
  Result:=0;
  try
  If folder[length(folder)]<>'\' then folder:=folder+'\';
  Found := FindFirst(folder+'*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
  If FileExists(folder+SearchRec.Name) then begin
  try
   Result:=Result+SearchRec.FindData.nFileSizeLow+SearchRec.FindData.nFileSizeHigh*2*MaxInt;
  except;
  end;
  end else If DirectoryExists(folder+SearchRec.Name) then Result:=Result+GetDirectorySize(folder+'\'+SearchRec.Name );
   end;
    Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  except
  end;
end;

Procedure CopyFullRecordInfo(ID : integer);
var
  DS : TDataSet;
  i : integer;
  s : string;
begin
 if not DBInDebug then exit;
 DS:=GetQuery;
 SetSQL(DS,'SELECT * FROM '+GetDefDBName+' WHERE id = '+IntToStr(ID));
 DS.Open;
 s:='';
 for i:=0 to DS.Fields.Count-1 do
 begin
//  if DS.FieldDefList[i].Name<>'StrTh' then
  begin
   if DS.Fields[i].DisplayText<>'(MEMO)' then
   s:=s+DS.FieldDefList[i].Name+' = '+DS.Fields[i].DisplayText+#13 else
   s:=s+DS.FieldDefList[i].Name+' = '+DS.Fields[i].AsString+#13;
  end;
 end;
 MessageBoxDB(GetActiveFormHandle,s,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
 FreeDS(DS);
end;

function AnsiCompareTextWithNum(Text1,Text2 : string) : integer;
var
  s1,s2 : string;

  function Num(str : string) : boolean;
  var
    i : integer;
  begin
   Result:=true;
   for i:=1 to Length(str) do
   begin
    if not (str[i] in ['0','1','2','3','4','5','6','7','8','9']) then
    begin
     Result:=false;
     break;
    end;
   end;
  end;

  function TrimNum(str : string) :string;
  var
    i : integer;
  begin
   Result:=str;
   if Result<>'' then
   for i:=1 to Length(Result) do
   begin
    if (Result[i] in ['0','1','2','3','4','5','6','7','8','9']) then
    begin
     Delete(Result,1,i-1);
     break;
    end;
   end;
   for i:=1 to Length(Result) do
   begin
    if not (Result[i] in ['0','1','2','3','4','5','6','7','8','9']) then
    begin
     Result:=Copy(Result,1,i-1);
     break;
    end;
   end;
  end;

begin
 s1:=TrimNum(Text1);
 s2:=TrimNum(Text2);
 if num(s1) or num(s2) then
 begin
  Result:=StrToIntDef(s1,0)-StrToIntDef(s2,0);
  exit;
 end;
 Result:=AnsiCompareStr(Text1,Text2);
end;

Function FileTime2DateTime(FT:_FileTime):TDateTime;
var
  FileTime:_SystemTime;
begin
  FileTimeToLocalFileTime(FT, FT);
  FileTimeToSystemTime(FT,FileTime);
  Result:=EncodeDate(FileTime.wYear, FileTime.wMonth, FileTime.wDay)+
  EncodeTime(FileTime.wHour, FileTime.wMinute, FileTime.wSecond, FileTime.wMilliseconds);
end;

function DateModify(FileName : string) : TDateTime;
var
  ts : TSearchRec;
begin
 Result:=0;
 if FindFirst(FileName, faAnyFile, ts)=0 then
 Result:=FileTime2DateTime(ts.FindData.ftLastWriteTime);
end;

function GettingProcNum: integer;  //Win95 or later and NT3.1 or later
var
  Struc:    _SYSTEM_INFO;
begin
  GetSystemInfo(Struc);
  Result:=Struc.dwNumberOfProcessors;
end;

function GetWindowsUserName: string;
const
 cnMaxUserNameLen = 254; 
var
 sUserName: string; 
 dwUserNameLen: DWORD; 
begin
 dwUserNameLen := cnMaxUserNameLen - 1; 
 SetLength(sUserName, cnMaxUserNameLen); 
 GetUserName(PChar(sUserName), dwUserNameLen); 
 SetLength(sUserName, dwUserNameLen); 
 Result := sUserName; 
end;

//SupportedExt
Procedure GetPhotosNamesFromDrive(Dir, Mask: String; var Files : TStrings; var MaxFilesCount : integer; MaxFilesSearch : Integer; CallBack : TCallBackProgressEvent = nil);
Var
 Found  : integer;
 SearchRec : TSearchRec;
 info : TProgressCallBackInfo;
begin
 if Dir='' then exit;
 If dir[length(dir)]<>'\' then dir:=dir+'\';
 Found := FindFirst(dir+'*.*', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
  If FileExists(dir+SearchRec.Name) then Dec(MaxFilesCount);
  if MaxFilesCount<0 then break;
  If FileExists(dir+SearchRec.Name) and ExtinMask(Mask,GetExt(dir+SearchRec.Name)) then
   begin
    if Files.Count>=MaxFilesSearch then break;
    Files.Add(dir+SearchRec.Name);
    if Files.Count>=MaxFilesSearch then break;
    if Assigned(CallBack) then
    begin
     info.MaxValue:=-1;
     info.Position:=-1;
     info.Information:=dir+SearchRec.Name;
     info.Terminate:=false;
     CallBack(nil,info);
     if info.Terminate then break;
    end;
   end else If DirectoryExists(dir+SearchRec.Name) then GetPhotosNamesFromDrive(dir+SearchRec.Name, Mask, Files, MaxFilesCount,MaxFilesSearch,CallBack);
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 FindClose(SearchRec);
end;

function EXIFDateToDate(DateTime : String) : TDateTime;
var
  yyyy,mm,dd : Word;
  D : String;
  DT : TDateTime;
begin
 Result:=0;
 if TryStrToDate(DateTime,DT) then
 begin
  Result:=DateOf(DT);
 end else
 begin
  D:=Copy(DateTime,1,10);
  TryStrToDate(D,Result);
  if Result=0 then
  begin
   yyyy:=StrToIntDef(Copy(DateTime,1,4),0);
   mm:=StrToIntDef(Copy(DateTime,6,2),0);
   dd:=StrToIntDef(Copy(DateTime,9,2),0);
   if (yyyy>1990) and (yyyy<2050) then
   if (mm>=1) and (mm<=12) then
   if (dd>=1) and (dd<=31) then
   Result:=EncodeDate(yyyy,mm,dd);
  end;
 end;
end;

function EXIFDateToTime(DateTime : String) : TDateTime;
var
//  yyyy,mm,dd : Word;
  T : String;
  DT : TDateTime;
begin   
 Result:=0;
 if TryStrToTime(DateTime,DT) then
 begin
  Result:=TimeOf(DT);
 end else
 begin
  T:=Copy(DateTime,12,8);
  TryStrToTime(T,Result);
  Result:=TimeOf(Result);
 end;
end;

function RemoveBlackColor(im : tbitmap) : TBitmap;
var
  i, j : integer;
  p : pargb;
begin
 im.PixelFormat:=pf24bit;
 Result:=TBitmap.create;
 Result.PixelFormat:=pf24bit;
 Result.Assign(im);
 for i:=0 to Result.Height-1 do
 begin
  p:=Result.ScanLine[i];
  for j:=0 to Result.Width-1 do
  begin
   if (p[j].r=0) and (p[j].g=0) and (p[j].b=0) then
   p[j].g := 1;
  end;
 end;
end;


function MessageBoxDB(Handle: THandle; AContent, Title, ADescription: string; Buttons,Icon: integer): integer; overload;
begin
 Result:=TaskDialogEx(Handle,AContent,Title,ADescription,Buttons,Icon,GetParamStrDBBool('NoVistaMsg'));
end;

function MessageBoxDB(Handle: THandle; AContent, Title: string; Buttons, Icon: integer): integer; overload;
begin
 Result:=MessageBoxDB(Handle,AContent,Title,'',Buttons,Icon);
end;

procedure TextToClipboard(const S : string);
var
  N : integer;
  mem : cardinal;
  ptr : pointer;
begin
 try
  with Clipboard do try
    Open;
    if IsClipboardFormatAvailable(CF_UNICODETEXT) then
    begin
      N := (Length(S) + 1) * 2;
      mem := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, N);
      ptr := GlobalLock(mem);
      Move(PWideChar(widestring(S))^, ptr^, N);
      GlobalUnlock(mem);
      SetAsHandle(CF_UNICODETEXT, mem);
    end;
    AsText := S;
    mem := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, SizeOf(dword));
    ptr := GlobalLock(mem);
    dword(ptr^) := (SUBLANG_NEUTRAL shl 10) or LANG_RUSSIAN;
    GlobalUnLock(mem);
    SetAsHandle(CF_LOCALE, mem);
  finally Close;
  end;
 except
 end;
end;

function GetActiveFormHandle : integer;
begin
 If Screen.ActiveForm <> nil then
   Result := Screen.ActiveForm.Handle
 else
   Result := 0;
end;

function GetGraphicFilter : string;
var
 AllFormatsString : string;
 FormatsString, StrTemp : string;
 p,i : integer;
 RAWFormats : string;
 
  procedure AddGraphicFormat(FormatName : string; Extensions : string; LastExtension : Boolean);
  begin
    FormatsString:=FormatsString+FormatName+' ('+Extensions+')'+'|'+Extensions;
    if not LastExtension then FormatsString:=FormatsString+'|';

    AllFormatsString:=AllFormatsString+Extensions;
    if not LastExtension then AllFormatsString:=AllFormatsString+';';
  end;

begin
 AllFormatsString:='';
 FormatsString:='';
 RAWFormats:='';
 if GraphicFilterString='' then
 begin
  AddGraphicFormat('JPEG Image File','*.jpg;*.jpeg;*.jfif;*.jpe;*.thm',false);  
  AddGraphicFormat('Tiff images','*.tiff;*.tif;*.fax',false);           
  AddGraphicFormat('Portable network graphic images','*.png',false);           
  AddGraphicFormat('GIF Images','*.gif',false);

  if IsRAWSupport then
  begin
   p:=1;
   for i:=1 to Length(RAWImages) do
   if (RAWImages[i]='|') then
   begin
    StrTemp:=copy(RAWImages,p,i-p);

    RAWFormats:=RAWFormats+'*.'+AnsiLowerCase(StrTemp);  
    if i <> Length(RAWImages) then RAWFormats:=RAWFormats+';';
    p:=i+1;
   end;
   AddGraphicFormat('Camera RAW Images',RAWFormats,false);
  end;

  AddGraphicFormat('Bitmaps','*.bmp;*.rle;*.dib',false);    
  AddGraphicFormat('Photoshop images','*.psd;*.pdd',false);
  AddGraphicFormat('Truevision images','*.win;*.vst;*.vda;*.tga;*.icb',false);
  AddGraphicFormat('ZSoft Paintbrush images','*.pcx;*.pcc;*.scr',false);
  AddGraphicFormat('Alias/Wavefront images','*.rpf;*.rla',false);
  AddGraphicFormat('SGI true color images','*.sgi;*.rgba;*.rgb;*.bw',false);
  AddGraphicFormat('Portable map images','*.ppm;*.pgm;*.pbm',false);
  AddGraphicFormat('Autodesk images','*.cel;*.pic',false);            
  AddGraphicFormat('Kodak Photo-CD images','*.pcd',false);
  AddGraphicFormat('Dr. Halo images','*.cut',false);
  AddGraphicFormat('Paintshop Pro images','*.psp',true);

  FormatsString:=Format(TEXT_MES_ALL_FORMATS,[AllFormatsString])+'|'+AllFormatsString+'|'+FormatsString;
  GraphicFilterString:=FormatsString;
 end;
 Result:=GraphicFilterString;
end;

function GetNeededRotation(OldRotation, NewRotation : integer) : Integer;
var
  ROT : array[0..3,0..3] of integer;
begin
{
  DB_IMAGE_ROTATED_0   = 0;
  DB_IMAGE_ROTATED_90  = 1;
  DB_IMAGE_ROTATED_180 = 2;
  DB_IMAGE_ROTATED_270 = 3;
  }
 ROT[DB_IMAGE_ROTATED_0,DB_IMAGE_ROTATED_0]:=DB_IMAGE_ROTATED_0;
 ROT[DB_IMAGE_ROTATED_0,DB_IMAGE_ROTATED_90]:=DB_IMAGE_ROTATED_90;
 ROT[DB_IMAGE_ROTATED_0,DB_IMAGE_ROTATED_180]:=DB_IMAGE_ROTATED_180;
 ROT[DB_IMAGE_ROTATED_0,DB_IMAGE_ROTATED_270]:=DB_IMAGE_ROTATED_270;

 ROT[DB_IMAGE_ROTATED_90,DB_IMAGE_ROTATED_0]:=DB_IMAGE_ROTATED_270;
 ROT[DB_IMAGE_ROTATED_90,DB_IMAGE_ROTATED_90]:=DB_IMAGE_ROTATED_0;
 ROT[DB_IMAGE_ROTATED_90,DB_IMAGE_ROTATED_180]:=DB_IMAGE_ROTATED_90;
 ROT[DB_IMAGE_ROTATED_90,DB_IMAGE_ROTATED_270]:=DB_IMAGE_ROTATED_180;

 ROT[DB_IMAGE_ROTATED_180,DB_IMAGE_ROTATED_0]:=DB_IMAGE_ROTATED_180;
 ROT[DB_IMAGE_ROTATED_180,DB_IMAGE_ROTATED_90]:= DB_IMAGE_ROTATED_270;
 ROT[DB_IMAGE_ROTATED_180,DB_IMAGE_ROTATED_180]:=DB_IMAGE_ROTATED_0;
 ROT[DB_IMAGE_ROTATED_180,DB_IMAGE_ROTATED_270]:=DB_IMAGE_ROTATED_90;

 ROT[DB_IMAGE_ROTATED_270,DB_IMAGE_ROTATED_0]:=DB_IMAGE_ROTATED_90;
 ROT[DB_IMAGE_ROTATED_270,DB_IMAGE_ROTATED_90]:=DB_IMAGE_ROTATED_180;
 ROT[DB_IMAGE_ROTATED_270,DB_IMAGE_ROTATED_180]:=DB_IMAGE_ROTATED_270;
 ROT[DB_IMAGE_ROTATED_270,DB_IMAGE_ROTATED_270]:=DB_IMAGE_ROTATED_0;

 Result:=ROT[OldRotation,NewRotation];
end;

procedure ExecuteQuery(SQL : string);
var
  DS : TDataSet;
begin
  DS:=GetQuery;
  try
    SetSQL(DS,SQL);
    try
      ExecSQL(DS);
      EventLog('::ExecuteSQLExecOnCurrentDB()/ExecSQL OK ['+SQL+']');
    except
      on e : Exception do EventLog(':ExecuteSQLExecOnCurrentDB()/ExecSQL throw exception: '+e.Message);
    end;
  finally
    FreeDS(DS);
  end;
end;

function ReadTextFileInString(FileName : string) : string;
var
  FS : TFileStream;
begin
  if not FileExists(FileName) then
    Exit;
 try
  FS:=TFileStream.Create(FileName, fmOpenRead);
 except   
  on e : Exception do
  begin
   EventLog(':ReadTextFileInString() throw exception: '+e.Message);
   exit;
  end;
 end;
 SetLength(Result,FS.Size);
 try
  FS.Read(Result[1],FS.Size);
 except
  on e : Exception do
  begin
   EventLog(':ReadTextFileInString() throw exception: '+e.Message);
   exit;
  end;
 end;
 FS.Free;
end;

procedure ApplyRotate(Bitmap : TBitmap; RotateValue : Integer);
begin
  case RotateValue of
    DB_IMAGE_ROTATED_270: Rotate270A(Bitmap);
    DB_IMAGE_ROTATED_90:  Rotate90A(Bitmap);
    DB_IMAGE_ROTATED_180: Rotate180A(Bitmap);
  end;
end;

initialization

DBKernel:=nil;
FExtImagesInImageList:=0;
LastInseredID:=0;
GraphicFilterString:='';
ProcessorCount := GettingProcNum;

finalization

CoUninitialize;

end.
