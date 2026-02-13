# ──────────────────────────────────────────────────────────
# Update-Vorlage.ps1
#
# Kopiert ein fertiges Fenster zurueck in eine Vorlage.
# Das urspruengliche Template wird ueberschrieben.
#
# Nutzung:
#   .\Update-Vorlage.ps1 -Quelle KundenDialog -Vorlage VorlageEinfacherDialog
#   .\Update-Vorlage.ps1 -Quelle MeinListenFenster -Vorlage VorlageListenDialog
#   .\Update-Vorlage.ps1 -Quelle NeuesHauptfenster -Vorlage VorlageHauptfenster
#
# Danach: .\Export-ItemTemplates.ps1 ausfuehren um die VS-Templates zu aktualisieren.
# ──────────────────────────────────────────────────────────

param(
    [Parameter(Mandatory=$true)]
    [string]$Quelle,       # Klassenname des fertigen Fensters (z.B. "KundenDialog")

    [Parameter(Mandatory=$true)]
    [ValidateSet("VorlageEinfacherDialog", "VorlageListenDialog", "VorlageHauptfenster")]
    [string]$Vorlage       # Ziel-Vorlage die ueberschrieben werden soll
)

$ErrorActionPreference = "Stop"

$scriptDir      = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootNamespace  = "PtoP_Windows_Urversion"
$vorlagenDir    = Join-Path $scriptDir "Vorlagen"
$vorlagenNs     = "$rootNamespace.Vorlagen"

# ── Quelldateien suchen ──
# Suche rekursiv im Projekt (aber nicht in Vorlagen/ oder ItemTemplates/)
$xamlFile = Get-ChildItem -Path $scriptDir -Filter "$Quelle.xaml" -Recurse |
    Where-Object { $_.FullName -notmatch '\\Vorlagen\\' -and
                   $_.FullName -notmatch '\\ItemTemplates\\' -and
                   $_.FullName -notmatch '\\bin\\' -and
                   $_.FullName -notmatch '\\obj\\' -and
                   $_.Name -eq "$Quelle.xaml" } |
    Select-Object -First 1

$csFile = Get-ChildItem -Path $scriptDir -Filter "$Quelle.xaml.cs" -Recurse |
    Where-Object { $_.FullName -notmatch '\\Vorlagen\\' -and
                   $_.FullName -notmatch '\\ItemTemplates\\' -and
                   $_.FullName -notmatch '\\bin\\' -and
                   $_.FullName -notmatch '\\obj\\' -and
                   $_.Name -eq "$Quelle.xaml.cs" } |
    Select-Object -First 1

if (-not $xamlFile) {
    Write-Host "FEHLER: $Quelle.xaml nicht gefunden!" -ForegroundColor Red
    Write-Host "Gesucht wurde im Projektordner (ohne Vorlagen/ und ItemTemplates/)." -ForegroundColor Yellow
    exit 1
}

if (-not $csFile) {
    Write-Host "FEHLER: $Quelle.xaml.cs nicht gefunden!" -ForegroundColor Red
    exit 1
}

Write-Host "Quelle gefunden:" -ForegroundColor Cyan
Write-Host "  XAML: $($xamlFile.FullName)"
Write-Host "  CS:   $($csFile.FullName)"
Write-Host ""

# ── Quell-Namespace ermitteln ──
# Aus der XAML x:Class den tatsaechlichen Namespace extrahieren
$xamlContent = Get-Content $xamlFile.FullName -Raw -Encoding UTF8
$csContent   = Get-Content $csFile.FullName   -Raw -Encoding UTF8

# Quell-Namespace aus x:Class extrahieren (z.B. "PtoP_Windows_Urversion.Dialoge.KundenDialog")
if ($xamlContent -match 'x:Class="([^"]+)"') {
    $fullClassName = $Matches[1]
    $quelleNamespace = $fullClassName.Substring(0, $fullClassName.LastIndexOf('.'))
} else {
    Write-Host "FEHLER: x:Class nicht in XAML gefunden!" -ForegroundColor Red
    exit 1
}

Write-Host "Quell-Namespace: $quelleNamespace" -ForegroundColor Gray
Write-Host "Quell-Klasse:    $Quelle" -ForegroundColor Gray
Write-Host ""

# ── Umwandlung: Fertiges Fenster → Vorlage ──
$newXaml = $xamlContent
$newCs   = $csContent

# Namespace ersetzen → Vorlagen-Namespace
$newXaml = $newXaml -replace [regex]::Escape("$quelleNamespace.$Quelle"), "$vorlagenNs.$Vorlage"
$newXaml = $newXaml -replace [regex]::Escape($quelleNamespace),           $vorlagenNs

# Klassenname ersetzen
$newXaml = $newXaml -replace [regex]::Escape($Quelle), $Vorlage

# Code-Behind anpassen
$newCs = $newCs -replace [regex]::Escape("$quelleNamespace"),  $vorlagenNs
$newCs = $newCs -replace [regex]::Escape($Quelle),            $Vorlage

# ── Vorlagen-Dateien ueberschreiben ──
$targetXaml = Join-Path $vorlagenDir "$Vorlage.xaml"
$targetCs   = Join-Path $vorlagenDir "$Vorlage.xaml.cs"

# Backup erstellen
if (Test-Path $targetXaml) {
    Copy-Item $targetXaml "$targetXaml.bak" -Force
    Copy-Item $targetCs   "$targetCs.bak"   -Force
    Write-Host "Backup erstellt (.bak Dateien)" -ForegroundColor Gray
}

Set-Content -Path $targetXaml -Value $newXaml -Encoding UTF8
Set-Content -Path $targetCs   -Value $newCs   -Encoding UTF8

Write-Host "Vorlage ueberschrieben:" -ForegroundColor Green
Write-Host "  $targetXaml" -ForegroundColor Green
Write-Host "  $targetCs" -ForegroundColor Green
Write-Host ""
Write-Host "Naechster Schritt:" -ForegroundColor Yellow
Write-Host "  .\Export-ItemTemplates.ps1" -ForegroundColor Yellow
Write-Host "  Dann Visual Studio neu starten." -ForegroundColor Yellow
