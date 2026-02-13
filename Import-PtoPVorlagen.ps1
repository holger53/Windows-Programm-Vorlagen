# ──────────────────────────────────────────────────────────
# Import-PtoPVorlagen.ps1
#
# Importiert das PtoP-Vorlagen-Repository in ein neues
# WPF-Projekt. Passt Namespaces automatisch an.
#
# Nutzung:
#   .\Import-PtoPVorlagen.ps1 -ProjektPfad "C:\repos\MeinProjekt" -Namespace "MeinProjekt"
#
# Was passiert:
#   1. Themes/, Base/, Helpers/, Vorlagen/, docs/ werden kopiert
#   2. Alle Namespaces werden angepasst (PtoP_Windows_Urversion → neuer Namespace)
#   3. Skripte werden kopiert und angepasst
#   4. App.xaml-Eintraege werden angezeigt (zum manuellen Einfuegen)
# ──────────────────────────────────────────────────────────

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjektPfad,

    [Parameter(Mandatory=$true)]
    [string]$Namespace
)

$ErrorActionPreference = "Stop"
$vorlagenDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$quellNamespace = "PtoP_Windows_Urversion"

# ── Validierung ──
if (-not (Test-Path $ProjektPfad)) {
    Write-Host "FEHLER: Projektpfad nicht gefunden: $ProjektPfad" -ForegroundColor Red
    exit 1
}

$csprojFiles = Get-ChildItem -Path $ProjektPfad -Filter "*.csproj" -Recurse -Depth 1
if ($csprojFiles.Count -eq 0) {
    Write-Host "FEHLER: Keine .csproj-Datei gefunden in $ProjektPfad" -ForegroundColor Red
    exit 1
}

Write-Host "PtoP-Vorlagen importieren" -ForegroundColor Cyan
Write-Host "  Quelle:    $vorlagenDir" -ForegroundColor Gray
Write-Host "  Ziel:      $ProjektPfad" -ForegroundColor Gray
Write-Host "  Namespace: $Namespace" -ForegroundColor Gray
Write-Host ""

# ── Ordner kopieren ──
$ordner = @("Themes", "Base", "Helpers", "Vorlagen", "ItemTemplates", "docs")

foreach ($o in $ordner) {
    $quelle = Join-Path $vorlagenDir $o
    $ziel   = Join-Path $ProjektPfad $o

    if (-not (Test-Path $quelle)) { continue }

    if (Test-Path $ziel) {
        Write-Host "  WARNUNG: $o/ existiert bereits – wird uebersprungen" -ForegroundColor Yellow
        Write-Host "           Loeschen Sie den Ordner zuerst oder benennen Sie ihn um." -ForegroundColor Yellow
        continue
    }

    Copy-Item -Path $quelle -Destination $ziel -Recurse -Force
    Write-Host "  Kopiert: $o/" -ForegroundColor Green
}

# ── Skripte kopieren ──
$skripte = @("Export-ItemTemplates.ps1", "Update-Vorlage.ps1")
foreach ($s in $skripte) {
    $quelle = Join-Path $vorlagenDir $s
    $ziel   = Join-Path $ProjektPfad $s
    if (Test-Path $quelle) {
        Copy-Item -Path $quelle -Destination $ziel -Force
        Write-Host "  Kopiert: $s" -ForegroundColor Green
    }
}

# ── Namespaces ersetzen ──
Write-Host ""
Write-Host "Namespaces anpassen ($quellNamespace -> $Namespace)..." -ForegroundColor Cyan

$extensions = @("*.xaml", "*.cs", "*.ps1", "*.md")

foreach ($ext in $extensions) {
    $dateien = Get-ChildItem -Path $ProjektPfad -Filter $ext -Recurse |
        Where-Object { $_.FullName -notmatch '\\bin\\' -and
                       $_.FullName -notmatch '\\obj\\' -and
                       $_.FullName -notmatch '\\.vs\\' -and
                       $_.FullName -notmatch '\\ItemTemplates\\' }

    foreach ($datei in $dateien) {
        $inhalt = Get-Content $datei.FullName -Raw -Encoding UTF8
        if ($inhalt -match [regex]::Escape($quellNamespace)) {
            $neuerInhalt = $inhalt -replace [regex]::Escape($quellNamespace), $Namespace
            Set-Content -Path $datei.FullName -Value $neuerInhalt -Encoding UTF8
            Write-Host "  Angepasst: $($datei.FullName.Replace($ProjektPfad, '.'))" -ForegroundColor DarkGreen
        }
    }
}

# ── ItemTemplates separat anpassen (nutzen $rootnamespace$ statt hartem Namespace) ──
$templateDateien = Get-ChildItem -Path (Join-Path $ProjektPfad "ItemTemplates") -Filter "*.xaml*" -Recurse -ErrorAction SilentlyContinue
foreach ($datei in $templateDateien) {
    $inhalt = Get-Content $datei.FullName -Raw -Encoding UTF8
    if ($inhalt -match [regex]::Escape($quellNamespace)) {
        $neuerInhalt = $inhalt -replace [regex]::Escape($quellNamespace), $Namespace
        Set-Content -Path $datei.FullName -Value $neuerInhalt -Encoding UTF8
        Write-Host "  Angepasst: $($datei.FullName.Replace($ProjektPfad, '.'))" -ForegroundColor DarkGreen
    }
}

# ── .csproj Excludes pruefen ──
$csproj = $csprojFiles | Select-Object -First 1
$csprojInhalt = Get-Content $csproj.FullName -Raw -Encoding UTF8

if ($csprojInhalt -notmatch 'ItemTemplates') {
    Write-Host ""
    Write-Host "WICHTIG: Fuegen Sie folgendes in Ihre .csproj ein," -ForegroundColor Yellow
    Write-Host "damit die ItemTemplates nicht mitkompiliert werden:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host '  <ItemGroup>' -ForegroundColor White
    Write-Host '    <None Remove="ItemTemplates\**" />' -ForegroundColor White
    Write-Host '    <Compile Remove="ItemTemplates\**" />' -ForegroundColor White
    Write-Host '    <Page Remove="ItemTemplates\**" />' -ForegroundColor White
    Write-Host '  </ItemGroup>' -ForegroundColor White
}

# ── App.xaml Hinweis ──
Write-Host ""
Write-Host "WICHTIG: Fuegen Sie folgendes in Ihre App.xaml ein" -ForegroundColor Yellow
Write-Host "(falls nicht bereits vorhanden):" -ForegroundColor Yellow
Write-Host ""
Write-Host '  <Application.Resources>' -ForegroundColor White
Write-Host '      <ResourceDictionary>' -ForegroundColor White
Write-Host '          <ResourceDictionary.MergedDictionaries>' -ForegroundColor White
Write-Host '              <ResourceDictionary Source="Themes/Controls.xaml"/>' -ForegroundColor White
Write-Host '              <ResourceDictionary Source="Themes/Typography.xaml"/>' -ForegroundColor White
Write-Host '          </ResourceDictionary.MergedDictionaries>' -ForegroundColor White
Write-Host '      </ResourceDictionary>' -ForegroundColor White
Write-Host '  </Application.Resources>' -ForegroundColor White

Write-Host ""
Write-Host "Import abgeschlossen!" -ForegroundColor Green
Write-Host ""
Write-Host "Naechste Schritte:" -ForegroundColor Yellow
Write-Host "  1. .csproj-Excludes einfuegen (siehe oben)" -ForegroundColor White
Write-Host "  2. App.xaml ResourceDictionaries einfuegen (siehe oben)" -ForegroundColor White
Write-Host "  3. .\Export-ItemTemplates.ps1 ausfuehren" -ForegroundColor White
Write-Host "  4. Visual Studio neu starten" -ForegroundColor White
