unit uRuntime;

interface

uses
  Winapi.Windows,
  uConstants;

var
   //TODO: delete it
   dbname: string = '';

var
  PortableWork: Boolean = False;
  FolderView: Boolean = False;
  DBTerminating: Boolean = False;
  DBID: string = DB_ID;
  CMDInProgress: Boolean = False;
  ProgramVersionString: string = '';
  BlockClosingOfWindows: Boolean = False;
  FExtImagesInImageList: Integer = 0;  //TODO: recheck usings
  UserDirectoryUpdaterCount: Integer = 0;

var
  ProcessorCount: Integer = 0;

var
  // Image sizes
  DBJpegCompressionQuality: Integer = 75;
  ThSize: Integer = 202;
  ThSizeExplorerPreview: Integer = 100;
  ThSizePropertyPreview: Integer = 100;
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
