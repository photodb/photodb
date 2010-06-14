unit UnitDBDeclare;

interface

uses Windows, Classes, Menus, Graphics, JPEG;

//Array types
type
    TArMenuItem   = array of TMenuItem;
    TArInteger    = array of Integer;
    TArStrings    = array of String;
    TArBoolean    = array of Boolean;
    TArDateTime   = array of TDateTime;
    TArTime       = array of TDateTime;
    TArInteger64  = array of int64;
    TArCardinal = array of Cardinal;

const
  BufferSize = 100*3*4*4096;
Type
  PBuffer = ^TBuffer;
  TBuffer = array [1..BufferSize] of Byte;

type
  TPasswordRecord = record
   CRC : Cardinal;
   FileName : String; 
   ID : integer;
  end;

  TPPasswordRecord = record
   CRC : Cardinal;
   FileName : PChar;
   ID : Cardinal;
  end;

  PPasswordRecord = ^TPPasswordRecord;

  TWriteLineProcedure = procedure(Sender : TObject; Line : string; aType : integer) of object;
  TGetFilesWithoutPassProc = function(Sender : TObject) : TList of object;
  TAddCryptFileToListProc = procedure(Sender : TObject; Rec : TPasswordRecord)  of object;
  TGetAvaliableCryptFileList = function(Sender : TObject) : TArInteger  of object;

  TProgressCallBackInfo = record
    MaxValue : int64;
    Position : int64;
    Information : String;
    Terminate : Boolean;
  end;

  TCallBackProgressEvent = procedure(Sender : TObject; var Info : TProgressCallBackInfo) of object;

  TRecreatingThInTableOptions = record
    WriteLineProc : TWriteLineProcedure;
    WriteLnLineProc : TWriteLineProcedure;
    OnEndProcedure : TNotifyEvent;
    FileName : string;
    GetFilesWithoutPassProc : TGetFilesWithoutPassProc;
    AddCryptFileToListProc : TAddCryptFileToListProc;
    GetAvaliableCryptFileList : TGetAvaliableCryptFileList;
    OnProgress : TCallBackProgressEvent;
  end;

  TImageDBOptions = record
    Version : integer;
    DBJpegCompressionQuality : byte;
    ThSize : integer;
    ThSizePanelPreview : integer;
    ThHintSize : integer;
    Description : string;
    Name : string;
  end;

  TPackingTableThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
  end;

  TRestoreThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
  end;

  TShowBadLinksThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;    
   WriteLnLineProc :  TWriteLineProcedure;
   OnProgress : TCallBackProgressEvent;
  end;

  TBackUpTableThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
   WriteLnLineProc :  TWriteLineProcedure;
  end;

  TOptimizeDublicatesThreadOptions = record
   FileName : string;
   OnEnd : TNotifyEvent;
   WriteLineProc :  TWriteLineProcedure;
   WriteLnLineProc :  TWriteLineProcedure;  
   OnProgress : TCallBackProgressEvent;
  end;

  TIfBreakThreadProc = function(Sender : TObject; SID : string) : boolean of object;


Type TEventField=(EventID_Param_Name, EventID_Param_ID, EventID_Param_Rotate,
     EventID_Param_Rating, EventID_Param_Private, EventID_Param_Comment,
     EventID_Param_KeyWords, EventID_Param_Access, EventID_Param_Attr,
     EventID_Param_Image, EventID_Param_Owner, EventID_Param_Collection,
     EventID_Param_Refresh, EventID_Param_ThemeCH, EventID_Param_Critical,
     EventID_Param_Add, EventID_Param_Delete, EventID_Param_Date,
     EventID_Param_Time, EventID_Param_IsDate , EventID_Param_IsTime,
     EventID_Param_Groups, EventID_Param_Crypt, EventID_Param_Include,
     EventID_Param_GroupsChanged, EventID_Param_CopyPaste,
     EventID_Param_Add_Crypt_WithoutPass, SetNewIDFileData,
     EventID_Param_Links,  EventID_Param_DB_Changed, EventID_Param_Refresh_Window,
     EventID_FileProcessed, EventID_Repaint_ImageList);
     
     TEventFields = set of TEventField;


  TEventValues = record
      Name : String;
      NewName : String;
      ID : integer;
      Rotate : integer;
      Rating : integer;
      Comment : String;
      KeyWords : string;
      Access : integer;
      Attr : integer;
      Image : TBitmap;
      Date : TDateTime;
      IsDate : Boolean;
      IsTime : Boolean;
      Time : TDateTime;
      Groups : String;
      JPEGImage : TJpegImage;
      Collection : string;
      Owner : string;
      Crypt : Boolean;
      Include : Boolean;
      Links : string;
     end;


  TOnDBKernelEventProcedure = procedure(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues) of object;

  ///////////////CONSTANT SECTION//////////////////////

const              
  LINE_INFO_UNDEFINED = 0;
  LINE_INFO_OK        = 1;
  LINE_INFO_ERROR     = 2;
  LINE_INFO_WARNING   = 3; 
  LINE_INFO_PLUS      = 4;   
  LINE_INFO_PROGRESS  = 5;   
  LINE_INFO_DB        = 6;
  LINE_INFO_GREETING  = 7;
  LINE_INFO_INFO      = -1;


type
  TImageCompareResult = record
    ByGistogramm : Byte;
    ByPixels : Byte;
  end;

  TSearchRecord = record
   FileName : string;
   Comments : string;
   KeyWords : string;
   ImTh : string;
   Groups : string;
   Links : string;
   FileSize : int64;
   Date : TDateTime;
   Time : TDateTime;
   IsDate : boolean;
   IsTime : boolean;
   Crypted : boolean;
   Include : boolean;
   Rotation : integer;
   Rating : integer;
   Access : integer;
   Exists : integer;
   ID : integer;
   Selected : boolean;
   Attr : integer;
   CompareResult : TImageCompareResult;
   Width : integer;
   Height : integer;
  end;

  TSearchRecordArray = array of TSearchRecord;

  TImageContRecord = record
   FileName : string;
   Rating : integer;
   Rotation : integer;
   ID : integer;
   Access : integer;
   Comment : string;
   FileSize : int64;
   Selected : boolean;
   Crypted : boolean;
   Exists : integer;
   ImTh : string;
   Date : TDateTime;
   IsDate : boolean;
   Time : TDateTime;  
   IsTime : boolean;
   Include : boolean;
   Links : string;
   Groups : string;
   KeyWords : string;
  end;
             
  TImageContRecordArray = array of TImageContRecord;

type
  TPhotoDBFile = record
   _Name : string;
   Icon : string;
   FileName : string;
   aType : integer;
  end;

  type TPhotoDBFiles = array of TPhotoDBFile;


implementation

end.
