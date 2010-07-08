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

implementation

end.
