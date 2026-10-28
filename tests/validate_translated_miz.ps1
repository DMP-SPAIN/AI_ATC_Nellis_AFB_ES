param(
    [string]$MissionPath = 'AI_ATC .miz file\AI_ATC_Nellis_v2.10_ES.miz',
    [string]$LuaExecutable = ''
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$originalMissionPath = 'AI_ATC .miz file\AI_ATC_Nellis_v2.10.miz'
$translatedFiles = @{
    'l10n/DEFAULT/AI_ATC_Nellis_v2.9.27.lua' = 'Lua files\Nellis AFB\AI_ATC_Nellis_v2.9.27.es.lua'
    'l10n/DEFAULT/AI_ATC_Creech_v2.9.27.lua' = 'Lua files\Creech AFB\AI_ATC_Creech_v2.9.27.es.lua'
    'l10n/DEFAULT/AI_ATC_Silverbow_v2.9.27.lua' = 'Lua files\Silverbow AF\AI_ATC_Silverbow_v2.9.27.es.lua'
}
$documentationFiles = @(Get-ChildItem -LiteralPath 'Documentation\Spanish' -File | ForEach-Object {
    [PSCustomObject]@{
        ArchiveName = 'Documentation/Spanish/' + $_.Name
        LocalPath = $_.FullName
    }
})
$graphicsPrefix = 'KNEEBOARD/IMAGES/'
$chartDirectory = 'CARTAS_ES'
$nonChartNames = @(
    'AA_localFrequencies.png', 'AAB_Local Frequencies.png', 'AB_Authentication.png',
    'AC_RadioCalls-P1_v2.0.png', 'AD_RadioCalls-P2_v2.0.png', 'AE_RadioCalls-P3_v2.0.png',
    'AF_RadioCalls-P4_v2.0.png', 'AG_RadioCalls-P5_v2.0.png', 'AH_RadioCalls-P6_v2.0.png',
    'AI_RadioCalls-P7_v2.0.png'
)

function Get-StreamHash([System.IO.Stream]$Stream) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($Stream)) -replace '-', '')
    } finally {
        $sha.Dispose()
    }
}

function Get-FileHashValue([string]$Path) {
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        return Get-StreamHash $stream
    } finally {
        $stream.Dispose()
    }
}

function Get-ZipEntryHash([System.IO.Compression.ZipArchiveEntry]$Entry) {
    $stream = $Entry.Open()
    try {
        return Get-StreamHash $stream
    } finally {
        $stream.Dispose()
    }
}

function Save-ZipEntry([System.IO.Compression.ZipArchiveEntry]$Entry, [string]$Path) {
    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $source = $Entry.Open()
    $destination = [System.IO.File]::Create($Path)
    try {
        $source.CopyTo($destination)
    } finally {
        $destination.Dispose()
        $source.Dispose()
    }
}

$mission = (Resolve-Path -LiteralPath $MissionPath).Path
$original = (Resolve-Path -LiteralPath $originalMissionPath).Path
$temp = Join-Path ([IO.Path]::GetTempPath()) ('ai-atc-miz-validation-' + [guid]::NewGuid().ToString('N'))
$sourceZip = [System.IO.Compression.ZipFile]::OpenRead($original)
$missionZip = [System.IO.Compression.ZipFile]::OpenRead($mission)

try {
    $sourceEntries = @{}
    foreach ($entry in $sourceZip.Entries) { $sourceEntries[$entry.FullName] = $entry }
    $missionEntries = @{}
    foreach ($entry in $missionZip.Entries) { $missionEntries[$entry.FullName] = $entry }
    $sourceGraphics = @($sourceEntries.Keys | Where-Object { $_ -like ($graphicsPrefix + '*.png') })
    $missionGraphics = @($missionEntries.Keys | Where-Object { $_ -like ($graphicsPrefix + '*.png') })
    if ($sourceGraphics.Count -ne 48 -or $missionGraphics.Count -ne 48) {
        throw "Se esperaban 48 gráficos internos: original=$($sourceGraphics.Count), traducida=$($missionGraphics.Count)."
    }
    $expectedChartNames = @($sourceGraphics | ForEach-Object { Split-Path -Leaf $_ } | Where-Object { $_ -notin $nonChartNames })
    $chartFiles = @(Get-ChildItem -LiteralPath $chartDirectory -File)
    $actualChartNames = @($chartFiles | Select-Object -ExpandProperty Name)
    if ($actualChartNames.Count -ne 38) {
        throw "Se esperaban 38 cartas externas y hay $($actualChartNames.Count)."
    }
    $missingCharts = @($expectedChartNames | Where-Object { $_ -notin $actualChartNames })
    $unexpectedCharts = @($actualChartNames | Where-Object { $_ -notin $expectedChartNames })
    if ($missingCharts.Count -gt 0 -or $unexpectedCharts.Count -gt 0) {
        throw "La carpeta CARTAS_ES no coincide. Faltan=$($missingCharts -join ', '); sobran=$($unexpectedCharts -join ', ')"
    }

    $allowedDocumentation = @{}
    foreach ($doc in $documentationFiles) { $allowedDocumentation[$doc.ArchiveName] = $doc.LocalPath }
    $unexpectedEntries = @($missionEntries.Keys | Where-Object {
        -not $sourceEntries.ContainsKey($_) -and -not $allowedDocumentation.ContainsKey($_)
    })
    if ($unexpectedEntries.Count -gt 0) {
        throw "Hay entradas inesperadas en la misión traducida: $($unexpectedEntries -join ', ')"
    }

    foreach ($name in $sourceEntries.Keys) {
        if (-not $missionEntries.ContainsKey($name)) {
            throw "Falta en la misión traducida: $name"
        }

        if ($translatedFiles.ContainsKey($name)) {
            $expected = Get-FileHashValue (Resolve-Path -LiteralPath $translatedFiles[$name]).Path
            $actual = Get-ZipEntryHash $missionEntries[$name]
            if ($expected -ne $actual) {
                throw "El Lua integrado no coincide con la traducción: $name"
            }
        } elseif ($name -like ($graphicsPrefix + '*.png')) {
            continue
        } else {
            $expected = Get-ZipEntryHash $sourceEntries[$name]
            $actual = Get-ZipEntryHash $missionEntries[$name]
            if ($expected -ne $actual) {
                throw "Una entrada no traducida ha cambiado: $name"
            }
        }
    }

    foreach ($doc in $documentationFiles) {
        if (-not $missionEntries.ContainsKey($doc.ArchiveName)) {
            throw "Falta el manual integrado: $($doc.ArchiveName)"
        }
        $expected = Get-FileHashValue (Resolve-Path -LiteralPath $doc.LocalPath).Path
        $actual = Get-ZipEntryHash $missionEntries[$doc.ArchiveName]
        if ($expected -ne $actual) {
            throw "El manual integrado no coincide: $($doc.ArchiveName)"
        }
    }

    New-Item -ItemType Directory -Path $temp | Out-Null
    foreach ($name in $translatedFiles.Keys) {
        $target = Join-Path $temp (Split-Path -Leaf $name)
        Save-ZipEntry $missionEntries[$name] $target
        if ($LuaExecutable) {
            & $LuaExecutable -e "assert(loadfile([[$target]]))"
            if ($LASTEXITCODE -ne 0) { throw "Sintaxis Lua inválida: $name" }
        }
    }

    $mapResource = Get-Content -Raw -LiteralPath (Join-Path $temp 'mapResource') -ErrorAction SilentlyContinue
    if (-not $mapResource) {
        $mapPath = Join-Path $temp 'mapResource'
        Save-ZipEntry $missionEntries['l10n/DEFAULT/mapResource'] $mapPath
        $mapResource = Get-Content -Raw -LiteralPath $mapPath
    }
    foreach ($name in $translatedFiles.Keys | ForEach-Object { Split-Path -Leaf $_ }) {
        if ($mapResource -notmatch [regex]::Escape($name)) {
            throw "mapResource no referencia $name"
        }
    }

    $graphicsTemp = Join-Path $temp 'graphics'
    Add-Type -AssemblyName System.Drawing
    foreach ($name in $sourceGraphics) {
        $target = Join-Path $graphicsTemp (Split-Path -Leaf $name)
        Save-ZipEntry $missionEntries[$name] $target
        $image = [System.Drawing.Image]::FromFile($target)
        try {
            if ($image.Width -le 0 -or $image.Height -le 0) { throw "Dimensiones inválidas: $name" }
        } finally {
            $image.Dispose()
        }
    }
    foreach ($name in $expectedChartNames) {
        $archiveName = $graphicsPrefix + $name
        $expected = Get-FileHashValue (Resolve-Path -LiteralPath (Join-Path $chartDirectory $name)).Path
        $actual = Get-ZipEntryHash $missionEntries[$archiveName]
        if ($expected -ne $actual) {
            throw "La carta externa no coincide con la integrada: $name"
        }
    }

    Write-Output "Translated .miz: PASS ($($missionEntries.Count) entradas; $($translatedFiles.Count) Lua integrados; $($documentationFiles.Count) manuales integrados; $($missionGraphics.Count) gráficos internos válidos; $($chartFiles.Count) cartas externas)"
} finally {
    $missionZip.Dispose()
    $sourceZip.Dispose()
    if (Test-Path -LiteralPath $temp) {
        Remove-Item -LiteralPath $temp -Recurse -Force
    }
}
