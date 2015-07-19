unit Dmitry.Memory;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes;

//Free object instance with check
procedure F(var Obj); inline;
//Free list items and then free list object
procedure FreeList(var obj; FreeList: Boolean = True);

implementation

procedure F(var Obj);
begin
  if TObject(Obj) <> nil then
    FreeAndNil(Obj);
end;

procedure FreeList(var obj; FreeList: Boolean = True);
var
  I: Integer;
  O: TObject;
begin
  if TObject(Obj) <> nil then
  begin
    if TObject(Obj) is TList then
    begin
      for I := 0 to TList(obj).Count - 1 do
        TObject(TList(obj)[I]).Free;

      if FreeList then
        FreeAndNil(Obj)
      else
        TList(obj).Clear;
    end else
    begin
      for O in TEnumerable<TObject>(obj) do
        O.Free;

      if FreeList then
        FreeAndNil(Obj)
      else
        TList<TObject>(Obj).Clear;
    end;

  end;
end;

end.
