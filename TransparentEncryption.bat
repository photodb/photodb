SET DELPHI=C:\Program Files (x86)\Embarcadero\RAD Studio\10.0
SET DM=D:\dmitry\Dmitry
SET NS=-NSSystem;System.Win;WinAPI;Vcl;Vcl.Imaging;Data;Xml;Data.Win;Vcl.Shell;Vcl.Samples;Soap
SET DCC32=%DELPHI%\BIN\DCC32.EXE
SET DCC64=%DELPHI%\BIN\DCC64.EXE

cd TransparentEncryption
"%DCC32%" %NS% TransparentEncryption -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
"%DCC64%" %NS% TransparentEncryption64 -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
"%DCC32%" %NS% PlayEncryptedMedia -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
"%DCC64%" %NS% PlayEncryptedMedia64 -E"..\PhotoDB\bin" -N0"..\dcu" -U"%DM%" -$I+ -$O+ -W-SYMBOL_PLATFORM -W-UNIT_PLATFORM
cd ..
