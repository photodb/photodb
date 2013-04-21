program PhotoDBTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  TestMediaInfo in 'TestMediaInfo.pas',
  DUnitTestRunner,

  MSXML2_TLB in '..\Units\MSXML2_TLB.pas',

  uSplashThread in '..\Threads\uSplashThread.pas',
  uActivationUtils in '..\Units\Utils\uActivationUtils.pas',
  uMath in '..\Units\System\uMath.pas',
  uConstants in '..\Units\uConstants.pas',
  uRuntime in '..\Units\System\uRuntime.pas',
  uTime in '..\Units\System\uTime.pas',
  uLogger in '..\Units\System\uLogger.pas',
  uMemory in '..\Units\System\uMemory.pas',
  uMediaInfo in '..\Units\uMediaInfo.pas',
  uBitmapUtils in '..\Units\Utils\uBitmapUtils.pas',
  uGraphicUtils in '..\Units\Utils\uGraphicUtils.pas',
  uRAWImage in '..\Units\Formats\uRAWImage.pas',
  uTiffImage in '..\Units\Formats\uTiffImage.pas',
  uAnimatedJPEG in '..\Units\Formats\uAnimatedJPEG.pas',
  uJpegUtils in '..\Units\Utils\uJpegUtils.pas',
  uPNGUtils in '..\Units\Utils\uPNGUtils.pas',
  uXMLUtils in '..\Units\Utils\uXMLUtils.pas',
  uFormUtils in '..\Units\Utils\uFormUtils.pas',
  uStringUtils in '..\Units\Utils\uStringUtils.pas',
  uShellUtils in '..\..\Installer\uShellUtils.pas',
  uTranslate in '..\Units\uTranslate.pas',
  lcms2dll in '..\External\lcms2dll.pas',
  uICCProfile in '..\Units\uICCProfile.pas',
  uProgramStatInfo in '..\Units\System\uProgramStatInfo.pas',
  CmpUnit in '..\Units\CmpUnit.pas',
  uList64 in '..\Units\uList64.pas',
  uGUIDUtils in '..\Units\Utils\uGUIDUtils.pas',
  uDBUtils in '..\Units\uDBUtils.pas',

  uDBAdapter in '..\Units\Database\uDBAdapter.pas',
  uDBConnection in '..\Units\Database\uDBConnection.pas',
  uDBEntities in '..\Units\Database\uDBEntities.pas',
  uDBContext in '..\Units\Database\uDBContext.pas',
  uDBClasses in '..\Units\Database\uDBClasses.pas',
  uDBScheme in '..\Units\Database\uDBScheme.pas',
  uSettingsRepository in '..\Units\Database\uSettingsRepository.pas',
  uGroupsRepository in '..\Units\Database\uGroupsRepository.pas',
  uMediaRepository in '..\Units\Database\uMediaRepository.pas',
  uPeopleRepository in '..\Units\Database\uPeopleRepository.pas',

  uInterfaces in '..\Units\Interfaces\uInterfaces.pas',

  uDBTypes in '..\Units\uDBTypes.pas',
  UnitDBCommonGraphics in '..\Units\UnitDBCommonGraphics.pas',
  uCDMappingTypes in '..\Units\uCDMappingTypes.pas',
  uBufferedFileStream in '..\Units\uBufferedFileStream.pas',
  u2DUtils in '..\Units\Utils\u2DUtils.pas',
  uFaceDetection in '..\Units\uFaceDetection.pas',
  uFaceDetectionThread in '..\Threads\uFaceDetectionThread.pas',

  uThreadTask in '..\Threads\uThreadTask.pas',
  uThreadEx in '..\Threads\uThreadEx.pas',
  uThreadForm in '..\Units\uThreadForm.pas',
  UnitWindowsCopyFilesThread in '..\Threads\UnitWindowsCopyFilesThread.pas',

  uIconUtils in '..\Units\Utils\uIconUtils.pas',
  uDateUtils in '..\Units\Utils\uDateUtils.pas',
  uExifUtils in '..\Units\Utils\uExifUtils.pas',
  uDBBaseTypes in '..\Units\uDBBaseTypes.pas',
  UnitDBCommon in '..\Units\UnitDBCommon.pas',
  UnitLinksSupport in '..\Units\UnitLinksSupport.pas',
  GraphicCrypt in '..\Units\GraphicCrypt.pas',
  uSessionPasswords in '..\Units\uSessionPasswords.pas',
  uCollectionEvents in '..\Units\uCollectionEvents.pas',

  GIFImage in '..\External\Formats\GIFImage.pas',

  UnitCrypting in '..\Units\UnitCrypting.pas',
  DECCipher in '..\External\Crypt\DECv5.2\DECCipher.pas',
  DECData in '..\External\Crypt\DECv5.2\DECData.pas',
  DECFmt in '..\External\Crypt\DECv5.2\DECFmt.pas',
  DECHash in '..\External\Crypt\DECv5.2\DECHash.pas',
  DECRandom in '..\External\Crypt\DECv5.2\DECRandom.pas',
  DECUtil in '..\External\Crypt\DECv5.2\DECUtil.pas',
  uStrongCrypt in '..\Units\uStrongCrypt.pas',

  GraphicEx in '..\External\Formats\GraphicEx\GraphicEx.pas',
  GraphicColor in '..\External\Formats\GraphicEx\GraphicColor.pas',
  GraphicCompression in '..\External\Formats\GraphicEx\GraphicCompression.pas',
  GraphicStrings in '..\External\Formats\GraphicEx\GraphicStrings.pas',
  MZLib in '..\External\Formats\GraphicEx\MZLib.pas',
  uAssociations in '..\..\Installer\uAssociations.pas',

  CCR.Exif.Consts in '..\External\CCR.Exif\CCR.Exif.Consts.pas',
  CCR.Exif.IPTC in '..\External\CCR.Exif\CCR.Exif.IPTC.pas',
  CCR.Exif in '..\External\CCR.Exif\CCR.Exif.pas',
  CCR.Exif.StreamHelper in '..\External\CCR.Exif\CCR.Exif.StreamHelper.pas',
  CCR.Exif.TagIDs in '..\External\CCR.Exif\CCR.Exif.TagIDs.pas',
  CCR.Exif.XMPUtils in '..\External\CCR.Exif\CCR.Exif.XMPUtils.pas',
  CCR.Exif.BaseUtils in '..\External\CCR.Exif\CCR.Exif.BaseUtils.pas',
  CCR.Exif.TiffUtils in '..\External\CCR.Exif\CCR.Exif.TiffUtils.pas',

  FreeBitmap in '..\External\Formats\FreeImage\FreeBitmap.pas',
  FreeImage in '..\External\Formats\FreeImage\FreeImage.pas',
  uFreeImageIO in '..\Units\Formats\uFreeImageIO.pas',
  uFreeImageImage in '..\Units\Formats\uFreeImageImage.pas',

  uDBGraphicTypes in '..\Units\uDBGraphicTypes.pas',

  UnitINI in '..\Units\UnitINI.pas',
  uSettings in '..\Units\uSettings.pas',
  uConfiguration in '..\Units\uConfiguration.pas',
  uShellIntegration in '..\Units\uShellIntegration.pas',
  uVistaFuncs in '..\Units\uVistaFuncs.pas',
  uAppUtils in '..\Units\Utils\uAppUtils.pas',
  uVCLHelpers in '..\Units\uVCLHelpers.pas',
  uFastLoad in '..\Units\uFastLoad.pas',
  uDBCustomThread in '..\Threads\uDBCustomThread.pas',
  uThemesUtils in '..\Units\Utils\uThemesUtils.pas',
  uDBThread in '..\Threads\uDBThread.pas',
  uGOM in '..\Units\System\uGOM.pas',
  uIME in '..\Units\System\uIME.pas',
  uShellNamespaceUtils in '..\Units\Utils\uShellNamespaceUtils.pas',
  uPortableDeviceManager in '..\Units\PortableDevices\uPortableDeviceManager.pas',
  uPortableClasses in '..\Units\PortableDevices\uPortableClasses.pas',
  uWIAClasses in '..\Units\PortableDevices\uWIAClasses.pas',
  uWIAInterfaces in '..\Units\PortableDevices\uWIAInterfaces.pas',
  uWPDClasses in '..\Units\PortableDevices\uWPDClasses.pas',
  uWPDInterfaces in '..\Units\PortableDevices\uWPDInterfaces.pas',
  uPortableDeviceUtils in '..\Units\PortableDevices\uPortableDeviceUtils.pas',
  ShellContextMenu in '..\Units\ShellContextMenu.pas',

  uDBForm in '..\Units\uDBForm.pas',
  uFormInterfaces in '..\Units\Interfaces\uFormInterfaces.pas',
  UnitDBDeclare in '..\Units\UnitDBDeclare.pas',
  uLockedFileNotifications in '..\Units\uLockedFileNotifications.pas',

  uErrors in '..\Units\uErrors.pas',
  uTransparentEncryption in '..\Units\uTransparentEncryption.pas',
  uResources in '..\Units\uResources.pas',
  uColorUtils in '..\Units\Utils\uColorUtils.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

