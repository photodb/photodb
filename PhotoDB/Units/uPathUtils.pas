unit uPathUtils;

interface

uses
  Classes,
  uMemory,
  SysUtils;

type
  TPath = class
    class function Combine(FirstPath: string; PathToCombine: string): string;
    class function TrimPathDirectories(Path: string): string;
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

class function TPath.TrimPathDirectories(Path: string): string;

  procedure ClearPathParts(C: Char);
  var
    I: Integer;
    SL: TStringList;
  begin
    SL := TStringList.Create;
    try
      SL.Delimiter := C;
      SL.StrictDelimiter := True;
      SL.DelimitedText := Result;
      for I := 0 to SL.Count - 1 do
        SL[I] := Trim(SL[I]);

      Result := SL.DelimitedText;
    finally
      F(SL);
    end;
  end;

begin
  Result := Path;
  ClearPathParts('/');
  ClearPathParts('\');
end;

end.
