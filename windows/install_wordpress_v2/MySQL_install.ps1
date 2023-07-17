# Установка протокола безопасности TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Установка Chocolatey (если еще не установлен)
if (!(Test-Path "$env:ProgramData\chocolatey\choco.exe")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Установка MySQL Server
choco install mysql -y

# Установка MySQL Workbench
choco install mysql.workbench -y

# Установка пароля для пользователя root
$mysqlExePath = "C:\tools\mysql\mysql-8.0.31-winx64\bin\mysql.exe"
$mysqlCommand = "-u root -e `"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1111';`""

# Создание файла с паролем
$mysqlPasswordFile = "C:\tools\mysql\password.txt"
"1111" | Out-File -FilePath $mysqlPasswordFile -Encoding utf8

# Выполнение команды с использованием файла конфигурации
$mysqlConfigFile = "C:\tools\mysql\my.cnf"
"[mysql]" | Out-File -FilePath $mysqlConfigFile -Encoding utf8
"password=`"1111`"" | Out-File -FilePath $mysqlConfigFile -Encoding utf8 -Append

$mysqlCommandWithConfig = "--defaults-file=`"$mysqlConfigFile`" " + $mysqlCommand
Start-Process -NoNewWindow -Wait -FilePath $mysqlExePath -ArgumentList $mysqlCommandWithConfig

# Удаление файлов с паролем и конфигурацией
Remove-Item -Path $mysqlPasswordFile, $mysqlConfigFile

# Создание базы данных wpdb
$mysqlCommand = "-u root -p1111 -e `"CREATE DATABASE wpdb;`""
Start-Process -NoNewWindow -Wait -FilePath $mysqlExePath -ArgumentList $mysqlCommand

# Создание пользователя wpuser
$mysqlCommand = "-u root -p1111 -e `"CREATE USER 'wpuser'@'localhost' IDENTIFIED BY '2222';`""
Start-Process -NoNewWindow -Wait -FilePath $mysqlExePath -ArgumentList $mysqlCommand

# Предоставление полного доступа пользователю wpuser к базе данных wpdb
$mysqlCommand = "-u root -p1111 -e `"GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost';`""
Start-Process -NoNewWindow -Wait -FilePath $mysqlExePath -ArgumentList $mysqlCommand

# Перезагрузка MySQL
$mysqlService = Get-Service -Name mysql
Restart-Service -InputObject $mysqlService

Invoke-Expression -Command C:\install_wordpress\WordPress_install.ps1