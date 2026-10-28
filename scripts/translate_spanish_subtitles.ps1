$ErrorActionPreference = 'Stop'

$subtitleFiles = @(
    'Lua files\Nellis AFB\AI_ATC_Nellis_v2.9.27.es.lua',
    'Lua files\Creech AFB\AI_ATC_Creech_v2.9.27.es.lua',
    'Lua files\Silverbow AF\AI_ATC_Silverbow_v2.9.27.es.lua'
)

# Estas sustituciones solo afectan a texto mostrado como subtítulo. Las claves
# internas de estado, los nombres de audio y las órdenes de radio permanecen en
# inglés porque el runtime las usa para resolver la lógica de AI_ATC.
$subtitleValuePairs = [ordered]@{
    'subtitle = "at High Key"' = 'subtitle = "en punto alto"'
    'subtitle = "at Low Key"' = 'subtitle = "en punto bajo"'
    'subtitle = "going around"' = 'subtitle = "aproximación frustrada"'
    'subtitle = "on outside viento de cola"' = 'subtitle = "en viento de cola exterior"'
    'subtitle = "re-entering Initial"' = 'subtitle = "reincorporándose al tramo inicial"'
    'subtitle = "Slightly above glidepath"' = 'subtitle = "Ligeramente por encima de la senda de planeo"'
    'subtitle = "Slightly below glidepath"' = 'subtitle = "Ligeramente por debajo de la senda de planeo"'
    'subtitle = "Well above glidepath"' = 'subtitle = "Muy por encima de la senda de planeo"'
    'subtitle = "Well below glidepath"' = 'subtitle = "Muy por debajo de la senda de planeo"'
    'subtitle = "Slightly left of course"' = 'subtitle = "Ligeramente a la izquierda del rumbo"'
    'subtitle = "Slightly right of course"' = 'subtitle = "Ligeramente a la derecha del rumbo"'
    'subtitle = "left of course"' = 'subtitle = "a la izquierda del rumbo"'
    'subtitle = "right of course"' = 'subtitle = "a la derecha del rumbo"'
    'subtitle = "Well left of course"' = 'subtitle = "Muy a la izquierda del rumbo"'
    'subtitle = "Well right of course"' = 'subtitle = "Muy a la derecha del rumbo"'
    'subtitle = "On course"' = 'subtitle = "En rumbo"'
    'subtitle = "on glidepath"' = 'subtitle = "en la senda de planeo"'
    'subtitle = "Going left of course slowly"' = 'subtitle = "Desviándose lentamente a la izquierda del rumbo"'
    'subtitle = "Going left of course rapidly"' = 'subtitle = "Desviándose rápidamente a la izquierda del rumbo"'
    'subtitle = "Going right of course slowly"' = 'subtitle = "Desviándose lentamente a la derecha del rumbo"'
    'subtitle = "Going right of course rapidly"' = 'subtitle = "Desviándose rápidamente a la derecha del rumbo"'
    'subtitle = "and correcting"' = 'subtitle = "y corrigiendo"'
    'subtitle = "and holding"' = 'subtitle = "y manteniendo"'
    'subtitle = "and coming up"' = 'subtitle = "y ascendiendo"'
    'subtitle = "and coming down"' = 'subtitle = "y descendiendo"'
    'subtitle = "increase rate of descent"' = 'subtitle = "aumente la razón de descenso"'
    'subtitle = "decrease rate of descent"' = 'subtitle = "disminuya la razón de descenso"'
    'subtitle = "Climb NOW!"' = 'subtitle = "¡Ascienda AHORA!"'
    'subtitle = "Left turn, direct JAYSN"' = 'subtitle = "Vire a la izquierda directo a JAYSN"'
    'subtitle = "Vire left direct ESSAA"' = 'subtitle = "Vire a la izquierda directo a ESSAA"'
    'subtitle = "Vire right direct ESSAA"' = 'subtitle = "Vire a la derecha directo a ESSAA"'
}

$phrasePairs = [ordered]@{
    'Strong vientos blowing' = 'Viento fuerte soplando'
    'Departure frequency 385.4. Squawk ' = 'Frecuencia de salida 385.4. Transpondedor '
    'Maintain at or below 4000 on departure. Contact departure on 385.4, Squawk ' = 'Mantenga 4000 o menos en salida. Contacte salida en 385.4. Transpondedor '
    'Contact tower holding short of Jolly.' = 'Contacte torre y manténgase antes de Jolly.'
    'Contact tower holding short runway ' = 'Contacte torre y manténgase antes de la pista '
    'Turn %s heading %s for %s departure.' = 'Vire %s rumbo %s para la salida %s.'
    'Depart field y remain clear de pista %s, Extreme la precaución' = 'Abandone el campo y manténgase fuera de la pista %s. Extreme la precaución'
    'Depart field y Remain clear de pista %s. Extreme la precaución.' = 'Abandone el campo y manténgase fuera de la pista %s. Extreme la precaución.'
    'Ascenso rápido to %s autorizado.' = 'Ascenso rápido a %s autorizado.'
    'Cleared entry to SCHEDULED airspace. Range altimeter ' = 'Entrada autorizada al espacio aéreo PROGRAMADO. Altímetro de zona '
    'Cleared entry at %s. Range altimeter ' = 'Entrada autorizada en %s. Altímetro de zona '
    'Fly Rumbo ' = 'vuele rumbo '
    'Expect PAR approach to Runway ' = 'Espere aproximación PAR a la pista '
    'Espere PAR aproximación to Pista ' = 'Espere aproximación PAR a la pista '
    'Wind %s at %s. Altimeter ' = 'Viento %s a %s. Altímetro '
    'Altimeter ' = 'Altímetro '
    'Maintain at or above %s until %s' = 'Mantenga %s o más hasta %s'
    'Maintain at or above %s. %s' = 'Mantenga %s o más. %s'
    'fly heading %s. Intercept the 358 radial. Climb and maintain %s. Say request?' = 'vuele rumbo %s. Intercepte la radial 358. Ascienda y mantenga %s. ¿Indique su solicitud?'
    'fly heading %s Maintain at or above %s.' = 'vuele rumbo %s. Mantenga %s o más.'
    'fly heading %s' = 'vuele rumbo %s'
    'Vectors for %s, fly heading %s' = 'Vectores para %s, vuele rumbo %s'
    'Nellis Control, fly heading %s' = 'Nellis Control, vuele rumbo %s'
    'bound tráfico' = 'tráfico en dirección'
    'bound traffic' = 'tráfico en dirección'
    'contactee' = 'contacte con'
    'cancellation recieved' = 'cancelación recibida'
    'cancellation received' = 'cancelación recibida'
    'Join %s viento de cola a or below 3600' = 'Incorpórese al viento de cola %s a 3600 o menos'
    'Join %s viento de cola a or below 3900' = 'Incorpórese al viento de cola %s a 3900 o menos'
    'Join %s downwind at or below 3900' = 'Incorpórese al viento de cola %s a 3900 o menos'
    'Make aproximación straight in to Jolly pad.' = 'Realice aproximación directa al punto Jolly.'
    'to pista' = 'a la pista'
    'vire out autorizado' = 'viraje exterior autorizado'
    'over aproximación lights.' = 'sobre las luces de aproximación.'
    'Aproximación Glidepath' = 'Aproximación por senda de planeo'
    'and you''ll be in parking space ' = 'y entrará en el puesto de estacionamiento '
    'left vire Juliett' = 'vire a la izquierda hacia Juliett'
    'Tanker B.R.A' = 'Avión cisterna B.R.A'
    'Your number %s in line for departure' = 'Su número %s en la cola de salida'
    'follow the %s in front of you' = 'siga al %s que tiene delante'
    'behind the %s on taxiway %s' = 'detrás del %s en la calle de rodaje %s'
    'Contact Nellis Control on 254.4, Squawk ' = 'Contacte Nellis Control en 254.4. Transpondedor '
    'Squawk ' = 'Transpondedor '
    'UHF Channel ' = 'canal UHF '
    ' recovery' = ' procedimiento de recuperación'
    'Radar Contact.' = 'Contacto radar.'
    'Turn %s heading %s' = 'Vire %s rumbo %s'
    'Report %s' = 'Informe %s'
    ' heading ' = ' rumbo '
    ' transition.' = ' transición.'
    'Left turn' = 'Vire a la izquierda'
    'Right turn' = 'Vire a la derecha'
    'Subtitle = "Left turn, direct JAYSN"' = 'Subtitle = "Vire a la izquierda directo a JAYSN"'
    'Subtitle = "Vire left direct ESSAA"' = 'Subtitle = "Vire a la izquierda directo a ESSAA"'
    'Subtitle = "Vire right direct ESSAA"' = 'Subtitle = "Vire a la derecha directo a ESSAA"'
}

$utf8NoBom = [Text.UTF8Encoding]::new($false)
$total = 0

foreach ($relativePath in $subtitleFiles) {
    $fullPath = (Resolve-Path -LiteralPath $relativePath).Path
    $content = [IO.File]::ReadAllText($fullPath)
    $updated = [regex]::Replace($content, '(?m)^[^\r\n]*', {
        param($match)
        $line = $match.Value
        if ($line -notmatch '(?i)\w*subtitle\w*|\w*turnsub\w*|\w*navsubtitle\w*|\w*sequencesub\w*|\w*trafficsub\w*|\w*reportsub\w*|\w*instruction\w*') {
            return $line
        }

        $before = $line
        foreach ($pair in $subtitleValuePairs.GetEnumerator()) {
            $line = $line.Replace($pair.Key, $pair.Value)
        }
        foreach ($pair in $phrasePairs.GetEnumerator()) {
            $line = $line.Replace($pair.Key, $pair.Value)
        }
        if ($line -ne $before) { $script:total++ }
        return $line
    })
    [IO.File]::WriteAllText($fullPath, $updated, $utf8NoBom)
    Write-Output "${relativePath}: actualizado"
}

Write-Output "Líneas de subtítulo actualizadas: $total"
