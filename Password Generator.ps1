<#
.SYNOPSIS
    Generates Random Passwords
.PARAMETER Length
    Integer value that determines the length of the generated password.
.PARAMETER Type
    Determines the character set used for creating passwords.
        Numbers          - 0-9
        HEX              - 0-9 + A-F
        Lower            - a-z
        LowerUpper       - a-z + A-Z
        LowerUpperNumber - a-z + A-Z + 0-9
        All              - a-z + A-Z + 0-9 + `~!@#$%^&*()_-+=[]{}\|;:'",./<>?
.PARAMETER Count
    Specifies the number of passwords to generate.    
.EXAMPLE
    PS C:\Scripts> .\Generate-Password.ps1 -Length 12 -Type All -Count 3
    *Z]Nv_8i\W'2
    Zn-XwT1;'bis
    0F)pI.G(,{-$
    PS C:\Scripts>
#>


# Required Parameters
Param(
    [Parameter(Mandatory=$True)]
    [int]$Length,
    [Parameter(Mandatory=$True)]
    [ValidateSet('Numbers','HEX','Lower','LowerUpper','LowerUpperNumber','All')]
    [string]$Type='All',
    [int]$Count=1
    )

$c=0
while($c -lt $Count){
    $c++
    
    # Numbers
    If($Type -eq 'Numbers'){
        $pw = ([char[]](Get-Random -Input $(48..57) -Count $Length) -join "")
        Write-Host $pw -ForegroundColor Cyan
        }

     # HEX
    If($Type -eq 'HEX'){
        $pw = ([char[]](Get-Random -Input $(48..57 + 65..70) -Count $Length) -join "")
        Write-Host $pw -ForegroundColor Cyan
        }

    # Lowers
    If($Type -eq 'Lower'){
        $pw = ([char[]](Get-Random -Input $(97..122) -Count $Length) -join "")
        Write-Host $pw -ForegroundColor Cyan
        }

    # Lowers and Uppers
    If($Type -eq 'LowerUpper'){
        $pw = ([char[]](Get-Random -Input $(97..122 + 65..90) -Count $Length) -join "")
        Write-Host $pw -ForegroundColor Cyan
        }

    # Lowers, Uppers, and Numbers
    If($Type -eq 'LowerUpperNumber'){
        $pw = ([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122) -Count $Length) -join "")
        Write-Host $pw -ForegroundColor Cyan
        }

    # All (Lowers, Uppers, Numbers, and Special)
    If($Type -eq 'All'){
        $pw = ([char[]](Get-Random -Input $(33..126) -Count $Length) -join "")
        Write-Host $pw -ForegroundColor Cyan
        }
    }
