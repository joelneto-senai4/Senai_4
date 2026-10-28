param([string]$Dispositivo = 'chrome')
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
& 'C:/flutter-stable-3.47.6/flutter/bin/flutter.bat' run -d $Dispositivo
