unit uConstants;

interface
           
//{$DEFINE ENGL}
{$DEFINE RUS}

uses
Windows,
Language;

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
  PHOTO_DB_APPDATA_DIRECTORY = 'Photo DataBase\Data';
  RegRoot : string = 'Software\Photo DataBase\';
  TempFolderMask = '|NDX|MB|DB|NET|';

  //Information
  MyComputer = TEXT_MES_MY_COMPUTER;
  ProductName = 'Photo DataBase 2.2';
  StartMenuProgramsPath = 'Photo DB v2.2';
  ProductVersion = '2.2';
  ProgramShortCutFile = ProductName+'.lnk';
  HelpShortCutFile = TEXT_MES_HELP+'.lnk';
  WindowsMenuTime = 1000;
  ProgramMail = 'illusdolphin@gmail.com';
  CopyRightString = 'Studio "Illusion Dolphin" © 2002-2008';
  {$IFDEF RUS}
  UpdateFileName = '/rus_update.txt';
  AlternativeUpdateURL = 'http://www.illusdolphin.narod.ru/photodb/rus_update.txt';
  HomeURL = 'http://www.illusdolphin.narod.ru/photodb';
  {$ENDIF}
  {$IFDEF ENGL}
  UpdateFileName = '/engl_update.txt';
  HomeURL = 'http://www.illusdolphin.narod.ru/photodb';
  {$ENDIF}

implementation

end.
