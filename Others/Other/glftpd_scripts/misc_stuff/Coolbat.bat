@echo off


cd /D %1


:: CHECK IN MAIN DIR

:checkrar
if not exist *.rar goto checkr01
"c:\program files\winrar\rar.exe" e -kbo-- *.rar %1
goto end

:checkr01
if not exist *.r01 goto check000
"c:\program files\winrar\rar.exe" e -kbo-- *.r01 %1
goto end

:check000
if not exist *.000 goto check001
"c:\program files\winrar\rar.exe" e -kbo-- *.000 %1
goto end

:check001
if not exist *.001 goto checkcd
"c:\program files\winrar\rar.exe" e -kbo-- *.001 %1
goto end

:: CHECK CD1


:checkcd
if not exist CD1 goto ERROR
cd CD1

:checkrar_1
if not exist *.rar goto checkr01_1
"c:\program files\winrar\rar.exe" e -kbo-- *.rar %1
goto checkcd_2

:checkr01_1
if not exist *.r01 goto check000_1
"c:\program files\winrar\rar.exe" e -kbo-- *.r01 %1
goto checkcd_2

:check000_1
if not exist *.000 goto check000_1
"c:\program files\winrar\rar.exe" e -kbo-- *.000 %1
goto checkcd_2

:check000_1
if not exist *.001 goto checkcd_2
"c:\program files\winrar\rar.exe" e -kbo-- *.001 %1
goto checkcd_2


:: CHECK CD2


:checkcd_2
cd %1
if not exist CD2 goto end
cd CD2

:checkrar_2
if not exist *.rar goto checkr01_2
"c:\program files\winrar\rar.exe" e -kbo-- *.rar %1
goto checkcd_3

:checkr01_2
if not exist *.r01 goto check000_2
"c:\program files\winrar\rar.exe" e -kbo-- *.r01 %1
goto checkcd_3

:check000_2
if not exist *.000 goto check001_2
"c:\program files\winrar\rar.exe" e -kbo-- *.000 %1
goto checkcd_3

:check001_2
if not exist *.001 goto end
"c:\program files\winrar\rar.exe" e -kbo-- *.001 %1
goto checkcd_3



:: CHECK CD3


:checkcd_3
cd %1
if not exist CD3 goto end
cd CD3

:checkrar_3
if not exist *.rar goto checkr01_3
"c:\program files\winrar\rar.exe" e -kbo-- *.rar %1
goto end

:checkr01_3
if not exist *.r01 goto check000_3
"c:\program files\winrar\rar.exe" e -kbo-- *.r01 %1
goto end

:check000_3
if not exist *.000 goto check001_3
"c:\program files\winrar\rar.exe" e -kbo-- *.000 %1
goto end

:check001_3
if not exist *.001 goto end
"c:\program files\winrar\rar.exe" e -kbo-- *.001 %1
goto end



:: NO FILES FOUND


goto end
:ERROR
echo No files found.
pause
goto end



:: QUIT


:end
