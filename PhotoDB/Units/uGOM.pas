unit uGOM;

interface

uses Classes, SysUtils, SyncObjs, UMemory;

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

var
  GOM: TManagerObjects = nil;

implementation

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
  FObjects.Free;
  FSync.Free;
  inherited;
end;

procedure TManagerObjects.FreeObj(Obj: TObject);
begin
  FSync.Enter;
  try
    RemoveObj(Obj);
    Obj.Free;
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
var
  I, J: Integer;
begin
  FSync.Enter;
  try
    FObjects.Remove(Obj);
  finally
    FSync.Leave;
  end;
end;

initialization

  GOM := TManagerObjects.Create;

finalization

  F(GOM);

end.
