# Whisper Modelle

Übersicht der verfügbaren Whisper-Modelle in little helper.
Alle Modelle laufen lokal via WhisperKit (Core ML, Apple Silicon).

## Modell-Vergleich

| Modell | ID | Größe | RAM | Geschwindigkeit | Genauigkeit | Empfehlung |
|--------|----|-------|-----|-----------------|-------------|------------|
| Tiny | `openai_whisper-tiny` | ~150 MB | ~400 MB | sehr schnell (~1s) | ausreichend | Alltag, kurze Diktate |
| Base | `openai_whisper-base` | ~280 MB | ~600 MB | schnell (~2s) | gut | Allgemein |
| Small | `openai_whisper-small` | ~500 MB | ~1 GB | mittel (~4s) | sehr gut | Komplexe Texte |
| Medium | `openai_whisper-medium` | ~1.5 GB | ~3 GB | langsam (~8s) | exzellent | Höchste Präzision |

*Geschwindigkeiten gemessen auf M2 MacBook Air für ~10s Aufnahme.*

## Empfehlung

**Tiny** ist für den täglichen Einsatz die beste Wahl:
- Unter 1 Sekunde Transkriptionszeit
- Ausreichende Genauigkeit für klare Aussprache
- Geringer RAM-Verbrauch

**Small** oder **Medium** bei:
- Starkem Akzent oder undeutlicher Aussprache
- Fachjargon / technischen Begriffen
- Langen Diktaten (>30 Sekunden)

## Download

Modelle werden beim ersten Wechsel automatisch von Hugging Face heruntergeladen.
WhisperKit speichert sie in:

```
~/Library/Application Support/little-helper/models/
```

Der Download ist einmalig — danach läuft alles vollständig offline.

## Modell wechseln

Einstellungen öffnen → „Whisper-Modell" → gewünschtes Modell auswählen.
Das neue Modell lädt sofort im Hintergrund, die App bleibt währenddessen nutzbar.
