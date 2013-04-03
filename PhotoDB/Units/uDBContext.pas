unit uDBContext;

interface

uses
  System.SysUtils,
  Dmitry.CRC32,

  CommonDBSupport,
  UnitINI,

  uConstants,
  uDBClasses,
  uSettings,
  uDBScheme;

type
  IDBContext = interface
    //TODO:
    //function CreateSelect: TSelectCommand;
    //function CreateUpdate: TUpdateCommand;
    //function InsertUpdate: TInsertCommand;
    function IsValid: Boolean;
    function GetCollectionFileName: string;
    property CollectionFileName: string read GetCollectionFileName;
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
  end;

implementation

{ TDBContext }

constructor TDBContext.Create(CollectionFile: string);
begin
  FCollectionFile := CollectionFile;
  FIsValid := InitCollection;
end;

function TDBContext.GetCollectionFileName: string;
begin
  Result := FCollectionFile;
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

end.
