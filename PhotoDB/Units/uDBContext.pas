unit uDBContext;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Data.DB,
  Dmitry.CRC32,

  CommonDBSupport,
  UnitINI,

  uConstants,
  uDBClasses,
  uSettings,
  uDBScheme;

type
  ISettingsProvider = interface

  end;

  IDBContext = interface
    function IsValid: Boolean;
    function GetCollectionFileName: string;
    property CollectionFileName: string read GetCollectionFileName;

    //low-level
    function CreateQuery(IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet;

    //middle-level
    function CreateSelect(TableName: string): TSelectCommand;
    function CreateUpdate(TableName: string): TUpdateCommand;
    function CreateInsert(TableName: string): TInsertCommand;
    function CreateDelete(TableName: string): TDeleteCommand;

    //todo: high-level
    //repositories
  end;

  TDBContext = class(TInterfacedObject, IDBContext)
  private
    FCollectionFile: string;
    FIsValid: Boolean;
    function InitCollection: Boolean;
  public
    //function CreateSelect: TSelectCommand;
    constructor Create(CollectionFile: string);

    function IsValid: Boolean;
    function GetCollectionFileName: string;

    //low-level
    function CreateQuery(IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet;

    //middle-level
    function CreateSelect(TableName: string): TSelectCommand;
    function CreateUpdate(TableName: string): TUpdateCommand;
    function CreateInsert(TableName: string): TInsertCommand;
    function CreateDelete(TableName: string): TDeleteCommand;

    //todo: high-level
    //repositories
  end;

implementation

{ TDBContext }

constructor TDBContext.Create(CollectionFile: string);
begin
  FCollectionFile := CollectionFile;
  FIsValid := InitCollection;
end;

function TDBContext.InitCollection: Boolean;
var
  Section: TBDRegistry;
  Version: Integer;
begin
  Result := False;
  Section := Settings.GetSection(RegRoot + 'CollectionSettings\' + IntToHex(Integer(StringCRC(FCollectionFile)), 8), False);

  Version := Section.ReadInteger('Version');
  if Version < CURRENT_DB_SCHEME_VERSION then
  begin
    if TDBScheme.IsOldColectionFile(FCollectionFile) then
      TDBScheme.UpdateCollection(FCollectionFile);

    if TDBScheme.IsValidCollectionFile(FCollectionFile) then
      Result := True;

    if Result then
      Section.WriteInteger('Version', CURRENT_DB_SCHEME_VERSION);
  end else
    Result := True;
end;

function TDBContext.IsValid: Boolean;
begin
  Result := FIsValid;
end;

function TDBContext.GetCollectionFileName: string;
begin
  Result := FCollectionFile;
end;

function TDBContext.CreateQuery(IsolationLevel: TDBIsolationLevel): TDataSet;
begin
  Result := GetQuery(FCollectionFile, GetCurrentThreadId <> MainThreadID, IsolationLevel);
end;

function TDBContext.CreateInsert(TableName: string): TInsertCommand;
begin
  Result := TInsertCommand.Create(TableName, FCollectionFile);
end;

function TDBContext.CreateSelect(TableName: string): TSelectCommand;
begin
  Result := TSelectCommand.Create(TableName, FCollectionFile, False, dbilRead);
end;

function TDBContext.CreateUpdate(TableName: string): TUpdateCommand;
begin
  Result := TUpdateCommand.Create(TableName, FCollectionFile);
end;

function TDBContext.CreateDelete(TableName: string): TDeleteCommand;
begin
  Result := TDeleteCommand.Create(TableName, FCollectionFile);
end;

end.
