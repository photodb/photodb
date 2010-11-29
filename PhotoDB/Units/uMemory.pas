unit uMemory;

interface

uses SysUtils, Classes
{$IFDEF PHOTODB}
, Forms, OLE2
{$ENDIF}
;

//Free object instance with check
procedure F(var Obj); inline;
//Release object with check (TForm supported too)
{$IFDEF PHOTODB}
procedure R(var Intf);
{$ENDIF}
//Free list items and then free list object
procedure FreeList(var obj);

implementation

procedure F(var Obj);
begin
  if TObject(Obj) <> nil then
    FreeAndNil(Obj);
end;

{$IFDEF PHOTODB}
procedure R(var Intf);
var
  I : IUnknown;
  F : TForm;
begin
  if (Pointer(Intf) <> nil) and (TObject(Intf) is TForm) then
  begin
    F := TForm(Intf);
    Pointer(Intf) := nil;
    F.Release;
  end else if IUnknown(Intf) <> nil then
  begin
    I := IUnknown(Intf);
    Pointer(Intf) := nil;
    I.Release;
  end;
end;
{$ENDIF}

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
