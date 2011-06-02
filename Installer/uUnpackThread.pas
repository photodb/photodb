unit uUnpackThread;

interface

uses
  Classes,
  Windows,
  SysUtils,
  ShellApi,
  uUnpackUtils,
  uUserUtils,
  ZLib;

type
  TUnpackThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

{ TUnpackThread }

procedure TUnpackThread.Execute;
var
  MS: TMemoryStream;
  DS: TDecompressionStream;
  FS: TFileStream;
  ExeFileName: string;
  Size: Int64;
begin
  inherited;
  FreeOnTerminate := True;
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream('SETUP_DATA', MS);
    MS.Read(Size, SizeOf(Size));
    DS := TDecompressionStream.Create(MS);
    try
      ExeFileName := GetTempFileName + '.exe';
      FS := TFileStream.Create(ExeFileName, fmCreate);
      try
        FS.CopyFrom(DS, Size);
      finally
        FS.Free;
      end;
      UserAccountService(ExeFileName);
    finally
      DS.Free;
    end;
  finally
    MS.Free;
  end;
end;

end.
