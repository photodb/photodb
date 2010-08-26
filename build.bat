SET DELPHI=C:\Program Files\Embarcadero\RAD Studio\7.0
SET PROGS=C:\Program Files
SET DCC32=%DELPHI%\BIN\DCC32.EXE
SET BRCC32=%DELPHI%\BIN\BRCC32.EXE
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
move photodb.cfg photodb.cfg.safe
"%DCC32%" photodb -DPHOTODB -Ebin -W -N0dcu --inline:on -U"D:\dmitry\Dmitry";"%PROGS%\Mustangpeak\EasyListview\Source";"%PROGS%\Mustangpeak\Common Library\Source";"External\Controls\DragDrop\Source";"External\Controls\Image Controls\Source" -RResources;"%DELPHI%\Lib" -$W -$D+ -$I+ -$O+ -$Z1
move photodb.cfg.safe photodb.cfg 

cd bin
sign.bat

pause