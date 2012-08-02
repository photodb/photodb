program PlayEncryptedMedia;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009+) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  Windows,
  uPlayEncryptedMedia in 'uPlayEncryptedMedia.pas';

{$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}

begin
  PlayMediaFromCommanLine;
end.
