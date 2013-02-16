REM  d:
REM  cd "D:\Dmitry\Delphi exe\Photo Database"

SET PLAYER=MEDIA_PLAYER
SET DELPHI=C:\Program Files (x86)\Embarcadero\RAD Studio\10.0
SET PROGS=C:\Users\Public\Documents
SET DCC32=%DELPHI%\BIN\DCC32.EXE
SET DCC64=%DELPHI%\BIN\DCC64.EXE
SET BRCC32=%DELPHI%\BIN\BRCC32.EXE
SET DM=D:\dmitry\Dmitry
SET NS=-NSSystem;System.Win;WinAPI;Vcl;Vcl.Imaging;Data;Xml;Data.Win;Vcl.Shell;Vcl.Samples;Soap
cd photodb/resources
"%BRCC32%" logo.rc
"%BRCC32%" slideshow_load.rc
"%BRCC32%" ExplorerBackground.rc
"%BRCC32%" Manifest.rc
"%BRCC32%" ImagePanelBackground.rc
"%BRCC32%" Loading.rc
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
"%DCC32%" %NS% UnInstall -D"UNINSTALL" -E"..\PhotoDB\bin" -N0"\PhotoDB\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd Bridge
"%DCC32%" %NS% PhotoDBBridge -E"..\PhotoDB\bin" -N0"\PhotoDB\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd Installer
"%DCC32%" %NS% InstallMaker -D"EXTERNAL;%PLAYER%" -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd PhotoDB

move photodb.cfg photodb.cfg.safe
"%DCC32%" %NS% photodb -D"PHOTODB;LICENCE" -Ebin -W -N0dcu --inline:on -U"%DM%";"%PROGS%\Mustangpeak\EasyListview\Source";"%PROGS%\Mustangpeak\Common Library\Source";"External\Controls\DragDrop\Source";"External\Controls\Image Controls\Source";"External\FastMM";"External\Controls\virtual-treeview\Common";"External\jcl\source\windows";"External\jcl\source\common" -I"External\jcl-2.4.1.4571\source\include" -R"Resources";"..\DBIcons";"%DELPHI%\Lib" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
move photodb.cfg.safe photodb.cfg 

cd ..
cd ExecCommand
ExecCommand "..\photodb\bin\sign.txt"
cd ..
cd PhotoDB

cd CRCCalculator
"%DCC32%" %NS% CRCCalculator -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
CRCCalculator.exe "..\bin\PhotoDB.exe" "..\KernelDLL\FileCRC.pas"
cd ..

cd KernelDLL
"%DCC32%" %NS% Kernel -E"..\bin" -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd dcu
del *.dcu
cd ..

cd ..
cd Installer
InstallMaker SETUP$ZIP.dat
"%BRCC32%" SETUP_ZIP.rc
"%DCC32%" %NS% Install -D"INSTALL;%PLAYER%" -N0"..\PhotoDB\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM

InstallMaker /setup Install.exe
"%BRCC32%" Install_Package.rc
"%DCC32%" %NS% PhotoDBInstall -E".." -D"INSTALL" -N0"..\PhotoDB\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM

cd ..
cd PhotoDB

pause