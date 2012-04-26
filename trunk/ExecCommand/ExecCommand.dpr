program ExecCommand;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Classes,
  ShellApi,
  ConsoleOoutput in 'ConsoleOoutput.pas';

var
  FS : TFileStream;
  SR : TStreamReader;
  Command : string;

begin
  try
    Writeln('File with instructions = ' + ParamStr(1));
    if not FileExists(ParamStr(1)) then
      Exit;

    FS := TFileStream.Create(ParamStr(1), fmOpenRead);
    try
      SR := TStreamReader.Create(FS);
      try
        Command := SR.ReadToEnd;
        Writeln('Command to execute: ' + Command);
        GetDosOutput(Command, ParamStr(1));
      finally
        SR.Close;
      end;
    finally
      FS.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
