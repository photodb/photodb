program PhotoDBInstall;

uses
  Forms,
  frmMain in 'frmMain.pas' {FrmMain},
  uInstallUtils in 'uInstallUtils.pas';

{$R SETUP_ZIP.res}

begin


(*  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  ExtractFileFromStorage(FS, 'c:\1\PhotoDB.exe');
  ExtractFileFromStorage(FS, 'c:\1\Kernel.dll');
  ExtractFileFromStorage(FS, 'c:\1\lpng-px.dll');
  ExtractFileFromStorage(FS, 'c:\1\Icons.dll');
  ExtractFileFromStorage(FS, 'c:\1\FreeImage.dll');
    {$IFDEF DBDEBUG}
  ExtractFileFromStorage(FS, 'c:\1\FastMM_FullDebugMode.dll');
    {$ENDIF}
  ExtractFileFromStorage(FS, 'c:\1\LanguageRU.xml');
  ExtractDirectoryFromStorage(FS, 'c:\1\Actions');
  ExtractDirectoryFromStorage(FS, 'c:\1\Scripts');
  ExtractDirectoryFromStorage(FS, 'c:\1\Images');  *)

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMainInstance);
  Application.Run;
end.
