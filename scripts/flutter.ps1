param([Parameter(ValueFromRemainingArguments=$true)][string[]]$FlutterArgs)
$ErrorActionPreference = 'Stop'
$sdk = 'C:\tools\flutter-puzzle-3.47.7\flutter\bin\flutter.bat'
if (-not (Test-Path -LiteralPath $sdk)) {
    throw 'Instala Flutter 3.47.7 en C:\tools\flutter-puzzle-3.47.7\flutter o ajusta scripts/flutter.ps1.'
}
Push-Location (Join-Path $PSScriptRoot '..\flutter_application_1')
try { & $sdk @FlutterArgs; $result = $LASTEXITCODE }
finally { Pop-Location }
exit $result
