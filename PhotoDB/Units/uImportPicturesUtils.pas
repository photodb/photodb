unit uImportPicturesUtils;

interface

uses
  System.DateUtils,
  System.SysUtils,

  Dmitry.Utils.System,
  Dmitry.PathProviders,
  Dmitry.PathProviders.FileSystem,

  CCR.Exif,

  uMemory,
  uTranslate,
  uExplorerPortableDeviceProvider,
  uRawExif,
  uAssociations,
  uDateUtils,
  uStringUtils;

function FormatPath(Patern: string; Date: TDate; ItemsLabel: string): string;
function GetImageDate(PI: TPathItem): TDateTime;

implementation

function FormatPath(Patern: string; Date: TDate; ItemsLabel: string): string;
var
  SR: TStringReplacer;
begin
  SR := TStringReplacer.Create(Patern);
  try
    SR.CaseSencetive := True;
    SR.AddPattern('''LABEL''', IIF(ItemsLabel = '', '', '''' + ItemsLabel + ''''));
    SR.AddPattern('[LABEL]', IIF(ItemsLabel = '', '', '[' + ItemsLabel + ']'));
    SR.AddPattern('(LABEL)', IIF(ItemsLabel = '', '', '(' + ItemsLabel + ')'));
    SR.AddPattern('LABEL', ItemsLabel);
    SR.AddPattern('YYYY', FormatDateTime('yyyy', Date));
    SR.AddPattern('YY', FormatDateTime('yy', Date));
    SR.AddPattern('mmmm', MonthToString(Date, 'Date'));
    SR.AddPattern('MMMM', UpperCaseFirstLetter(MonthToString(Date, 'Date')));
    SR.AddPattern('mmm', MonthToString(Date, 'Month'));
    SR.AddPattern('MMM', UpperCaseFirstLetter(MonthToString(Date, 'Month')));
    SR.AddPattern('MM', FormatDateTime('mm', Date));
    SR.AddPattern('M', FormatDateTime('M', Date));
    SR.AddPattern('DDD', UpperCaseFirstLetter(WeekDayToString(Date)));
    SR.AddPattern('ddd', WeekDayToString(Date));
    SR.AddPattern('DD', FormatDateTime('dd', Date));
    SR.AddPattern('D', FormatDateTime('d', Date));

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
        RAWExif := TRAWExif.Create;
        try
          RAWExif.LoadFromFile(PI.Path);
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
