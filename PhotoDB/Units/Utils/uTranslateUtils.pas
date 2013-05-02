unit uTranslateUtils;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Math,

  Dmitry.Utils.System,

  uTranslate;

function SizeInText(Size: Int64): string;
function SpeedInText(Speed: Extended): string;
function TimeIntervalInString(Time: TTime): string;
function NumberToShortNumber(Number: Integer): string;

implementation

function SpeedInText(Speed: Extended): string;
begin
  if Speed > 100 then
    Result := IntToStr(Round(Speed))
  else if Speed > 10 then
    Result := FormatFloat('##.#', Speed)
  else
    Result := FormatFloat('0.##', Speed);
end;

function SizeInText(Size: Int64): string;
begin
  if Size <= 1024 then
    Result := IntToStr(Size) + ' ' + TA('Bytes');
  if (Size > 1024) and (Size <= 1024 * 999) then
    Result := FloatToStrEx(Size / 1024, 3) + ' ' + TA('Kb');
  if (Size > 1024 * 999) and (Size <= 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024), 3) + ' ' + TA('Mb');
  if (Size > 1024 * 1024 * 999) and ((Size div 1024) <= 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024 * 1024), 3) + ' ' + TA('Gb');
  if (Size div 1024 > 1024 * 1024 * 999) then
    Result := FloatToStrEx((Size / (1024 * 1024)) / (1024 * 1024), 3) + ' ' + TA('Tb');
end;

function TimeIntervalInString(Time: TTime): string;
var
  Y, MM, Days, H, M, S, MS: Word;
  SD, SH, SM, SS: string;

  function RoundSeconds(Sec: Word): Word;
  begin
    Result := Ceil(S / 5) * 5;
  end;

begin
  DecodeDateTime(Time, Y, MM, Days, H, M, S, MS);
  Days := Min(30, (Days - 1) + (Y - 1) * 12 * 365 + (MM - 1) * 30);

  S := RoundSeconds(S);

  SD := IntToStr(Days) + ' ' + IIF(Days <> 1, TA('days', 'Global'), TA('day', 'Global'));
  SH := IntToStr(H) + ' ' + IIF(H <> 1, TA('hours', 'Global'), TA('hour', 'Global'));
  SM := IntToStr(M) + ' ' + IIF(M <> 1, TA('minutes', 'Global'), TA('minute', 'Global'));
  SS := IntToStr(S) + ' ' + IIF(S <> 1, TA('seconds', 'Global'), TA('second', 'Global'));

  if Days > 0 then
    Result := SD + ', ' + SH
  else if H > 0 then
    Result := SH + ', ' + SM
  else if M > 0 then
    Result := SM + ', ' + SS
  else
    Result := SS;

  if Length(Result) > 0 then
    Result[1] := UpCase(Result[1]);
end;

function NumberToShortNumber(Number: Integer): string;
begin
  if Number > 10000000 then
    Exit(IntToStr(Number div 1000000) + 'M+');

  if Number > 10000 then
    Exit(IntToStr(Number div 1000) + 'K+');

  Result := IntToStr(Number);
end;

end.
