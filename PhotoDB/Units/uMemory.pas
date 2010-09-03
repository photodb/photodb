unit uMemory;

interface

uses SysUtils;

procedure F(var Obj); inline;

implementation

procedure F(var Obj);
begin
  if TObject(Obj) <> nil then
    FreeAndNil(Obj);
end;

end.
