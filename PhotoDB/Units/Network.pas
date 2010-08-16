unit Network;

interface

uses Windows, SysUtils, Classes;

Function FillNetLevel(xxx: PNetResourceW; list: TStrings) : Word;
Function FindAllComputers(Workgroup: string; Computers : TStrings) : Cardinal;
Function GetResourceParent(ComputerName : String) : String;

implementation

Function FillNetLevel(xxx: PNetResourceW; list: TStrings) : Word;
Type
    PNRArr = ^TNRArr; 
    TNRArr = array[0..59] of TNetResource;
Var 
   x: PNRArr;
   tnr: TNetResource; 
   I : integer; 
   EntrReq, 
   SizeReq, 
   twx: Cardinal;
   WSName: string; 
begin 
     Result := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_ANY, RESOURCEUSAGE_CONTAINER, xxx, twx);
     If Result = ERROR_NO_NETWORK Then Exit;
     if Result = NO_ERROR then 
     begin
            New(x);
            EntrReq := 1; 
            SizeReq := SizeOf(TNetResource)*59; 
            while (twx <> 0) and
                  (WNetEnumResource(twx, EntrReq, x, SizeReq) <> ERROR_NO_MORE_ITEMS) do
            begin
                  For i := 0 To EntrReq - 1 do
                  begin
                   Move(x^[i], tnr, SizeOf(tnr));
                   case tnr.dwDisplayType of 
                    RESOURCEDISPLAYTYPE_DOMAIN: 
                    begin 
                       if tnr.lpRemoteName <> '' then 
                           WSName:= tnr.lpRemoteName 
                           else WSName:= tnr.lpComment; 
                       list.Add(WSName); 
                    end; 
                    else FillNetLevel(@tnr, list); 
                   end; 
                  end; 
            end; 
            Dispose(x); 
            WNetCloseEnum(twx); 
     end; 
end;

Function FindAllComputers(Workgroup: string; Computers : TStrings) : Cardinal;
var
  EnumHandle: THandle;
  WorkgroupRS: TNetResource;
  Buf: array[1..500] of TNetResource;
  BufSize: Cardinal;
  Entries: Cardinal;
begin
  Computers.Clear;
  Workgroup := Workgroup + #0;
  FillChar(WorkgroupRS, SizeOf(WorkgroupRS), 0);
  with WorkgroupRS do
    begin
      dwScope := 2; 
      dwType := 3; 
      dwDisplayType := 1;
      dwUsage := 2; 
      lpRemoteName := @Workgroup[1]; 
    end;
  WNetOpenEnum(RESOURCE_GLOBALNET,
    RESOURCETYPE_ANY, 
    0, 
    @WorkgroupRS, 
    EnumHandle);
  repeat 
    Entries := 1;
    BufSize := SizeOf(Buf);
    Result := WNetEnumResource(EnumHandle, Entries, @Buf, BufSize);
    if (Result = NO_ERROR) and (Entries = 1) then
      begin
       Computers.Add(StrPas(Buf[1].lpRemoteName))
      end;
  until (Entries <> 1) or (Result <> NO_ERROR);
  WNetCloseEnum(EnumHandle);
end;

Function GetResourceParent(ComputerName : String) : String;
var
  lpNetResource,lpNet: PNetResource;
  cbBuffer: DWORD;
  dwNetType: Cardinal;
  lpProviderName: Pchar;
begin
 cbBuffer:=1000;
 dwNetType:= WNNC_NET_LANMAN;
 GetMem(lpProviderName,cbBuffer);
 if WNetGetProviderName(dwNetType,lpProviderName,cbBuffer)=0 then
 begin
  GetMem(lpNet,1000);
  New(lpNetResource);
  cbBuffer:=1000;
  lpNetResource^.lpLocalName:=nil;
  lpNetResource^.dwScope:=0;
  lpNetResource^.dwDisplayType:=0;
  lpNetResource^.dwUsage:=0;
  lpNetResource^.lpComment:=nil;
  lpNetResource^.lpRemoteName:=PChar(ComputerName);
  lpNetResource^.dwType:=RESOURCETYPE_ANY;
  lpNetResource^.lpProvider:=lpProviderName;
  if WNetGetResourceParent(lpNetResource,lpNet,cbBuffer)=0 then
  begin
   Result:=StrPas(lpnet^.lpRemoteName);
  end;
  FreeMem(lpNetResource);
  FreeMem(lpNet);
 end;
 freemem(lpProviderName);
end;

end.
