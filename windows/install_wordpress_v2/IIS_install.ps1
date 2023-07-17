# Установка протокола безопасности TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Установка Web Server (IIS)
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Установка ASP.NET 4.6
Install-WindowsFeature -Name Web-Asp-Net45

# Установка необходимых ролей
Install-WindowsFeature -Name Web-Custom-Logging, Web-Log-Libraries, Web-CGI, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Net-Ext45, Web-ASP, Web-Asp-Net45, Web-Http-Logging, Web-Http-Tracing, Web-Dyn-Compression, Web-Stat-Compression, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, NET-Framework-Features -IncludeManagementTools

# Установка IIS Management Console
Install-WindowsFeature -Name Web-Mgmt-Console

$downloadUrl = 'https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi'
$downloadPath = 'C:\Temp\rewrite_amd64_en-US.msi'

# Создание временной папки для загрузки
$downloadFolder = 'C:\Temp'
New-Item -ItemType Directory -Force -Path $downloadFolder | Out-Null

# Скачивание модуля URL Rewrite
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Установка модуля URL Rewrite
Start-Process -FilePath msiexec.exe -ArgumentList "/i $downloadPath /quiet" -Wait

# Удаление загруженного файла после установки
Remove-Item -Path $downloadPath -Force

# Перезапуск службы IIS
Restart-Service -Name W3SVC

Invoke-Expression -Command C:\install_wordpress\PHP_install.ps1