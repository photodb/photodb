unit uInstallTypes;

interface

const
  MaxFileNameLength = 255;
  ReadBufferSize = 16 * 1024;

type
  TZipHeader = record
    CRC : Cardinal;
  end;

  TZipEntryHeader = record
    FileName : array[0..MaxFileNameLength] of Char;
    FileNameLength : Byte;
    FileOriginalSize : Int64;
    FileCompressedSize : Int64;
    IsDirectory : Boolean;
    ChildsCount : Integer;
  end;

  TExtractFileCallBack = procedure(BytesRead, BytesTotal : int64; var Terminate : Boolean) of object;

implementation


end.
