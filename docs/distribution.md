# Distribution

## Welcher Weg passt?

| Szenario | Skript | Voraussetzung |
|----------|--------|---------------|
| Nur für dich selbst | `./scripts/build-local.sh` | xcodegen |
| Teilen mit Freunden | `./scripts/build-local.sh` | xcodegen — Empfänger klickt einmalig Rechtsklick → Öffnen |
| Breite Distribution (kein Gatekeeper-Dialog) | `./scripts/build-dmg.sh` | Apple Developer Account (99 €/Jahr) |

---

## Lokaler Build (kein Developer Account)

```bash
./scripts/build-local.sh
```

Erstellt `build/little-helper-VERSION.dmg` — ad-hoc signiert, kein notarytool.

**Installation:**
1. DMG öffnen
2. App in den Applications-Ordner ziehen

**Erster Start auf einem anderen Mac:**
Gatekeeper zeigt eine Warnung weil die App nicht notarisiert ist.
Einmalig umgehen: Rechtsklick auf die App → **Öffnen** → im Dialog bestätigen.

---

## Voraussetzungen

### Einmalig installieren

```bash
brew install xcodegen create-dmg
```

### Apple Developer Account

- Bezahltes Apple Developer Program erforderlich (99 $/Jahr)
- Zertifikat: **Developer ID Application** — in Xcode unter Settings → Accounts → Manage Certificates anlegen
- Team ID: 10-stelliger alphanumerischer Code, sichtbar unter [developer.apple.com/account](https://developer.apple.com/account)

### App-spezifisches Passwort

Für `notarytool` wird ein App-spezifisches Passwort benötigt (kein Apple-ID-Passwort):

1. [appleid.apple.com](https://appleid.apple.com) → Anmeldung und Sicherheit → App-spezifische Passwörter
2. Neues Passwort für „notarytool" erstellen
3. Passwort einmalig im Keychain speichern:

```bash
xcrun notarytool store-credentials "notarytool" \
  --apple-id "schult.sebastian@googlemail.com" \
  --team-id "DEIN_TEAM_ID" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

### ExportOptions.plist anpassen

In `ExportOptions.plist` die Zeile mit `YOUR_TEAM_ID` durch die echte Team ID ersetzen:

```xml
<key>teamID</key>
<string>DEIN_TEAM_ID</string>
```

---

## Release bauen

```bash
TEAM_ID=DEIN_TEAM_ID ./scripts/build-dmg.sh
```

Das Skript führt automatisch alle Schritte aus:

| Schritt | Was passiert |
|---------|-------------|
| 1. xcodegen | Xcode-Projekt aus `project.yml` generieren |
| 2. Archive | Release-Build mit Developer ID signieren |
| 3. Export | `.app` aus dem Archiv exportieren |
| 4. DMG | `create-dmg` erstellt installierbares DMG mit App + Applications-Link |
| 5. Notarize | `xcrun notarytool` lädt DMG bei Apple hoch (dauert 1–5 min) |
| 6. Staple | Notarisierungsticket wird in das DMG eingebettet |

Das fertige DMG landet in `build/little-helper-VERSION.dmg`.

---

## Version erhöhen

In `Info.plist`:

```xml
<key>CFBundleShortVersionString</key>
<string>0.2.0</string>     <!-- Marketing-Version, sichtbar für User -->
<key>CFBundleVersion</key>
<string>2</string>          <!-- Build-Nummer, monoton steigend -->
```

---

## Troubleshooting

### „Developer ID Application certificate not found"

Das Zertifikat fehlt im Keychain. Lösung:

1. Xcode → Settings → Accounts → dein Apple-ID → Manage Certificates
2. „+" → Developer ID Application anlegen
3. Zertifikat wird automatisch in den Keychain importiert

### „Notarization failed: The signature of the binary is invalid"

Hardened Runtime muss aktiviert sein. In `project.yml` prüfen:

```yaml
ENABLE_HARDENED_RUNTIME: YES
```

### „xcrun notarytool: keychain profile not found"

Keychain-Profil noch nicht angelegt. Den `store-credentials`-Befehl aus dem Setup-Abschnitt ausführen.

### Notarisierung dauert länger als 5 Minuten

Normal bei Apple-Auslastung. `notarytool submit --wait` wartet automatisch. Alternativ ohne `--wait` einreichen und später mit `notarytool log` den Status abfragen.

---

## Dateistruktur

```
ExportOptions.plist     ← Signing-Konfiguration für xcodebuild -exportArchive
scripts/build-dmg.sh    ← Build-Pipeline (ausführbar mit TEAM_ID=... ./scripts/build-dmg.sh)
build/                  ← Gitignored — hier landen Archiv, Export und fertiges DMG
```
