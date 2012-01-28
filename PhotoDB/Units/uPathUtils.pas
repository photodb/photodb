unit uPathUtils;

interface

uses
  SysUtils;

type
  TPath = class
    class function Combine(FirstPath: string; PathToCombine: string): string;
  end;

implementation

{ TPath }

class function TPath.Combine(FirstPath, PathToCombine: string): string;
begin
  Result := FirstPath;
  Result := IncludeTrailingPathDelimiter(Result);
  if PathToCombine <> '' then
    if IsDelimiter('\/', PathToCombine, 1) then
      Delete(PathToCombine, 1, 1);

  Result := Result + PathToCombine;
end;

end.
