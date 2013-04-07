unit uSettingsRepository;

interface

uses
  uConstants,
  uMemory,
  uDBEntities,
  uDBContext,
  uDBClasses;

type
  TSettingsRepository = class(TBaseRepository<TSettings>, ISettingsRepository)
  public
    function Get: TSettings;
    function Update(Settings: TSettings): Boolean;
  end;

implementation

{ TSettingsRepository }

function TSettingsRepository.Get: TSettings;
var
  SC: TSelectCommand;
begin
  Result := TSettings.Create;

  SC := Context.CreateSelect(TableSettings);
  try
    SC.AddParameter(TAllParameter.Create());
    SC.AddWhereParameter(TCustomConditionParameter.Create('1 = 1'));

    if SC.Execute > 0 then
      Result.ReadFromDS(SC.DS);
  finally
    F(SC);
  end;
end;

function TSettingsRepository.Update(Settings: TSettings): Boolean;
var
  UC: TUpdateCommand;
begin
  Result := True;

  UC := Context.CreateUpdate(TableSettings);
  try
    UC.AddParameter(TIntegerParameter.Create('DBJpegCompressionQuality', Settings.DBJpegCompressionQuality));
    UC.AddParameter(TIntegerParameter.Create('ThImageSize', Settings.ThSize));
    UC.AddParameter(TIntegerParameter.Create('ThHintSize', Settings.ThHintSize));
    //UC.AddParameter(TIntegerParameter.Create('ThSizePanelPreview', Settings.ThSizePanelPreview));
    UC.AddParameter(TStringParameter.Create('DBName', Settings.Name));
    UC.AddParameter(TStringParameter.Create('DBDescription', Settings.Description));

    UC.AddWhereParameter(TCustomConditionParameter.Create('1 = 1'));

    UC.Execute;
  finally
    F(UC);
  end;
end;

end.
