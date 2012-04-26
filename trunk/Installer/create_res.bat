SET DELPHI=C:\Program Files\Embarcadero\RAD Studio\7.0
SET BRCC32=%DELPHI%\BIN\BRCC32.EXE

InstallMaker SETUP$ZIP.dat
"%BRCC32%" SETUP_ZIP.rc
pause