program InstallMaker;

{$WARN SYMBOL_PLATFORM OFF}

uses
  Classes,
  SysUtils,
  Zlib,
  uInstallTypes in 'uInstallTypes.pas',
  acWorkRes in '..\PhotoDB\Units\acWorkRes.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uInstallScope in 'uInstallScope.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uInstallZip in 'uInstallZip.pas';

var
  FileName : string;
  FS : TFileStream;
  I : Integer;
  DiskObject : TDiskObject;

  procedure AddFile(FileRelativePath : string);
  var
    FileName : string;
  begin
    FileName := IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + FileRelativePath;
    AddFileToStream(FS, FileName);
  end;

  procedure AddDirectory(DirectoryRelativePath : string);
  var
    DirectoryName : string;
  begin
    DirectoryName := IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + DirectoryRelativePath;
    AddDirectoryToStream(FS, DirectoryName);
  end;

begin
  FileName := IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + ParamStr(1);
  FS := TFileStream.Create(FileName, fmCreate);
  try
    for I := 0 to CurrentInstall.Files.Count - 1 do
    begin
      DiskObject := CurrentInstall.Files[I];
      if DiskObject is TFileObject then
        AddFile('..\PhotoDB\bin\' + DiskObject.Name);
      if DiskObject is TDirectoryObject then
        AddDirectory('..\PhotoDB\bin\' + DiskObject.Name);
    end;
  finally
    F(FS);
  end;
end.
