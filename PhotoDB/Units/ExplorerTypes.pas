unit ExplorerTypes;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Winapi.Windows,
  Vcl.Graphics,
  UnitDBDeclare,
  Vcl.ActnPopup,
  Vcl.Imaging.JPEG,

  Dmitry.Utils.System,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,
  Dmitry.PathProviders.Network,
  Dmitry.Controls.PathEditor,

  uMemory,
  uThreadEx,
  uThreadForm,
  uConstants,
  uGUIDUtils,
  uDBContext,
  uDBEntities,

  uExplorerGroupsProvider,
  uExplorerPersonsProvider,
  uExplorerPortableDeviceProvider,
  uExplorerShelfProvider,
  uExplorerDateStackProviders,
  uExplorerSearchProviders,
  uFormListView;

const
  ThSizeExplorerPreview = 100;

type
  TExplorerPath = record
    Path: string;
    PType: Integer;
    Tag: Integer;
    FocusedItem: string;
  end;

type
  TCustomExplorerForm = class(TListViewForm)
  private
    FWindowID: TGUID;
  protected
    function GetCurrentPath: string; virtual; abstract;
  public
    procedure SetPathItem(PI: TPathItem);  virtual; abstract;
    procedure SetNewPathW(WPath: TExplorerPath; Explorer: Boolean); virtual; abstract;
    procedure SetStringPath(Path: String; ChangeTreeView: Boolean); virtual; abstract;
    procedure SetPath(NewPath: string); virtual; abstract;
    procedure SetOldPath(OldPath: string); virtual; abstract;
    procedure LoadLastPath; virtual; abstract;
    procedure NavigateToFile(FileName: string); virtual; abstract;
    procedure GetCurrentImage(W, H: Integer; out Bitmap: TGraphic); virtual; abstract;
    constructor Create(AOwner: TComponent; GoToLastSavedPath: Boolean); reintroduce; overload;
    property WindowID: TGUID read FWindowID;
    property CurrentPath: string read GetCurrentPath;
  end;

  TExplorerLeftTab = (eltsExplorer, eltsInfo, eltsEXIF, eltsSearch, eltsAny);

  TExplorerRightTab = (ertsPreview, ertsMap, ertsAny);

type
  PFileNotifyInformation = ^TFileNotifyInformation;

  TFileNotifyInformation = record
    NextEntryOffset: DWORD;
    Action: DWORD;
    FileNameLength: DWORD;
    FileName: array [0 .. 0] of WideChar;
  end;

const
  FILE_LIST_DIRECTORY = $0001;

type
  TExplorerViewInfo = record
    ShowPrivate: Boolean;
    ShowFolders: Boolean;
    ShowSimpleFiles: Boolean;
    ShowImageFiles: Boolean;
    ShowHiddenFiles: Boolean;
    ShowAttributes: Boolean;
    ShowThumbNailsForFolders: Boolean;
    SaveThumbNailsForFolders: Boolean;
    ShowThumbNailsForImages: Boolean;
    ShowThumbNailsForVideo: Boolean;
    OldFolderName: string;
    View: Integer;
    PictureSize: Integer;
  end;

type
  TArExplorerPath = array of TExplorerPath;

type
  PDevBroadcastHdr = ^TDevBroadcastHdr;
  TDevBroadcastHdr = packed record
    dbcd_size: DWORD;
    dbcd_devicetype: DWORD;
    dbcd_reserved: DWORD;
  end;

type
  PDevBroadcastVolume = ^TDevBroadcastVolume;
  TDevBroadcastVolume = packed record
    dbcv_size: DWORD;
    dbcv_devicetype: DWORD;
    dbcv_reserved: DWORD;
    dbcv_unitmask: DWORD;
    dbcv_flags: Word;
  end;

  TExplorerFileInfo = class(TMediaItem)
  protected
    function InitNewInstance: TMediaItem; override;
  public
    IsBigImage: Boolean;
    SID: TGUID;
    FileType: Integer;
    Tag: Integer;
    Loaded: Boolean;
    ImageIndex: Integer;
    constructor CreateFromPathItem(PI: TPathItem);
    function Copy: TMediaItem; override;
  end;

  TExplorerFileInfos = class(TMediaItemCollection)
  private
    function GetValueByIndex(Index: Integer): TExplorerFileInfo;
    procedure SetValueByIndex(Index: Integer; const Value: TExplorerFileInfo);
  public
    property ExplorerItems[Index: Integer]: TExplorerFileInfo read GetValueByIndex write SetValueByIndex; default;
  end;

type
  TUpdaterInfo = class(TObject)
  private
    FContext: IDBContext;
    FIsUpdater: Boolean;
    FUpdateDB: Boolean;
    FProcHelpAfterUpdate: TNotifyEvent;
    FNewFileItem: Boolean;
    FFileInfo: TExplorerFileInfo;
    FDisableLoadingOfBigImage: Boolean;
    procedure SetFileInfo(const Value: TExplorerFileInfo);
    procedure Init;
    function GetFileName: string;
    function GetID: Integer;
    function GetSID: TGUID;
  public
    constructor Create; overload;
    constructor Create(Context: IDBContext; Info: TExplorerFileInfo); overload;
    destructor Destroy; override;
    procedure Assign(Info: TUpdaterInfo);
    function Copy: TUpdaterInfo;
    procedure ClearInfo;
    property IsUpdater: Boolean read FIsUpdater write FIsUpdater;
    property UpdateDB: Boolean read FUpdateDB write FUpdateDB;
    property ProcHelpAfterUpdate: TNotifyEvent read FProcHelpAfterUpdate write FProcHelpAfterUpdate;
    property NewFileItem: Boolean read FNewFileItem write FNewFileItem;
    property FileName: string read GetFileName;
    property ID: Integer read GetID;
    property SID: TGUID read GetSID;
    property DisableLoadingOfBigImage: Boolean read FDisableLoadingOfBigImage write FDisableLoadingOfBigImage;
    property Context: IDBContext read FContext write FContext;
  end;

function AddOneExplorerFileInfo(Infos: TExplorerFileInfos; FileName: string; FileType, ImageIndex: Integer;
  SID: TGUID; ID, Rating, Rotate, Access: Integer; FileSize: Int64; Comment, KeyWords, Groups: string; Date: TDateTime; IsDate, Encrypted, Include: Boolean): TExplorerFileInfo;

type
  TStringsHistoryW = class(TObject)
  private
    { Private declarations }
    FArray: array of TExplorerPath;
    FPosition: Integer;
    FOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetItem(Index: Integer): TExplorerPath;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Add(Path: TExplorerPath; FocusedPath: string = '');
    function CanBack: Boolean;
    function CanForward: Boolean;
    function GetCurrentPos: Integer;
    function DoBack: TExplorerPath;
    function GetBackPath: TExplorerPath;
    function DoForward: TExplorerPath;
    function GetForwardPath: TExplorerPath;
    function LastPath: TExplorerPath;
    function GetBackHistory: TArExplorerPath;
    function GetForwardHistory: TArExplorerPath;
    procedure Clear;
    procedure UpdateLastFileForCurrentState(FileName: string);
    property OnHistoryChange: TNotifyEvent read FOnChange write SetOnChange;
    property Position: Integer read FPosition write FPosition;
    property Items[Index: Integer]: TExplorerPath read GetItem; default;
  end;

type
  TIcon48 = class(TIcon)
  protected
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
  end;

  TLoadPathList = class(TThreadEx)
  private
    FOwner: TThreadForm;
    FPathList: TArExplorerPath;
    FSender: TPopupActionBar;
    FIcons: TPathItemCollection;
    procedure UpdateMenu;
  protected
    procedure Execute; override;
  public
    constructor Create(Owner: TThreadForm; PathList: TArExplorerPath; Sender: TPopupActionBar);
  end;

function ExplorerPath(Path: string; PType: Integer): TExplorerPath;

implementation

uses
  ExplorerUnit;

function ExplorerPath(Path : string; PType: Integer): TExplorerPath;
begin
  Result.Path := Path;
  Result.PType := PType;
end;

function AddOneExplorerFileInfo(Infos: TExplorerFileInfos; FileName: String; FileType, ImageIndex: Integer; SID: TGUID; ID, Rating, Rotate, Access: Integer; FileSize: Int64; Comment, KeyWords, Groups: String; Date: TDateTime; IsDate, Encrypted, Include: Boolean): TExplorerFileInfo;
var
  Info: TExplorerFileInfo;
begin
  Info := TExplorerFileInfo.Create;
  Info.FileName := FileName;
  Info.ID := ID;
  Info.FileType := FileType;
  Info.SID := SID;
  Info.Rotation := Rotate;
  Info.Rating := Rating;
  Info.Access := Access;
  Info.FileSize := FileSize;
  Info.Comment := Comment;
  Info.KeyWords := KeyWords;
  Info.ImageIndex := ImageIndex;
  Info.Date := Date;
  Info.IsDate := IsDate;
  Info.Groups := Groups;
  Info.Encrypted := Encrypted;
  Info.Loaded := False;
  Info.Include := Include;
  Info.IsBigImage := False;
  Info.Exists := 1;
  if Infos <> nil then
    Infos.Add(Info);
  Result := Info;
end;

{ TStringsHistoryW }

procedure TStringsHistoryW.Add(Path: TExplorerPath; FocusedPath: string);
begin
  Path.FocusedItem := FocusedPath;
  if FPosition = Length(FArray) - 1 then
  begin
    SetLength(FArray, Length(FArray) + 1);
    FArray[Length(FArray) - 1] := Path;
    FPosition:= Length(FArray) - 1;
  end else
  begin
    SetLength(FArray, FPosition + 2);
    FArray[FPosition + 1] := Path;
    FPosition := FPosition + 1;
  end;
  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self);
end;

function TStringsHistoryW.CanBack: Boolean;
begin
  Result := FPosition > 0
end;

function TStringsHistoryW.CanForward: boolean;
begin
  if FPosition = -1 then
    Result := False
  else
    Result := (FPosition <> Length(FArray) - 1) and (Length(FArray) <> 1)
end;

procedure TStringsHistoryW.Clear;
begin
  FPosition := -1;
  SetLength(FArray, 0);
end;

constructor TStringsHistoryW.Create;
begin
  inherited;
  FPosition := -1;
  SetLength(FArray, 0);
  fOnChange := nil;
end;

destructor TStringsHistoryW.Destroy;
begin
  SetLength(FArray, 0);
  inherited;
end;

function TStringsHistoryW.GetBackPath: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  if FPosition = 0 then
    Result := FArray[0]
  else
    Result := FArray[FPosition - 1];
end;

function TStringsHistoryW.DoBack: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  if FPosition = 0 then
    Result := FArray[0]
  else
  begin
    Dec(FPosition);
    Result := FArray[FPosition];
  end;

  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self);
end;

function TStringsHistoryW.DoForward: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  if (FPosition = Length(FArray)-1) or (Length(FArray)=1) then
    Result := FArray[Length(FArray) - 1]
  else
  begin
    Inc(FPosition);
    Result := FArray[FPosition];
  end;
  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self);
end;

function TStringsHistoryW.GetForwardPath: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  if (FPosition = Length(FArray) - 1) or (Length(FArray) = 1) then
    Result := FArray[Length(FArray) - 1]
  else
    Result := FArray[FPosition + 1];
end;

function TStringsHistoryW.GetBackHistory: TArExplorerPath;
var
  I : Integer;
begin
  SetLength(Result, 0);
  if FPosition = -1 then
    Exit;

  for I := 0 to FPosition - 1 do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[I] := FArray[I];
    Result[I].Tag := I;
  end;
end;

function TStringsHistoryW.GetCurrentPos: integer;
begin
  Result := FPosition + 1;
end;

function TStringsHistoryW.GetForwardHistory: TArExplorerPath;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if FPosition = -1 then
    Exit;

  for I := FPosition + 1 to Length(FArray) - 1 do
  begin
    SetLength(Result,Length(Result) + 1);
    Result[I - FPosition - 1] := FArray[I];
    Result[I - FPosition - 1].Tag := I;
  end;
end;

function TStringsHistoryW.GetItem(Index: Integer): TExplorerPath;
begin
  Result := FArray[Index];
end;

function TStringsHistoryW.LastPath: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  Result := FArray[FPosition];
end;

procedure TStringsHistoryW.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TStringsHistoryW.UpdateLastFileForCurrentState(FileName: string);
begin
  FArray[FPosition].FocusedItem := FileName;
end;

{ TIcon48 }

function TIcon48.GetHeight: Integer;
begin
  Result := 48;
end;

function TIcon48.GetWidth: Integer;
begin
  Result := 48;
end;

procedure TExplorerFileInfos.SetValueByIndex(Index: Integer;
  const Value: TExplorerFileInfo);
begin
  FData[Index] := Value;
end;

function TExplorerFileInfos.GetValueByIndex(Index: Integer): TExplorerFileInfo;
begin
   Result := FData[Index];
end;

{ TExplorerFileInfo }

function TExplorerFileInfo.Copy: TMediaItem;
var
  Info: TExplorerFileInfo;
begin
  Result := inherited Copy;
  Info := Result as TExplorerFileInfo;

  Info.SID := SID;
  Info.FileType := FileType;
  Info.IsBigImage := IsBigImage;
  Info.Tag := Tag;
  Info.Loaded := Loaded;
  Info.ImageIndex := ImageIndex;
end;

constructor TExplorerFileInfo.CreateFromPathItem(PI: TPathItem);
var
  CN: string;
begin
  inherited Create;
  FileName := PI.Path;
  Name := PI.DisplayName;
  SID := GetGUID;
  Loaded := False;
  Include := True;
  IsBigImage := False;
  ImageIndex := -1;
  Exists := 1;
  CN := PI.ClassName;

  if PI is TDriveItem then
    FileType := EXPLORER_ITEM_DRIVE
  else if PI is THomeItem then
    FileType := EXPLORER_ITEM_MYCOMPUTER
  else if PI is TGroupsItem then
    FileType := EXPLORER_ITEM_GROUP_LIST
  else if PI is TGroupItem then
  begin
    Comment := TGroupItem(PI).Comment;
    KeyWords := TGroupItem(PI).KeyWords;
    FileType := EXPLORER_ITEM_GROUP;
  end else if PI is TPersonsItem then
    FileType := EXPLORER_ITEM_PERSON_LIST
  else if PI is TPersonItem then
  begin
    Comment := TPersonItem(PI).Comment;
    ID := TPersonItem(PI).PersonID;
    FileType := EXPLORER_ITEM_PERSON;
  end else if PI is TNetworkItem then
    FileType := EXPLORER_ITEM_NETWORK
  else if PI is TWorkgroupItem then
    FileType := EXPLORER_ITEM_WORKGROUP
  else if PI is TComputerItem then
    FileType := EXPLORER_ITEM_COMPUTER
  else if PI is TShareItem then
    FileType := EXPLORER_ITEM_SHARE
  else if PI is TPortableDeviceItem then
    FileType := EXPLORER_ITEM_DEVICE
  else if PI is TPortableStorageItem then
    FileType := EXPLORER_ITEM_DEVICE_STORAGE
  else if PI is TPortableDirectoryItem then
    FileType := EXPLORER_ITEM_DEVICE_DIRECTORY
  else if PI is TPortableImageItem then
  begin
    FileSize := TPortableImageItem(PI).FileSize;
    FileType := EXPLORER_ITEM_DEVICE_IMAGE;
    Width := TPortableImageItem(PI).Width;
    Height := TPortableImageItem(PI).Height;
  end
  else if PI is TPortableVideoItem then
  begin
    FileSize := TPortableVideoItem(PI).FileSize;
    FileType := EXPLORER_ITEM_DEVICE_VIDEO
  end
  else if PI is TPortableFileItem then
  begin
    FileSize := TPortableFileItem(PI).FileSize;
    FileType := EXPLORER_ITEM_DEVICE_FILE;
  end
  else if PI is TShelfItem then
    FileType := EXPLORER_ITEM_SHELF
  else if PI is TDateStackItem then
    FileType := EXPLORER_ITEM_CALENDAR
  else if PI is TDateStackYearItem then
    FileType := EXPLORER_ITEM_CALENDAR_YEAR
  else if PI is TDateStackMonthItem then
    FileType := EXPLORER_ITEM_CALENDAR_MONTH
  else if PI is TDateStackDayItem then
    FileType := EXPLORER_ITEM_CALENDAR_DAY
  else if PI is TSearchItem then
    FileType := EXPLORER_ITEM_SEARCH;
end;

function TExplorerFileInfo.InitNewInstance: TMediaItem;
begin
  Result := TExplorerFileInfo.Create;
end;

{ TLoadPathList }

constructor TLoadPathList.Create(Owner: TThreadForm; PathList: TArExplorerPath;
  Sender: TPopupActionBar);
begin
  inherited Create(Owner, Owner.StateID);
  FOwner := Owner;
  FPathList := Copy(PathList);
  FSender := Sender;
end;

procedure TLoadPathList.Execute;
var
  I: Integer;
  PI: TPathItem;
begin
  inherited;
  FreeOnTerminate := True;
  FIcons := TPathItemCollection.Create;
  try
    for I := 0 to Length(FPathList) - 1 do
    begin
      PI := PathProviderManager.CreatePathItem(FPathList[I].Path);
      if PI <> nil then
      begin
        PI.LoadImage(PATH_LOAD_NORMAL or PATH_LOAD_FOR_IMAGE_LIST, 16);
        FIcons.Add(PI);
      end;
    end;

    SynchronizeEx(UpdateMenu);
  finally
    FIcons.FreeItems;
    F(FIcons);
  end;
end;

procedure TLoadPathList.UpdateMenu;
begin
  TExplorerForm(FOwner).UpdateMenuItems(FSender, FPathList, FIcons);
end;

{ TCustomExplorerForm }

constructor TCustomExplorerForm.Create(AOwner: TComponent;
  GoToLastSavedPath: Boolean);
begin
  FWindowID := GetGUID;
end;

{ TUpdaterInfo }

procedure TUpdaterInfo.Assign(Info: TUpdaterInfo);
begin
  Context := Info.Context;
  IsUpdater := Info.IsUpdater;
  UpdateDB := Info.UpdateDB;
  ProcHelpAfterUpdate := Info.ProcHelpAfterUpdate;
  NewFileItem := Info.NewFileItem;
  SetFileInfo(Info.FFileInfo);
  DisableLoadingOfBigImage := Info.DisableLoadingOfBigImage;
end;

procedure TUpdaterInfo.ClearInfo;
begin
  SetFileInfo(nil);
end;

function TUpdaterInfo.Copy: TUpdaterInfo;
begin
  Result := TUpdaterInfo.Create;
  Result.Assign(Self);
end;

procedure TUpdaterInfo.Init;
begin
  FIsUpdater := False;
  FUpdateDB := False;
  FProcHelpAfterUpdate := nil;
  FNewFileItem := False;
  FFileInfo := nil;
  FDisableLoadingOfBigImage := False;
  Context := nil;
end;

constructor TUpdaterInfo.Create(Context: IDBContext; Info: TExplorerFileInfo);
begin
  Init;
  FContext := Context;
  SetFileInfo(Info);
end;

constructor TUpdaterInfo.Create;
begin
  Init;
end;

destructor TUpdaterInfo.Destroy;
begin
  F(FFileInfo);
  inherited;
end;

function TUpdaterInfo.GetFileName: string;
begin
  if FFileInfo <> nil then
    Result := FFileInfo.FileName
  else
    Result := '';
end;

function TUpdaterInfo.GetID: Integer;
begin
  if FFileInfo <> nil then
    Result := FFileInfo.ID
  else
    Result := 0;
end;

function TUpdaterInfo.GetSID: TGUID;
begin
  if FFileInfo <> nil then
    Result := FFileInfo.SID
  else
    Result := GetEmptyGUID;
end;

procedure TUpdaterInfo.SetFileInfo(const Value: TExplorerFileInfo);
begin
  F(FFileInfo);
  if Value <> nil then
    FFileInfo := TExplorerFileInfo(Value.Copy);
end;

end.

