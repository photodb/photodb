unit uGUIDUtils;

interface

uses
  WInapi.ActiveX;

const
  SystemDirectoryWatchNotification: TGUID = '{EB9930E8-3158-4192-95F9-8341B313AA8D}';

function GetGUID: TGUID;
function IsSystemState(State: TGUID): Boolean;

implementation

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

function IsSystemState(State: TGUID): Boolean;
begin
  if State = SystemDirectoryWatchNotification then
    Exit(True);

  Result := False;
end;

end.
