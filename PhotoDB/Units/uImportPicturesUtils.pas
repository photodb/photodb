unit uImportPicturesUtils;

interface

uses
  DateUtils,
  uSysUtils,
  SysUtils,
  uMemory,
  uTranslate,
  uPathProviders,
  uExplorerFSProviders,
  uExplorerPortableDeviceProvider,
  RAWImage,
  uAssociations,
  CCR.Exif,
  uStringUtils;

function MonthToString(Date: TDate; Scope: string): string;
function WeekDayToString(Date: TDate): string;
function FormatPath(Patern: string; Date: TDate; ItemsLabel: string): string;
function GetImageDate(PI: TPathItem): TDateTime;

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

function GetImageDate(PI: TPathItem): TDateTime;
var
  RAWExif: TRAWExif;
  ExifData: TExifData;
begin
  Result := MinDateTime;

  if PI is TPortableFSItem then
    Result := TPortableImageItem(PI).Date
  else if PI is TFileItem then
  begin
    Result := TFileItem(PI).TimeStamp;
    if IsGraphicFile(PI.Path) then
    begin
      if IsRAWImageFile(PI.Path) then
      begin
        RAWExif := ReadRAWExif(PI.Path);
        try
          if RAWExif.IsEXIF then
            Result := DateOf(RAWExif.TimeStamp);
        finally
          F(RAWExif);
        end;
      end else
      begin
        ExifData := TExifData.Create;
        try
          ExifData.LoadFromGraphic(PI.Path);
          if not ExifData.Empty and (ExifData.DateTimeOriginal > 0) and (YearOf(ExifData.DateTimeOriginal) > 1900) then
            Result := DateOf(ExifData.DateTimeOriginal);
        finally
          F(ExifData);
        end;
      end;
    end;
  end;
end;

end.
