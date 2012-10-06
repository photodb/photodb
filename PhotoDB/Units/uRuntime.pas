unit uRuntime;

interface

uses
  Winapi.Windows,
  uConstants;

const
  DBInDebug = True;
  Emulation = False;
  UseSimpleSelectFolderDialog = False;

var
   //TODO: delete it
   dbname: string = '';

var
  PortableWork: Boolean = False;
  FolderView: Boolean = False;
  LastInseredID: Integer = 0;
  DBTerminating: Boolean = False;
  DBID: string = DB_ID;
  CMDInProgress: Boolean = False;
  ProgramVersionString: string = '';
  BlockClosingOfWindows: Boolean = False;

var
  ProcessorCount: Integer = 0;

var
  // Image sizes
  // In FormManager this sizes loaded from DB
  DBJpegCompressionQuality: Integer = 75;
  ThSize: Integer = 202;
  ThSizeExplorerPreview: Integer = 100;
  ThSizePropertyPreview: Integer = 100;
  ThSizePanelPreview: Integer = 85;
  ThImageSize: Integer = 200;
  ThHintSize: Integer = 400;

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
