unit uPathProviderUtils;

interface

uses
  uMemory,
  uPathProviders;

function ExecuteProviderFeature(Sender: TObject; FileName, Feature: string): Boolean;

implementation

function ExecuteProviderFeature(Sender: TObject; FileName, Feature: string): Boolean;
var
  PL: TPathItemCollection;
  P: TPathItem;
begin
  Result := False;

  P := PathProviderManager.CreatePathItem(FileName);
  try
    if P <> nil then
    begin
      if P.Provider.SupportsFeature(Feature) then
      begin
        PL := TPathItemCollection.Create;
        try
          PL.Add(P);
          Result := P.Provider.ExecuteFeature(Sender, PL, Feature, nil);
        finally
          F(PL);
        end;
      end;
    end;
  finally
    F(P);
  end;
end;

end.
