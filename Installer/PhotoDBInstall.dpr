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
  uIsAdmin in 'uIsAdmin.pas',
  uDecompressionProgressWindow in 'uDecompressionProgressWindow.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas';

{$R PhotoDBInstall.res}
{$R Install_Package.RES}
{$R ..\PhotoDB\Resources\PhotoDBInstall.res}

var
  MS: TMemoryStream;
  DS: TDecompressionStream;
  FS: TFileStream;
  ExeFileName: string;
  OriginalSize, FileSize: Int64;
  Mutex: Integer;

type
  TStreamHelper = class helper for TStream
  public
    function CopyFromEx(Source: TStream; Count: Int64; MaxBufSize: Integer; Progress: TProgressProc): Int64;
  end;

function TStreamHelper.CopyFromEx(Source: TStream; Count: Int64; MaxBufSize: Integer; Progress: TProgressProc): Int64;
var
  BufSize, N: Integer;
  Buffer: PByte;
  IsBreak: Boolean;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  IsBreak := False;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      WriteBuffer(Buffer^, N);
      Dec(Count, N);

      if Assigned(Progress) then
        Progress(Result, Size, IsBreak);

      if IsBreak then
        Break;
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;

function InitMutex(mid: string): Boolean;
begin
  Mutex := CreateMutex(nil, False, PChar(mid));
  Result := not ((Mutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS));
end;

begin
  //do not allow 2 copies of application
  if not InitMutex('{E8A4BE80-FF59-4742-AFA0-F6CC300F53A8}') then
    Exit;

  CreateProgressWindow;
  try
    MS := TMemoryStream.Create;
    try

      GetRCDATAResourceStream('SETUP_DATA', MS,
        procedure(BytesTotal, BytesComplete: Int64; var Break: Boolean)
        begin
          Break := not SetProgressPos(50 * BytesComplete div BytesTotal);
        end
      );

      MS.Read(OriginalSize, SizeOf(OriginalSize));
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
          FS.CopyFromEx(DS, OriginalSize, 100 * 1024,
            procedure(BytesTotal, BytesComplete: Int64; var Break: Boolean)
            begin
              Break := not SetProgressPos(50 + 50 * FS.Size div OriginalSize);
            end
          );
          FileSize := FS.Size;
        finally
          F(FS);
        end;

        CloseProgress;
        if FileSize = OriginalSize then
          UserAccountService(ExeFileName, IsUserAnAdmin or IsWindowsAdmin)
        else
          DeleteFile(ExeFileName);

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
  CloseProgress;
  if Mutex <> 0 then
    CloseHandle(Mutex);
end.
