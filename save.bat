@echo off
setlocal

REM === Uruchom build.bat jeśli istnieje ===
if exist "%~dp0build.bat" (
    echo [INFO] Uruchamiam build.bat...
    call "%~dp0build.bat"
)

REM === Przygotuj katalogi ===
echo [INFO] Czyszczę katalogi build i src...
rmdir /S /Q build 2>nul
rmdir /S /Q src 2>nul
mkdir build
mkdir src

REM === Zapisz obraz Dockera ===
echo [INFO] Zapisuję obraz Dockera...
docker save autorinks > build/docker.tar

REM === Kompilacja aplikacji przez PyInstaller ===
echo [INFO] Kompiluję aplikację przez PyInstaller...
pyinstaller app/main.py --distpath build --workpath build/build/pyTmp --specpath build/build/sp

REM === Kompilacja instalatora przez Inno Setup ===
echo [INFO] Kompiluję instalator przez Inno Setup...
where iscc >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Nie znaleziono komendy 'iscc'. Zainstaluj Inno Setup i dodaj do PATH.
    goto :end
)
iscc "%~dp0setup.iss"

REM === Archiwizacja źródeł i builda ===
echo [INFO] Tworzę archiwa ZIP...
powershell Compress-Archive -Path ".\app\*" -DestinationPath ".\build\sources.zip" -Force
powershell Compress-Archive -Path ".\build\*" -DestinationPath ".\build.zip" -Force
powershell Compress-Archive -Path ".\*" -DestinationPath ".\dev.zip" -Force

REM === Przygotowanie katalogu src do commita ===
echo [INFO] Przygotowuję katalog src...
copy "%~dp0requirements.txt" "src\requirements.txt"
xcopy "%~dp0app\*" "src\app\" /E /H /C /I

REM === Reset repozytorium i commit src ===
echo [INFO] Resetuję repozytorium i tworzę commit...
git reset
git checkout -b feature/src-upload 2>nul
git add src/
git commit -m "Upload source files (Auto update)"
git push origin HEAD:feature/src-upload

REM === Sprawdź czy gh CLI jest dostępne ===
where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Nie znaleziono komendy 'gh'. Zainstaluj GitHub CLI i dodaj do PATH.
    goto :end
)

REM === Utwórz Pull Request przez GitHub CLI ===
echo [INFO] Tworzę Pull Request...
gh pr create --title "Add src files" --body "Upload of source files (Auto update)"

REM === Utwórz Release z build.zip i dev.zip ===
echo [INFO] Tworzę release...
gh release create release "build.zip" --title "Compiled (Auto update)" --notes ""
gh release create dev "dev.zip" --title "Deving (Auto update)" --notes ""

REM === Sprzątanie jeśli nie podano -d ===
if "%~1" neq "-d" (
    echo [INFO] Sprzątam katalogi tymczasowe...
    rmdir /S /Q build
    rmdir /S /Q src
)

:end
echo [INFO] Gotowe!
@echo on