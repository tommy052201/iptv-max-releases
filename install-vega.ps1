<#
.SYNOPSIS
  Installa (o aggiorna) IPTV Max su una Fire TV con Vega OS, da Windows.

.DESCRIPTION
  Scarica l'ultimo .vpkg dalla release pubblica (oppure usa un file locale) e lo installa sulla TV col Vega SDK,
  che su Windows gira dentro WSL. Un'installazione sopra una versione esistente la aggiorna e conserva
  account, lista, preferiti e cronologia (non disinstallare prima: cancellerebbe i dati).

  Prima volta su una TV: Impostazioni > La mia Fire TV > Opzioni sviluppatore > Developer Mode acceso e
  "Connection Mode" = TCP/IP. Se la TV non è ancora autorizzata, serve il codice mostrato dalla TV:
  esegui in WSL `vega devmode login` e `vega devmode enable-device <codice>`.

.PARAMETER TvIp
  Indirizzo IP della Fire TV (Impostazioni > La mia Fire TV > Informazioni > Rete).

.PARAMETER Arch
  aarch64 (Fire TV Stick 4K Select, predefinito e provato), armv7 o x86_64.

.PARAMETER Path
  Usa questo .vpkg invece di scaricare l'ultima release.

.PARAMETER Distro
  Distribuzione WSL con il Vega SDK (predefinita: Ubuntu).

.PARAMETER Launch
  Avvia l'app dopo l'installazione.

.EXAMPLE
  .\scripts\install-vega.ps1 -TvIp 192.168.1.37

.EXAMPLE
  .\scripts\install-vega.ps1 -TvIp 192.168.1.37 -Path .\iptvmaxvega_aarch64.vpkg -Launch
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$TvIp,
    [ValidateSet('aarch64', 'armv7', 'x86_64')][string]$Arch = 'aarch64',
    [string]$Path,
    [string]$Distro = 'Ubuntu',
    [switch]$Launch
)

$ErrorActionPreference = 'Stop'
$AppId = 'com.iptvmax.tv.main'
$Repo = 'tommy052201/iptv-max-releases'

if ($TvIp -notmatch '^\d{1,3}(\.\d{1,3}){3}$') { throw "Indirizzo IP non valido: $TvIp" }
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    throw 'WSL non trovato. Il Vega SDK su Windows gira in WSL (installalo in ~/vega della distribuzione Linux).'
}

# 1. Il pacchetto
if ($Path) {
    if (-not (Test-Path $Path)) { throw "File non trovato: $Path" }
    # ProviderPath: con percorsi UNC (\\wsl.localhost\...) .Path include il prefisso del provider PowerShell.
    $vpkg = (Resolve-Path $Path).ProviderPath
} else {
    $vpkg = Join-Path ([IO.Path]::GetTempPath()) "iptvmax-vega-$Arch.vpkg"
    $url = "https://github.com/$Repo/releases/latest/download/iptvmax-vega-$Arch.vpkg"
    Write-Host "Scarico $url"
    try {
        Invoke-WebRequest -Uri $url -OutFile $vpkg -UseBasicParsing
    } catch {
        throw "Download non riuscito ($($_.Exception.Message)). Scarica il .vpkg a mano dalla release e usa -Path."
    }
}
Write-Host ("Pacchetto: {0} ({1:N1} MB)" -f $vpkg, ((Get-Item $vpkg).Length / 1MB))

# 2. Installazione dentro WSL (il percorso Windows diventa un percorso Linux)
$wslPath = (& wsl -d $Distro -- wslpath -a ($vpkg -replace '\\', '/')).Trim()
if (-not $wslPath) { throw "WSL '$Distro' non risponde: controlla il nome con 'wsl -l'." }

$launchLine = if ($Launch) { "vega device launch-app --appName $AppId --device ${TvIp}:5555" } else { 'true' }
$script = @"
set -e
. ~/vega/env 2>/dev/null || { echo 'Vega SDK non trovato in WSL (~/vega)' >&2; exit 2; }
vega exec vda connect ${TvIp}:5555
vega device install-app --packagePath '$wslPath' --device ${TvIp}:5555
$launchLine
"@
# Fine riga Unix: bash non accetta \r.
$script = $script -replace "`r", ''
$tmp = [IO.Path]::GetTempFileName()
[IO.File]::WriteAllText($tmp, $script, (New-Object Text.UTF8Encoding($false)))
$wslScript = (& wsl -d $Distro -- wslpath -a ($tmp -replace '\\', '/')).Trim()
Write-Host "Installo su $TvIp ..."
& wsl -d $Distro -- bash $wslScript
$code = $LASTEXITCODE
Remove-Item $tmp -ErrorAction SilentlyContinue
if ($code -ne 0) {
    throw "Installazione non riuscita (codice $code). Controlla: Developer Mode acceso, Connection Mode = TCP/IP, TV e PC nella stessa rete."
}
Write-Host 'Fatto. IPTV Max è installata: aprila dalla TV (account e lista restano se era già installata).'
