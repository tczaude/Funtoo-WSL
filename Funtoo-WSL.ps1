######## Begin INTRO ##########

Write-Host @"
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
 /$$$$$$$$                    /$$                                 /$$      /$$  /$$$$$$  /$$      
| $$_____/                   | $$                                | $$  /$ | $$ /$$__  $$| $$      
| $$    /$$   /$$ /$$$$$$$  /$$$$$$    /$$$$$$   /$$$$$$         | $$ /$$$| $$| $$  \__/| $$      
| $$$$$| $$  | $$| $$__  $$|_  $$_/   /$$__  $$ /$$__  $$ /$$$$$$| $$/$$ $$ $$|  $$$$$$ | $$      
| $$__/| $$  | $$| $$  \ $$  | $$    | $$  \ $$| $$  \ $$|______/| $$$$_  $$$$ \____  $$| $$      
| $$   | $$  | $$| $$  | $$  | $$ /$$| $$  | $$| $$  | $$        | $$$/ \  $$$ /$$  \ $$| $$      
| $$   |  $$$$$$/| $$  | $$  |  $$$$/|  $$$$$$/|  $$$$$$/        | $$/   \  $$|  $$$$$$/| $$$$$$$$
|__/    \______/ |__/  |__/   \___/   \______/  \______/         |__/     \__/ \______/ |________/
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  


This script is designed to assist with Funtoo setup and testing on WSL on Windows.

If you encounter any issues or have suggestions, please report them on GitHub. The project is maintained by Tomasz Czauderna.

If you find this project helpful and wish to support it, consider buying me a coffee 
* Ko-Fi (https://ko-fi.com/tczaude) 
* BuyMeACoffee (https://buycoffee.to/tczaude).

"@

Write-Host "Naciœnij dowolny klawisz, aby kontynuowaæ..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

######## End INTRO ##########

######## Begin select architecture ######## 

clear

$url = "https://build.funtoo.org/next/x86-64bit/"
$response = Invoke-WebRequest -Uri $url

try {
    $response = Invoke-WebRequest -Uri $url

    # Parsowanie zawartoœci HTML strony
    $html = $response.ParsedHtml
} catch {
    Write-Host "Wyst¹pi³ b³¹d podczas pobierania zawartoœci strony: $($_.Exception.Message)"
    exit 1  # Zakoñcz dzia³anie skryptu z kodem b³êdu
}

# Znalezienie wszystkich plików na stronie
$files = $html.getElementsByTagName("a") | Where-Object { $_.href -like "*" }

# Wyœwietlenie przetworzonych plików w formie tabeli z numeracj¹
$filesData = $files | ForEach-Object {
    $urlSegments = $_.href -split '/'
    $penultimateSegment = $urlSegments[-2]

    [PSCustomObject]@{
        LP = [array]::IndexOf($files, $_) + 1
        Nazwa = "$penultimateSegment"
        Link = $_.href
    }
}

$filesData | Format-Table -AutoSize

# Wybieranie numeru architektury do pobrania od u¿ytkownika
$selectedFileNumber = Read-Host "Podaj numer architektury, któr¹ chcesz pobraæ (LP) lub pozostaw puste i zostanie wybrana domyœlna (generic_64):"

# Sprawdzenie, czy wprowadzona wartoœæ jest liczb¹ ca³kowit¹
if ([string]::IsNullOrWhiteSpace($selectedFileNumber)) {
    $selectedArchitecture = "generic_64"
} else {
    if ($selectedFileNumber -as [int]) {
        $selectedFileNumber = [int]$selectedFileNumber

        # Sprawdzenie, czy wybrany numer mieœci siê w zakresie dostêpnych architektur
        if ($selectedFileNumber -ge 1 -and $selectedFileNumber -le $filesData.Count) {
            $selectedFile = $filesData | Where-Object { $_.LP -eq $selectedFileNumber }
            $selectedArchitecture = $selectedFile.Nazwa

            Write-Host "Wybrano architekturê: $selectedArchitecture"
        } else {
            Write-Host "Wybrany numer architektury jest poza zakresem dostêpnych architektur."
        }
    } else {
        Write-Host "Podana wartoœæ nie jest liczb¹ ca³kowit¹."
    }
}

# Aktualizacja zmiennej $url na podstawie wyboru u¿ytkownika
$url = "https://build.funtoo.org/next/x86-64bit/$selectedArchitecture/"

######## End select architecture ######## 

######## Begin select stage ########

clear

$response = Invoke-WebRequest -Uri $url

try {
    $response = Invoke-WebRequest -Uri $url

    # Parsowanie zawartoœci HTML strony
    $html = $response.ParsedHtml
} catch {
    Write-Host "Wyst¹pi³ b³¹d podczas pobierania zawartoœci strony: $($_.Exception.Message)"
    exit 1  # Zakoñcz dzia³anie skryptu z kodem b³êdu
}

# Znalezienie wszystkich plików na stronie
$files = $html.getElementsByTagName("a") | Where-Object { $_.href -like "*.xz" }

# Wyœwietlenie przetworzonych plików w formie tabeli z numeracj¹
$filesData = $files | ForEach-Object {
    $urlSegments = $_.href -split '/'
    $stage = $urlSegments[-1]

    [PSCustomObject]@{
        LP = [array]::IndexOf($files, $_) + 1
        Nazwa = "$stage"
        Link = $_.href
    }
}

$filesData | Format-Table -AutoSize

# Wybieranie numeru architektury do pobrania od u¿ytkownika

clear

$selectedFileNumber = Read-Host "Podaj numer Stage3, któr¹ chcesz pobraæ (LP) lub pozostaw puste i zostanie wybrana stage3-generic_64:"

if ([string]::IsNullOrWhiteSpace($selectedFileNumber)) {
  $stage3Link = $filesData | Where-Object { $_.Link -like "*/stage3-generic_64*" }

  if ($stage3Link -ne $null) {
    Write-Host "Znaleziono link do pliku stage3: $($stage3Link.Link)"
    $url = $stage3Link.Link
    $gpgUrl = "$url.gpg"
  } else {
    Write-Host "Nie znaleziono linku do pliku stage3."
  }
} else {
      if ($selectedFileNumber -as [int]) {
        $selectedFileNumber = [int]$selectedFileNumber

        # Sprawdzenie, czy wybrany numer mieœci siê w zakresie dostêpnych architektur
        if ($selectedFileNumber -ge 1 -and $selectedFileNumber -le $filesData.Count) {
            $selectedFile = $filesData | Where-Object { $_.LP -eq $selectedFileNumber }
            $selectedstage3 = $selectedFile.Nazwa

            Write-Host "Wybrano stage3: $selectedstage3"
            $url = "https://build.funtoo.org/next/x86-64bit/$selectedArchitecture/$selectedstage3"
            $gpgUrl = "$url.gpg"

        } else {
            Write-Host "Wybrany numer architektury jest poza zakresem dostêpnych stage3."
        }
    } else {
        Write-Host "Podana wartoœæ nie jest liczb¹ ca³kowit¹."
    }
}

$hash_url = [System.Security.Cryptography.HashAlgorithm]::Create('MD5').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($url))
$hash_gpgUrl = [System.Security.Cryptography.HashAlgorithm]::Create('MD5').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($gpgUrl))

$hash_url_String = [System.BitConverter]::ToString($hash_url) -replace '-', ''
$hash_gpgUrl_String = [System.BitConverter]::ToString($hash_gpgUrl) -replace '-', ''

# Wyodrêbnij ostatni segment URL po znaku /
$lastSegment = $url.Split("/")[-1]

# ZnajdŸ pozycjê pierwszej kropki w segmencie
$dotIndex = $lastSegment.LastIndexOf('.')
$dotCount = ($lastSegment -split '\.').Count - 1

$url_ext = $lastSegment.Split('.')[-($dotCount)..-1] -join '.'


Write-Host "URL: $url"
Write-Host "URL: $gpgUrl"
Write-Host "Rozszerzenie: $url_ext"
Write-Host "Hash URL: $hash_url_String"
Write-Host "Hash GPG URL: $hash_gpgUrl_String"

# Lokalizacja katalogu TEMP
$tempDirectory = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "FuntooWSL")

if (-not (Test-Path -Path $tempDirectory -PathType Container)) {
    New-Item -Path $tempDirectory -ItemType Directory
    Write-Host "Utworzono folder $folderPath"
}

# Nazwa pliku z rozszerzeniem
$fileName = "$hash_url_String.$url_ext"
$filePath = [System.IO.Path]::Combine($tempDirectory, $fileName)

# Sprawdzenie, czy plik o danym hashu istnieje w katalogu TEMP
if (-not (Test-Path -Path $filePath)) {
    # Jeœli nie istnieje, pobierz plik

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -uri $url -OutFile $filePath

} else {
    Write-Host "Plik $fileName ju¿ istnieje w katalogu TEMP"
}

# Nazwa pliku z rozszerzeniem
$fileName = "$hash_gpgUrl_String.$url_ext.gpg"
$filePath = [System.IO.Path]::Combine($tempDirectory, $fileName)

# Sprawdzenie, czy plik o danym hashu istnieje w katalogu TEMP
if (-not (Test-Path -Path $filePath)) {
    # Jeœli nie istnieje, pobierz plik

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -uri $gpgUrl -OutFile $filePath

} else {
    Write-Host "Plik $fileName ju¿ istnieje w katalogu TEMP"
}

######## End select stage ########

######## Begin GPG Validation ########

######## End GPG Validation ########

######## Begin WSL Global Configuration ########

clear

# Œcie¿ka do pliku .wslconfig w folderze UserProfile
$wslConfigPath = [System.IO.Path]::Combine($env:UserProfile, ".wslconfig")

# Sprawdzenie, czy plik .wslconfig istnieje
if (-not (Test-Path -Path $wslConfigPath -PathType Leaf)) {
    New-Item -ItemType File -Path $wslConfigPath 
}

# Odczytaj zawartoœæ pliku
$wslConfigContent = Get-Content -Path $wslConfigPath

if ($wslConfigContent -notmatch "\[wsl2\]") {

  # Dodaj sekcjê [wsl2]
  $newSection = @"
[wsl2]
"@

  Add-Content -Path $wslConfigPath -Value $newSection
}

if ($wslConfigContent -notmatch "memory=") {
    # Oblicz iloœæ dostêpnej pamiêci RAM w komputerze
    $ramSize = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB)

    # Ustalenie wartoœci dla memory w formacie {8GB OR 50% of the available RAM}
    if ($ramSize -ge 8) {
       $memoryValue = [math]::Ceiling($ramSize * 0.5).ToString() + "GB"
    } else {
      $memoryValue = "8GB"
    }

    # Dodaj liniê memory z obliczon¹ wartoœci¹
    $newLine = "memory=$memoryValue"

    Add-Content -Path $wslConfigPath -Value $newLine
}

# Jeœli wpis processors nie istnieje, dodaj go zgodnie z wytycznymi
if (-not $wslConfigContent -match "processors=") {
    # Oblicz iloœæ dostêpnych procesorów w komputerze
    $processorCount = [Environment]::ProcessorCount

    # Oblicz wartoœæ dla processors, uwzglêdniaj¹c ograniczenie wzglêdem pamiêci RAM
    $maxProcessors = [math]::Min([math]::Ceiling($ramSize * 0.5), $processorCount)

    # Dodaj liniê processors z obliczon¹ wartoœci¹
    $newLine = "processors=$maxProcessors"
    Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "localhostforwarding") {
  # Turn off default connection to bind WSL 2 localhost to Windows localhost
  # localhostforwarding=true
  $newLine = "localhostforwarding=true"
  Add-Content -Path $wslConfigPath -Value $newLine
}

# Skip mayby we try add Debian here or Arch need be testing
# Specify a custom Linux kernel to use with your installed distros. The default kernel used can be found at https://github.com/microsoft/WSL2-Linux-Kernel
# kernel=C:\\temp\\myCustomKernel

# We use standard kernel nod need this
# Sets additional kernel parameters, in this case enabling older Linux base images such as Centos 6
# kernelCommandLine = vsyscall=emulate

if (-not $wslConfigContent -match "swap=") {
  # Sets amount of swap storage space to 8GB, default is 25% of available RAM
  # swap=8GB
; 
  $totalMemoryGB = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
  $swapValue = "$($totalMemoryGB / 4)GB"

  # Dodaj liniê swap z obliczon¹ wartoœci¹
  $newLine = "swap=$swapValue"
  Add-Content -Path $wslConfigPath -Value $newLine
}

# No preference stay default
# Sets swapfile path location, default is %USERPROFILE%\AppData\Local\Temp\swap.vhdx
# swapfile=C:\\temp\\wsl-swap.vhdx


#if ($wslConfigContent -notmatch "pageReporting=") {
  # Disable page reporting so WSL retains all allocated memory claimed from Windows and releases none back when free
  # pageReporting=false
#  $newLine = "pageReporting=false"
#  Add-Content -Path $wslConfigPath -Value $newLine
#}

if (-not $wslConfigContent -match "nestedVirtualization=") {
  # Disables nested virtualization
  # nestedVirtualization=false
  $newLine = "nestedVirtualization=true"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "debugConsole") {
  # Turns on output console showing contents of dmesg when opening a WSL 2 distro for debugging
  # debugConsole=true
  $newLine = "debugConsole=true"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "experimental") {
  # Enable experimental features
  # [experimental]
  $newLine = "[experimental]"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "autoMemoryReclaim") {
  # Automatically releases cached memory after detecting idle CPU usage. Set to gradual for slow release, and dropcache for instant release of cached memory
  $newLine = "autoMemoryReclaim=gradual"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "sparseVhd") {
  # When set to true, any newly created VHD will be set to sparse automatically.
  $newLine = "sparseVhd=True"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "networkingMode") {
  # If the value is mirrored then this turns on mirrored networking mode. Default or unrecognized strings result in NAT networking.
  $newLine = "networkingMode=mirrored"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "firewall") {
  # Setting this to true allows the Windows Firewall rules, as well as rules specific to Hyper-V traffic, to filter WSL network traffic.
  $newLine = "firewall=false"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "dnsTunneling") {
  # Changes how DNS requests are proxied from WSL to Windows
  $newLine = "dnsTunneling=true"
  Add-Content -Path $wslConfigPath -Value $newLine
}

if (-not $wslConfigContent -match "autoProxy") {
  # Enforces WSL to use Windows’ HTTP proxy information
  $newLine = "autoProxy=false"
  Add-Content -Path $wslConfigPath -Value $newLine
}

# Zainicjowanie pustej tablicy do przechowywania unikalnych linii
$uniqueLines = @()

# Przetwarzanie linii pliku .wslconfig
foreach ($line in $wslConfigContent) {
    if ($line -notin $uniqueLines) {
        # Jeœli linia nie jest ju¿ w tablicy unikalnych linii, dodaj j¹
        $uniqueLines += $line
    }
}

# Zapis unikalnych linii z powrotem do pliku .wslconfig
$uniqueLines | Set-Content $wslConfigPath

#For apply settings we must shotdown WSL 

wsl --shutdown

######## End WSL Global Configuration ########

######## Begin import image ########

clear

# 1. Zapytaj u¿ytkownika o nazwê WSL
$wslName = Read-Host "Podaj nazwê WSL (naciœnij Enter, aby u¿yæ domyœlnej nazwy)"

# Utwórz domyœln¹ nazwê WSL z 6 losowymi znakami, jeœli nie podano ¿adnej nazwy

if ([string]::IsNullOrWhiteSpace($wslName)) {
    $randomChars = -join (65..90 + 97..122 | Get-Random -Count 6 | ForEach-Object { [char]$_ })
    $wslName = "Funtoo_$randomChars"
}

# 2. Ustal œcie¿kê do obrazu
$fileName = "$hash_url_String.$url_ext"
$filePath = [System.IO.Path]::Combine($tempDirectory, $fileName)

# 3. Importuj WSL z podan¹ nazw¹ i obrazem

$wslPath = Join-Path -Path $env:USERPROFILE\AppData\Local\WSL -ChildPath $wslName

if (-not (Test-Path -Path $wslPath -PathType Container)) {
    New-Item -Path $wslPath -ItemType Directory
}

$wslVersion = 2  # Wersja WSL 2

wsl --import $wslName $wslPath $filePath --version $wslVersion

######## End import image ########

wsl --update --pre-release
wsl --set-default $wslName 

######## Begin Per-Distribution WSL Config ########

# Spróbuj pobraæ nazwê zmiennego z nazw¹ u¿ytkownika Windows
$windowsUserName = $env:UserName

# Poproœ u¿ytkownika o podanie nazwy domyœlnego u¿ytkownika WSL
$newDefaultUser = Read-Host "Podaj nazwê domyœlnego u¿ytkownika dla WSL. Wciœnij Enter, aby u¿yæ nazwy u¿ytkownika Windows ($windowsUserName):"

if ([string]::IsNullOrWhiteSpace($newDefaultUser)) {
    # Jeœli u¿ytkownik nacisn¹³ Enter, u¿yj nazwy u¿ytkownika Windows
    $newDefaultUser = $windowsUserName
}

$contents = @"
[automount]

# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above. Set to false means drives won't be mounted automatically, but need to be mounted manually or with fstab.
enabled = true

# Sets the directory where fixed drives will be automatically mounted. This example changes the mount location, so your C-drive would be /c, rather than the default /mnt/c. 
root = /

# DrvFs-specific options can be specified.  
options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off"

# Sets the `/etc/fstab` file to be processed when a WSL distribution is launched.
mountFsTab = true

# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).

[network]
#hostname=
generateHosts = true
generateResolvConf = true

# Set whether WSL supports interop process like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
enabled = true
appendWindowsPath = true

# Set the user when launching a distribution with WSL.
[user]
#default_user=

# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
[boot]
command = "/sbin/openrc default"
command = "rm -r /tmp/.X11-unix && ln -s /mnt/wslg/.X11-unix /tmp/.X11-unix"

"@

# Utwórz plik "config" w WSL

# Utwórz plik "config" w systemie Windows (na przyk³ad w katalogu tymczasowym)
$wslConfigFilePath = Join-Path $env:TEMP 'wsl.conf'

$contents | Set-Content -Path $wslConfigFilePath

$contents = Get-Content -Path $wslConfigFilePath
$contents = $contents -replace '#hostname=.*', "hostname=$wslName"
$contents = $contents -replace '#default_user=.*', "default=$newDefaultUser"
$contents | Set-Content -Path $wslConfigFilePath

# Skopiuj plik "config" z systemu Windows do WSL
Copy-Item -Path $wslConfigFilePath -Destination "\\wsl.localhost\$wslName\etc\wsl.conf" -Force

# Usuñ tymczasowy plik "config" z systemu Windows
Remove-Item -Path $wslConfigFilePath -Force

######## End Per-Distribution WSL  ########

######## Begin Base Funtoo confguration #####

$contents = @"
# Compiler flags to set for all languages
COMMON_FLAGS="-march=native -O2 -pipe"
# Use the same settings for both variables
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"


# If left undefined, Portage's default behavior is to:
# - set the MAKEOPTS jobs value to the same number of threads returned by `nproc`
# - set the MAKEOPTS load-average value to the same number of threads returned by `nproc`
# Please replace '4' as appropriate for the system (min(RAM/2GB, threads), or leave it unset.

MAKEOPTS=""
"@

$wslConfigFilePath = Join-Path $env:TEMP 'make.conf'

$contents | Set-Content -Path $wslConfigFilePath

$contents = Get-Content -Path $wslConfigFilePath

$contents = $contents -replace 'MAKEOPTS=*', "MAKEOPTS=-j$maxProcessors -l$maxProcessors"
$contents | Set-Content -Path $wslConfigFilePath

# Skopiuj plik "config" z systemu Windows do WSL
Copy-Item -Path $wslConfigFilePath -Destination "\\wsl.localhost\$wslName\etc\portage\make.conf" -Force

# Usuñ tymczasowy plik "config" z systemu Windows
Remove-Item -Path $wslConfigFilePath -Force

wsl -e ego sync
wsl -e useradd -m -G users,wheel,audio -s /bin/bash $newDefaultUser
wsl -e emerge -vuND @world
wsl -e mkdir /run/openrc
wsl -e touch /run/openrc/softlevel
wsl -e rc

clear 

Write-Host @"
                                                                                          
                                                                                          
                                                                                          
 /$$$$$$$$ /$$                           /$$                                              
|__  $$__/| $$                          | $$                                              
   | $$   | $$$$$$$   /$$$$$$  /$$$$$$$ | $$   /$$  /$$$$$$$                              
   | $$   | $$__  $$ |____  $$| $$__  $$| $$  /$$/ /$$_____/                              
   | $$   | $$  \ $$  /$$$$$$$| $$  \ $$| $$$$$$/ |  $$$$$$                               
   | $$   | $$  | $$ /$$__  $$| $$  | $$| $$_  $$  \____  $$                              
   | $$   | $$  | $$|  $$$$$$$| $$  | $$| $$ \  $$ /$$$$$$$/                              
   |__/   |__/  |__/ \_______/|__/  |__/|__/  \__/|_______/                               
                                                                                          
                                                                                          
                                                                                          
 /$$   /$$           /$$                           /$$$$$$$$ /$$       /$$                
| $$  | $$          |__/                          |__  $$__/| $$      |__/                
| $$  | $$  /$$$$$$$ /$$ /$$$$$$$   /$$$$$$          | $$   | $$$$$$$  /$$  /$$$$$$$      
| $$  | $$ /$$_____/| $$| $$__  $$ /$$__  $$         | $$   | $$__  $$| $$ /$$_____/      
| $$  | $$|  $$$$$$ | $$| $$  \ $$| $$  \ $$         | $$   | $$  \ $$| $$|  $$$$$$       
| $$  | $$ \____  $$| $$| $$  | $$| $$  | $$         | $$   | $$  | $$| $$ \____  $$      
|  $$$$$$/ /$$$$$$$/| $$| $$  | $$|  $$$$$$$         | $$   | $$  | $$| $$ /$$$$$$$/      
 \______/ |_______/ |__/|__/  |__/ \____  $$         |__/   |__/  |__/|__/|_______/       
                                   /$$  \ $$                                              
                                  |  $$$$$$/                                              
                                   \______/                                               
 /$$$$$$$$                  /$$                                                           
|__  $$__/                 | $$                                                           
   | $$  /$$$$$$   /$$$$$$ | $$                                                           
   | $$ /$$__  $$ /$$__  $$| $$                                                           
   | $$| $$  \ $$| $$  \ $$| $$                                                           
   | $$| $$  | $$| $$  | $$| $$                                                           
   | $$|  $$$$$$/|  $$$$$$/| $$                                                           
   |__/ \______/  \______/ |__/                                                           
                                                                                          
                                                                                          
                                                                                          
 /$$   /$$                                     /$$$$$$$$                        /$$       
| $$  | $$                                    | $$_____/                       | $$       
| $$  | $$  /$$$$$$  /$$    /$$ /$$$$$$       | $$    /$$   /$$ /$$$$$$$       | $$       
| $$$$$$$$ |____  $$|  $$  /$$//$$__  $$      | $$$$$| $$  | $$| $$__  $$      | $$       
| $$__  $$  /$$$$$$$ \  $$/$$/| $$$$$$$$      | $$__/| $$  | $$| $$  \ $$      |__/       
| $$  | $$ /$$__  $$  \  $$$/ | $$_____/      | $$   | $$  | $$| $$  | $$                 
| $$  | $$|  $$$$$$$   \  $/  |  $$$$$$$      | $$   |  $$$$$$/| $$  | $$       /$$       
|__/  |__/ \_______/    \_/    \_______/      |__/    \______/ |__/  |__/      |__/       
                                                                                          
                                                                                          
                                                                                          


If you find this project helpful and wish to support it, consider buying me a coffee 
* Ko-Fi (https://ko-fi.com/tczaude) 
* BuyMeACoffee (https://buycoffee.to/tczaude).

"@

Write-Host ""
Write-Host "Naciœnij dowolny klawisz, aby kontynuowaæ..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
