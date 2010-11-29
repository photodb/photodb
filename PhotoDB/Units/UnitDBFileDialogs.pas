unit UnitDBFileDialogs;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows,
  {$IFDEF PHOTODB}
  UnitDBCommon,
  uAppUtils,
  {$ENDIF}
  Classes, uMemory,
  uVistaFuncs, VistaFileDialogs, Dialogs, ExtDlgs, acDlgSelect, SysUtils;

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
  public
    constructor Create();
    destructor Destroy; override;
    function Execute: Boolean;
    procedure SetFilterIndex(const Value: Integer);
    function GetFilterIndex: Integer;
    function FileName: string;
    procedure SetFileName(FileName: string);
    procedure SetOption(Option: VistaFileDialogs.TFileDialogOptions);
    procedure EnableMultyFileChooseWithDirectory;
    function GetFiles: TStrings;
    procedure EnableChooseWithDirectory;
    property FilterIndex: Integer write SetFilterIndex;
    property Filter: string read FFilter write SetFilter;
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
    I := Windows.GetEnvironmentVariable(PWideChar(VarName), nil, 0);
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
  Result := UVistaFuncs.IsWindowsVista and (GetDOSEnvVar('SAFEBOOT_OPTION') = '')
  {$IFDEF PHOTODB} and not GetParamStrDBBool ('/NoVistaFileDlg'){$ENDIF};
end;

function DBSelectDir(Handle: THandle; Title: string; UseSimple: Boolean): string;
begin
  Result := DBSelectDir(Handle, Title, '', UseSimple);
end;

function DBSelectDir(Handle: THandle; Title, SelectedRoot: string; UseSimple: Boolean): string;
var
  OpenDialog: DBOpenDialog;
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

    OpenDialog.SetOption([VistaFileDialogs.FdoPickFolders]);
    if OpenDialog.Execute then
      Result := OpenDialog.FileName;
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
    Dialog := VistaFileDialogs.TFileSaveDialog.Create(nil);
    VistaFileDialogs.TFileSaveDialog(Dialog).OnTypeChange := OnFilterIndexChanged;
  end else
  begin
    Dialog := Dialogs.TSaveDialog.Create(nil);
  end;
end;

destructor DBSaveDialog.Destroy;
begin
  F(Dialog);
end;

function DBSaveDialog.Execute : boolean;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileSaveDialog(Dialog).Execute
  else
    Result := Dialogs.TSaveDialog(Dialog).Execute;
end;

function DBSaveDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileSaveDialog(Dialog).FileName
  else
    Result := Dialogs.TSaveDialog(Dialog).FileName;
end;

function DBSaveDialog.GetFilterIndex: integer;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex
  else
    Result := Dialogs.TSaveDialog(Dialog).FilterIndex;
end;

procedure DBSaveDialog.OnFilterIndexChanged(Sender: TObject);
begin
  VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex;
end;

procedure DBSaveDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    VistaFileDialogs.TFileSaveDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    VistaFileDialogs.TFileSaveDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
  end else
  begin
    Dialogs.TSaveDialog(Dialog).FileName := FileName;
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
          with VistaFileDialogs.TFileSaveDialog(Dialog).FileTypes.Add() do
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
    Dialogs.TSaveDialog(Dialog).Filter := Value;
  end;
end;

procedure DBSaveDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    Dialogs.TSaveDialog(Dialog).FilterIndex := Value;
end;

{ DBOpenDialog }

constructor DBOpenDialog.Create;
begin
  if CanUseVistaDlg then
    Dialog := VistaFileDialogs.TFileOpenDialog.Create(nil)
  else
    Dialog := Dialogs.TOpenDialog.Create(nil);
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
    VistaFileDialogs.TFileOpenDialog(Dialog).Options := VistaFileDialogs.TFileOpenDialog(Dialog).Options + [VistaFileDialogs.FdoPickFolders, VistaFileDialogs.FdoStrictFileTypes];
    VistaFileDialogs.TFileOpenDialog(Dialog).Files;
  end else
  begin
    Dialogs.TOpenDialog(Dialog).Options := Dialogs.TOpenDialog(Dialog).Options + [OfPathMustExist, OfFileMustExist,
      OfEnableSizing];
  end;
end;

procedure DBOpenDialog.EnableMultyFileChooseWithDirectory;
begin
  if CanUseVistaDlg then
  begin
    VistaFileDialogs.TFileOpenDialog(Dialog).Options := VistaFileDialogs.TFileOpenDialog(Dialog).Options + [VistaFileDialogs.FdoPickFolders, VistaFileDialogs.FdoForceFileSystem,
      VistaFileDialogs.FdoAllowMultiSelect, VistaFileDialogs.FdoPathMustExist, VistaFileDialogs.FdoFileMustExist,
      VistaFileDialogs.FdoForcePreviewPaneOn];
    VistaFileDialogs.TFileOpenDialog(Dialog).Files
  end else
  begin
    Dialogs.TOpenDialog(Dialog).Options := Dialogs.TOpenDialog(Dialog).Options + [OfAllowMultiSelect, OfPathMustExist,
      OfFileMustExist, OfEnableSizing];
  end;
end;

function DBOpenDialog.Execute: Boolean;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileOpenDialog(Dialog).Execute
  else
    Result := Dialogs.TOpenDialog(Dialog).Execute;
end;

function DBOpenDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileOpenDialog(Dialog).FileName
  else
    Result := Dialogs.TOpenDialog(Dialog).FileName;
end;

function DBOpenDialog.GetFiles: TStrings;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileOpenDialog(Dialog).Files
  else
    Result := Dialogs.TOpenDialog(Dialog).Files;
end;

function DBOpenDialog.GetFilterIndex: Integer;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileOpenDialog(Dialog).FileTypeIndex
  else
    Result := Dialogs.TOpenDialog(Dialog).FilterIndex;
end;

procedure DBOpenDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    VistaFileDialogs.TFileOpenDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    VistaFileDialogs.TFileOpenDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
  end else
  begin
    Dialogs.TOpenDialog(Dialog).FileName := FileName;
  end;
end;

procedure DBOpenDialog.SetFilter(const Value: string);
var
  I, P: Integer;
  FilterStr: string;
  FilterMask: string;
  StrTemp: string;
  IsFilterMask: Boolean;
  FileType: VistaFileDialogs.TFileTypeItem;
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
          FileType := VistaFileDialogs.TFileOpenDialog(Dialog).FileTypes.Add();
          FileType.DisplayName := FilterStr;
          FileType.FileMask := FilterMask;
        end;
        IsFilterMask := not IsFilterMask;
        P := I + 1;
      end;
  end else
  begin
    Dialogs.TOpenDialog(Dialog).Filter := Value;
  end;
end;

procedure DBOpenDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    Dialogs.TOpenDialog(Dialog).FilterIndex := Value;
end;

procedure DBOpenDialog.SetOption(Option: VistaFileDialogs.TFileDialogOptions);
begin
  if CanUseVistaDlg then
    VistaFileDialogs.TFileSaveDialog(Dialog).Options := VistaFileDialogs.TFileSaveDialog(Dialog).Options + Option;
end;

{ DBOpenPictureDialog }

constructor DBOpenPictureDialog.Create;
begin
  inherited;
  if CanUseVistaDlg then
  begin
    Dialog := VistaFileDialogs.TFileOpenDialog.Create(nil);
    VistaFileDialogs.TFileOpenDialog(Dialog).Options := VistaFileDialogs.TFileOpenDialog(Dialog).Options + [VistaFileDialogs.FdoForcePreviewPaneOn];
  end else
  begin
    Dialog := ExtDlgs.TOpenPictureDialog.Create(nil);
  end;
end;

destructor DBOpenPictureDialog.Destroy;
begin
  F(Dialog);
end;

function DBOpenPictureDialog.Execute: Boolean;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileOpenDialog(Dialog).Execute
  else
    Result := ExtDlgs.TOpenPictureDialog(Dialog).Execute;
end;

function DBOpenPictureDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileOpenDialog(Dialog).FileName
  else
    Result := ExtDlgs.TOpenPictureDialog(Dialog).FileName;
end;

function DBOpenPictureDialog.GetFilterIndex: Integer;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileOpenDialog(Dialog).FileTypeIndex
  else
    Result := ExtDlgs.TOpenPictureDialog(Dialog).FilterIndex;
end;

procedure DBOpenPictureDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    VistaFileDialogs.TFileOpenDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    VistaFileDialogs.TFileOpenDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
  end else
  begin
    ExtDlgs.TOpenPictureDialog(Dialog).FileName := FileName;
  end;
end;

procedure DBOpenPictureDialog.SetFilter(const Value: string);
var
  I, P: Integer;
  FilterStr: string;
  FilterMask: string;
  StrTemp: string;
  IsFilterMask: Boolean;
  FileType: VistaFileDialogs.TFileTypeItem;
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
          FileType := VistaFileDialogs.TFileSaveDialog(Dialog).FileTypes.Add();
          FileType.DisplayName := FilterStr;
          FileType.FileMask := FilterMask;
        end;
        IsFilterMask := not IsFilterMask;
        P := I + 1;
      end;
  end else
  begin
    ExtDlgs.TOpenPictureDialog(Dialog).Filter := Value;
  end;
end;

procedure DBOpenPictureDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    ExtDlgs.TOpenPictureDialog(Dialog).FilterIndex := Value;
end;

{ DBSavePictureDialog }

constructor DBSavePictureDialog.Create;
begin
  if CanUseVistaDlg then
  begin
    Dialog := VistaFileDialogs.TFileSaveDialog.Create(nil);
    VistaFileDialogs.TFileSaveDialog(Dialog).Options := VistaFileDialogs.TFileSaveDialog(Dialog).Options + [VistaFileDialogs.FdoForcePreviewPaneOn];
    VistaFileDialogs.TFileSaveDialog(Dialog).OnTypeChange := OnFilterIndexChanged;
  end else
  begin
    Dialog := ExtDlgs.TSavePictureDialog.Create(nil);
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
    Result := VistaFileDialogs.TFileSaveDialog(Dialog).Execute
  else
    Result := ExtDlgs.TSavePictureDialog(Dialog).Execute;
end;

function DBSavePictureDialog.FileName: string;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileSaveDialog(Dialog).FileName
  else
    Result := ExtDlgs.TSavePictureDialog(Dialog).FileName;
end;

function DBSavePictureDialog.GetFilterIndex: Integer;
begin
  if CanUseVistaDlg then
    Result := VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex
  else
    Result := ExtDlgs.TSavePictureDialog(Dialog).FilterIndex;
end;

procedure DBSavePictureDialog.OnFilterIndexChanged(Sender: TObject);
begin
 VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex;
end;

procedure DBSavePictureDialog.SetFileName(FileName: string);
begin
  if CanUseVistaDlg then
  begin
    VistaFileDialogs.TFileSaveDialog(Dialog).DefaultFolder := ExtractFileDir(FileName);
    VistaFileDialogs.TFileSaveDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
  end else
  begin
    ExtDlgs.TSavePictureDialog(Dialog).FileName := FileName;
  end;
end;

procedure DBSavePictureDialog.SetFilter(const Value: string);
var
  I, P: Integer;
  FilterStr: string;
  FilterMask: string;
  StrTemp: string;
  IsFilterMask: Boolean;
  FileType: VistaFileDialogs.TFileTypeItem;
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
          FileType := VistaFileDialogs.TFileSaveDialog(Dialog).FileTypes.Add();
          FileType.DisplayName := FilterStr;
          FileType.FileMask := FilterMask;
        end;
        IsFilterMask := not IsFilterMask;
        P := I + 1;
      end;
  end else
  begin
    ExtDlgs.TSavePictureDialog(Dialog).Filter := Value;
  end;
end;

procedure DBSavePictureDialog.SetFilterIndex(const Value: Integer);
begin
  FFilterIndex := Value;
  if CanUseVistaDlg then
    VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value
  else
    ExtDlgs.TSavePictureDialog(Dialog).FilterIndex := Value;

end;

end.
