unit uInit;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  uRuntime;

implementation

initialization
  if ProcessorCount > 1 then
    SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  SetThreadPriority(MainThreadID, THREAD_PRIORITY_ABOVE_NORMAL);
  FolderView := FileExists(ExtractFilePath(ParamStr(0)) + ChangeFileExt(ExtractFileName(ParamStr(0)), '.photodb'));

finalization

end.
