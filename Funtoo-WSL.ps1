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

Write-Host "Naciœnij dowolny klawisz, aby kontynuowaæ..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

######## Begin select architecture ######## 

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
$selectedFileNumber = Read-Host "Podaj numer Stage3, któr¹ chcesz pobraæ (LP) lub pozostaw puste i zostanie wybrana stage3-generic_64:"

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

        # Sprawdzenie, czy wybrany numer mieœci siê w zakresie dostêpnych architektur
        if ($selectedFileNumber -ge 1 -and $selectedFileNumber -le $filesData.Count) {
            $selectedFile = $filesData | Where-Object { $_.LP -eq $selectedFileNumber }
            $selectedstage3 = $selectedFile.Nazwa

            Write-Host "Wybrano stage3: $selectedstage3"
            $url = "https://build.funtoo.org/next/x86-64bit/$selectedArchitecture/$selectedstage3"

        } else {
            Write-Host "Wybrany numer architektury jest poza zakresem dostêpnych stage3."
        }
    } else {
        Write-Host "Podana wartoœæ nie jest liczb¹ ca³kowit¹."
    }
}


Write-Host "$url"

######## End select stage ########
