unit uDBEntities;

interface

uses
  Data.DB;

type
  TBaseEntity = class
  public
    procedure ReadFromDS(DS: TDataSet); virtual; abstract;
  end;

  TSettings = class(TBaseEntity)
  public
    Version: Integer;
    Name: string;
    Description: string;

    DBJpegCompressionQuality: Byte;
    ThSize: Integer;
    ThHintSize: Integer;

    constructor Create;
    function Copy: TSettings;
    procedure ReadFromDS(DS: TDataSet); override;
  end;

implementation

{ TSettings }

function TSettings.Copy: TSettings;
begin
  Result := TSettings.Create;
  Result.Version := Version;

  Result.Name := Name;
  Result.Description := Description;

  Result.DBJpegCompressionQuality := DBJpegCompressionQuality;
  Result.ThSize := ThSize;
  Result.ThHintSize := ThHintSize;
end;

constructor TSettings.Create;
begin
  Version := 0;
  DBJpegCompressionQuality := 75;
  ThSize := 200;
  ThHintSize := 400;
end;

procedure TSettings.ReadFromDS(DS: TDataSet);
begin
  Version := DS.FieldByName('Version').AsInteger;

  Name := DS.FieldByName('DBName').AsString;
  Description := DS.FieldByName('DBDescription').AsString;

  DBJpegCompressionQuality := DS.FieldByName('DBJpegCompressionQuality').AsInteger;
  ThSize := DS.FieldByName('ThImageSize').AsInteger;
  ThHintSize := DS.FieldByName('ThHintSize').AsInteger;
end;

end.
