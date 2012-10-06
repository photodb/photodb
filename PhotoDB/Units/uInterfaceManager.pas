unit uInterfaceManager;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.SyncObjs,
  uMemory,
  uFormInterfaces;

type
  IList<T> = interface(IInterface)
    ['{50D2913D-ED71-4298-80A1-9E27F3864BFE}']
    function GetEnumerator: TList<T>.TEnumerator;
    function Add(const Value: T): Integer;
  end;

  TListEx<T> = class(TInterfacedObject, IList<T>)
  strict private
    FList: TList<T>;
    function GetEnumerator: TList<T>.TEnumerator;
  strict protected
    function Add(const Value: T): Integer;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TInterfaceManager = class(TObject)
  private
    FObjects: TList<TObject>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterObject(Obj: TObject);
    procedure UnRegisterObject(Obj: TObject);
    function QueryInterface<T: IInterface>(GUID: TGUID): T;
    function QueryInterfaces<T: IInterface>(GUID: TGUID): IList<T>;
  end;

function InterfaceManager: TInterfaceManager;

implementation

var
  FInterfaceManager: TInterfaceManager = nil;

function InterfaceManager: TInterfaceManager;
begin
  if FInterfaceManager = nil then
    FInterfaceManager := TInterfaceManager.Create;

  Result := FInterfaceManager;
end;

{ TInterfaceManager }

constructor TInterfaceManager.Create;
begin
  FObjects := TList<TObject>.Create;
end;

destructor TInterfaceManager.Destroy;
begin
  F(FObjects);
  inherited;
end;

function TInterfaceManager.QueryInterface<T>(GUID: TGUID): T;
var
  O: TObject;
begin
  Result := nil;
  for O in FObjects do
    if Supports(O, GUID) then
      O.GetInterface(GUID, Result);
end;

function TInterfaceManager.QueryInterfaces<T>(GUID: TGUID): IList<T>;
var
  O: TObject;
  L: TListEx<T>;
  I: T;
begin
  Result := TListEx<T>.Create;

  for O in FObjects do
    if Supports(O, GUID) then
    begin
      if O.GetInterface(GUID, I) then
        Result.Add(I);
    end;
end;

procedure TInterfaceManager.RegisterObject(Obj: TObject);
begin
  UnRegisterObject(Obj);
  FObjects.Add(Obj);
end;

procedure TInterfaceManager.UnRegisterObject(Obj: TObject);
begin
  FObjects.Remove(Obj);
end;

{ TListEx<T> }

function TListEx<T>.Add(const Value: T): Integer;
begin
  Result := FList.Add(Value);
end;

constructor TListEx<T>.Create;
begin
  inherited;
  FList := TList<T>.Create;
end;

destructor TListEx<T>.Destroy;
begin
  F(FList);
  inherited;
end;

function TListEx<T>.GetEnumerator: TList<T>.TEnumerator;
begin
  Result := FList.GetEnumerator;
end;

initialization

finalization
  F(FInterfaceManager);

end.
