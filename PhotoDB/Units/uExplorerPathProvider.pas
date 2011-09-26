unit uExplorerPathProvider;

interface

uses
  uPathProviders, uTranslate;

type
  TExplorerPathProvider = class(TPathProvider)
  protected
    function GetTranslateID: string; virtual; abstract;
    function L(StringToTranslate: string): string; overload;
    function L(StringToTranslate, ScopeName: string): string; overload;
  public
    property TranslateID: string read GetTranslateID;
  end;

implementation

{ TExplorerPathProvider }

function TExplorerPathProvider.L(StringToTranslate: string): string;
begin
  Result := TA(StringToTranslate, TranslateID);
end;

function TExplorerPathProvider.L(StringToTranslate, ScopeName: string): string;
begin
  Result := TA(StringToTranslate, ScopeName);
end;

end.
