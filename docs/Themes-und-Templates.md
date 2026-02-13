# PtoP Windows – Themes & Templates Anleitung

## Übersicht

Dieses Projekt verwendet ein zentrales Theme-System und wiederverwendbare Fenster-Vorlagen.
Alle Farben, Styles und Layouts werden an **einer Stelle** definiert und wirken global.

```
Projekt-Struktur (Theme & Templates)
─────────────────────────────────────
Themes/
├── Controls.xaml          ← Farben, Brushes, Button-Styles, Window-Templates
├── Colors.xaml            ← Farb-Definitionen (Referenz)
└── Typography.xaml        ← Schriftarten, TextBlock-Defaults

Base/
└── BaseWindow.cs          ← Basis-Klasse für Dialog-Fenster (Button-Leiste)

Helpers/
└── WindowHelper.cs        ← Chrome-CommandBindings (Close, Minimize, ...)

Vorlagen/                  ← "Lebende Vorlagen" – echte Fenster, im Designer bearbeitbar
├── VorlageEinfacherDialog.xaml / .cs
├── VorlageListenDialog.xaml / .cs
└── VorlageHauptfenster.xaml / .cs

ItemTemplates/             ← VS Item Templates (automatisch generiert)
├── PtoP_Dialog_Einfach/
├── PtoP_Dialog_Liste/
└── PtoP_Hauptfenster/

Export-ItemTemplates.ps1   ← Skript: Vorlagen → VS Item Templates exportieren
```

---

## 1. Theme-System

### 1.1 Wo sind die Farben definiert?

Alle Farben stehen in `Themes/Controls.xaml`:

```xml
<!-- Beispiel: Akzentfarbe ändern -->
<Color x:Key="Color.Accent">#FF60A5FA</Color>        ← Blau
<Color x:Key="Color.AccentHover">#FF3B82F6</Color>
<Color x:Key="Color.AccentPressed">#FF2563EB</Color>
```

**Eine Farbe hier ändern → ändert sich überall im Programm.**

### 1.2 Verfügbare Farb-Tokens

| Token | Verwendung |
|---|---|
| `Color.Background` / `Brush.Background` | Fenster-Hintergrund |
| `Color.Surface` / `Brush.Surface` | Karten, Panels, Titelleisten |
| `Color.Border` / `Brush.Border` | Rahmen und Trennlinien |
| `Color.TextPrimary` / `Brush.TextPrimary` | Haupttext |
| `Color.TextSecondary` / `Brush.TextSecondary` | Sekundärtext, Beschreibungen |
| `Color.Accent` / `Brush.Accent` | Primäre Akzentfarbe (Buttons) |
| `Color.AccentHover` / `Brush.AccentHover` | Hover-Zustand |
| `Color.AccentPressed` / `Brush.AccentPressed` | Gedrückt-Zustand |
| `Color.Danger` / `Brush.Danger` | Löschen/Beenden-Buttons |
| `Color.DangerHover` / `Brush.DangerHover` | Danger Hover |
| `Color.DangerPressed` / `Brush.DangerPressed` | Danger Gedrückt |
| `Color.Disabled` / `Brush.Disabled` | Deaktivierte Elemente |
| `Color.ListBackground` / `Brush.ListBackground` | ListBox-Hintergrund |
| `Color.ListItemHover` / `Brush.ListItemHover` | ListBox-Item Hover |
| `Color.ListItemSelected` / `Brush.ListItemSelected` | ListBox-Item ausgewählt |
| `Color.ButtonPanel` / `Brush.ButtonPanel` | 3D-Button-Sockel |

### 1.3 Verfügbare Button-Styles

```xml
<!-- Standard (blau, primär) – wird automatisch verwendet -->
<Button Content="Speichern"/>

<!-- Danger (grau → rot bei Hover) -->
<Button Content="Löschen" Style="{StaticResource DangerButton}"/>

<!-- Secondary (transparent, blauer Outline) -->
<Button Content="Abbrechen" Style="{StaticResource SecondaryButton}"/>

<!-- Save (grau → grün bei Hover) -->
<Button Content="Speichern" Style="{StaticResource SaveButton}"/>

<!-- Cancel (transparent → blassrot bei Hover) -->
<Button Content="Abbrechen" Style="{StaticResource CancelButton}"/>
```

| Style | Aussehen | Hover-Effekt |
|---|---|---|
| *(Standard)* | Blau, 3D-Bevel | Dunkler blau |
| `DangerButton` | Grau, 3D-Bevel | Rot |
| `SaveButton` | Grau, 3D-Bevel | Grün |
| `CancelButton` | Transparent, kein Rahmen | Blassrot |
| `SecondaryButton` | Transparent, blauer Outline | Blau gefüllt |

### 1.4 Verfügbare Control-Styles

#### ToggleButton

```xml
<!-- Grau wenn aus, Grün wenn an -->
<ToggleButton Content="Nicht gedrückt"/>
<ToggleButton Content="Gedrückt" IsChecked="True"/>
```

#### CheckBox

```xml
<!-- Auf grauem PanelHost-Panel -->
<CheckBox Content="Option A"/>
<CheckBox Content="Option B (aktiv)" IsChecked="True"/>
```

#### ContextMenu / MenuItem

Kontextmenüs werden automatisch gestylt (implizite Styles). Einfach wie gewohnt verwenden:

```xml
<Border.ContextMenu>
    <ContextMenu>
        <MenuItem Header="Ausschneiden" InputGestureText="Strg+X"/>
        <MenuItem Header="Kopieren" InputGestureText="Strg+C"/>
        <Separator/>
        <MenuItem Header="Deaktiviert" IsEnabled="False"/>
    </ContextMenu>
</Border.ContextMenu>
```

#### ListBox

ListBox und ListBoxItem haben implizite Styles mit Hover- und Auswahl-Farben.

### 1.5 Verfügbare Window-Styles

| Style | Verwendung | Basis |
|---|---|---|
| `PtoPWindow` | Hauptfenster mit eigenem Chrome | `Window` |
| (implizit für `BaseWindow`) | Dialog-Fenster mit Button-Leiste | `BaseWindow` |

### 1.6 Wie werden Themes geladen?

In `App.xaml`:

```xml
<Application.Resources>
    <ResourceDictionary>
        <ResourceDictionary.MergedDictionaries>
            <ResourceDictionary Source="Themes/Controls.xaml"/>
            <ResourceDictionary Source="Themes/Typography.xaml"/>
        </ResourceDictionary.MergedDictionaries>
    </ResourceDictionary>
</Application.Resources>
```

**Reihenfolge wichtig:** Controls.xaml (Farben + Styles) VOR Typography.xaml (braucht die Brushes).

---

## 2. BaseWindow – Dialog-Basis

`BaseWindow` ist die Basisklasse für alle Dialog-Fenster. Sie bietet eine konfigurierbare
Button-Leiste (OK, Abbrechen, Löschen) über Dependency Properties.

### 2.1 Verfügbare Properties

| Property | Typ | Default | Beschreibung |
|---|---|---|---|
| `ShowButtonBar` | bool | `true` | Button-Leiste anzeigen |
| `ShowOkButton` | bool | `true` | OK/Speichern-Button |
| `OkButtonText` | string | `"OK"` | Text des OK-Buttons |
| `OkCommand` | ICommand | null | Command für OK-Button |
| `OkButtonToolTip` | object | null | ToolTip des OK-Buttons |
| `ShowCancelButton` | bool | `true` | Abbrechen-Button |
| `CancelButtonText` | string | `"Abbrechen"` | Text des Abbrechen-Buttons |
| `CancelCommand` | ICommand | null | Command für Abbrechen |
| `CancelButtonToolTip` | object | null | ToolTip des Abbrechen-Buttons |
| `ShowDeleteButton` | bool | `false` | Löschen-Button (links) |
| `DeleteButtonText` | string | `"Löschen"` | Text des Löschen-Buttons |
| `DeleteCommand` | ICommand | null | Command für Löschen |
| `DeleteButtonToolTip` | object | null | ToolTip des Löschen-Buttons |

### 2.2 Beispiel: Neuen Dialog erstellen (manuell)

**XAML:**
```xml
<b:BaseWindow x:Class="PtoP_Windows_Urversion.MeinDialog"
              xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
              xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
              xmlns:b="clr-namespace:PtoP_Windows_Urversion.Base"
              Title="Mein Dialog"
              Height="400" Width="500"
              ShowOkButton="True"
              OkButtonText="Speichern"
              ShowCancelButton="True"
              ShowDeleteButton="False"
              ShowButtonBar="True"
              OkButtonToolTip="Änderungen speichern"
              CancelButtonToolTip="Dialog schließen ohne zu speichern">

    <StackPanel>
        <!-- Eigener Inhalt hier -->
    </StackPanel>

</b:BaseWindow>
```

**Code-Behind:**
```csharp
namespace PtoP_Windows_Urversion;

public partial class MeinDialog : Base.BaseWindow
{
    public MeinDialog()
    {
        InitializeComponent();
    }
}
```

### 2.3 Dialog öffnen

```csharp
// Modal (blockiert aufrufendes Fenster)
var dialog = new MeinDialog { Owner = this };
dialog.ShowDialog();

// Nicht-modal
var dialog = new MeinDialog();
dialog.Show();
```

### 2.4 Technischer Hinweis: Style-Auflösung

`BaseWindow` verwendet `SetResourceReference(StyleProperty, typeof(BaseWindow))` im Konstruktor,
um den impliziten Style aus `Controls.xaml` zu laden. Das ist nötig, weil ohne `Themes/Generic.xaml`
der `DefaultStyleKeyProperty`-Mechanismus den Style nicht automatisch findet.

---

## 3. Vorlagen-Fenster (Lebende Vorlagen)

### 3.1 Konzept

Im Ordner `Vorlagen/` liegen **echte, kompilierbare WPF-Fenster**.
Diese kann man:

- ✅ Im WPF Designer visuell bearbeiten
- ✅ Mit F5 starten und testen
- ✅ Mit IntelliSense bearbeiten
- ✅ Per Skript in VS Item Templates exportieren

### 3.2 Verfügbare Vorlagen

| Datei | Fenster-Typ | Beschreibung |
|---|---|---|
| `VorlageEinfacherDialog` | BaseWindow-Dialog | Formular mit Eingabefeldern + Button-Leiste |
| `VorlageListenDialog` | BaseWindow-Dialog | ListBox links, Detail rechts + Button-Leiste |
| `VorlageHauptfenster` | Window + PtoPWindow | Hauptfenster mit Toolbar + Statusleiste |

### 3.3 Vorlage visuell bearbeiten

1. Öffne z.B. `Vorlagen/VorlageListenDialog.xaml` im Designer
2. Bearbeite das Layout visuell oder im XAML-Editor
3. Teste mit F5 (ggf. `StartupUri` in `App.xaml` temporär anpassen)
4. Wenn zufrieden → Template exportieren (siehe Abschnitt 4)

---

## 4. VS Item Templates

### 4.1 Templates exportieren & installieren

Nach dem Bearbeiten einer Vorlage:

```powershell
.\Export-ItemTemplates.ps1
```

Dann **Visual Studio neu starten**.

Das Skript macht folgendes automatisch:
1. Liest die Vorlagen aus `Vorlagen/`
2. Ersetzt Namespace → `$rootnamespace$` und Klassenname → `$safeitemname$`
3. Erzeugt `.vstemplate`-Pakete in `ItemTemplates/`
4. Kopiert die ZIP-Dateien nach `%USERPROFILE%\Documents\Visual Studio 2022\Templates\ItemTemplates\PtoP\`

### 4.2 Template verwenden

1. **Rechtsklick auf Projekt** → **Hinzufügen** → **Neues Element...**
2. In der Suche **"PtoP"** eingeben
3. Vorlage auswählen:
   - **PtoP Einfacher Dialog**
   - **PtoP Listen-Dialog**
   - **PtoP Hauptfenster**
4. Namen eingeben → **Hinzufügen**

VS erzeugt die `.xaml` + `.xaml.cs` Dateien mit dem eingegebenen Namen.

### 4.3 Platzhalter-Zuordnung

| Im Vorlagen-Fenster | Im Template | Bei Verwendung |
|---|---|---|
| `PtoP_Windows_Urversion.Vorlagen` | `$rootnamespace$` | Projekt-Namespace |
| `VorlageEinfacherDialog` | `$safeitemname$` | Eingegebener Name |

### 4.4 Fertiges Fenster zurück ins Template übernehmen

Wenn Sie ein Fenster, das aus einem Template erstellt wurde, verändert haben und diese
Änderungen **zum neuen Standard-Template** machen wollen:

```powershell
# Schritt 1: Fertiges Fenster → Vorlage zurückkopieren
.\Update-Vorlage.ps1 -Quelle KundenDialog -Vorlage VorlageEinfacherDialog

# Schritt 2: Vorlage → VS Item Template exportieren
.\Export-ItemTemplates.ps1

# Schritt 3: Visual Studio neu starten
```

**Beispiel-Ablauf im Detail:**

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Template verwenden (VS: "Neues Element → PtoP")          │
│                                                             │
│    VS ersetzt automatisch:                                  │
│    $safeitemname$    → KundenDialog                          │
│    $rootnamespace$   → PtoP_Windows_Urversion                │
│                                                             │
│    Button-Texte, Event-Handler usw. bleiben unverändert ✅   │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. KundenDialog.xaml visuell bearbeiten                     │
│                                                             │
│    z.B. Button umbenennen: "Speichern" → "Buchen"           │
│    z.B. neues Feld: <TextBox x:Name="txtKunde"/>            │
│    z.B. neuer Button: Click="Drucken_Click"                 │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Update-Vorlage.ps1 ausführen                             │
│                                                             │
│    Das Skript ersetzt NUR:                                  │
│    "KundenDialog"              → "VorlageEinfacherDialog"   │
│    "PtoP_Windows_Urversion"    → "…Vorlagen"                │
│                                                             │
│    Alles andere bleibt UNVERÄNDERT:                         │
│    "Buchen" bleibt "Buchen" ✅                               │
│    "txtKunde" bleibt "txtKunde" ✅                           │
│    "Drucken_Click" bleibt "Drucken_Click" ✅                 │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Export-ItemTemplates.ps1 ausführen                       │
│                                                             │
│    Das Skript ersetzt NUR:                                  │
│    "VorlageEinfacherDialog"    → "$safeitemname$"            │
│    "PtoP_Windows_Urversion…"   → "$rootnamespace$"           │
│                                                             │
│    "Buchen" bleibt "Buchen" ✅                               │
│    "txtKunde" bleibt "txtKunde" ✅                           │
│    "Drucken_Click" bleibt "Drucken_Click" ✅                 │
└─────────────────────────────────────────────────────────────┘
```

**Wichtig:** Die Skripte ersetzen **ausschließlich Klassennamen und Namespaces** – niemals
Button-Beschriftungen, Event-Handler-Namen, Control-Namen oder Layout-Eigenschaften.
Alles was Sie visuell geändert haben, bleibt erhalten.

**Welche Vorlage für welches Fenster?**

| Wenn das Fenster ein... ist | Dann `-Vorlage` Parameter |
|---|---|
| Einfacher Dialog (BaseWindow) | `VorlageEinfacherDialog` |
| Listen-Dialog (BaseWindow) | `VorlageListenDialog` |
| Hauptfenster (Window + PtoPWindow) | `VorlageHauptfenster` |

**Backup:** Das Skript erstellt automatisch `.bak`-Dateien der alten Vorlage bevor es überschreibt.

---

## 5. Zusammenfassung: Was wo ändern?

| Ich möchte... | Datei / Befehl |
|---|---|
| Eine Farbe global ändern | `Themes/Controls.xaml` → Color-Tokens |
| Einen Button-Style ändern | `Themes/Controls.xaml` → Button Styles |
| Die Dialog-Button-Leiste ändern | `Themes/Controls.xaml` → BaseWindow Template |
| Die Titelleiste ändern | `Themes/Controls.xaml` → PtoPWindow / BaseWindow Template |
| Schriftart / Schriftgröße ändern | `Themes/Typography.xaml` |
| Neue DependencyProperty für Dialoge | `Base/BaseWindow.cs` |
| Fenster-Vorlage visuell bearbeiten | `Vorlagen/*.xaml` im Designer |
| Templates nach Änderung aktualisieren | `.\Export-ItemTemplates.ps1` ausführen |
| Fertiges Fenster → Template zurück | `.\Update-Vorlage.ps1 -Quelle X -Vorlage Y` |
| Neues Fenster im Projekt anlegen | VS → Neues Element → "PtoP" suchen |
| Vorlagen als eigenes Repo exportieren | `.\Export-PtoPVorlagen.ps1` (erst wenn Stand stabil ist) |
| Vorlagen in neues Projekt importieren | `.\Import-PtoPVorlagen.ps1 -ProjektPfad X -Namespace Y` |

---

## 6. Vorlagen-Repository (Wiederverwendung in neuen Projekten)

### 6.1 Konzept

Alle wiederverwendbaren Teile (Themes, Base, Helpers, Vorlagen, Templates, Skripte, Doku)
können in ein **eigenes GitHub-Repository** exportiert werden. Von dort lassen sie sich
in jedes neue WPF-Projekt importieren – mit automatischer Namespace-Anpassung.

```
Windows-Programm-Vorlagen (GitHub-Repo)   Neues Projekt
┌────────────────────────┐           ┌────────────────────────┐
│ Themes/                │           │ Themes/          ✅     │
│ Base/                  │  Import   │ Base/            ✅     │
│ Helpers/               │ ───────►  │ Helpers/         ✅     │
│ Vorlagen/              │           │ Vorlagen/        ✅     │
│ ItemTemplates/         │           │ ItemTemplates/   ✅     │
│ docs/                  │           │ docs/            ✅     │
│ Skripte (.ps1)         │           │ Skripte (.ps1)   ✅     │
└────────────────────────┘           └────────────────────────┘
  PtoP_Windows_Urversion               MeinNeuerNamespace
     (Original-Namespace)            (automatisch angepasst)
```

### 6.2 Erstmalig: Vorlagen-Repository erstellen

```powershell
# 1. Aus dem aktuellen Projekt exportieren
.\Export-PtoPVorlagen.ps1 -Ziel "C:\repos\Windows-Programm-Vorlagen"

# 2. Git-Repository initialisieren
cd "C:\repos\Windows-Programm-Vorlagen"
git init
git remote add origin https://github.com/<user>/Windows-Programm-Vorlagen.git
git add -A
git commit -m "Initiales Vorlagen-Repository"
git push -u origin master
```

### 6.3 In ein neues Projekt importieren

```powershell
# 1. Vorlagen-Repo klonen (einmalig pro Rechner)
git clone https://github.com/<user>/Windows-Programm-Vorlagen.git C:\repos\Windows-Programm-Vorlagen

# 2. In das neue Projekt importieren
C:\repos\Windows-Programm-Vorlagen\Import-PtoPVorlagen.ps1 `
    -ProjektPfad "C:\repos\MeinNeuesProjekt" `
    -Namespace "MeinNeuesProjekt"

# 3. In der .csproj die ItemTemplates ausschließen:
#    <ItemGroup>
#      <None Remove="ItemTemplates\**" />
#      <Compile Remove="ItemTemplates\**" />
#      <Page Remove="ItemTemplates\**" />
#    </ItemGroup>

# 4. In App.xaml die ResourceDictionaries einfügen:
#    <ResourceDictionary Source="Themes/Controls.xaml"/>
#    <ResourceDictionary Source="Themes/Typography.xaml"/>

# 5. VS Item Templates installieren
.\Export-ItemTemplates.ps1
```

### 6.4 Vorlagen-Repo aktualisieren

Wenn Sie die Vorlagen im aktuellen Projekt verbessert haben:

```powershell
# 1. Erneut exportieren (überschreibt das Repo)
.\Export-PtoPVorlagen.ps1 -Ziel "C:\repos\Windows-Programm-Vorlagen"

# 2. Änderungen committen & pushen
cd "C:\repos\Windows-Programm-Vorlagen"
git add -A
git commit -m "Vorlagen aktualisiert"
git push
```

### 6.5 Was wird angepasst, was nicht?

| Beim Import angepasst | Beispiel |
|---|---|
| Namespaces in `.cs` Dateien | `PtoP_Windows_Urversion` → `MeinProjekt` |
| Namespaces in `.xaml` Dateien | `clr-namespace:PtoP_Windows_Urversion.Base` → `clr-namespace:MeinProjekt.Base` |
| Namespace in Skripten | `$rootNamespace = "PtoP_Windows_Urversion"` → `$rootNamespace = "MeinProjekt"` |

| NICHT angepasst (bewusst) |
|---|
| Farben, Brushes, Styles |
| Button-Texte, Event-Handler |
| Layouts, Margins, Größen |
| Resource-Keys (`Brush.Accent` etc.) |

### 6.6 Empfohlener Workflow: Im Hauptprojekt entwickeln → dann exportieren

Das Hauptprojekt (**PtoP Windows Urversion**) ist die zentrale Entwicklungsumgebung für
Themes, Templates und Vorlagen. Hier wird alles gebaut, getestet und verfeinert.
Erst wenn ein stabiler Stand erreicht ist, wird in ein separates Repository exportiert.

```
Phase 1: Entwicklung (im Hauptprojekt)
──────────────────────────────────────────────────────

  PtoP Windows Urversion (Hauptprojekt)
  ┌──────────────────────────────────────┐
  │ 1. Themes/Controls.xaml bearbeiten   │
  │    (Farben, Brushes, Button-Styles)  │
  │                                      │
  │ 2. Vorlagen/ im Designer bearbeiten  │
  │    (Layouts, neue Controls)          │
  │                                      │
  │ 3. Mit F5 testen                     │
  │    (MainWindow.xaml zeigt alles)     │
  │                                      │
  │ 4. Export-ItemTemplates.ps1          │
  │    (VS Item Templates aktualisieren) │
  └──────────────────────────────────────┘
       ▼ Wenn zufrieden ...

Phase 2: Export (in separates Repo)
──────────────────────────────────────────────────────

  .\Export-PtoPVorlagen.ps1 -Ziel "C:\repos\Windows-Programm-Vorlagen"

  Windows-Programm-Vorlagen (separates GitHub-Repo)
  ┌──────────────────────────────────────┐
  │ Themes/          ✅                   │
  │ Base/            ✅                   │
  │ Helpers/         ✅                   │
  │ Vorlagen/        ✅                   │
  │ ItemTemplates/   ✅                   │
  │ docs/            ✅                   │
  │ Skripte (.ps1)   ✅                   │
  │ README.md        ✅                   │
  └──────────────────────────────────────┘
       ▼
  git add -A && git commit && git push
```

**Warum dieser Workflow?**

| Vorteil | Erklärung |
|---|---|
| **Alles an einem Ort** | Themes, Vorlagen und die Style-Testseite (MainWindow) sind im gleichen Projekt |
| **Sofort testbar** | F5 zeigt sofort alle Änderungen in der Style-Übersicht |
| **Designer-Unterstützung** | Vorlagen sind echte Fenster, voll im WPF Designer nutzbar |
| **Kein Sync-Problem** | Erst entwickeln, dann exportieren – kein Hin-und-Her zwischen Repos |
| **Jederzeit exportierbar** | `Export-PtoPVorlagen.ps1` kann beliebig oft ausgeführt werden |

**Wichtig:** Die Export-Skripte (`Export-PtoPVorlagen.ps1`, `Import-PtoPVorlagen.ps1`) sind
**Teil des Hauptprojekts** und werden bei Bedarf verwendet. Sie müssen nicht vorher ausgeführt
werden – das Hauptprojekt ist vollständig ohne Export nutzbar.

### 6.7 Geplant: Vorlagen-Repo als eigenständiges WPF-Projekt

In einer späteren Phase soll `Export-PtoPVorlagen.ps1` so erweitert werden, dass das
exportierte Repository ein **eigenständiges, lauffähiges WPF-Projekt** wird:

```
Windows-Programm-Vorlagen (als eigenständiges Projekt)
┌──────────────────────────────────────────┐
│ Windows-Programm-Vorlagen.csproj ← .NET 8 WPF │
│ Windows-Programm-Vorlagen.sln    ← VS Solution │
│ App.xaml / .cs          ← Themes laden    │
│ MainWindow.xaml / .cs   ← Demo/Showcase   │
│ Beispiele/              ← BeispielDialog  │
│ Themes/                 ← Farben, Styles  │
│ Base/                   ← BaseWindow      │
│ Helpers/                ← WindowHelper    │
│ Vorlagen/               ← Lebende Vorl.   │
│ ItemTemplates/          ← VS Templates    │
│ docs/                   ← Dokumentation   │
│ Skripte (.ps1)          ← Export/Import   │
└──────────────────────────────────────────┘
```

Damit kann man:
- ✅ Das Repo direkt in VS öffnen (als eigenständiges Projekt)
- ✅ Vorlagen im Designer bearbeiten und mit F5 testen
- ✅ Die Demo-MainWindow als Showcase nutzen
- ✅ Änderungen committen und pushen
- ✅ In neue Projekte mit `Import-PtoPVorlagen.ps1` importieren

---

## 7. Wichtige Regeln

1. **Farben NIE direkt in Fenstern setzen** – immer `{StaticResource Brush.XXX}` verwenden.
2. **Button-Styles NIE kopieren** – immer `Style="{StaticResource DangerButton}"` etc.
3. **Neue Dialoge von `BaseWindow` ableiten** – nicht von `Window`.
4. **Vorlagen-Ordner nicht löschen** – er ist die editierbare Quelle für die Templates.
5. **Nach Vorlagen-Änderung immer `Export-ItemTemplates.ps1` ausführen.**
6. **Nach Verbesserungen `Export-PtoPVorlagen.ps1` ausführen** um das Vorlagen-Repo zu aktualisieren.
7. **Erst im Hauptprojekt entwickeln & testen, dann exportieren** – nicht umgekehrt.

---

## 8. Schritt-für-Schritt: Einbindung in ein neues WPF-Projekt (Visual Studio)

Diese Anleitung zeigt, wie Sie die Vorlagen in ein **komplett neues** WPF-Projekt einbinden.

### 8.1 Voraussetzungen

- Visual Studio 2022 (17.x)
- .NET 8 SDK
- Git installiert
- Das Vorlagen-Repo geklont (einmalig):
  ```powershell
  git clone https://github.com/holger53/Windows-Programm-Vorlagen.git C:\repos\Windows-Programm-Vorlagen
  ```

### 8.2 Neues WPF-Projekt erstellen

1. **Visual Studio** → **Neues Projekt erstellen**
2. Vorlage wählen: **WPF-Anwendung** (.NET 8)
3. Projektname eingeben, z.B. `MeineApp`
4. Erstellen klicken

### 8.3 Vorlagen importieren

```powershell
# PowerShell im Projektverzeichnis öffnen
C:\repos\Windows-Programm-Vorlagen\Import-PtoPVorlagen.ps1 `
    -ProjektPfad "C:\Users\<user>\source\repos\MeineApp" `
    -Namespace "MeineApp"
```

Das Skript kopiert automatisch:
- `Themes/` (Controls.xaml, Colors.xaml, Typography.xaml)
- `Base/` (BaseWindow.cs)
- `Helpers/` (WindowHelper.cs)
- `Vorlagen/` (3 lebende Vorlagen)
- `ItemTemplates/` (VS Item Templates)
- `docs/` (diese Dokumentation)
- PowerShell-Skripte

Alle Namespaces werden automatisch von `PtoP_Windows_Urversion` → `MeineApp` angepasst.

### 8.4 .csproj anpassen

In der `.csproj`-Datei die ItemTemplates vom Build ausschließen:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <UseWPF>true</UseWPF>
  </PropertyGroup>

  <!-- ItemTemplates sind keine kompilierbaren Dateien -->
  <ItemGroup>
    <None Remove="ItemTemplates\**" />
    <Compile Remove="ItemTemplates\**" />
    <Page Remove="ItemTemplates\**" />
  </ItemGroup>
</Project>
```

### 8.5 App.xaml anpassen

Die Theme-ResourceDictionaries einbinden:

```xml
<Application x:Class="MeineApp.App"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             StartupUri="MainWindow.xaml">
    <Application.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <!-- Reihenfolge wichtig: Controls VOR Typography -->
                <ResourceDictionary Source="Themes/Controls.xaml"/>
                <ResourceDictionary Source="Themes/Typography.xaml"/>
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Application.Resources>
</Application>
```

### 8.6 VS Item Templates installieren

```powershell
# Im Projektverzeichnis ausführen
.\Export-ItemTemplates.ps1
```

Danach **Visual Studio neu starten**.

### 8.7 Neues Fenster mit Template anlegen

1. **Rechtsklick auf Projekt** → **Hinzufügen** → **Neues Element…**
2. Im Suchfeld **"PtoP"** eingeben
3. Vorlage auswählen:
   - **PtoP Einfacher Dialog** – Formular mit Eingabefeldern
   - **PtoP Listen-Dialog** – ListBox + Detail-Bereich
   - **PtoP Hauptfenster** – Hauptfenster mit Toolbar
4. Namen eingeben (z.B. `KundenDialog`) → **Hinzufügen**

Visual Studio erstellt `.xaml` + `.xaml.cs` mit korrektem Namespace.

### 8.8 Hauptfenster mit PtoP-Style verwenden

Um das Hauptfenster mit dem PtoP-WindowChrome zu versehen:

```xml
<Window x:Class="MeineApp.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Meine App"
        Height="600" Width="800"
        Style="{StaticResource PtoPWindow}">

    <DockPanel>
        <!-- Button-Leiste unten -->
        <Border DockPanel.Dock="Bottom"
                Background="{StaticResource Brush.ButtonPanel}"
                BorderBrush="{StaticResource Brush.Border}"
                BorderThickness="1"
                CornerRadius="10"
                Padding="16,6"
                Margin="24,4,24,8">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                <Button Content="Speichern" MinWidth="120" Margin="0,0,12,0"
                        Style="{StaticResource SaveButton}"/>
                <Button Content="Beenden" MinWidth="120"
                        Style="{StaticResource DangerButton}"/>
            </StackPanel>
        </Border>

        <!-- Inhalt -->
        <ScrollViewer VerticalScrollBarVisibility="Auto" Padding="24">
            <StackPanel Margin="24">
                <TextBlock Text="Willkommen" FontSize="22" FontWeight="SemiBold"/>
            </StackPanel>
        </ScrollViewer>
    </DockPanel>
</Window>
```

### 8.9 Dialog mit BaseWindow erstellen

```xml
<b:BaseWindow x:Class="MeineApp.KundenDialog"
              xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
              xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
              xmlns:b="clr-namespace:MeineApp.Base"
              Title="Kunden bearbeiten"
              Height="400" Width="500"
              ShowOkButton="True"
              OkButtonText="Speichern"
              OkButtonToolTip="Kundendaten speichern"
              ShowCancelButton="True"
              CancelButtonToolTip="Dialog schließen ohne zu speichern"
              ShowDeleteButton="True"
              DeleteButtonText="Kunde löschen"
              DeleteButtonToolTip="Kundendaten endgültig löschen">

    <StackPanel Margin="24">
        <TextBlock Text="Kundenname:" Margin="0,0,0,4"/>
        <TextBox x:Name="txtName" Margin="0,0,0,12"/>
        <TextBlock Text="E-Mail:" Margin="0,0,0,4"/>
        <TextBox x:Name="txtEmail"/>
    </StackPanel>
</b:BaseWindow>
```

```csharp
namespace MeineApp;

public partial class KundenDialog : Base.BaseWindow
{
    public KundenDialog()
    {
        InitializeComponent();
    }
}
```

### 8.10 Checkliste nach der Einbindung

- [ ] `Import-PtoPVorlagen.ps1` erfolgreich ausgeführt
- [ ] `.csproj`: ItemTemplates-Ausschluss hinzugefügt
- [ ] `App.xaml`: Controls.xaml + Typography.xaml eingebunden
- [ ] Projekt kompiliert ohne Fehler (F6)
- [ ] `Export-ItemTemplates.ps1` ausgeführt + VS neu gestartet
- [ ] Neues Element → "PtoP" → Templates werden angezeigt
- [ ] Test: Neuen Dialog erstellt und mit F5 geöffnet
