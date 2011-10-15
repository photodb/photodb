unit uGUIDUtils;

interface

uses
  ActiveX;

function GetGUID: TGUID;

implementation

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

end.
