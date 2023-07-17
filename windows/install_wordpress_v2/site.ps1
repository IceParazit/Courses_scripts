# Добавление модуля FastCGI
Import-Module WebAdministration

# Получение пути к исполняемому файлу PHP CGI
$phpCgiPath = "C:\PHP\php-cgi.exe"

# Добавление модуля отображения для обработки PHP файлов
Add-WebConfigurationProperty -pspath 'IIS:\' -filter "system.webServer/handlers" -name "." -value @{name='PHP-FCGI';path='*.php';verb='GET,HEAD,POST';modules='FastCgiModule';scriptProcessor=$phpCgiPath;resourceType='File'}

# Настройка обработки файлов index.php как документа по умолчанию
Set-WebConfigurationProperty -pspath 'IIS:\' -filter "system.webServer/defaultDocument/files/add[@value='index.php']" -name "value" -value "index.php"

Stop-Website -Name "Default Web Site"
Start-Website -Name "WordPressSite"

# Открытие сайта в браузере
$siteUrl = "http://localhost"
Start-Process -FilePath $siteUrl

# Перезагрузка службы IIS
Restart-Service -Name 'W3SVC'

