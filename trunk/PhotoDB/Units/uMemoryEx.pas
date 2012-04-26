unit uMemoryEx;

interface

uses
  SysUtils, Classes, Forms, OLE2;

//Release object with check (TForm supported too)
procedure R(var Intf);

implementation

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

end.
