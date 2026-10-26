
@echo off
:: Установка кодировки UTF-8 для правильного вывода русского языка
chcp 65001 > nul

:: 8. Сохранение отчёта (использование пути %~dp0 для создания файла рядом со скриптом)
set "REPORT_FILE=%~dp0pc_report.txt"

:: Инициализация/очистка файла отчёта
type null > "%REPORT_FILE%"

echo =========================================
echo Выполняется сбор сведений о системе...
echo =========================================
echo.

:: 3. Сведения об операционной системе
echo Операционная система>> "%REPORT_FILE%"
echo Операционная система
for /f "tokens=*" %%i in ('wmic os get Caption^,Version /format:list ^| findstr /r /v "^$"') do (
    echo %%i>> "%REPORT_FILE%"
    echo %%i
)
echo.>> "%REPORT_FILE%"
echo.

:: 4. Сведения о процессоре
echo Процессор>> "%REPORT_FILE%"
echo Процессор
for /f "tokens=*" %%i in ('wmic cpu get Name /format:list ^| findstr /r /v "^$"') do (
    echo %%i>> "%REPORT_FILE%"
    echo %%i
)
echo.>> "%REPORT_FILE%"
echo.

:: 5. Сведения об оперативной памяти
for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /value') do set "total_kb=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get FreePhysicalMemory /value') do set "free_kb=%%a"

:: Математический перевод килобайт в гигабайты (деление на 1048576 через set /a)
set /a total_gb=%total_kb% / 1048576
set /a free_gb=%free_kb% / 1048576

echo Оперативная память>> "%REPORT_FILE%"
echo Оперативная память
echo Всего памяти=%total_gb% ГБ>> "%REPORT_FILE%"
echo Всего памяти=%total_gb% ГБ
echo Свободно памяти=%free_gb% ГБ>> "%REPORT_FILE%"
echo Свободно памяти=%free_gb% ГБ
echo.>> "%REPORT_FILE%"
echo.

:: 6. Свободное место на диске
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get Size /value') do set "disk_size=%%a"
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set "disk_free=%%a"

:: Обход 32-битного лимита чисел в CMD: отсекаем последние 6 символов, затем делим на 1073
set "disk_size_short=%disk_size:~0,-6%"
set "disk_free_short=%disk_free:~0,-6%"
set /a disk_size_gb=%disk_size_short% / 1073
set /a disk_free_gb=%disk_free_short% / 1073

echo Диск C>> "%REPORT_FILE%"
echo Диск C
echo Всего места=%disk_size_gb% ГБ>> "%REPORT_FILE%"
echo Всего места=%disk_size_gb% ГБ
echo Свободно места=%disk_free_gb% ГБ>> "%REPORT_FILE%"
echo Свободно места=%disk_free_gb% ГБ
echo.>> "%REPORT_FILE%"
echo.

:: 7. Список установленных программ (Быстрый путь через реестр reg query)
echo Список установленных программ>> "%REPORT_FILE%"
echo Список установленных программ

for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /f DisplayName 2^>nul ^| findstr "DisplayName"') do (
    echo %%b>> "%REPORT_FILE%"
    echo %%b
)
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /f DisplayName 2^>nul ^| findstr "DisplayName"') do (
    echo %%b>> "%REPORT_FILE%"
    echo %%b
)

:: Конец работы программы
echo.
echo =========================================
echo Отчёт сохранён
echo =========================================
pause
