program PhotoDBInstall;

uses
  Windows,
  Classes,
  SysUtils,
  ZLib,
  uUnpackUtils in 'uUnpackUtils.pas',
  uUserUtils in 'uUserUtils.pas',
  uAppUtils in '..\PhotoDB\Units\uAppUtils.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uIsAdmin in 'uIsAdmin.pas';

{$R PhotoDBInstall.res}
{$R Install_Package.RES}
{$R ..\PhotoDB\Resources\PhotoDBInstall.res}

var
  MS: TMemoryStream;
  DS: TDecompressionStream;
  FS: TFileStream;
  ExeFileName: string;
  Size: Int64;

begin
  try
    MS := TMemoryStream.Create;
    try
      GetRCDATAResourceStream('SETUP_DATA', MS);
      MS.Read(Size, SizeOf(Size));
      DS := TDecompressionStream.Create(MS);
      try
        ExeFileName := IncludeTrailingBackslash(GetTempDirectory) + ExtractFileName(ParamStr(0));
        DeleteFile(ExeFileName);

        if FileExists(ExeFileName) then
        begin
          MessageBox(0, PChar('Can''t delete old file: ' + ExeFileName), 'Error', MB_OK or MB_ICONERROR);
          Exit;
        end;

        FS := TFileStream.Create(ExeFileName, fmCreate);
        try
          FS.CopyFrom(DS, Size);
        finally
          F(FS);
        end;
        UserAccountService(ExeFileName, IsUserAnAdmin or IsWindowsAdmin);
      finally
        F(DS);
      end;
    finally
      F(MS);
    end;
  except
    on e: Exception do
      MessageBox(0, PChar(e.Message), 'Error', MB_OK or MB_ICONERROR);
  end;
end.
