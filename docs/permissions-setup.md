# Permissions Setup

little helper benötigt zwei macOS-Berechtigungen um zu funktionieren.

## 1. Mikrofon-Berechtigung

**Wann:** Beim ersten Hotkey-Druck wird automatisch ein Systemdialog angezeigt.

**Was passiert wenn verweigert:** Aufnahme startet nicht, Fehlermeldung im Overlay.

**Manuell einrichten:**
1. Apple-Menü → Systemeinstellungen → Datenschutz & Sicherheit
2. „Mikrofon" öffnen
3. little helper aktivieren

---

## 2. Accessibility-Berechtigung

**Wann:** Beim ersten App-Start erscheint automatisch ein Systemdialog.

**Warum notwendig:** little helper simuliert ⌘V um Text an der Cursor-Position einzufügen. CGEvent (Tastatureingaben simulieren) erfordert Accessibility-Zugriff.

**Manuell einrichten:**
1. Apple-Menü → Systemeinstellungen → Datenschutz & Sicherheit
2. „Bedienungshilfen" öffnen
3. little helper aktivieren (ggf. erst durch das Schloss entsperren)

**Was passiert wenn verweigert:** Text-Insertion funktioniert nicht — Text landet zwar im Clipboard aber wird nicht automatisch eingefügt.

---

## Warum beide Berechtigungen?

| Berechtigung | Zweck |
|---|---|
| Mikrofon | Sprachaufnahme via AVAudioEngine |
| Accessibility | ⌘V-Simulation via CGEvent für Text-Insertion |

Beide Berechtigungen werden **nur bei aktiver Nutzung** verwendet. little helper macht keine Hintergrundaufnahmen und sendet keine Daten nach außen.
