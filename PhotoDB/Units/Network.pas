unit Network;

interface

uses Windows, SysUtils, Classes;

type
  TWNetOpenEnumW = function(dwScope, dwType, dwUsage: DWORD;  lpNetResource: PNetResourceW; var lphEnum: THandle): DWORD stdcall;
  TWNetEnumResourceW = function(hEnum: THandle; var lpcCount: DWORD;  lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD stdcall;
  TWNetCloseEnumW = function(hEnum: THandle): DWORD stdcall;
  TWNetGetProviderNameW = function(dwNetType: DWORD; lpProviderName: PWideChar;  var lpBufferSize: DWORD): DWORD stdcall;
  TWNetGetResourceParentW = function(lpNetResource: PNetResourceW;  lpBuffer: Pointer; var cbBuffer: DWORD): DWORD stdcall;

function FillNetLevel(Xxx: PNetResourceW; List: TStrings): Word;
function FindAllComputers(Workgroup: string; Computers: TStrings): Cardinal;
function GetResourceParent(ComputerName: string): string;

implementation

var
  MPRDllHandle : THandle = 0;
  WNetOpenEnumW : TWNetOpenEnumW;
  WNetEnumResourceW : TWNetEnumResourceW;
  WNetCloseEnumW : TWNetCloseEnumW;
  WNetGetProviderNameW : TWNetGetProviderNameW;
  WNetGetResourceParentW : TWNetGetResourceParentW;

procedure InitInet;
begin
  if MPRDllHandle = 0 then
  begin
    MPRDllHandle := LoadLibrary(mpr);
    WNetOpenEnumW := GetProcAddress(MPRDllHandle, 'WNetOpenEnumW');
    WNetEnumResourceW := GetProcAddress(MPRDllHandle, 'WNetEnumResourceW');
    WNetCloseEnumW := GetProcAddress(MPRDllHandle, 'WNetCloseEnum');
    WNetGetProviderNameW := GetProcAddress(MPRDllHandle, 'WNetGetProviderNameW');
    WNetGetResourceParentW := GetProcAddress(MPRDllHandle, 'WNetGetResourceParentW');
  end;
end;

function FillNetLevel(Xxx: PNetResourceW; List: TStrings): Word;
type
  PNRArr = ^TNRArr;
  TNRArr = array [0 .. 59] of TNetResource;
var
  X: PNRArr;
  Tnr: TNetResource;
  I: Integer;
  EntrReq, SizeReq, Twx: Cardinal;
  WSName: string;
begin
  InitInet;
  Result := WNetOpenEnumW(RESOURCE_GLOBALNET, RESOURCETYPE_ANY, RESOURCEUSAGE_CONTAINER, Xxx, Twx);
  if Result = ERROR_NO_NETWORK then
    Exit;
  if Result = NO_ERROR then
  begin
    New(X);
    EntrReq := 1;
    SizeReq := SizeOf(TNetResource) * 59;
    while (Twx <> 0) and (WNetEnumResourceW(Twx, EntrReq, X, SizeReq) <> ERROR_NO_MORE_ITEMS) do
    begin
      for I := 0 to EntrReq - 1 do
      begin
        Move(X^[I], Tnr, SizeOf(Tnr));
        case Tnr.DwDisplayType of
          RESOURCEDISPLAYTYPE_DOMAIN:
            begin
              if Tnr.LpRemoteName <> '' then
                WSName := Tnr.LpRemoteName
              else
                WSName := Tnr.LpComment;
              List.Add(WSName);
            end;
        else
          FillNetLevel(@Tnr, List);
        end;
      end;
    end;
    Dispose(X);
    WNetCloseEnumW(Twx);
  end;
end;

function FindAllComputers(Workgroup: string; Computers: TStrings): Cardinal;
var
  EnumHandle: THandle;
  WorkgroupRS: TNetResource;
  Buf: array [1 .. 500] of TNetResource;
  BufSize: Cardinal;
  Entries: Cardinal;
begin
  InitInet;
  Computers.Clear;
  Workgroup := Workgroup + #0;
  FillChar(WorkgroupRS, SizeOf(WorkgroupRS), 0);
  with WorkgroupRS do
  begin
    DwScope := 2;
    DwType := 3;
    DwDisplayType := 1;
    DwUsage := 2;
    LpRemoteName := @Workgroup[1];
  end;
  WNetOpenEnumW(RESOURCE_GLOBALNET, RESOURCETYPE_ANY, 0, @WorkgroupRS, EnumHandle);
  repeat
    Entries := 1;
    BufSize := SizeOf(Buf);
    Result := WNetEnumResourceW(EnumHandle, Entries, @Buf, BufSize);
    if (Result = NO_ERROR) and (Entries = 1) then
    begin
      Computers.Add(StrPas(Buf[1].LpRemoteName))
    end;
  until (Entries <> 1) or (Result <> NO_ERROR);
  WNetCloseEnumW(EnumHandle);
end;

function GetResourceParent(ComputerName: string): string;
var
  LpNetResource, LpNet: PNetResource;
  CbBuffer: DWORD;
  DwNetType: Cardinal;
  LpProviderName: PWideChar;
begin
  InitInet;
  CbBuffer := 1000;
  DwNetType := WNNC_NET_LANMAN;
  GetMem(LpProviderName, CbBuffer);
  if WNetGetProviderNameW(DwNetType, LpProviderName, CbBuffer) = 0 then
  begin
    GetMem(LpNet, 1000);
    New(LpNetResource);
    CbBuffer := 1000;
    LpNetResource^.LpLocalName := nil;
    LpNetResource^.DwScope := 0;
    LpNetResource^.DwDisplayType := 0;
    LpNetResource^.DwUsage := 0;
    LpNetResource^.LpComment := nil;
    LpNetResource^.LpRemoteName := PWideChar(ComputerName);
    LpNetResource^.DwType := RESOURCETYPE_ANY;
    LpNetResource^.LpProvider := LpProviderName;
    if WNetGetResourceParentW(LpNetResource, LpNet, CbBuffer) = 0 then
    begin
      Result := StrPas(Lpnet^.LpRemoteName);
    end;
    FreeMem(LpNetResource);
    FreeMem(LpNet);
  end;
  Freemem(LpProviderName);
end;

end.
