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
  DBID : string = '{E1446065-CB87-440D-9315-6FA356F921B5}';

var
  // Image sizes
  // In FormManager this sizes loaded from DB
  DBJpegCompressionQuality: Integer = 75;
  ThSize: Integer = 152;
  ThSizeExplorerPreview: Integer = 100;
  ThSizePropertyPreview: Integer = 100;
  ThSizePanelPreview: Integer = 85;
  ThImageSize: Integer = 150;
  ThHintSize: Integer = 300;

implementation

end.
