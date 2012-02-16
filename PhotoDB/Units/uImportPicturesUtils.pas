unit uImportPicturesUtils;

interface

uses
  DateUtils,
  uSysUtils,
  SysUtils,
  uMemory,
  uTranslate,
  uStringUtils;

function MonthToString(Date: TDate; Scope: string): string;
function WeekDayToString(Date: TDate): string;
function FormatPath(Patern: string; Date: TDate; ItemsLabel: string): string;

implementation

function MonthToString(Date: TDate; Scope: string): string;
const
  MonthList: array[1..12] of string = ('january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december');
begin
  Result := TA(MonthList[MonthOf(Date)], Scope);
end;

function WeekDayToString(Date: TDate): string;
const
  MonthList: array[1..7] of string = ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
begin
  Result := TA(MonthList[DayOfTheWeek(Date)], 'Date');
end;

function FormatPath(Patern: string; Date: TDate; ItemsLabel: string): string;
var
  SR: TStringReplacer;
begin
  SR := TStringReplacer.Create(Patern);
  try
    SR.AddPattern('''LABEL''', IIF(ItemsLabel = '', '', '''' + ItemsLabel + ''''));
    SR.AddPattern('[LABEL]', IIF(ItemsLabel = '', '', '[' + ItemsLabel + ']'));
    SR.AddPattern('(LABEL)', IIF(ItemsLabel = '', '', '(' + ItemsLabel + ')'));
    SR.AddPattern('LABEL', ItemsLabel);
    SR.AddPattern('YYYY', FormatDateTime('yyyy', Date));
    SR.AddPattern('YY', FormatDateTime('yy', Date));
    SR.AddPattern('MMMM', MonthToString(Date, 'Date'));
    SR.AddPattern('MMM', MonthToString(Date, 'Month'));
    SR.AddPattern('MM', FormatDateTime('mm', Date));
    SR.AddPattern('M', FormatDateTime('M', Date));
    SR.AddPattern('DDD', WeekDayToString(Date));
    SR.AddPattern('DD', FormatDateTime('dd', Date));
    SR.AddPattern('d', FormatDateTime('d', Date));

    Result := SR.Result;
  finally
    F(SR);
  end;
end;

end.
