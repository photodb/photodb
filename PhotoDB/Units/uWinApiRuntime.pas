unit uWinApiRuntime;

interface

uses
  Windows;

type
  NTStatus = CARDINAL;

PWSTR          = ^WCHAR;

PUnicodeString = ^TUnicodeString;
  TUnicodeString = record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
end;

type
  _FILE_INFORMATION_CLASS = (
// end_wdm
    FileEmpty,
    FileDirectoryInformation,       //= 1,
    FileFullDirectoryInformation,   // 2
    FileBothDirectoryInformation,   // 3
    FileBasicInformation,           // 4  wdm
    FileStandardInformation,        // 5  wdm
    FileInternalInformation,        // 6
    FileEaInformation,              // 7
    FileAccessInformation,          // 8
    FileNameInformation,            // 9
    FileRenameInformation,          // 10
    FileLinkInformation,            // 11
    FileNamesInformation,           // 12
    FileDispositionInformation,     // 13
    FilePositionInformation,        // 14 wdm
    FileFullEaInformation,          // 15
    FileModeInformation,            // 16
    FileAlignmentInformation,       // 17
    FileAllInformation,             // 18
    FileAllocationInformation,      // 19
    FileEndOfFileInformation,       // 20 wdm
    FileAlternateNameInformation,   // 21
    FileStreamInformation,          // 22
    FilePipeInformation,            // 23
    FilePipeLocalInformation,       // 24
    FilePipeRemoteInformation,      // 25
    FileMailslotQueryInformation,   // 26
    FileMailslotSetInformation,     // 27
    FileCompressionInformation,     // 28
    FileObjectIdInformation,        // 29
    FileCompletionInformation,      // 30
    FileMoveClusterInformation,     // 31
    FileQuotaInformation,           // 32
    FileReparsePointInformation,    // 33
    FileNetworkOpenInformation,     // 34
    FileAttributeTagInformation,    // 35
    FileTrackingInformation,        // 36
    FileIdBothDirectoryInformation, // 37
    FileIdFullDirectoryInformation, // 38
    FileMaximumInformation);
// begin_wdm
    FILE_INFORMATION_CLASS = _FILE_INFORMATION_CLASS;
    PFILE_INFORMATION_CLASS = ^FILE_INFORMATION_CLASS;

type
  FILE_DIRECTORY_INFORMATION = record
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    CreationTime,
    LastAccessTime,
    LastWriteTime,
    ChangeTime,
    EndOfFile,
    AllocationSize: int64;
    FileAttributes: ULONG;
    FileNameLength: ULONG;
    FileName: PWideChar;
 end;
 PFILE_DIRECTORY_INFORMATION = ^FILE_DIRECTORY_INFORMATION;

type
  FILE_FULL_DIRECTORY_INFORMATION = record
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    CreationTime,
    LastAccessTime,
    LastWriteTime,
    ChangeTime,
    EndOfFile,
    AllocationSize: Int64;
    FileAttributes: ULONG;
    FileNameLength: ULONG;
    EaInformationLength: ULONG;
    FileName: PWideChar;
 end;
 PFILE_FULL_DIRECTORY_INFORMATION = ^FILE_FULL_DIRECTORY_INFORMATION;

type
  FILE_BOTH_DIRECTORY_INFORMATION = record
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    CreationTime,
    LastAccessTime,
    LastWriteTime,
    ChangeTime,
    EndOfFile,
    AllocationSize: Int64;
    FileAttributes: ULONG;
    FileNameLength: ULONG;
    EaInformationLength: ULONG;
    AlternateNameLength: ULONG;
    AlternateName: array[0..11] of WideChar;
    FileName: PWideChar;
 end;
 PFILE_BOTH_DIRECTORY_INFORMATION = ^FILE_BOTH_DIRECTORY_INFORMATION;

type
  FILE_NAMES_INFORMATION = record
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    FileNameLength: ULONG;
    FileName: PWideChar;
 end;

type
  HANDLE = THandle;

  { .: LARGE_INTEGER :. }
  _LARGE_INTEGER = record
    case Integer of
      0: (LowPart: DWORD;
          HighPart: LONG);
      1: (QuadPart: LONGLONG);
  end;
  LARGE_INTEGER = _LARGE_INTEGER;
  PLARGE_INTEGER = ^LARGE_INTEGER;

  { .: IO_STATUS_BLOCK :. }
  _IO_STATUS_BLOCK = record
    Status: NTSTATUS;
    Information: ULONG_PTR;
  end;
  IO_STATUS_BLOCK = _IO_STATUS_BLOCK;
  PIO_STATUS_BLOCK = ^IO_STATUS_BLOCK;

  { .: OBJECT_ATTRIBUTES :. }
  _OBJECT_ATTRIBUTES = record
    Length: ULONG;
    RootDirectory: HANDLE;
    ObjectName: PUnicodeString;
    Attributes: ULONG;
    SecurityDescriptor: PVOID;
    SecurityQualityOfService: PVOID;
  end;
  OBJECT_ATTRIBUTES = _OBJECT_ATTRIBUTES;
  POBJECT_ATTRIBUTES = ^OBJECT_ATTRIBUTES;

  PIO_APC_ROUTINE = procedure (ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Reserved: ULONG); stdcall;

type
  TSetFilePointerNextHook   = function (hFile: THandle; lDistanceToMove: DWORD;
                                        lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
  TSetFilePointerExNextHook = function (hFile: THandle; liDistanceToMove: TLargeInteger;
                                        const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD): BOOL; stdcall;

var
  CreateProcessANextHook     : function (appName, cmdLine: pchar; processAttr, threadAttr: PSecurityAttributes; inheritHandles: bool; creationFlags: dword; environment: pointer; currentDir: pchar; const startupInfo: TStartupInfo; var processInfo: TProcessInformation) : bool; stdcall;
  CreateProcessWNextHook     : function (appName, cmdLine: pwidechar; processAttr, threadAttr: PSecurityAttributes; inheritHandles: bool; creationFlags: dword; environment: pointer; currentDir: pwidechar; const startupInfo: TStartupInfo; var processInfo: TProcessInformation) : bool; stdcall;

  SetFilePointerNextHook     : TSetFilePointerNextHook;
  SetFilePointerExNextHook   : TSetFilePointerExNextHook;

  OpenFileNextHook           : function (const lpFileName: LPCSTR; var lpReOpenBuff: TOFStruct; uStyle: UINT): HFILE; stdcall;

  CreateFileANextHook        : function (lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
  CreateFileWNextHook        : function (lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
  CloseHandleNextHook        : function (hObject: THandle): BOOL; stdcall;

  LoadLibraryANextHook       : function (lpLibFileName: PAnsiChar): HMODULE; stdcall;
  LoadLibraryWNextHook       : function (lpLibFileName: PWideChar): HMODULE; stdcall;

  LoadLibraryExANextHook     : function (lpLibFileName: PAnsiChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
  LoadLibraryExWNextHook     : function (lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;

  GetProcAddressNextHook     : function (hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;

  ReadFileNextHook           : function (hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD; lpNumberOfBytesRead: PDWORD; lpOverlapped: POverlapped): BOOL; stdcall;
  ReadFileExNextHook         : function (hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToRead: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: TPROverlappedCompletionRoutine): BOOL; stdcall;

  _lReadNextHook             : function(hFile: HFILE; lpBuffer: Pointer; uBytes: UINT): UINT; stdcall;
  _lOpenNextHook             : function (const lpPathName: LPCSTR; iReadWrite: Integer): HFILE; stdcall;
  _lCreatNextHook            : function (const lpPathName: LPCSTR; iAttribute: Integer): HFILE; stdcall;

  CreateFileMappingANextHook : function(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
                                        flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PAnsiChar): THandle; stdcall;
  CreateFileMappingWNextHook : function(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
                                        flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PWideChar): THandle; stdcall;

  MapViewOfFileNextHook      : function (hFileMappingObject: THandle; dwDesiredAccess: DWORD;
                                         dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T): Pointer; stdcall;

  MapViewOfFileExNextHook    : function (hFileMappingObject: THandle; dwDesiredAccess,
                                         dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T; lpBaseAddress: Pointer): Pointer; stdcall;

  UnmapViewOfFileNextHook    : function (lpBaseAddress: Pointer): BOOL; stdcall;

  GetFileSizeNextHook        : function (hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall;
  GetFileSizeExNextHook      : function (hFile: THandle; var lpFileSize: Int64): BOOL; stdcall;

  FindFirstFileANextHook     : function (lpFileName: PAnsiChar; var lpFindFileData: TWIN32FindDataA): THandle; stdcall;
  FindFirstFileWNextHook     : function (lpFileName: PWideChar; var lpFindFileData: TWIN32FindDataW): THandle; stdcall;


  GetFileAttributesExANextHook: function (lpFileName: PAnsiChar; fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
  GetFileAttributesExWNextHook: function (lpFileName: PWideChar; fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;


  DuplicateHandleNextHook    : function (hSourceProcessHandle, hSourceHandle, hTargetProcessHandle: THandle;
                                          lpTargetHandle: PHandle; dwDesiredAccess: DWORD;
                                          bInheritHandle: BOOL; dwOptions: DWORD): BOOL; stdcall;

  LdrLoadDllNextHook         : function (szcwPath: PWideChar;
                                          pdwLdrErr: PULONG;
                                          pUniModuleName: PUnicodeString;
                                          pResultInstance: PHandle): NTSTATUS; stdcall;

  NtCreateFileNextHook       : function (FileHandle: PHANDLE; DesiredAccess: ACCESS_MASK;
                                        ObjectAttributes: POBJECT_ATTRIBUTES; IoStatusBlock: PIO_STATUS_BLOCK;
                                        AllocationSize: PLARGE_INTEGER; FileAttributes: ULONG; ShareAccess: ULONG;
                                        CreateDisposition: ULONG; CreateOptions: ULONG; EaBuffer: PVOID;
                                        EaLength: ULONG): NTSTATUS; stdcall;

  NtQueryDirectoryFileNextHook : function(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID;
                                          IoStatusBlock: PIO_STATUS_BLOCK; FileInformation: PVOID; FileInformationLength: ULONG;
                                          FileInformationClass: FILE_INFORMATION_CLASS; ReturnSingleEntry: ByteBool; FileName: PUnicodeString;
                                          RestartScan: ByteBool): NTSTATUS; stdcall;


  NtQueryInformationFileNextHook : function(FileHandle: HANDLE;
                                IoStatusBlock: PIO_STATUS_BLOCK;
                                FileInformation: PVOID;
                                FileInformationLength: ULONG;
                                FileInformationClass: FILE_INFORMATION_CLASS
                                ): NTSTATUS; stdcall;

implementation

initialization
  CreateProcessANextHook     := nil;
  CreateProcessWNextHook     := nil;

  SetFilePointerNextHook     := nil;
  SetFilePointerExNextHook   := nil;

  OpenFileNextHook           := nil;

  CreateFileANextHook        := nil;
  CreateFileWNextHook        := nil;
  CloseHandleNextHook        := nil;

  LoadLibraryANextHook       := nil;
  LoadLibraryWNextHook       := nil;

  LoadLibraryExANextHook     := nil;
  LoadLibraryExWNextHook     := nil;

  GetProcAddressNextHook     := nil;

  ReadFileNextHook           := nil;
  ReadFileExNextHook         := nil;

  _lReadNextHook             := nil;
  _lOpenNextHook             := nil;
  _lCreatNextHook            := nil;

  CreateFileMappingANextHook     := nil;

  CreateFileMappingWNextHook     := nil;

  MapViewOfFileNextHook          := nil;

  MapViewOfFileExNextHook        := nil;

  UnmapViewOfFileNextHook        := nil;

  GetFileSizeNextHook            := nil;
  GetFileSizeExNextHook          := nil;

  FindFirstFileANextHook         := nil;
  FindFirstFileWNextHook         := nil;


  GetFileAttributesExANextHook   := nil;
  GetFileAttributesExWNextHook   := nil;


  DuplicateHandleNextHook        := nil;
  LdrLoadDllNextHook             := nil;
  NtCreateFileNextHook           := nil;
  NtQueryDirectoryFileNextHook   := nil;
  NtQueryInformationFileNextHook := nil;

end.
