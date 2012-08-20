library TransparentEncryption;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009+) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Winapi.Windows,
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  DECCipher in '..\PhotoDB\External\Crypt\DECv5.2\DECCipher.pas',
  DECUtil in '..\PhotoDB\External\Crypt\DECv5.2\DECUtil.pas',
  DECFmt in '..\PhotoDB\External\Crypt\DECv5.2\DECFmt.pas',
  DECData in '..\PhotoDB\External\Crypt\DECv5.2\DECData.pas',
  uStrongCrypt in '..\PhotoDB\Units\uStrongCrypt.pas',
  DECHash in '..\PhotoDB\External\Crypt\DECv5.2\DECHash.pas',
  DECRandom in '..\PhotoDB\External\Crypt\DECv5.2\DECRandom.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uErrors in '..\PhotoDB\Units\uErrors.pas',
  uHook in 'uHook.pas',
  uAPIHook in 'uAPIHook.pas',
  uTransparentEncryption in '..\PhotoDB\Units\uTransparentEncryption.pas',
  uTransparentEncryptor in 'uTransparentEncryptor.pas',
  uWinAPIRedirections in 'uWinAPIRedirections.pas',
  uLockedFileNotifications in '..\PhotoDB\Units\uLockedFileNotifications.pas';

{$R *.res}

exports
  LoadHook;

begin
  DefaultDll := InstParamStr;
  DllProc := @HandleEvents;
  HandleEvents(DLL_PROCESS_ATTACH);
end.
