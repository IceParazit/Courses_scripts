# Установка протокола безопасности TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Установка IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools


# Создание пути для установки WordPress
$sitePath = "C:\inetpub\wwwroot\wordpress"
New-Item -ItemType Directory -Path $sitePath -Force | Out-Null

# Скачивание и распаковка WordPress
$wordpressZipUrl = "https://wordpress.org/latest.zip"
$wordpressZipPath = "$env:TEMP\wordpress.zip"
Invoke-WebRequest -Uri $wordpressZipUrl -OutFile $wordpressZipPath
Expand-Archive -Path $wordpressZipPath -DestinationPath $sitePath -Force

# Параметры базы данных MySQL
$databaseName = "wpdb"
$databaseUser = "wpuser"
$databasePassword = "2222"

# Создание конфигурационного файла wp-config.php
New-Item -ItemType File -Path "C:\inetpub\wwwroot\wordpress\wp-config.php"
$wpConfigPath = Join-Path $sitePath "wp-config.php"
Copy-Item (Join-Path $sitePath "wp-config-sample.php") -Destination $wpConfigPath -Force
(Get-Content $wpConfigPath) | ForEach-Object {
    $_ -replace "database_name_here", $databaseName `
       -replace "username_here", $databaseUser `
       -replace "password_here", $databasePassword
} | Set-Content $wpConfigPath

# Настройка разрешений
$aclRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS AppPool\DefaultAppPool", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl = Get-Acl $sitePath
$acl.SetAccessRule($aclRule)
Set-Acl $sitePath $acl

# Создание пула приложений и веб-сайта
$siteName = "WordPressSite"
New-WebAppPool -Name $siteName -Force
Set-ItemProperty -Path "IIS:\AppPools\$siteName" -Name "managedRuntimeVersion" -Value ""

New-Website -Name $siteName -PhysicalPath $sitePath -Port 80 -ApplicationPool $siteName -Force



Invoke-Expression -Command C:\install_wordpress\site.ps1