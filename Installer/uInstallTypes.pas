unit uInstallTypes;

interface

uses Zlib, Windows, Classes, SysUtils, uMemory;

const
  MaxFileNameLength = 255;

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

function AddFileToStream(Stream : TStream; FileName : string) : Boolean;
function ExtractFileFromStorage(Src : TStream; Dest : TStream; FileName : string) : Boolean; overload;
function ExtractFileFromStorage(Src : TStream; FileName : string) : Boolean; overload;
function AddDirectoryToStream(Src : TStream; DirectoryName : string) : Boolean;
function ExtractDirectoryFromStorage(Src : TStream; DirectoryPath : string) : Boolean;

implementation

procedure FillFileName(var Header : TZipEntryHeader; FileName : string);
var
  I : Integer;
begin
  FileName := ExtractFileName(FileName);
  if Length(FileName) > MaxFileNameLength then
    raise Exception.Create('FileName is too long!');

  Header.FileNameLength := Length(FileName);
  for I := 0 to MaxFileNameLength do
    Header.FileName[I] := FileName[I + 1];
end;

function ExtractFileNameFromHeader(Header : TZipEntryHeader) : string;
var
  I : Integer;
begin
  SetLength(Result, Header.FileNameLength);
  for I := 0 to Header.FileNameLength - 1 do
    Result[I + 1] := Header.FileName[I];
end;

function AddFileToStream(Stream : TStream; FileName : string) : Boolean;
var
  FS : TFileStream;
  MS : TmemoryStream;
  Compression : TCompressionStream;
  EntryHeader : TZipEntryHeader;
begin
  Result := True;
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    MS := TMemoryStream.Create;
    try
      Compression := TCompressionStream.Create(clMax, MS);
      try
        FS.Seek(0, soFromBeginning);
        Compression.CopyFrom(FS, FS.Size);
        F(Compression);

        FillChar(EntryHeader, SizeOf(EntryHeader), #0);
        FillFileName(EntryHeader, FileName);
        EntryHeader.FileOriginalSize := FS.Size;
        EntryHeader.FileCompressedSize := MS.Size;
        EntryHeader.IsDirectory := False;
        EntryHeader.ChildsCount := 0;
        Stream.Write(EntryHeader, SizeOf(EntryHeader));

        MS.Seek(0, soFromBeginning);
        Stream.CopyFrom(MS, MS.Size);
      finally
        F(Compression);
      end;
    finally
      F(MS);
    end;
  finally
    F(FS);
  end;
end;

function ExtractFileFromStorage(Src : TStream; FileName : string) : Boolean; overload;
var
  FS : TFileStream;
begin
  FS := TFileStream.Create(FileName, fmCreate);
  try
    ExtractFileFromStorage(Src, FS, ExtractFileName(FileName));
  finally
    F(FS);
  end;
end;

function ExtractFileFromStorage(Src : TStream; Dest : TStream; FileName : string) : Boolean;
var
  EntryHeader : TZipEntryHeader;
  Decompression : TDecompressionStream;
begin
  Result := False;
  Src.Seek(0, soFromBeginning);

  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    try
      if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(FileName) then
      begin
        Decompression := TDecompressionStream.Create(Src);
        try
          Dest.CopyFrom(Decompression, EntryHeader.FileOriginalSize );
        finally
          F(Decompression);
        end;
        Result := True;
        Exit;
      end;

    finally
      Src.Seek(EntryHeader.FileCompressedSize, soFromCurrent);
    end;
  end;
end;

function AddDirectoryToStream(Src : TStream; DirectoryName : string) : Boolean;
var
  Files : TStrings;
  I, Found : Integer;
  SearchRec: TSearchRec;
  EntryHeader : TZipEntryHeader;
begin
  Files := TStringList.Create;
  DirectoryName := IncludeTrailingBackslash(DirectoryName);
  try
    Found := FindFirst(DirectoryName + '*.*', FaAnyFile - faDirectory - faHidden, SearchRec);
    while Found = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        Files.Add(DirectoryName + SearchRec.Name);

      Found := SysUtils.FindNext(SearchRec);
    end;
    FindClose(SearchRec);

    FillChar(EntryHeader, SizeOf(EntryHeader), #0);
    FillFileName(EntryHeader, ExcludeTrailingBackslash(DirectoryName));
    EntryHeader.FileOriginalSize := 0;
    EntryHeader.FileCompressedSize := 0;
    EntryHeader.IsDirectory := True;
    EntryHeader.ChildsCount := Files.Count;
    Src.Write(EntryHeader, SizeOf(EntryHeader));

    for I := 0 to Files.Count - 1 do
      AddFileToStream(Src, Files[I]);

  finally
    F(Files);
  end;
end;

function ExtractDirectoryFromStorage(Src : TStream; DirectoryPath : string) : Boolean;
var
  I : Integer;
  EntryHeader : TZipEntryHeader;
  Decompression : TDecompressionStream;
  Dest : TFileStream;
  DirectoryName : string;
begin
  Result := False;
  Src.Seek(0, soFromBeginning);
  DirectoryPath := IncludeTrailingBackslash(DirectoryPath);
  DirectoryName := ExtractFileName(ExcludeTrailingBackslash(DirectoryPath));

  CreateDir(DirectoryPath);

  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    try
      if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(DirectoryName) then
      begin
        for I := 1 to EntryHeader.ChildsCount do
        begin
          Src.Read(EntryHeader, SizeOf(EntryHeader));
          Decompression := TDecompressionStream.Create(Src);
          try
            Dest := TFileStream.Create(DirectoryPath + ExtractFileNameFromHeader(EntryHeader), fmCreate);
            try
              Dest.CopyFrom(Decompression, EntryHeader.FileOriginalSize);
            finally
              F(Dest);
            end;
          finally
            F(Decompression);
          end;
        end;
        Result := True;
        Exit;
      end;

    finally
      Src.Seek(EntryHeader.FileCompressedSize, soFromCurrent);
    end;
  end;
end;

end.
