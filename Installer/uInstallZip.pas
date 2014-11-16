unit uInstallZip;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.Math,
  System.Zlib,
  System.Classes,
  System.SysUtils,
  uInstallTypes,
  uMemory;

function AddStringToStream(Stream: TStream; S: string; FileName: string): Boolean;
function AddFileToStream(Stream: TStream; FileName: string): Boolean;
function AddStreamToStream(Stream: TStream; StreamToAdd: TStream; FileName: string): Boolean;
function ExtractStreamFromStorage(Src: TStream; Dest: TStream; FileName: string;
  CallBack: TExtractFileCallBack): Boolean;
function ExtractFileFromStorage(Src: TStream; FileName: string; CallBack: TExtractFileCallBack): Boolean;
function AddDirectoryToStream(Src: TStream; DirectoryName: string; Recursive: Boolean = False): Boolean;
function ExtractDirectoryFromStorage(Src: TStream; DirectoryPath: string; CallBack: TExtractFileCallBack): Boolean;
procedure FillFileList(Src: TStream; FileList: TStrings; out OriginalFilesSize: Int64);
function ReadFileContent(Src: TStream; FileName: string): string;
function ExtractFileEntry(Src: TStream; FileName: string; var Entry: TZipEntryHeader): Boolean;
function GetObjectSize(Src: TStream; FileName: string): Int64;

implementation

procedure FillFileName(var Header: TZipEntryHeader; FileName: string);
var
  I: Integer;
begin
  FileName := ExtractFileName(FileName);
  if Length(FileName) > MaxFileNameLength then
    raise Exception.Create('FileName is too long!');

  Header.FileNameLength := Length(FileName);
  for I := 0 to Min(MaxFileNameLength, Length(FileName) - 1) do
    Header.FileName[I] := FileName[I + 1];
end;

function ExtractFileNameFromHeader(Header: TZipEntryHeader): string;
var
  I: Integer;
begin
  SetLength(Result, Header.FileNameLength);
  for I := 0 to Header.FileNameLength - 1 do
    Result[I + 1] := Header.FileName[I];
end;

function AddStringToStream(Stream: TStream; S: string; FileName: string): Boolean;
var
  MS: TMemoryStream;
  SW: TStreamWriter;
begin
  MS := TMemoryStream.Create;
  try
    SW := TStreamWriter.Create(MS, TEncoding.UTF8);
    try
      SW.Write(S);
      MS.Seek(0, soFromBeginning);
      Result := AddStreamToStream(Stream, MS, FileName);
    finally
      F(SW);
    end;
  finally
    F(MS);
  end;
end;

function AddStreamToStream(Stream: TStream; StreamToAdd: TStream; FileName: string): Boolean;
var
  MS: TMemoryStream;
  Compression: TCompressionStream;
  EntryHeader: TZipEntryHeader;
begin
  MS := TMemoryStream.Create;
  try
    Compression := TCompressionStream.Create(clMax, MS);
    try
      StreamToAdd.Seek(0, soFromBeginning);
      Compression.CopyFrom(StreamToAdd, StreamToAdd.Size);
      F(Compression);

      FillChar(EntryHeader, SizeOf(EntryHeader), #0);
      FillFileName(EntryHeader, FileName);
      EntryHeader.FileOriginalSize := StreamToAdd.Size;
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
  Result := True;
end;

function AddFileToStream(Stream: TStream; FileName: string): Boolean;
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := AddStreamToStream(Stream, FS, FileName);
  finally
    F(FS);
  end;
end;

function ExtractFileFromStorage(Src: TStream; FileName: string; CallBack: TExtractFileCallBack): Boolean;
var
  FS: TFileStream;
  DirectoryName: string;
begin
  Result := True;
  DirectoryName := ExtractFileDir(FileName);
  CreateDir(DirectoryName);
  FS := TFileStream.Create(FileName, fmCreate);
  try
    ExtractStreamFromStorage(Src, FS, ExtractFileName(FileName), CallBack);
  finally
    F(FS);
  end;
end;

function ExtractStreamFromStorage(Src: TStream; Dest: TStream; FileName: string;
  CallBack: TExtractFileCallBack): Boolean;
var
  EntryHeader: TZipEntryHeader;
  Decompression: TDecompressionStream;
  SizeToCopy, CopyedSize: Integer;
  Terminated: Boolean;
begin
  Result := False;
  Src.Seek(0, SoFromBeginning);
  CopyedSize := 0;
  Terminated := False;

  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    try
      if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(FileName) then
      begin
        Decompression := TDecompressionStream.Create(Src);
        try
          while CopyedSize < EntryHeader.FileOriginalSize do
          begin
            SizeToCopy := Min(EntryHeader.FileOriginalSize - CopyedSize, ReadBufferSize);
            Dest.CopyFrom(Decompression, SizeToCopy);
            Inc(CopyedSize, SizeToCopy);
            if Assigned(CallBack) then
              CallBack(CopyedSize, EntryHeader.FileOriginalSize, Terminated);

            if Terminated then
              Exit;
          end;
        finally
          F(Decompression);
        end;
        Result := True;
        Exit;
      end;

    finally
      Src.Seek(EntryHeader.FileCompressedSize, TSeekOrigin.soCurrent);
    end;
  end;
end;

procedure FillDirectoryListing(DirectoryName: string; Files: TStrings; var TotalSize: Int64; Recursive: Boolean = False);
var
  Found: Integer;
  SearchRec: TSearchRec;
  Attr: Integer;
begin
  DirectoryName := IncludeTrailingBackslash(DirectoryName);

  Attr :=  FaAnyFile - faHidden;
  if not Recursive then
    Attr := Attr - faDirectory;

  Found := FindFirst(DirectoryName + '*.*', Attr, SearchRec);
  while Found = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    begin
      if SearchRec.Attr and faDirectory = 0 then
      begin
        Files.Add(DirectoryName + SearchRec.Name);
        Inc(TotalSize, SearchRec.Size);
      end else
        //FillDirectoryListing(DirectoryName + SearchRec.Name, Files, TotalSize, Recursive);
    end;

    Found := System.SysUtils.FindNext(SearchRec);
  end;
  System.SysUtils.FindClose(SearchRec);
end;

function AddDirectoryToStream(Src: TStream; DirectoryName: string; Recursive: Boolean = False): Boolean;
var
  Files: TStrings;
  I: Integer;
  EntryHeader: TZipEntryHeader;
  TotalSize: Int64;
begin
  Result := True;
  TotalSize := 0;
  Files := TStringList.Create;
  try
    DirectoryName := IncludeTrailingBackslash(DirectoryName);

    FillDirectoryListing(DirectoryName, Files, TotalSize, Recursive);

    FillChar(EntryHeader, SizeOf(EntryHeader), #0);
    FillFileName(EntryHeader, ExcludeTrailingBackslash(DirectoryName));
    EntryHeader.FileOriginalSize := TotalSize;
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

function ExtractDirectoryFromStorage(Src: TStream; DirectoryPath: string; CallBack: TExtractFileCallBack): Boolean;
var
  I: Integer;
  EntryHeader: TZipEntryHeader;
  Decompression: TDecompressionStream;
  Dest: TFileStream;
  DirectoryName: string;
  FDoneBytes, FTotalBytes: Int64;
  Terminate: Boolean;
begin
  Result := False;
  Terminate := False;
  FDoneBytes := 0;
  Src.Seek(0, soFromBeginning);
  DirectoryPath := IncludeTrailingBackslash(DirectoryPath);
  DirectoryName := ExtractFileName(ExcludeTrailingBackslash(DirectoryPath));
  CreateDir(DirectoryPath);

  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    try
      if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(DirectoryName) then
      begin
        FTotalBytes := EntryHeader.FileOriginalSize;
        for I := 1 to EntryHeader.ChildsCount do
        begin
          Src.Read(EntryHeader, SizeOf(EntryHeader));
          Decompression := TDecompressionStream.Create(Src);
          try
            Dest := TFileStream.Create(DirectoryPath + ExtractFileNameFromHeader(EntryHeader), fmCreate);
            try
              Dest.CopyFrom(Decompression, EntryHeader.FileOriginalSize);
              Inc(FDoneBytes, Dest.Size);

              if Assigned(CallBack) then
                CallBack(FDoneBytes, FTotalBytes, Terminate);

              if Terminate then
                Exit;
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
      Src.Seek(EntryHeader.FileCompressedSize, TSeekOrigin.soCurrent);
    end;
  end;
end;

procedure FillFileList(Src: TStream; FileList: TStrings; out OriginalFilesSize: Int64);
var
  EntryHeader: TZipEntryHeader;
begin
  OriginalFilesSize := 0;
  Src.Seek(0, soFromBeginning);
  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    if not EntryHeader.IsDirectory then
    begin
      FileList.Add(ExtractFileNameFromHeader(EntryHeader));
      Inc(OriginalFilesSize, EntryHeader.FileOriginalSize);
    end;
    Src.Seek(EntryHeader.FileCompressedSize, TSeekOrigin.soCurrent);
  end;
end;

function ReadFileContent(Src: TStream; FileName: string): string;
var
  MS: TMemoryStream;
  SR: TStreamReader;
begin
  Result := '';
  MS := TMemoryStream.Create;
  try
    if ExtractStreamFromStorage(Src, MS, FileName, nil) then
    begin
      if MS.Size > 0 then
      begin
        MS.Seek(0, soFromBeginning);
        SR := TStreamReader.Create(MS);
        try
          Result := SR.ReadToEnd;
        finally
          F(SR);
        end;
      end;
    end;
  finally
    F(MS);
  end;
end;

function ExtractFileEntry(Src: TStream; FileName: string; var Entry: TZipEntryHeader): Boolean;
begin
  Result := False;
  Src.Seek(0, soFromBeginning);
  while Src.Read(Entry, SizeOf(Entry)) = SizeOf(Entry) do
  begin
    if AnsiLowerCase(ExtractFileNameFromHeader(Entry)) = AnsiLowerCase(FileName) then
    begin
      Result := True;
      Exit;
    end;
    Src.Seek(Entry.FileCompressedSize, TSeekOrigin.soCurrent);
  end;
end;

function GetObjectSize(Src: TStream; FileName: string): Int64;
var
  EntryHeader: TZipEntryHeader;
  I: Integer;
begin
  Result := 0;
  Src.Seek(0, soFromBeginning);
  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(FileName) then
    begin
      if not EntryHeader.IsDirectory then
        Result := EntryHeader.FileOriginalSize
      else
      begin
        for I := 1 to EntryHeader.ChildsCount do
        begin
          Src.Read(EntryHeader, SizeOf(EntryHeader));
          Inc(Result, EntryHeader.FileOriginalSize);
          Src.Seek(EntryHeader.FileCompressedSize, TSeekOrigin.soCurrent);
        end;
      end;
      Exit;
    end;
    Src.Seek(EntryHeader.FileCompressedSize, TSeekOrigin.soCurrent);
  end;
end;

end.
