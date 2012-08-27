unit uAPIHook;

interface

uses
  Windows,
  SysUtils;

type
  //record for injecting
  TInjectDllData = record
    pLoadLibrary     : pointer; //points to the LoadLibrary Procedure :p
    lib_name         : pointer; //points to OUR dll lib name (eg c:\mydll.dll)
  end;

  //record for Code patching!!!
  TImageImportEntry = record
    Characteristics: dword;
    TimeDateStamp: dword;
    MajorVersion: word;
    MinorVersion: word;
    Name: dword;
    LookupTable: dword;
  end;

//The following code works for both Win32 - Standalone and Package, Win64 - Standalone and Package:
type
  TNativeUInt = {$if CompilerVersion < 23}Cardinal{$else}NativeUInt{$ifend};

function InjectDllToTarget(DllName: string; TargetProcessID: DWORD; Code: Pointer; CodeSize: NativeUInt): Boolean;
procedure InjectedProc(Parameter: Pointer); stdcall;
function HookCode(PEModule: HModule; Recursive: Boolean; TargetAddress, NewAddress: Pointer; var OldAddress: Pointer): Integer;

implementation

function GetActualAddr(Proc: Pointer): Pointer;
type
  PAbsoluteIndirectJmp = ^TAbsoluteIndirectJmp;
  TAbsoluteIndirectJmp = packed record
    OpCode: Word;   //$FF25(Jmp, FF /4)
    Addr: Cardinal;
  end;
var J: PAbsoluteIndirectJmp;
begin
  J := PAbsoluteIndirectJmp(Proc);
  if (J.OpCode = $25FF) then
    {$ifdef Win32}Result := PPointer(J.Addr)^{$endif}
    {$ifdef Win64}Result := PPointer(TNativeUInt(Proc) + J.Addr + 6{Instruction Size})^{$endif}
  else
    Result := Proc;
end;

procedure InjectedProcASM(pLoadLibrary: pointer; lib_name: pointer);
asm
  push pLoadLibrary
  call lib_name
end;

//Procedure to copy to foreign process
procedure InjectedProc(Parameter: Pointer); stdcall;
var
  InjectDllData : TInjectDllData;
begin
  InjectDllData := TInjectDllData(parameter^);
  InjectedProcASM(InjectDllData.lib_name, InjectDllData.pLoadLibrary);
end;

//check the exe stub for documentation on here!
function InjectDllToTarget(DllName: string; TargetProcessID: DWORD; Code: Pointer; CodeSize: NativeUInt): Boolean;
var
  InitDataAddr, WriteAddr: pointer;
  hProcess, ThreadHandle: NativeInt;
  BytesWritten: NativeUInt;
  TheadID: DWORD;
  InitData: TInjectDllData;
begin
  Result := False;
  InitData.pLoadLibrary := GetProcAddress(LoadLibrary('kernel32.dll'), 'LoadLibraryA');

  hProcess := OpenProcess( PROCESS_ALL_ACCESS, FALSE, TargetProcessID );
  If (hProcess = 0) then exit;

  InitData.lib_name := VirtualAllocEx(hProcess , nil, Length(dllName) + 5  , MEM_COMMIT , PAGE_READWRITE) ;
  If (InitData.lib_name <> nil) then
    WriteProcessMemory(hProcess , InitData.lib_name , PAnsiChar(dllName), length(dllName) , BytesWritten );

  InitDataAddr := VirtualAllocEx(hProcess , nil, sizeof(InitData)  , MEM_COMMIT , PAGE_READWRITE) ;
  If (InitDataAddr <> nil) then
    WriteProcessMemory(hProcess, InitDataAddr, (@InitData), sizeof(InitData), BytesWritten );

  WriteAddr := VirtualAllocEx(hProcess, nil, CodeSize, MEM_COMMIT, PAGE_READWRITE);
  If (WriteAddr <> nil) then
  begin
    WriteProcessMemory(hProcess, WriteAddr, code, CodeSize, BytesWritten);

    If BytesWritten = CodeSize then
    begin
      ThreadHandle := CreateRemoteThread(hProcess, nil, 0, WriteAddr, InitDataAddr , 0, TheadID);
      WaitForSingleObject(ThreadHandle, INFINITE);

      VirtualFreeEx(hProcess, WriteAddr, 0, MEM_RELEASE);
      Result := True;
    end;
  end;

  VirtualFreeEx(hProcess, InitDataAddr, 0 ,MEM_RELEASE);
  VirtualFreeEx(hProcess, InitData.lib_name, 0 ,MEM_RELEASE);

  CloseHandle(hProcess);
end;

function HookCode(PEModule: HModule; Recursive: Boolean; TargetAddress, NewAddress: Pointer; var OldAddress: Pointer): Integer;
var
  HookedModules: string;

  function HookModule(ImageDosHeader: PImageDosHeader; TargetAddress, NewAddress: Pointer; var OldAddress: Pointer): Integer;
  var
    Address: Pointer;
    ImportCode: ^Pointer;
    BytesWritten: NativeUInt;
    ImageNTHeaders: PImageNTHeaders;
    ImageImportEntry: ^TImageImportEntry;
    Module: string;
    OldProtect: Cardinal;
    ModuleHandle: HModule;
  begin
    Result := 0;

    OldAddress := GetActualAddr(TargetAddress);

    //check the header and see if there is one, if there isn't then exit hook routine
    If ImageDosHeader.e_magic <> IMAGE_DOS_SIGNATURE then Exit;
    //Loads the API headers into ImageNTHeaders
    ImageNTHeaders := Pointer(NativeInt(ImageDosHeader) + ImageDosHeader._lfanew);

    //checks if there are API header? (I think)
    If ImageNTHeaders^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress = 0 then Exit;
    //Gets just the API header addresses? (I think)
    ImageImportEntry := Pointer(NativeUInt(ImageDosHeader) + ImageNTHeaders^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);

    //Loops through each API header looking for the name you specified ready to patch!
    while ImageImportEntry^.Name <> 0 do
    begin
      //If its found then go into
      Module := string(AnsiString(PAnsiChar(NativeUInt(ImageDosHeader) + ImageImportEntry^.Name)));

      if Recursive then
        if Pos(LowerCase(Module), HookedModules) = 0 then
        begin
          //Writes the redirection of API
          HookedModules := HookedModules + LowerCase(Module);
          ModuleHandle := GetModuleHandle(PWideChar(Module));
          if (ModuleHandle > 0) and (ImageDosHeader <> Pointer(ModuleHandle)) then
            HookModule(Pointer(ModuleHandle), TargetAddress, NewAddress, OldAddress);
        end;

      //Sets the Address of the Table?
      ImportCode := Pointer(NativeUInt(ImageDosHeader) + ImageImportEntry.LookupTable);

                                      //TODO: remove magic constant
      while (ImportCode^ <> nil) and (NativeUInt(ImportCode^) > 4) do
      begin
        Address := GetActualAddr(ImportCode^);
        //checks address and writes our one!
        if Address = OldAddress then
        begin
          if VirtualProtect(ImportCode, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, OldProtect) then
          begin
            if WriteProcessMemory(GetCurrentProcess, ImportCode, @NewAddress, SizeOf(Pointer), BytesWritten) then
            begin
              //x64_test CloseHandle(FileCreate('d:\dbg\' + IntToStr(NativeUInt(ImportCode))));
              VirtualProtect(ImportCode, SizeOf(Pointer), OldProtect, @OldProtect);
              FlushInstructionCache(GetCurrentProcess, ImportCode, SizeOf(Pointer));
              Inc(Result);
            end;
          end;
        end;

        //increment the importcode until it finds the correct address
        Inc(ImportCode);
      end;

      //keep stepping thru each API Header
      Inc(ImageImportEntry);
    end;
  end;

begin
  Result := 0;
  if PEModule > 0 then
    Result := HookModule(Pointer(PEModule), TargetAddress, NewAddress, OldAddress);
end;

function UnhookCode(PEModule: HModule; Recursive: Boolean; NewAddress, OldAddress: Pointer): Integer;
begin
  Result := HookCode(PEModule, Recursive, NewAddress, OldAddress, NewAddress);
end;

end.
