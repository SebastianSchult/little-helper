# Ollama Grammar Correction Prompt

Wird in `OllamaEnhancer.swift` verwendet für optionale KI-Grammatikkorrektur via lokalem Ollama.

## Prompt

```
Correct grammar, punctuation, and sentence structure.
CRITICAL: Respond in the EXACT SAME language as the input. Never translate.
Return ONLY the corrected text, nothing else.

Input: {text}
Output:
```

## Parameter

| Parameter | Wert | Grund |
|-----------|------|-------|
| `temperature` | 0.1 | Geringe Kreativität — nur korrigieren, nicht umschreiben |
| `stream` | false | Einfachere Response-Verarbeitung |
| Timeout | 15s | Lokale Latenz für llama3.2:3b ~1-2s auf Apple Silicon |

## Design-Entscheidungen

**CRITICAL-Direktive für Sprache:** Ohne explizite Anweisung antwortet llama3.2:3b in der Sprache des Prompts (Englisch), nicht in der Sprache des Inputs. Die `CRITICAL`-Formulierung erhöht die Compliance deutlich.

**"Return ONLY the corrected text":** Verhindert, dass das Modell Kommentare, Erklärungen oder Präambeln zurückgibt.

**Kein System-Prompt:** Ollama's `/api/generate` Endpoint wird mit einem kombinierten User-Prompt verwendet statt separatem `system`-Feld — einfacher und reproduzierbarer.

## Kompatible Modelle

Getestet mit:
- `llama3.2:3b` — Default, ~2GB, ~1-2s Latenz, gutes Deutsch ✓
- `llama3.1:8b` — Höhere Qualität, ~5GB, ~3-5s Latenz ✓
- `deepseek-r1:7b` — **Nicht empfohlen**: Reasoning-Modell mit Chain-of-Thought → zu langsam

## Anforderungen

- Ollama lokal installiert: `brew install ollama`
- Modell gepullt: `ollama pull llama3.2:3b`
- Ollama läuft: `ollama serve` (oder als LaunchAgent)
