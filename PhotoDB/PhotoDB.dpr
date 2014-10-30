program PhotoDB;

{$DESCRIPTION 'Photo DB v4.6'}

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009+) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}

{$IFDEF DEBUG}
  //fast at multithreading
  {$DEFINE FAST_MM}
{$ELSE}
  //cool in debug mode
  {$DEFINE SCALE_MM}
{$ENDIF}

uses
  {$IFDEF SCALE_MM}
  ScaleMM2 in 'External\scalemm\ScaleMM2.pas',
  {$ENDIF }
  {$IFDEF FAST_MM}
  FastMM4 in 'External\FastMM\FastMM4.pas',
  FastMM4Messages in 'External\FastMM\FastMM4Messages.pas',
  {$ENDIF }
  {$IFDEF DEBUG}
  ExceptionJCLSupport in 'Units\ExceptionJCLSupport.pas',
  {$ENDIF }
  uInit in 'Units\uInit.pas',
  uTime in 'Units\System\uTime.pas',
  uSplashThread in 'Threads\uSplashThread.pas',
  uLanguageLoadThread in 'Threads\uLanguageLoadThread.pas',
  uLoadStyleThread in 'Threads\uLoadStyleThread.pas',
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Win.ComObj,
  Vcl.Controls,
  Vcl.Forms,
  Dmitry.Utils.Files,
  SlideShow in 'SlideShow.pas' {Viewer},
  Options in 'Options.pas' {OptionsForm},
  unitimhint in 'unitimhint.pas' {ImHint},
  SlideShowFullScreen in 'SlideShowFullScreen.pas' {FullScreenView},
  uActivation in 'uActivation.pas' {ActivateForm},
  uAbout in 'uAbout.pas' {AboutForm},
  FormManegerUnit in 'FormManegerUnit.pas' {FormManager},
  CMDUnit in 'CMDUnit.pas' {CMDForm},
  UnitEditGroupsForm in 'UnitEditGroupsForm.pas' {EditGroupsForm},
  UnitNewGroupForm in 'UnitNewGroupForm.pas' {NewGroupForm},
  UnitFormChangeGroup in 'UnitFormChangeGroup.pas' {FormChangeGroup},
  UnitQuickGroupInfo in 'UnitQuickGroupInfo.pas' {FormQuickGroupInfo},
  UnitMenuDateForm in 'UnitMenuDateForm.pas' {FormMenuDateEdit},
  UnitGroupReplace in 'UnitGroupReplace.pas' {FormGroupReplace},
  UnitSavingTableForm in 'UnitSavingTableForm.pas' {SavingTableForm},
  FloatPanelFullScreen in 'FloatPanelFullScreen.pas' {FloatPanel},
  UnitPasswordForm in 'UnitPasswordForm.pas' {PassWordForm},
  UnitCryptImageForm in 'UnitCryptImageForm.pas' {CryptImageForm},
  UnitFileRenamerForm in 'UnitFileRenamerForm.pas' {FormFastFileRenamer},
  UnitSizeResizerForm in 'UnitSizeResizerForm.pas' {FormSizeResizer},
  UnitJPEGOptions in 'UnitJPEGOptions.pas' {FormJpegOptions},
  DX_Alpha in 'DX_Alpha.pas' {DirectShowForm},
  UnitFormInternetUpdating in 'UnitFormInternetUpdating.pas' {FormInternetUpdating},
  UnitHelp in 'UnitHelp.pas' {HelpPopup},
  ProgressActionUnit in 'ProgressActionUnit.pas' {ProgressActionForm},
  ImEditor in 'ImageEditor\ImEditor.pas' {ImageEditor},
  ExEffectFormUnit in 'ImageEditor\ExEffectFormUnit.pas' {ExEffectForm},
  UnitEditorFullScreenForm in 'UnitEditorFullScreenForm.pas' {EditorFullScreenForm},
  UnitFormCDExport in 'UnitFormCDExport.pas' {FormCDExport},
  UnitFormCDMapper in 'UnitFormCDMapper.pas' {FormCDMapper},
  UnitFormCDMapInfo in 'UnitFormCDMapInfo.pas' {FormCDMapInfo},
  SelectGroupForm in 'SelectGroupForm.pas' {FormSelectGroup},
  UnitStringPromtForm in 'UnitStringPromtForm.pas' {FormStringPromt},
  UnitEditLinkForm in 'UnitEditLinkForm.pas' {FormEditLink},
  PrintMainForm in 'Printer\PrintMainForm.pas' {PrintForm},
  PrinterProgress in 'Printer\PrinterProgress.pas' {FormPrinterProgress},
  UnitActionsForm in 'UnitActionsForm.pas' {ActionsForm},
  UnitBigImagesSize in 'UnitBigImagesSize.pas' {BigImagesSizeForm},
  UnitHintCeator in 'Threads\UnitHintCeator.pas',
  ExplorerThreadUnit in 'Threads\ExplorerThreadUnit.pas',
  UnitPackingTable in 'Threads\UnitPackingTable.pas',
  UnitExplorerThumbnailCreatorThread in 'Threads\UnitExplorerThumbnailCreatorThread.pas',
  UnitSaveQueryThread in 'Threads\UnitSaveQueryThread.pas',
  UnitDirectXSlideShowCreator in 'Threads\UnitDirectXSlideShowCreator.pas',
  UnitViewerThread in 'Threads\UnitViewerThread.pas',
  UnitInternetUpdate in 'Threads\UnitInternetUpdate.pas',
  UnitWindowsCopyFilesThread in 'Threads\UnitWindowsCopyFilesThread.pas',
  UnitBackUpTableInCMD in 'Threads\UnitBackUpTableInCMD.pas',
  UnitPropertyLoadImageThread in 'Threads\UnitPropertyLoadImageThread.pas',
  UnitPropertyLoadGistogrammThread in 'Threads\UnitPropertyLoadGistogrammThread.pas',
  UnitRefreshDBRecordsThread in 'Threads\UnitRefreshDBRecordsThread.pas',
  UnitCryptingImagesThread in 'Threads\UnitCryptingImagesThread.pas',
  UnitSlideShowUpdateInfoThread in 'Threads\UnitSlideShowUpdateInfoThread.pas',
  UnitCDExportThread in 'Threads\UnitCDExportThread.pas',
  GraphicEx in 'External\Formats\GraphicEx\GraphicEx.pas',
  GraphicColor in 'External\Formats\GraphicEx\GraphicColor.pas',
  GraphicCompression in 'External\Formats\GraphicEx\GraphicCompression.pas',
  GraphicStrings in 'External\Formats\GraphicEx\GraphicStrings.pas',
  MZLib in 'External\Formats\GraphicEx\MZLib.pas',
  uRAWImage in 'Units\Formats\uRAWImage.pas',
  GIFImage in 'External\Formats\GIFImage.pas',
  ColorToolUnit in 'ImageEditor\ColorToolUnit.pas',
  CropToolUnit in 'ImageEditor\CropToolUnit.pas',
  EffectsToolThreadUnit in 'ImageEditor\EffectsToolThreadUnit.pas',
  EffectsToolUnit in 'ImageEditor\EffectsToolUnit.pas',
  ExEffects in 'ImageEditor\ExEffects.pas',
  ImageHistoryUnit in 'ImageEditor\ImageHistoryUnit.pas',
  RedEyeToolUnit in 'ImageEditor\RedEyeToolUnit.pas',
  ResizeToolThreadUnit in 'ImageEditor\ResizeToolThreadUnit.pas',
  ResizeToolUnit in 'ImageEditor\ResizeToolUnit.pas',
  RotateToolThreadUnit in 'ImageEditor\RotateToolThreadUnit.pas',
  RotateToolUnit in 'ImageEditor\RotateToolUnit.pas',
  ToolsUnit in 'ImageEditor\ToolsUnit.pas',
  Effects in 'ImageEditor\effects\Effects.pas',
  ExEffectsUnit in 'ImageEditor\ExEffectsUnit.pas',
  GBlur2 in 'ImageEditor\GBlur2.pas',
  CustomSelectTool in 'ImageEditor\CustomSelectTool.pas',
  TextToolUnit in 'ImageEditor\TextToolUnit.pas',
  BrushToolUnit in 'ImageEditor\BrushToolUnit.pas',
  UnitGeneratorPrinterPreview in 'Printer\UnitGeneratorPrinterPreview.pas',
  UnitPrinterTypes in 'Printer\UnitPrinterTypes.pas',
  ExEffectsUnitW in 'ImageEditor\ExEffectsUnitW.pas',
  Scanlines in 'ImageEditor\effects\Scanlines.pas',
  ScanlinesFX in 'ImageEditor\effects\ScanlinesFX.pas',
  InsertImageToolUnit in 'ImageEditor\InsertImageToolUnit.pas',
  OptimizeImageUnit in 'ImageEditor\OptimizeImageUnit.pas',
  UnitResampleFilters in 'ImageEditor\effects\UnitResampleFilters.pas',
  uVistaFuncs in 'Units\uVistaFuncs.pas',
  uDBManager in 'Units\Database\uDBManager.pas',
  CmpUnit in 'Units\CmpUnit.pas',
  DBCMenu in 'Units\DBCMenu.pas',
  ExplorerTypes in 'Units\ExplorerTypes.pas',
  UnitGroupsReplace in 'Units\UnitGroupsReplace.pas',
  UnitBitmapImageList in 'Units\UnitBitmapImageList.pas',
  GraphicCrypt in 'Units\GraphicCrypt.pas',
  UnitCrypting in 'Units\UnitCrypting.pas',
  ShellContextMenu in 'Units\ShellContextMenu.pas',
  DDraw in 'Units\DDraw.pas',
  UnitLinksSupport in 'Units\UnitLinksSupport.pas',
  GDIPlusRotate in 'Units\GDIPlusRotate.pas',
  UnitGroupsTools in 'Units\UnitGroupsTools.pas',
  UnitSQLOptimizing in 'Units\UnitSQLOptimizing.pas',
  uDBConnection in 'Units\Database\uDBConnection.pas',
  acWorkRes in 'Units\acWorkRes.pas',
  UnitPropeccedFilesSupport in 'Units\UnitPropeccedFilesSupport.pas',
  UnitINI in 'Units\UnitINI.pas',
  wfsU in 'Units\wfsU.pas',
  UnitPasswordKeeper in 'Units\UnitPasswordKeeper.pas',
  UnitDBDeclare in 'Units\UnitDBDeclare.pas',
  UnitDBCommon in 'Units\UnitDBCommon.pas',
  UnitDBCommonGraphics in 'Units\UnitDBCommonGraphics.pas',
  UnitSlideShowScanDirectoryThread in 'Units\UnitSlideShowScanDirectoryThread.pas',
  UnitDBFileDialogs in 'Units\UnitDBFileDialogs.pas',
  UnitSendMessageWithTimeoutThread in 'Units\UnitSendMessageWithTimeoutThread.pas',
  UnitCDMappingSupport in 'Units\UnitCDMappingSupport.pas',
  uThreadForm in 'Units\uThreadForm.pas',
  uThreadEx in 'Threads\uThreadEx.pas',
  uAssociatedIcons in 'Threads\uAssociatedIcons.pas',
  uLogger in 'Units\System\uLogger.pas',
  uConstants in 'Units\uConstants.pas',
  uStringUtils in 'Units\Utils\uStringUtils.pas',
  UnitLoadDBKernelIconsThread in 'Threads\UnitLoadDBKernelIconsThread.pas',
  UnitLoadCRCCheckThread in 'Threads\UnitLoadCRCCheckThread.pas',
  uFastLoad in 'Units\uFastLoad.pas',
  uResources in 'Units\uResources.pas',
  uExplorerThreadPool in 'Threads\uExplorerThreadPool.pas',
  uGOM in 'Units\System\uGOM.pas',
  uListViewUtils in 'Units\uListViewUtils.pas',
  FreeBitmap in 'External\Formats\FreeImage\FreeBitmap.pas',
  FreeImage in 'External\Formats\FreeImage\FreeImage.pas',
  FreeUtils in 'External\Formats\FreeImage\FreeUtils.pas',
  uDBDrawing in 'Units\uDBDrawing.pas',
  uList64 in 'Units\uList64.pas',
  uW7TaskBar in 'Units\uW7TaskBar.pas',
  uMath in 'Units\System\uMath.pas',
  DECCipher in 'External\Crypt\DECv5.2\DECCipher.pas',
  DECData in 'External\Crypt\DECv5.2\DECData.pas',
  DECFmt in 'External\Crypt\DECv5.2\DECFmt.pas',
  DECHash in 'External\Crypt\DECv5.2\DECHash.pas',
  DECRandom in 'External\Crypt\DECv5.2\DECRandom.pas',
  DECUtil in 'External\Crypt\DECv5.2\DECUtil.pas',
  uStrongCrypt in 'Units\uStrongCrypt.pas',
  uMemory in 'Units\System\uMemory.pas',
  uDBForm in 'Units\uDBForm.pas',
  uTranslate in 'Units\uTranslate.pas',
  uImageConvertThread in 'Threads\uImageConvertThread.pas',
  uWatermarkOptions in 'uWatermarkOptions.pas' {FrmWatermarkOptions},
  uMultiCPUThreadManager in 'Threads\uMultiCPUThreadManager.pas',
  uFormListView in 'Units\uFormListView.pas',
  uDBThread in 'Threads\uDBThread.pas',
  uGraphicUtils in 'Units\Utils\uGraphicUtils.pas',
  uPrivateHelper in 'Units\uPrivateHelper.pas',
  CCR.Exif.Consts in 'External\CCR.Exif\CCR.Exif.Consts.pas',
  CCR.Exif.IPTC in 'External\CCR.Exif\CCR.Exif.IPTC.pas',
  CCR.Exif in 'External\CCR.Exif\CCR.Exif.pas',
  CCR.Exif.StreamHelper in 'External\CCR.Exif\CCR.Exif.StreamHelper.pas',
  CCR.Exif.TagIDs in 'External\CCR.Exif\CCR.Exif.TagIDs.pas',
  CCR.Exif.XMPUtils in 'External\CCR.Exif\CCR.Exif.XMPUtils.pas',
  uPNGUtils in 'Units\Utils\uPNGUtils.pas',
  uFormUtils in 'Units\Utils\uFormUtils.pas',
  uShellUtils in '..\Installer\uShellUtils.pas',
  uInstallTypes in '..\Installer\uInstallTypes.pas',
  uInstallScope in '..\Installer\uInstallScope.pas',
  uDBBaseTypes in 'Units\uDBBaseTypes.pas',
  uDBUtils in 'Units\uDBUtils.pas',
  uAssociations in '..\Installer\uAssociations.pas',
  uAppUtils in 'Units\Utils\uAppUtils.pas',
  uEditorTypes in 'ImageEditor\uEditorTypes.pas',
  uShellIntegration in 'Units\uShellIntegration.pas',
  uDBTypes in 'Units\uDBTypes.pas',
  uActivationUtils in 'Units\Utils\uActivationUtils.pas',
  uDBFileTypes in 'Units\uDBFileTypes.pas',
  uRuntime in 'Units\System\uRuntime.pas',
  uDBGraphicTypes in 'Units\uDBGraphicTypes.pas',
  uStenography in 'Units\uStenography.pas',
  uInternetUtils in 'Units\Utils\uInternetUtils.pas',
  uViewerTypes in 'Units\uViewerTypes.pas',
  uDXUtils in 'Units\Utils\uDXUtils.pas',
  uFrameWizardBase in 'Wizards\uFrameWizardBase.pas' {FrameWizardBase: TFrame},
  uFrameFreeActivation in 'Activation\uFrameFreeActivation.pas' {FrameFreeActivation},
  uWizards in 'Wizards\uWizards.pas',
  uFrameActivationLanding in 'Activation\uFrameActivationLanding.pas' {FrameActivationLanding: TFrame},
  uInternetFreeActivationThread in 'Activation\uInternetFreeActivationThread.pas',
  uFrameFreeManualActivation in 'Activation\uFrameFreeManualActivation.pas' {FrameFreeManualActivation: TFrame},
  uFrameActicationSetCode in 'Activation\uFrameActicationSetCode.pas' {FrameActicationSetCode: TFrame},
  uFrameBuyApplication in 'Activation\uFrameBuyApplication.pas' {FrameBuyApplication: TFrame},
  uSettings in 'Units\uSettings.pas',
  CCR.Exif.BaseUtils in 'External\CCR.Exif\CCR.Exif.BaseUtils.pas',
  CCR.Exif.TiffUtils in 'External\CCR.Exif\CCR.Exif.TiffUtils.pas',
  uCryptUtils in 'Units\uCryptUtils.pas',
  uResourceUtils in 'Units\Utils\uResourceUtils.pas',
  uMobileUtils in 'Units\Utils\uMobileUtils.pas',
  uInterfaces in 'Units\Interfaces\uInterfaces.pas',
  uDBAdapter in 'Units\Database\uDBAdapter.pas',
  uCDMappingTypes in 'Units\uCDMappingTypes.pas',
  uMemoryEx in 'Units\System\uMemoryEx.pas',
  uDBShellUtils in 'Units\uDBShellUtils.pas',
  uFormSteganography in 'uFormSteganography.pas' {FormSteganography},
  uFrmSteganographyLanding in 'Steganography\uFrmSteganographyLanding.pas' {FrmSteganographyLanding: TFrame},
  uFrmCreatePNGSteno in 'Steganography\uFrmCreatePNGSteno.pas' {FrmCreatePNGSteno: TFrame},
  uFrmCreateJPEGSteno in 'Steganography\uFrmCreateJPEGSteno.pas' {FrmCreateJPEGSteno: TFrame},
  uStenoLoadImageThread in 'Threads\uStenoLoadImageThread.pas',
  uIME in 'Units\System\uIME.pas',
  uExifUtils in 'Units\Utils\uExifUtils.pas',
  uExifPatchThread in 'Threads\uExifPatchThread.pas',
  uTiffImage in 'Units\Formats\uTiffImage.pas',
  uJpegUtils in 'Units\Utils\uJpegUtils.pas',
  uBitmapUtils in 'Units\Utils\uBitmapUtils.pas',
  uIconUtils in 'Units\Utils\uIconUtils.pas',
  uWinThumbnails in 'Units\uWinThumbnails.pas',
  uShellThumbnails in 'Units\uShellThumbnails.pas',
  uMachMask in 'Units\uMachMask.pas',
  ExplorerUnit in 'ExplorerUnit.pas' {ExplorerForm},
  uDatabaseSearch in 'Units\uDatabaseSearch.pas',
  uFaceRecognizer in 'Units\uFaceRecognizer.pas',
  uFaceDetection in 'Units\uFaceDetection.pas',
  uFaceDetectionThread in 'Threads\uFaceDetectionThread.pas',
  uFormCreatePerson in 'uFormCreatePerson.pas' {FormCreatePerson},
  u2DUtils in 'Units\Utils\u2DUtils.pas',
  uDBClasses in 'Units\Database\uDBClasses.pas',
  uDateUtils in 'Units\Utils\uDateUtils.pas',
  uFormSelectPerson in 'uFormSelectPerson.pas' {FormFindPerson},
  uFormAddImage in 'uFormAddImage.pas' {FormAddingImage},
  UnitLoadPersonsThread in 'Threads\UnitLoadPersonsThread.pas',
  uConfiguration in 'Units\uConfiguration.pas',
  uVCLHelpers in 'Units\uVCLHelpers.pas',
  uFormPersonSuggest in 'uFormPersonSuggest.pas' {FormPersonSuggest},
  uDBCustomThread in 'Threads\uDBCustomThread.pas',
  uGUIDUtils in 'Units\Utils\uGUIDUtils.pas',
  uErrors in 'Units\uErrors.pas',
  uFormEditObject in 'uFormEditObject.pas' {FormEditObject},
  uExplorerDateStackProviders in 'Units\Providers\uExplorerDateStackProviders.pas',
  uExplorerGroupsProvider in 'Units\Providers\uExplorerGroupsProvider.pas',
  uExplorerPersonsProvider in 'Units\Providers\uExplorerPersonsProvider.pas',
  uExplorerSearchProviders in 'Units\Providers\uExplorerSearchProviders.pas',
  uExplorerPathProvider in 'Units\Providers\uExplorerPathProvider.pas',
  uExplorerPortableDeviceProvider in 'Units\Providers\uExplorerPortableDeviceProvider.pas',
  uPortableClasses in 'Units\PortableDevices\uPortableClasses.pas',
  uWIAClasses in 'Units\PortableDevices\uWIAClasses.pas',
  uWIAInterfaces in 'Units\PortableDevices\uWIAInterfaces.pas',
  uWPDClasses in 'Units\PortableDevices\uWPDClasses.pas',
  uWPDInterfaces in 'Units\PortableDevices\uWPDInterfaces.pas',
  uPortableDeviceManager in 'Units\PortableDevices\uPortableDeviceManager.pas',
  MSXML2_TLB in 'Units\MSXML2_TLB.pas',
  uPortableDeviceUtils in 'Units\PortableDevices\uPortableDeviceUtils.pas',
  uShellNamespaceUtils in 'Units\Utils\uShellNamespaceUtils.pas',
  uManagerExplorer in 'Units\uManagerExplorer.pas',
  uExplorerPastePIDLsThread in 'Threads\uExplorerPastePIDLsThread.pas',
  uFormImportImages in 'uFormImportImages.pas' {FormImportImages},
  uFormMoveFilesProgress in 'uFormMoveFilesProgress.pas' {FormMoveFilesProgress},
  uThreadImportPictures in 'Threads\uThreadImportPictures.pas',
  uPathUtils in 'Units\Utils\uPathUtils.pas',
  uImportScanThread in 'Threads\uImportScanThread.pas',
  uImportSeriesPreview in 'Threads\uImportSeriesPreview.pas',
  uCounters in 'Units\uCounters.pas',
  uFormImportPicturesSettings in 'uFormImportPicturesSettings.pas' {FormImportPicturesSettings},
  uImportPicturesUtils in 'Units\Utils\uImportPicturesUtils.pas',
  uPicturesImportPatternEdit in 'uPicturesImportPatternEdit.pas' {PicturesImportPatternEdit},
  uAnimatedJPEG in 'Units\Formats\uAnimatedJPEG.pas',
  uBufferedFileStream in 'Units\uBufferedFileStream.pas',
  uUpTime in 'Units\System\uUpTime.pas',
  uGeoLocation in 'Units\uGeoLocation.pas',
  uBrowserEmbedDraw in 'Units\uBrowserEmbedDraw.pas',
  IntfDocHostUIHandler in 'Units\WebJS\IntfDocHostUIHandler.pas',
  uWebJSExternal in 'Units\WebJS\uWebJSExternal.pas',
  uWebJSExternalContainer in 'Units\WebJS\uWebJSExternalContainer.pas',
  uWebNullContainer in 'Units\WebJS\uWebNullContainer.pas',
  WebJS_TLB in 'Units\WebJS\WebJS_TLB.pas',
  uThemesUtils in 'Units\Utils\uThemesUtils.pas',
  uDateTimePickerStyleHookXP in 'Units\Styles\uDateTimePickerStyleHookXP.pas',
  uEditStyleHookColor in 'Units\Styles\uEditStyleHookColor.pas',
  uHSLUtils in 'Units\Styles\uHSLUtils.pas',
  Vcl.Styles.Ext in 'Units\Styles\Vcl.Styles.Ext.pas',
  Vcl.Styles.Utils in 'Units\Styles\Vcl.Styles.Utils.pas',
  PropertyForm in 'PropertyForm.pas' {PropertiesForm},
  uPhotoShelf in 'Units\uPhotoShelf.pas',
  uExplorerShelfProvider in 'Units\Providers\uExplorerShelfProvider.pas',
  uXMLUtils in 'Units\Utils\uXMLUtils.pas',
  uGoogleOAuth in 'Units\Share\uGoogleOAuth.pas',
  uPhotoShareInterfaces in 'Units\Share\uPhotoShareInterfaces.pas',
  uPicasaProvider in 'Units\Share\uPicasaProvider.pas',
  uPicasaOAuth2 in 'Units\Share\uPicasaOAuth2.pas' {FormPicasaOAuth},
  uFormSharePhotos in 'uFormSharePhotos.pas' {FormSharePhotos},
  uOperationProgress in 'uOperationProgress.pas' {FormOperationProgress},
  uThreadTask in 'Threads\uThreadTask.pas',
  uBox in 'Units\Controls\uBox.pas',
  uShareImagesThread in 'Threads\uShareImagesThread.pas',
  uShareSettings in 'uShareSettings.pas' {FormShareSettings},
  uProgressBarStyleHookMarquee in 'Units\Styles\uProgressBarStyleHookMarquee.pas',
  uUninstallUtils in 'Units\Utils\uUninstallUtils.pas',
  uInternetProxy in 'Units\uInternetProxy.pas',
  uVCLStylesOneLoadSpeedUp in 'Units\Styles\uVCLStylesOneLoadSpeedUp.pas',
  lcms2dll in 'External\lcms2dll.pas',
  uICCProfile in 'Units\uICCProfile.pas',
  uImageLoader in 'Units\uImageLoader.pas',
  uPathProvideTreeView in 'Units\Controls\uPathProvideTreeView.pas',
  VirtualTrees in 'External\Controls\virtual-treeview\Source\VirtualTrees.pas',
  VTAccessibility in 'External\Controls\virtual-treeview\Source\VTAccessibility.pas',
  VTAccessibilityFactory in 'External\Controls\virtual-treeview\Source\VTAccessibilityFactory.pas',
  VTHeaderPopup in 'External\Controls\virtual-treeview\Source\VTHeaderPopup.pas',
  uFreeImageIO in 'Units\Formats\uFreeImageIO.pas',
  uExplorerProvidersInit in 'Units\Providers\uExplorerProvidersInit.pas',
  uExifInfo in 'Units\uExifInfo.pas',
  uFormInterfaces in 'Units\Interfaces\uFormInterfaces.pas',
  uFreeImageImage in 'Units\Formats\uFreeImageImage.pas',
  PDB.uVCLRewriters in 'Units\PDB.uVCLRewriters.pas',
  uDBInfoEditorUtils in 'Units\uDBInfoEditorUtils.pas',
  uRawExif in 'Units\uRawExif.pas',
  uMediaEncryption in 'Units\uMediaEncryption.pas',
  uTransparentEncryption in 'Units\uTransparentEncryption.pas',
  uLockedFileNotifications in 'Units\uLockedFileNotifications.pas',
  uExplorerFolderImages in 'Units\uExplorerFolderImages.pas',
  uFIRational in 'Units\uFIRational.pas',
  uMediaPlayers in 'Units\uMediaPlayers.pas',
  uImageViewer in 'Units\uImageViewer.pas',
  uIImageViewer in 'Units\Interfaces\uIImageViewer.pas',
  uImageViewerControl in 'Units\uImageViewerControl.pas',
  uImageViewerThread in 'Threads\uImageViewerThread.pas',
  uAnimationHelper in 'Units\uAnimationHelper.pas',
  uImageZoomHelper in 'Units\uImageZoomHelper.pas',
  uSearchQuery in 'Units\uSearchQuery.pas',
  uMonthCalendar in 'Units\Controls\uMonthCalendar.pas',
  uEXIFDisplayControl in 'Units\Controls\uEXIFDisplayControl.pas',
  uProgramStatInfo in 'Units\System\uProgramStatInfo.pas',
  uImageListUtils in 'Units\Utils\uImageListUtils.pas',
  uSysInfo in 'Units\uSysInfo.pas',
  uCommandLine in 'Units\uCommandLine.pas',
  uFormShareLink in 'uFormShareLink.pas' {FormShareLink},
  uShareUtils in 'Units\uShareUtils.pas',
  uWinApi in 'Units\uWinApi.pas',
  uImportSource in 'uImportSource.pas' {FormImportSource},
  uPopupActionBarEx in 'Units\Styles\uPopupActionBarEx.pas',
  uDatabaseDirectoriesUpdater in 'Units\uDatabaseDirectoriesUpdater.pas',
  uFormLinkItemSelector in 'uFormLinkItemSelector.pas' {FormLinkItemSelector},
  uLinkListEditorDatabases in 'Units\ListEditors\uLinkListEditorDatabases.pas',
  uLinkListEditorFolders in 'Units\ListEditors\uLinkListEditorFolders.pas',
  uLinkListEditorForExecutables in 'Units\ListEditors\uLinkListEditorForExecutables.pas',
  uFormSelectLocation in 'uFormSelectLocation.pas' {FormSelectLocation},
  uDBUpdateUtils in 'Units\uDBUpdateUtils.pas',
  uSiteUtils in 'Units\Utils\uSiteUtils.pas',
  uTranslateUtils in 'Units\Utils\uTranslateUtils.pas',
  uDialogUtils in 'Units\uDialogUtils.pas',
  uLinkListEditorUpdateDirectories in 'Units\ListEditors\uLinkListEditorUpdateDirectories.pas',
  uSessionPasswords in 'Units\uSessionPasswords.pas',
  uCollectionEvents in 'Units\uCollectionEvents.pas',
  uDBIcons in 'Units\uDBIcons.pas',
  uDBScheme in 'Units\Database\uDBScheme.pas',
  uDBContext in 'Units\Database\uDBContext.pas',
  uDBEntities in 'Units\Database\uDBEntities.pas',
  uSettingsRepository in 'Units\Database\uSettingsRepository.pas',
  uGroupsRepository in 'Units\Database\uGroupsRepository.pas',
  uMediaRepository in 'Units\Database\uMediaRepository.pas',
  uPeopleRepository in 'Units\Database\uPeopleRepository.pas',
  uFormBackgroundTaskStatus in 'uFormBackgroundTaskStatus.pas' {FormBackgroundTaskStatus},
  uMediaInfo in 'Units\uMediaInfo.pas',
  uColorUtils in 'Units\Utils\uColorUtils.pas',
  uImageViewCount in 'Units\uImageViewCount.pas',
  uFormDBPreviewSettings in 'uFormDBPreviewSettings.pas' {FormDBPreviewSize},
  uDatabaseInfoControl in 'Units\Controls\uDatabaseInfoControl.pas',
  uFormLinkItemEditor in 'uFormLinkItemEditor.pas' {FormLinkItemEditor},
  uCollectionUtils in 'Units\Database\uCollectionUtils.pas',
  uSecondCopy in 'Units\uSecondCopy.pas',
  uIDBForm in 'Units\Interfaces\uIDBForm.pas',
  uExplorerCollectionProvider in 'Units\Providers\uExplorerCollectionProvider.pas',
  uFormSelectDuplicateDirectories in 'uFormSelectDuplicateDirectories.pas' {FormSelectDuplicateDirectories},
  uFaceRecornizerTrainer in 'Units\uFaceRecornizerTrainer.pas',
  OpenCV.Utils in 'Units\OpenCV\OpenCV.Utils.pas',
  OpenCV.Core in 'Units\OpenCV\OpenCV.Core.pas',
  OpenCV.Lib in 'Units\OpenCV\OpenCV.Lib.pas',
  OpenCV.ImgProc in 'Units\OpenCV\OpenCV.ImgProc.pas',
  OpenCV.ObjDetect in 'Units\OpenCV\OpenCV.ObjDetect.pas',
  OpenCV.Legacy in 'Units\OpenCV\OpenCV.Legacy.pas',
  OpenCV.HighGUI in 'Units\OpenCV\OpenCV.HighGUI.pas',
  uFaceRecognizerService in 'Units\uFaceRecognizerService.pas',
  uFaceAnalyzer in 'Units\uFaceAnalyzer.pas',
  uRWLock in 'Units\System\uRWLock.pas';

{$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED or IMAGE_FILE_LARGE_ADDRESS_AWARE}
{$R *.tlb}
{$R *.res}

procedure LogApplicationParameters;
var
  I: Integer;
begin
  TW.I.Start('START');
  for I := 0 to 10 do
    if ParamStr(I) <> '' then
      TW.I.Start('Parameter: ' + ParamStr(I));
end;

begin
  CoInitFlags := COM_MODE;
  try
    //FullDebugModeScanMemoryPoolBeforeEveryOperation := True;
    //ReportMemoryLeaksOnShutdown := True;

  {
   //Command line

   /BACKUP
   /PACKTABLE
   /SLEEP
   /UNINSTALL
   /EXPLORER
   /GETPHOTOS
   /NOLOGO
   /NoPrevVersion
   /NoFaultCheck
   /NoFullRun
   /AddPass "pass1!pass2!..."
   /Logging
  }
    LogApplicationParameters;

    if FolderView then
      DBID := ReadInternalFSContent('ID');

    // PREPAIRING ----------------------------------------------------
    if GetParamStrDBBool('/SLEEP') then
      Sleep(1000);

    TW.I.Start('Application.Initialize');
    Application.Initialize;

    EventLog(Format('Folder View = %s', [BoolToStr(FolderView)]));

    TW.I.Start('FindRunningVersion');
    if not GetParamStrDBBool('/NoPrevVersion') then
      FindRunningVersion;

    TLoad.Instance.StartDBKernelIconsThread;
    // This is main form of application
    Application.CreateForm(TFormManager, FormManager);
  Application.ShowMainForm := False;

    if not DBTerminating and not GetParamStrDBBool('/install') and not GetParamStrDBBool('/uninstall') then
    begin
      if not DBManager.LoadDefaultCollection then
        DBManager.CreateSampleDefaultCollection;
    end;

    //TrainIt;

    // SERVICES ----------------------------------------------------
    CMDInProgress := True;
    try
      TCommandLine.ProcessServiceCommands(DBManager.DBContext);
      TCommandLine.ProcessUserCommandLine(DBManager.DBContext);
    finally
      CMDInProgress := False;
    end;

    // PREPAIRING RUNNING DB ----------------------------------------
    if not DBTerminating then
    begin
      EventLog('Run manager...');
      if not GetParamStrDBBool('/NoFullRun') or FolderView then
        FormManager.Run;

      if GetParamStrDBBool('/SLEEP') then
        ActivateBackgroundApplication(Application.Handle);

    end else if FormManager <> nil then
      FormManager.RunInBackground;

    TW.I.Start('AllowDragAndDrop');
    AllowDragAndDrop;

    TW.I.Start('Application.Run');
    Application.Run;

    if DBTerminating then
    begin
      TLoad.Instance.RequiredDBKernelIcons;
      TLoad.Instance.RequiredCRCCheck;
      TLoad.Instance.RequiredStyle;
    end;

    UnLoadTranslateModule;
  except
    on e: Exception do
    begin
      CloseSplashWindow;
      EventLog(e);
      MessageBox(0, PChar(e.ToString + sLineBreak + e.StackTrace), 'Fatal error', MB_OK or MB_ICONERROR);
    end;
  end;
end.
