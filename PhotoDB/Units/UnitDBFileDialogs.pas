unit UnitDBFileDialogs;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.ActiveX,
  Winapi.ShlObj,
  Vcl.Dialogs,
  Vcl.ExtDlgs,

  Dmitry.Utils.System,
  Dmitry.Utils.Dialogs,

  {$IFDEF PHOTODB}
  uAppUtils,
  uPortableDeviceManager,
  {$ENDIF}
  uConstants,
  uMemory,
  uVistaFuncs;

type
  DBSaveDialog = class(TObject)
  private
    Dialog: TObject;
    FFilterIndex: Integer;
    FFilter: string;
    procedure SetFilter(const Value: string);
    procedure OnFilterIndexChanged(Sender: TObject);
 public
    constructor Create;
    destructor Destroy; override;
    function Execute: Boolean;
    procedure SetFilterIndex(const Value: Integer);
    function GetFilterIndex: Integer;
    function FileName: string;
    procedure SetFileName(FileName: string);
    property FilterIndex: Integer write SetFilterIndex;
    property Filter: string read FFilter write SetFilter;
 end;

type
  DBOpenDialog = class(TObject)
  private
    Dialog: TObject;
    FFilterIndex: Integer;
    FFilter: string;
    procedure SetFilter(const Value: string);
    function GetShellItem: IShellItem;
  public
    constructor Create();
    destructor Destroy; override;
    function Execute: Boolean;
    procedure SetFilterIndex(const Value: Integer);
    function GetFilterIndex: Integer;
    function FileName: string;
    procedure SetFileName(FileName: string);
    procedure SetOption(Option: TFileDialogOptions);
    procedure EnableMultyFileChooseWithDirectory;
    function GetFiles: TStrings;
    procedure EnableChooseWithDirectory;
    property FilterIndex: Integer write SetFilterIndex;
    property Filter: string read FFilter write SetFilter;
    property ShellItem: IShellItem read GetShellItem;
  end;

type
  DBOpenPictureDialog = class(TObject)
  private
    Dialog: TObject;
    FFilterIndex: Integer;
    FFilter: string;
    procedure SetFilter(const Value: string);
  public
    constructor Create();
    destructor Destroy; override;
    function Execute: Boolean;
    procedure SetFilterIndex(const Value: Integer);
    function GetFilterIndex: Integer;
    function FileName: string;
    procedure SetFileName(FileName: string);
    property FilterIndex: Integer write SetFilterIndex;
    property Filter: string read FFilter write SetFilter;
  end;

type
  DBSavePictureDialog = class(TObject)
  private
    Dialog: TObject;
    FFilterIndex: Integer;
    FFilter: string;
    procedure SetFilter(const Value: string);
    procedure OnFilterIndexChanged(Sender: TObject);
  public
    constructor Create();
    destructor Destroy; override;
    function Execute: Boolean;
    procedure SetFilterIndex(const Value: Integer);
    function GetFilterIndex: Integer;
    function FileName: string;
    procedure SetFileName(FileName: string);
    property FilterIndex: Integer write SetFilterIndex;
    property Filter: string read FFilter write SetFilter;
  end;

function DBSelectDir(Handle: THandle; Title: string; UseSimple: Boolean): string; overload;
function DBSelectDir(Handle: THandle; Title, SelectedRoot: string; UseSimple: Boolean): string; overload;

implementation

function GetDOSEnvVar(const VarName: string): string;
var
  I: Integer;
begin
  Result := '';
  try
    I := GetEnvironmentVariable(PWideChar(VarName), nil, 0);
    if I > 0 then
    begin
      SetLength(Result, I);
      GetEnvironmentVariable(PWideChar(VarName), PWideChar(Result), I);
    end;
  except
    Result := '';
  end;
end;

function CanUseVistaDlg: Boolean;
begin
  Result := IsWindowsVista and (GetDOSEnvVar('SAFEBOOT_OPTION') = '')
  {$IFDEF PHOTODB} and not GetParamStrDBBool ('/NoVistaFileDlg'){$ENDIF};
end;

function DBSelectDir(Handle: THandle; Title: string; UseSimple: Boolean): string;
begin
  Result := DBSelectDir(Handle, Title, '', UseSimple);
end;

function GetItemName(Item: IShellItem; var ItemName: TFileName): HResult;
var
  pszItemName: LPCWSTR;
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

function DBSelectDir(Handle: THandle; Title, SelectedRoot: string; UseSimple: Boolean): string;
var
  OpenDialog: DBOpenDialog;
  {$IFDEF PHOTODB}
  Parent: IShellItem;
  FullItemPath, RootShellPath: string;
  I: Integer;
  ShellItemName: TFileName;
  ShellParentList: TList<IShellItem>;
  {$ENDIF}
begin
  Result := '';
  if UseSimple or not CanUseVistaDlg then
  begin
    Result := SelectDirPlus(Handle, Title, SelectedRoot);
  end else
  begin
    OpenDialog := DBOpenDialog.Create;
    try
    if SelectedRoot <> '' then
      if DirectoryExists(SelectedRoot) then
        OpenDialog.SetFileName(SelectedRoot);

    OpenDialog.SetOption([FdoPickFolders]);
    if OpenDialog.Execute then
      Result := OpenDialog.FileName;

    {$IFDEF PHOTODB}
    FullItemPath := '';
    if (Length(Result) > 2) and (Result[2] <> ':') and (OpenDialog.ShellItem <> nil) then
    begin
      ShellParentList := TList<IShellItem>.Create;
      try
        Parent := OpenDialog.ShellItem;
        while Parent <> nil do
        begin
          ShellParentList.Add(Parent);
          if not Succeeded(Parent.GetParent(Parent)) then
            Break;
        end;
        if ShellParentList.Count > 2 then
        begin
          RootShellPath := '';
          for I := 0 to ShellParentList.Count - 3 do
          begin
            GetItemName(ShellParentList[I], ShellItemName);
            FullItemPath := ShellItemName + '\' + FullItemPath;
            RootShellPath := ShellItemName;
          end;
          if CreateDeviceManagerInstance.GetDeviceByName(RootShellPath) <> nil then
            Result := cDevicesPath + '\' + FullItemPath;

          Result := ExcludeTrailingPathDelimiter(Result);
        end;
      finally
        F(ShellParentList);
      end;
    end;
    {$ENDIF}
    finally
      F(OpenDialog);
    end;
  end;
end;

{ DBSaveDialog }

constructor DBSaveDialog.Create;
begin
  if CanUseVistaDlg then
  begin
    Dialog := TFileSaveDialog.Create(nil);
    TFileSaveDialog(Dialog).OnTypeChange := OnFilterIndexChanged;
  end else
  begin
    Dialog := TSaveDialog.Create(nil);
  end;
end;

destructor DBSaveDialog.Destroy;
begin
  F(Dialog);
end;

function DBSaveDialog.Execute : boolean;
begin
  if CanUseVistaDlg then
    Result := TFileSaveDialog(Dialog).Execute
  else
    Result := TSaveDialog(Dialog).Execute;
end;

function DBSaveDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := TFileSaveDialog(Dialog).FileName
  else
    Result := TSaveDialog(Dialog).FileName;
end;

function DBSaveDialog.GetFilterIndex: integer;
begin
  if CanUseVistaDlg then
    Result := TFileSaveDialog(Dialog).FileTypeIndex
  else
    Result := TSaveDialog(Dialog).FilterIndex;
end;

procedure DBSaveDialog.OnFilterIndexChanged(Sender: TObject);
begin
  TFileSaveDialog(Dialog).FileTypeIndex := TFileSaveDialog(Dialog).FileTypeIndex;
end;

procedure DBSaveDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    TFileSaveDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    TFileSaveDialog(Dialog).FileName := ExtractFileName(FileName);
  end else
  begin
    TSaveDialog(Dialog).FileName := FileName;
  end;
end;

procedure DBSaveDialog.SetFilter(const Value: string);
var
  I, P: Integer;
  FilterStr: string;
  FilterMask: string;
  StrTemp: string;
  IsFilterMask: Boolean;
begin
  FFilter := Value;
  if CanUseVistaDlg then
  begin
    // DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
    P := 1;
    IsFilterMask := False;
    for I := 1 to Length(Value) do
      if (Value[I] = '|') or (I = Length(Value)) then
      begin
        if I = Length(Value) then
          StrTemp := Copy(Value, P, I - P + 1)
        else
          StrTemp := Copy(Value, P, I - P);
        if not IsFilterMask then
          FilterStr := StrTemp
        else
          FilterMask := StrTemp;

        if IsFilterMask then
        begin
          with TFileSaveDialog(Dialog).FileTypes.Add() do
          begin
            DisplayName := FilterStr;
            FileMask := FilterMask;
          end;
        end;
        IsFilterMask := not IsFilterMask;
        P := I + 1;
      end;
  end else
  begin
    TSaveDialog(Dialog).Filter := Value;
  end;
end;

procedure DBSaveDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    TSaveDialog(Dialog).FilterIndex := Value;
end;

{ DBOpenDialog }

constructor DBOpenDialog.Create;
begin
  if CanUseVistaDlg then
    Dialog := TFileOpenDialog.Create(nil)
  else
    Dialog := TOpenDialog.Create(nil);
end;

destructor DBOpenDialog.Destroy;
begin
  F(Dialog);
  inherited;
end;

procedure DBOpenDialog.EnableChooseWithDirectory;
begin
  if CanUseVistaDlg then
  begin
    TFileOpenDialog(Dialog).Options := TFileOpenDialog(Dialog).Options + [FdoPickFolders, FdoStrictFileTypes];
    TFileOpenDialog(Dialog).Files;
  end else
  begin
    TOpenDialog(Dialog).Options := TOpenDialog(Dialog).Options + [OfPathMustExist, OfFileMustExist, OfEnableSizing];
  end;
end;

procedure DBOpenDialog.EnableMultyFileChooseWithDirectory;
begin
  if CanUseVistaDlg then
  begin
    TFileOpenDialog(Dialog).Options := TFileOpenDialog(Dialog).Options + [FdoPickFolders, FdoForceFileSystem,
      FdoAllowMultiSelect, FdoPathMustExist, FdoFileMustExist,
      FdoForcePreviewPaneOn];
    TFileOpenDialog(Dialog).Files;
  end else
  begin
    TOpenDialog(Dialog).Options := TOpenDialog(Dialog).Options + [OfAllowMultiSelect, OfPathMustExist,
      OfFileMustExist, OfEnableSizing];
  end;
end;

function DBOpenDialog.Execute: Boolean;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).Execute
  else
    Result := TOpenDialog(Dialog).Execute;
end;

function DBOpenDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).FileName
  else
    Result := TOpenDialog(Dialog).FileName;
end;

function DBOpenDialog.GetFiles: TStrings;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).Files
  else
    Result := TOpenDialog(Dialog).Files;
end;

function DBOpenDialog.GetFilterIndex: Integer;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).FileTypeIndex
  else
    Result := TOpenDialog(Dialog).FilterIndex;
end;

function DBOpenDialog.GetShellItem: IShellItem;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).ShellItem
  else
    Result := nil; //not supported
end;

procedure DBOpenDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    TFileOpenDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    TFileOpenDialog(Dialog).FileName := ExtractFileName(FileName);
  end else
  begin
    TOpenDialog(Dialog).FileName := FileName;
  end;
end;

procedure DBOpenDialog.SetFilter(const Value: string);
var
  I, P: Integer;
  FilterStr: string;
  FilterMask: string;
  StrTemp: string;
  IsFilterMask: Boolean;
  FileType: TFileTypeItem;
begin
  FFilter := Value;
  if CanUseVistaDlg then
  begin
    // DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
    P := 1;
    IsFilterMask := False;
    for I := 1 to Length(Value) do
      if (Value[I] = '|') or (I = Length(Value)) then
      begin
        if I = Length(Value) then
          StrTemp := Copy(Value, P, I - P + 1)
        else
          StrTemp := Copy(Value, P, I - P);
        if not IsFilterMask then
          FilterStr := StrTemp
        else
          FilterMask := StrTemp;

        if IsFilterMask then
        begin
          FileType := TFileOpenDialog(Dialog).FileTypes.Add();
          FileType.DisplayName := FilterStr;
          FileType.FileMask := FilterMask;
        end;
        IsFilterMask := not IsFilterMask;
        P := I + 1;
      end;
  end else
  begin
    TOpenDialog(Dialog).Filter := Value;
  end;
end;

procedure DBOpenDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    TOpenDialog(Dialog).FilterIndex := Value;
end;

procedure DBOpenDialog.SetOption(Option: TFileDialogOptions);
begin
  if CanUseVistaDlg then
    TFileSaveDialog(Dialog).Options := TFileSaveDialog(Dialog).Options + Option;
end;

{ DBOpenPictureDialog }

constructor DBOpenPictureDialog.Create;
begin
  inherited;
  if CanUseVistaDlg then
  begin
    Dialog := TFileOpenDialog.Create(nil);
    TFileOpenDialog(Dialog).Options := TFileOpenDialog(Dialog).Options + [FdoForcePreviewPaneOn];
  end else
  begin
    Dialog := TOpenPictureDialog.Create(nil);
  end;
end;

destructor DBOpenPictureDialog.Destroy;
begin
  F(Dialog);
end;

function DBOpenPictureDialog.Execute: Boolean;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).Execute
  else
    Result := TOpenPictureDialog(Dialog).Execute;
end;

function DBOpenPictureDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).FileName
  else
    Result := TOpenPictureDialog(Dialog).FileName;
end;

function DBOpenPictureDialog.GetFilterIndex: Integer;
begin
  if CanUseVistaDlg then
    Result := TFileOpenDialog(Dialog).FileTypeIndex
  else
    Result := TOpenPictureDialog(Dialog).FilterIndex;
end;

procedure DBOpenPictureDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    TFileOpenDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    TFileOpenDialog(Dialog).FileName := ExtractFileName(FileName);
  end else
  begin
    TOpenPictureDialog(Dialog).FileName := FileName;
  end;
end;

procedure DBOpenPictureDialog.SetFilter(const Value: string);
var
  I, P: Integer;
  FilterStr: string;
  FilterMask: string;
  StrTemp: string;
  IsFilterMask: Boolean;
  FileType: TFileTypeItem;
begin
  FFilter := Value;
  if CanUseVistaDlg then
  begin
    // DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
    P := 1;
    IsFilterMask := False;
    for I := 1 to Length(Value) do
      if (Value[I] = '|') or (I = Length(Value)) then
      begin
        if I = Length(Value) then
          StrTemp := Copy(Value, P, I - P + 1)
        else
          StrTemp := Copy(Value, P, I - P);
        if not IsFilterMask then
          FilterStr := StrTemp
        else
          FilterMask := StrTemp;

        if IsFilterMask then
        begin
          FileType := TFileSaveDialog(Dialog).FileTypes.Add();
          FileType.DisplayName := FilterStr;
          FileType.FileMask := FilterMask;
        end;
        IsFilterMask := not IsFilterMask;
        P := I + 1;
      end;
  end else
  begin
    TOpenPictureDialog(Dialog).Filter := Value;
  end;
end;

procedure DBOpenPictureDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    TOpenPictureDialog(Dialog).FilterIndex := Value;
end;

{ DBSavePictureDialog }

constructor DBSavePictureDialog.Create;
begin
  if CanUseVistaDlg then
  begin
    Dialog := TFileSaveDialog.Create(nil);
    TFileSaveDialog(Dialog).Options := TFileSaveDialog(Dialog).Options + [FdoForcePreviewPaneOn];
    TFileSaveDialog(Dialog).OnTypeChange := OnFilterIndexChanged;
  end else
  begin
    Dialog := TSavePictureDialog.Create(nil);
  end;
end;

destructor DBSavePictureDialog.Destroy;
begin
  F(Dialog);
  inherited;
end;

function DBSavePictureDialog.Execute: boolean;
begin
  if CanUseVistaDlg then
    Result := TFileSaveDialog(Dialog).Execute
  else
    Result := TSavePictureDialog(Dialog).Execute;
end;

function DBSavePictureDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := TFileSaveDialog(Dialog).FileName
  else
    Result := TSavePictureDialog(Dialog).FileName;
end;

function DBSavePictureDialog.GetFilterIndex: Integer;
begin
  if CanUseVistaDlg then
    Result := TFileSaveDialog(Dialog).FileTypeIndex
  else
    Result := TSavePictureDialog(Dialog).FilterIndex;
end;

procedure DBSavePictureDialog.OnFilterIndexChanged(Sender: TObject);
begin
  TFileSaveDialog(Dialog).FileTypeIndex := TFileSaveDialog(Dialog).FileTypeIndex;
end;

procedure DBSavePictureDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    TFileSaveDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    TFileSaveDialog(Dialog).FileName := ExtractFileName(FileName);
  end else
  begin
    TSavePictureDialog(Dialog).FileName := FileName;
  end;
end;

procedure DBSavePictureDialog.SetFilter(const Value: string);
var
  I, P: Integer;
  FilterStr: string;
  FilterMask: string;
  StrTemp: string;
  IsFilterMask: Boolean;
  FileType: TFileTypeItem;
begin
  FFilter := Value;
  if CanUseVistaDlg then
  begin
    // DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
    P := 1;
    IsFilterMask := False;
    for I := 1 to Length(Value) do
      if (Value[I] = '|') or (I = Length(Value)) then
      begin
        if I = Length(Value) then
          StrTemp := Copy(Value, P, I - P + 1)
        else
          StrTemp := Copy(Value, P, I - P);
        if not IsFilterMask then
          FilterStr := StrTemp
        else
          FilterMask := StrTemp;

        if IsFilterMask then
        begin
          FileType := TFileSaveDialog(Dialog).FileTypes.Add();
          FileType.DisplayName := FilterStr;
          FileType.FileMask := FilterMask;
        end;
        IsFilterMask := not IsFilterMask;
        P := I + 1;
      end;
  end else
  begin
    TSavePictureDialog(Dialog).Filter := Value;
  end;
end;

procedure DBSavePictureDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    TSavePictureDialog(Dialog).FilterIndex := Value;

end;

end.
