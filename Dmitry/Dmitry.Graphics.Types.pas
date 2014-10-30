unit Dmitry.Graphics.Types;

interface

uses
  System.Classes,
  System.SyncObjs,
  Vcl.Graphics;

type
  TRGB = record
    B, G, R : Byte;
  end;

  ARGB = array [0..32677] of TRGB;
  PARGB = ^ARGB;
  PRGB = ^TRGB;
  PARGBArray = array of PARGB;

  TRGB32 = record
    B, G, R, L : byte;
  end;

  ARGB32 = array [0..32677] of TRGB32;
  PARGB32 = ^ARGB32;
  PRGB32 = ^TRGB32;
  PARGB32Array = array of PARGB32;

type
  TProgressCallBackProc = procedure(Progress: Integer; var Break: Boolean) of object;

var
  SumLMatrix : array[0..255, 0..255] of Byte;
  SumLMatrixDone : Boolean = False;

function SumL(LD, LS : Byte) : Byte; inline;
procedure InitSumLMatrix;

implementation

procedure InitSumLMatrix;
var
  I, J : Integer;
begin
  if not SumLMatrixDone then
  begin
    for I := 0 to 255 do
      for J := 0 to 255 do
        SumLMatrix[I, J] := SumL(I, J);

    SumLMatrixDone := True;
  end;
end;

function SumL(LD, LS : Byte) : Byte; inline;
var
  N : Byte;
begin
  N := 255 - LD;
  Result := LD + (N * LS + $7F) div 255;
end;

end.



