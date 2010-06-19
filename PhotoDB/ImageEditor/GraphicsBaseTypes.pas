unit GraphicsBaseTypes;

interface

uses Graphics;

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
  TRGB=record
  b,g,r : byte;
  end;

  ARGB=array [0..32677] of TRGB;
  PARGB=^ARGB;
  PRGB = ^TRGB;
  PARGBArray = array of PARGB;

  type
  TRGB32=record
  b,g,r,l : byte;
  end;
  Type
    ARGB32=array [0..32677] of TRGB32;
    PARGB32=^ARGB32;  
  PRGB32 = ^TRGB32;
  PARGB32Array = array of PARGB32;


type
 TSetPointerToNewImage = procedure(Image : TBitmap) of object;
 TCancelTemporaryImage  = procedure(Destroy : Boolean) of object;

 TArObject = array of TObject;

  TManagerObjects = class(TObject)
   Private
    FObjects : TArObject;
   Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure FreeObj(Obj : TObject);
    Procedure AddObj(Obj : TObject);
    Procedure RemoveObj(Obj : TObject);
    Function IsObj(Obj : TObject) : Boolean;
    Function ObjCount : Integer;
   published
  end;

  var GOM : TManagerObjects;

implementation

{ TManagerObjects }

procedure TManagerObjects.AddObj(Obj: TObject);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FObjects)-1 do
 if FObjects[i]=Obj then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FObjects,Length(FObjects)+1);
  FObjects[Length(FObjects)-1]:=Obj;
 end;
end;

constructor TManagerObjects.Create;
begin
 SetLength(FObjects,0);
end;

destructor TManagerObjects.Destroy;
begin
 SetLength(FObjects,0);
 inherited;
end;

procedure TManagerObjects.FreeObj(Obj: TObject);
begin
 RemoveObj(Obj);
 Obj.Free;
end;

function TManagerObjects.IsObj(Obj: TObject): Boolean;
Var
  i : Integer;
begin
 Result:=False;
 For i:=0 to Length(FObjects)-1 do
 if FObjects[i]=Obj then
 Begin
  Result:=True;
  Break;
 End;
end;

function TManagerObjects.ObjCount: Integer;
begin
 Result:=Length(FObjects);
end;

procedure TManagerObjects.RemoveObj(Obj: TObject);
var
  i, j : integer;
begin
 For i:=0 to Length(FObjects)-1 do
 if FObjects[i]=Obj then
 begin
  For j:=i to Length(FObjects)-2 do
  FObjects[j]:=FObjects[j+1];
  SetLength(FObjects,Length(FObjects)-1);
  break;
 end;
end;

initialization

GOM := TManagerObjects.Create;

end.
