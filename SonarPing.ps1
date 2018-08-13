<#
Synopsis- Script designed to run in the background and ping a remote machine and play a sound when it comes online.
Use Case- Analyst is waiting for a box to come online for analysis (This method will beat the splunk email)
#>

$pc = Read-Host "Enter PC name to monitor by sonar"

$x = 0

Write-Host "Flushing DNS" -ForegroundColor Magenta

ipconfig /flushdns

Write-Host "Pinging $pc by sonar . . . "

Write-Host "(Press Ctrl-C to break out of sonar loop.)"

do

{	$x = $x + 1

if (Test-Connection -count 1 -quiet -computer $pc)

{

[console]::beep(500,600)

Write-host  "Direct Hit!" -foregroundcolor red

Start-Sleep -s 2

}

else

{

#[console]::beep(500,60)

Write-host "Try Again" -foregroundcolor blue

$x = $x + 1

}

}

until

($x = 0)
