$ErrorActionPreference = 'Stop'

$files = @(
    'Lua files\Nellis AFB\AI_ATC_Nellis_v2.9.27.es.lua',
    'Lua files\Creech AFB\AI_ATC_Creech_v2.9.27.es.lua',
    'Lua files\Silverbow AF\AI_ATC_Silverbow_v2.9.27.es.lua'
)

$forbidden = @(
    'HoverCheck\(Alias, "(Tierra|Torre)"\)',
    'CancelIFR\(Alias, "Torre"\)',
    'WingmanReportBase\(Alias, "(Aproximación baja|Procedimiento opción)"',
    'SetCallsign\(Alias, "Fuerte"'
)

$required = @(
    'HoverCheck\(Alias, "(Ground|Tower)"\)',
    'CancelIFR\(Alias, "Tower"\)',
    'WingmanReportBase\(Alias, "(Low Approach|Option)"',
    'SetCallsign\(Alias, "Heavy"'
)

foreach ($file in $files) {
    $content = Get-Content -Raw -LiteralPath $file
    foreach ($pattern in $forbidden) {
        if ($content -match $pattern) {
            throw "Contrato roto en ${file}: se encontró '$pattern'."
        }
    }
    foreach ($pattern in $required) {
        if ($content -notmatch $pattern) {
            throw "Contrato incompleto en ${file}: falta '$pattern'."
        }
    }
}

Write-Output "Spanish internal-key contracts: PASS ($($files.Count) files)"
