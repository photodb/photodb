program PhotoDBBridge;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$SetPEFlags 1}// 1 = Windows.IMAGE_FILE_RELOCS_STRIPPED

uses
  Windows,
  Vcl.Forms,
  ComServ,
  uAutoplayHandler in 'uAutoplayHandler.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas';

var
  Frm: TForm;

exports
  DllGetClassObject,    //called by COM to obtain a class factory object
  DllCanUnloadNow,      //called by COM at runtime to determine if this DLL server is safe to unload
  DllRegisterServer,    //called by COM to register this DLL server
  DllUnregisterServer;  //called by COM to unregister this DLL server}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.ShowMainForm := False;
  Application.CreateForm(TForm, Frm);
  Application.Run;
end.
