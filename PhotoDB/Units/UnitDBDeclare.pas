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
    TArCardinal   = array of Cardinal;

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

  TSearchRecord = class(TObject)
  public
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

  TSearchRecordArray = class(TObject)
  private
    FList : TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TSearchRecord;
    procedure SetValueByIndex(Index: Integer; const Value: TSearchRecord);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure DeleteAt(Index : Integer);
    function AddNew : TSearchRecord;
    property Items[Index: Integer]: TSearchRecord read GetValueByIndex write SetValueByIndex; default;
    property Count : Integer read GetCount;
  end;

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
  TPhotoDBFile = class
  public
    Name : string;
    Icon : string;
    FileName : string;
    FileType : integer;
  end;

  TPhotoDBFiles = class
  private
    FList : TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TPhotoDBFile;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Name, Icon, FileName : string; FileType : Integer) : TPhotoDBFile;
    property Items[Index: Integer]: TPhotoDBFile read GetValueByIndex; default;
    property Count : Integer read GetCount;
  end;

  TDataObject = class(TObject)
  private
  public
    Include : Boolean;
    IsImage : Boolean;
  end;

  TSearchQuery = class(TObject)
  public
    Query : string;
    GroupName : string;
    RatingFrom : Integer;
    RatingTo : Integer;
    ShowPrivate : Boolean;
    DateFrom : TDateTime;
    DateTo : TDateTime;
    SortMethod : Integer;
    SortDecrement : Boolean;
  end;
implementation

{ TSearchRecordArray }

function TSearchRecordArray.AddNew: TSearchRecord;
begin
  Result := TSearchRecord.Create;
  FList.Add(Result);
end;

procedure TSearchRecordArray.Clear;
var
  I : Integer;
begin
  for I := 0 to FList.Count - 1 do
    TSearchRecord(FList[I]).Free;
  FList.Clear;
end;

constructor TSearchRecordArray.Create;
begin
  FList := TList.Create;
end;

procedure TSearchRecordArray.DeleteAt(Index: Integer);
var
  Rec : TSearchRecord;
begin
  Rec := FList[Index];
  Rec.Free;
  FList.Delete(Index);
end;

destructor TSearchRecordArray.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TSearchRecordArray.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSearchRecordArray.GetValueByIndex(Index: Integer): TSearchRecord;
begin
  Result := FList[Index];
end;

procedure TSearchRecordArray.SetValueByIndex(Index: Integer;
  const Value: TSearchRecord);
begin
  FList[Index] := Value;
end;

{ TPhotoDBFiles }

function TPhotoDBFiles.Add(Name, Icon, FileName: string;
  FileType: Integer): TPhotoDBFile;
begin
  Result := TPhotoDBFile.Create;
  Result.Name := Name;
  Result.Icon := Icon;
  Result.FileName := FileName;
  Result.FileType := FileType;
  FList.Add(Result);
end;

constructor TPhotoDBFiles.Create;
begin
  FList := TList.Create;
end;

destructor TPhotoDBFiles.Destroy;
var
  I : Integer;
begin
  for I := 0 to FList.Count - 1 do
    TPhotoDBFile(FList[I]).Free;
  FList.Free;
  inherited;
end;

function TPhotoDBFiles.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPhotoDBFiles.GetValueByIndex(Index: Integer): TPhotoDBFile;
begin
  Result := FList[Index];
end;

end.
