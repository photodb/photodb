unit uRuntime;

interface

const
  DBInDebug = True;
  Emulation = False;
  UseSimpleSelectFolderDialog = False;

var
  PortableWork : Boolean = False;
  FolderView: Boolean = False;
  LastInseredID: Integer = 0;
  DBTerminating: Boolean = False;

var
  // Image sizes
  // In FormManager this sizes loaded from DB
  DBJpegCompressionQuality: Integer = 75;
  ThSize: Integer = 152;
  ThSizeExplorerPreview: Integer = 100;
  ThSizePropertyPreview: Integer = 100;
  ThSizePanelPreview: Integer = 75;
  ThImageSize: Integer = 150;
  ThHintSize: Integer = 300;

implementation

end.
