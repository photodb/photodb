unit UnitDBFileDialogs;

interface

uses Windows,  UnitDBCommon, Classes,
     uVistaFuncs, VistaFileDialogs, Dialogs, ExtDlgs, acDlgSelect, SysUtils;

type
 DBSaveDialog = Class(TObject)
 private
   Dialog : TObject;
   fFilterIndex: integer;
   fFilter : string;
    procedure SetFilter(const Value: string);
    procedure OnFilterIndexChanged(Sender : TObject);
 public
   constructor Create();
   destructor Destroy; override;
   function Execute : boolean;
   procedure SetFilterIndex(const Value : integer);
   function GetFilterIndex : integer;
   function FileName : string;  
   procedure SetFileName(FileName : string);
 published
   property FilterIndex : integer write SetFilterIndex;
   property Filter : string read fFilter write SetFilter;
 end;

type
 DBOpenDialog = Class(TObject)
 private
   Dialog : TObject;
   fFilterIndex: integer;
   fFilter : string;
    procedure SetFilter(const Value: string);
 public
   constructor Create();
   destructor Destroy; override;
   function Execute : boolean;
   procedure SetFilterIndex(const Value : integer);
   function GetFilterIndex : integer;
   function FileName : string;
   procedure SetFileName(FileName : string);
   procedure SetOption(Option : VistaFileDialogs.TFileDialogOptions);
   procedure EnableMultyFileChooseWithDirectory;
   function GetFiles : TStrings;
   procedure EnableChooseWithDirectory;
 published
   property FilterIndex : integer write SetFilterIndex;
   property Filter : string read fFilter write SetFilter;
 end;

type
 DBOpenPictureDialog = Class(TObject)
 private
   Dialog : TObject;
   fFilterIndex: integer;
   fFilter : string;
    procedure SetFilter(const Value: string);
 public
   constructor Create();
   destructor Destroy; override;
   function Execute : boolean;
   procedure SetFilterIndex(const Value : integer);
   function GetFilterIndex : integer;
   function FileName : string;
   procedure SetFileName(FileName : string);
 published
   property FilterIndex : integer write SetFilterIndex;
   property Filter : string read fFilter write SetFilter;
 end;

type
 DBSavePictureDialog = Class(TObject)
 private
   Dialog : TObject;
   fFilterIndex: integer;
   fFilter : string;
    procedure SetFilter(const Value: string);     
    procedure OnFilterIndexChanged(Sender : TObject);
 public
   constructor Create();
   destructor Destroy; override;
   function Execute : boolean;
   procedure SetFilterIndex(const Value : integer);
   function GetFilterIndex : integer;
   function FileName : string;  
   procedure SetFileName(FileName : string);
 published
   property FilterIndex : integer write SetFilterIndex;
   property Filter : string read fFilter write SetFilter;
 end;

 function DBSelectDir(Handle : THandle; Title : String ; UseSimple : boolean) : string; overload;
 function DBSelectDir(Handle : THandle; Title, SelectedRoot : String ; UseSimple : boolean) : string; overload;

implementation

 function GetDOSEnvVar(const VarName: string): string;
 var
   i: integer;
 begin
  Result := '';
  try
   i := Windows.GetEnvironmentVariable(PWideChar(VarName), nil, 0);
   if i > 0 then
   begin
    SetLength(Result, i);
    GetEnvironmentVariable(PWideChar(VarName), PWideChar(Result), i);
   end;
  except
   Result := '';
  end;
 end;
 
 function CanUseVistaDlg : boolean;
 begin
  Result:=uVistaFuncs.IsWindowsVista and (GetDOSEnvVar('SAFEBOOT_OPTION')='') and not GetParamStrDBBool('/NoVistaFileDlg');
 end;
 
 function DBSelectDir(Handle : THandle; Title : String ; UseSimple : boolean) : string;
 begin
  Result:= DBSelectDir(Handle, Title, '', UseSimple);
 end;

 function DBSelectDir(Handle : THandle; Title, SelectedRoot : String ; UseSimple : boolean) : string;
 var
   OpenDialog : DBOpenDialog;
 begin
  Result:='';
  if UseSimple or not CanUseVistaDlg then
  begin
   Result:=SelectDirPlus(Handle, Title, SelectedRoot);
  end else
  begin
   OpenDialog := DBOpenDialog.Create;

   if SelectedRoot<>'' then
   if DirectoryExists(SelectedRoot) then
   OpenDialog.SetFileName(SelectedRoot);
   
   OpenDialog.SetOption([VistaFileDialogs.fdoPickFolders]);
   if OpenDialog.Execute then
   Result:=OpenDialog.FileName;
   OpenDialog.Free;
  end;
 end;

{ DBSaveDialog }

constructor DBSaveDialog.Create();
begin                
 inherited;
 if CanUseVistaDlg then
 begin
  Dialog:=VistaFileDialogs.TFileSaveDialog.Create(nil);
  VistaFileDialogs.TFileSaveDialog(Dialog).OnTypeChange:=OnFilterIndexChanged;
 end else
 begin
  Dialog:=Dialogs.TSaveDialog.Create(nil);
 end;
end;

destructor DBSaveDialog.Destroy;
begin
 Dialog.Free;
end;

function DBSaveDialog.Execute : boolean;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileSaveDialog(Dialog).Execute;
 end else
 begin
  Result:=Dialogs.TSaveDialog(Dialog).Execute;
 end;
end;

function DBSaveDialog.FileName: string;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileSaveDialog(Dialog).FileName;
 end else
 begin
  Result:=Dialogs.TSaveDialog(Dialog).FileName;
 end;
end;

function DBSaveDialog.GetFilterIndex: integer;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex;
 end else
 begin
  Result:=Dialogs.TSaveDialog(Dialog).FilterIndex;
 end;
end;

procedure DBSaveDialog.OnFilterIndexChanged(Sender: TObject);
begin
 VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex;
end;

procedure DBSaveDialog.SetFileName(FileName: string);
begin
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileSaveDialog(Dialog).DefaultFolder:=ExtractFileDir(FileName);
  VistaFileDialogs.TFileSaveDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
 end else
 begin
  Dialogs.TSaveDialog(Dialog).FileName := FileName;
 end;
end;

procedure DBSaveDialog.SetFilter(const Value: string);
var
  i,p : integer;
  FilterStr : string;
  FilterMask : string;
  StrTemp : string;
  IsFilterMask : boolean;
  FileType : TFileTypeItem;
begin
 fFilter := value;
 if CanUseVistaDlg then
 begin
  //DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
  p:=1;
  IsFilterMask:=false;
  for i:=1 to Length(Value) do
  if (Value[i]='|') or (i = Length(Value))  then
  begin
   if i = Length(Value) then
   StrTemp:=copy(Value,p,i-p+1) else
   StrTemp:=copy(Value,p,i-p);
   if not IsFilterMask then
   FilterStr:=StrTemp else FilterMask:=StrTemp;

   if isFilterMask then
   begin
    with VistaFileDialogs.TFileSaveDialog(Dialog).FileTypes.Add() do
    begin
    DisplayName:=FilterStr;
    FileMask:=FilterMask;
    end;
   end;
   IsFilterMask:=not IsFilterMask;
   p:=i+1;
  end;
 end else
 begin
  Dialogs.TSaveDialog(Dialog).Filter:=Value;
 end;
end;

procedure DBSaveDialog.SetFilterIndex(const Value: integer);
begin
 fFilterIndex := Value;
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value;
 end else
 begin
  Dialogs.TSaveDialog(Dialog).FilterIndex := Value;
 end;
end;

{ DBOpenDialog }

constructor DBOpenDialog.Create;
begin
 inherited;
 if CanUseVistaDlg then
 begin
  Dialog:=VistaFileDialogs.TFileOpenDialog.Create(nil);
 end else
 begin
  Dialog:=Dialogs.TOpenDialog.Create(nil);
 end;
end;

destructor DBOpenDialog.Destroy;
begin
 Dialog.Free;
 inherited;
end;

procedure DBOpenDialog.EnableChooseWithDirectory;
begin
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileOpenDialog(Dialog).Options:=VistaFileDialogs.TFileOpenDialog(Dialog).Options+[VistaFileDialogs.fdoPickFolders,VistaFileDialogs.fdoStrictFileTypes];
  VistaFileDialogs.TFileOpenDialog(Dialog).Files
 end else
 begin
  Dialogs.TOpenDialog(Dialog).Options:= Dialogs.TOpenDialog(Dialog).Options + [ofPathMustExist,ofFileMustExist,ofEnableSizing];
 end;
end;

procedure DBOpenDialog.EnableMultyFileChooseWithDirectory;
begin
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileOpenDialog(Dialog).Options:=VistaFileDialogs.TFileOpenDialog(Dialog).Options+[VistaFileDialogs.fdoPickFolders,VistaFileDialogs.fdoForceFileSystem,VistaFileDialogs.fdoAllowMultiSelect,VistaFileDialogs.fdoPathMustExist,VistaFileDialogs.fdoFileMustExist,VistaFileDialogs.fdoForcePreviewPaneOn];
  VistaFileDialogs.TFileOpenDialog(Dialog).Files
 end else
 begin
  Dialogs.TOpenDialog(Dialog).Options:= Dialogs.TOpenDialog(Dialog).Options + [ofAllowMultiSelect,ofPathMustExist,ofFileMustExist,ofEnableSizing];
 end;
end;

function DBOpenDialog.Execute: boolean;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileOpenDialog(Dialog).Execute;
 end else
 begin
  Result:=Dialogs.TOpenDialog(Dialog).Execute;
 end;
end;

function DBOpenDialog.FileName: string;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileOpenDialog(Dialog).FileName;
 end else
 begin
  Result:=Dialogs.TOpenDialog(Dialog).FileName;
 end;
end;

function DBOpenDialog.GetFiles: TStrings;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileOpenDialog(Dialog).Files;
 end else
 begin
  Result:=Dialogs.TOpenDialog(Dialog).Files;
 end;
end;

function DBOpenDialog.GetFilterIndex: integer;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileOpenDialog(Dialog).FileTypeIndex;
 end else
 begin
  Result:=Dialogs.TOpenDialog(Dialog).FilterIndex;
 end;
end;

procedure DBOpenDialog.SetFileName(FileName : string);
begin
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileOpenDialog(Dialog).DefaultFolder:=ExtractFileDir(FileName);
  VistaFileDialogs.TFileOpenDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
 end else
 begin
  Dialogs.TOpenDialog(Dialog).FileName := FileName;
 end;
end;

procedure DBOpenDialog.SetFilter(const Value: string);
var
  i,p : integer;
  FilterStr : string;
  FilterMask : string;
  StrTemp : string;
  IsFilterMask : boolean;
  FileType : VistaFileDialogs.TFileTypeItem;
begin
 fFilter := value;
 if CanUseVistaDlg then
 begin
  //DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
  p:=1;
  IsFilterMask:=false;
  for i:=1 to Length(Value) do
  if (Value[i]='|') or (i = Length(Value))  then
  begin
   if i = Length(Value) then
   StrTemp:=copy(Value,p,i-p+1) else
   StrTemp:=copy(Value,p,i-p);
   if not IsFilterMask then
   FilterStr:=StrTemp else FilterMask:=StrTemp;

   if isFilterMask then
   begin
    FileType:=VistaFileDialogs.TFileOpenDialog(Dialog).FileTypes.Add();
    FileType.DisplayName:=FilterStr;
    FileType.FileMask:=FilterMask;
   end;
   IsFilterMask:=not IsFilterMask;
   p:=i+1;
  end;
 end else
 begin
  Dialogs.TOpenDialog(Dialog).Filter:=Value;
 end;
end;

procedure DBOpenDialog.SetFilterIndex(const Value: integer);
begin
 fFilterIndex := Value;
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value;
 end else
 begin
  Dialogs.TOpenDialog(Dialog).FilterIndex := Value;
 end;
end;

procedure DBOpenDialog.SetOption(Option: VistaFileDialogs.TFileDialogOptions);
begin
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileSaveDialog(Dialog).Options := VistaFileDialogs.TFileSaveDialog(Dialog).Options + Option;
 end;
end;

{ DBOpenPictureDialog }

constructor DBOpenPictureDialog.Create;
begin
 inherited;
 if CanUseVistaDlg then
 begin
  Dialog:=VistaFileDialogs.TFileOpenDialog.Create(nil);
  VistaFileDialogs.TFileOpenDialog(Dialog).Options := VistaFileDialogs.TFileOpenDialog(Dialog).Options + [VistaFileDialogs.fdoForcePreviewPaneOn];
 end else
 begin
  Dialog:=ExtDlgs.TOpenPictureDialog.Create(nil);
 end;
end;

destructor DBOpenPictureDialog.Destroy;
begin
 Dialog.Free;
 inherited;
end;

function DBOpenPictureDialog.Execute: boolean;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileOpenDialog(Dialog).Execute;
 end else
 begin
  Result:=ExtDlgs.TOpenPictureDialog(Dialog).Execute;
 end;
end;

function DBOpenPictureDialog.FileName: string;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileOpenDialog(Dialog).FileName;
 end else
 begin
  Result:=ExtDlgs.TOpenPictureDialog(Dialog).FileName;
 end;
end;

function DBOpenPictureDialog.GetFilterIndex: integer;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileOpenDialog(Dialog).FileTypeIndex;
 end else
 begin
  Result:=ExtDlgs.TOpenPictureDialog(Dialog).FilterIndex;
 end;
end;

procedure DBOpenPictureDialog.SetFileName(FileName: string);
begin
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileOpenDialog(Dialog).DefaultFolder:=ExtractFileDir(FileName);
  VistaFileDialogs.TFileOpenDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
 end else
 begin
  ExtDlgs.TOpenPictureDialog(Dialog).FileName := FileName;
 end;
end;

procedure DBOpenPictureDialog.SetFilter(const Value: string);
var
  i,p : integer;
  FilterStr : string;
  FilterMask : string;
  StrTemp : string;
  IsFilterMask : boolean;
  FileType : VistaFileDialogs.TFileTypeItem;
begin
 fFilter := value;
 if CanUseVistaDlg then
 begin
  //DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
  p:=1;
  IsFilterMask:=false;
  for i:=1 to Length(Value) do
  if (Value[i]='|') or (i = Length(Value))  then
  begin
   if i = Length(Value) then
   StrTemp:=copy(Value,p,i-p+1) else
   StrTemp:=copy(Value,p,i-p);
   if not IsFilterMask then
   FilterStr:=StrTemp else FilterMask:=StrTemp;

   if isFilterMask then
   begin
    FileType:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypes.Add();
    FileType.DisplayName:=FilterStr;
    FileType.FileMask:=FilterMask;
   end;
   IsFilterMask:=not IsFilterMask;
   p:=i+1;
  end;
 end else
 begin
  ExtDlgs.TOpenPictureDialog(Dialog).Filter:=Value;
 end;
end;

procedure DBOpenPictureDialog.SetFilterIndex(const Value: integer);
begin
 fFilterIndex := Value;
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value;
 end else
 begin
  ExtDlgs.TOpenPictureDialog(Dialog).FilterIndex := Value;
 end;
end;

{ DBSavePictureDialog }

constructor DBSavePictureDialog.Create;
begin
 inherited;
 if CanUseVistaDlg then
 begin
  Dialog:=VistaFileDialogs.TFileSaveDialog.Create(nil);
  VistaFileDialogs.TFileSaveDialog(Dialog).Options := VistaFileDialogs.TFileSaveDialog(Dialog).Options + [VistaFileDialogs.fdoForcePreviewPaneOn];
  VistaFileDialogs.TFileSaveDialog(Dialog).OnTypeChange:=OnFilterIndexChanged;
 end else
 begin
  Dialog:=ExtDlgs.TSavePictureDialog.Create(nil);
 end;
end;

destructor DBSavePictureDialog.Destroy;
begin
 Dialog.Free;
 inherited;
end;

function DBSavePictureDialog.Execute: boolean;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileSaveDialog(Dialog).Execute;
 end else
 begin
  Result:=ExtDlgs.TSavePictureDialog(Dialog).Execute;
 end;
end;

function DBSavePictureDialog.FileName: string;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileSaveDialog(Dialog).FileName;
 end else
 begin
  Result:=ExtDlgs.TSavePictureDialog(Dialog).FileName;
 end;
end;

function DBSavePictureDialog.GetFilterIndex: integer;
begin
 if CanUseVistaDlg then
 begin
  Result:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex;
 end else
 begin
  Result:=ExtDlgs.TSavePictureDialog(Dialog).FilterIndex;
 end;
end;

procedure DBSavePictureDialog.OnFilterIndexChanged(Sender: TObject);
begin
 VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex;
end;

procedure DBSavePictureDialog.SetFileName(FileName: string);
begin
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileSaveDialog(Dialog).DefaultFolder:=ExtractFileDir(FileName);
  VistaFileDialogs.TFileSaveDialog(Dialog).FileName := SysUtils.ExtractFileName(FileName);
 end else
 begin
  ExtDlgs.TSavePictureDialog(Dialog).FileName := FileName;
 end;
end;

procedure DBSavePictureDialog.SetFilter(const Value: string);
var
  i,p : integer;
  FilterStr : string;
  FilterMask : string;
  StrTemp : string;
  IsFilterMask : boolean;
  FileType : VistaFileDialogs.TFileTypeItem;
begin
 fFilter := value;
 if CanUseVistaDlg then
 begin
  //DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith
  p:=1;
  IsFilterMask:=false;
  for i:=1 to Length(Value) do
  if (Value[i]='|') or (i = Length(Value))  then
  begin
   if i = Length(Value) then
   StrTemp:=copy(Value,p,i-p+1) else
   StrTemp:=copy(Value,p,i-p);
   if not IsFilterMask then
   FilterStr:=StrTemp else FilterMask:=StrTemp;

   if isFilterMask then
   begin
    FileType:=VistaFileDialogs.TFileSaveDialog(Dialog).FileTypes.Add();
    FileType.DisplayName:=FilterStr;
    FileType.FileMask:=FilterMask;
   end;
   IsFilterMask:=not IsFilterMask;
   p:=i+1;
  end;
 end else
 begin
  ExtDlgs.TSavePictureDialog(Dialog).Filter:=Value;
 end;
end;

procedure DBSavePictureDialog.SetFilterIndex(const Value: integer);
begin
 fFilterIndex := Value;
 if CanUseVistaDlg then
 begin
  VistaFileDialogs.TFileSaveDialog(Dialog).FileTypeIndex := Value;
 end else
 begin
  ExtDlgs.TSavePictureDialog(Dialog).FilterIndex := Value;
 end;
end;

end.
