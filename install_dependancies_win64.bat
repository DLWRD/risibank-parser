if not exist "C:\curl-7.87.0" (
echo Téléchargement de Curl en cours...
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://curl.se/windows/dl-7.87.0/curl-7.87.0-win64-mingw.zip', 'curl-7.87.0.zip')"
  echo Installation de Curl en cours...
  powershell -Command "Expand-Archive curl-7.87.0.zip -DestinationPath C:\curl-7.87.0"
  setx /M PATH "%PATH%;C:\curl-7.87.0\curl-7.87.0-win64-mingw"
)

if not exist "C:\Program Files\git" (
echo Téléchargement de Git en cours
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/Git-2.39.0.2-64-bit.exe', 'git_installer.exe')"
start "git_installer.exe"
pause
setx /M PATH "%PATH%;C:\Program Files\Git\cmd"
)