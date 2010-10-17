program PhotoDB;

{$DESCRIPTION 'Photo DB v2.3'}

uses
  FastMM4,
  uInit in 'Units\uInit.pas',
  uTime in 'Units\uTime.pas',
  uSplashThread in 'Threads\uSplashThread.pas',
  ADODB,
  FileCtrl,
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
  Grids,
  DBGrids,
  Menus,
  ExtCtrls,
  StdCtrls,
  ImgList,
  ComCtrls,
  ActiveX,
  ShlObj,
  DBCtrls,
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
  ExplorerUnit in 'ExplorerUnit.pas' {ExplorerForm},
  InstallFormUnit in 'InstallFormUnit.pas' {InstallForm},
  SetupProgressUnit in 'SetupProgressUnit.pas' {SetupProgressForm},
  UnInstallFormUnit in 'UnInstallFormUnit.pas' {UnInstallForm},
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
  UnitImageConverter in 'UnitImageConverter.pas' {FormConvertImages},
  UnitJPEGOptions in 'UnitJPEGOptions.pas' {FormJpegOptions},
  UnitRotateImages in 'UnitRotateImages.pas' {FormRotateImages},
  DX_Alpha in 'Units\dx\DX_Alpha.pas' {DirectShowForm},
  UnitFormInternetUpdating in 'UnitFormInternetUpdating.pas' {FormInternetUpdating},
  UnitHelp in 'UnitHelp.pas' {HelpPopup},
  ProgressActionUnit in 'ProgressActionUnit.pas' {ProgressActionForm},
  ImEditor in 'ImageEditor\ImEditor.pas' {ImageEditor},
  ExEffectFormUnit in 'ImageEditor\ExEffectFormUnit.pas' {ExEffectForm},
  UnitEditorFullScreenForm in 'UnitEditorFullScreenForm.pas' {EditorFullScreenForm},
  UnitExportImagesForm in 'UnitExportImagesForm.pas' {ExportImagesForm},
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
  UnitTIFFOptionsUnit in 'UnitTIFFOptionsUnit.pas' {TIFFOptionsForm},
  UnitImportingImagesForm in 'UnitImportingImagesForm.pas' {FormImportingImages},
  UnitConvertDBForm in 'UnitConvertDBForm.pas' {FormConvertingDB},
  UnitBigImagesSize in 'UnitBigImagesSize.pas' {BigImagesSizeForm},
  UnitStenoGraphia in 'UnitStenoGraphia.pas' {FormSteno},
  Loadingresults in 'Threads\Loadingresults.pas',
  UnitCleanUpThread in 'Threads\UnitCleanUpThread.pas',
  UnitLoadFilesToPanel in 'Threads\UnitLoadFilesToPanel.pas',
  EmptyDeletedThreadUnit in 'Threads\EmptyDeletedThreadUnit.pas',
  UnitHintCeator in 'Threads\UnitHintCeator.pas',
  UnitCmpDB in 'Threads\UnitCmpDB.pas',
  ExplorerThreadUnit in 'Threads\ExplorerThreadUnit.pas',
  UnitInstallThread in 'Threads\UnitInstallThread.pas',
  UnitUnInstallThread in 'Threads\UnitUnInstallThread.pas',
  UnitPackingTable in 'Threads\UnitPackingTable.pas',
  UnitUpdateDBThread in 'Threads\UnitUpdateDBThread.pas',
  UnitExportThread in 'Threads\UnitExportThread.pas',
  UnitBackUpTableThread in 'Threads\UnitBackUpTableThread.pas',
  UnitTerminationApplication in 'Threads\UnitTerminationApplication.pas',
  UnitExplorerThumbnailCreatorThread in 'Threads\UnitExplorerThumbnailCreatorThread.pas',
  UnitSaveQueryThread in 'Threads\UnitSaveQueryThread.pas',
  UnitRecreatingThInTable in 'Threads\UnitRecreatingThInTable.pas',
  UnitDirectXSlideShowCreator in 'Threads\UnitDirectXSlideShowCreator.pas',
  UnitViewerThread in 'Threads\UnitViewerThread.pas',
  UnitInternetUpdate in 'Threads\UnitInternetUpdate.pas',
  UnitRestoreTableThread in 'Threads\UnitRestoreTableThread.pas',
  UnitWindowsCopyFilesThread in 'Threads\UnitWindowsCopyFilesThread.pas',
  UnitThreadShowBadLinks in 'Threads\UnitThreadShowBadLinks.pas',
  UnitGetNewFilesInFolderThread in 'Threads\UnitGetNewFilesInFolderThread.pas',
  UnitActiveTableThread in 'Threads\UnitActiveTableThread.pas',
  UnitBackUpTableInCMD in 'Threads\UnitBackUpTableInCMD.pas',
  UnitOpenQueryThread in 'Threads\UnitOpenQueryThread.pas',
  UnitOptimizeDublicatesThread in 'Threads\UnitOptimizeDublicatesThread.pas',
  ConvertDBThreadUnit in 'Threads\ConvertDBThreadUnit.pas',
  UnitConvertImagesThread in 'Threads\UnitConvertImagesThread.pas',
  UnitPropertyLoadImageThread in 'Threads\UnitPropertyLoadImageThread.pas',
  UnitPropertyLoadGistogrammThread in 'Threads\UnitPropertyLoadGistogrammThread.pas',
  UnitScanImportPhotosThread in 'Threads\UnitScanImportPhotosThread.pas',
  UnitRefreshDBRecordsThread in 'Threads\UnitRefreshDBRecordsThread.pas',
  UnitCryptingImagesThread in 'Threads\UnitCryptingImagesThread.pas',
  UnitRotatingImagesThread in 'Threads\UnitRotatingImagesThread.pas',
  UnitPanelLoadingBigImagesThread in 'Threads\UnitPanelLoadingBigImagesThread.pas',
  UnitDBNullQueryThread in 'Threads\UnitDBNullQueryThread.pas',
  UnitFileExistsThread in 'Threads\UnitFileExistsThread.pas',
  UnitSlideShowUpdateInfoThread in 'Threads\UnitSlideShowUpdateInfoThread.pas',
  UnitCDExportThread in 'Threads\UnitCDExportThread.pas',
  UnitSearchBigImagesLoaderThread in 'Threads\UnitSearchBigImagesLoaderThread.pas',
  Scpanel in 'External\Controls\scpanel\Scpanel.pas',
  GraphicEx in 'External\Formats\GraphicEx\GraphicEx.pas',
  GraphicColor in 'External\Formats\GraphicEx\GraphicColor.pas',
  GraphicCompression in 'External\Formats\GraphicEx\GraphicCompression.pas',
  GraphicStrings in 'External\Formats\GraphicEx\GraphicStrings.pas',
  JPG in 'External\Formats\GraphicEx\JPG.pas',
  MZLib in 'External\Formats\GraphicEx\MZLib.pas',
  TiffImageUnit in 'External\Formats\TiffImageUnit.pas',
  LibDelphi in 'External\Formats\Tiff\LibDelphi.pas',
  LibJpegDelphi in 'External\Formats\Tiff\LibJpegDelphi.pas',
  LibTiffDelphi in 'External\Formats\Tiff\LibTiffDelphi.pas',
  ZLibDelphi in 'External\Formats\Tiff\ZLibDelphi.pas',
  RAWImage in 'External\Formats\DelphiDcraw\RAWImage.pas',
  GIFImage in 'External\Formats\GIFImage.pas',
  PNG_IO in 'External\Formats\PNG_IO.pas',
  PngDef in 'External\Formats\PngDef.pas',
  PNGImage in 'External\Formats\PNGImage.pas',
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
  GraphicsBaseTypes in 'ImageEditor\GraphicsBaseTypes.pas',
  GBlur2 in 'ImageEditor\GBlur2.pas',
  EffectsLanguage in 'ImageEditor\EffectsLanguage.pas',
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
  rxtypes in 'SelfDelete\rxtypes.pas',
  SelfDeleteUnit in 'SelfDelete\SelfDeleteUnit.pas',
  uVistaFuncs in 'Units\uVistaFuncs.pas',
  dEXIF in 'Units\dEXIF.pas',
  dIPTC in 'Units\dIPTC.pas',
  msData in 'Units\msData.pas',
  dolphin_db in 'Units\dolphin_db.pas',
  UnitDBKernel in 'Units\UnitDBKernel.pas',
  CmpUnit in 'Units\CmpUnit.pas',
  DBCMenu in 'Units\DBCMenu.pas',
  ExplorerTypes in 'Units\ExplorerTypes.pas',
  UnitGroupsWork in 'Units\UnitGroupsWork.pas',
  Language in 'Units\Language.pas',
  UnitGroupsReplace in 'Units\UnitGroupsReplace.pas',
  UnitBitmapImageList in 'Units\UnitBitmapImageList.pas',
  Network in 'Units\Network.pas',
  GraphicCrypt in 'Units\GraphicCrypt.pas',
  UnitCrypting in 'Units\UnitCrypting.pas',
  ShellContextMenu in 'Units\ShellContextMenu.pas',
  ImageConverting in 'Units\ImageConverting.pas',
  DDraw in 'Units\DDraw.pas',
  ole2 in 'Units\ole2.pas',
  DXCommon in 'Units\DXCommon.pas',
  Exif in 'Units\Exif.pas',
  UnitLinksSupport in 'Units\UnitLinksSupport.pas',
  GDIPlusRotate in 'Units\GDIPlusRotate.pas',
  UnitGroupsTools in 'Units\UnitGroupsTools.pas',
  UnitSQLOptimizing in 'Units\UnitSQLOptimizing.pas',
  CommonDBSupport in 'Units\CommonDBSupport.pas',
  UnitScripts in 'Units\UnitScripts.pas',
  ReplaseLanguageInScript in 'Units\ReplaseLanguageInScript.pas',
  ReplaseIconsInScript in 'Units\ReplaseIconsInScript.pas',
  DBScriptFunctions in 'Units\DBScriptFunctions.pas',
  UnitScriptsFunctions in 'Units\UnitScriptsFunctions.pas',
  UnitImageActions in 'Units\UnitImageActions.pas',
  UnitReadingActions in 'Units\UnitReadingActions.pas',
  UnitUpdateDBObject in 'Units\UnitUpdateDBObject.pas',
  UnitTimeCounter in 'Units\UnitTimeCounter.pas',
  VirtualSystemImageLists in 'Units\VirtualSystemImageLists.pas',
  acWorkRes in 'Units\acWorkRes.pas',
  UnitPropeccedFilesSupport in 'Units\UnitPropeccedFilesSupport.pas',
  UnitINI in 'Units\UnitINI.pas',
  UnitDBRedeclare in 'Units\UnitDBRedeclare.pas',
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
  WindowsIconCacheTools in 'Units\WindowsIconCacheTools.pas',
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
  UnitExplorerLoadSingleImageThread in 'Threads\UnitExplorerLoadSingleImageThread.pas',
  UnitDBThread in 'Units\UnitDBThread.pas',
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
  uDBImages in 'Units\uDBImages.pas',
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
  jpegdec in 'Units\jpegdec.pas',
  uMemory in 'Units\uMemory.pas',
  uDBForm in 'Units\uDBForm.pas',
  uTranslate in 'Units\uTranslate.pas',
  MSXML2_TLB in 'External\Xml\MSXML2_TLB.pas',
  OmniXML_MSXML in 'External\Xml\OmniXML_MSXML.pas',
  uImageConvertThread in 'Threads\uImageConvertThread.pas',
  uWatermarkOptions in 'uWatermarkOptions.pas' {FrmWatermarkOptions},
  AddSessionPasswordUnit in 'AddSessionPasswordUnit.pas' {AddSessionPasswordForm},
  uSearchThreadPool in 'Threads\uSearchThreadPool.pas',
  uMultiCPUThreadManager in 'Threads\uMultiCPUThreadManager.pas',
  uFormListView in 'Units\uFormListView.pas';

{$R *.res}

type
    TInitializeAProc = function(s:PChar) : boolean;

var
    S1: string;
{$IFDEF LICENCE}
    Initaproc: TInitializeAProc;
{$ENDIF}

function IsFalidDBFile : boolean;
begin
  Result := True;
end;

function FileVersion : integer;
begin
  Result := ReleaseNumber;
end;

procedure FindRunningVersion;
var
  HSemaphore : THandle;
  MessageToSent : string;
  CD : TCopyDataStruct;
  Buf: Pointer;
  P : PByte;
begin
  HSemaphore := CreateSemaphore( nil, 0, 1, PChar(DBID));
  if ((HSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    CloseHandle(HSemaphore);

    if (AnsiUpperCase(ParamStr(1)) <> '/EXPLORER') and (AnsiUpperCase(ParamStr(1)) <> '/GETPHOTOS') and (FindWindow(nil, DBID) <> 0) then
      MessageToSent := 'Activate'
    else
      MessageToSent := ParamStr(1) + #0 + ParamStr(2);

      cd.dwData := WM_COPYDATA_ID;
      cd.cbData := SizeOf(TMsgHdr) + ((Length(MessageToSent) + 1) * SizeOf(Char));
      GetMem(Buf, cd.cbData);
      try
        P := PByte(Buf);
        Integer(P) := Integer(P) + SizeOf(TMsgHdr);

        StrPLCopy(PChar(P), MessageToSent, Length(MessageToSent));
        cd.lpData := Buf;

        SplashThread.Terminate;
        if SendMessageEx(FindWindow(nil, DBID), WM_COPYDATA, 0, LongInt(@cd)) then
        begin
          Application.Terminate;
        end else
          if ID_YES <> MessageBoxDB(0, TEXT_MES_APPLICATION_PREV_FOUND_BUT_SEND_MES_FAILED, TEXT_MES_ERROR, TD_BUTTON_YESNO, TD_ICON_ERROR) then
          begin
            Application.Terminate;
          end;
      finally
        FreeMem(Buf);
      end;

  end;
end;

exports
  IsFalidDBFile name 'IsFalidDBFile',
  FileVersion name 'FileVersion';

begin
//  ReportMemoryLeaksOnShutdown := True;
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
  TW.i.Start('START');

  EventLog('');
  EventLog('');
  EventLog('');
  EventLog(Format('Program running! [%s]', [ProductName]));

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

  SetSplashProgress(5);
  TW.i.Start('InitializeDBLoadScript');
  InitializeDBLoadScript;
  // INITIALIZAING APPLICATION

  if GetDBViewMode then
  begin
    FolderView := True;
    // TODO: !!! UseScripts := False;
  end;

  SetSplashProgress(10);
  TW.i.Start('Application.Initialize');
  Application.Initialize;
  SetSplashProgress(15);

  EventLog(Format('Folder View = %s', [BoolToStr(FolderView)]));

  // INSTALL ----------------------------------------------------

  if not FolderView and not Emulation and not DBInDebug then
  begin
    EventLog('...INSTALL COMPARING...');
    If not ThisFileInstalled then
    begin
      if (AnsiUpperCase(ExtractFileName(Application.ExeName))
          <> 'SETUP.EXE') and not EmulationInstall then
      begin
        if ID_YES = MessageBoxDB(dolphin_db.GetActiveFormHandle,
          TEXT_MES_PROGRAMM_NOT_INSTALLED, TEXT_MES_ERROR, TD_BUTTON_YESNO,
          TD_ICON_ERROR) then
        begin
          EventLog('Loading Kernel.dll');
          KernelHandle := loadlibrary(PChar(ProgramDir + 'Kernel.dll'));
          if KernelHandle = 0 then
          begin
            EventLog('KernelHandle IS 0 -> exit');
            MessageBoxDB(dolphin_db.GetActiveFormHandle,
              TEXT_MES_ERROR_KERNEL_DLL, TEXT_MES_ERROR, TD_BUTTON_OK,
              TD_ICON_ERROR);
            Halt;
          end;
          DBKernel := TDBKernel.Create;
          DBKernel.LoadColorTheme;
          Application.CreateForm(TInstallForm, InstallForm);
  Application.Restore;
          EventLog(':InstallForm.SetQuickSelfInstallOption()');
          InstallForm.SetQuickSelfInstallOption;
          InstallForm.ShowModal;
          InstallForm.Release;
          InstallForm := nil;
          DBTerminating := True;
          Halt;
        end
        else
        begin
          DBTerminating := True;
          Halt;
        end;
      end
      else
      begin
        EventLog('Loading Kernel.dll');
        KernelHandle := loadlibrary(PChar(ProgramDir + 'Kernel.dll'));
        if KernelHandle = 0 then
        begin
          EventLog('KernelHandle IS 0 -> exit');
          MessageBoxDB(dolphin_db.GetActiveFormHandle,
            TEXT_MES_ERROR_KERNEL_DLL, TEXT_MES_ERROR, TD_BUTTON_OK,
            TD_ICON_ERROR);
          Halt;
        end;
        DBKernel := TDBKernel.Create;
        DBKernel.LoadColorTheme;
        if Length(GetDirectory(Application.ExeName)) > 200 then
        begin
          MessageBoxDB(Dolphin_DB.GetActiveFormHandle, PWideChar(Format(TEXT_MES_PATH_TOO_LONG, [GetDirectory(Application.ExeName)])), TEXT_MES_WARNING, TD_BUTTON_OK, TD_ICON_WARNING);
        end;
        Application.CreateForm(TInstallForm, InstallForm);
        Application.Restore;
        InstallForm.ShowModal;
        InstallForm.Release;
        InstallForm := nil;
        Halt;
      end;
    end;
  end;

  // UNINSTALL ----------------------------------------------------

  EventLog('...UNINSTALL COMPARING...');
  If ThisFileInstalled and GetParamStrDBBool('/UNINSTALL')
    and not DBTerminating then
  begin
    If ID_YES = MessageBoxDB(dolphin_db.GetActiveFormHandle,
      TEXT_MES_UNINSTALL_CONFIRM, TEXT_MES_WARNING, TD_BUTTON_YESNO,
      TD_ICON_WARNING) then
    begin
      AExplorerFolders.free;
      AExplorerFolders := nil;
      Application.CreateForm(TUnInstallForm, UnInstallForm);
      Application.Restore;
      UnInstallForm.ShowModal;
      UnInstallForm.Release;
      UnInstallForm := nil;
    end;
    Halt;
  end;

  EventLog('TDBKernel.Create');
  DBKernel := TDBKernel.Create;
  TW.i.Start('DBKernel.LogIn');
  DBKernel.LogIn('', '', True);
  TLoad.Instance.StartDBKernelIconsThread;
  TLoad.Instance.StartDBSettingsThread;
  SetSplashProgress(25);

  TW.i.Start('FindRunningVersion');
  if not GetParamStrDBBool('/NoPrevVersion') then
    FindRunningVersion;

  TW.i.Start('SetSplashProgress 35');
  SetSplashProgress(35);

  // This is main form of application
  TW.i.Start('TFormManager Create');
  Application.CreateForm(TFormManager, FormManager);
  Application.ShowMainForm := False;

  TW.i.Start('SetSplashProgress 50');
  SetSplashProgress(50);

  TW.i.Start('Kernel');
  // CHECK DEMO MODE ----------------------------------------------------
  if not DBTerminating then
  begin
    //EventLog(':DBKernel.InitRegModule');
    //TW.i.Start('InitRegModule');
    // TODO: LATER!!!! DBKernel.InitRegModule;
    EventLog(':DBKernel.LoadColorTheme');
    TW.i.Start('DBKernel.LoadColorThem');
    DBKernel.LoadColorTheme;
  end;
  TW.i.Start('SetSplashProgress 70');
  SetSplashProgress(70);

  if not FolderView then
    if not DBTerminating then
      If IsInstalling then
      begin
        EventLog('IsInstalling IS true -> exit');
        MessageBoxDB(GetActiveFormHandle, TEXT_MES_SETUP_RUNNING,
          TA('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
        Application.Terminate;
        DBTerminating := True;
      end;

  if ThisFileInstalled or DBInDebug or Emulation or GetDBViewMode then
    AExplorerFolders := TExplorerFolders.Create;

  TW.i.Start('GetCIDA');
  SetSplashProgress(90);

  TW.i.Start('LoadingAboutForm.Free');
  EventLog('...LOGGING...');
  if not FolderView then
    if not DBInDebug then
      if not DBTerminating then
        if DBKernel.ProgramInDemoMode then
          TSplashThread(SplashThread).ShowDemoInfo;

  EventLog('...GROUPS CHECK + MENU...');
  TW.i.Start('IsValidGroupsTable');

  try
    if not DBTerminating then
      if not IsValidGroupsTable then
        if ThisFileInstalled then
          CreateGroupsTable;
  except
    on e: Exception do
      EventLog(':PhotoDB() throw exception: ' + e.Message);
  end;
  // DB FAULT ----------------------------------------------------

  TW.i.Start('CHECKS');

  if not FolderView then
    if not DBTerminating then
      if not GetParamStrDBBool('/NoFaultCheck') then
        if (DBKernel.ReadProperty('Starting', 'ApplicationStarted') = '1')
          and not DBInDebug then
        begin
          EventLog('Application terminated...');
          if ID_OK = MessageBoxDB(FormManager.Handle, TEXT_MES_APPLICATION_FAILED, TEXT_MES_ERROR, TD_BUTTON_OKCANCEL, TD_ICON_ERROR) then
          begin
            SplashThread.Terminate;
            DBKernel.WriteBool('StartUp', 'Pack', False);
            Application.CreateForm(TCMDForm, CMDForm);
            CMDForm.PackPhotoTable;
            CMDForm.Release;
            CMDForm := nil;
          end;
        end;

  // SERVICES ----------------------------------------------------

  if not DBTerminating then
    if GetParamStrDBBool('/CONVERT') or DBKernel.ReadBool('StartUp',
      'ConvertDB', False) then
    begin
      SplashThread.Terminate;
      EventLog('Converting...');
      DBKernel.WriteBool('StartUp', 'ConvertDB', False);
      ConvertDB(dbname);
    end;

  if not DBTerminating then
    if GetParamStrDBBool('/PACKTABLE') or DBKernel.ReadBool('StartUp', 'Pack', False) then
    begin
      SplashThread.Terminate;
      EventLog('Packing...');
      DBKernel.WriteBool('StartUp', 'Pack', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.PackPhotoTable;
      CMDForm.Release;
      CMDForm := nil;
    end;

  if not DBTerminating then
    if GetParamStrDBBool('/BACKUP') then
    begin
      SplashThread.Terminate;
      EventLog('BackUp...');
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.BackUpTable;
      CMDForm.Release;
      CMDForm := nil;
    end;

  if not DBTerminating then
    if GetParamStrDBBool('/RECREATETHTABLE') or DBKernel.ReadBool('StartUp', 'RecreateIDEx', False) then
    begin
      SplashThread.Terminate;
      EventLog('Recreating thumbs in Table...');
      DBKernel.WriteBool('StartUp', 'RecreateIDEx', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.RecreateImThInPhotoTable;
      CMDForm.Release;
      CMDForm := nil;
    end;

  if not DBTerminating then
    if GetParamStrDBBool('/SHOWBADLINKS') or DBKernel.ReadBool('StartUp', 'ScanBadLinks', False) then
    begin
      SplashThread.Terminate;
      EventLog('Show Bad Links in table...');
      DBKernel.WriteBool('StartUp', 'ScanBadLinks', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.ShowBadLinks;
      CMDForm.Release;
      CMDForm := nil;
    end;

  if not DBTerminating then
    if GetParamStrDBBool('/OPTIMIZE_DUBLICTES') or DBKernel.ReadBool('StartUp', 'OptimizeDublicates', False) then
    begin
      SplashThread.Terminate;
      EventLog('Optimizingdublicates in table...');
      DBKernel.WriteBool('StartUp', 'OptimizeDublicates', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.OptimizeDublicates;
      CMDForm.Release;
      CMDForm := nil;
    end;

  if not DBTerminating then
    if DBKernel.ReadBool('StartUp', 'Restore', False) then
    begin
      SplashThread.Terminate;
      DBKernel.WriteBool('StartUp', 'Restore', False);
      EventLog('Restoring Table...' + DBKernel.ReadString('StartUp', 'RestoreFile'));
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.RestoreTable(DBKernel.ReadString('StartUp', 'RestoreFile'));
      CMDForm.Release;
      CMDForm := nil;
    end;

  TW.i.Start('LoadingAboutForm.FREE');

  // PREPAIRING RUNNING DB ----------------------------------------

  SetSplashProgress(100);

  If DBTerminating then
    Application.ShowMainForm := False;
  If not DBTerminating then
  begin
    EventLog('Form manager...');
    TW.i.Start('Form manager...');
    FormManager.Load;
  end;

  // THEMES AND RUNNING DB ---------------------------------------------

  TW.i.Start('THEMES AND RUNNING DB');

  If not DBTerminating then
  begin
    EventLog('Theme...');
    DBKernel.LoadColorTheme;
    EventLog('Run manager...');
    if not GetParamStrDBBool('/NoFullRun') then
      FormManager.Run(SplashThread);

    if not DBTerminating then
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
    if UpdaterDB = nil then
      UpdaterDB := TUpdaterDB.Create;
    FormManager.RegisterMainForm(UpdaterDB.Form);
    UpdaterDB.AddFile(s1);
  end;

  if (s1 <> '') and DirectoryExists(s1) then
  begin
    if UpdaterDB = nil then
      UpdaterDB := TUpdaterDB.Create;
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

  TW.i.Start('AllowDragAndDrop');
  AllowDragAndDrop;

  TW.i.Start('Application.Run');
  Application.Run;

end.
