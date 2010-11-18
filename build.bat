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
"%BRCC32%" SearchWait.rc
"%BRCC32%" DateRange.rc
"%BRCC32%" Manifest.rc
"%BRCC32%" ImagePanelBackground.rc

cd ..
cd ..
cd ExecCommand
"%DCC32%" ExecCommand -N0"..\PhotoDB\dcu" -$W -$D+ -$I+ -$O+ -$Z1
cd ..
cd PhotoDB

cd dcu
del *.dcu
cd ..

move photodb.cfg photodb.cfg.safe
"%DCC32%" photodb -D"PHOTODB,LICENCE" -Ebin -W -N0dcu --inline:on -U"%DM%";"%PROGS%\Mustangpeak\EasyListview\Source";"%PROGS%\Mustangpeak\Common Library\Source";"External\Controls\DragDrop\Source";"External\Controls\Image Controls\Source";"External\FastMM" -RResources;"%DELPHI%\Lib" -$W -$D+ -$I+ -$O+ -$Z1
move photodb.cfg.safe photodb.cfg 

cd ..
cd ExecCommand
ExecCommand "..\photodb\bin\sign.txt"
cd ..
cd PhotoDB

cd CRCCalculator
"%DCC32%" CRCCalculator -N0"..\dcu" -U"%DM%" -$W -$D+ -$I+ -$O+ -$Z1
CRCCalculator.exe "..\bin\PhotoDB.exe" "..\KernelDLL\FileCRC.pas"
cd ..

cd KernelDLL
"%DCC32%" Kernel -E"..\bin" -N0"..\dcu" -U"%DM%" -$W -$D+ -$I+ -$O+ -$Z1
cd ..

cd dcu
del *.dcu
cd ..

cd ..
cd Installer
InstallMaker SETUP$ZIP.dat
"%BRCC32%" SETUP_ZIP.rc
"%DCC32%" PhotoDBInstall -E".." -N0"\PhotoDB\dcu" -U"%DM%" -$W -$D+ -$I+ -$O+ -$Z1


pause