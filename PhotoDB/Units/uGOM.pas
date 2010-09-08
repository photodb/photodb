unit uGOM;

interface

uses Classes, SysUtils, SyncObjs;

type
  TManagerObjects = class(TObject)
  private
    FObjects : TList;
    FSycn    : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure FreeObj(Obj : TObject);
    procedure AddObj(Obj : TObject);
    procedure RemoveObj(Obj : TObject);
    function IsObj(Obj : TObject) : Boolean;
    function Count : Integer;
  end;

var
  GOM : TManagerObjects = nil;

implementation


{ TManagerObjects }

procedure TManagerObjects.AddObj(Obj: TObject);
begin
  FSycn.Enter;
  try
    if FObjects.IndexOf(Obj) > -1 then
      Exit;

    if Obj = nil then
      raise Exception.Create('Obj  is null!');

    FObjects.Add(Obj);
  finally
    FSycn.Leave;
  end;
end;

constructor TManagerObjects.Create;
begin
  FSycn := TCriticalSection.Create;
  FObjects := TList.Create;
end;

destructor TManagerObjects.Destroy;
begin
  FObjects.Free;
  FSycn.Free;
  inherited;
end;

procedure TManagerObjects.FreeObj(Obj: TObject);
begin      
  FSycn.Enter;
  try
    RemoveObj(Obj);
    Obj.Free;
  finally
    FSycn.Leave;
  end;
end;

function TManagerObjects.IsObj(Obj: TObject): Boolean;
begin
  FSycn.Enter;
  try
    Result := FObjects.IndexOf(Obj) > -1; 
  finally
    FSycn.Leave;
  end;
end;

function TManagerObjects.Count: Integer;
begin
  Result := FObjects.Count;
end;

procedure TManagerObjects.RemoveObj(Obj: TObject);
var
  i, j : integer;
begin      
  FSycn.Enter;
  try
    FObjects.Remove(Obj);  
  finally
    FSycn.Leave;
  end;
end;

initialization

  GOM := TManagerObjects.Create;

finalization

  GOM.Free;

end.
