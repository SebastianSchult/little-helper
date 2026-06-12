# prompts/

Prompts für little helper's KI-Enhancement-Stufe.

## Inhalt

- [grammar-correction.md](grammar-correction.md) — Ollama-Prompt für Grammatik- und Interpunktionskorrektur (verwendet in `OllamaEnhancer.swift`)

## Kontext

little helper hat zwei Enhancement-Stufen:

1. **Regelbasiert** (`AIEnhancer.swift`) — Füllwort-Filter + Interpunktion, immer lokal, kein Prompt nötig
2. **Ollama** (`OllamaEnhancer.swift`) — optionale LLM-Grammatikkorrektur via localhost:11434, konfigurierbar in Settings
