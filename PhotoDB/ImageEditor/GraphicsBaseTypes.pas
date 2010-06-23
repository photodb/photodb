unit GraphicsBaseTypes;

interface

uses Classes, Graphics, SyncObjs;

type TBaseEffectCallBackProc = procedure(Progress : integer; var Break: boolean) of object;

type TBaseEffectProc = procedure(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
     TBaseEffectProcThreadExit = procedure(Image : TBitmap; SID : string) of object;

type TBaseEffectProcW = record
  Proc : TBaseEffectProc;
  Name : String;
  ID : ShortString;
  end;

type TBaseEffectProcedures = array of TBaseEffectProcW;

Type
  TRGB = record
    B, G, R : Byte;
  end;

  ARGB = array [0..32677] of TRGB;
  PARGB = ^ARGB;
  PRGB = ^TRGB;
  PARGBArray = array of PARGB;

type
  TRGB32 = record
    B, G, R, L : byte;
  end;

  ARGB32 = array [0..32677] of TRGB32;
  PARGB32 = ^ARGB32;
  PRGB32 = ^TRGB32;
  PARGB32Array = array of PARGB32;

type
 TSetPointerToNewImage = procedure(Image : TBitmap) of object;
 TCancelTemporaryImage = procedure(Destroy : Boolean) of object;

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
    function ObjCount : Integer;
  end;

  var GOM : TManagerObjects = nil;

implementation

{ TManagerObjects }

procedure TManagerObjects.AddObj(Obj: TObject);
begin
  FSycn.Enter;
  try
    if FObjects.IndexOf(Obj) > -1 then
      Exit;

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

function TManagerObjects.ObjCount: Integer;
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
