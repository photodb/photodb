program PhotoDB;

{$DEFINE DEBUG}

uses
  Bde,
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
  createuserunit in 'createuserunit.pas' {NewSingleUserForm},
  SlideShowFullScreen in 'SlideShowFullScreen.pas' {FullScreenView},
  unitid in 'unitid.pas' {IDForm},
  activation in 'activation.pas' {ActivateForm},
  ExplorerUnit in 'ExplorerUnit.pas' {ExplorerForm},
  InstallFormUnit in 'InstallFormUnit.pas' {InstallForm},
  SetupProgressUnit in 'SetupProgressUnit.pas' {SetupProgressForm},
  UnInstallFormUnit in 'UnInstallFormUnit.pas' {UnInstallForm},
  UnitUpdateDB in 'UnitUpdateDB.pas' {UpdateDBForm},
  about in 'about.pas' {AboutForm},
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
  UserRightsEditorUnit in 'UserRightsEditorUnit.pas' {UserRightEditorForm},
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
  UnitFormCanvasSize in 'UnitFormCanvasSize.pas' {FormCanvasSize},
  UnitActionsForm in 'Units\UnitActionsForm.pas' {ActionsForm},
  UnitSplitExportForm in 'UnitSplitExportForm.pas' {SplitExportForm},
  UnitDebugScriptForm in 'UnitDebugScriptForm.pas' {DebugScriptForm},
  UnitTIFFOptionsUnit in 'UnitTIFFOptionsUnit.pas' {TIFFOptionsForm},
  UnitImportingImagesForm in 'UnitImportingImagesForm.pas' {FormImportingImages},
  UnitConvertDBForm in 'UnitConvertDBForm.pas' {FormConvertingDB},
  UnitRangeDBSelectForm in 'UnitRangeDBSelectForm.pas' {FormDateRangeSelectDB},
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
  Global_FastIO in 'External\Formats\DelphiDcraw\Global_FastIO.pas',
  GlobalTypes in 'External\Formats\DelphiDcraw\GlobalTypes.pas',
  GIFImage in 'External\Formats\GIFImage.pas',
  PNG_IO in 'External\Formats\PNG_IO.pas',
  PngDef in 'External\Formats\PngDef.pas',
  PngImage in 'External\Formats\PNGImage.pas',
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
  ThreadManeger in 'Units\ThreadManeger.pas',
  dolphin_db in 'Units\dolphin_db.pas',
  UnitDBKernel in 'Units\UnitDBKernel.pas',
  CmpUnit in 'Units\CmpUnit.pas',
  DBCMenu in 'Units\DBCMenu.pas',
  win32crc in 'Units\win32crc.pas',
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
  OLE2 in 'Units\ole2.pas',
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
  BitmapDB in 'Units\BitmapDB.pas',
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
  uScript in 'KernelDll\uScript.pas',
  uStringUtils in 'Units\uStringUtils.pas',
  uTime in 'Units\uTime.pas',
  UnitLoadDBKernelIconsThread in 'Threads\UnitLoadDBKernelIconsThread.pas',
  UnitLoadDBSettingsThread in 'Threads\UnitLoadDBSettingsThread.pas';

{$R *.res}

type
    TInitializeProc = function(s:PChar) : integer;
    TInitializeAProc = function(s:PChar) : boolean;

var
    s1 : string;
    Reg : TBDRegistry;
    hw : THandle;
    cd : TCopyDataStruct;
    rec : TRecToPass;
    hSemaphore:thandle;
    name : string;
    actcode : string;
    initproc : TInitializeProc;
    initaproc : TInitializeAProc;
    TablePacked : boolean;    
    ActivKey, ActivName, AllParams : String;
    aHandle : Thandle;
    i : integer;
    CheckResult : integer;
    //FAST LOAD
    LoadDBKernelIconsThread,
    LoadDBSettingsThread : THandle;

  f : TPcharFunction;
  Fh : pointer;
  p : PChar;
  k : integer;

function IsFalidDBFile : boolean;
begin
 Result:=true;
end;

function FileVersion : integer;
begin
 Result:=ReleaseNumber;
end;

Procedure FindRunningVersion;
begin
  Name := DBID;
  hSemaphore := CreateSemaphore( nil, 0, 1, pchar(name));
  if ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
   CloseHandle(hSemaphore); 
   if not CheckFileExistsWithMessageEx(ParamStr(1),false) then
   begin
    If (AnsiUpperCase(ParamStr(1))<>'/EXPLORER') and (AnsiUpperCase(ParamStr(1))<>'/GETPHOTOS') then
    begin
     if FindWindow(nil, DBID)<>0 then
     begin
      hw:=FindWindow(nil, DBID);
      rec.s := 'Activate';
      rec.i := 32;
      cd.dwData := 3232;
      cd.cbData := sizeof(rec);
      cd.lpData := @rec;
      if SendMessageEx(hw, WM_COPYDATA, 0, LongInt(@cd)) then
      begin
       halt;
      end else
      begin
       if ID_YES<>MessageBoxDB(0,TEXT_MES_APPLICATION_PREV_FOUND_BUT_SEND_MES_FAILED,TEXT_MES_ERROR, TD_BUTTON_YESNO, TD_ICON_ERROR) then halt;
      end;
     end;
    end else
    begin
      hw:=FindWindow(nil, DBID);
      rec.s := ParamStr(1)+#0+ParamStr(2);
      rec.i := 32;
      cd.dwData := 3232;
      cd.cbData := sizeof(rec);
      cd.lpData := @rec;
      if SendMessageEx(hw, WM_COPYDATA, 0, LongInt(@cd)) then
      begin
       halt;
      end else
      begin
       if ID_YES<>MessageBoxDB(0,TEXT_MES_APPLICATION_PREV_FOUND_BUT_SEND_MES_FAILED,TEXT_MES_ERROR, TD_BUTTON_YESNO, TD_ICON_ERROR) then halt;
      end;
    end;
    Exit;
   end;
   if FindWindow(nil, DBID)=0 then
   begin
    i:=0;
    Repeat
     Sleep(100);
     Inc(i,100);
     hSemaphore := CreateSemaphore( nil, 0, 1, PChar(Name));
     IF ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) THEN
     BEGIN
      CloseHandle(hSemaphore);
     end else break;
     if i>10000 then Halt; //more than 10 second -> exit;
    until (FindWindow(nil, DBID)<>0);
   end;
  end;
  hw := FindWindow(nil, DBID);
  if hw<>0 then
  begin
   rec.s := ParamStr(1)+#0+ParamStr(2);
   rec.i := 32;
   cd.dwData := 3232;
   cd.cbData := sizeof(rec);
   cd.lpData := @rec;
   if SendMessageEx(hw, WM_COPYDATA, 0, LongInt(@cd)) then
   begin
    halt;
   end else
   begin
    if ID_YES<>MessageBoxDB(0,TEXT_MES_APPLICATION_PREV_FOUND_BUT_SEND_MES_FAILED,TEXT_MES_ERROR, TD_BUTTON_YESNO, TD_ICON_ERROR) then halt;
   end;
   Exit;
  end;
end;

exports
 IsFalidDBFile name 'IsFalidDBFile',
 FileVersion name 'FileVersion';

begin
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
  TW.I.Start('CoInitialize');

  ProgramDir := ExtractFileDir(Application.ExeName) + '\';

  EventLog('');
  EventLog('');
  EventLog('');
  EventLog(Format('Program running! [%s]',[ProductName]));

  TScriptEnviroments.Instance.GetEnviroment('').SetInitProc(InitEnviroment);
            
  if GetParamStrDBBool('/Logging') then
  begin
   EventLog(Format('Program logging enabled!! [%s]',[ProductName]));
   LOGGING_ENABLED:=true;
  end else
  begin
   EventLog('Program logging DISABLED! Run program with param "/Logging"');
   LOGGING_ENABLED := false;
  end;
  AllParams:='';
  for i := 0 to 250 do
  if ParamStr(i)<>'' then
  AllParams:=AllParams+' '+ParamStr(i) else break;
  EventLog('Program params :'+AllParams);
  //PREPAIRING ----------------------------------------------------

  TablePacked:=false;
  If GetParamStrDBBool('/SLEEP') then Sleep(1000);
  SafeMode:=False;
  If GetParamStrDBBool('/SAFEMODE') then SafeMode:=True;

  EventLog(Format('Safe mode = %s',[BoolToStr(SafeMode)]));

  ProgramDir:=GetDirectory(Application.ExeName);
  DBTerminating:=false;     
  DBKernel:=nil;
            
  TW.I.Start('InitializeDBLoadScript');
  InitializeDBLoadScript;
  LoadingAboutForm:=nil;
  // INITIALIZAING APPLICATION

  if GetDBViewMode then
  begin
   FolderView:=true;
   UseScripts:=false;
  end;          
  TW.I.Start('Application.Initialize');
  Application.Initialize;

  EventLog(Format('Folder View = %s',[BoolToStr(FolderView)]));

  //INSTALL ----------------------------------------------------

  if not FolderView then
  if not Emulation then
  if not DBInDebug then
  begin
   EventLog('...INSTALL COMPARING...');
   If not ThisFileInstalled then
   begin
    if (AnsiUpperCase(ExtractFileName(Application.ExeName))<>'SETUP.EXE') and not EmulationInstall then
    begin
     if ID_YES=MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_PROGRAMM_NOT_INSTALLED,TEXT_MES_ERROR,TD_BUTTON_YESNO,TD_ICON_ERROR) then
     begin
      EventLog('Loading Kernel.dll');
      KernelHandle:=loadlibrary(PChar(ProgramDir+'Kernel.dll'));
      if KernelHandle=0 then
      begin
       EventLog('KernelHandle IS 0 -> exit');
       MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_ERROR_KERNEL_DLL,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
       Halt;
      end;
      DBKernel:=TDBKernel.Create;
      DBKernel.LoadColorTheme;
      Application.CreateForm(TInstallForm, InstallForm);
  Application.Restore;
      EventLog(':InstallForm.SetQuickSelfInstallOption()');
      InstallForm.SetQuickSelfInstallOption;
      InstallForm.ShowModal;
      InstallForm.Release;
      if UseFreeAfterRelease then InstallForm.free;
      InstallForm:=nil;
      DBTerminating:=True;
      Halt;
     end else
     begin
      DBTerminating:=True;
      Halt;
     end;
    end else
    begin               
     EventLog('Loading Kernel.dll');
     KernelHandle:=loadlibrary(PChar(ProgramDir+'Kernel.dll'));
     if KernelHandle=0 then
     begin                
      EventLog('KernelHandle IS 0 -> exit');
      MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_ERROR_KERNEL_DLL,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
      Halt;
     end;
     DBKernel:=TDBKernel.Create;
     DBKernel.LoadColorTheme;
     if Length(GetDirectory(Application.ExeName))>200 then
     begin  
      MessageBoxDB(Dolphin_DB.GetActiveFormHandle,PChar(Format(TEXT_MES_PATH_TOO_LONG,[GetDirectory(Application.ExeName)])),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
     end;
     Application.CreateForm(TInstallForm, InstallForm);
     Application.Restore;
     InstallForm.ShowModal;
     InstallForm.Release;
     if UseFreeAfterRelease then InstallForm.free;
     InstallForm:=nil;
     Halt;
    end;
   end;
  end;
  EventLog(':BDEInstalled()');
           
  //UNINSTALL ----------------------------------------------------
           
  EventLog('...UNINSTALL COMPARING...');
  If ThisFileInstalled and GetParamStrDBBool('/UNINSTALL') and not DBTerminating then
  begin
   If ID_YES=MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_UNINSTALL_CONFIRM,TEXT_MES_WARNING,TD_BUTTON_YESNO,TD_ICON_WARNING) then
   begin
    AExplorerFolders.Free;
    AExplorerFolders:=nil;
    Application.CreateForm(TUnInstallForm, UnInstallForm);
    Application.Restore;
    UnInstallForm.ShowModal;
    UnInstallForm.Release;
    if UseFreeAfterRelease then UnInstallForm.free;
    UnInstallForm:=nil;
   end;
   Halt;
  end;
           
  TW.I.Start('FindRunningVersion');
  if not SafeMode then
  if not GetParamStrDBBool('/NoPrevVersion') then
  FindRunningVersion;

  if not GetParamStrDBBool('/NoLogo') then
  begin
  TW.I.Start('TAboutForm');
   Application.CreateForm(TAboutForm, LoadingAboutForm);
   LoadingAboutForm.FormStyle := fsStayOnTop;
   TAboutForm(LoadingAboutForm).CloseButton.Visible:=false;  
  TW.I.Start('LoadingAboutForm.Show');
   LoadingAboutForm.Show;
  TW.I.Start('Application.Restore');
   Application.Restore;     
  TW.I.Start('Application.ProcessMessages');
   Application.ProcessMessages;
   TAboutForm(LoadingAboutForm).DmProgress1.MaxValue:=8;
  end else LoadingAboutForm:=nil;

            
  TW.I.Start('Kernel.dll');
  
  //CHECK DEMO MODE ----------------------------------------------------
  {$IFDEF DEBUG}
  EventLog('...CHECK DEMO MODE...');
  {$ENDIF}
  if not DBTerminating then
  begin
   EventLog('Loading Kernel.dll');
   if not FolderView then
   KernelHandle:=loadlibrary(PChar(ProgramDir+'Kernel.dll'));
   DBKernel:=TDBKernel.Create;
   TW.I.Start('DBKernel.LogIn');
   DBKernel.LogIn('','',true);
   LoadDBKernelIconsThread := TLoadDBKernelIconsThread.Create(False).ThreadID;
   LoadDBSettingsThread := TLoadDBSettingsThread.Create(False).ThreadID;
   EventLog(':DBKernel.LoadColorTheme');
   TW.I.Start('DBKernel.LoadColorThem');
   DBKernel.LoadColorTheme;
  end;

  if not FolderView then
  if not DBTerminating then
  If IsInstalling then
  begin     
   EventLog('IsInstalling IS true -> exit');
   MessageBoxDB(GetActiveFormHandle,TEXT_MES_SETUP_RUNNING,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   Application.Terminate;
   DBTerminating:=True;
  end;
  if not DBTerminating then
  if not FolderView then
  if KernelHandle=0 then
  begin
   EventLog('KernelHandle IS 0 -> exit');
   MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_ERROR_KERNEL_DLL,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   Halt;
  end;

  if ThisFileInstalled or DBInDebug or Emulation or GetDBViewMode then
  begin
   ProgramDir:=GetDirectory(ParamStr(0));
   AExplorerFolders := TExplorerFolders.Create;
  end;

   TW.I.Start('GetCIDA');

  if not FolderView then
  for k:=1 to 10 do
  begin
   Fh:=GetProcAddress(KernelHandle,'GetCIDA');
   if fh=nil then
   begin
    MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_ERROR_KERNEL_DLL,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
    halt;
    exit;
   end;
   @f:=Fh;
   p:=f;
  end;
          
   TW.I.Start('Initialize');

  {$IFDEF DEBUG}
  EventLog('...CHECK GetCIDA...');
  {$ENDIF}
  if LoadingAboutForm<>nil then TAboutForm(LoadingAboutForm).DmProgress1.Position:=1;
  if not FolderView then
  If not DBTerminating then
  begin
   @initproc := GetProcAddress(KernelHandle,'Initialize');

   GetMem(p,Length(Application.ExeName)+1);
   FillChar(p[0],Length(Application.ExeName)+1,#0);

   for k:=0 to Length(Application.ExeName)-1 do
   p[k]:=Application.ExeName[k+1];
   initproc(PChar(Application.ExeName));
   for k:=1 to 10 do
   begin
    {$IFDEF DEBUG}
    EventLog('...:GetCIDA('+IntToStr(k)+')...');
    {$ENDIF}
    Fh:=GetProcAddress(KernelHandle,'GetCIDA');
    if fh=nil then
    begin
     MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_ERROR_KERNEL_DLL,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     halt;
     exit;
    end;
    @f:=Fh;
    p:=f;
   end;

   {$IFDEF DEBUG}
   EventLog('...Get [Registration] Key and User Name...');
   {$ENDIF}
   Reg:=TBDRegistry.Create(REGISTRY_CLASSES,true);
   if PortableWork then
   begin
    ActivKey:='\CLSID';
    ActivName:='Key';
   end else
   begin
    ActivKey:='\CLSID\'+ActivationID;
    ActivName:='DefaultHandle';
   end;
   {$IFDEF DEBUG}
   EventLog('...ActivKey = '+ActivKey);   
   EventLog('...ActivName = '+ActivName);
   {$ENDIF}
   try
    Reg.OpenKey(ActivKey,true);
    ActCode:=Reg.ReadString(ActivName);
   except
    on e : Exception do EventLog(':PhotoDB() throw exception: '+e.Message);
   end;
   Reg.free;
   EventLog(':FindRunningVersion()');
  end;

  EventLog('...Loading menu...');

  if LoadingAboutForm<>nil then
  begin
    TAboutForm(LoadingAboutForm).DmProgress1.Position:=2;
     TW.I.Start('LoadRegistrationData');
    if not FolderView then
      TAboutForm(LoadingAboutForm).LoadRegistrationData;
  end;
  //LOGGING ----------------------------------------------------
               
     TW.I.Start('LoadingAboutForm.Free');
  EventLog('...LOGGING...');
  if not FolderView then
  if not DBInDebug then
  if not DBTerminating then
  If DBKernel.ProgramInDemoMode then
  begin
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   EventLog('Loading About...');
   if AboutForm= nil then
   Application.CreateForm(TAboutForm, AboutForm);
   AboutForm.Execute;
   AboutForm.Release;
   if UseFreeAfterRelease then AboutForm.Free;
   AboutForm:=nil;
  end;
  if LoadingAboutForm<>nil then TAboutForm(LoadingAboutForm).DmProgress1.Position:=3;
  {$IFDEF DEBUG}
  //DEBUGGING
  //LOGGING_MESSAGE:=true;
  {$ENDIF}
                   
  TW.I.Start('CHECK APPDATA DIRECTORY');

  //CHECK APPDATA DIRECTORY
  EventLog('...CHECK APPDATA DIRECTORY...');
  if not DirectoryExists(GetAppDataDirectory) then
  begin
   try
    CreateDirA(GetAppDataDirectory);
   except
    MessageBoxDB(Dolphin_DB.GetActiveFormHandle,Format(ERROR_CREATING_APP_DATA_DIRECTORY_MAY_NE_PROBLEMS,[GetAppDataDirectory]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   end;
  end;
  EventLog('...CHECK APPDATA TEMP DIRECTORY...');
  if not DirectoryExists(GetAppDataDirectory+TempFolder) then
  begin
   try
    CreateDirA(GetAppDataDirectory+TempFolder);
   except
    MessageBoxDB(Dolphin_DB.GetActiveFormHandle,Format(ERROR_CREATING_APP_DATA_DIRECTORY_TEMP_MAY_BE_PROBLEMS,[GetAppDataDirectory+TempFolder]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   end;
  end;
  if LoadingAboutForm<>nil then TAboutForm(LoadingAboutForm).DmProgress1.Position:=4;


  EventLog('Login...');
  if not FolderView then
  If not DBTerminating then
  begin
   EventLog(':DBKernel.FixLoginDB()');
   if LoadingAboutForm<>nil then TAboutForm(LoadingAboutForm).DmProgress1.Position:=6;

  end;
  //GROUPS CHECK + MENU----------------------------------------------------
                
  EventLog('...GROUPS CHECK + MENU...');
         
  TW.I.Start('IsValidGroupsTable');

  if not SafeMode then
  begin
   try
    if not DBTerminating then
    if not IsValidGroupsTable then
    if ThisFileInstalled then
    CreateGroupsTable;
   except    
    on e : Exception do EventLog(':PhotoDB() throw exception: '+e.Message);
   end;
  end;
  if LoadingAboutForm<>nil then TAboutForm(LoadingAboutForm).DmProgress1.Position:=7;
  //DB FAULT ----------------------------------------------------
         
   TW.I.Start('CHECKS');

  if not FolderView then
  if not DBTerminating then
  if not GetParamStrDBBool('/NoFaultCheck') then
  if (DBKernel.ReadProperty('Starting','ApplicationStarted')='1') and not DBInDebug then
  begin
   EventLog('Application terminated...');
   if LoadingAboutForm<>nil then
   aHandle:=LoadingAboutForm.Handle else aHandle:=0;
   if ID_OK=MessageBoxDB(aHandle,TEXT_MES_APPLICATION_FAILED,TEXT_MES_ERROR,TD_BUTTON_OKCANCEL,TD_ICON_ERROR) then
   begin
    LoadingAboutForm.Free;
    LoadingAboutForm:=nil;
    TablePacked:=true;
    DBkernel.WriteBool('StartUp','Pack',False);
    Application.CreateForm(TCMDForm, CMDForm);
    CMDForm.PackPhotoTable;
    CMDForm.Release;
    if UseFreeAfterRelease then CMDForm.Free;
    CMDForm:=nil;
   end;
  end;

  //SERVICES ----------------------------------------------------

  if not DBTerminating then
  If GetParamStrDBBool('/CONVERT') or DBKernel.ReadBool('StartUp','ConvertDB',False) then
  if not TablePacked then
  begin
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   EventLog('Converting...');
   DBkernel.WriteBool('StartUp','ConvertDB',False);
   ConvertDB(dbname);
  end;

  if not DBTerminating then
  If GetParamStrDBBool('/PACKTABLE') or DBKernel.ReadBool('StartUp','Pack',False) then
  if not TablePacked then
  begin
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   EventLog('Packing...');
   DBkernel.WriteBool('StartUp','Pack',False);
   Application.CreateForm(TCMDForm, CMDForm);
   CMDForm.PackPhotoTable;
   CMDForm.Release;
   if UseFreeAfterRelease then CMDForm.Free;
   CMDForm:=nil;
  end;

  if not DBTerminating then
  If GetParamStrDBBool('/BACKUP') or DBKernel.ReadBool('StartUp','BackUp',False) then
  if not TablePacked then
  begin   
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   EventLog('BackUp...');
   DBkernel.WriteBool('StartUp','BackUp',False);
   Application.CreateForm(TCMDForm, CMDForm);
   CMDForm.BackUpTable;
   CMDForm.Release;
   if UseFreeAfterRelease then CMDForm.Free;
   CMDForm:=nil;
  end;

  if not DBTerminating then
  If GetParamStrDBBool('/RECREATETHTABLE') or DBKernel.ReadBool('StartUp','RecreateIDEx',False) then
  begin
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   EventLog('Recreating thumbs in Table...');
   DBkernel.WriteBool('StartUp','RecreateIDEx',False);
   Application.CreateForm(TCMDForm, CMDForm);
   CMDForm.RecreateImThInPhotoTable;
   CMDForm.Release;
   if UseFreeAfterRelease then CMDForm.Free;
   CMDForm:=nil;
  end;
  
  if not DBTerminating then
  If GetParamStrDBBool('/SHOWBADLINKS') or DBKernel.ReadBool('StartUp','ScanBadLinks',False) then
  begin    
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   EventLog('Show Bad Links in table...');
   DBkernel.WriteBool('StartUp','ScanBadLinks',False);
   Application.CreateForm(TCMDForm, CMDForm);
   CMDForm.ShowBadLinks;
   CMDForm.Release;
   if UseFreeAfterRelease then CMDForm.Free;
   CMDForm:=nil;
  end;

  if not DBTerminating then
  If GetParamStrDBBool('/OPTIMIZE_DUBLICTES') or DBKernel.ReadBool('StartUp','OptimizeDublicates',False) then
  begin     
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   EventLog('Optimizingdublicates in table...');
   DBkernel.WriteBool('StartUp','OptimizeDublicates',False);
   Application.CreateForm(TCMDForm, CMDForm);
   CMDForm.OptimizeDublicates;
   CMDForm.Release;
   if UseFreeAfterRelease then CMDForm.Free;
   CMDForm:=nil;
  end;
  
  if not DBTerminating then
  If DBKernel.ReadBool('StartUp','Restore',False) then
  begin      
   LoadingAboutForm.Free;
   LoadingAboutForm:=nil;
   DBkernel.WriteBool('StartUp','Restore',False);
   EventLog('Restoring Table...'+DBkernel.ReadString('StartUp','RestoreFile'));
   Application.CreateForm(TCMDForm, CMDForm);
   CMDForm.RestoreTable(DBkernel.ReadString('StartUp','RestoreFile'));
   CMDForm.Release;
   if UseFreeAfterRelease then CMDForm.Free;
   CMDForm:=nil;
  end;

 //DEMO? ----------------------------------------------------

   TW.I.Start('DEMO');

 if LoadingAboutForm<>nil then
   TAboutForm(LoadingAboutForm).DmProgress1.Position:=8;
 if not FolderView then
 If not DBTerminating then
 if not DBInDebug then
 if not Emulation then
 begin
  EventLog('Verifyng....');
  @initAproc := GetProcAddress(KernelHandle,'InitializeA');
  if not initAproc(PChar(Application.ExeName)) then
  begin
   MessageBoxDB(GetActiveFormHandle,TEXT_MES_APPLICATION_NOT_VALID,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   DBTerminating:=True;
   Application.Terminate;
  end;
 end;

  TW.I.Start('WaitForSingleObjects -> LoadDBKernelIconsThread');
  WaitForSingleObject(LoadDBKernelIconsThread, INFINITE);
  TW.I.Start('WaitForSingleObjects -> LoadDBSettingsThread');
  WaitForSingleObject(LoadDBSettingsThread, INFINITE);
  TDBNullQueryThread.Create(False);
                        
  TW.I.Start('LoadingAboutForm.FREE');

  //PREPAIRING RUNNING DB ----------------------------------------
  if LoadingAboutForm<>nil then
  begin
    LoadingAboutForm.Free;
    LoadingAboutForm:=nil;
  end;

 If DBTerminating then
 Application.ShowMainForm:=False;
 If not DBTerminating then
 begin
  EventLog('Form manager...');
  TW.I.Start('Form manager...');
  Application.CreateForm(TFormManager, FormManager);
  If not DBTerminating then
  begin
   EventLog('ID Form...');
   TW.I.Start('ID Form...');
   Application.CreateForm(TIDForm, IDForm);
  end;
 end;

 //THEMES AND RUNNING DB ---------------------------------------------
                 
  TW.I.Start('THEMES AND RUNNING DB');

 If not DBTerminating then
 begin
  EventLog('Run manager...');
  if not GetParamStrDBBool('/NoFullRun') then
  FormManager.Run(LoadingAboutForm);
  if not SafeMode then
  begin
   EventLog('Theme...');
   DBkernel.LoadColorTheme;
   DBkernel.ReloadGlobalTheme;
  end;
  If not DBTerminating then
  begin
   if AnsiUpperCase(ParamStr(1))='/GETPHOTOS' then
   if ParamStr(2)<>'' then
   GetPhotosFromDrive(ParamStr(2)[1]);
  end;
 end;
 EventLog('Application Started!...');

 if GetParamStrDBBool('/Execute') then
 begin
  ExecuteScriptFile(SysUtils.AnsiDequotedStr(GetParamStrDBValue('/Execute'),'"'));
 end;

 if GetParamStrDBBool('/AddPass') then
 begin
  DBKernel.GetPasswordsFromParams;
 end;

 s1:=SysUtils.AnsiDequotedStr(GetParamStrDBValue('/Add'),'"');
 
 if FileExistsEx(s1) then
 begin            
  Running:=true;
  If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
  FormManager.RegisterMainForm(UpdaterDB.Form);
  UpdaterDB.AddFile(s1);
 end;

 if DirectoryExists(s1) then
 begin     
  Running:=true;
  If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
  FormManager.RegisterMainForm(UpdaterDB.Form);
  UpdaterDB.AddDirectory(s1,nil);
 end;

 if GetParamStrDBBool('/SQLExec') then
 begin
  Dolphin_DB.ExecuteQuery(SysUtils.AnsiDequotedStr(GetParamStrDBValue('/SQLExec'),'"'));
 end;
   
 if GetParamStrDBBool('/SQLExecFile') then
 begin
  s1:=SysUtils.AnsiDequotedStr(GetParamStrDBValue('/SQLExecFile'),'"');
  s1:=ReadTextFileInString(s1);
  Dolphin_DB.ExecuteQuery(s1);
 end;

  Application.Run;
end.
