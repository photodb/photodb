REM  d:
REM  cd "D:\Dmitry\Delphi exe\Photo Database"

SET PLAYER=MEDIA_PLAYER
SET DELPHI=C:\Program Files (x86)\Embarcadero\Studio\17.0
SET DCC32=%DELPHI%\BIN\DCC32.EXE
SET DCC64=%DELPHI%\BIN\DCC64.EXE
SET BRCC32=%DELPHI%\BIN\BRCC32.EXE
SET NS=-NSSystem;System.Win;WinAPI;Vcl;Vcl.Imaging;Data;Xml;Data.Win;Vcl.Shell;Vcl.Samples;Soap
SET JNG=%cd%\Tools\GraphicToJNG\GraphicToJNG.exe
cd photodb/resources

REM JNG FILES - BEGIN
"%JNG%" logo.PNG logo.JNG
"%JNG%" loading.PNG loading.JNG
"%BRCC32%" logo.rc
"%BRCC32%" Loading.rc
REM JNG FILES - END

"%BRCC32%" ExplorerBackground.rc
"%BRCC32%" Manifest.rc
"%BRCC32%" ImagePanelBackground.rc
"%BRCC32%" Install.rc
"%BRCC32%" PhotoDBInstall.rc
"%BRCC32%" Activation.rc
"%BRCC32%" PrinterPattern.rc
"%BRCC32%" BigPattern.rc
"%BRCC32%" Film_strip.rc
"%BRCC32%" explorer_search.rc
"%BRCC32%" PathSeparator.rc
"%BRCC32%" PicturesImport.rc
"%BRCC32%" SharePictures.rc
"%BRCC32%" NoHistogram.rc
"%BRCC32%" Import.rc
"%BRCC32%" CollectionSync.rc
"%BRCC32%" ExplorerItems.rc
"%BRCC32%" FaceMask.rc

cd ..
cd ..
cd ExecCommand
"%DCC32%" %NS% ExecCommand -N0"..\PhotoDB\dcu" -$I+ -$O+ 
cd ..
cd PhotoDB

cd dcu
del *.dcu
cd ..
cd ..

cd Uninstall
"%DCC32%" %NS% UnInstall -D"UNINSTALL;DBDEBUG" -E"..\PhotoDB\bin" -N0"\PhotoDB\dcu" -U"..\Dmitry" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd Bridge
"%DCC32%" %NS% PhotoDBBridge -E"..\PhotoDB\bin" -N0"\PhotoDB\dcu" -U"..\Dmitry" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd Installer
"%DCC32%" %NS% InstallMaker -D"EXTERNAL;DBDEBUG;%PLAYER%" -N0"..\dcu" -U"..\Dmitry" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..


rem cd TransparentEncryption
rem "%DCC32%" %NS% TransparentEncryption -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
rem "%DCC64%" %NS% TransparentEncryption64 -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
rem "%DCC32%" %NS% PlayEncryptedMedia -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
rem "%DCC64%" %NS% PlayEncryptedMedia64 -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
rem cd ..

cd PhotoDB

move photodb.cfg photodb.cfg.safe
"%DCC32%" %NS% photodb -D"PHOTODB;LICENCE;DEBUG;FullDebugMode;DBDEBUG" -Ebin -V -VN -GD -W -N0dcu --inline:on -U"..\Dmitry";"External\Mustangpeak\EasyListview\Source";"External\Mustangpeak\Common Library\Source";"External\Controls\DragDrop\Source";"External\Controls\Image Controls\Source";"External\FastMM;"External\scalemm";"External\Controls\virtual-treeview\Common;"External\jcl\source\windows";"External\jcl\source\common" -I"External\jcl\source\include" -R"Resources";"..\DBIcons";"%DELPHI%\Lib" -$D- -$I+ -$O- -$R+ -$W+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
move photodb.cfg.safe photodb.cfg 

cd ..
cd ExecCommand
ExecCommand "..\photodb\bin\sign.txt"
cd ..
cd PhotoDB

cd CRCCalculator
"%DCC32%" %NS% CRCCalculator -N0"..\dcu" -U"..\Dmitry" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
CRCCalculator.exe "..\bin\PhotoDB.exe" "..\KernelDLL\FileCRC.pas"
cd ..

cd KernelDLL
"%DCC32%" %NS% Kernel -E"..\bin" -N0"..\dcu" -U"..\Dmitry" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd dcu
del *.dcu
cd ..

cd ..
cd Installer
InstallMaker SETUP$ZIP.dat
rem use VS resource compiler because borland's fails on big files
RC SETUP_ZIP.rc
"%DCC32%" %NS% Install -D"INSTALL;%PLAYER%;DBDEBUG" -N0"..\PhotoDB\dcu" -U"..\Dmitry" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM

InstallMaker /setup Install.exe
rem use VS resource compiler because borland's fails on big files
RC Install_Package.rc
"%DCC32%" %NS% PhotoDBInstall -E".." -D"INSTALL;DBDEBUG" -N0"..\PhotoDB\dcu" -U"..\Dmitry" -$D- -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM

cd ..
cd PhotoDB

pause