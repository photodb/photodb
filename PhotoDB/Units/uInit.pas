unit uInit;

interface

uses
  Windows;

implementation

initialization

  SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  SetThreadPriority(MainThreadID, THREAD_PRIORITY_TIME_CRITICAL);

finalization

end.
