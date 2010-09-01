unit Dolphin_db;

interface

uses  Language, Tlhelp32, Registry, UnitDBKernel, ShellApi, Windows,
      Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, DB, Grids, DBGrids, Menus, ExtCtrls, StdCtrls,
      ImgList, ComCtrls, DBCtrls, JPEG, DmProgress, ClipBrd, win32crc,
      SaveWindowPos, ExtDlgs, ToolWin, DbiProcs, DbiErrs, Exif, UnitDBDeclare,
      acDlgSelect, GraphicCrypt, ShlObj, ActiveX, ShellCtrls, ComObj,
      MAPI, DDraw, Math, Effects, DateUtils, psAPI, DBCommon, GraphicsCool,
      uVistaFuncs, GIFImage, GraphicEx, GraphicsBaseTypes, uLogger, uFileUtils,
      UnitDBFileDialogs, RAWImage, UnitDBCommon, uConstants, uList64,
      UnitLinksSupport, EasyListView, ExplorerTypes;

const
  DBInDebug = True;
  Emulation = False;
  EmulationInstall = False;

var
  LOGGING_ENABLED: Boolean = True;
  LOGGING_MESSAGE: Boolean = False;

const
  Pwd_rusup = 'ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
  Pwd_rusdown = 'ёйцукенгшщзхъфывапролджэячсмитьбю';
  Pwd_englup = 'QWERTYUIOPASDFGHJKLZXCVBNM';
  Pwd_engldown = 'qwertyuiopasdfghjklzxcvbnm';
  Pwd_cifr = '0123456789';
  Pwd_spec = '!#$%&()=?@<>|{[]}/\*~+#;:.-_';
  Abs_engl: set of AnsiChar = ['a' .. 'z', 'A' .. 'Z'];
  Abs_rus: set of AnsiChar = ['а' .. 'Я', 'а' .. 'Я'];
  Abs_cifr: set of AnsiChar = ['0' .. '9'];
  Abs_hex: set of AnsiChar = ['a' .. 'e', 'A' .. 'E', '0' .. '9'];
  Abs_englUp: set of AnsiChar = ['A' .. 'Z'];
  Abs_rusUp: set of AnsiChar = ['А' .. 'Я'];
  Abs_englDown: set of AnsiChar = ['a' .. 'z'];
  Abs_rusDown: set of AnsiChar = ['а' .. 'я'];

  SHELL_FOLDERS_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\Explorer';
  QUICK_LAUNCH_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\GrpConv';

  Cifri: set of AnsiChar = ['0' .. '9'];

  Unusedchar: set of AnsiChar = ['''', '/', '|', '\', '<', '>', '"', '?', '*', ':'];
  Unusedchar_folders: set of AnsiChar = ['''', '/', '|', '<', '>', '"', '?', '*', ':'];
  Abs_alldb = ['0' .. '9', 'а' .. 'я', 'А' .. 'Я', 'ё', 'Ё', 'a' .. 'z', 'A' .. 'Z', '/', '|', '\', '<', '>', '''',
    '?', '*', ':'];

  Validchars: set of AnsiChar = ['a' .. 'z', 'A' .. 'Z', '[', ']', '-', '_', '!', ':', ';', '\', '/', '.', ',', ' ',
    '0' .. '9'];
  Validcharsmdb: set of AnsiChar = ['a' .. 'z', 'A' .. 'Z', '[', ']', '-', '_', '!', ':', ';', '\', '/', '.', ',', ' ',
    '0' .. '9', ' ', 'а' .. 'я', 'А' .. 'Я'];

const
  Db_access_private = 1;
  Db_access_none = 0;
  Db_attr_norm = 0;
  Db_attr_not_exists = 1;
  Db_attr_dublicate = 2;

const

  DB_IMAGE_ROTATED_0 = 0;
  DB_IMAGE_ROTATED_90 = 1;
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

type
  TOneRecordInfo = record
    ItemFileName: string;
    ItemCrypted: Boolean;
    ItemId: Integer;
    ItemImTh: string;
    ItemSize: Int64;
    ItemRotate: Integer;
    ItemRating: Integer;
    ItemAccess: Integer;
    ItemComment: string;
    ItemCollections: string;
    ItemGroups: string;
    ItemOwner: string;
    ItemKeyWords: string;
    ItemDate: TDateTime;
    ItemTime: TDateTime;
    ItemIsDate: Boolean;
    ItemIsTime: Boolean;
    ItemHeight: Integer;
    ItemWidth: Integer;
    ItemInclude: Boolean;
    Image: TJpegImage;
    Tag: Integer;
    PassTag: Integer;
    Loaded: Boolean;
    ItemLinks: string;
  end;

  TRecordsInfo = record
    ItemFileNames: TArStrings;
    ItemIds: TArInteger;
    ItemRotates: TArInteger;
    ItemRatings: TArInteger;
    ItemAccesses: TArInteger;
    ItemComments: TArStrings;
    ItemCollections: TArStrings;
    ItemGroups: TArStrings;
    ItemOwners: TArStrings;
    ItemKeyWords: TArStrings;
    ItemDates: TArDateTime;
    ItemTimes: TArTime;
    ItemIsDates: TArBoolean;
    ItemIsTimes: TArBoolean;
    ItemCrypted: TArBoolean;
    ItemInclude: TArBoolean;
    ItemLinks: TArStrings;
    Position: Integer;
    Tag: Integer;
    LoadedImageInfo: TArBoolean;
  end;

type
  TDBPopupMenuInfoRecord = class
  public
    FileName: string;
    Comment: string;
    FileSize: Int64;
    Rotation: Integer;
    Rating: Integer;
    ID: Integer;
    IsCurrent: Boolean;
    Selected: Boolean;
    Access: Integer;
    Date: TDateTime;
    Time: TDateTime;
    IsDate: Boolean;
    IsTime: Boolean;
    Groups: string;
    KeyWords: string;
    Crypted: Boolean;
    Attr: Integer;
    InfoLoaded: Boolean;
    Include: Boolean;
    Links: string; // ??? not for common use yet
    Exists: Integer; // for drawing in lists
    constructor CreateFromDS(DS: TDataSet);
    constructor CreateFromContRecord(ContRecord: TImageContRecord);
    constructor CreateFromSlideShowInfo(Info: TRecordsInfo; Position: Integer);
    constructor CreateFromSearchRecord(Info: TSearchRecord);
    constructor CreateFromExplorerInfo(Info: TExplorerFileInfo);
    constructor CreateFromRecordInfo(RI: TOneRecordInfo);
    function Copy : TDBPopupMenuInfoRecord;
  end;

type
  TDBPopupMenuInfo = class
  private
    FData: TList;
    FAttrExists: Boolean;
    FIsPlusMenu: Boolean;
    FIsListItem: Boolean;
    FListItem: TEasyItem;
    function GetValueByIndex(index: Integer): TDBPopupMenuInfoRecord;
    function GetCount: Integer;
    function GetIsVariousInclude: Boolean;
    function GetStatRating: Integer;
    function GetStatDate: TDateTime;
    function GetStatTime: TDateTime;
    function GetStatIsDate: Boolean;
    function GetStatIsTime: Boolean;
    function GetIsVariousDate: Boolean;
    function GetIsVariousTime: Boolean;
    function GetCommonKeyWords: string;
    function GetIsVariousComments: Boolean;
    function GetCommonGroups: string;
    function GetCommonLinks: TLinksInfo;
    function GetPosition: Integer;
    procedure SetPosition(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(MenuRecord: TDBPopupMenuInfoRecord);
    procedure Clear;
    property Items[index: Integer]: TDBPopupMenuInfoRecord read GetValueByIndex; default;
    property IsListItem: Boolean read FIsListItem write FIsListItem;
    property AttrExists: Boolean read FAttrExists write FAttrExists;
    property Count: Integer read GetCount;
    property IsVariousInclude: Boolean read GetIsVariousInclude;
    property IsVariousDate: Boolean read GetIsVariousDate;
    property IsVariousTime: Boolean read GetIsVariousTime;
    property IsVariousComments: Boolean read GetIsVariousComments;
    property StatRating: Integer read GetStatRating;
    property StatDate: TDateTime read GetStatDate;
    property StatTime: TDateTime read GetStatTime;
    property StatIsDate: Boolean read GetStatIsDate;
    property StatIsTime: Boolean read GetStatIsTime;
    property IsPlusMenu: Boolean read FIsPlusMenu write FIsPlusMenu;
    property CommonKeyWords: string read GetCommonKeyWords;
    property CommonGroups: string read GetCommonGroups;
    property CommonLinks: TLinksInfo read GetCommonLinks;
    property Position: Integer read GetPosition write SetPosition;
    property ListItem: TEasyItem read FListItem write FListItem;
    // TODO: +  PlusMenu : TArMenuitem;
    // TODO: +  IsListItem : boolean;
    // TODO: +  ListItem : TObject;
  end;

type
  TBuffer = array of Char;

type
  PCopyDataStruct = ^TCopyDataStruct;

  //TODO:!!!
  TCopyDataStruct = record
    DwData: LongInt;
    CbData: LongInt;
    LpData: Pointer;
  end;

  PRecToPass = ^TRecToPass;

  TRecToPass = packed record
    S: string[255];
    I: Integer;
  end;

type
  ShortcutType = (_DESKTOP, _QUICKLAUNCH, _SENDTO, _STARTMENU, _OTHERFOLDER, _PROGRAMS);

  THintRealFucntion = function(Item: TObject): Boolean of object;
  TPCharFunctionA = function(S: Pchar): PChar;
  TRemoteCloseFormProc = procedure(Form: TForm; ID: string) of object;
  TFileFoundedEvent = procedure(Owner: TObject; FileName: string; Size: Int64) of object;

  TSelectedInfo = record
    FileName: string;
    FileType: Integer;
    FileTypeW: string;
    KeyWords: string;
    CommonKeyWords: string;
    Rating: Integer;
    CommonRating: Integer;
    Comment: string;
    Groups: string;
    CommonComment: string;
    IsVariousComments: Boolean;
    IsVariousDates: Boolean;
    IsVariousTimes: Boolean;
    Size: Int64;
    Date: TDateTime;
    IsDate: Boolean;
    IsTime: Boolean;
    Time: TDateTime;
    Access: Integer;
    Id: Integer;
    Ids: TArInteger;
    One: Boolean;
    Width: Integer;
    Height: Integer;
    Nil_: Boolean;
    _GUID: TGUID;
    SelCount: Integer;
    Selected: TListItem;
    Links: string;
    IsVaruousInclude: Boolean;
    Include: Boolean;
  end;

  TImageDBRecordA = record
    IDs: array of Integer;
    FileNames: array of string;
    ImTh: string;
    Count: Integer;
    Attr: array of Integer;
    Jpeg: TJpegImage;
    OrWidth, OrHeight: Integer;
    Crypt: Boolean;
    Password: string;
    Size: Integer;
    UsedFileNameSearch: Boolean;
    ChangedRotate: array of Boolean;
    IsError: Boolean;
    ErrorText: string;
  end;

  TImageDBRecordAArray = array of TImageDBRecordA;

  TStringFunction = function: string;
  TIntegerFunction = function: Integer;
  TBooleanFunction = function: Boolean;
  TPcharFunction = function: Pchar;

  TDbFileInfoA = record
    ID: Integer;
    Rotated: Integer;
    Access: Integer;
    FileName: string;
    Comment: string;
  end;

  TAddFileInfo = record
    Rotate: Integer;
    Rating: Integer;
    Access: Integer;
    Comment: string;
    Owner: string;
    Collection: string;
    KeyWords: string;
  end;

  TAddFileInfoArray = array of TAddFileInfo;

type
  TDriveState = (DS_NO_DISK, DS_UNFORMATTED_DISK, DS_EMPTY_DISK, DS_DISK_WITH_FILES);

  TDllRegisterServer = function: HResult; stdcall;

const
  InstallType_Checked = 0;
  InstallType_UnChecked = 1;
  InstallType_Grayed = 2;

type
  TInstallExt = record
    Ext: string;
    InstallType: Integer;
  end;

  TInstallExts = array of TInstallExt;

const
  TA_UNKNOWN = 0;
  TA_NEEDS_TERMINATING = 1;
  TA_INFORM = 2;
  TA_INFORM_AND_NT = 3;

type
  TProcTerminating = record
    Proc: TNotifyEvent;
    Owner: TObject;
  end;

  TTemtinatedAction = record
    TerminatedPointer: PBoolean;
    TerminatedVerify: PBoolean;
    Options: Integer;
    Discription: string;
    Owner: TObject;
  end;

  TTemtinatedActions = array of TTemtinatedAction;

type
  TCallbackInfo = record
    Action: Byte;
    ForwardThread: Boolean;
    Direction: Boolean;
  end;

type
  TDirectXSlideShowCreatorCallBackResult = record
    Action: Byte;
    FileName: string;
    Result: Integer;
  end;

type
  TDirectXSlideShowCreatorCallBack = function(CallbackInfo: TCallbackInfo)
    : TDirectXSlideShowCreatorCallBackResult of object;

type
  TByteArr = array [0 .. 0] of Byte;
  PByteArr = ^TByteArr;

type
  TDirectXSlideShowCreatorInfo = record
    FileName: string;
    Rotate: Integer;
    CallBack: TDirectXSlideShowCreatorCallBack;
    FDirectXSlideShowReady: PBoolean;
    FDirectXSlideShowTerminate: PBoolean;
    DirectDraw4: IDirectDraw4;
    PrimarySurface: IDirectDrawSurface4;
    Offscreen: IDirectDrawSurface4;
    Buffer: IDirectDrawSurface4;
    Clpr: IDirectDrawClipper;
    BPP, RBM, GBM, BBM: Integer;
    TransSrc1, TransSrc2, TempSrc: PByteArr;
    SID: TGUID;
    Manager: TObject;
    Form: TForm;
  end;

type
  TUserMenuItem = record
    Caption: string;
    EXEFile: string;
    Params: string;
    Icon: string;
    UseSubMenu: Boolean;
  end;

  TUserMenuItemArray = array of TUserMenuItem;

  // Added in v2.0
type
  TPlaceFolder = record
    name: string;
    FolderName: string;
    Icon: string;
    MyComputer: Boolean;
    MyDocuments: Boolean;
    MyPictures: Boolean;
    OtherFolder: Boolean;
  end;

  TPlaceFolderArray = array of TPlaceFolder;

type
  TCorrectPathProc = procedure(Src: array of string; Dest: string) of object;

  // Added in 2.2 version

  TCallBackBigSizeProc = procedure(Sender: TObject; SizeX, SizeY: Integer) of object;

  TGistogrammData = record
    Gray: T255IntArray;
    Red: T255IntArray;
    Green: T255IntArray;
    Blue: T255IntArray;
    Loaded: Boolean;
    Max: Byte;
    LeftEffective: Byte;
    RightEffective: Byte;
  end;

const
  CSIDL_COMMON_APPDATA = $0023;
  CSIDL_MYMUSIC = $0013;
  CSIDL_MYPICTURES = $0014; // FONTS
  CSIDL_LOCAL = $0022;
  CSIDL_SYSTEM = $0025;
  CSIDL_WINDOWS = $0024;
  CSIDL_PROGRAM_FILES = $0026;
  CSIDL_LOCAL_APPDATA = $001C;

  // [BEGIN] Short install section oldest version
const
  // 1.75
  ProductName_1_75 = 'Photo DataBase 1.75';
  StartMenuProgramsPath_1_75 = 'Photo DB v1.75';
  ProductVersion_1_75 = '1.75';
  ProgramShortCutFile_1_75 = ProductName_1_75 + '.lnk';
  HelpShortCutFile_1_75 = TEXT_MES_HELP + '.lnk';
  // 1.8
  ProductName_1_8 = 'Photo DataBase 1.8';
  StartMenuProgramsPath_1_8 = 'Photo DB v1.8';
  ProductVersion_1_8 = '1.8';
  ProgramShortCutFile_1_8 = ProductName_1_8 + '.lnk';
  HelpShortCutFile_1_8 = TEXT_MES_HELP + '.lnk';
  // 1.9
  ProductName_1_9 = 'Photo DataBase 1.9';
  StartMenuProgramsPath_1_9 = 'Photo DB v1.9';
  ProductVersion_1_9 = '1.9';
  ProgramShortCutFile_1_9 = ProductName_1_9 + '.lnk';
  HelpShortCutFile_1_9 = TEXT_MES_HELP + '.lnk';

  // 2.0
  ProductName_2_0 = 'Photo DataBase 2.0';
  StartMenuProgramsPath_2_0 = 'Photo DB v2.0';
  ProductVersion_2_0 = '2.0';
  ProgramShortCutFile_2_0 = ProductName_2_0 + '.lnk';
  HelpShortCutFile_2_0 = TEXT_MES_HELP + '.lnk';

  // 2.1
  ProductName_2_1 = 'Photo DataBase 2.1';
  StartMenuProgramsPath_2_1 = 'Photo DB v2.1';
  ProductVersion_2_1 = '2.1';
  ProgramShortCutFile_2_1 = ProductName_2_1 + '.lnk';
  HelpShortCutFile_2_1 = TEXT_MES_HELP + '.lnk';
  // [END]

var
  RAWImages: string = 'CR2|';
  TempRAWMask: string = '|THUMB|JPG|TIFF|PBB|';
  SupportedExt : String = '|BMP|JFIF|JPG|JPE|JPEG|RLE|DIB|WIN|VST|VDA|TGA|ICB|TIFF|TIF|FAX|EPS|PCC|PCX|RPF|RLA|SGI|RGBA|RGB|BW|PSD|PDD|PPM|PGM|PBM|CEL|PIC|PCD|GIF|CUT|PSP|PNG|THM|';

const
  DBID = '{E1446065-CB87-440D-9315-6FA356F921B6}'; // B5
  DBBeginInstallID = '{A8C9FD9D-C2F6-4B1C-9164-11E6075FD527}';
  DBEndInstallID = '{C5348907-0AD6-4D02-8E0D-4063057B652F}';
  ReleaseNumber = 12;
  DemoSecondsToOpen = 5;
  MultimediaBaseFiles = '|MOV|MP3|AVI|MPEG|MPG|WAV|';
  FilesCount = 10;
  FileList: array [0 .. FilesCount - 1] of string = ('Kernel.dll', 'Licence.txt', 'Scripts', 'Tools.exe', 'Help',
    'lpng-px.dll', 'FreeImage.dll', 'icons.dll', 'Actions', 'Images');
  FileOptions: array [0 .. FilesCount - 1] of Boolean = (True, True, True, True, True, True, True, True, True, True);
  InstallFileNeeds: array [0 .. FilesCount - 1] of Boolean = (True, False, True, True, False, False, True, True, False,
    False);
  DBFilesExt: array [0 .. 1] of string = ('MDB', 'PHOTODB');
  RetryTryCountOnWrite = 10;
  RetryTryDelayOnWrite = 100;
  CurrentDBSettingVersion = 1;
  UseSimpleSelectFolderDialog = False;

var
  // Image sizes
  // In FormManager this sizes loaded from DB
  DBJpegCompressionQuality: Integer = 75;
  ThSize: Integer = 152;
  ThSizeExplorerPreview: Integer = 100;
  ThSizePropertyPreview: Integer = 100;
  ThSizePanelPreview: Integer = 75;
  ThImageSize: Integer = 150;
  ThHintSize: Integer = 300;
  ProcessorCount: Integer = 0;

resourcestring
  SNotSupported = 'This function is not supported by your version of Windows';

var
  DBName: string;
  Theme_ListSelectColor, Theme_MainColor, Theme_MainFontColor, Theme_ListColor, Theme_ListFontColor,
    Theme_MemoEditColor, Theme_MemoEditFontColor, Theme_LabelFontColor, Theme_ProgressBackColor,
    Theme_ProgressFontColor, Theme_ProgressFillColor: TColor;

  DBKernel: TDBKernel = nil;
  ResultLogin: Boolean;
  KernelHandle: THandle;
  DBTerminating: Boolean = False;
  HelpNO: Integer = 0;
  HelpActivationNO: Integer = 0;
  FExtImagesInImageList: Integer;
  LastInseredID: Integer;
  CopyFilesSynchCount: Integer = 0;
  FolderView: Boolean = False;
  DBLoadInitialized: Boolean = False;
  FThisFileInstalled: Integer = -1;
  GraphicFilterString: string;

function ActivationID: string;
function GetImageIDW(Image: string; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False; AThImageSize: Integer = 0;
  ADBJpegCompressionQuality: Byte = 0): TImageDBRecordA;
function GetImageIDWEx(Images: TArStrings; UseFileNameScanning: Boolean;
  OnlyImTh: Boolean = False): TImageDBRecordAArray;

function GetImageIDTh(ImageTh: string): TImageDBRecordA;
procedure SetPrivate(ID: Integer);
procedure UnSetPrivate(ID: Integer);

function SizeInTextA(Size: Int64): string;
procedure UpdateDeletedDBRecord(ID: Integer; FileName: string);
procedure UpdateMovedDBRecord(ID: Integer; FileName: string);

procedure SetRotate(ID, Rotate: Integer);
procedure SetRating(ID, Rating: Integer);
procedure SetAttr(ID, Attr: Integer);
function GetHardwareString: string;
function XorStrings(S1, S2: string): string;
function SetStringToLengthWithNoData(S: string; N: Integer): string;
function BitmapToString(Bit: Tbitmap): string;
function Delnakl(S: string): string;
function GetIdByFileName(FileName: string): Integer;
function GetFileNameById(ID: Integer): string;
function SaveIDsTofile(FileName: string; IDs: TArInteger): Boolean;
function LoadIDsFromfile(FileName: string): string;
function LoadIDsFromfileA(FileName: string): TArInteger;

function LoadImThsFromfileA(FileName: string): TArStrings;
function SaveImThsTofile(FileName: string; ImThs: TArstrings): Boolean;

function NormalizeDBString(S: string): string;
function HardwareStringToCode(Hs: string): string;
function CodeToActivateCode(S: string): string;
function GetuserString: string;
function RenameFileWithDB(OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;
function GetGUID: TGUID;
procedure GetFileListByMask(BeginFile, Mask: string;
  { var list : tstrings; } out Info: TRecordsInfo; var N: Integer; ShowPrivate: Boolean);
function AltKeyDown: Boolean;
function CtrlKeyDown: Boolean;
function ShiftKeyDown: Boolean;
procedure JPEGScale(Graphic: TGraphic; Width, Height: Integer);

{ DB Types }
function RecordInfoOne(name: string; ID, Rotate, Rating, Access: Integer; Size: Int64;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; Isdate, IsTime: Boolean; Time: TTime;
  Crypt, Include, Loaded: Boolean; Links: string): TOneRecordInfo;
function RecordsInfoFromArrays(Names: TArstrings; IDs, Rotates, Ratings, Accesss: TArInteger;
  Comments, KeyWords, Groups: TArstrings; Dates: TArDateTime; IsDates, IsTimes: TArBoolean; Times: TArTime;
  Crypt, Loaded, Include: TArBoolean; Links: TArStrings): TRecordsInfo;
function RecordInfoOneA(name: string; ID, Rotate, Rating, Access, Size: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt: Boolean; Tag: Integer; Include: Boolean; Links: string): TOneRecordInfo;
procedure AddRecordsInfoOne(var D: TRecordsInfo; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt, Loaded, Include: Boolean; Links: string);
procedure SetRecordsInfoOne(var D: TRecordsInfo; N: Integer; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TDateTime; Crypt, Include: Boolean;
  Links: string);
function RecordsInfoOne(name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; Isdate, IsTime: Boolean;
  Time: TDateTime; Crypt, Loaded, Include: Boolean; Links: string): TRecordsInfo;
function GetRecordsFromOne(Info: TOneRecordInfo): TRecordsInfo;
function GetRecordFromRecords(Info: TRecordsInfo; N: Integer): TOneRecordInfo;
procedure SetRecordToRecords(Info: TRecordsInfo; N: Integer; Rec: TOneRecordInfo);
procedure CopyRecordsInfo(var S, D: TRecordsInfo);
function RecordsInfoNil: TRecordsInfo;
procedure AddToRecordsInfoOneInfo(var Infos: TRecordsInfo; Info: TOneRecordInfo);
procedure DBPopupMenuInfoToRecordsInfo(var DBP: TDBPopupMenuInfo; var RI: TRecordsInfo);
function GetInfoByFileNameA(FileName: string; LoadThum: Boolean; var Info: TOneRecordInfo): Boolean;
function GetMenuInfoByID(ID: Integer): TDBPopupMenuInfo;
function GetMenuInfoByStrTh(StrTh: string): TDBPopupMenuInfo;
{ END DB Types }
function NormalizeDBStringLike(S: string): string;
procedure ShowPropertiesDialog(FName: string);
function MrsGetFileType(StrFilename: string): string;
procedure CopyFiles(Handle: Hwnd; Src: array of string; Dest: string; Move: Boolean; AutoRename: Boolean;
  CallBack: TCorrectPathProc = nil; ExplorerForm: TForm = nil);
function DeleteFiles(Handle: HWnd; Names: array of string; ToRecycle: Boolean): Integer;
function GetCDVolumeLabel(CDName: Char): string;
function DriveState(Driveletter: AnsiChar): TDriveState;
procedure ShowMyComputerProperties(Hwnd: THandle);
function KillTask(ExeFileName: string): Integer;
procedure LoadNickJpegImage(Image: TImage);
procedure DoHelp;
procedure DoGetCode(S: string);
function SilentDeleteFiles(Handle: HWnd; Names: array of string; ToRecycle: Boolean;
  HideErrors: Boolean = False): Integer;

{ Setup section }
function InstalledUserName: string;
function IsInstalledApplication: Boolean;
function RegInstallApplication(Filename, DBName, UserName: string): Boolean;
function ExtInstallApplication(Filename: string): Boolean;
function ExtInstallApplicationW(Exts: TInstallExts; Filename: string): Boolean;
function ExtUnInstallApplicationW: Boolean;
function IsNewVersion: Boolean;
function ThisFileInstalled: Boolean;
function DeleteRegistryEntries: Boolean;
procedure DoBeginInstall;
procedure DoEndInstall;
function IsInstalling: Boolean;
function InstalledDirectory: string;
function InstalledFileName: string;
function FileRegisteredOnInstalledApplication(Value: string): Boolean;
procedure GetValidMDBFilesInFolder(Dir: string; Init: Boolean; Res: TStrings);
function GetDefaultDBName: string;

function GetDirectorySize(Folder: string): Int64;

function ExtractAssociatedIcon_(FileName: string): HICON;
function ExtractAssociatedIcon_W(FileName: string; IconIndex: Word): HICON;

procedure DoHomeContactWithAuthor;
procedure DoHomePage;
procedure UpdateImageRecord(FileName: string; ID: Integer);
procedure UpdateImageRecordEx(FileName: string; ID: Integer; OnDBKernelEvent: TOnDBKernelEventProcedure);
procedure SetDesktopWallpaper(FileName: string; WOptions: Byte);

procedure RotateDBImage270(ID: Integer; OldRotation: Integer);
procedure RotateDBImage90(ID: Integer; OldRotation: Integer);
procedure RotateDBImage180(ID: Integer; OldRotation: Integer);

procedure DBError(ErrorValue, Error: string);

function GetExt(Filename: string): string;
function GetFileSizeByName(FileName: string): Int64;
function LongFileName(ShortName: string): string;
function LongFileNameW(ShortName: string): string;
function GetUserSID: PSID;
function SidToStr(Sid: PSID): WideString;
function GetDirectory(FileName: string): string;
function ExtinMask(Mask: string; Ext: string): Boolean;

function GetFileNameWithoutExt(Filename: string): string;
function GetFileSize(FileName: string): Int64;
// function GetCPUSpeed(interval:integer):real;

function CompareImages(Image1, Image2: TGraphic; var Rotate: Integer; FSpsearch_ScanFileRotate: Boolean = True;
  Quick: Boolean = False; Raz: Integer = 60): TImageCompareResult;
function GetIdeDiskSerialNumber: string;
procedure Delay(Msecs: Longint);
function ColorDiv2(Color1, COlor2: TColor): TColor;
function ColorDarken(Color: TColor): TColor;

function CreateDirA(Dir: string): Boolean;
function ValidDBPath(DBPath: string): Boolean;
function CopyFilesSynch(Handle: Hwnd; Src: array of string; Dest: string; Move: Boolean; AutoRename: Boolean): Integer;
function CreateProgressBar(StatusBar: TStatusBar; index: Integer): TProgressBar;

var
  Findleft: Integer;
  I: Integer;
procedure LoadDblFromfile(FileName: string; var IDs: TArInteger; var Files: TArStrings);
function SaveListTofile(FileName: string; IDs: TArInteger; Files: TArStrings): Boolean;
function IsWallpaper(FileName: string): Boolean;
procedure LoadFIlesFromClipBoard(var Effects: Integer; Files: TStrings);
procedure Copy_Move(Copy: Boolean; FileList: TStrings);
function GetProgramFilesDir: string;
procedure Deldir(Dir: string; Mask: string);
function Mince(PathToMince: string; InSpace: Integer): string;
function WindowsCopyFile(FromFile, ToDir: string): Boolean;
function WindowsCopyFileSilent(FromFile, ToDir: string): Boolean;
function CreateShortcutW(SourceFileName, ShortcutName: string; // the file the shortcut points to
  Location: ShortcutType; // shortcut location
  SubFolder, // subfolder of location
  WorkingDir, // working directory property of the shortcut
  Parameters, Description: string): // description property of the shortcut
  string;
procedure HideFromTaskBar(Handle: Thandle);
function RandomPwd(PWLen: Integer; StrTable: string): string;
procedure Del_Close_btn(Handle: Thandle);
procedure DoUpdateHelp;
function GetProcessMemory: Integer;
function ChangeIconDialog(HOwner: THandle; var FileName: string; var IconIndex: Integer): Boolean;
function GetProgramPath: string;
procedure SelectDB(DB: string);
procedure CopyFullRecordInfo(ID: Integer);

function LoadActionsFromfileA(FileName: string): TArStrings;

function SaveActionsTofile(FileName: string; Actions: TArstrings): Boolean;
procedure RenameFolderWithDB(OldFileName, NewFileName: string; Ask: Boolean = True);
function GetDBViewMode: Boolean;
function GetDBFileName(FileName, DBName: string): string;
// procedure CompareStrThs(Th1, Th2 : string);
function DBReadOnly: Boolean;
function StringCRC(Str: string): Cardinal;
function AnsiCompareTextWithNum(Text1, Text2: string): Integer;
function DateModify(FileName: string): TDateTime;

function GettingProcNum: Integer; // Win95 or later and NT3.1 or later
function GetWindowsUserName: string;
procedure GetPhotosNamesFromDrive(Dir, Mask: string; var Files: TStrings; var MaxFilesCount: Integer;
  MaxFilesSearch: Integer; CallBack: TCallBackProgressEvent = nil);
function EXIFDateToDate(DateTime: string): TDateTime;
function EXIFDateToTime(DateTime: string): TDateTime;

function MessageBoxDB(Handle: THandle; AContent, Title, ADescription: string; Buttons, Icon: Integer): Integer;
  overload;
function MessageBoxDB(Handle: THandle; AContent, Title: string; Buttons, Icon: Integer): Integer; overload;

procedure TextToClipboard(const S: string);
function GetActiveFormHandle: Integer;
function GetGraphicFilter: string;
function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
procedure ExecuteQuery(SQL: string);
function ReadTextFileInString(FileName: string): string;
function CompareImagesByGistogramm(Image1, Image2: TBitmap): Byte;
procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
function CenterPos(W1, W2: Integer): Integer;

var
  GetAnyValidDBFileInProgramFolderCounter: Integer;

implementation

uses UnitPasswordForm, UnitWindowsCopyFilesThread,
  CommonDBSupport, uActivation, UnitInternetUpdate, UnitManageGroups, uAbout,
  UnitUpdateDB, Searching, ManagerDBUnit, ProgressActionUnit, UnitINI,
  UnitDBCommonGraphics, UnitCDMappingSupport, UnitGroupsWork, CmpUnit;

function CenterPos(W1, W2: Integer): Integer;
begin
  Result := W1 div 2 - W2 div 2;
end;

function GetDBFileName(FileName, DBName: string): string;
begin
  Result := FileName;
  if Length(FileName) > 2 then
    if FileName[2] <> ':' then
      Result := GetDirectory(DBName) + FileName;
end;

function DBReadOnly: Boolean;
var
  Attr: Integer;
begin
  Result := False;
  if FileExists(GetDirectory(ParamStr(0)) + 'FolderDB.photodb') then
  begin
    Attr := Windows.GetFileAttributes(PChar(GetDirectory(ParamStr(0)) + 'FolderDB.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      Result := True;
  end;

  if FileExists(GetDirectory(ParamStr(0)) + AnsiLowerCase(GetFileNameWithoutExt(ParamStr(0))) + '.photodb') then
  begin
    Attr := Windows.GetFileAttributes
      (PChar(GetDirectory(ParamStr(0)) + AnsiLowerCase(GetFileNameWithoutExt(ParamStr(0))) + '.photodb'));
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      Result := True;
  end;
end;

function GetDBViewMode: Boolean;
begin
  Result := False;
  if not DBInDebug then
    if not ThisFileInstalled then
      if FileExists(GetDirectory(ParamStr(0)) + 'FolderDB.photodb') or FileExists
        (GetDirectory(ParamStr(0)) + AnsiLowerCase(GetFileNameWithoutExt(ParamStr(0))) + '.photodb') or FileExists
        (GetDirectory(ParamStr(0)) + AnsiLowerCase(GetFileNameWithoutExt(ParamStr(0))) + '.mdb') then
        Result := True;
end;

function FilePathCRC(FileName: string): Cardinal;
var
  Folder: string;
begin
  Folder := GetDirectory(FileName);
  UnFormatDir(Folder);
  CalcStringCRC32(AnsiLowerCase(Folder), Result);
end;

function StringCRC(Str: string): Cardinal;
begin
  Result := 0;
  CalcStringCRC32(Str, Result);
end;

function GetProcessMemory: Integer;
var
  Pmc: PPROCESS_MEMORY_COUNTERS;
  Cb: Integer;
begin
  Cb := SizeOf(_PROCESS_MEMORY_COUNTERS);
  GetMem(Pmc, Cb);
  Pmc^.Cb := Cb;
  if GetProcessMemoryInfo(GetCurrentProcess(), Pmc, Cb) then
    Result := Pmc^.WorkingSetSize
  else
    Result := 0;
  FreeMem(Pmc);
end;

function GetFileSize(FileName: string): Int64;
var
  FS: TFileStream;
begin
  try
{$I-}
    FS := TFileStream.Create(Filename, FmOpenRead or FmShareDenyNone);
{$I+}
  except
    Result := -1;
    Exit;
  end;
  Result := FS.Size;
  FS.Free;
end;

function GetFileSizeByName(FileName: string): Int64;
var
  FindData: TWin32FindData;
  HFind: THandle;
begin
  Result := 0;
  HFind := FindFirstFile(PChar(FileName), FindData);
  if HFind <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(HFind);
    if (FindData.DwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := FindData.NFileSizeHigh * 2 * MaxInt + FindData.NFileSizeLow;
  end;
end;

function LongFileName(ShortName: string): string;
var
  SR: TSearchRec;
begin
  Result := '';
  if (Pos('\\', ShortName) + Pos('*', ShortName) + Pos('?', ShortName) <> 0) or
    (not FileExists(ShortName) and not DirectoryExists(ShortName)) or (Length(ShortName) < 4) then
  begin
    Result := ShortName;
    Exit;
  end;
  if Pos('~1', ShortName) = 0 then
  begin
    Result := ShortName;
    Exit;
  end;
  while FindFirst(ShortName, FaAnyFile, SR) = 0 do
  begin
    { next part as prefix }
    Result := '\' + SR.name + Result;
    SysUtils.FindClose(SR); { the SysUtils, not the WinProcs procedure! }
    { directory up (cut before '\') }
    ShortName := ExtractFileDir(ShortName);
    if Length(ShortName) <= 2 then
    begin
      Break; { ShortName contains drive letter followed by ':' }
    end;
  end;
  Result := AnsiUpperCase(ExtractFileDrive(ShortName)) + Result;
end;

function LongFileNameW(ShortName: string): string;
var
  SR: TSearchRec;
begin
  Result := '';
  if (Pos('\\', ShortName) + Pos('*', ShortName) + Pos('?', ShortName) <> 0) or
    (not FileExists(ShortName) and not DirectoryExists(ShortName)) or (Length(ShortName) < 4) then
  begin
    Result := ShortName;
    Exit;
  end;
  while FindFirst(ShortName, FaAnyFile, SR) = 0 do
  begin
    { next part as prefix }
    Result := '\' + SR.name + Result;
    SysUtils.FindClose(SR); { the SysUtils, not the WinProcs procedure! }
    { directory up (cut before '\') }
    ShortName := ExtractFileDir(ShortName);
    if Length(ShortName) <= 2 then
    begin
      Break; { ShortName contains drive letter followed by ':' }
    end;
  end;
  Result := AnsiUpperCase(ExtractFileDrive(ShortName)) + Result;
end;

function GetUserSID: PSID;
type
  PTOKEN_USER = ^TOKEN_USER;

  _TOKEN_USER = record
    User: TSidAndAttributes;
  end;

  TOKEN_USER = _TOKEN_USER;
var
  HToken: THandle;
  CbBuf: Cardinal;
  PtiUser: PTOKEN_USER;
begin
  Result := nil;
  if not OpenThreadToken(GetCurrentThread(), TOKEN_QUERY, True, HToken) then
  begin
    if GetLastError() <> ERROR_NO_TOKEN then
      Exit;
    // В случее ошибки - получаем маркер доступа нашего процесса.
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, HToken) then
      Exit;
  end;
  // Вывываем GetTokenInformation для получения размера буфера
  if not GetTokenInformation(HToken, TokenUser, nil, 0, CbBuf) then
    if GetLastError() <> ERROR_INSUFFICIENT_BUFFER then
    begin
      CloseHandle(HToken);
      Exit;
    end;
  if CbBuf = 0 then
    Exit;
  // Выделяем память под буфер
  GetMem(PtiUser, CbBuf);
  // В случае удачного вызова получим указатель на TOKEN_USER
  if GetTokenInformation(HToken, TokenUser, PtiUser, CbBuf, CbBuf) then
    Result := PtiUser.User.Sid;
end;

function SidToStr(Sid: PSID): WideString;
var
  SIA: PSidIdentifierAuthority;
  DwCount: Cardinal;
  I: Integer;
begin
  // S-R-I-S-S...
  Result := '';
  // Проверяем SID
  if not IsValidSid(Sid) then
    Exit;
  Result := 'S-'; // Префикс
  // Получаем номер версии SID
  // Хотя работать на прямую с SID, как я уже говорил, не рекомендуется
  Result := Result + IntToStr(Byte(Sid^)) + '-';
  // Получаем орган, выдавший SID
  // Пока все находится в последнем байте
  Sia := GetSidIdentifierAuthority(Sid);
  Result := Result + IntToStr(Sia.Value[5]); // S-R-I-
  // кол-во RID
  DwCount := GetSidSubAuthorityCount(Sid)^;
  // и теперь перебираем их
  for I := 0 to DwCount - 1 do
    Result := Result + '-' + IntToStr(GetSidSubAuthority(Sid, I)^);
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

procedure GetValidMDBFilesInFolder(Dir: string; Init: Boolean; Res: TStrings);
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  if Init then
    GetAnyValidDBFileInProgramFolderCounter := 0;
  FormatDir(Dir);
  Found := FindFirst(Dir + '*.photodb', FaAnyFile, SearchRec);
  while Found = 0 do
  begin
    if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
    begin
      if Fileexists(Dir + SearchRec.name) then
      begin
        Inc(GetAnyValidDBFileInProgramFolderCounter);
        if GetAnyValidDBFileInProgramFolderCounter > 1000 then
          Break;
        if DBKernel.TestDB(Dir + SearchRec.name) then
        begin
          Res.Add(Dir + SearchRec.name)
        end;
      end
      else if Directoryexists(Dir + SearchRec.name) then
      begin
        GetValidMDBFilesInFolder(Dir + SearchRec.name, False, Res);
      end;
    end;
    Found := Sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

function InstalledFileName: string;
var
  FReg: TBDRegistry;
begin
  Result := '';
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    Result := FReg.ReadString('DataBase');
    if PortableWork then
      if Result <> '' then
        Result[1] := Application.Exename[1];
  except
  end;
  FReg.Free;
end;

function InstalledUserName: string;
var
  Reg: TBDRegistry;
begin
  Reg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    Reg.OpenKey(RegRoot, True);
    Result := Reg.ReadString('DBUserName');
  finally
    Reg.Free;
  end;
end;

function InstalledDirectory: string;
begin
  Result := ExtractFileDir(InstalledFileName);
end;

function IsInstalling: Boolean;
var
  HSemaphore: THandle;
begin
  Result := False;
  HSemaphore := CreateSemaphore(nil, 0, 1, PWideChar(DBBeginInstallID));
  if ((HSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    Result := True;
    HSemaphore := CreateSemaphore(nil, 0, 1, PWideChar(DBEndInstallID));
    if ((HSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
    begin
      Result := False;
    end;
    CloseHandle(HSemaphore);
  end;
  CloseHandle(HSemaphore);
end;

procedure DoBeginInstall;
begin
  CreateSemaphore(nil, 0, 1, PWideChar(DBBeginInstallID));
end;

procedure DoEndInstall;
begin
  CreateSemaphore(nil, 0, 1, PWideChar(DBEndInstallID));
end;

function IsNewVersion: Boolean;
var
  FReg: TBDRegistry;
  F: TIntegerFunction;
  H: Thandle;
  ProcH: Pointer;
  FileName: string;
begin
  Result := False;
  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    FileName := FReg.ReadString('DataBase');
    if PortableWork then
      if FileName <> '' then
        FileName[1] := Application.Exename[1];
    if FileExists(FileName) then
    begin
      H := LoadLibrary(PWideChar(FileName));
      if H <> 0 then
      begin
        ProcH := GetProcAddress(H, 'FileVersion');
        if ProcH <> nil then
        begin
          @F := ProcH;
          if F > ReleaseNumber then
            Result := True;
        end;
        FreeLibrary(H);
      end;
    end;
  except
  end;
  FReg.Free;
end;

function ThisFileInstalled: Boolean;
begin
  Result := AnsiUpperCase(ExtractFileName(Application.ExeName)) <> 'SETUP.EXE';
end;

function IsInstalledApplication: Boolean;
var
  FReg: TBDRegistry;
  F: TBooleanFunction;
  H: Thandle;
  ProcH: Pointer;
  FileName: string;
begin
  Result := False;
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    FileName := AnsiLowerCase(Freg.ReadString('DataBase'));
    if PortableWork then
      if FileName <> '' then
        FileName[1] := Application.ExeName[1];
    if FileExists(FileName) then
    begin
      H := Loadlibrary(PWideChar(FileName));
      if H <> 0 then
      begin
        ProcH := GetProcAddress(H, 'IsFalidDBFile');
        if ProcH <> nil then
        begin
          @F := ProcH;
          if F then
            if FileExists(GetDirectory(FileName) + '\Kernel.dll') then
              Result := True;
        end;
        FreeLibrary(H);
      end;
    end;
  except
    on E: Exception do
      EventLog(':IsInstalledApplication() throw exception: ' + E.message);
  end;
  FReg.Free;
end;

function DeleteRegistryEntries: Boolean;
var
  Freg: TRegistry;
begin
  Result := False;
  Freg := Tregistry.Create;
  try
    Freg.RootKey := Windows.HKEY_CLASSES_ROOT;
    Freg.DeleteKey('\.photodb');
    Freg.DeleteKey('\PhotoDB.PhotodbFile\');
    Freg.DeleteKey('\.ids');
    Freg.DeleteKey('\PhotoDB.IdsFile\');
    Freg.DeleteKey('\.dbl');
    Freg.DeleteKey('\PhotoDB.DblFile\');
    Freg.DeleteKey('\.ith');
    Freg.DeleteKey('\PhotoDB.IthFile\');
    Freg.DeleteKey('\Directory\Shell\PhDBBrowse\');
    Freg.DeleteKey('\Drive\Shell\PhDBBrowse\');
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
      Freg.Free;
    end;
  end;
  FReg.Free;
  FReg := Tregistry.Create;
  try
    FReg.RootKey := HKEY_INSTALL;
    FReg.DeleteKey(RegRoot);
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries()/HKEY_INSTALL throw exception: ' + E.message);
      FReg.Free;
    end;
  end;
  FReg.Free;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_USER_WORK;
    FReg.DeleteKey(RegRoot);
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries()/HKEY_USER_WORK throw exception: ' + E.message);
      FReg.Free;
    end;
  end;
  FReg.Free;
  FReg := Tregistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase');
    Result := True;
  except
    on E: Exception do
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
  end;
  FReg.Free;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler');
    FReg.DeleteKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler');
    FReg.OpenKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    FReg.DeleteValue('PhotoDBgetPhotosHandler');
    Result := True;
  except
    on E: Exception do
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
  end;
  FReg.Free;
end;

function GetDefaultDBName: string;
var
  Reg: TBDRegistry;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot, True);
    Result := Reg.ReadString('DBDefaultName');
  except
  end;
  Reg.Free;
end;

function RegInstallApplication(FileName, DBName, UserName: string): Boolean;
var
  Freg: TBDRegistry;
begin
  Result := False;
  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey(RegRoot, True);
    Freg.WriteString('ReleaseNumber', IntToStr(ReleaseNumber));
    Freg.WriteString('DataBase', Filename);
    Freg.WriteString('Folder', GetDirectory(Filename));
    Freg.WriteString('DBDefaultName', DBName);
    Freg.WriteString('DBUserName', UserName);
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Freg.Free;
      Exit;
    end;
  end;
  Freg.Free;

  if PortableWork then
    Exit;

  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase', True);
    Freg.WriteString('UninstallString', '"' + Filename + '"' + ' /uninstall');
    Freg.WriteString('DisplayName', 'Photo DataBase');
    Freg.WriteString('DisplayVersion', ProductVersion);
    Freg.WriteString('HelpLink', HomeURL);
    Freg.WriteString('Publisher', CopyRightString);
    Freg.WriteString('URLInfoAbout', 'MailTo:' + ProgramMail);
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Freg.Free;
      Exit;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.OpenKey('\.photodb', True);
    Freg.WriteString('', 'PhotoDB.PhotodbFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.PhotodbFile', True);
    Freg.OpenKey('\PhotoDB.PhotodbFile\DefaultIcon', True);
    Freg.WriteString('', FileName + ',0');
    Result := True;
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.OpenKey('\.ids', True);
    Freg.WriteString('', 'PhotoDB.IdsFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.IdsFile', True);
    Freg.OpenKey('\PhotoDB.IdsFile\DefaultIcon', True);
    Freg.WriteString('', FileName + ',0');
    Freg.OpenKey('\PhotoDB.IdsFile\Shell\Open\Command', True);
    Freg.WriteString('', '"' + GetDirectory(FileName) + 'PhotoDB.exe" "%1"');
    Result := True;
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.CloseKey;
    Freg.OpenKey('\.dbl', True);
    Freg.WriteString('', 'PhotoDB.dblFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.dblFile', True);
    Freg.OpenKey('\PhotoDB.dblFile\DefaultIcon', True);
    Freg.WriteString('', FileName + ',0');
    Freg.OpenKey('\PhotoDB.dblFile\Shell\Open\Command', True);
    Freg.WriteString('', '"' + GetDirectory(FileName) + 'PhotoDB.exe" "%1"');
    Result := True;
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.CloseKey;
    Freg.OpenKey('\.ith', True);
    Freg.Writestring('', 'PhotoDB.IthFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.IthFile', True);
    Freg.OpenKey('\PhotoDB.IthFile\DefaultIcon', True);
    Freg.Writestring('', FileName + ',0');
    Freg.OpenKey('\PhotoDB.IthFile\Shell\Open\Command', True);
    Freg.Writestring('', '"' + Getdirectory(FileName) + 'PhotoDB.exe" "%1"');
    Result := True;
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;

  Freg.Free;
  // Adding Handler for removable drives
  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey
      ('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler', True);
    Freg.WriteString('Action', TEXT_MES_GET_PHOTOS);
    Freg.WriteString('DefaultIcon', FileName + ',0');
    Freg.WriteString('InvokeProgID', 'PhotoDB.AutoPlayHandler');
    Freg.WriteString('InvokeVerb', 'Open');
    Freg.WriteString('Provider', 'Photo DataBase ' + ProductVersion);
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    Freg.WriteString('PhotoDBGetPhotosHandler', '');
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey('\SOFTWARE\Classes', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open\Command', True);
    Freg.WriteString('', '"' + GetDirectory(Filename) + 'PhotoDB.exe" "/GETPHOTOS" "%1"');
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;
end;

function FileRegisteredOnInstalledApplication(Value: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Length(Value) downto 2 do
    if (Value[I - 1] = '%') and (Value[I] = '1') then
    begin
      Delete(Value, I - 1, 2);
    end;
  for I := Length(Value) downto 1 do
    if Value[I] = '"' then
      Delete(Value, I, 1);
  for I := Length(Value) downto 1 do
    if Value[I] = ' ' then
      Delete(Value, I, 1)
    else
      Break;
  if AnsiLowerCase(Value) = AnsiLowerCase(GetDirectory(InstalledFileName) + 'PhotoDB.exe') then
    Result := True;
end;

function ExtInstallApplicationW(Exts: TInstallExts; Filename: string): Boolean;
var
  Reg: TRegistry;
  I: Integer;
  S: string;
  B, C: Boolean;

  procedure DeleteExtInfo(Ext: string);
  var
    FReg: TRegistry;
  begin
    FReg := TRegistry.Create;
    try
      FReg.RootKey := Windows.HKEY_CURRENT_USER;
      FReg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.' + Ext);
    finally
      FReg.Free;
    end;
  end;

begin
  Result := False;
  Reg := TRegistry.Create;
  Reg.RootKey := Windows.HKEY_CLASSES_ROOT;
  for I := 0 to Length(Exts) - 1 do
  begin
    case Exts[I].InstallType of
      InstallType_Checked:
        begin
          Reg.OpenKey('\.' + Exts[I].Ext, True);
          S := Reg.ReadString('');
          Reg.CloseKey;
          B := False;
          if S = '' then
            B := True;
          if not B then
          begin
            Reg.OpenKey('\' + S + '\Shell\Open\Command', False);
            if Reg.ReadString('') <> '' then
              B := False
            else
              B := True;
            Reg.CloseKey;
          end;
          if B then
          begin
            Reg.OpenKey('\.' + Exts[I].Ext, True);
            Reg.WriteString('', 'PhotoDB.' + Exts[I].Ext);
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\Open\Command', True);
            Reg.WriteString('', '"' + GetDirectory(FileName) + 'PhotoDB.exe" "%1"');
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\DefaultIcon', True);
            Reg.WriteString('', '' + GetDirectory(Filename) + 'PhotoDB.exe,0');
            Reg.CloseKey;
            DeleteExtInfo(Exts[I].Ext);
          end
          else
          begin
            Reg.OpenKey('\.' + Exts[I].Ext, True);
            S := Reg.ReadString('');
            Reg.WriteString('PhotoDB_PreviousAssociation', S);
            Reg.WriteString('', 'PhotoDB.' + Exts[I].Ext);
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\Open\Command', True);
            Reg.WriteString('', '"' + GetDirectory(Filename) + 'PhotoDB.exe" "%1"');
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\DefaultIcon', True);
            Reg.WriteString('', '' + GetDirectory(Filename) + 'PhotoDB.exe,0');
            Reg.CloseKey;
            DeleteExtInfo(Exts[I].Ext);
          end;
        end;
      InstallType_Grayed:
        begin
          Reg.OpenKey('\.' + Exts[I].Ext, True);
          S := Reg.ReadString('');
          Reg.CloseKey;
          C := False;
          B := True;
          if S = '' then
            C := True;
          if not C then
          begin
            Reg.OpenKey('\' + S + '\Shell\Open\Command', False);
            if Reg.ReadString('') <> '' then
              B := False
            else
              B := True;
            Reg.CloseKey;
          end;
          if B then
          begin
            Reg.OpenKey('\.' + Exts[I].Ext, True);
            Reg.WriteString('', 'PhotoDB.' + Exts[I].Ext);
            Reg.CloseKey;
          end;
          if B then
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\PhotoDBView', True)
          else
            Reg.OpenKey('\' + S + '\Shell\PhotoDBView', True);
          Reg.WriteString('', TEXT_MES_VIEW_WITH_DB);
          Reg.CloseKey;
          if B then
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\PhotoDBView\Command', True)
          else
            Reg.OpenKey('\' + S + '\Shell\PhotoDBView\Command', True);
          Reg.WriteString('', '"' + GetDirectory(Filename) + 'PhotoDB.exe" "%1"');
          if B then
          begin
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\DefaultIcon', True);
            Reg.WriteString('', '' + GetDirectory(Filename) + 'PhotoDB.exe,0');
          end;
          Reg.CloseKey;
        end;
    end;
  end;
  Reg.Free;
  Result := True;
end;

function ExtUnInstallApplicationW: Boolean;
var
  I, J: Integer;
  Reg: TRegistry;
  S: string;
  PrExt: Boolean;
begin
  Result := False;
  Reg := TRegistry.Create;
  Reg.RootKey := Windows.HKEY_CLASSES_ROOT;
  for I := 1 to Length(SupportedExt) do
  begin
    if SupportedExt[I] = '|' then
      for J := I to Length(SupportedExt) do
      begin
        if SupportedExt[J] = '|' then
          if (J - I - 1 > 0) and (I + 1 < Length(SupportedExt)) then
            if (AnsiLowerCase(Copy(SupportedExt, I + 1, J - I - 1)) <> '') then
            begin
              Reg.OpenKey('\.' + Copy(SupportedExt, I + 1, J - I - 1), True);
              S := Reg.ReadString('');
              Reg.CloseKey;
              if AnsiLowerCase(S) = AnsiLowerCase('PhotoDB.' + Copy(SupportedExt, I + 1, J - I - 1)) then
                PrExt := True
              else
                PrExt := False;
              if PrExt then
                Reg.DeleteKey('\' + S);
              Reg.DeleteKey('\' + S + '\Shell\PhotoDBView\Command');
              Reg.DeleteKey('\' + S + '\Shell\PhotoDBView');
              Reg.OpenKey('\.' + Copy(SupportedExt, I + 1, J - I - 1), True);
              S := Reg.ReadString('PhotoDB_PreviousAssociation');
              Reg.CloseKey;
              if S <> '' then
              begin
                Reg.OpenKey('\.' + Copy(SupportedExt, I + 1, J - I - 1), True);
                Reg.DeleteValue('PhotoDB_PreviousAssociation');
                Reg.WriteString('', S);
                Reg.CloseKey;
              end
              else
              begin
                if PrExt then
                  Reg.DeleteKey('\.' + Copy(SupportedExt, I + 1, J - I - 1));
              end;
              Break;
            end;
      end;
  end;
  Reg.Free;
  Result := True;
end;

function ExtInstallApplication(Filename: string): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := Tregistry.Create;
  try
    Reg.Rootkey := Windows.HKEY_CLASSES_ROOT;
    Reg.OpenKey('\Directory\Shell\PhDBBrowse', True);
    Reg.Writestring('', TEXT_MES_BROWSE_WITH_DB);
    Reg.CloseKey;
    Reg.OpenKey('\Directory\Shell\PhDBBrowse\Command', True);
    Reg.Writestring('', '"' + GetDirectory(Filename) + 'PhotoDB.exe" "/EXPLORER" "%1"');
    Result := True;
  except
    on E: Exception do
    begin
      EventLog(':ExtInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Reg.Free;
  Reg := Tregistry.Create;
  try
    Reg.Rootkey := Windows.HKEY_CLASSES_ROOT;
    Reg.OpenKey('\Drive\Shell\PhDBBrowse', True);
    Reg.Writestring('', TEXT_MES_BROWSE_WITH_DB);
    Reg.CloseKey;
    Reg.OpenKey('\Drive\Shell\PhDBBrowse\Command', True);
    Reg.Writestring('', '"' + GetDirectory(Filename) + 'PhotoDB.exe" "/EXPLORER" "%1"');
    Result := True;
  except
    on E: Exception do
    begin
      EventLog(':ExtInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Reg.Free;
end;

function TryOpenCDS(DS: TDataSet): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to 20 do
  begin
    Result := True;
    try
      DS.Active := True;
    except
      Result := False;
    end;
    if Result then
      Break;
    Sleep(DelayExecuteSQLOperation);
  end;
end;

function GetInfoByFileNameA(FileName: string; LoadThum: Boolean; var Info: TOneRecordInfo): Boolean;
var
  FQuery: TDataSet;
  FBS: TStream;
  B: Boolean;
  Folder, QueryString, S: string;
  CRC: Cardinal;
  JPEG: TJpegImage;
begin
  Result := False;
  FQuery := GetQuery;
  try
    FileName := AnsiLowerCase(FileName);
    UnProcessPath(FileName);

    if FolderView then
    begin
      Folder := GetDirectory(FileName);
      Delete(Folder, 1, Length(ProgramDir));
      UnFormatDir(Folder);
      S := FileName;
      Delete(S, 1, Length(ProgramDir));
    end
    else
    begin
      Folder := GetDirectory(FileName);
      UnFormatDir(Folder);
      S := FileName;
    end;
    CalcStringCRC32(Folder, CRC);
    QueryString := 'Select * from $DB$ where FolderCRC=' + IntToStr(Integer(CRC)) + ' and Name = :name';
    SetSQL(FQuery, QueryString);
    SetStrParam(FQuery, 0, ExtractFileName(S));
    TryOpenCDS(FQuery);

    if not TryOpenCDS(FQuery) or (FQuery.RecordCount = 0) then
    begin
      Pointer(JPEG) := Pointer(Info.Image);
      Info := RecordInfoOne(FileName, 0, 0, 0, 0, 0, '', '', '', '', '', 0, False, False, 0,
        ValidCryptGraphicFile(ProcessPath(FileName)), True, False, '');
      Info.ItemLinks := '';
      Info.ItemImTh := '';
      Pointer(Info.Image) := Pointer(JPEG);
      Exit;
    end;

    Result := True;
    Pointer(JPEG) := Pointer(Info.Image);
    Info := RecordInfoOne(FQuery.FieldByName('FFileName').AsString, FQuery.FieldByName('ID').AsInteger,
      FQuery.FieldByName('Rotated').AsInteger, FQuery.FieldByName('Rating').AsInteger,
      FQuery.FieldByName('Access').AsInteger, FQuery.FieldByName('FileSize').AsInteger,
      FQuery.FieldByName('Comment').AsString, FQuery.FieldByName('KeyWords').AsString,
      FQuery.FieldByName('Owner').AsString, FQuery.FieldByName('Collection').AsString,
      FQuery.FieldByName('Groups').AsString, FQuery.FieldByName('DateToAdd').AsDateTime,
      FQuery.FieldByName('IsDate').AsBoolean, FQuery.FieldByName('IsTime').AsBoolean,
      FQuery.FieldByName('aTime').AsDateTime, ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')),
      FQuery.FieldByName('Include').AsBoolean, True, FQuery.FieldByName('Links').AsString);
    Info.ItemHeight := FQuery.FieldByName('Height').AsInteger;
    Info.ItemWidth := FQuery.FieldByName('Width').AsInteger;
    Info.ItemLinks := FQuery.FieldByName('Links').AsString;
    Info.ItemImTh := FQuery.FieldByName('StrTh').AsString;
    Info.Tag := EXPLORER_ITEM_IMAGE;
    Pointer(Info.Image) := Pointer(JPEG);

    if LoadThum then
    begin
      if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
      begin
        DeCryptBlobStreamJPG(FQuery.FieldByName('thum'),
          DBKernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('thum')), Info.Image);
        Info.ItemCrypted := True;
        if not Info.Image.Empty then
          Info.Tag := 1;

      end else
      begin
        FBS := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
        try
          Info.Image.LoadFromStream(FBS);
        finally
          FBS.Free;
        end;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function RecordsInfoNil: TRecordsInfo;
begin
  Result.Position := 0;
  Result.Tag := 0;
  SetLength(Result.ItemFileNames, 0);
  SetLength(Result.ItemIds, 0);
  SetLength(Result.ItemRotates, 0);
  SetLength(Result.ItemRatings, 0);
  SetLength(Result.ItemAccesses, 0);
  SetLength(Result.ItemComments, 0);
  SetLength(Result.ItemOwners, 0);
  SetLength(Result.ItemKeyWords, 0);
  SetLength(Result.ItemCollections, 0);
  SetLength(Result.ItemDates, 0);
  SetLength(Result.ItemIsDates, 0);
  SetLength(Result.ItemIsTimes, 0);
  SetLength(Result.ItemTimes, 0);
  SetLength(Result.ItemGroups, 0);
  SetLength(Result.ItemCrypted, 0);
  SetLength(Result.LoadedImageInfo, 0);
  SetLength(Result.ItemInclude, 0);
  SetLength(Result.ItemLinks, 0);
end;

function RecordsInfoOne(name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean;
  Time: TDateTime; Crypt, Loaded, Include: Boolean; Links: string): TRecordsInfo;
begin
  Result.Position := 0;
  Result.Tag := 0;
  SetLength(Result.ItemFileNames, 1);
  SetLength(Result.ItemIds, 1);
  SetLength(Result.ItemRotates, 1);
  SetLength(Result.ItemRatings, 1);
  SetLength(Result.ItemAccesses, 1);
  SetLength(Result.ItemComments, 1);
  SetLength(Result.ItemOwners, 1);
  SetLength(Result.ItemKeyWords, 1);
  SetLength(Result.ItemCollections, 1);
  SetLength(Result.ItemDates, 1);
  SetLength(Result.ItemIsDates, 1);
  SetLength(Result.ItemIsTimes, 1);
  SetLength(Result.ItemTimes, 1);
  SetLength(Result.ItemGroups, 1);
  SetLength(Result.ItemCrypted, 1);
  SetLength(Result.LoadedImageInfo, 1);
  SetLength(Result.ItemInclude, 1);
  SetLength(Result.ItemLinks, 1);
  Result.ItemFileNames[0] := name;
  Result.ItemIds[0] := ID;
  Result.ItemRotates[0] := Rotate;
  Result.ItemRatings[0] := Rating;
  Result.ItemAccesses[0] := Access;
  Result.ItemComments[0] := Comment;
  Result.ItemOwners[0] := Owner_;
  Result.ItemKeyWords[0] := Comment;
  Result.ItemCollections[0] := Collection;
  Result.ItemDates[0] := Date;
  Result.ItemIsDates[0] := IsDate;
  Result.ItemIsTimes[0] := IsTime;
  Result.ItemTimes[0] := Time;
  Result.ItemGroups[0] := Groups;
  Result.ItemCrypted[0] := Crypt;
  Result.LoadedImageInfo[0] := Loaded;
  Result.ItemInclude[0] := Include;
  Result.ItemLinks[0] := Links;
end;

procedure AddToRecordsInfoOneInfo(var Infos: TRecordsInfo; Info: TOneRecordInfo);
var
  L: Integer;
begin
  L := Length(Infos.ItemFileNames) + 1;
  SetLength(Infos.ItemFileNames, L);
  SetLength(Infos.ItemIds, L);
  SetLength(Infos.ItemRotates, L);
  SetLength(Infos.ItemRatings, L);
  SetLength(Infos.ItemAccesses, L);
  SetLength(Infos.ItemComments, L);
  SetLength(Infos.ItemOwners, L);
  SetLength(Infos.ItemKeyWords, L);
  SetLength(Infos.ItemCollections, L);
  SetLength(Infos.ItemDates, L);
  SetLength(Infos.ItemIsDates, L);
  SetLength(Infos.ItemIsTimes, L);
  SetLength(Infos.ItemTimes, L);
  SetLength(Infos.ItemGroups, L);
  SetLength(Infos.ItemCrypted, L);
  SetLength(Infos.ItemInclude, L);
  SetLength(Infos.ItemLinks, L);
  Infos.ItemFileNames[L - 1] := Info.ItemFileName;
  Infos.ItemIds[L - 1] := Info.ItemId;
  Infos.ItemRotates[L - 1] := Info.ItemRotate;
  Infos.ItemRatings[L - 1] := Info.ItemRating;
  Infos.ItemAccesses[L - 1] := Info.ItemAccess;
  Infos.ItemComments[L - 1] := Info.ItemComment;
  Infos.ItemOwners[L - 1] := Info.ItemOwner;
  Infos.ItemKeyWords[L - 1] := Info.ItemKeyWords;
  Infos.ItemCollections[L - 1] := Info.ItemCollections;
  Infos.ItemDates[L - 1] := Info.ItemDate;
  Infos.ItemIsDates[L - 1] := Info.ItemIsDate;
  Infos.ItemIsTimes[L - 1] := Info.ItemIsTime;
  Infos.ItemTimes[L - 1] := Info.ItemTime;
  Infos.ItemGroups[L - 1] := Info.ItemGroups;
  Infos.ItemCrypted[L - 1] := Info.ItemCrypted;
  Infos.ItemInclude[L - 1] := Info.ItemInclude;
  Infos.ItemLinks[L - 1] := Info.ItemLinks;
end;

function RecordInfoOneA(name: string; ID, Rotate, Rating, Access, Size: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt: Boolean; Tag: Integer; Include: Boolean; Links: string): TOneRecordInfo;
begin
  Result.ItemFileName := name;
  Result.ItemCrypted := False;
  Result.ItemId := ID;
  Result.ItemSize := Size;
  Result.ItemRotate := Rotate;
  Result.ItemRating := Rating;
  Result.ItemAccess := Access;
  Result.ItemComment := Comment;
  Result.ItemCollections := Collection;
  Result.ItemOwner := Owner_;
  Result.ItemKeyWords := KeyWords;
  Result.Image := nil;
  Result.ItemDate := Date;
  Result.ItemTime := Time;
  Result.ItemIsDate := IsDate;
  Result.ItemIsTime := IsDate;
  Result.ItemGroups := Groups;
  Result.ItemCrypted := Crypt;
  Result.ItemInclude := Include;
  Result.ItemLinks := Links;
  Result.Tag := Tag;
end;

function GetRecordsFromOne(Info: TOneRecordInfo): TRecordsInfo;
begin
  Result.Position := 0;
  Result.Tag := 0;
  SetLength(Result.ItemFileNames, 1);
  SetLength(Result.ItemIds, 1);
  SetLength(Result.ItemRotates, 1);
  SetLength(Result.ItemRatings, 1);
  SetLength(Result.ItemAccesses, 1);
  SetLength(Result.ItemComments, 1);
  SetLength(Result.ItemComments, 1);
  SetLength(Result.ItemKeyWords, 1);
  SetLength(Result.ItemOwners, 1);
  SetLength(Result.ItemGroups, 1);
  SetLength(Result.ItemDates, 1);
  SetLength(Result.ItemTimes, 1);
  SetLength(Result.ItemIsDates, 1);
  SetLength(Result.ItemIsTimes, 1);
  SetLength(Result.ItemCollections, 1);
  SetLength(Result.ItemCrypted, 1);
  SetLength(Result.LoadedImageInfo, 1);
  SetLength(Result.ItemInclude, 1);
  SetLength(Result.ItemLinks, 1);
  Result.ItemFileNames[0] := Info.ItemFileName;
  Result.ItemIds[0] := Info.ItemId;
  Result.ItemRotates[0] := Info.ItemRotate;
  Result.ItemRatings[0] := Info.ItemRating;
  Result.ItemAccesses[0] := Info.ItemAccess;
  Result.ItemComments[0] := Info.ItemComment;
  Result.ItemKeyWords[0] := Info.ItemKeyWords;
  Result.ItemOwners[0] := Info.ItemOwner;
  Result.ItemCollections[0] := Info.ItemCollections;
  Result.ItemDates[0] := Info.ItemDate;
  Result.ItemTimes[0] := Info.ItemTime;
  Result.ItemIsDates[0] := Info.ItemIsDate;
  Result.ItemIsTimes[0] := Info.ItemIsTime;
  Result.ItemGroups[0] := Info.ItemGroups;
  Result.ItemCrypted[0] := Info.ItemCrypted;
  Result.LoadedImageInfo[0] := Info.Loaded;
  Result.ItemInclude[0] := Info.ItemInclude;
  Result.ItemLinks[0] := Info.ItemLinks;
end;

function GetRecordFromRecords(Info: TRecordsInfo; N: Integer): TOneRecordInfo;
begin
  Result.ItemFileName := Info.ItemFileNames[N];
  Result.ItemId := Info.ItemIds[N];
  Result.ItemRotate := Info.ItemRotates[N];
  Result.ItemRating := Info.ItemRatings[N];
  Result.ItemAccess := Info.ItemAccesses[N];
  Result.ItemComment := Info.ItemComments[N];
  Result.ItemKeyWords := Info.ItemKeyWords[N];
  Result.ItemOwner := Info.ItemOwners[N];
  Result.ItemCollections := Info.ItemCollections[N];
  Result.ItemDate := Info.ItemDates[N];
  Result.ItemTime := Info.ItemTimes[N];
  Result.ItemIsDate := Info.ItemIsDates[N];
  Result.ItemIsTime := Info.ItemIsTimes[N];
  Result.ItemGroups := Info.ItemGroups[N];
  Result.ItemCrypted := Info.ItemCrypted[N];
  Result.ItemInclude := Info.ItemInclude[N];
  Result.Loaded := Info.LoadedImageInfo[N];
  Result.ItemLinks := Info.ItemLinks[N];
end;

procedure SetRecordToRecords(Info: TRecordsInfo; N: Integer; Rec: TOneRecordInfo);
begin
  Info.ItemFileNames[N] := Rec.ItemFileName;
  Info.ItemIds[N] := Rec.ItemId;
  Info.ItemRotates[N] := Rec.ItemRotate;
  Info.ItemRatings[N] := Rec.ItemRating;
  Info.ItemAccesses[N] := Rec.ItemAccess;
  Info.ItemComments[N] := Rec.ItemComment;
  Info.ItemKeyWords[N] := Rec.ItemKeyWords;
  Info.ItemOwners[N] := Rec.ItemOwner;
  Info.ItemCollections[N] := Rec.ItemCollections;
  Info.ItemDates[N] := Rec.ItemDate;
  Info.ItemTimes[N] := Rec.ItemTime;
  Info.ItemIsDates[N] := Rec.ItemIsDate;
  Info.ItemIsTimes[N] := Rec.ItemIsTime;
  Info.ItemGroups[N] := Rec.ItemGroups;
  Info.ItemCrypted[N] := Rec.ItemCrypted;
  Info.ItemInclude[N] := Rec.ItemInclude;
  Info.LoadedImageInfo[N] := Rec.Loaded;
  Info.ItemLinks[N] := Rec.ItemLinks;
end;

function LoadInfoFromDataSet(TDS: TDataSet): TOneRecordInfo;
begin
  Result.ItemFileName := TDS.FieldByName('FFileName').AsString;
  Result.ItemCrypted := ValidCryptBlobStreamJPG(TDS.FieldByName('Thum'));
  Result.ItemId := TDS.FieldByName('ID').AsInteger;
  Result.ItemImTh := TDS.FieldByName('StrTh').AsString;
  Result.ItemSize := TDS.FieldByName('FileSize').AsInteger;
  Result.ItemRotate := TDS.FieldByName('Rotated').AsInteger;
  Result.ItemRating := TDS.FieldByName('Rating').AsInteger;
  Result.ItemAccess := TDS.FieldByName('Access').AsInteger;
  Result.ItemComment := TDS.FieldByName('Comment').AsString;
  Result.ItemGroups := TDS.FieldByName('Groups').AsString;
  Result.ItemKeyWords := TDS.FieldByName('KeyWords').AsString;
  Result.ItemDate := TDS.FieldByName('DateToAdd').AsDateTime;
  Result.ItemIsDate := TDS.FieldByName('IsDate').AsBoolean;
  Result.ItemIsTime := TDS.FieldByName('IsTime').AsBoolean;
  Result.ItemInclude := TDS.FieldByName('Include').AsBoolean;
  Result.ItemLinks := TDS.FieldByName('Links').AsString;
  Result.Loaded := True;
end;

procedure SetRecordsInfoOne(var D: TRecordsInfo; N: Integer; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TDateTime; Crypt, Include: Boolean;
  Links: string);
begin
  D.ItemFileNames[N] := name;
  D.ItemIds[N] := ID;
  D.ItemRotates[N] := Rotate;
  D.ItemRatings[N] := Rating;
  D.ItemAccesses[N] := Access;
  D.ItemComments[N] := Comment;
  D.ItemGroups[N] := Groups;
  D.ItemDates[N] := Date;
  D.ItemTimes[N] := Time;
  D.ItemIsDates[N] := IsDate;
  D.ItemIsTimes[N] := IsTime;
  D.ItemCrypted[N] := Crypt;
  D.ItemInclude[N] := Include;
  D.ItemLinks[N] := Links;
end;

procedure AddRecordsInfoOne(var D: TRecordsInfo; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt, Loaded, Include: Boolean; Links: string);
var
  L: Integer;
begin
  L := Length(D.ItemFileNames);
  SetLength(D.ItemFileNames, L + 1);
  SetLength(D.ItemIds, L + 1);
  SetLength(D.ItemRotates, L + 1);
  SetLength(D.ItemRatings, L + 1);
  SetLength(D.ItemAccesses, L + 1);
  SetLength(D.ItemComments, L + 1);
  SetLength(D.ItemOwners, L + 1);
  SetLength(D.ItemCollections, L + 1);
  SetLength(D.ItemKeyWords, L + 1);
  SetLength(D.ItemDates, L + 1);
  SetLength(D.ItemTimes, L + 1);
  SetLength(D.ItemIsDates, L + 1);
  SetLength(D.ItemIsTimes, L + 1);
  SetLength(D.ItemGroups, L + 1);
  SetLength(D.ItemCrypted, L + 1);
  SetLength(D.LoadedImageInfo, L + 1);
  SetLength(D.ItemInclude, L + 1);
  SetLength(D.ItemLinks, L + 1);
  D.ItemFileNames[L] := name;
  D.ItemIds[L] := ID;
  D.ItemRotates[L] := Rotate;
  D.ItemRatings[L] := Rating;
  D.ItemAccesses[L] := Access;
  D.ItemComments[L] := Comment;
  D.ItemOwners[L] := Owner_;
  D.ItemCollections[L] := Collection;
  D.ItemKeyWords[L] := KeyWords;
  D.ItemDates[L] := Date;
  D.ItemTimes[L] := Time;
  D.ItemIsDates[L] := IsDate;
  D.ItemIsTimes[L] := IsTime;
  D.ItemGroups[L] := Groups;
  D.ItemCrypted[L] := Crypt;
  D.LoadedImageInfo[L] := Loaded;
  D.ItemInclude[L] := Include;
  D.ItemLinks[L] := Links;
end;

procedure CopyArrayInt(var S, D: TArInteger);
var
  I: Integer;
begin
  SetLength(D, Length(S));
  for I := 0 to Length(D) - 1 do
    D[I] := S[I];
end;

procedure CopyArrayStr(var S, D: TArStrings);
var
  I: Integer;
begin
  SetLength(D, Length(S));
  for I := 0 to Length(D) - 1 do
    D[I] := S[I];
end;

procedure CopyArrayDate(var S, D: TArDateTime);
var
  I: Integer;
begin
  SetLength(D, Length(S));
  for I := 0 to Length(D) - 1 do
    D[I] := S[I];
end;

procedure CopyArrayTime(var S, D: TArTime);
var
  I: Integer;
begin
  SetLength(D, Length(S));
  for I := 0 to Length(D) - 1 do
    D[I] := S[I];
end;

procedure CopyArrayBool(var S, D: TArBoolean);
var
  I: Integer;
begin
  SetLength(D, Length(S));
  for I := 0 to Length(D) - 1 do
    D[I] := S[I];
end;

procedure CopyRecordsInfo(var S, D: TRecordsInfo);
begin
  D.Position := S.Position;
  CopyArrayStr(S.ItemFileNames, D.ItemFileNames);
  CopyArrayInt(S.ItemIds, D.ItemIds);
  CopyArrayInt(S.ItemRatings, D.ItemRatings);
  CopyArrayInt(S.ItemRotates, D.ItemRotates);
  CopyArrayInt(S.ItemAccesses, D.ItemAccesses);
  CopyArrayStr(S.ItemComments, D.ItemComments);
  CopyArrayDate(S.ItemDates, D.ItemDates);
  CopyArrayTime(S.ItemTimes, D.ItemTimes);
  CopyArrayBool(S.ItemIsDates, D.ItemIsDates);
  CopyArrayBool(S.ItemIsTimes, D.ItemIsTimes);
  CopyArrayStr(S.ItemGroups, D.ItemGroups);
  CopyArrayBool(S.ItemInclude, D.ItemInclude);
end;

function RecordsInfoFromArrays(Names: TArstrings; IDs, Rotates, Ratings, Accesss: TArInteger;
  Comments, KeyWords, Groups: TArstrings; Dates: TArDateTime; IsDates, IsTimes: TArBoolean; Times: TArTime;
  Crypt, Loaded, Include: TArBoolean; Links: TArStrings): TRecordsInfo;
begin
  CopyArrayStr(Names, Result.ItemFileNames);
  CopyArrayInt(IDs, Result.ItemIds);
  CopyArrayInt(Rotates, Result.ItemRotates);
  CopyArrayInt(Ratings, Result.ItemRatings);
  CopyArrayInt(Accesss, Result.ItemAccesses);
  CopyArrayStr(Comments, Result.ItemComments);
  CopyArrayStr(KeyWords, Result.ItemKeyWords);
  CopyArrayDate(Dates, Result.ItemDates);
  CopyArrayTime(Times, Result.ItemTimes);
  CopyArrayBool(IsDates, Result.ItemIsDates);
  CopyArrayBool(IsTimes, Result.ItemIsTimes);
  CopyArrayStr(Groups, Result.ItemGroups);
  CopyArrayBool(Crypt, Result.ItemCrypted);
  CopyArrayBool(Loaded, Result.LoadedImageInfo);
  CopyArrayBool(Include, Result.ItemInclude);
  CopyArrayStr(Links, Result.ItemLinks);
end;

procedure DBPopupMenuInfoToRecordsInfo(var DBP: TDBPopupMenuInfo; var RI: TRecordsInfo);
var
  I, FilesSelected: Integer;
begin
  FilesSelected := 0;
  for I := 0 to DBP.Count - 1 do
    if DBP[I].Selected then
      Inc(FilesSelected);

  RI := RecordsInfoNil;
  RI.Position := DBP.Position;
  for I := 0 to DBP.Count - 1 do
    if DBP[I].Selected or (FilesSelected <= 1) then
    begin
      AddRecordsInfoOne(RI, DBP[I].FileName, DBP[I].ID, DBP[I].Rotation, DBP[I].Rating, DBP[I].Access, DBP[I].Comment,
        '', '', '', DBP[I].Groups, DBP[I].Date, DBP[I].IsDate, DBP[I].IsTime, DBP[I].Time, DBP[I].Crypted,
        DBP[I].InfoLoaded, DBP[I].Include, DBP[I].Links);
    end;
end;

function GetMenuInfoByID(ID: Integer): TDBPopupMenuInfo;
var
  FQuery: TDataSet;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Result := nil;
  FQuery := GetQuery;
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE ID = :ID');
    SetIntParam(FQuery, 0, ID);
    FQuery.Open;
    if FQuery.RecordCount <> 1 then
      Exit;

    Result := TDBPopupMenuInfo.Create;
    MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
    Result.Add(MenuRecord);
    Result.ListItem := nil;
    Result.AttrExists := False;
    Result.IsListItem := False;
    Result.IsPlusMenu := False;
    FQuery.Close;
  finally
    FreeDS(FQuery);
  end;
end;

function GetMenuInfoByStrTh(StrTh: string): TDBPopupMenuInfo;
var
  FQuery: TDataSet;
  FromDB: string;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Result := nil;
  FQuery := GetQuery;
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE StrThCrc = :CRC AND StrTh = :StrTh');
    SetIntParam(FQuery, 0, StringCRC(StrTh));
    SetStrParam(FQuery, 1, StrTh);
    FQuery.Open;
    if FQuery.RecordCount <> 1 then
      Exit;

    Result := TDBPopupMenuInfo.Create;
    MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
    Result.Add(MenuRecord);
    Result.ListItem := nil;
    Result.AttrExists := False;
    Result.IsListItem := False;
    Result.IsPlusMenu := False;
    Result.Position := 0;
    FQuery.Close;
  finally
    FreeDS(FQuery);
  end;
end;

function RecordInfoOne(name: string; ID, Rotate, Rating, Access: Integer; Size: Int64;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt, Include, Loaded: Boolean; Links: string): TOneRecordInfo;
begin
  Result.ItemFileName := name;
  Result.ItemCrypted := Crypt;
  Result.ItemId := ID;
  Result.ItemSize := Size;
  Result.ItemRotate := Rotate;
  Result.ItemRating := Rating;
  Result.ItemAccess := Access;
  Result.ItemComment := Comment;
  Result.ItemCollections := Collection;
  Result.ItemOwner := Owner_;
  Result.ItemKeyWords := KeyWords;
  Result.ItemDate := Date;
  Result.ItemTime := Time;
  Result.ItemIsDate := IsDate;
  Result.ItemIsTime := IsTime;
  Result.ItemGroups := Groups;
  Result.ItemInclude := Include;
  Result.ItemLinks := Links;
  Result.Image := nil;
  Result.PassTag := 0;
  Result.Loaded := Loaded;
end;

procedure GetFileListByMask(BeginFile, Mask: string; out Info: TRecordsInfo; var N: Integer; ShowPrivate: Boolean);
var
  Found, I, J: Integer;
  SearchRec: TSearchRec;
  Folder, DBFolder, S, AddFolder: string;
  C: Integer;
  FQuery: TDataSet;
  FBlockedFiles: TArStrings;
  List: TStrings;
  Crc: Cardinal;
  FE, EM: Boolean;
  P: PChar;
  PSupportedExt: PChar;

  function IsFileBlocked(FileName: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Length(FBlockedFiles) - 1 do
      if AnsiLowerCase(FBlockedFiles[I]) = AnsiLowerCase(FileName) then
      begin
        Result := True;
        Break;
      end;
  end;

begin

  if FileExists(BeginFile) then
    Folder := GetDirectory(BeginFile);
  if DirectoryExists(BeginFile) then
    Folder := BeginFile;
  if Folder = '' then
    Exit;
  List := TStringlist.Create;
  C := 0;
  N := 0;
  SetLength(FBlockedFiles, 0);
  FQuery := GetQuery(True);
  FQuery.Active := False;
  Folder := AnsiLowerCase(Folder);
  Formatdir(Folder);
  Folder := AnsiLowercase(Folder);
  DBFolder := NormalizeDBStringLike(NormalizeDBString(Folder));

  if FolderView then
    AddFolder := AnsiLowerCase(ProgramDir)
  else
    AddFolder := '';

  UnFormatDir(DBFolder);
  CalcStringCRC32(AnsiLowerCase(DBFolder), Crc);

  if (GetDBType = DB_TYPE_MDB) and not FolderView then
    SetSQL(FQuery, 'Select * From (Select * from $DB$ where FolderCRC=' + Inttostr(Integer(Crc)) +
        ') where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
  if FolderView then
  begin
    SetSQL(FQuery, 'Select * From $DB$ where FolderCRC = :crc');
    S := DBFolder;
    Delete(S, 1, Length(ProgramDir));
    UnformatDir(S);
    CalcStringCRC32(AnsiLowerCase(S), Crc);
    SetIntParam(FQuery, 0, Integer(Crc));
  end else
  begin
    UnFormatDir(DBFolder);
    CalcStringCRC32(AnsiLowerCase(DBFolder), Crc);
    FormatDir(DBFolder);
    SetStrParam(FQuery, 0, '%' + DBFolder + '%');
    SetStrParam(FQuery, 1, '%' + DBFolder + '%\%');
  end;

  FQuery.Active := True;
  FQuery.First;
  SetLength(FBlockedFiles, 0);
  for I := 1 to FQuery.RecordCount do
  begin
    if FQuery.FieldByName('Access').AsInteger = Db_access_private then
    begin
      SetLength(FBlockedFiles, Length(FBlockedFiles) + 1);
      FBlockedFiles[Length(FBlockedFiles) - 1] := FQuery.FieldByName('FFileName').AsString;
    end;
    FQuery.Next;
  end;
  try
    BeginFile := AnsiLowerCase(BeginFile);
    PSupportedExt := PChar(Mask); // !!!!
    Found := FindFirst(Folder + '*.*', FaAnyFile, SearchRec);
    while Found = 0 do
    begin
      // if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
      begin
        FE := (SearchRec.Attr and FaDirectory = 0);
        S := ExtractFileExt(SearchRec.name);
        Delete(S, 1, 1);
        S := '|' + AnsiUpperCase(S) + '|';
        if PSupportedExt = '*.*' then
          EM := True
        else
        begin
          P := StrPos(PSupportedExt, PChar(S));
          EM := P <> nil;
        end;
        if FE and EM and not IsFileBlocked(Folder + SearchRec.name) then
        begin
          Inc(C);
          if AnsiLowerCase(Folder + SearchRec.name) = BeginFile then
            N := C - 1;
          List.Add(AnsiLowerCase(Folder + SearchRec.name));
        end;
      end;
      Found := SysUtils.FindNext(SearchRec);
    end;
    FindClose(SearchRec);
  except
  end;
  Info := RecordsInfoNil;
  FQuery.First;
  for I := 0 to List.Count - 1 do
    AddRecordsInfoOne(Info, List[I], 0, 0, 0, 0, '', '', '', '', '', 0, False, False, 0, False, False, True, '');

  for I := 0 to FQuery.RecordCount - 1 do
  begin
    for J := 0 to Length(Info.ItemFileNames) - 1 do
    begin
      if (AddFolder + FQuery.FieldByName('FFileName').AsString) = Info.ItemFileNames[J] then
      begin
        SetRecordToRecords(Info, J, LoadInfoFromDataSet(FQuery));
        Break;
      end;
    end;
    FQuery.Next;
  end;
  for I := 0 to Length(Info.ItemFileNames) - 1 do
  begin
    if AnsiLowerCase(Info.ItemFileNames[I]) = AnsiLowerCase(BeginFile) then
      Info.Position := I;
    if not Info.LoadedImageInfo[I] then
    begin
      Info.ItemCrypted[I] := False; // ? !!! ValidCryptGraphicFile(Info.ItemFileNames[i]);
      Info.LoadedImageInfo[I] := True;
    end;
  end;
  FQuery.Close;
  FreeDS(FQuery);
end;

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

function GetDirectoresOfPath(Dir: string): TArStrings;
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  SetLength(Result, 0);
  if Length(Dir) < 4 then
    Exit;
  if Dir[Length(Dir)] <> '\' then
    Dir := Dir + '\';
  Found := FindFirst(Dir + '*.*', FaDirectory, SearchRec);
  while Found = 0 do
  begin
    if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
      if (SearchRec.Attr and FaDirectory <> 0) then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := SearchRec.name;
      end;
    Found := Sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

procedure RenameFolderWithDB(OldFileName, NewFileName: string; Ask: Boolean = True);
var
  ProgressWindow: TProgressActionForm;
  FQuery, SetQuery: TDataSet;
  EventInfo: TEventValues;
  Crc: Cardinal;
  I, Int: Integer;
  FFolder, DBFolder, NewPath, OldPath, Sql, Dir, S: string;
  Dirs: TArStrings;
begin
  if DirectoryExists(NewFileName) or DirectoryExists(OldFileName) then
  begin
    UnFormatDir(OldFileName);
    UnFormatDir(NewFileName);

    FQuery := GetQuery;
    FFolder := OldFileName;

    FormatDir(FFolder);

    DBFolder := AnsiLowerCase(FFolder);
    DBFolder := NormalizeDBStringLike(NormalizeDBString(DBFolder));
    if FolderView then
    begin
      Delete(DBFolder, 1, Length(ProgramDir));
    end;
    SetSQL(FQuery, 'Select ID, FFileName From $DB$ where (FFileName Like :FolderA)');
    SetStrParam(FQuery, 0, '%' + DBFolder + '%');

    FQuery.Active := True;
    FQuery.First;
    if FQuery.RecordCount > 0 then
      if Ask or (ID_OK = MessageBoxDB(GetActiveFormHandle, Format(TEXT_MES_RENAME_FOLDER_WITH_DB_F,
            [OldFileName, IntToStr(FQuery.RecordCount)]), TEXT_MES_WARNING, TD_BUTTON_OKCANCEL, TD_ICON_WARNING)) then
      begin
        ProgressWindow := GetProgressWindow;
        ProgressWindow.OneOperation := True;
        ProgressWindow.MaxPosCurrentOperation := FQuery.RecordCount;
        SetQuery := GetQuery;

        if FQuery.RecordCount > 5 then
        begin
          ProgressWindow.Show;
          ProgressWindow.Repaint;
          ProgressWindow.DoubleBuffered := True;
        end;
        try
          for I := 1 to FQuery.RecordCount do
          begin

            NewPath := FQuery.FieldByName('FFileName').AsString;
            Delete(NewPath, 1, Length(OldFileName));
            NewPath := NewFileName + NewPath;
            OldPath := FQuery.FieldByName('FFileName').AsString;

            if GetDBType = DB_TYPE_MDB then
            begin
              if not FolderView then
              begin
                CalcStringCRC32(AnsiLowerCase(NewFileName), Crc);
              end
              else
              begin
                S := NewFileName;
                Delete(S, 1, Length(ProgramDir));
                UnFormatDir(S);
                CalcStringCRC32(AnsiLowerCase(S), Crc);
                FormatDir(S);
                NewPath := AnsiLowerCase(S + ExtractFileName(FQuery.FieldByName('FFileName').AsString));
              end;
              Int := Integer(Crc);
              Sql := 'UPDATE $DB$ SET FFileName="' + AnsiLowerCase(NormalizeDBString(NewPath))
                + '" , FolderCRC = ' + IntToStr(Int) + ' where ID = ' + Inttostr(FQuery.FieldByName('ID').AsInteger);
              SetSQL(SetQuery, Sql);
            end;
            ExecSQL(SetQuery);
            EventInfo.name := OldPath;
            EventInfo.NewName := NewPath;
            DBKernel.DoIDEvent(nil, 0, [EventID_Param_Name], EventInfo);
            try

              if I < 10 then
              begin
                ProgressWindow.XPosition := I;
                ProgressWindow.Repaint;
              end else
              begin
                if I mod 10 = 0 then
                begin
                  ProgressWindow.XPosition := I;
                  ProgressWindow.Repaint;
                end;
              end;
            except
            end;
            FQuery.Next;
          end;
        except
        end;
        FreeDS(SetQuery);
        ProgressWindow.Release;

      end;
    FreeDS(FQuery);
  end;
  Dir := '';
  UnformatDir(OldFileName);
  UnformatDir(NewFileName);
  SetLength(Dirs, 0);
  if DirectoryExists(OldFileName) then
  begin
    Dirs := GetDirectoresOfPath(OldFileName);
    if Length(Dirs) > 0 then
    begin
      for I := 0 to Length(Dirs) - 1 do
        RenameFolderWithDB(OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
  end;
  if DirectoryExists(NewFileName) then
  begin
    Dirs := GetDirectoresOfPath(NewFileName);
    if Length(Dirs) > 0 then
    begin
      for I := 0 to Length(Dirs) - 1 do
        RenameFolderWithDB(OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
  end;
end;

function RenameFileWithDB(OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;
var
  FQuery: TDataSet;
  EventInfo: TEventValues;
  Acrc, Folder: string;
  Crc: Cardinal;
begin
  Result := True;
  if not OnlyBD then
    if FileExists(OldFileName) or DirectoryExists(OldFileName) then
    begin
      try
        Result := RenameFile(OldFileName, NewFileName);
        if not Result then
          Exit;
      except
        Result := False;
        Exit;
      end;
    end;

  if ID <> 0 then
  begin
    FQuery := GetQuery;
    try
      if GetDBType = DB_TYPE_MDB then
      begin
        Acrc := ' ,FolderCRC = :FolderCRC';

        UnProcessPath(NewFileName);
        if not FolderView then
        begin
          Folder := GetDirectory(NewFileName);
          Folder := AnsiLowerCase(Folder);
          UnFormatDir(Folder);
          CalcStringCRC32(Folder, Crc);
        end else
        begin
          Folder := GetDirectory(NewFileName);
          Delete(Folder, 1, Length(ProgramDir));
          UnformatDir(Folder);
          CalcStringCRC32(AnsiLowerCase(Folder), Crc);
          FormatDir(Folder);
          Delete(NewFileName, 1, Length(ProgramDir));
        end;

      end
      else
      begin
        Acrc := '';
      end;
      FQuery.Active := False;
      SetSQL(FQuery, 'UPDATE $DB$ SET FFileName="' + AnsiLowerCase(NewFileName) + '", Name="' + ExtractFileName
          (NewFileName) + '" ' + Acrc + ' WHERE (ID=' + Inttostr(ID) + ')');
      if GetDBType = DB_TYPE_MDB then
        SetIntParam(FQuery, 0, Integer(Crc));
      ExecSQL(FQuery);
    except
    end;
    FreeDS(FQuery);
  end;
  RenameFolderWithDB(OldFileName, NewFileName);

  if OnlyBD then
  begin
    DBKernel.DoIDEvent(nil, ID, [EventID_Param_Name], EventInfo);
    Exit;
  end;

  EventInfo.name := OldFileName;
  EventInfo.NewName := NewFileName;
  DBKernel.DoIDEvent(nil, ID, [EventID_Param_Name], EventInfo);
end;

function ActivationID: string;
var
  F: TPCharFunction;
  Fh: Pointer;
  Activation: PChar;
begin
  Fh := GetProcAddress(KernelHandle, 'GetCIDA');
  if Fh = nil then
  begin
    ShowMessage(TEXT_MES_ERROR_KERNEL_DLL);
    Halt;
    Exit;
  end;
  @F := Fh;
  Activation := F();
  Result := Copy(Activation, 1, Length(Activation));
end;

function NormalizeDBString(S: string): string;
begin
  Result := AnsiQuotedStr(S, '"')
end;

function NormalizeDBStringLike(S: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    if (S[I] = '[') or (S[I] = ']') then
      S[I] := '_';
  Result := S;
end;

function GetIdByFileName(FileName: string): Integer;
var
  FQuery: TDataSet;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName))
        + ' AND FFileName LIKE :FFileName');
    if FolderView then
      Delete(FileName, 1, Length(ProgramDir));
    SetStrParam(FQuery, 0, Delnakl(NormalizeDBStringLike(AnsiLowerCase(FileName))));
    try
      FQuery.Active := True;
    except
      Result := 0;
      Exit;
    end;
    if FQuery.RecordCount = 0 then
      Result := 0
    else
      Result := FQuery.FieldByName('ID').AsInteger;
  finally
    FreeDS(FQuery);
  end;
end;

function GetFileNameById(ID: Integer): string;
var
  FQuery: TDataSet;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    SetSQL(FQuery, 'SELECT FFileName FROM $DB$ WHERE ID = :ID');
    SetIntParam(FQuery, 0, ID);
    try
      FQuery.Active := True;
    except
      Result := '';
      Exit;
    end;
    if FQuery.RecordCount = 0 then
      Result := ''
    else
      Result := FQuery.FieldByName('FFileName').AsString;
  finally
    FreeDS(FQuery);
  end;
end;

function Delnakl(S: string): string;
var
  J: Integer;
begin
  Result := S;
  for J := 1 to Length(Result) do
    if Result[J] = '\' then
      Result[J] := '_';
end;

function BitmapToString(Bit: Tbitmap): string;
var
  I, J: Integer;
  Rr1, Bb1, Gg1: Byte;
  B1, B2: Byte;
  B: Tbitmap;
  P: PARGB;
begin
  Result := '';
  B := Tbitmap.Create;
  B.PixelFormat := Pf24bit;
  QuickReduceWide(10, 10, Bit, B);
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
  for I := 0 to 9 do
  begin
    P := B.ScanLine[I];
    for J := 0 to 9 do
    begin
      Rr1 := P[J].R div 8;
      Gg1 := P[J].G div 8;
      Bb1 := P[J].B div 8;
      B1 := Rr1 shl 3;
      B1 := B1 + Gg1 shr 2;
      B2 := Gg1 shl 6;
      B2 := B2 + Bb1 shl 1;
      if (B1 = 0) and (B2 <> 0) then
      begin
        B2 := B2 + 1;
        B1 := B1 or 135;
      end;
      if (B1 <> 0) and (B2 = 0) then
      begin
        B2 := B2 + 1;
        B2 := B2 or 225;
      end;
      if (B1 = 0) and (B2 = 0) then
      begin
        B1 := 255;
        B2 := 255;
      end;
      if FIXIDEX then
        if (I = 9) and (J = 9) and (B2 = 32) then
          B2 := 255;
      Result := Result + Chr(B1) + Chr(B2);
    end;
  end;
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
  B.Free;
end;

function PixelsToText(Pixels: Integer): string;
begin
  if not DBkernel.ProgramInDemoMode then
  begin
    if CharToInt(DBkernel.GetCodeChar(8)) <> (CharToInt(DBkernel.GetCodeChar(4)) + CharToInt(DBkernel.GetCodeChar(6)))
      * 17 mod 15 then
    begin
      Result := 'Fuck you!';
      Exit;
    end;
  end;
  Result := Format(TEXT_MES_PIXEL_FORMAT, [IntToStr(Pixels)]);
end;

procedure SetRotate(ID, Rotate: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Rotated=%d Where ID=%d', [Rotate, ID]));
end;

procedure SetAttr(ID, Attr: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Attr=%d Where ID=%d', [Attr, ID]));
end;

procedure SetRating(ID, Rating: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Rating=%d Where ID=%d', [Rating, ID]));
end;

procedure UpdateMovedDBRecord(ID: Integer; FileName: string);
var
  MDBstr: string;
begin
  MDBstr := ', FolderCRC = ' + IntToStr(Integer(FilePathCRC(FileName)));

  ExecuteQuery('UPDATE $DB$ SET FFileName="' + AnsiLowerCase(FileName) + '", Name ="' + ExtractFileName(FileName)
      + '", Attr=' + Inttostr(Db_access_none) + MDBstr + ' WHERE (ID=' + Inttostr(ID) + ')');
end;

procedure UpdateDeletedDBRecord(ID: Integer; Filename: string);
var
  FQuery: TDataSet;
  Crc: Cardinal;
  Int: Integer;
  MDBstr: string;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    if GetDBType(Dbname) = DB_TYPE_MDB then
    begin
      Crc := FilePathCRC(FileName);
      Int := Integer(Crc);
      MDBstr := ', FolderCRC = ' + IntToStr(Int);
    end;
    SetSQL(FQuery, 'UPDATE $DB$ SET FFileName="' + AnsiLowerCase(Filename) + '", Attr=' + Inttostr(Db_access_none)
        + MDBstr + ' WHERE (ID=' + Inttostr(ID) + ') AND (Attr=' + Inttostr(Db_attr_not_exists) + ')');
    ExecSQL(FQuery);
  except
  end;
  FreeDS(FQuery);
end;

function FloatToStrA(Value: Extended; Round: Integer): string;
var
  Buffer: array [0 .. 63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, FvExtended, FfGeneral, Round, 0));
end;

function SizeInTextA(Size: Int64): string;
begin
  if Size <= 1024 then
    Result := Inttostr(Size) + ' ' + TEXT_MES_BYTES;
  if (Size > 1024) and (Size <= 1024 * 999) then
    Result := FloatToStrA(Size / 1024, 3) + ' ' + TEXT_MES_KB;
  if (Size > 1024 * 999) and (Size <= 1024 * 1024 * 999) then
    Result := FloatToStrA(Size / (1024 * 1024), 3) + ' ' + TEXT_MES_MB;
  if (Size > 1024 * 1024 * 999) then
    Result := FloatToStrA(Size / (1024 * 1024 * 1024), 3) + ' ' + TEXT_MES_GB;
end;

function GetimageIDTh(ImageTh: string): TImageDBRecordA;
var
  FQuery: TDataSet;
  I: Integer;
  FromDB: string;
begin
  FQuery := GetQuery;
  try
  if GetDBType = DB_TYPE_MDB then
    FromDB := '(Select ID, FFileName, Attr from $DB$ where StrThCrc = ' + IntToStr(Integer(StringCRC(ImageTh))) + ')'
  else
    FromDB := 'SELECT ID, FFileName, Attr FROM $DB$ WHERE StrTh = :str ';

  SetSQL(FQuery, FromDB);
  if GetDBType <> DB_TYPE_MDB then
    SetStrParam(Fquery, 0, ImageTh);
  try
    FQuery.Active := True;
  except
    Setlength(Result.Ids, 0);
    Setlength(Result.FileNames, 0);
    Setlength(Result.Attr, 0);
    Result.Count := 0;
    Result.ImTh := '';
    Exit;
  end;
  Setlength(Result.Ids, FQuery.RecordCount);
  Setlength(Result.FileNames, FQuery.RecordCount);
  Setlength(Result.Attr, FQuery.RecordCount);
  FQuery.First;
  for I := 1 to FQuery.RecordCount do
  begin
    Result.Ids[I - 1] := FQuery.FieldByName('ID').AsInteger;
    Result.FileNames[I - 1] := FQuery.FieldByName('FFileName').AsString;
    Result.Attr[I - 1] := FQuery.FieldByName('Attr').AsInteger;
    FQuery.Next;
  end;
  Result.Count := FQuery.RecordCount;
  Result.ImTh := ImageTh;
  finally
    FreeDS(FQuery);
  end;
end;

function GetImageIDFileName(FileName: string): TImageDBRecordA;
var
  FQuery: TDataSet;
  I, Count, Rot: Integer;
  Res: TImageCompareResult;
  Val: array of Boolean;
  Xrot: array of Integer;
  FJPEG: TJPEGImage;
  G: TGraphic;
  Pass: string;
  S: string;
begin
  FQuery := GetQuery;
  try
  FQuery.Active := False;

  SetSQL(FQuery, 'SELECT ID, FFileName, Attr, StrTh, Thum FROM $DB$ WHERE FFileName like :str ');
  S := FileName;
  if FolderView then
    Delete(S, 1, Length(ProgramDir));
  SetStrParam(FQuery, 0, '%' + Delnakl(NormalizeDBStringLike(AnsiLowerCase(ExtractFileName(S)))) + '%');

  try
    FQuery.Active := True;
  except
    Setlength(Result.Ids, 0);
    Setlength(Result.FileNames, 0);
    Setlength(Result.Attr, 0);
    Result.Count := 0;
    Result.ImTh := '';
    Exit;
  end;
  FQuery.First;
  // pic := TPicture.Create;
  G := nil;
  if FQuery.RecordCount <> 0 then
  begin
    if GraphicCrypt.ValidCryptGraphicFile(FileName) then
    begin
      Pass := DBKernel.FindPasswordForCryptImageFile(FileName);
      if Pass = '' then
      begin
        Setlength(Result.Ids, 0);
        Setlength(Result.FileNames, 0);
        Setlength(Result.Attr, 0);
        Result.Count := 0;
        Result.ImTh := '';
        Exit;
      end
      else
      begin
        G := GraphicCrypt.DeCryptGraphicFile(FileName, Pass);
      end;
    end
    else
    begin
      G := GetGraphicClass(GetExt(FileName), False).Create;
      G.LoadFromFile(FileName);
    end;
  end;
  JPEGScale(G, 100, 100);
  SetLength(Val, FQuery.RecordCount);
  SetLength(Xrot, FQuery.RecordCount);
  Count := 0;
  FJPEG := nil;
  for I := 1 to FQuery.RecordCount do
  begin
    if ValidCryptBlobStreamJPG(FQuery.FieldByName('Thum')) then
    begin
      Pass := '';
      Pass := DBkernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('Thum'));
      FJPEG := TJPEGImage.Create;
      if Pass <> '' then
        DeCryptBlobStreamJPG(FQuery.FieldByName('Thum'), Pass, FJPEG);

    end
    else
    begin
      FJPEG := TJPEGImage.Create;
      FJPEG.Assign(FQuery.FieldByName('Thum'));
    end;
    // FJPEG.FREE ??? TODO: check
    Res := CompareImages(FJPEG, G, Rot);
    Xrot[I - 1] := Rot;
    Val[I - 1] := (Res.ByGistogramm > 1) or (Res.ByPixels > 1);
    if Val[I - 1] then
      Inc(Count);
    FQuery.Next;
  end;
  if FJPEG <> nil then
    FJPEG.Free;
  if G <> nil then
    G.Free;
  Setlength(Result.Ids, Count);
  Setlength(Result.FileNames, Count);
  Setlength(Result.Attr, Count);
  Setlength(Result.ChangedRotate, Count);
  Result.Count := Count;
  FQuery.First;
  Count := -1;
  for I := 1 to FQuery.RecordCount do
    if Val[I - 1] then
    begin
      Inc(Count);
      Result.ChangedRotate[Count] := Xrot[Count] <> 0;
      Result.Ids[Count] := FQuery.FieldByName('ID').AsInteger;
      Result.FileNames[Count] := FQuery.FieldByName('FFileName').AsString;
      Result.Attr[Count] := FQuery.FieldByName('Attr').AsInteger;
      Result.ImTh := FQuery.FieldByName('StrTh').AsString;
      FQuery.Next;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function GetimageIDWEx(Images: TArStrings; UseFileNameScanning: Boolean;
  OnlyImTh: Boolean = False): TImageDBRecordAArray;
var
  K, I, L, Len: Integer;
  FQuery: TDataSet;
  Sql, Temp, FromDB: string;
  ThImS: TImageDBRecordAArray;
begin
  L := Length(Images);
  SetLength(ThImS, L);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    ThImS[I] := GetImageIDW(Images[I], UseFileNameScanning, True);
  FQuery := GetQuery;
  FQuery.Active := False;
  Sql := '';
  if GetDBType = DB_TYPE_MDB then
  begin
    FromDB := '(SELECT ID, FFileName, Attr, StrTh FROM $DB$ WHERE ';
    for I := 1 to L do
    begin
      if I = 1 then
        Sql := Sql + Format(' (StrThCrc = :strcrc%d) ', [I])
      else
        Sql := Sql + Format(' or (StrThCrc = :strcrc%d) ', [I]);
    end;
    FromDB := FromDB + Sql + ')';
  end
  else
    FromDB := '$DB$';

  Sql := 'SELECT ID, FFileName, Attr, StrTh FROM ' + FromDB + ' WHERE ';

  for I := 1 to L do
  begin
    if I = 1 then
      Sql := Sql + Format(' (StrTh = :str%d) ', [I])
    else
      Sql := Sql + Format(' or (StrTh = :str%d) ', [I]);
  end;
  SetSQL(FQuery, Sql);
  if GetDBType = DB_TYPE_MDB then
  begin
    for I := 0 to L - 1 do
    begin
      Result[I] := ThImS[I];
      SetIntParam(FQuery, I, Integer(StringCRC(ThImS[I].ImTh)));
    end;
    for I := L to 2 * L - 1 do
    begin
      SetStrParam(FQuery, I, ThImS[I - L].ImTh);
    end;
  end
  else
  begin
    for I := 0 to L - 1 do
    begin
      Result[I] := ThImS[I];
      SetStrParam(FQuery, I, ThImS[I].ImTh);
    end;
  end;

  try
    FQuery.Active := True;
  except
    FreeDS(FQuery);
    for I := 0 to L - 1 do
    begin
      Setlength(Result[I].Ids, 0);
      Setlength(Result[I].FileNames, 0);
      Setlength(Result[I].Attr, 0);
      Result[I].Count := 0;
      Result[I].ImTh := '';
      if Result[I].Jpeg <> nil then
        Result[I].Jpeg.Free;
      Result[I].Jpeg := nil;
    end;
    Exit;
  end;

  for K := 0 to L - 1 do
  begin
    Setlength(Result[K].Ids, 0);
    Setlength(Result[K].FileNames, 0);
    Setlength(Result[K].Attr, 0);
    Len := 0;
    FQuery.First;
    for I := 1 to FQuery.RecordCount do
    begin

      Temp := FQuery.FieldByName('StrTh').AsVariant;
      if Temp = ThImS[K].ImTh then
      begin
        Inc(Len);
        Setlength(Result[K].Ids, Len);
        Setlength(Result[K].FileNames, Len);
        Setlength(Result[K].Attr, Len);
        Result[K].Ids[Len - 1] := FQuery.FieldByName('ID').AsInteger;
        Result[K].FileNames[Len - 1] := FQuery.FieldByName('FFileName').AsString;
        Result[K].Attr[Len - 1] := FQuery.FieldByName('Attr').AsInteger;
      end;
      FQuery.Next;
    end;
    Result[K].Count := Len;
    Result[K].ImTh := ThImS[K].ImTh;
  end;
  FreeDS(FQuery);
end;

function GetImageIDW(Image: string; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False; AThImageSize: Integer = 0;
  ADBJpegCompressionQuality: Byte = 0): TImageDBRecordA;
var
  Bmp, Thbmp: TBitmap;
  FileName, Imth, PassWord: string;
  G: TGraphic;
begin
  DoProcessPath(Image);
  if AThImageSize = 0 then
    AThImageSize := ThImageSize;
  if ADBJpegCompressionQuality = 0 then
    ADBJpegCompressionQuality := DBJpegCompressionQuality;
  Result.Crypt := False;
  Result.Password := '';
  Result.UsedFileNameSearch := False;
  Result.IsError := False;
  G := nil;
  FileName := Image;
  Result.Jpeg := nil;
  try
    if ValidCryptGraphicFile(FileName) then
    begin
      Result.Crypt := True;
      Password := DBKernel.FindPasswordForCryptImageFile(FileName);
      Result.Password := Password;
      if PassWord = '' then
      begin
        if G <> nil then
          G.Free;
        Result.Count := 0;
        Result.ImTh := '';
        Exit;
      end;
      try
        G := DeCryptGraphicFile(FileName, PassWord);
      except
        if G <> nil then
          G.Free;
        Result.Count := 0;
        Exit;
      end;
    end
    else
    begin
      Result.Crypt := False;
      G := GetGraphicClass(GetExt(FileName), False).Create;
      G.LoadFromFile(FileName);
    end;
  except
    on E: Exception do
    begin
      Result.IsError := True;
      Result.ErrorText := E.message;
      if G <> nil then
        G.Free;
      Result.Count := 0;
      Exit;
    end;
  end;
  Result.OrWidth := G.Width;
  Result.OrHeight := G.Height;
  try
    JpegScale(G, AThImageSize, AThImageSize);
    Result.Jpeg := TJpegImage.Create;
    Result.Jpeg.CompressionQuality := ADBJpegCompressionQuality;
    Bmp := Tbitmap.Create;
    Bmp.PixelFormat := Pf24bit;
    Thbmp := Tbitmap.Create;
    Thbmp.PixelFormat := Pf24bit;
    if Max(G.Width, G.Height) > AThImageSize then
    begin
      if G.Width > G.Height then
      begin
        Thbmp.Width := AThImageSize;
        Thbmp.Height := Round(AThImageSize * (G.Height / G.Width));
   end else
      begin
        Thbmp.Width := Round(AThImageSize * (G.Width / G.Height));
        Thbmp.Height := AThImageSize;
      end;
  end else begin
      Thbmp.Width := G.Width;
      Thbmp.Height := G.Height;
    end;
    try
      LoadImageX(G, Bmp, $FFFFFF);
      // bmp.assign(G); //+1
    except
      on E: Exception do
      begin
        EventLog(':GetImageIDW() throw exception: ' + E.message);
        Result.IsError := True;
        Result.ErrorText := E.message;

        Bmp.PixelFormat := Pf24bit;
        Bmp.Width := AThImageSize;
        Bmp.Height := AThImageSize;
        FillRectNoCanvas(Bmp, $FFFFFF);
        DrawIconEx(Bmp.Canvas.Handle, 70, 70, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 16, 16, 0, 0, DI_NORMAL);
        Thbmp.Height := 100;
        Thbmp.Width := 100;
      end;
    end;
    if G <> nil then
      G.Free;
    DoResize(Thbmp.Width, Thbmp.Height, Bmp, Thbmp);
    Bmp.Free;
    Result.Jpeg.Assign(Thbmp); // +s
    try
      Result.Jpeg.JPEGNeeded;
    except
      on E: Exception do
      begin
        Result.IsError := True;
        Result.ErrorText := E.message;
      end;
    end;

    try
      Thbmp.Assign(Result.Jpeg);
    except
      on E: Exception do
      begin
        EventLog(':GetImageIDW() throw exception: ' + E.message);
        Result.IsError := True;
        Result.ErrorText := E.message;
        Thbmp.Width := Result.Jpeg.Width;
        Thbmp.Height := Result.Jpeg.Height;
        FillRectNoCanvas(Thbmp, $0);
      end;
    end;
    Imth := BitmapToString(Thbmp);
    Thbmp.Free;
    if OnlyImTh and not UseFileNameScanning then
    begin
      Result.ImTh := Imth;
    end
    else
    begin
      Result := GetImageIDTh(Imth);
      if (Result.Count = 0) and UseFileNameScanning then
      begin
        Result := GetImageIDFileName(FileName);
        Result.UsedFileNameSearch := True;
      end;
    end;
  except
    on E: Exception do
    begin
      Result.IsError := True;
      Result.ErrorText := E.message;
    end;
  end;
end;

procedure SetPrivate(ID: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Access=%d WHERE ID=%d', [Db_access_private, ID]));
end;

procedure UnSetPrivate(ID: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Access=%d WHERE ID=%d', [Db_access_none, ID]));
end;

function Xorstrings(S1, S2: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to 255 do
    Result := Result + ' ';
  for I := 1 to Min(Min(Length(S1), Length(S2)), 255) do
  begin
    Result[I] := Chr(Ord(S1[I]) xor Ord(S2[I]));
  end;
end;

function Setstringtolengthwithnodata(S: string; N: Integer): string;
var
  Cs, I: Integer;
begin
  Cs := 0;
  for I := 1 to Min(Length(S), N) do
    Cs := Cs + Ord(S[I]);
  Result := '';
  for I := 1 to N do
    Result := Result + ' ';
  for I := 1 to N do
    if I <= Length(S) then
      Result[I] := Chr((Ord(S[I]) xor I) xor Cs)
    else
      Result[I] := Chr((I + Cs) xor Cs);
end;

function GetHardwareString: string;
var
  I: Integer;
  LpDisplayDevice: TDisplayDevice;
  Cc, DwFlags: DWORD;
  EBXstr, ECXstr, EDXstr: string[5];
  Hardwarestring, S1: string;

  function GlobalMemoryStatus(index: Integer): Integer;
  var
    MemoryStatus: TMemoryStatus;
  begin
    with MemoryStatus do
    begin
      DwLength := SizeOf(TMemoryStatus);
      Windows.GlobalMemoryStatus(MemoryStatus);
      case index of
        1:
          Result := DwMemoryLoad;
        2:
          Result := DwTotalPhys div 1024;
        3:
          Result := DwAvailPhys div 1024;
        4:
          Result := DwTotalPageFile div 1024;
        5:
          Result := DwAvailPageFile div 1024;
        6:
          Result := DwTotalVirtual div 1024;
        7:
          Result := DwAvailVirtual div 1024;
      else
        Result := 0;
      end;
    end;
  end;

  function GettingKeybType: string; // Win95 or later and NT3.1 or later
  var
    Flag: Integer;
  begin
    Flag := 0;
    case GetKeyboardType(Flag) of
      1:
        Result := 'IBM PC/XT or compatible (83-key) keyboard';
      2:
        Result := 'Olivetti "ICO" (102-key) keyboard';
      3:
        Result := 'IBM PC/AT (84-key) or similar keyboard';
      4:
        Result := 'IBM enhanced (101- or 102-key) keyboard';
      5:
        Result := 'Nokia 1050 and similar keyboards';
      6:
        Result := 'Nokia 9140 and similar keyboards';
      7:
        Result := 'Japanese keyboard';
    end;
  end;

begin
  for I := 1 to 255 do
    Hardwarestring := Hardwarestring + ' ';
  S1 := Setstringtolengthwithnodata(Inttostr(GlobalMemoryStatus(2)), 255);
  Hardwarestring := Xorstrings(Hardwarestring, S1);
  S1 := '';
  LpDisplayDevice.Cb := Sizeof(LpDisplayDevice);
  DwFlags := 0;
  Cc := 0;
  while EnumDisplayDevices(nil, Cc, LpDisplayDevice, DwFlags) do
  begin
    Inc(Cc);
    S1 := S1 + LpDisplayDevice.DeviceString;
  end;
  S1 := Setstringtolengthwithnodata(S1, 255);
  Hardwarestring := Xorstrings(Hardwarestring, S1);
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
  S1 := EBXstr + '  ' + ECXstr + '  ' + EDXstr;
  S1 := Setstringtolengthwithnodata(S1, 255);
  Hardwarestring := Xorstrings(Hardwarestring, S1);
  S1 := Setstringtolengthwithnodata(GettingKeybType, 255);
  Hardwarestring := Xorstrings(Hardwarestring, S1);
  Result := Hardwarestring;
end;

function SaveIDsTofile(FileName: string; IDs: TArInteger): Boolean;
var
  I: Integer;
  X: array of Byte;
  FS: Tfilestream;
begin
  Result := False;
  if Length(IDs) = 0 then
    Exit;
  try
    FS := TFileStream.Create(Filename, FmOpenWrite or FmCreate);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    X[0] := Ord(' ');
    X[1] := Ord('F');
    X[2] := Ord('I');
    X[3] := Ord('L');
    X[4] := Ord('E');
    X[5] := Ord('-');
    X[6] := Ord('D');
    X[7] := Ord('B');
    X[8] := Ord('I');
    X[9] := Ord('D');
    X[10] := Ord('S');
    X[11] := Ord('-');
    X[12] := Ord('V');
    X[13] := Ord('1');
    Fs.write(Pointer(X)^, 14);
    for I := 0 to Length(IDs) - 1 do
      Fs.write(IDs[I], Sizeof(IDs[I]));
  except
    Fs.Free;
    Exit;
  end;
  Fs.Free;
  Result := True;
end;

function LoadIDsFromfile(FileName: string): string;
var
  I: Integer;
  X: array of Byte;
  Fs: TFileStream;
  Int: Integer;
  V1: Boolean;
begin
  SetLength(Result, 0);
  if not FileExists(FileName) then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenRead);
  except
    Exit;
  end;
  SetLength(X, 14);
  Fs.read(Pointer(X)^, 14);
  if (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
    (X[6] = Ord('D')) and (X[7] = Ord('B')) and (X[8] = Ord('I')) and (X[9] = Ord('D')) and (X[10] = Ord('S')) and
    (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1')) then
    V1 := True;
  for I := 1 to (Fs.Size - 14) div Sizeof(Integer) do
  begin
    Fs.read(Int, Sizeof(Integer));
    Result := Result + Inttostr(Int) + '$';
  end;
  Fs.Free;
end;

function LoadIDsFromfileA(FileName: string): TArInteger;
var
  Int, I: Integer;
  X: array of Byte;
  Fs: Tfilestream;
  V1: Boolean;
begin
  SetLength(Result, 0);
  if not FileExists(FileName) then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenRead);
  except
    Exit;
  end;
  SetLength(X, 14);
  Fs.read(Pointer(X)^, 14);
  if (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
    (X[6] = Ord('D')) and (X[7] = Ord('B')) and (X[8] = Ord('I')) and (X[9] = Ord('D')) and (X[10] = Ord('S')) and
    (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1')) then
    V1 := True
  else
    Exit;
  for I := 1 to (Fs.Size - 14) div SizeOf(Integer) do
  begin
    Fs.read(Int, Sizeof(Integer));
    SetLength(Result, Length(Result) + 1);
    Result[Length(Result) - 1] := Int;
  end;
  Fs.Free;
end;

function SaveImThsTofile(FileName: string; ImThs: TArstrings): Boolean;
var
  I: Integer;
  X: array of Byte;
  Fs: Tfilestream;
begin
  Result := False;
  if Length(ImThs) = 0 then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenWrite or FmCreate);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    X[0] := Ord(' ');
    X[1] := Ord('F');
    X[2] := Ord('I');
    X[3] := Ord('L');
    X[4] := Ord('E');
    X[5] := Ord('-');
    X[6] := Ord('I');
    X[7] := Ord('M');
    X[8] := Ord('T');
    X[9] := Ord('H');
    X[10] := Ord('S');
    X[11] := Ord('-');
    X[12] := Ord('V');
    X[13] := Ord('1');
    Fs.write(Pointer(X)^, 14);
    for I := 0 to Length(ImThs) - 1 do
      Fs.write(ImThs[I, 1], Length(ImThs[I]));
  except
    Fs.Free;
    Exit;
  end;
  Fs.Free;
  Result := True;
end;

function LoadImThsFromfileA(FileName: string): TArStrings;
var
  I: Integer;
  S: string;
  X: array of Byte;
  Fs: Tfilestream;
  V1: Boolean;
begin
  SetLength(Result, 0);
  if not FileExists(FileName) then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenRead);
  except
    Exit;
  end;
  SetLength(X, 14);
  Fs.read(Pointer(X)^, 14);
  if (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
    (X[6] = Ord('I')) and (X[7] = Ord('M')) and (X[8] = Ord('T')) and (X[9] = Ord('H')) and (X[10] = Ord('S')) and
    (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1')) then
    V1 := True
  else
  begin
    Fs.Free;
    Exit;
  end;
  for I := 1 to (Fs.Size - 14) div 200 do
  begin
    SetLength(S, 200);
    Fs.read(S[1], 200);
    SetLength(Result, Length(Result) + 1);
    Result[Length(Result) - 1] := S;
  end;
  Fs.Free;
end;

function HardwareStringToCode(Hs: string): string;
var
  I, J: Integer;
  S: Byte;
begin
  Hs := GetUserString;
  Result := '';
  for I := 1 to 8 do
  begin
    S := 0;
    for J := 1 to 32 do
      S := S + Ord(Hs[32 * (I - 1) + J - 1]);
    Result := Result + Inttohex(S, 2);
  end;
end;

function CodeToActivateCode(S: string): string;
var
  C, Intr, Sum, I: Integer;
  Hs: string;
begin
  Sum := 0;
  for I := 1 to Length(S) do
    Sum := Sum + Ord(S[I]);
  Result := '';
  for I := 1 to Length(S) div 2 do
  begin
    C := Hextointdef(S[2 * (I - 1) + 1] + S[2 * (I - 1) + 2], 0);
    Intr := Round(Abs($FF * Cos($FF * C + Sum + Sin(I))));
    Hs := Inttohex(Intr, 2);
    Result := Result + Hs;
  end;
end;

function GetUserString: string;
var
  S1, Hardwarestring: string;
begin
  Hardwarestring := Gethardwarestring;
  S1 := SidToStr(GetUserSID);
  S1 := Setstringtolengthwithnodata(S1, 255);
  Hardwarestring := Xorstrings(Hardwarestring, S1);
  Result := Hardwarestring;
end;

function AltKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_MENU)) and $8000) <> 0;
end;

function CtrlKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_CONTROL)) and $8000) <> 0;
end;

function ShiftKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_SHIFT)) and $8000) <> 0;
end;

procedure JPEGScale(Graphic: TGraphic; Width, Height: Integer);
var
  ScaleX, ScaleY, Scale: Extended;
begin
  if (Graphic is TJpegImage) then
  begin
    (Graphic as TJpegImage).Performance := jpBestSpeed;
    (Graphic as TJpegImage).ProgressiveDisplay := False;
    ScaleX:= Graphic.Width / Width;
    ScaleY := Graphic.Height / Height;
    Scale := Max(ScaleX, ScaleY);
    if Scale < 2 then
      (Graphic as TJpegImage).Scale := JsFullSize;
    if (Scale >= 2) and (Scale < 4) then
      (Graphic as TJpegImage).Scale := JsHalf;
    if (Scale >= 4) and (Scale < 8) then
      (Graphic as TJpegImage).Scale := JsQuarter;
    if Scale >= 8 then
      (Graphic as TJpegImage).Scale := JsEighth;
  end;
end;

procedure ShowPropertiesDialog(FName: string);
var
  SExInfo: TSHELLEXECUTEINFO;
begin
  ZeroMemory(Addr(SExInfo), SizeOf(SExInfo));
  SExInfo.CbSize := SizeOf(SExInfo);
  SExInfo.LpFile := PWideChar(FName);
  SExInfo.LpVerb := 'Properties';
  SExInfo.FMask := SEE_MASK_INVOKEIDLIST;
  ShellExecuteEx(Addr(SExInfo));
end;

function MrsGetFileType(StrFilename: string): string;
var
  FileInfo: TSHFileInfo;
begin
  FillChar(FileInfo, SizeOf(FileInfo), #0);
  SHGetFileInfo(PWideChar(StrFilename), 0, FileInfo, SizeOf(FileInfo), SHGFI_TYPENAME);
  Result := FileInfo.SzTypeName;
end;

procedure CreateBuffer(Names: array of string; var P: TBuffer);
var
  I: Integer;
  S: string;
begin
  for I := 0 to Length(Names) - 1 do
  begin
    if S = '' then
    begin
      S := Names[I];
    end
    else
    begin
      S := S + #0 + Names[I];
    end;
  end;
  S := S + #0#0;
  SetLength(P, Length(S));
  for I := 1 to Length(S) do
    P[I - 1] := S[I];
end;

function CopyFilesSynch(Handle: Hwnd; Src: array of string; Dest: string; Move: Boolean; AutoRename: Boolean): Integer;
var
  SHFileOpStruct: TSHFileOpStruct;
  SrcBuf: TBuffer;
begin
  Result := -1;
  Inc(CopyFilesSynchCount);
  try
    CreateBuffer(Src, SrcBuf);
    with SHFileOpStruct do
    begin
      Wnd := Handle;
      WFunc := FO_COPY;
      if Move then
        WFunc := FO_MOVE;
      PFrom := Pointer(SrcBuf);
      PTo := PWideChar(Dest);
      FFlags := 0;
      if AutoRename then
        FFlags := FOF_RENAMEONCOLLISION;
      FAnyOperationsAborted := False;
      HNameMappings := nil;
      LpszProgressTitle := nil;
    end;
    Result := SHFileOperation(SHFileOpStruct);
    SrcBuf := nil;
  except
  end;
  Dec(CopyFilesSynchCount);
end;

procedure CopyFiles(Handle: Hwnd; Src: array of string; Dest: string; Move: Boolean; AutoRename: Boolean;
  CallBack: TCorrectPathProc = nil; ExplorerForm: TForm = nil);
begin
  TWindowsCopyFilesThread.Create(False, Handle, Src, Dest, Move, AutoRename, CallBack, ExplorerForm);
end;

function DeleteFiles(Handle: HWnd; Names: array of string; ToRecycle: Boolean): Integer;
var
  SHFileOpStruct: TSHFileOpStruct;
  Src: TBuffer;
begin
  CreateBuffer(Names, Src);
  with SHFileOpStruct do
  begin
    Wnd := Handle;
    WFunc := FO_DELETE;
    PFrom := Pointer(Src);
    PTo := nil;
    FFlags := 0;
    if ToRecycle then
      FFlags := FOF_ALLOWUNDO;
    FAnyOperationsAborted := False;
    HNameMappings := nil;
    LpszProgressTitle := nil;
  end;
  Result := SHFileOperation(SHFileOpStruct);
  Src := nil;
end;

function SilentDeleteFiles(Handle: HWnd; Names: array of string; ToRecycle: Boolean;
  HideErrors: Boolean = False): Integer;
var
  SHFileOpStruct: TSHFileOpStruct;
  Src: TBuffer;
begin
  CreateBuffer(Names, Src);
  with SHFileOpStruct do
  begin
    Wnd := Handle;
    WFunc := FO_DELETE;
    PFrom := Pointer(Src);
    PTo := nil;
    FFlags := FOF_NOCONFIRMATION;
    if HideErrors then
      FFlags := FFlags or FOF_SILENT or FOF_NOERRORUI;
    if ToRecycle then
      FFlags := FFlags or FOF_ALLOWUNDO;
    FAnyOperationsAborted := False;
    HNameMappings := nil;
    LpszProgressTitle := nil;
  end;
  Result := SHFileOperation(SHFileOpStruct);
  Src := nil;
end;

function GetCDVolumeLabel(CDName: Char): string;
var
  VolumeName, FileSystemName: array [0 .. MAX_PATH - 1] of Char;
  VolumeSerialNo: DWord;
  MaxComponentLength, FileSystemFlags: Cardinal;
begin
  GetVolumeInformation(PWideChar(CDName + ':\'), VolumeName, MAX_PATH, @VolumeSerialNo, MaxComponentLength,
    FileSystemFlags, FileSystemName, MAX_PATH);
  Result := VolumeName;
end;

function DriveState(Driveletter: AnsiChar): TDriveState;
var
  Mask: string[6];
  SRec: TSearchRec;
  OldMode: Cardinal;
  Retcode: Integer;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  Mask := '?:\*.*';
  Mask[1] := Driveletter;
{$I-} { не возбуждаем исключение при неудаче }
  Retcode := FindFirst(Mask, FaAnyfile, SRec);
  FindClose(SRec);
{$I+}
  case Retcode of
    0:
      Result := DS_DISK_WITH_FILES; { обнаружен по крайней мере один файл }
    -18:
      Result := DS_EMPTY_DISK; { никаких файлов не обнаружено, но ok }
    -21:
      Result := DS_NO_DISK; { DOS ERROR_NOT_READY }
  else
    Result := DS_UNFORMATTED_DISK; { в моей системе значение равно -1785! }
  end;
  SetErrorMode(OldMode);
end;

procedure ShowMyComputerProperties(Hwnd: THandle);
var
  PMalloc: IMalloc;
  Desktop: IShellFolder;
  Mnu: IContextMenu;
  Hr: HRESULT;
  PidlDrives: PItemIDList;
  Cmd: TCMInvokeCommandInfo;
begin
  Hr := SHGetMalloc(PMalloc);
  if SUCCEEDED(Hr) then
    try
      Hr := SHGetDesktopFolder(Desktop);
      if SUCCEEDED(Hr) then
        try
          Hr := SHGetSpecialFolderLocation(Hwnd, CSIDL_DRIVES, PidlDrives);
          if SUCCEEDED(Hr) then
            try
              Hr := Desktop.GetUIObjectOf(Hwnd, 1, PidlDrives, IContextMenu, nil, Pointer(Mnu));
              if SUCCEEDED(Hr) then
                try
                  FillMemory(@Cmd, Sizeof(Cmd), 0);
                  with Cmd do
                  begin
                    CbSize := Sizeof(Cmd);
                    FMask := 0;
                    Hwnd := 0;
                    LpVerb := PAnsiChar('Properties');
                    NShow := SW_SHOWNORMAL;
                  end;
                  Hr := Mnu.InvokeCommand(Cmd);
                finally
                  Mnu := nil;
                end;
            finally
              PMalloc.Free(PidlDrives);
            end;
        finally
          Desktop := nil;
        end;
    finally
      PMalloc := nil;
    end;
end;

function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.DwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.SzExeFile)) = UpperCase(ExeFileName)) or
        (UpperCase(FProcessEntry32.SzExeFile) = UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.Th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure LoadNickJpegImage(Image: TImage);
var
  Pic: Tpicture;
  Bmp, Bitmap: Tbitmap;
  FJPG: TJpegImage;
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create();
  OpenPictureDialog.Filter := GetGraphicFilter;
  if OpenPictureDialog.Execute then
  begin
    Pic := TPicture.Create;
    try
      Pic.LoadFromFile(OpenPictureDialog.FileName);
    except
      Pic.Free;
      OpenPictureDialog.Free;
      Exit;
    end;
    JpegScale(Pic.Graphic, 48, 48);
    Bitmap := TBitmap.Create;
    Bitmap.PixelFormat := Pf24Bit;
    Bitmap.Assign(Pic.Graphic);
    Pic.Free;
    Bmp := Tbitmap.Create;
    Bmp.PixelFormat := Pf24bit;
    if Bitmap.Width > Bitmap.Height then
    begin
      if Bitmap.Width > 48 then
        Bmp.Width := 48
      else
        Bmp.Width := Bitmap.Width;
      Bmp.Height := Round(Bmp.Width * (Bitmap.Height / Bitmap.Width));
    end
    else
    begin
      if Bitmap.Height > 48 then
        Bmp.Height := 48
      else
        Bmp.Height := Bitmap.Height;
      Bmp.Width := Round(Bmp.Height * (Bitmap.Width / Bitmap.Height));
    end;
    DoResize(Bmp.Width, Bmp.Height, Bitmap, Bmp);
    Bitmap.Free;
    Fjpg := TJPegImage.Create;
    Fjpg.CompressionQuality := DBJpegCompressionQuality;
    Fjpg.Assign(Bmp);
    Fjpg.JPEGNeeded;
    if Image.Picture.Graphic = nil then
      Image.Picture.Graphic := TJpegImage.Create;
    Image.Picture.Graphic.Assign(Fjpg);
    Image.Refresh;
    Fjpg.Free;
    Bmp.Free;
    OpenPictureDialog.Free;
  end;
end;

function ExtractAssociatedIcon_(FileName: string): HICON;
var
  I: Word;
  B: array [0 .. 2048] of Char;
begin
  I := 1;
  Result := ExtractAssociatedIcon(Application.Handle, StrLCopy(B, PWideChar(FileName), SizeOf(B) - 1), I);
end;

function ExtractAssociatedIcon_W(FileName: string; IconIndex: Word): HICON;
var
  B: array [0 .. 2048] of Char;
begin
  Result := ExtractAssociatedIcon(Application.Handle, StrLCopy(B, PWideChar(FileName), SizeOf(B) - 1), IconIndex);
end;

procedure DoHelp;
begin
  ShellExecute(0, nil, 'http://photodb.illusdolphin.net', nil, nil, SW_NORMAL);
end;

procedure DoUpdateHelp;
begin
  if FileExists(ProgramDir + 'Help\photodb_updating.htm') then
    ShellExecute(0, nil, PWideChar(ProgramDir + 'Help\photodb_updating.htm'), nil, nil, SW_NORMAL);
end;

procedure DoHomePage;
begin
  ShellExecute(0, nil, PWideChar(HomeURL), nil, nil, SW_NORMAL);
end;

procedure DoHomeContactWithAuthor;
begin
  ShellExecute(0, nil, PWideChar('mailto:' + ProgramMail + '?subject=''''' + ProductName + ''''''), nil, nil,
    SW_NORMAL);
end;

procedure DoGetCode(S: string);
begin
  ShellExecute(0, nil, PWideChar('mailto:' + ProgramMail + '?subject=''''' + ProductName +
        ''''' REGISTRATION CODE = ''''' + S + ''''''), nil, nil, SW_NORMAL);
end;

procedure UpdateImageThInLinks(OldImageTh, NewImageTh: string);
var
  FQuery: TDataSet;
  IDs: TArInteger;
  Links: TArStrings;
  I, J: Integer;
  Info: TArLinksInfo;
  Link, OldImageThCode: string;
  Table: TDataSet;
begin
  if OldImageTh = NewImageTh then
    Exit;
  if not DBKernel.ReadBool('Options', 'CheckUpdateLinks', False) then
    Exit;
  FQuery := GetQuery;
  OldImageThCode := CodeExtID(OldImageTh);
  SetSQL(FQuery, 'Select ID, Links from $DB$ where Links like "%' + OldImageThCode + '%"');
  try
    FQuery.Active := True;
  except
    FreeDS(FQuery);
    Exit;
  end;
  if FQuery.RecordCount = 0 then
  begin
    FreeDS(FQuery);
    Exit;
  end;
  FQuery.First;
  SetLength(IDs, 0);
  SetLength(Links, 0);
  for I := 1 to FQuery.RecordCount do
  begin
    SetLength(IDs, Length(IDs) + 1);
    IDs[Length(IDs) - 1] := FQuery.FieldByName('ID').AsInteger;
    SetLength(Links, Length(Links) + 1);
    Links[Length(Links) - 1] := FQuery.FieldByName('Links').AsString;
    FQuery.Next;
  end;
  FQuery.Close;
  FreeDS(FQuery);
  SetLength(Info, Length(Links));
  for I := 0 to Length(IDs) - 1 do
  begin
    Info[I] := ParseLinksInfo(Links[I]);
    for J := 0 to Length(Info[I]) - 1 do
    begin
      if Info[I, J].LinkType = LINK_TYPE_ID_EXT then
        if Info[I, J].LinkValue = OldImageThCode then
        begin
          Info[I, J].LinkValue := CodeExtID(NewImageTh);
        end;
    end;
  end;
  // correction
  // Access
  Table := GetQuery;
  for I := 0 to Length(IDs) - 1 do
  begin
    Link := CodeLinksInfo(Info[I]);
    SetSQL(Table, 'Update $DB$ set Links="' + Link + '" where ID = ' + IntToStr(IDs[I]));
    ExecSQL(Table);
  end;
end;

procedure UpdateImageRecord(FileName: string; ID: Integer);
begin
  UpdateImageRecordEx(FileName, ID, nil);
end;

procedure UpdateImageRecordEx(FileName: string; ID: Integer; OnDBKernelEvent: TOnDBKernelEventProcedure);
var
  Table: TDataSet;
  Res: TImageDBRecordA;
  Dublicat, IsDate, IsTime, UpdateDateTime: Boolean;
  I, Attr, Counter: Integer;
  EventInfo: TEventValues;
  Exif: TEXIF;
  EF: TEventFields;
  Path, OldImTh, Folder, _SetSql: string;
  Crc: Cardinal;
  DateToAdd, ATime: TDateTime;
  Ms: TMemoryStream;

  function Next: Integer;
  begin
    Result := Counter;
    Inc(Counter);
  end;

  procedure DoDBkernelEvent(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
  begin
    if Assigned(OnDBKernelEvent) then
    begin
      OnDBKernelEvent(Sender, ID, Params, Value);
    end
    else
    begin
      DBKernel.DoIDEvent(Sender, ID, Params, Value);
    end;
  end;

begin
  if ID = 0 then
    Exit;
  if FolderView then
    if not FileExists(FileName) then
      FileName := ProgramDir + FileName;

  FileName := LongFileNameW(FileName);
  for I := Length(FileName) - 1 downto 1 do
  begin
    if (FileName[I] = '\') and (FileName[I + 1] = '\') then
      Delete(FileName, I, 1);
  end;
  Res := GetimageIDW(FileName, False);
  if Res.Jpeg = nil then
    Exit;

  IsDate := False;
  IsTime := False;
  DateToAdd := 0;
  ATime := 0;
  // ----
  if GetDBType = DB_TYPE_MDB then
  begin
    Table := GetQuery;
    SetSQL(Table, 'Select StrTh,Attr from $DB$ where ID = ' + IntToStr(ID));
    try
      Table.Open;
      OldImTh := Table.FieldByName('StrTh').AsString;
      Attr := Table.FieldByName('Attr').AsInteger;
      Table.Close;
      _SetSql := 'FFileName=:FFileName,';
      _SetSql := _SetSql + 'Name=:Name,';
      _SetSql := _SetSql + 'StrTh=:StrTh,';
      _SetSql := _SetSql + 'StrThCrc=:StrThCrc,';
      _SetSql := _SetSql + 'thum=:thum,';

      _SetSql := _SetSql + Format('Width=%d,', [Res.OrWidth]);
      _SetSql := _SetSql + Format('Height=%d,', [Res.OrHeight]);
      _SetSql := _SetSql + Format('FileSize=%d,', [GetFileSizeByName(ProcessPath(FileName))]);

      if not FolderView then
      begin
        Folder := GetDirectory(FileName);
        UnProcessPath(Folder);
        UnFormatDir(Folder);
        CalcStringCRC32(AnsiLowerCase(Folder), Crc);
      end
      else
      begin
        Folder := GetDirectory(FileName);
        UnProcessPath(Folder);
        Delete(Folder, 1, Length(ProgramDir));
        UnformatDir(Folder);
        CalcStringCRC32(AnsiLowerCase(Folder), Crc);
        FormatDir(Folder);
      end;
      _SetSql := _SetSql + Format('FolderCRC=%d,', [Crc]);

      UpdateDateTime := False;
      if DBKernel.ReadBool('Options', 'FixDateAndTime', True) then
      begin
        Exif := TExif.Create;
        try
          Exif.ReadFromFile(FileName);
          if YearOf(Exif.Date) > 2000 then
          begin
            UpdateDateTime := True;
            DateToAdd := Exif.Date;
            ATime := Exif.Time;
            IsDate := True;
            IsTime := True;
            EventInfo.Date := Exif.Date;
            EventInfo.Time := Exif.Time;
            EventInfo.IsDate := True;
            EventInfo.IsTime := True;
            EF := [EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate, EventID_Param_IsTime];
            DoDBkernelEvent(nil, ID, EF, EventInfo);
            _SetSql := _SetSql + 'DateToAdd=:DateToAdd,';
            _SetSql := _SetSql + 'aTime=:aTime,';
            _SetSql := _SetSql + 'IsDate=:IsDate,';
            _SetSql := _SetSql + 'IsTime=:IsTime,';
          end;
        except
          on E: Exception do
            EventLog(':UpdateImageRecordEx()/FixDateAndTime throw exception: ' + E.message);
        end;
        Exif.Free;
      end;

      if Attr = Db_attr_dublicate then
      begin
        Dublicat := False;
        for I := 0 to Res.Count - 1 do
          if Res.IDs[I] <> ID then
            if Res.Attr[I] <> Db_attr_not_exists then
            begin
              Dublicat := True;
              Break;
            end;
        if not Dublicat then
        begin
          _SetSql := _SetSql + Format('Attr=%d,', [Db_attr_norm]);
          EventInfo.Attr := Db_attr_norm;
          DoDBkernelEvent(nil, ID, [EventID_Param_Attr], EventInfo);
        end;
      end;

      if Attr = Db_attr_not_exists then
      begin
        _SetSql := _SetSql + Format('Attr=%d,', [Db_attr_norm]);
        EventInfo.Attr := Db_attr_norm;
        DoDBkernelEvent(nil, ID, [EventID_Param_Attr], EventInfo);
      end;

      if _SetSql[Length(_SetSql)] = ',' then
        _SetSql := Copy(_SetSql, 1, Length(_SetSql) - 1);
      SetSQL(Table, 'Update $DB$ Set ' + _SetSql + ' where ID = ' + IntToStr(ID));
      if FolderView then
        Path := Folder + ExtractFilename(AnsiLowerCase(FileName))
      else
        Path := AnsiLowerCase(FileName);
      UnProcessPath(Path);

      SetStrParam(Table, Next, Path);

      SetStrParam(Table, Next, ExtractFileName(FileName));
      SetStrParam(Table, Next, Res.ImTh);
      SetIntParam(Table, Next, Integer(StringCRC(Res.ImTh)));
      // if crypted file not password entered
      if Res.Crypt or (Res.Password <> '') then
      begin
        MS := TMemoryStream.Create;
        try
          CryptGraphicImage(Res.Jpeg, Res.Password, MS);
          LoadParamFromStream(Table, Next, MS, FtBlob);
        finally
          MS.Free;
        end;
      end
      else
        AssignParam(Table, Next, Res.Jpeg);
      if UpdateDateTime then
      begin
        SetDateParam(Table, 'DateToAdd', DateToAdd);
        SetDateParam(Table, 'aTime', ATime);
        SetBoolParam(Table, Next, IsDate);
        SetBoolParam(Table, Next, IsTime);
      end;
      ExecSQL(Table);
    except
      on E: Exception do
        EventLog(':UpdateImageRecordEx()/ExecSQL throw exception: ' + E.message);
    end;
    Res.Jpeg.Free;
    FreeDS(Table);
    UpdateImageThInLinks(OldImTh, Res.ImTh);
    Exit;
  end;

  // ----
  Table := GetTable;
  Table.Active := True;
  EF := [];
  try
    if Table.Locate('ID', ID, [LoPartialKey]) then
    begin
      OldImTh := Table.FieldByName('StrTh').AsString;
      Table.Edit;
      Table.FieldByName('FFileName').AsString := AnsiLowerCase(FileName);
      Table.FieldByName('Name').AsString := ExtractFilename(FileName);
      Table.FieldByName('StrTh').AsString := Res.ImTh;
      Table.FieldByName('thum').Assign(Res.Jpeg);
      Table.FieldByName('Width').AsInteger := Res.OrWidth;
      Table.FieldByName('Height').AsInteger := Res.OrHeight;
      Table.FieldByName('FileSize').AsInteger := GetFileSizeByName(FileName);

      if DBKernel.ReadBool('Options', 'FixDateAndTime', True) then
      begin
        Exif := TExif.Create;
        try
          Exif.ReadFromFile(FileName);
          if YearOf(Exif.Date) > 2000 then
          begin
            Table.FieldByName('DateToAdd').AsDateTime := Exif.Date;
            Table.FieldByName('aTime').AsDateTime := Exif.Time;
            Table.FieldByName('IsDate').AsBoolean := True;
            Table.FieldByName('IsTime').AsBoolean := True;
            EventInfo.Date := Exif.Date;
            EventInfo.Time := Exif.Time;
            EventInfo.IsDate := True;
            EventInfo.IsTime := True;
            EF := [EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate, EventID_Param_IsTime];
            DoDBkernelEvent(nil, ID, EF, EventInfo);
          end;
        except
          on E: Exception do
            EventLog(':UpdateImageRecordEx()/FixDateAndTime throw exception: ' + E.message);
        end;
        Exif.Free;
      end;

      if Res.Crypt then
        CryptBlobStream(Table.FieldByName('thum'), Res.Password);

      if Table.FieldByName('Attr').AsInteger = Db_attr_dublicate then
      begin
        Dublicat := False;
        for I := 0 to Res.Count - 1 do
          if Res.IDs[I] <> ID then
            if Res.Attr[I] <> Db_attr_not_exists then
            begin
              Dublicat := True;
              Break;
            end;
        if not Dublicat then
        begin
          Table.FieldByName('Attr').AsInteger := Db_attr_norm;
          EventInfo.Attr := Db_attr_norm;
          DoDBkernelEvent(nil, ID, [EventID_Param_Attr], EventInfo);
        end;
      end;

      if Table.FieldByName('Attr').AsInteger = Db_attr_not_exists then
      begin
        Table.FieldByName('Attr').AsInteger := Db_attr_norm;
        EventInfo.Attr := Db_attr_norm;
        DoDBkernelEvent(nil, ID, [EventID_Param_Attr], EventInfo);
      end;

    end;
  finally
    Res.Jpeg.Free;
    FreeDS(Table);
  end;
  try
    UpdateImageThInLinks(OldImTh, Res.ImTh);
  except
    on E: Exception do
      EventLog(':UpdateImageRecordEx()/UpdateImageThInLinks throw exception: ' + E.message);
  end;
end;

procedure SetDesktopWallpaper(FileName: string; WOptions: Byte);
const
  CLSID_ActiveDesktop: TGUID = '{75048700-EF1F-11D0-9888-006097DEACF9}';
var
  ActiveDesktop: IActiveDesktop;
  P: PWideChar;
  S: string;
  Options: TWallPaperOpt;
begin
  ActiveDesktop := CreateComObject(CLSID_ActiveDesktop) as IActiveDesktop;
  S := FileName;
  GetMem(P, Length(S) * 2 + 1);
  ActiveDesktop.SetWallpaper(StringToWideChar(S, P, Length(S) * 2 + 1), 0);
  FreeMem(P);
  Options.DwSize := SizeOf(_tagWALLPAPEROPT);
  Options.DwStyle := WOptions;
  ActiveDesktop.SetWallpaperOptions(Options, 0);
  ActiveDesktop.ApplyChanges(AD_APPLY_ALL or AD_APPLY_FORCE);
end;

procedure RotateDBImage270(ID: Integer; OldRotation: Integer);
var
  EventInfo: TEventValues;
begin
  if ID <> 0 then
  begin
    case OldRotation of
      DB_IMAGE_ROTATED_0:
        EventInfo.Rotate := DB_IMAGE_ROTATED_270;
      DB_IMAGE_ROTATED_90:
        EventInfo.Rotate := DB_IMAGE_ROTATED_0;
      DB_IMAGE_ROTATED_180:
        EventInfo.Rotate := DB_IMAGE_ROTATED_90;
      DB_IMAGE_ROTATED_270:
        EventInfo.Rotate := DB_IMAGE_ROTATED_180;
    end;
    SetRotate(ID, EventInfo.Rotate);
    DBKernel.DoIDEvent(nil, ID, [EventID_Param_Rotate], EventInfo);
  end;
end;

procedure RotateDBImage90(ID: Integer; OldRotation: Integer);
var
  EventInfo: TEventValues;
begin
  if ID <> 0 then
  begin
    case OldRotation of
      DB_IMAGE_ROTATED_0:
        EventInfo.Rotate := DB_IMAGE_ROTATED_90;
      DB_IMAGE_ROTATED_90:
        EventInfo.Rotate := DB_IMAGE_ROTATED_180;
      DB_IMAGE_ROTATED_180:
        EventInfo.Rotate := DB_IMAGE_ROTATED_270;
      DB_IMAGE_ROTATED_270:
        EventInfo.Rotate := DB_IMAGE_ROTATED_0;
    end;
    SetRotate(ID, EventInfo.Rotate);
    DBKernel.DoIDEvent(nil, ID, [EventID_Param_Rotate], EventInfo);
  end;
end;

procedure RotateDBImage180(ID: Integer; OldRotation: Integer);
var
  EventInfo: TEventValues;
begin
  if ID <> 0 then
  begin
    case OldRotation of
      DB_IMAGE_ROTATED_0:
        EventInfo.Rotate := DB_IMAGE_ROTATED_180;
      DB_IMAGE_ROTATED_90:
        EventInfo.Rotate := DB_IMAGE_ROTATED_270;
      DB_IMAGE_ROTATED_180:
        EventInfo.Rotate := DB_IMAGE_ROTATED_0;
      DB_IMAGE_ROTATED_270:
        EventInfo.Rotate := DB_IMAGE_ROTATED_90;
    end;
    SetRotate(ID, EventInfo.Rotate);
    DBKernel.DoIDEvent(nil, ID, [EventID_Param_Rotate], EventInfo);
  end;
end;

function SendMail(const From, Dest, Subject, Text, FileName: PAnsiChar; Outlook: Boolean): Integer;
var
  message: TMapiMessage;
  Recipient, Sender: TMapiRecipDesc;
  File_Attachment: TMapiFileDesc;

  function MakeMessage: TMapiMessage;
  begin
    FillChar(Sender, SizeOf(Sender), 0);
    Sender.UlRecipClass := MAPI_ORIG;
    Sender.LpszAddress := From;

    FillChar(Recipient, SizeOf(Recipient), 0);
    Recipient.UlRecipClass := MAPI_TO;
    Recipient.LpszAddress := Dest;

    FillChar(File_Attachment, SizeOf(File_Attachment), 0);
    File_Attachment.NPosition := Cardinal(-1);
    File_Attachment.LpszPathName := FileName;

    FillChar(Result, SizeOf(Result), 0);
    with message do
    begin
      LpszSubject := Subject;
      LpszNoteText := Text;
      LpOriginator := @Sender;
      NRecipCount := 1;
      LpRecips := @Recipient;
      NFileCount := 1;
      LpFiles := @File_Attachment;
    end;
  end;

var
  SM: TFNMapiSendMail;
  MAPIModule: HModule;
  MAPI_FLAG: Cardinal;
begin
  if Outlook then
    MAPI_FLAG := MAPI_DIALOG
  else
    MAPI_FLAG := 0;
  MAPIModule := LoadLibrary(PWideChar(MAPIDLL));
  if MAPIModule = 0 then
    Result := -1
  else
    try
      @SM := GetProcAddress(MAPIModule, 'MAPISendMail');
      if @SM <> nil then
      begin
        MakeMessage;
        Result := SM(0, Application.Handle, message, MAPI_FLAG, 0);
      end
      else
        Result := 1;
    finally
      FreeLibrary(MAPIModule);
    end;
end;

procedure DBError(ErrorValue, Error: string);
var
  Body: TStrings;
begin
  Body := TStringList.Create;
  Body.Add('Error body:');
  Body.Add(ErrorValue);
  SendMail('', ProgramMail, PAnsiChar('Error in program [' + Error + ']'), PAnsichar(Body.Text), '', True);
  Body.Free;
end;

procedure StretchA(Width, Height: Integer; var S, D: TBitmap);
var
  I, J: Integer;
  P1: Pargb;
  Sh, Sw: Extended;
  Xp: array of PARGB;
begin
  D.Width := 100;
  D.Height := 100;
  Sw := S.Width / Width;
  Sh := S.Height / Height;
  SetLength(Xp, S.Height);
  for I := 0 to S.Height - 1 do
    Xp[I] := S.ScanLine[I];
  try
    for I := 0 to Height - 1 do
    begin
      P1 := D.ScanLine[I];
      for J := 0 to Width - 1 do
      begin
        P1[J].R := Xp[Round(Sh * (I)), Round(Sw * J)].R;
        P1[J].G := Xp[Round(Sh * (I)), Round(Sw * J)].G;
        P1[J].B := Xp[Round(Sh * (I)), Round(Sw * J)].B;
      end;
    end;
  except
  end;
end;

function Gistogramma(W, H: Integer; S: PARGBArray): TGistogrammData;
var
  I, J, Max: Integer;
  Ps: PARGB;
  LGray, LR, LG, LB: Byte;
begin

  /// сканирование изображение и подведение статистики
  for I := 0 to 255 do
  begin
    Result.Red[I] := 0;
    Result.Green[I] := 0;
    Result.Blue[I] := 0;
    Result.Gray[I] := 0;
  end;
  for I := 0 to H - 1 do
  begin
    Ps := S[I];
    for J := 0 to W - 1 do
    begin
      LR := Ps[J].R;
      LG := Ps[J].G;
      LB := Ps[J].B;
      LGray := Round(0.3 * LR + 0.59 * LG + 0.11 * LB);
      Inc(Result.Gray[LGray]);
      Inc(Result.Red[LR]);
      Inc(Result.Green[LG]);
      Inc(Result.Blue[LB]);
    end;
  end;

  /// поиск максимума
  Max := 1;
  Result.Max := 0;
  for I := 5 to 250 do
  begin
    if Max < Result.Red[I] then
    begin
      Max := Result.Red[I];
      Result.Max := I;
    end;
  end;
  for I := 5 to 250 do
  begin
    if Max < Result.Green[I] then
    begin
      Max := Result.Green[I];
      Result.Max := I;
    end;
  end;
  for I := 5 to 250 do
  begin
    if Max < Result.Blue[I] then
    begin
      Max := Result.Blue[I];
      Result.Max := I;
    end;
  end;

  /// в основном диапозоне 0..100
  for I := 0 to 255 do
  begin
    Result.Red[I] := Round(100 * Result.Red[I] / Max);
  end;

  // max:=1;
  for I := 0 to 255 do
  begin
    Result.Green[I] := Round(100 * Result.Green[I] / Max);
  end;

  // max:=1;
  for I := 0 to 255 do
  begin
    Result.Blue[I] := Round(100 * Result.Blue[I] / Max);
  end;

  // max:=1;
  for I := 0 to 255 do
  begin
    Result.Gray[I] := Round(100 * Result.Gray[I] / Max);
  end;

  /// ограничение на значение - изза нахождения максимума не во всём диапозоне
  for I := 0 to 255 do
  begin
    if Result.Red[I] > 255 then
      Result.Red[I] := 255;
  end;

  for I := 0 to 255 do
  begin
    if Result.Green[I] > 255 then
      Result.Green[I] := 255;
  end;

  for I := 0 to 255 do
  begin
    if Result.Blue[I] > 255 then
      Result.Blue[I] := 255;
  end;

  for I := 0 to 255 do
  begin
    if Result.Gray[I] > 255 then
      Result.Gray[I] := 255;
  end;

  // получаем границы диапозона
  Result.LeftEffective := 0;
  Result.RightEffective := 255;
  for I := 0 to 254 do
  begin
    if (Result.Gray[I] > 10) and (Result.Gray[I + 1] > 10) then
    begin
      Result.LeftEffective := I;
      Break;
    end;
  end;
  for I := 255 downto 1 do
  begin
    if (Result.Gray[I] > 10) and (Result.Gray[I - 1] > 10) then
    begin
      Result.RightEffective := I;
      Break;
    end;
  end;

end;

function CompareImagesByGistogramm(Image1, Image2: TBitmap): Byte;
var
  PRGBArr: PARGBArray;
  I: Integer;
  Diff: Byte;
  Data1, Data2, Data: TGistogrammData;
  Mx_r, Mx_b, Mx_g: Integer;
  ResultExt: Extended;

  function AbsByte(B1, B2: Integer): Integer;
  begin
    // if b1<b2 then Result:=b2-b1 else Result:=b1-b2;
    Result := B2 - B1;
  end;

  procedure RemovePicks;
  const
    InterpolateWidth = 10;
  var
    I, J, R, G, B: Integer;
    Ar, Ag, Ab: array [0 .. InterpolateWidth - 1] of Integer;
  begin
    Mx_r := 0;
    Mx_g := 0;
    Mx_b := 0;
    /// выкидываем пики резкие и сглаживаем гистограмму
    for J := 0 to InterpolateWidth - 1 do
    begin
      Ar[J] := 0;
      Ag[J] := 0;
      Ab[J] := 0;
    end;

    for I := 1 to 254 do
    begin
      Ar[I mod InterpolateWidth] := Data.Red[I];
      Ag[I mod InterpolateWidth] := Data.Green[I];
      Ab[I mod InterpolateWidth] := Data.Blue[I];

      R := 0;
      G := 0;
      B := 0;
      for J := 0 to InterpolateWidth - 1 do
      begin
        R := Ar[J] + R;
        G := Ag[J] + G;
        B := Ab[J] + B;
      end;
      Data.Red[I] := R div InterpolateWidth;
      Data.Green[I] := G div InterpolateWidth;
      Data.Blue[I] := B div InterpolateWidth;

      Mx_r := Mx_r + Data.Red[I];
      Mx_g := Mx_g + Data.Green[I];
      Mx_b := Mx_b + Data.Blue[I];
    end;

    Mx_r := Mx_r div 254;
    Mx_g := Mx_g div 254;
    Mx_b := Mx_b div 254;
  end;

begin
  Mx_r := 0;
  Mx_g := 0;
  Mx_b := 0;
  SetLength(PRGBArr, Image1.Height);
  for I := 0 to Image1.Height - 1 do
    PRGBArr[I] := Image1.ScanLine[I];
  Data1 := Gistogramma(Image1.Width, Image1.Height, PRGBArr);

  // ???GetGistogrammBitmapX(150,0,Data1.Red,a,a).SaveToFile('c:\w1.bmp');

  SetLength(PRGBArr, Image2.Height);
  for I := 0 to Image2.Height - 1 do
    PRGBArr[I] := Image2.ScanLine[I];
  Data2 := Gistogramma(Image2.Width, Image2.Height, PRGBArr);

  // ???GetGistogrammBitmapX(150,0,Data2.Red,a,a).SaveToFile('c:\w2.bmp');

  for I := 0 to 255 do
  begin
    Data.Green[I] := AbsByte(Data1.Green[I], Data2.Green[I]);
    Data.Blue[I] := AbsByte(Data1.Blue[I], Data2.Blue[I]);
    Data.Red[I] := AbsByte(Data1.Red[I], Data2.Red[I]);
  end;

  // ???GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w.bmp');

  RemovePicks;

  // ???GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w_pick.bmp');

  for I := 0 to 255 do
  begin
    Data.Green[I] := Abs(Data.Green[I] - Mx_g);
    Data.Blue[I] := Abs(Data.Blue[I] - Mx_b);
    Data.Red[I] := Abs(Data.Red[I] - Mx_r);
  end;

  // ?GetGistogrammBitmapX(50,25,Data.Red,a,a).SaveToFile('c:\w_mx.bmp');

  ResultExt := 10000;
  if Abs(Data2.Max - Data2.Max) > 20 then
    ResultExt := ResultExt / (Abs(Data2.Max - Data1.Max) / 20);

  if (Data2.LeftEffective > Data1.RightEffective) or (Data1.LeftEffective > Data2.RightEffective) then
  begin
    ResultExt := ResultExt / 10;
  end;
  if Abs(Data2.LeftEffective - Data1.LeftEffective) > 5 then
    ResultExt := ResultExt / (Abs(Data2.LeftEffective - Data1.LeftEffective) / 20);
  if Abs(Data2.RightEffective - Data1.RightEffective) > 5 then
    ResultExt := ResultExt / (Abs(Data2.RightEffective - Data1.RightEffective) / 20);

  for I := 0 to 255 do
  begin
    Diff := Round(Sqrt(Sqr(0.3 * Data.Red[I]) + Sqr(0.58 * Data.Green[I]) + Sqr(0.11 * Data.Blue[I])));
    if (Diff > 5) and (Diff < 10) then
      ResultExt := ResultExt * (1 - Diff / 1024);
    if (Diff >= 10) and (Diff < 20) then
      ResultExt := ResultExt * (1 - Diff / 512);
    if (Diff >= 20) and (Diff < 100) then
      ResultExt := ResultExt * (1 - Diff / 255);
    if Diff >= 100 then
      ResultExt := ResultExt * Sqr(1 - Diff / 255);
    if Diff = 0 then
      ResultExt := ResultExt * 1.02;
    if Diff = 1 then
      ResultExt := ResultExt * 1.01;
    if Diff = 2 then
      ResultExt := ResultExt * 1.001;
  end;
  // Result in 0..10000
  if ResultExt > 10000 then
    ResultExt := 10000;
  Result := Round(Power(101, ResultExt / 10000) - 1); // Result in 0..100
end;

function CompareImages(Image1, Image2: TGraphic; var Rotate: Integer; FSpsearch_ScanFileRotate: Boolean = True;
  Quick: Boolean = False; Raz: Integer = 60): TImageCompareResult;
type
  TCompareArray = array [0 .. 99, 0 .. 99, 0 .. 2] of Integer;
var
  B1, B2, B1_, B2_0: TBitmap;
  X1, X2_0, X2_90, X2_180, X2_270: TCompareArray;
  I: Integer;
  Res: array [0 .. 3] of TImageCompareResult;

  procedure FillArray(Image: TBitmap; var AArray: TCompareArray);
  var
    I, J: Integer;
    P: Pargb;
  begin
    for I := 0 to 99 do
    begin
      P := Image.ScanLine[I];
      for J := 0 to 99 do
      begin
        AArray[I, J, 0] := P[J].R;
        AArray[I, J, 1] := P[J].G;
        AArray[I, J, 2] := P[J].B;
      end;
    end;
  end;

  function CmpImages(Image1, Image2: TCompareArray): Byte;
  var
    X: TCompareArray;
    I, J, K: Integer;
    Diff, ResultExt: Extended;
  begin
    ResultExt := 10000;
    for I := 0 to 99 do
      for J := 0 to 99 do
        for K := 0 to 2 do
        begin
          X[I, J, K] := Abs(Image1[I, J, K] - Image2[I, J, K]);
        end;

    for I := 0 to 99 do
      for J := 0 to 99 do
      begin
        Diff := Round(Sqrt(Sqr(0.3 * X[I, J, 0]) + Sqr(0.58 * X[I, J, 1]) + Sqr(0.11 * X[I, J, 2])));
        if Diff > Raz then
          ResultExt := ResultExt * (1 - Diff / 1024);
        if Diff = 0 then
          ResultExt := ResultExt * 1.05;
        if Diff = 1 then
          ResultExt := ResultExt * 1.01;
        if Diff < 10 then
          ResultExt := ResultExt * 1.001;
      end;
    if ResultExt > 10000 then
      ResultExt := 10000;
    Result := Round(Power(101, ResultExt / 10000) - 1); // Result in 0..100
  end;

begin
  if Image1.Empty or Image2.Empty then
  begin
    Result.ByGistogramm := 0;
    Result.ByPixels := 0;
    Exit;
  end;
  B1 := TBitmap.Create;
  B2 := TBitmap.Create;
  B1.PixelFormat := Pf24bit;
  B2.PixelFormat := Pf24bit;
  B1.Assign(Image1);
  B2.Assign(Image2);

  B1_ := TBitmap.Create;
  B2_0 := TBitmap.Create;
  B1_.PixelFormat := Pf24bit;
  B2_0.PixelFormat := Pf24bit;
  if Quick then
  begin
    if (B1.Width = 100) and (B1.Height = 100) then
    begin
      B1_.Assign(B1);
    end
    else
      StretchA(100, 100, B1, B1_);
    B1.Free;
    FillArray(B1_, X1);
    if (B2.Width = 100) and (B2.Height = 100) then
    begin
      B2_0.Assign(B2);
    end
    else
      StretchA(100, 100, B2, B2_0);
    B2.Free;
    FillArray(B2_0, X2_0);
  end
  else
  begin
    if (B1.Width >= 100) and (B1.Height >= 100) then
      StretchCool(100, 100, B1, B1_)
    else
      Interpolate(0, 0, 100, 100, Rect(0, 0, B1.Width, B1.Height), B1, B1_);
    B1.Free;
    FillArray(B1_, X1);
    if (B2.Width >= 100) and (B2.Height >= 100) then
      StretchCool(100, 100, B2, B2_0)
    else
      Interpolate(0, 0, 100, 100, Rect(0, 0, B2.Width, B2.Height), B2, B2_0);
    B2.Free;
    FillArray(B2_0, X2_0);
  end;
  if not Quick then
    Result.ByGistogramm := CompareImagesByGistogramm(B1_, B2_0);
  B1_.Free;
  if FSpsearch_ScanFileRotate then
  begin
    Rotate90A(B2_0);
    FillArray(B2_0, X2_90);
    Rotate90A(B2_0);
    FillArray(B2_0, X2_180);
    Rotate90A(B2_0);
    FillArray(B2_0, X2_270);
  end;
  B2_0.Free;
  Res[0].ByPixels := CmpImages(X1, X2_0);
  if FSpsearch_ScanFileRotate then
  begin
    Res[3].ByPixels := CmpImages(X1, X2_90);
    Res[2].ByPixels := CmpImages(X1, X2_180);
    Res[1].ByPixels := CmpImages(X1, X2_270);
  end;
  Rotate := 0;
  Result.ByPixels := Res[0].ByPixels;
  if FSpsearch_ScanFileRotate then
    for I := 0 to 3 do
    begin
      if Res[I].ByPixels > Result.ByPixels then
      begin
        Result.ByPixels := Res[I].ByPixels;
        Rotate := I;
      end;
    end;
end;

function GetIdeDiskSerialNumberW: string;
var
  VolumeName, FileSystemName: array [0 .. MAX_PATH - 1] of Char;
  VolumeSerialNo: DWord;
  MaxComponentLength, FileSystemFlags: Cardinal;
begin
  GetVolumeInformation(PWideChar(Copy(Application.ExeName, 1, 3)), VolumeName, MAX_PATH, @VolumeSerialNo,
    MaxComponentLength, FileSystemFlags, FileSystemName, MAX_PATH);
  Result := IntToHex(VolumeSerialNo, 8);
end;

function GetIdeDiskSerialNumber: string;
type
  TSrbIoControl = packed record
    HeaderLength: ULONG;
    Signature: array [0 .. 7] of Char;
    Timeout: ULONG;
    ControlCode: ULONG;
    ReturnCode: ULONG;
    Length: ULONG;
  end;

  SRB_IO_CONTROL = TSrbIoControl;
  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    BFeaturesReg: Byte; // Used for specifying SMART "commands".
    BSectorCountReg: Byte; // IDE sector count register
    BSectorNumberReg: Byte; // IDE sector number register
    BCylLowReg: Byte; // IDE low order cylinder value
    BCylHighReg: Byte; // IDE high order cylinder value
    BDriveHeadReg: Byte; // IDE drive/head register
    BCommandReg: Byte; // Actual IDE command.
    BReserved: Byte; // reserved for future use. Must be zero.
  end;

  IDEREGS = TIDERegs;
  PIDERegs = ^TIDERegs;

  TSendCmdInParams = packed record
    CBufferSize: DWORD; // Buffer size in bytes
    IrDriveRegs: TIDERegs; // Structure with drive register values.
    BDriveNumber: Byte; // Physical drive number to send command to (0,1,2,3).
    BReserved: array [0 .. 2] of Byte; // Reserved for future expansion.
    DwReserved: array [0 .. 3] of DWORD; // For future use.
    BBuffer: array [0 .. 0] of Byte; // Input buffer.
  end;

  SENDCMDINPARAMS = TSendCmdInParams;
  PSendCmdInParams = ^TSendCmdInParams;

  TIdSector = packed record
    WGenConfig: Word;
    WNumCyls: Word;
    WReserved: Word;
    WNumHeads: Word;
    WBytesPerTrack: Word;
    WBytesPerSector: Word;
    WSectorsPerTrack: Word;
    WVendorUnique: array [0 .. 2] of Word;
    SSerialNumber: array [0 .. 19] of Char;
    WBufferType: Word;
    WBufferSize: Word;
    WECCSize: Word;
    SFirmwareRev: array [0 .. 7] of Char;
    SModelNumber: array [0 .. 39] of Char;
    WMoreVendorUnique: Word;
    WDoubleWordIO: Word;
    WCapabilities: Word;
    WReserved1: Word;
    WPIOTiming: Word;
    WDMATiming: Word;
    WBS: Word;
    WNumCurrentCyls: Word;
    WNumCurrentHeads: Word;
    WNumCurrentSectorsPerTrack: Word;
    UlCurrentSectorCapacity: ULONG;
    WMultSectorStuff: Word;
    UlTotalAddressableSectors: ULONG;
    WSingleWordDMA: Word;
    WMultiWordDMA: Word;
    BReserved: array [0 .. 127] of Byte;
  end;

  PIdSector = ^TIdSector;

const
  IDE_ID_FUNCTION = $EC;
  IDENTIFY_BUFFER_SIZE = 512;
  DFP_RECEIVE_DRIVE_DATA = $0007C088;
  IOCTL_SCSI_MINIPORT = $0004D008;
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001B0501;
  DataSize = Sizeof(TSendCmdInParams) - 1 + IDENTIFY_BUFFER_SIZE;
  BufferSize = SizeOf(SRB_IO_CONTROL) + DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE + 16;
var
  HDevice: THandle;
  CbBytesReturned: DWORD;
  PInData: PSendCmdInParams;
  POutData: Pointer; // PSendCmdInParams;
  Buffer: array [0 .. BufferSize - 1] of Byte;
  SrbControl: TSrbIoControl absolute Buffer;

  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    Ptr: PChar;
    I: Integer;
    C: Char;
  begin
    Ptr := @Data;
    for I := 0 to (Size shr 1) - 1 do
    begin
      C := Ptr^;
      Ptr^ := (Ptr + 1)^; (Ptr + 1)
      ^ := C;
      Inc(Ptr, 2);
    end;
  end;

begin
  if PortableWork then
  begin
    Result := GetIdeDiskSerialNumberW;
    Exit;
  end;
  Result := '';
  FillChar(Buffer, BufferSize, #0);
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin // Windows NT, Windows 2000
    // Get SCSI port handle
    HDevice := CreateFile('\\.\Scsi0:', GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, 0, 0);
    if HDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      SrbControl.HeaderLength := SizeOf(SRB_IO_CONTROL);
      System.Move('SCSIDISK', SrbControl.Signature, 8);
      SrbControl.Timeout := 2;
      SrbControl.Length := DataSize;
      SrbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
      PInData := PSendCmdInParams(PChar(@Buffer) + SizeOf(SRB_IO_CONTROL));
      POutData := PInData;
      with PInData^ do
      begin
        CBufferSize := IDENTIFY_BUFFER_SIZE;
        BDriveNumber := 0;
        with IrDriveRegs do
        begin
          BFeaturesReg := 0;
          BSectorCountReg := 1;
          BSectorNumberReg := 1;
          BCylLowReg := 0;
          BCylHighReg := 0;
          BDriveHeadReg := $A0;
          BCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(HDevice, IOCTL_SCSI_MINIPORT, @Buffer, BufferSize, @Buffer, BufferSize, CbBytesReturned,
        nil) then
        Exit;
    finally
      CloseHandle(HDevice);
    end;
  end
  else
  begin // Windows 95 OSR2, Windows 98
    HDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
    if HDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      PInData := PSendCmdInParams(@Buffer);
      POutData := PChar(@PInData^.BBuffer);
      with PInData^ do
      begin
        CBufferSize := IDENTIFY_BUFFER_SIZE;
        BDriveNumber := 0;
        with IrDriveRegs do
        begin
          BFeaturesReg := 0;
          BSectorCountReg := 1;
          BSectorNumberReg := 1;
          BCylLowReg := 0;
          BCylHighReg := 0;
          BDriveHeadReg := $A0;
          BCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(HDevice, DFP_RECEIVE_DRIVE_DATA, PInData, SizeOf(TSendCmdInParams) - 1, POutData,
        W9xBufferSize, CbBytesReturned, nil) then
        Exit;
    finally
      CloseHandle(HDevice);
    end;
  end;
  with PIdSector(PChar(POutData) + 16)^ do
  begin
    ChangeByteOrder(SSerialNumber, SizeOf(SSerialNumber));
    SetString(Result, SSerialNumber, SizeOf(SSerialNumber));
  end;
end;

procedure Delay(Msecs: Longint);
var
  FirstTick: Cardinal;
begin
  FirstTick := GetTickCount;
  repeat
    Application.ProcessMessages; { для того чтобы не "завесить" Windows }
  until (GetTickCount - FirstTick) >= Msecs;
end;

function ColorDiv2(Color1, COlor2: TColor): TColor;
begin
  Result := RGB((GetRValue(Color1) + GetRValue(Color2)) div 2, (GetGValue(Color1) + GetGValue(Color2)) div 2,
    (GetBValue(Color1) + GetBValue(Color2)) div 2);
end;

function ColorDarken(Color: TColor): TColor;
begin
  Result := RGB(Round(GetRValue(Color) / 1.2), (Round(GetGValue(Color) / 1.2)), (Round(GetBValue(Color) / 1.2)));
end;

function CreateDirA(Dir: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  if Dir[Length(Dir)] <> '\' then
    Dir := Dir + '\';
  if Length(Dir) < 3 then
    Exit;
  for I := 1 to Length(Dir) do
    try
      if (Dir[I] = '\') or (I = Length(Dir)) then
        if not CreateDir(Copy(Dir, 1, I)) then
        begin
          Result := False;
          Exit;
        end;
    except
      Result := False;
      Exit;
    end;
end;

function ValidDBPath(DBPath: string): Boolean;
var
  I: Integer;
  X: set of Char;
begin
  Result := True;
  X := [];
  if GetDBType(DBPath) = DB_TYPE_MDB then
    X := Validcharsmdb;
  for I := 1 to Length(DBPath) do
    if not(DBPath[I] in Validchars) then
    begin
      DBPath[I] := '?';
      Result := False;
      Exit;
    end;
end;

function CreateProgressBar(StatusBar: TStatusBar; index: Integer): TProgressBar;
var
  Findleft: Integer;
  I: Integer;
begin
  Result := TProgressBar.Create(Statusbar);
  Result.Parent := Statusbar;
  Result.Visible := True;
  Result.Top := 2;
  FindLeft := 0;
  for I := 0 to index - 1 do
    FindLeft := FindLeft + Statusbar.Panels[I].Width + 1;
  Result.Left := Findleft;
  Result.Width := Statusbar.Panels[index].Width - 4;
  Result.Height := Statusbar.Height - 2;
end;

function SaveListTofile(FileName: string; IDs: TArInteger; Files: TArStrings): Boolean;
var
  I: Integer;
  X: array of Byte;
  Fs: TFileStream;
  LenIDS, LenFiles, L: Integer;
begin
  Result := False;
  if Length(IDs) + Length(Files) = 0 then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenWrite or FmCreate);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    X[0] := Ord(' ');
    X[1] := Ord('F');
    X[2] := Ord('I');
    X[3] := Ord('L');
    X[4] := Ord('E');
    X[5] := Ord('-');
    X[6] := Ord('D');
    X[7] := Ord('B');
    X[8] := Ord('L');
    X[9] := Ord('S');
    X[10] := Ord('T');
    X[11] := Ord('-');
    X[12] := Ord('V');
    X[13] := Ord('1');
    Fs.write(Pointer(X)^, 14);
    LenIDS := Length(IDs);
    Fs.write(LenIDS, Sizeof(LenIDS));
    LenFiles := Length(Files);
    Fs.write(LenFiles, Sizeof(LenFiles));
    for I := 0 to LenIDS - 1 do
      Fs.write(IDs[I], Sizeof(IDs[I]));
    for I := 0 to LenFiles - 1 do
    begin
      L := Length(Files[I]);
      Fs.write(L, Sizeof(L));
      Fs.write(Files[I][1], L + 1);
    end;
  except
    Fs.Free;
    Exit;
  end;
  Fs.Free;
  Result := True;
end;

procedure LoadDblFromfile(FileName: string; var IDs: TArInteger; var Files: TArStrings);
var
  Int, I: Integer;
  X: array of Byte;
  Fs: Tfilestream;
  V1: Boolean;
  LenIDS, LenFiles, L: Integer;
  Str: string;
begin
  SetLength(IDs, 0);
  SetLength(Files, 0);
  if not FileExists(FileName) then
    Exit;
  try
    FS := TFileStream.Create(FileName, FmOpenRead);
  except
    Exit;
  end;
  SetLength(X, 14);
  Fs.read(Pointer(X)^, 14);
  if (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
    (X[6] = Ord('D')) and (X[7] = Ord('B')) and (X[8] = Ord('L')) and (X[9] = Ord('S')) and (X[10] = Ord('T')) and
    (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1')) then
    V1 := True
  else
  begin
    FS.Free;
    Exit;
  end;
  Fs.read(LenIDS, SizeOf(LenIDS));
  Fs.read(LenFiles, SizeOf(LenFiles));
  SetLength(IDs, LenIDS);
  SetLength(Files, LenFiles);
  for I := 1 to LenIDS do
  begin
    Fs.read(Int, Sizeof(Integer));
    IDs[I - 1] := Int;
  end;
  for I := 1 to LenFiles do
  begin
    Fs.read(L, Sizeof(L));
    SetLength(Str, L);
    Fs.read(Str[1], L + 1);
    Files[I - 1] := Str;
  end;
  Fs.Free;
end;

function IsWallpaper(FileName: string): Boolean;
var
  Str: string;
begin
  Str := GetExt(FileName);
  Result := (Str = 'HTML') or (Str = 'HTM') or (Str = 'GIF') or (Str = 'JPG') or (Str = 'JPEG') or (Str = 'JPE') or
    (Str = 'BMP');
  Result := Result and StaticPath(FileName);
end;

procedure LoadFIlesFromClipBoard(var Effects: Integer; Files: TStrings);
var
  Hand: THandle;
  Count: Integer;
  Pfname: array [0 .. 10023] of Char;
  CD: Cardinal;
  S: string;
  DwEffect: ^Word;
begin
  Effects := 0;
  Files.Clear;
  if IsClipboardFormatAvailable(CF_HDROP) then
  begin
    if OpenClipboard(Application.Handle) = False then
      Exit;
    CD := 0;
    repeat
      CD := EnumClipboardFormats(CD);
      if (CD <> 0) and (GetClipboardFormatName(CD, Pfname, 1024) <> 0) then
      begin
        S := UpperCase(string(Pfname));
        if Pos('DROPEFFECT', S) <> 0 then
        begin
          Hand := GetClipboardData(CD);
          if (Hand <> NULL) then
          begin
            DwEffect := GlobalLock(Hand);
            Effects := DwEffect^;
            GlobalUnlock(Hand);
          end;
          CD := 0;
        end;
      end;
    until (CD = 0);
    Hand := GetClipboardData(CF_HDROP);
    if (Hand <> NULL) then
    begin
      Count := DragQueryFile(Hand, $FFFFFFFF, nil, 0);
      if Count > 0 then
        repeat
          Dec(Count);
          DragQueryFile(Hand, Count, Pfname, 1024);
          Files.Add(string(Pfname));
        until (Count = 0);
      end;
      CloseClipboard();
    end;
  end;

  procedure Copy_Move(Copy: Boolean; FileList: TStrings);
  var
    HGlobal, ShGlobal: THandle;
    DropFiles: PDropFiles;
    REff: Cardinal;
    DwEffect: ^Word;
    RSize, ILen, I: Integer;
    Files: string;
  begin
    if (FileList.Count = 0) or (OpenClipboard(Application.Handle) = False) then
      Exit;

    Files := '';
    // File1#0File2#0#0
    for I := 0 to FileList.Count - 1 do
      Files := Files + FileList[I] + #0;
    Files := Files + #0;
    ILen := Length(Files);

    try
      EmptyClipboard;
      RSize := SizeOf(TDropFiles) + SizeOf(Char) * ILen;
      HGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, RSize);
      if HGlobal <> 0 then
      begin
        DropFiles := GlobalLock(HGlobal);
        DropFiles.PFiles := SizeOf(TDropFiles);
        DropFiles.FNC := False;
        DropFiles.FWide := True;

        Move(Files[1], (PByte(DropFiles) + SizeOf(TDropFiles))^, ILen * SizeOf(Char));

        GlobalUnlock(HGlobal);
        ShGlobal := SetClipboardData(CF_HDROP, HGlobal);
        if (ShGlobal <> 0) then
        begin
          HGlobal := GlobalAlloc(GMEM_MOVEABLE, SizeOf(DwEffect));
          if HGlobal <> 0 then
          begin
            DwEffect := GlobalLock(HGlobal);

            if Copy then
              DwEffect^ := DROPEFFECT_COPY
            else
              DwEffect^ := DROPEFFECT_MOVE;

            GlobalUnlock(HGlobal);

            REff := RegisterClipboardFormat(PWideChar('Preferred DropEffect')); // 'CFSTR_PREFERREDDROPEFFECT'));
            SetClipboardData(REff, HGlobal)
          end;
        end;
      end;
    finally
      CloseClipboard;
    end;
  end;

  function GetProgramFilesDirByKeyStr(KeyStr: string): string;
  var
    DwKeySize: DWORD;
    Key: HKEY;
    DwType: DWORD;
  begin
    if RegOpenKeyEx(Windows.HKEY_LOCAL_MACHINE, PChar(KeyStr), 0, KEY_READ, Key) = ERROR_SUCCESS then
      try
        RegQueryValueEx(Key, 'ProgramFilesDir', nil, @DwType, nil, @DwKeySize);
        if (DwType in [REG_SZ, REG_EXPAND_SZ]) and (DwKeySize > 0) then
        begin
          SetLength(Result, DwKeySize);
          RegQueryValueEx(Key, 'ProgramFilesDir', nil, @DwType, PByte(PChar(Result)), @DwKeySize);
        end
        else
        begin
          RegQueryValueEx(Key, 'ProgramFilesPath', nil, @DwType, nil, @DwKeySize);
          if (DwType in [REG_SZ, REG_EXPAND_SZ]) and (DwKeySize > 0) then
          begin
            SetLength(Result, DwKeySize);
            RegQueryValueEx(Key, 'ProgramFilesPath', nil, @DwType, PByte(PChar(Result)), @DwKeySize);
          end;
        end;
      finally
        RegCloseKey(Key);
      end;
  end;

  function GetProgramFilesDir: string;
  const
    DefaultProgramFilesDir = '%SystemDrive%\Program Files';
  var
    FolderName: string;
    DwStrSize: DWORD;
    I: Integer;
  begin
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      FolderName := GetProgramFilesDirByKeyStr('Software\Microsoft\Windows NT\CurrentVersion');
    end;
    if Length(FolderName) = 0 then
    begin
      FolderName := GetProgramFilesDirByKeyStr('Software\Microsoft\Windows\CurrentVersion');
    end;
    if Length(FolderName) = 0 then
      FolderName := DefaultProgramFilesDir;
    DwStrSize := ExpandEnvironmentStrings(PChar(FolderName), nil, 0);
    SetLength(Result, DwStrSize);
    ExpandEnvironmentStrings(PChar(FolderName), PChar(Result), DwStrSize);
    for I := 1 to Length(Result) do
      if Result[I] = #0 then
      begin
        Result := Copy(Result, 1, I - 1);
        Break;
      end;
  end;

  procedure DelDir(Dir: string; Mask: string);
  var
    Found: Integer;
    SearchRec: TSearchRec;
    F: Textfile;
  begin
    if Length(Dir) < 4 then
      Exit;
    if Dir[Length(Dir)] <> '\' then
      Dir := Dir + '\';
    Found := FindFirst(Dir + '*.*', FaAnyFile, SearchRec);
    while Found = 0 do
    begin
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
      begin
        if Fileexists(Dir + SearchRec.name) and Extinmask(Mask, Getext(Dir + SearchRec.name)) then
        begin
          try
            Filesetattr(Dir + SearchRec.name, 0);
            Assignfile(F, Dir + SearchRec.name);
{$I-}
            Erase(F);
{$I+}
          except
            ;
          end;
        end
        else if Directoryexists(Dir + SearchRec.name) then
          Deldir(Dir + SearchRec.name, Mask);
      end;
      Found := Sysutils.FindNext(SearchRec);
    end;
    FindClose(SearchRec);
    try
      Removedir(Dir);
    except
    end;
  end;

  function Mince(PathToMince: string; InSpace: Integer): string;
  { ========================================================= }
  // "C:\Program Files\Delphi\DDrop\TargetDemo\main.pas"
  // "C:\Program Files\..\main.pas"
  var
    Sl: TStringList;
    SHelp, SFile: string;
    IPos: Integer;

  begin
    SHelp := PathToMince;
    IPos := Pos('\', SHelp);
    if IPos = 0 then
    begin
      Result := PathToMince;
    end
    else
    begin
      Sl := TStringList.Create;
      // Decode string
      while IPos <> 0 do
      begin
        Sl.Add(Copy(SHelp, 1, (IPos - 1)));
        SHelp := Copy(SHelp, (IPos + 1), Length(SHelp));
        IPos := Pos('\', SHelp);
      end;
      if SHelp <> '' then
      begin
        Sl.Add(SHelp);
      end;
      // Encode string
      SFile := Sl[Sl.Count - 1];
      Sl.Delete(Sl.Count - 1);
      Result := '';
      while (Length(Result + SFile) < InSpace) and (Sl.Count <> 0) do
      begin
        Result := Result + Sl[0] + '\';
        Sl.Delete(0);
      end;
      if Sl.Count = 0 then
      begin
        Result := Result + SFile;
      end
      else
      begin
        Result := Result + '..\' + SFile;
      end;
      Sl.Free;
    end;
  end;

  function WindowsCopyFile(FromFile, ToDir: string): Boolean;
  var
    F: TShFileOpStruct;
  begin
    F.Wnd := 0;
    F.WFunc := FO_COPY;
    FromFile := FromFile + #0;
    F.PFrom := Pchar(FromFile);
    ToDir := ToDir + #0;
    F.PTo := Pchar(ToDir);
    F.FFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
    Result := ShFileOperation(F) = 0;
  end;

  function WindowsCopyFileSilent(FromFile, ToDir: string): Boolean;
  var
    F: TShFileOpStruct;
  begin
    F.Wnd := 0;
    F.WFunc := FO_COPY;
    FromFile := FromFile + #0;
    F.PFrom := Pchar(FromFile);
    ToDir := ToDir + #0;
    F.PTo := Pchar(ToDir);
    F.FFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    Result := ShFileOperation(F) = 0;
  end;

  { :Converts Ansi string to Unicode string using specified code page.
    @param   s        Ansi string.
    @param   codePage Code page to be used in conversion.
    @returns Converted wide string.
  }
  function StringToWideString(const S: AnsiString; CodePage: Word): WideString;
  var
    L: Integer;
  begin
    if S = '' then
      Result := ''
    else
    begin
      L := MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@S[1]), -1, nil, 0);
      SetLength(Result, L - 1);
      if L > 1 then
        MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@S[1]), -1, PWideChar(@Result[1]), L - 1);
    end;
  end; { StringToWideString }

  function CreateShortcutW(SourceFileName, ShortcutName: string; // the file the shortcut points to
    Location: ShortcutType; // shortcut location
    SubFolder, // subfolder of location
    WorkingDir, // working directory property of the shortcut
    Parameters, Description: string): // description property of the shortcut
    string;
  var
    MyObject: IUnknown;
    MySLink: IShellLink;
    MyPFile: IPersistFile;
    Directory, LinkName: string;
    WFileName: string;
    Reg: TRegIniFile;
    WideFileName: WideString;
    FS: TFileStream;
  begin

    MyObject := CreateComObject(CLSID_ShellLink);
    MySLink := MyObject as IShellLink;
    MyPFile := MyObject as IPersistFile;

    MySLink.SetPath(PWideChar(SourceFileName));
    MySLink.SetArguments(PWideChar(Parameters));
    MySLink.SetDescription(PWideChar(Description));

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
          _OTHERFOLDER:
            Directory := SubFolder;
          _DESKTOP:
            Directory := Reg.ReadString('Shell Folders', 'Desktop', '');
          _STARTMENU:
            Directory := Reg.ReadString('Shell Folders', 'Start Menu', '');
          _SENDTO:
            Directory := Reg.ReadString('Shell Folders', 'SendTo', '');
          _PROGRAMS:
            Directory := Reg.ReadString('Shell Folders', 'Programs', '');
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
        MySLink.SetWorkingDirectory(PWideChar(ExtractFilePath(SourceFileName)))
      else
        MySLink.SetWorkingDirectory(PWideChar(WorkingDir));

      try

        WideFileName := StringToWideString(WFileName, CP_ACP);

        FS := nil;
        try
          FS := TFileStream.Create(SourceFileName, FmShareExclusive);
        except
        end;
        MyPFile.Save(PWideChar(WideFileName), False);
        if FS <> nil then
          FS.Free;

      except
      end;
      Result := WFileName;
    end;
  end;

  procedure HideFromTaskBar(Handle: Thandle);
  var
    ExtendedStyle: Integer;
  begin
    ExtendedStyle := GetWindowLong(Application.Handle, GWL_EXSTYLE);
    SetWindowLong(Application.Handle, SW_SHOWMINNOACTIVE,
      WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_LTRREADING or WS_EX_LEFT or ExtendedStyle);
  end;

  function RandomPwd(PWLen: Integer; StrTable: string): string;
  var
    Y, I: Integer;
  begin
    Randomize;
    SetLength(Result, PWLen);
    Y := Length(StrTable);
    for I := 1 to PWLen do
    begin
      Result[I] := StrTable[Random(Y) + 1];
    end;
  end;

  procedure Del_Close_btn(Handle: Thandle);
  var
    HMenuHandle: HMENU;
  begin
    if (Handle <> 0) then
    begin
      HMenuHandle := GetSystemMenu(Handle, FALSE);
      if (HMenuHandle <> 0) then
        DeleteMenu(HMenuHandle, SC_CLOSE, MF_BYCOMMAND);
    end;
  end;

  function ChangeIconDialog(HOwner: THandle; var FileName: string; var IconIndex: Integer): Boolean;
  type
    SHChangeIconProc = function(Wnd: HWND; SzFileName: PChar; Reserved: Integer; var LpIconIndex: Integer): DWORD;
      stdcall;
    SHChangeIconProcW = function(Wnd: HWND; SzFileName: PWideChar; Reserved: Integer; var LpIconIndex: Integer): DWORD;
      stdcall;

  const
    Shell32 = 'shell32.dll';

  var
    ShellHandle: THandle;
    SHChangeIcon: SHChangeIconProc;
    SHChangeIconW: SHChangeIconProcW;
    Buf: array [0 .. MAX_PATH] of Char;
    BufW: array [0 .. MAX_PATH] of WideChar;
  begin
    Result := False;
    SHChangeIcon := nil;
    SHChangeIconW := nil;
    ShellHandle := Windows.LoadLibrary(PChar(Shell32));
    try
      if ShellHandle <> 0 then
      begin
        if Win32Platform = VER_PLATFORM_WIN32_NT then
          SHChangeIconW := GetProcAddress(ShellHandle, PChar(62))
        else
          SHChangeIcon := GetProcAddress(ShellHandle, PChar(62));
      end;
      if Assigned(SHChangeIconW) then
      begin
        StringToWideChar(FileName, BufW, SizeOf(BufW));
        Result := SHChangeIconW(HOwner, BufW, SizeOf(BufW), IconIndex) = 1;
        if Result then
          FileName := BufW;
      end
      else if Assigned(SHChangeIcon) then
      begin
        StrPCopy(Buf, FileName);
        Result := SHChangeIcon(HOwner, Buf, SizeOf(Buf), IconIndex) = 1;
        if Result then
          FileName := Buf;
      end
      else
        raise Exception.Create(SNotSupported);
    finally
      if ShellHandle <> 0 then
        FreeLibrary(ShellHandle);
    end;
  end;

  function GetProgramPath: string;
  begin
    Result := Application.ExeName;
  end;

  procedure SelectDB(DB: string);
  var
    EventInfo: TEventValues;
    DBVersion: Integer;

    procedure DoErrorMsg;
    begin
      if Screen.ActiveForm <> nil then
      begin
        MessageBoxDB(GetActiveFormHandle, Format(TEXT_MES_ERROR_DB_FILE_F, [DB]), TEXT_MES_ERROR, TD_BUTTON_OK,
          TD_ICON_ERROR);
      end;
    end;

  begin
    if FileExists(DB) then
    begin
      DBVersion := DBKernel.TestDBEx(DB);
      if DBkernel.ValidDBVersion(DB, DBVersion) then
      begin
        Dbname := DB;
        DBKernel.SetDataBase(DB);
        EventInfo.name := Dbname;
        LastInseredID := 0;
        DBKernel.DoIDEvent(nil, 0, [EventID_Param_DB_Changed], EventInfo);
      end
      else
      begin
        DoErrorMsg;
      end;
    end
    else
    begin
      DoErrorMsg;
    end;
  end;

  function SaveActionsTofile(FileName: string; Actions: TArstrings): Boolean;
  var
    I, Length: Integer;
    X: array of Byte;
    Fs: TFileStream;
  begin
    Result := False;
    if System.Length(Actions) = 0 then
      Exit;
    try
      Fs := TFileStream.Create(FileName, FmOpenWrite or FmCreate);
    except
      Exit;
    end;
    try
      SetLength(X, 14);
      X[0] := Ord(' ');
      X[1] := Ord('D');
      X[2] := Ord('B');
      X[3] := Ord('A');
      X[4] := Ord('C');
      X[5] := Ord('T');
      X[6] := Ord('I');
      X[7] := Ord('O');
      X[8] := Ord('N');
      X[9] := Ord('S');
      X[10] := Ord('-');
      X[11] := Ord('-');
      X[12] := Ord('V');
      X[13] := Ord('1');
      Fs.write(Pointer(X)^, 14);
      Length := System.Length(Actions);
      Fs.write(Length, SizeOf(Length));
      for I := 0 to System.Length(Actions) - 1 do
      begin
        Length := System.Length(Actions[I]);
        Fs.write(Length, SizeOf(Length));
        Fs.write(Actions[I, 1], System.Length(Actions[I]));
      end;
    except
      Fs.Free;
      Exit;
    end;
    Fs.Free;
    Result := True;
  end;

  function LoadActionsFromfileA(FileName: string): TArStrings;
  var
    I, Length: Integer;
    S: string;
    X: array of Byte;
    Fs: Tfilestream;
    V1: Boolean;
  begin
    SetLength(Result, 0);
    if not FileExists(FileName) then
      Exit;
    try
      Fs := Tfilestream.Create(Filename, FmOpenRead);
    except
      Exit;
    end;
    SetLength(X, 14);
    Fs.read(Pointer(X)^, 14);
    if (X[1] = Ord('D')) and (X[2] = Ord('B')) and (X[3] = Ord('A')) and (X[4] = Ord('C')) and (X[5] = Ord('T')) and
      (X[6] = Ord('I')) and (X[7] = Ord('O')) and (X[8] = Ord('N')) and (X[9] = Ord('S')) and (X[10] = Ord('-')) and
      (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1')) then
      V1 := True
    else
    begin
      Fs.Free;
      Exit;
    end;

    Fs.read(Length, SizeOf(Length));
    for I := 1 to Length do
    begin
      Fs.read(Length, SizeOf(Length));
      SetLength(S, Length);
      Fs.read(S[1], Length);
      SetLength(Result, System.Length(Result) + 1);
      Result[System.Length(Result) - 1] := S;
    end;
    Fs.Free;
  end;

  function GetDirectorySize(Folder: string): Int64;
  var
    Found: Integer;
    SearchRec: TSearchRec;
  begin
    Result := 0;
    try
      if Folder[Length(Folder)] <> '\' then
        Folder := Folder + '\';
      Found := FindFirst(Folder + '*.*', FaAnyFile, SearchRec);
      while Found = 0 do
      begin
        if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
        begin
          if FileExists(Folder + SearchRec.name) then
          begin
            try
              Result := Result + SearchRec.FindData.NFileSizeLow + SearchRec.FindData.NFileSizeHigh * 2 * MaxInt;
            except
              ;
            end;
          end
          else if DirectoryExists(Folder + SearchRec.name) then
            Result := Result + GetDirectorySize(Folder + '\' + SearchRec.name);
        end;
        Found := SysUtils.FindNext(SearchRec);
      end;
      FindClose(SearchRec);
    except
    end;
  end;

  procedure CopyFullRecordInfo(ID: Integer);
  var
    DS: TDataSet;
    I: Integer;
    S: string;
  begin
    if not DBInDebug then
      Exit;
    DS := GetQuery;
    SetSQL(DS, 'SELECT * FROM $DB$ WHERE id = ' + IntToStr(ID));
    DS.Open;
    S := '';
    for I := 0 to DS.Fields.Count - 1 do
    begin
      // if DS.FieldDefList[i].Name<>'StrTh' then
      begin
        if DS.Fields[I].DisplayText <> '(MEMO)' then
          S := S + DS.FieldDefList[I].name + ' = ' + DS.Fields[I].DisplayText + #13
        else
          S := S + DS.FieldDefList[I].name + ' = ' + DS.Fields[I].AsString + #13;
      end;
    end;
    MessageBoxDB(GetActiveFormHandle, S, TEXT_MES_INFORMATION, TD_BUTTON_OK, TD_ICON_INFORMATION);
    FreeDS(DS);
  end;

  function AnsiCompareTextWithNum(Text1, Text2: string): Integer;
  var
    S1, S2: string;

    function Num(Str: string): Boolean;
    var
      I: Integer;
    begin
      Result := True;
      for I := 1 to Length(Str) do
      begin
        if not CharInSet(Str[I], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
        begin
          Result := False;
          Break;
        end;
      end;
    end;

    function TrimNum(Str: string): string;
    var
      I: Integer;
    begin
      Result := Str;
      if Result <> '' then
        for I := 1 to Length(Result) do
        begin
          if not CharInSet(Result[I], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
          begin
            Delete(Result, 1, I - 1);
            Break;
          end;
        end;
      for I := 1 to Length(Result) do
      begin
        if not CharInSet(Result[I], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
        begin
          Result := Copy(Result, 1, I - 1);
          Break;
        end;
      end;
    end;

  begin
    S1 := TrimNum(Text1);
    S2 := TrimNum(Text2);
    if Num(S1) or Num(S2) then
    begin
      Result := StrToIntDef(S1, 0) - StrToIntDef(S2, 0);
      Exit;
    end;
    Result := AnsiCompareStr(Text1, Text2);
  end;

function FileTime2DateTime(FT: _FileTime): TDateTime;
var
  FileTime: _SystemTime;
begin
  FileTimeToLocalFileTime(FT, FT);
  FileTimeToSystemTime(FT, FileTime);
  Result := EncodeDate(FileTime.WYear, FileTime.WMonth, FileTime.WDay) + EncodeTime(FileTime.WHour, FileTime.WMinute,
    FileTime.WSecond, FileTime.WMilliseconds);
end;

function DateModify(FileName: string): TDateTime;
var
  Ts: TSearchRec;
begin
  Result := 0;
  if FindFirst(FileName, FaAnyFile, Ts) = 0 then
    Result := FileTime2DateTime(Ts.FindData.FtLastWriteTime);
end;

function GettingProcNum: Integer; // Win95 or later and NT3.1 or later
var
  Struc: _SYSTEM_INFO;
begin
  GetSystemInfo(Struc);
  Result := Struc.DwNumberOfProcessors;
end;

function GetWindowsUserName: string;
const
  CnMaxUserNameLen = 254;
var
  SUserName: string;
  DwUserNameLen: DWORD;
begin
  DwUserNameLen := CnMaxUserNameLen - 1;
  SetLength(SUserName, CnMaxUserNameLen);
  GetUserName(PWideChar(SUserName), DwUserNameLen);
  SetLength(SUserName, DwUserNameLen);
  Result := SUserName;
end;

  // SupportedExt
  procedure GetPhotosNamesFromDrive(Dir, Mask: string; var Files: TStrings; var MaxFilesCount: Integer;
    MaxFilesSearch: Integer; CallBack: TCallBackProgressEvent = nil);
  var
    Found: Integer;
    SearchRec: TSearchRec;
    Info: TProgressCallBackInfo;
  begin
    if Dir = '' then
      Exit;
    if Dir[Length(Dir)] <> '\' then
      Dir := Dir + '\';
    Found := FindFirst(Dir + '*.*', FaAnyFile, SearchRec);
    while Found = 0 do
    begin
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
      begin
        if FileExists(Dir + SearchRec.name) then
          Dec(MaxFilesCount);
        if MaxFilesCount < 0 then
          Break;
        if FileExists(Dir + SearchRec.name) and ExtinMask(Mask, GetExt(Dir + SearchRec.name)) then
        begin
          if Files.Count >= MaxFilesSearch then
            Break;
          Files.Add(Dir + SearchRec.name);
          if Files.Count >= MaxFilesSearch then
            Break;
          if Assigned(CallBack) then
          begin
            Info.MaxValue := -1;
            Info.Position := -1;
            Info.Information := Dir + SearchRec.name;
            Info.Terminate := False;
            CallBack(nil, Info);
            if Info.Terminate then
              Break;
          end;
        end
        else if DirectoryExists(Dir + SearchRec.name) then
          GetPhotosNamesFromDrive(Dir + SearchRec.name, Mask, Files, MaxFilesCount, MaxFilesSearch, CallBack);
      end;
      Found := SysUtils.FindNext(SearchRec);
    end;
    FindClose(SearchRec);
  end;

  function EXIFDateToDate(DateTime: string): TDateTime;
  var
    Yyyy, Mm, Dd: Word;
    D: string;
    DT: TDateTime;
  begin
    Result := 0;
    if TryStrToDate(DateTime, DT) then
    begin
      Result := DateOf(DT);
    end
    else
    begin
      D := Copy(DateTime, 1, 10);
      TryStrToDate(D, Result);
      if Result = 0 then
      begin
        Yyyy := StrToIntDef(Copy(DateTime, 1, 4), 0);
        Mm := StrToIntDef(Copy(DateTime, 6, 2), 0);
        Dd := StrToIntDef(Copy(DateTime, 9, 2), 0);
        if (Yyyy > 1990) and (Yyyy < 2050) then
          if (Mm >= 1) and (Mm <= 12) then
            if (Dd >= 1) and (Dd <= 31) then
              Result := EncodeDate(Yyyy, Mm, Dd);
      end;
    end;
  end;

  function EXIFDateToTime(DateTime: string): TDateTime;
  var
    // yyyy,mm,dd : Word;
    T: string;
    DT: TDateTime;
  begin
    Result := 0;
    if TryStrToTime(DateTime, DT) then
    begin
      Result := TimeOf(DT);
    end
    else
    begin
      T := Copy(DateTime, 12, 8);
      TryStrToTime(T, Result);
      Result := TimeOf(Result);
    end;
  end;

  function MessageBoxDB(Handle: THandle; AContent, Title, ADescription: string; Buttons, Icon: Integer): Integer;
    overload;
  begin
    Result := TaskDialogEx(Handle, AContent, Title, ADescription, Buttons, Icon, GetParamStrDBBool('NoVistaMsg'));
  end;

  function MessageBoxDB(Handle: THandle; AContent, Title: string; Buttons, Icon: Integer): Integer; overload;
  begin
    Result := MessageBoxDB(Handle, AContent, Title, '', Buttons, Icon);
  end;

  procedure TextToClipboard(const S: string);
  var
    N: Integer;
    Mem: Cardinal;
    Ptr: Pointer;
  begin
    try
      with Clipboard do
        try
          Open;
          if IsClipboardFormatAvailable(CF_UNICODETEXT) then
          begin
            N := (Length(S) + 1) * 2;
            Mem := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, N);
            Ptr := GlobalLock(Mem);
            Move(PWideChar(Widestring(S))^, Ptr^, N);
            GlobalUnlock(Mem);
            SetAsHandle(CF_UNICODETEXT, Mem);
          end;
          AsText := S;
          Mem := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, SizeOf(Dword));
          Ptr := GlobalLock(Mem);
          Dword(Ptr^) := (SUBLANG_NEUTRAL shl 10) or LANG_RUSSIAN;
          GlobalUnLock(Mem);
          SetAsHandle(CF_LOCALE, Mem);
        finally
          Close;
        end;
    except
    end;
  end;

  function GetActiveFormHandle: Integer;
  begin
    if Screen.ActiveForm <> nil then
      Result := Screen.ActiveForm.Handle
    else
      Result := 0;
  end;

  function GetGraphicFilter: string;
  var
    AllFormatsString: string;
    FormatsString, StrTemp: string;
    P, I: Integer;
    RAWFormats: string;

    procedure AddGraphicFormat(FormatName: string; Extensions: string; LastExtension: Boolean);
    begin
      FormatsString := FormatsString + FormatName + ' (' + Extensions + ')' + '|' + Extensions;
      if not LastExtension then
        FormatsString := FormatsString + '|';

      AllFormatsString := AllFormatsString + Extensions;
      if not LastExtension then
        AllFormatsString := AllFormatsString + ';';
    end;

  begin
    AllFormatsString := '';
    FormatsString := '';
    RAWFormats := '';
    if GraphicFilterString = '' then
    begin
      AddGraphicFormat('JPEG Image File', '*.jpg;*.jpeg;*.jfif;*.jpe;*.thm', False);
      AddGraphicFormat('Tiff images', '*.tiff;*.tif;*.fax', False);
      AddGraphicFormat('Portable network graphic images', '*.png', False);
      AddGraphicFormat('GIF Images', '*.gif', False);

      if IsRAWSupport then
      begin
        P := 1;
        for I := 1 to Length(RAWImages) do
          if (RAWImages[I] = '|') then
          begin
            StrTemp := Copy(RAWImages, P, I - P);

            RAWFormats := RAWFormats + '*.' + AnsiLowerCase(StrTemp);
            if I <> Length(RAWImages) then
              RAWFormats := RAWFormats + ';';
            P := I + 1;
          end;
        AddGraphicFormat('Camera RAW Images', RAWFormats, False);
      end;

      AddGraphicFormat('Bitmaps', '*.bmp;*.rle;*.dib', False);
      AddGraphicFormat('Photoshop images', '*.psd;*.pdd', False);
      AddGraphicFormat('Truevision images', '*.win;*.vst;*.vda;*.tga;*.icb', False);
      AddGraphicFormat('ZSoft Paintbrush images', '*.pcx;*.pcc;*.scr', False);
      AddGraphicFormat('Alias/Wavefront images', '*.rpf;*.rla', False);
      AddGraphicFormat('SGI true color images', '*.sgi;*.rgba;*.rgb;*.bw', False);
      AddGraphicFormat('Portable map images', '*.ppm;*.pgm;*.pbm', False);
      AddGraphicFormat('Autodesk images', '*.cel;*.pic', False);
      AddGraphicFormat('Kodak Photo-CD images', '*.pcd', False);
      AddGraphicFormat('Dr. Halo images', '*.cut', False);
      AddGraphicFormat('Paintshop Pro images', '*.psp', True);

      FormatsString := Format(TEXT_MES_ALL_FORMATS, [AllFormatsString]) + '|' + AllFormatsString + '|' + FormatsString;
      GraphicFilterString := FormatsString;
    end;
    Result := GraphicFilterString;
  end;

  function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
  var
    ROT: array [0 .. 3, 0 .. 3] of Integer;
  begin
    {
      DB_IMAGE_ROTATED_0   = 0;
      DB_IMAGE_ROTATED_90  = 1;
      DB_IMAGE_ROTATED_180 = 2;
      DB_IMAGE_ROTATED_270 = 3;
      }
    ROT[DB_IMAGE_ROTATED_0, DB_IMAGE_ROTATED_0] := DB_IMAGE_ROTATED_0;
    ROT[DB_IMAGE_ROTATED_0, DB_IMAGE_ROTATED_90] := DB_IMAGE_ROTATED_90;
    ROT[DB_IMAGE_ROTATED_0, DB_IMAGE_ROTATED_180] := DB_IMAGE_ROTATED_180;
    ROT[DB_IMAGE_ROTATED_0, DB_IMAGE_ROTATED_270] := DB_IMAGE_ROTATED_270;

    ROT[DB_IMAGE_ROTATED_90, DB_IMAGE_ROTATED_0] := DB_IMAGE_ROTATED_270;
    ROT[DB_IMAGE_ROTATED_90, DB_IMAGE_ROTATED_90] := DB_IMAGE_ROTATED_0;
    ROT[DB_IMAGE_ROTATED_90, DB_IMAGE_ROTATED_180] := DB_IMAGE_ROTATED_90;
    ROT[DB_IMAGE_ROTATED_90, DB_IMAGE_ROTATED_270] := DB_IMAGE_ROTATED_180;

    ROT[DB_IMAGE_ROTATED_180, DB_IMAGE_ROTATED_0] := DB_IMAGE_ROTATED_180;
    ROT[DB_IMAGE_ROTATED_180, DB_IMAGE_ROTATED_90] := DB_IMAGE_ROTATED_270;
    ROT[DB_IMAGE_ROTATED_180, DB_IMAGE_ROTATED_180] := DB_IMAGE_ROTATED_0;
    ROT[DB_IMAGE_ROTATED_180, DB_IMAGE_ROTATED_270] := DB_IMAGE_ROTATED_90;

    ROT[DB_IMAGE_ROTATED_270, DB_IMAGE_ROTATED_0] := DB_IMAGE_ROTATED_90;
    ROT[DB_IMAGE_ROTATED_270, DB_IMAGE_ROTATED_90] := DB_IMAGE_ROTATED_180;
    ROT[DB_IMAGE_ROTATED_270, DB_IMAGE_ROTATED_180] := DB_IMAGE_ROTATED_270;
    ROT[DB_IMAGE_ROTATED_270, DB_IMAGE_ROTATED_270] := DB_IMAGE_ROTATED_0;

    Result := ROT[OldRotation, NewRotation];
  end;

  procedure ExecuteQuery(SQL: string);
  var
    DS: TDataSet;
  begin
    DS := GetQuery;
    try
      SetSQL(DS, SQL);
      try
        ExecSQL(DS);
        EventLog('::ExecuteSQLExecOnCurrentDB()/ExecSQL OK [' + SQL + ']');
      except
        on E: Exception do
          EventLog(':ExecuteSQLExecOnCurrentDB()/ExecSQL throw exception: ' + E.message);
      end;
    finally
      FreeDS(DS);
    end;
  end;

  function ReadTextFileInString(FileName: string): string;
  var
    FS: TFileStream;
  begin
    if not FileExists(FileName) then
      Exit;
    try
      FS := TFileStream.Create(FileName, FmOpenRead);
    except
      on E: Exception do
      begin
        EventLog(':ReadTextFileInString() throw exception: ' + E.message);
        Exit;
      end;
    end;
    SetLength(Result, FS.Size);
    try
      FS.read(Result[1], FS.Size);
    except
      on E: Exception do
      begin
        EventLog(':ReadTextFileInString() throw exception: ' + E.message);
        Exit;
      end;
    end;
    FS.Free;
  end;

  procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
  begin
    case RotateValue of
      DB_IMAGE_ROTATED_270:
        Rotate270A(Bitmap);
      DB_IMAGE_ROTATED_90:
        Rotate90A(Bitmap);
      DB_IMAGE_ROTATED_180:
        Rotate180A(Bitmap);
    end;
  end;

  { TDBPopupMenuInfo }

  procedure TDBPopupMenuInfo.Add(MenuRecord: TDBPopupMenuInfoRecord);
  begin
    FData.Add(MenuRecord);
  end;

  procedure TDBPopupMenuInfo.Clear;
  var
    I: Integer;
  begin
    for I := 0 to FData.Count - 1 do
      TDBPopupMenuInfoRecord(FData[I]).Free;
    FData.Clear;
  end;

  constructor TDBPopupMenuInfo.Create;
  begin
    FData := TList.Create;
  end;

  destructor TDBPopupMenuInfo.Destroy;
  begin
    Clear;
    FData.Free;
    inherited;
  end;

  function TDBPopupMenuInfo.GetCommonGroups: string;
  var
    SL: TStringList;
    I: Integer;
  begin
    SL := TStringList.Create;
    try
      for I := 0 to Count - 1 do
        SL.Add(Self[I].Groups);
      Result := UnitGroupsWork.GetCommonGroups(SL);
    finally
      SL.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetCommonKeyWords: string;
  var
    KL: TStringList;
    I: Integer;
  begin
    KL := TStringList.Create;
    try
      for I := 0 to Count - 1 do
        KL.Add(Self[I].KeyWords);
      Result := GetCommonWordsA(KL);
    finally
      KL.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetCommonLinks: TLinksInfo;
  var
    LL: TStringList;
    I: Integer;
  begin
    LL := TStringList.Create;
    try
      for I := 0 to Count - 1 do
        LL.Add(Self[I].Links);
      Result := UnitLinksSupport.GetCommonLinks(LL);
    finally
      LL.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetCount: Integer;
  begin
    Result := FData.Count;
  end;

  function TDBPopupMenuInfo.GetIsVariousComments: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if Count > 1 then
      for I := 1 to Count - 1 do
        if Self[0].Comment <> Self[I].Comment then
          Result := True;
  end;

  function TDBPopupMenuInfo.GetIsVariousDate: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if Count > 1 then
      for I := 1 to Count - 1 do
        if Self[0].Date <> Self[I].Date then
          Result := True;
  end;

  function TDBPopupMenuInfo.GetIsVariousInclude: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if Count > 1 then
      for I := 1 to Count - 1 do
        if Self[0].Include <> Self[I].Include then
          Result := True;
  end;

  function TDBPopupMenuInfo.GetIsVariousTime: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if Count > 1 then
      for I := 1 to Count - 1 do
        if Self[0].Time <> Self[I].Time then
          Result := True;
  end;

  function TDBPopupMenuInfo.GetPosition: Integer;
  var
    I: Integer;
  begin
    Result := -1;
    if Count > 0 then
      Result := 0;
    for I := 1 to Count - 1 do
      if Self[I].IsCurrent then
        Result := I;
  end;

  function TDBPopupMenuInfo.GetStatDate: TDateTime;
  var
    I: Integer;
    List: TList64;
  begin
    List := TList64.Create;
    try
      for I := 0 to Count - 1 do
        List.Add(Self[I].Date);
      Result := List.MaxStatDateTime;
    finally
      List.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetStatIsDate: Boolean;
  var
    I: Integer;
    List: TList64;
  begin
    List := TList64.Create;
    try
      for I := 0 to Count - 1 do
        List.Add(Self[I].IsDate);
      Result := List.MaxStatBoolean;
    finally
      List.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetStatIsTime: Boolean;
  var
    I: Integer;
    List: TList64;
  begin
    List := TList64.Create;
    try
      for I := 0 to Count - 1 do
        List.Add(Self[I].IsTime);
      Result := List.MaxStatBoolean;
    finally
      List.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetStatRating: Integer;
  var
    I: Integer;
    List: TList64;
  begin
    List := TList64.Create;
    try
      for I := 0 to Count - 1 do
        List.Add(Self[I].Rating);
      Result := List.MaxStatInteger;
    finally
      List.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetStatTime: TDateTime;
  var
    I: Integer;
    List: TList64;
  begin
    List := TList64.Create;
    try
      for I := 0 to Count - 1 do
        List.Add(Self[I].Time);
      Result := List.MaxStatDateTime;
    finally
      List.Free;
    end;
  end;

  function TDBPopupMenuInfo.GetValueByIndex(index: Integer): TDBPopupMenuInfoRecord;
  begin
    Result := FData[index];
  end;

  procedure TDBPopupMenuInfo.SetPosition(const Value: Integer);
  var
    I: Integer;
  begin
    for I := 0 to Count - 1 do
      Self[I].IsCurrent := False;
    Self[Value].IsCurrent := True;
  end;

  { TDBPopupMenuInfoRecord }

function TDBPopupMenuInfoRecord.Copy: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord.Create;
  Result.ID := ID;
  Result.FileName := FileName;
  Result.Comment := Comment;
  Result.Groups := Groups;
  Result.FileSize := FileSize;
  Result.Rotation := Rotation;
  Result.Rating := Rating;
  Result.Access := Access;
  Result.Date := Date;
  Result.Time := Time;
  Result.IsDate := IsDate;
  Result.IsTime := IsTime;
  Result.Crypted := Crypted;
  Result.KeyWords := KeyWords;
  Result.InfoLoaded := InfoLoaded;
  Result.Include := Include;
  Result.Links := Links;
end;

constructor TDBPopupMenuInfoRecord.CreateFromContRecord(ContRecord: TImageContRecord);
begin
  ID := ContRecord.ID;
  FileName := ProcessPath(ContRecord.FileName);
  Comment := ContRecord.Comment;
  FileSize := ContRecord.FileSize;
  Rotation := ContRecord.Rotation;
  Access := ContRecord.Access;
  Rating := ContRecord.Rating;
  Date := ContRecord.Date;
  Time := ContRecord.Time;
  IsDate := ContRecord.IsDate;
  IsTime := ContRecord.IsTime;
  Groups := ContRecord.Groups;
  Crypted := ContRecord.Crypted;
  Include := ContRecord.Include;
  KeyWords := ContRecord.KeyWords;
  Links := ContRecord.Links;
  InfoLoaded := True;
end;

constructor TDBPopupMenuInfoRecord.CreateFromDS(DS: TDataSet);
var
  ThumbField: TField;
begin
  InfoLoaded := True;
  Selected := True;
  ID := DS.FieldByName('ID').AsInteger;
  KeyWords := DS.FieldByName('KeyWords').AsString;
  FileName := ProcessPath(DS.FieldByName('FFileName').AsString);
  FileSize := DS.FieldByName('FileSize').AsInteger;
  Rotation := DS.FieldByName('Rotated').AsInteger;
  Rating := DS.FieldByName('Rating').AsInteger;
  Access := DS.FieldByName('Access').AsInteger;
  Attr := DS.FieldByName('Attr').AsInteger;
  Comment := DS.FieldByName('Comment').AsString;
  Date := DS.FieldByName('DateToAdd').AsDateTime;
  Time := DS.FieldByName('aTime').AsDateTime;
  IsDate := DS.FieldByName('IsDate').AsBoolean;
  IsTime := DS.FieldByName('IsTime').AsBoolean;
  Groups := DS.FieldByName('Groups').AsString;

  ThumbField := DS.FindField('Thum');
  if ThumbField <> nil then
    Crypted := ValidCryptBlobStreamJPG(ThumbField)
  else
    Crypted := False;

  Include := DS.FieldByName('Include').AsBoolean;
  Links := DS.FieldByName('Links').AsString;
end;

constructor TDBPopupMenuInfoRecord.CreateFromExplorerInfo(Info: TExplorerFileInfo);
begin
  ID := Info.ID;
  FileName := Info.FileName;
  Comment := Info.Comment;
  Groups := Info.Groups;
  FileSize := Info.FileSize;
  Rotation := Info.Rotate;
  Rating := Info.Rating;
  Access := Info.Access;
  Date := Info.Date;
  Time := Info.Time;
  IsDate := Info.IsDate;
  IsTime := Info.IsTime;
  Crypted := Info.Crypted;
  KeyWords := Info.KeyWords;
  InfoLoaded := Info.Loaded;
  Include := Info.Include;
  Links := Info.Links;
end;

constructor TDBPopupMenuInfoRecord.CreateFromRecordInfo(RI: TOneRecordInfo);
begin
  FileName := RI.ItemFileName;
  Comment := RI.ItemComment;
  Groups := RI.ItemGroups;
  ID := RI.ItemId;
  FileSize := RI.ItemSize;
  Rotation := RI.ItemRotate;
  Rating := RI.ItemRating;
  Access := RI.ItemAccess;
  Date := RI.ItemDate;
  Time := RI.ItemTime;
  IsDate := RI.ItemIsDate;
  IsTime := RI.ItemIsTime;
  Crypted := RI.ItemCrypted;
  KeyWords := RI.ItemKeyWords;
  InfoLoaded := RI.Loaded;
  Include := RI.ItemInclude;
  Links := RI.ItemLinks;
end;

constructor TDBPopupMenuInfoRecord.CreateFromSearchRecord(Info: TSearchRecord);
begin
  FileName := ProcessPath(Info.FileName);
  Comment := Info.Comments;
  FileSize := Info.FileSize;
  Rotation := Info.Rotation;
  ID := Info.ID;
  Access := Info.Access;
  Rating := Info.Rating;
  Date := Info.Date;
  Time := Info.Time;
  IsDate := Info.IsDate;
  IsTime := Info.IsTime;
  Groups := Info.Groups;
  Crypted := Info.Crypted;
  KeyWords := Info.KeyWords;
  Attr := Info.Attr;
  InfoLoaded := True;
  Include := Info.Include;
  Links := Info.Links;
end;

constructor TDBPopupMenuInfoRecord.CreateFromSlideShowInfo(Info: TRecordsInfo; Position: Integer);
begin
  FileName := Info.ItemFileNames[Position];
  ID := Info.ItemIds[Position];
  Rotation := Info.ItemRotates[Position];
  Rating := Info.ItemRatings[Position];
  Comment := Info.ItemComments[Position];
  Access := Info.ItemAccesses[Position];
  Date := Info.ItemDates[Position];
  Time := Info.ItemTimes[Position];
  IsDate := Info.ItemIsDates[Position];
  IsTime := Info.ItemIsTimes[Position];
  Groups := Info.ItemGroups[Position];
  Crypted := Info.ItemCrypted[Position];
  KeyWords := Info.ItemKeyWords[Position];
  Links := Info.ItemLinks[Position];
  Selected := True;
  InfoLoaded := True;
  Attr := 0;
  InfoLoaded := Info.LoadedImageInfo[Position];
  FileSize := GetFileSizeByName(Info.ItemFileNames[Position]);
  Include := Info.ItemInclude[Position];
end;

initialization

  DBKernel := nil;
  FExtImagesInImageList := 0;
  LastInseredID := 0;
  GraphicFilterString := '';
  ProcessorCount := GettingProcNum;

finalization

CoUninitialize;

end.
