unit uConstants;

interface

uses
  Windows;

const
  //envoirements
  TempFolder = '\Temp\';
  HKEY_INSTALL = Windows.HKEY_LOCAL_MACHINE;
  HKEY_USER_WORK = Windows.HKEY_CURRENT_USER;
  PlugInImagesFolder = 'PlugInsEx\';
  OldPlugInImagesFolder = 'PlugIns\';
  ThemesDirectory = 'Themes\';
  BackUpFolder : String = '\DBBackUp\';
  ScriptsFolder : String = 'Scripts\';
  ActionsFolder : String = 'Actions\';  
  ImagesFolder : String = 'Images\';
  DBRestoreFolder : String = '\DB\';
  PHOTO_DB_APPDATA_DIRECTORY = 'Photo DataBase';
  RegRoot : string = 'Software\Photo DataBase\';
  TempFolderMask = '|NDX|MB|DB|NET|';
  DelayReadFileOperation = 200;
  DelayExecuteSQLOperation = 200;
  LanguageFileMask = 'Language';
  SetupDataName = 'SETUP_DATA';

  //Information
  ProductName = 'Photo DataBase 2.3';
  StartMenuProgramsPath = 'Photo DB v2.3';
  ProductVersion = '2.3';
  ProgramShortCutFile = ProductName+'.lnk';
  HelpShortCutFile = 'Help.lnk';
  WindowsMenuTime = 1000;
  ProgramMail = 'illusdolphin@gmail.com';
  CopyRightString = 'Studio "Illusion Dolphin" © 2002-2011';
  UpdateURL = 'http://photodb.illusdolphin.net/update.aspx';
  InstallNotifyURL = 'http://photodb.illusdolphin.net/install.aspx';
  UpdateNotifyURL = 'http://photodb.illusdolphin.net/update.aspx';
  HomeURL = 'http://photodb.illusdolphin.net';

  //install
  DBID = '{E1446065-CB87-440D-9315-6FA356F921B5}';
  DBBeginInstallID = '{A8C9FD9D-C2F6-4B1C-9164-11E6075FD527}';
  DBEndInstallID = '{C5348907-0AD6-4D02-8E0D-4063057B652F}';
  ReleaseNumber = 12;

const
    WM_DROPFILES = $0233;
    WM_COPYDATA = $004A;
    FIXIDEX = True;
    WM_COPYDATA_ID = 3232;


const
  Pwd_rusup = '¨ÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀÏÐÎËÄÆÝß×ÑÌÈÒÜÁÞ';
  Pwd_rusdown = '¸éöóêåíãøùçõúôûâàïðîëäæýÿ÷ñìèòüáþ';
  Pwd_englup = 'QWERTYUIOPASDFGHJKLZXCVBNM';
  Pwd_engldown = 'qwertyuiopasdfghjklzxcvbnm';
  Pwd_cifr = '0123456789';
  Pwd_spec = '!#$%&()=?@<>|{[]}/\*~+#;:.-_';
  Abs_engl: set of AnsiChar = ['a' .. 'z', 'A' .. 'Z'];
  Abs_rus: set of AnsiChar = ['à' .. 'ß', 'à' .. 'ß'];
  Abs_cifr: set of AnsiChar = ['0' .. '9'];
  Abs_hex: set of AnsiChar = ['a' .. 'e', 'A' .. 'E', '0' .. '9'];
  Abs_englUp: set of AnsiChar = ['A' .. 'Z'];
  Abs_rusUp: set of AnsiChar = ['À' .. 'ß'];
  Abs_englDown: set of AnsiChar = ['a' .. 'z'];
  Abs_rusDown: set of AnsiChar = ['à' .. 'ÿ'];

  SHELL_FOLDERS_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\Explorer';
  QUICK_LAUNCH_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\GrpConv';

  Cifri: set of AnsiChar = ['0' .. '9'];

  Unusedchar: set of AnsiChar = ['''', '/', '|', '\', '<', '>', '"', '?', '*', ':'];
  Unusedchar_folders: set of AnsiChar = ['''', '/', '|', '<', '>', '"', '?', '*', ':'];
  Abs_alldb = ['0' .. '9', 'à' .. 'ÿ', 'À' .. 'ß', '¸', '¨', 'a' .. 'z', 'A' .. 'Z', '/', '|', '\', '<', '>', '''',
    '?', '*', ':'];

  Validchars: set of AnsiChar = ['a' .. 'z', 'A' .. 'Z', '[', ']', '-', '_', '!', ':', ';', '\', '/', '.', ',', ' ',
    '0' .. '9'];
  Validcharsmdb: set of AnsiChar = ['a' .. 'z', 'A' .. 'Z', '[', ']', '-', '_', '!', ':', ';', '\', '/', '.', ',', ' ',
    '0' .. '9', ' ', 'à' .. 'ÿ', 'À' .. 'ß'];

const
  Db_access_private = 1;
  Db_access_none = 0;
  Db_attr_norm = 0;
  Db_attr_not_exists = 1;
  Db_attr_dublicate = 2;

const
  DB_IMAGE_ROTATE_UNKNOWN = -1;
  DB_IMAGE_ROTATE_0       = 0;
  DB_IMAGE_ROTATE_90      = 1;
  DB_IMAGE_ROTATE_180     = 2;
  DB_IMAGE_ROTATE_270     = 3;
  DB_IMAGE_ROTATE_EXIF    = 4;

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

//////////////////////////////////
///
///  Explorer
///
//////////////////////////////////

const
  EXPLORER_ITEM_FOLDER     = 0;
  EXPLORER_ITEM_IMAGE      = 1;
  EXPLORER_ITEM_FILE       = 2;
  EXPLORER_ITEM_DRIVE      = 3;
  EXPLORER_ITEM_MYCOMPUTER = 4;
  EXPLORER_ITEM_NETWORK    = 5;
  EXPLORER_ITEM_WORKGROUP  = 6;
  EXPLORER_ITEM_COMPUTER   = 7;
  EXPLORER_ITEM_SHARE      = 8;
  EXPLORER_ITEM_EXEFILE    = 9;
  EXPLORER_ITEM_OTHER      = 10;

//////////////////////////////////////////////////

  THREAD_TYPE_NONE           = -1;
  THREAD_TYPE_FOLDER         = 0;
  THREAD_TYPE_DISK           = THREAD_TYPE_FOLDER;
  THREAD_TYPE_MY_COMPUTER    = 2;
  THREAD_TYPE_NETWORK        = 3;
  THREAD_TYPE_WORKGROUP      = 4;
  THREAD_TYPE_COMPUTER       = 5;
  THREAD_TYPE_IMAGE          = 6;
  THREAD_TYPE_FILE           = 7;
  THREAD_TYPE_FOLDER_UPDATE  = 8;
  THREAD_TYPE_BIG_IMAGES     = 9;
  THREAD_TYPE_THREAD_PREVIEW = 10;

  THREAD_PREVIEW_MODE_IMAGE      = 1;
  THREAD_PREVIEW_MODE_BIG_IMAGE  = 2;
  THREAD_PREVIEW_MODE_DIRECTORY  = 3;
  THREAD_PREVIEW_MODE_EXIT       = 0;

  LV_THUMBS     = 0;
  LV_ICONS      = 1;
  LV_SMALLICONS = 2;
  LV_TITLES     = 3;
  LV_TILE       = 4;
  LV_GRID       = 5;

implementation

end.
