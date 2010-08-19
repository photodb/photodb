cd photodb/resources
BRCC32 logo.rc
BRCC32 slideshow_load.rc
BRCC32 ExplorerBackground.rc
BRCC32 SearchBackground.rc
BRCC32 SearchWait.rc
BRCC32 DateRange.rc
BRCC32 Manifest.rc

cd ..
DCC32 photodb -ndcu -ebin -U"D:\dmitry\Dmitry";"C:\Program Files\Mustangpeak\EasyListview\Source";"C:\Program Files\Mustangpeak\Common Library\Source" -RResources;"C:\Program Files\Borland\Delphi7\Lib" -$W -$D+ -$I+ -$O+ 

pause