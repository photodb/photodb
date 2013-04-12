unit uRuntime;

interface

uses
  Winapi.Windows,
  uConstants;

var
  PortableWork: Boolean = False;
  FolderView: Boolean = False;
  DBTerminating: Boolean = False;
  DBID: string = DB_ID;
  CMDInProgress: Boolean = False;
  ProgramVersionString: string = '';
  BlockClosingOfWindows: Boolean = False;
  UserDirectoryUpdaterCount: Integer = 0;

var
  ProcessorCount: Integer = 0;

implementation

function GettingProcNum: Integer;
var
  Struc: _SYSTEM_INFO;
begin
  GetSystemInfo(Struc);
  Result := Struc.DwNumberOfProcessors;
end;

initialization
  ProcessorCount := GettingProcNum;

end.
