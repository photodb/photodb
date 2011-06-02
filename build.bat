d:
cd "D:\Dmitry\Delphi exe\Photo Database"

SET DELPHI=C:\Program Files\Embarcadero\RAD Studio\7.0
SET PROGS=C:\Program Files
SET DCC32=%DELPHI%\BIN\DCC32.EXE
SET BRCC32=%DELPHI%\BIN\BRCC32.EXE
SET DM=D:\dmitry\Dmitry
cd photodb/resources
"%BRCC32%" logo.rc
"%BRCC32%" slideshow_load.rc
"%BRCC32%" ExplorerBackground.rc
"%BRCC32%" SearchBackground.rc
"%BRCC32%" DateRange.rc
"%BRCC32%" Manifest.rc
"%BRCC32%" ImagePanelBackground.rc
"%BRCC32%" Loading.rc
"%BRCC32%" Install.rc
"%BRCC32%" Activation.rc
"%BRCC32%" PrinterPattern.rc
"%BRCC32%" BigPattern.rc

cd ..
cd ..
cd ExecCommand
"%DCC32%" ExecCommand -N0"..\PhotoDB\dcu" -$I+ -$O+ 
cd ..
cd PhotoDB

cd dcu
del *.dcu
cd ..

cd ..
cd Uninstall
"%DCC32%" UnInstall -D"UNINSTALL" -E"..\PhotoDB\bin" -N0"\PhotoDB\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..
cd PhotoDB

move photodb.cfg photodb.cfg.safe
"%DCC32%" photodb -D"PHOTODB,LICENCE" -Ebin -W -N0dcu --inline:on -U"%DM%";"%PROGS%\Mustangpeak\EasyListview\Source";"%PROGS%\Mustangpeak\Common Library\Source";"External\Controls\DragDrop\Source";"External\Controls\Image Controls\Source";"External\FastMM" -R"Resources";"..\DBIcons";"%DELPHI%\Lib" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
move photodb.cfg.safe photodb.cfg 

cd ..
cd ExecCommand
ExecCommand "..\photodb\bin\sign.txt"
cd ..
cd PhotoDB

cd CRCCalculator
"%DCC32%" CRCCalculator -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
CRCCalculator.exe "..\bin\PhotoDB.exe" "..\KernelDLL\FileCRC.pas"
cd ..

cd KernelDLL
"%DCC32%" Kernel -E"..\bin" -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..

cd dcu
del *.dcu
cd ..

cd ..
cd Installer
InstallMaker SETUP$ZIP.dat
"%BRCC32%" SETUP_ZIP.rc
"%DCC32%" Install -D"INSTALL" -E".." -N0"..\PhotoDB\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..
cd PhotoDB

pause