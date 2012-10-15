program CRCCalculator;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  win32crc in '..\KernelDll\win32crc.pas';

var
  CRCValue: Cardinal;
  TotalBytes: Comp;
  Error: Word;
  FS: TFileStream;
  SW: TStreamWriter;
  UnitName: string;

{$R *.res}

begin
  try
    CalcFileCRC32(ParamStr(1), CRCValue, TotalBytes, Error);
    FS := TFileStream.Create(ParamStr(2), fmCreate);
    try
      SW := TStreamWriter.Create(FS);
      try
        UnitName := ExtractFileName(ParamStr(2));
        UnitName := ChangeFileExt(UnitName, '');
        SW.Write(Format('Unit %s;', [UnitName]));
        SW.WriteLine;
        SW.Write('interface');
        SW.WriteLine;
        SW.Write('const');
        SW.WriteLine;
        SW.Write(Format('  ProgramCRC : Integer = $%s;', [IntToHex(CRCValue, 8)]));
        SW.WriteLine;
        SW.Write('implementation');
        SW.WriteLine;
        SW.Write('begin');
        SW.WriteLine;
        SW.Write('end.');
        Writeln(Format('Unit "%s" created! File CRC32 = %s', [UnitName, IntToHex(CRCValue, 8)]));
      finally
        SW.Free;
      end;
    finally
      FS.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
