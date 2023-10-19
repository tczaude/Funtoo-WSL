######## Begin INTRO ##########

Write-Host @"
  _____ _               _____  _  __ _ 
 / ____| |             |_   _|| |/ _(_)
| (___ | |_   _  __ _    | |  | | |_ _ 
 \___ \| | | | |/ _` |   | |  | |  _| |
 ____) | | |_| | (_| |  _| |_ | | | | |
|_____/|_|\__,_|\__,_| |_____|/ |_||_|

This script is designed to assist with Funtoo setup and testing on WSL on Windows.

If you encounter any issues or have suggestions, please report them on GitHub. The project is maintained by Tomasz Czauderna.

If you find this project helpful and wish to support it, consider buying me a coffee on Ko-Fi (https://ko-fi.com/tczaude) or BuyMeACoffee (https://buycoffee.to/tczaude).
"@

######## End INTRO ##########

Write-Host "Naci�nij dowolny klawisz, aby kontynuowa�..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

######## Begin select architecture ######## 

$url = "https://build.funtoo.org/next/x86-64bit/"
$response = Invoke-WebRequest -Uri $url

try {
    $response = Invoke-WebRequest -Uri $url

    # Parsowanie zawarto�ci HTML strony
    $html = $response.ParsedHtml
} catch {
    Write-Host "Wyst�pi� b��d podczas pobierania zawarto�ci strony: $($_.Exception.Message)"
    exit 1  # Zako�cz dzia�anie skryptu z kodem b��du
}

# Znalezienie wszystkich plik�w na stronie
$files = $html.getElementsByTagName("a") | Where-Object { $_.href -like "*" }

# Wy�wietlenie przetworzonych plik�w w formie tabeli z numeracj�
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

# Wybieranie numeru architektury do pobrania od u�ytkownika
$selectedFileNumber = Read-Host "Podaj numer architektury, kt�r� chcesz pobra� (LP) lub pozostaw puste i zostanie wybrana domy�lna (generic_64):"

# Sprawdzenie, czy wprowadzona warto�� jest liczb� ca�kowit�
if ([string]::IsNullOrWhiteSpace($selectedFileNumber)) {
    $selectedArchitecture = "generic_64"
} else {
    if ($selectedFileNumber -as [int]) {
        $selectedFileNumber = [int]$selectedFileNumber

        # Sprawdzenie, czy wybrany numer mie�ci si� w zakresie dost�pnych architektur
        if ($selectedFileNumber -ge 1 -and $selectedFileNumber -le $filesData.Count) {
            $selectedFile = $filesData | Where-Object { $_.LP -eq $selectedFileNumber }
            $selectedArchitecture = $selectedFile.Nazwa

            Write-Host "Wybrano architektur�: $selectedArchitecture"
        } else {
            Write-Host "Wybrany numer architektury jest poza zakresem dost�pnych architektur."
        }
    } else {
        Write-Host "Podana warto�� nie jest liczb� ca�kowit�."
    }
}

# Aktualizacja zmiennej $url na podstawie wyboru u�ytkownika
$url = "https://build.funtoo.org/next/x86-64bit/$selectedArchitecture/"

######## End select architecture ######## 

######## Begin select stage ########

$response = Invoke-WebRequest -Uri $url

try {
    $response = Invoke-WebRequest -Uri $url

    # Parsowanie zawarto�ci HTML strony
    $html = $response.ParsedHtml
} catch {
    Write-Host "Wyst�pi� b��d podczas pobierania zawarto�ci strony: $($_.Exception.Message)"
    exit 1  # Zako�cz dzia�anie skryptu z kodem b��du
}

# Znalezienie wszystkich plik�w na stronie
$files = $html.getElementsByTagName("a") | Where-Object { $_.href -like "*.xz" }

# Wy�wietlenie przetworzonych plik�w w formie tabeli z numeracj�
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

# Wybieranie numeru architektury do pobrania od u�ytkownika
$selectedFileNumber = Read-Host "Podaj numer Stage3, kt�r� chcesz pobra� (LP) lub pozostaw puste i zostanie wybrana stage3-generic_64:"

if ([string]::IsNullOrWhiteSpace($selectedFileNumber)) {
  $stage3Link = $filesData | Where-Object { $_.Link -like "*/stage3-generic_64*" }

  if ($stage3Link -ne $null) {
    Write-Host "Znaleziono link do pliku stage3: $($stage3Link.Link)"
    $url = $stage3Link.Link
  } else {
    Write-Host "Nie znaleziono linku do pliku stage3."
  }
} else {
      if ($selectedFileNumber -as [int]) {
        $selectedFileNumber = [int]$selectedFileNumber

        # Sprawdzenie, czy wybrany numer mie�ci si� w zakresie dost�pnych architektur
        if ($selectedFileNumber -ge 1 -and $selectedFileNumber -le $filesData.Count) {
            $selectedFile = $filesData | Where-Object { $_.LP -eq $selectedFileNumber }
            $selectedstage3 = $selectedFile.Nazwa

            Write-Host "Wybrano stage3: $selectedstage3"
            $url = "https://build.funtoo.org/next/x86-64bit/$selectedArchitecture/$selectedstage3"

        } else {
            Write-Host "Wybrany numer architektury jest poza zakresem dost�pnych stage3."
        }
    } else {
        Write-Host "Podana warto�� nie jest liczb� ca�kowit�."
    }
}


Write-Host "$url"

######## End select stage ########
