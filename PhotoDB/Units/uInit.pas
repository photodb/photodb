unit uInit;

interface

uses
  Windows, uRuntime, SysUtils;

implementation

initialization

  SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  SetThreadPriority(MainThreadID, THREAD_PRIORITY_TIME_CRITICAL);
  FolderView := FileExists(ExtractFilePath(ParamStr(0)) + ChangeFileExt(ExtractFileName(ParamStr(0)), '.photodb'));

finalization

end.
