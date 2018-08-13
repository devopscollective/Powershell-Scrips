<#
V1.3
Synopsis- Tool to inventory a remote computers list of installed software and then give you an option to uninstall software from that list.
Usage- Double click script to launch and it will reopen as admin and prompt for credentials.
#>

param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

'running with full privileges'

Function Get-Software  {

    [OutputType('System.Software.Inventory')]
  
    [Cmdletbinding()] 
  
    Param( 
  
    [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
  
    [String[]]$Computername=$env:computername
  
    )         
  
    Begin {
  
    }
  
    Process  {     
  
    ForEach  ($Computer in  $Computername){ 
  
    If  (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {
  
    $Paths  = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
  
    ForEach($Path in $Paths) { 
  
    Write-Verbose  "Checking Path: $Path"
  
    #  Create an instance of the Registry Object and open the HKLM base key 
  
    Try  { 
  
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Computer,'Registry64') 
  
    } Catch  { 
  
    Write-Error $_ 
  
    Continue 
  
    } 
  
    #  Drill down into the Uninstall key using the OpenSubKey Method 
  
    Try  {
  
    $regkey=$reg.OpenSubKey($Path)  
  
    # Retrieve an array of string that contain all the subkey names 
  
    $subkeys=$regkey.GetSubKeyNames()      
  
    # Open each Subkey and use GetValue Method to return the required  values for each 
  
    ForEach ($key in $subkeys){   
  
    Write-Verbose "Key: $Key"
  
    $thisKey=$Path+"\\"+$key 
  
    Try {  
  
    $thisSubKey=$reg.OpenSubKey($thisKey)   
  
    # Prevent Objects with empty DisplayName 
  
    $DisplayName =  $thisSubKey.getValue("DisplayName")
  
    If ($DisplayName  -AND $DisplayName  -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {
  
    $Date = $thisSubKey.GetValue('InstallDate')
  
    If ($Date) {
  
    Try {
  
    $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
  
    } Catch{
  
    Write-Warning "$($Computer): $_ <$($Date)>"
  
    $Date = $Null
  
    }
  
    } 
  
    # Create New Object with empty Properties 
  
    $Publisher =  Try {
  
    $thisSubKey.GetValue('Publisher').Trim()
  
    } 
  
    Catch {
  
    $thisSubKey.GetValue('Publisher')
  
    }
  
    $Version = Try {
  
    #Some weirdness with trailing [char]0 on some strings
  
    $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))
  
    } 
  
    Catch {
  
    $thisSubKey.GetValue('DisplayVersion')
  
    }
  
    $UninstallString =  Try {
  
    $thisSubKey.GetValue('UninstallString').Trim()
  
    } 
  
    Catch {
  
    $thisSubKey.GetValue('UninstallString')
  
    }
  
    $InstallLocation =  Try {
  
    $thisSubKey.GetValue('InstallLocation').Trim()
  
    } 
  
    Catch {
  
    $thisSubKey.GetValue('InstallLocation')
  
    }
  
    $InstallSource =  Try {
  
    $thisSubKey.GetValue('InstallSource').Trim()
  
    } 
  
    Catch {
  
    $thisSubKey.GetValue('InstallSource')
  
    }
  
    $HelpLink = Try {
  
    $thisSubKey.GetValue('HelpLink').Trim()
  
    } 
  
    Catch {
  
    $thisSubKey.GetValue('HelpLink')
  
    }
  
    $Object = [pscustomobject]@{
  
    Computername = $Computer
  
    DisplayName = $DisplayName
  
    Version  = $Version
  
    InstallDate = $Date
  
    Publisher = $Publisher
  
    UninstallString = $UninstallString
  
    InstallLocation = $InstallLocation
  
    InstallSource  = $InstallSource
  
    HelpLink = $thisSubKey.GetValue('HelpLink')
  
    EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize')*1024)/1MB,2))
  
    }
  
    $Object.pstypenames.insert(0,'System.Software.Inventory')
  
    Write-Output $Object
  
    }
  
    } Catch {
  
    Write-Warning "$Key : $_"
  
    }   
  
    }
  
    } Catch  {}   
  
    $reg.Close() 
  
    }                  
  
    } Else  {
  
    Write-Error  "$($Computer): unable to reach remote system!"
  
    }
  
    } 
  
    } 
  
  }

$pc = Read-host "Enter a Machine Name"
do
{
$a = Read-Host -Prompt "
`n1. Inventory Software for $pc
`n2. Remove Software for $pc
`n3. EXIT
`nPlease select a number"
switch ($a) {
    1{$n = Get-Software -ComputerName $pc 
        $n = $n | ?  {$_.DisplayName -notmatch "Update"} |
        ? {$_.DisplayName -notmatch "Service Pack"} 
        $n | Out-GridView}
    2{$appName = Read-host "Enter an Application Name" 
    $app = Get-Software -computerName $pc | Where-Object {$_.Name -Match $appName}
    $app.Uninstall()}
    3{exit} 
}
}
until ($input -eq 'q')
