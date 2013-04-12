program PhotoDBInstall;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$SetPEFlags 1}// 1 = Windows.IMAGE_FILE_RELOCS_STRIPPED

uses
  Windows,
  Classes,
  SysUtils,
  ZLib,
  uUnpackUtils in 'uUnpackUtils.pas',
  uUserUtils in 'uUserUtils.pas',
  uAppUtils in '..\PhotoDB\Units\Utils\uAppUtils.pas',
  uMemory in '..\PhotoDB\Units\System\uMemory.pas',
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
  Mutex: Integer;

function InitMutex(mid: string): Boolean;
begin
  Mutex := CreateMutex(nil, False, PChar(mid));
  Result := not ((Mutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS));
end;

begin
  //do not allow 2 copies of application
  if not InitMutex('{E8A4BE80-FF59-4742-AFA0-F6CC300F53A8}') then
    Exit;

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
  if Mutex <> 0 then
    CloseHandle(Mutex);
end.
