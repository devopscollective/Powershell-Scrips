<#
.SYNOPSIS
    Gathers all logs from remote system for Incident Response analysis.
.PARAMETER Computername
    -Computername parameter added to $Computername variable.   
.EXAMPLE
    PS C:\Invoke-logs -Computername computername
.NOTES
    Author: Dan Rogers
    Email: daniel.o.rogers@uscis.dhs.gov
    Date: 08/01/2018
#>

Function Invoke-logs {

Param(
    [string[]]$ComputerName = $env:COMPUTERNAME
    )

if(!(test-path c:\temp1\$ComputerName)) {mkdir c:\temp1\$ComputerName}

Copy-Item -Path \\$Computername\c$\ProgramData\McAfee\Solidcore\Logs\* -Destination C:\temp1\$ComputerName

Copy-Item -Path \\$Computername\c$\Windows\System32\LogFiles\Firewall\DomainFW.log -Destination C:\temp1\$ComputerName

Copy-Item -Path \\$Computername\c$\Windows\System32\LogFiles\Firewall\PrivateFW.log -Destination C:\temp1\$ComputerName

Copy-Item -Path \\$Computername\c$\Windows\System32\LogFiles\Firewall\PublicFW.log -Destination C:\temp1\$ComputerName

Copy-Item -Path \\$Computername\c$\Windows\System32\winevt\Logs\Application.evtx -Destination C:\temp1\$ComputerName

Copy-Item -Path \\$Computername\c$\Windows\System32\winevt\Logs\Security.evtx -Destination C:\temp1\$ComputerName

Copy-Item -Path \\$Computername\c$\Windows\System32\winevt\Logs\System.evtx -Destination C:\temp1\$ComputerName

Copy-Item -Path "\\$Computername\c$\ProgramData\McAfee\Endpoint Security\Logs\OnDemandScan_Activity.log" -Destination C:\temp1\$ComputerName

$a = Get-Item c:\temp1\$ComputerName\*.evtx
foreach($file in $a)
{
get-winevent -path $file.FullName | export-csv $file.FullName.replace(".evtx",".csv") -useculture
}

Start C:\temp1\$ComputerName
}
