Get-ChildItem "HKCU:\Software\Microsoft\Terminal Server Client" -Recurse | Remove-ItemProperty -Name UsernameHint -Ea 0
Remove-Item -Path 'HKCU:\Software\Microsoft\Terminal Server Client\Servers' -Recurse  2>&1 | Out-Null
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Terminal Server Client\Default' 'MR*'  2>&1 | Out-Null
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Terminal Server Client\LocalDevices' 'MR*'  2>&1 | Out-Null
$docs = [environment]::getfolderpath("mydocuments") + '\Default.rdp'
remove-item  $docs  -Force  2>&1 | Out-Null
New-Item -Path 'HKCU:\Software\Microsoft\Terminal Server Client\Servers' -type directory 2>&1 | Out-Null