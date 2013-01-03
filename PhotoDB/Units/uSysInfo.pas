unit uSysInfo;

interface

uses
  System.Win.Registry,
  System.SysUtils,
  Winapi.Windows,

  Dmitry.Utils.System;

const
  VER_NT_WORKSTATION    :Integer = 1;
  VER_SUITE_ENTERPRISE  :Integer = 2;
  VER_NT_SERVER         :Integer = 3;
  VER_SUITE_DATACENTER  :Integer = 128;
  VER_SUITE_PERSONAL    :Integer = 512;

const
  PRODUCT_BUSINESS                      = $00000006; {Business Edition}
  PRODUCT_BUSINESS_N                    = $00000010; {Business Edition}
  PRODUCT_CLUSTER_SERVER                = $00000012; {Cluster Server Edition}
  PRODUCT_DATACENTER_SERVER             = $00000008; {Server Datacenter Edition
(full installation)}
  PRODUCT_DATACENTER_SERVER_CORE        = $0000000C; {Server Datacenter Edition
(core installation)}
  PRODUCT_ENTERPRISE                    = $00000004; {Enterprise Edition}
  PRODUCT_ENTERPRISE_N                  = $0000001B; {Enterprise Edition}
  PRODUCT_ENTERPRISE_SERVER             = $0000000A; {Server Enterprise Edition
(full installation)}
  PRODUCT_ENTERPRISE_SERVER_CORE        = $0000000E; {Server Enterprise Edition
(core installation)}
  PRODUCT_ENTERPRISE_SERVER_IA64        = $0000000F; {Server Enterprise Edition
for Itanium-based Systems}
  PRODUCT_HOME_BASIC                    = $00000002; {Home Basic Edition}
  PRODUCT_HOME_BASIC_N                  = $00000005; {Home Basic Edition}
  PRODUCT_HOME_PREMIUM                  = $00000003; {Home Premium Edition}
  PRODUCT_HOME_PREMIUM_N                = $0000001A; {Home Premium Edition}
  PRODUCT_HOME_SERVER                   = $00000013; {Home Server Edition}
  PRODUCT_SERVER_FOR_SMALLBUSINESS      = $00000018; {Server for Small Business
Edition}
  PRODUCT_SMALLBUSINESS_SERVER          = $00000009; {Small Business Server}
  PRODUCT_SMALLBUSINESS_SERVER_PREMIUM  = $00000019; {Small Business Server
Premium Edition}
  PRODUCT_STANDARD_SERVER               = $00000007; {Server Standard Edition
(full installation)}
  PRODUCT_STANDARD_SERVER_CORE          = $0000000D; {Server Standard Edition
(core installation)}
  PRODUCT_STARTER                       = $0000000B; {Starter Edition}
  PRODUCT_STORAGE_ENTERPRISE_SERVER     = $00000017; {Storage Server Enterprise
Edition}
  PRODUCT_STORAGE_EXPRESS_SERVER        = $00000014; {Storage Server Express
Edition}
  PRODUCT_STORAGE_STANDARD_SERVER       = $00000015; {Storage Server Standard
Edition}
  PRODUCT_STORAGE_WORKGROUP_SERVER      = $00000016; {Storage Server Workgroup
Edition}
  PRODUCT_UNDEFINED                     = $00000000; {An unknown product}
  PRODUCT_ULTIMATE                      = $00000001; {Ultimate Edition}
  PRODUCT_ULTIMATE_N                    = $0000001C; {Ultimate Edition}
  PRODUCT_WEB_SERVER                    = $00000011; {Web Server Edition}
  PRODUCT_UNLICENSED                    = $ABCDABCD; {Unlicensed product}

function GetOSInfo: string;

implementation

function GetOSInfo: string;
var
  NTBres, BRes: Boolean;
  OSVI: TOSVERSIONINFO;
  OSVI_NT: TOSVERSIONINFOEX;
  tmpStr, SPVersion: string;
  dwOSMajorVersion, dwOSMinorVersion,
  dwSpMajorVersion, dwSpMinorVersion,
  pdwReturnedProductType: DWORD;
  Is64Windows: Boolean;

  function GetProductInfo: string;
  var
    GetProductInfo: function (dwOSMajorVersion, dwOSMinorVersion,
                              dwSpMajorVersion, dwSpMinorVersion: DWORD;
                              var pdwReturnedProductType: DWORD): BOOL stdcall;
  begin
    @GetProductInfo := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), 'GetProductInfo');

     if Assigned(GetProductInfo) then
     begin
       GetProductInfo( dwOSMajorVersion, dwOSMinorVersion,
                       dwSpMajorVersion, dwSpMinorVersion,
                       pdwReturnedProductType );
       case pdwReturnedProductType of
         PRODUCT_BUSINESS:
           tmpStr := 'Business Edition';
         PRODUCT_BUSINESS_N:
           tmpStr := 'Business Edition';
         PRODUCT_CLUSTER_SERVER:
           tmpStr := 'Cluster Server Edition';
         PRODUCT_DATACENTER_SERVER:
           tmpStr := 'Server Datacenter Edition (full installation)';
         PRODUCT_DATACENTER_SERVER_CORE:
           tmpStr := 'Server Datacenter Edition (core installation)';
         PRODUCT_ENTERPRISE:
           tmpStr := 'Enterprise Edition';
         PRODUCT_ENTERPRISE_N:
           tmpStr := 'Enterprise Edition';
         PRODUCT_ENTERPRISE_SERVER:
           tmpStr := 'Server Enterprise Edition (full installation)';
         PRODUCT_ENTERPRISE_SERVER_CORE:
           tmpStr := 'Server Enterprise Edition (core installation)';
         PRODUCT_ENTERPRISE_SERVER_IA64:
           tmpStr := 'Server Enterprise Edition for Itanium-based Systems';
         PRODUCT_HOME_BASIC:
           tmpStr := 'Home Basic Edition';
         PRODUCT_HOME_BASIC_N:
           tmpStr := 'Home Basic Edition';
         PRODUCT_HOME_PREMIUM:
           tmpStr := 'Home Premium Edition';
         PRODUCT_HOME_PREMIUM_N:
           tmpStr := 'Home Premium Edition';
         PRODUCT_HOME_SERVER:
           tmpStr := 'Home Server Edition';
         PRODUCT_SERVER_FOR_SMALLBUSINESS:
           tmpStr := 'Server for Small Business Edition';
         PRODUCT_SMALLBUSINESS_SERVER:
           tmpStr := 'Small Business Server';
         PRODUCT_SMALLBUSINESS_SERVER_PREMIUM:
           tmpStr := 'Small Business Server Premium Edition';
         PRODUCT_STANDARD_SERVER:
           tmpStr := 'Server Standard Edition (full installation)';
         PRODUCT_STANDARD_SERVER_CORE:
           tmpStr := 'Server Standard Edition (core installation)';
         PRODUCT_STARTER:
           tmpStr := 'Starter Edition';
         PRODUCT_STORAGE_ENTERPRISE_SERVER:
           tmpStr := 'Storage Server Enterprise Edition';
         PRODUCT_STORAGE_EXPRESS_SERVER:
           tmpStr := 'Storage Server Express Edition';
         PRODUCT_STORAGE_STANDARD_SERVER:
           tmpStr := 'Storage Server Standard Edition';
         PRODUCT_STORAGE_WORKGROUP_SERVER:
           tmpStr := 'Storage Server Workgroup Edition';
         PRODUCT_UNDEFINED:
           tmpStr := 'An unknown product';
         PRODUCT_ULTIMATE:
           tmpStr := 'Ultimate Edition';
         PRODUCT_ULTIMATE_N:
           tmpStr := 'Ultimate Edition';
         PRODUCT_WEB_SERVER:
           tmpStr := 'Web Server Edition';
         PRODUCT_UNLICENSED:
           tmpStr := 'Unlicensed product'
       else
         tmpStr := '';
       end;{ pdwReturnedProductType }
       Result := Result + tmpStr;
       NTBRes := FALSE;
     end;{ GetProductInfo<>NIL }
  end;

begin

  Result := 'Error';
  NTBRes := FALSE;
  try
    OSVI_NT.dwOSVersionInfoSize := SizeOf(TOSVERSIONINFOEX);
    NTBRes := GetVersionExW(OSVI_NT);
    OSVI.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
    BRes := GetVersionEx(OSVI);
  except
    OSVI.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
    BRes := GetVersionEx(OSVI);
  end;
  if (not BRes) and (not NTBres) then
    Exit;
  Move( OSVI, OSVI_NT, SizeOf(TOSVersionInfo) );

  Result := FormatEx('Windows {0}.{1}', [OSVI_NT.dwMajorVersion, OSVI_NT.dwMinorVersion]);

  case OSVI_NT.dwPlatformId of
     VER_PLATFORM_WIN32_NT:
       begin
         if OSVI_NT.dwMajorVersion <= 4 then
           Result := 'Windows NT ';
         if (OSVI_NT.dwMajorVersion = 5) and (OSVI_NT.dwMinorVersion = 0) then
           Result := 'Windows 2000 ';
         if  (OSVI_NT.dwMajorVersion = 5) and (OSVI_NT.dwMinorVersion = 1) then
           Result := 'Windows XP ';
         if (OSVI_NT.dwMajorVersion = 6) and (OSVI_NT.dwMinorVersion = 0) then
           Result := 'Windows Vista ' + GetProductInfo;
         if (OSVI_NT.dwMajorVersion = 6) and (OSVI_NT.dwMinorVersion = 1) then
           Result := 'Windows 7 ' + GetProductInfo;
         if (OSVI_NT.dwMajorVersion = 6) and (OSVI_NT.dwMinorVersion = 2) then
           Result := 'Windows 8 ' + GetProductInfo;

         SPVersion := StrPas(OSVI_NT.szCSDVersion);
         if SPVersion <> '' then
           Result := Result + ', ' + SPVersion;

         IsWow64Process(GetCurrentProcessId, @Is64Windows);
         if Is64Windows then
           Result := Result + ' (x64)';

         if NTBres then
         begin
           if OSVI_NT.wProductType = VER_NT_WORKSTATION then
           begin
             if OSVI_NT.wProductType = VER_NT_WORKSTATION then
             begin
               case OSVI_NT.wSuiteMask of
                 512: Result := Result + 'Personal';
                 768: Result := Result + 'Home Premium';
               else
                 Result := Result + 'Professional';
               end;
             end
             else if OSVI_NT.wProductType = VER_NT_SERVER then
             begin
               if OSVI_NT.wSuiteMask = VER_SUITE_DATACENTER then
                 Result := Result + 'DataCenter Server'
               else if OSVI_NT.wSuiteMask = VER_SUITE_ENTERPRISE then
                 Result :=  Result + 'Advanced Server'
               else
                 Result := Result + 'Server';
             end;
           end{ wProductType=VER_NT_WORKSTATION }
           else
           begin
             with TRegistry.Create do
               try
                 RootKey := HKEY_LOCAL_MACHINE;
                 if OpenKeyReadOnly('SYSTEM\CurrentControlSet\Control\ProductOptions') then
                   try
                     tmpStr := UpperCase(ReadString('ProductType'));
                     if tmpStr = 'WINNT' then
                       Result := Result + 'Workstation';
                     if tmpStr = 'SERVERNT' then
                       Result := Result + 'Server';
                   finally
                     CloseKey;
                   end;
               finally
                 Free;
               end;
             end;{ wProductType<>VER_NT_WORKSTATION }
           end;{ NTBRes }
         end;{ VER_PLATFORM_WIN32_NT }
     VER_PLATFORM_WIN32_WINDOWS:
       begin
         if (OSVI.dwMajorVersion = 4) and (OSVI.dwMinorVersion = 0) then
         begin
           Result := 'Windows 95 ';
           if OSVI.szCSDVersion[1] = 'C' then
             Result := Result + 'OSR2';
         end;
         if (OSVI.dwMajorVersion = 4) and (OSVI.dwMinorVersion = 10) then
         begin
           Result := 'Windows 98 ';
           if OSVI.szCSDVersion[1] = 'A' then
             Result := Result + 'SE';
         end;
         if (OSVI.dwMajorVersion = 4) and (OSVI.dwMinorVersion = 90) then
           Result := 'Windows Me';
       end;{ VER_PLATFORM_WIN32_WINDOWS }
     VER_PLATFORM_WIN32s:
       Result := 'Microsoft Win32s';
  else
    Result := FormatEx('Unknown {0}.{1}', [OSVI_NT.dwMajorVersion, OSVI_NT.dwMinorVersion]);
  end;{ OSVI_NT.dwPlatformId }
end;{ GetOSInfo }

end.
