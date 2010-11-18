program PhotoDBInstall;

uses
  Forms,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uInstallUtils in 'uInstallUtils.pas',
  uFrmLanguage in 'uFrmLanguage.pas' {FormLanguage},
  uInstallTypes in 'uInstallTypes.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uDBForm in '..\PhotoDB\Units\uDBForm.pas',
  uTranslate in '..\PhotoDB\Units\uTranslate.pas',
  MSXML2_TLB in '..\PhotoDB\External\Xml\MSXML2_TLB.pas',
  OmniXML_MSXML in '..\PhotoDB\External\Xml\OmniXML_MSXML.pas',
  uLogger in '..\PhotoDB\Units\uLogger.pas',
  uFileUtils in '..\PhotoDB\Units\uFileUtils.pas',
  VRSIShortCuts in '..\PhotoDB\Units\VRSIShortCuts.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas';

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
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
