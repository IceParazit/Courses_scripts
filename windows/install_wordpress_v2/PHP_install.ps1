# Установка PHP
$downloadUrl = "https://windows.php.net/downloads/releases/php-8.2.7-nts-Win32-vs16-x64.zip"
$downloadPath = "C:\php.zip"
$extractPath = "C:\PHP"
$phpIniPath = "$extractPath\php.ini"

# Установка протокола безопасности TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Загрузка архива PHP
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Разархивирование архива PHP
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Создание файла php.ini и запись настроек
$phpIniContent = @"
cgi.force_redirect = 0
cgi.fix_pathinfo = 1
fastcgi.impersonate = 1
fastcgi.logging = 0
extension=mysqli
extension=pdo_mysql
"@
$phpIniContent | Out-File -FilePath $phpIniPath -Encoding UTF8

# Добавление пути PHP в переменную среды PATH
$envPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*;$extractPath*") {
    $newPath = "$envPath;$extractPath"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
}

# Очистка временных файлов
Remove-Item $downloadPath

# Загрузка и установка VC_redist.x64
$vsRedistUrl = "https://aka.ms/vs/16/release/VC_redist.x64.exe"
$vsRedistPath = "C:\VC_redist.x64.exe"

Invoke-WebRequest -Uri $vsRedistUrl -OutFile $vsRedistPath
Start-Process -FilePath $vsRedistPath -ArgumentList "/quiet" -Wait

Remove-Item $vsRedistPath

Invoke-Expression -Command C:\install_wordpress\MYSQL_install.ps1