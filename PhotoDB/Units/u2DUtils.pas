unit u2DUtils;

interface

uses
  Windows;

function RectInRect(ROuter: TRect; RInner: TRect): Boolean;
function RectSquare(R: TRect): Double;
function RectInRectPercent(ROuter: TRect; RInner: TRect): Byte;
function RectIntersectWithRectPercent(ROuter: TRect; RInner: TRect): Byte;
function MoveRect(R: TRect; Dx, Dy: Integer): TRect;
function RectWidth(R: TRect): Integer;
function RectHeight(R: TRect): Integer;

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
  IntersectRect(R, ROuter, RInner);
  Result := RectInRectPercent(RInner, R);
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

end.
