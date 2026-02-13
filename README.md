# Windows-Programm-Vorlagen

Wiederverwendbares Theme- und Template-System fuer WPF-Projekte (.NET 8).

## Inhalt

| Ordner / Datei | Beschreibung |
|---|---|
| `Themes/` | Farben, Brushes, Button-Styles, Window-Templates |
| `Base/` | BaseWindow-Klasse (Dialog-Basis mit Button-Leiste) |
| `Helpers/` | WindowHelper (Chrome-CommandBindings) |
| `Vorlagen/` | Lebende Vorlagen (im Designer bearbeitbar) |
| `ItemTemplates/` | VS Item Templates (automatisch generiert) |
| `docs/` | Ausfuehrliche Dokumentation |
| `Export-ItemTemplates.ps1` | Vorlagen â†’ VS Templates exportieren |
| `Update-Vorlage.ps1` | Fertiges Fenster â†’ Vorlage zurueckkopieren |
| `Import-PtoPVorlagen.ps1` | Dieses Repo in ein neues Projekt importieren |

## In ein neues Projekt importieren

```powershell
# 1. Repository klonen (einmalig)
git clone https://github.com/<user>/Windows-Programm-Vorlagen.git C:\repos\PtoP-Vorlagen

# 2. Im neuen Projekt-Ordner ausfuehren
C:\repos\Windows-Programm-Vorlagen\Import-PtoPVorlagen.ps1 -ProjektPfad "C:\repos\MeinNeuesProjekt" -Namespace "MeinNeuesProjekt"
```

Fertig! Alle Themes, Base-Klassen, Vorlagen und Skripte sind im neuen Projekt.

## Dokumentation

Siehe [docs/Themes-und-Templates.md](docs/Themes-und-Templates.md) fuer die vollstaendige Anleitung.

