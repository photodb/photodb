unit VistaFileDialogs;

interface

uses Windows, Classes, ShlObj, ActiveX, VistaDialogInterfaces,
     Forms, SysUtils;

type

  TFileDialogOption = (fdoOverWritePrompt, fdoStrictFileTypes,
    fdoNoChangeDir, fdoPickFolders, fdoForceFileSystem,
    fdoAllNonStorageItems, fdoNoValidate, fdoAllowMultiSelect,
    fdoPathMustExist, fdoFileMustExist, fdoCreatePrompt,
    fdoShareAware, fdoNoReadOnlyReturn, fdoNoTestFileCreate,
    fdoHideMRUPlaces, fdoHidePinnedPlaces, fdoNoDereferenceLinks,
    fdoDontAddToRecent, fdoForceShowHidden, fdoDefaultNoMiniMode,
    fdoForcePreviewPaneOn);                            
  TFileDialogOptions = set of TFileDialogOption;

  TFileDialogOverwriteResponse = (forDefault = FDEOR_DEFAULT,
    forAccept = FDEOR_ACCEPT, forRefuse = FDEOR_REFUSE);
  TFileDialogShareViolationResponse = (fsrDefault = FDESVR_DEFAULT,
    fsrAccept = FDESVR_ACCEPT, fsrRefuse = FDESVR_REFUSE);

  TFileDialogCloseEvent = procedure(Sender: TObject; var CanClose: Boolean) of object;
  TFileDialogFolderChangingEvent = procedure(Sender: TObject; var CanChange: Boolean) of object;
  TFileDialogOverwriteEvent = procedure(Sender: TObject;
    var Response: TFileDialogOverwriteResponse) of object;
  TFileDialogShareViolationEvent = procedure(Sender: TObject;
    var Response: TFileDialogShareViolationResponse) of object;

 TFileTypeItem = class(TCollectionItem)
  private
    FDisplayName: string;
    FDisplayNameWStr: LPCWSTR;
    FFileMask: string;
    FFileMaskWStr: LPCWSTR;
    function GetDisplayNameWStr: LPCWSTR;
    function GetFileMaskWStr: LPCWSTR;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property DisplayNameWStr: LPCWSTR read GetDisplayNameWStr;
    property FileMaskWStr: LPCWSTR read GetFileMaskWStr;
  published
    property DisplayName: string read FDisplayName write FDisplayName;
    property FileMask: string read FFileMask write FFileMask;
  end;

  TFileTypeItems = class(TCollection)
  private
    function GetItem(Index: Integer): TFileTypeItem;
    procedure SetItem(Index: Integer; const Value: TFileTypeItem);
  public
    function Add: TFileTypeItem;
    function FilterSpecArray: TComdlgFilterSpecArray;
    property Items[Index: Integer]: TFileTypeItem read GetItem write SetItem; default;
  end;

  TFavoriteLinkItem = class(TCollectionItem)
  private
    FLocation: string;
  published
  protected
    function GetDisplayName: string; override;
  published
    property Location: string read FLocation write FLocation;
  end;

  TFavoriteLinkItems = class;

  TFavoriteLinkItemsEnumerator = class
  private
    FIndex: Integer;
    FCollection: TFavoriteLinkItems;
  public
    constructor Create(ACollection: TFavoriteLinkItems);
    function GetCurrent: TFavoriteLinkItem;
    function MoveNext: Boolean;
    property Current: TFavoriteLinkItem read GetCurrent;
  end;

  TFavoriteLinkItems = class(TCollection)
  private
    function GetItem(Index: Integer): TFavoriteLinkItem;
    procedure SetItem(Index: Integer; const Value: TFavoriteLinkItem);
  public
    function Add: TFavoriteLinkItem;
    function GetEnumerator: TFavoriteLinkItemsEnumerator;
    property Items[Index: Integer]: TFavoriteLinkItem read GetItem write SetItem; default;
  end;

  TFileName = string;

  TCustomFileDialog = class(TComponent)
  private
    FClientGuid: string;
    FDefaultExtension: string;
    FDefaultFolder: string;
    FDialog: IFileDialog;
    FFavoriteLinks: TFavoriteLinkItems;
    FFileName: TFileName;
    FFileNameLabel: string;
    FFiles: TStrings;
    FFileTypeIndex: Cardinal;
    FFileTypes: TFileTypeItems;
    FHandle: HWnd;
    FOkButtonLabel: string;
    FOptions: TFileDialogOptions;
    FShellItem: IShellItem;
    FShellItems: IShellItemArray;
    FTitle: string;
    FOnExecute: TNotifyEvent;
    FOnFileOkClick: TFileDialogCloseEvent;
    FOnFolderChange: TNotifyEvent;
    FOnFolderChanging: TFileDialogFolderChangingEvent;
    FOnOverwrite: TFileDialogOverwriteEvent;
    FOnSelectionChange: TNotifyEvent;
    FOnShareViolation: TFileDialogShareViolationEvent;
    FOnTypeChange: TNotifyEvent;
    function GetDefaultFolder: string;
    function GetFileName: TFileName;
    function GetFiles: TStrings;
    procedure GetWindowHandle;
    procedure SetClientGuid(const Value: string);
    procedure SetDefaultFolder(const Value: string);
    procedure SetFavoriteLinks(const Value: TFavoriteLinkItems);
    procedure SetFileName(const Value: TFileName);
    procedure SetFileTypes(const Value: TFileTypeItems);
  protected
    function CreateFileDialog: IFileDialog; virtual; abstract;
    procedure DoOnExecute; dynamic;
    function DoOnFileOkClick: Boolean; dynamic;
    procedure DoOnFolderChange; dynamic;
    function DoOnFolderChanging: Boolean; dynamic;
    procedure DoOnOverwrite(var Response: TFileDialogOverwriteResponse); dynamic;
    procedure DoOnSelectionChange; dynamic;
    procedure DoOnShareViolation(var Response: TFileDialogShareViolationResponse); dynamic;
    procedure DoOnTypeChange; dynamic;
    function GetFileNames(Items: IShellItemArray): HResult; dynamic;
    function GetItemName(Item: IShellItem; var ItemName: TFileName): HResult; dynamic;
    function GetResults: HResult; virtual;
  protected
    function FileOkClick: HResult; dynamic;
    function FolderChange: HResult; dynamic;
    function FolderChanging(psiFolder: IShellItem): HResult; dynamic;
    function Overwrite(psiFile: IShellItem; var Response: Cardinal): HResult; dynamic;
    function SelectionChange: HResult; dynamic;
    function ShareViolation(psiFile: IShellItem; var Response: Cardinal): HResult; dynamic;
    function TypeChange: HResult; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; overload; virtual;
    function Execute(ParentWnd: HWND): Boolean; overload; virtual;
    property ClientGuid: string read FClientGuid write SetClientGuid;
    property DefaultExtension: string read FDefaultExtension write FDefaultExtension;
    property DefaultFolder: string read GetDefaultFolder write SetDefaultFolder;
    property Dialog: IFileDialog read FDialog;
    property FavoriteLinks: TFavoriteLinkItems read FFavoriteLinks write SetFavoriteLinks;
    property FileName: TFileName read GetFileName write SetFileName;
    property FileNameLabel: string read FFileNameLabel write FFileNameLabel;
    property Files: TStrings read GetFiles;
    property FileTypes: TFileTypeItems read FFileTypes write SetFileTypes;
    property FileTypeIndex: Cardinal read FFileTypeIndex write FFileTypeIndex default 1;
    property Handle: HWnd read FHandle;
    property OkButtonLabel: string read FOkButtonLabel write FOkButtonLabel;
    property Options: TFileDialogOptions read FOptions write FOptions;
    property ShellItem: IShellItem read FShellItem;
    property ShellItems: IShellItemArray read FShellItems;
    property Title: string read FTitle write FTitle;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
    property OnFileOkClick: TFileDialogCloseEvent read FOnFileOkClick write FOnFileOkClick;
    property OnFolderChange: TNotifyEvent read FOnFolderChange write FOnFolderChange;
    property OnFolderChanging: TFileDialogFolderChangingEvent read FOnFolderChanging write FOnFolderChanging;
    property OnOverwrite: TFileDialogOverwriteEvent read FOnOverwrite write FOnOverwrite;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property OnShareViolation: TFileDialogShareViolationEvent read FOnShareViolation write FOnShareViolation;
    property OnTypeChange: TNotifyEvent read FOnTypeChange write FOnTypeChange;
  end;

  { TFileOpenDialog }

  TCustomFileOpenDialog = class(TCustomFileDialog)
  protected
    function CreateFileDialog: IFileDialog; override;
    function GetResults: HResult; override;
    function SelectionChange: HResult; override;
  end;

    TFileOpenDialog = class(TCustomFileOpenDialog)
  published
    property ClientGuid;
    property DefaultExtension;
    property DefaultFolder;
    property FavoriteLinks;
    property FileName;
    property FileNameLabel;
    property FileTypes;
    property FileTypeIndex;
    property OkButtonLabel;
    property Options;
    property Title;
    property OnExecute;
    property OnFileOkClick;
    property OnFolderChange;
    property OnFolderChanging;
    property OnSelectionChange;
    property OnShareViolation;
    property OnTypeChange;
  end; //platform

  { TFileSaveDialog }

  TCustomFileSaveDialog = class(TCustomFileDialog)
  protected
    function CreateFileDialog: IFileDialog; override;
  end;

  TFileSaveDialog = class(TCustomFileSaveDialog)
  published
    property ClientGuid;
    property DefaultExtension;
    property DefaultFolder;
    property FavoriteLinks;
    property FileName;
    property FileNameLabel;
    property FileTypes;
    property FileTypeIndex;
    property OkButtonLabel;
    property Options;
    property Title;
    property OnExecute;
    property OnFileOkClick;
    property OnFolderChange;
    property OnFolderChanging;
    property OnOverwrite;
    property OnSelectionChange;
    property OnShareViolation;
    property OnTypeChange;
  end platform;

const
  shell32 = 'shell32.dll';

var
  Shell32Lib: HModule;

function SHCreateItemFromParsingName(pszPath: LPCWSTR; const pbc: IBindCtx;
  const riid: TIID; out ppv): HResult;

var
  _SHCreateItemFromParsingName: function(pszPath: LPCWSTR; const pbc: IBindCtx;
    const riid: TIID; out ppv): HResult; stdcall;


implementation

{ TFileDialogFileType }

function WStrLCopy(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar;
var
  Src : PWideChar;
begin
  Result := Dest;
  Src := Source;
  while (Src^ <> #$00) and (MaxLen > 0) do
  begin
    Dest^ := Src^;
    Inc(Src);
    Inc(Dest);
    Dec(MaxLen);
  end;
  Dest^ := #$00;
end;

function WStrPCopy(Dest: PWideChar; const Source: WideString): PWideChar;
begin
  Result := WStrLCopy(Dest, PWideChar(Source), Length(Source));
end;

function WStrPLCopy(Dest: PWideChar; const Source: WideString; MaxLen: Cardinal): PWideChar;
begin
  Result := WStrLCopy(Dest, PWideChar(Source), MaxLen);
end;

constructor TFileTypeItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FDisplayNameWStr := nil;
  FFileMaskWStr := nil;
end;

destructor TFileTypeItem.Destroy;
begin
  if FDisplayNameWStr <> nil then
    CoTaskMemFree(FDisplayNameWStr);
  if FFileMaskWStr <> nil then
    CoTaskMemFree(FFileMaskWStr);
  inherited;
end;

function TFileTypeItem.GetDisplayNameWStr: LPCWSTR;
var
  Len: Integer;
begin
  if FDisplayNameWStr <> nil then
    CoTaskMemFree(FDisplayNameWStr);
  Len := Length(FDisplayName);
  FDisplayNameWStr := CoTaskMemAlloc((Len * 2) + 2);
  Result := WStrPLCopy(FDisplayNameWStr, WideString(FDisplayName), Len);
end;

function TFileTypeItem.GetDisplayName: string;
begin
  if FDisplayName <> '' then
    Result := FDisplayName
  else
    Result := inherited GetDisplayName;
end;

function TFileTypeItem.GetFileMaskWStr: LPCWSTR;
var
  Len: Integer;
begin
  if FFileMaskWStr <> nil then
    CoTaskMemFree(FFileMaskWStr);
  Len := Length(FFileMask);
  FFileMaskWStr := CoTaskMemAlloc((Len * 2) + 2);
  Result := WStrPLCopy(FFileMaskWStr, WideString(FFileMask), Len);
end;

{ TFileDialogFileTypes }

function TFileTypeItems.Add: TFileTypeItem;
begin
  Result := TFileTypeItem(inherited Add);
end;

function TFileTypeItems.FilterSpecArray: TComdlgFilterSpecArray;
var
  I: Integer;
begin
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
  begin
    Result[I].pszName := Items[I].DisplayNameWStr;
    Result[I].pszSpec := Items[I].FileMaskWStr;
  end;
end;

function TFileTypeItems.GetItem(Index: Integer): TFileTypeItem;
begin
  Result := TFileTypeItem(inherited GetItem(Index));
end;

procedure TFileTypeItems.SetItem(Index: Integer; const Value: TFileTypeItem);
begin
  inherited SetItem(Index, Value);
end;

{ TFilePlacesEnumerator }

constructor TFavoriteLinkItemsEnumerator.Create(ACollection: TFavoriteLinkItems);
begin
  inherited Create;
  FIndex := -1;
  FCollection := ACollection;
end;

function TFavoriteLinkItemsEnumerator.GetCurrent: TFavoriteLinkItem;
begin
  Result := FCollection[FIndex];
end;

function TFavoriteLinkItemsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FCollection.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TFilePlaceItem }

function TFavoriteLinkItem.GetDisplayName: string;
begin
  if FLocation <> '' then
    Result := FLocation
  else
    Result := inherited GetDisplayName;
end;

{ TFilePlaces }

function TFavoriteLinkItems.Add: TFavoriteLinkItem;
begin
  Result := TFavoriteLinkItem(inherited Add);
end;

function TFavoriteLinkItems.GetEnumerator: TFavoriteLinkItemsEnumerator;
begin
  Result := TFavoriteLinkItemsEnumerator.Create(Self);
end;

function TFavoriteLinkItems.GetItem(Index: Integer): TFavoriteLinkItem;
begin
  Result := TFavoriteLinkItem(inherited GetItem(Index));
end;

procedure TFavoriteLinkItems.SetItem(Index: Integer; const Value: TFavoriteLinkItem);
begin
  inherited SetItem(Index, Value);
end;

{ TFileDialogEvents }

{ TFileDialogEvents }

type
  TFileDialogEvents = class(TInterfacedObject, IFileDialogEvents)
  private
    FFileDialog: TCustomFileDialog;
    FRetrieveHandle: Boolean;
  public
    constructor Create(AFileDialog: TCustomFileDialog);
    { IFileDialogEvents }
    function OnFileOk(const pfd: IFileDialog): HResult; stdcall;
    function OnFolderChanging(const pfd: IFileDialog;
      const psiFolder: IShellItem): HResult; stdcall;
    function OnFolderChange(const pfd: IFileDialog): HResult; stdcall;
    function OnSelectionChange(const pfd: IFileDialog): HResult; stdcall;
    function OnShareViolation(const pfd: IFileDialog; const psi: IShellItem;
      out pResponse: DWORD): HResult; stdcall;
    function OnTypeChange(const pfd: IFileDialog): HResult; stdcall;
    function OnOverwrite(const pfd: IFileDialog; const psi: IShellItem;
      out pResponse: DWORD): HResult; stdcall;
  end;

constructor TFileDialogEvents.Create(AFileDialog: TCustomFileDialog);
begin
  FFileDialog := AFileDialog;
  FRetrieveHandle := True;
end;

function TFileDialogEvents.OnFileOk(const pfd: IFileDialog): HResult;
begin
  if Assigned(FFileDialog.OnFileOkClick) then
    Result := FFileDialog.FileOkClick
  else
    Result := E_NOTIMPL;
end;

function TFileDialogEvents.OnFolderChange(const pfd: IFileDialog): HResult;
begin
  if Assigned(FFileDialog.OnFolderChange) then
    Result := FFileDialog.FolderChange
  else
    Result := E_NOTIMPL;
end;

function TFileDialogEvents.OnFolderChanging(const pfd: IFileDialog;
  const psiFolder: IShellItem): HResult;
begin
  if Assigned(FFileDialog.OnFolderChanging) then
    Result := FFileDialog.FolderChanging(psiFolder)
  else
    Result := E_NOTIMPL;
end;

function TFileDialogEvents.OnOverwrite(const pfd: IFileDialog;
  const psi: IShellItem; out pResponse: DWORD): HResult;
begin
  if Assigned(FFileDialog.OnOverwrite) then
    Result := FFileDialog.Overwrite(psi, pResponse)
  else
    Result := E_NOTIMPL;
end;

function TFileDialogEvents.OnSelectionChange(const pfd: IFileDialog): HResult;
begin
  // OnSelectionChange is called when the dialog is opened, use this
  // to retrieve the window handle if OnTypeChange wasn't triggered.
  if FRetrieveHandle then
  begin
    FFileDialog.GetWindowHandle;
    FRetrieveHandle := False;
  end;

  if Assigned(FFileDialog.OnSelectionChange) then
    Result := FFileDialog.SelectionChange
  else
    Result := E_NOTIMPL;
end;

function TFileDialogEvents.OnShareViolation(const pfd: IFileDialog;
  const psi: IShellItem; out pResponse: DWORD): HResult;
begin
  if Assigned(FFileDialog.OnShareViolation) then
    Result := FFileDialog.ShareViolation(psi, pResponse)
  else
    Result := E_NOTIMPL;
end;

function TFileDialogEvents.OnTypeChange(const pfd: IFileDialog): HResult;
begin
  // OnTypeChange is supposed to always be called when the dialog is
  // opened. In reality it isn't called if you don't assign any FileTypes.
  // Use this to retrieve the window handle, if it's called.
  if FRetrieveHandle then
  begin
    FFileDialog.GetWindowHandle;
    FRetrieveHandle := False;
  end;

  if Assigned(FFileDialog.OnTypeChange) then
    Result := FFileDialog.TypeChange
  else
    Result := E_NOTIMPL;
end;

{ TCustomFileDialog }

constructor TCustomFileDialog.Create(AOwner: TComponent);
begin
  inherited;
  FFiles := TStringList.Create;
  FFileTypeIndex := 1;
  FFileTypes := TFileTypeItems.Create(TFileTypeItem);
  FHandle := 0;
  FOptions := [];
  FFavoriteLinks := TFavoriteLinkItems.Create(TFavoriteLinkItem); //TStringList.Create;
  FShellItem := nil;
  FShellItems := nil;
end;

destructor TCustomFileDialog.Destroy;
begin
  FFiles.Free;
  FFileTypes.Free;
  FFavoriteLinks.Free;
  FShellItem := nil;
  FShellItems := nil;
  inherited;
end;

procedure TCustomFileDialog.DoOnExecute;
begin
  if Assigned(FOnExecute) then
    FOnExecute(Self);
end;

function TCustomFileDialog.DoOnFileOkClick: Boolean;
begin
  Result := True;
  if Assigned(FOnFileOkClick) then
    FOnFileOkClick(Self, Result);
end;

procedure TCustomFileDialog.DoOnFolderChange;
begin
  if Assigned(FOnFolderChange) then
    FOnFolderChange(Self);
end;

function TCustomFileDialog.DoOnFolderChanging: Boolean;
begin
  Result := True;
  if Assigned(FOnFolderChanging) then
    FOnFolderChanging(Self, Result);
end;

procedure TCustomFileDialog.DoOnOverwrite(var Response: TFileDialogOverwriteResponse);
begin
  if Assigned(FOnOverwrite) then
    FOnOverwrite(Self, Response);
end;

procedure TCustomFileDialog.DoOnSelectionChange;
begin
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self);
end;

procedure TCustomFileDialog.DoOnShareViolation(var Response: TFileDialogShareViolationResponse);
begin
  if Assigned(FOnShareViolation) then
    FOnShareViolation(Self, Response);
end;

procedure TCustomFileDialog.DoOnTypeChange;
begin
  if Assigned(FOnTypeChange) then
    FOnTypeChange(Self);
end;

                                                                                           
function TCustomFileDialog.Execute: Boolean;
var
  ParentWnd: HWND;
begin
{  if Application.ModalPopupMode <> pmNone then
  begin
    ParentWnd := Application.ActiveFormHandle;
    if ParentWnd = 0 then
      ParentWnd := Application.Handle;
  end
  else   }
    ParentWnd := Application.Handle;
  Result := Execute(ParentWnd);
end;

                                                                                           
function TCustomFileDialog.Execute(ParentWnd: HWND): Boolean;
const
  CDialogOptions: array[TFileDialogOption] of DWORD = (
    FOS_OVERWRITEPROMPT, FOS_STRICTFILETYPES, FOS_NOCHANGEDIR,
    FOS_PICKFOLDERS, FOS_FORCEFILESYSTEM, FOS_ALLNONSTORAGEITEMS,
    FOS_NOVALIDATE, FOS_ALLOWMULTISELECT, FOS_PATHMUSTEXIST,
    FOS_FILEMUSTEXIST, FOS_CREATEPROMPT, FOS_SHAREAWARE,
    FOS_NOREADONLYRETURN, FOS_NOTESTFILECREATE, FOS_HIDEMRUPLACES,
    FOS_HIDEPINNEDPLACES, FOS_NODEREFERENCELINKS, FOS_DONTADDTORECENT,
    FOS_FORCESHOWHIDDEN, FOS_DEFAULTNOMINIMODE, FOS_FORCEPREVIEWPANEON);
var
  LWindowList: Pointer;
  LFocusState: TFocusState;
  LPlace: TFavoriteLinkItem;
  LShellItem: IShellItem;
  LAdviseCookie: Cardinal;
  LDialogOptions: Cardinal;
  LDialogEvents: TFileDialogEvents;
  LDialogOption: TFileDialogOption;
  i : integer;
begin
  Result := False;
  FDialog := CreateFileDialog;
  if FDialog <> nil then
    try
      with FDialog do
      begin
        // ClientGuid, DefaultExt, FileName, Title, OkButtonLabel, FileNameLabel
        if FClientGuid <> '' then
          SetClientGuid(StringToGUID(FClientGuid));
        if FDefaultExtension <> '' then
          SetDefaultExtension(PWideChar(WideString(FDefaultExtension)));
        if FFileName <> '' then
          SetFileName(PWideChar(WideString(FFileName)));
        if FFileNameLabel <> '' then
          SetFileNameLabel(PWideChar(WideString(FFileNameLabel)));
        if FOkButtonLabel <> '' then
          SetOkButtonLabel(PWideChar(WideString(FOkButtonLabel)));
        if FTitle <> '' then
          SetTitle(PWideChar(WideString(FTitle)));

        // DefaultFolder
        if FDefaultFolder <> '' then
        begin
          if Succeeded(SHCreateItemFromParsingName(PWideChar(WideString(FDefaultFolder)),
             nil, StringToGUID(SID_IShellItem), LShellItem)) then
            SetFolder(LShellItem);
        end;

        // FileTypes, FileTypeIndex
        if FFileTypes.Count > 0 then
        begin
          FDialog.SetFileTypes(FFileTypes.Count, FFileTypes.FilterSpecArray);
          SetFileTypeIndex(FFileTypeIndex);
        end;

        // Options
        LDialogOptions := 0;

        for LDialogOption:=Low(TFileDialogOption) to High(TFileDialogOption) do
        if LDialogOption in Options then
          LDialogOptions := LDialogOptions or CDialogOptions[LDialogOption];

        SetOptions(LDialogOptions);


        // Additional Places
        for i:=0 to FFavoriteLinks.Count-1 do
        begin
          LPlace:=FFavoriteLinks[i];
          if Succeeded(SHCreateItemFromParsingName(PWideChar(WideString(LPlace.Location)),
             nil, StringToGUID(SID_IShellItem), LShellItem)) then
            AddPlace(LShellItem, FDAP_BOTTOM);
        end;
 
        // Show dialog and get results
        DoOnExecute;
        LWindowList := DisableTaskWindows(ParentWnd);
        LFocusState := SaveFocusState;
        try
          LDialogEvents := TFileDialogEvents.Create(Self);
          Advise(LDialogEvents, LAdviseCookie);
          try
            Result := Succeeded(Show(ParentWnd));
            if Result then
              Result := Succeeded(GetResults);
          finally
            Unadvise(LAdviseCookie);
          end;
        finally
          EnableTaskWindows(LWindowList);
          SetActiveWindow(ParentWnd);
          RestoreFocusState(LFocusState);
        end;
      end;
    finally
      FDialog := nil;
    end;
end;

function TCustomFileDialog.FileOkClick: HResult;
const
  CResults: array[Boolean] of HResult = (S_FALSE, S_OK);
begin
  Result := GetResults;
  if Succeeded(Result) then
    Result := CResults[DoOnFileOkClick];
  Files.Clear;
end;

function TCustomFileDialog.FolderChange: HResult;
begin
  FFileName := '';
  Result := FDialog.GetFolder(FShellItem);
  if Succeeded(Result) then
  begin
    Result := GetItemName(FShellItem, FFileName);
    if Succeeded(Result) then
      DoOnFolderChange;
  end;
  FShellItem := nil;
end;

function TCustomFileDialog.FolderChanging(psiFolder: IShellItem): HResult;
const
  CResults: array[Boolean] of HResult = (S_FALSE, S_OK);
begin
  FFileName := '';
  FShellItem := psiFolder;
  Result := GetItemName(FShellItem, FFileName);
  if Succeeded(Result) then
    Result := CResults[DoOnFolderChanging];
  FShellItem := nil;
end;

                                                                    
function TCustomFileDialog.GetDefaultFolder: string;
begin
  Result := FDefaultFolder;
end;

                                                                    
function TCustomFileDialog.GetFileName: TFileName;
begin
  Result := FFileName;
end;

function TCustomFileDialog.GetFileNames(Items: IShellItemArray): HResult;
var
  Count: Integer;
  LShellItem: IShellItem;
  LEnumerator: IEnumShellItems;
begin
  Files.Clear;
  Result := Items.EnumItems(LEnumerator);
  if Succeeded(Result) then
  begin
    Result := LEnumerator.Next(1, LShellItem, @Count);
    while Succeeded(Result) and (Count <> 0) do
    begin
      GetItemName(LShellItem, FFileName);
      Files.Add(FFileName);
      Result := LEnumerator.Next(1, LShellItem, @Count);
    end;
    if Files.Count > 0 then
      FFileName := Files[0];
  end;
end;

                                                                    
function TCustomFileDialog.GetFiles: TStrings;
begin
  Result := FFiles;
end;

function TCustomFileDialog.GetItemName(Item: IShellItem; var ItemName: TFileName): HResult;
var
  pszItemName: PWideChar;
begin
  Result := Item.GetDisplayName(SIGDN_FILESYSPATH, pszItemName);
  if Failed(Result) then
    Result := Item.GetDisplayName(SIGDN_NORMALDISPLAY, pszItemName);
  if Succeeded(Result) then
  try
    ItemName := pszItemName;
  finally
    CoTaskMemFree(pszItemName);
  end;
end;

function TCustomFileDialog.GetResults: HResult;
begin
  Result := FDialog.GetResult(FShellItem);
  if Succeeded(Result) then
  begin
    Result := GetItemName(FShellItem, FFileName);
    FFiles.Clear;
    FFiles.Add(FFileName);
  end;
end;

procedure TCustomFileDialog.GetWindowHandle;
var
  LOleWindow: IOleWindow;
begin
  if Supports(FDialog, IOleWindow, LOleWindow) then
    LOleWindow.GetWindow(FHandle);
end;

function TCustomFileDialog.Overwrite(psiFile: IShellItem; var Response: Cardinal): HResult;
var
  LResponse: TFileDialogOverwriteResponse;
begin
  FFileName := '';
  LResponse := forAccept;
  FShellItem := psiFile;
  Result := GetItemName(FShellItem, FFileName);
  if Succeeded(Result) then
    DoOnOverwrite(LResponse);
  Response := Cardinal(LResponse);
  FShellItem := nil;
end;

function TCustomFileDialog.SelectionChange: HResult;
begin
  FFileName := '';
  Result := FDialog.GetCurrentSelection(FShellItem);
  if Succeeded(Result) then
  begin
    Result := GetItemName(FShellItem, FFileName);
    if Succeeded(Result) then
      DoOnSelectionChange;
  end;
  FShellItem := nil;
end;

procedure TCustomFileDialog.SetClientGuid(const Value: string);
begin
  if Value <> FClientGuid then
  begin
    if Value <> '' then
      StringToGUID(Value);
    FClientGuid := Value;
  end;
end;

                                                                    
procedure TCustomFileDialog.SetDefaultFolder(const Value: string);
begin
  if FDefaultFolder <> Value then
    FDefaultFolder := Value;
end;

                                                                    
procedure TCustomFileDialog.SetFileName(const Value: TFileName);
begin
  if Value <> FFileName then
    FFileName := Value;
end;

procedure TCustomFileDialog.SetFileTypes(const Value: TFileTypeItems);
begin
  if Value <> nil then
    FFileTypes.Assign(Value);
end;

                                                                    
procedure TCustomFileDialog.SetFavoriteLinks(const Value: TFavoriteLinkItems);
begin
  if Value <> nil then
    FFavoriteLinks.Assign(Value);
end;

function TCustomFileDialog.ShareViolation(psiFile: IShellItem;
  var Response: Cardinal): HResult;
var
  LResponse: TFileDialogShareViolationResponse;
begin
  FFileName := '';
  LResponse := fsrAccept;
  FShellItem := psiFile;
  Result := GetItemName(FShellItem, FFileName);
  if Succeeded(Result) then
    DoOnShareViolation(LResponse);
  Response := Cardinal(LResponse);
  FShellItem := nil;
end;

function TCustomFileDialog.TypeChange: HResult;
begin
  Result := FDialog.GetFileTypeIndex(FFileTypeIndex);
  if Succeeded(Result) then
    DoOnTypeChange;
end;

{ TCustomFileOpenDialog }

function TCustomFileOpenDialog.CreateFileDialog: IFileDialog;
begin
  CoCreateInstance(CLSID_FileOpenDialog, nil, CLSCTX_INPROC_SERVER,
    IFileOpenDialog, Result);
end;

function TCustomFileOpenDialog.GetResults: HResult;
begin
  if not (fdoAllowMultiSelect in Options) then
    Result := inherited GetResults
  else
  begin
    Result := (Dialog as IFileOpenDialog).GetResults(FShellItems);
    if Succeeded(Result) then
      Result := GetFileNames(FShellItems);
  end;
end;

function TCustomFileOpenDialog.SelectionChange: HResult;
begin
  if not (fdoAllowMultiSelect in Options) then
    Result := inherited SelectionChange
  else
  begin
    Result := (Dialog as IFileOpenDialog).GetSelectedItems(FShellItems);
    if Succeeded(Result) then
    begin
      Result := GetFileNames(FShellItems);
      if Succeeded(Result) then
      begin
        Dialog.GetCurrentSelection(FShellItem);
        DoOnSelectionChange;
      end;
      FShellItems := nil;
    end;
  end;
end;

function TCustomFileSaveDialog.CreateFileDialog: IFileDialog;
begin
  CoCreateInstance(CLSID_FileSaveDialog, nil, CLSCTX_INPROC_SERVER,
    IFileSaveDialog, Result);
end;

procedure InitShlObj;
begin
  Shell32Lib := GetModuleHandle(shell32);
end;

function SHCreateItemFromParsingName(pszPath: LPCWSTR; const pbc: IBindCtx;
  const riid: TIID; out ppv): HResult;
begin
  if Assigned(_SHCreateItemFromParsingName) then
    Result := _SHCreateItemFromParsingName(pszPath, pbc, riid, ppv)
  else
  begin
    InitShlObj;
    Result := E_NOTIMPL;
    if Shell32Lib > 0 then
    begin
      _SHCreateItemFromParsingName := GetProcAddress(Shell32Lib, 'SHCreateItemFromParsingName'); // Do not localize
      if Assigned(_SHCreateItemFromParsingName) then
        Result := _SHCreateItemFromParsingName(pszPath, pbc, riid, ppv);
    end;
  end;
end;

end.
