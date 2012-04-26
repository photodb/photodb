unit u2DUtils;

interface

uses
  Windows, Math;

function RectInRect(ROuter: TRect; RInner: TRect): Boolean;
function RectSquare(R: TRect): Double;
function RectInRectPercent(ROuter: TRect; RInner: TRect): Byte;
function RectIntersectWithRectPercent(ROuter: TRect; RInner: TRect): Byte;
function MoveRect(R: TRect; Dx, Dy: Integer): TRect;
function RectWidth(R: TRect): Integer;
function RectHeight(R: TRect): Integer;
function NormalizeRect(R: TRect): TRect;

implementation

function RectInRect(ROuter: TRect; RInner: TRect): Boolean;
begin
  Result := PtInRect(ROuter, RInner.TopLeft) and PtInRect(ROuter, RInner.BottomRight);
end;

function RectSquare(R: TRect): Double;
begin
  Result := (R.Right - R.Left) * (R.Bottom - R.Top);
end;

function RectInRectPercent(ROuter: TRect; RInner: TRect): Byte;
begin
  Result := 0;
  if RectInRect(ROuter, RInner) or EqualRect(ROuter, RInner) then
  begin
    if IsRectEmpty(ROuter) then
    begin
      Result := 100;
      Exit;
    end;
    Result := Round(100 * RectSquare(RInner) / RectSquare(ROuter));
  end;
end;

function RectIntersectWithRectPercent(ROuter: TRect; RInner: TRect): Byte;
var
  R: TRect;
begin
  ROuter := NormalizeRect(ROuter);
  RInner := NormalizeRect(RInner);
  IntersectRect(R, ROuter, RInner);
  if IsRectEmpty(R) then
    Exit(0);

  Result := Round(100 * RectSquare(R) / RectSquare(RInner));
end;

function MoveRect(R: TRect; Dx, Dy: Integer): TRect;
begin
  Result.Left := R.Left + Dx;
  Result.Right := R.Right + Dx;
  Result.Top := R.Top + Dy;
  Result.Bottom := R.Bottom + Dy;
end;

function RectWidth(R: TRect): Integer;
begin
  Result := R.Right - R.Left;
end;

function RectHeight(R: TRect): Integer;
begin
  Result := R.Bottom - R.Top;
end;

function NormalizeRect(R: TRect): TRect;
begin
  Result.Left := Min(R.Left, R.Right);
  Result.Right := Max(R.Left, R.Right);
  Result.Top := Min(R.Top, R.Bottom);
  Result.Bottom := Max(R.Top, R.Bottom);
end;

end.
