<#

    # Synopsis

    Function to search C: for a specific file name.  

    

    # Example

    Get-AppPath

#>
Function Get-AppPath {

 

$pc = Read-Host "Computer Name"

 

$app = Read-Host "Application Name"

 

$found = @()

 

foreach($computer in $pc) {

 

$file = Get-WMiObject -ComputerName $computer -Class CIM_DataFile -Filter "FileName = '$app'"

 

$file | Add-Member -MemberType NoteProperty -Name ComputerName -Value $computer

 

$found += $file

 

}

 

$found | Out-GridView

 

}

 

<#

    # Synopsis

    Function to poll all registry locations for installed software

    

    # Example

    Get-InstalledSoftware -ComputerName dcenocis198*** -DisplayName *mozilla*

#>
function Get-InstalledSoftware {

 

    param

    (

        $DisplayName='*',

 

        $DisplayVersion='*',

 

        $UninstallString='*',

 

        $InstallDate='*'

 

    )

   

    # registry locations where installed software is logged

    $pathAllUser = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

    $pathCurrentUser = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

    $pathAllUser32 = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

    $pathCurrentUser32 = "Registry::HKEY_CURRENT_USER\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

 

  

    # get all values

    Get-ItemProperty -Path $pathAllUser, $pathCurrentUser, $pathAllUser32, $pathCurrentUser32 |

      # choose the values to use

      Select-Object -Property DisplayVersion, DisplayName, UninstallString, InstallDate |

      # skip all values w/o displayname

      Where-Object DisplayName -ne $null |

      # apply user filters submitted via parameter:

      Where-Object DisplayName -like $DisplayName |

      Where-Object DisplayVersion -like $DisplayVersion |

      Where-Object UninstallString -like $UninstallString |

      Where-Object InstallDate -like $InstallDate |

 

      # sort by displayname

      Sort-Object -Property DisplayName

}