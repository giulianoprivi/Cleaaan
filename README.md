# Cleaaan

Pulisci Desktop e Download con un clic.

## Installazione

1. Vai su [**Releases**](../../releases) e scarica `Cleaaan.dmg`
2. Apri il `.dmg` e trascina **Cleaaan** nella cartella Applicazioni
3. Al primo avvio, se macOS mostra "sviluppatore non identificato":
   - Fai **tasto destro** → **Apri**
   - Oppure: **Impostazioni di Sistema → Privacy e Sicurezza → Apri comunque**

## Come si usa

1. Apri Cleaaan dal Dock o dall'icona nella barra dei menu
2. Seleziona **Desktop**, **Downloads**, o entrambi
3. Clicca **Pulisci**

I file vengono spostati in `~/Desktop/Roba cleaaan/`:

| Cartella     | Estensioni                                |
|--------------|-------------------------------------------|
| Documenti    | pdf, docx, pages, xlsx, numbers, key, … |
| Immagini     | png, jpg, heic, gif, svg, …              |
| Video        | mp4, mov, avi, mkv, …                    |
| Altro        | tutto il resto                            |

## Pubblica una nuova versione

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions compila e pubblica automaticamente il `.dmg`.
