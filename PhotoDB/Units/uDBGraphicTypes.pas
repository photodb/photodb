unit uDBGraphicTypes;

interface

uses
  Vcl.Graphics,
  Dmitry.Graphics.Types;

type
  T255ByteArray = array [0 .. 255] of Byte;
  T255IntArray = array [0 .. 255] of Integer;

  TGistogrammData = record
    Gray: T255IntArray;
    Red: T255IntArray;
    Green: T255IntArray;
    Blue: T255IntArray;
    Loaded: Boolean;
    Loading: Boolean;
    Max: Byte;
    LeftEffective: Byte;
    RightEffective: Byte;
  end;

type
  TArPARGB = array of PARGB;

type
  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array [0 .. MaxInt div Sizeof(Integer) - 2] of Integer;

  TColor3 = packed record
    B, G, R: Byte;
  end;

  TColor3Array = array [0 .. MaxInt div Sizeof(TColor3) - 2] of TColor3;
  PColor3Array = ^TColor3Array;

type
  TImageCompareResult = record
    ByGistogramm : Byte;
    ByPixels : Byte;
  end;

implementation

end.
