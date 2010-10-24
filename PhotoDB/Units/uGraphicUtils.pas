unit uGraphicUtils;

interface

uses
  Windows, SysUtils, Classes, Graphics;

function MixColors(Color1, Color2: TColor; Percent: Integer): TColor;
function MakeDarken(BaseColor : TColor; Multiply : Extended) : TColor; overload;
function MakeDarken(Color: TColor): TColor; overload;

implementation

function MakeDarken(BaseColor : TColor; Multiply : Extended) : TColor;
var
  R, G, B : Byte;
begin
  BaseColor := ColorToRGB(BaseColor);
  R := GetRValue(BaseColor);
  G := GetGValue(BaseColor);
  B := GetBValue(BaseColor);
  R := Byte(Round(R * Multiply));
  G := Byte(Round(G * Multiply));
  B := Byte(Round(B * Multiply));
  Result := RGB(R, G, B);
end;

function MakeDarken(Color: TColor): TColor;
begin
  Color := ColorToRGB(Color);
  Result := RGB(Round(0.75 * GetRValue(Color)), Round(0.75 * GetGValue(Color)), Round(0.75 * GetBValue(Color)));
end;

function MixColors(Color1, Color2: TColor; Percent: Integer): TColor;
var
  R, G, B: Byte;
  P: Extended;
begin
  Color1 := ColorToRGB(Color1);
  Color2 := ColorToRGB(Color2);
  P := (Percent / 100);
  R := Round(P * GetRValue(Color1) + (P - 1) * GetRValue(Color2));
  G := Round(P * GetGValue(Color1) + (P - 1) * GetGValue(Color2));
  B := Round(P * GetBValue(Color1) + (P - 1) * GetBValue(Color2));
  Result := RGB(R, G, B);
end;

end.
