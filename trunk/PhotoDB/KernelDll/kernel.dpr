library Kernel;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  win32crc in 'win32crc.pas',
  FileCRC in 'FileCRC.pas';

{$DEFINE RUS}

function ValidateApplication(S: PChar): Boolean;
var
  Tb: TInteger8;
  Er: Word;
  Crc: Cardinal;
  Str: string;
begin
  Str := Copy(S, 1, Length(S));
  CalcFileCRC32(S, Crc, Tb, Er);
  Result := Integer(Crc) = ProgramCRC;
end;

exports
  ValidateApplication name 'ValidateApplication';

begin
end.
