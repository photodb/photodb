program InstallMaker;

uses
  Classes,
  SysUtils,
  Zlib,
  uInstallTypes in 'uInstallTypes.pas',
  acWorkRes in '..\PhotoDB\Units\acWorkRes.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas';

var
  FileName : string;
  FS : TFileStream;
  FD : TFileStream;

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
    AddFile('..\PhotoDB\bin\PhotoDB.exe');
    AddFile('..\PhotoDB\bin\Kernel.dll');
    AddFile('..\PhotoDB\bin\lpng-px.dll');
    AddFile('..\PhotoDB\bin\Icons.dll');
    AddFile('..\PhotoDB\bin\FreeImage.dll');
    {$IFDEF DBDEBUG}
    AddFile('..\PhotoDB\bin\FastMM_FullDebugMode.dll');
    {$ENDIF}
    AddDirectory('..\PhotoDB\bin\Actions');
    AddDirectory('..\PhotoDB\bin\Acripts');
    AddDirectory('..\PhotoDB\bin\Images');
    AddDirectory('..\PhotoDB\bin\Languages');
  finally
    F(FS);
  end;
end.
