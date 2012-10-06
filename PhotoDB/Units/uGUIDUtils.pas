unit uGUIDUtils;

interface

uses
  WInapi.ActiveX;

function GetGUID: TGUID;

implementation

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

end.
