param(
    [string]$MissionPath = 'AI_ATC .miz file\AI_ATC_Nellis_v2.10_ES.miz'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$luaMap = [ordered]@{
    'l10n/DEFAULT/AI_ATC_Nellis_v2.9.27.lua' = 'Lua files\Nellis AFB\AI_ATC_Nellis_v2.9.27.es.lua'
    'l10n/DEFAULT/AI_ATC_Creech_v2.9.27.lua' = 'Lua files\Creech AFB\AI_ATC_Creech_v2.9.27.es.lua'
    'l10n/DEFAULT/AI_ATC_Silverbow_v2.9.27.lua' = 'Lua files\Silverbow AF\AI_ATC_Silverbow_v2.9.27.es.lua'
}

$sourcePath = (Resolve-Path -LiteralPath $MissionPath).Path
$tempPath = Join-Path ([IO.Path]::GetDirectoryName($sourcePath)) ([IO.Path]::GetFileNameWithoutExtension($sourcePath) + '.subtitle.tmp.miz')
if (Test-Path -LiteralPath $tempPath) {
    throw "Ya existe el temporal de reconstrucción: $tempPath"
}

$sourceZip = $null
$targetZip = $null
$replaced = 0
try {
    $sourceZip = [IO.Compression.ZipFile]::OpenRead($sourcePath)
    $targetZip = [IO.Compression.ZipFile]::Open($tempPath, [IO.Compression.ZipArchiveMode]::Create)

    foreach ($entry in $sourceZip.Entries) {
        $targetEntry = $targetZip.CreateEntry($entry.FullName, [IO.Compression.CompressionLevel]::Optimal)
        $targetStream = $null
        $sourceStream = $null
        try {
            $targetStream = $targetEntry.Open()
            if ($luaMap.Contains($entry.FullName)) {
                $relativeLuaPath = $luaMap[$entry.FullName]
                $luaPath = (Resolve-Path -LiteralPath $relativeLuaPath).Path
                $bytes = [IO.File]::ReadAllBytes($luaPath)
                $targetStream.Write($bytes, 0, $bytes.Length)
                $replaced++
            } elseif (-not $entry.FullName.EndsWith('/')) {
                $sourceStream = $entry.Open()
                $sourceStream.CopyTo($targetStream)
            }
        } finally {
            if ($sourceStream) { $sourceStream.Dispose() }
            if ($targetStream) { $targetStream.Dispose() }
        }
    }
} finally {
    if ($sourceZip) { $sourceZip.Dispose() }
    if ($targetZip) { $targetZip.Dispose() }
}

if ($replaced -ne $luaMap.Count) {
    throw "Se reemplazaron $replaced Lua de $($luaMap.Count)."
}

$size = (Get-Item -LiteralPath $tempPath).Length
if ($size -ge 100MB) {
    throw "El .miz resultante supera el límite de GitHub: $size bytes."
}

Move-Item -LiteralPath $tempPath -Destination $sourcePath -Force
Write-Output "Miz reconstruido: $MissionPath"
Write-Output "Lua traducidos integrados: $replaced"
Write-Output "Tamaño: $size bytes"
