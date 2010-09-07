unit uMemory;

interface

uses SysUtils, Classes;

//Free object instance with check
procedure F(var Obj); inline;
//Free list items and then free list object
procedure FreeList(var obj);

implementation

procedure F(var Obj);
begin
  if TObject(Obj) <> nil then
    FreeAndNil(Obj);
end;

procedure FreeList(var obj);
var
  I : Integer;
begin
  if TObject(Obj) <> nil then
  begin
    for I := 0 to TList(obj).Count - 1 do
      TObject(TList(obj)[I]).Free;

    FreeAndNil(Obj);
  end;
end;

end.
