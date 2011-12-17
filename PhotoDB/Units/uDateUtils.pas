unit uDateUtils;

interface

uses
  SysUtils, DateUtils;

function DateTimeStrEval(const DateTimeFormat : string;
                         const DateTimeStr : string) : TDateTime;

implementation

// =============================================================================
// Evaluate a date time string into a TDateTime obeying the
// rules of the specified DateTimeFormat string
// eg. DateTimeStrEval('dd-MMM-yyyy hh:nn','23-May-2002 12:34)
//
// NOTE : One assumption I have to make that DAYS,MONTHS,HOURS and
//        MINUTES have a leading ZERO or SPACE (ie. are 2 chars long)
//        and MILLISECONDS are 3 chars long (ZERO or SPACE padded)
//
// Supports DateTimeFormat Specifiers
//
// dd    the day as a number with a leading zero or space (01-31).
// ddd the day as an abbreviation (Sun-Sat)
// dddd the day as a full name (Sunday-Saturday)
// mm    the month as a number with a leading zero or space (01-12).
// mmm the month as an abbreviation (Jan-Dec)
// mmmm the month as a full name (January-December)
// yy    the year as a two-digit number (00-99).
// yyyy the year as a four-digit number (0000-9999).
// hh    the hour with a leading zero or space (00-23)
// nn    the minute with a leading zero or space (00-59).
// ss    the second with a leading zero or space (00-59).
// zzz the millisecond with a leading zero (000-999).
// ampm  Specifies am or pm flag hours (0..12)
// ap    Specifies a or p flag hours (0..12)
//
//
// Delphi 6 Specific in DateUtils can be translated to ....
//
// YearOf()
//
// function YearOf(const AValue: TDateTime): Word;
// var LMonth, LDay : word;
// begin
//   DecodeDate(AValue,Result,LMonth,LDay);
// end;
//
// TryEncodeDateTime()
//
// function TryEncodeDateTime(const AYear,AMonth,ADay,AHour,AMinute,ASecond,
//                            AMilliSecond : word;
//                            out AValue : TDateTime): Boolean;
// var LTime : TDateTime;
// begin
//   Result := TryEncodeDate(AYear, AMonth, ADay, AValue);
//   if Result then begin
//     Result := TryEncodeTime(AHour, AMinute, ASecond, AMilliSecond, LTime);
//     if Result then
//       AValue := AValue + LTime;
//   end;
// end;
//
// =============================================================================

function DateTimeStrEval(const DateTimeFormat: string;
  const DateTimeStr: string): TDateTime;
var
  I, Ii, Iii: Integer;
  Retvar: TDateTime;
  Tmp, Fmt, Data, Mask, Spec: string;
  Year, Month, Day, Hour, Minute, Second, MSec: Word;
  AmPm: Integer;
begin
  Year := 1;
  Month := 1;
  Day := 1;
  Hour := 0;
  Minute := 0;
  Second := 0;
  MSec := 0;
  Fmt := UpperCase(DateTimeFormat);
  Data := UpperCase(DateTimeStr);
  I := 1;
  Mask := '';
  AmPm := 0;

  while I < Length(Fmt) do
  begin
    if CharInSet(Fmt[I], ['A', 'P', 'D', 'M', 'Y', 'H', 'N', 'S', 'Z']) then
    begin
      // Start of a date specifier
      Mask := Fmt[I];
      Ii := I + 1;

      // Keep going till not valid specifier
      while True do
      begin
        if Ii > Length(Fmt) then
          Break; // End of specifier string
        Spec := Mask + Fmt[Ii];

        if (Spec = 'DD') or (Spec = 'DDD') or (Spec = 'DDDD') or (Spec = 'MM')
          or (Spec = 'MMM') or (Spec = 'MMMM') or (Spec = 'YY') or
          (Spec = 'YYY') or (Spec = 'YYYY') or (Spec = 'HH') or (Spec = 'NN') or
          (Spec = 'SS') or (Spec = 'ZZ') or (Spec = 'ZZZ') or (Spec = 'AP') or
          (Spec = 'AM') or (Spec = 'AMP') or (Spec = 'AMPM') then
        begin
          Mask := Spec;
          Inc(Ii);
        end
        else
        begin
          // End of or Invalid specifier
          Break;
        end;
      end;

      // Got a valid specifier ? - evaluate it from data string
      if (Mask <> '') and (Length(Data) > 0) then
      begin
        // Day 1..31
        if (Mask = 'DD') then
        begin
          Day := StrToIntDef(Trim(Copy(Data, 1, 2)), 0);
          Delete(Data, 1, 2);
        end;

        // Day Sun..Sat (Just remove from data string)
        if Mask = 'DDD' then
          Delete(Data, 1, 3);

        // Day Sunday..Saturday (Just remove from data string LEN)
        if Mask = 'DDDD' then
        begin
          Tmp := Copy(Data, 1, 3);
          for Iii := 1 to 7 do
          begin
            if Tmp = UpperCase(Copy(FormatSettings.LongDayNames[Iii],
              1, 3)) then
            begin
              Delete(Data, 1, Length(FormatSettings.LongDayNames[Iii]));
              Break;
            end;
          end;
        end;

        // Month 1..12
        if (Mask = 'MM') then
        begin
          Month := StrToIntDef(Trim(Copy(Data, 1, 2)), 0);
          Delete(Data, 1, 2);
        end;

        // Month Jan..Dec
        if Mask = 'MMM' then
        begin
          Tmp := Copy(Data, 1, 3);
          for Iii := 1 to 12 do
          begin
            if Tmp = UpperCase(Copy(FormatSettings.LongMonthNames[Iii],
              1, 3)) then
            begin
              Month := Iii;
              Delete(Data, 1, 3);
              Break;
            end;
          end;
        end;

        // Month January..December
        if Mask = 'MMMM' then
        begin
          Tmp := Copy(Data, 1, 3);
          for Iii := 1 to 12 do
          begin
            if Tmp = UpperCase(Copy(FormatSettings.LongMonthNames[Iii],
              1, 3)) then
            begin
              Month := Iii;
              Delete(Data, 1, Length(FormatSettings.LongMonthNames[Iii]));
              Break;
            end;
          end;
        end;

        // Year 2 Digit
        if Mask = 'YY' then
        begin
          Year := StrToIntDef(Copy(Data, 1, 2), 0);
          Delete(Data, 1, 2);
          if Year < FormatSettings.TwoDigitYearCenturyWindow then
            Year := (YearOf(Date) div 100) * 100 + Year
          else
            Year := (YearOf(Date) div 100 - 1) * 100 + Year;
        end;

        // Year 4 Digit
        if Mask = 'YYYY' then
        begin
          Year := StrToIntDef(Copy(Data, 1, 4), 0);
          Delete(Data, 1, 4);
        end;

        // Hours
        if Mask = 'HH' then
        begin
          Hour := StrToIntDef(Trim(Copy(Data, 1, 2)), 0);
          Delete(Data, 1, 2);
        end;

        // Minutes
        if Mask = 'NN' then
        begin
          Minute := StrToIntDef(Trim(Copy(Data, 1, 2)), 0);
          Delete(Data, 1, 2);
        end;

        // Seconds
        if Mask = 'SS' then
        begin
          Second := StrToIntDef(Trim(Copy(Data, 1, 2)), 0);
          Delete(Data, 1, 2);
        end;

        // Milliseconds
        if (Mask = 'ZZ') or (Mask = 'ZZZ') then
        begin
          MSec := StrToIntDef(Trim(Copy(Data, 1, 3)), 0);
          Delete(Data, 1, 3);
        end;

        // AmPm A or P flag
        if (Mask = 'AP') then
        begin
          if Data[1] = 'A' then
            AmPm := -1
          else
            AmPm := 1;
          Delete(Data, 1, 1);
        end;

        // AmPm AM or PM flag
        if (Mask = 'AM') or (Mask = 'AMP') or (Mask = 'AMPM') then
        begin
          if Copy(Data, 1, 2) = 'AM' then
            AmPm := -1
          else
            AmPm := 1;
          Delete(Data, 1, 2);
        end;

        Mask := '';
        I := Ii;
      end;
    end else
    begin
      // Remove delimiter from data string
      if Length(Data) > 1 then
        Delete(Data, 1, 1);
      Inc(I);
    end;
  end;

  if AmPm = 1 then
    Hour := Hour + 12;
  if not TryEncodeDateTime(Year, Month, Day, Hour, Minute, Second, MSec,
    Retvar) then
    Retvar := 0.0;
  Result := Retvar;
end;

end.
