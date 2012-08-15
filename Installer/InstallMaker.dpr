program InstallMaker;

{$WARN SYMBOL_PLATFORM OFF}

uses
  Classes,
  SysUtils,
  Zlib,
  uSysUtils,
  uInstallTypes in 'uInstallTypes.pas',
  acWorkRes in '..\PhotoDB\Units\acWorkRes.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uInstallScope in 'uInstallScope.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uInstallZip in 'uInstallZip.pas',
  uAppUtils in '..\PhotoDB\Units\uAppUtils.pas',
  uDBBaseTypes in '..\PhotoDB\Units\uDBBaseTypes.pas';

{$R ..\PhotoDB\Resources\PhotoDBInstall.res}

var
  FileName: string;
  FS: TFileStream;
  I: Integer;
  DiskObject: TDiskObject;

  procedure AddFile(FileRelativePath: string);
  var
    FileName : string;
  begin
    FileName := IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + FileRelativePath;
    AddFileToStream(FS, FileName);
  end;

  procedure AddDirectory(DirectoryRelativePath: string; Recursive: Boolean = False);
  var
    DirectoryName : string;
  begin
    DirectoryName := IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + DirectoryRelativePath;
    AddDirectoryToStream(FS, DirectoryName, Recursive);
  end;

  procedure PackZip(S, D: string);
  var
    MS: TMemoryStream;
    FS,
    FD: TFileStream;
    Size: Int64;
    Compression : TCompressionStream;
  begin
    FS := TFileStream.Create(S, fmOpenRead or fmShareDenyWrite);
    try
      MS := TMemoryStream.Create;
      try
        Size := FS.Size;
        MS.Write(Size, SizeOf(Size));
        Compression := TCompressionStream.Create(clMax, MS);
        try
          FS.Seek(0, soFromBeginning);
          Compression.CopyFrom(FS, FS.Size);
          F(Compression);
          FD := TFileStream.Create(D, fmCreate);
          try
            MS.Seek(0, soFromBeginning);
            FD.CopyFrom(MS, MS.Size);
          finally
            F(FD);
          end;
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

begin
  if GetParamStrDBBool('/setup') then
  begin
    FileName := IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + GetParamStrDBValue('/setup');
    PackZip(FileName, FileName + '.zip');
  end else
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
          AddDirectory('..\PhotoDB\bin\' + DiskObject.Name, TDirectoryObject(DiskObject).IsRecursive);
      end;
      AddStringToStream(FS, ReleaseToString(GetExeVersion(IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + '..\PhotoDB\bin\PhotoDB.exe')), 'VERSION.INFO');
    finally
      F(FS);
    end;
  end;
end.
