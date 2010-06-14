unit GlobalTypes;

interface

Uses
  Windows,Graphics,Dialogs,Forms,SysUtils,Messages, ExtCtrls,
  Menus, Classes, StdCtrls, ComCtrls, Buttons, Controls,
  Consts
  ;

Const
   MaxFileList=128000;
   MaxFileLength=360;
   WM_FixColumns   = WM_USER + 1;
   WM_SlideShow    = WM_USER + 2;
   WM_RETRY_RESIZE = WM_USER + 3;
   WM_RETRY_RESIZE_DOFULL1 = WM_USER + 4;
   WM_RETRY_RESIZE_THUMB = WM_USER + 5;
   WM_COMBOUPDATE  = WM_USER + 6;
   WM_FTPSITES     = WM_USER + 7;
   WM_FTPSITES_B   = WM_USER + 8;
   WM_DODRAG       = WM_USER + 9;
   WM_DATABASE_RESYNC= WM_USER + 10;
   WM_DATABASE_DONEXT= WM_USER + 11;
   WM_DATABASE_DOPREV= WM_USER + 12;
   WM_DATABASE_DOHOME= WM_USER + 13;
   WM_DATABASE_DOEND = WM_USER + 14;
   WM_SUBCAPTIONVISIBLECHANGE= WM_USER + 15;
   WM_FILESLIST_CHANGE_START = WM_USER + 16;
   WM_FILESLIST_CHANGE_END = WM_USER + 17;
   WM_FILESLIST_CHANGED = WM_USER + 18;

   WM_Change_Start_Delete    = 3;
   WM_Change_End_Delete      = 3;
   WM_Change_Start_SingleTag = 1;
   WM_Change_End_SingleTag   = 1;
   WM_Change_End_InfoDone    = 2;
   WM_Change_Start_Ignore    = 4;
   WM_Change_End_Ignore      = 4;
Const
{
{ ****** THESE MUST BE IN ALPHA order for the SORT COL TO WORK!!!!
}
  ImageTypeNONE=0;
  ImageTypeAVI=1;
  ImageTypeBMP=2;
  ImageTypeDCX=3;
  ImageTypeEMF=4;
  ImageTypeFLI=5;
  ImageTypeGIF=6;
  ImageTypeICO=7;
  ImageTypeJPG=8;
  ImageTypeMIDI=9;
  ImageTypeMOV=10;
  ImageTypeMPG=11;
  ImageTypePCX=12;
  ImageTypePIC=13;
  ImageTypePNG=14;
  ImageTypeTGA=15;
  ImageTypeWAV=16;
  ImageTypeWMF=17;
  ImageTypeMP3=18;
  ImageTypeWMA=19;

  clLightGray=$00C0C0D0;
  crNextPrev=10;
  crNotes1=11;
  crCheck1=12;
  crMagnify1=13;
  crCOPY=14;
  crMOVE=15;
  crLINK=16;
  crCOPYsc=17;
  crMOVEsc=18;
  crLINKsc=19;
  crHandOpen=20;
  crHandClosed=21;

  ImageListIcons_B_DOT_OFF =5;
  ImageListIcons_B_DOT_ON  =6;
  ImageListIcons_B_CHECK_GREEN =29;
  ImageListIcons_B_CHECK_GRAY  =58;

  clFakeTransparent=$C08040;
  clLightYellow=$C0FFFF;
  clFaintYellow=$E0FFFF;
  clFaintGreen=$FFFFC0;
  G_Comma=#255;
  G_CommaString=G_Comma+G_Comma+G_Comma+G_Comma+G_Comma+G_Comma+G_Comma+G_Comma+G_Comma+G_Comma;
  Blnk='                                                    '+
       '                                                    '+
       '                                                    '+
       '                                                    '+
       '                                                    '+
       '                                                    '+
       '                                                    '+
       '                                                    ';
Const

  rt_Non_Registered=0;
  rt_Registered=1;
  rt_OEM=2;
  rt_PRO=3;
  rt_SYSOP=4;
  rt_RegTable:Array[0..4] Of String=('NON-REGISTERED','REGISTERED','OEM','PRO','SYSOP');
  CONST_Min_SysRes=8;
  CONST_Min_UserRes=8;
  CONST_Min_GDIRes=7;
  CONST_TVIEW_INI='TVIEW.INI';
  CONST_TVFTP_INI='TVFTP.INI';
  CONST_AssocExt='.TV_DB_Notes';
  CONST_TVRecycle='TV_RecycleBin\';
  CONST_TVRecycleTXT='RECYCLE.TXT';
  CONST_TVRecycleNumber:Integer=0;
  TVINI_Name:String=CONST_TVIEW_INI;
  TVFTP_Name:String=CONST_TVFTP_INI;
  MemorizedFile='MEMORIZED.TXT';
  GLOBAL_DONT_MATCH='*** DO NOT MATCH THESE ***';
  GLOBAL_NONE='None';
  CONST_Properties='Properties';
  GLOBAL_TURBOVIEW='TurboView'; {This controls the registry SetupVersion as well!}
  ProgramVersion='2.4.0';
  ProgramName=Global_TurboView+' '+ProgramVersion;

  GLOBAL_InvalidFTP='The only valid characters are A-Z and 0-9 and the / ~ - . \ _  symbols.';
  C_NoTagNoRemoveBusy='Please don''t add or remove files from the files list or TAG or UN-TAG files while you are generating the Previews.';

   CONST_SmoothMenu='LP_SMOOTH';
   CONST_EditMenu='LP_EDIT';
   CONST_PrintMenu='LP_PRINT';

   CONST_FTPMENU_NAME='FTPMENU';


Type
   String255=String[255];
   String80=String[80];
   String10=String[10];

   TRGB=Packed Record
       R,G,B:Byte;
       End;
   PRGB=^TRGB;

   DataRGBArray=Array[0..65535] Of TRGB;
   PDataRGBArray=^DataRGBArray;
   ArrayPointer=Array[0..65535] Of Pointer;
   PArrayPointer=^ArrayPointer;
   DataLineArray=Array[0..65535] Of Byte;
   PDataLineArray=^DataLineArray;
   DataLongIntArray=Array[0..65535] Of LongInt;{KEEP IT SMALLINT!!!}
   PDataLongIntArray=^DataLongIntArray;
   DataWordIntArray=Array[0..65535] Of SmallInt;{KEEP IT SMALLINT!!!}
   PDataWordIntArray=^DataWordIntArray;
   DataSmallIntArray=Array[-65535..65535] Of SmallInt;{KEEP IT SMALLINT!!!}
   FakePalette= Packed Record
      LPal : TLogPalette;
      Dummy:Array[1..255] of TPaletteEntry;
      End;

   TypeEgaPalette=Array[0..16] Of Byte;
   TypePalette=Array[0..255,1..3] Of Byte;

   SelectUniqueArrayFast=Array[0..MaxFileList] Of Integer;
   SelectUniqueArray=Array[0..MaxFileList] Of Byte;
   SelectArray=Array[0..MaxFileList] Of Boolean;
   SelectArrayPtr=^SelectArray;
   
Type
  TBigArrayBool=Array[0..999999] Of Boolean;
  PBigArrayBool=^TBigArrayBool;
  TBigArrayInt=Array[0..999999] Of Integer;
  PBigArrayInt=^TBigArrayInt;
  TSaveCur=Packed Record
        Enabled:Boolean;
        SaveCur:TCursor;
        End;
  TSaveArrayCur=Array[0..999999] Of TSaveCur;
  PSaveArrayCur=^TSaveArrayCur;

  FileStuff=Packed Record
             FileName:String[12];
             Path:Byte;
             XRes:Word;
             YRes:Word;
             XRes_Cat:Word;
             YRes_Cat:Word;
             Size:LongInt;
             Date:LongInt;
             Colors:Word;
             SlideShow:Boolean;
             Compressed:Boolean;
             Interlaced:Boolean;
             Score:Char;
             Category:String10;
             DataBasePrime:Boolean;
             DOSNum:Word;
             DataBaseRec:Word;
             NextFile:SmallInt;
             FileTypeX:Word;
             End;
   File_Ptr=^FileStuff;

Type
{
{ Callbacks
}
  CallBackDither=Procedure(PercentDone:Byte;const Msg: String;Stage:TProgressStage) Of Object;
  CallBackDitherShow=Procedure(ShowIt:Boolean) Of Object;
  PCallBackDitherShow=^CallBackDitherShow;
  ProcSimple=Procedure(Mess:String);
  ProcSimpleM=Procedure(Mess:String) Of Object;
  ProcSimpleIM=Procedure(Index:Integer) Of Object;
  TStatusProc=Procedure(X:Integer;Mess,Mess2:String) Of Object;
  TMultiStatusProc=Procedure(X:Integer;Mess,Mess2:String;Const P1,P2:ProcSimpleM;Const P3:ProcSimpleIM);

Procedure PostMessage_ChangeStart(Val:Integer);
Procedure PostMessage_ChangeEnd(Val:Integer);

implementation

Procedure PostMessage_ChangeStart(Val:Integer);
Begin
PostMessage(0,WM_FILESLIST_Change_Start,Val,0);
End;

Procedure PostMessage_ChangeEnd(Val:Integer);
Begin
PostMessage(0,WM_FILESLIST_Change_End,Val,0);
End;

end.
