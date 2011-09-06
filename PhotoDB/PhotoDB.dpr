program PhotoDB;

{$DESCRIPTION 'Photo DB v2.3'}

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$SetPEFlags 1}// 1 = Windows.IMAGE_FILE_RELOCS_STRIPPED

uses
  FastMM4,
  uInit in 'Units\uInit.pas',
  uTime in 'Units\uTime.pas',
  uSplashThread in 'Threads\uSplashThread.pas',
  uLanguageLoadThread in 'Threads\uLanguageLoadThread.pas',
  ActiveX,
  ComObj,
  ADODB,
  ShellApi,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  DB,
  Menus,
  ExtCtrls,
  StdCtrls,
  ImgList,
  ComCtrls,
  ShlObj,
  jpeg,
  DmProgress,
  ClipBrd,
  SaveWindowPos,
  ExtDlgs,
  ToolWin,
  Rating,
  Searching in 'Searching.pas' {SearchForm},
  SlideShow in 'SlideShow.pas' {Viewer},
  Options in 'Options.pas' {OptionsForm},
  PropertyForm in 'PropertyForm.pas' {PropertiesForm},
  UnitFormCont in 'UnitFormCont.pas' {FormCont},
  replaceform in 'replaceform.pas' {DBReplaceForm},
  unitimhint in 'unitimhint.pas' {ImHint},
  SlideShowFullScreen in 'SlideShowFullScreen.pas' {FullScreenView},
  uActivation in 'uActivation.pas' {ActivateForm},
  UnitUpdateDB in 'UnitUpdateDB.pas' {UpdateDBForm},
  uAbout in 'uAbout.pas' {AboutForm},
  FormManegerUnit in 'FormManegerUnit.pas' {FormManager},
  ManagerDBUnit in 'ManagerDBUnit.pas' {ManagerDB},
  CMDUnit in 'CMDUnit.pas' {CMDForm},
  ExportUnit in 'ExportUnit.pas' {ExportForm},
  UnitDBCleaning in 'UnitDBCleaning.pas' {DBCleaningForm},
  UnitCompareProgress in 'UnitCompareProgress.pas' {ImportProgressForm},
  UnitCompareDataBases in 'UnitCompareDataBases.pas' {ImportDataBaseForm},
  UnitEditGroupsForm in 'UnitEditGroupsForm.pas' {EditGroupsForm},
  UnitNewGroupForm in 'UnitNewGroupForm.pas' {NewGroupForm},
  UnitManageGroups in 'UnitManageGroups.pas' {FormManageGroups},
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
  DX_Alpha in 'Units\dx\DX_Alpha.pas' {DirectShowForm},
  UnitFormInternetUpdating in 'UnitFormInternetUpdating.pas' {FormInternetUpdating},
  UnitHelp in 'UnitHelp.pas' {HelpPopup},
  ProgressActionUnit in 'ProgressActionUnit.pas' {ProgressActionForm},
  ImEditor in 'ImageEditor\ImEditor.pas' {ImageEditor},
  ExEffectFormUnit in 'ImageEditor\ExEffectFormUnit.pas' {ExEffectForm},
  UnitEditorFullScreenForm in 'UnitEditorFullScreenForm.pas' {EditorFullScreenForm},
  UnitChangeDBPath in 'UnitChangeDBPath.pas' {FormChangeDBPath},
  UnitSelectDB in 'UnitSelectDB.pas' {FormSelectDB},
  UnitDBOptions in 'UnitDBOptions.pas' {FormDBOptions},
  UnitFormCDExport in 'UnitFormCDExport.pas' {FormCDExport},
  UnitFormCDMapper in 'UnitFormCDMapper.pas' {FormCDMapper},
  UnitFormCDMapInfo in 'UnitFormCDMapInfo.pas' {FormCDMapInfo},
  SelectGroupForm in 'SelectGroupForm.pas' {FormSelectGroup},
  UnitHistoryForm in 'UnitHistoryForm.pas' {FormHistory},
  UnitStringPromtForm in 'UnitStringPromtForm.pas' {FormStringPromt},
  UnitEditLinkForm in 'UnitEditLinkForm.pas' {FormEditLink},
  UnitSelectFontForm in 'UnitSelectFontForm.pas' {FormSelectFont},
  UnitListOfKeyWords in 'UnitListOfKeyWords.pas' {FormListOfKeyWords},
  UnitDBTreeView in 'DBTools\UnitDBTreeView.pas' {FormCreateDBFileTree},
  PrintMainForm in 'Printer\PrintMainForm.pas' {PrintForm},
  PrinterProgress in 'Printer\PrinterProgress.pas' {FormPrinterProgress},
  UnitGetPhotosForm in 'UnitGetPhotosForm.pas' {GetToPersonalFolderForm},
  UnitFormManagerHint in 'UnitFormManagerHint.pas' {FormManagerHint},
  UnitActionsForm in 'Units\UnitActionsForm.pas' {ActionsForm},
  UnitSplitExportForm in 'UnitSplitExportForm.pas' {SplitExportForm},
  UnitDebugScriptForm in 'UnitDebugScriptForm.pas' {DebugScriptForm},
  UnitImportingImagesForm in 'UnitImportingImagesForm.pas' {FormImportingImages},
  UnitConvertDBForm in 'UnitConvertDBForm.pas' {FormConvertingDB},
  UnitBigImagesSize in 'UnitBigImagesSize.pas' {BigImagesSizeForm},
  Loadingresults in 'Threads\Loadingresults.pas',
  UnitCleanUpThread in 'Threads\UnitCleanUpThread.pas',
  UnitLoadFilesToPanel in 'Threads\UnitLoadFilesToPanel.pas',
  UnitHintCeator in 'Threads\UnitHintCeator.pas',
  UnitCmpDB in 'Threads\UnitCmpDB.pas',
  ExplorerThreadUnit in 'Threads\ExplorerThreadUnit.pas',
  UnitPackingTable in 'Threads\UnitPackingTable.pas',
  UnitUpdateDBThread in 'Threads\UnitUpdateDBThread.pas',
  UnitExportThread in 'Threads\UnitExportThread.pas',
  UnitExplorerThumbnailCreatorThread in 'Threads\UnitExplorerThumbnailCreatorThread.pas',
  UnitSaveQueryThread in 'Threads\UnitSaveQueryThread.pas',
  UnitRecreatingThInTable in 'Threads\UnitRecreatingThInTable.pas',
  UnitDirectXSlideShowCreator in 'Threads\UnitDirectXSlideShowCreator.pas',
  UnitViewerThread in 'Threads\UnitViewerThread.pas',
  UnitInternetUpdate in 'Threads\UnitInternetUpdate.pas',
  UnitRestoreTableThread in 'Threads\UnitRestoreTableThread.pas',
  UnitWindowsCopyFilesThread in 'Threads\UnitWindowsCopyFilesThread.pas',
  UnitThreadShowBadLinks in 'Threads\UnitThreadShowBadLinks.pas',
  UnitBackUpTableInCMD in 'Threads\UnitBackUpTableInCMD.pas',
  UnitOpenQueryThread in 'Threads\UnitOpenQueryThread.pas',
  UnitOptimizeDublicatesThread in 'Threads\UnitOptimizeDublicatesThread.pas',
  ConvertDBThreadUnit in 'Threads\ConvertDBThreadUnit.pas',
  UnitPropertyLoadImageThread in 'Threads\UnitPropertyLoadImageThread.pas',
  UnitPropertyLoadGistogrammThread in 'Threads\UnitPropertyLoadGistogrammThread.pas',
  UnitScanImportPhotosThread in 'Threads\UnitScanImportPhotosThread.pas',
  UnitRefreshDBRecordsThread in 'Threads\UnitRefreshDBRecordsThread.pas',
  UnitCryptingImagesThread in 'Threads\UnitCryptingImagesThread.pas',
  UnitPanelLoadingBigImagesThread in 'Threads\UnitPanelLoadingBigImagesThread.pas',
  UnitFileExistsThread in 'Threads\UnitFileExistsThread.pas',
  UnitSlideShowUpdateInfoThread in 'Threads\UnitSlideShowUpdateInfoThread.pas',
  UnitCDExportThread in 'Threads\UnitCDExportThread.pas',
  UnitSearchBigImagesLoaderThread in 'Threads\UnitSearchBigImagesLoaderThread.pas',
  Scpanel in 'External\Controls\scpanel\Scpanel.pas',
  GraphicEx in 'External\Formats\GraphicEx\GraphicEx.pas',
  GraphicColor in 'External\Formats\GraphicEx\GraphicColor.pas',
  GraphicCompression in 'External\Formats\GraphicEx\GraphicCompression.pas',
  GraphicStrings in 'External\Formats\GraphicEx\GraphicStrings.pas',
  MZLib in 'External\Formats\GraphicEx\MZLib.pas',
  RAWImage in 'External\Formats\DelphiDcraw\RAWImage.pas',
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
  dolphin_db in 'Units\dolphin_db.pas',
  UnitDBKernel in 'Units\UnitDBKernel.pas',
  CmpUnit in 'Units\CmpUnit.pas',
  DBCMenu in 'Units\DBCMenu.pas',
  ExplorerTypes in 'Units\ExplorerTypes.pas',
  UnitGroupsWork in 'Units\UnitGroupsWork.pas',
  UnitGroupsReplace in 'Units\UnitGroupsReplace.pas',
  UnitBitmapImageList in 'Units\UnitBitmapImageList.pas',
  GraphicCrypt in 'Units\GraphicCrypt.pas',
  UnitCrypting in 'Units\UnitCrypting.pas',
  ShellContextMenu in 'Units\ShellContextMenu.pas',
  DDraw in 'Units\DDraw.pas',
  DXCommon in 'Units\DXCommon.pas',
  UnitLinksSupport in 'Units\UnitLinksSupport.pas',
  GDIPlusRotate in 'Units\GDIPlusRotate.pas',
  UnitGroupsTools in 'Units\UnitGroupsTools.pas',
  UnitSQLOptimizing in 'Units\UnitSQLOptimizing.pas',
  CommonDBSupport in 'Units\CommonDBSupport.pas',
  UnitScripts in 'Units\UnitScripts.pas',
  ReplaseIconsInScript in 'Units\ReplaseIconsInScript.pas',
  DBScriptFunctions in 'Units\DBScriptFunctions.pas',
  UnitScriptsFunctions in 'Units\UnitScriptsFunctions.pas',
  UnitUpdateDBObject in 'Units\UnitUpdateDBObject.pas',
  UnitTimeCounter in 'Units\UnitTimeCounter.pas',
  acWorkRes in 'Units\acWorkRes.pas',
  UnitPropeccedFilesSupport in 'Units\UnitPropeccedFilesSupport.pas',
  UnitINI in 'Units\UnitINI.pas',
  wfsU in 'Units\wfsU.pas',
  UnitFileCheckerDB in 'Units\UnitFileCheckerDB.pas',
  UnitPasswordKeeper in 'Units\UnitPasswordKeeper.pas',
  UnitDBDeclare in 'Units\UnitDBDeclare.pas',
  UnitDBCommon in 'Units\UnitDBCommon.pas',
  UnitDBCommonGraphics in 'Units\UnitDBCommonGraphics.pas',
  UnitSlideShowScanDirectoryThread in 'Units\UnitSlideShowScanDirectoryThread.pas',
  VistaDialogInterfaces in 'Units\VistaDialogInterfaces.pas',
  VistaFileDialogs in 'Units\VistaFileDialogs.pas',
  UnitDBFileDialogs in 'Units\UnitDBFileDialogs.pas',
  UnitSendMessageWithTimeoutThread in 'Units\UnitSendMessageWithTimeoutThread.pas',
  VRSIShortCuts in 'Units\VRSIShortCuts.pas',
  UnitCDMappingSupport in 'Units\UnitCDMappingSupport.pas',
  uThreadForm in 'Units\uThreadForm.pas',
  uThreadEx in 'Threads\uThreadEx.pas',
  uAssociatedIcons in 'Threads\uAssociatedIcons.pas',
  uLogger in 'Units\uLogger.pas',
  uConstants in 'Units\uConstants.pas',
  uFileUtils in 'Units\uFileUtils.pas',
  uScript in 'Units\uScript.pas',
  uStringUtils in 'Units\uStringUtils.pas',
  UnitLoadDBKernelIconsThread in 'Threads\UnitLoadDBKernelIconsThread.pas',
  UnitLoadDBSettingsThread in 'Threads\UnitLoadDBSettingsThread.pas',
  UnitLoadCRCCheckThread in 'Threads\UnitLoadCRCCheckThread.pas',
  uFastLoad in 'Units\uFastLoad.pas',
  uResources in 'Units\uResources.pas',
  uExplorerThreadPool in 'Threads\uExplorerThreadPool.pas',
  uGOM in 'Units\uGOM.pas',
  uListViewUtils in 'Units\uListViewUtils.pas',
  FreeBitmap in 'External\Formats\FreeImage\FreeBitmap.pas',
  FreeImage in 'External\Formats\FreeImage\FreeImage.pas',
  FreeUtils in 'External\Formats\FreeImage\FreeUtils.pas',
  uDBDrawing in 'Units\uDBDrawing.pas',
  uList64 in 'Units\uList64.pas',
  uThreadLoadingManagerDB in 'Threads\uThreadLoadingManagerDB.pas',
  uW7TaskBar in 'Units\uW7TaskBar.pas',
  uDBHint in 'Units\uDBHint.pas',
  uMath in 'Units\uMath.pas',
  ASN1 in 'External\Crypt\DECv5.2\ASN1.pas',
  CPU in 'External\Crypt\DECv5.2\CPU.pas',
  CRC in 'External\Crypt\DECv5.2\CRC.pas',
  DECCipher in 'External\Crypt\DECv5.2\DECCipher.pas',
  DECData in 'External\Crypt\DECv5.2\DECData.pas',
  DECFmt in 'External\Crypt\DECv5.2\DECFmt.pas',
  DECHash in 'External\Crypt\DECv5.2\DECHash.pas',
  DECRandom in 'External\Crypt\DECv5.2\DECRandom.pas',
  DECUtil in 'External\Crypt\DECv5.2\DECUtil.pas',
  TypInfoEx in 'External\Crypt\DECv5.2\TypInfoEx.pas',
  uStrongCrypt in 'Units\uStrongCrypt.pas',
  uMemory in 'Units\uMemory.pas',
  uDBForm in 'Units\uDBForm.pas',
  uTranslate in 'Units\uTranslate.pas',
  uImageConvertThread in 'Threads\uImageConvertThread.pas',
  uWatermarkOptions in 'uWatermarkOptions.pas' {FrmWatermarkOptions},
  uSearchThreadPool in 'Threads\uSearchThreadPool.pas',
  uMultiCPUThreadManager in 'Threads\uMultiCPUThreadManager.pas',
  uFormListView in 'Units\uFormListView.pas',
  uDBThread in 'Threads\uDBThread.pas',
  uGraphicUtils in 'Units\uGraphicUtils.pas',
  UnitActiveTableThread in 'Threads\UnitActiveTableThread.pas',
  uImageSource in 'Units\uImageSource.pas',
  uDBPopupMenuInfo in 'Units\uDBPopupMenuInfo.pas',
  uPrivateHelper in 'Units\uPrivateHelper.pas',
  CCR.Exif.Consts in 'External\CCR.Exif\CCR.Exif.Consts.pas',
  CCR.Exif.IPTC in 'External\CCR.Exif\CCR.Exif.IPTC.pas',
  CCR.Exif in 'External\CCR.Exif\CCR.Exif.pas',
  CCR.Exif.StreamHelper in 'External\CCR.Exif\CCR.Exif.StreamHelper.pas',
  CCR.Exif.TagIDs in 'External\CCR.Exif\CCR.Exif.TagIDs.pas',
  CCR.Exif.XMPUtils in 'External\CCR.Exif\CCR.Exif.XMPUtils.pas',
  uPNGUtils in 'Units\uPNGUtils.pas',
  uFormUtils in 'Units\uFormUtils.pas',
  uShellUtils in '..\Installer\uShellUtils.pas',
  uInstallTypes in '..\Installer\uInstallTypes.pas',
  uInstallScope in '..\Installer\uInstallScope.pas',
  uDBBaseTypes in 'Units\uDBBaseTypes.pas',
  uDBUtils in 'Units\uDBUtils.pas',
  uAssociations in '..\Installer\uAssociations.pas',
  uAppUtils in 'Units\uAppUtils.pas',
  uEditorTypes in 'ImageEditor\uEditorTypes.pas',
  uShellIntegration in 'Units\uShellIntegration.pas',
  uSysUtils in 'Units\uSysUtils.pas',
  uDBTypes in 'Units\uDBTypes.pas',
  uActivationUtils in 'Units\uActivationUtils.pas',
  uDBFileTypes in 'Units\uDBFileTypes.pas',
  uRuntime in 'Units\uRuntime.pas',
  uDBGraphicTypes in 'Units\uDBGraphicTypes.pas',
  uStenography in 'Units\uStenography.pas',
  uInternetUtils in 'Units\uInternetUtils.pas',
  uViewerTypes in 'Units\uViewerTypes.pas',
  uDXUtils in 'Units\dx\uDXUtils.pas',
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
  uSearchTypes in 'Units\uSearchTypes.pas',
  uCryptUtils in 'Units\uCryptUtils.pas',
  uResourceUtils in 'Units\uResourceUtils.pas',
  uMobileUtils in 'Units\uMobileUtils.pas',
  uFrmConvertationLanding in 'Convertation\uFrmConvertationLanding.pas' {FrmConvertationLanding: TFrame},
  uFrmConvertationSettings in 'Convertation\uFrmConvertationSettings.pas' {FrmConvertationSettings: TFrame},
  uFrmConvertationProgress in 'Convertation\uFrmConvertationProgress.pas' {FrmConvertationProgress: TFrame},
  uFrmSelectDBLanding in 'SelectDB\uFrmSelectDBLanding.pas' {FrmSelectDBLanding: TFrame},
  uFrmSelectDBNewPathAndIcon in 'SelectDB\uFrmSelectDBNewPathAndIcon.pas' {FrmSelectDBNewPathAndIcon: TFrame},
  uFrmSelectDBFromList in 'SelectDB\uFrmSelectDBFromList.pas' {FrmSelectDBFromList: TFrame},
  uFrmSelectDBExistedFile in 'SelectDB\uFrmSelectDBExistedFile.pas' {FrmSelectDBExistedFile: TFrame},
  uFrmSelectDBCreationSummary in 'SelectDB\uFrmSelectDBCreationSummary.pas' {FrmSelectDBCreationSummary: TFrame},
  uInterfaces in 'Units\uInterfaces.pas',
  uDBAdapter in 'Units\uDBAdapter.pas',
  uCDMappingTypes in 'Units\uCDMappingTypes.pas',
  uMemoryEx in 'Units\uMemoryEx.pas',
  uDBShellUtils in 'Units\uDBShellUtils.pas',
  uDBImageUtils in 'Units\uDBImageUtils.pas',
  uFormSteganography in 'uFormSteganography.pas' {FormSteganography},
  uFrmSteganographyLanding in 'Steganography\uFrmSteganographyLanding.pas' {FrmSteganographyLanding: TFrame},
  uFrmCreatePNGSteno in 'Steganography\uFrmCreatePNGSteno.pas' {FrmCreatePNGSteno: TFrame},
  uFrmCreateJPEGSteno in 'Steganography\uFrmCreateJPEGSteno.pas' {FrmCreateJPEGSteno: TFrame},
  uStenoLoadImageThread in 'Threads\uStenoLoadImageThread.pas',
  uFrmImportImagesLanding in 'ImportImages\uFrmImportImagesLanding.pas' {FrmImportImagesLanding: TFrame},
  uFrmImportImagesOptions in 'ImportImages\uFrmImportImagesOptions.pas' {FrmImportImagesOptions: TFrame},
  uFrmImportImagesProgress in 'ImportImages\uFrmImportImagesProgress.pas' {FrmImportImagesProgress: TFrame},
  uIME in 'Units\uIME.pas',
  uGetPhotosThread in 'Threads\uGetPhotosThread.pas',
  uSearchHelpAddPhotosThread in 'Threads\uSearchHelpAddPhotosThread.pas',
  uExifUtils in 'Units\uExifUtils.pas',
  uExifPatchThread in 'Threads\uExifPatchThread.pas',
  uTiffImage in 'Units\uTiffImage.pas',
  uJpegUtils in 'Units\uJpegUtils.pas',
  uBitmapUtils in 'Units\uBitmapUtils.pas',
  uIconUtils in 'Units\uIconUtils.pas',
  uWinThumbnails in 'Units\uWinThumbnails.pas',
  uShellThumbnails in 'Units\uShellThumbnails.pas',
  uMachMask in 'Units\uMachMask.pas',
  VCLFlickerReduce in 'Units\VCLFlickerReduce.pas',
  ExplorerUnit in 'ExplorerUnit.pas' {ExplorerForm},
  uDatabaseSearch in 'Units\uDatabaseSearch.pas',
  uFaceDetection in 'Units\uFaceDetection.pas',
  uFaceDetectionThread in 'Threads\uFaceDetectionThread.pas';

{$R *.res}

var
  S1: string;

function IsFalidDBFile : boolean;
begin
  Result := True;
end;

function FileVersion : integer;
begin
  Result := ReleaseNumber;
end;

procedure StopApplication;
begin
  CloseSplashWindow;
  DBTerminating := True;
end;

procedure FindRunningVersion;
var
  HSemaphore : THandle;
  MessageToSent : string;
  CD : TCopyDataStruct;
  Buf: Pointer;
  P : PByte;
begin
  SetLastError(0);
  HSemaphore := CreateSemaphore( nil, 0, 1, PChar(DBID));
  if ((HSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    CloseHandle(HSemaphore);

    if FindWindow(nil, PChar(DBID)) <> 0 then
    begin

      if ParamStr(1) = '' then
        MessageToSent := 'Activate'
      else
        MessageToSent := ParamStr(1) + #1 + ParamStr(2);

        cd.dwData := WM_COPYDATA_ID;
        cd.cbData := SizeOf(TMsgHdr) + ((Length(MessageToSent) + 1) * SizeOf(Char));
        GetMem(Buf, cd.cbData);
        try
          P := PByte(Buf);
          Integer(P) := Integer(P) + SizeOf(TMsgHdr);

          StrPLCopy(PChar(P), MessageToSent, Length(MessageToSent));
          cd.lpData := Buf;

          if SendMessageEx(FindWindow(nil, PChar(DBID)), WM_COPYDATA, 0, LongInt(@cd)) then
          begin
            CloseSplashWindow;
            DBTerminating := True;
          end else
          begin
            CloseSplashWindow;
            if ID_YES <> MessageBoxDB(0, TA('This program is running, but isn''t responding! Run new instance?', 'System'), TA('Error'), TD_BUTTON_YESNO, TD_ICON_ERROR) then
              DBTerminating := True;
          end;

        finally
          FreeMem(Buf);
        end;
    end;
  end;
end;

exports
  IsFalidDBFile name 'IsFalidDBFile',
  FileVersion name 'FileVersion';

begin
  try
    //FullDebugModeScanMemoryPoolBeforeEveryOperation := True;
    //ReportMemoryLeaksOnShutdown := True;
  {
   //Command line

   /OPTIMIZE_DUBLICTES
   /SHOWBADLINKS
   /RECREATETHTABLE
   /BACKUP
   /PACKTABLE
   /CONVERT
   /SLEEP
   /SAFEMODE
   /UNINSTALL
   /EXPLORER
   /GETPHOTOS
   /NOLOGO
   /NoPrevVersion
   /NoFaultCheck
   /NoFullRun
   /Execute "c:\script.dbscript"
   /NoVistaMsg
   /NoVistaFileDlg
   /SelectDB "DBFile"
   /SelectDB "DBName"
   /SelectDBPermanent
   /ADD "file"
   /ADD "directory"
   /AddPass "pass1!pass2!..."
   /Logging
   /SQLExec
   /SQLExecFile
  }
    TW.I.Start('START');

    EventLog('');
    EventLog('');
    EventLog('');
    EventLog(Format('Program running! [%s]', [ProductName]));

    if FolderView then
      DBID := ReadInternalFSContent('ID');
    // Lazy init enviroment procedure
    TW.i.Start('TScriptEnviroments');
    TScriptEnviroments.Instance.GetEnviroment('').SetInitProc(InitEnviroment);

    LOGGING_ENABLED := GetParamStrDBBool('/Logging');
    if LOGGING_ENABLED then
      EventLog(Format('Program logging enabled!! [%s]', [ProductName]))
    else
      EventLog('Program logging DISABLED! Run program with param "/Logging"');

    // PREPAIRING ----------------------------------------------------

    if GetParamStrDBBool('/SLEEP') then
      Sleep(1000);

    SetSplashProgress(15);
    TW.i.Start('Application.Initialize');
    Application.Initialize;
    SetSplashProgress(30);

    EventLog(Format('Folder View = %s', [BoolToStr(FolderView)]));

    TW.I.Start('FindRunningVersion');
    if not GetParamStrDBBool('/NoPrevVersion') then
      FindRunningVersion;

    TW.i.Start('InitializeDBLoadScript');
    if not DBTerminating then
    begin
      EventLog('TDBKernel.Create');
      DBKernel := TDBKernel.Create;
      TW.I.Start('DBKernel.DBInit');
      DBKernel.DBInit;

      TW.I.Start('SetSplashProgress 35');
      SetSplashProgress(45);

      TLoad.Instance.StartDBKernelIconsThread;
      TLoad.Instance.StartDBSettingsThread;

      SetSplashProgress(60);

      TW.I.Start('TFormManager Create');
      Application.CreateForm(TFormManager, FormManager);
  Application.ShowMainForm := False;
      // This is main form of application

      TW.I.Start('SetSplashProgress 70');
      SetSplashProgress(70);
    end;

    TW.I.Start('GetCIDA');
    SetSplashProgress(90);

    EventLog('...GROUPS CHECK + MENU...');
    // DB FAULT ----------------------------------------------------

    TW.I.Start('CHECKS');

    // SERVICES ----------------------------------------------------
    CMDInProgress := True;

    if not FolderView and not DBTerminating and GetParamStrDBBool('/install') then
    begin
      if not FileExistsSafe(dbname) then
      begin
        s1 := IncludeTrailingBackslash(GetMyDocumentsPath) + TA('My collection') + '.photodb';
        CreateExampleDB(s1, Application.ExeName + ',0', ExtractFileDir(Application.ExeName));
        DBKernel.AddDB(TA('My collection'), s1, Application.ExeName + ',0');
        DBKernel.SetDataBase(s1);
      end;

      StopApplication;
    end;

    if not FolderView and not DBTerminating then
      if not GetParamStrDBBool('/NoFaultCheck') then
        if (Settings.ReadProperty('Starting', 'ApplicationStarted') = '1')
          and not DBInDebug then
        begin
          EventLog('Application terminated...');
          if ID_OK = MessageBoxDB(FormManager.Handle, TA('There was an error closing previous instance of this program! Check database file for errors?', 'System'), TA('Error'), TD_BUTTON_OKCANCEL, TD_ICON_ERROR) then
          begin
            CloseSplashWindow;
            Settings.WriteBool('StartUp', 'Pack', False);
            Application.CreateForm(TCMDForm, CMDForm);
            CMDForm.PackPhotoTable;
            R(CMDForm);
          end;
        end;

    if not FolderView and not DBTerminating then
      if GetParamStrDBBool('/CONVERT') or Settings.ReadBool('StartUp',
        'ConvertDB', False) then
      begin
        CloseSplashWindow;
        EventLog('Converting...');
        Settings.WriteBool('StartUp', 'ConvertDB', False);
        ConvertDB(dbname);
      end;

    if not FolderView and not DBTerminating then
      if GetParamStrDBBool('/PACKTABLE') or Settings.ReadBool('StartUp', 'Pack', False) then
      begin
        CloseSplashWindow;
        EventLog('Packing...');
        Settings.WriteBool('StartUp', 'Pack', False);
        Application.CreateForm(TCMDForm, CMDForm);
        CMDForm.PackPhotoTable;
        R(CMDForm);
      end;

    if not FolderView and not DBTerminating then
      if GetParamStrDBBool('/BACKUP') or Settings.ReadBool('StartUp', 'BackUp', False) then
      begin
        CloseSplashWindow;
        EventLog('BackUp...');
        Settings.WriteBool('StartUp', 'BackUp', False);
        Application.CreateForm(TCMDForm, CMDForm);
        CMDForm.BackUpTable;
        R(CMDForm);
      end;

    if not FolderView and not DBTerminating then
      if GetParamStrDBBool('/RECREATETHTABLE') or Settings.ReadBool('StartUp', 'RecreateIDEx', False) then
      begin
        CloseSplashWindow;
        EventLog('Recreating thumbs in Table...');
        Settings.WriteBool('StartUp', 'RecreateIDEx', False);
        Application.CreateForm(TCMDForm, CMDForm);
        CMDForm.RecreateImThInPhotoTable;
        R(CMDForm);
      end;

    if not FolderView and not DBTerminating then
      if GetParamStrDBBool('/SHOWBADLINKS') or Settings.ReadBool('StartUp', 'ScanBadLinks', False) then
      begin
        CloseSplashWindow;
        EventLog('Show Bad Links in table...');
        Settings.WriteBool('StartUp', 'ScanBadLinks', False);
        Application.CreateForm(TCMDForm, CMDForm);
        CMDForm.ShowBadLinks;
        R(CMDForm);
      end;

    if not FolderView and not DBTerminating then
      if GetParamStrDBBool('/OPTIMIZE_DUBLICTES') or Settings.ReadBool('StartUp', 'OptimizeDublicates', False) then
      begin
        CloseSplashWindow;
        EventLog('Optimizingdublicates in table...');
        Settings.WriteBool('StartUp', 'OptimizeDublicates', False);
        Application.CreateForm(TCMDForm, CMDForm);
        CMDForm.OptimizeDublicates;
        R(CMDForm);
      end;

    if not FolderView and not DBTerminating then
      if Settings.ReadBool('StartUp', 'Restore', False) then
      begin
        CloseSplashWindow;
        Settings.WriteBool('StartUp', 'Restore', False);
        EventLog('Restoring Table...' + Settings.ReadString('StartUp', 'RestoreFile'));
        Application.CreateForm(TCMDForm, CMDForm);
        CMDForm.RestoreTable(Settings.ReadString('StartUp', 'RestoreFile'));
        R(CMDForm);
      end;

    CMDInProgress := False;

    // PREPAIRING RUNNING DB ----------------------------------------

    SetSplashProgress(100);

    If DBTerminating then
      Application.ShowMainForm := False;
    If not DBTerminating then
    begin
      EventLog('Form manager...');
      TW.I.Start('Form manager...');
      FormManager.Load;
    end;

    // THEMES AND RUNNING DB ---------------------------------------------

    TW.I.Start('THEMES AND RUNNING DB');

    If not DBTerminating then
    begin
      EventLog('Run manager...');
      if not GetParamStrDBBool('/NoFullRun') or FolderView then
        FormManager.Run;

      if GetParamStrDBBool('/SLEEP') then
        ActivateBackgroundApplication(Application.Handle);

      if not DBTerminating and not FolderView then
      begin
        if AnsiUpperCase(ParamStr(1)) = '/GETPHOTOS' then
          if ParamStr(2) <> '' then
            GetPhotosFromDrive(ParamStr(2)[1]);
      end;
    end;
    EventLog('Application Started!...');

    if GetParamStrDBBool('/Execute') then
    begin
      ExecuteScriptFile(SysUtils.AnsiDequotedStr(GetParamStrDBValue('/Execute'), '"'));
    end;

    if GetParamStrDBBool('/AddPass') then
    begin
      DBKernel.GetPasswordsFromParams;
    end;

    s1 := SysUtils.AnsiDequotedStr(GetParamStrDBValue('/Add'), '"');

    if (s1 <> '') and FileExistsEx(s1) then
    begin
      FormManager.RegisterMainForm(UpdaterDB.Form);
      UpdaterDB.AddFile(s1);
    end;

    if (s1 <> '') and DirectoryExists(s1) then
    begin
      FormManager.RegisterMainForm(UpdaterDB.Form);
      UpdaterDB.AddDirectory(s1, nil);
    end;

    if GetParamStrDBBool('/SQLExec') then
    begin
      ExecuteQuery(SysUtils.AnsiDequotedStr(GetParamStrDBValue('/SQLExec'), '"'));
    end;

    if GetParamStrDBBool('/SQLExecFile') then
    begin
      s1 := SysUtils.AnsiDequotedStr(GetParamStrDBValue('/SQLExecFile'), '"');
      s1 := ReadTextFileInString(s1);
      ExecuteQuery(s1);
    end;

    if GetParamStrDBBool('/CPU1') then
      ProcessorCount := 1;

    TW.I.Start('AllowDragAndDrop');
    AllowDragAndDrop;

    TW.I.Start('Application.Run');

    if not DBTerminating then
      Application.Run;

    if DBTerminating then
      begin
        TLoad.Instance.RequaredDBKernelIcons;
        TLoad.Instance.RequaredCRCCheck;
        TLoad.Instance.RequaredDBSettings;
      end;

  except
    on e : Exception do
    begin
      ShowMessage('Fatal error: ' + e.Message);
    end;
  end;
end.
