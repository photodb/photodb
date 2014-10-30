unit uGOM;

interface

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  uRWLock,
  uMemory;

type
  TManagerObjects = class(TObject)
  private
    FObjects: TList;
    FSync: IReadWriteSync;
  public
    constructor Create;
    destructor Destroy; override;
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
  FSync.BeginWrite;
  try
    if FObjects.IndexOf(Obj) > -1 then
      Exit;

    if Obj = nil then
      raise Exception.Create('Obj  is null!');

    FObjects.Add(Obj);
  finally
    FSync.EndWrite;
  end;
end;

constructor TManagerObjects.Create;
begin
  FSync := CreateRWLock;
  FObjects := TList.Create;
end;

destructor TManagerObjects.Destroy;
begin
  F(FObjects);
  FSync := nil;
  inherited;
end;

function TManagerObjects.IsObj(Obj: TObject): Boolean;
begin
  FSync.BeginRead;
  try
    Result := FObjects.IndexOf(Obj) > -1;
  finally
    FSync.EndRead;
  end;
end;

function TManagerObjects.Count: Integer;
begin
  Result := FObjects.Count;
end;

procedure TManagerObjects.RemoveObj(Obj: TObject);
begin
  FSync.BeginWrite;
  try
    FObjects.Remove(Obj);
  finally
    FSync.EndWrite;
  end;
end;

initialization

finalization

  F(GOMObj);

end.
