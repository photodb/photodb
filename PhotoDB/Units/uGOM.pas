unit uGOM;

interface

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  uMemory;

type
  TManagerObjects = class(TObject)
  private
    FObjects: TList;
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure FreeObj(Obj: TObject);
    procedure AddObj(Obj: TObject);
    procedure RemoveObj(Obj: TObject);
    function IsObj(Obj: TObject): Boolean;
    function Count: Integer;
  end;

function GOM: TManagerObjects;

implementation

var
  GOMObj: TManagerObjects = nil;

function GOM: TManagerObjects;
begin
  if GOMObj = nil then
    GOMObj := TManagerObjects.Create;

  Result := GOMObj;
end;

{ TManagerObjects }

procedure TManagerObjects.AddObj(Obj: TObject);
begin
  FSync.Enter;
  try
    if FObjects.IndexOf(Obj) > -1 then
      Exit;

    if Obj = nil then
      raise Exception.Create('Obj  is null!');

    FObjects.Add(Obj);
  finally
    FSync.Leave;
  end;
end;

constructor TManagerObjects.Create;
begin
  FSync := TCriticalSection.Create;
  FObjects := TList.Create;
end;

destructor TManagerObjects.Destroy;
begin
  F(FObjects);
  F(FSync);
  inherited;
end;

procedure TManagerObjects.FreeObj(Obj: TObject);
begin
  FSync.Enter;
  try
    RemoveObj(Obj);
    F(Obj);
  finally
    FSync.Leave;
  end;
end;

function TManagerObjects.IsObj(Obj: TObject): Boolean;
begin
  FSync.Enter;
  try
    Result := FObjects.IndexOf(Obj) > -1;
  finally
    FSync.Leave;
  end;
end;

function TManagerObjects.Count: Integer;
begin
  Result := FObjects.Count;
end;

procedure TManagerObjects.RemoveObj(Obj: TObject);
begin
  FSync.Enter;
  try
    FObjects.Remove(Obj);
  finally
    FSync.Leave;
  end;
end;

initialization

finalization

  F(GOMObj);

end.
