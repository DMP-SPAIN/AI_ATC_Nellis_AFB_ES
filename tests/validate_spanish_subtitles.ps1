$ErrorActionPreference = 'Stop'

$subtitleFiles = @(
    'Lua files\Nellis AFB\AI_ATC_Nellis_v2.9.27.es.lua',
    'Lua files\Creech AFB\AI_ATC_Creech_v2.9.27.es.lua',
    'Lua files\Silverbow AF\AI_ATC_Silverbow_v2.9.27.es.lua'
)

$forbiddenFragments = @(
    'Strong vientos blowing',
    'Departure frequency',
    'Maintain at or below',
    'Turn .* heading .* for .* departure',
    'Contact tower',
    'Taxi via',
    'Your number .* in line for departure',
    'follow the .* in front of you',
    'behind the .* on taxiway',
    'bound traffic',
    'Depart field',
    'Ascenso rápido to',
    'remain clear',
    'Fly Rumbo',
    'Cleared entry',
    'SCHEDULED airspace',
    'Range altimeter',
    'PAR aproximación to',
    'Expect PAR approach',
    'Wind .* at',
    'Altimeter',
    'Maintain at or above',
    'fly heading',
    'Intercept the .* radial',
    'Climb and maintain',
    'Say request',
    'cancellation recieved',
    'cancellation received',
    'contactee',
    'contact tower',
    'Join .* or below',
    'Join .* downwind at or below',
    'Make aproximación straight in to',
    'to pista',
    'vire out autorizado',
    'left vire',
    'over aproximación lights',
    'Aproximación Glidepath',
    'and you.?ll be in parking space',
    'Slightly below glidepath',
    'Well below glidepath',
    'Slightly above glidepath',
    'Well above glidepath',
    'Slightly left of course',
    'Slightly right of course',
    'Well left of course',
    'Well right of course',
    'left of course',
    'right of course',
    'On course',
    'on glidepath',
    'Going left of course',
    'Going right of course',
    'increase rate of descent',
    'decrease rate of descent',
    'Left turn, direct',
    'Vire left direct',
    'Vire right direct',
    'Left turn',
    'Right turn',
    'on outside viento de cola'
)

$failures = @()
foreach ($path in $subtitleFiles) {
    $lines = Get-Content -LiteralPath $path
    foreach ($line in $lines) {
        if ($line -notmatch '(?i)subtitle|instruction|turnsub|navsubtitle|sequencesub|trafficsub|reportsub') { continue }
        $visible = $line
        $assignment = [regex]::Match($line, '(?i)\bsubtitle\d*\s*=')
        if ($assignment.Success) {
            $visible = $line.Substring($assignment.Index + $assignment.Length)
        }
        foreach ($fragment in $forbiddenFragments) {
            if ($visible -match $fragment) {
                $failures += "${path}: $line"
                break
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "Hay $($failures.Count) subtítulos con restos de inglés."
}

Write-Output 'Spanish subtitles contract: PASS'
