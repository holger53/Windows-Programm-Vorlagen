# ──────────────────────────────────────────────────────────
# Export-ItemTemplates.ps1
#
# Liest die "lebenden Vorlagen" aus dem Vorlagen/-Ordner,
# ersetzt Namespace + Klassenname durch VS-Platzhalter,
# erzeugt die ItemTemplates und installiert sie in VS 2022.
#
# Nutzung:  .\Export-ItemTemplates.ps1
#           dann Visual Studio neu starten.
# ──────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"

$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$vorlagenDir = Join-Path $scriptDir "Vorlagen"
$outputDir   = Join-Path $scriptDir "ItemTemplates"
$vsTargetDir = Join-Path $env:USERPROFILE "Documents\Visual Studio 2022\Templates\ItemTemplates\PtoP"

$rootNamespace = "PtoP_Windows_Urversion"

# ── Template-Definitionen ──
$templates = @(
    @{
        ClassName   = "VorlageEinfacherDialog"
        TemplateName = "PtoP Einfacher Dialog"
        Description = "Ein Dialog mit Formular-Feldern und konfigurierbarer Button-Leiste (Speichern, Abbrechen, Loeschen). Basiert auf BaseWindow."
        DefaultName = "NeuerDialog"
        SortOrder   = 10
        OutputFolder = "PtoP_Dialog_Einfach"
    },
    @{
        ClassName   = "VorlageListenDialog"
        TemplateName = "PtoP Listen-Dialog"
        Description = "Ein Dialog mit grosser ListBox links, Detail-Bereich rechts und konfigurierbarer Button-Leiste. Basiert auf BaseWindow."
        DefaultName = "NeuerListenDialog"
        SortOrder   = 20
        OutputFolder = "PtoP_Dialog_Liste"
    },
    @{
        ClassName   = "VorlageHauptfenster"
        TemplateName = "PtoP Hauptfenster"
        Description = "Ein Hauptfenster mit eigener Titelleiste, Toolbar, Statusleiste und PtoP-Chrome. Basiert auf dem PtoPWindow-Style."
        DefaultName = "NeuesHauptfenster"
        SortOrder   = 30
        OutputFolder = "PtoP_Hauptfenster"
    }
)

# ── Funktion: Platzhalter einsetzen ──
function Convert-ToTemplate {
    param([string]$Content, [string]$ClassName)

    $result = $Content
    # Namespace ersetzen (z.B. PtoP_Windows_Urversion.Vorlagen → $rootnamespace$)
    $result = $result -replace "$rootNamespace\.Vorlagen\.", '$rootnamespace$.'
    $result = $result -replace "$rootNamespace\.Vorlagen",  '$rootnamespace$'
    $result = $result -replace "$rootNamespace\.",           '$rootnamespace$.'
    $result = $result -replace "$rootNamespace",             '$rootnamespace$'
    # Klassenname ersetzen
    $result = $result -replace [regex]::Escape($ClassName),  '$safeitemname$'

    return $result
}

# ── Hauptlogik ──
Write-Host "PtoP Item-Templates exportieren..." -ForegroundColor Cyan
Write-Host ""

foreach ($t in $templates) {
    $className = $t.ClassName
    $outFolder = Join-Path $outputDir $t.OutputFolder

    # Quelldateien lesen
    $xamlPath = Join-Path $vorlagenDir "$className.xaml"
    $csPath   = Join-Path $vorlagenDir "$className.xaml.cs"

    if (-not (Test-Path $xamlPath)) {
        Write-Host "UEBERSPRUNGEN: $xamlPath nicht gefunden" -ForegroundColor Yellow
        continue
    }

    $xamlContent = Get-Content $xamlPath -Raw -Encoding UTF8
    $csContent   = Get-Content $csPath   -Raw -Encoding UTF8

    # Platzhalter einsetzen
    $xamlTemplate = Convert-ToTemplate -Content $xamlContent -ClassName $className
    $csTemplate   = Convert-ToTemplate -Content $csContent   -ClassName $className

    # Ausgabeordner erstellen
    if (Test-Path $outFolder) { Remove-Item $outFolder -Recurse -Force }
    New-Item -ItemType Directory -Path $outFolder -Force | Out-Null

    # Template-Dateien schreiben
    $xamlTemplateName = "$className`Template.xaml"
    $csTemplateName   = "$className`Template.xaml.cs"

    Set-Content -Path (Join-Path $outFolder $xamlTemplateName) -Value $xamlTemplate -Encoding UTF8
    Set-Content -Path (Join-Path $outFolder $csTemplateName)   -Value $csTemplate   -Encoding UTF8

    # .vstemplate erzeugen
    $vstemplateXml = @"
<VSTemplate Version="3.0.0" Type="Item"
            xmlns="http://schemas.microsoft.com/developer/vstemplate/2005">
  <TemplateData>
    <Name>$($t.TemplateName)</Name>
    <Description>$($t.Description)</Description>
    <ProjectType>CSharp</ProjectType>
    <SortOrder>$($t.SortOrder)</SortOrder>
    <DefaultName>$($t.DefaultName)</DefaultName>
  </TemplateData>
  <TemplateContent>
    <References />
    <ProjectItem SubType="Designer"
                 TargetFileName="`$fileinputname`$.xaml"
                 ReplaceParameters="true">$xamlTemplateName</ProjectItem>
    <ProjectItem TargetFileName="`$fileinputname`$.xaml.cs"
                 ReplaceParameters="true">$csTemplateName</ProjectItem>
  </TemplateContent>
</VSTemplate>
"@
    Set-Content -Path (Join-Path $outFolder "$($t.OutputFolder).vstemplate") -Value $vstemplateXml -Encoding UTF8

    Write-Host "  Exportiert: $className -> $($t.OutputFolder)/" -ForegroundColor Green
}

# ── In VS installieren ──
Write-Host ""
Write-Host "Templates in VS 2022 installieren..." -ForegroundColor Cyan

if (-not (Test-Path $vsTargetDir)) {
    New-Item -ItemType Directory -Path $vsTargetDir -Force | Out-Null
}

foreach ($t in $templates) {
    $outFolder = Join-Path $outputDir $t.OutputFolder
    $zipPath   = Join-Path $vsTargetDir "$($t.OutputFolder).zip"

    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Compress-Archive -Path "$outFolder\*" -DestinationPath $zipPath -Force

    Write-Host "  Installiert: $($t.OutputFolder).zip" -ForegroundColor Green
}

Write-Host ""
Write-Host "Fertig! Visual Studio neu starten." -ForegroundColor Green
Write-Host "Neues Element hinzufuegen -> nach 'PtoP' suchen." -ForegroundColor Yellow
