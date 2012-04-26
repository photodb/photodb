unit uMath;

interface

const
  CHalf64 : Double = 0.5;

function FastTrunc(const Value: Double): Integer; overload;
function FastRound(Sample: Double): Integer;
function FastCeil(const X: Double): Integer;
function FastFloor(const X: Double): Integer;
procedure FastAbs(var Value: Double); inline;

implementation

function FastFractional(const Value: Double): Double;
asm
  fld Value.Double
  fld Value.Double
  fsub CHalf64
  frndint
  fsubp
end;

function FastCeil(const X: Double): Integer;
begin
  Result := FastTrunc(X);
  if FastFractional(X) > 0 then
    Inc(Result);
end;

function FastFloor(const X: Double): Integer;
begin
  Result := FastTrunc(X);
  if FastFractional(X) < 0 then
    Dec(Result);
end;

function FastTrunc(const Value: Double): Integer; overload;
asm
  fld Value.Double
  fsub CHalf64
  fistp Result.Integer
end;

function FastRound(Sample: Double): Integer;
asm
  fld Sample.Double
  frndint
  fistp Result.Integer
end;

procedure FastAbs(var Value: Double);
var
  I : array [0..1] of Integer absolute Value;
begin
  I[0] := I[0] and $7FFFFFFF;
end;

end.
