# IPTV Max - Download

Installer pubblici di IPTV Max, player IPTV in stile Netflix per TV e PC (il codice è privato).

> L'app non include contenuti: serve un abbonamento a un provider IPTV compatibile Xtream Codes (o una lista M3U).

## Scarica

Vai su [Releases](../../releases/latest) per l'ultima versione:

| File | Dispositivo |
|---|---|
| `iptvmax.apk` | Fire TV / Android TV |
| `IPTVMax.msi` | Windows (richiede [VLC 64-bit](https://www.videolan.org)) |
| `iptvmax-vega-aarch64.vpkg` | Vega OS (Fire TV Stick 4K Select) |
| `iptvmax-vega-armv7.vpkg`, `iptvmax-vega-x86_64.vpkg` | altri modelli Vega OS |

## Installazione su Fire TV / Android TV con Downloader

1. Installa l'app **Downloader** (AFTVnews) dall'Amazon Appstore (o dal Play Store su Android TV).
2. Aprila e inserisci il codice:

   ## `7180422`

3. Conferma l'installazione. La prima volta Fire OS chiede di consentire
   *Installa app sconosciute* per Downloader.

Il codice scarica sempre l'ultima versione.

## Link diretto

https://github.com/tommy052201/iptv-max-releases/releases/latest/download/iptvmax.apk

## Aggiornamenti

- **Fire TV / Android TV**: l'app controlla da sola le nuove release e mostra un avviso per aggiornare.
- **Windows**: esegui `IPTVMax.msi` (serve VLC 64-bit). L'app si aggiorna da sola quando la chiudi.

## Fire TV con Vega OS (es. Fire TV Stick 4K Select)

Le Fire TV con Vega OS non installano APK né usano Downloader: serve un pacchetto `.vpkg`, installato dal PC.
L'app è la stessa (grafica, film, serie, dirette, multiscreen, QR per aggiungere la lista dal telefono);
avvisa quando esce una versione nuova ma non si aggiorna da sola.

Pacchetti (ultima release):

- Fire TV Stick 4K Select: https://github.com/tommy052201/iptv-max-releases/releases/latest/download/iptvmax-vega-aarch64.vpkg
- `iptvmax-vega-armv7.vpkg` e `iptvmax-vega-x86_64.vpkg` per gli altri modelli Vega

### Installazione e aggiornamento da Windows

1. Sulla TV: *Impostazioni → La mia Fire TV → Opzioni sviluppatore*: attiva **Developer Mode** e imposta
   **Connection Mode = TCP/IP**.
2. Sul PC servono WSL (Ubuntu) con il **Vega SDK** installato (`~/vega`).
   La prima volta: `vega devmode login` e `vega devmode enable-device <codice mostrato dalla TV>`.
3. Scarica [`install-vega.ps1`](install-vega.ps1) ed esegui in PowerShell:

   ```powershell
   .\install-vega.ps1 -TvIp 192.168.1.37
   ```

   Lo script scarica l'ultima versione e la installa. Per **aggiornare** si riesegue lo stesso comando:
   account, lista, preferiti e cronologia restano (non disinstallare l'app prima, cancellerebbe i dati).
   Opzioni: `-Launch` avvia l'app a fine installazione, `-Path file.vpkg` usa un pacchetto già scaricato,
   `-Arch armv7|x86_64` per altri modelli.

Su Mac/Linux: `vega device install-app --packagePath iptvmax-vega-aarch64.vpkg --device <ip-tv>:5555`.

> Se il link dei `.vpkg` risponde 404, l'ultima release è stata pubblicata prima del supporto Vega: attendi la
> prossima build.

## Funzioni

- Grafica in stile Netflix, uguale su tutti i dispositivi: file di titoli, card che si allarga, sfondo del titolo selezionato
- TV in diretta con guida dei programmi ("in onda" e "a seguire") e multiscreen (2 canali su TV, 4 su PC)
- Film e serie con "Continua a guardare", prossimo episodio automatico e consigli a fine film
- Ricerca, La mia lista, generi e sezione Per te
- Aggiungi la lista dal telefono: inquadra il QR sulla TV e inserisci Xtream Codes, link M3U o file M3U (cifrato end-to-end)
