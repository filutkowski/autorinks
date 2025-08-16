@echo off
REM === Uruchom build.bat jeśli istnieje ===
if exist "%~dp0build.bat" (
    call "%~dp0build.bat"
)

REM === Przygotuj katalogi ===
rmdir /S /Q build
rmdir /S /Q src
mkdir build
mkdir src

REM === Zapisz obraz Dockera ===
docker save autorinks > build/docker.tar

REM === Kompilacja aplikacji przez PyInstaller ===
pyinstaller app/main.py --distpath build --workpath build/build/pyTmp --specpath build/build/sp

REM === Kompilacja instalatora przez Inno Setup ===
issc "%~dp0setup.iss"

REM === Archiwizacja źródeł i builda ===
powershell Compress-Archive -Path ".\app\" -DestinationPath ".\build\sources.zip"
powershell Compress-Archive -Path ".\build\" -DestinationPath ".\build.zip"
powershell Compres-Archive -Path ".\" -DestinationPath ".\dev.zip"

REM === Przygotowanie katalogu src do commita ===
copy "%~dp0requirements.txt" "src\requirements.txt"
xcopy "%~dp0app\*" "src\app\" /E /H /C /I

REM === Reset repozytorium i commit src ===
git reset
git add src/
git commit -m "Upload source files (Auto update)"
git push origin -u feature/src-upload

REM === Utwórz Pull Request przez GitHub CLI ===
gh pr create --title "Add src files" --body "Upload of source files (Auto update)"

REM === Utwórz Release z build.zip ===
gh release create release "build.zip" --title "Compiled (Auto update)" --notes ""
gh release create dev "dev.zip" --title "Deving (Auto update)" --notes ""
REM === Sprzątanie ===
rmdir /S /Q build
rmdir /S /Q src
@echo on0