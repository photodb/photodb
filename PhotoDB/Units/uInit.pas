unit uInit;

interface

uses
  Windows, uRuntime, SysUtils, uFileUtils;

implementation

initialization

  SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  SetThreadPriority(MainThreadID, THREAD_PRIORITY_TIME_CRITICAL);
  FolderView := True;//FileExistsSafe(ExtractFilePath(ParamStr(0)) + GetFileNameWithoutExt(ParamStr(0)) + '.photodb');

finalization

end.
